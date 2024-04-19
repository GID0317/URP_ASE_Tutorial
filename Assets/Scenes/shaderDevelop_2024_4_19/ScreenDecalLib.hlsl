#ifndef SCREEN_DECAL_LIB_INCLUDED
#define SCREEN_DECAL_LIB_INCLUDED

// viewRay.w �� surfEyeDepth
void VertexViewRayParams(in float3 pos, out float4 viewRay, out float3 viewRayStartPos)
{
	float4x4 ViewToObjectMatrix = mul(GetWorldToObjectMatrix(), UNITY_MATRIX_I_V);
    float3 _viewPos = TransformWorldToView(TransformObjectToWorld(pos)); 
    viewRay.w = -_viewPos.z; 
    viewRay.xyz = unity_OrthoParams.w > 0 ? mul((float3x3)ViewToObjectMatrix, float3(0, 0, _viewPos.z)): mul((float3x3)ViewToObjectMatrix, _viewPos.xyz); 
    viewRayStartPos.xyz = unity_OrthoParams.w > 0 ? mul(ViewToObjectMatrix, float4(_viewPos.xy, 0, 1)).xyz : mul(ViewToObjectMatrix, float4(0,0,0,1)).xyz ;
}

float4x4 _WorldToLocalMatrix;
// viewRay.w �� surfEyeDepth
// ע particle system �� UNITY_MATRIX_M ����ת����û�����ţ���һ����λ��
void VertexViewRayParams(in float3 vertexPos, in float3 centerPos, in float3 sizeXYZ, in float3 rotation3D, out float4 viewRay, out float3 viewRayStartPos)
{
	float4x4 _meshPreRS_matrix_inv = _WorldToLocalMatrix;

	// ��������ʱ��Ԥ������ transform �� Rotation Scale Ԥ�Ȱ� Mesh ����������ת���ٰ� rotation3D sizeXYZ centerPos ���֡�
	// ����Ԥ�ȵ� Rotation Scale ����Ϊ _meshPreRS_matrix, _meshPreRS_matrix ���� (float3x3)_LocalToWorldMatrix
	// ������ _meshPreRS_matrix_inv ���� (float3x3)_WorldToLocalMatrix
	// _meshPreRS_matrix_inv ֻ����ת�����ţ�û��λ��
	_meshPreRS_matrix_inv._m03_m13_m23 = 0;

	// scale
	float4x4 S_Inv = {
	    rcp(sizeXYZ.x), 0, 0, 0,
	    0, rcp(sizeXYZ.y), 0, 0,
	    0, 0, rcp(sizeXYZ.z), 0,
	    0, 0, 0, 1
	};

	// position
	float4x4 T_Inv = {
	    1, 0, 0, -centerPos.x,
	    0, 1, 0, -centerPos.y,
	    0, 0, 1, -centerPos.z,
	    0, 0, 0, 1,
	};

	// rotation z
	float4x4 Rz_Inv = {
	    cos(-rotation3D.z), sin(-rotation3D.z), 0, 0,
	    - sin(-rotation3D.z), cos(-rotation3D.z), 0, 0,
	    0, 0, 1, 0,
	    0, 0, 0, 1
	};
	
	// rotation x
	float4x4 Rx_Inv = {
	    1, 0, 0, 0,
	    0, cos(-rotation3D.x), -sin(-rotation3D.x), 0,
	    0, sin(-rotation3D.x), cos(-rotation3D.x), 0,
	    0, 0, 0, 1
	};
	
	// rotation y
	float4x4 Ry_Inv = {
	    cos(-rotation3D.y), 0, sin(-rotation3D.y), 0,
	    0, 1, 0, 0,
	    - sin(-rotation3D.y), 0, cos(-rotation3D.y), 0,
	    0, 0, 0, 1
	};
	
	// ��Ϊ TRS = T * Ry * Rx * Rz * S
	// ���� TRS_Inv = S_Inv * Rz_Inv * Ry_Inv * Rx_Inv * T_Inv;
	float4x4 _worldToParticleIgnoreMeshPreRS_matrix;
	_worldToParticleIgnoreMeshPreRS_matrix = mul(S_Inv, mul(Rz_Inv, mul(Ry_Inv, mul(Rx_Inv, T_Inv))));
	
	// ���Ͽ�����任 Mesh Ԥ�ȵ� Rotation Scale����׷����� _particlePreRS_matrix_inv
	float4x4 _worldToMesh_matrix = mul(_meshPreRS_matrix_inv, _worldToParticleIgnoreMeshPreRS_matrix);
	// _worldToMesh_matrix = _worldToParticleIgnoreMeshPreRS_matrix;
	// _worldToPartical_matrix =_worldToObject_matrix;
	
	float4x4 ViewToObjectMatrix = mul(_worldToMesh_matrix, UNITY_MATRIX_I_V);
    float3 _viewPos = TransformWorldToView(TransformObjectToWorld(vertexPos)); 
    viewRay.w = -_viewPos.z; 
    viewRay.xyz = unity_OrthoParams.w > 0 ? mul((float3x3)ViewToObjectMatrix, float3(0, 0, _viewPos.z)): mul((float3x3)ViewToObjectMatrix, _viewPos.xyz); 
    viewRayStartPos.xyz = unity_OrthoParams.w > 0 ? mul(ViewToObjectMatrix, float4(_viewPos.xy, 0, 1)).xyz : mul(ViewToObjectMatrix, float4(0,0,0,1)).xyz ;
}

float LinearEyeDepthPerspOrOrtho(float rawDepth)
{
	float persp = LinearEyeDepth(rawDepth, _ZBufferParams); 
    float ortho = (_ProjectionParams.z-_ProjectionParams.y)*(1-rawDepth)+_ProjectionParams.y; 
    float _linearEyeDepth = unity_OrthoParams.w > 0 ? ortho : persp; 
	return _linearEyeDepth;
}

#endif