Shader "Hidden/BT-ScreenSpaceShadows"
{
	Properties
	{
		_ShadowMapTexture ("_ShadowMapTexture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "ShadowmapFilter"="HardShadow" }
		Pass
		{
			Blend One Zero
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ SHADOWS_SINGLE_CASCADE
			#pragma multi_compile _ SHADOWS_SPLIT_SPHERES
			#pragma multi_compile _ _BT_SIM_GAME
			#pragma multi_compile _ _BT_SUNLIGHT_CONTROL

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;
Texture2D _ShadowMapTexture;
SamplerComparisonState sampler_ShadowMapTexture;


struct appdata
{
	float4 position0 : POSITION0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#else
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#endif

struct fout
{
	float4 t0 : SV_Target0;
	float4 t1 : SV_Target1;
	float4 t2 : SV_Target2;
};

// vs 3de80ecd1a09f1b2: 16 retail keyword combination(s)
void vs_3de80ecd1a09f1b2_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float3 o4 : TEXCOORD3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r0.xyzw;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  r0.yzw = float3(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1]) * r0.yyy;
  r0.xyz = float3(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0]) * r0.xxx + r0.yzw;
  o1.zw = r1.xw + r1.zz;
  o1.xy = v1.xy;
  o2.xyz = v2.xyz;
  r1.xyz = -float3(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2]) + r0.xyz;
  r0.xyz = float3(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2]) + r0.xyz;
  r0.xyz = float3(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3]) + r0.xyz;
  r1.xyz = float3(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3]) + r1.xyz;
  r1.w = -r1.z;
  o3.xyz = r1.xyw;
  r0.w = -r0.z;
  o4.xyz = r0.xyw;
  return;
}


// ps 8caa72e988b21b58: 3 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SUNLIGHT_CONTROL) || !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && defined(_BT_SIM_GAME)
void ps_8caa72e988b21b58_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = cmp(r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.w = 1 + -r0.w;
  r0.z = r0.z + r0.w;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps 8caa72e988b21b58: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_8caa72e988b21b58_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = cmp(r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.w = 1 + -r0.w;
  r0.z = r0.z + r0.w;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps 1e250150efc6e892: 3 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SUNLIGHT_CONTROL) || !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && defined(_BT_SIM_GAME)
void ps_1e250150efc6e892_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps 1e250150efc6e892: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_1e250150efc6e892_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps a26a698e440bd45a: 6 retail keyword combination(s)
#if defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SUNLIGHT_CONTROL) || defined(SHADOWS_SINGLE_CASCADE) && defined(_BT_SIM_GAME)
void ps_a26a698e440bd45a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps a26a698e440bd45a: 2 retail keyword combination(s)
#if defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_a26a698e440bd45a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float3 o4 = 0;
		vs_3de80ecd1a09f1b2_impl(v.position0, v.texcoord0, v.texcoord1.xyz, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3.xyz = o4;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r = (fout)0;
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES)
	{
		float4 o0 = 0;
		ps_8caa72e988b21b58_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES)
	{
		float4 o0 = 0;
		ps_1e250150efc6e892_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SHADOWS_SINGLE_CASCADE)
	{
		float4 o0 = 0;
		ps_a26a698e440bd45a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#else
	{ r = (fout)0; }
#endif
	return r;
}
			ENDCG
		}
	}
	SubShader
	{
		Tags { "ShadowmapFilter"="HardShadow_FORCE_INV_PROJECTION_IN_PS" }
		Pass
		{
			Blend One Zero
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ SHADOWS_SINGLE_CASCADE
			#pragma multi_compile _ SHADOWS_SPLIT_SPHERES
			#pragma multi_compile _ _BT_SIM_GAME
			#pragma multi_compile _ _BT_SUNLIGHT_CONTROL

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;
Texture2D _ShadowMapTexture;
SamplerComparisonState sampler_ShadowMapTexture;


struct appdata
{
	float4 position0 : POSITION0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#else
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#endif

struct fout
{
	float4 t0 : SV_Target0;
	float4 t1 : SV_Target1;
	float4 t2 : SV_Target2;
};

// vs 3de80ecd1a09f1b2: 16 retail keyword combination(s)
void vs_3de80ecd1a09f1b2_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float3 o4 : TEXCOORD3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r0.xyzw;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  r0.yzw = float3(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1]) * r0.yyy;
  r0.xyz = float3(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0]) * r0.xxx + r0.yzw;
  o1.zw = r1.xw + r1.zz;
  o1.xy = v1.xy;
  o2.xyz = v2.xyz;
  r1.xyz = -float3(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2]) + r0.xyz;
  r0.xyz = float3(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2]) + r0.xyz;
  r0.xyz = float3(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3]) + r0.xyz;
  r1.xyz = float3(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3]) + r1.xyz;
  r1.w = -r1.z;
  o3.xyz = r1.xyw;
  r0.w = -r0.z;
  o4.xyz = r0.xyw;
  return;
}


// ps e0b42d7da93462cc: 3 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SUNLIGHT_CONTROL) || !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && defined(_BT_SIM_GAME)
void ps_e0b42d7da93462cc_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = cmp(-r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(-r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.z = r0.z + -r0.w;
  r0.z = 1 + r0.z;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps e0b42d7da93462cc: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_e0b42d7da93462cc_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = cmp(-r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(-r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.z = r0.z + -r0.w;
  r0.z = 1 + r0.z;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps fc97b017e5b9c202: 3 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SUNLIGHT_CONTROL) || !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && defined(_BT_SIM_GAME)
void ps_fc97b017e5b9c202_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps fc97b017e5b9c202: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_fc97b017e5b9c202_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps 13f540241299efa2: 6 retail keyword combination(s)
#if defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SUNLIGHT_CONTROL) || defined(SHADOWS_SINGLE_CASCADE) && defined(_BT_SIM_GAME)
void ps_13f540241299efa2_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
// ps 13f540241299efa2: 2 retail keyword combination(s)
#if defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_13f540241299efa2_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r0.xy, r0.z).x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


#endif
v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float3 o4 = 0;
		vs_3de80ecd1a09f1b2_impl(v.position0, v.texcoord0, v.texcoord1.xyz, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3.xyz = o4;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r = (fout)0;
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES)
	{
		float4 o0 = 0;
		ps_e0b42d7da93462cc_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES)
	{
		float4 o0 = 0;
		ps_fc97b017e5b9c202_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SHADOWS_SINGLE_CASCADE)
	{
		float4 o0 = 0;
		ps_13f540241299efa2_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#else
	{ r = (fout)0; }
#endif
	return r;
}
			ENDCG
		}
	}
	SubShader
	{
		Tags { "ShadowmapFilter"="PCF_SOFT" }
		Pass
		{
			Blend One Zero
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ SHADOWS_SINGLE_CASCADE
			#pragma multi_compile _ SHADOWS_SPLIT_SPHERES
			#pragma multi_compile _ _BT_SIM_GAME
			#pragma multi_compile _ _BT_SUNLIGHT_CONTROL

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;
Texture2D _CameraGBufferTexture3;
SamplerState sampler_CameraGBufferTexture3;
Texture2D _ShadowMapTexture;
SamplerComparisonState sampler_ShadowMapTexture;

float4 _ShadowMapTexture_TexelSize;

struct appdata
{
	float4 position0 : POSITION0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#else
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#endif

struct fout
{
	float4 t0 : SV_Target0;
	float4 t1 : SV_Target1;
	float4 t2 : SV_Target2;
};

// vs 3de80ecd1a09f1b2: 16 retail keyword combination(s)
void vs_3de80ecd1a09f1b2_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float3 o4 : TEXCOORD3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r0.xyzw;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  r0.yzw = float3(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1]) * r0.yyy;
  r0.xyz = float3(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0]) * r0.xxx + r0.yzw;
  o1.zw = r1.xw + r1.zz;
  o1.xy = v1.xy;
  o2.xyz = v2.xyz;
  r1.xyz = -float3(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2]) + r0.xyz;
  r0.xyz = float3(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2]) + r0.xyz;
  r0.xyz = float3(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3]) + r0.xyz;
  r1.xyz = float3(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3]) + r1.xyz;
  r1.w = -r1.z;
  o3.xyz = r1.xyw;
  r0.w = -r0.z;
  o4.xyz = r0.xyw;
  return;
}


// ps bbc8c2f5b77d1ab4: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && !defined(_BT_SUNLIGHT_CONTROL)
void ps_bbc8c2f5b77d1ab4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = cmp(r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.z = r0.z + -r0.w;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps bbc8c2f5b77d1ab4: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_bbc8c2f5b77d1ab4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = cmp(r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.z = r0.z + -r0.w;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 8d7954464647fb3c: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && !defined(_BT_SUNLIGHT_CONTROL)
void ps_8d7954464647fb3c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 8d7954464647fb3c: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_8d7954464647fb3c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 9c901f3e0cf95e68: 2 retail keyword combination(s)
#if defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SIM_GAME) && !defined(_BT_SUNLIGHT_CONTROL)
void ps_9c901f3e0cf95e68_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r1.xz = _ShadowMapTexture_TexelSize.yy;
  r1.y = 0.142857149;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r2.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r2.zw = -r2.xy * float2(2,2) + float2(3,3);
  r3.xy = -r2.xy * float2(3,3) + float2(4,4);
  r2.zw = r2.zw / r3.xy;
  r4.xy = float2(-2,-2) + r2.zw;
  r5.z = r4.y;
  r2.zw = r2.xy * float2(3,3) + float2(1,1);
  r3.xz = r2.xy / r2.zw;
  r5.xw = float2(2,2) + r3.xz;
  r4.w = r5.x;
  r2.yz = float2(3,3) + r2.xy;
  r0.w = 3 * r2.x;
  r6.xz = r0.ww * float2(-1,1) + float2(4,1);
  r5.xy = _ShadowMapTexture_TexelSize.xy * r2.yz;
  r1.xyz = r5.zyw * r1.xyz;
  r4.z = r5.x;
  r5.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.xx;
  r2.y = 0.142857149;
  r5.xyz = r4.zxw * r2.yxz;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r2.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r2.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r6.y = 7;
  r3.xyz = r6.xyz * r3.yyy;
  r2.yzw = r6.xyz * r2.www;
  r4.xy = float2(7,7) * r6.xz;
  r2.x = r3.y * r2.x;
  r1.x = r3.x * r1.x + r2.x;
  r0.w = r3.z * r0.w + r1.x;
  r1.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r1.wywz;
  r5.yw = r1.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r4.x * r1.x + r0.w;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r5.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r4.y * r0.y + r0.x;
  r0.x = r2.y * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.zw, r0.z).x;
  r0.x = r2.z * r0.y + r0.x;
  r0.x = r2.w * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 9c901f3e0cf95e68: 2 retail keyword combination(s)
#if defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_9c901f3e0cf95e68_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r1.xz = _ShadowMapTexture_TexelSize.yy;
  r1.y = 0.142857149;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r2.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r2.zw = -r2.xy * float2(2,2) + float2(3,3);
  r3.xy = -r2.xy * float2(3,3) + float2(4,4);
  r2.zw = r2.zw / r3.xy;
  r4.xy = float2(-2,-2) + r2.zw;
  r5.z = r4.y;
  r2.zw = r2.xy * float2(3,3) + float2(1,1);
  r3.xz = r2.xy / r2.zw;
  r5.xw = float2(2,2) + r3.xz;
  r4.w = r5.x;
  r2.yz = float2(3,3) + r2.xy;
  r0.w = 3 * r2.x;
  r6.xz = r0.ww * float2(-1,1) + float2(4,1);
  r5.xy = _ShadowMapTexture_TexelSize.xy * r2.yz;
  r1.xyz = r5.zyw * r1.xyz;
  r4.z = r5.x;
  r5.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.xx;
  r2.y = 0.142857149;
  r5.xyz = r4.zxw * r2.yxz;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r2.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r2.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r6.y = 7;
  r3.xyz = r6.xyz * r3.yyy;
  r2.yzw = r6.xyz * r2.www;
  r4.xy = float2(7,7) * r6.xz;
  r2.x = r3.y * r2.x;
  r1.x = r3.x * r1.x + r2.x;
  r0.w = r3.z * r0.w + r1.x;
  r1.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r1.wywz;
  r5.yw = r1.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r4.x * r1.x + r0.w;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r5.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r4.y * r0.y + r0.x;
  r0.x = r2.y * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.zw, r0.z).x;
  r0.x = r2.z * r0.y + r0.x;
  r0.x = r2.w * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 7560546bb413a0d5: 2 retail keyword combination(s)
void ps_7560546bb413a0d5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = cmp(r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.z = r0.z + -r0.w;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


// ps 0fde3992382e20f5: 2 retail keyword combination(s)
void ps_0fde3992382e20f5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


// ps c8f83ece7c312cee: 4 retail keyword combination(s)
void ps_c8f83ece7c312cee_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.z = r0.x + -r0.y;
  r0.y = unity_OrthoParams.w * r0.z + r0.y;
  r0.x = 1 + -r0.x;
  r1.xyz = v4.xyz + -v3.xyz;
  r0.xzw = r0.xxx * r1.xyz + v3.xyz;
  r0.xzw = -v2.xyz * r0.yyy + r0.xzw;
  r1.xyz = v2.xyz * r0.yyy;
  r0.xyz = unity_OrthoParams.www * r0.xzw + r1.xyz;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r1.xz = _ShadowMapTexture_TexelSize.yy;
  r1.y = 0.142857149;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r2.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r2.zw = -r2.xy * float2(2,2) + float2(3,3);
  r3.xy = -r2.xy * float2(3,3) + float2(4,4);
  r2.zw = r2.zw / r3.xy;
  r4.xy = float2(-2,-2) + r2.zw;
  r5.z = r4.y;
  r2.zw = r2.xy * float2(3,3) + float2(1,1);
  r3.xz = r2.xy / r2.zw;
  r5.xw = float2(2,2) + r3.xz;
  r4.w = r5.x;
  r2.yz = float2(3,3) + r2.xy;
  r0.w = 3 * r2.x;
  r6.xz = r0.ww * float2(-1,1) + float2(4,1);
  r5.xy = _ShadowMapTexture_TexelSize.xy * r2.yz;
  r1.xyz = r5.zyw * r1.xyz;
  r4.z = r5.x;
  r5.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.xx;
  r2.y = 0.142857149;
  r5.xyz = r4.zxw * r2.yxz;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r2.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r2.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r6.y = 7;
  r3.xyz = r6.xyz * r3.yyy;
  r2.yzw = r6.xyz * r2.www;
  r4.xy = float2(7,7) * r6.xz;
  r2.x = r3.y * r2.x;
  r1.x = r3.x * r1.x + r2.x;
  r0.w = r3.z * r0.w + r1.x;
  r1.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r1.wywz;
  r5.yw = r1.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r4.x * r1.x + r0.w;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r5.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r4.y * r0.y + r0.x;
  r0.x = r2.y * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.zw, r0.z).x;
  r0.x = r2.z * r0.y + r0.x;
  r0.x = r2.w * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float3 o4 = 0;
		vs_3de80ecd1a09f1b2_impl(v.position0, v.texcoord0, v.texcoord1.xyz, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3.xyz = o4;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r = (fout)0;
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_bbc8c2f5b77d1ab4_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_8d7954464647fb3c_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_9c901f3e0cf95e68_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_7560546bb413a0d5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_0fde3992382e20f5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SHADOWS_SINGLE_CASCADE) && defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_c8f83ece7c312cee_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#else
	{ r = (fout)0; }
#endif
	return r;
}
			ENDCG
		}
	}
	SubShader
	{
		Tags { "ShadowmapFilter"="PCF_SOFT_FORCE_INV_PROJECTION_IN_PS" }
		Pass
		{
			Blend One Zero
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ SHADOWS_SINGLE_CASCADE
			#pragma multi_compile _ SHADOWS_SPLIT_SPHERES
			#pragma multi_compile _ _BT_SIM_GAME
			#pragma multi_compile _ _BT_SUNLIGHT_CONTROL

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;
Texture2D _CameraGBufferTexture3;
SamplerState sampler_CameraGBufferTexture3;
Texture2D _ShadowMapTexture;
SamplerComparisonState sampler_ShadowMapTexture;

float4 _ShadowMapTexture_TexelSize;

struct appdata
{
	float4 position0 : POSITION0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#else
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#endif

struct fout
{
	float4 t0 : SV_Target0;
	float4 t1 : SV_Target1;
	float4 t2 : SV_Target2;
};

// vs 3de80ecd1a09f1b2: 16 retail keyword combination(s)
void vs_3de80ecd1a09f1b2_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float3 o4 : TEXCOORD3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r0.xyzw;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  r0.yzw = float3(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1]) * r0.yyy;
  r0.xyz = float3(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0]) * r0.xxx + r0.yzw;
  o1.zw = r1.xw + r1.zz;
  o1.xy = v1.xy;
  o2.xyz = v2.xyz;
  r1.xyz = -float3(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2]) + r0.xyz;
  r0.xyz = float3(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2]) + r0.xyz;
  r0.xyz = float3(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3]) + r0.xyz;
  r1.xyz = float3(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3]) + r1.xyz;
  r1.w = -r1.z;
  o3.xyz = r1.xyw;
  r0.w = -r0.z;
  o4.xyz = r0.xyw;
  return;
}


// ps 380ad20077894d35: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && !defined(_BT_SUNLIGHT_CONTROL)
void ps_380ad20077894d35_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = cmp(-r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(-r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.z = r0.z + -r0.w;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 380ad20077894d35: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_380ad20077894d35_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = cmp(-r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(-r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.z = r0.z + -r0.w;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 2c3e842b8c2727c4: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && !defined(_BT_SUNLIGHT_CONTROL)
void ps_2c3e842b8c2727c4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 2c3e842b8c2727c4: 1 retail keyword combination(s)
#if !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_2c3e842b8c2727c4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 76fc501b95eae262: 2 retail keyword combination(s)
#if defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SIM_GAME) && !defined(_BT_SUNLIGHT_CONTROL)
void ps_76fc501b95eae262_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r1.xz = _ShadowMapTexture_TexelSize.yy;
  r1.y = 0.142857149;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r2.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r2.zw = -r2.xy * float2(2,2) + float2(3,3);
  r3.xy = -r2.xy * float2(3,3) + float2(4,4);
  r2.zw = r2.zw / r3.xy;
  r4.xy = float2(-2,-2) + r2.zw;
  r5.z = r4.y;
  r2.zw = r2.xy * float2(3,3) + float2(1,1);
  r3.xz = r2.xy / r2.zw;
  r5.xw = float2(2,2) + r3.xz;
  r4.w = r5.x;
  r2.yz = float2(3,3) + r2.xy;
  r0.w = 3 * r2.x;
  r6.xz = r0.ww * float2(-1,1) + float2(4,1);
  r5.xy = _ShadowMapTexture_TexelSize.xy * r2.yz;
  r1.xyz = r5.zyw * r1.xyz;
  r4.z = r5.x;
  r5.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.xx;
  r2.y = 0.142857149;
  r5.xyz = r4.zxw * r2.yxz;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r2.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r2.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r6.y = 7;
  r3.xyz = r6.xyz * r3.yyy;
  r2.yzw = r6.xyz * r2.www;
  r4.xy = float2(7,7) * r6.xz;
  r2.x = r3.y * r2.x;
  r1.x = r3.x * r1.x + r2.x;
  r0.w = r3.z * r0.w + r1.x;
  r1.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r1.wywz;
  r5.yw = r1.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r4.x * r1.x + r0.w;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r5.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r4.y * r0.y + r0.x;
  r0.x = r2.y * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.zw, r0.z).x;
  r0.x = r2.z * r0.y + r0.x;
  r0.x = r2.w * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 76fc501b95eae262: 2 retail keyword combination(s)
#if defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SIM_GAME) && defined(_BT_SUNLIGHT_CONTROL)
void ps_76fc501b95eae262_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r1.xz = _ShadowMapTexture_TexelSize.yy;
  r1.y = 0.142857149;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r2.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r2.zw = -r2.xy * float2(2,2) + float2(3,3);
  r3.xy = -r2.xy * float2(3,3) + float2(4,4);
  r2.zw = r2.zw / r3.xy;
  r4.xy = float2(-2,-2) + r2.zw;
  r5.z = r4.y;
  r2.zw = r2.xy * float2(3,3) + float2(1,1);
  r3.xz = r2.xy / r2.zw;
  r5.xw = float2(2,2) + r3.xz;
  r4.w = r5.x;
  r2.yz = float2(3,3) + r2.xy;
  r0.w = 3 * r2.x;
  r6.xz = r0.ww * float2(-1,1) + float2(4,1);
  r5.xy = _ShadowMapTexture_TexelSize.xy * r2.yz;
  r1.xyz = r5.zyw * r1.xyz;
  r4.z = r5.x;
  r5.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.xx;
  r2.y = 0.142857149;
  r5.xyz = r4.zxw * r2.yxz;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r2.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r2.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r6.y = 7;
  r3.xyz = r6.xyz * r3.yyy;
  r2.yzw = r6.xyz * r2.www;
  r4.xy = float2(7,7) * r6.xz;
  r2.x = r3.y * r2.x;
  r1.x = r3.x * r1.x + r2.x;
  r0.w = r3.z * r0.w + r1.x;
  r1.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r1.wywz;
  r5.yw = r1.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r4.x * r1.x + r0.w;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r5.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r4.y * r0.y + r0.x;
  r0.x = r2.y * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.zw, r0.z).x;
  r0.x = r2.z * r0.y + r0.x;
  r0.x = r2.w * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  r0.x = r0.x * r0.y + _LightShadowData.x;
  r1.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, v1.xy).xyzw;
  r0.y = cmp(1 < r1.w);
  r0.z = -2 + r1.w;
  r0.y = r0.y ? r0.z : r1.w;
  o0.xyzw = r0.xxxx * r0.yyyy;
  return;
}


#endif
// ps 861c79d558da9ebf: 2 retail keyword combination(s)
void ps_861c79d558da9ebf_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = cmp(-r0.zzzz >= _LightSplitsNear.xyzw);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyzw = cmp(-r0.zzzz < _LightSplitsFar.xyzw);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r1.xyzw = r2.xyzw * r1.xyzw;
  r2.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.w = dot(r1.xyzw, float4(1,1,1,1));
  r0.z = r0.z + -r0.w;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


// ps 282eb85523a18442: 2 retail keyword combination(s)
void ps_282eb85523a18442_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r2.xyz = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r2.xyz);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * r0.www + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r1.x = dot(r1.xyzw, float4(1,1,1,1));
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * r0.www + r3.xyz;
  r2.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r3.xyz;
  r0.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * r0.www + r0.xyz;
  r0.xyz = r0.xyz * r1.www + r2.xyz;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r0.z = r0.z + -r1.x;
  r0.z = 1 + r0.z;
  r1.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r1.zw = -r1.xy * float2(3,3) + float2(4,4);
  r0.w = 3 * r1.x;
  r2.xz = r0.ww * float2(-1,1) + float2(4,1);
  r2.y = 7;
  r3.xyz = r2.xyz * r1.www;
  r4.xy = -r1.xy * float2(2,2) + float2(3,3);
  r1.zw = r4.xy / r1.zw;
  r4.xy = float2(-2,-2) + r1.zw;
  r5.z = r4.y;
  r1.zw = r1.xy * float2(3,3) + float2(1,1);
  r6.xy = r1.xy / r1.zw;
  r7.xyz = r2.xyz * r1.www;
  r1.zw = float2(7,7) * r2.xz;
  r1.xy = float2(3,3) + r1.xy;
  r5.xy = _ShadowMapTexture_TexelSize.xy * r1.xy;
  r1.xy = float2(2,2) + r6.xy;
  r5.w = r1.y;
  r4.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.yy;
  r2.y = 0.142857149;
  r2.xyz = r5.zyw * r2.xyz;
  r4.z = r5.x;
  r5.w = r2.x;
  r6.xz = _ShadowMapTexture_TexelSize.xx;
  r6.y = 0.142857149;
  r5.xyz = r6.yxz * r4.zxw;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r1.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r1.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r1.y = r3.y * r1.y;
  r1.x = r3.x * r1.x + r1.y;
  r0.w = r3.z * r0.w + r1.x;
  r2.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r2.wywz;
  r5.yw = r2.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r1.w * r0.y + r0.x;
  r0.x = r7.x * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r7.y * r0.y + r0.x;
  r0.x = r7.z * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


// ps b718fadcc87d2b2b: 4 retail keyword combination(s)
void ps_b718fadcc87d2b2b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = v1.zw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = r0.xyz / r0.www;
  r1.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r0.xyzw;
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * r0.www + r0.xyz;
  r1.xz = _ShadowMapTexture_TexelSize.yy;
  r1.y = 0.142857149;
  r0.xy = r0.xy * _ShadowMapTexture_TexelSize.zw + float2(0.5,0.5);
  r2.xy = frac(r0.xy);
  r0.xy = floor(r0.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r2.zw = -r2.xy * float2(2,2) + float2(3,3);
  r3.xy = -r2.xy * float2(3,3) + float2(4,4);
  r2.zw = r2.zw / r3.xy;
  r4.xy = float2(-2,-2) + r2.zw;
  r5.z = r4.y;
  r2.zw = r2.xy * float2(3,3) + float2(1,1);
  r3.xz = r2.xy / r2.zw;
  r5.xw = float2(2,2) + r3.xz;
  r4.w = r5.x;
  r2.yz = float2(3,3) + r2.xy;
  r0.w = 3 * r2.x;
  r6.xz = r0.ww * float2(-1,1) + float2(4,1);
  r5.xy = _ShadowMapTexture_TexelSize.xy * r2.yz;
  r1.xyz = r5.zyw * r1.xyz;
  r4.z = r5.x;
  r5.w = r1.x;
  r2.xz = _ShadowMapTexture_TexelSize.xx;
  r2.y = 0.142857149;
  r5.xyz = r4.zxw * r2.yxz;
  r4.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.ywxw;
  r2.xy = r0.xy * _ShadowMapTexture_TexelSize.xy + r5.zw;
  r0.w = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r2.xy, r0.z).x;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.xy, r0.z).x;
  r2.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r4.zw, r0.z).x;
  r6.y = 7;
  r3.xyz = r6.xyz * r3.yyy;
  r2.yzw = r6.xyz * r2.www;
  r4.xy = float2(7,7) * r6.xz;
  r2.x = r3.y * r2.x;
  r1.x = r3.x * r1.x + r2.x;
  r0.w = r3.z * r0.w + r1.x;
  r1.w = r5.y;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r1.wywz;
  r5.yw = r1.yz;
  r1.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r1.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.w = r4.x * r1.x + r0.w;
  r3.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xyzy;
  r5.xyzw = r0.xyxy * _ShadowMapTexture_TexelSize.xyxy + r5.xwzw;
  r0.x = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.xy, r0.z).x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r3.zw, r0.z).x;
  r0.x = r0.x * 49 + r0.w;
  r0.x = r4.y * r0.y + r0.x;
  r0.x = r2.y * r1.y + r0.x;
  r0.y = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.xy, r0.z).x;
  r0.z = _ShadowMapTexture.SampleCmpLevelZero(sampler_ShadowMapTexture, r5.zw, r0.z).x;
  r0.x = r2.z * r0.y + r0.x;
  r0.x = r2.w * r0.z + r0.x;
  r0.x = 0.0069444445 * r0.x;
  r0.y = 1 + -_LightShadowData.x;
  o0.xyzw = r0.xxxx * r0.yyyy + _LightShadowData.xxxx;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float3 o4 = 0;
		vs_3de80ecd1a09f1b2_impl(v.position0, v.texcoord0, v.texcoord1.xyz, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3.xyz = o4;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r = (fout)0;
#if !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_380ad20077894d35_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && !defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_2c3e842b8c2727c4_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SHADOWS_SINGLE_CASCADE) && !defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_76fc501b95eae262_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SHADOWS_SINGLE_CASCADE) && !defined(SHADOWS_SPLIT_SPHERES) && defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_861c79d558da9ebf_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SHADOWS_SINGLE_CASCADE) && defined(SHADOWS_SPLIT_SPHERES) && defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_282eb85523a18442_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SHADOWS_SINGLE_CASCADE) && defined(_BT_SIM_GAME)
	{
		float4 o0 = 0;
		ps_b718fadcc87d2b2b_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
		r.t0 = o0;
	}
#else
	{ r = (fout)0; }
#endif
	return r;
}
			ENDCG
		}
	}
}
