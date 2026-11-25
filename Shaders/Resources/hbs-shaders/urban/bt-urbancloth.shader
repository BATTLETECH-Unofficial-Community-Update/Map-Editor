Shader "Urban/Urban Cloth"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		[Gamma] _Metallic ("Metallic", Range(0,1)) = 0
		_MetallicGlossMap ("Metallic", 2D) = "white" {}
		_Gradient ("Gradient", 2D) = "white" {}
		_BumpScale ("Scale", Float) = 1
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_Parallax ("Height Scale", Range(0.005,0.08)) = 0.02
		_ParallaxMap ("Height Map", 2D) = "black" {}
		_OcclusionStrength ("Strength", Range(0,1)) = 1
		_OcclusionMap ("Occlusion", 2D) = "white" {}
		_EmissionColor ("Color", Color) = (0,0,0,1)
		_EmissionMap ("Emission", 2D) = "white" {}
		_DetailMask ("Detail Mask", 2D) = "white" {}
		_DetailAlbedoMap ("Detail Albedo x2", 2D) = "grey" {}
		_DetailNormalMapScale ("Scale", Float) = 1
		_DetailNormalMap ("Normal Map", 2D) = "bump" {}
		_BlendMainTex ("Blend Albedo", 2D) = "white" {}
		_BlendMetallicGlossMap ("Blend Metallic", 2D) = "bump" {}
		_BlendNormalMap ("Blend Normal Map", 2D) = "bump" {}
		_BlendOcclusionMap ("Blend Occlusion", 2D) = "white" {}
		[MaterialToggle(_VERTEX_BLEND)] _UseBlend ("__blend", Float) = 0
		[Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0
		[Enum(UV0,0,UV1,1)] _UVSecMask ("UV Set for detail mask texture", Float) = 0
		[HideInInspector] _Mode ("__mode", Float) = 0
		[HideInInspector] _SrcBlend ("__src", Float) = 1
		[HideInInspector] _DstBlend ("__dst", Float) = 0
		[HideInInspector] _ZWrite ("__zw", Float) = 1
		[MaterialToggle(_OVERLAY_DOWNMOSS)] _Downmoss ("___moss", Float) = 0
		[MaterialToggle(_OVERLAY_UPMOSS)] _Upmoss ("___moss", Float) = 0
		_MatID ("Material Type", Float) = 1
		_PaintScheme ("Paint Scheme", 2D) = "black" {}
		_PaintColor1 ("Color 1", Color) = (1,1,1,1)
		_PaintColor2 ("Color 2", Color) = (1,1,1,1)
		_PaintColor3 ("Color 3", Color) = (1,1,1,1)
		_PaintSmoothness1 ("P1S", Range(0,1)) = 0.5
		_PaintSmoothness2 ("P2S", Range(0,1)) = 0.5
		_PaintSmoothness3 ("P3S", Range(0,1)) = 0.5
		_PaintMetal1 ("P1M", Range(0,1)) = 0
		_PaintMetal2 ("P2M", Range(0,1)) = 0
		_PaintMetal3 ("P3M", Range(0,1)) = 0
		_PaintWear ("Paint Wear", Range(0,1)) = 0.5
		[HideInInspector] _SelectedID ("selected", Float) = 1
		[HideInInspector] _SelectedIntensity ("highlight intensity", Float) = 0
		[HideInInspector] _StippleAlpha ("Stipple Alpha", Float) = 1
		[MaterialToggle(_RUBBLE)] _Rubble ("___rubble", Float) = 0
		[MaterialToggle(_BLINKING)] _Blinking ("___blinking", Float) = 0
		[MaterialToggle(_TERRAIN_BLEND)] _TerrainBlend ("_____", Float) = 0
		_BlinkingProps ("BlinkingProperties", Vector) = (0,0,0,0)
		_BlinkingTex ("Blinking Texture", 2D) = "black" {}
		[Enum(Normal,0,Counter,1,Night,2)] _EmissiveMode ("Emissive Mode", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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
			#pragma multi_compile _ INSTANCING_ON
			#pragma multi_compile _ LIGHTPROBE_SH
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _FOG_3D

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _OcclusionMap;
SamplerState sampler_OcclusionMap;
Texture2D _FogIntegrationTex;
SamplerState sampler_FogIntegrationTex;
Texture3D _FogIntegration3D;
SamplerState sampler_FogIntegration3D;

#ifdef HBS_HARNESS_RETAIL_SLOTS
#undef CBUFFER_START
#define CBUFFER_START(name) cbuffer name : register(HBS_SLOT_##name) {
#if !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#define HBS_SLOT_UnityInstancing_PerDraw2 b5
#elif !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#define HBS_SLOT_UnityInstancing_PerDraw2 b5
#else
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#endif
#endif
CBUFFER_START(UnityDrawCallInfo)
	int unity_BaseInstanceID;
CBUFFER_END
CBUFFER_START(UnityInstancing_PerDraw0)
	struct
	{
		float4x4 unity_ObjectToWorldArray;
		float4x4 unity_WorldToObjectArray;
	} unity_Builtins0Array[500];
CBUFFER_END
CBUFFER_START(UnityInstancing_PerDraw2)
	struct
	{
		float4 unity_SHArArray;
		float4 unity_SHAgArray;
		float4 unity_SHAbArray;
		float4 unity_SHBrArray;
		float4 unity_SHBgArray;
		float4 unity_SHBbArray;
		float4 unity_SHCArray;
	} unity_Builtins2Array[500];
CBUFFER_END
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
float4 _ScaleOffset;
float3 _VolumeSize;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	uint sv_instanceid0 : SV_InstanceID;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};

#if !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
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
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
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
#elif defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
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
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
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
#elif !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
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
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
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
#elif defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
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
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
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

// vs 5a3a748f6139fc37: 2 retail keyword combination(s)
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


// vs a1a88f5059d212ed: 2 retail keyword combination(s)
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


// vs 3c5a3c43901031ef: 2 retail keyword combination(s)
void vs_3c5a3c43901031ef_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  uint v4 : SV_InstanceID0,
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
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v4.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v4.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r1.xyzw = r1.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r1.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r1.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r0.yzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r0.yzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r0.yzw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.yzw;
  o7.xyz = r0.yzw;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r1.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0]));
  r1.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1]));
  r1.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2]));
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  o5.xyz = r1.xyz * r0.xxx;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  return;
}


// vs f8976dae1bf90889: 2 retail keyword combination(s)
void vs_f8976dae1bf90889_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  uint v4 : SV_InstanceID0,
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
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v4.x, instance_id
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v4.x + asint(unity_BaseInstanceID);
  r0.y = (uint)r0.x << 3;
  r0.x = (int)r0.x * 7;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r1.xyzw = r1.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r1.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r1.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r1.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r1.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r1.xyz;
  r1.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xyz;
  o7.xyz = r1.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r1.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][0]));
  r1.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][1]));
  r1.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][2]));
  r0.y = dot(r1.xyz, r1.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = r1.xyz * r0.yyy;
  o5.xyz = r0.yzw;
  o5.w = 0;
  r1.x = r0.z * r0.z;
  r1.x = r0.y * r0.y + -r1.x;
  r2.xyzw = r0.yzww * r0.zwwy;
  r3.x = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBrArray.xyzw, r2.xyzw);
  r3.y = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBgArray.xyzw, r2.xyzw);
  r3.z = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBbArray.xyzw, r2.xyzw);
  o6.xyz = unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHCArray.xyz * r1.xxx + r3.xyz;
  o6.w = 0;
  o8.zw = float2(0,0);
  o9.xyzw = float4(0,0,0,0);
  return;
}


// vs f540b2c00c7085d1: 2 retail keyword combination(s)
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


// vs cbf60bce4b65a03a: 2 retail keyword combination(s)
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


// vs ce0df3ae8577f90f: 2 retail keyword combination(s)
void vs_ce0df3ae8577f90f_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  uint v4 : SV_InstanceID0,
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
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v4.x, instance_id
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v4.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
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
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r0.yzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r0.yzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r0.yzw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.yzw;
  o8.xyz = r0.yzw;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r3.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0]));
  r3.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1]));
  r3.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2]));
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = rsqrt(r0.x);
  o5.xyz = r3.xyz * r0.xxx;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o7.w = r2.w;
  o7.xy = r0.xw + r0.zz;
  o9.zw = float2(0,0);
  o10.xyzw = float4(0,0,0,0);
  return;
}


// vs 18d2a874533b5518: 2 retail keyword combination(s)
void vs_18d2a874533b5518_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  uint v4 : SV_InstanceID0,
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
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v4.x, instance_id
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v4.x + asint(unity_BaseInstanceID);
  r0.y = (uint)r0.x << 3;
  r0.x = (int)r0.x * 7;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
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
  r3.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r3.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r3.xyz;
  r3.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r3.xyz;
  r3.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r3.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r3.xyz;
  o8.xyz = r3.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r3.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][0]));
  r3.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][1]));
  r3.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][2]));
  r0.y = dot(r3.xyz, r3.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = r3.xyz * r0.yyy;
  o5.xyz = r0.yzw;
  o5.w = 0;
  r2.z = r0.z * r0.z;
  r2.z = r0.y * r0.y + -r2.z;
  r3.xyzw = r0.yzww * r0.zwwy;
  r4.x = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBrArray.xyzw, r3.xyzw);
  r4.y = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBgArray.xyzw, r3.xyzw);
  r4.z = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBbArray.xyzw, r3.xyzw);
  o6.xyz = unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHCArray.xyz * r2.zzz + r4.xyz;
  o6.w = 0;
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o7.w = r2.w;
  o7.xy = r0.xw + r0.zz;
  o9.zw = float2(0,0);
  o10.xyzw = float4(0,0,0,0);
  return;
}


// ps d62c84a79ed13cc9: 4 retail keyword combination(s)
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


// ps 4a2273fbed4e78e2: 2 retail keyword combination(s)
void ps_4a2273fbed4e78e2_impl(
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
    r6.x = dot(unity_Builtins2Array[0u].unity_SHArArray.xyzw, r2.xyzw);
    r6.y = dot(unity_Builtins2Array[0u].unity_SHAgArray.xyzw, r2.xyzw);
    r6.z = dot(unity_Builtins2Array[0u].unity_SHAbArray.xyzw, r2.xyzw);
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


// ps febdecc2a8c49a1d: 2 retail keyword combination(s)
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


// ps 857e7ca47c0c45d2: 1 retail keyword combination(s)
void ps_857e7ca47c0c45d2_impl(
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
    r6.x = dot(unity_Builtins2Array[0u].unity_SHArArray.xyzw, r2.xyzw);
    r6.y = dot(unity_Builtins2Array[0u].unity_SHAgArray.xyzw, r2.xyzw);
    r6.z = dot(unity_Builtins2Array[0u].unity_SHAbArray.xyzw, r2.xyzw);
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


// ps f746b71ae7ebda9a: 2 retail keyword combination(s)
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


// ps adf95d32f8152416: 1 retail keyword combination(s)
void ps_adf95d32f8152416_impl(
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
    r6.x = dot(unity_Builtins2Array[0u].unity_SHArArray.xyzw, r2.xyzw);
    r6.y = dot(unity_Builtins2Array[0u].unity_SHAgArray.xyzw, r2.xyzw);
    r6.z = dot(unity_Builtins2Array[0u].unity_SHAbArray.xyzw, r2.xyzw);
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


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
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
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
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
#elif defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
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
		vs_3c5a3c43901031ef_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
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
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
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
		vs_f8976dae1bf90889_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
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
#elif !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
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
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
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
#elif defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
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
		vs_ce0df3ae8577f90f_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
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
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)
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
		vs_18d2a874533b5518_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
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
#if !defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		ps_d62c84a79ed13cc9_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		ps_a28d7abef68387d2_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		ps_4a2273fbed4e78e2_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif (!defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D)) && ((!defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)))
	{
		float4 o0 = 0;
		ps_febdecc2a8c49a1d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D)) && ((!defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)))
	{
		float4 o0 = 0;
		ps_fa956d7d496a5514_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D)) && ((!defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)))
	{
		float4 o0 = 0;
		ps_857e7ca47c0c45d2_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif (!defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D)) && ((!defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)))
	{
		float4 o0 = 0;
		ps_f746b71ae7ebda9a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D)) && ((!defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)))
	{
		float4 o0 = 0;
		ps_99da9915dcb6abd4_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
		r.t0 = o0;
	}
#elif (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D)) && ((!defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_BT_FORWARD_FOG)))
	{
		float4 o0 = 0;
		ps_adf95d32f8152416_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord7, i.texcoord8, i.texcoord9, i.texcoord10, o0);
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
			#pragma multi_compile _ INSTANCING_ON
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile _ SHADOWS_CUBE
			#pragma multi_compile _ SHADOWS_DEPTH
			#pragma multi_compile _ _STIPPLE_FADE

#define cmp -

Texture2D _DitherMaskLOD2D;
SamplerState sampler_DitherMaskLOD2D;
Texture3D _DitherMaskLOD;
SamplerState sampler_DitherMaskLOD;

#ifdef HBS_HARNESS_RETAIL_SLOTS
#undef CBUFFER_START
#define CBUFFER_START(name) cbuffer name : register(HBS_SLOT_##name) {
#if !defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#elif !defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#elif !defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#elif !defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b4
#define HBS_SLOT_UnityInstancing_PerDraw0 b5
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b4
#define HBS_SLOT_UnityInstancing_PerDraw0 b5
#elif defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)
#define HBS_SLOT_UnityDrawCallInfo b4
#define HBS_SLOT_UnityInstancing_PerDraw0 b5
#elif defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)
#define HBS_SLOT_UnityDrawCallInfo b4
#define HBS_SLOT_UnityInstancing_PerDraw0 b5
#else
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#endif
#endif
CBUFFER_START(UnityDrawCallInfo)
	int unity_BaseInstanceID;
CBUFFER_END
#if defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE)
CBUFFER_START(UnityInstancing_PerDraw0)
	struct
	{
		float4x4 unity_ObjectToWorldArray;
		float4x4 unity_WorldToObjectArray;
	} unity_Builtins0Array[500];
CBUFFER_END
#elif defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE)
CBUFFER_START(UnityInstancing_PerDraw0)
	struct
	{
		float4x4 unity_ObjectToWorldArray;
		float4x4 unity_WorldToObjectArray;
		float2 unity_LODFadeArray;
	} unity_Builtins0Array[455];
CBUFFER_END
#endif
float4 _MainTex_ST;
float _StippleAlpha;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	uint sv_instanceid0 : SV_InstanceID;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#elif !defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#elif !defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord1 : TEXCOORD1;
};
#elif !defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord1 : TEXCOORD1;
};
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord1 : TEXCOORD1;
};
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord1 : TEXCOORD1;
};
#elif defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord1 : TEXCOORD1;
};
#elif defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)
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
#if !defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
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


#endif
// vs d4c082007ab5ea9a: 1 retail keyword combination(s)
#if !defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
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


#endif
// vs 959bd274d6c82aa1: 1 retail keyword combination(s)
#if defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
void vs_959bd274d6c82aa1_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  uint v3 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v3.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v3.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) * v0.wwww + r1.xyzw;
  r0.y = cmp(unity_LightShadowBias.z != 0.000000);
  [branch] if (r0.y != 0) {
    r2.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0]));
    r2.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1]));
    r2.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2]));
    r0.x = dot(r2.xyz, r2.xyz);
    r0.x = rsqrt(r0.x);
    r0.xyz = r2.xyz * r0.xxx;
    r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
    r0.w = dot(r2.xyz, r2.xyz);
    r0.w = rsqrt(r0.w);
    r2.xyz = r2.xyz * r0.www;
    r0.w = dot(r0.xyz, r2.xyz);
    r0.w = -r0.w * r0.w + 1;
    r0.w = sqrt(r0.w);
    r0.w = unity_LightShadowBias.z * r0.w;
    r1.xyz = -r0.xyz * r0.www + r1.xyz;
  }
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = unity_LightShadowBias.x / r0.w;
  r1.x = min(0, r1.x);
  r1.x = max(-1, r1.x);
  r0.z = r1.x + r0.z;
  r1.x = min(r0.z, r0.w);
  r1.x = r1.x + -r0.z;
  o0.z = unity_LightShadowBias.y * r1.x + r0.z;
  o0.xyw = r0.xyw;
  return;
}


#endif
// vs 1fdab3a3170dc948: 1 retail keyword combination(s)
#if defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
void vs_1fdab3a3170dc948_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  uint v3 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v3.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v3.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) * v0.wwww + r1.xyzw;
  r0.y = cmp(unity_LightShadowBias.z != 0.000000);
  [branch] if (r0.y != 0) {
    r2.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0]));
    r2.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1]));
    r2.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2]));
    r0.x = dot(r2.xyz, r2.xyz);
    r0.x = rsqrt(r0.x);
    r0.xyz = r2.xyz * r0.xxx;
    r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
    r0.w = dot(r2.xyz, r2.xyz);
    r0.w = rsqrt(r0.w);
    r2.xyz = r2.xyz * r0.www;
    r0.w = dot(r0.xyz, r2.xyz);
    r0.w = -r0.w * r0.w + 1;
    r0.w = sqrt(r0.w);
    r0.w = unity_LightShadowBias.z * r0.w;
    r1.xyz = -r0.xyz * r0.www + r1.xyz;
  }
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = min(r0.z, r0.w);
  r1.x = r1.x + -r0.z;
  o0.z = unity_LightShadowBias.y * r1.x + r0.z;
  o0.xyw = r0.xyw;
  return;
}


#endif
// vs 4faced0784cff9d7: 3 retail keyword combination(s)
#if !defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
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


#endif
// vs 38f094d13644ad58: 3 retail keyword combination(s)
#if !defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
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


#endif
// vs 759be9d01547c582: 1 retail keyword combination(s)
#if defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
void vs_759be9d01547c582_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  uint v3 : SV_InstanceID0,
  inout float2 o0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v3.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v3.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) * v0.wwww + r1.xyzw;
  r0.y = cmp(unity_LightShadowBias.z != 0.000000);
  [branch] if (r0.y != 0) {
    r2.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0]));
    r2.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1]));
    r2.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2]));
    r0.x = dot(r2.xyz, r2.xyz);
    r0.x = rsqrt(r0.x);
    r0.xyz = r2.xyz * r0.xxx;
    r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
    r0.w = dot(r2.xyz, r2.xyz);
    r0.w = rsqrt(r0.w);
    r2.xyz = r2.xyz * r0.www;
    r0.w = dot(r0.xyz, r2.xyz);
    r0.w = -r0.w * r0.w + 1;
    r0.w = sqrt(r0.w);
    r0.w = unity_LightShadowBias.z * r0.w;
    r1.xyz = -r0.xyz * r0.www + r1.xyz;
  }
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = unity_LightShadowBias.x / r0.w;
  r1.x = min(0, r1.x);
  r1.x = max(-1, r1.x);
  r0.z = r1.x + r0.z;
  r1.x = min(r0.z, r0.w);
  r1.x = r1.x + -r0.z;
  o1.z = unity_LightShadowBias.y * r1.x + r0.z;
  o0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xyw = r0.xyw;
  return;
}


#endif
// vs 01781992ccca5cb7: 1 retail keyword combination(s)
#if defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
void vs_01781992ccca5cb7_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  uint v3 : SV_InstanceID0,
  inout float2 o0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v3.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v3.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) * v0.wwww + r1.xyzw;
  r0.y = cmp(unity_LightShadowBias.z != 0.000000);
  [branch] if (r0.y != 0) {
    r2.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0]));
    r2.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1]));
    r2.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2]));
    r0.x = dot(r2.xyz, r2.xyz);
    r0.x = rsqrt(r0.x);
    r0.xyz = r2.xyz * r0.xxx;
    r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
    r0.w = dot(r2.xyz, r2.xyz);
    r0.w = rsqrt(r0.w);
    r2.xyz = r2.xyz * r0.www;
    r0.w = dot(r0.xyz, r2.xyz);
    r0.w = -r0.w * r0.w + 1;
    r0.w = sqrt(r0.w);
    r0.w = unity_LightShadowBias.z * r0.w;
    r1.xyz = -r0.xyz * r0.www + r1.xyz;
  }
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = min(r0.z, r0.w);
  r1.x = r1.x + -r0.z;
  o1.z = unity_LightShadowBias.y * r1.x + r0.z;
  o0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xyw = r0.xyw;
  return;
}


#endif
// vs 5ffaa5f30fb79baa: 2 retail keyword combination(s)
#if defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)
void vs_5ffaa5f30fb79baa_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  uint v3 : SV_InstanceID0,
  inout float2 o0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v3.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v3.x + asint(unity_BaseInstanceID);
  r0.x = (int)r0.x * 9;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[3][3]) * v0.wwww + r1.xyzw;
  r0.y = cmp(unity_LightShadowBias.z != 0.000000);
  [branch] if (r0.y != 0) {
    r2.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[2][0]));
    r2.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[2][1]));
    r2.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[2][2]));
    r0.x = dot(r2.xyz, r2.xyz);
    r0.x = rsqrt(r0.x);
    r0.xyz = r2.xyz * r0.xxx;
    r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
    r0.w = dot(r2.xyz, r2.xyz);
    r0.w = rsqrt(r0.w);
    r2.xyz = r2.xyz * r0.www;
    r0.w = dot(r0.xyz, r2.xyz);
    r0.w = -r0.w * r0.w + 1;
    r0.w = sqrt(r0.w);
    r0.w = unity_LightShadowBias.z * r0.w;
    r1.xyz = -r0.xyz * r0.www + r1.xyz;
  }
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = unity_LightShadowBias.x / r0.w;
  r1.x = min(0, r1.x);
  r1.x = max(-1, r1.x);
  r0.z = r1.x + r0.z;
  r1.x = min(r0.z, r0.w);
  r1.x = r1.x + -r0.z;
  o1.z = unity_LightShadowBias.y * r1.x + r0.z;
  o0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xyw = r0.xyw;
  return;
}


#endif
// vs 03b61989ac02d345: 2 retail keyword combination(s)
#if defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)
void vs_03b61989ac02d345_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  uint v3 : SV_InstanceID0,
  inout float2 o0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v3.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v3.x + asint(unity_BaseInstanceID);
  r0.x = (int)r0.x * 9;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_ObjectToWorldArray[3][3]) * v0.wwww + r1.xyzw;
  r0.y = cmp(unity_LightShadowBias.z != 0.000000);
  [branch] if (r0.y != 0) {
    r2.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[2][0]));
    r2.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[2][1]));
    r2.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 9u].unity_WorldToObjectArray[2][2]));
    r0.x = dot(r2.xyz, r2.xyz);
    r0.x = rsqrt(r0.x);
    r0.xyz = r2.xyz * r0.xxx;
    r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
    r0.w = dot(r2.xyz, r2.xyz);
    r0.w = rsqrt(r0.w);
    r2.xyz = r2.xyz * r0.www;
    r0.w = dot(r0.xyz, r2.xyz);
    r0.w = -r0.w * r0.w + 1;
    r0.w = sqrt(r0.w);
    r0.w = unity_LightShadowBias.z * r0.w;
    r1.xyz = -r0.xyz * r0.www + r1.xyz;
  }
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r1.x = min(r0.z, r0.w);
  r1.x = r1.x + -r0.z;
  o1.z = unity_LightShadowBias.y * r1.x + r0.z;
  o0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xyw = r0.xyw;
  return;
}


#endif
// ps 5b3349ebfd951ea3: 4 retail keyword combination(s)
#if !defined(LOD_FADE_CROSSFADE) && !defined(_STIPPLE_FADE)
void ps_5b3349ebfd951ea3_impl(
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = float4(0,0,0,0);
  return;
}


#endif
// ps 27dd6cf20fd779b0: 4 retail keyword combination(s)
#if !defined(LOD_FADE_CROSSFADE) && defined(_STIPPLE_FADE)
void ps_27dd6cf20fd779b0_impl(
  float2 v0 : TEXCOORD1,
  float4 v1 : SV_Position0,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

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


#endif
// ps 3d212729b7c84c6c: 4 retail keyword combination(s)
#if !defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE)
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


#endif
// ps 3d212729b7c84c6c: 4 retail keyword combination(s)
#if defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE)
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
  r0.z = r0.y * 0.0625 + (unity_Builtins0Array[0u].unity_LODFadeArray.x < 0 ? unity_Builtins0Array[0u].unity_LODFadeArray.y + 0.9375 : unity_Builtins0Array[0u].unity_LODFadeArray.y);
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


#endif
v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		vs_aa4b0478faaa884a_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0);
		o.sv_position = o0;
	}
#elif !defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		vs_d4c082007ab5ea9a_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0);
		o.sv_position = o0;
	}
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		vs_959bd274d6c82aa1_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.sv_instanceid0, o0);
		o.sv_position = o0;
	}
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		vs_1fdab3a3170dc948_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.sv_instanceid0, o0);
		o.sv_position = o0;
	}
#elif !defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_4faced0784cff9d7_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0, o1);
		o.texcoord1.xy = o0;
		o.sv_position = o1;
	}
#elif !defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_38f094d13644ad58_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0, o1);
		o.texcoord1.xy = o0;
		o.sv_position = o1;
	}
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_759be9d01547c582_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.sv_instanceid0, o0, o1);
		o.texcoord1.xy = o0;
		o.sv_position = o1;
	}
#elif defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_01781992ccca5cb7_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.sv_instanceid0, o0, o1);
		o.texcoord1.xy = o0;
		o.sv_position = o1;
	}
#elif defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_5ffaa5f30fb79baa_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.sv_instanceid0, o0, o1);
		o.texcoord1.xy = o0;
		o.sv_position = o1;
	}
#elif defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_03b61989ac02d345_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.sv_instanceid0, o0, o1);
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
#if !defined(LOD_FADE_CROSSFADE) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		ps_5b3349ebfd951ea3_impl(o0);
		r.t0 = o0;
	}
#elif (!defined(LOD_FADE_CROSSFADE) && defined(_STIPPLE_FADE)) && ((!defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)) || (!defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)) || (defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)))
	{
		float4 o0 = 0;
		ps_27dd6cf20fd779b0_impl(i.texcoord1.xy, i.sv_position, o0);
		r.t0 = o0;
	}
#elif (defined(LOD_FADE_CROSSFADE)) && ((!defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)) || (!defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) || !defined(INSTANCING_ON) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && !defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && defined(SHADOWS_DEPTH)) || (defined(INSTANCING_ON) && defined(LOD_FADE_CROSSFADE) && !defined(SHADOWS_DEPTH)))
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
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ INSTANCING_ON
			#pragma multi_compile _ LIGHTPROBE_SH
			#pragma multi_compile _ UNITY_HDR_ON
			#pragma multi_compile _ _STIPPLE_FADE

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _DitherMaskLOD2D;
SamplerState sampler_DitherMaskLOD2D;
Texture2D _OcclusionMap;
SamplerState sampler_OcclusionMap;

#ifdef HBS_HARNESS_RETAIL_SLOTS
#undef CBUFFER_START
#define CBUFFER_START(name) cbuffer name : register(HBS_SLOT_##name) {
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#define HBS_SLOT_UnityInstancing_PerDraw2 b5
#elif defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b4
#define HBS_SLOT_UnityInstancing_PerDraw0 b5
#define HBS_SLOT_UnityInstancing_PerDraw2 b6
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b3
#define HBS_SLOT_UnityInstancing_PerDraw0 b4
#define HBS_SLOT_UnityInstancing_PerDraw2 b5
#elif defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)
#define HBS_SLOT_UnityDrawCallInfo b4
#define HBS_SLOT_UnityInstancing_PerDraw0 b5
#define HBS_SLOT_UnityInstancing_PerDraw2 b6
#else
#define HBS_SLOT_UnityDrawCallInfo b11
#define HBS_SLOT_UnityInstancing_PerDraw0 b12
#define HBS_SLOT_UnityInstancing_PerDraw2 b10
#endif
#endif
CBUFFER_START(UnityDrawCallInfo)
	int unity_BaseInstanceID;
CBUFFER_END
CBUFFER_START(UnityInstancing_PerDraw0)
	struct
	{
		float4x4 unity_ObjectToWorldArray;
		float4x4 unity_WorldToObjectArray;
	} unity_Builtins0Array[500];
CBUFFER_END
#if defined(INSTANCING_ON) && defined(LIGHTPROBE_SH)
CBUFFER_START(UnityInstancing_PerDraw2)
	struct
	{
		float4 unity_SHArArray;
		float4 unity_SHAgArray;
		float4 unity_SHAbArray;
		float4 unity_SHBrArray;
		float4 unity_SHBgArray;
		float4 unity_SHBbArray;
		float4 unity_SHCArray;
	} unity_Builtins2Array[500];
CBUFFER_END
#elif defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON)
CBUFFER_START(UnityInstancing_PerDraw2)
	struct
	{
		float4 unity_DynamicLightmapSTArray;
	} unity_Builtins2Array[500];
CBUFFER_END
#endif
float4 _MainTex_ST;
float4 _DetailAlbedoMap_ST;
float4 _DetailMask_ST;
float _UVSec;
float _UVSecMask;
float4 _Color;
float _Metallic;
float _Glossiness;
float _OcclusionStrength;
float4 unity_DynamicLightmap_HDR;
float _StippleAlpha;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	uint sv_instanceid0 : SV_InstanceID;
	float4 tangent0 : TANGENT0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};

#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
};
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
};
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
};
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
	nointerpolation uint sv_instanceid0 : SV_InstanceID;
};
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
	nointerpolation uint sv_instanceid0 : SV_InstanceID;
};
#elif defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
	nointerpolation uint sv_instanceid0 : SV_InstanceID;
};
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
};
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
};
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
};
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	nointerpolation uint sv_instanceid0 : SV_InstanceID;
};
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	nointerpolation uint sv_instanceid0 : SV_InstanceID;
};
#elif defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	nointerpolation uint sv_instanceid0 : SV_InstanceID;
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

// vs b959b7505b9ab0c5: 2 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
void vs_b959b7505b9ab0c5_impl(
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
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8)
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
  return;
}


#endif
// vs bbd96082d5e86825: 2 retail keyword combination(s)
#if !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
void vs_bbd96082d5e86825_impl(
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
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8)
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
  return;
}


#endif
// vs b22b4542831785e6: 2 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)
void vs_b22b4542831785e6_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float4 v4 : TEXCOORD1,
  float2 v5 : TEXCOORD2,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8)
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
  o6.zw = v5.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o6.xy = float2(0,0);
  o8.zw = float2(0,0);
  return;
}


#endif
// vs 41bb200fc40cf21c: 2 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
void vs_41bb200fc40cf21c_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  uint v4 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8,
  inout uint o9 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v4.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v4.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r1.xyzw = r1.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r1.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r1.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r0.yzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r0.yzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r0.yzw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.yzw;
  o7.xyz = r0.yzw;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r1.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0]));
  r1.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1]));
  r1.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2]));
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  o5.xyz = r1.xyz * r0.xxx;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  o8.zw = float2(0,0);
  o9.x = v4.x;
  return;
}


#endif
// vs a3d634a40fc73bb2: 2 retail keyword combination(s)
#if defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
void vs_a3d634a40fc73bb2_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  uint v4 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8,
  inout uint o9 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v4.x, instance_id
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v4.x + asint(unity_BaseInstanceID);
  r0.y = (uint)r0.x << 3;
  r0.x = (int)r0.x * 7;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r1.xyzw = r1.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r1.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r1.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r1.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r1.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r1.xyz;
  r1.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xyz;
  o7.xyz = r1.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r1.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][0]));
  r1.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][1]));
  r1.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][2]));
  r0.y = dot(r1.xyz, r1.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = r1.xyz * r0.yyy;
  o5.xyz = r0.yzw;
  o5.w = 0;
  r1.x = r0.z * r0.z;
  r1.x = r0.y * r0.y + -r1.x;
  r2.xyzw = r0.yzww * r0.zwwy;
  r3.x = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBrArray.xyzw, r2.xyzw);
  r3.y = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBgArray.xyzw, r2.xyzw);
  r3.z = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBbArray.xyzw, r2.xyzw);
  o6.xyz = unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHCArray.xyz * r1.xxx + r3.xyz;
  o6.w = 0;
  o8.zw = float2(0,0);
  o9.x = v4.x;
  return;
}


#endif
// vs 2ded13253a0f9e0c: 2 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)
void vs_2ded13253a0f9e0c_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float4 v4 : TEXCOORD1,
  float2 v5 : TEXCOORD2,
  uint v6 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8,
  inout uint o9 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v6.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v6.x + asint(unity_BaseInstanceID);
  r0.y = (uint)r0.x << 3;
  o6.zw = v5.xy * unity_Builtins2Array[(uint)(r0.x) / 1u].unity_DynamicLightmapSTArray.xy + unity_Builtins2Array[(uint)(r0.x) / 1u].unity_DynamicLightmapSTArray.zw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r1.xyzw = r1.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r1.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r1.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r0.xzw;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r0.xzw;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r0.xzw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xzw;
  o7.xyz = r0.xzw;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1]) * v3.yyy;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0]) * v3.xxx + r0.xzw;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2]) * v3.zzz + r0.xzw;
  r1.x = dot(r0.xzw, r0.xzw);
  r1.x = rsqrt(r1.x);
  r0.xzw = r1.xxx * r0.xzw;
  o3.xyz = r0.xzw;
  o3.w = 0;
  r1.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][0]));
  r1.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][1]));
  r1.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][2]));
  r0.y = dot(r1.xyz, r1.xyz);
  r0.y = rsqrt(r0.y);
  r1.xyz = r1.xyz * r0.yyy;
  r2.xyz = r1.zxy * r0.zwx;
  r0.xyz = r1.yzx * r0.wxz + -r2.xyz;
  o5.xyz = r1.xyz;
  r0.w = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r0.xyz * r0.www;
  o4.w = 0;
  o5.w = 0;
  o6.xy = float2(0,0);
  o8.zw = float2(0,0);
  o9.x = v6.x;
  return;
}


#endif
// vs 5a1d2ec0bfb8e3a6: 2 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
void vs_5a1d2ec0bfb8e3a6_impl(
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
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9)
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
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r1.xyzw = r1.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r1.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r1.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xyz;
  o7.xyz = r1.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r1.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  o5.xyz = r1.xyz * r1.www;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  o8.zw = float2(0,0);
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o9.zw = r0.zw;
  r0.xy = r1.xw + r1.zz;
  r0.xy = _ScreenParams.xy * r0.xy;
  o9.xy = float2(0.25,0.25) * r0.xy;
  return;
}


#endif
// vs 9520798156e7ffce: 2 retail keyword combination(s)
#if !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
void vs_9520798156e7ffce_impl(
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
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9)
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
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r0.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r1.xyzw = r1.xyzw ? v2.xyxy : v3.xyxy;
  o1.zw = r1.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r1.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xyz;
  o7.xyz = r1.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r1.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  r1.xyz = r1.xyz * r1.www;
  o5.xyz = r1.xyz;
  o5.w = 0;
  r1.w = r1.y * r1.y;
  r1.w = r1.x * r1.x + -r1.w;
  r2.xyzw = r1.xyzz * r1.yzzx;
  r1.x = dot(unity_SHBr.xyzw, r2.xyzw);
  r1.y = dot(unity_SHBg.xyzw, r2.xyzw);
  r1.z = dot(unity_SHBb.xyzw, r2.xyzw);
  o6.xyz = unity_SHC.xyz * r1.www + r1.xyz;
  o6.w = 0;
  o8.zw = float2(0,0);
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o9.zw = r0.zw;
  r0.xy = r1.xw + r1.zz;
  r0.xy = _ScreenParams.xy * r0.xy;
  o9.xy = float2(0.25,0.25) * r0.xy;
  return;
}


#endif
// vs 6b66ed07e08af778: 2 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)
void vs_6b66ed07e08af778_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float4 v4 : TEXCOORD1,
  float2 v5 : TEXCOORD2,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9)
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
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r0.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = cmp(float4(_UVSecMask, _UVSecMask, _UVSec, _UVSec) == float4(0,0,0,0));
  r1.xyzw = r1.xyzw ? v2.xyxy : v4.xyxy;
  o1.zw = r1.zw * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
  o8.xy = r1.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xyz;
  o7.xyz = r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  r1.xyz = r1.xyz * r1.www;
  o3.xyz = r1.xyz;
  o3.w = 0;
  r2.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r2.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r2.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r1.w = dot(r2.xyz, r2.xyz);
  r1.w = rsqrt(r1.w);
  r2.xyz = r2.xyz * r1.www;
  r3.xyz = r2.zxy * r1.yzx;
  r1.xyz = r2.yzx * r1.zxy + -r3.xyz;
  o5.xyz = r2.xyz;
  r1.w = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r1.xyz * r1.www;
  o4.w = 0;
  o5.w = 0;
  o6.zw = v5.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o6.xy = float2(0,0);
  o8.zw = float2(0,0);
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o9.zw = r0.zw;
  r0.xy = r1.xw + r1.zz;
  r0.xy = _ScreenParams.xy * r0.xy;
  o9.xy = float2(0.25,0.25) * r0.xy;
  return;
}


#endif
// vs 525554b717947bd0: 2 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
void vs_525554b717947bd0_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  uint v4 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout uint o10 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v4.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v4.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
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
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r0.yzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r0.yzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r0.yzw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.yzw;
  o7.xyz = r0.yzw;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r2.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0]));
  r2.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1]));
  r2.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2]));
  r0.x = dot(r2.xyz, r2.xyz);
  r0.x = rsqrt(r0.x);
  o5.xyz = r2.xyz * r0.xxx;
  o5.w = 0;
  o6.xyzw = float4(0,0,0,0);
  o8.zw = float2(0,0);
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  r0.xy = r0.xw + r0.zz;
  r0.xy = _ScreenParams.xy * r0.xy;
  o9.xy = float2(0.25,0.25) * r0.xy;
  o10.x = v4.x;
  return;
}


#endif
// vs be790d5f340e0b36: 2 retail keyword combination(s)
#if defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
void vs_be790d5f340e0b36_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  uint v4 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout uint o10 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v4.x, instance_id
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v4.x + asint(unity_BaseInstanceID);
  r0.y = (uint)r0.x << 3;
  r0.x = (int)r0.x * 7;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
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
  r2.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r2.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r2.xyz;
  r2.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r2.xyz;
  r2.xyz = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r2.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r2.xyz;
  o7.xyz = r2.xyz;
  o3.xyzw = float4(0,0,0,0);
  o4.xyzw = float4(0,0,0,0);
  r2.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][0]));
  r2.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][1]));
  r2.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][2]));
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = r2.xyz * r0.yyy;
  o5.xyz = r0.yzw;
  o5.w = 0;
  r2.x = r0.z * r0.z;
  r2.x = r0.y * r0.y + -r2.x;
  r3.xyzw = r0.yzww * r0.zwwy;
  r4.x = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBrArray.xyzw, r3.xyzw);
  r4.y = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBgArray.xyzw, r3.xyzw);
  r4.z = dot(unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHBbArray.xyzw, r3.xyzw);
  o6.xyz = unity_Builtins2Array[(uint)(r0.x) / 7u].unity_SHCArray.xyz * r2.xxx + r4.xyz;
  o6.w = 0;
  o8.zw = float2(0,0);
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  r0.xy = r0.xw + r0.zz;
  r0.xy = _ScreenParams.xy * r0.xy;
  o9.xy = float2(0.25,0.25) * r0.xy;
  o10.x = v4.x;
  return;
}


#endif
// vs 38d86e6d438821d7: 2 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)
void vs_38d86e6d438821d7_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : TANGENT0,
  float4 v4 : TEXCOORD1,
  float2 v5 : TEXCOORD2,
  uint v6 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD8,
  inout float4 o9 : TEXCOORD9,
  inout uint o10 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v6.x, instance_id
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v6.x + asint(unity_BaseInstanceID);
  r0.y = (uint)r0.x << 3;
  o6.zw = v5.xy * unity_Builtins2Array[(uint)(r0.x) / 1u].unity_DynamicLightmapSTArray.xy + unity_Builtins2Array[(uint)(r0.x) / 1u].unity_DynamicLightmapSTArray.zw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
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
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1]) * v0.yyy;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0]) * v0.xxx + r0.xzw;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2]) * v0.zzz + r0.xzw;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r0.xzw;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xzw;
  o7.xyz = r0.xzw;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][1]) * v3.yyy;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][0]) * v3.xxx + r0.xzw;
  r0.xzw = float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_ObjectToWorldArray[2][2]) * v3.zzz + r0.xzw;
  r2.x = dot(r0.xzw, r0.xzw);
  r2.x = rsqrt(r2.x);
  r0.xzw = r2.xxx * r0.xzw;
  o3.xyz = r0.xzw;
  o3.w = 0;
  r2.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][0]));
  r2.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][1]));
  r2.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.y) / 8u].unity_WorldToObjectArray[2][2]));
  r0.y = dot(r2.xyz, r2.xyz);
  r0.y = rsqrt(r0.y);
  r2.xyz = r2.xyz * r0.yyy;
  r3.xyz = r2.zxy * r0.zwx;
  r0.xyz = r2.yzx * r0.wxz + -r3.xyz;
  o5.xyz = r2.xyz;
  r0.w = unity_WorldTransformParams.w * v3.w;
  o4.xyz = r0.xyz * r0.www;
  o4.w = 0;
  o5.w = 0;
  o6.xy = float2(0,0);
  o8.zw = float2(0,0);
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o9.zw = r1.zw;
  r0.xy = r0.xw + r0.zz;
  r0.xy = _ScreenParams.xy * r0.xy;
  o9.xy = float2(0.25,0.25) * r0.xy;
  o10.x = v6.x;
  return;
}


#endif
// ps 83567ed922a943ea: 1 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_83567ed922a943ea_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  o0.w = r0.y * _OcclusionStrength + r0.x;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v9.xxx ? r0.xyz : -r0.xyz;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(1,1,1,1);
  return;
}


#endif
// ps 241cdf655ea9a316: 1 retail keyword combination(s)
#if !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_241cdf655ea9a316_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v9.xxx ? r0.xyz : -r0.xyz;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.x = 1 + -_OcclusionStrength;
  r1.x = r1.y * _OcclusionStrength + r1.x;
  r1.y = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r1.y != 0) {
    r1.y = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r2.xyz;
    r1.yzw = r1.yyy ? r2.xyz : v7.xyz;
    r1.yzw = -unity_ProbeVolumeMin.xyz + r1.yzw;
    r2.yzw = unity_ProbeVolumeSizeInv.xyz * r1.yzw;
    r1.y = 0.25 * r2.y;
    r1.z = 0.5 * unity_ProbeVolumeParams.z;
    r1.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r1.y = max(r1.y, r1.z);
    r2.x = min(r1.y, r1.w);
    r3.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r2.xzw).xyzw;
    r1.yzw = float3(0.25,0,0) + r2.xzw;
    r4.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r1.yzw = float3(0.5,0,0) + r2.xzw;
    r2.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r0.w = 1;
    r3.x = dot(r3.xyzw, r0.xyzw);
    r3.y = dot(r4.xyzw, r0.xyzw);
    r3.z = dot(r2.xyzw, r0.xyzw);
  } else {
    r0.w = 1;
    r3.x = dot(unity_SHAr.xyzw, r0.xyzw);
    r3.y = dot(unity_SHAg.xyzw, r0.xyzw);
    r3.z = dot(unity_SHAb.xyzw, r0.xyzw);
  }
  r1.yzw = v6.xyz + r3.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r1.yzw = r1.yzw * r1.xxx;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  o3.xyz = exp2(-r1.yzw);
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = r1.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  o2.w = 0;
  o3.w = 1;
  return;
}


#endif
// ps ea58ed24f7ec22a6: 1 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_ea58ed24f7ec22a6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_IsFrontFace0,
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
  r0.x = 1 + -_OcclusionStrength;
  r0.x = r0.y * _OcclusionStrength + r0.x;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy;
  r0.yzw = v9.xxx ? r0.yzw : -r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r0.xyz = r0.yzw * r0.xxx;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  o3.xyz = exp2(-r0.xyz);
  o3.w = 1;
  return;
}


#endif
// ps 2fdc3d2ce3718748: 1 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_2fdc3d2ce3718748_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  o0.w = r0.y * _OcclusionStrength + r0.x;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v9.xxx ? r0.xyz : -r0.xyz;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(0,0,0,1);
  return;
}


#endif
// ps 4a2dbbdc532fdb2a: 1 retail keyword combination(s)
#if !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_4a2dbbdc532fdb2a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v9.xxx ? r0.xyz : -r0.xyz;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.x = 1 + -_OcclusionStrength;
  r1.x = r1.y * _OcclusionStrength + r1.x;
  r1.y = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r1.y != 0) {
    r1.y = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r2.xyz;
    r1.yzw = r1.yyy ? r2.xyz : v7.xyz;
    r1.yzw = -unity_ProbeVolumeMin.xyz + r1.yzw;
    r2.yzw = unity_ProbeVolumeSizeInv.xyz * r1.yzw;
    r1.y = 0.25 * r2.y;
    r1.z = 0.5 * unity_ProbeVolumeParams.z;
    r1.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r1.y = max(r1.y, r1.z);
    r2.x = min(r1.y, r1.w);
    r3.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r2.xzw).xyzw;
    r1.yzw = float3(0.25,0,0) + r2.xzw;
    r4.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r1.yzw = float3(0.5,0,0) + r2.xzw;
    r2.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r0.w = 1;
    r3.x = dot(r3.xyzw, r0.xyzw);
    r3.y = dot(r4.xyzw, r0.xyzw);
    r3.z = dot(r2.xyzw, r0.xyzw);
  } else {
    r0.w = 1;
    r3.x = dot(unity_SHAr.xyzw, r0.xyzw);
    r3.y = dot(unity_SHAg.xyzw, r0.xyzw);
    r3.z = dot(unity_SHAb.xyzw, r0.xyzw);
  }
  r1.yzw = v6.xyz + r3.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r1.yzw = r1.yzw * r1.xxx;
  o3.xyz = max(float3(0,0,0), r1.yzw);
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = r1.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  o2.w = 0;
  o3.w = 1;
  return;
}


#endif
// ps 019032fe7a826deb: 1 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_019032fe7a826deb_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_IsFrontFace0,
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
  r0.x = 1 + -_OcclusionStrength;
  r0.x = r0.y * _OcclusionStrength + r0.x;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy;
  r0.yzw = v9.xxx ? r0.yzw : -r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r0.xyz = r0.yzw * r0.xxx;
  o3.xyz = max(float3(0,0,0), r0.xyz);
  o3.w = 1;
  return;
}


#endif
// ps 4da74588fd3c9c90: 1 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_4da74588fd3c9c90_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_InstanceID0,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  o0.w = r0.y * _OcclusionStrength + r0.x;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v10.xxx ? r0.xyz : -r0.xyz;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(1,1,1,1);
  return;
}


#endif
// ps b40ea96e48d65331: 1 retail keyword combination(s)
#if defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_b40ea96e48d65331_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_InstanceID0,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v10.xxx ? r0.xyz : -r0.xyz;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.x = 1 + -_OcclusionStrength;
  r1.x = r1.y * _OcclusionStrength + r1.x;
  r1.y = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r1.y != 0) {
    r1.y = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r2.xyz;
    r1.yzw = r1.yyy ? r2.xyz : v7.xyz;
    r1.yzw = -unity_ProbeVolumeMin.xyz + r1.yzw;
    r2.yzw = unity_ProbeVolumeSizeInv.xyz * r1.yzw;
    r1.y = 0.25 * r2.y;
    r1.z = 0.5 * unity_ProbeVolumeParams.z;
    r1.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r1.y = max(r1.y, r1.z);
    r2.x = min(r1.y, r1.w);
    r3.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r2.xzw).xyzw;
    r1.yzw = float3(0.25,0,0) + r2.xzw;
    r4.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r1.yzw = float3(0.5,0,0) + r2.xzw;
    r2.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r0.w = 1;
    r3.x = dot(r3.xyzw, r0.xyzw);
    r3.y = dot(r4.xyzw, r0.xyzw);
    r3.z = dot(r2.xyzw, r0.xyzw);
  } else {
    r0.w = 1;
    r3.x = dot(unity_Builtins2Array[0u].unity_SHArArray.xyzw, r0.xyzw);
    r3.y = dot(unity_Builtins2Array[0u].unity_SHAgArray.xyzw, r0.xyzw);
    r3.z = dot(unity_Builtins2Array[0u].unity_SHAbArray.xyzw, r0.xyzw);
  }
  r1.yzw = v6.xyz + r3.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r1.yzw = r1.yzw * r1.xxx;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  o3.xyz = exp2(-r1.yzw);
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = r1.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  o2.w = 0;
  o3.w = 1;
  return;
}


#endif
// ps 8dd7b0bb77b5b438: 1 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_8dd7b0bb77b5b438_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_InstanceID0,
  uint v10 : SV_IsFrontFace0,
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
  r0.x = 1 + -_OcclusionStrength;
  r0.x = r0.y * _OcclusionStrength + r0.x;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy;
  r0.yzw = v10.xxx ? r0.yzw : -r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r0.xyz = r0.yzw * r0.xxx;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  o3.xyz = exp2(-r0.xyz);
  o3.w = 1;
  return;
}


#endif
// ps a26c542e6b5b14fa: 1 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_a26c542e6b5b14fa_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_InstanceID0,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  o0.w = r0.y * _OcclusionStrength + r0.x;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v10.xxx ? r0.xyz : -r0.xyz;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(0,0,0,1);
  return;
}


#endif
// ps ac8c037028577dc1: 1 retail keyword combination(s)
#if defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_ac8c037028577dc1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_InstanceID0,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v10.xxx ? r0.xyz : -r0.xyz;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.x = 1 + -_OcclusionStrength;
  r1.x = r1.y * _OcclusionStrength + r1.x;
  r1.y = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r1.y != 0) {
    r1.y = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r2.xyz;
    r1.yzw = r1.yyy ? r2.xyz : v7.xyz;
    r1.yzw = -unity_ProbeVolumeMin.xyz + r1.yzw;
    r2.yzw = unity_ProbeVolumeSizeInv.xyz * r1.yzw;
    r1.y = 0.25 * r2.y;
    r1.z = 0.5 * unity_ProbeVolumeParams.z;
    r1.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r1.y = max(r1.y, r1.z);
    r2.x = min(r1.y, r1.w);
    r3.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r2.xzw).xyzw;
    r1.yzw = float3(0.25,0,0) + r2.xzw;
    r4.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r1.yzw = float3(0.5,0,0) + r2.xzw;
    r2.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r0.w = 1;
    r3.x = dot(r3.xyzw, r0.xyzw);
    r3.y = dot(r4.xyzw, r0.xyzw);
    r3.z = dot(r2.xyzw, r0.xyzw);
  } else {
    r0.w = 1;
    r3.x = dot(unity_Builtins2Array[0u].unity_SHArArray.xyzw, r0.xyzw);
    r3.y = dot(unity_Builtins2Array[0u].unity_SHAgArray.xyzw, r0.xyzw);
    r3.z = dot(unity_Builtins2Array[0u].unity_SHAbArray.xyzw, r0.xyzw);
  }
  r1.yzw = v6.xyz + r3.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r1.yzw = r1.yzw * r1.xxx;
  o3.xyz = max(float3(0,0,0), r1.yzw);
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = r1.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  o2.w = 0;
  o3.w = 1;
  return;
}


#endif
// ps 5fb00c65f96b2064: 1 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
void ps_5fb00c65f96b2064_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  uint v9 : SV_InstanceID0,
  uint v10 : SV_IsFrontFace0,
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
  r0.x = 1 + -_OcclusionStrength;
  r0.x = r0.y * _OcclusionStrength + r0.x;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy;
  r0.yzw = v10.xxx ? r0.yzw : -r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r0.xyz = r0.yzw * r0.xxx;
  o3.xyz = max(float3(0,0,0), r0.xyz);
  o3.w = 1;
  return;
}


#endif
// ps a2085bbd014c3e94: 1 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_a2085bbd014c3e94_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.x = -0.5 + r0.w;
  r0.x = cmp(r0.x < 0);
  r0.y = cmp(_StippleAlpha < 0.999000013);
  r0.x = r0.y ? r0.x : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  o0.w = r0.y * _OcclusionStrength + r0.x;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v10.xxx ? r0.xyz : -r0.xyz;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(1,1,1,1);
  return;
}


#endif
// ps 109996a14563a219: 1 retail keyword combination(s)
#if !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_109996a14563a219_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.x = cmp(_StippleAlpha < 0.999000013);
  r1.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.y = -0.5 + r1.w;
  r0.y = cmp(r0.y < 0);
  r0.x = r0.x ? r0.y : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v10.xxx ? r0.xyz : -r0.xyz;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.x = 1 + -_OcclusionStrength;
  r1.x = r1.y * _OcclusionStrength + r1.x;
  r1.y = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r1.y != 0) {
    r1.y = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r2.xyz;
    r1.yzw = r1.yyy ? r2.xyz : v7.xyz;
    r1.yzw = -unity_ProbeVolumeMin.xyz + r1.yzw;
    r2.yzw = unity_ProbeVolumeSizeInv.xyz * r1.yzw;
    r1.y = 0.25 * r2.y;
    r1.z = 0.5 * unity_ProbeVolumeParams.z;
    r1.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r1.y = max(r1.y, r1.z);
    r2.x = min(r1.y, r1.w);
    r3.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r2.xzw).xyzw;
    r1.yzw = float3(0.25,0,0) + r2.xzw;
    r4.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r1.yzw = float3(0.5,0,0) + r2.xzw;
    r2.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r0.w = 1;
    r3.x = dot(r3.xyzw, r0.xyzw);
    r3.y = dot(r4.xyzw, r0.xyzw);
    r3.z = dot(r2.xyzw, r0.xyzw);
  } else {
    r0.w = 1;
    r3.x = dot(unity_SHAr.xyzw, r0.xyzw);
    r3.y = dot(unity_SHAg.xyzw, r0.xyzw);
    r3.z = dot(unity_SHAb.xyzw, r0.xyzw);
  }
  r1.yzw = v6.xyz + r3.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r1.yzw = r1.yzw * r1.xxx;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  o3.xyz = exp2(-r1.yzw);
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = r1.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  o2.w = 0;
  o3.w = 1;
  return;
}


#endif
// ps abcd2e086c8ad49a: 1 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_abcd2e086c8ad49a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.x = -0.5 + r0.w;
  r0.x = cmp(r0.x < 0);
  r0.y = cmp(_StippleAlpha < 0.999000013);
  r0.x = r0.y ? r0.x : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  r0.x = r0.y * _OcclusionStrength + r0.x;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy;
  r0.yzw = v10.xxx ? r0.yzw : -r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r0.xyz = r0.yzw * r0.xxx;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  o3.xyz = exp2(-r0.xyz);
  o3.w = 1;
  return;
}


#endif
// ps 670793d98e585275: 1 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_670793d98e585275_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.x = -0.5 + r0.w;
  r0.x = cmp(r0.x < 0);
  r0.y = cmp(_StippleAlpha < 0.999000013);
  r0.x = r0.y ? r0.x : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  o0.w = r0.y * _OcclusionStrength + r0.x;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v10.xxx ? r0.xyz : -r0.xyz;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(0,0,0,1);
  return;
}


#endif
// ps c18d296710a1b288: 1 retail keyword combination(s)
#if !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_c18d296710a1b288_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.x = cmp(_StippleAlpha < 0.999000013);
  r1.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.y = -0.5 + r1.w;
  r0.y = cmp(r0.y < 0);
  r0.x = r0.x ? r0.y : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v10.xxx ? r0.xyz : -r0.xyz;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.x = 1 + -_OcclusionStrength;
  r1.x = r1.y * _OcclusionStrength + r1.x;
  r1.y = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r1.y != 0) {
    r1.y = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r2.xyz;
    r1.yzw = r1.yyy ? r2.xyz : v7.xyz;
    r1.yzw = -unity_ProbeVolumeMin.xyz + r1.yzw;
    r2.yzw = unity_ProbeVolumeSizeInv.xyz * r1.yzw;
    r1.y = 0.25 * r2.y;
    r1.z = 0.5 * unity_ProbeVolumeParams.z;
    r1.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r1.y = max(r1.y, r1.z);
    r2.x = min(r1.y, r1.w);
    r3.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r2.xzw).xyzw;
    r1.yzw = float3(0.25,0,0) + r2.xzw;
    r4.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r1.yzw = float3(0.5,0,0) + r2.xzw;
    r2.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r0.w = 1;
    r3.x = dot(r3.xyzw, r0.xyzw);
    r3.y = dot(r4.xyzw, r0.xyzw);
    r3.z = dot(r2.xyzw, r0.xyzw);
  } else {
    r0.w = 1;
    r3.x = dot(unity_SHAr.xyzw, r0.xyzw);
    r3.y = dot(unity_SHAg.xyzw, r0.xyzw);
    r3.z = dot(unity_SHAb.xyzw, r0.xyzw);
  }
  r1.yzw = v6.xyz + r3.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r1.yzw = r1.yzw * r1.xxx;
  o3.xyz = max(float3(0,0,0), r1.yzw);
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = r1.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  o2.w = 0;
  o3.w = 1;
  return;
}


#endif
// ps 0812b1e8721db75c: 1 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_0812b1e8721db75c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.x = -0.5 + r0.w;
  r0.x = cmp(r0.x < 0);
  r0.y = cmp(_StippleAlpha < 0.999000013);
  r0.x = r0.y ? r0.x : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  r0.x = r0.y * _OcclusionStrength + r0.x;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy;
  r0.yzw = v10.xxx ? r0.yzw : -r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r0.xyz = r0.yzw * r0.xxx;
  o3.xyz = max(float3(0,0,0), r0.xyz);
  o3.w = 1;
  return;
}


#endif
// ps 68feefc9a6fabe7a: 1 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_68feefc9a6fabe7a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_InstanceID0,
  uint v11 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.x = -0.5 + r0.w;
  r0.x = cmp(r0.x < 0);
  r0.y = cmp(_StippleAlpha < 0.999000013);
  r0.x = r0.y ? r0.x : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  o0.w = r0.y * _OcclusionStrength + r0.x;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v11.xxx ? r0.xyz : -r0.xyz;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(1,1,1,1);
  return;
}


#endif
// ps dce0f4852d1247e2: 1 retail keyword combination(s)
#if defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_dce0f4852d1247e2_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_InstanceID0,
  uint v11 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.x = cmp(_StippleAlpha < 0.999000013);
  r1.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.y = -0.5 + r1.w;
  r0.y = cmp(r0.y < 0);
  r0.x = r0.x ? r0.y : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v11.xxx ? r0.xyz : -r0.xyz;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.x = 1 + -_OcclusionStrength;
  r1.x = r1.y * _OcclusionStrength + r1.x;
  r1.y = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r1.y != 0) {
    r1.y = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r2.xyz;
    r1.yzw = r1.yyy ? r2.xyz : v7.xyz;
    r1.yzw = -unity_ProbeVolumeMin.xyz + r1.yzw;
    r2.yzw = unity_ProbeVolumeSizeInv.xyz * r1.yzw;
    r1.y = 0.25 * r2.y;
    r1.z = 0.5 * unity_ProbeVolumeParams.z;
    r1.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r1.y = max(r1.y, r1.z);
    r2.x = min(r1.y, r1.w);
    r3.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r2.xzw).xyzw;
    r1.yzw = float3(0.25,0,0) + r2.xzw;
    r4.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r1.yzw = float3(0.5,0,0) + r2.xzw;
    r2.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r0.w = 1;
    r3.x = dot(r3.xyzw, r0.xyzw);
    r3.y = dot(r4.xyzw, r0.xyzw);
    r3.z = dot(r2.xyzw, r0.xyzw);
  } else {
    r0.w = 1;
    r3.x = dot(unity_Builtins2Array[0u].unity_SHArArray.xyzw, r0.xyzw);
    r3.y = dot(unity_Builtins2Array[0u].unity_SHAgArray.xyzw, r0.xyzw);
    r3.z = dot(unity_Builtins2Array[0u].unity_SHAbArray.xyzw, r0.xyzw);
  }
  r1.yzw = v6.xyz + r3.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r1.yzw = r1.yzw * r1.xxx;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  o3.xyz = exp2(-r1.yzw);
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = r1.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  o2.w = 0;
  o3.w = 1;
  return;
}


#endif
// ps 321d6edc5858ba1f: 1 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_321d6edc5858ba1f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_InstanceID0,
  uint v11 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.x = -0.5 + r0.w;
  r0.x = cmp(r0.x < 0);
  r0.y = cmp(_StippleAlpha < 0.999000013);
  r0.x = r0.y ? r0.x : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  r0.x = r0.y * _OcclusionStrength + r0.x;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy;
  r0.yzw = v11.xxx ? r0.yzw : -r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r0.xyz = r0.yzw * r0.xxx;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  o3.xyz = exp2(-r0.xyz);
  o3.w = 1;
  return;
}


#endif
// ps 2e064e3d1ef893bd: 1 retail keyword combination(s)
#if !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_2e064e3d1ef893bd_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_InstanceID0,
  uint v11 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.x = -0.5 + r0.w;
  r0.x = cmp(r0.x < 0);
  r0.y = cmp(_StippleAlpha < 0.999000013);
  r0.x = r0.y ? r0.x : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  o0.w = r0.y * _OcclusionStrength + r0.x;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v11.xxx ? r0.xyz : -r0.xyz;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(0,0,0,1);
  return;
}


#endif
// ps 2d2926fa2cbaa245: 1 retail keyword combination(s)
#if defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_2d2926fa2cbaa245_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_InstanceID0,
  uint v11 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.x = cmp(_StippleAlpha < 0.999000013);
  r1.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.y = -0.5 + r1.w;
  r0.y = cmp(r0.y < 0);
  r0.x = r0.x ? r0.y : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = dot(v5.xyz, v5.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v5.xyz * r0.xxx;
  r0.xyz = v11.xxx ? r0.xyz : -r0.xyz;
  r1.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r1.x = 1 + -_OcclusionStrength;
  r1.x = r1.y * _OcclusionStrength + r1.x;
  r1.y = cmp(unity_ProbeVolumeParams.x == 1.000000);
  [branch] if (r1.y != 0) {
    r1.y = cmp(unity_ProbeVolumeParams.y == 1.000000);
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][1], unity_ProbeVolumeWorldToObject[1][1], unity_ProbeVolumeWorldToObject[2][1]) * v7.yyy;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][0], unity_ProbeVolumeWorldToObject[1][0], unity_ProbeVolumeWorldToObject[2][0]) * v7.xxx + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][2], unity_ProbeVolumeWorldToObject[1][2], unity_ProbeVolumeWorldToObject[2][2]) * v7.zzz + r2.xyz;
    r2.xyz = float3(unity_ProbeVolumeWorldToObject[0][3], unity_ProbeVolumeWorldToObject[1][3], unity_ProbeVolumeWorldToObject[2][3]) + r2.xyz;
    r1.yzw = r1.yyy ? r2.xyz : v7.xyz;
    r1.yzw = -unity_ProbeVolumeMin.xyz + r1.yzw;
    r2.yzw = unity_ProbeVolumeSizeInv.xyz * r1.yzw;
    r1.y = 0.25 * r2.y;
    r1.z = 0.5 * unity_ProbeVolumeParams.z;
    r1.w = -unity_ProbeVolumeParams.z * 0.5 + 0.25;
    r1.y = max(r1.y, r1.z);
    r2.x = min(r1.y, r1.w);
    r3.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r2.xzw).xyzw;
    r1.yzw = float3(0.25,0,0) + r2.xzw;
    r4.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r1.yzw = float3(0.5,0,0) + r2.xzw;
    r2.xyzw = unity_ProbeVolumeSH.Sample(samplerunity_ProbeVolumeSH, r1.yzw).xyzw;
    r0.w = 1;
    r3.x = dot(r3.xyzw, r0.xyzw);
    r3.y = dot(r4.xyzw, r0.xyzw);
    r3.z = dot(r2.xyzw, r0.xyzw);
  } else {
    r0.w = 1;
    r3.x = dot(unity_Builtins2Array[0u].unity_SHArArray.xyzw, r0.xyzw);
    r3.y = dot(unity_Builtins2Array[0u].unity_SHAgArray.xyzw, r0.xyzw);
    r3.z = dot(unity_Builtins2Array[0u].unity_SHAbArray.xyzw, r0.xyzw);
  }
  r1.yzw = v6.xyz + r3.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r1.yzw = r1.yzw * r1.xxx;
  o3.xyz = max(float3(0,0,0), r1.yzw);
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = r1.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  o2.w = 0;
  o3.w = 1;
  return;
}


#endif
// ps 8931eb601c5fb7f8: 1 retail keyword combination(s)
#if defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)
void ps_8931eb601c5fb7f8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  uint v10 : SV_InstanceID0,
  uint v11 : SV_IsFrontFace0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 16 * _StippleAlpha;
  r0.x = floor(r0.x);
  r0.x = 0.0625 * r0.x;
  r1.xy = v9.xy / v9.ww;
  r0.y = frac(r1.y);
  r1.z = r0.y * 0.0625 + r0.x;
  r0.xyzw = _DitherMaskLOD2D.Sample(sampler_DitherMaskLOD2D, r1.xz).xyzw;
  r0.x = -0.5 + r0.w;
  r0.x = cmp(r0.x < 0);
  r0.y = cmp(_StippleAlpha < 0.999000013);
  r0.x = r0.y ? r0.x : 0;
  clip(r0.x != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v1.xy).xyzw;
  r0.x = 1 + -_OcclusionStrength;
  r0.x = r0.y * _OcclusionStrength + r0.x;
  o0.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.yw = float2(0.5,1);
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v5.xyz * r0.yyy;
  r0.yzw = v11.xxx ? r0.yzw : -r0.yzw;
  o2.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.w = max(9.99999975e-005, r1.w);
  r0.y = dot(r0.yzw, r1.xyz);
  r0.y = 0.5 + r0.y;
  r2.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v6.zw).xyzw;
  r0.z = unity_DynamicLightmap_HDR.x * r2.w;
  r1.xyz = r0.zzz * r2.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = unity_DynamicLightmap_HDR.yyy * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = r0.yzw / r1.www;
  r0.xyz = r0.yzw * r0.xxx;
  o3.xyz = max(float3(0,0,0), r0.xyz);
  o3.w = 1;
  return;
}


#endif
v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
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
		vs_b959b7505b9ab0c5_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
	}
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
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
		vs_bbd96082d5e86825_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)
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
		vs_b22b4542831785e6_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1, v.texcoord2.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
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
		uint o9 = 0;
		vs_41bb200fc40cf21c_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
		o.sv_instanceid0 = o9;
	}
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)
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
		uint o9 = 0;
		vs_a3d634a40fc73bb2_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
		o.sv_instanceid0 = o9;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)
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
		uint o9 = 0;
		vs_2ded13253a0f9e0c_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1, v.texcoord2.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
		o.sv_instanceid0 = o9;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
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
		vs_5a1d2ec0bfb8e3a6_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
	}
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
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
		vs_9520798156e7ffce_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)
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
		vs_6b66ed07e08af778_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1, v.texcoord2.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
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
		uint o10 = 0;
		vs_525554b717947bd0_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.sv_instanceid0 = o10;
	}
#elif defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)
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
		uint o10 = 0;
		vs_be790d5f340e0b36_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.sv_instanceid0 = o10;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)
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
		uint o10 = 0;
		vs_38d86e6d438821d7_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.tangent0, v.texcoord1, v.texcoord2.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord8 = o8;
		o.texcoord9 = o9;
		o.sv_instanceid0 = o10;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i, bool isFrontFace : SV_IsFrontFace)
{
	fout r;
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_83567ed922a943ea_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_241cdf655ea9a316_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_ea58ed24f7ec22a6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_2fdc3d2ce3718748_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_4a2dbbdc532fdb2a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_019032fe7a826deb_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_4da74588fd3c9c90_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_b40ea96e48d65331_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_8dd7b0bb77b5b438_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_a26c542e6b5b14fa_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_ac8c037028577dc1_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(UNITY_HDR_ON) && !defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_5fb00c65f96b2064_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (!defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_a2085bbd014c3e94_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_109996a14563a219_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_abcd2e086c8ad49a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (!defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_670793d98e585275_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_c18d296710a1b288_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (!defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && !defined(INSTANCING_ON) && defined(_STIPPLE_FADE)) || (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_0812b1e8721db75c_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_68feefc9a6fabe7a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_dce0f4852d1247e2_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_321d6edc5858ba1f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_2e064e3d1ef893bd_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_2d2926fa2cbaa245_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(UNITY_HDR_ON) && defined(_STIPPLE_FADE)) && ((!defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && !defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(INSTANCING_ON) && defined(LIGHTPROBE_SH) && defined(_STIPPLE_FADE)) || (defined(DYNAMICLIGHTMAP_ON) && defined(INSTANCING_ON) && defined(_STIPPLE_FADE)))
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_8931eb601c5fb7f8_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord8, i.texcoord9, i.sv_instanceid0, (isFrontFace ? 0xffffffffu : 0u), o0, o1, o2, o3);
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
	}
}
