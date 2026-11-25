Shader "Hidden/BT-DeferredReflections"
{
	Properties
	{
		_SrcBlend ("_SrcBlend", Float) = 1
		_DstBlend ("_DstBlend", Float) = 1
	}
	SubShader
	{
		Pass
		{
			Blend [_SrcBlend] [_DstBlend]
			ZWrite Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _BT_CUSTOM_REFLECTION
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _BT_ONLYLIT
			#pragma multi_compile _ _BT_SIM_GAME
			#pragma multi_compile _ _LOADINGSCREEN
			#pragma multi_compile _ _OVERLAY_RAIN
			#pragma multi_compile _ _PORTRAITCAM
			#pragma multi_compile _ _SPACE
			#pragma multi_compile _ _URBAN

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _CameraGBufferTexture0;
SamplerState sampler_CameraGBufferTexture0;
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;
Texture2D _CameraGBufferTexture3;
SamplerState sampler_CameraGBufferTexture3;
Texture2D _CameraGBufferTexture1;
SamplerState sampler_CameraGBufferTexture1;
Texture2D _GroundHeightTex;
SamplerState sampler_GroundHeightTex;
Texture2D _ColorTempLUT;
SamplerState sampler_ColorTempLUT;
TextureCube _BT_Reflection;
SamplerState sampler_BT_Reflection;

float _LightAsQuad;
float _EV;
float _BT_ReflectionIntensity;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
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

// vs d1696a61e9856034: 512 retail keyword combination(s)
void vs_d1696a61e9856034_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float3 o2 : TEXCOORD1)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  r1.y = _ProjectionParams.x * r1.y;
  r2.xzw = float3(0.5,0.5,0.5) * r1.xwy;
  o1.zw = r1.zw;
  o1.xy = r2.xw + r2.zz;
  r1.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r0.yyy;
  r1.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * r0.www + r0.xyz;
  r1.xyz = float3(-1,-1,1) * r0.xyz;
  r0.xyz = -r0.xyz * float3(-1,-1,1) + v1.xyz;
  o2.xyz = _LightAsQuad.xxx * r0.xyz + r1.xyz;
  return;
}


// ps 3bec7143ebca6f05: 4 retail keyword combination(s)
void ps_3bec7143ebca6f05_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 47dbfb91a9a64ed9: 2 retail keyword combination(s)
void ps_47dbfb91a9a64ed9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = r4.xyz * r4.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 26508f5bc0b0a985: 2 retail keyword combination(s)
void ps_26508f5bc0b0a985_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = r4.xyz * r4.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps d19fba7fc9d6a5c9: 2 retail keyword combination(s)
void ps_d19fba7fc9d6a5c9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps d0fe8e707059ff92: 2 retail keyword combination(s)
void ps_d0fe8e707059ff92_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps f674a6afcdaa735c: 2 retail keyword combination(s)
void ps_f674a6afcdaa735c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r8.zw = float2(1024,1024) + r0.xz;
  r8.zw = float2(0.00048828125,0.00048828125) * r8.zw;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r8.zw).xyzw;
  r1.w = 50 + r9.x;
  r3.w = r9.x + -r1.w;
  r1.w = -r1.w + r0.y;
  r3.w = 1 / r3.w;
  r1.w = saturate(r3.w * r1.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r1.w = 0.5 * r1.w;
  r1.w = min(1, r1.w);
  r1.xw = float2(1,1) + -r1.zw;
  r3.w = saturate(r7.w + r7.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r1.x * 0.699999988 + 1.70000005;
  r4.w = r4.w * r1.x;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = r4.xyz * r3.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps ed0dde713633e5ef: 2 retail keyword combination(s)
void ps_ed0dde713633e5ef_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r7.xy = float2(1024,1024) + r0.xz;
  r7.xy = float2(0.00048828125,0.00048828125) * r7.xy;
  r8.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r7.xy).xyzw;
  r4.w = 50 + r8.x;
  r5.w = r8.x + -r4.w;
  r4.w = -r4.w + r0.y;
  r5.w = 1 / r5.w;
  r4.w = saturate(r5.w * r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r4.w = 0.5 * r4.w;
  r4.w = min(1, r4.w);
  r4.w = 1 + -r4.w;
  r5.w = -0.25 + r6.w;
  r5.w = saturate(r5.w + r5.w);
  r6.z = r5.w * -2 + 3;
  r5.w = r5.w * r5.w;
  r5.w = r6.z * r5.w;
  r6.z = -r3.w * 0.699999988 + 1.70000005;
  r6.z = r6.z * r3.w;
  r6.z = 6 * r6.z;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r6.z).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = r4.xyz * r5.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 089266b46e4b4323: 4 retail keyword combination(s)
void ps_089266b46e4b4323_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps a90032be74feb038: 4 retail keyword combination(s)
void ps_a90032be74feb038_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = r4.xyz * r4.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 5670ab94e2a93369: 2 retail keyword combination(s)
void ps_5670ab94e2a93369_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 25e116f2f1cc7e1f: 2 retail keyword combination(s)
void ps_25e116f2f1cc7e1f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 3bbad50732791a26: 2 retail keyword combination(s)
void ps_3bbad50732791a26_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r8.zw = float2(1024,1024) + r0.xz;
  r8.zw = float2(0.00048828125,0.00048828125) * r8.zw;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r8.zw).xyzw;
  r1.w = 50 + r9.x;
  r3.w = r9.x + -r1.w;
  r1.w = -r1.w + r0.y;
  r3.w = 1 / r3.w;
  r1.w = saturate(r3.w * r1.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r1.w = 0.5 * r1.w;
  r1.w = min(1, r1.w);
  r1.xw = float2(1,1) + -r1.zw;
  r3.w = saturate(r7.w + r7.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r1.x * 0.699999988 + 1.70000005;
  r4.w = r4.w * r1.x;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = r4.xyz * r3.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 6052b207c2105fd1: 2 retail keyword combination(s)
void ps_6052b207c2105fd1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r7.xy = float2(1024,1024) + r0.xz;
  r7.xy = float2(0.00048828125,0.00048828125) * r7.xy;
  r8.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r7.xy).xyzw;
  r4.w = 50 + r8.x;
  r5.w = r8.x + -r4.w;
  r4.w = -r4.w + r0.y;
  r5.w = 1 / r5.w;
  r4.w = saturate(r5.w * r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r4.w = 0.5 * r4.w;
  r4.w = min(1, r4.w);
  r4.w = 1 + -r4.w;
  r5.w = -0.25 + r6.w;
  r5.w = saturate(r5.w + r5.w);
  r6.z = r5.w * -2 + 3;
  r5.w = r5.w * r5.w;
  r5.w = r6.z * r5.w;
  r6.z = -r3.w * 0.699999988 + 1.70000005;
  r6.z = r6.z * r3.w;
  r6.z = 6 * r6.z;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r6.z).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = r4.xyz * r5.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 3133dfdfc3aa4713: 4 retail keyword combination(s)
void ps_3133dfdfc3aa4713_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 48f59423fcddb526: 4 retail keyword combination(s)
void ps_48f59423fcddb526_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 5b23c4eb614bc3a8: 2 retail keyword combination(s)
void ps_5b23c4eb614bc3a8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps c02de1fa4850a779: 2 retail keyword combination(s)
void ps_c02de1fa4850a779_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps c0b39ac668df28b6: 2 retail keyword combination(s)
void ps_c0b39ac668df28b6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r8.zw = float2(1024,1024) + r0.xz;
  r8.zw = float2(0.00048828125,0.00048828125) * r8.zw;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r8.zw).xyzw;
  r1.w = 50 + r9.x;
  r3.w = r9.x + -r1.w;
  r1.w = -r1.w + r0.y;
  r3.w = 1 / r3.w;
  r1.w = saturate(r3.w * r1.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r1.w = 0.5 * r1.w;
  r1.w = min(1, r1.w);
  r1.xw = float2(1,1) + -r1.zw;
  r3.w = saturate(r7.w + r7.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r1.x * 0.699999988 + 1.70000005;
  r4.w = r4.w * r1.x;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps ba20c195c8b866dd: 2 retail keyword combination(s)
void ps_ba20c195c8b866dd_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r7.xy = float2(1024,1024) + r0.xz;
  r7.xy = float2(0.00048828125,0.00048828125) * r7.xy;
  r8.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r7.xy).xyzw;
  r4.w = 50 + r8.x;
  r5.w = r8.x + -r4.w;
  r4.w = -r4.w + r0.y;
  r5.w = 1 / r5.w;
  r4.w = saturate(r5.w * r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r4.w = 0.5 * r4.w;
  r4.w = min(1, r4.w);
  r4.w = 1 + -r4.w;
  r5.w = -0.25 + r6.w;
  r5.w = saturate(r5.w + r5.w);
  r6.z = r5.w * -2 + 3;
  r5.w = r5.w * r5.w;
  r5.w = r6.z * r5.w;
  r6.z = -r3.w * 0.699999988 + 1.70000005;
  r6.z = r6.z * r3.w;
  r6.z = 6 * r6.z;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r6.z).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = r4.xyz * r5.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 4252afa3a7d4a3d9: 2 retail keyword combination(s)
void ps_4252afa3a7d4a3d9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r9.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r9.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 39fbcdaa53b3bb9e: 4 retail keyword combination(s)
void ps_39fbcdaa53b3bb9e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = r4.xyz * r4.www;
  r7.xyw = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r7.xyw;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 7607b145d0653638: 2 retail keyword combination(s)
void ps_7607b145d0653638_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r9.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r9.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps d5bf1b6e6cb68b7f: 2 retail keyword combination(s)
void ps_d5bf1b6e6cb68b7f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r9.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r9.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps e3e1fbdb424b78c4: 2 retail keyword combination(s)
void ps_e3e1fbdb424b78c4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r7.xyw = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r7.xyw;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 851378f52c95c205: 2 retail keyword combination(s)
void ps_851378f52c95c205_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r8.zw = float2(1024,1024) + r0.xz;
  r8.zw = float2(0.00048828125,0.00048828125) * r8.zw;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r8.zw).xyzw;
  r1.w = 50 + r9.x;
  r3.w = r9.x + -r1.w;
  r1.w = -r1.w + r0.y;
  r3.w = 1 / r3.w;
  r1.w = saturate(r3.w * r1.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r1.w = 0.5 * r1.w;
  r1.w = min(1, r1.w);
  r1.xw = float2(1,1) + -r1.zw;
  r3.w = saturate(r7.w + r7.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r1.x * 0.699999988 + 1.70000005;
  r4.w = r4.w * r1.x;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = r4.xyz * r3.www;
  r9.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r9.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps ec8133398bb2017c: 2 retail keyword combination(s)
void ps_ec8133398bb2017c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r7.xy = float2(1024,1024) + r0.xz;
  r7.xy = float2(0.00048828125,0.00048828125) * r7.xy;
  r8.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r7.xy).xyzw;
  r4.w = 50 + r8.x;
  r5.w = r8.x + -r4.w;
  r4.w = -r4.w + r0.y;
  r5.w = 1 / r5.w;
  r4.w = saturate(r5.w * r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r4.w = 0.5 * r4.w;
  r4.w = min(1, r4.w);
  r4.w = 1 + -r4.w;
  r5.w = -0.25 + r6.w;
  r5.w = saturate(r5.w + r5.w);
  r6.z = r5.w * -2 + 3;
  r5.w = r5.w * r5.w;
  r5.w = r6.z * r5.w;
  r6.z = -r3.w * 0.699999988 + 1.70000005;
  r6.z = r6.z * r3.w;
  r6.z = 6 * r6.z;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r6.z).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = r4.xyz * r5.www;
  r7.xyw = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r7.xyw;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps fdec60988bdb9e2f: 128 retail keyword combination(s)
void ps_fdec60988bdb9e2f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy / v1.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.z = cmp(0.999000013 < r0.z);
  [branch] if (r0.z != 0) {
    r0.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r0.xy).xyzw;
    o0.xyz = r0.xyz;
    o0.w = 1;
    return;
  }
  o0.xyzw = float4(0,0,0,1);
  return;
}


// ps 0c224e8bcdbdb4d7: 2 retail keyword combination(s)
void ps_0c224e8bcdbdb4d7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 9e3670cf6b9ac97c: 4 retail keyword combination(s)
void ps_9e3670cf6b9ac97c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = r4.xyz * r4.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 20d26a96982b9cd0: 2 retail keyword combination(s)
void ps_20d26a96982b9cd0_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 9e6a73ed1d09f54d: 2 retail keyword combination(s)
void ps_9e6a73ed1d09f54d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 5516fed3b9555ffd: 2 retail keyword combination(s)
void ps_5516fed3b9555ffd_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 12fb276ba9b78642: 2 retail keyword combination(s)
void ps_12fb276ba9b78642_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r8.zw = float2(1024,1024) + r0.xz;
  r8.zw = float2(0.00048828125,0.00048828125) * r8.zw;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r8.zw).xyzw;
  r1.w = 50 + r9.x;
  r3.w = r9.x + -r1.w;
  r1.w = -r1.w + r0.y;
  r3.w = 1 / r3.w;
  r1.w = saturate(r3.w * r1.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r1.w = 0.5 * r1.w;
  r1.w = min(1, r1.w);
  r1.xw = float2(1,1) + -r1.zw;
  r3.w = saturate(r7.w + r7.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r1.x * 0.699999988 + 1.70000005;
  r4.w = r4.w * r1.x;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = r4.xyz * r3.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 18302c0504422732: 2 retail keyword combination(s)
void ps_18302c0504422732_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r7.xy = float2(1024,1024) + r0.xz;
  r7.xy = float2(0.00048828125,0.00048828125) * r7.xy;
  r8.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r7.xy).xyzw;
  r4.w = 50 + r8.x;
  r5.w = r8.x + -r4.w;
  r4.w = -r4.w + r0.y;
  r5.w = 1 / r5.w;
  r4.w = saturate(r5.w * r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r4.w = 0.5 * r4.w;
  r4.w = min(1, r4.w);
  r4.w = 1 + -r4.w;
  r5.w = -0.25 + r6.w;
  r5.w = saturate(r5.w + r5.w);
  r6.z = r5.w * -2 + 3;
  r5.w = r5.w * r5.w;
  r5.w = r6.z * r5.w;
  r6.z = -r3.w * 0.699999988 + 1.70000005;
  r6.z = r6.z * r3.w;
  r6.z = 6 * r6.z;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r6.z).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = r4.xyz * r5.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 820823829ad4e8fa: 4 retail keyword combination(s)
void ps_820823829ad4e8fa_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 16669c0dc368dc6e: 4 retail keyword combination(s)
void ps_16669c0dc368dc6e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = r4.xyz * r4.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps f5344e350239eab6: 2 retail keyword combination(s)
void ps_f5344e350239eab6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 2176d34b9120d982: 2 retail keyword combination(s)
void ps_2176d34b9120d982_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps e357b3b7fe006f0f: 2 retail keyword combination(s)
void ps_e357b3b7fe006f0f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r8.zw = float2(1024,1024) + r0.xz;
  r8.zw = float2(0.00048828125,0.00048828125) * r8.zw;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r8.zw).xyzw;
  r1.w = 50 + r9.x;
  r3.w = r9.x + -r1.w;
  r1.w = -r1.w + r0.y;
  r3.w = 1 / r3.w;
  r1.w = saturate(r3.w * r1.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r1.w = 0.5 * r1.w;
  r1.w = min(1, r1.w);
  r1.xw = float2(1,1) + -r1.zw;
  r3.w = saturate(r7.w + r7.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r1.x * 0.699999988 + 1.70000005;
  r4.w = r4.w * r1.x;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = r4.xyz * r3.www;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 23bc4d47ec76d4d2: 2 retail keyword combination(s)
void ps_23bc4d47ec76d4d2_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r7.xy = float2(1024,1024) + r0.xz;
  r7.xy = float2(0.00048828125,0.00048828125) * r7.xy;
  r8.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r7.xy).xyzw;
  r4.w = 50 + r8.x;
  r5.w = r8.x + -r4.w;
  r4.w = -r4.w + r0.y;
  r5.w = 1 / r5.w;
  r4.w = saturate(r5.w * r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r4.w = 0.5 * r4.w;
  r4.w = min(1, r4.w);
  r4.w = 1 + -r4.w;
  r5.w = -0.25 + r6.w;
  r5.w = saturate(r5.w + r5.w);
  r6.z = r5.w * -2 + 3;
  r5.w = r5.w * r5.w;
  r5.w = r6.z * r5.w;
  r6.z = -r3.w * 0.699999988 + 1.70000005;
  r6.z = r6.z * r3.w;
  r6.z = 6 * r6.z;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r6.z).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = r4.xyz * r5.www;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps c440beb2267c6793: 4 retail keyword combination(s)
void ps_c440beb2267c6793_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 3a9e4677ef801c93: 4 retail keyword combination(s)
void ps_3a9e4677ef801c93_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps f5f4be6315711387: 2 retail keyword combination(s)
void ps_f5f4be6315711387_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps b827fed951424a58: 2 retail keyword combination(s)
void ps_b827fed951424a58_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps d8f7f8b06806b33c: 2 retail keyword combination(s)
void ps_d8f7f8b06806b33c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r8.zw = float2(1024,1024) + r0.xz;
  r8.zw = float2(0.00048828125,0.00048828125) * r8.zw;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r8.zw).xyzw;
  r1.w = 50 + r9.x;
  r3.w = r9.x + -r1.w;
  r1.w = -r1.w + r0.y;
  r3.w = 1 / r3.w;
  r1.w = saturate(r3.w * r1.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r1.w = 0.5 * r1.w;
  r1.w = min(1, r1.w);
  r1.xw = float2(1,1) + -r1.zw;
  r3.w = saturate(r7.w + r7.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r1.x * 0.699999988 + 1.70000005;
  r4.w = r4.w * r1.x;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = 1 + -r0.w;
  r0.w = saturate(r1.z + r0.w);
  r2.xyz = r1.xxx * r4.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r1.xzw = r1.xxx * r3.xyz + r7.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.xyz * r1.xzw + r0.yzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps bac2e2f1ecfb2a4a: 2 retail keyword combination(s)
void ps_bac2e2f1ecfb2a4a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r7.xy = float2(1024,1024) + r0.xz;
  r7.xy = float2(0.00048828125,0.00048828125) * r7.xy;
  r8.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r7.xy).xyzw;
  r4.w = 50 + r8.x;
  r5.w = r8.x + -r4.w;
  r4.w = -r4.w + r0.y;
  r5.w = 1 / r5.w;
  r4.w = saturate(r5.w * r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r4.w = 0.5 * r4.w;
  r4.w = min(1, r4.w);
  r4.w = 1 + -r4.w;
  r5.w = -0.25 + r6.w;
  r5.w = saturate(r5.w + r5.w);
  r6.z = r5.w * -2 + 3;
  r5.w = r5.w * r5.w;
  r5.w = r6.z * r5.w;
  r6.z = -r3.w * 0.699999988 + 1.70000005;
  r6.z = r6.z * r3.w;
  r6.z = 6 * r6.z;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r6.z).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = r4.xyz * r5.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = 1 + -r1.x;
  r1.x = saturate(r1.z + r1.x);
  r3.xyz = r2.yyy * r4.xyz;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xzw = r5.xyz * r1.www;
  r1.xzw = r1.xzw * r6.www;
  r0.yzw = r3.xyz * r0.www + r1.xzw;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps fb1fd56292fdb230: 4 retail keyword combination(s)
void ps_fb1fd56292fdb230_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r9.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r9.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 5d149882a230e502: 4 retail keyword combination(s)
void ps_5d149882a230e502_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = r4.xyz * r4.www;
  r7.xyw = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r7.xyw;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 8832160b5d135afb: 2 retail keyword combination(s)
void ps_8832160b5d135afb_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r1.x = 1 + -r1.z;
  r1.w = saturate(r7.w + r7.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r3.w = -r1.x * 0.699999988 + 1.70000005;
  r3.w = r3.w * r1.x;
  r3.w = 6 * r3.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r3.w).xyzw;
  r3.w = -1 + r4.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r4.xyz = r3.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r9.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r9.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 424ae23d77874191: 2 retail keyword combination(s)
void ps_424ae23d77874191_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r3.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r3.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r7.xyw = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r7.xyw;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 96f81340781b2c26: 2 retail keyword combination(s)
void ps_96f81340781b2c26_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r7.xyz = r1.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r8.x = 0.263157904 * r1.y;
  r0.w = -r1.x * 0.959999979 + 0.959999979;
  r6.xyz = r6.xyz * r0.www;
  r8.zw = float2(1024,1024) + r0.xz;
  r8.zw = float2(0.00048828125,0.00048828125) * r8.zw;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r8.zw).xyzw;
  r1.w = 50 + r9.x;
  r3.w = r9.x + -r1.w;
  r1.w = -r1.w + r0.y;
  r3.w = 1 / r3.w;
  r1.w = saturate(r3.w * r1.w);
  r3.w = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r3.w * r1.w;
  r1.w = 0.5 * r1.w;
  r1.w = min(1, r1.w);
  r1.xw = float2(1,1) + -r1.zw;
  r3.w = saturate(r7.w + r7.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r1.x * 0.699999988 + 1.70000005;
  r4.w = r4.w * r1.x;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r1.www;
  r4.xyz = r4.xyz * r3.www;
  r9.xyz = float3(3,3,3) * r4.xyz;
  r1.w = saturate(dot(r2.xyz, -r3.xyz));
  r1.x = r1.x * r1.x;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r0.w = r1.z + -r0.w;
  r0.w = saturate(1 + r0.w);
  r2.xyz = r1.xxx * r9.xyz;
  r1.x = 1 + -r1.w;
  r1.z = r1.x * r1.x;
  r1.z = r1.z * r1.z;
  r1.x = r1.z * r1.x;
  r3.xyz = r0.www + -r7.xyz;
  r3.xyz = r1.xxx * r3.xyz + r7.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.x * 0.75 + 0.00999999978;
  r1.xzw = r3.xyz * r0.www;
  r1.xzw = float3(0.25,0.25,0.25) * r1.xzw;
  r1.xzw = r2.xyz * float3(0.75,0.75,0.75) + r1.xzw;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r6.xyz * r5.xyz;
  r0.yzw = r0.yzw * r6.www + r1.xzw;
  r1.x = r1.y * 5000 + 1000;
  r8.x = saturate(r8.x);
  r8.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r8.xy).xyzw;
  r1.z = r8.x * 10 + 5;
  r2.xyz = r3.xyz * r1.zzz;
  r1.x = saturate(0.00100000005 * r1.x);
  r1.z = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.z * r1.x;
  r1.xzw = r2.xyz * r1.xxx;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 40f42945efe627a4: 2 retail keyword combination(s)
void ps_40f42945efe627a4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r6.x = 0.263157904 * r1.y;
  r7.xyz = r1.xxy * float3(0.590000033,0.590000033,5000) + float3(0.209999993,0.169999987,1000);
  r0.w = r1.x * r7.y + 0.0399999991;
  r1.x = -r1.x * 0.959999979 + 0.959999979;
  r1.w = r7.x * r1.x;
  r3.w = 1 + -r1.z;
  r7.xy = float2(1024,1024) + r0.xz;
  r7.xy = float2(0.00048828125,0.00048828125) * r7.xy;
  r8.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r7.xy).xyzw;
  r4.w = 50 + r8.x;
  r5.w = r8.x + -r4.w;
  r4.w = -r4.w + r0.y;
  r5.w = 1 / r5.w;
  r4.w = saturate(r5.w * r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r4.w = 0.5 * r4.w;
  r4.w = min(1, r4.w);
  r4.w = 1 + -r4.w;
  r5.w = -0.25 + r6.w;
  r5.w = saturate(r5.w + r5.w);
  r6.z = r5.w * -2 + 3;
  r5.w = r5.w * r5.w;
  r5.w = r6.z * r5.w;
  r6.z = -r3.w * 0.699999988 + 1.70000005;
  r6.z = r6.z * r3.w;
  r6.z = 6 * r6.z;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r6.z).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = r4.xyz * r5.www;
  r7.xyw = float3(3,3,3) * r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r2.y = r3.w * r3.w;
  r2.y = r2.y * r2.y + 1;
  r2.y = 1 / r2.y;
  r1.x = r1.z + -r1.x;
  r1.x = saturate(1 + r1.x);
  r3.xyz = r2.yyy * r7.xyw;
  r1.z = 1 + -r2.x;
  r2.x = r1.z * r1.z;
  r2.x = r2.x * r2.x;
  r1.z = r2.x * r1.z;
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r2.xyz = r3.xyz * r0.www;
  r3.xyz = float3(2.98832679,2.98832679,2.98832679) * r4.xyz;
  r0.w = r1.z * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.www;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r6.x = saturate(r6.x);
  r6.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r6.xy).xyzw;
  r1.x = r6.x * 10 + 5;
  r1.xzw = r3.xyz * r1.xxx;
  r2.x = saturate(0.00100000005 * r7.z);
  r2.y = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r2.x = r2.y * r2.x;
  r1.xzw = r2.xxx * r1.xzw;
  r2.x = cmp(r2.w >= 0.899999976);
  r2.x = r2.x ? 1.000000 : 0;
  r1.xzw = r2.xxx * r1.xzw;
  r1.xyz = r1.xzw * r1.yyy;
  r1.w = -13 + _EV;
  r1.w = exp2(r1.w);
  r0.yzw = r1.xyz * r1.www + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 46c049175efa4884: 128 retail keyword combination(s)
void ps_46c049175efa4884_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy / v1.ww;
  r1.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r0.z = cmp(r1.w == 0.333333343);
  [branch] if (r0.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.z = cmp(0.999000013 < r0.z);
  [branch] if (r0.z != 0) {
    r0.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r0.xy).xyzw;
    o0.xyz = r0.xyz;
    o0.w = 1;
    return;
  }
  o0.xyzw = float4(0,0,0,1);
  return;
}


// ps bb5bf3d7d84ec2d1: 4 retail keyword combination(s)
void ps_bb5bf3d7d84ec2d1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 3306ed24a4e73e3f: 2 retail keyword combination(s)
void ps_3306ed24a4e73e3f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 417114f78a174121: 2 retail keyword combination(s)
void ps_417114f78a174121_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps a508b25a44c123d1: 2 retail keyword combination(s)
void ps_a508b25a44c123d1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps fc41ec93e06ba57a: 2 retail keyword combination(s)
void ps_fc41ec93e06ba57a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps d3a416d02cd7a29f: 2 retail keyword combination(s)
void ps_d3a416d02cd7a29f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r9.x;
  r4.w = r9.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = saturate(r8.w + r8.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 2a24bd81ebab94bf: 2 retail keyword combination(s)
void ps_2a24bd81ebab94bf_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r7.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r7.x;
  r4.w = r7.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r7.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r7.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r7.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 1fc0a5dcbda6982f: 4 retail keyword combination(s)
void ps_1fc0a5dcbda6982f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 8f6b0bf307fbab9d: 4 retail keyword combination(s)
void ps_8f6b0bf307fbab9d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 48aa4fdb97af6415: 2 retail keyword combination(s)
void ps_48aa4fdb97af6415_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 02dc06d4ad268912: 2 retail keyword combination(s)
void ps_02dc06d4ad268912_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 70bc556c39d344f3: 2 retail keyword combination(s)
void ps_70bc556c39d344f3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r9.x;
  r4.w = r9.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = saturate(r8.w + r8.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps df51cbd48bb254a5: 2 retail keyword combination(s)
void ps_df51cbd48bb254a5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r7.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r7.x;
  r4.w = r7.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r7.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r7.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r7.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 6fc79c276050b53a: 4 retail keyword combination(s)
void ps_6fc79c276050b53a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps bb8f789917bded97: 2 retail keyword combination(s)
void ps_bb8f789917bded97_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps b67db1efb91ca7c4: 2 retail keyword combination(s)
void ps_b67db1efb91ca7c4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps c6a81d34a4710e7f: 2 retail keyword combination(s)
void ps_c6a81d34a4710e7f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 3ffe4b16c0a04597: 2 retail keyword combination(s)
void ps_3ffe4b16c0a04597_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 7ad426119d8ab0d3: 2 retail keyword combination(s)
void ps_7ad426119d8ab0d3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r9.x;
  r4.w = r9.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = saturate(r8.w + r8.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 7b1c78b7a3d5fc72: 2 retail keyword combination(s)
void ps_7b1c78b7a3d5fc72_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r7.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r7.x;
  r4.w = r7.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r7.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r7.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r7.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps c95a15da0c10dc37: 4 retail keyword combination(s)
void ps_c95a15da0c10dc37_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 59dbafc9f4bb85bc: 4 retail keyword combination(s)
void ps_59dbafc9f4bb85bc_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps ce8ee28518e12683: 2 retail keyword combination(s)
void ps_ce8ee28518e12683_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps f1d1ca5e3ebbbf29: 2 retail keyword combination(s)
void ps_f1d1ca5e3ebbbf29_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 822792b667b9e02f: 2 retail keyword combination(s)
void ps_822792b667b9e02f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r9.x;
  r4.w = r9.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = saturate(r8.w + r8.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps aec40b7c140c383e: 2 retail keyword combination(s)
void ps_aec40b7c140c383e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r7.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r7.x;
  r4.w = r7.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r7.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r7.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r7.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps ae91d8af7ad5e47a: 2 retail keyword combination(s)
void ps_ae91d8af7ad5e47a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 6cea563486f3907a: 4 retail keyword combination(s)
void ps_6cea563486f3907a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps e6605e4622eb77f8: 2 retail keyword combination(s)
void ps_e6605e4622eb77f8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps ef554063f70e9836: 2 retail keyword combination(s)
void ps_ef554063f70e9836_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps d40d666e744dba09: 2 retail keyword combination(s)
void ps_d40d666e744dba09_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps c0e840c510c88f0c: 2 retail keyword combination(s)
void ps_c0e840c510c88f0c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r9.x;
  r4.w = r9.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = saturate(r8.w + r8.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 7381f6f1dbed6719: 2 retail keyword combination(s)
void ps_7381f6f1dbed6719_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r7.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r7.x;
  r4.w = r7.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r7.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r7.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r7.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 8ca288d0ea8ac9a5: 4 retail keyword combination(s)
void ps_8ca288d0ea8ac9a5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 2b5c0e5576304af4: 4 retail keyword combination(s)
void ps_2b5c0e5576304af4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 9de70b28b2134a59: 2 retail keyword combination(s)
void ps_9de70b28b2134a59_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps c80b755eeae75a93: 2 retail keyword combination(s)
void ps_c80b755eeae75a93_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps eee8cde4d77889c5: 2 retail keyword combination(s)
void ps_eee8cde4d77889c5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r9.x;
  r4.w = r9.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = saturate(r8.w + r8.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 3546464377e262d8: 2 retail keyword combination(s)
void ps_3546464377e262d8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r7.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r7.x;
  r4.w = r7.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r7.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r7.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r7.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 5e917d5498c19dec: 4 retail keyword combination(s)
void ps_5e917d5498c19dec_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 820d425aac12e4dc: 4 retail keyword combination(s)
void ps_820d425aac12e4dc_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 61b093a581d26180: 2 retail keyword combination(s)
void ps_61b093a581d26180_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 1285f6f2e189862c: 2 retail keyword combination(s)
void ps_1285f6f2e189862c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 1b7ad0b155df8df9: 2 retail keyword combination(s)
void ps_1b7ad0b155df8df9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r9.x;
  r4.w = r9.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = saturate(r8.w + r8.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r2.y = 1 + -r7.x;
  r1.z = saturate(r2.y + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r4.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www;
  r0.yzw = r2.yzw * r3.xyz + r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 67ca6fa1eb185d13: 2 retail keyword combination(s)
void ps_67ca6fa1eb185d13_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r7.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r7.x;
  r4.w = r7.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r7.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r7.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r7.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = 1 + -r1.y;
  r1.y = saturate(r1.z + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r0.w = r0.w * r1.y + r1.w;
  r1.yzw = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r1.yzw, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r1.xyz = r5.xyz * r1.xxx;
  r1.xyz = r1.xyz * r6.www;
  r0.yzw = r2.yzw * r0.www + r1.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 8e0b5ec27220a937: 4 retail keyword combination(s)
void ps_8e0b5ec27220a937_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps beb9aeaff379f8e8: 4 retail keyword combination(s)
void ps_beb9aeaff379f8e8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 149232ed48dfdbf7: 2 retail keyword combination(s)
void ps_149232ed48dfdbf7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r3.w = saturate(r8.w + r8.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps f02da0e326b87100: 2 retail keyword combination(s)
void ps_f02da0e326b87100_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r3.w = -0.25 + r6.w;
  r3.w = saturate(r3.w + r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r4.w = -r0.w * 0.699999988 + 1.70000005;
  r4.w = r4.w * r0.w;
  r4.w = 6 * r4.w;
  r4.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r4.w).xyzw;
  r4.w = -1 + r4.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r4.xyz = r4.www * r4.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps e533b0fe073fd788: 2 retail keyword combination(s)
void ps_e533b0fe073fd788_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r0.w = cmp(r2.w == 0.666666687);
  r7.xyz = float3(0.980400026,0.980400026,0.980400026) * r6.xyz;
  r8.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,-0.25) + r6.xyzw;
  r9.yzw = r1.xxx * r8.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r9.x = -r1.x * 0.959999979 + 0.959999979;
  r1.xyw = r9.xxx * r6.xyz;
  r1.xyw = r0.www ? r7.xyz : r1.xyw;
  r7.xyzw = r0.wwww ? float4(0.980400026,0.0195999984,0.0195999984,0.0195999984) : r9.xyzw;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r9.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r9.x;
  r4.w = r9.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = saturate(r8.w + r8.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r8.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r8.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r8.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.z = -r7.x + r1.z;
  r1.z = saturate(1 + r1.z);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r2.x = r0.w * r0.w;
  r2.x = r2.x * r2.x;
  r0.w = r2.x * r0.w;
  r3.xyz = r1.zzz + -r7.yzw;
  r3.xyz = r0.www * r3.xyz + r7.yzw;
  r2.xyz = r3.xyz * r2.yzw;
  r3.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r3.xyz = r3.xyz * r0.www;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r2.xyz = r2.xyz * float3(0.75,0.75,0.75) + r3.xyz;
  r3.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r3.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xyw;
  r0.yzw = r0.yzw * r6.www + r2.xyz;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 4291a9ee1487679b: 2 retail keyword combination(s)
void ps_4291a9ee1487679b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v2.z;
  r0.xyz = v2.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r2.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r1.z = dot(r3.xyz, r2.xyz);
  r1.z = r1.z + r1.z;
  r4.xyz = r2.xyz * -r1.zzz + r3.xyz;
  r1.z = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r1.z != 0) {
    r5.xyz = -unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMin.xyz;
    r6.xyz = unity_SpecCube1_ProbePosition.www + unity_SpecCube0_BoxMax.xyz;
    r1.z = dot(r4.xyz, r4.xyz);
    r1.z = rsqrt(r1.z);
    r7.xyz = r4.xyz * r1.zzz;
    r6.xyz = r6.xyz + -r0.xyz;
    r6.xyz = r6.xyz / r7.xyz;
    r5.xyz = r5.xyz + -r0.xyz;
    r5.xyz = r5.xyz / r7.xyz;
    r8.xyz = cmp(float3(0,0,0) < r7.xyz);
    r5.xyz = r8.xyz ? r6.xyz : r5.xyz;
    r1.z = min(r5.x, r5.y);
    r1.z = min(r1.z, r5.z);
    r5.xyz = -unity_SpecCube0_ProbePosition.xyz + r0.xyz;
    r4.xyz = r7.xyz * r1.zzz + r5.xyz;
  }
  r1.z = cmp(r2.w == 0.333333343);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r5.xyzw = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3, r1.xy).xyzw;
  r0.w = cmp(0.999000013 < r0.w);
  [branch] if (r0.w != 0) {
    o0.xyz = r5.xyz;
    o0.w = 1;
    return;
  }
  r6.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, r1.xy).xyzw;
  r1.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r1.xy).xyzw;
  r1.yw = r1.xx * float2(0.590000033,0.590000033) + float2(0.209999993,0.169999987);
  r0.w = cmp(r2.w == 0.666666687);
  r3.w = 0.980400026 * r1.y;
  r6.y = r1.x * r1.w + 0.0399999991;
  r6.x = -r1.x * 0.959999979 + 0.959999979;
  r1.x = r6.x * r1.y;
  r1.x = r0.w ? r3.w : r1.x;
  r1.yw = r0.ww ? float2(0.980400026,0.0195999984) : r6.xy;
  r0.w = 1 + -r1.z;
  r6.xy = float2(1024,1024) + r0.xz;
  r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
  r7.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r6.xy).xyzw;
  r3.w = 50 + r7.x;
  r4.w = r7.x + -r3.w;
  r3.w = -r3.w + r0.y;
  r4.w = 1 / r4.w;
  r3.w = saturate(r4.w * r3.w);
  r4.w = r3.w * -2 + 3;
  r3.w = r3.w * r3.w;
  r3.w = r4.w * r3.w;
  r3.w = 0.5 * r3.w;
  r3.w = min(1, r3.w);
  r3.w = 1 + -r3.w;
  r4.w = -0.25 + r6.w;
  r4.w = saturate(r4.w + r4.w);
  r5.w = r4.w * -2 + 3;
  r4.w = r4.w * r4.w;
  r4.w = r5.w * r4.w;
  r5.w = -r0.w * 0.699999988 + 1.70000005;
  r5.w = r5.w * r0.w;
  r5.w = 6 * r5.w;
  r7.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r4.xyz, r5.w).xyzw;
  r4.x = -1 + r7.w;
  r4.x = unity_SpecCube0_HDR.w * r4.x + 1;
  r4.x = log2(r4.x);
  r4.x = unity_SpecCube0_HDR.y * r4.x;
  r4.x = exp2(r4.x);
  r4.x = unity_SpecCube0_HDR.x * r4.x;
  r4.xyz = r4.xxx * r7.xyz;
  r4.xyz = _BT_ReflectionIntensity.xxx * r4.xyz;
  r4.xyz = r4.xyz * r3.www;
  r4.xyz = r4.xyz * r4.www;
  r4.xyz = float3(3,3,3) * r4.xyz;
  r3.w = cmp(0 < r2.w);
  r2.w = cmp(r2.w < 0.5);
  r2.w = r2.w ? r3.w : 0;
  r4.xyz = r2.www ? float3(0,0,0) : r4.xyz;
  r2.x = saturate(dot(r2.xyz, -r3.xyz));
  r0.w = r0.w * r0.w;
  r0.w = r0.w * r0.w + 1;
  r0.w = 1 / r0.w;
  r1.y = r1.z + -r1.y;
  r1.y = saturate(1 + r1.y);
  r2.yzw = r0.www * r4.xyz;
  r0.w = 1 + -r2.x;
  r1.z = r0.w * r0.w;
  r1.z = r1.z * r1.z;
  r0.w = r1.z * r0.w;
  r1.y = r1.y + -r1.w;
  r1.y = r0.w * r1.y + r1.w;
  r1.yzw = r2.yzw * r1.yyy;
  r2.xyz = float3(0.996108949,0.996108949,0.996108949) * r4.xyz;
  r0.w = r0.w * 0.75 + 0.00999999978;
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r1.yzw = r1.yzw * float3(0.75,0.75,0.75) + r2.xyz;
  r2.xyz = -unity_SpecCube0_BoxMax.xyz + r0.xyz;
  r0.xyz = unity_SpecCube0_BoxMin.xyz + -r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = r0.x / unity_SpecCube1_ProbePosition.w;
  r0.x = saturate(1 + -r0.x);
  r0.yzw = r5.xyz * r1.xxx;
  r0.yzw = r0.yzw * r6.www + r1.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float3 o2 = 0;
		vs_d1696a61e9856034_impl(v.position0, v.normal0.xyz, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1.xyz = o2;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r = (fout)0;
#if !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_3bec7143ebca6f05_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_47dbfb91a9a64ed9_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_26508f5bc0b0a985_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_d19fba7fc9d6a5c9_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_d0fe8e707059ff92_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_f674a6afcdaa735c_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_ed0dde713633e5ef_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_089266b46e4b4323_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_a90032be74feb038_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_5670ab94e2a93369_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_25e116f2f1cc7e1f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_3bbad50732791a26_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_6052b207c2105fd1_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_3133dfdfc3aa4713_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_48f59423fcddb526_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_5b23c4eb614bc3a8_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_c02de1fa4850a779_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_c0b39ac668df28b6_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_ba20c195c8b866dd_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_4252afa3a7d4a3d9_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_39fbcdaa53b3bb9e_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_7607b145d0653638_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_d5bf1b6e6cb68b7f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_e3e1fbdb424b78c4_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_851378f52c95c205_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_ec8133398bb2017c_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_LOADINGSCREEN) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_fdec60988bdb9e2f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_0c224e8bcdbdb4d7_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_9e3670cf6b9ac97c_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_20d26a96982b9cd0_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_9e6a73ed1d09f54d_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_5516fed3b9555ffd_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_12fb276ba9b78642_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_18302c0504422732_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_820823829ad4e8fa_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_16669c0dc368dc6e_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_f5344e350239eab6_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_2176d34b9120d982_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_e357b3b7fe006f0f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_23bc4d47ec76d4d2_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_c440beb2267c6793_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_3a9e4677ef801c93_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_f5f4be6315711387_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_b827fed951424a58_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_d8f7f8b06806b33c_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_bac2e2f1ecfb2a4a_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_fb1fd56292fdb230_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_5d149882a230e502_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_8832160b5d135afb_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_424ae23d77874191_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_96f81340781b2c26_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && !defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_40f42945efe627a4_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_LOADINGSCREEN) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_46c049175efa4884_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_bb5bf3d7d84ec2d1_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_3306ed24a4e73e3f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_417114f78a174121_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_a508b25a44c123d1_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_fc41ec93e06ba57a_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_d3a416d02cd7a29f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_2a24bd81ebab94bf_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_1fc0a5dcbda6982f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_8f6b0bf307fbab9d_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_48aa4fdb97af6415_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_02dc06d4ad268912_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_70bc556c39d344f3_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_df51cbd48bb254a5_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_6fc79c276050b53a_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_bb8f789917bded97_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_b67db1efb91ca7c4_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_c6a81d34a4710e7f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_3ffe4b16c0a04597_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_7ad426119d8ab0d3_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_7b1c78b7a3d5fc72_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_c95a15da0c10dc37_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE)
	{
		float4 o0 = 0;
		ps_59dbafc9f4bb85bc_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_ce8ee28518e12683_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_f1d1ca5e3ebbbf29_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_822792b667b9e02f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && !defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_aec40b7c140c383e_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_ae91d8af7ad5e47a_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_6cea563486f3907a_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_e6605e4622eb77f8_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_ef554063f70e9836_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_d40d666e744dba09_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_c0e840c510c88f0c_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_7381f6f1dbed6719_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_8ca288d0ea8ac9a5_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_2b5c0e5576304af4_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_9de70b28b2134a59_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_c80b755eeae75a93_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_eee8cde4d77889c5_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && !defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_3546464377e262d8_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_5e917d5498c19dec_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_820d425aac12e4dc_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_61b093a581d26180_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_1285f6f2e189862c_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_1b7ad0b155df8df9_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && !defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_67ca6fa1eb185d13_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_8e0b5ec27220a937_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE)
	{
		float4 o0 = 0;
		ps_beb9aeaff379f8e8_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_149232ed48dfdbf7_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && !defined(_URBAN)
	{
		float4 o0 = 0;
		ps_f02da0e326b87100_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && !defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_e533b0fe073fd788_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_CUSTOM_REFLECTION) && defined(_BT_ONLYLIT) && defined(_BT_SIM_GAME) && !defined(_LOADINGSCREEN) && defined(_OVERLAY_RAIN) && defined(_PORTRAITCAM) && defined(_SPACE) && defined(_URBAN)
	{
		float4 o0 = 0;
		ps_4291a9ee1487679b_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#else
	{ r = (fout)0; }
#endif
	return r;
}
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest Always
			Cull Off
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ UNITY_HDR_ON

#define cmp -

Texture2D _CameraReflectionsTexture;
SamplerState sampler_CameraReflectionsTexture;


struct appdata
{
	float4 position0 : POSITION0;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
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

// vs 56d2c20469bcaeb5: 2 retail keyword combination(s)
void vs_56d2c20469bcaeb5_impl(
  float4 v0 : POSITION0,
  inout float2 o0 : TEXCOORD0,
  inout float4 o1 : SV_POSITION0)
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
  r1.x = _ProjectionParams.x * r0.y;
  r1.w = 0.5 * r1.x;
  r1.xz = float2(0.5,0.5) * r0.xw;
  o1.xyzw = r0.xyzw;
  o0.xy = r1.xw + r1.zz;
  return;
}


// ps e860abc1ff539bae: 1 retail keyword combination(s)
void ps_e860abc1ff539bae_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraReflectionsTexture.Sample(sampler_CameraReflectionsTexture, v0.xy).xyzw;
  o0.xyz = exp2(-r0.xyz);
  o0.w = 1;
  return;
}


// ps 76e5e517046a4a01: 1 retail keyword combination(s)
void ps_76e5e517046a4a01_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = _CameraReflectionsTexture.Sample(sampler_CameraReflectionsTexture, v0.xy).xyzw;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_56d2c20469bcaeb5_impl(v.position0, o0, o1);
		o.texcoord0.xy = o0;
		o.sv_position = o1;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r = (fout)0;
#if !defined(UNITY_HDR_ON)
	{
		float4 o0 = 0;
		ps_e860abc1ff539bae_impl(i.texcoord0.xy, i.sv_position, o0);
		r.t0 = o0;
	}
#elif defined(UNITY_HDR_ON)
	{
		float4 o0 = 0;
		ps_76e5e517046a4a01_impl(i.texcoord0.xy, i.sv_position, o0);
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
