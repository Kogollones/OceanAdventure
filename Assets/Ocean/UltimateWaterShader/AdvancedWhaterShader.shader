Shader "Custom/UltimateWaterShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _FoamTex ("Foam Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _ReflectionTex ("Reflection Texture", 2D) = "white" {}
        _RefractionTex ("Refraction Texture", 2D) = "white" {}
        _CausticsTex ("Caustics Texture", 2D) = "white" {}
		_Displacement_Speed ("Displacement Speed", Range(0, 10)) = 1.0
        _WaveSpeed ("Wave Speed", Range(0, 10)) = 1.0
        _WaveScale ("Wave Scale", Range(0, 10)) = 1.0
        _FoamScale ("Foam Scale", Range(0, 10)) = 1.0
        _FoamSpeed ("Foam Speed", Range(0, 10)) = 1.0
        _FoamThreshold ("Foam Threshold", Range(0, 1)) = 0.7
        _FoamFadeRate ("Foam Fade Rate", Range(0, 10)) = 1.0
        _WaveFoamStrength ("Wave Foam Strength", Range(0, 1)) = 0.5
        _ShorelineFoamStrength ("Shoreline Foam Strength", Range(0, 1)) = 0.5
        _ShorelineFoamMaxDepth ("Shoreline Foam Max Depth", Range(0, 10)) = 1.0
        _WindStrength ("Wind Strength", Range(0, 10)) = 1.0
        _CausticsStrength ("Caustics Strength", Range(0, 1)) = 0.5

        _Depth ("Depth", Range(0, 10)) = 1.0
        _DeepColor ("Deep Water Color", Color) = (0, 0.2, 0.4, 1)
        _ShallowColor ("Shallow Water Color", Color) = (0.3, 0.5, 0.7, 1)
        _HorizonColor ("Horizon Water Color", Color) = (0.2, 0.3, 0.4, 1)
        _Translucency ("Translucency", Range(0, 1)) = 0.5

        _FresnelPower ("Fresnel Power", Range(1, 5)) = 3.0
        _RefractionDistortion ("Refraction Distortion", Range(0, 1)) = 0.1

        // Shading modes and other properties
        _ShadingMode ("Shading Mode", Float) = 0.0
        _SparkleIntensity ("Sparkle Intensity", Range(0, 1)) = 0.5
        _FlatShading ("Flat Shading", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 400

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float3 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
                float depth : TEXCOORD4;
                float3 worldTangent : TEXCOORD5;
                float3 worldBitangent : TEXCOORD6;
                float3 vertexColor : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _FoamTex;
            sampler2D _NormalMap;
            sampler2D _ReflectionTex;
            sampler2D _RefractionTex;
            sampler2D _CausticsTex;
            float _WaveSpeed;
            float _WaveScale;
            float _FoamScale;
            float _FoamSpeed;
            float _FoamThreshold;
            float _FoamFadeRate;
            float _WaveFoamStrength;
            float _ShorelineFoamStrength;
            float _ShorelineFoamMaxDepth;
            float _WindStrength;
            float _CausticsStrength;
            float _Depth;
            float4 _DeepColor;
            float4 _ShallowColor;
            float4 _HorizonColor;
            float _Translucency;
            float _FresnelPower;
            float _RefractionDistortion;
            float _ShadingMode;
            float _SparkleIntensity;
            float _FlatShading;

            float4 _LightColor0;

            float4 GerstnerWave(float4 pos, float4 waveDir, float freq, float amp, float speed, float phase)
            {
                float2 dir = normalize(waveDir.xy);
                float wave = dot(dir, pos.xy) * freq + _Time.y * speed + phase;
                pos.z += sin(wave) * amp;
                pos.xy += cos(wave) * amp * dir;
                return pos;
            }

            v2f vert(appdata v)
            {
                v2f o;
                float4 pos = v.vertex;

                // Apply multiple Gerstner waves
                pos = GerstnerWave(pos, float4(1, 0, 0, 0), 0.2, 0.1, _WaveSpeed, 0);
                pos = GerstnerWave(pos, float4(0, 1, 0, 0), 0.3, 0.05, _WaveSpeed, 0.5);

                o.vertex = UnityObjectToClipPos(pos);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.depth = pos.z;
                o.worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
                o.worldBitangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                o.vertexColor = v.color;

                return o;
            }

            float CalculateFoam(float3 worldPos, float2 uv)
            {
                float foam = tex2D(_FoamTex, uv * _FoamScale).a;
                foam = smoothstep(_FoamThreshold, 1.0, foam);
                return foam * _FoamFadeRate;
            }

            float CalculateUnderwaterEffect(float3 worldPos)
            {
                float depthFactor = saturate(worldPos.y / _Depth);
                float4 underwaterColor = lerp(_DeepColor, _ShallowColor, depthFactor);
                return underwaterColor * _Translucency;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Sample textures
                fixed4 col = tex2D(_MainTex, i.uv);
                float foam = CalculateFoam(i.worldPos, i.uv);
                float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                float3 reflection = tex2D(_ReflectionTex, i.screenPos.xy).rgb;
                float3 refraction = tex2D(_RefractionTex, i.screenPos.xy).rgb;
                float caustics = tex2D(_CausticsTex, i.uv * _WaveScale * _Depth).r;

                // Foam based on wave height
                foam = smoothstep(_FoamThreshold, 1.0, foam);

                // Lighting calculation
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = saturate(dot(normal, lightDir));
                float3 lighting = NdotL * _LightColor0.rgb;

                // Fresnel effect for reflections and refractions
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float fresnel = pow(1.0 - saturate(dot(viewDir, normal)), _FresnelPower);

                // Combine textures and lighting
                col.rgb += foam * _FoamSpeed;
                col.rgb = lerp(refraction, reflection, fresnel);
                col.rgb *= lighting;
                col.rgb += caustics * _CausticsStrength;

                // Sparkles based on normal map
                float sparkle = dot(normal, normalize(float3(0.577, 0.577, 0.577)));
                sparkle = pow(saturate(sparkle), 20.0) * _SparkleIntensity;
                col.rgb += sparkle;

                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
