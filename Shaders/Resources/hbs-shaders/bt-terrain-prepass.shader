Shader "Hidden/BT-Terrain-FarPass"
{
	Properties
	{
		[HideInInspector] _Control ("Control (RGBA)", 2D) = "red" {}
		[HideInInspector] _ControlA ("Control A(RGBA)", 2D) = "red" {}
		[HideInInspector] _ControlB ("Control B(RGBA)", 2D) = "red" {}
		[HideInInspector] _HSV ("HSV", 2D) = "gray" {}
		[HideInInspector] _GlobalColor ("Global Color", 2D) = "white" {}
		[HideInInspector] _AlbedoArray ("Albedo Array", 2DArray) = "white" {}
		[HideInInspector] _NormalArray ("Normal Array", 2DArray) = "white" {}
		[HideInInspector] _HeightArray ("Normal Array", 2DArray) = "white" {}
		[HideInInspector] _HeightRange0 ("Height Range", Vector) = (0,0,0,0)
		[HideInInspector] _HeightRange1 ("Height Range", Vector) = (0,0,0,0)
		_TilingFactor ("Tiling Factor", Float) = 16
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Tags { "RenderType"="Opaque" }
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ DIRLIGHTMAP_OFF
			#pragma multi_compile _ DIRLIGHTMAP_SEPARATE
			#pragma multi_compile _ DYNAMICLIGHTMAP_OFF
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_OFF
			#pragma multi_compile _ UNITY_HDR_ON

#define cmp -

Texture2D _ControlA;
SamplerState sampler_ControlA;
Texture2D _ControlB;
SamplerState sampler_ControlB;
Texture2DArray _AlbedoArray;
SamplerState sampler_AlbedoArray;
Texture2DArray _NormalArray;
SamplerState sampler_NormalArray;
Texture2DArray _HeightArray;

float _TilingFactor;
float4 _BT_SunlightDirection;
float _HeightBlend;
float4 _HeightRange0;
float4 _HeightRange1;
float _TerrainBias;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};

#if !defined(DYNAMICLIGHTMAP_ON)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord6 : TEXCOORD6;
	float4 texcoord7 : TEXCOORD7;
};
#elif defined(DYNAMICLIGHTMAP_ON)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord6 : TEXCOORD6;
	float4 texcoord7 : TEXCOORD7;
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
};

// vs d8ef705a8ffc438e: 6 retail keyword combination(s)
void vs_d8ef705a8ffc438e_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  float2 v2 : TEXCOORD1,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xy = v1.xy;
  r1.xyzw = _TilingFactor.xxxx * r0.xzxy;
  o1.zw = -r1.xy * float2(0.001953125,0.001953125) + float2(1,1);
  r1.xy = _TilingFactor.xx * r0.zy;
  o2.xyzw = float4(0.001953125,0.001953125,0.001953125,0.001953125) * r1.zwxy;
  r1.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o8.xyz = r0.xyz;
  r0.x = dot(r1.xyz, r1.xyz);
  o3.xyz = r1.xyz;
  o3.w = sqrt(r0.x);
  o4.xyzw = float4(0,0,0,0);
  r0.xyz = float3(0,1,0) * v3.zxy;
  r0.xyz = v3.yzx * float3(1,0,0) + -r0.xyz;
  r0.w = dot(r0.xy, r0.xy);
  r0.w = rsqrt(r0.w);
  o5.xyz = r0.xyz * r0.www;
  o5.w = _BT_SunlightDirection.x;
  r1.xyz = v3.zxy * r0.yzx;
  r0.xyz = v3.yzx * r0.zxy + -r1.xyz;
  r0.xyz = -unity_WorldTransformParams.www * r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o6.xyz = r0.xyz * r0.www;
  o6.w = _BT_SunlightDirection.y;
  r0.x = dot(v3.xyz, v3.xyz);
  r0.x = rsqrt(r0.x);
  o7.xyz = v3.xyz * r0.xxx;
  o7.w = _BT_SunlightDirection.z;
  o8.w = 1;
  return;
}


// vs 70bfab99e1b6dfa8: 2 retail keyword combination(s)
void vs_70bfab99e1b6dfa8_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float2 v3 : TEXCOORD2,
  float3 v4 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xy = v1.xy;
  r1.xyzw = _TilingFactor.xxxx * r0.xzxy;
  o1.zw = -r1.xy * float2(0.001953125,0.001953125) + float2(1,1);
  r1.xy = _TilingFactor.xx * r0.zy;
  o2.xyzw = float4(0.001953125,0.001953125,0.001953125,0.001953125) * r1.zwxy;
  r1.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o8.xyz = r0.xyz;
  r0.x = dot(r1.xyz, r1.xyz);
  o3.xyz = r1.xyz;
  o3.w = sqrt(r0.x);
  o4.zw = v3.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o4.xy = float2(0,0);
  r0.xyz = float3(0,1,0) * v4.zxy;
  r0.xyz = v4.yzx * float3(1,0,0) + -r0.xyz;
  r0.w = dot(r0.xy, r0.xy);
  r0.w = rsqrt(r0.w);
  o5.xyz = r0.xyz * r0.www;
  o5.w = _BT_SunlightDirection.x;
  r1.xyz = v4.zxy * r0.yzx;
  r0.xyz = v4.yzx * r0.zxy + -r1.xyz;
  r0.xyz = -unity_WorldTransformParams.www * r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o6.xyz = r0.xyz * r0.www;
  o6.w = _BT_SunlightDirection.y;
  r0.x = dot(v4.xyz, v4.xyz);
  r0.x = rsqrt(r0.x);
  o7.xyz = v4.xyz * r0.xxx;
  o7.w = _BT_SunlightDirection.z;
  o8.w = 1;
  return;
}


// ps b36ce64ad90a53d5: 8 retail keyword combination(s)
void ps_b36ce64ad90a53d5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _ControlA.Sample(sampler_ControlA, v1.xy).xyzw;
  r1.xyzw = _ControlB.Sample(sampler_ControlB, v1.xy).xyzw;
  r2.xyz = float3(-0.5,-0.5,-0.5) + abs(v7.yzx);
  r2.xyz = float3(7,7,7) * r2.xyz;
  r2.xyz = max(float3(9.99999975e-005,9.99999975e-005,9.99999975e-005), r2.xyz);
  r2.w = dot(r2.xyz, r2.xyz);
  r2.w = rsqrt(r2.w);
  r2.xyz = r2.xyz * r2.www;
  r2.w = dot(r2.zxy, float3(1,1,1));
  r2.xyz = r2.xyz / r2.www;
  r3.xyz = cmp(r2.zxy < float3(0.75,0.75,0.75));
  r2.w = r3.y ? r3.x : 0;
  r2.w = r3.z ? r2.w : 0;
  r3.xy = _TilingFactor.xx * -v8.xz;
  r3.xy = float2(0.001953125,0.001953125) * r3.xy;
  r4.xyzw = _TilingFactor.xxxx * v8.xyyz;
  r5.xyzw = float4(0.001953125,-0.001953125,0.001953125,0.001953125) * r4.xzyw;
  r4.yw = cmp(v7.xz < float2(0,0));
  r4.xz = -r4.zx * float2(-0.001953125,0.001953125) + float2(1,1);
  r5.xy = r4.yw ? r4.xz : r5.yx;
  r4.xyz = ddx(r3.xyx);
  r6.xyz = ddy(r3.xyx);
  [branch] if (r2.w == 0) {
    r7.xyz = cmp(r2.xyz >= float3(0.25,0.25,0.25));
    r7.xyz = r7.xyz ? float3(1,1,1) : 0;
    r8.xy = r7.xx * r3.xy;
    r7.xw = -r7.xx * r3.xy + r5.yz;
    r7.xy = r7.yy * r7.xw + r8.xy;
    r8.xy = -r7.xy + r5.xw;
    r7.xy = r7.zz * r8.xy + r7.xy;
    r8.xyz = _TerrainBias.xxx * r4.zyz;
    r9.xyz = _TerrainBias.xxx * r6.zyz;
    r10.xyz = r8.zyz + r8.zyz;
    r11.xyz = r9.zyz + r9.zyz;
    r7.zw = float2(0,1);
    r12.xyzw = _HeightArray.SampleGrad(sampler_AlbedoArray, r7.xyz, r10.zyz, r11.zyz).xyzw;
    r10.xyzw = _HeightArray.SampleGrad(sampler_AlbedoArray, r7.xyw, r10.xyz, r11.xyz).xyzw;
    r11.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r12.xyzw;
    r11.xyzw = _HeightRange0.xyzw * r11.xyzw + float4(0.5,0.5,0.5,0.5);
    r10.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r10.xyzw;
    r12.xw = r1.xw;
    r12.y = 0.5;
    r10.xyzw = _HeightRange1.xyzw * r10.xyzw + r12.xyyw;
    r2.w = 1 + -r0.x;
    r12.xyzw = r11.xyzw + r0.xyzw;
    r4.w = cmp(r2.w < r12.x);
    r2.w = -r12.x + r2.w;
    r2.w = saturate(r2.w / _HeightBlend);
    r2.w = 1 + -r2.w;
    r2.w = r4.w ? 1 : r2.w;
    r13.x = r2.w * r0.x;
    r2.w = r13.x * r11.x;
    r4.w = r13.x * r11.x + -r0.y;
    r4.w = 1 + r4.w;
    r6.w = cmp(r4.w < r12.y);
    r4.w = r4.w + -r12.y;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r13.y = r4.w * r0.y;
    r4.w = -r13.x * r11.x + r11.y;
    r2.w = r13.y * r4.w + r2.w;
    r4.w = r2.w + -r0.z;
    r4.w = 1 + r4.w;
    r6.w = cmp(r4.w < r12.z);
    r4.w = r4.w + -r12.z;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r13.z = r4.w * r0.z;
    r4.w = r11.z + -r2.w;
    r2.w = r13.z * r4.w + r2.w;
    r4.w = r2.w + -r0.w;
    r4.w = 1 + r4.w;
    r6.w = cmp(r4.w < r12.w);
    r4.w = r4.w + -r12.w;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r13.w = r4.w * r0.w;
    r4.w = r11.w + -r2.w;
    r2.w = r13.w * r4.w + r2.w;
    r4.w = r2.w + -r1.x;
    r4.w = 1 + r4.w;
    r10.xw = float2(0.5,0.5) + r10.xw;
    r6.w = cmp(r4.w < r10.x);
    r4.w = -r10.x + r4.w;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r12.x = r4.w * r1.x;
    r4.w = r11.x + -r2.w;
    r2.w = r12.x * r4.w + r2.w;
    r4.w = r2.w + -r1.y;
    r4.w = 1 + r4.w;
    r11.xy = r10.yz + r1.yz;
    r6.w = cmp(r4.w < r11.x);
    r4.w = -r11.x + r4.w;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r12.y = r4.w * r1.y;
    r4.w = r10.y + -r2.w;
    r2.w = r12.y * r4.w + r2.w;
    r4.w = r2.w + -r1.z;
    r4.w = 1 + r4.w;
    r6.w = cmp(r4.w < r11.y);
    r4.w = r4.w + -r11.y;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r12.z = r4.w * r1.z;
    r4.w = r10.z + -r2.w;
    r2.w = r12.z * r4.w + r2.w;
    r2.w = r2.w + -r1.w;
    r2.w = 1 + r2.w;
    r4.w = cmp(r2.w < r10.w);
    r2.w = r2.w + -r10.w;
    r2.w = saturate(r2.w / _HeightBlend);
    r2.w = 1 + -r2.w;
    r2.w = r4.w ? 1 : r2.w;
    r12.w = r2.w * r1.w;
    r2.w = dot(r13.xyzw, float4(1,1,1,1));
    r4.w = dot(r12.xyzw, float4(1,1,1,1));
    r2.w = r4.w + r2.w;
    r10.xyzw = r13.xyzw / r2.wwww;
    r11.xyzw = r12.xyzw / r2.wwww;
    r2.w = cmp(r2.w < 0.00999999978);
    r10.xyzw = r2.wwww ? float4(1,0,0,0) : r10.xyzw;
    r11.xyzw = r2.wwww ? float4(0,0,0,0) : r11.xyzw;
    r12.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r7.xyz, r8.zyz, r9.zyz).xyzw;
    r13.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r7.xyw, r8.zyz, r9.zyz).xyzw;
    r14.xy = r7.xy;
    r14.zw = float2(2,3);
    r15.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r14.xyz, r8.zyz, r9.zyz).xyzw;
    r16.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r14.xyw, r8.zyz, r9.zyz).xyzw;
    r13.xyzw = r13.xyzw * r10.yyyy;
    r12.xyzw = r12.xyzw * r10.xxxx + r13.xyzw;
    r12.xyzw = r15.xyzw * r10.zzzz + r12.xyzw;
    r12.xyzw = r16.xyzw * r10.wwww + r12.xyzw;
    r13.xyzw = _NormalArray.SampleGrad(sampler_AlbedoArray, r7.xyz, r8.zyz, r9.zyz).xzyw;
    r7.xyzw = _NormalArray.SampleGrad(sampler_AlbedoArray, r7.xyw, r8.zyz, r9.zyz).xzyw;
    r15.x = 0;
    r15.yw = r13.xz;
    r13.x = 0;
    r13.xyzw = r13.xyxw * r10.yyyy;
    r13.xyzw = r15.xyxw * r10.xxxx + r13.xyzw;
    r15.x = 0;
    r15.yw = r7.xz;
    r13.xyzw = r15.xyxw * r10.zzzz + r13.xyzw;
    r7.x = 0;
    r7.xyzw = r7.xyxw * r10.wwww + r13.xyzw;
    r10.xy = r14.xy;
    r10.zw = float2(4,5);
    r13.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyz, r8.zyz, r9.zyz).xyzw;
    r15.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyw, r8.zyz, r9.zyz).xyzw;
    r10.zw = float2(6,7);
    r16.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyz, r8.zyz, r9.zyz).xyzw;
    r10.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyw, r8.zyz, r9.zyz).xyzw;
    r12.xyzw = r13.xyzw * r11.xxxx + r12.xyzw;
    r12.xyzw = r15.xyzw * r11.yyyy + r12.xyzw;
    r12.xyzw = r16.xyzw * r11.zzzz + r12.xyzw;
    o0.xyzw = r10.xyzw * r11.wwww + r12.xyzw;
    r10.xyzw = _NormalArray.SampleGrad(sampler_AlbedoArray, r14.xyz, r8.zyz, r9.zyz).xzyw;
    r8.xyzw = _NormalArray.SampleGrad(sampler_AlbedoArray, r14.xyw, r8.xyz, r9.xyz).xzyw;
    r9.x = 0;
    r9.yw = r10.xz;
    r7.xyzw = r9.xyxw * r11.xxxx + r7.xyzw;
    r10.x = 0;
    r7.xyzw = r10.xyxw * r11.yyyy + r7.xyzw;
    r9.x = 0;
    r9.yw = r8.xz;
    r7.xyzw = r9.xyxw * r11.zzzz + r7.xyzw;
    r8.x = 0;
    r7.xyzw = r8.xyxw * r11.wwww + r7.xyzw;
    r7.xyzw = r7.xyzw * float4(1,-1,1,-1) + float4(0,1,0,1);
  } else {
    r4.xyz = _TerrainBias.xxx * r4.xyz;
    r6.xyz = _TerrainBias.xxx * r6.xyz;
    r8.xyz = r4.zyz + r4.zyz;
    r9.xyz = r6.zyz + r6.zyz;
    r3.zw = float2(0,1);
    r10.xyzw = _HeightArray.SampleGrad(sampler_AlbedoArray, r3.xyz, r8.zyz, r9.zyz).xyzw;
    r11.xyzw = _HeightArray.SampleGrad(sampler_AlbedoArray, r3.xyw, r8.zyz, r9.zyz).xyzw;
    r10.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r10.xyzw;
    r10.xyzw = _HeightRange0.xyzw * r10.xyzw + float4(0.5,0.5,0.5,0.5);
    r11.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r11.xyzw;
    r12.xw = r1.xw;
    r12.y = 0.5;
    r11.xyzw = _HeightRange1.xyzw * r11.xyzw + r12.xyyw;
    r13.xyzw = float4(1,1,1,1) + -r0.xyzw;
    r14.xyzw = r10.xyzw + r0.xyzw;
    r2.w = cmp(r13.x < r14.x);
    r4.w = -r14.x + r13.x;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r2.w = r2.w ? 1 : r4.w;
    r15.x = r2.w * r0.x;
    r2.w = r15.x * r10.x;
    r4.w = r15.x * r10.x + r13.y;
    r6.w = cmp(r4.w < r14.y);
    r4.w = r4.w + -r14.y;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r15.y = r4.w * r0.y;
    r4.w = -r15.x * r10.x + r10.y;
    r2.w = r15.y * r4.w + r2.w;
    r4.w = r2.w + r13.z;
    r6.w = cmp(r4.w < r14.z);
    r4.w = r4.w + -r14.z;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r15.z = r4.w * r0.z;
    r4.w = r10.z + -r2.w;
    r2.w = r15.z * r4.w + r2.w;
    r4.w = r2.w + r13.w;
    r6.w = cmp(r4.w < r14.w);
    r4.w = r4.w + -r14.w;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r15.w = r4.w * r0.w;
    r4.w = r10.w + -r2.w;
    r2.w = r15.w * r4.w + r2.w;
    r14.xyzw = float4(1,1,1,1) + -r1.xyzw;
    r4.w = r14.x + r2.w;
    r10.yz = float2(0.5,0.5) + r11.xw;
    r6.w = cmp(r4.w < r10.y);
    r4.w = -r10.y + r4.w;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r16.x = r4.w * r1.x;
    r4.w = r10.x + -r2.w;
    r2.w = r16.x * r4.w + r2.w;
    r4.w = r2.w + r14.y;
    r10.xy = r11.yz + r1.yz;
    r6.w = cmp(r4.w < r10.x);
    r4.w = -r10.x + r4.w;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r16.y = r4.w * r1.y;
    r4.w = r11.y + -r2.w;
    r2.w = r16.y * r4.w + r2.w;
    r4.w = r2.w + r14.z;
    r6.w = cmp(r4.w < r10.y);
    r4.w = r4.w + -r10.y;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r16.z = r4.w * r1.z;
    r4.w = r11.z + -r2.w;
    r2.w = r16.z * r4.w + r2.w;
    r2.w = r2.w + r14.w;
    r4.w = cmp(r2.w < r10.z);
    r2.w = r2.w + -r10.z;
    r2.w = saturate(r2.w / _HeightBlend);
    r2.w = 1 + -r2.w;
    r2.w = r4.w ? 1 : r2.w;
    r16.w = r2.w * r1.w;
    r2.w = dot(r15.xyzw, float4(1,1,1,1));
    r4.w = dot(r16.xyzw, float4(1,1,1,1));
    r2.w = r4.w + r2.w;
    r10.xyzw = r15.xyzw / r2.wwww;
    r11.xyzw = r16.xyzw / r2.wwww;
    r2.w = cmp(r2.w < 0.00999999978);
    r10.xyzw = r2.wwww ? float4(1,0,0,0) : r10.xyzw;
    r11.xyzw = r2.wwww ? float4(0,0,0,0) : r11.xyzw;
    r15.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r3.xyz, r4.zyz, r6.zyz).xyzw;
    r16.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r3.xyw, r4.zyz, r6.zyz).xyzw;
    r3.zw = float2(2,3);
    r17.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r3.xyz, r4.zyz, r6.zyz).xyzw;
    r18.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r3.xyw, r4.zyz, r6.zyz).xyzw;
    r16.xyzw = r16.xyzw * r10.yyyy;
    r15.xyzw = r15.xyzw * r10.xxxx + r16.xyzw;
    r15.xyzw = r17.xyzw * r10.zzzz + r15.xyzw;
    r10.xyzw = r18.xyzw * r10.wwww + r15.xyzw;
    r3.zw = float2(4,5);
    r15.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r3.xyz, r4.zyz, r6.zyz).xyzw;
    r16.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r3.xyw, r4.zyz, r6.zyz).xyzw;
    r3.zw = float2(6,7);
    r17.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r3.xyz, r4.zyz, r6.zyz).xyzw;
    r3.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r3.xyw, r4.zyz, r6.zyz).xyzw;
    r10.xyzw = r15.xyzw * r11.xxxx + r10.xyzw;
    r10.xyzw = r16.xyzw * r11.yyyy + r10.xyzw;
    r10.xyzw = r17.xyzw * r11.zzzz + r10.xyzw;
    r3.xyzw = r3.xyzw * r11.wwww + r10.xyzw;
    r10.xy = r5.yz;
    r10.zw = float2(0,1);
    r11.xyzw = _HeightArray.SampleGrad(sampler_AlbedoArray, r10.xyz, r8.zyz, r9.zyz).xyzw;
    r15.xyzw = _HeightArray.SampleGrad(sampler_AlbedoArray, r10.xyw, r8.zyz, r9.zyz).xyzw;
    r11.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r11.xyzw;
    r11.xyzw = _HeightRange0.xyzw * r11.xyzw + float4(0.5,0.5,0.5,0.5);
    r15.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r15.xyzw;
    r15.xyzw = _HeightRange1.xyzw * r15.xyzw + r12.xyyw;
    r16.xyzw = r11.xyzw + r0.xyzw;
    r2.w = cmp(r13.x < r16.x);
    r4.w = -r16.x + r13.x;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r2.w = r2.w ? 1 : r4.w;
    r17.x = r2.w * r0.x;
    r2.w = r17.x * r11.x;
    r4.w = r17.x * r11.x + r13.y;
    r6.w = cmp(r4.w < r16.y);
    r4.w = r4.w + -r16.y;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r17.y = r4.w * r0.y;
    r4.w = -r17.x * r11.x + r11.y;
    r2.w = r17.y * r4.w + r2.w;
    r4.w = r2.w + r13.z;
    r6.w = cmp(r4.w < r16.z);
    r4.w = r4.w + -r16.z;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r17.z = r4.w * r0.z;
    r4.w = r11.z + -r2.w;
    r2.w = r17.z * r4.w + r2.w;
    r4.w = r2.w + r13.w;
    r6.w = cmp(r4.w < r16.w);
    r4.w = r4.w + -r16.w;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r17.w = r4.w * r0.w;
    r4.w = r11.w + -r2.w;
    r2.w = r17.w * r4.w + r2.w;
    r4.w = r2.w + r14.x;
    r11.yz = float2(0.5,0.5) + r15.xw;
    r6.w = cmp(r4.w < r11.y);
    r4.w = -r11.y + r4.w;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r16.x = r4.w * r1.x;
    r4.w = r11.x + -r2.w;
    r2.w = r16.x * r4.w + r2.w;
    r4.w = r2.w + r14.y;
    r11.xy = r15.yz + r1.yz;
    r6.w = cmp(r4.w < r11.x);
    r4.w = -r11.x + r4.w;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r16.y = r4.w * r1.y;
    r4.w = r15.y + -r2.w;
    r2.w = r16.y * r4.w + r2.w;
    r4.w = r2.w + r14.z;
    r6.w = cmp(r4.w < r11.y);
    r4.w = r4.w + -r11.y;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r4.w = r6.w ? 1 : r4.w;
    r16.z = r4.w * r1.z;
    r4.w = r15.z + -r2.w;
    r2.w = r16.z * r4.w + r2.w;
    r2.w = r2.w + r14.w;
    r4.w = cmp(r2.w < r11.z);
    r2.w = r2.w + -r11.z;
    r2.w = saturate(r2.w / _HeightBlend);
    r2.w = 1 + -r2.w;
    r2.w = r4.w ? 1 : r2.w;
    r16.w = r2.w * r1.w;
    r2.w = dot(r17.xyzw, float4(1,1,1,1));
    r4.w = dot(r16.xyzw, float4(1,1,1,1));
    r2.w = r4.w + r2.w;
    r11.xyzw = r17.xyzw / r2.wwww;
    r15.xyzw = r16.xyzw / r2.wwww;
    r2.w = cmp(r2.w < 0.00999999978);
    r11.xyzw = r2.wwww ? float4(1,0,0,0) : r11.xyzw;
    r15.xyzw = r2.wwww ? float4(0,0,0,0) : r15.xyzw;
    r16.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyz, r4.zyz, r6.zyz).xyzw;
    r17.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyw, r4.zyz, r6.zyz).xyzw;
    r10.zw = float2(2,3);
    r18.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyz, r4.zyz, r6.zyz).xyzw;
    r19.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyw, r4.zyz, r6.zyz).xyzw;
    r17.xyzw = r17.xyzw * r11.yyyy;
    r16.xyzw = r16.xyzw * r11.xxxx + r17.xyzw;
    r16.xyzw = r18.xyzw * r11.zzzz + r16.xyzw;
    r11.xyzw = r19.xyzw * r11.wwww + r16.xyzw;
    r10.zw = float2(4,5);
    r16.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyz, r4.zyz, r6.zyz).xyzw;
    r17.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyw, r4.zyz, r6.zyz).xyzw;
    r10.zw = float2(6,7);
    r18.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyz, r4.zyz, r6.zyz).xyzw;
    r10.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r10.xyw, r4.zyz, r6.zyz).xyzw;
    r11.xyzw = r16.xyzw * r15.xxxx + r11.xyzw;
    r11.xyzw = r17.xyzw * r15.yyyy + r11.xyzw;
    r11.xyzw = r18.xyzw * r15.zzzz + r11.xyzw;
    r10.xyzw = r10.xyzw * r15.wwww + r11.xyzw;
    r5.yz = float2(1,0);
    r11.xyzw = _HeightArray.SampleGrad(sampler_AlbedoArray, r5.xwz, r8.zyz, r9.zyz).xyzw;
    r8.xyzw = _HeightArray.SampleGrad(sampler_AlbedoArray, r5.xwy, r8.xyz, r9.xyz).xyzw;
    r9.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r11.xyzw;
    r9.xyzw = _HeightRange0.xyzw * r9.xyzw + float4(0.5,0.5,0.5,0.5);
    r8.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r8.xyzw;
    r8.xyzw = _HeightRange1.xyzw * r8.xyzw + r12.xyyw;
    r11.xyzw = r9.xyzw + r0.xyzw;
    r2.w = cmp(r13.x < r11.x);
    r4.w = r13.x + -r11.x;
    r4.w = saturate(r4.w / _HeightBlend);
    r4.w = 1 + -r4.w;
    r2.w = r2.w ? 1 : r4.w;
    r12.x = r2.w * r0.x;
    r0.x = r12.x * r9.x;
    r2.w = r12.x * r9.x + r13.y;
    r4.w = cmp(r2.w < r11.y);
    r2.w = r2.w + -r11.y;
    r2.w = saturate(r2.w / _HeightBlend);
    r2.w = 1 + -r2.w;
    r2.w = r4.w ? 1 : r2.w;
    r12.y = r2.w * r0.y;
    r0.y = -r12.x * r9.x + r9.y;
    r0.x = r12.y * r0.y + r0.x;
    r0.y = r0.x + r13.z;
    r2.w = cmp(r0.y < r11.z);
    r0.y = r0.y + -r11.z;
    r0.y = saturate(r0.y / _HeightBlend);
    r0.y = 1 + -r0.y;
    r0.y = r2.w ? 1 : r0.y;
    r12.z = r0.y * r0.z;
    r0.y = r9.z + -r0.x;
    r0.x = r12.z * r0.y + r0.x;
    r0.y = r0.x + r13.w;
    r0.z = cmp(r0.y < r11.w);
    r0.y = r0.y + -r11.w;
    r0.y = saturate(r0.y / _HeightBlend);
    r0.y = 1 + -r0.y;
    r0.y = r0.z ? 1 : r0.y;
    r12.w = r0.y * r0.w;
    r0.y = r9.w + -r0.x;
    r0.x = r12.w * r0.y + r0.x;
    r0.y = r0.x + r14.x;
    r0.zw = float2(0.5,0.5) + r8.xw;
    r2.w = cmp(r0.y < r0.z);
    r0.y = r0.y + -r0.z;
    r0.y = saturate(r0.y / _HeightBlend);
    r0.y = 1 + -r0.y;
    r0.y = r2.w ? 1 : r0.y;
    r11.x = r0.y * r1.x;
    r0.y = r9.x + -r0.x;
    r0.x = r11.x * r0.y + r0.x;
    r0.y = r0.x + r14.y;
    r8.xw = r8.yz + r1.yz;
    r0.z = cmp(r0.y < r8.x);
    r0.y = -r8.x + r0.y;
    r0.y = saturate(r0.y / _HeightBlend);
    r0.y = 1 + -r0.y;
    r0.y = r0.z ? 1 : r0.y;
    r11.y = r0.y * r1.y;
    r0.y = r8.y + -r0.x;
    r0.x = r11.y * r0.y + r0.x;
    r0.y = r0.x + r14.z;
    r0.z = cmp(r0.y < r8.w);
    r0.y = r0.y + -r8.w;
    r0.y = saturate(r0.y / _HeightBlend);
    r0.y = 1 + -r0.y;
    r0.y = r0.z ? 1 : r0.y;
    r11.z = r0.y * r1.z;
    r0.y = r8.z + -r0.x;
    r0.x = r11.z * r0.y + r0.x;
    r0.x = r0.x + r14.w;
    r0.y = cmp(r0.x < r0.w);
    r0.x = r0.x + -r0.w;
    r0.x = saturate(r0.x / _HeightBlend);
    r0.x = 1 + -r0.x;
    r0.x = r0.y ? 1 : r0.x;
    r11.w = r0.x * r1.w;
    r0.x = dot(r12.xyzw, float4(1,1,1,1));
    r0.y = dot(r11.xyzw, float4(1,1,1,1));
    r0.x = r0.x + r0.y;
    r1.xyzw = r12.xyzw / r0.xxxx;
    r8.xyzw = r11.xyzw / r0.xxxx;
    r0.x = cmp(r0.x < 0.00999999978);
    r1.xyzw = r0.xxxx ? float4(1,0,0,0) : r1.xyzw;
    r0.xyzw = r0.xxxx ? float4(0,0,0,0) : r8.xyzw;
    r8.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r5.xwz, r4.zyz, r6.zyz).xyzw;
    r9.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r5.xwy, r4.zyz, r6.zyz).xyzw;
    r5.yz = float2(3,2);
    r11.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r5.xwz, r4.zyz, r6.zyz).xyzw;
    r12.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r5.xwy, r4.zyz, r6.zyz).xyzw;
    r9.xyzw = r9.xyzw * r1.yyyy;
    r8.xyzw = r8.xyzw * r1.xxxx + r9.xyzw;
    r8.xyzw = r11.xyzw * r1.zzzz + r8.xyzw;
    r1.xyzw = r12.xyzw * r1.wwww + r8.xyzw;
    r5.yz = float2(5,4);
    r8.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r5.xwz, r4.zyz, r6.zyz).xyzw;
    r9.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r5.xwy, r4.zyz, r6.zyz).xyzw;
    r5.yz = float2(7,6);
    r11.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r5.xwz, r4.zyz, r6.zyz).xyzw;
    r4.xyzw = _AlbedoArray.SampleGrad(sampler_AlbedoArray, r5.xwy, r4.xyz, r6.xyz).xyzw;
    r1.xyzw = r8.xyzw * r0.xxxx + r1.xyzw;
    r1.xyzw = r9.xyzw * r0.yyyy + r1.xyzw;
    r1.xyzw = r11.xyzw * r0.zzzz + r1.xyzw;
    r0.xyzw = r4.xyzw * r0.wwww + r1.xyzw;
    r1.xyzw = r10.xyzw * r2.yyyy;
    r1.xyzw = r3.xyzw * r2.xxxx + r1.xyzw;
    o0.xyzw = r0.xyzw * r2.zzzz + r1.xyzw;
  }
  r0.x = dot(r7.xyzw, r7.xyzw);
  r0.x = rsqrt(r0.x);
  o1.xyzw = r7.xyzw * r0.xxxx;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(DYNAMICLIGHTMAP_ON)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float4 o7 = 0;
		float4 o8 = 0;
		vs_d8ef705a8ffc438e_impl(v.position0, v.texcoord0, v.texcoord1.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6, o7, o8);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
	}
#elif defined(DYNAMICLIGHTMAP_ON)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float4 o7 = 0;
		float4 o8 = 0;
		vs_70bfab99e1b6dfa8_impl(v.position0, v.texcoord0, v.texcoord1, v.texcoord2.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6, o7, o8);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		ps_b36ce64ad90a53d5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, o0, o1);
		r.t0 = o0;
		r.t1 = o1;
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
