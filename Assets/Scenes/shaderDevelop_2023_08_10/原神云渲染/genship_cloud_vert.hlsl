#include "genship_cloud_common.hlsl"

// #define _ProjectionParams float4(1.00, 0.25, 6000.68506, 0.00017) // _58._m0
// #define UNITY_MATRIX_M _58._m1
// static const matrix UNITY_MATRIX_M = {
//     float4(1.00, 0.00, 0.00, 0.00),
//     float4(0.00, 1.00, 0.00, 0.00),
//     float4(0.00, 0.00, 1.00, 0.00),
//     float4(0.00, 0.00, 0.00, 1.00)
// }; // _58._m1
// #define transpose(UNITY_MATRIX_VP) _58._m2
// UNITY_MARRIX_V
// UNITY_MATRIX_VP
// static const matrix transpose(UNITY_MATRIX_VP) = {
//     float4(-1.11146, 1.95758E-08, 0.57462, 0.57457         ),
//     float4(5.51985E-09, 2.41421, -8.32307E-09, -8.32238E-09),
//     float4(-0.78026, -1.08062E-08, -0.81853, -0.81846      ),
//     float4(-1.93807, -1207.10669, 3.5313, 4.03098          )
// }; //_58._m2
#define _RolePos_maybe  float3(-3.48413, 195.00, 2.47919) // _58._m3
#define _UpDir  float3(0.00, 1.00, 0.00         ) // _58._m4
#define _SkyColorCenter  float3(0.00972, 0.02298, 0.06016) // _58._m5
#define _SkyColorAround  float3(0.00972, 0.02298, 0.06016) // _58._m6
#define _SunColorCenter  float3(0.0538, 0.09841, 0.2073  ) // _58._m7
#define _SunColorAround  float3(0.0538, 0.09841, 0.2073  ) // _58._m8
#define _LDotDir_n11_RemapDownAt0_A  0.49336  // _58._m9
#define _IrradianceMapR_maxAngleRange 0.20     // _58._m10
#define _IrradianceMapG_Color float3(0.00837, 0.10516, 0.26225) // _58._m11
#define _IrradianceMapG_Intensity 0.50 // _58._m12
#define _IrradianceMapG_maxAngleRange 0.30 // _58._m13
#define _lightDir_maybe float3(0.00688, -0.84638, -0.53253) // _58._m14
#define _58__m15 float3(0.01938, 0.00651, 0.02122  ) // _58._m15
#define _58__m16 4.09789 // _58._m16
#define _58__m17 0.80205 // _58._m17
#define _58__m18 8.30078 // _58._m18
#define _58__m19 float3(0.01938, 0.00651, 0.02122) // _58._m19
#define _58__m20 0.01039 // _58._m20
#define _58__m21 float3(0.31638, 0.70655, 0.633) // _58._m21
#define _58__m22 float3(0.29669, 0.64985, 1.00 ) // _58._m22
#define _58__m23 3.29897 // _58._m23
#define _58__m24 0.19794 // _58._m24
#define _58__m25 0.50    // _58._m25
#define _DisturbanceNoiseOffset2 262.33862 // _58._m26
// uniform float _58__m26;
#define _58__m27 float3(0.05199, 0.10301, 0.13598) // _58._m27
#define _58__m28 float3(0.10391, 0.41824, 0.88688) // _58._m28
#define _58__m29 float3(0.00, 0.03576, 0.12083   ) // _58._m29
#define _58__m30 float3(0.02281, 0.05716, 0.14666) // _58._m30
#define _LDotDir_n11_RemapDownAt0_B 0.0881      // _58._m31
#define _58__m32 0.11        // _58._m32
#define _58__m33 1.00        // _58._m33
#define _58__m34 0.8299      // _58._m34
#define _MaskMapGridSize float2( 2.00, 4.00 ) // _58._m35
// float2 _MaskMapGridSize;
#define _DisturbanceNoiseScale 3.00        // _58._m36
#define _DisturbanceNoiseOffset 6.00        // _58._m37
// uniform float _DisturbanceNoiseS;
// uniform float _58__m37;
#define _58__m38 1.00        // _58._m38

sampler2D _IrradianceMap;

float FastAcosForAbsCos(float in_abs_cos) {
    float _local_tmp = ((in_abs_cos * -0.0187292993068695068359375 + 0.074261002242565155029296875) * in_abs_cos - 0.212114393711090087890625) * in_abs_cos + 1.570728778839111328125;
    return _local_tmp * sqrt(1.0 - in_abs_cos);
}

float FastAcos(float in_cos) {
    float local_abs_cos = abs(in_cos);
    float local_abs_acos = FastAcosForAbsCos(local_abs_cos);
    return in_cos < 0.0 ?  UNITY_PI - local_abs_acos : local_abs_acos;
}

v2f vert (appdata v)
{

    float4 Vertex_Position = v.vertex;

    // Vertex_1.y = {0, 0.28235, 0.42745, 0.56863, 0.8549, 1.0}
    float4 Vertex_GridIndexY_ = v.color;
    
    float4 Vertex_uv = float4( v.uv, 0,0 ) ;
    
    // Vertex_DensityParamsXYZW.x = 104.096           |  171.435
    // Vertex_DensityParamsXYZW.y = 4.70795 ~ 102.966 |  17.8982 ~ 153.264

    // Vertex_DensityParamsXYZW.y / Vertex_DensityParamsXYZW.x = {0.04, 0.12 0.13, 0.15, 0.23, 0.25, 0.37, 0.42, 0.49, 0.52, 0.53, ..., 0.989}
    
    // Vertex_DensityParamsXYZW.z = 0.4
    // Vertex_DensityParamsXYZW.w = 0.6
    float4 Vertex_DensityParamsXYZW = fixed4( v.uv2, v.uv3 );
    v2f o;
    

    
    
    // float2 _29;

    float3 _35;
    float3 _36;
    float3 _37;
    float _39;

    float3 _41;


    // float2 _44;
    float _45;
    float _46;

    float _miu;

    float _50;
    float _51;
    // float _52;
    

    float4 _WorldPos = mul(UNITY_MATRIX_M, Vertex_Position);
    float4 _clipPos = mul(UNITY_MATRIX_VP, _WorldPos);
    _clipPos.z = _clipPos.w;
    o.vertex = _clipPos;



    // #define _RolePos_maybe  float3(-3.48413, 195.00, 2.47919) // _58._m3
    float3 _worldPos_relativeToRole = _WorldPos.xyz - _RolePos_maybe;
    
    float3 _relativeToRoleDir = normalize(_worldPos_relativeToRole);

    float _rawUpDotDir = dot(_UpDir, _relativeToRoleDir);
    _miu = clamp(_rawUpDotDir, -1.0, 1.0);

    // (1.57079632679 - acos(x)) * 0.636619772367
    float _angle_up_to_down_1_n1 = (UNITY_HALF_PI - FastAcos(_miu)) * UNITY_INV_HALF_PI;

    o.Varying_RelativeToRoleDirXYZ_Angle1_n1.w = _angle_up_to_down_1_n1;
    o.Varying_RelativeToRoleDirXYZ_Angle1_n1.xyz = _relativeToRoleDir;
    


    
    {
        // #define _MaskMapGridSize float2( 2.00, 4.00 ) // _58._m35
        // ���Է��֣�_MaskMapGridSize.x < 0 ʱ��Ҫ�ĳ� +1, _MaskMapGridSize.x < 0 ������ȷ�����ҷ�תЧ��
        // ԭ������� -1.0
        float _gridIndex_0_7;
        _gridIndex_0_7 = _MaskMapGridSize.x * _MaskMapGridSize.y + (_MaskMapGridSize.x >= 0 ? -1.0 : +1.0); // 7

        // Vertex_1.y         = {0,     0.28235, 0.42745, 0.56863, 0.8549, 1.0}
        // Vertex_1.y * 7     = {0,     1.97645, 2.99215, 3.98041, 5.9843, 7.0}
        // floor(_gridIndex_0_7 + 0.5)  = {0,     2,       3,       4,       6,      7}
        _gridIndex_0_7 = (Vertex_GridIndexY_.y * _gridIndex_0_7); // 0~7
        _gridIndex_0_7 = floor(_gridIndex_0_7 + 0.5);
        
        
        float _gridSizeX = abs(_MaskMapGridSize.x);
        float _gridIndex_x = frac(_gridIndex_0_7 / _gridSizeX) * _gridSizeX;
        
        float _gridIndex_y = floor(_gridIndex_0_7 / _MaskMapGridSize.x);

        float2 _gridRootIntUVAtLeftDown = float2(_gridIndex_x, _gridIndex_y);

        float2 _gridUVStartAtLeftDown = _gridRootIntUVAtLeftDown + Vertex_uv.xy;

        o.Varying_MaskMapUvXY_DisturbanceNoiseUvZW.xy = _gridUVStartAtLeftDown/_MaskMapGridSize;
    }
    
    // #define _58__m26 262.33862 // _58._m26
    // #define _58__m37 6.00        // _58._m37
    // #define _58__m36 3.00        // _58._m36
    o.Varying_MaskMapUvXY_DisturbanceNoiseUvZW.zw = Vertex_uv.xy * _DisturbanceNoiseScale + float2(1.2, 0.8) * _DisturbanceNoiseOffset2 * _DisturbanceNoiseOffset;
    
    
    // #define _lightDir_maybe float3(0.00688, -0.84638, -0.53253) // _58._m14
    float _LDotDir = dot(_relativeToRoleDir, _lightDir_maybe);
    float _LDotDirRemap01 = _LDotDir * 0.5 + 0.5;

    // #define _58__m34 0.8299      // _58._m34
    o.Varying_DesityRefW_ColorzwYZ_LDotDir01FixX.x = _LDotDirRemap01 * _58__m34;

    o.Varying_DesityRefW_ColorzwYZ_LDotDir01FixX.yz = Vertex_GridIndexY_.zw;
    
    // #define _58__m33 1.00        // _58._m33
    // #define _58__m38 1.00        // _58._m38
    float _Vertex_y_present_fix = Vertex_DensityParamsXYZW.y / max(Vertex_DensityParamsXYZW.x, 1.0e-05) * _58__m33 * _58__m38;

    // 1.0 - smoothstep(0, 0.4, x) * (1.0 - smoothstep(0.6, 1.0, x))
    // o.Varying_2.w �� _Vertex_y_present_fix 01 ӳ�䵽 1 \ 0 / 1 ��ƽ��ͼ�������� 0.4 ���ﵽ���λ 0, 0.6 ���뿪���λ 0
    o.Varying_DesityRefW_ColorzwYZ_LDotDir01FixX.w = 1.0 - smoothstep(0, Vertex_DensityParamsXYZW.z, _Vertex_y_present_fix) * (1.0 - smoothstep(Vertex_DensityParamsXYZW.w, 1.0, _Vertex_y_present_fix));
    
    // #define _IrradianceMapR_maxAngleRange 0.20     // _58._m10
    // _irradianceMapR ������� 0 �ȵģ����ұ��� 0.2*90��=18�� �ģ���ֻ��¼ˮƽ�����ֵ�����ߣ����͵�ֵ���� 18�� ��ֵ��
    float2 _irradianceMap_R_uv;
        _irradianceMap_R_uv.x = abs(_angle_up_to_down_1_n1) / max(_IrradianceMapR_maxAngleRange, 1.0e-04);
        _irradianceMap_R_uv.y = 0.5;
    

    float _irradianceMapR = tex2Dlod(_IrradianceMap, float4(_irradianceMap_R_uv, 0.0, 0.0)).x;
    

    // #define _LDotDir_n11_RemapDownAt0_A  0.49336  // _58._m9
    // #define _LDotDir_n11_RemapDownAt0_B 0.0881      // _58._m31
    // ��˼��һ��ֱ�� y = 1
    //    ���� (1, 1) �㣬�� x=0 ������ѹ����� �� 0.8���Ǿͱ�� 0~1 remap �� 0.2~1
    // �������ֵ������ pow(, 3) �����㣬������ 0 �����½���ֻ�нӽ� 1 ����ֵ������ sunDisk ��ʵ��


    float _LDotDirRemapA = _LDotDir * _LDotDir_n11_RemapDownAt0_A + (-_LDotDir_n11_RemapDownAt0_A) + 1.0;
    float _LDotDirRemapB = _LDotDir * _LDotDir_n11_RemapDownAt0_B + (-_LDotDir_n11_RemapDownAt0_B) + 1.0;
    _LDotDirRemapA = max(_LDotDirRemapA, 0);
    _LDotDirRemapB = max(_LDotDirRemapB, 0);

    float _LDotDirRemapA_pow3 = _LDotDirRemapA * _LDotDirRemapA * _LDotDirRemapA;
    // #define _SunColorCenter  float3(0.0538, 0.09841, 0.2073  ) // _58._m7
    // #define _SunColorAround  float3(0.0538, 0.09841, 0.2073  ) // _58._m8
    // _sunColor ����ָ _irradianceMapR Ϊ 1 ����ɫ�����ܲ��� sun
    float3 _sunColor = lerp(_SunColorAround, _SunColorCenter, _LDotDirRemapA_pow3);
    
    // #define _SkyColorCenter  float3(0.00972, 0.02298, 0.06016) // _58._m5
    // #define _SkyColorAround  float3(0.00972, 0.02298, 0.06016) // _58._m6
    // _skyColor ����ָ _irradianceMapR Ϊ 0 ����ɫ��������մ�����ɫ sky ����
    float3 _skyColor = lerp(_SkyColorAround, _SkyColorCenter, _LDotDirRemapA_pow3);

    float3 _irradianceRColor = lerp( _skyColor, _sunColor, _irradianceMapR );

    float2 _irradianceMap_G_uv;
    // #define _IrradianceMapG_maxAngleRange 0.30 // _58._m13
    // _irradianceMapR ������� 0 �ȵģ����ұ��� 0.3*90��=27�� �ģ���ֻ��¼ˮƽ�����ֵ�����ߣ����͵�ֵ���� 27�� ��ֵ��
        _irradianceMap_G_uv.x = abs(_angle_up_to_down_1_n1) / max(_IrradianceMapG_maxAngleRange, 1.0e-04);
        _irradianceMap_G_uv.y = 0.5;

    float _irradianceMapG = tex2Dlod(_IrradianceMap, float4(_irradianceMap_G_uv, 0.0, 0.0)).y;

    // #define _IrradianceMapG_Color float3(0.00837, 0.10516, 0.26225) // _58._m11
    // #define _IrradianceMapG_Intensity 0.50 // _58._m12
    float3 _irradianceMapGColor = _irradianceMapG * _IrradianceMapG_Color * _IrradianceMapG_Intensity;

        // float smoothstep(float t1, float t2, float x) {
        //   x = clamp((x - t1) / (t2 - t1), 0.0, 1.0); 
        //   return x * x * (3 - 2 * x);
        // }

    // smoothstep(0, 1, clamp( (abs(x)-0.2) * 10/3, 0, 1))
    // �� 0.2 ���뿪0��ƽ��������0.5 ����ʼ�ﵽ��� 1.0 
    float _lightDirY_remap_smooth01 = smoothstep(0, 1, clamp( (abs(_lightDir_maybe.y) - 0.2) * 10/3, 0, 1 ));
    
    // smoothstep(0, 1, max((clamp(x, 0.0, 1.0)-1)/0.7 + 1, 0.0))
    // y=x ֱ�ߣ��̶� (1, 1) �㲻������ת��ʹ��б�ʱ�� 1/0.7������˥������ smooth
    float _LDotDir_01_remapFade_smooth = smoothstep(0, 1, max((clamp(_LDotDirRemap01, 0.0, 1.0)-1)/0.7 + 1, 0.0));

    // ��˼�������жϸ߶ȣ��ߵĵط����ǹ̶� _irradianceMapGColor
    //       lightDirY > 0.5 ���� _irradianceMapGColor
    //       lightDirY < 0.2 ���� _LDotDir_01_remapFade_smooth * _irradianceMapGColor
    // 
    // ����ж� _LDotDir 
    float _LDotDirFinalRemap = lerp(_LDotDir_01_remapFade_smooth, 1.0, _lightDirY_remap_smooth01);
    
    float3 _sumIrradianceRGColor = _irradianceMapGColor * _LDotDirFinalRemap + _irradianceRColor;
    // _36 = _sumIrradianceRGColor;
    
float _47;
    // _47 = dot(_relativeToRoleDir, _UpDir);
    // _47 = _rawUpDotDir;
    _35.x = abs(_rawUpDotDir) * _58__m18;
float4 _33;
    // _33.x = dot(_lightDir_maybe, _relativeToRoleDir);
    // _33.x = _LDotDir;
    // _33.x = (_33.x * 0.5) + 0.5;
    // _33.x = _LDotDirRemap01;
    _33.x = clamp(_LDotDirRemap01, 0.0, 1.0);
    
    _41.x = log2(_33.x);
    _45 = _41.x * _35.x;
    _37 = _35.xxx * float3(0.1, 0.01, 0.5);
    float2 _750 = _41.xx * _37.xy;
    _41 = float3(_750.x, _41.y, _750.y);
    float2 _755 = exp2(_41.xz);
    _41 = float3(_755.x, _41.y, _755.y);
    _41.y = exp2(_45);
    _41 = min(_41, (1.0));
    _41.x = (_41.x * 0.119999997317790985107421875) + _41.y;
    _41.x = (_41.z * 0.02999999932944774627685546875) + _41.x;
    _41.x *= _58__m20;
    _41 = _41.xxx * _58__m19;
    _39 = _33.x + (-0.5);
    _35.x = log2(_33.x);
    _35.x *= _37.z;
    _35.x = exp2(_35.x);
    _35.x = _rawUpDotDir * _35.x;
    _35.x = clamp(_35.x, 0.0, 1.0);
    _35.x *= _58__m20;
    _37 = _35.xxx * _58__m15;
    _47 = _39 + _39;
    _47 = max(_47, 0.0);
    _33.x = (_47 * (-2.0)) + 3.0;
    _47 *= _47;
    _47 *= _33.x;
    float3 _853 = (_41 * (_47)) + _sumIrradianceRGColor;
    _33 = float4(_853.x, _853.y, _853.z, _33.w);
    o.Varying_3 = _33.xyz;
    _47 = dot(_58__m21, _relativeToRoleDir);
    _47 = clamp(_47, 0.0, 1.0);
    _35.x = dot(_relativeToRoleDir, _58__m21);
    _35.x = (_35.x * 0.5) + 0.5;
    float2 _886 = _35.xz + (-float2(_58__m17, _58__m17));
    _35 = float3(_886.x, _35.y, _886.y);
    _50 = _47 * _47;
    _50 = _47 * _50;
    _50 = _47 * _50;
    _50 = (_50 * _47) + (-0.5);
    _50 += _50;
    _50 = max(_50, 0.0);
    _36.x = (_50 * (-2.0)) + 3.0;
    _50 *= _50;
    _50 *= _36.x;
    _50 *= _58__m24;
    _36.x = _58__m25 + (-0.5);
    _36.x = ((-abs(_36.x)) * 2.0) + 1.0;
    _50 *= _36.x;
    _36 = (_50) * _58__m22;
    _50 = max(_58__m23, 0.0);
    _50 = min(_50, 0.800000011920928955078125);
    _36 = (_36 * (_50)) + _37;
    _50 = (-_58__m32) + 0.699999988079071044921875;
    _50 *= 2.5000002384185791015625;
    _50 = clamp(_50, 0.0, 1.0);
    _51 = (_50 * (-2.0)) + 3.0;
    _50 *= _50;
    _50 *= _51;
    o.Varying_4 = (_50) * _36;
    _36.x = (-_58__m17) + 1.0;
    _36.x = 1.0 / _36.x;
    float2 _995 = _35.xz * _36.xx;
    _35 = float3(_995.x, _35.y, _995.y);
    float2 _1000 = clamp(_35.xz, (0.0), (1.0));
    _35 = float3(_1000.x, _35.y, _1000.y);
    _36.x = (_35.x * (-2.0)) + 3.0;
    _35.x *= _35.x;
    _35.x *= _36.x;
    _35.x *= _58__m23;
    _35.x *= 0.100000001490116119384765625;
    _35.x *= _35.x;
    _36 = _35.xxx * _58__m22;
    _35.x = (_LDotDirRemap01 * (-2.0)) + 3.0;
    _46 = _LDotDirRemap01 * _LDotDirRemap01;
    _35.x = _46 * _35.x;
    _35.x *= _58__m16;
    _35.x *= 0.125;
    _35.x *= _35.x;
    _36 = (_58__m19 * _35.xxx) + _36;
    o.Varying_5 = (_50) * _36;
    // _35.x = _LDotDirRemapB * _LDotDirRemapB;
    _35.x = _LDotDirRemapB * _LDotDirRemapB * _LDotDirRemapB;
float3 _42;
    _42 = _58__m27 + (-_58__m28);
    o.Varying_6 = (_35.xxx * _42) + _58__m28;
    _42 = _58__m29 + (-_58__m30);
    o.Varying_7 = (_35.xxx * _42) + _58__m30;
    
    return o;
}