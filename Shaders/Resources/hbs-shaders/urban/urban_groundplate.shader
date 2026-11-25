Shader "Urban/Urban Ground Plate"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
		[Enum(None, 0, Forest, 1, Rough, 2, Road, 3, Impassable, 4, Special, 5)] _LayerMask ("Layer Mask", Float) = 0
		[Enum(Object, 0, World, 1)] _UVSpace ("Texture Space", Float) = 0
		_Seed ("Random Seed(x, y), Random Scale(z, w)", Vector) = (0,0,0.0001,0.0001)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		[Gamma] _Metallic ("Metallic", Range(0,1)) = 0
		_MetallicGlossMap ("Metallic", 2D) = "white" {}
		_BumpScale ("Scale", Float) = 1
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_OcclusionStrength ("Strength", Range(0,1)) = 1
		_OcclusionMap ("Occlusion", 2D) = "white" {}
		_EmissionColor ("Color", Color) = (0,0,0,1)
		_EmissionMap ("Emission", 2D) = "white" {}
		_DetailAlbedoMap ("Detail Albedo", 2D) = "grey" {}
		_DetailOcclusionMap ("Detail Occlusion", 2D) = "white" {}
		_DetailMetallicGlossMap ("Detail Metallic", 2D) = "white" {}
		_DetailNormalMapScale ("Scale", Float) = 1
		_DetailNormalMap ("Normal Map", 2D) = "bump" {}
		[HideInInspector] _Mode ("__mode", Float) = 0
		[HideInInspector] _SrcBlend ("__src", Float) = 1
		[HideInInspector] _DstBlend ("__dst", Float) = 0
		[HideInInspector] _ZWrite ("__zw", Float) = 1
		[Enum(No, 0, Yes, 1)] __detail ("__detail", Float) = 0
	}
	SubShader
	{
		Tags { "Queue"="Geometry+10" "RenderType"="Opaque" "SurfaceType"="GroundPlate" }
		LOD 100
		Pass
		{
			Name "FORWARD"
			Tags { "LightMode"="ForwardBase" }
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ DIRECTIONAL
			#pragma multi_compile _ LIGHTPROBE_SH
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _EMISSION
			#pragma multi_compile _ _FOG_3D
			#pragma multi_compile _ _METALLICGLOSSMAP
			#pragma multi_compile _ _NORMALMAP

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _OcclusionMap;
SamplerState sampler_OcclusionMap;
Texture2D _BumpMap;
SamplerState sampler_BumpMap;
Texture2D _MetallicGlossMap;
SamplerState sampler_MetallicGlossMap;
Texture2D _FogIntegrationTex;
SamplerState sampler_FogIntegrationTex;
Texture3D _FogIntegration3D;
SamplerState sampler_FogIntegration3D;
Texture2D _EmissionMap;
SamplerState sampler_EmissionMap;

float4 _MainTex_ST;
float4 _DetailAlbedoMap_ST;
float4 _DetailMask_ST;
float _UVSec;
float _UVSecMask;
float4 _LightColor0;
float4 _Color;
float _Metallic;
float _Glossiness;
float _OcclusionStrength;
float _BumpScale;
float4 _EmissionColor;
float _BT_NightLights;
float _EmissiveMode;
float _EV;
float4 _ScaleOffset;
float3 _VolumeSize;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 tangent0 : TANGENT0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};

#if !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
};
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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

// vs 5a3a748f6139fc37: 6 retail keyword combination(s)
void vs_5a3a748f6139fc37_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD8,
  inout float4 o8 : TEXCOORD9,
  inout float4 o9 : TEXCOORD10)
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
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r0.xyzw = r0.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r0.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r0.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o7.xyz = r0.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o5.xyz = r0.xyz * r0.www;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  return;
}


// vs 8dcf4e10631baab1: 6 retail keyword combination(s)
void vs_8dcf4e10631baab1_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD8,
  inout float4 o8 : TEXCOORD9,
  inout float4 o9 : TEXCOORD10)
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
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r0.xyzw = r0.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r0.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r0.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o7.xyz = r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o3.xyz = r0.xyz;
  o3.w = 0;
  r1.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.xyz = r1.zxy * r0.yzx;
  r0.xyz = r1.yzx * r0.zxy + -r2.xyz;
  r0.w = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r0.xyz * r0.www;
  o4.w = 0;
  o5.xyz = r1.xyz;
  o5.w = 0;
  r0.x = r1.y * r1.y;
  r0.x = r1.x * r1.x + -r0.x;
  r1.xyzw = r1.xyzz * r1.yzzx;
  r2.x = dot(unity_SHBr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHBg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHBb.xyzw, r1.xyzw);
  o6.xyz = unity_SHC.xyz * r0.xxx + r2.xyz;
  o6.w = 0;
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  return;
}


// vs a1a88f5059d212ed: 6 retail keyword combination(s)
void vs_a1a88f5059d212ed_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD8,
  inout float4 o8 : TEXCOORD9,
  inout float4 o9 : TEXCOORD10)
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
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r0.xyzw = r0.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r0.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r0.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o7.xyz = r0.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o5.xyz = r0.xyz;
  o5.w = 0;
  r0.w = r0.y * r0.y;
  r0.w = r0.x * r0.x + -r0.w;
  r1.xyzw = r0.xyzz * r0.yzzx;
  r0.x = dot(unity_SHBr.xyzw, r1.xyzw);
  r0.y = dot(unity_SHBg.xyzw, r1.xyzw);
  r0.z = dot(unity_SHBb.xyzw, r1.xyzw);
  o6.xyz = unity_SHC.xyz * r0.www + r0.xyz;
  o6.w = 0;
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  return;
}


// vs 802e47eca2eba240: 6 retail keyword combination(s)
void vs_802e47eca2eba240_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD8,
  inout float4 o8 : TEXCOORD9,
  inout float4 o9 : TEXCOORD10)
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
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r0.xyzw = r0.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r0.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r0.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o7.xyz = r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o3.xyz = r0.xyz;
  o3.w = 0;
  r1.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.xyz = r1.zxy * r0.yzx;
  r0.xyz = r1.yzx * r0.zxy + -r2.xyz;
  o5.xyz = r1.xyz;
  r0.w = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r0.xyz * r0.www;
  o4.w = 0;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  return;
}


// vs f540b2c00c7085d1: 6 retail keyword combination(s)
void vs_f540b2c00c7085d1_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
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

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r2.xyzw = r2.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r2.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o9.xy = r2.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r2.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r2.xyz;
  o8.xyz = r2.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r2.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r2.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r2.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  o5.xyz = r2.xyz * r1.zzz;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o7.w = r1.w;
  o7.xy = r0.xw + r0.zz;
  o9.zw = float2(0,0);
  o10.xyzw = float4(0,0,0,0);
  return;
}


// vs 3f9fedfb41a210c6: 6 retail keyword combination(s)
void vs_3f9fedfb41a210c6_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
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

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r2.xyzw = r2.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r2.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o9.xy = r2.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r2.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r2.xyz;
  o8.xyz = r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r2.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  o3.xyz = r2.xyz;
  o3.w = 0;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r4.xyz = r3.zxy * r2.yzx;
  r2.xyz = r3.yzx * r2.zxy + -r4.xyz;
  r1.z = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r2.xyz * r1.zzz;
  o4.w = 0;
  o5.xyz = r3.xyz;
  o5.w = 0;
  r1.z = r3.y * r3.y;
  r1.z = r3.x * r3.x + -r1.z;
  r2.xyzw = r3.xyzz * r3.yzzx;
  r3.x = dot(unity_SHBr.xyzw, r2.xyzw);
  r3.y = dot(unity_SHBg.xyzw, r2.xyzw);
  r3.z = dot(unity_SHBb.xyzw, r2.xyzw);
  o6.xyz = unity_SHC.xyz * r1.zzz + r3.xyz;
  o6.w = 0;
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o7.w = r1.w;
  o7.xy = r0.xw + r0.zz;
  o9.zw = float2(0,0);
  o10.xyzw = float4(0,0,0,0);
  return;
}


// vs cbf60bce4b65a03a: 6 retail keyword combination(s)
void vs_cbf60bce4b65a03a_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
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
  float4 r0,r1,r2,r3;
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
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r2.xyzw = r2.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r2.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o9.xy = r2.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r2.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r2.xyz;
  o8.xyz = r2.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r2.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r2.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r2.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  o5.xyz = r2.xyz;
  o5.w = 0;
  r1.z = r2.y * r2.y;
  r1.z = r2.x * r2.x + -r1.z;
  r2.xyzw = r2.xyzz * r2.yzzx;
  r3.x = dot(unity_SHBr.xyzw, r2.xyzw);
  r3.y = dot(unity_SHBg.xyzw, r2.xyzw);
  r3.z = dot(unity_SHBb.xyzw, r2.xyzw);
  o6.xyz = unity_SHC.xyz * r1.zzz + r3.xyz;
  o6.w = 0;
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o7.w = r1.w;
  o7.xy = r0.xw + r0.zz;
  o9.zw = float2(0,0);
  o10.xyzw = float4(0,0,0,0);
  return;
}


// vs ab5492553953bfa2: 6 retail keyword combination(s)
void vs_ab5492553953bfa2_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
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

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r2.xyzw = r2.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r2.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o9.xy = r2.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r2.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r2.xyz;
  o8.xyz = r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r2.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  o3.xyz = r2.xyz;
  o3.w = 0;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz;
  r4.xyz = r3.zxy * r2.yzx;
  r2.xyz = r3.yzx * r2.zxy + -r4.xyz;
  o5.xyz = r3.xyz;
  r1.z = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r2.xyz * r1.zzz;
  o4.w = 0;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o7.w = r1.w;
  o7.xy = r0.xw + r0.zz;
  o9.zw = float2(0,0);
  o10.xyzw = float4(0,0,0,0);
  return;
}


// ps d62c84a79ed13cc9: 2 retail keyword combination(s)
void ps_d62c84a79ed13cc9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r0.w = dot(v5.xyz, v5.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = v5.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r2.w = 1 + -_Glossiness;
  r3.w = dot(r3.xyz, r2.xyz);
  r3.w = r3.w + r3.w;
  r4.xyz = r2.xyz * -r3.www + r3.xyz;
  r3.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r3.w != 0) {
    r3.w = dot(r4.xyz, r4.xyz);
    r3.w = rsqrt(r3.w);
    r5.xyz = r4.xyz * r3.www;
    r6.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r6.xyz = r6.xyz / r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r7.xyz = r7.xyz / r5.xyz;
    r8.xyz = cmp(float3(0,0,0) < r5.xyz);
    r6.xyz = r8.xyz ? r6.xyz : r7.xyz;
    r3.w = min(r6.x, r6.y);
    r3.w = min(r3.w, r6.z);
    r6.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r5.xyz = r5.xyz * r3.www + r6.xyz;
  } else {
    r5.xyz = r4.xyz;
  }
  r3.w = -r2.w * 0.699999988 + 1.70000005;
  r3.w = r3.w * r2.w;
  r3.w = 6 * r3.w;
  r5.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r5.xyz, r3.w).xyzw;
  r4.w = -1 + r5.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r6.xyz = r4.www * r5.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r7.xyz = r5.www * r4.xyz;
      r8.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r8.xyz = r8.xyz / r7.xyz;
      r9.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r9.xyz = r9.xyz / r7.xyz;
      r10.xyz = cmp(float3(0,0,0) < r7.xyz);
      r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
      r5.w = min(r8.x, r8.y);
      r5.w = min(r5.w, r8.z);
      r8.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r4.xyz = r7.xyz * r5.www + r8.xyz;
    }
    r7.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
    r3.w = -1 + r7.w;
    r3.w = unity_SpecCube1_HDR.w * r3.w + 1;
    r3.w = log2(r3.w);
    r3.w = unity_SpecCube1_HDR.y * r3.w;
    r3.w = exp2(r3.w);
    r3.w = unity_SpecCube1_HDR.x * r3.w;
    r4.xyz = r3.www * r7.xyz;
    r5.xyz = r4.www * r5.xyz + -r4.xyz;
    r6.xyz = unity_SpecCube0_BoxMin.www * r5.xyz + r4.xyz;
  }
  r4.xyz = r6.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r1.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r1.xyz * r1.www;
  r5.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r5.xyz, r5.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r5.xyz = r5.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r5.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r5.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r2.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r2.w = r2.w * r2.w;
  r2.w = max(0.00200000009, r2.w);
  r3.y = 1 + -r2.w;
  r3.w = abs(r0.w) * r3.y + r2.w;
  r3.y = r3.x * r3.y + r2.w;
  r0.w = r3.y * abs(r0.w);
  r0.w = r3.x * r3.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.y = r2.w * r2.w;
  r3.w = r2.x * r3.y + -r2.x;
  r2.x = r3.w * r2.x + 1;
  r3.y = 0.318309873 * r3.y;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.y / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r2.w * r2.w + 1;
  r2.x = 1 / r2.x;
  r2.w = dot(r0.xyz, r0.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.w = r2.w * r0.w;
  r1.w = _Glossiness + -r1.w;
  r1.w = saturate(1 + r1.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r2.y = r0.w * r0.w;
  r2.y = r2.y * r2.y;
  r0.w = r2.y * r0.w;
  r2.yzw = float3(1,1,1) + -r0.xyz;
  r2.yzw = r2.yzw * r0.www + r0.xyz;
  r2.yzw = r5.xyz * r2.yzw;
  r1.xyz = r1.xyz * r3.xyw + r2.yzw;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r1.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  o0.xyz = r2.xyz * r0.xyz + r1.xyz;
  o0.w = 1;
  return;
}


// ps 2b73e31a95f5fab5: 2 retail keyword combination(s)
void ps_2b73e31a95f5fab5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r2.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r2.xy = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r2.yzw = v4.xyz * r2.yyy;
  r2.xyz = v3.xyz * r2.xxx + r2.yzw;
  r2.xyz = v5.xyz * r0.www + r2.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r3.w = 1 + -_Glossiness;
  r4.x = dot(r3.xyz, r2.xyz);
  r4.x = r4.x + r4.x;
  r4.xyz = r2.xyz * -r4.xxx + r3.xyz;
  r4.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r4.w != 0) {
    r4.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r5.xyz;
    r5.xyz = r4.www ? r5.xyz : v7.xyz;
    r5.xyz = -unity_ProbeVolumeMin.xyz + r5.xyz;
    r5.yzw = unity_ProbeVolumeSizeInv.xyz * r5.xyz;
    r4.w = 0.25 * r5.y;
    r5.y = 0.5 * unity_ProbeVolumeParams.z;
    r6.x = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r4.w = max(r5.y, r4.w);
    r5.x = min(r4.w, r6.x);
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xzw).xyzw;
    r7.xyz = float3(0.25,0,0) + r5.xzw;
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r7.xyz).xyzw;
    r5.xyz = float3(0.5,0,0) + r5.xzw;
    r5.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xyz).xyzw;
    r2.w = 1;
    r6.x = dot(r6.xyzw, r2.xyzw);
    r6.y = dot(r7.xyzw, r2.xyzw);
    r6.z = dot(r5.xyzw, r2.xyzw);
  } else {
    r2.w = 1;
    r6.x = dot(unity_SHAr.xyzw, r2.xyzw);
    r6.y = dot(unity_SHAg.xyzw, r2.xyzw);
    r6.z = dot(unity_SHAb.xyzw, r2.xyzw);
  }
  r5.xyz = v6.xyz + r6.xyz;
  r5.xyz = max(float3(0,0,0), r5.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r4.xyz, r4.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r4.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r4.xyz;
  }
  r2.w = -r3.w * 0.699999988 + 1.70000005;
  r2.w = r3.w * r2.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r4.w = -1 + r6.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r7.xyz = r4.www * r6.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r8.xyz = r5.www * r4.xyz;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r5.w = min(r9.x, r9.y);
      r5.w = min(r5.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r4.xyz = r8.xyz * r5.www + r9.xyz;
    }
    r8.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r2.w).xyzw;
    r2.w = -1 + r8.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r4.xyz = r2.www * r8.xyz;
    r6.xyz = r4.www * r6.xyz + -r4.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r4.xyz;
  }
  r4.xyz = r7.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r2.www * r1.xyz;
  r6.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r6.xyz, r6.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r6.xyz = r6.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r6.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r3.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r4.w = r3.z * r3.z;
  r4.w = r4.w * r4.w;
  r3.z = r4.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r3.y = r3.w * r3.w;
  r3.y = max(0.00200000009, r3.y);
  r3.w = 1 + -r3.y;
  r4.w = abs(r0.w) * r3.w + r3.y;
  r3.w = r3.x * r3.w + r3.y;
  r0.w = r3.w * abs(r0.w);
  r0.w = r3.x * r4.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.w = r3.y * r3.y;
  r4.w = r2.x * r3.w + -r2.x;
  r2.x = r4.w * r2.x + 1;
  r3.w = 0.318309873 * r3.w;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.w / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r3.y * r3.y + 1;
  r2.x = 1 / r2.x;
  r3.x = dot(r0.xyz, r0.xyz);
  r3.x = cmp(r3.x != 0.000000);
  r3.x = r3.x ? 1.000000 : 0;
  r0.w = r3.x * r0.w;
  r2.w = _Glossiness + -r2.w;
  r2.w = saturate(1 + r2.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r3.xyw = r5.xyz * r1.www + r3.xyw;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r1.w = r0.w * r0.w;
  r1.w = r1.w * r1.w;
  r0.w = r1.w * r0.w;
  r6.xyz = float3(1,1,1) + -r0.xyz;
  r6.xyz = r6.xyz * r0.www + r0.xyz;
  r5.xyz = r6.xyz * r5.xyz;
  r1.xyz = r1.xyz * r3.xyw + r5.xyz;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r2.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  o0.xyz = r2.xyz * r0.xyz + r1.xyz;
  o0.w = 1;
  return;
}


// ps a6da6af2cfa68497: 2 retail keyword combination(s)
void ps_a6da6af2cfa68497_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v7.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  o0.xyz = r2.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps 70ede3492a50b70f: 2 retail keyword combination(s)
void ps_70ede3492a50b70f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v7.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  o0.xyz = r1.xyz * r0.www + r0.xyz;
  o0.w = 1;
  return;
}


// ps fc10e403f890fdee: 2 retail keyword combination(s)
void ps_fc10e403f890fdee_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v7.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  o0.xyz = r2.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps 4915ee326d1745ff: 2 retail keyword combination(s)
void ps_4915ee326d1745ff_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v7.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  o0.xyz = r1.xyz * r0.www + r0.xyz;
  o0.w = 1;
  return;
}


// ps a28d7abef68387d2: 2 retail keyword combination(s)
void ps_a28d7abef68387d2_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r0.w = dot(v5.xyz, v5.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = v5.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r3.w = 1 + -_Glossiness;
  r4.x = dot(r3.xyz, r2.xyz);
  r4.x = r4.x + r4.x;
  r4.xyz = r2.xyz * -r4.xxx + r3.xyz;
  r4.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r4.w != 0) {
    r4.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r5.xyz;
    r5.xyz = r4.www ? r5.xyz : v7.xyz;
    r5.xyz = -unity_ProbeVolumeMin.xyz + r5.xyz;
    r5.yzw = unity_ProbeVolumeSizeInv.xyz * r5.xyz;
    r4.w = 0.25 * r5.y;
    r5.y = 0.5 * unity_ProbeVolumeParams.z;
    r6.x = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r4.w = max(r5.y, r4.w);
    r5.x = min(r4.w, r6.x);
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xzw).xyzw;
    r7.xyz = float3(0.25,0,0) + r5.xzw;
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r7.xyz).xyzw;
    r5.xyz = float3(0.5,0,0) + r5.xzw;
    r5.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xyz).xyzw;
    r2.w = 1;
    r6.x = dot(r6.xyzw, r2.xyzw);
    r6.y = dot(r7.xyzw, r2.xyzw);
    r6.z = dot(r5.xyzw, r2.xyzw);
  } else {
    r2.w = 1;
    r6.x = dot(unity_SHAr.xyzw, r2.xyzw);
    r6.y = dot(unity_SHAg.xyzw, r2.xyzw);
    r6.z = dot(unity_SHAb.xyzw, r2.xyzw);
  }
  r5.xyz = v6.xyz + r6.xyz;
  r5.xyz = max(float3(0,0,0), r5.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r4.xyz, r4.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r4.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r4.xyz;
  }
  r2.w = -r3.w * 0.699999988 + 1.70000005;
  r2.w = r3.w * r2.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r4.w = -1 + r6.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r7.xyz = r4.www * r6.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r8.xyz = r5.www * r4.xyz;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r5.w = min(r9.x, r9.y);
      r5.w = min(r5.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r4.xyz = r8.xyz * r5.www + r9.xyz;
    }
    r8.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r2.w).xyzw;
    r2.w = -1 + r8.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r4.xyz = r2.www * r8.xyz;
    r6.xyz = r4.www * r6.xyz + -r4.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r4.xyz;
  }
  r4.xyz = r7.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r2.www * r1.xyz;
  r6.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r6.xyz, r6.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r6.xyz = r6.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r6.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r3.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r4.w = r3.z * r3.z;
  r4.w = r4.w * r4.w;
  r3.z = r4.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r3.y = r3.w * r3.w;
  r3.y = max(0.00200000009, r3.y);
  r3.w = 1 + -r3.y;
  r4.w = abs(r0.w) * r3.w + r3.y;
  r3.w = r3.x * r3.w + r3.y;
  r0.w = r3.w * abs(r0.w);
  r0.w = r3.x * r4.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.w = r3.y * r3.y;
  r4.w = r2.x * r3.w + -r2.x;
  r2.x = r4.w * r2.x + 1;
  r3.w = 0.318309873 * r3.w;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.w / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r3.y * r3.y + 1;
  r2.x = 1 / r2.x;
  r3.x = dot(r0.xyz, r0.xyz);
  r3.x = cmp(r3.x != 0.000000);
  r3.x = r3.x ? 1.000000 : 0;
  r0.w = r3.x * r0.w;
  r2.w = _Glossiness + -r2.w;
  r2.w = saturate(1 + r2.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r3.xyw = r5.xyz * r1.www + r3.xyw;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r1.w = r0.w * r0.w;
  r1.w = r1.w * r1.w;
  r0.w = r1.w * r0.w;
  r6.xyz = float3(1,1,1) + -r0.xyz;
  r6.xyz = r6.xyz * r0.www + r0.xyz;
  r5.xyz = r6.xyz * r5.xyz;
  r1.xyz = r1.xyz * r3.xyw + r5.xyz;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r2.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  o0.xyz = r2.xyz * r0.xyz + r1.xyz;
  o0.w = 1;
  return;
}


// ps 294fe643c3f1585b: 2 retail keyword combination(s)
void ps_294fe643c3f1585b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r2.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r2.xy = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r2.yzw = v4.xyz * r2.yyy;
  r2.xyz = v3.xyz * r2.xxx + r2.yzw;
  r2.xyz = v5.xyz * r0.www + r2.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r2.w = 1 + -_Glossiness;
  r3.w = dot(r3.xyz, r2.xyz);
  r3.w = r3.w + r3.w;
  r4.xyz = r2.xyz * -r3.www + r3.xyz;
  r3.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r3.w != 0) {
    r3.w = dot(r4.xyz, r4.xyz);
    r3.w = rsqrt(r3.w);
    r5.xyz = r4.xyz * r3.www;
    r6.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r6.xyz = r6.xyz / r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r7.xyz = r7.xyz / r5.xyz;
    r8.xyz = cmp(float3(0,0,0) < r5.xyz);
    r6.xyz = r8.xyz ? r6.xyz : r7.xyz;
    r3.w = min(r6.x, r6.y);
    r3.w = min(r3.w, r6.z);
    r6.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r5.xyz = r5.xyz * r3.www + r6.xyz;
  } else {
    r5.xyz = r4.xyz;
  }
  r3.w = -r2.w * 0.699999988 + 1.70000005;
  r3.w = r3.w * r2.w;
  r3.w = 6 * r3.w;
  r5.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r5.xyz, r3.w).xyzw;
  r4.w = -1 + r5.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r6.xyz = r4.www * r5.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r7.xyz = r5.www * r4.xyz;
      r8.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r8.xyz = r8.xyz / r7.xyz;
      r9.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r9.xyz = r9.xyz / r7.xyz;
      r10.xyz = cmp(float3(0,0,0) < r7.xyz);
      r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
      r5.w = min(r8.x, r8.y);
      r5.w = min(r5.w, r8.z);
      r8.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r4.xyz = r7.xyz * r5.www + r8.xyz;
    }
    r7.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
    r3.w = -1 + r7.w;
    r3.w = unity_SpecCube1_HDR.w * r3.w + 1;
    r3.w = log2(r3.w);
    r3.w = unity_SpecCube1_HDR.y * r3.w;
    r3.w = exp2(r3.w);
    r3.w = unity_SpecCube1_HDR.x * r3.w;
    r4.xyz = r3.www * r7.xyz;
    r5.xyz = r4.www * r5.xyz + -r4.xyz;
    r6.xyz = unity_SpecCube0_BoxMin.www * r5.xyz + r4.xyz;
  }
  r4.xyz = r6.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r1.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r1.xyz * r1.www;
  r5.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r5.xyz, r5.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r5.xyz = r5.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r5.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r5.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r2.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r2.w = r2.w * r2.w;
  r2.w = max(0.00200000009, r2.w);
  r3.y = 1 + -r2.w;
  r3.w = abs(r0.w) * r3.y + r2.w;
  r3.y = r3.x * r3.y + r2.w;
  r0.w = r3.y * abs(r0.w);
  r0.w = r3.x * r3.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.y = r2.w * r2.w;
  r3.w = r2.x * r3.y + -r2.x;
  r2.x = r3.w * r2.x + 1;
  r3.y = 0.318309873 * r3.y;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.y / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r2.w * r2.w + 1;
  r2.x = 1 / r2.x;
  r2.w = dot(r0.xyz, r0.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.w = r2.w * r0.w;
  r1.w = _Glossiness + -r1.w;
  r1.w = saturate(1 + r1.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r2.y = r0.w * r0.w;
  r2.y = r2.y * r2.y;
  r0.w = r2.y * r0.w;
  r2.yzw = float3(1,1,1) + -r0.xyz;
  r2.yzw = r2.yzw * r0.www + r0.xyz;
  r2.yzw = r5.xyz * r2.yzw;
  r1.xyz = r1.xyz * r3.xyw + r2.yzw;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r1.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  o0.xyz = r2.xyz * r0.xyz + r1.xyz;
  o0.w = 1;
  return;
}


// ps 67c6429c1e53864f: 2 retail keyword combination(s)
void ps_67c6429c1e53864f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  o0.xyz = r0.yzw * r1.xyz + r2.xyz;
  o0.w = 1;
  return;
}


// ps e62edbd3bddbee75: 2 retail keyword combination(s)
void ps_e62edbd3bddbee75_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  o0.xyz = r1.xyz * r0.www + r0.xyz;
  o0.w = 1;
  return;
}


// ps fbfdde3acf4f1a12: 2 retail keyword combination(s)
void ps_fbfdde3acf4f1a12_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  o0.xyz = r0.yzw * r1.xyz + r2.xyz;
  o0.w = 1;
  return;
}


// ps 394f67da08dac43f: 2 retail keyword combination(s)
void ps_394f67da08dac43f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v7.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v7.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v7.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v7.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v7.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v7.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = 1 + -r0.x;
  r0.x = saturate(r0.w + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  o0.xyz = r1.xyz * r0.www + r0.xyz;
  o0.w = 1;
  return;
}


// ps febdecc2a8c49a1d: 1 retail keyword combination(s)
void ps_febdecc2a8c49a1d_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r0.w = dot(v5.xyz, v5.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = v5.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r2.w = 1 + -_Glossiness;
  r3.w = dot(r3.xyz, r2.xyz);
  r3.w = r3.w + r3.w;
  r4.xyz = r2.xyz * -r3.www + r3.xyz;
  r3.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r3.w != 0) {
    r3.w = dot(r4.xyz, r4.xyz);
    r3.w = rsqrt(r3.w);
    r5.xyz = r4.xyz * r3.www;
    r6.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r6.xyz = r6.xyz / r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r5.xyz;
    r8.xyz = cmp(float3(0,0,0) < r5.xyz);
    r6.xyz = r8.xyz ? r6.xyz : r7.xyz;
    r3.w = min(r6.x, r6.y);
    r3.w = min(r3.w, r6.z);
    r6.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r5.xyz = r5.xyz * r3.www + r6.xyz;
  } else {
    r5.xyz = r4.xyz;
  }
  r3.w = -r2.w * 0.699999988 + 1.70000005;
  r3.w = r3.w * r2.w;
  r3.w = 6 * r3.w;
  r5.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r5.xyz, r3.w).xyzw;
  r4.w = -1 + r5.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r6.xyz = r4.www * r5.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r7.xyz = r5.www * r4.xyz;
      r8.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r8.xyz = r8.xyz / r7.xyz;
      r9.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r7.xyz;
      r10.xyz = cmp(float3(0,0,0) < r7.xyz);
      r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
      r5.w = min(r8.x, r8.y);
      r5.w = min(r5.w, r8.z);
      r8.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r4.xyz = r7.xyz * r5.www + r8.xyz;
    }
    r7.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
    r3.w = -1 + r7.w;
    r3.w = unity_SpecCube1_HDR.w * r3.w + 1;
    r3.w = log2(r3.w);
    r3.w = unity_SpecCube1_HDR.y * r3.w;
    r3.w = exp2(r3.w);
    r3.w = unity_SpecCube1_HDR.x * r3.w;
    r4.xyz = r3.www * r7.xyz;
    r5.xyz = r4.www * r5.xyz + -r4.xyz;
    r6.xyz = unity_SpecCube0_BoxMin.www * r5.xyz + r4.xyz;
  }
  r4.xyz = r6.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r1.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r1.xyz * r1.www;
  r5.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r5.xyz, r5.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r5.xyz = r5.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r5.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r5.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r2.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r2.w = r2.w * r2.w;
  r2.w = max(0.00200000009, r2.w);
  r3.y = 1 + -r2.w;
  r3.w = abs(r0.w) * r3.y + r2.w;
  r3.y = r3.x * r3.y + r2.w;
  r0.w = r3.y * abs(r0.w);
  r0.w = r3.x * r3.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.y = r2.w * r2.w;
  r3.w = r2.x * r3.y + -r2.x;
  r2.x = r3.w * r2.x + 1;
  r3.y = 0.318309873 * r3.y;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.y / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r2.w * r2.w + 1;
  r2.x = 1 / r2.x;
  r2.w = dot(r0.xyz, r0.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.w = r2.w * r0.w;
  r1.w = _Glossiness + -r1.w;
  r1.w = saturate(1 + r1.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r2.y = r0.w * r0.w;
  r2.y = r2.y * r2.y;
  r0.w = r2.y * r0.w;
  r2.yzw = float3(1,1,1) + -r0.xyz;
  r2.yzw = r2.yzw * r0.www + r0.xyz;
  r2.yzw = r5.xyz * r2.yzw;
  r1.xyz = r1.xyz * r3.xyw + r2.yzw;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r1.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  r0.xyz = r2.xyz * r0.xyz + r1.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps c010e7dbfc270341: 1 retail keyword combination(s)
void ps_c010e7dbfc270341_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r2.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r2.xy = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r2.yzw = v4.xyz * r2.yyy;
  r2.xyz = v3.xyz * r2.xxx + r2.yzw;
  r2.xyz = v5.xyz * r0.www + r2.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r3.w = 1 + -_Glossiness;
  r4.x = dot(r3.xyz, r2.xyz);
  r4.x = r4.x + r4.x;
  r4.xyz = r2.xyz * -r4.xxx + r3.xyz;
  r4.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r4.w != 0) {
    r4.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r5.xyz;
    r5.xyz = r4.www ? r5.xyz : v8.xyz;
    r5.xyz = -unity_ProbeVolumeMin.xyz + r5.xyz;
    r5.yzw = unity_ProbeVolumeSizeInv.xyz * r5.xyz;
    r4.w = 0.25 * r5.y;
    r5.y = 0.5 * unity_ProbeVolumeParams.z;
    r6.x = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r4.w = max(r5.y, r4.w);
    r5.x = min(r4.w, r6.x);
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xzw).xyzw;
    r7.xyz = float3(0.25,0,0) + r5.xzw;
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r7.xyz).xyzw;
    r5.xyz = float3(0.5,0,0) + r5.xzw;
    r5.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xyz).xyzw;
    r2.w = 1;
    r6.x = dot(r6.xyzw, r2.xyzw);
    r6.y = dot(r7.xyzw, r2.xyzw);
    r6.z = dot(r5.xyzw, r2.xyzw);
  } else {
    r2.w = 1;
    r6.x = dot(unity_SHAr.xyzw, r2.xyzw);
    r6.y = dot(unity_SHAg.xyzw, r2.xyzw);
    r6.z = dot(unity_SHAb.xyzw, r2.xyzw);
  }
  r5.xyz = v6.xyz + r6.xyz;
  r5.xyz = max(float3(0,0,0), r5.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r4.xyz, r4.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r4.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r4.xyz;
  }
  r2.w = -r3.w * 0.699999988 + 1.70000005;
  r2.w = r3.w * r2.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r4.w = -1 + r6.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r7.xyz = r4.www * r6.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r8.xyz = r5.www * r4.xyz;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r5.w = min(r9.x, r9.y);
      r5.w = min(r5.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r4.xyz = r8.xyz * r5.www + r9.xyz;
    }
    r8.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r2.w).xyzw;
    r2.w = -1 + r8.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r4.xyz = r2.www * r8.xyz;
    r6.xyz = r4.www * r6.xyz + -r4.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r4.xyz;
  }
  r4.xyz = r7.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r2.www * r1.xyz;
  r6.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r6.xyz, r6.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r6.xyz = r6.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r6.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r3.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r4.w = r3.z * r3.z;
  r4.w = r4.w * r4.w;
  r3.z = r4.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r3.y = r3.w * r3.w;
  r3.y = max(0.00200000009, r3.y);
  r3.w = 1 + -r3.y;
  r4.w = abs(r0.w) * r3.w + r3.y;
  r3.w = r3.x * r3.w + r3.y;
  r0.w = r3.w * abs(r0.w);
  r0.w = r3.x * r4.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.w = r3.y * r3.y;
  r4.w = r2.x * r3.w + -r2.x;
  r2.x = r4.w * r2.x + 1;
  r3.w = 0.318309873 * r3.w;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.w / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r3.y * r3.y + 1;
  r2.x = 1 / r2.x;
  r3.x = dot(r0.xyz, r0.xyz);
  r3.x = cmp(r3.x != 0.000000);
  r3.x = r3.x ? 1.000000 : 0;
  r0.w = r3.x * r0.w;
  r2.w = _Glossiness + -r2.w;
  r2.w = saturate(1 + r2.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r3.xyw = r5.xyz * r1.www + r3.xyw;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r1.w = r0.w * r0.w;
  r1.w = r1.w * r1.w;
  r0.w = r1.w * r0.w;
  r6.xyz = float3(1,1,1) + -r0.xyz;
  r6.xyz = r6.xyz * r0.www + r0.xyz;
  r5.xyz = r6.xyz * r5.xyz;
  r1.xyz = r1.xyz * r3.xyw + r5.xyz;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r2.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  r0.xyz = r2.xyz * r0.xyz + r1.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 8ed50a1430f55a97: 1 retail keyword combination(s)
void ps_8ed50a1430f55a97_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v8.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps e2d034de71fcc12b: 1 retail keyword combination(s)
void ps_e2d034de71fcc12b_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v8.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = 1 + -r0.x;
  r0.x = saturate(r0.w + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps bd5c676263e5abd0: 1 retail keyword combination(s)
void ps_bd5c676263e5abd0_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v8.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 5256eb957ad3b799: 1 retail keyword combination(s)
void ps_5256eb957ad3b799_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v8.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = 1 + -r0.x;
  r0.x = saturate(r0.w + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps fa956d7d496a5514: 1 retail keyword combination(s)
void ps_fa956d7d496a5514_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r0.w = dot(v5.xyz, v5.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = v5.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r3.w = 1 + -_Glossiness;
  r4.x = dot(r3.xyz, r2.xyz);
  r4.x = r4.x + r4.x;
  r4.xyz = r2.xyz * -r4.xxx + r3.xyz;
  r4.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r4.w != 0) {
    r4.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r5.xyz;
    r5.xyz = r4.www ? r5.xyz : v8.xyz;
    r5.xyz = -unity_ProbeVolumeMin.xyz + r5.xyz;
    r5.yzw = unity_ProbeVolumeSizeInv.xyz * r5.xyz;
    r4.w = 0.25 * r5.y;
    r5.y = 0.5 * unity_ProbeVolumeParams.z;
    r6.x = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r4.w = max(r5.y, r4.w);
    r5.x = min(r4.w, r6.x);
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xzw).xyzw;
    r7.xyz = float3(0.25,0,0) + r5.xzw;
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r7.xyz).xyzw;
    r5.xyz = float3(0.5,0,0) + r5.xzw;
    r5.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xyz).xyzw;
    r2.w = 1;
    r6.x = dot(r6.xyzw, r2.xyzw);
    r6.y = dot(r7.xyzw, r2.xyzw);
    r6.z = dot(r5.xyzw, r2.xyzw);
  } else {
    r2.w = 1;
    r6.x = dot(unity_SHAr.xyzw, r2.xyzw);
    r6.y = dot(unity_SHAg.xyzw, r2.xyzw);
    r6.z = dot(unity_SHAb.xyzw, r2.xyzw);
  }
  r5.xyz = v6.xyz + r6.xyz;
  r5.xyz = max(float3(0,0,0), r5.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r4.xyz, r4.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r4.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r4.xyz;
  }
  r2.w = -r3.w * 0.699999988 + 1.70000005;
  r2.w = r3.w * r2.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r4.w = -1 + r6.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r7.xyz = r4.www * r6.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r8.xyz = r5.www * r4.xyz;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r5.w = min(r9.x, r9.y);
      r5.w = min(r5.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r4.xyz = r8.xyz * r5.www + r9.xyz;
    }
    r8.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r2.w).xyzw;
    r2.w = -1 + r8.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r4.xyz = r2.www * r8.xyz;
    r6.xyz = r4.www * r6.xyz + -r4.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r4.xyz;
  }
  r4.xyz = r7.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r2.www * r1.xyz;
  r6.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r6.xyz, r6.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r6.xyz = r6.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r6.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r3.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r4.w = r3.z * r3.z;
  r4.w = r4.w * r4.w;
  r3.z = r4.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r3.y = r3.w * r3.w;
  r3.y = max(0.00200000009, r3.y);
  r3.w = 1 + -r3.y;
  r4.w = abs(r0.w) * r3.w + r3.y;
  r3.w = r3.x * r3.w + r3.y;
  r0.w = r3.w * abs(r0.w);
  r0.w = r3.x * r4.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.w = r3.y * r3.y;
  r4.w = r2.x * r3.w + -r2.x;
  r2.x = r4.w * r2.x + 1;
  r3.w = 0.318309873 * r3.w;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.w / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r3.y * r3.y + 1;
  r2.x = 1 / r2.x;
  r3.x = dot(r0.xyz, r0.xyz);
  r3.x = cmp(r3.x != 0.000000);
  r3.x = r3.x ? 1.000000 : 0;
  r0.w = r3.x * r0.w;
  r2.w = _Glossiness + -r2.w;
  r2.w = saturate(1 + r2.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r3.xyw = r5.xyz * r1.www + r3.xyw;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r1.w = r0.w * r0.w;
  r1.w = r1.w * r1.w;
  r0.w = r1.w * r0.w;
  r6.xyz = float3(1,1,1) + -r0.xyz;
  r6.xyz = r6.xyz * r0.www + r0.xyz;
  r5.xyz = r6.xyz * r5.xyz;
  r1.xyz = r1.xyz * r3.xyw + r5.xyz;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r2.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  r0.xyz = r2.xyz * r0.xyz + r1.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps fb12db7039bc7c7f: 1 retail keyword combination(s)
void ps_fb12db7039bc7c7f_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r2.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r2.xy = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r2.yzw = v4.xyz * r2.yyy;
  r2.xyz = v3.xyz * r2.xxx + r2.yzw;
  r2.xyz = v5.xyz * r0.www + r2.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r2.w = 1 + -_Glossiness;
  r3.w = dot(r3.xyz, r2.xyz);
  r3.w = r3.w + r3.w;
  r4.xyz = r2.xyz * -r3.www + r3.xyz;
  r3.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r3.w != 0) {
    r3.w = dot(r4.xyz, r4.xyz);
    r3.w = rsqrt(r3.w);
    r5.xyz = r4.xyz * r3.www;
    r6.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r6.xyz = r6.xyz / r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r5.xyz;
    r8.xyz = cmp(float3(0,0,0) < r5.xyz);
    r6.xyz = r8.xyz ? r6.xyz : r7.xyz;
    r3.w = min(r6.x, r6.y);
    r3.w = min(r3.w, r6.z);
    r6.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r5.xyz = r5.xyz * r3.www + r6.xyz;
  } else {
    r5.xyz = r4.xyz;
  }
  r3.w = -r2.w * 0.699999988 + 1.70000005;
  r3.w = r3.w * r2.w;
  r3.w = 6 * r3.w;
  r5.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r5.xyz, r3.w).xyzw;
  r4.w = -1 + r5.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r6.xyz = r4.www * r5.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r7.xyz = r5.www * r4.xyz;
      r8.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r8.xyz = r8.xyz / r7.xyz;
      r9.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r7.xyz;
      r10.xyz = cmp(float3(0,0,0) < r7.xyz);
      r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
      r5.w = min(r8.x, r8.y);
      r5.w = min(r5.w, r8.z);
      r8.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r4.xyz = r7.xyz * r5.www + r8.xyz;
    }
    r7.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
    r3.w = -1 + r7.w;
    r3.w = unity_SpecCube1_HDR.w * r3.w + 1;
    r3.w = log2(r3.w);
    r3.w = unity_SpecCube1_HDR.y * r3.w;
    r3.w = exp2(r3.w);
    r3.w = unity_SpecCube1_HDR.x * r3.w;
    r4.xyz = r3.www * r7.xyz;
    r5.xyz = r4.www * r5.xyz + -r4.xyz;
    r6.xyz = unity_SpecCube0_BoxMin.www * r5.xyz + r4.xyz;
  }
  r4.xyz = r6.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r1.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r1.xyz * r1.www;
  r5.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r5.xyz, r5.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r5.xyz = r5.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r5.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r5.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r2.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r2.w = r2.w * r2.w;
  r2.w = max(0.00200000009, r2.w);
  r3.y = 1 + -r2.w;
  r3.w = abs(r0.w) * r3.y + r2.w;
  r3.y = r3.x * r3.y + r2.w;
  r0.w = r3.y * abs(r0.w);
  r0.w = r3.x * r3.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.y = r2.w * r2.w;
  r3.w = r2.x * r3.y + -r2.x;
  r2.x = r3.w * r2.x + 1;
  r3.y = 0.318309873 * r3.y;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.y / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r2.w * r2.w + 1;
  r2.x = 1 / r2.x;
  r2.w = dot(r0.xyz, r0.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.w = r2.w * r0.w;
  r1.w = _Glossiness + -r1.w;
  r1.w = saturate(1 + r1.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r2.y = r0.w * r0.w;
  r2.y = r2.y * r2.y;
  r0.w = r2.y * r0.w;
  r2.yzw = float3(1,1,1) + -r0.xyz;
  r2.yzw = r2.yzw * r0.www + r0.xyz;
  r2.yzw = r5.xyz * r2.yzw;
  r1.xyz = r1.xyz * r3.xyw + r2.yzw;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r1.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  r0.xyz = r2.xyz * r0.xyz + r1.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 093827d26be22911: 1 retail keyword combination(s)
void ps_093827d26be22911_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 7b4597216f6633f6: 1 retail keyword combination(s)
void ps_7b4597216f6633f6_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 8a334493ca7a1dc8: 1 retail keyword combination(s)
void ps_8a334493ca7a1dc8_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 77a71ec498d930dc: 1 retail keyword combination(s)
void ps_77a71ec498d930dc_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = 1 + -r0.x;
  r0.x = saturate(r0.w + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps f746b71ae7ebda9a: 1 retail keyword combination(s)
void ps_f746b71ae7ebda9a_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r0.w = dot(v5.xyz, v5.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = v5.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r2.w = 1 + -_Glossiness;
  r3.w = dot(r3.xyz, r2.xyz);
  r3.w = r3.w + r3.w;
  r4.xyz = r2.xyz * -r3.www + r3.xyz;
  r3.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r3.w != 0) {
    r3.w = dot(r4.xyz, r4.xyz);
    r3.w = rsqrt(r3.w);
    r5.xyz = r4.xyz * r3.www;
    r6.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r6.xyz = r6.xyz / r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r5.xyz;
    r8.xyz = cmp(float3(0,0,0) < r5.xyz);
    r6.xyz = r8.xyz ? r6.xyz : r7.xyz;
    r3.w = min(r6.x, r6.y);
    r3.w = min(r3.w, r6.z);
    r6.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r5.xyz = r5.xyz * r3.www + r6.xyz;
  } else {
    r5.xyz = r4.xyz;
  }
  r3.w = -r2.w * 0.699999988 + 1.70000005;
  r3.w = r3.w * r2.w;
  r3.w = 6 * r3.w;
  r5.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r5.xyz, r3.w).xyzw;
  r4.w = -1 + r5.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r6.xyz = r4.www * r5.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r7.xyz = r5.www * r4.xyz;
      r8.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r8.xyz = r8.xyz / r7.xyz;
      r9.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r7.xyz;
      r10.xyz = cmp(float3(0,0,0) < r7.xyz);
      r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
      r5.w = min(r8.x, r8.y);
      r5.w = min(r5.w, r8.z);
      r8.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r4.xyz = r7.xyz * r5.www + r8.xyz;
    }
    r7.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
    r3.w = -1 + r7.w;
    r3.w = unity_SpecCube1_HDR.w * r3.w + 1;
    r3.w = log2(r3.w);
    r3.w = unity_SpecCube1_HDR.y * r3.w;
    r3.w = exp2(r3.w);
    r3.w = unity_SpecCube1_HDR.x * r3.w;
    r4.xyz = r3.www * r7.xyz;
    r5.xyz = r4.www * r5.xyz + -r4.xyz;
    r6.xyz = unity_SpecCube0_BoxMin.www * r5.xyz + r4.xyz;
  }
  r4.xyz = r6.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r1.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r1.xyz * r1.www;
  r5.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r5.xyz, r5.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r5.xyz = r5.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r5.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r5.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r2.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r2.w = r2.w * r2.w;
  r2.w = max(0.00200000009, r2.w);
  r3.y = 1 + -r2.w;
  r3.w = abs(r0.w) * r3.y + r2.w;
  r3.y = r3.x * r3.y + r2.w;
  r0.w = r3.y * abs(r0.w);
  r0.w = r3.x * r3.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.y = r2.w * r2.w;
  r3.w = r2.x * r3.y + -r2.x;
  r2.x = r3.w * r2.x + 1;
  r3.y = 0.318309873 * r3.y;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.y / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r2.w * r2.w + 1;
  r2.x = 1 / r2.x;
  r2.w = dot(r0.xyz, r0.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.w = r2.w * r0.w;
  r1.w = _Glossiness + -r1.w;
  r1.w = saturate(1 + r1.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r2.y = r0.w * r0.w;
  r2.y = r2.y * r2.y;
  r0.w = r2.y * r0.w;
  r2.yzw = float3(1,1,1) + -r0.xyz;
  r2.yzw = r2.yzw * r0.www + r0.xyz;
  r2.yzw = r5.xyz * r2.yzw;
  r1.xyz = r1.xyz * r3.xyw + r2.yzw;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r1.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  r0.xyz = r2.xyz * r0.xyz + r1.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 2d06d46df77cb003: 1 retail keyword combination(s)
void ps_2d06d46df77cb003_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r2.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r2.xy = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r2.yzw = v4.xyz * r2.yyy;
  r2.xyz = v3.xyz * r2.xxx + r2.yzw;
  r2.xyz = v5.xyz * r0.www + r2.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r3.w = 1 + -_Glossiness;
  r4.x = dot(r3.xyz, r2.xyz);
  r4.x = r4.x + r4.x;
  r4.xyz = r2.xyz * -r4.xxx + r3.xyz;
  r4.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r4.w != 0) {
    r4.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r5.xyz;
    r5.xyz = r4.www ? r5.xyz : v8.xyz;
    r5.xyz = -unity_ProbeVolumeMin.xyz + r5.xyz;
    r5.yzw = unity_ProbeVolumeSizeInv.xyz * r5.xyz;
    r4.w = 0.25 * r5.y;
    r5.y = 0.5 * unity_ProbeVolumeParams.z;
    r6.x = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r4.w = max(r5.y, r4.w);
    r5.x = min(r4.w, r6.x);
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xzw).xyzw;
    r7.xyz = float3(0.25,0,0) + r5.xzw;
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r7.xyz).xyzw;
    r5.xyz = float3(0.5,0,0) + r5.xzw;
    r5.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xyz).xyzw;
    r2.w = 1;
    r6.x = dot(r6.xyzw, r2.xyzw);
    r6.y = dot(r7.xyzw, r2.xyzw);
    r6.z = dot(r5.xyzw, r2.xyzw);
  } else {
    r2.w = 1;
    r6.x = dot(unity_SHAr.xyzw, r2.xyzw);
    r6.y = dot(unity_SHAg.xyzw, r2.xyzw);
    r6.z = dot(unity_SHAb.xyzw, r2.xyzw);
  }
  r5.xyz = v6.xyz + r6.xyz;
  r5.xyz = max(float3(0,0,0), r5.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r4.xyz, r4.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r4.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r4.xyz;
  }
  r2.w = -r3.w * 0.699999988 + 1.70000005;
  r2.w = r3.w * r2.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r4.w = -1 + r6.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r7.xyz = r4.www * r6.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r8.xyz = r5.www * r4.xyz;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r5.w = min(r9.x, r9.y);
      r5.w = min(r5.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r4.xyz = r8.xyz * r5.www + r9.xyz;
    }
    r8.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r2.w).xyzw;
    r2.w = -1 + r8.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r4.xyz = r2.www * r8.xyz;
    r6.xyz = r4.www * r6.xyz + -r4.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r4.xyz;
  }
  r4.xyz = r7.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r2.www * r1.xyz;
  r6.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r6.xyz, r6.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r6.xyz = r6.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r6.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r3.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r4.w = r3.z * r3.z;
  r4.w = r4.w * r4.w;
  r3.z = r4.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r3.y = r3.w * r3.w;
  r3.y = max(0.00200000009, r3.y);
  r3.w = 1 + -r3.y;
  r4.w = abs(r0.w) * r3.w + r3.y;
  r3.w = r3.x * r3.w + r3.y;
  r0.w = r3.w * abs(r0.w);
  r0.w = r3.x * r4.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.w = r3.y * r3.y;
  r4.w = r2.x * r3.w + -r2.x;
  r2.x = r4.w * r2.x + 1;
  r3.w = 0.318309873 * r3.w;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.w / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r3.y * r3.y + 1;
  r2.x = 1 / r2.x;
  r3.x = dot(r0.xyz, r0.xyz);
  r3.x = cmp(r3.x != 0.000000);
  r3.x = r3.x ? 1.000000 : 0;
  r0.w = r3.x * r0.w;
  r2.w = _Glossiness + -r2.w;
  r2.w = saturate(1 + r2.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r3.xyw = r5.xyz * r1.www + r3.xyw;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r1.w = r0.w * r0.w;
  r1.w = r1.w * r1.w;
  r0.w = r1.w * r0.w;
  r6.xyz = float3(1,1,1) + -r0.xyz;
  r6.xyz = r6.xyz * r0.www + r0.xyz;
  r5.xyz = r6.xyz * r5.xyz;
  r1.xyz = r1.xyz * r3.xyw + r5.xyz;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r2.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  r0.xyz = r2.xyz * r0.xyz + r1.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 2bd88af65296c7cc: 1 retail keyword combination(s)
void ps_2bd88af65296c7cc_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v8.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = 1 + -r0.x;
  r0.x = saturate(r0.w + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps e60d787546b6920d: 1 retail keyword combination(s)
void ps_e60d787546b6920d_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v8.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = 1 + -r0.x;
  r0.x = saturate(r0.w + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 4d113f63d045045d: 1 retail keyword combination(s)
void ps_4d113f63d045045d_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v8.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 3c2a2c184c833056: 1 retail keyword combination(s)
void ps_3c2a2c184c833056_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r2.w != 0) {
    r2.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r6.xyz;
    r6.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r6.xyz;
    r6.xyz = r2.www ? r6.xyz : v8.xyz;
    r6.xyz = -unity_ProbeVolumeMin.xyz + r6.xyz;
    r6.yzw = unity_ProbeVolumeSizeInv.xyz * r6.xyz;
    r2.w = 0.25 * r6.y;
    r4.w = 0.5 * unity_ProbeVolumeParams.z;
    r5.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r2.w = max(r4.w, r2.w);
    r6.x = min(r2.w, r5.w);
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xzw).xyzw;
    r8.xyz = float3(0.25,0,0) + r6.xzw;
    r8.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r8.xyz).xyzw;
    r6.xyz = float3(0.5,0,0) + r6.xzw;
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r6.xyz).xyzw;
    r3.w = 1;
    r7.x = dot(r7.xyzw, r3.xyzw);
    r7.y = dot(r8.xyzw, r3.xyzw);
    r7.z = dot(r6.xyzw, r3.xyzw);
  } else {
    r3.w = 1;
    r7.x = dot(unity_SHAr.xyzw, r3.xyzw);
    r7.y = dot(unity_SHAg.xyzw, r3.xyzw);
    r7.z = dot(unity_SHAb.xyzw, r3.xyzw);
  }
  r6.xyz = v6.xyz + r7.xyz;
  r6.xyz = max(float3(0,0,0), r6.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r5.xyz * r2.www;
    r8.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r7.xyz;
    r9.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r9.xyz = r9.xyz / r7.xyz;
    r10.xyz = cmp(float3(0,0,0) < r7.xyz);
    r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
    r2.w = min(r8.x, r8.y);
    r2.w = min(r2.w, r8.z);
    r8.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r7.xyz = r7.xyz * r2.www + r8.xyz;
  } else {
    r7.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r7.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r7.xyz, r2.w).xyzw;
  r3.w = -1 + r7.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r8.xyz = r3.www * r7.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r9.xyz = r5.xyz * r4.www;
      r10.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r9.xyz;
      r11.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r11.xyz = r11.xyz / r9.xyz;
      r12.xyz = cmp(float3(0,0,0) < r9.xyz);
      r10.xyz = r12.xyz ? r10.xyz : r11.xyz;
      r4.w = min(r10.x, r10.y);
      r4.w = min(r4.w, r10.z);
      r10.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r9.xyz * r4.www + r10.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r7.xyz = r3.www * r7.xyz + -r5.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.www * r7.xyz + r5.xyz;
  }
  r5.xyz = r8.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r7.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r7.xyz, r7.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r7.xyz = r7.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r2.w = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r3.x = saturate(dot(r3.xyz, r7.xyz));
  r3.y = saturate(dot(_WorldSpaceLightPos0.xyz, r7.xyz));
  r3.z = r3.y * r3.y;
  r3.z = dot(r3.zz, r1.ww);
  r3.z = -0.5 + r3.z;
  r3.w = 1 + -r2.w;
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.w = r3.z * r3.w + 1;
  r4.x = 1 + -abs(r0.y);
  r4.y = r4.x * r4.x;
  r4.y = r4.y * r4.y;
  r4.x = r4.y * r4.x;
  r3.z = r3.z * r4.x + 1;
  r3.z = r3.w * r3.z;
  r3.z = r3.z * r2.w;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.w = 1 + -r1.w;
  r4.y = abs(r0.y) * r3.w + r1.w;
  r3.w = r2.w * r3.w + r1.w;
  r0.y = r3.w * abs(r0.y);
  r0.y = r2.w * r4.y + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.w = r1.w * r1.w;
  r4.y = r3.x * r3.w + -r3.x;
  r3.x = r4.y * r3.x + 1;
  r3.w = 0.318309873 * r3.w;
  r3.x = r3.x * r3.x + 1.00000001e-007;
  r3.x = r3.w / r3.x;
  r0.y = r3.x * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r2.w;
  r0.y = max(0, r0.y);
  r1.w = r1.w * r1.w + 1;
  r1.w = 1 / r1.w;
  r2.w = dot(r1.xyz, r1.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.y = r2.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r3.xzw = _LightColor0.xyz * r3.zzz;
  r3.xzw = r6.xyz * r0.zzz + r3.xzw;
  r0.yzw = _LightColor0.xyz * r0.yyy;
  r2.w = 1 + -r3.y;
  r3.y = r2.w * r2.w;
  r3.y = r3.y * r3.y;
  r2.w = r3.y * r2.w;
  r4.yzw = float3(1,1,1) + -r1.xyz;
  r4.yzw = r4.yzw * r2.www + r1.xyz;
  r0.yzw = r4.yzw * r0.yzw;
  r0.yzw = r2.xyz * r3.xzw + r0.yzw;
  r2.xyz = r1.www * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r4.xxx * r3.xyz + r1.xyz;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 99da9915dcb6abd4: 1 retail keyword combination(s)
void ps_99da9915dcb6abd4_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r0.w = dot(v5.xyz, v5.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = v5.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r3.w = 1 + -_Glossiness;
  r4.x = dot(r3.xyz, r2.xyz);
  r4.x = r4.x + r4.x;
  r4.xyz = r2.xyz * -r4.xxx + r3.xyz;
  r4.w = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r4.w != 0) {
    r4.w = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v8.yyy;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v8.xxx + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v8.zzz + r5.xyz;
    r5.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r5.xyz;
    r5.xyz = r4.www ? r5.xyz : v8.xyz;
    r5.xyz = -unity_ProbeVolumeMin.xyz + r5.xyz;
    r5.yzw = unity_ProbeVolumeSizeInv.xyz * r5.xyz;
    r4.w = 0.25 * r5.y;
    r5.y = 0.5 * unity_ProbeVolumeParams.z;
    r6.x = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r4.w = max(r5.y, r4.w);
    r5.x = min(r4.w, r6.x);
    r6.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xzw).xyzw;
    r7.xyz = float3(0.25,0,0) + r5.xzw;
    r7.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r7.xyz).xyzw;
    r5.xyz = float3(0.5,0,0) + r5.xzw;
    r5.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r5.xyz).xyzw;
    r2.w = 1;
    r6.x = dot(r6.xyzw, r2.xyzw);
    r6.y = dot(r7.xyzw, r2.xyzw);
    r6.z = dot(r5.xyzw, r2.xyzw);
  } else {
    r2.w = 1;
    r6.x = dot(unity_SHAr.xyzw, r2.xyzw);
    r6.y = dot(unity_SHAg.xyzw, r2.xyzw);
    r6.z = dot(unity_SHAb.xyzw, r2.xyzw);
  }
  r5.xyz = v6.xyz + r6.xyz;
  r5.xyz = max(float3(0,0,0), r5.xyz);
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r4.xyz, r4.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r4.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r4.xyz;
  }
  r2.w = -r3.w * 0.699999988 + 1.70000005;
  r2.w = r3.w * r2.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r4.w = -1 + r6.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r7.xyz = r4.www * r6.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r8.xyz = r5.www * r4.xyz;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r5.w = min(r9.x, r9.y);
      r5.w = min(r5.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r4.xyz = r8.xyz * r5.www + r9.xyz;
    }
    r8.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r2.w).xyzw;
    r2.w = -1 + r8.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r4.xyz = r2.www * r8.xyz;
    r6.xyz = r4.www * r6.xyz + -r4.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r4.xyz;
  }
  r4.xyz = r7.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r2.www * r1.xyz;
  r6.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r6.xyz, r6.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r6.xyz = r6.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r6.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r3.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r4.w = r3.z * r3.z;
  r4.w = r4.w * r4.w;
  r3.z = r4.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r3.y = r3.w * r3.w;
  r3.y = max(0.00200000009, r3.y);
  r3.w = 1 + -r3.y;
  r4.w = abs(r0.w) * r3.w + r3.y;
  r3.w = r3.x * r3.w + r3.y;
  r0.w = r3.w * abs(r0.w);
  r0.w = r3.x * r4.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.w = r3.y * r3.y;
  r4.w = r2.x * r3.w + -r2.x;
  r2.x = r4.w * r2.x + 1;
  r3.w = 0.318309873 * r3.w;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.w / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r3.y * r3.y + 1;
  r2.x = 1 / r2.x;
  r3.x = dot(r0.xyz, r0.xyz);
  r3.x = cmp(r3.x != 0.000000);
  r3.x = r3.x ? 1.000000 : 0;
  r0.w = r3.x * r0.w;
  r2.w = 1 + -r2.w;
  r2.w = saturate(_Glossiness + r2.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r3.xyw = r5.xyz * r1.www + r3.xyw;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r1.w = r0.w * r0.w;
  r1.w = r1.w * r1.w;
  r0.w = r1.w * r0.w;
  r6.xyz = float3(1,1,1) + -r0.xyz;
  r6.xyz = r6.xyz * r0.www + r0.xyz;
  r5.xyz = r6.xyz * r5.xyz;
  r1.xyz = r1.xyz * r3.xyw + r5.xyz;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r2.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  r0.xyz = r2.xyz * r0.xyz + r1.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps cb3a147d76ec81bc: 1 retail keyword combination(s)
void ps_cb3a147d76ec81bc_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r0.xyz;
  r2.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r2.xy = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r2.yzw = v4.xyz * r2.yyy;
  r2.xyz = v3.xyz * r2.xxx + r2.yzw;
  r2.xyz = v5.xyz * r0.www + r2.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = v2.xyz * r0.www;
  r4.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.w = 1 + -_OcclusionStrength;
  r1.w = r4.y * _OcclusionStrength + r1.w;
  r2.w = 1 + -_Glossiness;
  r3.w = dot(r3.xyz, r2.xyz);
  r3.w = r3.w + r3.w;
  r4.xyz = r2.xyz * -r3.www + r3.xyz;
  r3.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r3.w != 0) {
    r3.w = dot(r4.xyz, r4.xyz);
    r3.w = rsqrt(r3.w);
    r5.xyz = r4.xyz * r3.www;
    r6.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r6.xyz = r6.xyz / r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r5.xyz;
    r8.xyz = cmp(float3(0,0,0) < r5.xyz);
    r6.xyz = r8.xyz ? r6.xyz : r7.xyz;
    r3.w = min(r6.x, r6.y);
    r3.w = min(r3.w, r6.z);
    r6.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r5.xyz = r5.xyz * r3.www + r6.xyz;
  } else {
    r5.xyz = r4.xyz;
  }
  r3.w = -r2.w * 0.699999988 + 1.70000005;
  r3.w = r3.w * r2.w;
  r3.w = 6 * r3.w;
  r5.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r5.xyz, r3.w).xyzw;
  r4.w = -1 + r5.w;
  r4.w = unity_SpecCube0_HDR.w * r4.w + 1;
  r4.w = log2(r4.w);
  r4.w = unity_SpecCube0_HDR.y * r4.w;
  r4.w = exp2(r4.w);
  r4.w = unity_SpecCube0_HDR.x * r4.w;
  r6.xyz = r4.www * r5.xyz;
  r5.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r5.w != 0) {
    r5.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r5.w != 0) {
      r5.w = dot(r4.xyz, r4.xyz);
      r5.w = rsqrt(r5.w);
      r7.xyz = r5.www * r4.xyz;
      r8.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r8.xyz = r8.xyz / r7.xyz;
      r9.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r7.xyz;
      r10.xyz = cmp(float3(0,0,0) < r7.xyz);
      r8.xyz = r10.xyz ? r8.xyz : r9.xyz;
      r5.w = min(r8.x, r8.y);
      r5.w = min(r5.w, r8.z);
      r8.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r4.xyz = r7.xyz * r5.www + r8.xyz;
    }
    r7.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r4.xyz, r3.w).xyzw;
    r3.w = -1 + r7.w;
    r3.w = unity_SpecCube1_HDR.w * r3.w + 1;
    r3.w = log2(r3.w);
    r3.w = unity_SpecCube1_HDR.y * r3.w;
    r3.w = exp2(r3.w);
    r3.w = unity_SpecCube1_HDR.x * r3.w;
    r4.xyz = r3.www * r7.xyz;
    r5.xyz = r4.www * r5.xyz + -r4.xyz;
    r6.xyz = unity_SpecCube0_BoxMin.www * r5.xyz + r4.xyz;
  }
  r4.xyz = r6.xyz * r1.www;
  r0.xyz = _Color.xyz * r0.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r0.xyz = _Metallic.xxx * r0.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r1.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r1.xyz * r1.www;
  r5.xyz = -v2.xyz * r0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r5.xyz, r5.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r5.xyz = r5.xyz * r0.www;
  r0.w = dot(r2.xyz, -r3.xyz);
  r3.x = saturate(dot(r2.xyz, _WorldSpaceLightPos0.xyz));
  r2.x = saturate(dot(r2.xyz, r5.xyz));
  r2.y = saturate(dot(_WorldSpaceLightPos0.xyz, r5.xyz));
  r2.z = r2.y * r2.y;
  r2.z = dot(r2.zz, r2.ww);
  r2.z = -0.5 + r2.z;
  r3.y = 1 + -r3.x;
  r3.z = r3.y * r3.y;
  r3.z = r3.z * r3.z;
  r3.y = r3.z * r3.y;
  r3.y = r2.z * r3.y + 1;
  r3.z = 1 + -abs(r0.w);
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r2.z = r2.z * r3.z + 1;
  r2.z = r3.y * r2.z;
  r2.z = r2.z * r3.x;
  r2.w = r2.w * r2.w;
  r2.w = max(0.00200000009, r2.w);
  r3.y = 1 + -r2.w;
  r3.w = abs(r0.w) * r3.y + r2.w;
  r3.y = r3.x * r3.y + r2.w;
  r0.w = r3.y * abs(r0.w);
  r0.w = r3.x * r3.w + r0.w;
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 0.5 / r0.w;
  r3.y = r2.w * r2.w;
  r3.w = r2.x * r3.y + -r2.x;
  r2.x = r3.w * r2.x + 1;
  r3.y = 0.318309873 * r3.y;
  r2.x = r2.x * r2.x + 1.00000001e-007;
  r2.x = r3.y / r2.x;
  r0.w = r2.x * r0.w;
  r0.w = 3.14159274 * r0.w;
  r0.w = r0.w * r3.x;
  r0.w = max(0, r0.w);
  r2.x = r2.w * r2.w + 1;
  r2.x = 1 / r2.x;
  r2.w = dot(r0.xyz, r0.xyz);
  r2.w = cmp(r2.w != 0.000000);
  r2.w = r2.w ? 1.000000 : 0;
  r0.w = r2.w * r0.w;
  r1.w = 1 + -r1.w;
  r1.w = saturate(_Glossiness + r1.w);
  r3.xyw = _LightColor0.xyz * r2.zzz;
  r5.xyz = _LightColor0.xyz * r0.www;
  r0.w = 1 + -r2.y;
  r2.y = r0.w * r0.w;
  r2.y = r2.y * r2.y;
  r0.w = r2.y * r0.w;
  r2.yzw = float3(1,1,1) + -r0.xyz;
  r2.yzw = r2.yzw * r0.www + r0.xyz;
  r2.yzw = r5.xyz * r2.yzw;
  r1.xyz = r1.xyz * r3.xyw + r2.yzw;
  r2.xyz = r2.xxx * r4.xyz;
  r3.xyw = r1.www + -r0.xyz;
  r0.xyz = r3.zzz * r3.xyw + r0.xyz;
  r0.xyz = r2.xyz * r0.xyz + r1.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 9054f93b82a8d0db: 1 retail keyword combination(s)
void ps_9054f93b82a8d0db_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 71da5e5b31a408f5: 1 retail keyword combination(s)
void ps_71da5e5b31a408f5_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = v5.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = r0.w + -r0.x;
  r0.x = saturate(1 + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 5ea8d9700f94b05b: 1 retail keyword combination(s)
void ps_5ea8d9700f94b05b_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = 1 + -r0.x;
  r0.x = saturate(r0.w + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


// ps 0eb88115c90e1b1f: 1 retail keyword combination(s)
void ps_0eb88115c90e1b1f_impl(
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyz = _Color.xyz * r1.xyz;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r3.x = r3.x * r3.w;
  r0.yz = r3.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.w = dot(r0.yz, r0.yz);
  r1.w = min(1, r1.w);
  r1.w = 1 + -r1.w;
  r1.w = sqrt(r1.w);
  r3.xyz = v4.xyz * r0.zzz;
  r3.xyz = v3.xyz * r0.yyy + r3.xyz;
  r3.xyz = v5.xyz * r1.www + r3.xyz;
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r3.xyz = r3.xyz * r0.yyy;
  r0.y = dot(v2.xyz, v2.xyz);
  r0.y = rsqrt(r0.y);
  r4.xyz = v2.xyz * r0.yyy;
  r5.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.z = 1 + -_OcclusionStrength;
  r0.z = r5.y * _OcclusionStrength + r0.z;
  r1.w = 1 + -r0.w;
  r2.w = dot(r4.xyz, r3.xyz);
  r2.w = r2.w + r2.w;
  r5.xyz = r3.xyz * -r2.www + r4.xyz;
  r2.w = cmp(0 < unity_SpecCube0_ProbePosition.w);
  [branch] if (r2.w != 0) {
    r2.w = dot(r5.xyz, r5.xyz);
    r2.w = rsqrt(r2.w);
    r6.xyz = r5.xyz * r2.www;
    r7.xyz = unity_SpecCube0_BoxMax.xyz + -v8.xyz;
    r7.xyz = r7.xyz / r6.xyz;
    r8.xyz = unity_SpecCube0_BoxMin.xyz + -v8.xyz;
    r8.xyz = r8.xyz / r6.xyz;
    r9.xyz = cmp(float3(0,0,0) < r6.xyz);
    r7.xyz = r9.xyz ? r7.xyz : r8.xyz;
    r2.w = min(r7.x, r7.y);
    r2.w = min(r2.w, r7.z);
    r7.xyz = -unity_SpecCube0_ProbePosition.xyz + v8.xyz;
    r6.xyz = r6.xyz * r2.www + r7.xyz;
  } else {
    r6.xyz = r5.xyz;
  }
  r2.w = -r1.w * 0.699999988 + 1.70000005;
  r2.w = r2.w * r1.w;
  r2.w = 6 * r2.w;
  r6.xyzw = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, r6.xyz, r2.w).xyzw;
  r3.w = -1 + r6.w;
  r3.w = unity_SpecCube0_HDR.w * r3.w + 1;
  r3.w = log2(r3.w);
  r3.w = unity_SpecCube0_HDR.y * r3.w;
  r3.w = exp2(r3.w);
  r3.w = unity_SpecCube0_HDR.x * r3.w;
  r7.xyz = r3.www * r6.xyz;
  r4.w = cmp(unity_SpecCube0_BoxMin.w < 0.999989986);
  [branch] if (r4.w != 0) {
    r4.w = cmp(0 < unity_SpecCube1_ProbePosition.w);
    [branch] if (r4.w != 0) {
      r4.w = dot(r5.xyz, r5.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r5.xyz * r4.www;
      r9.xyz = unity_SpecCube1_BoxMax.xyz + -v8.xyz;
      r9.xyz = r9.xyz / r8.xyz;
      r10.xyz = unity_SpecCube1_BoxMin.xyz + -v8.xyz;
      r10.xyz = r10.xyz / r8.xyz;
      r11.xyz = cmp(float3(0,0,0) < r8.xyz);
      r9.xyz = r11.xyz ? r9.xyz : r10.xyz;
      r4.w = min(r9.x, r9.y);
      r4.w = min(r4.w, r9.z);
      r9.xyz = -unity_SpecCube1_ProbePosition.xyz + v8.xyz;
      r5.xyz = r8.xyz * r4.www + r9.xyz;
    }
    r5.xyzw = unity_SpecCube1.SampleLevel(samplerunity_SpecCube0, r5.xyz, r2.w).xyzw;
    r2.w = -1 + r5.w;
    r2.w = unity_SpecCube1_HDR.w * r2.w + 1;
    r2.w = log2(r2.w);
    r2.w = unity_SpecCube1_HDR.y * r2.w;
    r2.w = exp2(r2.w);
    r2.w = unity_SpecCube1_HDR.x * r2.w;
    r5.xyz = r2.www * r5.xyz;
    r6.xyz = r3.www * r6.xyz + -r5.xyz;
    r7.xyz = unity_SpecCube0_BoxMin.www * r6.xyz + r5.xyz;
  }
  r5.xyz = r7.xyz * r0.zzz;
  r1.xyz = _Color.xyz * r1.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r1.xyz = r0.xxx * r1.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.x = -r0.x * 0.959999979 + 0.959999979;
  r2.xyz = r2.xyz * r0.xxx;
  r6.xyz = -v2.xyz * r0.yyy + _WorldSpaceLightPos0.xyz;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = max(0.00100000005, r0.y);
  r0.y = rsqrt(r0.y);
  r6.xyz = r6.xyz * r0.yyy;
  r0.y = dot(r3.xyz, -r4.xyz);
  r0.z = saturate(dot(r3.xyz, _WorldSpaceLightPos0.xyz));
  r2.w = saturate(dot(r3.xyz, r6.xyz));
  r3.x = saturate(dot(_WorldSpaceLightPos0.xyz, r6.xyz));
  r3.y = r3.x * r3.x;
  r3.y = dot(r3.yy, r1.ww);
  r3.y = -0.5 + r3.y;
  r3.z = 1 + -r0.z;
  r3.w = r3.z * r3.z;
  r3.w = r3.w * r3.w;
  r3.z = r3.w * r3.z;
  r3.z = r3.y * r3.z + 1;
  r3.w = 1 + -abs(r0.y);
  r4.x = r3.w * r3.w;
  r4.x = r4.x * r4.x;
  r3.w = r4.x * r3.w;
  r3.y = r3.y * r3.w + 1;
  r3.y = r3.z * r3.y;
  r3.y = r3.y * r0.z;
  r1.w = r1.w * r1.w;
  r1.w = max(0.00200000009, r1.w);
  r3.z = 1 + -r1.w;
  r4.x = abs(r0.y) * r3.z + r1.w;
  r3.z = r0.z * r3.z + r1.w;
  r0.y = r3.z * abs(r0.y);
  r0.y = r0.z * r4.x + r0.y;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r3.z = r1.w * r1.w;
  r4.x = r2.w * r3.z + -r2.w;
  r2.w = r4.x * r2.w + 1;
  r3.z = 0.318309873 * r3.z;
  r2.w = r2.w * r2.w + 1.00000001e-007;
  r2.w = r3.z / r2.w;
  r0.y = r2.w * r0.y;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.z;
  r0.y = max(0, r0.y);
  r0.z = r1.w * r1.w + 1;
  r0.z = 1 / r0.z;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = cmp(r1.w != 0.000000);
  r1.w = r1.w ? 1.000000 : 0;
  r0.y = r1.w * r0.y;
  r0.x = 1 + -r0.x;
  r0.x = saturate(r0.w + r0.x);
  r4.xyz = _LightColor0.xyz * r3.yyy;
  r6.xyz = _LightColor0.xyz * r0.yyy;
  r0.y = 1 + -r3.x;
  r0.w = r0.y * r0.y;
  r0.w = r0.w * r0.w;
  r0.y = r0.w * r0.y;
  r3.xyz = float3(1,1,1) + -r1.xyz;
  r3.xyz = r3.xyz * r0.yyy + r1.xyz;
  r3.xyz = r6.xyz * r3.xyz;
  r2.xyz = r2.xyz * r4.xyz + r3.xyz;
  r0.yzw = r0.zzz * r5.xyz;
  r3.xyz = r0.xxx + -r1.xyz;
  r1.xyz = r3.www * r3.xyz + r1.xyz;
  r0.xyz = r0.yzw * r1.xyz + r2.xyz;
  r1.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.w = cmp(_BT_NightLights != 1.000000);
  r0.w = r0.w ? r1.x : 0;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.x = r1.y ? r1.x : 1;
  r0.w = r0.w ? 0 : r1.x;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r1.xy = v7.xy / v7.ww;
  r0.w = 8 * v7.z;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v7.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
		vs_5a3a748f6139fc37_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord8 = o7;
		o.texcoord9 = o8;
		o.texcoord10 = o9;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
		vs_8dcf4e10631baab1_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord8 = o7;
		o.texcoord9 = o8;
		o.texcoord10 = o9;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
		vs_a1a88f5059d212ed_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord8 = o7;
		o.texcoord9 = o8;
		o.texcoord10 = o9;
	}
#elif !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
		vs_802e47eca2eba240_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord8 = o7;
		o.texcoord9 = o8;
		o.texcoord10 = o9;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
		vs_f540b2c00c7085d1_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
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
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
		vs_3f9fedfb41a210c6_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
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
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
		vs_cbf60bce4b65a03a_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
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
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
		vs_ab5492553953bfa2_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
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
#if !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_d62c84a79ed13cc9_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_2b73e31a95f5fab5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_a6da6af2cfa68497_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && defined(_EMISSION) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_70ede3492a50b70f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_fc10e403f890fdee_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && defined(_EMISSION) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_4915ee326d1745ff_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_a28d7abef68387d2_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_294fe643c3f1585b_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_67c6429c1e53864f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && defined(_EMISSION) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_e62edbd3bddbee75_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_fbfdde3acf4f1a12_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG) && defined(_EMISSION) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_394f67da08dac43f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_febdecc2a8c49a1d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_c010e7dbfc270341_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_8ed50a1430f55a97_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_EMISSION) && !defined(_FOG_3D) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_e2d034de71fcc12b_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_bd5c676263e5abd0_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_EMISSION) && !defined(_FOG_3D) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_5256eb957ad3b799_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_fa956d7d496a5514_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_fb12db7039bc7c7f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_093827d26be22911_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_EMISSION) && !defined(_FOG_3D) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_7b4597216f6633f6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_8a334493ca7a1dc8_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_EMISSION) && !defined(_FOG_3D) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_77a71ec498d930dc_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_f746b71ae7ebda9a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_2d06d46df77cb003_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_2bd88af65296c7cc_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_EMISSION) && defined(_FOG_3D) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_e60d787546b6920d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_4d113f63d045045d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_EMISSION) && defined(_FOG_3D) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_3c2a2c184c833056_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_99da9915dcb6abd4_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_cb3a147d76ec81bc_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_9054f93b82a8d0db_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_EMISSION) && defined(_FOG_3D) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_71da5e5b31a408f5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_EMISSION) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_5ea8d9700f94b05b_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_EMISSION) && defined(_FOG_3D) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_0eb88115c90e1b1f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
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
			Name "FORWARD_DELTA"
			Tags { "LightMode"="ForwardAdd" }
			Blend One One
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ DIRECTIONAL
			#pragma multi_compile _ DIRECTIONAL_COOKIE
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _BT_SUNLIGHT_CONTROL
			#pragma multi_compile _ _FOG_3D
			#pragma multi_compile _ _METALLICGLOSSMAP
			#pragma multi_compile _ _NORMALMAP

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _TransmittanceLUT;
SamplerState sampler_TransmittanceLUT;
Texture2D _BumpMap;
SamplerState sampler_BumpMap;
Texture2D _MetallicGlossMap;
SamplerState sampler_MetallicGlossMap;
Texture2D _FogIntegrationTex;
SamplerState sampler_FogIntegrationTex;
Texture3D _FogIntegration3D;
SamplerState sampler_FogIntegration3D;

float4 _MainTex_ST;
float4 _DetailAlbedoMap_ST;
float4 _DetailMask_ST;
float _UVSec;
float _UVSecMask;
float4x4 unity_WorldToLight;
float4 _LightColor0;
float4 _Color;
float _Metallic;
float _Glossiness;
float _BumpScale;
float4 _ScaleOffset;
float3 _VolumeSize;
float _BT_SunlightIntensity;
float _BT_CloudCover;
float4 _BT_SunlightColor;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 tangent0 : TANGENT0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};

#if !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
	float4 texcoord11 : TEXCOORD11;
};
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
	float4 texcoord11 : TEXCOORD11;
};
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
	float4 texcoord11 : TEXCOORD11;
};
#elif !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
	float4 texcoord11 : TEXCOORD11;
};
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
	float4 texcoord11 : TEXCOORD11;
};
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
	float4 texcoord11 : TEXCOORD11;
};
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
	float4 texcoord11 : TEXCOORD11;
};
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	float4 texcoord10 : TEXCOORD10;
	float4 texcoord11 : TEXCOORD11;
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

// vs 6a8dbb31ee88778a: 8 retail keyword combination(s)
void vs_6a8dbb31ee88778a_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD8,
  inout float4 o7 : TEXCOORD9,
  inout float4 o8 : TEXCOORD10,
  inout float4 o9 : TEXCOORD11)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r0.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r2.xyzw = r2.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r2.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o7.xy = r2.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r2.xyz = -r0.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  o6.xyzw = r0.xyzw;
  r2.w = 0;
  o3.xyzw = r2.wwwx;
  o4.xyzw = r2.wwwy;
  o5.w = r2.z;
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o5.xyz = r0.xyz * r0.www;
  o7.zw = float2(0,0);
  o8.xyzw = float4(0,0,0,0);
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  o9.xy = r0.xw + r0.zz;
  return;
}


// vs 8e50d5c1e9134f81: 8 retail keyword combination(s)
void vs_8e50d5c1e9134f81_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD8,
  inout float4 o8 : TEXCOORD9,
  inout float4 o9 : TEXCOORD10,
  inout float4 o10 : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r0.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r2.xyzw = r2.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r2.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r2.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r2.xyz;
  r2.w = dot(r2.xyz, r2.xyz);
  r2.w = rsqrt(r2.w);
  r2.xyz = r2.xyz * r2.www;
  o3.xyz = r2.xyz;
  r3.xyz = -r0.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  o3.w = r3.x;
  r4.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r4.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r4.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r2.w = dot(r4.xyz, r4.xyz);
  r2.w = rsqrt(r2.w);
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = r4.zxy * r2.yzx;
  r2.xyz = r4.yzx * r2.zxy + -r5.xyz;
  o5.xyz = r4.xyz;
  r2.w = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r2.xyz * r2.www;
  o4.w = r3.y;
  o5.w = r3.z;
  r2.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r0.yy;
  r2.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r0.xx + r2.xy;
  r2.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r0.zz + r2.xy;
  o6.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) * r0.ww + r2.xy;
  o7.xyzw = r0.xyzw;
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o10.zw = r1.zw;
  o10.xy = r0.xw + r0.zz;
  return;
}


// vs d5a700f00e42a3fb: 8 retail keyword combination(s)
void vs_d5a700f00e42a3fb_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD8,
  inout float4 o8 : TEXCOORD9,
  inout float4 o9 : TEXCOORD10,
  inout float4 o10 : TEXCOORD11)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r0.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r2.xyzw = r2.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r2.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r2.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r2.w = 0;
  r2.xyz = -r0.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  o3.xyzw = r2.wwwx;
  o4.xyzw = r2.wwwy;
  o5.w = r2.z;
  r2.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r2.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r2.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r2.w = dot(r2.xyz, r2.xyz);
  r2.w = rsqrt(r2.w);
  o5.xyz = r2.xyz * r2.www;
  r2.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r0.yy;
  r2.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r0.xx + r2.xy;
  r2.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r0.zz + r2.xy;
  o6.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) * r0.ww + r2.xy;
  o7.xyzw = r0.xyzw;
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o10.zw = r1.zw;
  o10.xy = r0.xw + r0.zz;
  return;
}


// vs 8102b99710c7b01c: 8 retail keyword combination(s)
void vs_8102b99710c7b01c_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD8,
  inout float4 o7 : TEXCOORD9,
  inout float4 o8 : TEXCOORD10,
  inout float4 o9 : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r0.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r2.xyzw = r2.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r2.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o7.xy = r2.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r2.xyz;
  r2.w = dot(r2.xyz, r2.xyz);
  r2.w = rsqrt(r2.w);
  r2.xyz = r2.xyz * r2.www;
  o3.xyz = r2.xyz;
  r3.xyz = -r0.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  o6.xyzw = r0.xyzw;
  o3.w = r3.x;
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r4.xyz = r0.zxy * r2.yzx;
  r2.xyz = r0.yzx * r2.zxy + -r4.xyz;
  o5.xyz = r0.xyz;
  r0.x = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r2.xyz * r0.xxx;
  o4.w = r3.y;
  o5.w = r3.z;
  o7.zw = float2(0,0);
  o8.xyzw = float4(0,0,0,0);
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  o9.xy = r0.xw + r0.zz;
  return;
}


// vs 694b8a47a3d3496d: 8 retail keyword combination(s)
void vs_694b8a47a3d3496d_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD7,
  inout float4 o7 : TEXCOORD8,
  inout float4 o8 : TEXCOORD9,
  inout float4 o9 : TEXCOORD10,
  inout float4 o10 : TEXCOORD11)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r0.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r3.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r3.xyzw = r3.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r3.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r3.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r3.xyz = -r0.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  o7.xyzw = r0.xyzw;
  r3.w = 0;
  o3.xyzw = r3.wwwx;
  o4.xyzw = r3.wwwy;
  o5.w = r3.z;
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o5.xyz = r0.xyz * r0.www;
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o6.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r0.xw + r0.zz;
  o6.xyw = r2.xyw;
  o10.xyzw = r2.xyzw;
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  return;
}


// vs 7e110e989849cffe: 8 retail keyword combination(s)
void vs_7e110e989849cffe_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
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
  inout float4 o10 : TEXCOORD10,
  inout float4 o11 : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r0.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r3.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r3.xyzw = r3.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r3.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o9.xy = r3.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r3.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r3.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r3.xyz;
  r3.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r3.xyz;
  r3.w = dot(r3.xyz, r3.xyz);
  r3.w = rsqrt(r3.w);
  r3.xyz = r3.xyz * r3.www;
  o3.xyz = r3.xyz;
  r4.xyz = -r0.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  o3.w = r4.x;
  r5.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r5.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r5.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r3.w = dot(r5.xyz, r5.xyz);
  r3.w = rsqrt(r3.w);
  r5.xyz = r5.xyz * r3.www;
  r6.xyz = r5.zxy * r3.yzx;
  r3.xyz = r5.yzx * r3.zxy + -r6.xyz;
  o5.xyz = r5.xyz;
  r3.w = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r3.xyz * r3.www;
  o4.w = r4.y;
  o5.w = r4.z;
  r3.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r0.yy;
  r3.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r0.xx + r3.xy;
  r3.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r0.zz + r3.xy;
  o6.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) * r0.ww + r3.xy;
  o8.xyzw = r0.xyzw;
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r0.xw + r0.zz;
  o7.xyw = r2.xyw;
  o11.xyzw = r2.xyzw;
  o9.zw = float2(0,0);
  o10.xyzw = float4(0,0,0,0);
  return;
}


// vs 2229293735e41d20: 8 retail keyword combination(s)
void vs_2229293735e41d20_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
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
  inout float4 o10 : TEXCOORD10,
  inout float4 o11 : TEXCOORD11)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r0.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r3.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r3.xyzw = r3.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r3.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o9.xy = r3.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r3.w = 0;
  r3.xyz = -r0.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  o3.xyzw = r3.wwwx;
  o4.xyzw = r3.wwwy;
  o5.w = r3.z;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r3.w = dot(r3.xyz, r3.xyz);
  r3.w = rsqrt(r3.w);
  o5.xyz = r3.xyz * r3.www;
  r3.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r0.yy;
  r3.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r0.xx + r3.xy;
  r3.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r0.zz + r3.xy;
  o6.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) * r0.ww + r3.xy;
  o8.xyzw = r0.xyzw;
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r0.xw + r0.zz;
  o7.xyw = r2.xyw;
  o11.xyzw = r2.xyzw;
  o9.zw = float2(0,0);
  o10.xyzw = float4(0,0,0,0);
  return;
}


// vs 8216bec70f86a226: 8 retail keyword combination(s)
void vs_8216bec70f86a226_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD7,
  inout float4 o7 : TEXCOORD8,
  inout float4 o8 : TEXCOORD9,
  inout float4 o9 : TEXCOORD10,
  inout float4 o10 : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r0.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r3.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r3.xyzw = r3.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r3.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r3.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r3.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r3.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r3.xyz;
  r3.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r3.xyz;
  r3.w = dot(r3.xyz, r3.xyz);
  r3.w = rsqrt(r3.w);
  r3.xyz = r3.xyz * r3.www;
  o3.xyz = r3.xyz;
  r4.xyz = -r0.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  o7.xyzw = r0.xyzw;
  o3.w = r4.x;
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r5.xyz = r0.zxy * r3.yzx;
  r3.xyz = r0.yzx * r3.zxy + -r5.xyz;
  o5.xyz = r0.xyz;
  r0.x = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r3.xyz * r0.xxx;
  o4.w = r4.y;
  o5.w = r4.z;
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o6.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r0.xw + r0.zz;
  o6.xyw = r2.xyw;
  o10.xyzw = r2.xyzw;
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  return;
}


// ps 99ea005456eb30a1: 2 retail keyword combination(s)
void ps_99ea005456eb30a1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD8,
  float4 v7 : TEXCOORD9,
  float4 v8 : TEXCOORD10,
  float4 v9 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  o0.xyz = r1.xyz * r0.xyz + r3.xyz;
  o0.w = 1;
  return;
}


// ps db034f59756263d2: 2 retail keyword combination(s)
void ps_db034f59756263d2_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  o0.xyz = r2.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps 729cfdc53479e7d5: 2 retail keyword combination(s)
void ps_729cfdc53479e7d5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  o0.xyz = r4.xyz * r0.xyz + r3.xyz;
  o0.w = 1;
  return;
}


// ps 2483f80fbb38bac1: 2 retail keyword combination(s)
void ps_2483f80fbb38bac1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  o0.xyz = r4.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps 3abd6972dbf2c0dd: 2 retail keyword combination(s)
void ps_3abd6972dbf2c0dd_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  o0.xyz = r1.xyz * r0.xyz + r3.xyz;
  o0.w = 1;
  return;
}


// ps 84b88346bc5df258: 2 retail keyword combination(s)
void ps_84b88346bc5df258_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD8,
  float4 v7 : TEXCOORD9,
  float4 v8 : TEXCOORD10,
  float4 v9 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  o0.xyz = r2.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps 69cf76e238e9a3e6: 2 retail keyword combination(s)
void ps_69cf76e238e9a3e6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD8,
  float4 v7 : TEXCOORD9,
  float4 v8 : TEXCOORD10,
  float4 v9 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  o0.xyz = r4.xyz * r0.xyz + r3.xyz;
  o0.w = 1;
  return;
}


// ps 57350c08d6eadd3a: 2 retail keyword combination(s)
void ps_57350c08d6eadd3a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD8,
  float4 v7 : TEXCOORD9,
  float4 v8 : TEXCOORD10,
  float4 v9 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  o0.xyz = r4.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps 212c0c042e07bf3f: 1 retail keyword combination(s)
void ps_212c0c042e07bf3f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  r0.xyz = r1.xyz * r0.xyz + r3.xyz;
  r1.xy = v6.xy / v6.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v6.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v6.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps f1298e74eab015b9: 1 retail keyword combination(s)
void ps_f1298e74eab015b9_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 514122de163d8c7a: 1 retail keyword combination(s)
void ps_514122de163d8c7a_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r0.xyz + r3.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 7fa03e9d841c5e7d: 1 retail keyword combination(s)
void ps_7fa03e9d841c5e7d_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r1.xyz + r0.yzw;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps bb89961abf7338f5: 1 retail keyword combination(s)
void ps_bb89961abf7338f5_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  r0.xyz = r1.xyz * r0.xyz + r3.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps a4aee200cccf3153: 1 retail keyword combination(s)
void ps_a4aee200cccf3153_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = v6.xy / v6.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v6.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v6.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 1ec4df5051094f7b: 1 retail keyword combination(s)
void ps_1ec4df5051094f7b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r0.xyz + r3.xyz;
  r1.xy = v6.xy / v6.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v6.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v6.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 319dbabc458cb216: 1 retail keyword combination(s)
void ps_319dbabc458cb216_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r1.xyz + r0.yzw;
  r1.xy = v6.xy / v6.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v6.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v6.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps f8175fe24e4a2704: 1 retail keyword combination(s)
void ps_f8175fe24e4a2704_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  r0.xyz = r1.xyz * r0.xyz + r3.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v6.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v6.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v6.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v6.xy / v6.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps dd36ced59be1f35c: 1 retail keyword combination(s)
void ps_dd36ced59be1f35c_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = float2(-0.0625,-0.1875) + v7.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v7.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v7.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v7.xy / v7.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps 1b58bf1fc8cc61f7: 1 retail keyword combination(s)
void ps_1b58bf1fc8cc61f7_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r0.xyz + r3.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v7.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v7.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v7.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v7.xy / v7.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps f01711b6d55da455: 1 retail keyword combination(s)
void ps_f01711b6d55da455_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r1.xyz + r0.yzw;
  r1.xy = float2(-0.0625,-0.1875) + v7.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v7.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v7.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v7.xy / v7.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps 2a6c349b5cc32ae0: 1 retail keyword combination(s)
void ps_2a6c349b5cc32ae0_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  r0.xyz = r1.xyz * r0.xyz + r3.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v7.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v7.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v7.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v7.xy / v7.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps ec595136417492e7: 1 retail keyword combination(s)
void ps_ec595136417492e7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = float2(-0.0625,-0.1875) + v6.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v6.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v6.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v6.xy / v6.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps 898174f1d5d1ca52: 1 retail keyword combination(s)
void ps_898174f1d5d1ca52_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r0.xyz + r3.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v6.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v6.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v6.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v6.xy / v6.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps 6d519b696eb84bc5: 1 retail keyword combination(s)
void ps_6d519b696eb84bc5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = _LightColor0.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r1.xyz + r0.yzw;
  r1.xy = float2(-0.0625,-0.1875) + v6.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v6.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v6.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v6.xy / v6.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps 1b2b89ea06ad61e3: 2 retail keyword combination(s)
void ps_1b2b89ea06ad61e3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD8,
  float4 v7 : TEXCOORD9,
  float4 v8 : TEXCOORD10,
  float4 v9 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  o0.xyz = r1.xyz * r0.xyz + r3.xyz;
  o0.w = 1;
  return;
}


// ps 6c00ec29df4b3386: 2 retail keyword combination(s)
void ps_6c00ec29df4b3386_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  o0.xyz = r2.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps ca7310b0aca8f532: 2 retail keyword combination(s)
void ps_ca7310b0aca8f532_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  o0.xyz = r4.xyz * r0.xyz + r3.xyz;
  o0.w = 1;
  return;
}


// ps a5e1f156b5f015c3: 2 retail keyword combination(s)
void ps_a5e1f156b5f015c3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  o0.xyz = r4.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps 7bc04624f00176e7: 2 retail keyword combination(s)
void ps_7bc04624f00176e7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  o0.xyz = r1.xyz * r0.xyz + r3.xyz;
  o0.w = 1;
  return;
}


// ps 101eee4282a03f2a: 2 retail keyword combination(s)
void ps_101eee4282a03f2a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD8,
  float4 v7 : TEXCOORD9,
  float4 v8 : TEXCOORD10,
  float4 v9 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  o0.xyz = r2.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps 6cd928be0f8e874e: 2 retail keyword combination(s)
void ps_6cd928be0f8e874e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD8,
  float4 v7 : TEXCOORD9,
  float4 v8 : TEXCOORD10,
  float4 v9 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  o0.xyz = r4.xyz * r0.xyz + r3.xyz;
  o0.w = 1;
  return;
}


// ps df9f56375753792e: 2 retail keyword combination(s)
void ps_df9f56375753792e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD8,
  float4 v7 : TEXCOORD9,
  float4 v8 : TEXCOORD10,
  float4 v9 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  o0.xyz = r4.xyz * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps d82c5793304f25c1: 1 retail keyword combination(s)
void ps_d82c5793304f25c1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  r0.xyz = r1.xyz * r0.xyz + r3.xyz;
  r1.xy = v6.xy / v6.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v6.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v6.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 8f92691eb4032a1c: 1 retail keyword combination(s)
void ps_8f92691eb4032a1c_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 75f71fa8bc8d86c5: 1 retail keyword combination(s)
void ps_75f71fa8bc8d86c5_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r0.xyz + r3.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 8504a568f156f50d: 1 retail keyword combination(s)
void ps_8504a568f156f50d_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r1.xyz + r0.yzw;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps b6a205f6752c4792: 1 retail keyword combination(s)
void ps_b6a205f6752c4792_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  r0.xyz = r1.xyz * r0.xyz + r3.xyz;
  r1.xy = v7.xy / v7.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v7.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v7.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps a150f0627d247c2f: 1 retail keyword combination(s)
void ps_a150f0627d247c2f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = v6.xy / v6.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v6.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v6.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 12572d166b2e781a: 1 retail keyword combination(s)
void ps_12572d166b2e781a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r0.xyz + r3.xyz;
  r1.xy = v6.xy / v6.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v6.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v6.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps a89546fc2ca50f8a: 1 retail keyword combination(s)
void ps_a89546fc2ca50f8a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r1.xyz + r0.yzw;
  r1.xy = v6.xy / v6.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v6.z * r0.w;
  r1.z = floor(r1.z);
  r1.w = 1 + r1.z;
  r1.w = min(r1.w, r0.w);
  r0.w = v6.z * r0.w + -r1.z;
  r1.xyzw = r1.xyzw / _ScaleOffset.wwww;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r3.y = floor(r1.w);
  r1.w = r2.x ? r2.y : -r2.y;
  r3.x = r1.w * _ScaleOffset.w + -1;
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r2.x = cmp(r1.z >= -r1.z);
  r2.y = frac(abs(r1.z));
  r3.y = floor(r1.z);
  r1.z = r2.x ? r2.y : -r2.y;
  r3.x = r1.z * _ScaleOffset.w + -1;
  r1.xy = r3.xy * r1.ww + r1.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = r2.w + -r1.w;
  r0.w = r0.w * r1.x + r1.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 03ce30abfd57726e: 1 retail keyword combination(s)
void ps_03ce30abfd57726e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  r0.xyz = r1.xyz * r0.xyz + r3.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v6.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v6.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v6.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v6.xy / v6.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps 95a2bbd4e0b8b348: 1 retail keyword combination(s)
void ps_95a2bbd4e0b8b348_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = float2(-0.0625,-0.1875) + v7.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v7.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v7.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v7.xy / v7.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps 3159d5e9fc1efb4c: 1 retail keyword combination(s)
void ps_3159d5e9fc1efb4c_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r0.xyz + r3.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v7.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v7.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v7.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v7.xy / v7.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps f52f86bb5b2ca071: 1 retail keyword combination(s)
void ps_f52f86bb5b2ca071_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r1.xyz + r0.yzw;
  r1.xy = float2(-0.0625,-0.1875) + v7.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v7.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v7.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v7.xy / v7.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps e06b5da9fa347868: 1 retail keyword combination(s)
void ps_e06b5da9fa347868_impl(
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
  float4 v11 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r0.z = 1 + -_Glossiness;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.x = r0.x * r2.w + -r0.x;
  r0.x = r3.x * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = _Metallic.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.xyz;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.w = -_Metallic * 0.959999979 + 0.959999979;
  r1.xyz = r4.xyz * r0.www;
  r0.xyz = r1.xyz * r0.xyz + r3.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v7.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v7.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v7.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v7.xy / v7.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps a41c0d408de906c6: 1 retail keyword combination(s)
void ps_a41c0d408de906c6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r1.y = 1 + -_Glossiness;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.x = r0.w * r2.w + -r0.w;
  r0.w = r3.x * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r3.xyz * r0.zzz;
  r2.xyz = r3.xyz * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = _Color.xyz * r3.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r3.xyz = _Color.xyz * r3.xyz;
  r4.xyz = _Metallic.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r5.xyz = float3(1,1,1) + -r4.xyz;
  r4.xyz = r5.xyz * r1.www + r4.xyz;
  r0.yzw = r4.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.x = -_Metallic * 0.959999979 + 0.959999979;
  r2.xyz = r3.xyz * r0.xxx;
  r0.xyz = r2.xyz * r1.xyz + r0.yzw;
  r1.xy = float2(-0.0625,-0.1875) + v6.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v6.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v6.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v6.xy / v6.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps f343738fe27d52af: 1 retail keyword combination(s)
void ps_f343738fe27d52af_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r1.w = dot(r1.xyz, -r0.yzw);
  r2.x = 9.99999975e-006 + -r1.w;
  r0.yzw = -r0.yzw * r2.xxx + r1.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r0.yzw = r2.xxx ? r0.yzw : r1.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = max(0.00100000005, r0.x);
  r0.x = rsqrt(r0.x);
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r3.xyz);
  r0.y = dot(r2.xyz, r3.xyz);
  r0.xy = max(float2(0,0), r0.xy);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r0.z = 1 + -r3.w;
  r0.w = r0.z * r0.z;
  r0.z = -r0.z * r0.z + 1;
  r2.w = r0.w * r0.w;
  r3.y = r0.x * r2.w + -r0.x;
  r0.x = r3.y * r0.x + 1;
  r0.x = r0.x * r0.x + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.x = r2.w / r0.x;
  r1.x = dot(r1.xyz, r2.xyz);
  r1.y = dot(r2.xyz, r2.xyz);
  r1.y = rsqrt(r1.y);
  r1.y = v4.w * r1.y;
  r2.x = r1.y * -0.5 + 0.5;
  r1.x = max(0, r1.x);
  r1.y = r1.x * r0.z + r0.w;
  r0.z = r1.w * r0.z + r0.w;
  r1.y = r1.w * r1.y;
  r1.z = 1 + -r1.w;
  r0.z = r1.x * r0.z + r1.y;
  r0.z = 9.99999975e-006 + r0.z;
  r0.z = 0.5 / r0.z;
  r0.x = r0.z * r0.x;
  r0.x = 3.14159274 * r0.x;
  r0.x = r0.x * r1.x;
  r0.x = max(0, r0.x);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r1.y * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r1.y = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r1.y * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r3.yzw = r2.xyz * r0.xxx;
  r0.x = 1 + -r0.y;
  r0.z = r0.x * r0.x;
  r0.z = r0.z * r0.z;
  r0.x = r0.z * r0.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r5.xyz = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r5.xyz = r3.xxx * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.z = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r0.zzz;
  r6.xyz = float3(1,1,1) + -r5.xyz;
  r5.xyz = r6.xyz * r0.xxx + r5.xyz;
  r3.xyz = r5.xyz * r3.yzw;
  r0.x = r1.z * r1.z;
  r0.x = r0.x * r0.x;
  r0.x = r0.x * r1.z;
  r0.z = r0.y + r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.5 * r0.w;
  r0.y = r0.y * r0.w + r0.z;
  r0.z = r0.w * -0.337748349 + 1;
  r0.y = -1 + r0.y;
  r0.x = r0.y * r0.x + 1;
  r0.w = 1 + -r1.x;
  r1.y = r0.w * r0.w;
  r1.y = r1.y * r1.y;
  r0.w = r1.y * r0.w;
  r0.y = r0.y * r0.w + 1;
  r0.x = r0.y * r0.x;
  r0.x = r0.x * r0.z;
  r0.x = r0.x * r1.x;
  r0.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r0.xyz + r3.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v6.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v6.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v6.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v6.xy / v6.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


// ps ba6a715793af5100: 1 retail keyword combination(s)
void ps_ba6a715793af5100_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD7,
  float4 v7 : TEXCOORD8,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  float4 v10 : TEXCOORD11,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(v2.xyz, v2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v2.xyz * r0.www;
  r1.w = dot(r0.xyz, -r1.xyz);
  r2.x = 9.99999975e-006 + -r1.w;
  r1.xyz = -r1.xyz * r2.xxx + r0.xyz;
  r2.x = cmp(r1.w < 0);
  r1.w = saturate(r1.w);
  r1.xyz = r2.xxx ? r1.xyz : r0.xyz;
  r2.x = v3.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = -v2.xyz * r0.www + r2.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = max(0.00100000005, r0.w);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = dot(r1.xyz, r3.xyz);
  r1.x = dot(r2.xyz, r3.xyz);
  r1.x = max(0, r1.x);
  r0.w = max(0, r0.w);
  r3.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  r1.y = 1 + -r3.w;
  r1.z = r1.y * r1.y;
  r1.y = -r1.y * r1.y + 1;
  r2.w = r1.z * r1.z;
  r3.y = r0.w * r2.w + -r0.w;
  r0.w = r3.y * r0.w + 1;
  r0.w = r0.w * r0.w + 1.00000001e-007;
  r2.w = 0.318309873 * r2.w;
  r0.w = r2.w / r0.w;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = v4.w * r0.y;
  r2.x = r0.y * -0.5 + 0.5;
  r0.x = max(0, r0.x);
  r0.y = r1.w * r1.y + r1.z;
  r0.z = r0.x * r1.y + r1.z;
  r0.z = r1.w * r0.z;
  r1.y = 1 + -r1.w;
  r0.y = r0.x * r0.y + r0.z;
  r0.y = 9.99999975e-006 + r0.y;
  r0.y = 0.5 / r0.y;
  r0.y = r0.y * r0.w;
  r0.y = 3.14159274 * r0.y;
  r0.y = r0.y * r0.x;
  r0.y = max(0, r0.y);
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r0.z = 0.100000001 + v4.w;
  r0.z = saturate(5 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = -0.349999994 + _BT_CloudCover;
  r0.z = saturate(1.53846157 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = -r0.w * r0.z + 1;
  r3.yzw = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r3.yzw = float3(0.25,0.25,0.25) * r3.yzw;
  r3.yzw = r3.yzw * r0.zzz;
  r2.xyz = r3.yzw * r2.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.w = 1 + -r1.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r3.yzw = _Color.xyz * r4.xyz + float3(-0.0399999991,-0.0399999991,-0.0399999991);
  r4.xyz = _Color.xyz * r4.xyz;
  r3.yzw = r3.xxx * r3.yzw + float3(0.0399999991,0.0399999991,0.0399999991);
  r2.w = -r3.x * 0.959999979 + 0.959999979;
  r4.xyz = r4.xyz * r2.www;
  r5.xyz = float3(1,1,1) + -r3.yzw;
  r3.xyz = r5.xyz * r1.www + r3.yzw;
  r0.yzw = r3.xyz * r0.yzw;
  r1.w = r1.x + r1.x;
  r1.x = r1.w * r1.x;
  r1.w = 0.5 * r1.z;
  r1.x = r1.x * r1.z + r1.w;
  r1.z = r1.z * -0.337748349 + 1;
  r1.x = -1 + r1.x;
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r1.y = r1.w * r1.y;
  r1.y = r1.x * r1.y + 1;
  r1.w = 1 + -r0.x;
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r1.x = r1.x * r1.w + 1;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.z;
  r0.x = r1.x * r0.x;
  r1.xyz = r2.xyz * r0.xxx;
  r0.xyz = r4.xyz * r1.xyz + r0.yzw;
  r1.xy = float2(-0.0625,-0.1875) + v6.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v6.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v6.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v6.xy / v6.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
		vs_6a8dbb31ee88778a_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord8 = o6;
		o.texcoord9 = o7;
		o.texcoord10 = o8;
		o.texcoord11 = o9;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
		vs_8e50d5c1e9134f81_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord8 = o7;
		o.texcoord9 = o8;
		o.texcoord10 = o9;
		o.texcoord11 = o10;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
		vs_d5a700f00e42a3fb_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord8 = o7;
		o.texcoord9 = o8;
		o.texcoord10 = o9;
		o.texcoord11 = o10;
	}
#elif !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
		vs_8102b99710c7b01c_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord8 = o6;
		o.texcoord9 = o7;
		o.texcoord10 = o8;
		o.texcoord11 = o9;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
		vs_694b8a47a3d3496d_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord7 = o6;
		o.texcoord8 = o7;
		o.texcoord9 = o8;
		o.texcoord10 = o9;
		o.texcoord11 = o10;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
		float4 o11 = 0;
		vs_7e110e989849cffe_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11);
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
		o.texcoord11 = o11;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_NORMALMAP)
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
		float4 o11 = 0;
		vs_2229293735e41d20_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11);
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
		o.texcoord11 = o11;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_NORMALMAP)
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
		vs_8216bec70f86a226_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord7 = o6;
		o.texcoord8 = o7;
		o.texcoord9 = o8;
		o.texcoord10 = o9;
		o.texcoord11 = o10;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_99ea005456eb30a1_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_db034f59756263d2_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_729cfdc53479e7d5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_2483f80fbb38bac1_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_3abd6972dbf2c0dd_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_84b88346bc5df258_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_69cf76e238e9a3e6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_57350c08d6eadd3a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_212c0c042e07bf3f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_f1298e74eab015b9_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_514122de163d8c7a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_7fa03e9d841c5e7d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_bb89961abf7338f5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_a4aee200cccf3153_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_1ec4df5051094f7b_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_319dbabc458cb216_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_f8175fe24e4a2704_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_dd36ced59be1f35c_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_1b58bf1fc8cc61f7_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_f01711b6d55da455_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_2a6c349b5cc32ae0_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_ec595136417492e7_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_898174f1d5d1ca52_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && !defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_6d519b696eb84bc5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_1b2b89ea06ad61e3_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_6c00ec29df4b3386_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_ca7310b0aca8f532_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_a5e1f156b5f015c3_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_7bc04624f00176e7_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_101eee4282a03f2a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_6cd928be0f8e874e_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && !defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_df9f56375753792e_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_d82c5793304f25c1_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_8f92691eb4032a1c_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_75f71fa8bc8d86c5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_8504a568f156f50d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_b6a205f6752c4792_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_a150f0627d247c2f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_12572d166b2e781a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && !defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_a89546fc2ca50f8a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_03ce30abfd57726e_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_95a2bbd4e0b8b348_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_3159d5e9fc1efb4c_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_f52f86bb5b2ca071_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_e06b5da9fa347868_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_a41c0d408de906c6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_f343738fe27d52af_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
		r.t0 = o0;
	}
#elif !defined(DIRECTIONAL_COOKIE) && defined(_BT_FORWARD_FOG) && defined(_BT_SUNLIGHT_CONTROL) && defined(_FOG_3D) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		ps_ba6a715793af5100_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, i.texcoord11, o0);
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
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" "ShadowSupport"="true" }
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile _ SHADOWS_CUBE
			#pragma multi_compile _ SHADOWS_DEPTH

#define cmp -

Texture2D _DitherMaskLOD2D;
SamplerState sampler_DitherMaskLOD2D;
Texture3D _DitherMaskLOD;
SamplerState sampler_DitherMaskLOD;

float4 _MainTex_ST;
float _StippleAlpha;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#elif !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#elif defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord1 : TEXCOORD1;
};
#elif defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)
struct v2f
{
	float4 sv_position : SV_POSITION;
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
};

// vs aa4b0478faaa884a: 1 retail keyword combination(s)
void vs_aa4b0478faaa884a_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r1.xyzw;
  r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(r0.xyz, r2.xyz);
  r0.w = -r0.w * r0.w + 1;
  r0.w = sqrt(r0.w);
  r0.w = unity_LightShadowBias.z * r0.w;
  r0.xyz = -r0.xyz * r0.www + r1.xyz;
  r0.w = cmp(unity_LightShadowBias.z != 0.000000);
  r0.xyz = r0.www ? r0.xyz : r1.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = unity_LightShadowBias.x / r0.w;
  r1.x = min(0, r1.x);
  r1.x = max(-1, r1.x);
  r0.z = r1.x + r0.z;
  r1.x = min(r0.z, r0.w);
  o0.xyw = r0.xyw;
  r0.x = r1.x + -r0.z;
  o0.z = unity_LightShadowBias.y * r0.x + r0.z;
  return;
}


// vs d4c082007ab5ea9a: 1 retail keyword combination(s)
void vs_d4c082007ab5ea9a_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r1.xyzw;
  r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(r0.xyz, r2.xyz);
  r0.w = -r0.w * r0.w + 1;
  r0.w = sqrt(r0.w);
  r0.w = unity_LightShadowBias.z * r0.w;
  r0.xyz = -r0.xyz * r0.www + r1.xyz;
  r0.w = cmp(unity_LightShadowBias.z != 0.000000);
  r0.xyz = r0.www ? r0.xyz : r1.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = min(r0.z, r0.w);
  r1.x = r1.x + -r0.z;
  o0.z = unity_LightShadowBias.y * r1.x + r0.z;
  o0.xyw = r0.xyw;
  return;
}


// vs 4faced0784cff9d7: 1 retail keyword combination(s)
void vs_4faced0784cff9d7_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  inout float2 o0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r1.xyzw;
  r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(r0.xyz, r2.xyz);
  r0.w = -r0.w * r0.w + 1;
  r0.w = sqrt(r0.w);
  r0.w = unity_LightShadowBias.z * r0.w;
  r0.xyz = -r0.xyz * r0.www + r1.xyz;
  r0.w = cmp(unity_LightShadowBias.z != 0.000000);
  r0.xyz = r0.www ? r0.xyz : r1.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = unity_LightShadowBias.x / r0.w;
  r1.x = min(0, r1.x);
  r1.x = max(-1, r1.x);
  r0.z = r1.x + r0.z;
  r1.x = min(r0.z, r0.w);
  o1.xyw = r0.xyw;
  r0.x = r1.x + -r0.z;
  o1.z = unity_LightShadowBias.y * r0.x + r0.z;
  return;
}


// vs 38f094d13644ad58: 1 retail keyword combination(s)
void vs_38f094d13644ad58_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  inout float2 o0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r1.xyzw;
  r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(r0.xyz, r2.xyz);
  r0.w = -r0.w * r0.w + 1;
  r0.w = sqrt(r0.w);
  r0.w = unity_LightShadowBias.z * r0.w;
  r0.xyz = -r0.xyz * r0.www + r1.xyz;
  r0.w = cmp(unity_LightShadowBias.z != 0.000000);
  r0.xyz = r0.www ? r0.xyz : r1.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r2.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r2.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = min(r0.z, r0.w);
  r1.x = r1.x + -r0.z;
  o1.z = unity_LightShadowBias.y * r1.x + r0.z;
  o1.xyw = r0.xyw;
  return;
}


// ps 5b3349ebfd951ea3: 2 retail keyword combination(s)
void ps_5b3349ebfd951ea3_impl(
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = float4(0,0,0,0);
  return;
}


// ps 3d212729b7c84c6c: 2 retail keyword combination(s)
void ps_3d212729b7c84c6c_impl(
  float2 v0 : TEXCOORD1,
  float4 v1 : SV_Position0,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy / v1.ww;
  r0.xy = float2(0.25,0.25) * r0.xy;
  r0.y = frac(r0.y);
  r0.z = r0.y * 0.0625 + (unity_LODFade.x < 0 ? unity_LODFade.y + 0.9375 : unity_LODFade.y);
  r0.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r0.xz).xyzw;
  r0.x = -0.5 + r0.w;
  r0.x = cmp(r0.x < 0);
  clip(r0.x != 0 ? -1 : 1);
  r0.x = saturate(_StippleAlpha);
  r0.z = 0.9375 * r0.x;
  r0.xy = float2(0.25,0.25) * v1.xy;
  r0.xyzw = _DitherMaskLOD.Sample(sampler_DitherMaskLOD, r0.xyz).xyzw;
  r0.x = -0.00999999978 + r0.w;
  r0.x = cmp(r0.x < 0);
  clip(r0.x != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)
	{
		float4 o0 = 0;
		vs_aa4b0478faaa884a_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0);
		o.sv_position = o0;
	}
#elif !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)
	{
		float4 o0 = 0;
		vs_d4c082007ab5ea9a_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0);
		o.sv_position = o0;
	}
#elif defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_4faced0784cff9d7_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0, o1);
		o.texcoord1.xy = o0;
		o.sv_position = o1;
	}
#elif defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_38f094d13644ad58_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0, o1);
		o.texcoord1.xy = o0;
		o.sv_position = o1;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(LOD_FADE_CROSSFADE)
	{
		float4 o0 = 0;
		ps_5b3349ebfd951ea3_impl(o0);
		r.t0 = o0;
	}
#elif defined(LOD_FADE_CROSSFADE)
	{
		float4 o0 = 0;
		ps_3d212729b7c84c6c_impl(i.texcoord1.xy, i.sv_position, o0);
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
			Name "DEFERRED"
			Tags { "LightMode"="Deferred" }
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ LIGHTPROBE_SH
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile _ UNITY_HDR_ON
			#pragma multi_compile _ _DETAIL_OVERLAY
			#pragma multi_compile _ _EMISSION
			#pragma multi_compile _ _GEO_LOW
			#pragma multi_compile _ _METALLICGLOSSMAP
			#pragma multi_compile _ _NORMALMAP

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture3D _BT_NoiseTex3D;
SamplerState sampler_BT_NoiseTex3D;
Texture2D _OcclusionMap;
SamplerState sampler_OcclusionMap;
Texture2D _BumpMap;
SamplerState sampler_BumpMap;
Texture2D _MetallicGlossMap;
SamplerState sampler_MetallicGlossMap;
Texture2D _EmissionMap;
SamplerState sampler_EmissionMap;
Texture2D _DetailAlbedoMap;
SamplerState sampler_DetailAlbedoMap;
Texture2D _DetailNormalMap;
SamplerState sampler_DetailNormalMap;

float4 _MainTex_ST;
int _UVSpace;
float4 _Seed;
float4 _Color;
float _Metallic;
float _Glossiness;
float _OcclusionStrength;
float _BumpScale;
float4 _EmissionColor;
float _BT_NightLights;
float _DetailNormalMapScale;
float4 unity_DynamicLightmap_HDR;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 tangent0 : TANGENT0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
};

#if !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && !defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(LIGHTPROBE_SH) && defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(LIGHTPROBE_SH) && !defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord3 : TEXCOORD3;
};
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && defined(_NORMALMAP)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
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
	float4 t3 : SV_Target3;
};

// vs dd08ff023da5eee8: 24 retail keyword combination(s)
void vs_dd08ff023da5eee8_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  float4 v3 : TANGENT0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float3 o3 : TEXCOORD3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  r0.zw = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.zw = r0.xy * _Seed.zw + _Seed.xy;
  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = _UVSpace.xx ? r0.zw : r0.xy;
  o2.xyzw = float4(0,0,0,0);
  r0.x = dot(v2.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v2.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v2.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o3.xyz = r0.xyz * r0.www;
  return;
}


// vs 78823937ded9641b: 32 retail keyword combination(s)
void vs_78823937ded9641b_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  float4 v3 : TANGENT0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD3,
  inout float4 o4 : TEXCOORD4,
  inout float3 o5 : TEXCOORD5)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  r0.zw = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.zw = r0.xy * _Seed.zw + _Seed.xy;
  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = _UVSpace.xx ? r0.zw : r0.xy;
  r0.x = dot(v2.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v2.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v2.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = r0.y * r0.y;
  r0.w = r0.x * r0.x + -r0.w;
  r1.xyzw = r0.xyzz * r0.yzzx;
  r2.x = dot(unity_SHBr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHBg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHBb.xyzw, r1.xyzw);
  o2.xyz = unity_SHC.xyz * r0.www + r2.xyz;
  o2.w = 0;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  o3.xyz = r1.xyz;
  r2.xyz = r1.yzx * r0.zxy;
  r1.xyz = r0.yzx * r1.zxy + -r2.xyz;
  o5.xyz = r0.xyz;
  r0.x = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r1.xyz * r0.xxx;
  return;
}


// vs ff19f77b2fec55ee: 24 retail keyword combination(s)
void vs_ff19f77b2fec55ee_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  float4 v3 : TANGENT0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float3 o3 : TEXCOORD3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  r0.zw = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.zw = r0.xy * _Seed.zw + _Seed.xy;
  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = _UVSpace.xx ? r0.zw : r0.xy;
  r0.x = dot(v2.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v2.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v2.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = r0.y * r0.y;
  r0.w = r0.x * r0.x + -r0.w;
  r1.xyzw = r0.xyzz * r0.yzzx;
  o3.xyz = r0.xyz;
  r0.x = dot(unity_SHBr.xyzw, r1.xyzw);
  r0.y = dot(unity_SHBg.xyzw, r1.xyzw);
  r0.z = dot(unity_SHBb.xyzw, r1.xyzw);
  o2.xyz = unity_SHC.xyz * r0.www + r0.xyz;
  o2.w = 0;
  return;
}


// vs f50c86c2c38b72e0: 32 retail keyword combination(s)
void vs_f50c86c2c38b72e0_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD2,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD3,
  inout float4 o4 : TEXCOORD4,
  inout float3 o5 : TEXCOORD5)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  r0.zw = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.zw = r0.xy * _Seed.zw + _Seed.xy;
  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = _UVSpace.xx ? r0.zw : r0.xy;
  o2.zw = v4.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o2.xy = float2(0,0);
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o3.xyz = r0.xyz;
  r1.x = dot(v2.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(v2.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(v2.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.xyz = r1.zxy * r0.yzx;
  r0.xyz = r1.yzx * r0.zxy + -r2.xyz;
  o5.xyz = r1.xyz;
  r0.w = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r0.xyz * r0.www;
  return;
}


// vs 2ec6a8c9c189673b: 24 retail keyword combination(s)
void vs_2ec6a8c9c189673b_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  float4 v3 : TANGENT0,
  float2 v4 : TEXCOORD2,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float3 o3 : TEXCOORD3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  r0.zw = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.zw = r0.xy * _Seed.zw + _Seed.xy;
  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = _UVSpace.xx ? r0.zw : r0.xy;
  o2.zw = v4.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o2.xy = float2(0,0);
  r0.x = dot(v2.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v2.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v2.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o3.xyz = r0.xyz * r0.www;
  return;
}


// vs d3638328b0fb7c75: 32 retail keyword combination(s)
void vs_d3638328b0fb7c75_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  float4 v3 : TANGENT0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD3,
  inout float4 o4 : TEXCOORD4,
  inout float3 o5 : TEXCOORD5)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  r0.zw = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.zw = r0.xy * _Seed.zw + _Seed.xy;
  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = _UVSpace.xx ? r0.zw : r0.xy;
  o2.xyzw = float4(0,0,0,0);
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o3.xyz = r0.xyz;
  r1.x = dot(v2.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(v2.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(v2.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.xyz = r1.zxy * r0.yzx;
  r0.xyz = r1.yzx * r0.zxy + -r2.xyz;
  o5.xyz = r1.xyz;
  r0.w = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r0.xyz * r0.www;
  return;
}


// ps 3c9604fc276b2e8f: 8 retail keyword combination(s)
void ps_3c9604fc276b2e8f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  o0.w = _OcclusionStrength * r0.x + 1;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0,0);
  r0.x = dot(v3.xyz, v3.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v3.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  o3.xyzw = float4(0,0,0,1);
  return;
}


// ps ab200bddc1fb5b56: 8 retail keyword combination(s)
void ps_ab200bddc1fb5b56_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0,0);
  r1.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r1.x = r1.x * r1.w;
  r0.yz = r1.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.yyy + r1.xyz;
  r0.y = dot(r0.yz, r0.yz);
  r0.y = min(1, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = sqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy + r1.xyz;
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r1.xyz = r1.xxx * r0.yzw;
  o2.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.w = 1;
  r2.x = dot(unity_SHAr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHAg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHAb.xyzw, r1.xyzw);
  r0.yzw = v2.xyz + r2.xyz;
  r0.yzw = max(float3(0,0,0), r0.yzw);
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps dcf5c16b949b8708: 8 retail keyword combination(s)
void ps_dcf5c16b949b8708_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  r1.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r1.xw;
  o1.yw = float2(0,0);
  o2.w = 0.333333343;
  r0.y = dot(v3.xyz, v3.xyz);
  r0.y = rsqrt(r0.y);
  r1.xyz = v3.xyz * r0.yyy;
  o2.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.w = 1;
  r2.x = dot(unity_SHAr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHAg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHAb.xyzw, r1.xyzw);
  r0.yzw = v2.xyz + r2.xyz;
  r0.yzw = max(float3(0,0,0), r0.yzw);
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps 089e1c5ff63deb2c: 8 retail keyword combination(s)
void ps_089e1c5ff63deb2c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  r1.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r1.xw;
  o1.yw = float2(0,0);
  o2.w = 0.333333343;
  r0.y = dot(v3.xyz, v3.xyz);
  r0.y = rsqrt(r0.y);
  r1.xyz = v3.xyz * r0.yyy;
  o2.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.w = 1;
  r2.x = dot(unity_SHAr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHAg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHAb.xyzw, r1.xyzw);
  r0.yzw = v2.xyz + r2.xyz;
  r0.yzw = max(float3(0,0,0), r0.yzw);
  r1.x = cmp(_BT_NightLights != 1.000000);
  r1.x = r1.x ? 0 : 1;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.yzw = _EmissionColor.xyz * r2.xyz;
  r1.xyz = r1.yzw * r1.xxx;
  o3.xyz = r0.yzw * r0.xxx + r1.xyz;
  o3.w = 1;
  return;
}


// ps fb1cb424e8f83748: 8 retail keyword combination(s)
void ps_fb1cb424e8f83748_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  r1.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r1.xw;
  o1.yw = float2(0,0);
  r1.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r1.x = r1.x * r1.w;
  r0.yz = r1.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.yyy + r1.xyz;
  r0.y = dot(r0.yz, r0.yz);
  r0.y = min(1, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = sqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy + r1.xyz;
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r1.xyz = r1.xxx * r0.yzw;
  o2.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.w = 1;
  r2.x = dot(unity_SHAr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHAg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHAb.xyzw, r1.xyzw);
  r0.yzw = v2.xyz + r2.xyz;
  r0.yzw = max(float3(0,0,0), r0.yzw);
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps 3df710a535107e5b: 8 retail keyword combination(s)
void ps_3df710a535107e5b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  r1.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r1.xw;
  o1.yw = float2(0,0);
  r1.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r1.x = r1.x * r1.w;
  r0.yz = r1.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.yyy + r1.xyz;
  r0.y = dot(r0.yz, r0.yz);
  r0.y = min(1, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = sqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy + r1.xyz;
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r1.xyz = r1.xxx * r0.yzw;
  o2.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.w = 1;
  r2.x = dot(unity_SHAr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHAg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHAb.xyzw, r1.xyzw);
  r0.yzw = v2.xyz + r2.xyz;
  r0.yzw = max(float3(0,0,0), r0.yzw);
  r1.x = cmp(_BT_NightLights != 1.000000);
  r1.x = r1.x ? 0 : 1;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.yzw = _EmissionColor.xyz * r2.xyz;
  r1.xyz = r1.yzw * r1.xxx;
  o3.xyz = r0.yzw * r0.xxx + r1.xyz;
  o3.w = 1;
  return;
}


// ps fa6ba7fc08e27017: 8 retail keyword combination(s)
void ps_fa6ba7fc08e27017_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xz = v1.zw;
  r0.y = 0;
  r0.xyz = float3(4,4,4) * r0.xyz;
  r0.xyzw = _BT_NoiseTex3D.SampleBias(sampler_BT_NoiseTex3D, r0.xyz, 3).xyzw;
  r0.x = r0.y * 0.5 + r0.x;
  r0.x = r0.z * 0.25 + r0.x;
  r0.x = r0.w * 0.125 + r0.x;
  r0.x = 0.533333361 * r0.x;
  r1.xyzw = _DetailAlbedoMap.Sample(sampler_DetailAlbedoMap, v1.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.yzw = -r2.xyz + r1.xyz;
  r0.yzw = r0.xxx * r0.yzw + r2.xyz;
  o0.xyz = _Color.xyz * r0.yzw;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.y = -1 + r1.x;
  r0.y = _OcclusionStrength * r0.y + 1;
  o0.w = r0.y;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0,0);
  r1.xyzw = _DetailNormalMap.Sample(sampler_DetailNormalMap, v1.xy).xyzw;
  r1.x = r1.x * r1.w;
  r0.zw = r1.xy * float2(2,2) + float2(-1,-1);
  r1.xy = _DetailNormalMapScale.xx * r0.zw;
  r0.z = dot(r1.xy, r1.xy);
  r0.z = min(1, r0.z);
  r0.z = 1 + -r0.z;
  r1.z = sqrt(r0.z);
  r2.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r0.zw = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r0.zw;
  r0.z = dot(r2.xy, r2.xy);
  r0.z = min(1, r0.z);
  r0.z = 1 + -r0.z;
  r2.z = sqrt(r0.z);
  r1.xyz = -r2.xyz + r1.xyz;
  r0.xzw = r0.xxx * r1.xyz + r2.xyz;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.xzw = v5.xyz * r0.www + r1.xyz;
  r1.x = dot(r0.xzw, r0.xzw);
  r1.x = rsqrt(r1.x);
  r1.xyz = r1.xxx * r0.xzw;
  o2.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.w = 1;
  r2.x = dot(unity_SHAr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHAg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHAb.xyzw, r1.xyzw);
  r0.xzw = v2.xyz + r2.xyz;
  r0.xzw = max(float3(0,0,0), r0.xzw);
  o3.xyz = r0.xzw * r0.yyy;
  o3.w = 1;
  return;
}


// ps 0902b105a254ac2d: 8 retail keyword combination(s)
void ps_0902b105a254ac2d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0,0);
  o2.w = 0.333333343;
  r0.y = dot(v3.xyz, v3.xyz);
  r0.y = rsqrt(r0.y);
  r1.xyz = v3.xyz * r0.yyy;
  o2.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.w = 1;
  r2.x = dot(unity_SHAr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHAg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHAb.xyzw, r1.xyzw);
  r0.yzw = v2.xyz + r2.xyz;
  r0.yzw = max(float3(0,0,0), r0.yzw);
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps 5c9770512ac9d90b: 8 retail keyword combination(s)
void ps_5c9770512ac9d90b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0,0);
  r1.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r1.x = r1.x * r1.w;
  r0.yz = r1.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.yyy + r1.xyz;
  r0.y = dot(r0.yz, r0.yz);
  r0.y = min(1, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = sqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy + r1.xyz;
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r0.yzw = r1.xxx * r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps 1a0e7d6f340bd337: 8 retail keyword combination(s)
void ps_1a0e7d6f340bd337_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  r1.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r1.xw;
  o1.yw = float2(0,0);
  r0.y = dot(v3.xyz, v3.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v3.xyz * r0.yyy;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps 0c993fe6a4722281: 8 retail keyword combination(s)
void ps_0c993fe6a4722281_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  r1.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r1.xw;
  o1.yw = float2(0,0);
  r0.y = dot(v3.xyz, v3.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v3.xyz * r0.yyy;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r1.x = cmp(_BT_NightLights != 1.000000);
  r1.x = r1.x ? 0 : 1;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.yzw = _EmissionColor.xyz * r2.xyz;
  r1.xyz = r1.yzw * r1.xxx;
  o3.xyz = r0.yzw * r0.xxx + r1.xyz;
  o3.w = 1;
  return;
}


// ps 1eb1b397f42335b4: 8 retail keyword combination(s)
void ps_1eb1b397f42335b4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  r1.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r1.xw;
  o1.yw = float2(0,0);
  r1.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r1.x = r1.x * r1.w;
  r0.yz = r1.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.yyy + r1.xyz;
  r0.y = dot(r0.yz, r0.yz);
  r0.y = min(1, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = sqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy + r1.xyz;
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r0.yzw = r1.xxx * r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps 83594e23d6f0a880: 8 retail keyword combination(s)
void ps_83594e23d6f0a880_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  r1.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r1.xw;
  o1.yw = float2(0,0);
  r1.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r1.x = r1.x * r1.w;
  r0.yz = r1.xy * float2(2,2) + float2(-1,-1);
  r0.yz = _BumpScale.xx * r0.yz;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.yyy + r1.xyz;
  r0.y = dot(r0.yz, r0.yz);
  r0.y = min(1, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = sqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy + r1.xyz;
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r0.yzw = r1.xxx * r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r1.x = cmp(_BT_NightLights != 1.000000);
  r1.x = r1.x ? 0 : 1;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.yzw = _EmissionColor.xyz * r2.xyz;
  r1.xyz = r1.yzw * r1.xxx;
  o3.xyz = r0.yzw * r0.xxx + r1.xyz;
  o3.w = 1;
  return;
}


// ps 7e56539f5ed132e8: 8 retail keyword combination(s)
void ps_7e56539f5ed132e8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xz = v1.zw;
  r0.y = 0;
  r0.xyz = float3(4,4,4) * r0.xyz;
  r0.xyzw = _BT_NoiseTex3D.SampleBias(sampler_BT_NoiseTex3D, r0.xyz, 3).xyzw;
  r0.x = r0.y * 0.5 + r0.x;
  r0.x = r0.z * 0.25 + r0.x;
  r0.x = r0.w * 0.125 + r0.x;
  r0.x = 0.533333361 * r0.x;
  r1.xyzw = _DetailAlbedoMap.Sample(sampler_DetailAlbedoMap, v1.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.yzw = -r2.xyz + r1.xyz;
  r0.yzw = r0.xxx * r0.yzw + r2.xyz;
  o0.xyz = _Color.xyz * r0.yzw;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.y = -1 + r1.x;
  r0.y = _OcclusionStrength * r0.y + 1;
  o0.w = r0.y;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0,0);
  r1.xyzw = _DetailNormalMap.Sample(sampler_DetailNormalMap, v1.xy).xyzw;
  r1.x = r1.x * r1.w;
  r0.zw = r1.xy * float2(2,2) + float2(-1,-1);
  r1.xy = _DetailNormalMapScale.xx * r0.zw;
  r0.z = dot(r1.xy, r1.xy);
  r0.z = min(1, r0.z);
  r0.z = 1 + -r0.z;
  r1.z = sqrt(r0.z);
  r2.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r0.zw = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r0.zw;
  r0.z = dot(r2.xy, r2.xy);
  r0.z = min(1, r0.z);
  r0.z = 1 + -r0.z;
  r2.z = sqrt(r0.z);
  r1.xyz = -r2.xyz + r1.xyz;
  r0.xzw = r0.xxx * r1.xyz + r2.xyz;
  r1.xyz = v4.xyz * r0.zzz;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.xzw = v5.xyz * r0.www + r1.xyz;
  r1.x = dot(r0.xzw, r0.xzw);
  r1.x = rsqrt(r1.x);
  r0.xzw = r1.xxx * r0.xzw;
  o2.xyz = r0.xzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.x = dot(r0.xzw, r1.xyz);
  r0.x = 0.5 + r0.x;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.xzw = r1.xyz * r0.xxx;
  r0.xzw = r0.xzw / r1.www;
  o3.xyz = r0.xzw * r0.yyy;
  o3.w = 1;
  return;
}


// ps d8d40b22326a7c66: 8 retail keyword combination(s)
void ps_d8d40b22326a7c66_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  r0.x = _OcclusionStrength * r0.x + 1;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0,0);
  r0.y = dot(v3.xyz, v3.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v3.xyz * r0.yyy;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v2.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps d6ad5521cf9cdbce: 8 retail keyword combination(s)
void ps_d6ad5521cf9cdbce_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  o0.w = _OcclusionStrength * r0.x + 1;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0,0);
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  o3.xyzw = float4(0,0,0,1);
  return;
}


// ps 94ae8b418213fab6: 8 retail keyword combination(s)
void ps_94ae8b418213fab6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  o0.w = _OcclusionStrength * r0.x + 1;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r0.xw;
  o1.yw = float2(0,0);
  r0.x = dot(v3.xyz, v3.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v3.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  o3.xyzw = float4(0,0,0,1);
  return;
}


// ps fbd7028c983edf01: 8 retail keyword combination(s)
void ps_fbd7028c983edf01_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  o0.w = _OcclusionStrength * r0.x + 1;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r0.xw;
  o1.yw = float2(0,0);
  r0.x = dot(v3.xyz, v3.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v3.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r0.x = cmp(_BT_NightLights != 1.000000);
  r0.x = r0.x ? 0 : 1;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r0.yzw = _EmissionColor.xyz * r1.xyz;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps 37d0c85155a605a9: 8 retail keyword combination(s)
void ps_37d0c85155a605a9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  o0.w = _OcclusionStrength * r0.x + 1;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r0.xw;
  o1.yw = float2(0,0);
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  o3.xyzw = float4(0,0,0,1);
  return;
}


// ps d423018caf47d2c9: 8 retail keyword combination(s)
void ps_d423018caf47d2c9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = -1 + r0.x;
  o0.w = _OcclusionStrength * r0.x + 1;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v1.xy).xyzw;
  o1.xz = r0.xw;
  o1.yw = float2(0,0);
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r1.xyz = v4.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  r0.x = cmp(_BT_NightLights != 1.000000);
  r0.x = r0.x ? 0 : 1;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r0.yzw = _EmissionColor.xyz * r1.xyz;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 1;
  return;
}


// ps 40b79f54ae662f71: 8 retail keyword combination(s)
void ps_40b79f54ae662f71_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xz = v1.zw;
  r0.y = 0;
  r0.xyz = float3(4,4,4) * r0.xyz;
  r0.xyzw = _BT_NoiseTex3D.SampleBias(sampler_BT_NoiseTex3D, r0.xyz, 3).xyzw;
  r0.x = r0.y * 0.5 + r0.x;
  r0.x = r0.z * 0.25 + r0.x;
  r0.x = r0.w * 0.125 + r0.x;
  r0.x = 0.533333361 * r0.x;
  r1.xyzw = _DetailAlbedoMap.Sample(sampler_DetailAlbedoMap, v1.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.yzw = -r2.xyz + r1.xyz;
  r0.yzw = r0.xxx * r0.yzw + r2.xyz;
  o0.xyz = _Color.xyz * r0.yzw;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.y = -1 + r1.x;
  o0.w = _OcclusionStrength * r0.y + 1;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0,0);
  r1.xyzw = _DetailNormalMap.Sample(sampler_DetailNormalMap, v1.xy).xyzw;
  r1.x = r1.x * r1.w;
  r0.yz = r1.xy * float2(2,2) + float2(-1,-1);
  r1.xy = _DetailNormalMapScale.xx * r0.yz;
  r0.y = dot(r1.xy, r1.xy);
  r0.y = min(1, r0.y);
  r0.y = 1 + -r0.y;
  r1.z = sqrt(r0.y);
  r2.xyzw = _BumpMap.Sample(sampler_BumpMap, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r0.yz = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r0.yz;
  r0.y = dot(r2.xy, r2.xy);
  r0.y = min(1, r0.y);
  r0.y = 1 + -r0.y;
  r2.z = sqrt(r0.y);
  r0.yzw = -r2.xyz + r1.xyz;
  r0.xyz = r0.xxx * r0.yzw + r2.xyz;
  r1.xyz = v4.xyz * r0.yyy;
  r0.xyw = v3.xyz * r0.xxx + r1.xyz;
  r0.xyz = v5.xyz * r0.zzz + r0.xyw;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
  o3.xyzw = float4(0,0,0,1);
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float3 o3 = 0;
		vs_dd08ff023da5eee8_impl(v.position0, v.texcoord0.xy, v.normal0.xyz, v.tangent0, o0, o1, o2, o3);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord3.xyz = o3;
	}
#elif defined(LIGHTPROBE_SH) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_78823937ded9641b_impl(v.position0, v.texcoord0.xy, v.normal0.xyz, v.tangent0, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord3 = o3;
		o.texcoord4 = o4;
		o.texcoord5.xyz = o5;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float3 o3 = 0;
		vs_ff19f77b2fec55ee_impl(v.position0, v.texcoord0.xy, v.normal0.xyz, v.tangent0, o0, o1, o2, o3);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord3.xyz = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_f50c86c2c38b72e0_impl(v.position0, v.texcoord0.xy, v.normal0.xyz, v.tangent0, v.texcoord2.xy, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord3 = o3;
		o.texcoord4 = o4;
		o.texcoord5.xyz = o5;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float3 o3 = 0;
		vs_2ec6a8c9c189673b_impl(v.position0, v.texcoord0.xy, v.normal0.xyz, v.tangent0, v.texcoord2.xy, o0, o1, o2, o3);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord3.xyz = o3;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_d3638328b0fb7c75_impl(v.position0, v.texcoord0.xy, v.normal0.xyz, v.tangent0, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord3 = o3;
		o.texcoord4 = o4;
		o.texcoord5.xyz = o5;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_3c9604fc276b2e8f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_DETAIL_OVERLAY) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_ab200bddc1fb5b56_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_dcf5c16b949b8708_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(LIGHTPROBE_SH) && defined(_EMISSION) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_089e1c5ff63deb2c_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_fb1cb424e8f83748_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(LIGHTPROBE_SH) && defined(_EMISSION) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_3df710a535107e5b_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(LIGHTPROBE_SH) && defined(_DETAIL_OVERLAY)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_fa6ba7fc08e27017_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(LIGHTPROBE_SH) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_0902b105a254ac2d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_DETAIL_OVERLAY) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_5c9770512ac9d90b_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_1a0e7d6f340bd337_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_EMISSION) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_0c993fe6a4722281_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_1eb1b397f42335b4_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_EMISSION) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_83594e23d6f0a880_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_DETAIL_OVERLAY)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_7e56539f5ed132e8_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_d8d40b22326a7c66_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && !defined(_DETAIL_OVERLAY) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_d6ad5521cf9cdbce_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_94ae8b418213fab6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && defined(_EMISSION) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_fbd7028c983edf01_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_37d0c85155a605a9_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && defined(_EMISSION) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_d423018caf47d2c9_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(LIGHTPROBE_SH) && defined(_DETAIL_OVERLAY)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_40b79f54ae662f71_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
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
			Name "META"
			Tags { "LightMode"="Meta" }
			ZWrite On
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _EMISSION
			#pragma multi_compile _ _METALLICGLOSSMAP

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _EmissionMap;
SamplerState sampler_EmissionMap;

float4 _MainTex_ST;
float4 _DetailAlbedoMap_ST;
float _UVSec;
float4 unity_MetaVertexControl;
float4 _SpecColor;
float4 _Color;
float _Glossiness;
float unity_OneOverOutputBoost;
float unity_MaxOutputValue;
float4 unity_MetaFragmentControl;
float4 _EmissionColor;
float unity_UseLinearSpace;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
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
};

// vs e950fd051506cb1f: 3 retail keyword combination(s)
void vs_e950fd051506cb1f_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float2 v4 : TEXCOORD2,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = cmp(0 < v0.z);
  r0.z = r0.x ? 0.000100 : 0;
  r0.xy = v3.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  r0.xyz = unity_MetaVertexControl.xxx ? r0.xyz : v0.xyz;
  r0.w = cmp(0 < r0.z);
  r1.z = r0.w ? 0.000100 : 0;
  r1.xy = v4.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  r0.xyz = unity_MetaVertexControl.yyy ? r1.xyz : r0.xyz;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r0.xyzw;
  r0.x = cmp(_UVSec == 0.000000);
  r0.xy = r0.xx ? v2.xy : v3.xy;
  o1.zw = r0.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps ed6394f73ecd3cff: 2 retail keyword combination(s)
void ps_ed6394f73ecd3cff_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 1 + -_Glossiness;
  r0.x = r0.x * r0.x;
  r0.xyz = _SpecColor.xyz * r0.xxx;
  r0.xyz = float3(0.5,0.5,0.5) * r0.xyz;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r1.xyz;
  r0.w = 1 + -_SpecColor.x;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.xyz = log2(r0.xyz);
  r0.w = saturate(unity_OneOverOutputBoost);
  r0.xyz = r0.www * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = min(unity_MaxOutputValue.xxx, r0.xyz);
  r0.w = 1;
  r0.xyzw = unity_MetaFragmentControl.xxxx ? r0.xyzw : float4(0,0,0,0);
  o0.xyzw = unity_MetaFragmentControl.yyyy ? float4(0,0,0,1) : r0.xyzw;
  return;
}


// ps 4968babf236f40bd: 1 retail keyword combination(s)
void ps_4968babf236f40bd_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 1 + -_Glossiness;
  r0.x = r0.x * r0.x;
  r0.xyz = _SpecColor.xyz * r0.xxx;
  r0.xyz = float3(0.5,0.5,0.5) * r0.xyz;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = _Color.xyz * r1.xyz;
  r0.w = 1 + -_SpecColor.x;
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.xyz = log2(r0.xyz);
  r0.w = saturate(unity_OneOverOutputBoost);
  r0.xyz = r0.www * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = min(unity_MaxOutputValue.xxx, r0.xyz);
  r0.w = 1;
  r0.xyzw = unity_MetaFragmentControl.xxxx ? r0.xyzw : float4(0,0,0,0);
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, v1.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r1.xyz;
  r2.xyz = r1.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r2.xyz = r1.xyz * r2.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  r2.xyz = r2.xyz * r1.xyz;
  r1.w = cmp(0 != unity_UseLinearSpace);
  r1.xyz = r1.www ? r1.xyz : r2.xyz;
  r1.w = 1;
  o0.xyzw = unity_MetaFragmentControl.yyyy ? r1.xyzw : r0.xyzw;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		vs_e950fd051506cb1f_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1, v.texcoord2.xy, o0, o1);
		o.sv_position = o0;
		o.texcoord0 = o1;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_METALLICGLOSSMAP) || !defined(_EMISSION)
	{
		float4 o0 = 0;
		ps_ed6394f73ecd3cff_impl(i.sv_position, i.texcoord0, o0);
		r.t0 = o0;
	}
#elif defined(_EMISSION)
	{
		float4 o0 = 0;
		ps_4968babf236f40bd_impl(i.sv_position, i.texcoord0, o0);
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
			Name "DESIGN"
			Tags { "LightMode"="DesignMask" }
			ZWrite On
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt

#define cmp -


int _LayerMask;

struct appdata
{
	float4 position0 : POSITION0;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
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

// vs e1db43b18c53b97e: 1 retail keyword combination(s)
void vs_e1db43b18c53b97e_impl(
  float4 v0 : POSITION0,
  inout float4 o0 : SV_POSITION0)
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
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  return;
}


// ps b8119f37a334e8df: 1 retail keyword combination(s)
void ps_b8119f37a334e8df_impl(
  float4 v0 : SV_POSITION0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = cmp(asint(_LayerMask.xxxx) == int4(0,1,2,3));
  o0.xyzw = r0.xyzw ? float4(1,1,1,1) : 0;
  r0.xyzw = cmp(asint(_LayerMask.xxxx) == int4(4,5,6,7));
  o1.xyzw = r0.xyzw ? float4(1,1,1,1) : 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		vs_e1db43b18c53b97e_impl(v.position0, o0);
		o.sv_position = o0;
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
		ps_b8119f37a334e8df_impl(i.sv_position, o0, o1);
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
	CustomEditor "BTBuildingShaderGUI"
}
