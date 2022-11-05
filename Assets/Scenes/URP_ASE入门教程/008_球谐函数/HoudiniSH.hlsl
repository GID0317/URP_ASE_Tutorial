#ifndef XUE_HOUDINI_SH_INCLUDED
#define XUE_HOUDINI_SH_INCLUDED


// �����https://catlikecoding.com/unity/tutorials/rendering/part-5/
// Spherical Harmonics Bands ����
// l0, l1, l2 �Ȳ����Ѿ�Ԥ��������������
half HoudiniSpaceShadeSH9(half3 direction, half4 l0l1, half4 l2_1stTo4th, half l2_5th)
{
    // l0l1.x   Ϊ l0 �� Y0_0
    // l0l1.yzw Ϊ l1 �� Y1_-1, Y1_0, Y1_1
    half3 l0l1result = dot(direction.yzx, l0l1.yzw) + l0l1.x;

    half x1, x2;
    // 4 of the quadratic (L2) polynomials
    half4 vB = direction.xyzz * direction.yzzx;
    x1 = dot(l2_1stTo4th, vB);

    // Final (5th) quadratic (L2) polynomial
    half vC = direction.x*direction.x - direction.y*direction.y;
    x2 = l2_5th * vC;
    
    return l0l1result + x1 + x2;
}

/**
 * direction Ϊ��һ������
 * l0, l1, l2 �Ȳ�����Ԥ���˳����Ĳ���
 * ���� l2 �� Y2_0 ��Ԥ�������
 *   https://catlikecoding.com/unity/tutorials/rendering/part-5/
 *   Spherical Harmonics Bands ����
 */
half UnitySpaceShadeSH9(half3 direction, half4 l0l1, half4 l2_1stTo4th, half l2_5th )
{
    // ���˵�������Ҫ��������
    // half3 houdiniDirection = half3(-direction.x, -direction.z, direction.y);
    
    // houdini �м���sh������
    //   ����(��) 0~�� ��Ӧ +Z -> -Z��
    //   ��λ��(��) 0~2�� ��Ӧ -X -> +Y -> +X -> -Y -> -X��
    // ��ӦUnity��
    //    ����(��) 0~�� ��Ӧ +Z -> -Z��
    //    ��λ��(��) 0~2�� ��Ӧ +X -> +Y -> -X -> -Y -> +X��
    // ��Unity��sh��������漰�� ��, �� ������ѧ����������ѿ��������Ӧ��ϵ��
    // ����ֱ��ʹ��ֱ������ϵ���ʽ����г����
    // ֱ�������еı��ʽ�ο���https://zh.wikipedia.org/wiki/%E7%90%83%E8%B0%90%E5%87%BD%E6%95%B0
    
    return HoudiniSpaceShadeSH9(direction, l0l1, l2_1stTo4th, l2_5th);
}



#endif