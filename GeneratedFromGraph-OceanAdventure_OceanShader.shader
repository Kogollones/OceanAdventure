Shader "Shader Graphs/OceanAdventure_OceanShader"
{
    Properties
    {
        _EdgeColor("EdgeColor", Color) = (0.2509804, 0.3294118, 0.2862745, 1)
        [HDR]_FoamColor("FoamColor", Color) = (4, 4, 4, 1)
        _WaveFrequency("WaveFrequency", Float) = 3
        [ToggleUI]_ScreenSpaceReflections("ScreenSpaceReflections", Float) = 1
        _WaveSpeed("WaveSpeed", Float) = 0.1
        _WaveDist("WaveDist", Float) = 5
        _MaxWaveDist("MaxWaveDist", Float) = 250
        _Color("Color", Color) = (0.1921569, 0.2392157, 0.2627451, 1)
        _NormalStrength("NormalStrength", Float) = 0.1
        _Speed("Speed", Float) = 0.2
        _Tiling("Tiling", Float) = 0.2
        _Transparency("Transparency", Range(0, 1)) = 0.95
        _Caustic_Strength("Caustic_Strength", Range(0, 2)) = 2
        [ToggleUI]_UseFoam("UseFoam", Float) = 1
        _Displacement_Amount("Displacement_Amount", Float) = 0.2
        _Displacement_Scale("Displacement_Scale", Float) = 1
        _Displacement_Speed("Displacement_Speed", Float) = 0.1
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
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
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
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
        
        
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
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
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
             float4 fogFactorAndVertexLight : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
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
        float4 _EdgeColor;
        float4 _FoamColor;
        float _WaveFrequency;
        float _ScreenSpaceReflections;
        float _WaveSpeed;
        float _WaveDist;
        float _MaxWaveDist;
        float4 _Color;
        float _NormalStrength;
        float _Speed;
        float _Tiling;
        float _Transparency;
        float _Caustic_Strength;
        float _UseFoam;
        float _Displacement_Amount;
        float _Displacement_Scale;
        float _Displacement_Speed;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include "Assets/WaterWorks/Shaders/WaterSSR.hlsl"
        
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
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float Vector1_c541d038fef84e4aaa1dbed97e38d366, Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float IN, out float2 YZ_3, out float2 XZ_2, out float2 XY_1)
        {
        float _Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float = Vector1_c541d038fef84e4aaa1dbed97e38d366;
        float3 _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpacePosition, (_Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float.xxx), _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3);
        float _Split_1acef4fb48e74181929303b0d2263c94_R_1_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[0];
        float _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[1];
        float _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[2];
        float _Split_1acef4fb48e74181929303b0d2263c94_A_4_Float = 0;
        float2 _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_B_3_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        float2 _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float);
        float2 _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        YZ_3 = _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2;
        XZ_2 = _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2;
        XY_1 = _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float
        {
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 _UV, float _UseUV, Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float IN, out float3 WorldPos_1)
        {
        float _Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean = _UseUV;
        float2 _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2 = _UV;
        float4 _ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float2 _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2;
        Unity_Branch_float2(_Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean, _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2, (_ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4.xy), _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2);
        float _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float;
        Unity_SceneDepth_Eye_float((float4(_Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2, 0.0, 1.0)), _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float);
        float _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float;
        Unity_DotProduct_float3(IN.WorldSpaceViewDirection, (-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float);
        float3 _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3;
        Unity_Divide_float3(IN.WorldSpaceViewDirection, (_DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3);
        float3 _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3;
        Unity_Multiply_float3_float3((_SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3, _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3);
        float3 _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3, _WorldSpaceCameraPos, _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3);
        WorldPos_1 = _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        }
        
        float2 Unity_Voronoi_RandomVector_LegacySine_float (float2 UV, float offset)
        {
            Hash_LegacySine_2_2_float(UV, UV);
            return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
        }
        
        void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    float2 lattice = float2(x, y);
                    float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
                    if (d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        };
        
        void SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float _Offset, Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float IN, out float Distance_1)
        {
        Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.NDCPosition = IN.NDCPosition;
        float3 _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3;
        SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3);
        float3 _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3;
        Unity_Subtract_float3(_WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3, IN.WorldSpacePosition, _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3);
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_R_1_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[0];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[1];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_B_3_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[2];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_A_4_Float = 0;
        float _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float;
        Unity_Absolute_float(_Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float, _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float);
        float _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float = _Offset;
        float _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float;
        Unity_Clamp_float(_Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float, float(0), _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float);
        float _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        Unity_Divide_float(_Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float, _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float);
        Distance_1 = _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        float3 TimeParameters;
        };
        
        void SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(float _WaveFrequency, float _WaveSpeed, float _WaveDist, float _Offset, Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float IN, out float Waves_1, out float Foam_2)
        {
        float _Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float = _WaveDist;
        Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpacePosition = IN.WorldSpacePosition;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.NDCPosition = IN.NDCPosition;
        float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float;
        SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(_Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float);
        float _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float = _WaveSpeed;
        float _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float, _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float);
        float _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float = _Offset;
        float _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float;
        Unity_Add_float(_Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float, _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float);
        float _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float;
        Unity_Add_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float);
        float _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float = _WaveFrequency;
        float _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float;
        Unity_Multiply_float_float(_Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float);
        float _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float;
        Unity_Floor_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float);
        float _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float;
        Unity_Fraction_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float);
        float _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float;
        Unity_Power_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, float(20), _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float);
        float _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float;
        Unity_Add_float(_Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float, _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float, _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float);
        float _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float;
        Unity_Divide_float(_Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float);
        float _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float;
        Unity_Subtract_float(_Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float);
        float _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float;
        Unity_Clamp_float(_Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float, float(0), float(1), _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float);
        float _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float;
        Unity_Multiply_float_float(2, _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float, _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float);
        float _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Unity_Clamp_float(_Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float, float(0), float(1), _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float);
        float _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float;
        Unity_OneMinus_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float);
        float _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float;
        Unity_Power_float(_OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float, float(10), _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float);
        float _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float;
        Unity_Step_float(float(1), _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float);
        float _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float;
        Unity_OneMinus_float(_Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float);
        float _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float;
        Unity_Multiply_float_float(_Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float, _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float);
        float _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float;
        Unity_Clamp_float(_Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float, float(0), float(1), _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float);
        float _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float;
        Unity_OneMinus_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float);
        float _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float;
        Unity_Smoothstep_float(float(0), float(1), _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float);
        float _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float;
        Unity_Multiply_float_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float);
        float _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        Unity_Multiply_float_float(_Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float, _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float);
        Waves_1 = _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Foam_2 = _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void ref_float(float3 View, float3 Normal, float IOR, out float3 Out){
        Out = refract(View, Normal, IOR);
        }
        
        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float
        {
        float3 WorldSpaceNormal;
        float3 WorldSpaceTangent;
        float3 WorldSpaceBiTangent;
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float(float Vector1_9AC3B9A5, float3 Vector3_90258404, float Vector1_6604C6DE, Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float IN, out float3 Out_1)
        {
        float3 _SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3;
        Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3);
        float4 _ScreenPosition_0e0d43ed492f568494cf68c3f0d94863_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float3 _Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3;
        Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3);
        float3 _Property_06b2b93e9aad7f83bcbdcd89ffb2c49f_Out_0_Vector3 = Vector3_90258404;
        float3 _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3;
        Unity_Normalize_float3(_Property_06b2b93e9aad7f83bcbdcd89ffb2c49f_Out_0_Vector3, _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3);
        float _Property_5eb756389a644c899050838a3ceca5e1_Out_0_Float = Vector1_9AC3B9A5;
        float3 _refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3;
        ref_float(_Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3, _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3, _Property_5eb756389a644c899050838a3ceca5e1_Out_0_Float, _refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3);
        float3 _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3;
        {
        float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
        _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3 = TransformWorldToTangent(_refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3.xyz, tangentTransform, true);
        }
        float3 _Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3;
        Unity_Add_float3((_ScreenPosition_0e0d43ed492f568494cf68c3f0d94863_Out_0_Vector4.xyz), _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3, _Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3);
        float3 _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3;
        Unity_Floor_float3(_Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3, _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3);
        float3 _Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3;
        Unity_Subtract_float3(_Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3, _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3, _Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3);
        float2 _Vector2_4edaee860484198683cf81fd0bffdd27_Out_0_Vector2 = float2(float(1), float(1));
        float _Property_e30ceff597802a8b9a455fb3e3965d62_Out_0_Float = Vector1_6604C6DE;
        float _Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float;
        Unity_Divide_float(_Property_e30ceff597802a8b9a455fb3e3965d62_Out_0_Float, float(100), _Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float);
        float _Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float;
        Unity_Clamp_float(_Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float, float(0), float(5), _Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float);
        float2 _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_4edaee860484198683cf81fd0bffdd27_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2);
        float2 _Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2, _Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2);
        float3 _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2, 0.0, 1.0)), _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3);
        float3 _Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3;
        Unity_Add_float3(_SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3, _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3, _Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3);
        float2 _Vector2_19ef821db1cdc783a43742b9cf51b8c8_Out_0_Vector2 = float2(float(-1), float(1));
        float2 _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_19ef821db1cdc783a43742b9cf51b8c8_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2);
        float2 _Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2, _Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2);
        float3 _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2, 0.0, 1.0)), _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3);
        float3 _Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3;
        Unity_Add_float3(_Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3, _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3, _Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3);
        float2 _Vector2_fb7f3e085d3ebe84b7178b3bc4a39da8_Out_0_Vector2 = float2(float(1), float(-1));
        float2 _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_fb7f3e085d3ebe84b7178b3bc4a39da8_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2);
        float2 _Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2, _Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2);
        float3 _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2, 0.0, 1.0)), _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3);
        float3 _Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3;
        Unity_Add_float3(_Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3, _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3, _Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3);
        float2 _Vector2_9e6584c2279b638190dff9a888cf9a4d_Out_0_Vector2 = float2(float(-1), float(-1));
        float2 _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_9e6584c2279b638190dff9a888cf9a4d_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2);
        float2 _Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2, _Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2);
        float3 _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2, 0.0, 1.0)), _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3);
        float3 _Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3;
        Unity_Add_float3(_Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3, _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3, _Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3);
        float _Float_62fb265fcb81c2809fc6b96dcab9cf54_Out_0_Float = float(5);
        float3 _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3;
        Unity_Divide_float3(_Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3, (_Float_62fb265fcb81c2809fc6b96dcab9cf54_Out_0_Float.xxx), _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3);
        Out_1 = _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
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
            float _Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_f0b669abeb8b471ab09abf291dad8815_A_4_Float = 0;
            float _Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float = _Displacement_Scale;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_d51af62a44f34b2eb621da1dbe974c41;
            _WSUVWater_d51af62a44f34b2eb621da1dbe974c41.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2);
            float _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float = _Displacement_Speed;
            float _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float, _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float);
            float2 _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, (_Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float.xx), _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2);
            float _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2, float(2), _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float);
            float _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float = _Displacement_Amount;
            float _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float, _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float);
            float _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float;
            Unity_Add_float(_Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float);
            float3 _Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3 = float3(_Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float, _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float);
            float3 _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
            _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3 = TransformWorldToObject(_Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3.xyz);
            description.Position = _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e;
            _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e.NDCPosition = IN.NDCPosition;
            float3 _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3;
            SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e, _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3);
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_R_1_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[0];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_G_2_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[1];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_B_3_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[2];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_A_4_Float = 0;
            float2 _Vector2_c0a539d837d74542b502faac38a301ce_Out_0_Vector2 = float2(_Split_af2dcc47ab1f44c09a4753a196a06d9c_R_1_Float, _Split_af2dcc47ab1f44c09a4753a196a06d9c_B_3_Float);
            float _Property_d5ee87edeaeb46438ba81528f2801bc2_Out_0_Float = _Speed;
            float _Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d5ee87edeaeb46438ba81528f2801bc2_Out_0_Float, _Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float);
            float _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float, 20, _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float);
            float _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float;
            float _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_Vector2_c0a539d837d74542b502faac38a301ce_Out_0_Vector2, _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float, float(0.5), _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float, _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Cells_4_Float);
            float _Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float;
            Unity_Power_float(_Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float, float(3), _Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float);
            float _Property_274d0ef360aa4c7a9365ff75e7b4395b_Out_0_Float = _Caustic_Strength;
            float _Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float;
            Unity_Multiply_float_float(_Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float, _Property_274d0ef360aa4c7a9365ff75e7b4395b_Out_0_Float, _Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(5), _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e, _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float);
            float _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float, _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float);
            float _Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float, _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float, _Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float);
            float _Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float = _WaveFrequency;
            float _Property_477adb340d344e78a50e313038d7008b_Out_0_Float = _WaveSpeed;
            float _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float = _WaveDist;
            float _Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370;
            _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2);
            float _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float = _Speed;
            float _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float, _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float);
            float _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float;
            Unity_Divide_float(_Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float, float(5), _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float);
            float2 _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (1, 1), (_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float.xx), _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2);
            float _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2, float(50), _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float);
            float _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float;
            Unity_Negate_float(_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float, _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float);
            float2 _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float.xx), _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2);
            float _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2, float(50), _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float);
            float _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float;
            Unity_Add_float(_GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float, _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float, _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float);
            float _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float;
            Unity_Divide_float(_Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float, float(100), _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float);
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_5b92dfc7e363488d925b69046c47538f;
            _WSUVWater_5b92dfc7e363488d925b69046c47538f.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float(0.5), _WSUVWater_5b92dfc7e363488d925b69046c47538f, _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2);
            float _Property_762f6624e50447109a1a63175dcb252b_Out_0_Float = _WaveSpeed;
            float _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float;
            Unity_Multiply_float_float(_Property_762f6624e50447109a1a63175dcb252b_Out_0_Float, 100, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float);
            float _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float);
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float;
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(1), _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float);
            float _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float;
            Unity_Remap_float(_Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, float2 (0, 1), float2 (-0.02, 0.02), _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float);
            float _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float;
            Unity_Add_float(_Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float, _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float, _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float);
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float;
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(2), _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float);
            float _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float;
            Unity_Remap_float(_Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, float2 (0, 1), float2 (-0.01, 0.01), _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float);
            float _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float;
            Unity_Add_float(_Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float, _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float, _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float);
            float _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, 0.2, _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float);
            float2 _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, (_Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float.xx), _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2);
            float _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2, float(0.1), _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float);
            float _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float;
            Unity_Remap_float(_GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float, float2 (0, 1), float2 (-0.05, 0.05), _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float);
            float _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float;
            Unity_Add_float(_Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float, _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float);
            Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpacePosition = IN.WorldSpacePosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.NDCPosition = IN.NDCPosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.TimeParameters = IN.TimeParameters;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float;
            SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(_Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float, _Property_477adb340d344e78a50e313038d7008b_Out_0_Float, _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float);
            float _Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float);
            float _Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float;
            Unity_Add_float(_Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float, float(1), _Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float);
            float _Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_36fa2fa042a646e3884f906afce491d4;
            _WSUVWater_36fa2fa042a646e3884f906afce491d4.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float, _WSUVWater_36fa2fa042a646e3884f906afce491d4, _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2);
            float _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float = _Speed;
            float _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float, _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float);
            float _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float;
            Unity_Add_float(_Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float, float(15), _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float);
            float2 _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (1, 1), (_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float.xx), _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2);
            float _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2, float(10), _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float);
            float _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float;
            Unity_Negate_float(_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float, _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float);
            float2 _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float.xx), _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2);
            float _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2, float(10), _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float);
            float _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float;
            Unity_Add_float(_GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float, _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float, _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float);
            float _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float;
            Unity_Divide_float(_Add_17adcc70e6964669b273ffa660c43379_Out_2_Float, float(2), _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float);
            float3 _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3);
            float3 _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3;
            Unity_Power_float3(_Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3, float3(0.8, 5, 0.8), _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3);
            float _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[0];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[1];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[2];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_A_4_Float = 0;
            float _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float;
            Unity_Multiply_float_float(_Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float, _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float);
            float _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float = _Speed;
            float _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float, _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float);
            float _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float, 5, _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2, _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2);
            float _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float = _Speed;
            float _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float, _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float);
            float _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float;
            Unity_Add_float(_Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float, float(15), _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float);
            float2 _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (1, 1), (_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float.xx), _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2);
            float _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2, float(10), _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float);
            float _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float;
            Unity_Negate_float(_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float, _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float);
            float2 _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float.xx), _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2);
            float _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2, float(10), _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float);
            float _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float;
            Unity_Add_float(_GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float, _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float, _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float);
            float _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float;
            Unity_Divide_float(_Add_230c1475b56243bf8ed4151c26453420_Out_2_Float, float(2), _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float);
            float _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float;
            Unity_Multiply_float_float(_Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float);
            float _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float;
            Unity_Add_float(_Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float, _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float);
            float2 _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2, _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2, _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2);
            float _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float = _Speed;
            float _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float, _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float);
            float _Add_983001d85ada4e5396410433f0861366_Out_2_Float;
            Unity_Add_float(_Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float, float(15), _Add_983001d85ada4e5396410433f0861366_Out_2_Float);
            float2 _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (1, 1), (_Add_983001d85ada4e5396410433f0861366_Out_2_Float.xx), _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2);
            float _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2, float(10), _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float);
            float _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float;
            Unity_Negate_float(_Add_983001d85ada4e5396410433f0861366_Out_2_Float, _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float);
            float2 _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float.xx), _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2);
            float _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2, float(10), _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float);
            float _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float;
            Unity_Add_float(_GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float, _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float, _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float);
            float _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float;
            Unity_Divide_float(_Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float, float(2), _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float);
            float _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float);
            float _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float;
            Unity_Add_float(_Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float, _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float);
            float _Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float = _NormalStrength;
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3;
            float3x3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Add_b59ffb521828459097b93f52a7273e22_Out_2_Float,_Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix, _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3);
            float3 _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3);
            float3 _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3);
            Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float _RefractionWater_1dc846b8009e42daa40194bfa238ccf5;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceNormal = IN.WorldSpaceNormal;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceTangent = IN.WorldSpaceTangent;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.NDCPosition = IN.NDCPosition;
            float3 _RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3;
            SG_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float(float(0), _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3, float(0), _RefractionWater_1dc846b8009e42daa40194bfa238ccf5, _RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3);
            float3 _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3;
            Unity_Divide_float3(_RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3, float3(4, 4, 4), _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3);
            float3 _Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float.xxx), _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3, _Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3);
            float _Property_435087f89a0844699f112036328deb26_Out_0_Boolean = _ScreenSpaceReflections;
            float4 _ScreenPosition_1edb3c7d82804b74905a8e863bff1c6b_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float3 _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, float(0.2), _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3);
            float3 _SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3;
            SSR_float(IN.WorldSpaceViewDirection, float(0.2), _ScreenPosition_1edb3c7d82804b74905a8e863bff1c6b_Out_0_Vector4, float(15), float(0.5), float(1), _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3, IN.WorldSpacePosition, 0, _SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3);
            float3 _SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3;
            Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3);
            float _SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float);
            float3 _Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3, (_SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float.xxx), _Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3);
            float3 _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3, float3(0, 0, 0), _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3);
            float3 _Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3;
            Unity_Add_float3(_SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3, _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3, _Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3);
            float4 _Property_e872ea45cad54716aa3bfdc09420466c_Out_0_Vector4 = _EdgeColor;
            float4 _Property_a836ea15ef7548cfaaa54fe15300f69e_Out_0_Vector4 = _Color;
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(5), _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd, _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float);
            float _OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float, _OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float);
            float4 _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_632fd0c5217a4c1f85635b2663b7f106_R_1_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[0];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_G_2_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[1];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_B_3_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[2];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[3];
            float _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float = _MaxWaveDist;
            float _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float;
            Unity_Clamp_float(_Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float, float(0), _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float, _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float);
            float _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float = _MaxWaveDist;
            float _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float;
            Unity_Divide_float(_Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float, _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float, _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float);
            float _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float;
            Unity_OneMinus_float(_Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float);
            float _Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float);
            float _OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float;
            Unity_OneMinus_float(_Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float, _OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float);
            float4 _Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4;
            Unity_Lerp_float4(_Property_e872ea45cad54716aa3bfdc09420466c_Out_0_Vector4, _Property_a836ea15ef7548cfaaa54fe15300f69e_Out_0_Vector4, (_OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float.xxxx), _Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4);
            float4 _Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4, float4(0.5, 0.5, 0.5, 1), _Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4);
            float3 _Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3, (_Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4.xyz), _Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3);
            float _FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(1), _FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float);
            float3 _Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3, (_FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float.xxx), _Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3);
            float3 _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3;
            Unity_Add_float3(_Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3, (_Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4.xyz), _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3);
            float3 _Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3;
            Unity_Branch_float3(_Property_435087f89a0844699f112036328deb26_Out_0_Boolean, _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3, (_Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4.xyz), _Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3);
            float4 _Property_383d38dddb2c43959c6bb3f96b7dac8b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _Property_62bafa60731645a8987f0591e2774b91_Out_0_Boolean = _UseFoam;
            float _Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float;
            Unity_Branch_float(_Property_62bafa60731645a8987f0591e2774b91_Out_0_Boolean, float(1), float(0), _Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float);
            float _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float;
            Unity_Multiply_float_float(_Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float, _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float);
            float _Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float, _Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float);
            float _Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float;
            Unity_Clamp_float(_Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float, float(0), float(1), _Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float);
            float3 _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3;
            Unity_Lerp_float3(_Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3, (_Property_383d38dddb2c43959c6bb3f96b7dac8b_Out_0_Vector4.xyz), (_Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float.xxx), _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3);
            float _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float;
            Unity_OneMinus_float(_WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float);
            float _Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float, _Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float);
            float _OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float;
            Unity_OneMinus_float(_Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float, _OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float);
            float _Property_6595fb42eef04aeca117629c498ea6d1_Out_0_Float = _Transparency;
            float _Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float, _Property_6595fb42eef04aeca117629c498ea6d1_Out_0_Float, _Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float);
            float3 _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3;
            Unity_Lerp_float3(_Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3, _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3, (_Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float.xxx), _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3);
            float _Add_7e98ff6b8f8340219e3a2ec06ccd17fd_Out_2_Float;
            Unity_Add_float(_WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float, _Add_7e98ff6b8f8340219e3a2ec06ccd17fd_Out_2_Float);
            float _Property_d8abdfff88934758906aa518a31078e1_Out_0_Boolean = _UseFoam;
            float _Branch_736b55481aea4fc0b8afd7acfc734644_Out_3_Float;
            Unity_Branch_float(_Property_d8abdfff88934758906aa518a31078e1_Out_0_Boolean, float(0.5), float(0), _Branch_736b55481aea4fc0b8afd7acfc734644_Out_3_Float);
            float3 _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Out_1_Vector3;
            float3x3 _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Add_7e98ff6b8f8340219e3a2ec06ccd17fd_Out_2_Float,_Branch_736b55481aea4fc0b8afd7acfc734644_Out_3_Float,_NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Position,_NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_TangentMatrix, _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Out_1_Vector3);
            float3 _NormalBlend_e9da2f02159743cf818eeb703b494873_Out_2_Vector3;
            Unity_NormalBlend_float(_NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Out_1_Vector3, _NormalBlend_e9da2f02159743cf818eeb703b494873_Out_2_Vector3);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_72c92735390a461dac7c71af8138c538;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(0.1), _EdgeDistance_72c92735390a461dac7c71af8138c538, _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float);
            float _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float);
            float _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float, _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float);
            float _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float, _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float);
            surface.BaseColor = _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3;
            surface.NormalTS = _NormalBlend_e9da2f02159743cf818eeb703b494873_Out_2_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = float(1);
            surface.Occlusion = float(1);
            surface.Alpha = _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
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
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
        
        
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
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
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
             float4 fogFactorAndVertexLight : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
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
        float4 _EdgeColor;
        float4 _FoamColor;
        float _WaveFrequency;
        float _ScreenSpaceReflections;
        float _WaveSpeed;
        float _WaveDist;
        float _MaxWaveDist;
        float4 _Color;
        float _NormalStrength;
        float _Speed;
        float _Tiling;
        float _Transparency;
        float _Caustic_Strength;
        float _UseFoam;
        float _Displacement_Amount;
        float _Displacement_Scale;
        float _Displacement_Speed;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include "Assets/WaterWorks/Shaders/WaterSSR.hlsl"
        
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
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float Vector1_c541d038fef84e4aaa1dbed97e38d366, Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float IN, out float2 YZ_3, out float2 XZ_2, out float2 XY_1)
        {
        float _Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float = Vector1_c541d038fef84e4aaa1dbed97e38d366;
        float3 _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpacePosition, (_Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float.xxx), _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3);
        float _Split_1acef4fb48e74181929303b0d2263c94_R_1_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[0];
        float _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[1];
        float _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[2];
        float _Split_1acef4fb48e74181929303b0d2263c94_A_4_Float = 0;
        float2 _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_B_3_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        float2 _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float);
        float2 _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        YZ_3 = _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2;
        XZ_2 = _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2;
        XY_1 = _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float
        {
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 _UV, float _UseUV, Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float IN, out float3 WorldPos_1)
        {
        float _Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean = _UseUV;
        float2 _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2 = _UV;
        float4 _ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float2 _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2;
        Unity_Branch_float2(_Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean, _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2, (_ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4.xy), _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2);
        float _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float;
        Unity_SceneDepth_Eye_float((float4(_Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2, 0.0, 1.0)), _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float);
        float _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float;
        Unity_DotProduct_float3(IN.WorldSpaceViewDirection, (-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float);
        float3 _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3;
        Unity_Divide_float3(IN.WorldSpaceViewDirection, (_DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3);
        float3 _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3;
        Unity_Multiply_float3_float3((_SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3, _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3);
        float3 _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3, _WorldSpaceCameraPos, _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3);
        WorldPos_1 = _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        }
        
        float2 Unity_Voronoi_RandomVector_LegacySine_float (float2 UV, float offset)
        {
            Hash_LegacySine_2_2_float(UV, UV);
            return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
        }
        
        void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    float2 lattice = float2(x, y);
                    float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
                    if (d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        };
        
        void SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float _Offset, Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float IN, out float Distance_1)
        {
        Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.NDCPosition = IN.NDCPosition;
        float3 _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3;
        SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3);
        float3 _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3;
        Unity_Subtract_float3(_WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3, IN.WorldSpacePosition, _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3);
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_R_1_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[0];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[1];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_B_3_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[2];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_A_4_Float = 0;
        float _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float;
        Unity_Absolute_float(_Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float, _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float);
        float _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float = _Offset;
        float _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float;
        Unity_Clamp_float(_Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float, float(0), _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float);
        float _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        Unity_Divide_float(_Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float, _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float);
        Distance_1 = _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        float3 TimeParameters;
        };
        
        void SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(float _WaveFrequency, float _WaveSpeed, float _WaveDist, float _Offset, Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float IN, out float Waves_1, out float Foam_2)
        {
        float _Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float = _WaveDist;
        Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpacePosition = IN.WorldSpacePosition;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.NDCPosition = IN.NDCPosition;
        float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float;
        SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(_Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float);
        float _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float = _WaveSpeed;
        float _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float, _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float);
        float _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float = _Offset;
        float _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float;
        Unity_Add_float(_Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float, _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float);
        float _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float;
        Unity_Add_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float);
        float _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float = _WaveFrequency;
        float _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float;
        Unity_Multiply_float_float(_Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float);
        float _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float;
        Unity_Floor_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float);
        float _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float;
        Unity_Fraction_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float);
        float _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float;
        Unity_Power_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, float(20), _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float);
        float _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float;
        Unity_Add_float(_Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float, _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float, _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float);
        float _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float;
        Unity_Divide_float(_Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float);
        float _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float;
        Unity_Subtract_float(_Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float);
        float _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float;
        Unity_Clamp_float(_Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float, float(0), float(1), _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float);
        float _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float;
        Unity_Multiply_float_float(2, _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float, _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float);
        float _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Unity_Clamp_float(_Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float, float(0), float(1), _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float);
        float _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float;
        Unity_OneMinus_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float);
        float _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float;
        Unity_Power_float(_OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float, float(10), _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float);
        float _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float;
        Unity_Step_float(float(1), _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float);
        float _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float;
        Unity_OneMinus_float(_Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float);
        float _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float;
        Unity_Multiply_float_float(_Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float, _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float);
        float _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float;
        Unity_Clamp_float(_Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float, float(0), float(1), _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float);
        float _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float;
        Unity_OneMinus_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float);
        float _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float;
        Unity_Smoothstep_float(float(0), float(1), _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float);
        float _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float;
        Unity_Multiply_float_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float);
        float _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        Unity_Multiply_float_float(_Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float, _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float);
        Waves_1 = _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Foam_2 = _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void ref_float(float3 View, float3 Normal, float IOR, out float3 Out){
        Out = refract(View, Normal, IOR);
        }
        
        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float
        {
        float3 WorldSpaceNormal;
        float3 WorldSpaceTangent;
        float3 WorldSpaceBiTangent;
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float(float Vector1_9AC3B9A5, float3 Vector3_90258404, float Vector1_6604C6DE, Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float IN, out float3 Out_1)
        {
        float3 _SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3;
        Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3);
        float4 _ScreenPosition_0e0d43ed492f568494cf68c3f0d94863_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float3 _Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3;
        Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3);
        float3 _Property_06b2b93e9aad7f83bcbdcd89ffb2c49f_Out_0_Vector3 = Vector3_90258404;
        float3 _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3;
        Unity_Normalize_float3(_Property_06b2b93e9aad7f83bcbdcd89ffb2c49f_Out_0_Vector3, _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3);
        float _Property_5eb756389a644c899050838a3ceca5e1_Out_0_Float = Vector1_9AC3B9A5;
        float3 _refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3;
        ref_float(_Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3, _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3, _Property_5eb756389a644c899050838a3ceca5e1_Out_0_Float, _refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3);
        float3 _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3;
        {
        float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
        _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3 = TransformWorldToTangent(_refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3.xyz, tangentTransform, true);
        }
        float3 _Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3;
        Unity_Add_float3((_ScreenPosition_0e0d43ed492f568494cf68c3f0d94863_Out_0_Vector4.xyz), _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3, _Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3);
        float3 _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3;
        Unity_Floor_float3(_Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3, _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3);
        float3 _Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3;
        Unity_Subtract_float3(_Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3, _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3, _Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3);
        float2 _Vector2_4edaee860484198683cf81fd0bffdd27_Out_0_Vector2 = float2(float(1), float(1));
        float _Property_e30ceff597802a8b9a455fb3e3965d62_Out_0_Float = Vector1_6604C6DE;
        float _Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float;
        Unity_Divide_float(_Property_e30ceff597802a8b9a455fb3e3965d62_Out_0_Float, float(100), _Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float);
        float _Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float;
        Unity_Clamp_float(_Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float, float(0), float(5), _Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float);
        float2 _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_4edaee860484198683cf81fd0bffdd27_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2);
        float2 _Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2, _Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2);
        float3 _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2, 0.0, 1.0)), _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3);
        float3 _Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3;
        Unity_Add_float3(_SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3, _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3, _Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3);
        float2 _Vector2_19ef821db1cdc783a43742b9cf51b8c8_Out_0_Vector2 = float2(float(-1), float(1));
        float2 _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_19ef821db1cdc783a43742b9cf51b8c8_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2);
        float2 _Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2, _Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2);
        float3 _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2, 0.0, 1.0)), _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3);
        float3 _Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3;
        Unity_Add_float3(_Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3, _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3, _Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3);
        float2 _Vector2_fb7f3e085d3ebe84b7178b3bc4a39da8_Out_0_Vector2 = float2(float(1), float(-1));
        float2 _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_fb7f3e085d3ebe84b7178b3bc4a39da8_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2);
        float2 _Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2, _Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2);
        float3 _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2, 0.0, 1.0)), _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3);
        float3 _Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3;
        Unity_Add_float3(_Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3, _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3, _Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3);
        float2 _Vector2_9e6584c2279b638190dff9a888cf9a4d_Out_0_Vector2 = float2(float(-1), float(-1));
        float2 _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_9e6584c2279b638190dff9a888cf9a4d_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2);
        float2 _Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2, _Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2);
        float3 _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2, 0.0, 1.0)), _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3);
        float3 _Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3;
        Unity_Add_float3(_Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3, _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3, _Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3);
        float _Float_62fb265fcb81c2809fc6b96dcab9cf54_Out_0_Float = float(5);
        float3 _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3;
        Unity_Divide_float3(_Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3, (_Float_62fb265fcb81c2809fc6b96dcab9cf54_Out_0_Float.xxx), _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3);
        Out_1 = _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
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
            float _Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_f0b669abeb8b471ab09abf291dad8815_A_4_Float = 0;
            float _Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float = _Displacement_Scale;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_d51af62a44f34b2eb621da1dbe974c41;
            _WSUVWater_d51af62a44f34b2eb621da1dbe974c41.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2);
            float _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float = _Displacement_Speed;
            float _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float, _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float);
            float2 _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, (_Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float.xx), _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2);
            float _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2, float(2), _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float);
            float _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float = _Displacement_Amount;
            float _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float, _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float);
            float _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float;
            Unity_Add_float(_Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float);
            float3 _Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3 = float3(_Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float, _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float);
            float3 _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
            _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3 = TransformWorldToObject(_Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3.xyz);
            description.Position = _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e;
            _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e.NDCPosition = IN.NDCPosition;
            float3 _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3;
            SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e, _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3);
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_R_1_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[0];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_G_2_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[1];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_B_3_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[2];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_A_4_Float = 0;
            float2 _Vector2_c0a539d837d74542b502faac38a301ce_Out_0_Vector2 = float2(_Split_af2dcc47ab1f44c09a4753a196a06d9c_R_1_Float, _Split_af2dcc47ab1f44c09a4753a196a06d9c_B_3_Float);
            float _Property_d5ee87edeaeb46438ba81528f2801bc2_Out_0_Float = _Speed;
            float _Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d5ee87edeaeb46438ba81528f2801bc2_Out_0_Float, _Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float);
            float _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float, 20, _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float);
            float _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float;
            float _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_Vector2_c0a539d837d74542b502faac38a301ce_Out_0_Vector2, _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float, float(0.5), _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float, _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Cells_4_Float);
            float _Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float;
            Unity_Power_float(_Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float, float(3), _Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float);
            float _Property_274d0ef360aa4c7a9365ff75e7b4395b_Out_0_Float = _Caustic_Strength;
            float _Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float;
            Unity_Multiply_float_float(_Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float, _Property_274d0ef360aa4c7a9365ff75e7b4395b_Out_0_Float, _Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(5), _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e, _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float);
            float _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float, _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float);
            float _Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float, _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float, _Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float);
            float _Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float = _WaveFrequency;
            float _Property_477adb340d344e78a50e313038d7008b_Out_0_Float = _WaveSpeed;
            float _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float = _WaveDist;
            float _Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370;
            _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2);
            float _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float = _Speed;
            float _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float, _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float);
            float _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float;
            Unity_Divide_float(_Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float, float(5), _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float);
            float2 _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (1, 1), (_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float.xx), _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2);
            float _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2, float(50), _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float);
            float _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float;
            Unity_Negate_float(_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float, _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float);
            float2 _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float.xx), _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2);
            float _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2, float(50), _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float);
            float _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float;
            Unity_Add_float(_GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float, _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float, _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float);
            float _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float;
            Unity_Divide_float(_Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float, float(100), _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float);
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_5b92dfc7e363488d925b69046c47538f;
            _WSUVWater_5b92dfc7e363488d925b69046c47538f.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float(0.5), _WSUVWater_5b92dfc7e363488d925b69046c47538f, _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2);
            float _Property_762f6624e50447109a1a63175dcb252b_Out_0_Float = _WaveSpeed;
            float _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float;
            Unity_Multiply_float_float(_Property_762f6624e50447109a1a63175dcb252b_Out_0_Float, 100, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float);
            float _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float);
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float;
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(1), _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float);
            float _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float;
            Unity_Remap_float(_Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, float2 (0, 1), float2 (-0.02, 0.02), _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float);
            float _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float;
            Unity_Add_float(_Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float, _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float, _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float);
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float;
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(2), _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float);
            float _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float;
            Unity_Remap_float(_Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, float2 (0, 1), float2 (-0.01, 0.01), _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float);
            float _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float;
            Unity_Add_float(_Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float, _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float, _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float);
            float _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, 0.2, _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float);
            float2 _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, (_Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float.xx), _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2);
            float _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2, float(0.1), _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float);
            float _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float;
            Unity_Remap_float(_GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float, float2 (0, 1), float2 (-0.05, 0.05), _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float);
            float _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float;
            Unity_Add_float(_Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float, _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float);
            Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpacePosition = IN.WorldSpacePosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.NDCPosition = IN.NDCPosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.TimeParameters = IN.TimeParameters;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float;
            SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(_Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float, _Property_477adb340d344e78a50e313038d7008b_Out_0_Float, _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float);
            float _Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float);
            float _Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float;
            Unity_Add_float(_Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float, float(1), _Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float);
            float _Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_36fa2fa042a646e3884f906afce491d4;
            _WSUVWater_36fa2fa042a646e3884f906afce491d4.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float, _WSUVWater_36fa2fa042a646e3884f906afce491d4, _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2);
            float _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float = _Speed;
            float _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float, _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float);
            float _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float;
            Unity_Add_float(_Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float, float(15), _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float);
            float2 _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (1, 1), (_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float.xx), _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2);
            float _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2, float(10), _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float);
            float _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float;
            Unity_Negate_float(_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float, _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float);
            float2 _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float.xx), _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2);
            float _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2, float(10), _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float);
            float _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float;
            Unity_Add_float(_GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float, _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float, _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float);
            float _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float;
            Unity_Divide_float(_Add_17adcc70e6964669b273ffa660c43379_Out_2_Float, float(2), _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float);
            float3 _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3);
            float3 _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3;
            Unity_Power_float3(_Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3, float3(0.8, 5, 0.8), _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3);
            float _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[0];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[1];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[2];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_A_4_Float = 0;
            float _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float;
            Unity_Multiply_float_float(_Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float, _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float);
            float _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float = _Speed;
            float _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float, _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float);
            float _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float, 5, _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2, _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2);
            float _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float = _Speed;
            float _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float, _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float);
            float _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float;
            Unity_Add_float(_Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float, float(15), _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float);
            float2 _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (1, 1), (_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float.xx), _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2);
            float _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2, float(10), _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float);
            float _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float;
            Unity_Negate_float(_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float, _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float);
            float2 _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float.xx), _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2);
            float _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2, float(10), _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float);
            float _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float;
            Unity_Add_float(_GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float, _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float, _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float);
            float _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float;
            Unity_Divide_float(_Add_230c1475b56243bf8ed4151c26453420_Out_2_Float, float(2), _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float);
            float _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float;
            Unity_Multiply_float_float(_Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float);
            float _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float;
            Unity_Add_float(_Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float, _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float);
            float2 _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2, _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2, _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2);
            float _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float = _Speed;
            float _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float, _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float);
            float _Add_983001d85ada4e5396410433f0861366_Out_2_Float;
            Unity_Add_float(_Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float, float(15), _Add_983001d85ada4e5396410433f0861366_Out_2_Float);
            float2 _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (1, 1), (_Add_983001d85ada4e5396410433f0861366_Out_2_Float.xx), _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2);
            float _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2, float(10), _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float);
            float _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float;
            Unity_Negate_float(_Add_983001d85ada4e5396410433f0861366_Out_2_Float, _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float);
            float2 _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float.xx), _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2);
            float _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2, float(10), _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float);
            float _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float;
            Unity_Add_float(_GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float, _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float, _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float);
            float _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float;
            Unity_Divide_float(_Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float, float(2), _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float);
            float _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float);
            float _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float;
            Unity_Add_float(_Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float, _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float);
            float _Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float = _NormalStrength;
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3;
            float3x3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Add_b59ffb521828459097b93f52a7273e22_Out_2_Float,_Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix, _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3);
            float3 _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3);
            float3 _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3);
            Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float _RefractionWater_1dc846b8009e42daa40194bfa238ccf5;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceNormal = IN.WorldSpaceNormal;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceTangent = IN.WorldSpaceTangent;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.NDCPosition = IN.NDCPosition;
            float3 _RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3;
            SG_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float(float(0), _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3, float(0), _RefractionWater_1dc846b8009e42daa40194bfa238ccf5, _RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3);
            float3 _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3;
            Unity_Divide_float3(_RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3, float3(4, 4, 4), _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3);
            float3 _Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float.xxx), _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3, _Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3);
            float _Property_435087f89a0844699f112036328deb26_Out_0_Boolean = _ScreenSpaceReflections;
            float4 _ScreenPosition_1edb3c7d82804b74905a8e863bff1c6b_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float3 _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, float(0.2), _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3);
            float3 _SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3;
            SSR_float(IN.WorldSpaceViewDirection, float(0.2), _ScreenPosition_1edb3c7d82804b74905a8e863bff1c6b_Out_0_Vector4, float(15), float(0.5), float(1), _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3, IN.WorldSpacePosition, 0, _SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3);
            float3 _SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3;
            Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3);
            float _SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float);
            float3 _Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3, (_SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float.xxx), _Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3);
            float3 _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3, float3(0, 0, 0), _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3);
            float3 _Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3;
            Unity_Add_float3(_SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3, _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3, _Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3);
            float4 _Property_e872ea45cad54716aa3bfdc09420466c_Out_0_Vector4 = _EdgeColor;
            float4 _Property_a836ea15ef7548cfaaa54fe15300f69e_Out_0_Vector4 = _Color;
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(5), _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd, _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float);
            float _OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float, _OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float);
            float4 _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_632fd0c5217a4c1f85635b2663b7f106_R_1_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[0];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_G_2_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[1];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_B_3_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[2];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[3];
            float _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float = _MaxWaveDist;
            float _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float;
            Unity_Clamp_float(_Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float, float(0), _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float, _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float);
            float _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float = _MaxWaveDist;
            float _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float;
            Unity_Divide_float(_Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float, _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float, _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float);
            float _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float;
            Unity_OneMinus_float(_Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float);
            float _Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float);
            float _OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float;
            Unity_OneMinus_float(_Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float, _OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float);
            float4 _Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4;
            Unity_Lerp_float4(_Property_e872ea45cad54716aa3bfdc09420466c_Out_0_Vector4, _Property_a836ea15ef7548cfaaa54fe15300f69e_Out_0_Vector4, (_OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float.xxxx), _Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4);
            float4 _Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4, float4(0.5, 0.5, 0.5, 1), _Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4);
            float3 _Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3, (_Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4.xyz), _Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3);
            float _FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(1), _FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float);
            float3 _Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3, (_FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float.xxx), _Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3);
            float3 _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3;
            Unity_Add_float3(_Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3, (_Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4.xyz), _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3);
            float3 _Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3;
            Unity_Branch_float3(_Property_435087f89a0844699f112036328deb26_Out_0_Boolean, _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3, (_Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4.xyz), _Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3);
            float4 _Property_383d38dddb2c43959c6bb3f96b7dac8b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _Property_62bafa60731645a8987f0591e2774b91_Out_0_Boolean = _UseFoam;
            float _Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float;
            Unity_Branch_float(_Property_62bafa60731645a8987f0591e2774b91_Out_0_Boolean, float(1), float(0), _Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float);
            float _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float;
            Unity_Multiply_float_float(_Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float, _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float);
            float _Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float, _Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float);
            float _Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float;
            Unity_Clamp_float(_Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float, float(0), float(1), _Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float);
            float3 _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3;
            Unity_Lerp_float3(_Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3, (_Property_383d38dddb2c43959c6bb3f96b7dac8b_Out_0_Vector4.xyz), (_Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float.xxx), _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3);
            float _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float;
            Unity_OneMinus_float(_WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float);
            float _Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float, _Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float);
            float _OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float;
            Unity_OneMinus_float(_Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float, _OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float);
            float _Property_6595fb42eef04aeca117629c498ea6d1_Out_0_Float = _Transparency;
            float _Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float, _Property_6595fb42eef04aeca117629c498ea6d1_Out_0_Float, _Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float);
            float3 _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3;
            Unity_Lerp_float3(_Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3, _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3, (_Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float.xxx), _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3);
            float _Add_7e98ff6b8f8340219e3a2ec06ccd17fd_Out_2_Float;
            Unity_Add_float(_WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float, _Add_7e98ff6b8f8340219e3a2ec06ccd17fd_Out_2_Float);
            float _Property_d8abdfff88934758906aa518a31078e1_Out_0_Boolean = _UseFoam;
            float _Branch_736b55481aea4fc0b8afd7acfc734644_Out_3_Float;
            Unity_Branch_float(_Property_d8abdfff88934758906aa518a31078e1_Out_0_Boolean, float(0.5), float(0), _Branch_736b55481aea4fc0b8afd7acfc734644_Out_3_Float);
            float3 _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Out_1_Vector3;
            float3x3 _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Add_7e98ff6b8f8340219e3a2ec06ccd17fd_Out_2_Float,_Branch_736b55481aea4fc0b8afd7acfc734644_Out_3_Float,_NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Position,_NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_TangentMatrix, _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Out_1_Vector3);
            float3 _NormalBlend_e9da2f02159743cf818eeb703b494873_Out_2_Vector3;
            Unity_NormalBlend_float(_NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Out_1_Vector3, _NormalBlend_e9da2f02159743cf818eeb703b494873_Out_2_Vector3);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_72c92735390a461dac7c71af8138c538;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(0.1), _EdgeDistance_72c92735390a461dac7c71af8138c538, _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float);
            float _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float);
            float _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float, _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float);
            float _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float, _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float);
            surface.BaseColor = _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3;
            surface.NormalTS = _NormalBlend_e9da2f02159743cf818eeb703b494873_Out_2_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = float(1);
            surface.Occlusion = float(1);
            surface.Alpha = _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
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
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
        
        
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
             float3 positionWS;
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
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
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
        float4 _EdgeColor;
        float4 _FoamColor;
        float _WaveFrequency;
        float _ScreenSpaceReflections;
        float _WaveSpeed;
        float _WaveDist;
        float _MaxWaveDist;
        float4 _Color;
        float _NormalStrength;
        float _Speed;
        float _Tiling;
        float _Transparency;
        float _Caustic_Strength;
        float _UseFoam;
        float _Displacement_Amount;
        float _Displacement_Scale;
        float _Displacement_Speed;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float Vector1_c541d038fef84e4aaa1dbed97e38d366, Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float IN, out float2 YZ_3, out float2 XZ_2, out float2 XY_1)
        {
        float _Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float = Vector1_c541d038fef84e4aaa1dbed97e38d366;
        float3 _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpacePosition, (_Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float.xxx), _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3);
        float _Split_1acef4fb48e74181929303b0d2263c94_R_1_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[0];
        float _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[1];
        float _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[2];
        float _Split_1acef4fb48e74181929303b0d2263c94_A_4_Float = 0;
        float2 _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_B_3_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        float2 _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float);
        float2 _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        YZ_3 = _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2;
        XZ_2 = _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2;
        XY_1 = _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float
        {
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 _UV, float _UseUV, Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float IN, out float3 WorldPos_1)
        {
        float _Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean = _UseUV;
        float2 _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2 = _UV;
        float4 _ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float2 _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2;
        Unity_Branch_float2(_Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean, _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2, (_ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4.xy), _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2);
        float _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float;
        Unity_SceneDepth_Eye_float((float4(_Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2, 0.0, 1.0)), _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float);
        float _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float;
        Unity_DotProduct_float3(IN.WorldSpaceViewDirection, (-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float);
        float3 _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3;
        Unity_Divide_float3(IN.WorldSpaceViewDirection, (_DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3);
        float3 _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3;
        Unity_Multiply_float3_float3((_SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3, _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3);
        float3 _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3, _WorldSpaceCameraPos, _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3);
        WorldPos_1 = _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        };
        
        void SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float _Offset, Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float IN, out float Distance_1)
        {
        Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.NDCPosition = IN.NDCPosition;
        float3 _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3;
        SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3);
        float3 _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3;
        Unity_Subtract_float3(_WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3, IN.WorldSpacePosition, _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3);
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_R_1_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[0];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[1];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_B_3_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[2];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_A_4_Float = 0;
        float _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float;
        Unity_Absolute_float(_Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float, _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float);
        float _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float = _Offset;
        float _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float;
        Unity_Clamp_float(_Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float, float(0), _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float);
        float _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        Unity_Divide_float(_Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float, _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float);
        Distance_1 = _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
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
            float _Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_f0b669abeb8b471ab09abf291dad8815_A_4_Float = 0;
            float _Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float = _Displacement_Scale;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_d51af62a44f34b2eb621da1dbe974c41;
            _WSUVWater_d51af62a44f34b2eb621da1dbe974c41.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2);
            float _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float = _Displacement_Speed;
            float _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float, _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float);
            float2 _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, (_Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float.xx), _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2);
            float _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2, float(2), _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float);
            float _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float = _Displacement_Amount;
            float _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float, _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float);
            float _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float;
            Unity_Add_float(_Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float);
            float3 _Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3 = float3(_Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float, _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float);
            float3 _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
            _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3 = TransformWorldToObject(_Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3.xyz);
            description.Position = _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_632fd0c5217a4c1f85635b2663b7f106_R_1_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[0];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_G_2_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[1];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_B_3_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[2];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[3];
            float _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float = _MaxWaveDist;
            float _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float;
            Unity_Clamp_float(_Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float, float(0), _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float, _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float);
            float _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float = _MaxWaveDist;
            float _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float;
            Unity_Divide_float(_Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float, _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float, _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float);
            float _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float;
            Unity_OneMinus_float(_Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_72c92735390a461dac7c71af8138c538;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(0.1), _EdgeDistance_72c92735390a461dac7c71af8138c538, _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float);
            float _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float);
            float _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float, _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float);
            float _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float, _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float);
            surface.Alpha = _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            
        
        
        
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
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
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
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
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
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
            output.tangentWS.xyzw = input.tangentWS;
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
        float4 _EdgeColor;
        float4 _FoamColor;
        float _WaveFrequency;
        float _ScreenSpaceReflections;
        float _WaveSpeed;
        float _WaveDist;
        float _MaxWaveDist;
        float4 _Color;
        float _NormalStrength;
        float _Speed;
        float _Tiling;
        float _Transparency;
        float _Caustic_Strength;
        float _UseFoam;
        float _Displacement_Amount;
        float _Displacement_Scale;
        float _Displacement_Speed;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float Vector1_c541d038fef84e4aaa1dbed97e38d366, Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float IN, out float2 YZ_3, out float2 XZ_2, out float2 XY_1)
        {
        float _Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float = Vector1_c541d038fef84e4aaa1dbed97e38d366;
        float3 _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpacePosition, (_Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float.xxx), _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3);
        float _Split_1acef4fb48e74181929303b0d2263c94_R_1_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[0];
        float _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[1];
        float _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[2];
        float _Split_1acef4fb48e74181929303b0d2263c94_A_4_Float = 0;
        float2 _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_B_3_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        float2 _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float);
        float2 _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        YZ_3 = _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2;
        XZ_2 = _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2;
        XY_1 = _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        float2 Unity_Voronoi_RandomVector_LegacySine_float (float2 UV, float offset)
        {
            Hash_LegacySine_2_2_float(UV, UV);
            return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
        }
        
        void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    float2 lattice = float2(x, y);
                    float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
                    if (d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float
        {
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 _UV, float _UseUV, Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float IN, out float3 WorldPos_1)
        {
        float _Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean = _UseUV;
        float2 _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2 = _UV;
        float4 _ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float2 _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2;
        Unity_Branch_float2(_Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean, _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2, (_ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4.xy), _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2);
        float _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float;
        Unity_SceneDepth_Eye_float((float4(_Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2, 0.0, 1.0)), _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float);
        float _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float;
        Unity_DotProduct_float3(IN.WorldSpaceViewDirection, (-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float);
        float3 _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3;
        Unity_Divide_float3(IN.WorldSpaceViewDirection, (_DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3);
        float3 _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3;
        Unity_Multiply_float3_float3((_SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3, _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3);
        float3 _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3, _WorldSpaceCameraPos, _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3);
        WorldPos_1 = _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        struct Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        };
        
        void SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float _Offset, Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float IN, out float Distance_1)
        {
        Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.NDCPosition = IN.NDCPosition;
        float3 _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3;
        SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3);
        float3 _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3;
        Unity_Subtract_float3(_WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3, IN.WorldSpacePosition, _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3);
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_R_1_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[0];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[1];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_B_3_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[2];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_A_4_Float = 0;
        float _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float;
        Unity_Absolute_float(_Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float, _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float);
        float _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float = _Offset;
        float _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float;
        Unity_Clamp_float(_Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float, float(0), _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float);
        float _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        Unity_Divide_float(_Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float, _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float);
        Distance_1 = _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        }
        
        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        float3 TimeParameters;
        };
        
        void SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(float _WaveFrequency, float _WaveSpeed, float _WaveDist, float _Offset, Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float IN, out float Waves_1, out float Foam_2)
        {
        float _Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float = _WaveDist;
        Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpacePosition = IN.WorldSpacePosition;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.NDCPosition = IN.NDCPosition;
        float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float;
        SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(_Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float);
        float _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float = _WaveSpeed;
        float _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float, _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float);
        float _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float = _Offset;
        float _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float;
        Unity_Add_float(_Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float, _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float);
        float _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float;
        Unity_Add_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float);
        float _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float = _WaveFrequency;
        float _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float;
        Unity_Multiply_float_float(_Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float);
        float _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float;
        Unity_Floor_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float);
        float _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float;
        Unity_Fraction_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float);
        float _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float;
        Unity_Power_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, float(20), _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float);
        float _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float;
        Unity_Add_float(_Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float, _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float, _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float);
        float _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float;
        Unity_Divide_float(_Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float);
        float _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float;
        Unity_Subtract_float(_Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float);
        float _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float;
        Unity_Clamp_float(_Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float, float(0), float(1), _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float);
        float _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float;
        Unity_Multiply_float_float(2, _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float, _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float);
        float _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Unity_Clamp_float(_Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float, float(0), float(1), _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float);
        float _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float;
        Unity_OneMinus_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float);
        float _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float;
        Unity_Power_float(_OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float, float(10), _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float);
        float _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float;
        Unity_Step_float(float(1), _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float);
        float _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float;
        Unity_OneMinus_float(_Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float);
        float _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float;
        Unity_Multiply_float_float(_Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float, _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float);
        float _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float;
        Unity_Clamp_float(_Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float, float(0), float(1), _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float);
        float _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float;
        Unity_OneMinus_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float);
        float _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float;
        Unity_Smoothstep_float(float(0), float(1), _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float);
        float _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float;
        Unity_Multiply_float_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float);
        float _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        Unity_Multiply_float_float(_Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float, _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float);
        Waves_1 = _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Foam_2 = _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
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
            float _Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_f0b669abeb8b471ab09abf291dad8815_A_4_Float = 0;
            float _Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float = _Displacement_Scale;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_d51af62a44f34b2eb621da1dbe974c41;
            _WSUVWater_d51af62a44f34b2eb621da1dbe974c41.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2);
            float _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float = _Displacement_Speed;
            float _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float, _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float);
            float2 _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, (_Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float.xx), _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2);
            float _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2, float(2), _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float);
            float _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float = _Displacement_Amount;
            float _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float, _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float);
            float _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float;
            Unity_Add_float(_Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float);
            float3 _Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3 = float3(_Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float, _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float);
            float3 _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
            _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3 = TransformWorldToObject(_Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3.xyz);
            description.Position = _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_36fa2fa042a646e3884f906afce491d4;
            _WSUVWater_36fa2fa042a646e3884f906afce491d4.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float, _WSUVWater_36fa2fa042a646e3884f906afce491d4, _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2);
            float _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float = _Speed;
            float _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float, _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float);
            float _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float;
            Unity_Add_float(_Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float, float(15), _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float);
            float2 _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (1, 1), (_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float.xx), _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2);
            float _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2, float(10), _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float);
            float _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float;
            Unity_Negate_float(_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float, _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float);
            float2 _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float.xx), _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2);
            float _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2, float(10), _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float);
            float _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float;
            Unity_Add_float(_GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float, _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float, _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float);
            float _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float;
            Unity_Divide_float(_Add_17adcc70e6964669b273ffa660c43379_Out_2_Float, float(2), _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float);
            float3 _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3);
            float3 _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3;
            Unity_Power_float3(_Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3, float3(0.8, 5, 0.8), _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3);
            float _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[0];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[1];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[2];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_A_4_Float = 0;
            float _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float;
            Unity_Multiply_float_float(_Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float, _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float);
            float _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float = _Speed;
            float _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float, _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float);
            float _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float, 5, _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2, _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2);
            float _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float = _Speed;
            float _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float, _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float);
            float _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float;
            Unity_Add_float(_Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float, float(15), _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float);
            float2 _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (1, 1), (_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float.xx), _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2);
            float _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2, float(10), _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float);
            float _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float;
            Unity_Negate_float(_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float, _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float);
            float2 _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float.xx), _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2);
            float _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2, float(10), _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float);
            float _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float;
            Unity_Add_float(_GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float, _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float, _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float);
            float _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float;
            Unity_Divide_float(_Add_230c1475b56243bf8ed4151c26453420_Out_2_Float, float(2), _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float);
            float _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float;
            Unity_Multiply_float_float(_Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float);
            float _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float;
            Unity_Add_float(_Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float, _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float);
            float2 _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2, _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2, _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2);
            float _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float = _Speed;
            float _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float, _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float);
            float _Add_983001d85ada4e5396410433f0861366_Out_2_Float;
            Unity_Add_float(_Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float, float(15), _Add_983001d85ada4e5396410433f0861366_Out_2_Float);
            float2 _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (1, 1), (_Add_983001d85ada4e5396410433f0861366_Out_2_Float.xx), _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2);
            float _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2, float(10), _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float);
            float _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float;
            Unity_Negate_float(_Add_983001d85ada4e5396410433f0861366_Out_2_Float, _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float);
            float2 _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float.xx), _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2);
            float _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2, float(10), _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float);
            float _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float;
            Unity_Add_float(_GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float, _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float, _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float);
            float _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float;
            Unity_Divide_float(_Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float, float(2), _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float);
            float _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float);
            float _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float;
            Unity_Add_float(_Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float, _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float);
            float _Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float = _NormalStrength;
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3;
            float3x3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Add_b59ffb521828459097b93f52a7273e22_Out_2_Float,_Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix, _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3);
            float _Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float = _WaveFrequency;
            float _Property_477adb340d344e78a50e313038d7008b_Out_0_Float = _WaveSpeed;
            float _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float = _WaveDist;
            float _Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370;
            _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2);
            float _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float = _Speed;
            float _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float, _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float);
            float _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float;
            Unity_Divide_float(_Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float, float(5), _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float);
            float2 _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (1, 1), (_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float.xx), _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2);
            float _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2, float(50), _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float);
            float _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float;
            Unity_Negate_float(_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float, _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float);
            float2 _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float.xx), _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2);
            float _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2, float(50), _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float);
            float _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float;
            Unity_Add_float(_GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float, _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float, _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float);
            float _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float;
            Unity_Divide_float(_Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float, float(100), _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float);
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_5b92dfc7e363488d925b69046c47538f;
            _WSUVWater_5b92dfc7e363488d925b69046c47538f.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float(0.5), _WSUVWater_5b92dfc7e363488d925b69046c47538f, _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2);
            float _Property_762f6624e50447109a1a63175dcb252b_Out_0_Float = _WaveSpeed;
            float _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float;
            Unity_Multiply_float_float(_Property_762f6624e50447109a1a63175dcb252b_Out_0_Float, 100, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float);
            float _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float);
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float;
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(1), _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float);
            float _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float;
            Unity_Remap_float(_Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, float2 (0, 1), float2 (-0.02, 0.02), _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float);
            float _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float;
            Unity_Add_float(_Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float, _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float, _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float);
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float;
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(2), _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float);
            float _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float;
            Unity_Remap_float(_Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, float2 (0, 1), float2 (-0.01, 0.01), _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float);
            float _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float;
            Unity_Add_float(_Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float, _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float, _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float);
            float _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, 0.2, _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float);
            float2 _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, (_Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float.xx), _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2);
            float _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2, float(0.1), _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float);
            float _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float;
            Unity_Remap_float(_GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float, float2 (0, 1), float2 (-0.05, 0.05), _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float);
            float _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float;
            Unity_Add_float(_Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float, _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float);
            Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpacePosition = IN.WorldSpacePosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.NDCPosition = IN.NDCPosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.TimeParameters = IN.TimeParameters;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float;
            SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(_Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float, _Property_477adb340d344e78a50e313038d7008b_Out_0_Float, _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float);
            float3 _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3);
            float _Add_7e98ff6b8f8340219e3a2ec06ccd17fd_Out_2_Float;
            Unity_Add_float(_WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float, _Add_7e98ff6b8f8340219e3a2ec06ccd17fd_Out_2_Float);
            float _Property_d8abdfff88934758906aa518a31078e1_Out_0_Boolean = _UseFoam;
            float _Branch_736b55481aea4fc0b8afd7acfc734644_Out_3_Float;
            Unity_Branch_float(_Property_d8abdfff88934758906aa518a31078e1_Out_0_Boolean, float(0.5), float(0), _Branch_736b55481aea4fc0b8afd7acfc734644_Out_3_Float);
            float3 _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Out_1_Vector3;
            float3x3 _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Add_7e98ff6b8f8340219e3a2ec06ccd17fd_Out_2_Float,_Branch_736b55481aea4fc0b8afd7acfc734644_Out_3_Float,_NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Position,_NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_TangentMatrix, _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Out_1_Vector3);
            float3 _NormalBlend_e9da2f02159743cf818eeb703b494873_Out_2_Vector3;
            Unity_NormalBlend_float(_NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, _NormalFromHeight_cd963b1aef6c4e2c953e03bb24d78a23_Out_1_Vector3, _NormalBlend_e9da2f02159743cf818eeb703b494873_Out_2_Vector3);
            float4 _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_632fd0c5217a4c1f85635b2663b7f106_R_1_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[0];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_G_2_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[1];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_B_3_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[2];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[3];
            float _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float = _MaxWaveDist;
            float _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float;
            Unity_Clamp_float(_Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float, float(0), _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float, _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float);
            float _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float = _MaxWaveDist;
            float _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float;
            Unity_Divide_float(_Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float, _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float, _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float);
            float _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float;
            Unity_OneMinus_float(_Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_72c92735390a461dac7c71af8138c538;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(0.1), _EdgeDistance_72c92735390a461dac7c71af8138c538, _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float);
            float _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float);
            float _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float, _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float);
            float _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float, _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float);
            surface.NormalTS = _NormalBlend_e9da2f02159743cf818eeb703b494873_Out_2_Vector3;
            surface.Alpha = _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
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
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
        
        
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
             float4 tangentWS;
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
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float4 texCoord1 : INTERP2;
             float4 texCoord2 : INTERP3;
             float3 positionWS : INTERP4;
             float3 normalWS : INTERP5;
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
            output.tangentWS = input.tangentWS.xyzw;
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
        float4 _EdgeColor;
        float4 _FoamColor;
        float _WaveFrequency;
        float _ScreenSpaceReflections;
        float _WaveSpeed;
        float _WaveDist;
        float _MaxWaveDist;
        float4 _Color;
        float _NormalStrength;
        float _Speed;
        float _Tiling;
        float _Transparency;
        float _Caustic_Strength;
        float _UseFoam;
        float _Displacement_Amount;
        float _Displacement_Scale;
        float _Displacement_Speed;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include "Assets/WaterWorks/Shaders/WaterSSR.hlsl"
        
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
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float Vector1_c541d038fef84e4aaa1dbed97e38d366, Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float IN, out float2 YZ_3, out float2 XZ_2, out float2 XY_1)
        {
        float _Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float = Vector1_c541d038fef84e4aaa1dbed97e38d366;
        float3 _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpacePosition, (_Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float.xxx), _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3);
        float _Split_1acef4fb48e74181929303b0d2263c94_R_1_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[0];
        float _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[1];
        float _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[2];
        float _Split_1acef4fb48e74181929303b0d2263c94_A_4_Float = 0;
        float2 _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_B_3_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        float2 _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float);
        float2 _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        YZ_3 = _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2;
        XZ_2 = _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2;
        XY_1 = _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float
        {
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 _UV, float _UseUV, Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float IN, out float3 WorldPos_1)
        {
        float _Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean = _UseUV;
        float2 _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2 = _UV;
        float4 _ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float2 _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2;
        Unity_Branch_float2(_Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean, _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2, (_ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4.xy), _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2);
        float _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float;
        Unity_SceneDepth_Eye_float((float4(_Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2, 0.0, 1.0)), _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float);
        float _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float;
        Unity_DotProduct_float3(IN.WorldSpaceViewDirection, (-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float);
        float3 _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3;
        Unity_Divide_float3(IN.WorldSpaceViewDirection, (_DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3);
        float3 _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3;
        Unity_Multiply_float3_float3((_SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3, _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3);
        float3 _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3, _WorldSpaceCameraPos, _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3);
        WorldPos_1 = _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        }
        
        float2 Unity_Voronoi_RandomVector_LegacySine_float (float2 UV, float offset)
        {
            Hash_LegacySine_2_2_float(UV, UV);
            return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
        }
        
        void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    float2 lattice = float2(x, y);
                    float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
                    if (d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        };
        
        void SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float _Offset, Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float IN, out float Distance_1)
        {
        Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.NDCPosition = IN.NDCPosition;
        float3 _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3;
        SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3);
        float3 _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3;
        Unity_Subtract_float3(_WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3, IN.WorldSpacePosition, _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3);
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_R_1_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[0];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[1];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_B_3_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[2];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_A_4_Float = 0;
        float _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float;
        Unity_Absolute_float(_Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float, _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float);
        float _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float = _Offset;
        float _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float;
        Unity_Clamp_float(_Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float, float(0), _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float);
        float _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        Unity_Divide_float(_Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float, _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float);
        Distance_1 = _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        float3 TimeParameters;
        };
        
        void SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(float _WaveFrequency, float _WaveSpeed, float _WaveDist, float _Offset, Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float IN, out float Waves_1, out float Foam_2)
        {
        float _Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float = _WaveDist;
        Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpacePosition = IN.WorldSpacePosition;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.NDCPosition = IN.NDCPosition;
        float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float;
        SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(_Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float);
        float _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float = _WaveSpeed;
        float _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float, _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float);
        float _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float = _Offset;
        float _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float;
        Unity_Add_float(_Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float, _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float);
        float _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float;
        Unity_Add_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float);
        float _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float = _WaveFrequency;
        float _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float;
        Unity_Multiply_float_float(_Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float);
        float _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float;
        Unity_Floor_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float);
        float _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float;
        Unity_Fraction_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float);
        float _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float;
        Unity_Power_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, float(20), _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float);
        float _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float;
        Unity_Add_float(_Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float, _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float, _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float);
        float _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float;
        Unity_Divide_float(_Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float);
        float _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float;
        Unity_Subtract_float(_Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float);
        float _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float;
        Unity_Clamp_float(_Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float, float(0), float(1), _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float);
        float _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float;
        Unity_Multiply_float_float(2, _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float, _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float);
        float _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Unity_Clamp_float(_Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float, float(0), float(1), _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float);
        float _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float;
        Unity_OneMinus_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float);
        float _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float;
        Unity_Power_float(_OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float, float(10), _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float);
        float _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float;
        Unity_Step_float(float(1), _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float);
        float _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float;
        Unity_OneMinus_float(_Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float);
        float _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float;
        Unity_Multiply_float_float(_Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float, _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float);
        float _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float;
        Unity_Clamp_float(_Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float, float(0), float(1), _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float);
        float _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float;
        Unity_OneMinus_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float);
        float _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float;
        Unity_Smoothstep_float(float(0), float(1), _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float);
        float _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float;
        Unity_Multiply_float_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float);
        float _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        Unity_Multiply_float_float(_Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float, _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float);
        Waves_1 = _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Foam_2 = _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void ref_float(float3 View, float3 Normal, float IOR, out float3 Out){
        Out = refract(View, Normal, IOR);
        }
        
        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float
        {
        float3 WorldSpaceNormal;
        float3 WorldSpaceTangent;
        float3 WorldSpaceBiTangent;
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float(float Vector1_9AC3B9A5, float3 Vector3_90258404, float Vector1_6604C6DE, Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float IN, out float3 Out_1)
        {
        float3 _SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3;
        Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3);
        float4 _ScreenPosition_0e0d43ed492f568494cf68c3f0d94863_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float3 _Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3;
        Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3);
        float3 _Property_06b2b93e9aad7f83bcbdcd89ffb2c49f_Out_0_Vector3 = Vector3_90258404;
        float3 _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3;
        Unity_Normalize_float3(_Property_06b2b93e9aad7f83bcbdcd89ffb2c49f_Out_0_Vector3, _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3);
        float _Property_5eb756389a644c899050838a3ceca5e1_Out_0_Float = Vector1_9AC3B9A5;
        float3 _refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3;
        ref_float(_Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3, _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3, _Property_5eb756389a644c899050838a3ceca5e1_Out_0_Float, _refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3);
        float3 _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3;
        {
        float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
        _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3 = TransformWorldToTangent(_refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3.xyz, tangentTransform, true);
        }
        float3 _Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3;
        Unity_Add_float3((_ScreenPosition_0e0d43ed492f568494cf68c3f0d94863_Out_0_Vector4.xyz), _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3, _Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3);
        float3 _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3;
        Unity_Floor_float3(_Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3, _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3);
        float3 _Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3;
        Unity_Subtract_float3(_Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3, _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3, _Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3);
        float2 _Vector2_4edaee860484198683cf81fd0bffdd27_Out_0_Vector2 = float2(float(1), float(1));
        float _Property_e30ceff597802a8b9a455fb3e3965d62_Out_0_Float = Vector1_6604C6DE;
        float _Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float;
        Unity_Divide_float(_Property_e30ceff597802a8b9a455fb3e3965d62_Out_0_Float, float(100), _Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float);
        float _Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float;
        Unity_Clamp_float(_Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float, float(0), float(5), _Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float);
        float2 _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_4edaee860484198683cf81fd0bffdd27_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2);
        float2 _Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2, _Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2);
        float3 _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2, 0.0, 1.0)), _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3);
        float3 _Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3;
        Unity_Add_float3(_SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3, _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3, _Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3);
        float2 _Vector2_19ef821db1cdc783a43742b9cf51b8c8_Out_0_Vector2 = float2(float(-1), float(1));
        float2 _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_19ef821db1cdc783a43742b9cf51b8c8_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2);
        float2 _Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2, _Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2);
        float3 _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2, 0.0, 1.0)), _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3);
        float3 _Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3;
        Unity_Add_float3(_Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3, _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3, _Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3);
        float2 _Vector2_fb7f3e085d3ebe84b7178b3bc4a39da8_Out_0_Vector2 = float2(float(1), float(-1));
        float2 _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_fb7f3e085d3ebe84b7178b3bc4a39da8_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2);
        float2 _Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2, _Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2);
        float3 _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2, 0.0, 1.0)), _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3);
        float3 _Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3;
        Unity_Add_float3(_Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3, _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3, _Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3);
        float2 _Vector2_9e6584c2279b638190dff9a888cf9a4d_Out_0_Vector2 = float2(float(-1), float(-1));
        float2 _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_9e6584c2279b638190dff9a888cf9a4d_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2);
        float2 _Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2, _Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2);
        float3 _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2, 0.0, 1.0)), _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3);
        float3 _Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3;
        Unity_Add_float3(_Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3, _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3, _Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3);
        float _Float_62fb265fcb81c2809fc6b96dcab9cf54_Out_0_Float = float(5);
        float3 _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3;
        Unity_Divide_float3(_Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3, (_Float_62fb265fcb81c2809fc6b96dcab9cf54_Out_0_Float.xxx), _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3);
        Out_1 = _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
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
            float _Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_f0b669abeb8b471ab09abf291dad8815_A_4_Float = 0;
            float _Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float = _Displacement_Scale;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_d51af62a44f34b2eb621da1dbe974c41;
            _WSUVWater_d51af62a44f34b2eb621da1dbe974c41.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2);
            float _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float = _Displacement_Speed;
            float _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float, _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float);
            float2 _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, (_Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float.xx), _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2);
            float _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2, float(2), _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float);
            float _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float = _Displacement_Amount;
            float _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float, _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float);
            float _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float;
            Unity_Add_float(_Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float);
            float3 _Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3 = float3(_Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float, _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float);
            float3 _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
            _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3 = TransformWorldToObject(_Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3.xyz);
            description.Position = _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e;
            _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e.NDCPosition = IN.NDCPosition;
            float3 _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3;
            SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e, _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3);
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_R_1_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[0];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_G_2_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[1];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_B_3_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[2];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_A_4_Float = 0;
            float2 _Vector2_c0a539d837d74542b502faac38a301ce_Out_0_Vector2 = float2(_Split_af2dcc47ab1f44c09a4753a196a06d9c_R_1_Float, _Split_af2dcc47ab1f44c09a4753a196a06d9c_B_3_Float);
            float _Property_d5ee87edeaeb46438ba81528f2801bc2_Out_0_Float = _Speed;
            float _Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d5ee87edeaeb46438ba81528f2801bc2_Out_0_Float, _Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float);
            float _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float, 20, _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float);
            float _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float;
            float _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_Vector2_c0a539d837d74542b502faac38a301ce_Out_0_Vector2, _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float, float(0.5), _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float, _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Cells_4_Float);
            float _Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float;
            Unity_Power_float(_Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float, float(3), _Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float);
            float _Property_274d0ef360aa4c7a9365ff75e7b4395b_Out_0_Float = _Caustic_Strength;
            float _Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float;
            Unity_Multiply_float_float(_Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float, _Property_274d0ef360aa4c7a9365ff75e7b4395b_Out_0_Float, _Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(5), _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e, _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float);
            float _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float, _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float);
            float _Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float, _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float, _Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float);
            float _Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float = _WaveFrequency;
            float _Property_477adb340d344e78a50e313038d7008b_Out_0_Float = _WaveSpeed;
            float _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float = _WaveDist;
            float _Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370;
            _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2);
            float _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float = _Speed;
            float _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float, _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float);
            float _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float;
            Unity_Divide_float(_Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float, float(5), _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float);
            float2 _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (1, 1), (_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float.xx), _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2);
            float _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2, float(50), _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float);
            float _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float;
            Unity_Negate_float(_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float, _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float);
            float2 _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float.xx), _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2);
            float _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2, float(50), _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float);
            float _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float;
            Unity_Add_float(_GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float, _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float, _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float);
            float _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float;
            Unity_Divide_float(_Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float, float(100), _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float);
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_5b92dfc7e363488d925b69046c47538f;
            _WSUVWater_5b92dfc7e363488d925b69046c47538f.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float(0.5), _WSUVWater_5b92dfc7e363488d925b69046c47538f, _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2);
            float _Property_762f6624e50447109a1a63175dcb252b_Out_0_Float = _WaveSpeed;
            float _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float;
            Unity_Multiply_float_float(_Property_762f6624e50447109a1a63175dcb252b_Out_0_Float, 100, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float);
            float _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float);
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float;
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(1), _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float);
            float _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float;
            Unity_Remap_float(_Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, float2 (0, 1), float2 (-0.02, 0.02), _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float);
            float _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float;
            Unity_Add_float(_Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float, _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float, _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float);
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float;
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(2), _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float);
            float _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float;
            Unity_Remap_float(_Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, float2 (0, 1), float2 (-0.01, 0.01), _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float);
            float _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float;
            Unity_Add_float(_Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float, _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float, _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float);
            float _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, 0.2, _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float);
            float2 _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, (_Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float.xx), _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2);
            float _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2, float(0.1), _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float);
            float _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float;
            Unity_Remap_float(_GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float, float2 (0, 1), float2 (-0.05, 0.05), _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float);
            float _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float;
            Unity_Add_float(_Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float, _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float);
            Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpacePosition = IN.WorldSpacePosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.NDCPosition = IN.NDCPosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.TimeParameters = IN.TimeParameters;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float;
            SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(_Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float, _Property_477adb340d344e78a50e313038d7008b_Out_0_Float, _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float);
            float _Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float);
            float _Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float;
            Unity_Add_float(_Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float, float(1), _Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float);
            float _Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_36fa2fa042a646e3884f906afce491d4;
            _WSUVWater_36fa2fa042a646e3884f906afce491d4.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float, _WSUVWater_36fa2fa042a646e3884f906afce491d4, _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2);
            float _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float = _Speed;
            float _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float, _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float);
            float _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float;
            Unity_Add_float(_Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float, float(15), _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float);
            float2 _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (1, 1), (_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float.xx), _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2);
            float _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2, float(10), _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float);
            float _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float;
            Unity_Negate_float(_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float, _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float);
            float2 _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float.xx), _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2);
            float _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2, float(10), _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float);
            float _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float;
            Unity_Add_float(_GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float, _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float, _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float);
            float _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float;
            Unity_Divide_float(_Add_17adcc70e6964669b273ffa660c43379_Out_2_Float, float(2), _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float);
            float3 _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3);
            float3 _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3;
            Unity_Power_float3(_Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3, float3(0.8, 5, 0.8), _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3);
            float _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[0];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[1];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[2];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_A_4_Float = 0;
            float _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float;
            Unity_Multiply_float_float(_Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float, _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float);
            float _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float = _Speed;
            float _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float, _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float);
            float _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float, 5, _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2, _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2);
            float _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float = _Speed;
            float _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float, _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float);
            float _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float;
            Unity_Add_float(_Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float, float(15), _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float);
            float2 _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (1, 1), (_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float.xx), _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2);
            float _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2, float(10), _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float);
            float _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float;
            Unity_Negate_float(_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float, _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float);
            float2 _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float.xx), _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2);
            float _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2, float(10), _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float);
            float _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float;
            Unity_Add_float(_GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float, _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float, _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float);
            float _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float;
            Unity_Divide_float(_Add_230c1475b56243bf8ed4151c26453420_Out_2_Float, float(2), _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float);
            float _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float;
            Unity_Multiply_float_float(_Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float);
            float _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float;
            Unity_Add_float(_Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float, _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float);
            float2 _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2, _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2, _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2);
            float _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float = _Speed;
            float _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float, _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float);
            float _Add_983001d85ada4e5396410433f0861366_Out_2_Float;
            Unity_Add_float(_Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float, float(15), _Add_983001d85ada4e5396410433f0861366_Out_2_Float);
            float2 _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (1, 1), (_Add_983001d85ada4e5396410433f0861366_Out_2_Float.xx), _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2);
            float _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2, float(10), _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float);
            float _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float;
            Unity_Negate_float(_Add_983001d85ada4e5396410433f0861366_Out_2_Float, _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float);
            float2 _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float.xx), _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2);
            float _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2, float(10), _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float);
            float _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float;
            Unity_Add_float(_GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float, _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float, _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float);
            float _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float;
            Unity_Divide_float(_Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float, float(2), _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float);
            float _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float);
            float _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float;
            Unity_Add_float(_Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float, _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float);
            float _Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float = _NormalStrength;
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3;
            float3x3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Add_b59ffb521828459097b93f52a7273e22_Out_2_Float,_Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix, _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3);
            float3 _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3);
            float3 _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3);
            Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float _RefractionWater_1dc846b8009e42daa40194bfa238ccf5;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceNormal = IN.WorldSpaceNormal;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceTangent = IN.WorldSpaceTangent;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.NDCPosition = IN.NDCPosition;
            float3 _RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3;
            SG_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float(float(0), _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3, float(0), _RefractionWater_1dc846b8009e42daa40194bfa238ccf5, _RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3);
            float3 _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3;
            Unity_Divide_float3(_RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3, float3(4, 4, 4), _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3);
            float3 _Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float.xxx), _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3, _Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3);
            float _Property_435087f89a0844699f112036328deb26_Out_0_Boolean = _ScreenSpaceReflections;
            float4 _ScreenPosition_1edb3c7d82804b74905a8e863bff1c6b_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float3 _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, float(0.2), _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3);
            float3 _SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3;
            SSR_float(IN.WorldSpaceViewDirection, float(0.2), _ScreenPosition_1edb3c7d82804b74905a8e863bff1c6b_Out_0_Vector4, float(15), float(0.5), float(1), _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3, IN.WorldSpacePosition, 0, _SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3);
            float3 _SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3;
            Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3);
            float _SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float);
            float3 _Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3, (_SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float.xxx), _Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3);
            float3 _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3, float3(0, 0, 0), _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3);
            float3 _Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3;
            Unity_Add_float3(_SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3, _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3, _Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3);
            float4 _Property_e872ea45cad54716aa3bfdc09420466c_Out_0_Vector4 = _EdgeColor;
            float4 _Property_a836ea15ef7548cfaaa54fe15300f69e_Out_0_Vector4 = _Color;
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(5), _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd, _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float);
            float _OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float, _OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float);
            float4 _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_632fd0c5217a4c1f85635b2663b7f106_R_1_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[0];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_G_2_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[1];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_B_3_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[2];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[3];
            float _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float = _MaxWaveDist;
            float _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float;
            Unity_Clamp_float(_Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float, float(0), _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float, _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float);
            float _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float = _MaxWaveDist;
            float _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float;
            Unity_Divide_float(_Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float, _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float, _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float);
            float _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float;
            Unity_OneMinus_float(_Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float);
            float _Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float);
            float _OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float;
            Unity_OneMinus_float(_Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float, _OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float);
            float4 _Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4;
            Unity_Lerp_float4(_Property_e872ea45cad54716aa3bfdc09420466c_Out_0_Vector4, _Property_a836ea15ef7548cfaaa54fe15300f69e_Out_0_Vector4, (_OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float.xxxx), _Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4);
            float4 _Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4, float4(0.5, 0.5, 0.5, 1), _Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4);
            float3 _Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3, (_Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4.xyz), _Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3);
            float _FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(1), _FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float);
            float3 _Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3, (_FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float.xxx), _Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3);
            float3 _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3;
            Unity_Add_float3(_Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3, (_Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4.xyz), _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3);
            float3 _Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3;
            Unity_Branch_float3(_Property_435087f89a0844699f112036328deb26_Out_0_Boolean, _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3, (_Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4.xyz), _Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3);
            float4 _Property_383d38dddb2c43959c6bb3f96b7dac8b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _Property_62bafa60731645a8987f0591e2774b91_Out_0_Boolean = _UseFoam;
            float _Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float;
            Unity_Branch_float(_Property_62bafa60731645a8987f0591e2774b91_Out_0_Boolean, float(1), float(0), _Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float);
            float _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float;
            Unity_Multiply_float_float(_Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float, _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float);
            float _Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float, _Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float);
            float _Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float;
            Unity_Clamp_float(_Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float, float(0), float(1), _Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float);
            float3 _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3;
            Unity_Lerp_float3(_Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3, (_Property_383d38dddb2c43959c6bb3f96b7dac8b_Out_0_Vector4.xyz), (_Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float.xxx), _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3);
            float _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float;
            Unity_OneMinus_float(_WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float);
            float _Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float, _Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float);
            float _OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float;
            Unity_OneMinus_float(_Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float, _OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float);
            float _Property_6595fb42eef04aeca117629c498ea6d1_Out_0_Float = _Transparency;
            float _Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float, _Property_6595fb42eef04aeca117629c498ea6d1_Out_0_Float, _Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float);
            float3 _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3;
            Unity_Lerp_float3(_Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3, _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3, (_Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float.xxx), _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_72c92735390a461dac7c71af8138c538;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(0.1), _EdgeDistance_72c92735390a461dac7c71af8138c538, _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float);
            float _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float);
            float _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float, _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float);
            float _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float, _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float);
            surface.BaseColor = _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
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
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
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
             float3 positionWS;
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
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
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
            output.positionWS.xyz = input.positionWS;
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
            output.positionWS = input.positionWS.xyz;
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
        float4 _EdgeColor;
        float4 _FoamColor;
        float _WaveFrequency;
        float _ScreenSpaceReflections;
        float _WaveSpeed;
        float _WaveDist;
        float _MaxWaveDist;
        float4 _Color;
        float _NormalStrength;
        float _Speed;
        float _Tiling;
        float _Transparency;
        float _Caustic_Strength;
        float _UseFoam;
        float _Displacement_Amount;
        float _Displacement_Scale;
        float _Displacement_Speed;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float Vector1_c541d038fef84e4aaa1dbed97e38d366, Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float IN, out float2 YZ_3, out float2 XZ_2, out float2 XY_1)
        {
        float _Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float = Vector1_c541d038fef84e4aaa1dbed97e38d366;
        float3 _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpacePosition, (_Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float.xxx), _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3);
        float _Split_1acef4fb48e74181929303b0d2263c94_R_1_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[0];
        float _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[1];
        float _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[2];
        float _Split_1acef4fb48e74181929303b0d2263c94_A_4_Float = 0;
        float2 _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_B_3_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        float2 _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float);
        float2 _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        YZ_3 = _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2;
        XZ_2 = _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2;
        XY_1 = _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float
        {
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 _UV, float _UseUV, Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float IN, out float3 WorldPos_1)
        {
        float _Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean = _UseUV;
        float2 _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2 = _UV;
        float4 _ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float2 _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2;
        Unity_Branch_float2(_Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean, _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2, (_ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4.xy), _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2);
        float _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float;
        Unity_SceneDepth_Eye_float((float4(_Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2, 0.0, 1.0)), _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float);
        float _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float;
        Unity_DotProduct_float3(IN.WorldSpaceViewDirection, (-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float);
        float3 _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3;
        Unity_Divide_float3(IN.WorldSpaceViewDirection, (_DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3);
        float3 _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3;
        Unity_Multiply_float3_float3((_SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3, _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3);
        float3 _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3, _WorldSpaceCameraPos, _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3);
        WorldPos_1 = _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        };
        
        void SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float _Offset, Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float IN, out float Distance_1)
        {
        Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.NDCPosition = IN.NDCPosition;
        float3 _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3;
        SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3);
        float3 _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3;
        Unity_Subtract_float3(_WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3, IN.WorldSpacePosition, _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3);
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_R_1_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[0];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[1];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_B_3_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[2];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_A_4_Float = 0;
        float _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float;
        Unity_Absolute_float(_Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float, _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float);
        float _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float = _Offset;
        float _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float;
        Unity_Clamp_float(_Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float, float(0), _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float);
        float _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        Unity_Divide_float(_Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float, _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float);
        Distance_1 = _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
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
            float _Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_f0b669abeb8b471ab09abf291dad8815_A_4_Float = 0;
            float _Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float = _Displacement_Scale;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_d51af62a44f34b2eb621da1dbe974c41;
            _WSUVWater_d51af62a44f34b2eb621da1dbe974c41.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2);
            float _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float = _Displacement_Speed;
            float _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float, _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float);
            float2 _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, (_Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float.xx), _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2);
            float _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2, float(2), _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float);
            float _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float = _Displacement_Amount;
            float _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float, _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float);
            float _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float;
            Unity_Add_float(_Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float);
            float3 _Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3 = float3(_Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float, _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float);
            float3 _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
            _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3 = TransformWorldToObject(_Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3.xyz);
            description.Position = _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_632fd0c5217a4c1f85635b2663b7f106_R_1_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[0];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_G_2_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[1];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_B_3_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[2];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[3];
            float _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float = _MaxWaveDist;
            float _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float;
            Unity_Clamp_float(_Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float, float(0), _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float, _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float);
            float _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float = _MaxWaveDist;
            float _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float;
            Unity_Divide_float(_Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float, _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float, _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float);
            float _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float;
            Unity_OneMinus_float(_Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_72c92735390a461dac7c71af8138c538;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(0.1), _EdgeDistance_72c92735390a461dac7c71af8138c538, _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float);
            float _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float);
            float _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float, _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float);
            float _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float, _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float);
            surface.Alpha = _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            
        
        
        
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
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
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
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
             float3 positionWS;
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
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
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
            output.positionWS.xyz = input.positionWS;
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
            output.positionWS = input.positionWS.xyz;
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
        float4 _EdgeColor;
        float4 _FoamColor;
        float _WaveFrequency;
        float _ScreenSpaceReflections;
        float _WaveSpeed;
        float _WaveDist;
        float _MaxWaveDist;
        float4 _Color;
        float _NormalStrength;
        float _Speed;
        float _Tiling;
        float _Transparency;
        float _Caustic_Strength;
        float _UseFoam;
        float _Displacement_Amount;
        float _Displacement_Scale;
        float _Displacement_Speed;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float Vector1_c541d038fef84e4aaa1dbed97e38d366, Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float IN, out float2 YZ_3, out float2 XZ_2, out float2 XY_1)
        {
        float _Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float = Vector1_c541d038fef84e4aaa1dbed97e38d366;
        float3 _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpacePosition, (_Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float.xxx), _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3);
        float _Split_1acef4fb48e74181929303b0d2263c94_R_1_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[0];
        float _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[1];
        float _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[2];
        float _Split_1acef4fb48e74181929303b0d2263c94_A_4_Float = 0;
        float2 _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_B_3_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        float2 _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float);
        float2 _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        YZ_3 = _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2;
        XZ_2 = _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2;
        XY_1 = _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float
        {
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 _UV, float _UseUV, Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float IN, out float3 WorldPos_1)
        {
        float _Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean = _UseUV;
        float2 _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2 = _UV;
        float4 _ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float2 _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2;
        Unity_Branch_float2(_Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean, _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2, (_ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4.xy), _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2);
        float _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float;
        Unity_SceneDepth_Eye_float((float4(_Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2, 0.0, 1.0)), _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float);
        float _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float;
        Unity_DotProduct_float3(IN.WorldSpaceViewDirection, (-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float);
        float3 _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3;
        Unity_Divide_float3(IN.WorldSpaceViewDirection, (_DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3);
        float3 _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3;
        Unity_Multiply_float3_float3((_SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3, _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3);
        float3 _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3, _WorldSpaceCameraPos, _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3);
        WorldPos_1 = _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        };
        
        void SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float _Offset, Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float IN, out float Distance_1)
        {
        Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.NDCPosition = IN.NDCPosition;
        float3 _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3;
        SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3);
        float3 _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3;
        Unity_Subtract_float3(_WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3, IN.WorldSpacePosition, _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3);
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_R_1_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[0];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[1];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_B_3_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[2];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_A_4_Float = 0;
        float _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float;
        Unity_Absolute_float(_Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float, _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float);
        float _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float = _Offset;
        float _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float;
        Unity_Clamp_float(_Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float, float(0), _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float);
        float _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        Unity_Divide_float(_Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float, _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float);
        Distance_1 = _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
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
            float _Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_f0b669abeb8b471ab09abf291dad8815_A_4_Float = 0;
            float _Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float = _Displacement_Scale;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_d51af62a44f34b2eb621da1dbe974c41;
            _WSUVWater_d51af62a44f34b2eb621da1dbe974c41.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2);
            float _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float = _Displacement_Speed;
            float _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float, _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float);
            float2 _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, (_Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float.xx), _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2);
            float _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2, float(2), _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float);
            float _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float = _Displacement_Amount;
            float _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float, _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float);
            float _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float;
            Unity_Add_float(_Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float);
            float3 _Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3 = float3(_Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float, _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float);
            float3 _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
            _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3 = TransformWorldToObject(_Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3.xyz);
            description.Position = _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_632fd0c5217a4c1f85635b2663b7f106_R_1_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[0];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_G_2_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[1];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_B_3_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[2];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[3];
            float _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float = _MaxWaveDist;
            float _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float;
            Unity_Clamp_float(_Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float, float(0), _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float, _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float);
            float _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float = _MaxWaveDist;
            float _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float;
            Unity_Divide_float(_Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float, _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float, _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float);
            float _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float;
            Unity_OneMinus_float(_Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_72c92735390a461dac7c71af8138c538;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(0.1), _EdgeDistance_72c92735390a461dac7c71af8138c538, _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float);
            float _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float);
            float _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float, _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float);
            float _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float, _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float);
            surface.Alpha = _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            
        
        
        
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
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
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
        
        
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
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
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
            output.tangentWS.xyzw = input.tangentWS;
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
        float4 _EdgeColor;
        float4 _FoamColor;
        float _WaveFrequency;
        float _ScreenSpaceReflections;
        float _WaveSpeed;
        float _WaveDist;
        float _MaxWaveDist;
        float4 _Color;
        float _NormalStrength;
        float _Speed;
        float _Tiling;
        float _Transparency;
        float _Caustic_Strength;
        float _UseFoam;
        float _Displacement_Amount;
        float _Displacement_Scale;
        float _Displacement_Speed;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include "Assets/WaterWorks/Shaders/WaterSSR.hlsl"
        
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
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float Vector1_c541d038fef84e4aaa1dbed97e38d366, Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float IN, out float2 YZ_3, out float2 XZ_2, out float2 XY_1)
        {
        float _Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float = Vector1_c541d038fef84e4aaa1dbed97e38d366;
        float3 _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3;
        Unity_Multiply_float3_float3(IN.WorldSpacePosition, (_Property_d7ab228f473641c9a2e701d8f25cdb11_Out_0_Float.xxx), _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3);
        float _Split_1acef4fb48e74181929303b0d2263c94_R_1_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[0];
        float _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[1];
        float _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float = _Multiply_d790d2f3126841a8975695f5b676e85b_Out_2_Vector3[2];
        float _Split_1acef4fb48e74181929303b0d2263c94_A_4_Float = 0;
        float2 _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_B_3_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        float2 _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_B_3_Float);
        float2 _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2 = float2(_Split_1acef4fb48e74181929303b0d2263c94_R_1_Float, _Split_1acef4fb48e74181929303b0d2263c94_G_2_Float);
        YZ_3 = _Vector2_5b8ffb5f468941d781da551f6c7d92b9_Out_0_Vector2;
        XZ_2 = _Vector2_53537842a972489fa6886beef0a17153_Out_0_Vector2;
        XY_1 = _Vector2_6016d8803b574b5993a6b09cfc842d1d_Out_0_Vector2;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float
        {
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 _UV, float _UseUV, Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float IN, out float3 WorldPos_1)
        {
        float _Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean = _UseUV;
        float2 _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2 = _UV;
        float4 _ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float2 _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2;
        Unity_Branch_float2(_Property_98b0109a4ddb491e92e9884c8b506d68_Out_0_Boolean, _Property_0de2042a676f48348247930ca4d8f412_Out_0_Vector2, (_ScreenPosition_9dca11b3934b4ce7afc140fb052e5feb_Out_0_Vector4.xy), _Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2);
        float _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float;
        Unity_SceneDepth_Eye_float((float4(_Branch_6a9995126ca34e7d9bd33aaff592aca0_Out_3_Vector2, 0.0, 1.0)), _SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float);
        float _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float;
        Unity_DotProduct_float3(IN.WorldSpaceViewDirection, (-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float);
        float3 _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3;
        Unity_Divide_float3(IN.WorldSpaceViewDirection, (_DotProduct_15de1d4606494133b06fe8315d37f93b_Out_2_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3);
        float3 _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3;
        Unity_Multiply_float3_float3((_SceneDepth_f05c2c9962d44d9ba0941245bb8939b4_Out_1_Float.xxx), _Divide_6e5b76a0b08f4f4987ccfe7b93614a96_Out_2_Vector3, _Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3);
        float3 _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        Unity_Add_float3(_Multiply_d1da2012fccf4b729ce67fac0a8fa520_Out_2_Vector3, _WorldSpaceCameraPos, _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3);
        WorldPos_1 = _Add_387b1ec6847e4fed8b4ceeb22ea8036c_Out_2_Vector3;
        }
        
        float2 Unity_Voronoi_RandomVector_LegacySine_float (float2 UV, float offset)
        {
            Hash_LegacySine_2_2_float(UV, UV);
            return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
        }
        
        void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    float2 lattice = float2(x, y);
                    float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
                    if (d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        };
        
        void SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float _Offset, Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float IN, out float Distance_1)
        {
        Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024.NDCPosition = IN.NDCPosition;
        float3 _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3;
        SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024, _WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3);
        float3 _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3;
        Unity_Subtract_float3(_WaterDepthToWorldPos_77a5299076df412c9edaea0e2323e024_WorldPos_1_Vector3, IN.WorldSpacePosition, _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3);
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_R_1_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[0];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[1];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_B_3_Float = _Subtract_09398f45505c46808183da543fb38e7c_Out_2_Vector3[2];
        float _Split_a414dd9fb9664b5891b7a8323eb4c497_A_4_Float = 0;
        float _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float;
        Unity_Absolute_float(_Split_a414dd9fb9664b5891b7a8323eb4c497_G_2_Float, _Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float);
        float _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float = _Offset;
        float _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float;
        Unity_Clamp_float(_Absolute_4a22dfefb44c4d0c8528e55d9d3e49d7_Out_1_Float, float(0), _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float);
        float _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        Unity_Divide_float(_Clamp_3c528cf4521344539c084133d08dc015_Out_3_Float, _Property_f91e8126a5d04149a0e3549bfcd99ef7_Out_0_Float, _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float);
        Distance_1 = _Divide_95921147a70149b09ac9cac8f8992d3a_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float
        {
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float2 NDCPosition;
        float3 TimeParameters;
        };
        
        void SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(float _WaveFrequency, float _WaveSpeed, float _WaveDist, float _Offset, Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float IN, out float Waves_1, out float Foam_2)
        {
        float _Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float = _WaveDist;
        Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.WorldSpacePosition = IN.WorldSpacePosition;
        _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61.NDCPosition = IN.NDCPosition;
        float _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float;
        SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(_Property_4bdf2fbc35d24836a753d74aa9ddcfe4_Out_0_Float, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61, _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float);
        float _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float = _WaveSpeed;
        float _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_1d06ab0c5c764087bf1680fa7fd10711_Out_0_Float, _Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float);
        float _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float = _Offset;
        float _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float;
        Unity_Add_float(_Multiply_3c2cfc49f6d3413c8ff6e591b8b25985_Out_2_Float, _Property_5bad4d2ed3004ae1a3ce5a93585a8ab3_Out_0_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float);
        float _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float;
        Unity_Add_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float);
        float _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float = _WaveFrequency;
        float _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float;
        Unity_Multiply_float_float(_Add_1d8cfa15449e42df94912c50173944b6_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float);
        float _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float;
        Unity_Floor_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float);
        float _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float;
        Unity_Fraction_float(_Multiply_dd229aaf3add4575a6b74a0c604d7fc8_Out_2_Float, _Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float);
        float _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float;
        Unity_Power_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, float(20), _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float);
        float _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float;
        Unity_Add_float(_Floor_2c9faabe0b7b4665a8039670e2349f2b_Out_1_Float, _Power_d9b81fdb9fa042e196776dbc3001628a_Out_2_Float, _Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float);
        float _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float;
        Unity_Divide_float(_Add_a3194d790b294bed8e938caccbea35c1_Out_2_Float, _Property_b75807894639406c9e5efd860307f1e8_Out_0_Float, _Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float);
        float _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float;
        Unity_Subtract_float(_Divide_357c0898075b4aef8d46cd59c4473714_Out_2_Float, _Add_9c0be73ba3da4cd9b76dc3fe62b99519_Out_2_Float, _Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float);
        float _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float;
        Unity_Clamp_float(_Subtract_f442f515ac634d188c850112f51a6f5e_Out_2_Float, float(0), float(1), _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float);
        float _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float;
        Unity_Multiply_float_float(2, _Clamp_9a10e123e6a74b188729306c3ad6fa26_Out_3_Float, _Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float);
        float _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Unity_Clamp_float(_Multiply_eb73f7dc4fea4014b20044b5d7610e7f_Out_2_Float, float(0), float(1), _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float);
        float _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float;
        Unity_OneMinus_float(_Fraction_736982134f0849189a94f81dd7da1532_Out_1_Float, _OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float);
        float _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float;
        Unity_Power_float(_OneMinus_b08d9010bdc44af78e8121e3016562a8_Out_1_Float, float(10), _Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float);
        float _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float;
        Unity_Step_float(float(1), _EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float);
        float _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float;
        Unity_OneMinus_float(_Step_a257accb1f2f4edbb58711f89ce3527b_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float);
        float _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float;
        Unity_Multiply_float_float(_Power_3fd2351f074d4f6190c96c9f6881f5c4_Out_2_Float, _OneMinus_4e5f6eaf5e3049b7b43ad5a4614cbdb6_Out_1_Float, _Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float);
        float _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float;
        Unity_Clamp_float(_Multiply_57b19bbde1d54651838b3fe415317cf3_Out_2_Float, float(0), float(1), _Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float);
        float _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float;
        Unity_OneMinus_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float);
        float _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float;
        Unity_Smoothstep_float(float(0), float(1), _OneMinus_afeda05296ec46d78e3ca7cc244246b6_Out_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float);
        float _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float;
        Unity_Multiply_float_float(_EdgeDistance_14053fb19a1d4b90b49d9c77319cac61_Distance_1_Float, _Smoothstep_cb6937a92151447ea02ffd167dcbdee3_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float);
        float _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        Unity_Multiply_float_float(_Clamp_b21efe9206cd4477889050453d9a7a5e_Out_3_Float, _Multiply_be10f83ca76d4e7cb20a9ad4499f907b_Out_2_Float, _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float);
        Waves_1 = _Clamp_1dbbdddcc4e04ed3bc052571950d1485_Out_3_Float;
        Foam_2 = _Multiply_622373cdc6794aa7a88e4b100c1de9f6_Out_2_Float;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            float3 worldDerivativeX = ddx(Position);
            float3 worldDerivativeY = ddy(Position);
        
            float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
            float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
            float d = dot(worldDerivativeX, crossY);
            float sgn = d < 0.0 ? (-1.0f) : 1.0f;
            float surface = sgn / max(0.000000000000001192093f, abs(d));
        
            float dHdx = ddx(In);
            float dHdy = ddy(In);
            float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
            Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
            Out = TransformWorldToTangent(Out, TangentMatrix);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void ref_float(float3 View, float3 Normal, float IOR, out float3 Out){
        Out = refract(View, Normal, IOR);
        }
        
        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float
        {
        float3 WorldSpaceNormal;
        float3 WorldSpaceTangent;
        float3 WorldSpaceBiTangent;
        float3 WorldSpaceViewDirection;
        float2 NDCPosition;
        };
        
        void SG_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float(float Vector1_9AC3B9A5, float3 Vector3_90258404, float Vector1_6604C6DE, Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float IN, out float3 Out_1)
        {
        float3 _SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3;
        Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3);
        float4 _ScreenPosition_0e0d43ed492f568494cf68c3f0d94863_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
        float3 _Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3;
        Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3);
        float3 _Property_06b2b93e9aad7f83bcbdcd89ffb2c49f_Out_0_Vector3 = Vector3_90258404;
        float3 _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3;
        Unity_Normalize_float3(_Property_06b2b93e9aad7f83bcbdcd89ffb2c49f_Out_0_Vector3, _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3);
        float _Property_5eb756389a644c899050838a3ceca5e1_Out_0_Float = Vector1_9AC3B9A5;
        float3 _refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3;
        ref_float(_Normalize_6a3f36e95910c288a7a180d63a3f3585_Out_1_Vector3, _Normalize_c918b38177a4ac80a62e4673926c4f41_Out_1_Vector3, _Property_5eb756389a644c899050838a3ceca5e1_Out_0_Float, _refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3);
        float3 _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3;
        {
        float3x3 tangentTransform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
        _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3 = TransformWorldToTangent(_refCustomFunction_dcef08c16ebd6e8b85328cccffc54b2c_Out_3_Vector3.xyz, tangentTransform, true);
        }
        float3 _Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3;
        Unity_Add_float3((_ScreenPosition_0e0d43ed492f568494cf68c3f0d94863_Out_0_Vector4.xyz), _Transform_98c50fd86157e786a46cca23b0143f38_Out_1_Vector3, _Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3);
        float3 _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3;
        Unity_Floor_float3(_Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3, _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3);
        float3 _Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3;
        Unity_Subtract_float3(_Add_6e0bd6169796b98eb3b67572d2d01024_Out_2_Vector3, _Floor_ec0817ac0a524e8cb4f706386a4bda1f_Out_1_Vector3, _Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3);
        float2 _Vector2_4edaee860484198683cf81fd0bffdd27_Out_0_Vector2 = float2(float(1), float(1));
        float _Property_e30ceff597802a8b9a455fb3e3965d62_Out_0_Float = Vector1_6604C6DE;
        float _Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float;
        Unity_Divide_float(_Property_e30ceff597802a8b9a455fb3e3965d62_Out_0_Float, float(100), _Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float);
        float _Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float;
        Unity_Clamp_float(_Divide_6a7cd5ea5bb8a7858b4b26659d68382d_Out_2_Float, float(0), float(5), _Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float);
        float2 _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_4edaee860484198683cf81fd0bffdd27_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2);
        float2 _Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_18eabb74f597b58ea3427b0fe99afba4_Out_2_Vector2, _Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2);
        float3 _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_0a2958a769661b8087952748eeda74bc_Out_2_Vector2, 0.0, 1.0)), _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3);
        float3 _Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3;
        Unity_Add_float3(_SceneColor_9acc175d01aad38abfd3ce4717cb7fa6_Out_1_Vector3, _SceneColor_f5613bb04a5acb8aa0e54bebe59ca82d_Out_1_Vector3, _Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3);
        float2 _Vector2_19ef821db1cdc783a43742b9cf51b8c8_Out_0_Vector2 = float2(float(-1), float(1));
        float2 _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_19ef821db1cdc783a43742b9cf51b8c8_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2);
        float2 _Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_b50767920bfdce888205465269083b1e_Out_2_Vector2, _Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2);
        float3 _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_3858c65c32de4b828db34732166869f1_Out_2_Vector2, 0.0, 1.0)), _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3);
        float3 _Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3;
        Unity_Add_float3(_Add_afff453db064f986bee48c3ec5ec0c58_Out_2_Vector3, _SceneColor_224694bf71acd988a997594ae03a3ab5_Out_1_Vector3, _Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3);
        float2 _Vector2_fb7f3e085d3ebe84b7178b3bc4a39da8_Out_0_Vector2 = float2(float(1), float(-1));
        float2 _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_fb7f3e085d3ebe84b7178b3bc4a39da8_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2);
        float2 _Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_04d05d32892c5983abb75ad05b581609_Out_2_Vector2, _Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2);
        float3 _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_0f4225a6c180f68dabe00718b1d0b225_Out_2_Vector2, 0.0, 1.0)), _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3);
        float3 _Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3;
        Unity_Add_float3(_Add_61083fb8fbd0bc828db59f4708e7910e_Out_2_Vector3, _SceneColor_96c2c25411d91b89a01bbfaea970e85f_Out_1_Vector3, _Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3);
        float2 _Vector2_9e6584c2279b638190dff9a888cf9a4d_Out_0_Vector2 = float2(float(-1), float(-1));
        float2 _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_9e6584c2279b638190dff9a888cf9a4d_Out_0_Vector2, (_Clamp_948299dbf0bc7e819fe27a35f7c6b55c_Out_3_Float.xx), _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2);
        float2 _Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2;
        Unity_Add_float2((_Subtract_1952259c01cb9b888049a2124f20b73e_Out_2_Vector3.xy), _Multiply_489aa81da842e98ebed152c65c009a6b_Out_2_Vector2, _Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2);
        float3 _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3;
        Unity_SceneColor_float((float4(_Add_7723bc48fcce2087bbedbb7796a7b3c5_Out_2_Vector2, 0.0, 1.0)), _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3);
        float3 _Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3;
        Unity_Add_float3(_Add_452aa915519b888195ce93c8eb63c6fd_Out_2_Vector3, _SceneColor_bc12a5b6a4d8a58585a19fd4986d9a1e_Out_1_Vector3, _Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3);
        float _Float_62fb265fcb81c2809fc6b96dcab9cf54_Out_0_Float = float(5);
        float3 _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3;
        Unity_Divide_float3(_Add_e01dd7ab05801483857427bf177d5606_Out_2_Vector3, (_Float_62fb265fcb81c2809fc6b96dcab9cf54_Out_0_Float.xxx), _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3);
        Out_1 = _Divide_30f163a9d12bec8daac86c40d08e2ec0_Out_2_Vector3;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
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
            float _Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_f0b669abeb8b471ab09abf291dad8815_A_4_Float = 0;
            float _Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float = _Displacement_Scale;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_d51af62a44f34b2eb621da1dbe974c41;
            _WSUVWater_d51af62a44f34b2eb621da1dbe974c41.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2;
            float2 _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_e97a974437e34842b9947a1ee6de24f4_Out_0_Float, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_YZ_3_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, _WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XY_1_Vector2);
            float _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float = _Displacement_Speed;
            float _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_52dd117432e04458956fcbbe176815d7_Out_0_Float, _Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float);
            float2 _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_d51af62a44f34b2eb621da1dbe974c41_XZ_2_Vector2, (_Multiply_0a7f7e185cab4d63a45480591f9f5a3a_Out_2_Float.xx), _Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2);
            float _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_2a5d1f28b19049ae93b71fc41425832f_Out_2_Vector2, float(2), _GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float);
            float _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float = _Displacement_Amount;
            float _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float;
            Unity_Multiply_float_float(_GradientNoise_cef5308b1c2d4674ac16aa7e5a485ba4_Out_2_Float, _Property_8a849e9472c24f49b3c3a73cf57ad920_Out_0_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float);
            float _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float;
            Unity_Add_float(_Split_f0b669abeb8b471ab09abf291dad8815_G_2_Float, _Multiply_a78515cd93bb48a0b97f2062068389b8_Out_2_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float);
            float3 _Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3 = float3(_Split_f0b669abeb8b471ab09abf291dad8815_R_1_Float, _Add_1ecf4f0dc4034e3d868e95d8cae87ba7_Out_2_Float, _Split_f0b669abeb8b471ab09abf291dad8815_B_3_Float);
            float3 _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
            _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3 = TransformWorldToObject(_Vector3_22a0de6729c1498a8df015cc082ad46d_Out_0_Vector3.xyz);
            description.Position = _Transform_630212d29b2a41fe8fa82da102ce4f9d_Out_1_Vector3;
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            Bindings_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e;
            _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e.NDCPosition = IN.NDCPosition;
            float3 _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3;
            SG_WaterDepthToWorldPos_48489c6a22e34554e80fc4885c307b70_float(float2 (0, 0), 0, _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e, _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3);
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_R_1_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[0];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_G_2_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[1];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_B_3_Float = _WaterDepthToWorldPos_fe31d0668984452bbfb24f101ea1d08e_WorldPos_1_Vector3[2];
            float _Split_af2dcc47ab1f44c09a4753a196a06d9c_A_4_Float = 0;
            float2 _Vector2_c0a539d837d74542b502faac38a301ce_Out_0_Vector2 = float2(_Split_af2dcc47ab1f44c09a4753a196a06d9c_R_1_Float, _Split_af2dcc47ab1f44c09a4753a196a06d9c_B_3_Float);
            float _Property_d5ee87edeaeb46438ba81528f2801bc2_Out_0_Float = _Speed;
            float _Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d5ee87edeaeb46438ba81528f2801bc2_Out_0_Float, _Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float);
            float _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e60c073b24254fedbea9924c12dabe33_Out_2_Float, 20, _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float);
            float _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float;
            float _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_Vector2_c0a539d837d74542b502faac38a301ce_Out_0_Vector2, _Multiply_72637dc33edb43ae9abc52a05cb55af5_Out_2_Float, float(0.5), _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float, _Voronoi_576bd6f5338c4870b0daaabdaaf60152_Cells_4_Float);
            float _Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float;
            Unity_Power_float(_Voronoi_576bd6f5338c4870b0daaabdaaf60152_Out_3_Float, float(3), _Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float);
            float _Property_274d0ef360aa4c7a9365ff75e7b4395b_Out_0_Float = _Caustic_Strength;
            float _Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float;
            Unity_Multiply_float_float(_Power_746b63cc80274e76b2764ec0f8d80fe9_Out_2_Float, _Property_274d0ef360aa4c7a9365ff75e7b4395b_Out_0_Float, _Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(5), _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e, _EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float);
            float _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_f681784f2eaf4d4fa679225dbce1d14e_Distance_1_Float, _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float);
            float _Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_5fcc0803920c4070853d34a6c615c7e7_Out_2_Float, _OneMinus_54cff148709743969d168679df8c6849_Out_1_Float, _Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float);
            float _Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float = _WaveFrequency;
            float _Property_477adb340d344e78a50e313038d7008b_Out_0_Float = _WaveSpeed;
            float _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float = _WaveDist;
            float _Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370;
            _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2;
            float2 _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_c060d09b39a6413e9e2ba216d6017e32_Out_0_Float, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_YZ_3_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, _WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XY_1_Vector2);
            float _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float = _Speed;
            float _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3a5d40f4288c4e09a6ab2ab58b65c1f1_Out_0_Float, _Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float);
            float _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float;
            Unity_Divide_float(_Multiply_31092a161bc6424c896ed671f15b5a7b_Out_2_Float, float(5), _Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float);
            float2 _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (1, 1), (_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float.xx), _TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2);
            float _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_b998fe394b6c4ad2b8ae8733a4fe344a_Out_3_Vector2, float(50), _GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float);
            float _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float;
            Unity_Negate_float(_Divide_e970f20ba2204d9b977f2401e4c23d67_Out_2_Float, _Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float);
            float2 _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_a1c8966597334e0a9de5c3ea3a7b0370_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_d271f65cda544c888dbc6f922b949def_Out_1_Float.xx), _TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2);
            float _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_2b347460a7a645ce9058354f98dcd2a2_Out_3_Vector2, float(50), _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float);
            float _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float;
            Unity_Add_float(_GradientNoise_7d512bd0b7c64d05a8f884578aefc898_Out_2_Float, _GradientNoise_2406093dafae445aa2f562774665b0e0_Out_2_Float, _Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float);
            float _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float;
            Unity_Divide_float(_Add_0cb46bd4a0894c5189cf3599eb6cb3a2_Out_2_Float, float(100), _Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float);
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_5b92dfc7e363488d925b69046c47538f;
            _WSUVWater_5b92dfc7e363488d925b69046c47538f.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2;
            float2 _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(float(0.5), _WSUVWater_5b92dfc7e363488d925b69046c47538f, _WSUVWater_5b92dfc7e363488d925b69046c47538f_YZ_3_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _WSUVWater_5b92dfc7e363488d925b69046c47538f_XY_1_Vector2);
            float _Property_762f6624e50447109a1a63175dcb252b_Out_0_Float = _WaveSpeed;
            float _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float;
            Unity_Multiply_float_float(_Property_762f6624e50447109a1a63175dcb252b_Out_0_Float, 100, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float);
            float _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float);
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float;
            float _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(1), _Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, _Voronoi_2b710b9e27af45d3926810e6823ccb77_Cells_4_Float);
            float _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float;
            Unity_Remap_float(_Voronoi_2b710b9e27af45d3926810e6823ccb77_Out_3_Float, float2 (0, 1), float2 (-0.02, 0.02), _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float);
            float _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float;
            Unity_Add_float(_Divide_57caf400aee94267ab274c41fd9668b0_Out_2_Float, _Remap_4e612b8d85da4b8ab79f68d91bffa909_Out_3_Float, _Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float);
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float;
            float _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float;
            Unity_Voronoi_LegacySine_float(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, _Multiply_a48fa9bbdb82428da90b1bf843ffc4db_Out_2_Float, float(2), _Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, _Voronoi_b92cee69ba1646188e5648cffc060a40_Cells_4_Float);
            float _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float;
            Unity_Remap_float(_Voronoi_b92cee69ba1646188e5648cffc060a40_Out_3_Float, float2 (0, 1), float2 (-0.01, 0.01), _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float);
            float _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float;
            Unity_Add_float(_Add_f1f3af2928e94f49b5e8c9d99b27e38f_Out_2_Float, _Remap_d93cada2533e49febcdb4a2bce277250_Out_3_Float, _Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float);
            float _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_3678f02a47a94b7caa4e32a914258668_Out_2_Float, 0.2, _Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float);
            float2 _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_5b92dfc7e363488d925b69046c47538f_XZ_2_Vector2, (_Multiply_03f6fd149cd64b37ba5e2b2e7a92df18_Out_2_Float.xx), _Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2);
            float _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_4dd4437e21a64149b168cd9108854faa_Out_2_Vector2, float(0.1), _GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float);
            float _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float;
            Unity_Remap_float(_GradientNoise_d920f797f1c44ecaa040059d4513d03d_Out_2_Float, float2 (0, 1), float2 (-0.05, 0.05), _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float);
            float _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float;
            Unity_Add_float(_Add_fad07a7725ff44218e1fbbd990805a7b_Out_2_Float, _Remap_b556be64e8ea4236aeba5bde5d8fc2ce_Out_3_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float);
            Bindings_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.WorldSpacePosition = IN.WorldSpacePosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.NDCPosition = IN.NDCPosition;
            _WaveDistance_3d44fc24ca6945f991bbe0446a505a88.TimeParameters = IN.TimeParameters;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float;
            float _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float;
            SG_WaveDistance_d58957f120086c44a95a7eb2f92ccc7d_float(_Property_9d39a42662aa40eabda5f3937a2e6684_Out_0_Float, _Property_477adb340d344e78a50e313038d7008b_Out_0_Float, _Property_6d1d8a922d334f619d73cb6067ec316a_Out_0_Float, _Add_5a7d21cab47f4379875e213aae8d4d7e_Out_2_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float);
            float _Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_4e1215d7c6f243fda2e27a2d8e4cbd4e_Out_2_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float);
            float _Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float;
            Unity_Add_float(_Multiply_87fd2aba2be3455796b79614430b6ab4_Out_2_Float, float(1), _Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float);
            float _Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float = _Tiling;
            Bindings_WSUVWater_018fad018d058a44caa283cdf595320b_float _WSUVWater_36fa2fa042a646e3884f906afce491d4;
            _WSUVWater_36fa2fa042a646e3884f906afce491d4.WorldSpacePosition = IN.WorldSpacePosition;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2;
            float2 _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2;
            SG_WSUVWater_018fad018d058a44caa283cdf595320b_float(_Property_13201da71be643ec9a3ce8a9d6eb18b4_Out_0_Float, _WSUVWater_36fa2fa042a646e3884f906afce491d4, _WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, _WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2);
            float _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float = _Speed;
            float _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_5fb06a5e119c4b128a838626c2bd45b4_Out_0_Float, _Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float);
            float _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float;
            Unity_Add_float(_Multiply_b4e3bcfad32b402fbd1499123f4bc83a_Out_2_Float, float(15), _Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float);
            float2 _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (1, 1), (_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float.xx), _TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2);
            float _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_f011ff8858e443919f1b9c903be6dcd8_Out_3_Vector2, float(10), _GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float);
            float _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float;
            Unity_Negate_float(_Add_ed5804b88bf24c29858708a614b79b72_Out_2_Float, _Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float);
            float2 _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2;
            Unity_TilingAndOffset_float(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XZ_2_Vector2, float2 (0.5, 0.5), (_Negate_fe91f92d23254ed9b9ca32b3d823f857_Out_1_Float.xx), _TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2);
            float _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_192b5d5ece6c4e8ba3f4ede2c5558717_Out_3_Vector2, float(10), _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float);
            float _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float;
            Unity_Add_float(_GradientNoise_34e334b2f7b04501ae0caeb39dd3bc61_Out_2_Float, _GradientNoise_26e8afb399b34677bb1d359f3e83b141_Out_2_Float, _Add_17adcc70e6964669b273ffa660c43379_Out_2_Float);
            float _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float;
            Unity_Divide_float(_Add_17adcc70e6964669b273ffa660c43379_Out_2_Float, float(2), _Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float);
            float3 _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3);
            float3 _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3;
            Unity_Power_float3(_Absolute_9370216baa1e4894bda627e0251aaa7e_Out_1_Vector3, float3(0.8, 5, 0.8), _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3);
            float _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[0];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[1];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float = _Power_9e0cbe103d4341a0a3463a4d138078e6_Out_2_Vector3[2];
            float _Split_05dcfe67494545f6932f8f114a84a8e8_A_4_Float = 0;
            float _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float;
            Unity_Multiply_float_float(_Divide_9bcf4a6c4d7548ae85ed8d3fedf2b9d8_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_G_2_Float, _Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float);
            float _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float = _Speed;
            float _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c84ceb478a1946dc9bd1f7e4369e42f9_Out_0_Float, _Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float);
            float _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_6064d2834454494caf2247c693e2e55c_Out_2_Float, 5, _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_YZ_3_Vector2, _Vector2_d8cbcfbdbed54c398d783ac53a256e2f_Out_0_Vector2, _Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2);
            float _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float = _Speed;
            float _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ef30d7780da44f9e9c03c2b10a4b69c6_Out_0_Float, _Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float);
            float _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float;
            Unity_Add_float(_Multiply_6a9d562c9dd74d67b8961de0ed92bf80_Out_2_Float, float(15), _Add_3372469fcbd249c480c07248c68574e0_Out_2_Float);
            float2 _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (1, 1), (_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float.xx), _TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2);
            float _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_daf2a7f544dd47afa040be5051f268b3_Out_3_Vector2, float(10), _GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float);
            float _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float;
            Unity_Negate_float(_Add_3372469fcbd249c480c07248c68574e0_Out_2_Float, _Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float);
            float2 _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_d94bb6fce8ff457e8397af810eed6d46_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_312a3e5099ce48a382142f13d46765d0_Out_1_Float.xx), _TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2);
            float _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a90b7547937046b2ac79fce384f01c19_Out_3_Vector2, float(10), _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float);
            float _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float;
            Unity_Add_float(_GradientNoise_3a70a728e9744af487ebb5e1df654bd1_Out_2_Float, _GradientNoise_d750cae8744a4735a2d779554260c2f8_Out_2_Float, _Add_230c1475b56243bf8ed4151c26453420_Out_2_Float);
            float _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float;
            Unity_Divide_float(_Add_230c1475b56243bf8ed4151c26453420_Out_2_Float, float(2), _Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float);
            float _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float;
            Unity_Multiply_float_float(_Divide_b5476ec1fc54436fb9972f44a0bcfaf3_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_R_1_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float);
            float _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float;
            Unity_Add_float(_Multiply_4d02c572aedc43a8a3737b51d3e33cfd_Out_2_Float, _Multiply_40c78c41d88e4495bd5444d9ae886de8_Out_2_Float, _Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float);
            float2 _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2 = float2(float(0), _Multiply_8899b8dbfa5d41699180f1baa1505e7d_Out_2_Float);
            float2 _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2;
            Unity_Add_float2(_WSUVWater_36fa2fa042a646e3884f906afce491d4_XY_1_Vector2, _Vector2_849e96ba734d43b6bcf80013b6c84f50_Out_0_Vector2, _Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2);
            float _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float = _Speed;
            float _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_31379bec6a9a4d589559eaca4cbc7b91_Out_0_Float, _Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float);
            float _Add_983001d85ada4e5396410433f0861366_Out_2_Float;
            Unity_Add_float(_Multiply_3773f9599abf4b59ad4d949fdb6c38ff_Out_2_Float, float(15), _Add_983001d85ada4e5396410433f0861366_Out_2_Float);
            float2 _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (1, 1), (_Add_983001d85ada4e5396410433f0861366_Out_2_Float.xx), _TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2);
            float _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_86158f582ec14cc89a08d178c516ab23_Out_3_Vector2, float(10), _GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float);
            float _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float;
            Unity_Negate_float(_Add_983001d85ada4e5396410433f0861366_Out_2_Float, _Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float);
            float2 _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Add_138a8d251b164cbe86d980a76ead7793_Out_2_Vector2, float2 (0.5, 0.5), (_Negate_adc5d8b1f7e04a699ef3f3b1cb481eac_Out_1_Float.xx), _TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2);
            float _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_fd8eb98438184a87be1851a874127c8a_Out_3_Vector2, float(10), _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float);
            float _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float;
            Unity_Add_float(_GradientNoise_846c0241034a4eceb1e57dd4703ccd82_Out_2_Float, _GradientNoise_9f20bf62958b452894557a2ee9cc0358_Out_2_Float, _Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float);
            float _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float;
            Unity_Divide_float(_Add_a2f2a2d30a3949b1891ab946daad15f0_Out_2_Float, float(2), _Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float);
            float _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3c0b2d53a0604189bca2785a3df6bbee_Out_2_Float, _Split_05dcfe67494545f6932f8f114a84a8e8_B_3_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float);
            float _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float;
            Unity_Add_float(_Add_4e64b91bb2c748a1811f991a309f90fd_Out_2_Float, _Multiply_a5d8c71ff6d4413fbb091efccec1fb3a_Out_2_Float, _Add_b59ffb521828459097b93f52a7273e22_Out_2_Float);
            float _Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float = _NormalStrength;
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3;
            float3x3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Add_b59ffb521828459097b93f52a7273e22_Out_2_Float,_Property_c7f2c4ec740648fa9edb95f9ba6a1804_Out_0_Float,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Position,_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_TangentMatrix, _NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3);
            float3 _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalFromHeight_34b5a648d43a4f31bb9069e4a56ea015_Out_1_Vector3, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3);
            float3 _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3;
            Unity_NormalBlend_float(IN.WorldSpaceNormal, _NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3);
            Bindings_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float _RefractionWater_1dc846b8009e42daa40194bfa238ccf5;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceNormal = IN.WorldSpaceNormal;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceTangent = IN.WorldSpaceTangent;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _RefractionWater_1dc846b8009e42daa40194bfa238ccf5.NDCPosition = IN.NDCPosition;
            float3 _RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3;
            SG_RefractionWater_484fd2cdea9f33c47ba61290a601149b_float(float(0), _NormalBlend_f60fafd20078438e9267b138069730e4_Out_2_Vector3, float(0), _RefractionWater_1dc846b8009e42daa40194bfa238ccf5, _RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3);
            float3 _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3;
            Unity_Divide_float3(_RefractionWater_1dc846b8009e42daa40194bfa238ccf5_Out_1_Vector3, float3(4, 4, 4), _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3);
            float3 _Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Add_74a1608bded94ff089b0dd8ae2345a15_Out_2_Float.xxx), _Divide_e53068e00def4d668328cf9ff2f0f682_Out_2_Vector3, _Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3);
            float _Property_435087f89a0844699f112036328deb26_Out_0_Boolean = _ScreenSpaceReflections;
            float4 _ScreenPosition_1edb3c7d82804b74905a8e863bff1c6b_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float3 _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3;
            Unity_NormalStrength_float(_NormalStrength_0beaa210f6f3480f81a4bd00581ea9bd_Out_2_Vector3, float(0.2), _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3);
            float3 _SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3;
            SSR_float(IN.WorldSpaceViewDirection, float(0.2), _ScreenPosition_1edb3c7d82804b74905a8e863bff1c6b_Out_0_Vector4, float(15), float(0.5), float(1), _NormalStrength_a1c22b45b2a94a2d88518e2cc2fabe69_Out_2_Vector3, IN.WorldSpacePosition, 0, _SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3);
            float3 _SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3;
            Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3);
            float _SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float);
            float3 _Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3;
            Unity_Multiply_float3_float3(_SceneColor_49a0d82c24b54d2c880e133bc77d3778_Out_1_Vector3, (_SceneDepth_69735bdd1616426dace37c830cb105b1_Out_1_Float.xxx), _Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3);
            float3 _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_191cad60ec964075aaf244181265370d_Out_2_Vector3, float3(0, 0, 0), _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3);
            float3 _Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3;
            Unity_Add_float3(_SSRCustomFunction_26d27e050a474c018d7565e969730c2f_col_3_Vector3, _Multiply_ea2d4e72e6a043d580125345ea95846b_Out_2_Vector3, _Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3);
            float4 _Property_e872ea45cad54716aa3bfdc09420466c_Out_0_Vector4 = _EdgeColor;
            float4 _Property_a836ea15ef7548cfaaa54fe15300f69e_Out_0_Vector4 = _Color;
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(5), _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd, _EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float);
            float _OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_d1ca074e9cd54c598d41b0345ab22cdd_Distance_1_Float, _OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float);
            float4 _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_632fd0c5217a4c1f85635b2663b7f106_R_1_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[0];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_G_2_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[1];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_B_3_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[2];
            float _Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float = _ScreenPosition_90597768ba8841bcbadc8c4621410f3d_Out_0_Vector4[3];
            float _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float = _MaxWaveDist;
            float _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float;
            Unity_Clamp_float(_Split_632fd0c5217a4c1f85635b2663b7f106_A_4_Float, float(0), _Property_c19dbcee3fbc47d5851d722e0714a563_Out_0_Float, _Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float);
            float _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float = _MaxWaveDist;
            float _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float;
            Unity_Divide_float(_Clamp_4efe562fae7d4f7d86e8cf8653e9e185_Out_3_Float, _Property_8e9cfeb152f040a488244230485fe343_Out_0_Float, _Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float);
            float _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float;
            Unity_OneMinus_float(_Divide_91fa43b96c144c819df08cae1228a7f4_Out_2_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float);
            float _Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_fc246c679c264bbfaf9edeccf00c77b2_Out_1_Float, _OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float);
            float _OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float;
            Unity_OneMinus_float(_Multiply_6489f6e788b241d792b366f16bd38624_Out_2_Float, _OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float);
            float4 _Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4;
            Unity_Lerp_float4(_Property_e872ea45cad54716aa3bfdc09420466c_Out_0_Vector4, _Property_a836ea15ef7548cfaaa54fe15300f69e_Out_0_Vector4, (_OneMinus_02ffe46bf8124ad6a4bb7b25c5524f0f_Out_1_Float.xxxx), _Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4);
            float4 _Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4, float4(0.5, 0.5, 0.5, 1), _Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4);
            float3 _Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_8267ccf3cb5145c6848f64dc843e8d49_Out_2_Vector3, (_Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4.xyz), _Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3);
            float _FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(1), _FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float);
            float3 _Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_df91d57e18294b9bbc28dc9c5883a8e5_Out_2_Vector3, (_FresnelEffect_d1927b38676e4bda97214f7866675a78_Out_3_Float.xxx), _Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3);
            float3 _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3;
            Unity_Add_float3(_Multiply_4cde91c6da6b4d728f515510e7ae481f_Out_2_Vector3, (_Multiply_69d263c3f43644a5b2a322039184d156_Out_2_Vector4.xyz), _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3);
            float3 _Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3;
            Unity_Branch_float3(_Property_435087f89a0844699f112036328deb26_Out_0_Boolean, _Add_c39f2b5e29624492b5c82751b5ca4755_Out_2_Vector3, (_Lerp_7162712fe15d439c83426bc2d3da0965_Out_3_Vector4.xyz), _Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3);
            float4 _Property_383d38dddb2c43959c6bb3f96b7dac8b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_FoamColor) : _FoamColor;
            float _Property_62bafa60731645a8987f0591e2774b91_Out_0_Boolean = _UseFoam;
            float _Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float;
            Unity_Branch_float(_Property_62bafa60731645a8987f0591e2774b91_Out_0_Boolean, float(1), float(0), _Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float);
            float _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float;
            Unity_Multiply_float_float(_Branch_9d35e021c4e5408f806aec43907ce343_Out_3_Float, _WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Foam_2_Float, _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float);
            float _Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _Multiply_cb9b0aa3b61b48cf8ae3513d75a89186_Out_2_Float, _Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float);
            float _Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float;
            Unity_Clamp_float(_Multiply_0f50eb07f02642b8b17bacc297656bc7_Out_2_Float, float(0), float(1), _Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float);
            float3 _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3;
            Unity_Lerp_float3(_Branch_76e3cac8f52045499311ee523546d404_Out_3_Vector3, (_Property_383d38dddb2c43959c6bb3f96b7dac8b_Out_0_Vector4.xyz), (_Clamp_f0897963e69148f580f34cda0002d5b5_Out_3_Float.xxx), _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3);
            float _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float;
            Unity_OneMinus_float(_WaveDistance_3d44fc24ca6945f991bbe0446a505a88_Waves_1_Float, _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float);
            float _Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_5602192689dc4cc1a2474053d5dbf6ae_Out_1_Float, _Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float);
            float _OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float;
            Unity_OneMinus_float(_Multiply_08334cf979f8486ea63ff64da4e24eee_Out_2_Float, _OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float);
            float _Property_6595fb42eef04aeca117629c498ea6d1_Out_0_Float = _Transparency;
            float _Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_7fd7b5ddb97a422da22d02245be8b7d4_Out_1_Float, _Property_6595fb42eef04aeca117629c498ea6d1_Out_0_Float, _Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float);
            float3 _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3;
            Unity_Lerp_float3(_Multiply_530ad6b3c0f5408e9cd5a876859afaef_Out_2_Vector3, _Lerp_eb2ab1b69b3246c7a65ac6ec86da7538_Out_3_Vector3, (_Multiply_c4c1160964a2460486d7a1d5c653a3e0_Out_2_Float.xxx), _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3);
            Bindings_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float _EdgeDistance_72c92735390a461dac7c71af8138c538;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.WorldSpacePosition = IN.WorldSpacePosition;
            _EdgeDistance_72c92735390a461dac7c71af8138c538.NDCPosition = IN.NDCPosition;
            float _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float;
            SG_EdgeDistance_855e1b7d514c442498370d0fb61777c3_float(float(0.1), _EdgeDistance_72c92735390a461dac7c71af8138c538, _EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float);
            float _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float;
            Unity_OneMinus_float(_EdgeDistance_72c92735390a461dac7c71af8138c538_Distance_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float);
            float _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_668a7efe8d3b4201a02755c4326c8b97_Out_1_Float, _OneMinus_1474ea58a62a4c1397f8c73de89ff1c4_Out_1_Float, _Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float);
            float _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0d9144b38f784b6a9dec99336b981df0_Out_2_Float, _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float);
            surface.BaseColor = _Lerp_9d32d88fe293465d98692519a37f5112_Out_3_Vector3;
            surface.Alpha = _OneMinus_4398d87ac10d4d94b269ef5460759231_Out_1_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
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