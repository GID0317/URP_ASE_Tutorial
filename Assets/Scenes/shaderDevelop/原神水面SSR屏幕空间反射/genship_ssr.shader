Shader "Unlit/genship_ssr"
{
    Properties
    {
//        _MainTex ("Texture", 2D) = "white" {}
        _reflectInfiniteDistanceX_and_AlphaY("_reflectInfiniteDistanceX_and_AlphaY", Vector) = (129.00, 1.00, 0.00, 0.00)
        _InfiniteScreenPos_ST("_InfiniteScreenPos_ST", Vector) = (1.47305, 0.82843, -0.73652, -0.41421)
        _Linear_Tracing_AMOUNT_LENGTH("_Linear_Tracing_AMOUNT_LENGTH", Range(0, 17)) = 17
    }
    SubShader
    {
        Tags { "LightMode"="UniversalForward" "RenderType"="Transparent" "RenderQueue" = "Transparent" }
        LOD 100
//        Blend One Zero
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        

        Pass
        {
            HLSLPROGRAM
            // sampler2D _MainTex;
            // float4 _MainTex_ST;
            float4 _reflectInfiniteDistanceX_and_AlphaY;
            float4 _InfiniteScreenPos_ST;
            float _Linear_Tracing_AMOUNT_LENGTH;
            
            #pragma enable_d3d11_debug_symbols
            #pragma vertex vert
            #pragma fragment frag

            #define REQUIRE_DEPTH_TEXTURE 1
            #define REQUIRE_OPAQUE_TEXTURE 1
            
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 Varying_worldPos : TEXCOORD0;
                float3 Varying_WorldNormal : TEXCOORD1;
                float4 Varying_NotNormaizeScreenPosXYW : TEXCOORD2;
            };
            

            float4 ComputeNonStereoScreenPos(float4 pos) {
                float4 o = pos * 0.5;
                o.xy = float2(o.x, o.y*_ProjectionParams.x) + o.w;
                o.zw = pos.zw;
                return o;
                // return ComputeScreenPos(pos);
            }


            v2f vert (appdata v)
            {
                v2f o;

                float3 _WorldPos = TransformObjectToWorld( v.vertex.xyz );
                o.Varying_worldPos.xyz = _WorldPos;
				float4 _ClipPos = TransformWorldToHClip( _WorldPos );
                o.vertex = _ClipPos;
                
                o.Varying_WorldNormal = TransformObjectToWorldNormal(v.normal);
                
                o.Varying_NotNormaizeScreenPosXYW = ComputeNonStereoScreenPos(o.vertex);

                return o;
            }

            float2 NormalizeScreenPos(float3 xyw) {
                return xyw.xy / xyw.zz;
            }

            float MinTo01Edge2D( float2 in01_2D) {
                float2 oneMinus = 1.0 - in01_2D;
                float2 minPerXY = min(in01_2D, oneMinus);
                return min(minPerXY.y, minPerXY.x);
            }

            float CalcFadeToScreenEdge(float2 screenPos) {
                float minToScreenEdge = MinTo01Edge2D(screenPos);

                bool _bIsCloseToScreenEdgePixel;
                _bIsCloseToScreenEdgePixel = 0.15 < minToScreenEdge;
                
                float minToScreenEdge6_66 = clamp(minToScreenEdge * 6.666666666, 0.0, 1.0);

                return _bIsCloseToScreenEdgePixel ? 1.0 : minToScreenEdge6_66;
            }



            float Linear01Depth(float z)
            {
                float isOrtho = unity_OrthoParams.w;
                float isPers = 1.0 - unity_OrthoParams.w;
                z *= _ZBufferParams.x;
                return (1.0 - isOrtho * z) / (isPers * z + _ZBufferParams.y);
            }

            #define Linear_Tracing_MAX_STEP 8
            #define Linear_Tracing_AMOUNT_LENGTH _Linear_Tracing_AMOUNT_LENGTH //17
            
            float4 frag (v2f input) : SV_Target
            {
                float4 value = float4(0, 0, 0, 1);
                float3 viewDir = (-input.Varying_worldPos.xyz) + _WorldSpaceCameraPos;

                float3 viewDir_normalize = normalize(viewDir);

                float3 viewInDir = -viewDir_normalize;
                
                float3 reflectDir = reflect(viewInDir, input.Varying_WorldNormal);
                
                reflectDir = normalize(reflectDir);

            // 1. raycast ���߼��������ܲ��� raycast ����
                float3 _raycast_end = (reflectDir * Linear_Tracing_AMOUNT_LENGTH) + input.Varying_worldPos.xyz;

                float4 _raycast_end_clipPos = TransformWorldToHClip(_raycast_end);

                float4 _raycast_end_NonStereoScreenPos = ComputeNonStereoScreenPos(_raycast_end_clipPos);

                float3 _raycast_step_NonStereoScreenPos_Delta = _raycast_end_NonStereoScreenPos.xyw - input.Varying_NotNormaizeScreenPosXYW.xyw;
                
                float _raycast_hit_at_step = 0.0;

                // value.rg = NormalizeScreenPos(input.Varying_NotNormaizeScreenPosXYW.xyw);
                // ���Կ������շ������Ļ����������������Ƿ��쳣��������� w <0 �����·���
                value.rg = NormalizeScreenPos(_raycast_end_NonStereoScreenPos.xyw) - NormalizeScreenPos(input.Varying_NotNormaizeScreenPosXYW.xyw);
                
                // Linear Tracing Method 8 step,
                value.rgb *= 0;
                for (int i = 0; i < Linear_Tracing_MAX_STEP; i++) {
                    int currentStepInt = i+1;
                    // float currentStepInt = i+0.5;
                    float currentStep01 = float(currentStepInt)/float(Linear_Tracing_MAX_STEP);
                    
                    float3 currentNonStereoScreenPos = _raycast_step_NonStereoScreenPos_Delta * currentStep01 + input.Varying_NotNormaizeScreenPosXYW.xyw;
                    float2 currentScreenPos = NormalizeScreenPos( currentNonStereoScreenPos );
                    // �ȼ��ڣ�
                    // ��ԭ�� glsl ���� currentNonStereoScreenPos.z (��clippos.w) ��Ϊ surface eye depth �Ƚϣ��༭�������� ??
                    // float3 currentViewPos = TransformWorldToView(reflectDir * Linear_Tracing_AMOUNT_LENGTH * currentStep01 + input.Varying_worldPos.xyz);
                    // float3 currentNonStereoScreenPos = ComputeNonStereoScreenPos(TransformWViewToHClip(currentViewPos)).xyw;
                    // float2 currentScreenPos = NormalizeScreenPos( currentNonStereoScreenPos );

                    // ע��ԭ��������ͼ�Ѿ�Ԥ���� Linear01Depth����������Դ��û�� Linear01Depth
                    float currentSampleEyeDepth = Linear01Depth(SampleSceneDepth(currentScreenPos).x) * _ProjectionParams.z;
                    float _WDistanceToSampleDepth = currentNonStereoScreenPos.z - currentSampleEyeDepth;
                    // ׼ȷ�� surface eye depth Ӧ���� -currentViewPos.z ??�������� currentNonStereoScreenPos.z (��clippos.w) ??
                    // float _WDistanceToSampleDepth = -currentViewPos.z - currentSampleEyeDepth;
                    bool _bCloseToSampleDepth = abs(_WDistanceToSampleDepth) < 3.1875;

                    
                    
                    // raycast �ɹ�
                    if (_bCloseToSampleDepth) {
                        _raycast_hit_at_step = float(currentStepInt);
                        // value.rgb = float3(1,1,1);
                        // value.rg = currentScreenPos - NormalizeScreenPos(input.Varying_NotNormaizeScreenPosXYW.xyw);
                        break;
                    }
                }

                // value.rgb = reflectDir.rgb;
                //value.rg = NormalizeScreenPos(input.Varying_NotNormaizeScreenPosXYW.xyw);

            bool _bAnyExistCloseToSampleDepth = _raycast_hit_at_step > 0.0;

            float3 _one_step_delta = _raycast_step_NonStereoScreenPos_Delta / Linear_Tracing_MAX_STEP;


            // 2. Ԥ׼�� û�� raycast �ɹ�������
                // #define _reflectInfiniteDistanceX_and_AlphaY float4(129.00, 1.00, 0.00, 0.00)
                float3 _reflectInfinitePos = (reflectDir * _reflectInfiniteDistanceX_and_AlphaY.x) + input.Varying_worldPos.xyz;

                float4 _InfiniteClipPos = TransformWorldToHClip(_reflectInfinitePos);

                // float2 _InfiniteScreenPos = (_InfiniteClipPos.ww*0.5 + _InfiniteClipPos.xy*0.5) / _InfiniteClipPos.ww;
                float2 _InfiniteScreenPos = NormalizeScreenPos(ComputeNonStereoScreenPos(_InfiniteClipPos).xyw) ;

                // ע��ԭ��������ͼ�Ѿ�Ԥ���� Linear01Depth����������Դ��û�� Linear01Depth
                float _InfiniteActualEyeDepth = Linear01Depth(SampleSceneDepth(_InfiniteScreenPos).x) * _ProjectionParams.z;


                bool _bInfinitePosIsActualMoreDepthThanHere = _InfiniteActualEyeDepth > input.Varying_NotNormaizeScreenPosXYW.w;

                float _fadeToScreenEdge = CalcFadeToScreenEdge(_InfiniteScreenPos);

                // #define _InfiniteScreenPos_ST float4(1.47305, 0.82843, -0.73652, -0.41421)
                // scale small, 0~1  ->  -0.736 ~ 0.736  ,  -0.414 ~ 0.414
                // 1.47305:0.82843 == 16/9
                // ������Ļ���Ľ�һ��ģ�������
                float2 _InfiniteAdjustClipPos_XY = (_InfiniteScreenPos * _InfiniteScreenPos_ST.xy) + _InfiniteScreenPos_ST.zw;

                float3 _InfiniteAdjustViewPos = float3( _InfiniteActualEyeDepth * _InfiniteAdjustClipPos_XY, -_InfiniteActualEyeDepth );

                float3 _InfiniteActualAdjustWorldPos = mul(UNITY_MATRIX_I_V, float4(_InfiniteAdjustViewPos, 1)).xyz;

                float3 _WorldSpaceHereToActualInfiniteVector = _InfiniteActualAdjustWorldPos - input.Varying_worldPos.xyz;
                
                // ���Ӱ�첻��   
                // ���ⷴ����ڽӽ����ء��ӽ�ˮ�������
                float _WorldNDotInfiniteDir = dot(input.Varying_WorldNormal, _WorldSpaceHereToActualInfiniteVector);

                _WorldNDotInfiniteDir = clamp(_WorldNDotInfiniteDir + 1.0, 0.1, 1.0);

                // ����Զ�ĵط������ȱȵ�ǰ���ػ�����˵����Ӧ�÷��������������ͷ�����ݡ�
                float _fadeToScreenEdgeNoDepthMoreFade = ( _bInfinitePosIsActualMoreDepthThanHere ? 1.0 : 0.01 ) * _fadeToScreenEdge;


            // 3. ���� _reflectColorRGBA
            float4 _reflectColorRGBA;
                if (_bAnyExistCloseToSampleDepth)
                {
                    float3 _raycast_hit_NotNormalizeScreenPosXYW = _raycast_hit_at_step * _one_step_delta + input.Varying_NotNormaizeScreenPosXYW.xyw;
                
                    float2 _raycast_hit_ScreenPos = NormalizeScreenPos(_raycast_hit_NotNormalizeScreenPosXYW);
                
                    _fadeToScreenEdge = CalcFadeToScreenEdge(_raycast_hit_ScreenPos);
                
                    _reflectColorRGBA.rgb = SampleSceneColor(_raycast_hit_ScreenPos).xyz ;
                
                    // ԭ�������� + ����������ʱ���ֵ�ͷ�����Ӱ���ĳ� * �� ??
                    // ��Ҫ�ض��ǶȲ��ܿ�������Ӱ���������ʱ�����û� + ������֤ raycast �ɹ�ʱ���ܿ��������ĵ�Ӱ��
                    // _reflectColorRGBA.a = (_fadeToScreenEdgeNoDepthMoreFade * _WorldNDotInfiniteDir) + _fadeToScreenEdge;
                    _reflectColorRGBA.a = (_fadeToScreenEdgeNoDepthMoreFade * _WorldNDotInfiniteDir) + _fadeToScreenEdge;
                    
                    // _reflectColorRGBA.rgb = float3(1, 0, 0);
                
                }
                else
                {
                    _reflectColorRGBA.rgb = SampleSceneColor(_InfiniteScreenPos).xyz;
                    _reflectColorRGBA.a = _WorldNDotInfiniteDir * _fadeToScreenEdgeNoDepthMoreFade;
                    
                    // _reflectColorRGBA.rgb = float3(0, 0, 0);
                }

                float4 Output_1;
                float4 Output_2;
                // #define _reflectInfiniteDistanceX_and_AlphaY float4(129.00, 1.00, 0.00, 0.00)
                float4 _reflectColorAdjust = _reflectColorRGBA * _reflectInfiniteDistanceX_and_AlphaY.y;
                Output_1.xyz = _reflectColorAdjust.xyz;

                bool _bReflectColorAlphaNearlyZero = _reflectColorAdjust.w < 0.02;
                bool _meshEyeDepthLess7 = input.Varying_NotNormaizeScreenPosXYW.w < 7.0;
                bool _bNearlyFadeoutFromScreen = _fadeToScreenEdge < 0.01;

                // ��Ļ�߱ߣ������������alpha�ӽ�0�ģ�ֱ�� alpha ����Ϊ0
                bool _bNoReflect = _bNearlyFadeoutFromScreen || (_meshEyeDepthLess7 && _bReflectColorAlphaNearlyZero);
                Output_1.w = _bNoReflect ? 0.0 : _reflectColorAdjust.w;
                Output_1.a = saturate(Output_1.a);
                // Output_1.a = saturate(_reflectColorAdjust.w);

                // Output_1.a *= saturate((0.4 - dot(viewDir_normalize, input.Varying_WorldNormal))*20.0);
                
                // Output_1.a = saturate(1);

            // 4. ���� ͸��color��ֱ�Ӿ���ץ��
                Output_2.xyz = SampleSceneColor(NormalizeScreenPos(input.Varying_NotNormaizeScreenPosXYW.xyw)).xyz;
                Output_2.w = 1.0;
                
                float4 col = 0;
                
                col = Output_1;
                // col.rg = _InfiniteScreenPos.xy;
                // col.rg = NormalizeScreenPos(input.Varying_NotNormaizeScreenPosXYW.xyw);
                // col.a = 1.0;

                // return value;
                return col;
            }
            ENDHLSL
        }
    }
}
