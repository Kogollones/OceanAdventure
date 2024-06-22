Shader "Shader Graphs/UltimateWaterShader"
{
    Properties
    {
        [NoScaleOffset]_NormalMap("NormalMap", 2D) = "white" {}
        [NoScaleOffset]_ReflectionTex("ReflectionTex", 2D) = "white" {}
        [NoScaleOffset]_RefractionTex("RefractionTex", 2D) = "white" {}
        [NoScaleOffset]_CausticsTex("CausticsTex", 2D) = "white" {}
        _WaveSpeed("WaveSpeed", Float) = 0
        _WaveScale("WaveScale", Float) = 1
        _WaveFoamStrength("WaveFoamStrength", Float) = 0.1
        _ShorelineFoamStrength("ShorelineFoamStrength", Float) = 0.3
        _ShorelineFoamMaxDepth("ShorelineFoamMaxDepth", Float) = 0.5
        _WindStrength("WindStrength", Float) = 0
        _CausticsStrength("CausticsStrength", Float) = 0.3
        _Depth("Depth", Float) = 0
        _FresnelPower("FresnelPower", Float) = 0.2
        _RefractionDistorion("RefractionDistorion", Float) = 0.5
        _SparkleIntensity("SparkleIntensity", Float) = 0.02
        _DeepColor("DeepColor", Color) = (0, 0.06226414, 0.08679241, 1)
        _ShallowColor("ShallowColor", Color) = (0.3150943, 0.7763737, 1, 1)
        _LightColor0("_LightColor0", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_ReflectionCubeMap("ReflectionCubeMap", CUBE) = "" {}
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        _TwoConstant("TwoConstant", Float) = 2
        _PIConstant("PIConstant", Float) = 3.14159
        _Amplitude1("Amplitude1", Float) = 20
        _Direction1("Direction1", Vector) = (1, 0, 0, 0)
        _Wavelenght1("Wavelenght1", Float) = 10
        _Amplitude2("Amplitude2", Float) = 1
        _Direction2("Direction2", Vector) = (5, 0, 0, 0)
        _Wavelenght2("Wavelenght2", Float) = 2
        _Speed2("Speed2", Float) = 1
        _Speed1("Speed1", Float) = 1
        [NoScaleOffset]_FoamTex("FoamTex", 2D) = "white" {}
        _FoamFadeRate("FoamFadeRate", Float) = 1
        _FoamThreshold("FoamThreshold", Float) = 0.3
        _FoamSpeed("FoamSpeed", Float) = 1
        _FoamDepthThreshold("FoamDepthThreshold", Float) = 0.2
        _FoamIntensity("FoamIntensity", Float) = 0.2
        [NoScaleOffset]_FoamNoiseTex("FoamNoiseTex", 2D) = "white" {}
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _ReflectionTex_TexelSize;
        float4 _RefractionTex_TexelSize;
        float4 _CausticsTex_TexelSize;
        float4 _DeepColor;
        float4 _ShallowColor;
        float _WaveSpeed;
        float _WaveScale;
        float4 _FoamTex_TexelSize;
        float _WaveFoamStrength;
        float _FoamSpeed;
        float _FoamThreshold;
        float _FoamFadeRate;
        float _WindStrength;
        float _ShorelineFoamStrength;
        float _ShorelineFoamMaxDepth;
        float _CausticsStrength;
        float _Depth;
        float _FresnelPower;
        float _RefractionDistorion;
        float _SparkleIntensity;
        float4 _LightColor0;
        float _Amplitude1;
        float _Wavelenght1;
        float2 _Direction1;
        float _Speed1;
        float _Amplitude2;
        float _Wavelenght2;
        float2 _Direction2;
        float _Speed2;
        float _FoamDepthThreshold;
        float _FoamIntensity;
        float4 _FoamNoiseTex_TexelSize;
        float _TwoConstant;
        float _PIConstant;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_ReflectionTex);
        SAMPLER(sampler_ReflectionTex);
        TEXTURE2D(_RefractionTex);
        SAMPLER(sampler_RefractionTex);
        TEXTURE2D(_CausticsTex);
        SAMPLER(sampler_CausticsTex);
        TEXTURE2D(_FoamTex);
        SAMPLER(sampler_FoamTex);
        TEXTURE2D(_FoamNoiseTex);
        SAMPLER(sampler_FoamNoiseTex);
        TEXTURECUBE(_ReflectionCubeMap);
        SAMPLER(sampler_ReflectionCubeMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_NormalUnpack_float(float4 In, out float3 Out)
        {
                        Out = UnpackNormal(In);
                    }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_095b19eee2b9488abf2e03abc09c9cf7_Out_0_Vector4 = _DeepColor;
            float4 _Property_039818151c644b9c8cf17cdd0a4fe3ea_Out_0_Vector4 = _ShallowColor;
            float _SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float);
            float4 _Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4;
            Unity_Lerp_float4(_Property_095b19eee2b9488abf2e03abc09c9cf7_Out_0_Vector4, _Property_039818151c644b9c8cf17cdd0a4fe3ea_Out_0_Vector4, (_SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float.xxxx), _Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4);
            UnityTexture2D _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_5a01ecd713ae4fc5b1a2d7e9a91afa6b_Out_0_Vector4 = IN.uv0;
            float4 _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.tex, _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.samplerstate, _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.GetTransformedUV((_UV_5a01ecd713ae4fc5b1a2d7e9a91afa6b_Out_0_Vector4.xy)) );
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_R_4_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.r;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_G_5_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.g;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_B_6_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.b;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_A_7_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.a;
            float4 _Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4;
            Unity_Add_float4(_Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4, _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4, _Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4);
            float _Property_02a0d57c0dd94704b5f460809d75b330_Out_0_Float = _FoamFadeRate;
            float _Property_1fd0ccc19b3048efb56100c1201b01f2_Out_0_Float = _FoamThreshold;
            UnityTexture2D _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTex);
            float _Property_60eb08d0cb21444eaaa2a5ea1fdf235a_Out_0_Float = _WaveScale;
            float2 _TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_60eb08d0cb21444eaaa2a5ea1fdf235a_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2);
            float4 _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.tex, _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.samplerstate, _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2) );
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_R_4_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.r;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_G_5_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.g;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_B_6_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.b;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_A_7_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.a;
            float _Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float = _Amplitude1;
            float2 _Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2 = _Direction1;
            float _Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_A_4_Float = 0;
            float2 _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2 = float2(_Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float, _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float);
            float _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float;
            Unity_DotProduct_float2(_Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2, _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2, _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float);
            float _Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float = _Speed1;
            float _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float;
            Unity_Multiply_float_float(_Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float, IN.TimeParameters.z, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float);
            float _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float;
            Unity_Subtract_float(_DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float, _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float);
            float _Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float = _TwoConstant;
            float _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float = _PIConstant;
            float _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float;
            Unity_Multiply_float_float(_Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float, _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float, _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float);
            float _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float = _Wavelenght1;
            float _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float;
            Unity_Divide_float(_Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float, _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float);
            float _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float, _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float);
            float _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float;
            Unity_Sine_float(_Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float);
            float _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float;
            Unity_Multiply_float_float(_Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float, _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float);
            float _Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float = _Amplitude2;
            float2 _Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2 = _Direction2;
            float _Split_647deeb3d0dd470682efb9858d851041_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_647deeb3d0dd470682efb9858d851041_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_647deeb3d0dd470682efb9858d851041_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_647deeb3d0dd470682efb9858d851041_A_4_Float = 0;
            float2 _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2 = float2(_Split_647deeb3d0dd470682efb9858d851041_R_1_Float, _Split_647deeb3d0dd470682efb9858d851041_B_3_Float);
            float _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float;
            Unity_DotProduct_float2(_Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2, _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2, _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float);
            float _Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float = _Speed2;
            float _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float;
            Unity_Multiply_float_float(_Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float, IN.TimeParameters.z, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float);
            float _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float;
            Unity_Subtract_float(_DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float, _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float);
            float _Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float = _TwoConstant;
            float _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float = _PIConstant;
            float _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float;
            Unity_Multiply_float_float(_Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float, _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float, _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float);
            float _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float = _Wavelenght2;
            float _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float;
            Unity_Divide_float(_Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float, _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float);
            float _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float, _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float);
            float _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float;
            Unity_Sine_float(_Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float);
            float _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float;
            Unity_Multiply_float_float(_Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float);
            float _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float;
            Unity_Add_float(_Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float, _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float);
            float4 _Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4, (_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxxx), _Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4);
            UnityTexture2D _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamNoiseTex);
            float4 _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.tex, _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.samplerstate, _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_R_4_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.r;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_G_5_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.g;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_B_6_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.b;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_A_7_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.a;
            float _Property_6cad358dfaea42629685af54482e7342_Out_0_Float = _FoamIntensity;
            float4 _Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4, (_Property_6cad358dfaea42629685af54482e7342_Out_0_Float.xxxx), _Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4);
            float _Property_913f5b2f63b24ae5a66f5d92be101c66_Out_0_Float = _FoamSpeed;
            float4 _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4, (_Property_913f5b2f63b24ae5a66f5d92be101c66_Out_0_Float.xxxx), _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4);
            float4 _Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4, _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4, _Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4);
            float _Property_e02b1ca207cf4f579ec91183888fb147_Out_0_Float = _FoamDepthThreshold;
            float _SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float);
            float4 _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4;
            Unity_Smoothstep_float4(_Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4, (_Property_e02b1ca207cf4f579ec91183888fb147_Out_0_Float.xxxx), (_SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float.xxxx), _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4);
            float4 _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4;
            Unity_Add_float4((_Property_1fd0ccc19b3048efb56100c1201b01f2_Out_0_Float.xxxx), _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4, _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4);
            float4 _Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4;
            Unity_Subtract_float4((_Property_02a0d57c0dd94704b5f460809d75b330_Out_0_Float.xxxx), _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4, _Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4);
            float _Property_a63fc6bae8d14edc843219bd157e28e9_Out_0_Float = _WaveFoamStrength;
            float4 _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4, (_Property_a63fc6bae8d14edc843219bd157e28e9_Out_0_Float.xxxx), _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4);
            float4 _Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4;
            Unity_Add_float4(_Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4, _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4, _Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4);
            UnityTexture2D _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ReflectionTex);
            UnityTextureCube _Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap = UnityBuildTextureCubeStruct(_ReflectionCubeMap);
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_A_4_Float = 0;
            float2 _Vector2_ce6fbcae9335437aab8963ad06b894c5_Out_0_Vector2 = float2(_Split_761cfc6cff1b407c9870fb3a8fe6e9ad_R_1_Float, _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_B_3_Float);
            float _Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float;
            Unity_Multiply_float_float(_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float, 2, _Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float);
            float2 _Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_ce6fbcae9335437aab8963ad06b894c5_Out_0_Vector2, (_Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float.xx), _Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2);
            float2 _Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2, (IN.WorldSpaceViewDirection.xy), _Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2);
            float4 _SampleCubemap_e75d60130f2d4e7da4f0215f12d4ebef_Out_0_Vector4 = SAMPLE_TEXTURECUBE_LOD(_Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap.tex, _Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap.samplerstate, (float3(_Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2, 0.0)), float(0));
            float4 _Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleCubemap_e75d60130f2d4e7da4f0215f12d4ebef_Out_0_Vector4, float4(0.3, 0.3, 0.3, 0.3), _Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4);
            float4 _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.tex, _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.samplerstate, _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.GetTransformedUV((_Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4.xy)) );
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_R_4_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.r;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_G_5_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.g;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_B_6_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.b;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_A_7_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.a;
            float _Property_327e01c3795044ffa63b63e1944f45a2_Out_0_Float = _RefractionDistorion;
            float4 _Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4, (_Property_327e01c3795044ffa63b63e1944f45a2_Out_0_Float.xxxx), _Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4);
            UnityTexture2D _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RefractionTex);
            float4 _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.tex, _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.samplerstate, _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.GetTransformedUV((_Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4.xy)) );
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_R_4_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.r;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_G_5_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.g;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_B_6_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.b;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_A_7_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.a;
            float _Property_70b12ff6ef56428aa5a486e3737fa86e_Out_0_Float = _FresnelPower;
            float _FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_70b12ff6ef56428aa5a486e3737fa86e_Out_0_Float, _FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float);
            float4 _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4, _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4, (_FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float.xxxx), _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4);
            float4 _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4;
            Unity_Add_float4(_Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4, _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4, _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4);
            UnityTexture2D _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticsTex);
            float4 _UV_28f6b818761741b2b4c2b10c7a622b0a_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_28f6b818761741b2b4c2b10c7a622b0a_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2);
            float4 _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.tex, _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.samplerstate, _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2) );
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_R_4_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.r;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_G_5_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.g;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_B_6_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.b;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_A_7_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.a;
            float _Property_1b3931c88eac43bb829335204a37e9a6_Out_0_Float = _CausticsStrength;
            float4 _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4, (_Property_1b3931c88eac43bb829335204a37e9a6_Out_0_Float.xxxx), _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4);
            float4 _Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxxx), _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4, _Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4);
            float4 _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4, float4(0.3, 0.3, 0.3, 0.3), _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4);
            float4 _Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4;
            Unity_Add_float4(_Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4, _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4, _Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4);
            float _Property_2199df2931454b518d2b9d9c9a1de19b_Out_0_Float = _ShorelineFoamStrength;
            float _Property_f21c1332f7b24b4da7b24cd420bec761_Out_0_Float = _ShorelineFoamMaxDepth;
            float _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float);
            float _Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float;
            Unity_Lerp_float(_Property_2199df2931454b518d2b9d9c9a1de19b_Out_0_Float, _Property_f21c1332f7b24b4da7b24cd420bec761_Out_0_Float, _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float, _Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float);
            float4 _Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4;
            Unity_Add_float4(_Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4, (_Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float.xxxx), _Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4);
            float4 _UV_65a5cc357b884dd7af1304bb2518f5e9_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_65a5cc357b884dd7af1304bb2518f5e9_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2);
            float _SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(_TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2, float(500), _SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float);
            float _Property_6640be77490641c79ea1bdea6fd941dd_Out_0_Float = _SparkleIntensity;
            float _Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float, _Property_6640be77490641c79ea1bdea6fd941dd_Out_0_Float, _Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float);
            float _Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float, _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float, _Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float);
            float4 _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4;
            Unity_Add_float4(_Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4, (_Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float.xxxx), _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4);
            float4 _Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4;
            Unity_Add_float4(_Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4, _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4, _Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4);
            float4 _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4;
            Unity_Add_float4(_Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4, _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4, _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4);
            float4 _Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4;
            Unity_Add_float4(_Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4, _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4, _Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4);
            float4 _Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4, float4(0.35, 0.3, 0.28, 1), _Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4);
            UnityTexture2D _Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _UV_3af21fa97c5648e08942dd9a10beceef_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_d1c8ea0cfc0542de957969815643affe_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_3af21fa97c5648e08942dd9a10beceef_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d1c8ea0cfc0542de957969815643affe_Out_3_Vector2);
            float _Property_ee4cc209f6da4e0d8b24ad340ecfa4ea_Out_0_Float = _WaveSpeed;
            float _Multiply_48c1f242e5904f3aaf00ffe2bf68be58_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee4cc209f6da4e0d8b24ad340ecfa4ea_Out_0_Float, _Multiply_48c1f242e5904f3aaf00ffe2bf68be58_Out_2_Float);
            float _Sine_35f4a253f40b46aa81aad2e7effdb1c4_Out_1_Float;
            Unity_Sine_float(_Multiply_48c1f242e5904f3aaf00ffe2bf68be58_Out_2_Float, _Sine_35f4a253f40b46aa81aad2e7effdb1c4_Out_1_Float);
            float _Property_b34c2c2807a44db8b4be30d6f150861b_Out_0_Float = _WaveScale;
            float _Multiply_563f33741e6c4fb8908ec662048885f1_Out_2_Float;
            Unity_Multiply_float_float(_Sine_35f4a253f40b46aa81aad2e7effdb1c4_Out_1_Float, _Property_b34c2c2807a44db8b4be30d6f150861b_Out_0_Float, _Multiply_563f33741e6c4fb8908ec662048885f1_Out_2_Float);
            float2 _Add_100483f023444857a041e0b5a6405b30_Out_2_Vector2;
            Unity_Add_float2(_TilingAndOffset_d1c8ea0cfc0542de957969815643affe_Out_3_Vector2, (_Multiply_563f33741e6c4fb8908ec662048885f1_Out_2_Float.xx), _Add_100483f023444857a041e0b5a6405b30_Out_2_Vector2);
            float4 _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D.tex, _Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D.samplerstate, _Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D.GetTransformedUV(_Add_100483f023444857a041e0b5a6405b30_Out_2_Vector2) );
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_R_4_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.r;
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_G_5_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.g;
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_B_6_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.b;
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_A_7_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.a;
            float3 _NormalUnpack_a6518034dbcf44b0b4a9e33e6a1ca3f7_Out_1_Vector3;
            Unity_NormalUnpack_float(_SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4, _NormalUnpack_a6518034dbcf44b0b4a9e33e6a1ca3f7_Out_1_Vector3);
            float3 _Multiply_79a115a2f2784bfda5b49d34a8db7386_Out_2_Vector3;
            Unity_Multiply_float3_float3(_NormalUnpack_a6518034dbcf44b0b4a9e33e6a1ca3f7_Out_1_Vector3, (_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxx), _Multiply_79a115a2f2784bfda5b49d34a8db7386_Out_2_Vector3);
            float3 _Multiply_70d73c8d6af7473b93889f81df9dd4ed_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_79a115a2f2784bfda5b49d34a8db7386_Out_2_Vector3, float3(0.3, 0.3, 0.3), _Multiply_70d73c8d6af7473b93889f81df9dd4ed_Out_2_Vector3);
            surface.BaseColor = (_Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4.xyz);
            surface.NormalTS = _Multiply_70d73c8d6af7473b93889f81df9dd4ed_Out_2_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = float(0.5);
            surface.Occlusion = float(1);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _ReflectionTex_TexelSize;
        float4 _RefractionTex_TexelSize;
        float4 _CausticsTex_TexelSize;
        float4 _DeepColor;
        float4 _ShallowColor;
        float _WaveSpeed;
        float _WaveScale;
        float4 _FoamTex_TexelSize;
        float _WaveFoamStrength;
        float _FoamSpeed;
        float _FoamThreshold;
        float _FoamFadeRate;
        float _WindStrength;
        float _ShorelineFoamStrength;
        float _ShorelineFoamMaxDepth;
        float _CausticsStrength;
        float _Depth;
        float _FresnelPower;
        float _RefractionDistorion;
        float _SparkleIntensity;
        float4 _LightColor0;
        float _Amplitude1;
        float _Wavelenght1;
        float2 _Direction1;
        float _Speed1;
        float _Amplitude2;
        float _Wavelenght2;
        float2 _Direction2;
        float _Speed2;
        float _FoamDepthThreshold;
        float _FoamIntensity;
        float4 _FoamNoiseTex_TexelSize;
        float _TwoConstant;
        float _PIConstant;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_ReflectionTex);
        SAMPLER(sampler_ReflectionTex);
        TEXTURE2D(_RefractionTex);
        SAMPLER(sampler_RefractionTex);
        TEXTURE2D(_CausticsTex);
        SAMPLER(sampler_CausticsTex);
        TEXTURE2D(_FoamTex);
        SAMPLER(sampler_FoamTex);
        TEXTURE2D(_FoamNoiseTex);
        SAMPLER(sampler_FoamNoiseTex);
        TEXTURECUBE(_ReflectionCubeMap);
        SAMPLER(sampler_ReflectionCubeMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_NormalUnpack_float(float4 In, out float3 Out)
        {
                        Out = UnpackNormal(In);
                    }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_095b19eee2b9488abf2e03abc09c9cf7_Out_0_Vector4 = _DeepColor;
            float4 _Property_039818151c644b9c8cf17cdd0a4fe3ea_Out_0_Vector4 = _ShallowColor;
            float _SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float);
            float4 _Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4;
            Unity_Lerp_float4(_Property_095b19eee2b9488abf2e03abc09c9cf7_Out_0_Vector4, _Property_039818151c644b9c8cf17cdd0a4fe3ea_Out_0_Vector4, (_SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float.xxxx), _Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4);
            UnityTexture2D _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_5a01ecd713ae4fc5b1a2d7e9a91afa6b_Out_0_Vector4 = IN.uv0;
            float4 _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.tex, _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.samplerstate, _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.GetTransformedUV((_UV_5a01ecd713ae4fc5b1a2d7e9a91afa6b_Out_0_Vector4.xy)) );
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_R_4_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.r;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_G_5_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.g;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_B_6_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.b;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_A_7_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.a;
            float4 _Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4;
            Unity_Add_float4(_Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4, _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4, _Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4);
            float _Property_02a0d57c0dd94704b5f460809d75b330_Out_0_Float = _FoamFadeRate;
            float _Property_1fd0ccc19b3048efb56100c1201b01f2_Out_0_Float = _FoamThreshold;
            UnityTexture2D _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTex);
            float _Property_60eb08d0cb21444eaaa2a5ea1fdf235a_Out_0_Float = _WaveScale;
            float2 _TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_60eb08d0cb21444eaaa2a5ea1fdf235a_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2);
            float4 _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.tex, _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.samplerstate, _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2) );
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_R_4_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.r;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_G_5_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.g;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_B_6_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.b;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_A_7_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.a;
            float _Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float = _Amplitude1;
            float2 _Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2 = _Direction1;
            float _Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_A_4_Float = 0;
            float2 _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2 = float2(_Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float, _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float);
            float _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float;
            Unity_DotProduct_float2(_Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2, _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2, _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float);
            float _Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float = _Speed1;
            float _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float;
            Unity_Multiply_float_float(_Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float, IN.TimeParameters.z, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float);
            float _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float;
            Unity_Subtract_float(_DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float, _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float);
            float _Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float = _TwoConstant;
            float _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float = _PIConstant;
            float _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float;
            Unity_Multiply_float_float(_Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float, _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float, _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float);
            float _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float = _Wavelenght1;
            float _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float;
            Unity_Divide_float(_Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float, _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float);
            float _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float, _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float);
            float _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float;
            Unity_Sine_float(_Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float);
            float _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float;
            Unity_Multiply_float_float(_Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float, _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float);
            float _Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float = _Amplitude2;
            float2 _Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2 = _Direction2;
            float _Split_647deeb3d0dd470682efb9858d851041_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_647deeb3d0dd470682efb9858d851041_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_647deeb3d0dd470682efb9858d851041_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_647deeb3d0dd470682efb9858d851041_A_4_Float = 0;
            float2 _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2 = float2(_Split_647deeb3d0dd470682efb9858d851041_R_1_Float, _Split_647deeb3d0dd470682efb9858d851041_B_3_Float);
            float _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float;
            Unity_DotProduct_float2(_Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2, _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2, _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float);
            float _Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float = _Speed2;
            float _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float;
            Unity_Multiply_float_float(_Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float, IN.TimeParameters.z, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float);
            float _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float;
            Unity_Subtract_float(_DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float, _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float);
            float _Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float = _TwoConstant;
            float _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float = _PIConstant;
            float _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float;
            Unity_Multiply_float_float(_Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float, _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float, _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float);
            float _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float = _Wavelenght2;
            float _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float;
            Unity_Divide_float(_Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float, _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float);
            float _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float, _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float);
            float _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float;
            Unity_Sine_float(_Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float);
            float _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float;
            Unity_Multiply_float_float(_Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float);
            float _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float;
            Unity_Add_float(_Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float, _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float);
            float4 _Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4, (_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxxx), _Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4);
            UnityTexture2D _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamNoiseTex);
            float4 _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.tex, _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.samplerstate, _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_R_4_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.r;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_G_5_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.g;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_B_6_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.b;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_A_7_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.a;
            float _Property_6cad358dfaea42629685af54482e7342_Out_0_Float = _FoamIntensity;
            float4 _Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4, (_Property_6cad358dfaea42629685af54482e7342_Out_0_Float.xxxx), _Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4);
            float _Property_913f5b2f63b24ae5a66f5d92be101c66_Out_0_Float = _FoamSpeed;
            float4 _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4, (_Property_913f5b2f63b24ae5a66f5d92be101c66_Out_0_Float.xxxx), _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4);
            float4 _Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4, _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4, _Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4);
            float _Property_e02b1ca207cf4f579ec91183888fb147_Out_0_Float = _FoamDepthThreshold;
            float _SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float);
            float4 _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4;
            Unity_Smoothstep_float4(_Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4, (_Property_e02b1ca207cf4f579ec91183888fb147_Out_0_Float.xxxx), (_SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float.xxxx), _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4);
            float4 _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4;
            Unity_Add_float4((_Property_1fd0ccc19b3048efb56100c1201b01f2_Out_0_Float.xxxx), _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4, _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4);
            float4 _Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4;
            Unity_Subtract_float4((_Property_02a0d57c0dd94704b5f460809d75b330_Out_0_Float.xxxx), _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4, _Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4);
            float _Property_a63fc6bae8d14edc843219bd157e28e9_Out_0_Float = _WaveFoamStrength;
            float4 _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4, (_Property_a63fc6bae8d14edc843219bd157e28e9_Out_0_Float.xxxx), _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4);
            float4 _Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4;
            Unity_Add_float4(_Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4, _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4, _Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4);
            UnityTexture2D _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ReflectionTex);
            UnityTextureCube _Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap = UnityBuildTextureCubeStruct(_ReflectionCubeMap);
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_A_4_Float = 0;
            float2 _Vector2_ce6fbcae9335437aab8963ad06b894c5_Out_0_Vector2 = float2(_Split_761cfc6cff1b407c9870fb3a8fe6e9ad_R_1_Float, _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_B_3_Float);
            float _Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float;
            Unity_Multiply_float_float(_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float, 2, _Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float);
            float2 _Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_ce6fbcae9335437aab8963ad06b894c5_Out_0_Vector2, (_Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float.xx), _Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2);
            float2 _Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2, (IN.WorldSpaceViewDirection.xy), _Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2);
            float4 _SampleCubemap_e75d60130f2d4e7da4f0215f12d4ebef_Out_0_Vector4 = SAMPLE_TEXTURECUBE_LOD(_Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap.tex, _Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap.samplerstate, (float3(_Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2, 0.0)), float(0));
            float4 _Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleCubemap_e75d60130f2d4e7da4f0215f12d4ebef_Out_0_Vector4, float4(0.3, 0.3, 0.3, 0.3), _Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4);
            float4 _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.tex, _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.samplerstate, _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.GetTransformedUV((_Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4.xy)) );
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_R_4_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.r;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_G_5_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.g;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_B_6_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.b;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_A_7_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.a;
            float _Property_327e01c3795044ffa63b63e1944f45a2_Out_0_Float = _RefractionDistorion;
            float4 _Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4, (_Property_327e01c3795044ffa63b63e1944f45a2_Out_0_Float.xxxx), _Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4);
            UnityTexture2D _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RefractionTex);
            float4 _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.tex, _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.samplerstate, _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.GetTransformedUV((_Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4.xy)) );
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_R_4_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.r;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_G_5_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.g;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_B_6_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.b;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_A_7_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.a;
            float _Property_70b12ff6ef56428aa5a486e3737fa86e_Out_0_Float = _FresnelPower;
            float _FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_70b12ff6ef56428aa5a486e3737fa86e_Out_0_Float, _FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float);
            float4 _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4, _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4, (_FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float.xxxx), _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4);
            float4 _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4;
            Unity_Add_float4(_Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4, _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4, _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4);
            UnityTexture2D _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticsTex);
            float4 _UV_28f6b818761741b2b4c2b10c7a622b0a_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_28f6b818761741b2b4c2b10c7a622b0a_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2);
            float4 _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.tex, _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.samplerstate, _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2) );
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_R_4_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.r;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_G_5_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.g;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_B_6_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.b;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_A_7_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.a;
            float _Property_1b3931c88eac43bb829335204a37e9a6_Out_0_Float = _CausticsStrength;
            float4 _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4, (_Property_1b3931c88eac43bb829335204a37e9a6_Out_0_Float.xxxx), _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4);
            float4 _Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxxx), _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4, _Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4);
            float4 _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4, float4(0.3, 0.3, 0.3, 0.3), _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4);
            float4 _Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4;
            Unity_Add_float4(_Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4, _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4, _Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4);
            float _Property_2199df2931454b518d2b9d9c9a1de19b_Out_0_Float = _ShorelineFoamStrength;
            float _Property_f21c1332f7b24b4da7b24cd420bec761_Out_0_Float = _ShorelineFoamMaxDepth;
            float _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float);
            float _Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float;
            Unity_Lerp_float(_Property_2199df2931454b518d2b9d9c9a1de19b_Out_0_Float, _Property_f21c1332f7b24b4da7b24cd420bec761_Out_0_Float, _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float, _Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float);
            float4 _Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4;
            Unity_Add_float4(_Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4, (_Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float.xxxx), _Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4);
            float4 _UV_65a5cc357b884dd7af1304bb2518f5e9_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_65a5cc357b884dd7af1304bb2518f5e9_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2);
            float _SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(_TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2, float(500), _SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float);
            float _Property_6640be77490641c79ea1bdea6fd941dd_Out_0_Float = _SparkleIntensity;
            float _Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float, _Property_6640be77490641c79ea1bdea6fd941dd_Out_0_Float, _Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float);
            float _Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float, _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float, _Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float);
            float4 _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4;
            Unity_Add_float4(_Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4, (_Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float.xxxx), _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4);
            float4 _Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4;
            Unity_Add_float4(_Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4, _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4, _Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4);
            float4 _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4;
            Unity_Add_float4(_Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4, _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4, _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4);
            float4 _Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4;
            Unity_Add_float4(_Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4, _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4, _Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4);
            float4 _Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4, float4(0.35, 0.3, 0.28, 1), _Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4);
            UnityTexture2D _Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _UV_3af21fa97c5648e08942dd9a10beceef_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_d1c8ea0cfc0542de957969815643affe_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_3af21fa97c5648e08942dd9a10beceef_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d1c8ea0cfc0542de957969815643affe_Out_3_Vector2);
            float _Property_ee4cc209f6da4e0d8b24ad340ecfa4ea_Out_0_Float = _WaveSpeed;
            float _Multiply_48c1f242e5904f3aaf00ffe2bf68be58_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee4cc209f6da4e0d8b24ad340ecfa4ea_Out_0_Float, _Multiply_48c1f242e5904f3aaf00ffe2bf68be58_Out_2_Float);
            float _Sine_35f4a253f40b46aa81aad2e7effdb1c4_Out_1_Float;
            Unity_Sine_float(_Multiply_48c1f242e5904f3aaf00ffe2bf68be58_Out_2_Float, _Sine_35f4a253f40b46aa81aad2e7effdb1c4_Out_1_Float);
            float _Property_b34c2c2807a44db8b4be30d6f150861b_Out_0_Float = _WaveScale;
            float _Multiply_563f33741e6c4fb8908ec662048885f1_Out_2_Float;
            Unity_Multiply_float_float(_Sine_35f4a253f40b46aa81aad2e7effdb1c4_Out_1_Float, _Property_b34c2c2807a44db8b4be30d6f150861b_Out_0_Float, _Multiply_563f33741e6c4fb8908ec662048885f1_Out_2_Float);
            float2 _Add_100483f023444857a041e0b5a6405b30_Out_2_Vector2;
            Unity_Add_float2(_TilingAndOffset_d1c8ea0cfc0542de957969815643affe_Out_3_Vector2, (_Multiply_563f33741e6c4fb8908ec662048885f1_Out_2_Float.xx), _Add_100483f023444857a041e0b5a6405b30_Out_2_Vector2);
            float4 _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D.tex, _Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D.samplerstate, _Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D.GetTransformedUV(_Add_100483f023444857a041e0b5a6405b30_Out_2_Vector2) );
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_R_4_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.r;
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_G_5_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.g;
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_B_6_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.b;
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_A_7_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.a;
            float3 _NormalUnpack_a6518034dbcf44b0b4a9e33e6a1ca3f7_Out_1_Vector3;
            Unity_NormalUnpack_float(_SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4, _NormalUnpack_a6518034dbcf44b0b4a9e33e6a1ca3f7_Out_1_Vector3);
            float3 _Multiply_79a115a2f2784bfda5b49d34a8db7386_Out_2_Vector3;
            Unity_Multiply_float3_float3(_NormalUnpack_a6518034dbcf44b0b4a9e33e6a1ca3f7_Out_1_Vector3, (_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxx), _Multiply_79a115a2f2784bfda5b49d34a8db7386_Out_2_Vector3);
            float3 _Multiply_70d73c8d6af7473b93889f81df9dd4ed_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_79a115a2f2784bfda5b49d34a8db7386_Out_2_Vector3, float3(0.3, 0.3, 0.3), _Multiply_70d73c8d6af7473b93889f81df9dd4ed_Out_2_Vector3);
            surface.BaseColor = (_Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4.xyz);
            surface.NormalTS = _Multiply_70d73c8d6af7473b93889f81df9dd4ed_Out_2_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = float(0.5);
            surface.Occlusion = float(1);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _ReflectionTex_TexelSize;
        float4 _RefractionTex_TexelSize;
        float4 _CausticsTex_TexelSize;
        float4 _DeepColor;
        float4 _ShallowColor;
        float _WaveSpeed;
        float _WaveScale;
        float4 _FoamTex_TexelSize;
        float _WaveFoamStrength;
        float _FoamSpeed;
        float _FoamThreshold;
        float _FoamFadeRate;
        float _WindStrength;
        float _ShorelineFoamStrength;
        float _ShorelineFoamMaxDepth;
        float _CausticsStrength;
        float _Depth;
        float _FresnelPower;
        float _RefractionDistorion;
        float _SparkleIntensity;
        float4 _LightColor0;
        float _Amplitude1;
        float _Wavelenght1;
        float2 _Direction1;
        float _Speed1;
        float _Amplitude2;
        float _Wavelenght2;
        float2 _Direction2;
        float _Speed2;
        float _FoamDepthThreshold;
        float _FoamIntensity;
        float4 _FoamNoiseTex_TexelSize;
        float _TwoConstant;
        float _PIConstant;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_ReflectionTex);
        SAMPLER(sampler_ReflectionTex);
        TEXTURE2D(_RefractionTex);
        SAMPLER(sampler_RefractionTex);
        TEXTURE2D(_CausticsTex);
        SAMPLER(sampler_CausticsTex);
        TEXTURE2D(_FoamTex);
        SAMPLER(sampler_FoamTex);
        TEXTURE2D(_FoamNoiseTex);
        SAMPLER(sampler_FoamNoiseTex);
        TEXTURECUBE(_ReflectionCubeMap);
        SAMPLER(sampler_ReflectionCubeMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _ReflectionTex_TexelSize;
        float4 _RefractionTex_TexelSize;
        float4 _CausticsTex_TexelSize;
        float4 _DeepColor;
        float4 _ShallowColor;
        float _WaveSpeed;
        float _WaveScale;
        float4 _FoamTex_TexelSize;
        float _WaveFoamStrength;
        float _FoamSpeed;
        float _FoamThreshold;
        float _FoamFadeRate;
        float _WindStrength;
        float _ShorelineFoamStrength;
        float _ShorelineFoamMaxDepth;
        float _CausticsStrength;
        float _Depth;
        float _FresnelPower;
        float _RefractionDistorion;
        float _SparkleIntensity;
        float4 _LightColor0;
        float _Amplitude1;
        float _Wavelenght1;
        float2 _Direction1;
        float _Speed1;
        float _Amplitude2;
        float _Wavelenght2;
        float2 _Direction2;
        float _Speed2;
        float _FoamDepthThreshold;
        float _FoamIntensity;
        float4 _FoamNoiseTex_TexelSize;
        float _TwoConstant;
        float _PIConstant;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_ReflectionTex);
        SAMPLER(sampler_ReflectionTex);
        TEXTURE2D(_RefractionTex);
        SAMPLER(sampler_RefractionTex);
        TEXTURE2D(_CausticsTex);
        SAMPLER(sampler_CausticsTex);
        TEXTURE2D(_FoamTex);
        SAMPLER(sampler_FoamTex);
        TEXTURE2D(_FoamNoiseTex);
        SAMPLER(sampler_FoamNoiseTex);
        TEXTURECUBE(_ReflectionCubeMap);
        SAMPLER(sampler_ReflectionCubeMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _ReflectionTex_TexelSize;
        float4 _RefractionTex_TexelSize;
        float4 _CausticsTex_TexelSize;
        float4 _DeepColor;
        float4 _ShallowColor;
        float _WaveSpeed;
        float _WaveScale;
        float4 _FoamTex_TexelSize;
        float _WaveFoamStrength;
        float _FoamSpeed;
        float _FoamThreshold;
        float _FoamFadeRate;
        float _WindStrength;
        float _ShorelineFoamStrength;
        float _ShorelineFoamMaxDepth;
        float _CausticsStrength;
        float _Depth;
        float _FresnelPower;
        float _RefractionDistorion;
        float _SparkleIntensity;
        float4 _LightColor0;
        float _Amplitude1;
        float _Wavelenght1;
        float2 _Direction1;
        float _Speed1;
        float _Amplitude2;
        float _Wavelenght2;
        float2 _Direction2;
        float _Speed2;
        float _FoamDepthThreshold;
        float _FoamIntensity;
        float4 _FoamNoiseTex_TexelSize;
        float _TwoConstant;
        float _PIConstant;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_ReflectionTex);
        SAMPLER(sampler_ReflectionTex);
        TEXTURE2D(_RefractionTex);
        SAMPLER(sampler_RefractionTex);
        TEXTURE2D(_CausticsTex);
        SAMPLER(sampler_CausticsTex);
        TEXTURE2D(_FoamTex);
        SAMPLER(sampler_FoamTex);
        TEXTURE2D(_FoamNoiseTex);
        SAMPLER(sampler_FoamNoiseTex);
        TEXTURECUBE(_ReflectionCubeMap);
        SAMPLER(sampler_ReflectionCubeMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_NormalUnpack_float(float4 In, out float3 Out)
        {
                        Out = UnpackNormal(In);
                    }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _UV_3af21fa97c5648e08942dd9a10beceef_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_d1c8ea0cfc0542de957969815643affe_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_3af21fa97c5648e08942dd9a10beceef_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d1c8ea0cfc0542de957969815643affe_Out_3_Vector2);
            float _Property_ee4cc209f6da4e0d8b24ad340ecfa4ea_Out_0_Float = _WaveSpeed;
            float _Multiply_48c1f242e5904f3aaf00ffe2bf68be58_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee4cc209f6da4e0d8b24ad340ecfa4ea_Out_0_Float, _Multiply_48c1f242e5904f3aaf00ffe2bf68be58_Out_2_Float);
            float _Sine_35f4a253f40b46aa81aad2e7effdb1c4_Out_1_Float;
            Unity_Sine_float(_Multiply_48c1f242e5904f3aaf00ffe2bf68be58_Out_2_Float, _Sine_35f4a253f40b46aa81aad2e7effdb1c4_Out_1_Float);
            float _Property_b34c2c2807a44db8b4be30d6f150861b_Out_0_Float = _WaveScale;
            float _Multiply_563f33741e6c4fb8908ec662048885f1_Out_2_Float;
            Unity_Multiply_float_float(_Sine_35f4a253f40b46aa81aad2e7effdb1c4_Out_1_Float, _Property_b34c2c2807a44db8b4be30d6f150861b_Out_0_Float, _Multiply_563f33741e6c4fb8908ec662048885f1_Out_2_Float);
            float2 _Add_100483f023444857a041e0b5a6405b30_Out_2_Vector2;
            Unity_Add_float2(_TilingAndOffset_d1c8ea0cfc0542de957969815643affe_Out_3_Vector2, (_Multiply_563f33741e6c4fb8908ec662048885f1_Out_2_Float.xx), _Add_100483f023444857a041e0b5a6405b30_Out_2_Vector2);
            float4 _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D.tex, _Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D.samplerstate, _Property_909fc1290f684b85aae021fae134c128_Out_0_Texture2D.GetTransformedUV(_Add_100483f023444857a041e0b5a6405b30_Out_2_Vector2) );
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_R_4_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.r;
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_G_5_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.g;
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_B_6_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.b;
            float _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_A_7_Float = _SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4.a;
            float3 _NormalUnpack_a6518034dbcf44b0b4a9e33e6a1ca3f7_Out_1_Vector3;
            Unity_NormalUnpack_float(_SampleTexture2D_344d8d13056944ffa8ab85c84bd63511_RGBA_0_Vector4, _NormalUnpack_a6518034dbcf44b0b4a9e33e6a1ca3f7_Out_1_Vector3);
            float _Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float = _Amplitude1;
            float2 _Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2 = _Direction1;
            float _Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_A_4_Float = 0;
            float2 _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2 = float2(_Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float, _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float);
            float _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float;
            Unity_DotProduct_float2(_Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2, _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2, _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float);
            float _Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float = _Speed1;
            float _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float;
            Unity_Multiply_float_float(_Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float, IN.TimeParameters.z, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float);
            float _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float;
            Unity_Subtract_float(_DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float, _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float);
            float _Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float = _TwoConstant;
            float _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float = _PIConstant;
            float _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float;
            Unity_Multiply_float_float(_Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float, _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float, _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float);
            float _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float = _Wavelenght1;
            float _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float;
            Unity_Divide_float(_Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float, _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float);
            float _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float, _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float);
            float _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float;
            Unity_Sine_float(_Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float);
            float _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float;
            Unity_Multiply_float_float(_Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float, _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float);
            float _Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float = _Amplitude2;
            float2 _Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2 = _Direction2;
            float _Split_647deeb3d0dd470682efb9858d851041_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_647deeb3d0dd470682efb9858d851041_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_647deeb3d0dd470682efb9858d851041_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_647deeb3d0dd470682efb9858d851041_A_4_Float = 0;
            float2 _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2 = float2(_Split_647deeb3d0dd470682efb9858d851041_R_1_Float, _Split_647deeb3d0dd470682efb9858d851041_B_3_Float);
            float _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float;
            Unity_DotProduct_float2(_Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2, _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2, _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float);
            float _Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float = _Speed2;
            float _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float;
            Unity_Multiply_float_float(_Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float, IN.TimeParameters.z, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float);
            float _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float;
            Unity_Subtract_float(_DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float, _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float);
            float _Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float = _TwoConstant;
            float _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float = _PIConstant;
            float _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float;
            Unity_Multiply_float_float(_Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float, _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float, _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float);
            float _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float = _Wavelenght2;
            float _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float;
            Unity_Divide_float(_Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float, _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float);
            float _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float, _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float);
            float _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float;
            Unity_Sine_float(_Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float);
            float _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float;
            Unity_Multiply_float_float(_Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float);
            float _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float;
            Unity_Add_float(_Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float, _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float);
            float3 _Multiply_79a115a2f2784bfda5b49d34a8db7386_Out_2_Vector3;
            Unity_Multiply_float3_float3(_NormalUnpack_a6518034dbcf44b0b4a9e33e6a1ca3f7_Out_1_Vector3, (_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxx), _Multiply_79a115a2f2784bfda5b49d34a8db7386_Out_2_Vector3);
            float3 _Multiply_70d73c8d6af7473b93889f81df9dd4ed_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_79a115a2f2784bfda5b49d34a8db7386_Out_2_Vector3, float3(0.3, 0.3, 0.3), _Multiply_70d73c8d6af7473b93889f81df9dd4ed_Out_2_Vector3);
            surface.NormalTS = _Multiply_70d73c8d6af7473b93889f81df9dd4ed_Out_2_Vector3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _ReflectionTex_TexelSize;
        float4 _RefractionTex_TexelSize;
        float4 _CausticsTex_TexelSize;
        float4 _DeepColor;
        float4 _ShallowColor;
        float _WaveSpeed;
        float _WaveScale;
        float4 _FoamTex_TexelSize;
        float _WaveFoamStrength;
        float _FoamSpeed;
        float _FoamThreshold;
        float _FoamFadeRate;
        float _WindStrength;
        float _ShorelineFoamStrength;
        float _ShorelineFoamMaxDepth;
        float _CausticsStrength;
        float _Depth;
        float _FresnelPower;
        float _RefractionDistorion;
        float _SparkleIntensity;
        float4 _LightColor0;
        float _Amplitude1;
        float _Wavelenght1;
        float2 _Direction1;
        float _Speed1;
        float _Amplitude2;
        float _Wavelenght2;
        float2 _Direction2;
        float _Speed2;
        float _FoamDepthThreshold;
        float _FoamIntensity;
        float4 _FoamNoiseTex_TexelSize;
        float _TwoConstant;
        float _PIConstant;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_ReflectionTex);
        SAMPLER(sampler_ReflectionTex);
        TEXTURE2D(_RefractionTex);
        SAMPLER(sampler_RefractionTex);
        TEXTURE2D(_CausticsTex);
        SAMPLER(sampler_CausticsTex);
        TEXTURE2D(_FoamTex);
        SAMPLER(sampler_FoamTex);
        TEXTURE2D(_FoamNoiseTex);
        SAMPLER(sampler_FoamNoiseTex);
        TEXTURECUBE(_ReflectionCubeMap);
        SAMPLER(sampler_ReflectionCubeMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_095b19eee2b9488abf2e03abc09c9cf7_Out_0_Vector4 = _DeepColor;
            float4 _Property_039818151c644b9c8cf17cdd0a4fe3ea_Out_0_Vector4 = _ShallowColor;
            float _SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float);
            float4 _Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4;
            Unity_Lerp_float4(_Property_095b19eee2b9488abf2e03abc09c9cf7_Out_0_Vector4, _Property_039818151c644b9c8cf17cdd0a4fe3ea_Out_0_Vector4, (_SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float.xxxx), _Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4);
            UnityTexture2D _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_5a01ecd713ae4fc5b1a2d7e9a91afa6b_Out_0_Vector4 = IN.uv0;
            float4 _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.tex, _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.samplerstate, _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.GetTransformedUV((_UV_5a01ecd713ae4fc5b1a2d7e9a91afa6b_Out_0_Vector4.xy)) );
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_R_4_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.r;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_G_5_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.g;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_B_6_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.b;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_A_7_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.a;
            float4 _Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4;
            Unity_Add_float4(_Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4, _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4, _Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4);
            float _Property_02a0d57c0dd94704b5f460809d75b330_Out_0_Float = _FoamFadeRate;
            float _Property_1fd0ccc19b3048efb56100c1201b01f2_Out_0_Float = _FoamThreshold;
            UnityTexture2D _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTex);
            float _Property_60eb08d0cb21444eaaa2a5ea1fdf235a_Out_0_Float = _WaveScale;
            float2 _TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_60eb08d0cb21444eaaa2a5ea1fdf235a_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2);
            float4 _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.tex, _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.samplerstate, _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2) );
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_R_4_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.r;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_G_5_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.g;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_B_6_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.b;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_A_7_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.a;
            float _Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float = _Amplitude1;
            float2 _Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2 = _Direction1;
            float _Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_A_4_Float = 0;
            float2 _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2 = float2(_Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float, _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float);
            float _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float;
            Unity_DotProduct_float2(_Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2, _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2, _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float);
            float _Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float = _Speed1;
            float _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float;
            Unity_Multiply_float_float(_Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float, IN.TimeParameters.z, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float);
            float _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float;
            Unity_Subtract_float(_DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float, _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float);
            float _Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float = _TwoConstant;
            float _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float = _PIConstant;
            float _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float;
            Unity_Multiply_float_float(_Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float, _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float, _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float);
            float _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float = _Wavelenght1;
            float _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float;
            Unity_Divide_float(_Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float, _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float);
            float _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float, _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float);
            float _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float;
            Unity_Sine_float(_Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float);
            float _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float;
            Unity_Multiply_float_float(_Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float, _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float);
            float _Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float = _Amplitude2;
            float2 _Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2 = _Direction2;
            float _Split_647deeb3d0dd470682efb9858d851041_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_647deeb3d0dd470682efb9858d851041_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_647deeb3d0dd470682efb9858d851041_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_647deeb3d0dd470682efb9858d851041_A_4_Float = 0;
            float2 _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2 = float2(_Split_647deeb3d0dd470682efb9858d851041_R_1_Float, _Split_647deeb3d0dd470682efb9858d851041_B_3_Float);
            float _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float;
            Unity_DotProduct_float2(_Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2, _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2, _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float);
            float _Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float = _Speed2;
            float _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float;
            Unity_Multiply_float_float(_Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float, IN.TimeParameters.z, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float);
            float _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float;
            Unity_Subtract_float(_DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float, _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float);
            float _Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float = _TwoConstant;
            float _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float = _PIConstant;
            float _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float;
            Unity_Multiply_float_float(_Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float, _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float, _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float);
            float _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float = _Wavelenght2;
            float _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float;
            Unity_Divide_float(_Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float, _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float);
            float _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float, _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float);
            float _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float;
            Unity_Sine_float(_Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float);
            float _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float;
            Unity_Multiply_float_float(_Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float);
            float _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float;
            Unity_Add_float(_Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float, _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float);
            float4 _Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4, (_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxxx), _Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4);
            UnityTexture2D _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamNoiseTex);
            float4 _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.tex, _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.samplerstate, _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_R_4_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.r;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_G_5_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.g;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_B_6_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.b;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_A_7_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.a;
            float _Property_6cad358dfaea42629685af54482e7342_Out_0_Float = _FoamIntensity;
            float4 _Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4, (_Property_6cad358dfaea42629685af54482e7342_Out_0_Float.xxxx), _Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4);
            float _Property_913f5b2f63b24ae5a66f5d92be101c66_Out_0_Float = _FoamSpeed;
            float4 _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4, (_Property_913f5b2f63b24ae5a66f5d92be101c66_Out_0_Float.xxxx), _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4);
            float4 _Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4, _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4, _Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4);
            float _Property_e02b1ca207cf4f579ec91183888fb147_Out_0_Float = _FoamDepthThreshold;
            float _SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float);
            float4 _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4;
            Unity_Smoothstep_float4(_Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4, (_Property_e02b1ca207cf4f579ec91183888fb147_Out_0_Float.xxxx), (_SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float.xxxx), _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4);
            float4 _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4;
            Unity_Add_float4((_Property_1fd0ccc19b3048efb56100c1201b01f2_Out_0_Float.xxxx), _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4, _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4);
            float4 _Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4;
            Unity_Subtract_float4((_Property_02a0d57c0dd94704b5f460809d75b330_Out_0_Float.xxxx), _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4, _Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4);
            float _Property_a63fc6bae8d14edc843219bd157e28e9_Out_0_Float = _WaveFoamStrength;
            float4 _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4, (_Property_a63fc6bae8d14edc843219bd157e28e9_Out_0_Float.xxxx), _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4);
            float4 _Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4;
            Unity_Add_float4(_Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4, _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4, _Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4);
            UnityTexture2D _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ReflectionTex);
            UnityTextureCube _Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap = UnityBuildTextureCubeStruct(_ReflectionCubeMap);
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_A_4_Float = 0;
            float2 _Vector2_ce6fbcae9335437aab8963ad06b894c5_Out_0_Vector2 = float2(_Split_761cfc6cff1b407c9870fb3a8fe6e9ad_R_1_Float, _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_B_3_Float);
            float _Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float;
            Unity_Multiply_float_float(_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float, 2, _Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float);
            float2 _Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_ce6fbcae9335437aab8963ad06b894c5_Out_0_Vector2, (_Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float.xx), _Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2);
            float2 _Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2, (IN.WorldSpaceViewDirection.xy), _Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2);
            float4 _SampleCubemap_e75d60130f2d4e7da4f0215f12d4ebef_Out_0_Vector4 = SAMPLE_TEXTURECUBE_LOD(_Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap.tex, _Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap.samplerstate, (float3(_Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2, 0.0)), float(0));
            float4 _Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleCubemap_e75d60130f2d4e7da4f0215f12d4ebef_Out_0_Vector4, float4(0.3, 0.3, 0.3, 0.3), _Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4);
            float4 _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.tex, _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.samplerstate, _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.GetTransformedUV((_Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4.xy)) );
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_R_4_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.r;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_G_5_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.g;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_B_6_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.b;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_A_7_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.a;
            float _Property_327e01c3795044ffa63b63e1944f45a2_Out_0_Float = _RefractionDistorion;
            float4 _Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4, (_Property_327e01c3795044ffa63b63e1944f45a2_Out_0_Float.xxxx), _Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4);
            UnityTexture2D _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RefractionTex);
            float4 _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.tex, _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.samplerstate, _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.GetTransformedUV((_Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4.xy)) );
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_R_4_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.r;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_G_5_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.g;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_B_6_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.b;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_A_7_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.a;
            float _Property_70b12ff6ef56428aa5a486e3737fa86e_Out_0_Float = _FresnelPower;
            float _FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_70b12ff6ef56428aa5a486e3737fa86e_Out_0_Float, _FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float);
            float4 _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4, _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4, (_FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float.xxxx), _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4);
            float4 _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4;
            Unity_Add_float4(_Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4, _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4, _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4);
            UnityTexture2D _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticsTex);
            float4 _UV_28f6b818761741b2b4c2b10c7a622b0a_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_28f6b818761741b2b4c2b10c7a622b0a_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2);
            float4 _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.tex, _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.samplerstate, _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2) );
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_R_4_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.r;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_G_5_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.g;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_B_6_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.b;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_A_7_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.a;
            float _Property_1b3931c88eac43bb829335204a37e9a6_Out_0_Float = _CausticsStrength;
            float4 _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4, (_Property_1b3931c88eac43bb829335204a37e9a6_Out_0_Float.xxxx), _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4);
            float4 _Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxxx), _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4, _Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4);
            float4 _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4, float4(0.3, 0.3, 0.3, 0.3), _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4);
            float4 _Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4;
            Unity_Add_float4(_Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4, _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4, _Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4);
            float _Property_2199df2931454b518d2b9d9c9a1de19b_Out_0_Float = _ShorelineFoamStrength;
            float _Property_f21c1332f7b24b4da7b24cd420bec761_Out_0_Float = _ShorelineFoamMaxDepth;
            float _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float);
            float _Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float;
            Unity_Lerp_float(_Property_2199df2931454b518d2b9d9c9a1de19b_Out_0_Float, _Property_f21c1332f7b24b4da7b24cd420bec761_Out_0_Float, _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float, _Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float);
            float4 _Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4;
            Unity_Add_float4(_Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4, (_Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float.xxxx), _Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4);
            float4 _UV_65a5cc357b884dd7af1304bb2518f5e9_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_65a5cc357b884dd7af1304bb2518f5e9_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2);
            float _SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(_TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2, float(500), _SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float);
            float _Property_6640be77490641c79ea1bdea6fd941dd_Out_0_Float = _SparkleIntensity;
            float _Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float, _Property_6640be77490641c79ea1bdea6fd941dd_Out_0_Float, _Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float);
            float _Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float, _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float, _Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float);
            float4 _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4;
            Unity_Add_float4(_Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4, (_Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float.xxxx), _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4);
            float4 _Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4;
            Unity_Add_float4(_Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4, _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4, _Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4);
            float4 _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4;
            Unity_Add_float4(_Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4, _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4, _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4);
            float4 _Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4;
            Unity_Add_float4(_Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4, _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4, _Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4);
            float4 _Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4, float4(0.35, 0.3, 0.28, 1), _Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4);
            surface.BaseColor = (_Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _ReflectionTex_TexelSize;
        float4 _RefractionTex_TexelSize;
        float4 _CausticsTex_TexelSize;
        float4 _DeepColor;
        float4 _ShallowColor;
        float _WaveSpeed;
        float _WaveScale;
        float4 _FoamTex_TexelSize;
        float _WaveFoamStrength;
        float _FoamSpeed;
        float _FoamThreshold;
        float _FoamFadeRate;
        float _WindStrength;
        float _ShorelineFoamStrength;
        float _ShorelineFoamMaxDepth;
        float _CausticsStrength;
        float _Depth;
        float _FresnelPower;
        float _RefractionDistorion;
        float _SparkleIntensity;
        float4 _LightColor0;
        float _Amplitude1;
        float _Wavelenght1;
        float2 _Direction1;
        float _Speed1;
        float _Amplitude2;
        float _Wavelenght2;
        float2 _Direction2;
        float _Speed2;
        float _FoamDepthThreshold;
        float _FoamIntensity;
        float4 _FoamNoiseTex_TexelSize;
        float _TwoConstant;
        float _PIConstant;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_ReflectionTex);
        SAMPLER(sampler_ReflectionTex);
        TEXTURE2D(_RefractionTex);
        SAMPLER(sampler_RefractionTex);
        TEXTURE2D(_CausticsTex);
        SAMPLER(sampler_CausticsTex);
        TEXTURE2D(_FoamTex);
        SAMPLER(sampler_FoamTex);
        TEXTURE2D(_FoamNoiseTex);
        SAMPLER(sampler_FoamNoiseTex);
        TEXTURECUBE(_ReflectionCubeMap);
        SAMPLER(sampler_ReflectionCubeMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _ReflectionTex_TexelSize;
        float4 _RefractionTex_TexelSize;
        float4 _CausticsTex_TexelSize;
        float4 _DeepColor;
        float4 _ShallowColor;
        float _WaveSpeed;
        float _WaveScale;
        float4 _FoamTex_TexelSize;
        float _WaveFoamStrength;
        float _FoamSpeed;
        float _FoamThreshold;
        float _FoamFadeRate;
        float _WindStrength;
        float _ShorelineFoamStrength;
        float _ShorelineFoamMaxDepth;
        float _CausticsStrength;
        float _Depth;
        float _FresnelPower;
        float _RefractionDistorion;
        float _SparkleIntensity;
        float4 _LightColor0;
        float _Amplitude1;
        float _Wavelenght1;
        float2 _Direction1;
        float _Speed1;
        float _Amplitude2;
        float _Wavelenght2;
        float2 _Direction2;
        float _Speed2;
        float _FoamDepthThreshold;
        float _FoamIntensity;
        float4 _FoamNoiseTex_TexelSize;
        float _TwoConstant;
        float _PIConstant;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_ReflectionTex);
        SAMPLER(sampler_ReflectionTex);
        TEXTURE2D(_RefractionTex);
        SAMPLER(sampler_RefractionTex);
        TEXTURE2D(_CausticsTex);
        SAMPLER(sampler_CausticsTex);
        TEXTURE2D(_FoamTex);
        SAMPLER(sampler_FoamTex);
        TEXTURE2D(_FoamNoiseTex);
        SAMPLER(sampler_FoamNoiseTex);
        TEXTURECUBE(_ReflectionCubeMap);
        SAMPLER(sampler_ReflectionCubeMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _ReflectionTex_TexelSize;
        float4 _RefractionTex_TexelSize;
        float4 _CausticsTex_TexelSize;
        float4 _DeepColor;
        float4 _ShallowColor;
        float _WaveSpeed;
        float _WaveScale;
        float4 _FoamTex_TexelSize;
        float _WaveFoamStrength;
        float _FoamSpeed;
        float _FoamThreshold;
        float _FoamFadeRate;
        float _WindStrength;
        float _ShorelineFoamStrength;
        float _ShorelineFoamMaxDepth;
        float _CausticsStrength;
        float _Depth;
        float _FresnelPower;
        float _RefractionDistorion;
        float _SparkleIntensity;
        float4 _LightColor0;
        float _Amplitude1;
        float _Wavelenght1;
        float2 _Direction1;
        float _Speed1;
        float _Amplitude2;
        float _Wavelenght2;
        float2 _Direction2;
        float _Speed2;
        float _FoamDepthThreshold;
        float _FoamIntensity;
        float4 _FoamNoiseTex_TexelSize;
        float _TwoConstant;
        float _PIConstant;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_ReflectionTex);
        SAMPLER(sampler_ReflectionTex);
        TEXTURE2D(_RefractionTex);
        SAMPLER(sampler_RefractionTex);
        TEXTURE2D(_CausticsTex);
        SAMPLER(sampler_CausticsTex);
        TEXTURE2D(_FoamTex);
        SAMPLER(sampler_FoamTex);
        TEXTURE2D(_FoamNoiseTex);
        SAMPLER(sampler_FoamNoiseTex);
        TEXTURECUBE(_ReflectionCubeMap);
        SAMPLER(sampler_ReflectionCubeMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_095b19eee2b9488abf2e03abc09c9cf7_Out_0_Vector4 = _DeepColor;
            float4 _Property_039818151c644b9c8cf17cdd0a4fe3ea_Out_0_Vector4 = _ShallowColor;
            float _SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float);
            float4 _Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4;
            Unity_Lerp_float4(_Property_095b19eee2b9488abf2e03abc09c9cf7_Out_0_Vector4, _Property_039818151c644b9c8cf17cdd0a4fe3ea_Out_0_Vector4, (_SceneDepth_7c9e55f9ad284125ab751e08ebb14161_Out_1_Float.xxxx), _Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4);
            UnityTexture2D _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _UV_5a01ecd713ae4fc5b1a2d7e9a91afa6b_Out_0_Vector4 = IN.uv0;
            float4 _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.tex, _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.samplerstate, _Property_cead32f4e6f542688d8eadf62f092bf2_Out_0_Texture2D.GetTransformedUV((_UV_5a01ecd713ae4fc5b1a2d7e9a91afa6b_Out_0_Vector4.xy)) );
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_R_4_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.r;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_G_5_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.g;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_B_6_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.b;
            float _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_A_7_Float = _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4.a;
            float4 _Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4;
            Unity_Add_float4(_Lerp_750cc7799f7247a9b88597c14fa57fae_Out_3_Vector4, _SampleTexture2D_6f32899c68334a5489871e651cb6aa31_RGBA_0_Vector4, _Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4);
            float _Property_02a0d57c0dd94704b5f460809d75b330_Out_0_Float = _FoamFadeRate;
            float _Property_1fd0ccc19b3048efb56100c1201b01f2_Out_0_Float = _FoamThreshold;
            UnityTexture2D _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTex);
            float _Property_60eb08d0cb21444eaaa2a5ea1fdf235a_Out_0_Float = _WaveScale;
            float2 _TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_60eb08d0cb21444eaaa2a5ea1fdf235a_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2);
            float4 _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.tex, _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.samplerstate, _Property_bfd9148f81394c7e8f1e29684912398b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_875553402d114031a45c1372229c8d35_Out_3_Vector2) );
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_R_4_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.r;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_G_5_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.g;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_B_6_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.b;
            float _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_A_7_Float = _SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4.a;
            float _Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float = _Amplitude1;
            float2 _Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2 = _Direction1;
            float _Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_5378cea9e2ea47b7b6063937b35460c9_A_4_Float = 0;
            float2 _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2 = float2(_Split_5378cea9e2ea47b7b6063937b35460c9_R_1_Float, _Split_5378cea9e2ea47b7b6063937b35460c9_B_3_Float);
            float _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float;
            Unity_DotProduct_float2(_Property_a6c9c35088fe4d45892610969bda00b3_Out_0_Vector2, _Vector2_db5fd616c3f84c0aaa138d93e1ba7a6c_Out_0_Vector2, _DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float);
            float _Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float = _Speed1;
            float _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float;
            Unity_Multiply_float_float(_Property_ba03b2b58a514c99ae1b29857facf726_Out_0_Float, IN.TimeParameters.z, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float);
            float _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float;
            Unity_Subtract_float(_DotProduct_b161868701ee424f980f1304acda07fe_Out_2_Float, _Multiply_3f78840aeb4848d5945654958998bdae_Out_2_Float, _Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float);
            float _Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float = _TwoConstant;
            float _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float = _PIConstant;
            float _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float;
            Unity_Multiply_float_float(_Property_02e0973cb5214e5da3cf5ad8f5a50389_Out_0_Float, _Property_e8519d69bf3249f89026078eca919a05_Out_0_Float, _Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float);
            float _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float = _Wavelenght1;
            float _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float;
            Unity_Divide_float(_Multiply_c00d5b1665894e6bbaf1d3cdfef86b92_Out_2_Float, _Property_60e4eb8263624016ac6586f38c300009_Out_0_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float);
            float _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_cc70da1e7b6c43d5b4f506390c4f4934_Out_2_Float, _Divide_6ad198cda62443168254b1a6fbaa4dfb_Out_2_Float, _Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float);
            float _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float;
            Unity_Sine_float(_Multiply_3669ed69f5644e9aa98bce9283f06b05_Out_2_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float);
            float _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float;
            Unity_Multiply_float_float(_Property_00946975e5aa4e939b3902377e26dc1f_Out_0_Float, _Sine_10f71ba6f81f42f99a4936cd900f3313_Out_1_Float, _Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float);
            float _Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float = _Amplitude2;
            float2 _Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2 = _Direction2;
            float _Split_647deeb3d0dd470682efb9858d851041_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_647deeb3d0dd470682efb9858d851041_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_647deeb3d0dd470682efb9858d851041_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_647deeb3d0dd470682efb9858d851041_A_4_Float = 0;
            float2 _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2 = float2(_Split_647deeb3d0dd470682efb9858d851041_R_1_Float, _Split_647deeb3d0dd470682efb9858d851041_B_3_Float);
            float _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float;
            Unity_DotProduct_float2(_Property_999a786312304320aeccdfe30413fde9_Out_0_Vector2, _Vector2_3fb6419766df42efa5f72a1c0af4c873_Out_0_Vector2, _DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float);
            float _Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float = _Speed2;
            float _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float;
            Unity_Multiply_float_float(_Property_8643bbc5db54470aa6e1d3bef592f8f3_Out_0_Float, IN.TimeParameters.z, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float);
            float _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float;
            Unity_Subtract_float(_DotProduct_f3a2501f2f584987866286bea8d0f011_Out_2_Float, _Multiply_835d7285f10248619a1c6fdb6bdd26e4_Out_2_Float, _Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float);
            float _Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float = _TwoConstant;
            float _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float = _PIConstant;
            float _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float;
            Unity_Multiply_float_float(_Property_35cb7bd1afdc4a6f96fc1aaee3921923_Out_0_Float, _Property_6c3d891264494e2db14fd1eb719da6c5_Out_0_Float, _Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float);
            float _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float = _Wavelenght2;
            float _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float;
            Unity_Divide_float(_Multiply_5760b60a54bf404f9f82a5e632545bf3_Out_2_Float, _Property_d79317d01ef34f64bc14fe12ed9ea404_Out_0_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float);
            float _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_d6f54810f9604ae8803f7344167f3ade_Out_2_Float, _Divide_c1a56e3835564169a3db34650cd6c4f8_Out_2_Float, _Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float);
            float _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float;
            Unity_Sine_float(_Multiply_b5d84cdc545a412aaef069a1276bc123_Out_2_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float);
            float _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float;
            Unity_Multiply_float_float(_Property_b29043e7489a473ba80fbc8677f970f6_Out_0_Float, _Sine_c268cf0b03ab4a42a4453904db6b35a1_Out_1_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float);
            float _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float;
            Unity_Add_float(_Multiply_45471f4f41ef4b3ab025dd03353b070c_Out_2_Float, _Multiply_3633d364d510427ea327ac3b8d55c508_Out_2_Float, _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float);
            float4 _Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ea4ae5b9bb6f4725ad1803eaf147db69_RGBA_0_Vector4, (_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxxx), _Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4);
            UnityTexture2D _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamNoiseTex);
            float4 _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.tex, _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.samplerstate, _Property_19d51d53201f4951a9fb2f0ddae62cc9_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_R_4_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.r;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_G_5_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.g;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_B_6_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.b;
            float _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_A_7_Float = _SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4.a;
            float _Property_6cad358dfaea42629685af54482e7342_Out_0_Float = _FoamIntensity;
            float4 _Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_a6edb3b82f054e7986494b25abf4b0b0_RGBA_0_Vector4, (_Property_6cad358dfaea42629685af54482e7342_Out_0_Float.xxxx), _Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4);
            float _Property_913f5b2f63b24ae5a66f5d92be101c66_Out_0_Float = _FoamSpeed;
            float4 _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_383d1d3f58b74b5d8b31deb5b192da52_Out_2_Vector4, (_Property_913f5b2f63b24ae5a66f5d92be101c66_Out_0_Float.xxxx), _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4);
            float4 _Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_adea5d1ce6a14ab7a59a2e22f03fbc69_Out_2_Vector4, _Multiply_c11d583dd8284d0c978564083a71525a_Out_2_Vector4, _Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4);
            float _Property_e02b1ca207cf4f579ec91183888fb147_Out_0_Float = _FoamDepthThreshold;
            float _SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float);
            float4 _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4;
            Unity_Smoothstep_float4(_Multiply_3df450fa1c43455685255407721ea4ab_Out_2_Vector4, (_Property_e02b1ca207cf4f579ec91183888fb147_Out_0_Float.xxxx), (_SceneDepth_c4bfecf7d191482c8a8ddd92fec5387a_Out_1_Float.xxxx), _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4);
            float4 _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4;
            Unity_Add_float4((_Property_1fd0ccc19b3048efb56100c1201b01f2_Out_0_Float.xxxx), _Smoothstep_32b345b8640b4ca197418e1a22562e39_Out_3_Vector4, _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4);
            float4 _Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4;
            Unity_Subtract_float4((_Property_02a0d57c0dd94704b5f460809d75b330_Out_0_Float.xxxx), _Add_c146461ef3734d5daf29b5c8008b2f04_Out_2_Vector4, _Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4);
            float _Property_a63fc6bae8d14edc843219bd157e28e9_Out_0_Float = _WaveFoamStrength;
            float4 _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Subtract_c160e57fcbb149a7b5e240aab3b24169_Out_2_Vector4, (_Property_a63fc6bae8d14edc843219bd157e28e9_Out_0_Float.xxxx), _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4);
            float4 _Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4;
            Unity_Add_float4(_Add_ab568fcf8c5e446f86aa4237a8626759_Out_2_Vector4, _Multiply_36e0ec88815341e3a6eb60c9127d2ac5_Out_2_Vector4, _Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4);
            UnityTexture2D _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ReflectionTex);
            UnityTextureCube _Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap = UnityBuildTextureCubeStruct(_ReflectionCubeMap);
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_A_4_Float = 0;
            float2 _Vector2_ce6fbcae9335437aab8963ad06b894c5_Out_0_Vector2 = float2(_Split_761cfc6cff1b407c9870fb3a8fe6e9ad_R_1_Float, _Split_761cfc6cff1b407c9870fb3a8fe6e9ad_B_3_Float);
            float _Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float;
            Unity_Multiply_float_float(_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float, 2, _Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float);
            float2 _Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_ce6fbcae9335437aab8963ad06b894c5_Out_0_Vector2, (_Multiply_38041a24ad954b808e88977de77a176e_Out_2_Float.xx), _Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2);
            float2 _Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a934efc4682d41b4bdaa2ab02e5e31c0_Out_2_Vector2, (IN.WorldSpaceViewDirection.xy), _Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2);
            float4 _SampleCubemap_e75d60130f2d4e7da4f0215f12d4ebef_Out_0_Vector4 = SAMPLE_TEXTURECUBE_LOD(_Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap.tex, _Property_22efe1a4e8fa4b88a125e169e95746d5_Out_0_Cubemap.samplerstate, (float3(_Add_5683d21e8d7a461693ae8d53b42ab75c_Out_2_Vector2, 0.0)), float(0));
            float4 _Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleCubemap_e75d60130f2d4e7da4f0215f12d4ebef_Out_0_Vector4, float4(0.3, 0.3, 0.3, 0.3), _Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4);
            float4 _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.tex, _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.samplerstate, _Property_ff35d380855042ceba4a6f3b45ea7ab9_Out_0_Texture2D.GetTransformedUV((_Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4.xy)) );
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_R_4_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.r;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_G_5_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.g;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_B_6_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.b;
            float _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_A_7_Float = _SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4.a;
            float _Property_327e01c3795044ffa63b63e1944f45a2_Out_0_Float = _RefractionDistorion;
            float4 _Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9b538705dc194ab8b9baf1d402b7e725_RGBA_0_Vector4, (_Property_327e01c3795044ffa63b63e1944f45a2_Out_0_Float.xxxx), _Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4);
            UnityTexture2D _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RefractionTex);
            float4 _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.tex, _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.samplerstate, _Property_323333a4ce194ebb831c22b7c4da4287_Out_0_Texture2D.GetTransformedUV((_Multiply_311fcc62a5394676b2b565e4b18a1ae7_Out_2_Vector4.xy)) );
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_R_4_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.r;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_G_5_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.g;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_B_6_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.b;
            float _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_A_7_Float = _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4.a;
            float _Property_70b12ff6ef56428aa5a486e3737fa86e_Out_0_Float = _FresnelPower;
            float _FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_70b12ff6ef56428aa5a486e3737fa86e_Out_0_Float, _FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float);
            float4 _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_e004a9f868304a609f95baa25f53a4aa_Out_2_Vector4, _SampleTexture2D_c6914a4295dd46e09140c5f4ea7582a4_RGBA_0_Vector4, (_FresnelEffect_2b1ade6201574915af146eebf99c4cdc_Out_3_Float.xxxx), _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4);
            float4 _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4;
            Unity_Add_float4(_Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4, _Lerp_c658ce4c9e6b406198dcac0b3cfc5183_Out_3_Vector4, _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4);
            UnityTexture2D _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticsTex);
            float4 _UV_28f6b818761741b2b4c2b10c7a622b0a_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_28f6b818761741b2b4c2b10c7a622b0a_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2);
            float4 _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.tex, _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.samplerstate, _Property_98ab02fc2bc044719427238fb98b4435_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_21105446df1544d5a8b7c6abb8ff0423_Out_3_Vector2) );
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_R_4_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.r;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_G_5_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.g;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_B_6_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.b;
            float _SampleTexture2D_bc189b92da274c218ebe363df50974e7_A_7_Float = _SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4.a;
            float _Property_1b3931c88eac43bb829335204a37e9a6_Out_0_Float = _CausticsStrength;
            float4 _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_bc189b92da274c218ebe363df50974e7_RGBA_0_Vector4, (_Property_1b3931c88eac43bb829335204a37e9a6_Out_0_Float.xxxx), _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4);
            float4 _Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float.xxxx), _Multiply_f80a2e562280480eab697ada75107550_Out_2_Vector4, _Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4);
            float4 _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_849eefbe787c4fff9e9fe6d77e654ddc_Out_2_Vector4, float4(0.3, 0.3, 0.3, 0.3), _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4);
            float4 _Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4;
            Unity_Add_float4(_Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4, _Multiply_fd60f29331054c7c9223fed5257a4b80_Out_2_Vector4, _Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4);
            float _Property_2199df2931454b518d2b9d9c9a1de19b_Out_0_Float = _ShorelineFoamStrength;
            float _Property_f21c1332f7b24b4da7b24cd420bec761_Out_0_Float = _ShorelineFoamMaxDepth;
            float _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float);
            float _Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float;
            Unity_Lerp_float(_Property_2199df2931454b518d2b9d9c9a1de19b_Out_0_Float, _Property_f21c1332f7b24b4da7b24cd420bec761_Out_0_Float, _SceneDepth_45c9dae1d58a4e94a676920e8a80b68a_Out_1_Float, _Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float);
            float4 _Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4;
            Unity_Add_float4(_Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4, (_Lerp_e5747328cfe64960b710543bc806c3cc_Out_3_Float.xxxx), _Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4);
            float4 _UV_65a5cc357b884dd7af1304bb2518f5e9_Out_0_Vector4 = IN.uv0;
            float2 _TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_65a5cc357b884dd7af1304bb2518f5e9_Out_0_Vector4.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2);
            float _SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(_TilingAndOffset_3d324ad576e9499a969f8aadd57739e0_Out_3_Vector2, float(500), _SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float);
            float _Property_6640be77490641c79ea1bdea6fd941dd_Out_0_Float = _SparkleIntensity;
            float _Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_60bf276a5c59421d85539ba7474340b6_Out_2_Float, _Property_6640be77490641c79ea1bdea6fd941dd_Out_0_Float, _Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float);
            float _Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_9ffe952ad0014b169f372ec23a20d9cd_Out_2_Float, _Add_3745ec8934644a37be9982e20fe27db7_Out_2_Float, _Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float);
            float4 _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4;
            Unity_Add_float4(_Add_aac606ee20a54d8f9a1003834cfc4699_Out_2_Vector4, (_Multiply_ecceffdf47c14e9bb8550b676be9bc02_Out_2_Float.xxxx), _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4);
            float4 _Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4;
            Unity_Add_float4(_Add_3944f4e0959d4242b235228a7c9c007f_Out_2_Vector4, _Add_a612d69991e8410e99f7b2b4b387f024_Out_2_Vector4, _Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4);
            float4 _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4;
            Unity_Add_float4(_Add_3572eab8fe6042fb9c543b511672d8c5_Out_2_Vector4, _Add_94bb9fe3663e473c92ed33005b5b7616_Out_2_Vector4, _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4);
            float4 _Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4;
            Unity_Add_float4(_Add_564139d38b714bd4829e5d5dfa7864c7_Out_2_Vector4, _Add_7d3b2214b32747748284f1f40cfe3cf1_Out_2_Vector4, _Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4);
            float4 _Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Add_dd3991f78c984d06a086b0f5bcb14444_Out_2_Vector4, float4(0.35, 0.3, 0.28, 1), _Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4);
            surface.BaseColor = (_Multiply_e013bf794ad140c5916de71d81352b19_Out_2_Vector4.xyz);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}
