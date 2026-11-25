Shader "Hidden/BT-WaterGbuffer"
{
	Properties
	{
		_ExtinctionDepth ("Extinction Depth", Float) = 1
		_WaterColor ("Water Color", Color) = (0,0,0,1)
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		[Gamma] _Metallic ("Metallic", Range(0,1)) = 0
		_MetallicGlossMap ("Metallic", 2D) = "white" {}
		_Gradient ("Gradient", 2D) = "white" {}
		_BumpScale ("Scale", Float) = 1
		_BumpMap ("Normal Map", 2D) = "bump" {}
	}
	SubShader
	{
		Tags { "Queue"="Geometry" "RenderType"="Geometry" }
		Pass
		{
			Tags { "LightMode"="ForwardBase" "ShadowSupport"="true" }
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt
			#pragma multi_compile _ DIRECTIONAL
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ LIGHTPROBE_SH
			#pragma multi_compile _ SHADOWS_SCREEN
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ _GEN_WATER
			#pragma multi_compile _ _NORMALMAP

#define cmp -

Texture2D _BT_TerrainHeight;
SamplerState sampler_BT_TerrainHeight;
Texture2D _BumpMap;
SamplerState sampler_BumpMap;
TextureCube _BT_Reflection;
SamplerState sampler_BT_Reflection;

float4 _BT_GlobalWind;
float _Metallic;
float _Glossiness;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 normal0 : NORMAL0;
	float4 tangent0 : TANGENT0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};

#if !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && !defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(LIGHTPROBE_SH) && !defined(VERTEXLIGHT_ON) && !defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(LIGHTPROBE_SH) && defined(VERTEXLIGHT_ON) && !defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(LIGHTPROBE_SH) && !defined(VERTEXLIGHT_ON) && defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(LIGHTPROBE_SH) && defined(VERTEXLIGHT_ON) && defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
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

// vs ab49c65d5565d598: 4 retail keyword combination(s)
void vs_ab49c65d5565d598_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[1][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[1][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[1][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.wwww + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.wwww;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r0.xzxz;
  o2.w = 0;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xwz;
  o3.xyzw = float4(0,0,1,0);
  o4.xyzw = float4(1,0,0,0);
  o5.xyzw = float4(0,1,0,0);
  o6.xyzw = float4(0,0,0,0);
  o7.xyzw = r0.xyzw;
  r2.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r0.www;
  r0.xyw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r0.xyz;
  o8.xyz = float3(-1,-1,1) * r0.xyz;
  o8.w = -r0.z;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  o9.xy = r0.xw + r0.zz;
  r0.x = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.x = rsqrt(r0.x);
  r0.xy = _BT_GlobalWind.xz * r0.xx;
  r0.z = v5.x + v5.y;
  r0.z = cmp(r0.z < 0.200000003);
  o10.xy = r0.zz ? r0.xy : v5.xy;
  o10.zw = v5.zw;
  return;
}


// vs e4a76ad09b3022ad: 2 retail keyword combination(s)
void vs_e4a76ad09b3022ad_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[1][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[1][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[1][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.wwww + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.wwww;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r0.xzxz;
  o2.w = 0;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xwz;
  o3.xyzw = float4(0,0,1,0);
  o4.xyzw = float4(1,0,0,0);
  o5.xyzw = float4(0,1,0,0);
  o6.xyz = -unity_SHC.xyz;
  o6.w = 0;
  o7.xyzw = r0.xyzw;
  r2.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r0.www;
  r0.xyw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r0.xyz;
  o8.xyz = float3(-1,-1,1) * r0.xyz;
  o8.w = -r0.z;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  o9.xy = r0.xw + r0.zz;
  r0.x = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.x = rsqrt(r0.x);
  r0.xy = _BT_GlobalWind.xz * r0.xx;
  r0.z = v5.x + v5.y;
  r0.z = cmp(r0.z < 0.200000003);
  o10.xy = r0.zz ? r0.xy : v5.xy;
  o10.zw = v5.zw;
  return;
}


// vs e74464bdfa18da29: 4 retail keyword combination(s)
void vs_e74464bdfa18da29_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float4 v4 : TEXCOORD1,
  float2 v5 : TEXCOORD2,
  float4 v6 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[1][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[1][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[1][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.wwww + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.wwww;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r0.xzxz;
  o2.w = 0;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xwz;
  o3.xyzw = float4(0,0,1,0);
  o4.xyzw = float4(1,0,0,0);
  o5.xyzw = float4(0,1,0,0);
  o6.zw = v5.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o6.xy = float2(0,0);
  o7.xyzw = r0.xyzw;
  r2.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r0.www;
  r0.xyw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r0.xyz;
  o8.xyz = float3(-1,-1,1) * r0.xyz;
  o8.w = -r0.z;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  o9.xy = r0.xw + r0.zz;
  r0.x = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.x = rsqrt(r0.x);
  r0.xy = _BT_GlobalWind.xz * r0.xx;
  r0.z = v6.x + v6.y;
  r0.z = cmp(r0.z < 0.200000003);
  o10.xy = r0.zz ? r0.xy : v6.xy;
  o10.zw = v6.zw;
  return;
}


// vs 55889f862c54b0f3: 2 retail keyword combination(s)
void vs_55889f862c54b0f3_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[1][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[1][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[1][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.wwww + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.wwww;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r0.xzxz;
  o2.w = 0;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xwz;
  o3.xyzw = float4(0,0,1,0);
  o4.xyzw = float4(1,0,0,0);
  o5.xyzw = float4(0,1,0,0);
  r2.xyzw = unity_4LightPosX0.xyzw + -r0.xxxx;
  r3.xyzw = unity_4LightPosY0.xyzw + -r0.wwww;
  r4.xyzw = r3.xyzw * r3.xyzw;
  r2.xyzw = r2.xyzw * r2.xyzw + r4.xyzw;
  r4.xyzw = unity_4LightPosZ0.xyzw + -r0.zzzz;
  r2.xyzw = r4.xyzw * r4.xyzw + r2.xyzw;
  r2.xyzw = max(float4(9.99999997e-007,9.99999997e-007,9.99999997e-007,9.99999997e-007), r2.xyzw);
  r4.xyzw = rsqrt(r2.xyzw);
  r2.xyzw = r2.xyzw * unity_4LightAtten0.xyzw + float4(1,1,1,1);
  r2.xyzw = float4(1,1,1,1) / r2.xyzw;
  r3.xyzw = r4.xyzw * r3.xyzw;
  r3.xyzw = max(float4(0,0,0,0), r3.xyzw);
  r2.xyzw = r3.xyzw * r2.xyzw;
  r3.xyz = unity_LightColor[1].xyz * r2.yyy;
  r3.xyz = unity_LightColor[0].xyz * r2.xxx + r3.xyz;
  r2.xyz = unity_LightColor[2].xyz * r2.zzz + r3.xyz;
  r2.xyz = unity_LightColor[3].xyz * r2.www + r2.xyz;
  o6.xyz = -unity_SHC.xyz + r2.xyz;
  o6.w = 0;
  o7.xyzw = r0.xyzw;
  r2.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r0.www;
  r0.xyw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r0.xyz;
  o8.xyz = float3(-1,-1,1) * r0.xyz;
  o8.w = -r0.z;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  o9.xy = r0.xw + r0.zz;
  r0.x = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.x = rsqrt(r0.x);
  r0.xy = _BT_GlobalWind.xz * r0.xx;
  r0.z = v5.x + v5.y;
  r0.z = cmp(r0.z < 0.200000003);
  o10.xy = r0.zz ? r0.xy : v5.xy;
  o10.zw = v5.zw;
  return;
}


// vs 307468efcef94919: 4 retail keyword combination(s)
void vs_307468efcef94919_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  const float4 icb[] = { { 0, 0, 0.130899698, 0.250000},
                              { 0.100000, -0.100000, 0.202683404, 0.250000},
                              { -0.200000, 0.200000, 0.108330779, 0.150000},
                              { -0.800000, -0.300000, 0.103003040, 0.250000},
                              { -0.200000, 0.100000, 0.139626339, 0.150000},
                              { 0.274889350, 0, 0, 0},
                              { 1.074222, 0, 0, 0},
                              { 0.162496164, 0, 0, 0},
                              { 0.834324598, 0, 0, 0},
                              { 0.418879032, 0, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v5.x + v5.y;
  r0.x = cmp(r0.x < 0.200000003);
  r0.y = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.y = rsqrt(r0.y);
  r0.yz = _BT_GlobalWind.xz * r0.yy;
  r0.xy = r0.xx ? r0.yz : v5.xy;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyw = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.www + r1.xzy;
  r0.zw = float2(1024,1024) + r1.xy;
  r0.zw = r0.zw * float2(0.00048828125,0.00048828125) + float2(9.99999046,9.99999046);
  r2.xy = trunc(r0.zw);
  r0.zw = frac(r0.zw);
  r3.xyzw = r2.xyxy + r2.xyxy;
  r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
  r3.xyzw = r3.xyzw ? float4(2,2,0.5,0.5) : float4(-2,-2,-0.5,-0.5);
  r2.xy = r3.zw * r2.xy;
  r2.xy = frac(r2.xy);
  r2.xy = r3.xy * r2.xy;
  r2.xy = cmp(r2.xy < float2(1,1));
  r2.zw = float2(1,1) + -r0.zw;
  r0.zw = r2.xy ? r0.zw : r2.zw;
  r2.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r0.zw, 0).xyzw;
  r0.z = cmp(r2.x < r1.w);
  [branch] if (r0.z != 0) {
    r0.z = dot(r0.xy, r0.xy);
    r0.z = rsqrt(r0.z);
    r2.yz = r0.xy * r0.zz;
    r2.x = max(9.99999975e-006, r2.y);
    r0.z = dot(r2.xz, r2.xz);
    r0.z = rsqrt(r0.z);
    r0.zw = r2.xz * r0.zz;
    r2.xz = float2(0,0);
    r3.zw = float2(0,0);
    r3.xy = r0.zw;
    r5.xy = r1.xy;
    r4.xyw = float3(0,0,0);
    r6.y = 0;
    r1.z = r1.w;
    r5.zw = float2(0,0);
    [loop] while (true) {
      r6.w = cmp((uint)r5.w >= 5);
      [branch] if (r6.w != 0) break;
      r7.xy = icb[r5.w+0].xy + r3.xy;
      r6.w = dot(r7.xy, r7.xy);
      r6.w = rsqrt(r6.w);
      r7.xy = r7.xy * r6.ww;
      r6.w = (int)r5.w & 1;
      r7.z = (uint)r5.w;
      r7.z = 1 + r7.z;
      r7.zw = r7.yx / r7.zz;
      r3.xy = r6.ww ? r7.zw : r7.xy;
      r6.w = dot(r5.xy, r3.xy);
      r7.x = icb[r5.w+0].z + icb[r5.w+0].z;
      r7.y = icb[r5.w+0].w * r7.x;
      r7.y = 0.25 * r7.y;
      r7.z = 1 / r7.y;
      r7.z = -9.99999975e-005 + r7.z;
      r7.zw = r7.zz * float2(0.200000003,0.200000003) + float2(9.99999975e-005,-0.999899983);
      r8.x = icb[r5.w+5].x * _Time.w;
      r6.w = r7.x * r6.w + r8.x;
      sincos(r6.w, r7.x, r8.x);
      r6.w = icb[r5.w+0].w * r7.z;
      r8.yz = r6.ww * r3.xy;
      r8.yz = r8.yz * r8.xx;
      r5.xy = r8.yz * float2(0.25,0.25) + r5.xy;
      r6.w = icb[r5.w+0].w * r7.x;
      r1.z = r6.w * 0.25 + r1.z;
      r6.w = r7.y * r7.x;
      r7.x = r8.x * r7.y;
      r7.y = r7.z * r3.x;
      r8.xy = r7.yy * r3.xy;
      r5.z = r8.x * r6.w + r5.z;
      r8.xz = r3.xy * r3.yy;
      r4.w = r8.x * r6.w + r4.w;
      r6.y = r3.x * r7.x + r6.y;
      r4.x = r8.y * r6.w + r4.x;
      r7.y = r8.z * r7.z;
      r3.z = r7.y * r6.w + r3.z;
      r4.y = r3.y * r7.x + r4.y;
      r2.xz = -r3.xy * r7.xx + r2.xz;
      r7.x = r7.w * 0.200000003 + 1;
      r3.w = r7.x * r6.w + r3.w;
      r5.w = (int)r5.w + 1;
    }
    r1.xy = r5.xy;
    r6.x = 1 + -r5.z;
    r6.z = -r4.w;
    r2.yw = float2(1,1) + -r3.wz;
    r4.z = r2.w;
  } else {
    r2.xyz = float3(0,1,0);
    r4.xyz = float3(1,0,0);
    r6.xyz = float3(0,0,1);
    r1.xyz = r1.xyw;
  }
  r3.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.zzzz;
  r3.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.yyyy + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r3.xyzw;
  r5.xz = float2(0.5,0.5) * r3.xw;
  r0.z = _ProjectionParams.x * r3.y;
  r5.w = 0.5 * r0.z;
  o9.xy = r5.xw + r5.zz;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r1.xyxy;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xzy;
  r5.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r1.zzz;
  r5.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r1.xxx + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r1.yyy + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r5.xyz;
  o8.xyz = float3(-1,-1,1) * r5.xyz;
  o8.w = -r5.z;
  o0.xyzw = r3.xyzw;
  o2.w = 0;
  o3.xyz = r6.xyz;
  o3.w = 0;
  o4.xyz = r4.xyz;
  o4.w = 0;
  o5.xyz = r2.xyz;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  o7.xyzw = r1.xzyw;
  o9.zw = r3.zw;
  o10.zw = v5.zw;
  o10.xy = r0.xy;
  return;
}


// vs cf907010dd1d60b1: 2 retail keyword combination(s)
void vs_cf907010dd1d60b1_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  const float4 icb[] = { { 0, 0, 0.130899698, 0.250000},
                              { 0.100000, -0.100000, 0.202683404, 0.250000},
                              { -0.200000, 0.200000, 0.108330779, 0.150000},
                              { -0.800000, -0.300000, 0.103003040, 0.250000},
                              { -0.200000, 0.100000, 0.139626339, 0.150000},
                              { 0.274889350, 0, 0, 0},
                              { 1.074222, 0, 0, 0},
                              { 0.162496164, 0, 0, 0},
                              { 0.834324598, 0, 0, 0},
                              { 0.418879032, 0, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v5.x + v5.y;
  r0.x = cmp(r0.x < 0.200000003);
  r0.y = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.y = rsqrt(r0.y);
  r0.yz = _BT_GlobalWind.xz * r0.yy;
  r0.xy = r0.xx ? r0.yz : v5.xy;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyw = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.www + r1.xzy;
  r0.zw = float2(1024,1024) + r1.xy;
  r0.zw = r0.zw * float2(0.00048828125,0.00048828125) + float2(9.99999046,9.99999046);
  r2.xy = trunc(r0.zw);
  r0.zw = frac(r0.zw);
  r3.xyzw = r2.xyxy + r2.xyxy;
  r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
  r3.xyzw = r3.xyzw ? float4(2,2,0.5,0.5) : float4(-2,-2,-0.5,-0.5);
  r2.xy = r3.zw * r2.xy;
  r2.xy = frac(r2.xy);
  r2.xy = r3.xy * r2.xy;
  r2.xy = cmp(r2.xy < float2(1,1));
  r2.zw = float2(1,1) + -r0.zw;
  r0.zw = r2.xy ? r0.zw : r2.zw;
  r2.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r0.zw, 0).xyzw;
  r0.z = cmp(r2.x < r1.w);
  [branch] if (r0.z != 0) {
    r0.z = dot(r0.xy, r0.xy);
    r0.z = rsqrt(r0.z);
    r2.yz = r0.xy * r0.zz;
    r2.x = max(9.99999975e-006, r2.y);
    r0.z = dot(r2.xz, r2.xz);
    r0.z = rsqrt(r0.z);
    r0.zw = r2.xz * r0.zz;
    r2.xz = float2(0,0);
    r3.zw = float2(0,0);
    r3.xy = r0.zw;
    r5.xy = r1.xy;
    r4.xyw = float3(0,0,0);
    r6.y = 0;
    r1.z = r1.w;
    r5.zw = float2(0,0);
    [loop] while (true) {
      r6.w = cmp((uint)r5.w >= 5);
      [branch] if (r6.w != 0) break;
      r7.xy = icb[r5.w+0].xy + r3.xy;
      r6.w = dot(r7.xy, r7.xy);
      r6.w = rsqrt(r6.w);
      r7.xy = r7.xy * r6.ww;
      r6.w = (int)r5.w & 1;
      r7.z = (uint)r5.w;
      r7.z = 1 + r7.z;
      r7.zw = r7.yx / r7.zz;
      r3.xy = r6.ww ? r7.zw : r7.xy;
      r6.w = dot(r5.xy, r3.xy);
      r7.x = icb[r5.w+0].z + icb[r5.w+0].z;
      r7.y = icb[r5.w+0].w * r7.x;
      r7.y = 0.25 * r7.y;
      r7.z = 1 / r7.y;
      r7.z = -9.99999975e-005 + r7.z;
      r7.zw = r7.zz * float2(0.200000003,0.200000003) + float2(9.99999975e-005,-0.999899983);
      r8.x = icb[r5.w+5].x * _Time.w;
      r6.w = r7.x * r6.w + r8.x;
      sincos(r6.w, r7.x, r8.x);
      r6.w = icb[r5.w+0].w * r7.z;
      r8.yz = r6.ww * r3.xy;
      r8.yz = r8.yz * r8.xx;
      r5.xy = r8.yz * float2(0.25,0.25) + r5.xy;
      r6.w = icb[r5.w+0].w * r7.x;
      r1.z = r6.w * 0.25 + r1.z;
      r6.w = r7.y * r7.x;
      r7.x = r8.x * r7.y;
      r7.y = r7.z * r3.x;
      r8.xy = r7.yy * r3.xy;
      r5.z = r8.x * r6.w + r5.z;
      r8.xz = r3.xy * r3.yy;
      r4.w = r8.x * r6.w + r4.w;
      r6.y = r3.x * r7.x + r6.y;
      r4.x = r8.y * r6.w + r4.x;
      r7.y = r8.z * r7.z;
      r3.z = r7.y * r6.w + r3.z;
      r4.y = r3.y * r7.x + r4.y;
      r2.xz = -r3.xy * r7.xx + r2.xz;
      r7.x = r7.w * 0.200000003 + 1;
      r3.w = r7.x * r6.w + r3.w;
      r5.w = (int)r5.w + 1;
    }
    r1.xy = r5.xy;
    r6.x = 1 + -r5.z;
    r6.z = -r4.w;
    r2.yw = float2(1,1) + -r3.wz;
    r4.z = r2.w;
  } else {
    r2.xyz = float3(0,1,0);
    r4.xyz = float3(1,0,0);
    r6.xyz = float3(0,0,1);
    r1.xyz = r1.xyw;
  }
  r3.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.zzzz;
  r3.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.yyyy + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r3.xyzw;
  r5.xz = float2(0.5,0.5) * r3.xw;
  r0.z = _ProjectionParams.x * r3.y;
  r5.w = 0.5 * r0.z;
  o9.xy = r5.xw + r5.zz;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r1.xyxy;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xzy;
  r5.xyzw = r2.xyzz * r2.yzzx;
  r7.x = dot(unity_SHBr.xyzw, r5.xyzw);
  r7.y = dot(unity_SHBg.xyzw, r5.xyzw);
  r7.z = dot(unity_SHBb.xyzw, r5.xyzw);
  r0.z = r2.y * r2.y;
  r0.z = r2.x * r2.x + -r0.z;
  o6.xyz = unity_SHC.xyz * r0.zzz + r7.xyz;
  r5.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r1.zzz;
  r5.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r1.xxx + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r1.yyy + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r5.xyz;
  o8.xyz = float3(-1,-1,1) * r5.xyz;
  o8.w = -r5.z;
  o0.xyzw = r3.xyzw;
  o2.w = 0;
  o3.xyz = r6.xyz;
  o3.w = 0;
  o4.xyz = r4.xyz;
  o4.w = 0;
  o5.xyz = r2.xyz;
  o5.w = 0;
  o6.w = 0;
  o7.xyzw = r1.xzyw;
  o9.zw = r3.zw;
  o10.zw = v5.zw;
  o10.xy = r0.xy;
  return;
}


// vs bca9f0c834939fa5: 4 retail keyword combination(s)
void vs_bca9f0c834939fa5_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float4 v4 : TEXCOORD1,
  float2 v5 : TEXCOORD2,
  float4 v6 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  const float4 icb[] = { { 0, 0, 0.130899698, 0.250000},
                              { 0.100000, -0.100000, 0.202683404, 0.250000},
                              { -0.200000, 0.200000, 0.108330779, 0.150000},
                              { -0.800000, -0.300000, 0.103003040, 0.250000},
                              { -0.200000, 0.100000, 0.139626339, 0.150000},
                              { 0.274889350, 0, 0, 0},
                              { 1.074222, 0, 0, 0},
                              { 0.162496164, 0, 0, 0},
                              { 0.834324598, 0, 0, 0},
                              { 0.418879032, 0, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v6.x + v6.y;
  r0.x = cmp(r0.x < 0.200000003);
  r0.y = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.y = rsqrt(r0.y);
  r0.yz = _BT_GlobalWind.xz * r0.yy;
  r0.xy = r0.xx ? r0.yz : v6.xy;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyw = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.www + r1.xzy;
  r0.zw = float2(1024,1024) + r1.xy;
  r0.zw = r0.zw * float2(0.00048828125,0.00048828125) + float2(9.99999046,9.99999046);
  r2.xy = trunc(r0.zw);
  r0.zw = frac(r0.zw);
  r3.xyzw = r2.xyxy + r2.xyxy;
  r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
  r3.xyzw = r3.xyzw ? float4(2,2,0.5,0.5) : float4(-2,-2,-0.5,-0.5);
  r2.xy = r3.zw * r2.xy;
  r2.xy = frac(r2.xy);
  r2.xy = r3.xy * r2.xy;
  r2.xy = cmp(r2.xy < float2(1,1));
  r2.zw = float2(1,1) + -r0.zw;
  r0.zw = r2.xy ? r0.zw : r2.zw;
  r2.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r0.zw, 0).xyzw;
  r0.z = cmp(r2.x < r1.w);
  [branch] if (r0.z != 0) {
    r0.z = dot(r0.xy, r0.xy);
    r0.z = rsqrt(r0.z);
    r2.yz = r0.xy * r0.zz;
    r2.x = max(9.99999975e-006, r2.y);
    r0.z = dot(r2.xz, r2.xz);
    r0.z = rsqrt(r0.z);
    r0.zw = r2.xz * r0.zz;
    r2.xz = float2(0,0);
    r3.zw = float2(0,0);
    r3.xy = r0.zw;
    r5.xy = r1.xy;
    r4.xyw = float3(0,0,0);
    r6.y = 0;
    r1.z = r1.w;
    r5.zw = float2(0,0);
    [loop] while (true) {
      r6.w = cmp((uint)r5.w >= 5);
      [branch] if (r6.w != 0) break;
      r7.xy = icb[r5.w+0].xy + r3.xy;
      r6.w = dot(r7.xy, r7.xy);
      r6.w = rsqrt(r6.w);
      r7.xy = r7.xy * r6.ww;
      r6.w = (int)r5.w & 1;
      r7.z = (uint)r5.w;
      r7.z = 1 + r7.z;
      r7.zw = r7.yx / r7.zz;
      r3.xy = r6.ww ? r7.zw : r7.xy;
      r6.w = dot(r5.xy, r3.xy);
      r7.x = icb[r5.w+0].z + icb[r5.w+0].z;
      r7.y = icb[r5.w+0].w * r7.x;
      r7.y = 0.25 * r7.y;
      r7.z = 1 / r7.y;
      r7.z = -9.99999975e-005 + r7.z;
      r7.zw = r7.zz * float2(0.200000003,0.200000003) + float2(9.99999975e-005,-0.999899983);
      r8.x = icb[r5.w+5].x * _Time.w;
      r6.w = r7.x * r6.w + r8.x;
      sincos(r6.w, r7.x, r8.x);
      r6.w = icb[r5.w+0].w * r7.z;
      r8.yz = r6.ww * r3.xy;
      r8.yz = r8.yz * r8.xx;
      r5.xy = r8.yz * float2(0.25,0.25) + r5.xy;
      r6.w = icb[r5.w+0].w * r7.x;
      r1.z = r6.w * 0.25 + r1.z;
      r6.w = r7.y * r7.x;
      r7.x = r8.x * r7.y;
      r7.y = r7.z * r3.x;
      r8.xy = r7.yy * r3.xy;
      r5.z = r8.x * r6.w + r5.z;
      r8.xz = r3.xy * r3.yy;
      r4.w = r8.x * r6.w + r4.w;
      r6.y = r3.x * r7.x + r6.y;
      r4.x = r8.y * r6.w + r4.x;
      r7.y = r8.z * r7.z;
      r3.z = r7.y * r6.w + r3.z;
      r4.y = r3.y * r7.x + r4.y;
      r2.xz = -r3.xy * r7.xx + r2.xz;
      r7.x = r7.w * 0.200000003 + 1;
      r3.w = r7.x * r6.w + r3.w;
      r5.w = (int)r5.w + 1;
    }
    r1.xy = r5.xy;
    r6.x = 1 + -r5.z;
    r6.z = -r4.w;
    r2.yw = float2(1,1) + -r3.wz;
    r4.z = r2.w;
  } else {
    r2.xyz = float3(0,1,0);
    r4.xyz = float3(1,0,0);
    r6.xyz = float3(0,0,1);
    r1.xyz = r1.xyw;
  }
  r3.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.zzzz;
  r3.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.yyyy + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r3.xyzw;
  r5.xz = float2(0.5,0.5) * r3.xw;
  r0.z = _ProjectionParams.x * r3.y;
  r5.w = 0.5 * r0.z;
  o9.xy = r5.xw + r5.zz;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r1.xyxy;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xzy;
  o6.zw = v5.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  r5.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r1.zzz;
  r5.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r1.xxx + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r1.yyy + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r5.xyz;
  o8.xyz = float3(-1,-1,1) * r5.xyz;
  o8.w = -r5.z;
  o0.xyzw = r3.xyzw;
  o2.w = 0;
  o3.xyz = r6.xyz;
  o3.w = 0;
  o4.xyz = r4.xyz;
  o4.w = 0;
  o5.xyz = r2.xyz;
  o5.w = 0;
  o6.xy = float2(0,0);
  o7.xyzw = r1.xzyw;
  o9.zw = r3.zw;
  o10.zw = v6.zw;
  o10.xy = r0.xy;
  return;
}


// vs 97fba076d47f5d1f: 2 retail keyword combination(s)
void vs_97fba076d47f5d1f_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  const float4 icb[] = { { 0, 0, 0.130899698, 0.250000},
                              { 0.100000, -0.100000, 0.202683404, 0.250000},
                              { -0.200000, 0.200000, 0.108330779, 0.150000},
                              { -0.800000, -0.300000, 0.103003040, 0.250000},
                              { -0.200000, 0.100000, 0.139626339, 0.150000},
                              { 0.274889350, 0, 0, 0},
                              { 1.074222, 0, 0, 0},
                              { 0.162496164, 0, 0, 0},
                              { 0.834324598, 0, 0, 0},
                              { 0.418879032, 0, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v5.x + v5.y;
  r0.x = cmp(r0.x < 0.200000003);
  r0.y = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.y = rsqrt(r0.y);
  r0.yz = _BT_GlobalWind.xz * r0.yy;
  r0.xy = r0.xx ? r0.yz : v5.xy;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyw = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.www + r1.xzy;
  r0.zw = float2(1024,1024) + r1.xy;
  r0.zw = r0.zw * float2(0.00048828125,0.00048828125) + float2(9.99999046,9.99999046);
  r2.xy = trunc(r0.zw);
  r0.zw = frac(r0.zw);
  r3.xyzw = r2.xyxy + r2.xyxy;
  r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
  r3.xyzw = r3.xyzw ? float4(2,2,0.5,0.5) : float4(-2,-2,-0.5,-0.5);
  r2.xy = r3.zw * r2.xy;
  r2.xy = frac(r2.xy);
  r2.xy = r3.xy * r2.xy;
  r2.xy = cmp(r2.xy < float2(1,1));
  r2.zw = float2(1,1) + -r0.zw;
  r0.zw = r2.xy ? r0.zw : r2.zw;
  r2.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r0.zw, 0).xyzw;
  r0.z = cmp(r2.x < r1.w);
  [branch] if (r0.z != 0) {
    r0.z = dot(r0.xy, r0.xy);
    r0.z = rsqrt(r0.z);
    r2.yz = r0.xy * r0.zz;
    r2.x = max(9.99999975e-006, r2.y);
    r0.z = dot(r2.xz, r2.xz);
    r0.z = rsqrt(r0.z);
    r0.zw = r2.xz * r0.zz;
    r2.xz = float2(0,0);
    r3.zw = float2(0,0);
    r3.xy = r0.zw;
    r5.xy = r1.xy;
    r4.xyw = float3(0,0,0);
    r6.y = 0;
    r1.z = r1.w;
    r5.zw = float2(0,0);
    [loop] while (true) {
      r6.w = cmp((uint)r5.w >= 5);
      [branch] if (r6.w != 0) break;
      r7.xy = icb[r5.w+0].xy + r3.xy;
      r6.w = dot(r7.xy, r7.xy);
      r6.w = rsqrt(r6.w);
      r7.xy = r7.xy * r6.ww;
      r6.w = (int)r5.w & 1;
      r7.z = (uint)r5.w;
      r7.z = 1 + r7.z;
      r7.zw = r7.yx / r7.zz;
      r3.xy = r6.ww ? r7.zw : r7.xy;
      r6.w = dot(r5.xy, r3.xy);
      r7.x = icb[r5.w+0].z + icb[r5.w+0].z;
      r7.y = icb[r5.w+0].w * r7.x;
      r7.y = 0.25 * r7.y;
      r7.z = 1 / r7.y;
      r7.z = -9.99999975e-005 + r7.z;
      r7.zw = r7.zz * float2(0.200000003,0.200000003) + float2(9.99999975e-005,-0.999899983);
      r8.x = icb[r5.w+5].x * _Time.w;
      r6.w = r7.x * r6.w + r8.x;
      sincos(r6.w, r7.x, r8.x);
      r6.w = icb[r5.w+0].w * r7.z;
      r8.yz = r6.ww * r3.xy;
      r8.yz = r8.yz * r8.xx;
      r5.xy = r8.yz * float2(0.25,0.25) + r5.xy;
      r6.w = icb[r5.w+0].w * r7.x;
      r1.z = r6.w * 0.25 + r1.z;
      r6.w = r7.y * r7.x;
      r7.x = r8.x * r7.y;
      r7.y = r7.z * r3.x;
      r8.xy = r7.yy * r3.xy;
      r5.z = r8.x * r6.w + r5.z;
      r8.xz = r3.xy * r3.yy;
      r4.w = r8.x * r6.w + r4.w;
      r6.y = r3.x * r7.x + r6.y;
      r4.x = r8.y * r6.w + r4.x;
      r7.y = r8.z * r7.z;
      r3.z = r7.y * r6.w + r3.z;
      r4.y = r3.y * r7.x + r4.y;
      r2.xz = -r3.xy * r7.xx + r2.xz;
      r7.x = r7.w * 0.200000003 + 1;
      r3.w = r7.x * r6.w + r3.w;
      r5.w = (int)r5.w + 1;
    }
    r1.xy = r5.xy;
    r6.x = 1 + -r5.z;
    r6.z = -r4.w;
    r2.yw = float2(1,1) + -r3.wz;
    r4.z = r2.w;
  } else {
    r2.xyz = float3(0,1,0);
    r4.xyz = float3(1,0,0);
    r6.xyz = float3(0,0,1);
    r1.xyz = r1.xyw;
  }
  r3.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.zzzz;
  r3.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.yyyy + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r3.xyzw;
  r5.xz = float2(0.5,0.5) * r3.xw;
  r0.z = _ProjectionParams.x * r3.y;
  r5.w = 0.5 * r0.z;
  o9.xy = r5.xw + r5.zz;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r1.xyxy;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xzy;
  r5.xyzw = unity_4LightPosX0.xyzw + -r1.xxxx;
  r7.xyzw = unity_4LightPosY0.xyzw + -r1.zzzz;
  r8.xyzw = unity_4LightPosZ0.xyzw + -r1.yyyy;
  r9.xyzw = r7.xyzw * r7.xyzw;
  r9.xyzw = r5.xyzw * r5.xyzw + r9.xyzw;
  r9.xyzw = r8.xyzw * r8.xyzw + r9.xyzw;
  r9.xyzw = max(float4(9.99999997e-007,9.99999997e-007,9.99999997e-007,9.99999997e-007), r9.xyzw);
  r7.xyzw = r7.xyzw * r2.yyyy;
  r5.xyzw = r5.xyzw * r2.xxxx + r7.xyzw;
  r5.xyzw = r8.xyzw * r2.zzzz + r5.xyzw;
  r7.xyzw = rsqrt(r9.xyzw);
  r5.xyzw = r7.xyzw * r5.xyzw;
  r5.xyzw = max(float4(0,0,0,0), r5.xyzw);
  r7.xyzw = r9.xyzw * unity_4LightAtten0.xyzw + float4(1,1,1,1);
  r7.xyzw = float4(1,1,1,1) / r7.xyzw;
  r5.xyzw = r7.xyzw * r5.xyzw;
  r7.xyz = unity_LightColor[1].xyz * r5.yyy;
  r7.xyz = unity_LightColor[0].xyz * r5.xxx + r7.xyz;
  r5.xyz = unity_LightColor[2].xyz * r5.zzz + r7.xyz;
  r5.xyz = unity_LightColor[3].xyz * r5.www + r5.xyz;
  r7.xyzw = r2.xyzz * r2.yzzx;
  r8.x = dot(unity_SHBr.xyzw, r7.xyzw);
  r8.y = dot(unity_SHBg.xyzw, r7.xyzw);
  r8.z = dot(unity_SHBb.xyzw, r7.xyzw);
  r0.z = r2.y * r2.y;
  r0.z = r2.x * r2.x + -r0.z;
  r7.xyz = unity_SHC.xyz * r0.zzz + r8.xyz;
  o6.xyz = r7.xyz + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r1.zzz;
  r5.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r1.xxx + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r1.yyy + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r5.xyz;
  o8.xyz = float3(-1,-1,1) * r5.xyz;
  o8.w = -r5.z;
  o0.xyzw = r3.xyzw;
  o2.w = 0;
  o3.xyz = r6.xyz;
  o3.w = 0;
  o4.xyz = r4.xyz;
  o4.w = 0;
  o5.xyz = r2.xyz;
  o5.w = 0;
  o6.w = 0;
  o7.xyzw = r1.xzyw;
  o9.zw = r3.zw;
  o10.zw = v5.zw;
  o10.xy = r0.xy;
  return;
}


// ps d5c57da47d8649a1: 6 retail keyword combination(s)
void ps_d5c57da47d8649a1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD7,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  float4 v10 : TEXCOORD10,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(1024,1024) + v7.xz;
  r0.xy = r0.xy * float2(0.00048828125,0.00048828125) + float2(9.99999046,9.99999046);
  r0.zw = trunc(r0.xy);
  r1.xyzw = r0.zwzw + r0.zwzw;
  r1.xyzw = cmp(r1.xyzw >= -r1.zwzw);
  r1.xyzw = r1.xyzw ? float4(2,2,0.5,0.5) : float4(-2,-2,-0.5,-0.5);
  r0.zw = r1.zw * r0.zw;
  r0.xyzw = frac(r0.xyzw);
  r0.zw = r1.xy * r0.zw;
  r0.zw = cmp(r0.zw < float2(1,1));
  r1.xy = float2(1,1) + -r0.xy;
  r0.xy = r0.zw ? r0.xy : r1.xy;
  r0.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r0.xy, 0).xyzw;
  r0.y = dot(v10.xy, v10.xy);
  r0.y = rsqrt(r0.y);
  r1.xyzw = v10.xyxy * r0.yyyy;
  r2.xyzw = _Time.xxxx * float4(2,2,2,2) + float4(0,0,0.5,0.5);
  r2.xyzw = frac(r2.xyzw);
  r3.xyzw = r1.zwzw * r2.xyzw + v1.xyxy;
  r4.xyzw = _BumpMap.Sample(sampler_BumpMap, r3.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r3.zw).xyzw;
  r0.y = 0.5 + -r2.y;
  r0.y = abs(r0.y) + abs(r0.y);
  r2.xyz = r3.xyw + -r4.xyw;
  r2.yzw = r0.yyy * r2.xyz + r4.xyw;
  r2.x = r2.y * r2.w;
  r0.yz = r2.xz * float2(2,2) + float2(-1,-1);
  r2.xy = float2(0.100000001,0.100000001) * r0.yz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r2.xyzw = float4(0,0,0.5,0.5) + _Time.xxxx;
  r2.xyzw = frac(r2.xyzw);
  r1.xyzw = r2.xyzw * r1.xyzw;
  r1.xyzw = v1.xyxy * float4(0.25,0.25,0.25,0.25) + r1.xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r1.xy).xyzw;
  r1.xyzw = _BumpMap.Sample(sampler_BumpMap, r1.zw).xyzw;
  r1.z = 0.5 + -r2.y;
  r1.z = abs(r1.z) + abs(r1.z);
  r1.xyw = r1.xyw + -r3.xyw;
  r1.yzw = r1.zzz * r1.xyw + r3.xyw;
  r1.x = r1.y * r1.w;
  r1.xy = r1.xz * float2(2,2) + float2(-1,-1);
  r1.xy = float2(0.0850000009,0.0850000009) * r1.xy;
  r1.z = dot(r1.xy, r1.xy);
  r1.z = min(1, r1.z);
  r1.z = 1 + -r1.z;
  r1.z = sqrt(r1.z);
  r2.xy = r0.yz * float2(0.100000001,0.100000001) + r1.xy;
  r2.z = r1.z * r0.w;
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.yyy + r1.xyz;
  r0.yzw = v5.xyz * r0.www + r1.xyz;
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r0.yzw = r1.xxx * r0.yzw;
  r1.x = dot(v2.xyz, v2.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v2.xyz * r1.xxx;
  r0.x = -v7.w + r0.x;
  r0.x = -10 + abs(r0.x);
  r0.x = saturate(-0.5 * r0.x);
  r1.w = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r1.w * r0.x;
  r1.w = 1 + -_Glossiness;
  r2.x = dot(r1.xyz, r0.yzw);
  r2.x = r2.x + r2.x;
  r2.xyz = r0.yzw * -r2.xxx + r1.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r2.xyz, r2.xyz);
    r2.w = rsqrt(r2.w);
    r3.xyz = r2.xyz * r2.www;
    r4.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r4.xyz = r4.xyz / r3.xyz;
    r5.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r5.xyz = r5.xyz / r3.xyz;
    r6.xyz = cmp(float3(0,0,0) < r3.xyz);
    r4.xyz = r6.xyz ? r4.xyz : r5.xyz;
    r2.w = min(r4.x, r4.y);
    r2.w = min(r2.w, r4.z);
    r4.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r3.xyz = r3.xyz * r2.www + r4.xyz;
  } else {
    r3.xyz = r2.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r3.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r3.xyz, r2.w).xyzw;
  r3.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r3.w != 0) {
    r3.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r3.w != 0) {
      r3.w = dot(r2.xyz, r2.xyz);
      r3.w = rsqrt(r3.w);
      r4.xyz = r3.www * r2.xyz;
      r5.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r5.xyz = r5.xyz / r4.xyz;
      r6.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r6.xyz = r6.xyz / r4.xyz;
      r7.xyz = cmp(float3(0,0,0) < r4.xyz);
      r5.xyz = r7.xyz ? r5.xyz : r6.xyz;
      r3.w = min(r5.x, r5.y);
      r3.w = min(r3.w, r5.z);
      r5.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r2.xyz = r4.xyz * r3.www + r5.xyz;
    }
    r2.xyzw = unity_SpecCube1.SampleLevel(sampler_BT_Reflection, r2.xyz, r2.w).xyzw;
    r2.w = -1 + r2.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r4.xyz = r2.www * r2.xyz;
    r2.xyz = -r2.www * r2.xyz + r3.xyz;
    r3.xyz = unity_SpecCube0_BoxMin.www * r2.xyz + r4.xyz;
  }
  r2.x = _Metallic * 0.0399999991 + 0.00999999978;
  r2.y = -_Metallic * 0.99000001 + 0.99000001;
  r0.x = r0.x * 0.5 + 0.5;
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = saturate(dot(r0.yzw, -r1.xyz));
  r1.x = r1.w * r1.w;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r1.y = 1 + -r2.y;
  r1.y = saturate(_Glossiness + r1.y);
  r1.xzw = r1.xxx * r3.xyz;
  r2.y = 3 * r2.x;
  r0.x = 1 + -r0.x;
  r2.z = r0.x * r0.x;
  r2.z = r2.z * r2.z;
  r0.x = r2.z * r0.x;
  r1.y = -r2.x * 3 + r1.y;
  r0.x = r0.x * r1.y + r2.y;
  o2.xyz = r1.xzw * r0.xxx;
  o1.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.xyzw = float4(0,0,0.949999988,0);
  o1.w = 0;
  o2.w = 0;
  return;
}


// ps 6382f57d486b9f09: 6 retail keyword combination(s)
void ps_6382f57d486b9f09_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD7,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  float4 v10 : TEXCOORD10,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(1024,1024) + v7.xz;
  r0.xy = r0.xy * float2(0.00048828125,0.00048828125) + float2(9.99999046,9.99999046);
  r0.zw = trunc(r0.xy);
  r1.xyzw = r0.zwzw + r0.zwzw;
  r1.xyzw = cmp(r1.xyzw >= -r1.zwzw);
  r1.xyzw = r1.xyzw ? float4(2,2,0.5,0.5) : float4(-2,-2,-0.5,-0.5);
  r0.zw = r1.zw * r0.zw;
  r0.xyzw = frac(r0.xyzw);
  r0.zw = r1.xy * r0.zw;
  r0.zw = cmp(r0.zw < float2(1,1));
  r1.xy = float2(1,1) + -r0.xy;
  r0.xy = r0.zw ? r0.xy : r1.xy;
  r0.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r0.xy, 0).xyzw;
  r0.y = saturate(v2.w);
  r0.y = r0.y * 0.400000006 + 0.100000001;
  r0.z = dot(v10.xy, v10.xy);
  r0.z = rsqrt(r0.z);
  r1.xyzw = v10.xyxy * r0.zzzz;
  r2.xyzw = _Time.xxxx * float4(2,2,2,2) + float4(0,0,0.5,0.5);
  r2.xyzw = frac(r2.xyzw);
  r3.xyzw = r1.zwzw * r2.xyzw + v1.xyxy;
  r4.xyzw = _BumpMap.Sample(sampler_BumpMap, r3.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r3.zw).xyzw;
  r0.z = 0.5 + -r2.y;
  r0.z = abs(r0.z) + abs(r0.z);
  r2.xyz = r3.xyw + -r4.xyw;
  r2.yzw = r0.zzz * r2.xyz + r4.xyw;
  r2.x = r2.y * r2.w;
  r0.zw = r2.xz * float2(2,2) + float2(-1,-1);
  r2.xy = r0.zw * r0.yy;
  r2.x = dot(r2.xy, r2.xy);
  r2.x = min(1, r2.x);
  r2.x = 1 + -r2.x;
  r2.x = sqrt(r2.x);
  r3.xyzw = float4(0,0,0.5,0.5) + _Time.xxxx;
  r3.xyzw = frac(r3.xyzw);
  r1.xyzw = r3.xyzw * r1.xyzw;
  r1.xyzw = v1.xyxy * float4(0.25,0.25,0.25,0.25) + r1.xyzw;
  r4.xyzw = _BumpMap.Sample(sampler_BumpMap, r1.xy).xyzw;
  r1.xyzw = _BumpMap.Sample(sampler_BumpMap, r1.zw).xyzw;
  r1.z = 0.5 + -r3.y;
  r1.z = abs(r1.z) + abs(r1.z);
  r1.xyw = r1.xyw + -r4.xyw;
  r1.yzw = r1.zzz * r1.xyw + r4.xyw;
  r2.y = 0.850000024 * r0.y;
  r1.x = r1.y * r1.w;
  r1.xy = r1.xz * float2(2,2) + float2(-1,-1);
  r1.xy = r1.xy * r2.yy;
  r1.z = dot(r1.xy, r1.xy);
  r1.z = min(1, r1.z);
  r1.z = 1 + -r1.z;
  r1.z = sqrt(r1.z);
  r3.xy = r0.zw * r0.yy + r1.xy;
  r3.z = r2.x * r1.z;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = r3.xyz * r0.yyy;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.yyy + r1.xyz;
  r0.yzw = v5.xyz * r0.www + r1.xyz;
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r0.yzw = r1.xxx * r0.yzw;
  r1.x = dot(v2.xyz, v2.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v2.xyz * r1.xxx;
  r0.x = -v7.w + r0.x;
  r0.x = -10 + abs(r0.x);
  r0.x = saturate(-0.5 * r0.x);
  r1.w = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r1.w * r0.x;
  r1.w = 1 + -_Glossiness;
  r2.x = dot(r1.xyz, r0.yzw);
  r2.x = r2.x + r2.x;
  r2.xyz = r0.yzw * -r2.xxx + r1.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r2.xyz, r2.xyz);
    r2.w = rsqrt(r2.w);
    r3.xyz = r2.xyz * r2.www;
    r4.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r4.xyz = r4.xyz / r3.xyz;
    r5.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r5.xyz = r5.xyz / r3.xyz;
    r6.xyz = cmp(float3(0,0,0) < r3.xyz);
    r4.xyz = r6.xyz ? r4.xyz : r5.xyz;
    r2.w = min(r4.x, r4.y);
    r2.w = min(r2.w, r4.z);
    r4.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r3.xyz = r3.xyz * r2.www + r4.xyz;
  } else {
    r3.xyz = r2.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r3.xyzw = _BT_Reflection.SampleLevel(sampler_BT_Reflection, r3.xyz, r2.w).xyzw;
  r3.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r3.w != 0) {
    r3.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r3.w != 0) {
      r3.w = dot(r2.xyz, r2.xyz);
      r3.w = rsqrt(r3.w);
      r4.xyz = r3.www * r2.xyz;
      r5.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r5.xyz = r5.xyz / r4.xyz;
      r6.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r6.xyz = r6.xyz / r4.xyz;
      r7.xyz = cmp(float3(0,0,0) < r4.xyz);
      r5.xyz = r7.xyz ? r5.xyz : r6.xyz;
      r3.w = min(r5.x, r5.y);
      r3.w = min(r3.w, r5.z);
      r5.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r2.xyz = r4.xyz * r3.www + r5.xyz;
    }
    r2.xyzw = unity_SpecCube1.SampleLevel(sampler_BT_Reflection, r2.xyz, r2.w).xyzw;
    r2.w = -1 + r2.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r4.xyz = r2.www * r2.xyz;
    r2.xyz = -r2.www * r2.xyz + r3.xyz;
    r3.xyz = unity_SpecCube0_BoxMin.www * r2.xyz + r4.xyz;
  }
  r2.x = _Metallic * 0.0399999991 + 0.00999999978;
  r2.y = -_Metallic * 0.99000001 + 0.99000001;
  r0.x = r0.x * 0.5 + 0.5;
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = saturate(dot(r0.yzw, -r1.xyz));
  r1.x = r1.w * r1.w;
  r1.x = r1.x * r1.x + 1;
  r1.x = 1 / r1.x;
  r1.y = 1 + -r2.y;
  r1.y = saturate(_Glossiness + r1.y);
  r1.xzw = r1.xxx * r3.xyz;
  r2.y = 3 * r2.x;
  r0.x = 1 + -r0.x;
  r2.z = r0.x * r0.x;
  r2.z = r2.z * r2.z;
  r0.x = r2.z * r0.x;
  r1.y = -r2.x * 3 + r1.y;
  r0.x = r0.x * r1.y + r2.y;
  o2.xyz = r1.xzw * r0.xxx;
  o1.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.xyzw = float4(0,0,0.949999988,0);
  o1.w = 0;
  o2.w = 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && !defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_ab49c65d5565d598_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#elif defined(LIGHTPROBE_SH) && !defined(VERTEXLIGHT_ON) && !defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_e4a76ad09b3022ad_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_e74464bdfa18da29_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1, v.texcoord2.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#elif defined(LIGHTPROBE_SH) && defined(VERTEXLIGHT_ON) && !defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_55889f862c54b0f3_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_307468efcef94919_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#elif defined(LIGHTPROBE_SH) && !defined(VERTEXLIGHT_ON) && defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_cf907010dd1d60b1_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_bca9f0c834939fa5_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1, v.texcoord2.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#elif defined(LIGHTPROBE_SH) && defined(VERTEXLIGHT_ON) && defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_97fba076d47f5d1f_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_GEN_WATER)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_d5c57da47d8649a1_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(_GEN_WATER)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_6382f57d486b9f09_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
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
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _GEN_WATER
			#pragma multi_compile _ _NORMALMAP

#define cmp -

Texture2D _BT_TerrainHeight;
SamplerState sampler_BT_TerrainHeight;

float4 _BT_GlobalWind;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 normal0 : NORMAL0;
	float4 tangent0 : TANGENT0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};

#if !defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#else
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#endif

struct fout
{
	float t0 : SV_Target0;
};

// vs ab49c65d5565d598: 1 retail keyword combination(s)
void vs_ab49c65d5565d598_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[1][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[1][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[1][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.wwww + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.wwww;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r0.xzxz;
  o2.w = 0;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xwz;
  o3.xyzw = float4(0,0,1,0);
  o4.xyzw = float4(1,0,0,0);
  o5.xyzw = float4(0,1,0,0);
  o6.xyzw = float4(0,0,0,0);
  o7.xyzw = r0.xyzw;
  r2.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r0.www;
  r0.xyw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r0.xyz;
  o8.xyz = float3(-1,-1,1) * r0.xyz;
  o8.w = -r0.z;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  o9.xy = r0.xw + r0.zz;
  r0.x = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.x = rsqrt(r0.x);
  r0.xy = _BT_GlobalWind.xz * r0.xx;
  r0.z = v5.x + v5.y;
  r0.z = cmp(r0.z < 0.200000003);
  o10.xy = r0.zz ? r0.xy : v5.xy;
  o10.zw = v5.zw;
  return;
}


// vs 307468efcef94919: 1 retail keyword combination(s)
void vs_307468efcef94919_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  const float4 icb[] = { { 0, 0, 0.130899698, 0.250000},
                              { 0.100000, -0.100000, 0.202683404, 0.250000},
                              { -0.200000, 0.200000, 0.108330779, 0.150000},
                              { -0.800000, -0.300000, 0.103003040, 0.250000},
                              { -0.200000, 0.100000, 0.139626339, 0.150000},
                              { 0.274889350, 0, 0, 0},
                              { 1.074222, 0, 0, 0},
                              { 0.162496164, 0, 0, 0},
                              { 0.834324598, 0, 0, 0},
                              { 0.418879032, 0, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v5.x + v5.y;
  r0.x = cmp(r0.x < 0.200000003);
  r0.y = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.y = rsqrt(r0.y);
  r0.yz = _BT_GlobalWind.xz * r0.yy;
  r0.xy = r0.xx ? r0.yz : v5.xy;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyw = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.www + r1.xzy;
  r0.zw = float2(1024,1024) + r1.xy;
  r0.zw = r0.zw * float2(0.00048828125,0.00048828125) + float2(9.99999046,9.99999046);
  r2.xy = trunc(r0.zw);
  r0.zw = frac(r0.zw);
  r3.xyzw = r2.xyxy + r2.xyxy;
  r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
  r3.xyzw = r3.xyzw ? float4(2,2,0.5,0.5) : float4(-2,-2,-0.5,-0.5);
  r2.xy = r3.zw * r2.xy;
  r2.xy = frac(r2.xy);
  r2.xy = r3.xy * r2.xy;
  r2.xy = cmp(r2.xy < float2(1,1));
  r2.zw = float2(1,1) + -r0.zw;
  r0.zw = r2.xy ? r0.zw : r2.zw;
  r2.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r0.zw, 0).xyzw;
  r0.z = cmp(r2.x < r1.w);
  [branch] if (r0.z != 0) {
    r0.z = dot(r0.xy, r0.xy);
    r0.z = rsqrt(r0.z);
    r2.yz = r0.xy * r0.zz;
    r2.x = max(9.99999975e-006, r2.y);
    r0.z = dot(r2.xz, r2.xz);
    r0.z = rsqrt(r0.z);
    r0.zw = r2.xz * r0.zz;
    r2.xz = float2(0,0);
    r3.zw = float2(0,0);
    r3.xy = r0.zw;
    r5.xy = r1.xy;
    r4.xyw = float3(0,0,0);
    r6.y = 0;
    r1.z = r1.w;
    r5.zw = float2(0,0);
    [loop] while (true) {
      r6.w = cmp((uint)r5.w >= 5);
      [branch] if (r6.w != 0) break;
      r7.xy = icb[r5.w+0].xy + r3.xy;
      r6.w = dot(r7.xy, r7.xy);
      r6.w = rsqrt(r6.w);
      r7.xy = r7.xy * r6.ww;
      r6.w = (int)r5.w & 1;
      r7.z = (uint)r5.w;
      r7.z = 1 + r7.z;
      r7.zw = r7.yx / r7.zz;
      r3.xy = r6.ww ? r7.zw : r7.xy;
      r6.w = dot(r5.xy, r3.xy);
      r7.x = icb[r5.w+0].z + icb[r5.w+0].z;
      r7.y = icb[r5.w+0].w * r7.x;
      r7.y = 0.25 * r7.y;
      r7.z = 1 / r7.y;
      r7.z = -9.99999975e-005 + r7.z;
      r7.zw = r7.zz * float2(0.200000003,0.200000003) + float2(9.99999975e-005,-0.999899983);
      r8.x = icb[r5.w+5].x * _Time.w;
      r6.w = r7.x * r6.w + r8.x;
      sincos(r6.w, r7.x, r8.x);
      r6.w = icb[r5.w+0].w * r7.z;
      r8.yz = r6.ww * r3.xy;
      r8.yz = r8.yz * r8.xx;
      r5.xy = r8.yz * float2(0.25,0.25) + r5.xy;
      r6.w = icb[r5.w+0].w * r7.x;
      r1.z = r6.w * 0.25 + r1.z;
      r6.w = r7.y * r7.x;
      r7.x = r8.x * r7.y;
      r7.y = r7.z * r3.x;
      r8.xy = r7.yy * r3.xy;
      r5.z = r8.x * r6.w + r5.z;
      r8.xz = r3.xy * r3.yy;
      r4.w = r8.x * r6.w + r4.w;
      r6.y = r3.x * r7.x + r6.y;
      r4.x = r8.y * r6.w + r4.x;
      r7.y = r8.z * r7.z;
      r3.z = r7.y * r6.w + r3.z;
      r4.y = r3.y * r7.x + r4.y;
      r2.xz = -r3.xy * r7.xx + r2.xz;
      r7.x = r7.w * 0.200000003 + 1;
      r3.w = r7.x * r6.w + r3.w;
      r5.w = (int)r5.w + 1;
    }
    r1.xy = r5.xy;
    r6.x = 1 + -r5.z;
    r6.z = -r4.w;
    r2.yw = float2(1,1) + -r3.wz;
    r4.z = r2.w;
  } else {
    r2.xyz = float3(0,1,0);
    r4.xyz = float3(1,0,0);
    r6.xyz = float3(0,0,1);
    r1.xyz = r1.xyw;
  }
  r3.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.zzzz;
  r3.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.yyyy + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r3.xyzw;
  r5.xz = float2(0.5,0.5) * r3.xw;
  r0.z = _ProjectionParams.x * r3.y;
  r5.w = 0.5 * r0.z;
  o9.xy = r5.xw + r5.zz;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r1.xyxy;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xzy;
  r5.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r1.zzz;
  r5.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r1.xxx + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r1.yyy + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r5.xyz;
  o8.xyz = float3(-1,-1,1) * r5.xyz;
  o8.w = -r5.z;
  o0.xyzw = r3.xyzw;
  o2.w = 0;
  o3.xyz = r6.xyz;
  o3.w = 0;
  o4.xyz = r4.xyz;
  o4.w = 0;
  o5.xyz = r2.xyz;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  o7.xyzw = r1.xzyw;
  o9.zw = r3.zw;
  o10.zw = v5.zw;
  o10.xy = r0.xy;
  return;
}


// ps f806ba390739bb43: 2 retail keyword combination(s)
void ps_f806ba390739bb43_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD7,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  float4 v10 : TEXCOORD10,
  inout float o0 : SV_Target0)
{
  o0.x = v9.z / v9.w;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_ab49c65d5565d598_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#elif defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_307468efcef94919_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
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
		float o0 = 0;
		ps_f806ba390739bb43_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
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
			ZWrite Off
			ColorMask B

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _GEN_WATER
			#pragma multi_compile _ _NORMALMAP

#define cmp -

Texture2D _BT_TerrainHeight;
SamplerState sampler_BT_TerrainHeight;

float4 _BT_GlobalWind;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 normal0 : NORMAL0;
	float4 tangent0 : TANGENT0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};

#if !defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(_GEN_WATER)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
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
};

// vs ab49c65d5565d598: 1 retail keyword combination(s)
void vs_ab49c65d5565d598_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[1][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[1][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[1][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.wwww + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.wwww;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r0.xzxz;
  o2.w = 0;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xwz;
  o3.xyzw = float4(0,0,1,0);
  o4.xyzw = float4(1,0,0,0);
  o5.xyzw = float4(0,1,0,0);
  o6.xyzw = float4(0,0,0,0);
  o7.xyzw = r0.xyzw;
  r2.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r0.www;
  r0.xyw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r0.xyz;
  o8.xyz = float3(-1,-1,1) * r0.xyz;
  o8.w = -r0.z;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  o9.xy = r0.xw + r0.zz;
  r0.x = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.x = rsqrt(r0.x);
  r0.xy = _BT_GlobalWind.xz * r0.xx;
  r0.z = v5.x + v5.y;
  r0.z = cmp(r0.z < 0.200000003);
  o10.xy = r0.zz ? r0.xy : v5.xy;
  o10.zw = v5.zw;
  return;
}


// vs 307468efcef94919: 1 retail keyword combination(s)
void vs_307468efcef94919_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  float4 v5 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD7,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout float4 o10 : TEXCOORD10)
{
  const float4 icb[] = { { 0, 0, 0.130899698, 0.250000},
                              { 0.100000, -0.100000, 0.202683404, 0.250000},
                              { -0.200000, 0.200000, 0.108330779, 0.150000},
                              { -0.800000, -0.300000, 0.103003040, 0.250000},
                              { -0.200000, 0.100000, 0.139626339, 0.150000},
                              { 0.274889350, 0, 0, 0},
                              { 1.074222, 0, 0, 0},
                              { 0.162496164, 0, 0, 0},
                              { 0.834324598, 0, 0, 0},
                              { 0.418879032, 0, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v5.x + v5.y;
  r0.x = cmp(r0.x < 0.200000003);
  r0.y = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.y = rsqrt(r0.y);
  r0.yz = _BT_GlobalWind.xz * r0.yy;
  r0.xy = r0.xx ? r0.yz : v5.xy;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyw = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[1][3]) * v0.www + r1.xzy;
  r0.zw = float2(1024,1024) + r1.xy;
  r0.zw = r0.zw * float2(0.00048828125,0.00048828125) + float2(9.99999046,9.99999046);
  r2.xy = trunc(r0.zw);
  r0.zw = frac(r0.zw);
  r3.xyzw = r2.xyxy + r2.xyxy;
  r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
  r3.xyzw = r3.xyzw ? float4(2,2,0.5,0.5) : float4(-2,-2,-0.5,-0.5);
  r2.xy = r3.zw * r2.xy;
  r2.xy = frac(r2.xy);
  r2.xy = r3.xy * r2.xy;
  r2.xy = cmp(r2.xy < float2(1,1));
  r2.zw = float2(1,1) + -r0.zw;
  r0.zw = r2.xy ? r0.zw : r2.zw;
  r2.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r0.zw, 0).xyzw;
  r0.z = cmp(r2.x < r1.w);
  [branch] if (r0.z != 0) {
    r0.z = dot(r0.xy, r0.xy);
    r0.z = rsqrt(r0.z);
    r2.yz = r0.xy * r0.zz;
    r2.x = max(9.99999975e-006, r2.y);
    r0.z = dot(r2.xz, r2.xz);
    r0.z = rsqrt(r0.z);
    r0.zw = r2.xz * r0.zz;
    r2.xz = float2(0,0);
    r3.zw = float2(0,0);
    r3.xy = r0.zw;
    r5.xy = r1.xy;
    r4.xyw = float3(0,0,0);
    r6.y = 0;
    r1.z = r1.w;
    r5.zw = float2(0,0);
    [loop] while (true) {
      r6.w = cmp((uint)r5.w >= 5);
      [branch] if (r6.w != 0) break;
      r7.xy = icb[r5.w+0].xy + r3.xy;
      r6.w = dot(r7.xy, r7.xy);
      r6.w = rsqrt(r6.w);
      r7.xy = r7.xy * r6.ww;
      r6.w = (int)r5.w & 1;
      r7.z = (uint)r5.w;
      r7.z = 1 + r7.z;
      r7.zw = r7.yx / r7.zz;
      r3.xy = r6.ww ? r7.zw : r7.xy;
      r6.w = dot(r5.xy, r3.xy);
      r7.x = icb[r5.w+0].z + icb[r5.w+0].z;
      r7.y = icb[r5.w+0].w * r7.x;
      r7.y = 0.25 * r7.y;
      r7.z = 1 / r7.y;
      r7.z = -9.99999975e-005 + r7.z;
      r7.zw = r7.zz * float2(0.200000003,0.200000003) + float2(9.99999975e-005,-0.999899983);
      r8.x = icb[r5.w+5].x * _Time.w;
      r6.w = r7.x * r6.w + r8.x;
      sincos(r6.w, r7.x, r8.x);
      r6.w = icb[r5.w+0].w * r7.z;
      r8.yz = r6.ww * r3.xy;
      r8.yz = r8.yz * r8.xx;
      r5.xy = r8.yz * float2(0.25,0.25) + r5.xy;
      r6.w = icb[r5.w+0].w * r7.x;
      r1.z = r6.w * 0.25 + r1.z;
      r6.w = r7.y * r7.x;
      r7.x = r8.x * r7.y;
      r7.y = r7.z * r3.x;
      r8.xy = r7.yy * r3.xy;
      r5.z = r8.x * r6.w + r5.z;
      r8.xz = r3.xy * r3.yy;
      r4.w = r8.x * r6.w + r4.w;
      r6.y = r3.x * r7.x + r6.y;
      r4.x = r8.y * r6.w + r4.x;
      r7.y = r8.z * r7.z;
      r3.z = r7.y * r6.w + r3.z;
      r4.y = r3.y * r7.x + r4.y;
      r2.xz = -r3.xy * r7.xx + r2.xz;
      r7.x = r7.w * 0.200000003 + 1;
      r3.w = r7.x * r6.w + r3.w;
      r5.w = (int)r5.w + 1;
    }
    r1.xy = r5.xy;
    r6.x = 1 + -r5.z;
    r6.z = -r4.w;
    r2.yw = float2(1,1) + -r3.wz;
    r4.z = r2.w;
  } else {
    r2.xyz = float3(0,1,0);
    r4.xyz = float3(1,0,0);
    r6.xyz = float3(0,0,1);
    r1.xyz = r1.xyw;
  }
  r3.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.zzzz;
  r3.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.yyyy + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r3.xyzw;
  r5.xz = float2(0.5,0.5) * r3.xw;
  r0.z = _ProjectionParams.x * r3.y;
  r5.w = 0.5 * r0.z;
  o9.xy = r5.xw + r5.zz;
  o1.xyzw = float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) * r1.xyxy;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xzy;
  r5.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r1.zzz;
  r5.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r1.xxx + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r1.yyy + r5.xyz;
  r5.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) + r5.xyz;
  o8.xyz = float3(-1,-1,1) * r5.xyz;
  o8.w = -r5.z;
  o0.xyzw = r3.xyzw;
  o2.w = 0;
  o3.xyz = r6.xyz;
  o3.w = 0;
  o4.xyz = r4.xyz;
  o4.w = 0;
  o5.xyz = r2.xyz;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  o7.xyzw = r1.xzyw;
  o9.zw = r3.zw;
  o10.zw = v5.zw;
  o10.xy = r0.xy;
  return;
}


// ps 7fabc991b3b58b11: 2 retail keyword combination(s)
void ps_7fabc991b3b58b11_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD7,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  float4 v10 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = float4(0,0,0,0);
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_ab49c65d5565d598_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
	}
#elif defined(_GEN_WATER)
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
		float4 o9 = 0;
		float4 o10 = 0;
		vs_307468efcef94919_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, v.color0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord7 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.texcoord10 = o10;
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
		ps_7fabc991b3b58b11_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
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
