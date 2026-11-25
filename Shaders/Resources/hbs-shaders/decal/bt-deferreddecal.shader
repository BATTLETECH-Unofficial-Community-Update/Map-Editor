Shader "Battletech Decal"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_GlossMapScale ("Smoothness Scale", Range(0,1)) = 1
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0
		[Gamma] _Metallic ("Metallic", Range(0,1)) = 0
		_Reflectance ("Reflectance", Range(0,1)) = 0.5
		_MetallicGlossMap ("Metallic", 2D) = "white" {}
		[ToggleOff] _SpecularHighlights ("Specular Highlights", Float) = 1
		[ToggleOff] _GlossyReflections ("Glossy Reflections", Float) = 1
		_BumpScale ("Scale", Float) = 1
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_Parallax ("Height Scale", Range(0.005,0.08)) = 0.02
		_ParallaxMap ("Height Map", 2D) = "black" {}
		_OcclusionStrength ("Strength", Range(0,1)) = 1
		_OcclusionMap ("Occlusion", 2D) = "white" {}
		_EmissionColor ("Color", Color) = (0,0,0,1)
		_EmissionMap ("Emission", 2D) = "white" {}
		[Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0
		[Enum(UV0,0,UV1,1)] _UVSecMask ("UV Set for detail mask texture", Float) = 0
		[HideInInspector] _Mode ("__mode", Float) = 0
		[HideInInspector] _SrcBlend ("__src", Float) = 1
		[HideInInspector] _DstBlend ("__dst", Float) = 0
		[HideInInspector] _ZWrite ("__zw", Float) = 1
		_DecalClip ("Decal Clip", Range(0,1)) = 0.5
		_DecalFade ("Decal Fade", Range(0,1)) = 0
		[HideInInspector] _AffectTerrain ("___terain", Float) = 1
		[HideInInspector] _AffectWorld ("___world", Float) = 1
		[HideInInspector] _AffectMech ("___mech", Float) = 1
		[HideInInspector] _AffectTree ("___mech", Float) = 1
		_DecalAffects ("Decal Affection", Vector) = (1,1,1,1)
		_DecalSheetProperties ("Decal Texture Sheet Properties", Vector) = (1,1,0,0)
		[HideInInspector] _DecalSheet ("_DecalSheet", Float) = 0
		[ToggleOff] _FlipAlpha ("Flipped Alpha", Float) = 0
		_DetailAlbedoMap ("Detail Albedo Map", 2D) = "white" {}
		_DetailNormalMap ("Detail Normal Map", 2D) = "white" {}
		[ToggleOff] _NightLight ("Night Light", Float) = 0
		[ToggleOff] _EmissiveOnly ("Emissive Only", Float) = 0
		_Priority ("Priority", Float) = 100
	}
	SubShader
	{
		Pass
		{
			Name "DEFERRED - BASE"
			Blend [_SrcBlend] [_DstBlend]
			ZWrite Off
			ZTest GEqual
			Cull Front
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt
			#pragma multi_compile _ INSTANCING_ON
			#pragma multi_compile _ _ALPHABLEND_ON
			#pragma multi_compile _ _ALPHATEST_ON
			#pragma multi_compile _ _DYNAMIC
			#pragma multi_compile _ _EMISSION
			#pragma multi_compile _ _FLIPALPHA
			#pragma multi_compile _ _METALLICGLOSSMAP
			#pragma multi_compile _ _NORMALMAP
			#pragma multi_compile _ _SIMGAME
			#pragma multi_compile _ _TEXTURE_SHEET

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _NormalsCopy;
SamplerState sampler_NormalsCopy;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _MetallicGlossMap;
SamplerState sampler_MetallicGlossMap;
Texture2D _BumpMap;
SamplerState sampler_BumpMap;

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
float _BT_ScorchAlpha[125];
float4 _Color;
float4 _MainTex_ST;
float _Metallic;
float _Glossiness;
float _DecalClip;
float4 _DecalAffects;
float _FlipAlpha;
float _Cutoff;
float _BumpScale;
float _DecalFade;
float4 _BT_DecalSheet[500];
float2 _DecalSheetProperties;
float _SheetXCoord;
float _SheetYCoord;

struct appdata
{
	float4 position0 : POSITION0;
	uint sv_instanceid0 : SV_InstanceID;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(INSTANCING_ON)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
};
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	nointerpolation uint sv_instanceid0 : SV_InstanceID;
};
#elif defined(INSTANCING_ON) && defined(_DYNAMIC)
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
};

// vs 3aabc121d1148606: 128 retail keyword combination(s)
void vs_3aabc121d1148606_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7,
  inout float4 o9 : TEXCOORD8,
  inout float4 o10 : TEXCOORD9)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  o0.xyzw = r0.xyzw;
  r0.y = _ProjectionParams.x * r0.y;
  r2.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o1.w = r0.w;
  o1.xy = r2.xw + r2.zz;
  o1.z = 1;
  r0.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r1.yyy;
  r0.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r1.xxx + r0.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r1.zzz + r0.xyz;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * r1.www + r0.xyz;
  o3.xyz = float3(-1,-1,1) * r0.xyz;
  r0.x = dot(float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]), float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]));
  r0.x = rsqrt(r0.x);
  o4.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.xxxx;
  r0.x = dot(float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]), float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]));
  r0.x = rsqrt(r0.x);
  o5.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx;
  r0.x = dot(float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]), float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]));
  r0.x = rsqrt(r0.x);
  o6.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.xxxx;
  o7.xyzw = float4(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0], unity_WorldToObject[3][0]);
  o8.xyzw = float4(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1], unity_WorldToObject[3][1]);
  o9.xyzw = float4(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2], unity_WorldToObject[3][2]);
  o10.xyzw = float4(unity_WorldToObject[0][3], unity_WorldToObject[1][3], unity_WorldToObject[2][3], unity_WorldToObject[3][3]);
  return;
}


// vs 9ec4659e392cdc37: 64 retail keyword combination(s)
void vs_9ec4659e392cdc37_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  uint v2 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7,
  inout float4 o9 : TEXCOORD8,
  inout float4 o10 : TEXCOORD9,
  inout uint o11 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v2.x, instance_id
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v2.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r2.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.yzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r2.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r2.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r2.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r2.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.z = 1;
  r0.y = _ProjectionParams.x * r1.y;
  r3.w = 0.5 * r0.y;
  r3.xz = float2(0.5,0.5) * r1.xw;
  o1.w = r1.w;
  o1.xy = r3.xw + r3.zz;
  r0.yzw = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r2.yyy;
  r0.yzw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r2.xxx + r0.yzw;
  r0.yzw = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r2.zzz + r0.yzw;
  r0.yzw = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * r2.www + r0.yzw;
  o3.xyz = float3(-1,-1,1) * r0.yzw;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]));
  r0.y = rsqrt(r0.y);
  o4.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * r0.yyyy;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]));
  r0.y = rsqrt(r0.y);
  o5.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * r0.yyyy;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]));
  r0.y = rsqrt(r0.y);
  o6.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * r0.yyyy;
  o7.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][0]);
  o8.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][1]);
  o9.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][2]);
  o10.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][3]);
  o11.x = v2.x;
  return;
}


// vs 951b464132746e30: 64 retail keyword combination(s)
void vs_951b464132746e30_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  uint v2 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7,
  inout float4 o9 : TEXCOORD8,
  inout float4 o10 : TEXCOORD9,
  inout uint o11 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v2.x, instance_id
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v2.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r2.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.yzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r2.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r2.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r2.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r2.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  r0.y = v2.x;
  o1.z = _BT_ScorchAlpha[r0.y].x;
  r0.y = _ProjectionParams.x * r1.y;
  r3.w = 0.5 * r0.y;
  r3.xz = float2(0.5,0.5) * r1.xw;
  o1.w = r1.w;
  o1.xy = r3.xw + r3.zz;
  r0.yzw = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r2.yyy;
  r0.yzw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r2.xxx + r0.yzw;
  r0.yzw = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r2.zzz + r0.yzw;
  r0.yzw = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * r2.www + r0.yzw;
  o3.xyz = float3(-1,-1,1) * r0.yzw;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]));
  r0.y = rsqrt(r0.y);
  o4.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * r0.yyyy;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]));
  r0.y = rsqrt(r0.y);
  o5.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * r0.yyyy;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]));
  r0.y = rsqrt(r0.y);
  o6.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * r0.yyyy;
  o7.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][0]);
  o8.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][1]);
  o9.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][2]);
  o10.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][3]);
  o11.x = v2.x;
  return;
}


// ps b77aae2c9fde1f05: 8 retail keyword combination(s)
void ps_b77aae2c9fde1f05_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = (int)r2.z | (int)r2.x;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = dot(r1.xyz, v4.xyz);
  r2.x = r2.y + -r2.x;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r2.y = r2.x ? r3.x : 0;
  r2.x = ~(int)r2.x;
  clip(r2.y != 0 ? -1 : 1);
  r2.yz = cmp(r1.ww < float2(0.5,1));
  r2.w = r2.y ? r2.x : 0;
  r2.w = r3.y ? r2.w : 0;
  clip(r2.w != 0 ? -1 : 1);
  r2.y = ~(int)r2.y;
  r2.x = r2.y ? r2.x : 0;
  r2.x = r2.z ? r2.x : 0;
  r2.x = r2.x ? r3.z : 0;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r1.w = r1.w ? r2.x : 0;
  r1.w = r1.w ? r3.w : 0;
  clip(r1.w != 0 ? -1 : 1);
  r1.w = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.x = r2.x ? r1.w : r0.x;
  o0.xyzw = r0.yzwx;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps c7bfc4981ee8f4a7: 8 retail keyword combination(s)
void ps_c7bfc4981ee8f4a7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = (int)r2.z | (int)r2.x;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = dot(r1.xyz, v4.xyz);
  r2.x = r2.y + -r2.x;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = r0.w * _Color.w + -_Cutoff;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r2.y = r2.x ? r3.x : 0;
  r2.x = ~(int)r2.x;
  clip(r2.y != 0 ? -1 : 1);
  r2.yz = cmp(r1.ww < float2(0.5,1));
  r2.w = r2.y ? r2.x : 0;
  r2.w = r3.y ? r2.w : 0;
  clip(r2.w != 0 ? -1 : 1);
  r2.y = ~(int)r2.y;
  r2.x = r2.y ? r2.x : 0;
  r2.x = r2.z ? r2.x : 0;
  r2.x = r2.x ? r3.z : 0;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r1.w = r1.w ? r2.x : 0;
  r1.w = r1.w ? r3.w : 0;
  clip(r1.w != 0 ? -1 : 1);
  r1.w = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.x = r2.x ? r1.w : r0.x;
  o0.xyzw = r0.yzwx;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 331582e658be1f75: 8 retail keyword combination(s)
void ps_331582e658be1f75_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = r2.w * _Color.w + -_Cutoff;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r0.w = r0.z ? r3.x : 0;
  r0.z = ~(int)r0.z;
  clip(r0.w != 0 ? -1 : 1);
  r4.xy = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.z ? r4.x : 0;
  r0.w = r3.y ? r0.w : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = ~(int)r4.x;
  r0.z = r0.z ? r0.w : 0;
  r0.z = r4.y ? r0.z : 0;
  r0.z = r0.z ? r3.z : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w != 0.000000);
  r0.w = cmp(r1.w >= 1);
  r0.z = r0.w ? r0.z : 0;
  r0.z = r0.z ? r3.w : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r0.w = cmp(0 != _FlipAlpha);
  r0.z = r0.w ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 97de704a858c2645: 8 retail keyword combination(s)
void ps_97de704a858c2645_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = (int)r2.z | (int)r2.x;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.y = cmp(0 != _FlipAlpha);
  r0.x = r2.y ? r2.x : r0.x;
  o0.xyz = r0.yzw;
  r0.xyzw = _DecalAffects.yxwz * r0.xxxx;
  r2.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r2.y ? r0.z : r0.w;
  r0.y = r2.x ? r0.y : r0.z;
  r0.z = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = r0.z ? r0.x : r0.y;
  r0.y = _DecalClip * 2 + -1;
  r0.z = _DecalFade + r0.y;
  r0.y = -_DecalFade + r0.y;
  r0.yz = max(float2(-1,-1), r0.yz);
  r0.yz = min(float2(1,1), r0.yz);
  r0.z = r0.z + -r0.y;
  r0.z = 1 / r0.z;
  r0.w = dot(r1.xyz, v4.xyz);
  r0.y = r0.w + -r0.y;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = r0.x * r0.y;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 74aeb89cc8afab1a: 16 retail keyword combination(s)
void ps_74aeb89cc8afab1a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r3.x = cmp(0 != _FlipAlpha);
  r0.z = r3.x ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r3.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r3.y ? r2.z : r2.w;
  r0.z = r3.x ? r2.y : r0.z;
  r1.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r1.w ? r2.x : r0.z;
  r1.w = _DecalClip * 2 + -1;
  r2.x = _DecalFade + r1.w;
  r1.w = -_DecalFade + r1.w;
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r2.x = max(-1, r2.x);
  r2.x = min(1, r2.x);
  r2.x = r2.x + -r1.w;
  r2.x = 1 / r2.x;
  r2.y = dot(r1.xyz, v4.xyz);
  r1.w = r2.y + -r1.w;
  r1.w = saturate(r1.w * r2.x);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r0.z = r1.w * r0.z;
  o0.w = r0.z;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r2.xyz = v5.yzx * r1.zxy;
  r2.xyz = r1.yzx * v5.zxy + -r2.xyz;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r2.xyz = r2.xyz * r0.yyy;
  r2.xyz = v5.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx + r2.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 9bc12a9e67f421b2: 16 retail keyword combination(s)
void ps_9bc12a9e67f421b2_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r0.w = cmp(0 != _FlipAlpha);
  r0.z = r0.w ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r0.zw = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.w ? r2.z : r2.w;
  r0.z = r0.z ? r2.y : r0.w;
  r0.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r0.w ? r2.x : r0.z;
  r0.w = _DecalClip * 2 + -1;
  r1.w = _DecalFade + r0.w;
  r0.w = -_DecalFade + r0.w;
  r0.w = max(-1, r0.w);
  r0.w = min(1, r0.w);
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r1.w = r1.w + -r0.w;
  r1.w = 1 / r1.w;
  r2.x = dot(r1.xyz, v4.xyz);
  r0.w = r2.x + -r0.w;
  r0.w = saturate(r0.w * r1.w);
  r1.w = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.w * r0.w;
  r0.z = r0.z * r0.w;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps ee75aef2cefaa085: 4 retail keyword combination(s)
void ps_ee75aef2cefaa085_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = (int)r2.z | (int)r2.x;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = dot(r1.xyz, v4.xyz);
  r2.x = r2.y + -r2.x;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r2.y = r2.x ? r3.x : 0;
  r2.x = ~(int)r2.x;
  clip(r2.y != 0 ? -1 : 1);
  r2.yz = cmp(r1.ww < float2(0.5,1));
  r2.w = r2.y ? r2.x : 0;
  r2.w = r3.y ? r2.w : 0;
  clip(r2.w != 0 ? -1 : 1);
  r2.y = ~(int)r2.y;
  r2.x = r2.y ? r2.x : 0;
  r2.x = r2.z ? r2.x : 0;
  r2.x = r2.x ? r3.z : 0;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r1.w = r1.w ? r2.x : 0;
  r1.w = r1.w ? r3.w : 0;
  clip(r1.w != 0 ? -1 : 1);
  r1.w = v11.x;
  r2.x = _BT_DecalSheet[r1.w].z * r0.w;
  r0.w = -r0.w * _BT_DecalSheet[r1.w].z + 1;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = cmp(0 != _FlipAlpha);
  r0.x = r0.x ? r0.w : r2.x;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 0cfd6dcd8e7a6451: 4 retail keyword combination(s)
void ps_0cfd6dcd8e7a6451_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = (int)r2.z | (int)r2.x;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = dot(r1.xyz, v4.xyz);
  r2.x = r2.y + -r2.x;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = v11.x;
  r2.y = r0.w * _BT_DecalSheet[r2.x].z + -_Cutoff;
  r2.y = cmp(r2.y < 0);
  clip(r2.y != 0 ? -1 : 1);
  r2.y = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r2.z = r2.y ? r3.x : 0;
  r2.y = ~(int)r2.y;
  clip(r2.z != 0 ? -1 : 1);
  r2.zw = cmp(r1.ww < float2(0.5,1));
  r3.x = r2.z ? r2.y : 0;
  r3.x = r3.x ? r3.y : 0;
  clip(r3.x != 0 ? -1 : 1);
  r2.z = ~(int)r2.z;
  r2.y = r2.z ? r2.y : 0;
  r2.y = r2.w ? r2.y : 0;
  r2.y = r2.y ? r3.z : 0;
  clip(r2.y != 0 ? -1 : 1);
  r2.y = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r1.w = r1.w ? r2.y : 0;
  r1.w = r1.w ? r3.w : 0;
  clip(r1.w != 0 ? -1 : 1);
  r1.w = _BT_DecalSheet[r2.x].z * r0.w;
  r0.w = -r0.w * _BT_DecalSheet[r2.x].z + 1;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = cmp(0 != _FlipAlpha);
  r0.x = r0.x ? r0.w : r1.w;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 27d0c1e3a0130f9d: 4 retail keyword combination(s)
void ps_27d0c1e3a0130f9d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = v11.x;
  r0.w = r2.w * _BT_DecalSheet[r0.z].z + -_Cutoff;
  r0.w = cmp(r0.w < 0);
  clip(r0.w != 0 ? -1 : 1);
  r0.w = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r3.x = r0.w ? r3.x : 0;
  r0.w = ~(int)r0.w;
  clip(r3.x != 0 ? -1 : 1);
  r4.xy = cmp(r1.ww < float2(0.5,1));
  r3.x = r0.w ? r4.x : 0;
  r3.x = r3.x ? r3.y : 0;
  clip(r3.x != 0 ? -1 : 1);
  r3.x = ~(int)r4.x;
  r0.w = r0.w ? r3.x : 0;
  r0.w = r4.y ? r0.w : 0;
  r0.w = r0.w ? r3.z : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r0.w = r0.w ? r1.w : 0;
  r0.w = r0.w ? r3.w : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = _BT_DecalSheet[r0.z].z * r2.w;
  r0.z = -r2.w * _BT_DecalSheet[r0.z].z + 1;
  o0.xyz = _Color.xyz * r2.xyz;
  r1.w = cmp(0 != _FlipAlpha);
  r0.z = r1.w ? r0.z : r0.w;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps dca048179bdad375: 4 retail keyword combination(s)
void ps_dca048179bdad375_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = (int)r2.z | (int)r2.x;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = v11.x;
  r2.y = _BT_DecalSheet[r2.x].z * r0.w;
  r0.w = -r0.w * _BT_DecalSheet[r2.x].z + 1;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = cmp(0 != _FlipAlpha);
  r0.x = r0.x ? r0.w : r2.y;
  r0.xyzw = _DecalAffects.yxwz * r0.xxxx;
  r2.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r2.y ? r0.z : r0.w;
  r0.y = r2.x ? r0.y : r0.z;
  r0.z = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = r0.z ? r0.x : r0.y;
  r0.y = _DecalClip * 2 + -1;
  r0.z = _DecalFade + r0.y;
  r0.y = -_DecalFade + r0.y;
  r0.yz = max(float2(-1,-1), r0.yz);
  r0.yz = min(float2(1,1), r0.yz);
  r0.z = r0.z + -r0.y;
  r0.z = 1 / r0.z;
  r0.w = dot(r1.xyz, v4.xyz);
  r0.y = r0.w + -r0.y;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = r0.x * r0.y;
  r0.x = v1.z * r0.x;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps c58b2422f8e82d73: 8 retail keyword combination(s)
void ps_c58b2422f8e82d73_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  r0.z = v11.x;
  r3.x = _BT_DecalSheet[r0.z].z * r2.w;
  r0.z = -r2.w * _BT_DecalSheet[r0.z].z + 1;
  o0.xyz = _Color.xyz * r2.xyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.z = r2.x ? r0.z : r3.x;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r3.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r3.y ? r2.z : r2.w;
  r0.z = r3.x ? r2.y : r0.z;
  r1.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r1.w ? r2.x : r0.z;
  r1.w = _DecalClip * 2 + -1;
  r2.x = _DecalFade + r1.w;
  r1.w = -_DecalFade + r1.w;
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r2.x = max(-1, r2.x);
  r2.x = min(1, r2.x);
  r2.x = r2.x + -r1.w;
  r2.x = 1 / r2.x;
  r2.y = dot(r1.xyz, v4.xyz);
  r1.w = r2.y + -r1.w;
  r1.w = saturate(r1.w * r2.x);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r0.z = r1.w * r0.z;
  r0.z = v1.z * r0.z;
  o0.w = r0.z;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r2.xyz = v5.yzx * r1.zxy;
  r2.xyz = r1.yzx * v5.zxy + -r2.xyz;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r2.xyz = r2.xyz * r0.yyy;
  r2.xyz = v5.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx + r2.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 5e61056b70fd62a0: 8 retail keyword combination(s)
void ps_5e61056b70fd62a0_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = v11.x;
  r0.w = _BT_DecalSheet[r0.z].z * r2.w;
  r0.z = -r2.w * _BT_DecalSheet[r0.z].z + 1;
  o0.xyz = _Color.xyz * r2.xyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.z = r2.x ? r0.z : r0.w;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r0.zw = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.w ? r2.z : r2.w;
  r0.z = r0.z ? r2.y : r0.w;
  r0.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r0.w ? r2.x : r0.z;
  r0.w = _DecalClip * 2 + -1;
  r1.w = _DecalFade + r0.w;
  r0.w = -_DecalFade + r0.w;
  r0.w = max(-1, r0.w);
  r0.w = min(1, r0.w);
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r1.w = r1.w + -r0.w;
  r1.w = 1 / r1.w;
  r2.x = dot(r1.xyz, v4.xyz);
  r0.w = r2.x + -r0.w;
  r0.w = saturate(r0.w * r1.w);
  r1.w = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.w * r0.w;
  r0.z = r0.z * r0.w;
  r0.z = v1.z * r0.z;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 6cd9f4a62aa49837: 4 retail keyword combination(s)
void ps_6cd9f4a62aa49837_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = (int)r2.z | (int)r2.x;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = dot(r1.xyz, v4.xyz);
  r2.x = r2.y + -r2.x;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r2.y = r2.x ? r3.x : 0;
  r2.x = ~(int)r2.x;
  clip(r2.y != 0 ? -1 : 1);
  r2.yz = cmp(r1.ww < float2(0.5,1));
  r2.w = r2.y ? r2.x : 0;
  r2.w = r3.y ? r2.w : 0;
  clip(r2.w != 0 ? -1 : 1);
  r2.y = ~(int)r2.y;
  r2.x = r2.y ? r2.x : 0;
  r2.x = r2.z ? r2.x : 0;
  r2.x = r2.x ? r3.z : 0;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r1.w = r1.w ? r2.x : 0;
  r1.w = r1.w ? r3.w : 0;
  clip(r1.w != 0 ? -1 : 1);
  r1.w = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.x = r2.x ? r1.w : r0.x;
  o0.xyzw = r0.yzwx;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps b851baa6dcdc3796: 4 retail keyword combination(s)
void ps_b851baa6dcdc3796_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = (int)r2.z | (int)r2.x;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = dot(r1.xyz, v4.xyz);
  r2.x = r2.y + -r2.x;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = r0.w * _Color.w + -_Cutoff;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r2.y = r2.x ? r3.x : 0;
  r2.x = ~(int)r2.x;
  clip(r2.y != 0 ? -1 : 1);
  r2.yz = cmp(r1.ww < float2(0.5,1));
  r2.w = r2.y ? r2.x : 0;
  r2.w = r3.y ? r2.w : 0;
  clip(r2.w != 0 ? -1 : 1);
  r2.y = ~(int)r2.y;
  r2.x = r2.y ? r2.x : 0;
  r2.x = r2.z ? r2.x : 0;
  r2.x = r2.x ? r3.z : 0;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r1.w = r1.w ? r2.x : 0;
  r1.w = r1.w ? r3.w : 0;
  clip(r1.w != 0 ? -1 : 1);
  r1.w = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.x = r2.x ? r1.w : r0.x;
  o0.xyzw = r0.yzwx;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 083e277877f1ba98: 4 retail keyword combination(s)
void ps_083e277877f1ba98_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = r2.w * _Color.w + -_Cutoff;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r0.w = r0.z ? r3.x : 0;
  r0.z = ~(int)r0.z;
  clip(r0.w != 0 ? -1 : 1);
  r4.xy = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.z ? r4.x : 0;
  r0.w = r3.y ? r0.w : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = ~(int)r4.x;
  r0.z = r0.z ? r0.w : 0;
  r0.z = r4.y ? r0.z : 0;
  r0.z = r0.z ? r3.z : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w != 0.000000);
  r0.w = cmp(r1.w >= 1);
  r0.z = r0.w ? r0.z : 0;
  r0.z = r0.z ? r3.w : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r0.w = cmp(0 != _FlipAlpha);
  r0.z = r0.w ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 0bf4d6da52144922: 4 retail keyword combination(s)
void ps_0bf4d6da52144922_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = (int)r2.z | (int)r2.x;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.y = cmp(0 != _FlipAlpha);
  r0.x = r2.y ? r2.x : r0.x;
  o0.xyz = r0.yzw;
  r0.xyzw = _DecalAffects.yxwz * r0.xxxx;
  r2.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r2.y ? r0.z : r0.w;
  r0.y = r2.x ? r0.y : r0.z;
  r0.z = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = r0.z ? r0.x : r0.y;
  r0.y = _DecalClip * 2 + -1;
  r0.z = _DecalFade + r0.y;
  r0.y = -_DecalFade + r0.y;
  r0.yz = max(float2(-1,-1), r0.yz);
  r0.yz = min(float2(1,1), r0.yz);
  r0.z = r0.z + -r0.y;
  r0.z = 1 / r0.z;
  r0.w = dot(r1.xyz, v4.xyz);
  r0.y = r0.w + -r0.y;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = r0.x * r0.y;
  r0.x = v1.z * r0.x;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps b2a812c2060bbc33: 8 retail keyword combination(s)
void ps_b2a812c2060bbc33_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r3.x = cmp(0 != _FlipAlpha);
  r0.z = r3.x ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r3.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r3.y ? r2.z : r2.w;
  r0.z = r3.x ? r2.y : r0.z;
  r1.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r1.w ? r2.x : r0.z;
  r1.w = _DecalClip * 2 + -1;
  r2.x = _DecalFade + r1.w;
  r1.w = -_DecalFade + r1.w;
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r2.x = max(-1, r2.x);
  r2.x = min(1, r2.x);
  r2.x = r2.x + -r1.w;
  r2.x = 1 / r2.x;
  r2.y = dot(r1.xyz, v4.xyz);
  r1.w = r2.y + -r1.w;
  r1.w = saturate(r1.w * r2.x);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r0.z = r1.w * r0.z;
  r0.z = v1.z * r0.z;
  o0.w = r0.z;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r2.xyz = v5.yzx * r1.zxy;
  r2.xyz = r1.yzx * v5.zxy + -r2.xyz;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r2.xyz = r2.xyz * r0.yyy;
  r2.xyz = v5.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx + r2.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps df39bdbe40b840e3: 8 retail keyword combination(s)
void ps_df39bdbe40b840e3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r0.w = cmp(0 != _FlipAlpha);
  r0.z = r0.w ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r0.zw = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.w ? r2.z : r2.w;
  r0.z = r0.z ? r2.y : r0.w;
  r0.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r0.w ? r2.x : r0.z;
  r0.w = _DecalClip * 2 + -1;
  r1.w = _DecalFade + r0.w;
  r0.w = -_DecalFade + r0.w;
  r0.w = max(-1, r0.w);
  r0.w = min(1, r0.w);
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r1.w = r1.w + -r0.w;
  r1.w = 1 / r1.w;
  r2.x = dot(r1.xyz, v4.xyz);
  r0.w = r2.x + -r0.w;
  r0.w = saturate(r0.w * r1.w);
  r1.w = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.w * r0.w;
  r0.z = r0.z * r0.w;
  r0.z = v1.z * r0.z;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 9c96cdd2cc72d1d8: 8 retail keyword combination(s)
void ps_9c96cdd2cc72d1d8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w == 0.000000);
  r2.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r2.xyzw = cmp(r2.xyzw < float4(0,0,0,0));
  r0.w = r0.z ? r2.x : 0;
  r0.z = ~(int)r0.z;
  clip(r0.w != 0 ? -1 : 1);
  r3.xy = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.z ? r3.x : 0;
  r0.w = r2.y ? r0.w : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = ~(int)r3.x;
  r0.z = r0.z ? r0.w : 0;
  r0.z = r3.y ? r0.z : 0;
  r0.z = r0.z ? r2.z : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w != 0.000000);
  r0.w = cmp(r1.w >= 1);
  r0.z = r0.w ? r0.z : 0;
  r0.z = r0.z ? r2.w : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.w = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.x = r2.x ? r1.w : r0.x;
  o0.xyzw = r0.yzwx;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps df906aeb7ace27c5: 8 retail keyword combination(s)
void ps_df906aeb7ace27c5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.x = r0.w * _Color.w + -_Cutoff;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r2.y = r2.x ? r3.x : 0;
  r2.x = ~(int)r2.x;
  clip(r2.y != 0 ? -1 : 1);
  r2.yz = cmp(r1.ww < float2(0.5,1));
  r2.w = r2.y ? r2.x : 0;
  r2.w = r3.y ? r2.w : 0;
  clip(r2.w != 0 ? -1 : 1);
  r2.y = ~(int)r2.y;
  r2.x = r2.y ? r2.x : 0;
  r2.x = r2.z ? r2.x : 0;
  r2.x = r2.x ? r3.z : 0;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r1.w = r1.w ? r2.x : 0;
  r1.w = r1.w ? r3.w : 0;
  clip(r1.w != 0 ? -1 : 1);
  r1.w = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.x = r2.x ? r1.w : r0.x;
  o0.xyzw = r0.yzwx;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 95c0812930ca81dc: 8 retail keyword combination(s)
void ps_95c0812930ca81dc_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = r2.w * _Color.w + -_Cutoff;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r0.w = r0.z ? r3.x : 0;
  r0.z = ~(int)r0.z;
  clip(r0.w != 0 ? -1 : 1);
  r4.xy = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.z ? r4.x : 0;
  r0.w = r3.y ? r0.w : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = ~(int)r4.x;
  r0.z = r0.z ? r0.w : 0;
  r0.z = r4.y ? r0.z : 0;
  r0.z = r0.z ? r3.z : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w != 0.000000);
  r0.w = cmp(r1.w >= 1);
  r0.z = r0.w ? r0.z : 0;
  r0.z = r0.z ? r3.w : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r0.w = cmp(0 != _FlipAlpha);
  r0.z = r0.w ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 8b0c02b3da246c56: 8 retail keyword combination(s)
void ps_8b0c02b3da246c56_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.x = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.y = cmp(0 != _FlipAlpha);
  r0.x = r2.y ? r2.x : r0.x;
  o0.xyz = r0.yzw;
  r0.xyzw = _DecalAffects.yxwz * r0.xxxx;
  r2.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r2.y ? r0.z : r0.w;
  r0.y = r2.x ? r0.y : r0.z;
  r0.z = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = r0.z ? r0.x : r0.y;
  r0.y = _DecalClip * 2 + -1;
  r0.z = _DecalFade + r0.y;
  r0.y = -_DecalFade + r0.y;
  r0.yz = max(float2(-1,-1), r0.yz);
  r0.yz = min(float2(1,1), r0.yz);
  r0.z = r0.z + -r0.y;
  r0.z = 1 / r0.z;
  r0.w = dot(r1.xyz, v4.xyz);
  r0.y = r0.w + -r0.y;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = r0.x * r0.y;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 4e599e95a9ee3022: 16 retail keyword combination(s)
void ps_4e599e95a9ee3022_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r3.x = cmp(0 != _FlipAlpha);
  r0.z = r3.x ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r3.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r3.y ? r2.z : r2.w;
  r0.z = r3.x ? r2.y : r0.z;
  r1.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r1.w ? r2.x : r0.z;
  r1.w = _DecalClip * 2 + -1;
  r2.x = _DecalFade + r1.w;
  r1.w = -_DecalFade + r1.w;
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r2.x = max(-1, r2.x);
  r2.x = min(1, r2.x);
  r2.x = r2.x + -r1.w;
  r2.x = 1 / r2.x;
  r2.y = dot(r1.xyz, v4.xyz);
  r1.w = r2.y + -r1.w;
  r1.w = saturate(r1.w * r2.x);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r0.z = r1.w * r0.z;
  o0.w = r0.z;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r2.xyz = v5.yzx * r1.zxy;
  r2.xyz = r1.yzx * v5.zxy + -r2.xyz;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r2.xyz = r2.xyz * r0.yyy;
  r2.xyz = v5.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx + r2.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 5a2994fbaa92485a: 16 retail keyword combination(s)
void ps_5a2994fbaa92485a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r0.w = cmp(0 != _FlipAlpha);
  r0.z = r0.w ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r0.zw = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.w ? r2.z : r2.w;
  r0.z = r0.z ? r2.y : r0.w;
  r0.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r0.w ? r2.x : r0.z;
  r0.w = _DecalClip * 2 + -1;
  r1.w = _DecalFade + r0.w;
  r0.w = -_DecalFade + r0.w;
  r0.w = max(-1, r0.w);
  r0.w = min(1, r0.w);
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r1.w = r1.w + -r0.w;
  r1.w = 1 / r1.w;
  r2.x = dot(r1.xyz, v4.xyz);
  r0.w = r2.x + -r0.w;
  r0.w = saturate(r0.w * r1.w);
  r1.w = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.w * r0.w;
  r0.z = r0.z * r0.w;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 7d0b38144a8a42d9: 4 retail keyword combination(s)
void ps_7d0b38144a8a42d9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w == 0.000000);
  r2.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r2.xyzw = cmp(r2.xyzw < float4(0,0,0,0));
  r0.w = r0.z ? r2.x : 0;
  r0.z = ~(int)r0.z;
  clip(r0.w != 0 ? -1 : 1);
  r3.xy = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.z ? r3.x : 0;
  r0.w = r2.y ? r0.w : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = ~(int)r3.x;
  r0.z = r0.z ? r0.w : 0;
  r0.z = r3.y ? r0.z : 0;
  r0.z = r0.z ? r2.z : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w != 0.000000);
  r0.w = cmp(r1.w >= 1);
  r0.z = r0.w ? r0.z : 0;
  r0.z = r0.z ? r2.w : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r1.w = v11.x;
  r2.xy = _BT_DecalSheet[r1.w].xy * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.x = _BT_DecalSheet[r1.w].z * r0.w;
  r0.w = -r0.w * _BT_DecalSheet[r1.w].z + 1;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = cmp(0 != _FlipAlpha);
  r0.x = r0.x ? r0.w : r2.x;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 046171ef67a27d02: 4 retail keyword combination(s)
void ps_046171ef67a27d02_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.x = v11.x;
  r2.yz = _BT_DecalSheet[r2.x].xy * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.yz;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.y = r0.w * _BT_DecalSheet[r2.x].z + -_Cutoff;
  r2.y = cmp(r2.y < 0);
  clip(r2.y != 0 ? -1 : 1);
  r2.y = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r2.z = r2.y ? r3.x : 0;
  r2.y = ~(int)r2.y;
  clip(r2.z != 0 ? -1 : 1);
  r2.zw = cmp(r1.ww < float2(0.5,1));
  r3.x = r2.z ? r2.y : 0;
  r3.x = r3.x ? r3.y : 0;
  clip(r3.x != 0 ? -1 : 1);
  r2.z = ~(int)r2.z;
  r2.y = r2.z ? r2.y : 0;
  r2.y = r2.w ? r2.y : 0;
  r2.y = r2.y ? r3.z : 0;
  clip(r2.y != 0 ? -1 : 1);
  r2.y = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r1.w = r1.w ? r2.y : 0;
  r1.w = r1.w ? r3.w : 0;
  clip(r1.w != 0 ? -1 : 1);
  r1.w = _BT_DecalSheet[r2.x].z * r0.w;
  r0.w = -r0.w * _BT_DecalSheet[r2.x].z + 1;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = cmp(0 != _FlipAlpha);
  r0.x = r0.x ? r0.w : r1.w;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 1c578913599ce8d8: 4 retail keyword combination(s)
void ps_1c578913599ce8d8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.x = v11.x;
  r2.yz = _BT_DecalSheet[r2.x].xy * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.yz;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = r3.w * _BT_DecalSheet[r2.x].z + -_Cutoff;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w == 0.000000);
  r4.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r4.xyzw = cmp(r4.xyzw < float4(0,0,0,0));
  r0.w = r0.z ? r4.x : 0;
  r0.z = ~(int)r0.z;
  clip(r0.w != 0 ? -1 : 1);
  r2.yz = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.z ? r2.y : 0;
  r0.w = r4.y ? r0.w : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = ~(int)r2.y;
  r0.z = r0.z ? r0.w : 0;
  r0.z = r2.z ? r0.z : 0;
  r0.z = r0.z ? r4.z : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w != 0.000000);
  r0.w = cmp(r1.w >= 1);
  r0.z = r0.w ? r0.z : 0;
  r0.z = r0.z ? r4.w : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _BT_DecalSheet[r2.x].z * r3.w;
  r0.w = -r3.w * _BT_DecalSheet[r2.x].z + 1;
  o0.xyz = _Color.xyz * r3.xyz;
  r1.w = cmp(0 != _FlipAlpha);
  r0.z = r1.w ? r0.w : r0.z;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 6ae366eb7475713a: 4 retail keyword combination(s)
void ps_6ae366eb7475713a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.x = v11.x;
  r2.yz = _BT_DecalSheet[r2.x].xy * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.yz;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.y = _BT_DecalSheet[r2.x].z * r0.w;
  r0.w = -r0.w * _BT_DecalSheet[r2.x].z + 1;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = cmp(0 != _FlipAlpha);
  r0.x = r0.x ? r0.w : r2.y;
  r0.xyzw = _DecalAffects.yxwz * r0.xxxx;
  r2.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r2.y ? r0.z : r0.w;
  r0.y = r2.x ? r0.y : r0.z;
  r0.z = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = r0.z ? r0.x : r0.y;
  r0.y = _DecalClip * 2 + -1;
  r0.z = _DecalFade + r0.y;
  r0.y = -_DecalFade + r0.y;
  r0.yz = max(float2(-1,-1), r0.yz);
  r0.yz = min(float2(1,1), r0.yz);
  r0.z = r0.z + -r0.y;
  r0.z = 1 / r0.z;
  r0.w = dot(r1.xyz, v4.xyz);
  r0.y = r0.w + -r0.y;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = r0.x * r0.y;
  r0.x = v1.z * r0.x;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps bd3b4a20f3cd0016: 8 retail keyword combination(s)
void ps_bd3b4a20f3cd0016_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.x = v11.x;
  r2.yz = _BT_DecalSheet[r2.x].xy * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.yz;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  r0.z = _BT_DecalSheet[r2.x].z * r3.w;
  r2.x = -r3.w * _BT_DecalSheet[r2.x].z + 1;
  o0.xyz = _Color.xyz * r3.xyz;
  r2.y = cmp(0 != _FlipAlpha);
  r0.z = r2.y ? r2.x : r0.z;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r3.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r3.y ? r2.z : r2.w;
  r0.z = r3.x ? r2.y : r0.z;
  r1.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r1.w ? r2.x : r0.z;
  r1.w = _DecalClip * 2 + -1;
  r2.x = _DecalFade + r1.w;
  r1.w = -_DecalFade + r1.w;
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r2.x = max(-1, r2.x);
  r2.x = min(1, r2.x);
  r2.x = r2.x + -r1.w;
  r2.x = 1 / r2.x;
  r2.y = dot(r1.xyz, v4.xyz);
  r1.w = r2.y + -r1.w;
  r1.w = saturate(r1.w * r2.x);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r0.z = r1.w * r0.z;
  r0.z = v1.z * r0.z;
  o0.w = r0.z;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r2.xyz = v5.yzx * r1.zxy;
  r2.xyz = r1.yzx * v5.zxy + -r2.xyz;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r2.xyz = r2.xyz * r0.yyy;
  r2.xyz = v5.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx + r2.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 906d8ae00ef003c6: 8 retail keyword combination(s)
void ps_906d8ae00ef003c6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.x = v11.x;
  r2.yz = _BT_DecalSheet[r2.x].xy * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.yz;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = _BT_DecalSheet[r2.x].z * r3.w;
  r0.w = -r3.w * _BT_DecalSheet[r2.x].z + 1;
  o0.xyz = _Color.xyz * r3.xyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.z = r2.x ? r0.w : r0.z;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r0.zw = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.w ? r2.z : r2.w;
  r0.z = r0.z ? r2.y : r0.w;
  r0.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r0.w ? r2.x : r0.z;
  r0.w = _DecalClip * 2 + -1;
  r1.w = _DecalFade + r0.w;
  r0.w = -_DecalFade + r0.w;
  r0.w = max(-1, r0.w);
  r0.w = min(1, r0.w);
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r1.w = r1.w + -r0.w;
  r1.w = 1 / r1.w;
  r2.x = dot(r1.xyz, v4.xyz);
  r0.w = r2.x + -r0.w;
  r0.w = saturate(r0.w * r1.w);
  r1.w = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.w * r0.w;
  r0.z = r0.z * r0.w;
  r0.z = v1.z * r0.z;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 7d27a3fb36d8c7b7: 4 retail keyword combination(s)
void ps_7d27a3fb36d8c7b7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w == 0.000000);
  r2.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r2.xyzw = cmp(r2.xyzw < float4(0,0,0,0));
  r0.w = r0.z ? r2.x : 0;
  r0.z = ~(int)r0.z;
  clip(r0.w != 0 ? -1 : 1);
  r3.xy = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.z ? r3.x : 0;
  r0.w = r2.y ? r0.w : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = ~(int)r3.x;
  r0.z = r0.z ? r0.w : 0;
  r0.z = r3.y ? r0.z : 0;
  r0.z = r0.z ? r2.z : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w != 0.000000);
  r0.w = cmp(r1.w >= 1);
  r0.z = r0.w ? r0.z : 0;
  r0.z = r0.z ? r2.w : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.w = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.x = r2.x ? r1.w : r0.x;
  o0.xyzw = r0.yzwx;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 18caf8302d73f661: 4 retail keyword combination(s)
void ps_18caf8302d73f661_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.x = r0.w * _Color.w + -_Cutoff;
  r2.x = cmp(r2.x < 0);
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r2.y = r2.x ? r3.x : 0;
  r2.x = ~(int)r2.x;
  clip(r2.y != 0 ? -1 : 1);
  r2.yz = cmp(r1.ww < float2(0.5,1));
  r2.w = r2.y ? r2.x : 0;
  r2.w = r3.y ? r2.w : 0;
  clip(r2.w != 0 ? -1 : 1);
  r2.y = ~(int)r2.y;
  r2.x = r2.y ? r2.x : 0;
  r2.x = r2.z ? r2.x : 0;
  r2.x = r2.x ? r3.z : 0;
  clip(r2.x != 0 ? -1 : 1);
  r2.x = cmp(r1.w != 0.000000);
  r1.w = cmp(r1.w >= 1);
  r1.w = r1.w ? r2.x : 0;
  r1.w = r1.w ? r3.w : 0;
  clip(r1.w != 0 ? -1 : 1);
  r1.w = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.x = cmp(0 != _FlipAlpha);
  r0.x = r2.x ? r1.w : r0.x;
  o0.xyzw = r0.yzwx;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps d16a5ab87c5966b9: 4 retail keyword combination(s)
void ps_d16a5ab87c5966b9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = r2.w * _Color.w + -_Cutoff;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w == 0.000000);
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + _DecalAffects.yxwz;
  r3.xyzw = cmp(r3.xyzw < float4(0,0,0,0));
  r0.w = r0.z ? r3.x : 0;
  r0.z = ~(int)r0.z;
  clip(r0.w != 0 ? -1 : 1);
  r4.xy = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.z ? r4.x : 0;
  r0.w = r3.y ? r0.w : 0;
  clip(r0.w != 0 ? -1 : 1);
  r0.w = ~(int)r4.x;
  r0.z = r0.z ? r0.w : 0;
  r0.z = r4.y ? r0.z : 0;
  r0.z = r0.z ? r3.z : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = cmp(r1.w != 0.000000);
  r0.w = cmp(r1.w >= 1);
  r0.z = r0.w ? r0.z : 0;
  r0.z = r0.z ? r3.w : 0;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r0.w = cmp(0 != _FlipAlpha);
  r0.z = r0.w ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps e81f545ca47e3481: 4 retail keyword combination(s)
void ps_e81f545ca47e3481_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.x = -r0.w * _Color.w + 1;
  r0.xyzw = _Color.wxyz * r0.wxyz;
  r2.y = cmp(0 != _FlipAlpha);
  r0.x = r2.y ? r2.x : r0.x;
  o0.xyz = r0.yzw;
  r0.xyzw = _DecalAffects.yxwz * r0.xxxx;
  r2.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r2.y ? r0.z : r0.w;
  r0.y = r2.x ? r0.y : r0.z;
  r0.z = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = r0.z ? r0.x : r0.y;
  r0.y = _DecalClip * 2 + -1;
  r0.z = _DecalFade + r0.y;
  r0.y = -_DecalFade + r0.y;
  r0.yz = max(float2(-1,-1), r0.yz);
  r0.yz = min(float2(1,1), r0.yz);
  r0.z = r0.z + -r0.y;
  r0.z = 1 / r0.z;
  r0.w = dot(r1.xyz, v4.xyz);
  r0.y = r0.w + -r0.y;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = r0.x * r0.y;
  r0.x = v1.z * r0.x;
  o0.w = r0.x;
  o1.w = r0.x;
  o2.w = r0.x;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps f565a603b5b6c06f: 8 retail keyword combination(s)
void ps_f565a603b5b6c06f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r3.x = cmp(0 != _FlipAlpha);
  r0.z = r3.x ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r3.xy = cmp(r1.ww < float2(0.5,1));
  r0.z = r3.y ? r2.z : r2.w;
  r0.z = r3.x ? r2.y : r0.z;
  r1.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r1.w ? r2.x : r0.z;
  r1.w = _DecalClip * 2 + -1;
  r2.x = _DecalFade + r1.w;
  r1.w = -_DecalFade + r1.w;
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r2.x = max(-1, r2.x);
  r2.x = min(1, r2.x);
  r2.x = r2.x + -r1.w;
  r2.x = 1 / r2.x;
  r2.y = dot(r1.xyz, v4.xyz);
  r1.w = r2.y + -r1.w;
  r1.w = saturate(r1.w * r2.x);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r0.z = r1.w * r0.z;
  r0.z = v1.z * r0.z;
  o0.w = r0.z;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.xz = float2(_Metallic, _Glossiness);
  o1.y = 0;
  r2.xyz = v5.yzx * r1.zxy;
  r2.xyz = r1.yzx * v5.zxy + -r2.xyz;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.xy = _BumpScale.xx * r0.xy;
  r2.xyz = r2.xyz * r0.yyy;
  r2.xyz = v5.xyz * r0.xxx + r2.xyz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.x = sqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx + r2.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps 9ecc01b4213f405d: 8 retail keyword combination(s)
void ps_9ecc01b4213f405d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r0.w = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r2.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r2.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r2.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r2.xyz = cmp(r2.xyz < float3(0,0,0));
  r0.z = (int)r2.y | (int)r2.x;
  r0.z = (int)r2.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r2.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r2.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.z = -r2.w * _Color.w + 1;
  r2.xyzw = _Color.wxyz * r2.wxyz;
  r0.w = cmp(0 != _FlipAlpha);
  r0.z = r0.w ? r0.z : r2.x;
  o0.xyz = r2.yzw;
  r2.xyzw = _DecalAffects.yxwz * r0.zzzz;
  r0.zw = cmp(r1.ww < float2(0.5,1));
  r0.w = r0.w ? r2.z : r2.w;
  r0.z = r0.z ? r2.y : r0.w;
  r0.w = cmp(r1.w == 0.000000);
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.z = r0.w ? r2.x : r0.z;
  r0.w = _DecalClip * 2 + -1;
  r1.w = _DecalFade + r0.w;
  r0.w = -_DecalFade + r0.w;
  r0.w = max(-1, r0.w);
  r0.w = min(1, r0.w);
  r1.w = max(-1, r1.w);
  r1.w = min(1, r1.w);
  r1.w = r1.w + -r0.w;
  r1.w = 1 / r1.w;
  r2.x = dot(r1.xyz, v4.xyz);
  r0.w = r2.x + -r0.w;
  r0.w = saturate(r0.w * r1.w);
  r1.w = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.w * r0.w;
  r0.z = r0.z * r0.w;
  r0.z = v1.z * r0.z;
  o0.w = r0.z;
  r2.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, r0.xy).xyzw;
  r3.xyzw = _BumpMap.Sample(sampler_BumpMap, r0.xy).xyzw;
  o1.xz = r2.xw;
  o1.w = r0.z;
  o2.w = r0.z;
  o1.y = 0;
  r0.xyz = v5.yzx * r1.zxy;
  r0.xyz = r1.yzx * v5.zxy + -r0.xyz;
  r3.x = r3.x * r3.w;
  r2.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _BumpScale.xx * r2.xy;
  r0.xyz = r2.yyy * r0.xyz;
  r0.xyz = v5.xyz * r2.xxx + r0.xyz;
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(INSTANCING_ON)
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
		vs_3aabc121d1148606_impl(v.position0, v.texcoord0.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
		o.texcoord8 = o9;
		o.texcoord9 = o10;
	}
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC)
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
		uint o11 = 0;
		vs_9ec4659e392cdc37_impl(v.position0, v.texcoord0.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
		o.texcoord8 = o9;
		o.texcoord9 = o10;
		o.sv_instanceid0 = o11;
	}
#elif defined(INSTANCING_ON) && defined(_DYNAMIC)
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
		uint o11 = 0;
		vs_951b464132746e30_impl(v.position0, v.texcoord0.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
		o.texcoord8 = o9;
		o.texcoord9 = o10;
		o.sv_instanceid0 = o11;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(INSTANCING_ON) && !defined(_ALPHABLEND_ON) && !defined(_ALPHATEST_ON) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_b77aae2c9fde1f05_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && !defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_c7bfc4981ee8f4a7_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_331582e658be1f75_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && defined(_ALPHABLEND_ON) && !defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_97de704a858c2645_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_74aeb89cc8afab1a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && !defined(_TEXTURE_SHEET) || !defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && defined(_METALLICGLOSSMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_9bc12a9e67f421b2_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && !defined(_ALPHABLEND_ON) && !defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_ee75aef2cefaa085_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && !defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_0cfd6dcd8e7a6451_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_27d0c1e3a0130f9d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHABLEND_ON) && !defined(_DYNAMIC) && !defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_dca048179bdad375_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_c58b2422f8e82d73_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && !defined(_TEXTURE_SHEET) || defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && defined(_METALLICGLOSSMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_5e61056b70fd62a0_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && !defined(_ALPHABLEND_ON) && !defined(_ALPHATEST_ON) && defined(_DYNAMIC) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_6cd9f4a62aa49837_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_DYNAMIC) && !defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_b851baa6dcdc3796_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_DYNAMIC) && defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_083e277877f1ba98_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHABLEND_ON) && defined(_DYNAMIC) && !defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_0bf4d6da52144922_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_DYNAMIC) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_b2a812c2060bbc33_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_DYNAMIC) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && !defined(_TEXTURE_SHEET) || defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && defined(_DYNAMIC) && defined(_METALLICGLOSSMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_df39bdbe40b840e3_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && !defined(_ALPHABLEND_ON) && !defined(_ALPHATEST_ON) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_9c96cdd2cc72d1d8_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && !defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_df906aeb7ace27c5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_95c0812930ca81dc_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && defined(_ALPHABLEND_ON) && !defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_8b0c02b3da246c56_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_4e599e95a9ee3022_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif !defined(INSTANCING_ON) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && defined(_TEXTURE_SHEET) || !defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && defined(_METALLICGLOSSMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_5a2994fbaa92485a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && !defined(_ALPHABLEND_ON) && !defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_7d0b38144a8a42d9_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && !defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_046171ef67a27d02_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_1c578913599ce8d8_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHABLEND_ON) && !defined(_DYNAMIC) && !defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_6ae366eb7475713a_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_bd3b4a20f3cd0016_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && defined(_TEXTURE_SHEET) || defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && defined(_METALLICGLOSSMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_906d8ae00ef003c6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && !defined(_ALPHABLEND_ON) && !defined(_ALPHATEST_ON) && defined(_DYNAMIC) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_7d27a3fb36d8c7b7_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_DYNAMIC) && !defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_18caf8302d73f661_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_DYNAMIC) && defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_d16a5ab87c5966b9_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHABLEND_ON) && defined(_DYNAMIC) && !defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_e81f545ca47e3481_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_DYNAMIC) && !defined(_METALLICGLOSSMAP) && defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_f565a603b5b6c06f_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
	}
#elif defined(INSTANCING_ON) && defined(_DYNAMIC) && !defined(_EMISSION) && defined(_METALLICGLOSSMAP) && defined(_TEXTURE_SHEET) || defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && defined(_DYNAMIC) && defined(_METALLICGLOSSMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		ps_9ecc01b4213f405d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2);
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
			Name "DEFERRED - ADD"
			Tags { "LightMode"="Deferred" }
			Blend One One
			ZWrite Off
			ZTest GEqual
			Cull Front
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt
			#pragma multi_compile _ INSTANCING_ON
			#pragma multi_compile _ _ALPHABLEND_ON
			#pragma multi_compile _ _ALPHATEST_ON
			#pragma multi_compile _ _DYNAMIC
			#pragma multi_compile _ _EMISSION
			#pragma multi_compile _ _FLIPALPHA
			#pragma multi_compile _ _METALLICGLOSSMAP
			#pragma multi_compile _ _NORMALMAP
			#pragma multi_compile _ _SIMGAME
			#pragma multi_compile _ _TEXTURE_SHEET

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _NormalsCopy;
SamplerState sampler_NormalsCopy;
Texture2D _EmissionMap;
SamplerState sampler_EmissionMap;
Texture2D _MainTex;
SamplerState sampler_MainTex;

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
float _BT_ScorchAlpha[125];
float _DecalClip;
float _Cutoff;
float4 _MainTex_ST;
float4 _EmissionColor;
float _BT_NightLights;
float _EmissiveMode;
float _EV;
float _DecalFade;
float4 _BT_DecalSheet[500];
float2 _DecalSheetProperties;
float _SheetXCoord;
float _SheetYCoord;

struct appdata
{
	float4 position0 : POSITION0;
	uint sv_instanceid0 : SV_InstanceID;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(INSTANCING_ON)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
};
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC)
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
	float4 texcoord8 : TEXCOORD8;
	float4 texcoord9 : TEXCOORD9;
	nointerpolation uint sv_instanceid0 : SV_InstanceID;
};
#elif defined(INSTANCING_ON) && defined(_DYNAMIC)
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

// vs 3aabc121d1148606: 128 retail keyword combination(s)
void vs_3aabc121d1148606_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7,
  inout float4 o9 : TEXCOORD8,
  inout float4 o10 : TEXCOORD9)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  o0.xyzw = r0.xyzw;
  r0.y = _ProjectionParams.x * r0.y;
  r2.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o1.w = r0.w;
  o1.xy = r2.xw + r2.zz;
  o1.z = 1;
  r0.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r1.yyy;
  r0.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r1.xxx + r0.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r1.zzz + r0.xyz;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * r1.www + r0.xyz;
  o3.xyz = float3(-1,-1,1) * r0.xyz;
  r0.x = dot(float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]), float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]));
  r0.x = rsqrt(r0.x);
  o4.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.xxxx;
  r0.x = dot(float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]), float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]));
  r0.x = rsqrt(r0.x);
  o5.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx;
  r0.x = dot(float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]), float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]));
  r0.x = rsqrt(r0.x);
  o6.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.xxxx;
  o7.xyzw = float4(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0], unity_WorldToObject[3][0]);
  o8.xyzw = float4(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1], unity_WorldToObject[3][1]);
  o9.xyzw = float4(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2], unity_WorldToObject[3][2]);
  o10.xyzw = float4(unity_WorldToObject[0][3], unity_WorldToObject[1][3], unity_WorldToObject[2][3], unity_WorldToObject[3][3]);
  return;
}


// vs 9ec4659e392cdc37: 64 retail keyword combination(s)
void vs_9ec4659e392cdc37_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  uint v2 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7,
  inout float4 o9 : TEXCOORD8,
  inout float4 o10 : TEXCOORD9,
  inout uint o11 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v2.x, instance_id
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v2.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r2.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.yzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r2.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r2.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r2.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r2.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.z = 1;
  r0.y = _ProjectionParams.x * r1.y;
  r3.w = 0.5 * r0.y;
  r3.xz = float2(0.5,0.5) * r1.xw;
  o1.w = r1.w;
  o1.xy = r3.xw + r3.zz;
  r0.yzw = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r2.yyy;
  r0.yzw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r2.xxx + r0.yzw;
  r0.yzw = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r2.zzz + r0.yzw;
  r0.yzw = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * r2.www + r0.yzw;
  o3.xyz = float3(-1,-1,1) * r0.yzw;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]));
  r0.y = rsqrt(r0.y);
  o4.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * r0.yyyy;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]));
  r0.y = rsqrt(r0.y);
  o5.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * r0.yyyy;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]));
  r0.y = rsqrt(r0.y);
  o6.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * r0.yyyy;
  o7.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][0]);
  o8.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][1]);
  o9.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][2]);
  o10.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][3]);
  o11.x = v2.x;
  return;
}


// vs 951b464132746e30: 64 retail keyword combination(s)
void vs_951b464132746e30_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  uint v2 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7,
  inout float4 o9 : TEXCOORD8,
  inout float4 o10 : TEXCOORD9,
  inout uint o11 : SV_InstanceID0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v2.x, instance_id
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)v2.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r2.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3]) * v0.www + r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r0.yzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r2.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r2.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r2.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r2.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  r0.y = v2.x;
  o1.z = _BT_ScorchAlpha[r0.y].x;
  r0.y = _ProjectionParams.x * r1.y;
  r3.w = 0.5 * r0.y;
  r3.xz = float2(0.5,0.5) * r1.xw;
  o1.w = r1.w;
  o1.xy = r3.xw + r3.zz;
  r0.yzw = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r2.yyy;
  r0.yzw = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r2.xxx + r0.yzw;
  r0.yzw = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r2.zzz + r0.yzw;
  r0.yzw = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * r2.www + r0.yzw;
  o3.xyz = float3(-1,-1,1) * r0.yzw;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]));
  r0.y = rsqrt(r0.y);
  o4.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * r0.yyyy;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]));
  r0.y = rsqrt(r0.y);
  o5.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * r0.yyyy;
  r0.y = dot(float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]), float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]));
  r0.y = rsqrt(r0.y);
  o6.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * r0.yyyy;
  o7.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][0]);
  o8.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][1]);
  o9.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][2]);
  o10.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[3][3]);
  o11.x = v2.x;
  return;
}


// ps 2e4a7446f14cec88: 32 retail keyword combination(s)
void ps_2e4a7446f14cec88_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r0.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xyz = cmp(r0.xyz < float3(0,0,0));
  r0.x = (int)r0.y | (int)r0.x;
  r0.x = (int)r0.z | (int)r0.x;
  clip(r0.x != 0 ? -1 : 1);
  r0.x = _DecalClip * 2 + -1;
  r0.x = r0.w + -r0.x;
  r0.x = cmp(r0.x < 0);
  clip(r0.x != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  o3.xyzw = float4(0,0,0,0);
  return;
}


// ps ff542a39a554451e: 8 retail keyword combination(s)
void ps_ff542a39a554451e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.x = cmp(r0.w >= _Cutoff);
  r0.x = r0.x ? 1.000000 : 0;
  r0.yzw = _EmissionColor.xyz * r1.xyz;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 0;
  return;
}


// ps e586012bff93c21b: 48 retail keyword combination(s)
void ps_e586012bff93c21b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy / v1.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = _ProjectionParams.z / v3.z;
  r0.yzw = v3.xyz * r0.yyy;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r0.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xyz = cmp(r0.xyz < float3(0,0,0));
  r0.x = (int)r0.y | (int)r0.x;
  r0.x = (int)r0.z | (int)r0.x;
  clip(r0.x != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  o3.xyzw = float4(0,0,0,0);
  return;
}


// ps 14256903d1fc907d: 16 retail keyword combination(s)
void ps_14256903d1fc907d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r0.z = _DecalClip * 2 + -1;
  r1.x = -_DecalFade + r0.z;
  r0.z = _DecalFade + r0.z;
  r0.z = max(-1, r0.z);
  r0.z = min(1, r0.z);
  r1.x = max(-1, r1.x);
  r1.x = min(1, r1.x);
  r0.zw = -r1.xx + r0.zw;
  r0.z = 1 / r0.z;
  r0.z = saturate(r0.w * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyw = _EmissionColor.xyz * r2.xyz;
  r0.z = r1.w * r0.z;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.xyw = r1.xxx * r0.xyw;
  o3.xyz = r0.xyw * r0.zzz;
  o3.w = 0;
  return;
}


// ps ceaa7f8b4580db09: 32 retail keyword combination(s)
void ps_ceaa7f8b4580db09_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r0.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xyz = cmp(r0.xyz < float3(0,0,0));
  r0.x = (int)r0.y | (int)r0.x;
  r0.x = (int)r0.z | (int)r0.x;
  clip(r0.x != 0 ? -1 : 1);
  r0.x = _DecalClip * 2 + -1;
  r0.x = r0.w + -r0.x;
  r0.x = cmp(r0.x < 0);
  clip(r0.x != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  o3.xyzw = float4(0,0,0,0);
  return;
}


// ps 3e9f3971d649ba8e: 4 retail keyword combination(s)
void ps_3e9f3971d649ba8e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.x = cmp(r0.w >= _Cutoff);
  r0.x = r0.x ? 1.000000 : 0;
  r0.yzw = _EmissionColor.xyz * r1.xyz;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r1.x = v11.x;
  r0.yzw = _BT_DecalSheet[r1.x].zzz * r0.yzw;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 0;
  return;
}


// ps 047d45bf2f6dd7f4: 48 retail keyword combination(s)
void ps_047d45bf2f6dd7f4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy / v1.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = _ProjectionParams.z / v3.z;
  r0.yzw = v3.xyz * r0.yyy;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r0.xyw = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r0.xyw;
  r0.xyz = v10.xyz + r0.xyz;
  r0.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xyz = cmp(r0.xyz < float3(0,0,0));
  r0.x = (int)r0.y | (int)r0.x;
  r0.x = (int)r0.z | (int)r0.x;
  clip(r0.x != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  o3.xyzw = float4(0,0,0,0);
  return;
}


// ps 5ee0b2c56c10b949: 8 retail keyword combination(s)
void ps_5ee0b2c56c10b949_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r0.z = _DecalClip * 2 + -1;
  r1.x = -_DecalFade + r0.z;
  r0.z = _DecalFade + r0.z;
  r0.z = max(-1, r0.z);
  r0.z = min(1, r0.z);
  r1.x = max(-1, r1.x);
  r1.x = min(1, r1.x);
  r0.zw = -r1.xx + r0.zw;
  r0.z = 1 / r0.z;
  r0.z = saturate(r0.w * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyw = _EmissionColor.xyz * r2.xyz;
  r0.z = r1.w * r0.z;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.xyw = r1.xxx * r0.xyw;
  r1.x = v11.x;
  r0.xyw = _BT_DecalSheet[r1.x].zzz * r0.xyw;
  o3.xyz = r0.xyw * r0.zzz;
  o3.w = 0;
  return;
}


// ps d9f4f053df80d554: 4 retail keyword combination(s)
void ps_d9f4f053df80d554_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.x = cmp(r0.w >= _Cutoff);
  r0.x = r0.x ? 1.000000 : 0;
  r0.yzw = _EmissionColor.xyz * r1.xyz;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 0;
  return;
}


// ps ea8930c5cb95c064: 8 retail keyword combination(s)
void ps_ea8930c5cb95c064_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r0.z = _DecalClip * 2 + -1;
  r1.x = -_DecalFade + r0.z;
  r0.z = _DecalFade + r0.z;
  r0.z = max(-1, r0.z);
  r0.z = min(1, r0.z);
  r1.x = max(-1, r1.x);
  r1.x = min(1, r1.x);
  r0.zw = -r1.xx + r0.zw;
  r0.z = 1 / r0.z;
  r0.z = saturate(r0.w * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyw = _EmissionColor.xyz * r2.xyz;
  r0.z = r1.w * r0.z;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.xyw = r1.xxx * r0.xyw;
  o3.xyz = r0.xyw * r0.zzz;
  o3.w = 0;
  return;
}


// ps 47ce90282f072f51: 8 retail keyword combination(s)
void ps_47ce90282f072f51_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r1.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r1.xy;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.x = cmp(r0.w >= _Cutoff);
  r0.x = r0.x ? 1.000000 : 0;
  r0.yzw = _EmissionColor.xyz * r1.xyz;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 0;
  return;
}


// ps 2648a999eddacaa3: 16 retail keyword combination(s)
void ps_2648a999eddacaa3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r0.z = _DecalClip * 2 + -1;
  r1.x = -_DecalFade + r0.z;
  r0.z = _DecalFade + r0.z;
  r0.z = max(-1, r0.z);
  r0.z = min(1, r0.z);
  r1.x = max(-1, r1.x);
  r1.x = min(1, r1.x);
  r0.zw = -r1.xx + r0.zw;
  r0.z = 1 / r0.z;
  r0.z = saturate(r0.w * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r1.xy = float2(1,1) / _DecalSheetProperties.xy;
  r1.zw = float2(_SheetXCoord, _SheetYCoord) * r1.xy;
  r0.xy = r0.xy * r1.xy + r1.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyw = _EmissionColor.xyz * r2.xyz;
  r0.z = r1.w * r0.z;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.xyw = r1.xxx * r0.xyw;
  o3.xyz = r0.xyw * r0.zzz;
  o3.w = 0;
  return;
}


// ps d7586ee5287bede6: 4 retail keyword combination(s)
void ps_d7586ee5287bede6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r1.x = v11.x;
  r1.yz = _BT_DecalSheet[r1.x].xy * r0.zw;
  r0.xy = r0.xy * r0.zw + r1.yz;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.x = cmp(r0.w >= _Cutoff);
  r0.x = r0.x ? 1.000000 : 0;
  r0.yzw = _EmissionColor.xyz * r2.xyz;
  r1.y = -13 + _EV;
  r1.y = exp2(r1.y);
  r1.zw = cmp(_EmissiveMode.xx == float2(2,1));
  r1.y = r1.w ? r1.y : 1;
  r1.w = cmp(_BT_NightLights != 1.000000);
  r1.z = r1.w ? r1.z : 0;
  r1.y = r1.z ? 0 : r1.y;
  r0.yzw = r1.yyy * r0.yzw;
  r0.yzw = _BT_DecalSheet[r1.x].zzz * r0.yzw;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 0;
  return;
}


// ps 00965134b724a7e6: 8 retail keyword combination(s)
void ps_00965134b724a7e6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  nointerpolation uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r0.z = _DecalClip * 2 + -1;
  r1.x = -_DecalFade + r0.z;
  r0.z = _DecalFade + r0.z;
  r0.z = max(-1, r0.z);
  r0.z = min(1, r0.z);
  r1.x = max(-1, r1.x);
  r1.x = min(1, r1.x);
  r0.zw = -r1.xx + r0.zw;
  r0.z = 1 / r0.z;
  r0.z = saturate(r0.w * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r1.xy = float2(1,1) / _DecalSheetProperties.xy;
  r0.w = v11.x;
  r1.zw = _BT_DecalSheet[r0.w].xy * r1.xy;
  r0.xy = r0.xy * r1.xy + r1.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r1.xyz = _EmissionColor.xyz * r2.xyz;
  r0.x = r1.w * r0.z;
  r0.y = -13 + _EV;
  r0.y = exp2(r0.y);
  r2.xy = cmp(_EmissiveMode.xx == float2(2,1));
  r0.y = r2.y ? r0.y : 1;
  r0.z = cmp(_BT_NightLights != 1.000000);
  r0.z = r0.z ? r2.x : 0;
  r0.y = r0.z ? 0 : r0.y;
  r1.xyz = r1.xyz * r0.yyy;
  r0.yzw = _BT_DecalSheet[r0.w].zzz * r1.xyz;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 0;
  return;
}


// ps 2c8c9ca4825f8ec7: 4 retail keyword combination(s)
void ps_2c8c9ca4825f8ec7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  r0.z = _DecalClip * 2 + -1;
  r0.z = r0.w + -r0.z;
  r0.z = cmp(r0.z < 0);
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r0.zw = float2(1,1) / _DecalSheetProperties.xy;
  r1.xy = float2(_SheetXCoord, _SheetYCoord) * r0.zw;
  r0.xy = r0.xy * r0.zw + r1.xy;
  r1.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.x = cmp(r0.w >= _Cutoff);
  r0.x = r0.x ? 1.000000 : 0;
  r0.yzw = _EmissionColor.xyz * r1.xyz;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  o3.xyz = r0.yzw * r0.xxx;
  o3.w = 0;
  return;
}


// ps 5529bb599d2caeb3: 8 retail keyword combination(s)
void ps_5529bb599d2caeb3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  float4 v10 : TEXCOORD9,
  uint v11 : SV_InstanceID0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ProjectionParams.z / v3.z;
  r0.xyz = v3.xyz * r0.xxx;
  r1.xy = v1.xy / v1.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r1.xy).xyzw;
  r1.xyzw = _NormalsCopy.Sample(sampler_NormalsCopy, r1.xy).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r1.xyz, v4.xyz);
  r1.x = _ZBufferParams.x * r2.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r1.xyz = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.xyz;
  r1.xyz = v8.xyz * r0.yyy;
  r1.xyz = v7.xyz * r0.xxx + r1.xyz;
  r0.xyz = v9.xyz * r0.zzz + r1.xyz;
  r0.xyz = v10.xyz + r0.xyz;
  r1.xyz = float3(0.5,0.5,0.5) + -abs(r0.xyz);
  r0.xy = float2(0.5,0.5) + r0.xz;
  r1.xyz = cmp(r1.xyz < float3(0,0,0));
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  clip(r0.z != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  o1.xyzw = float4(0,0,0,0);
  o2.xyzw = float4(0,0,0,0);
  r0.z = _DecalClip * 2 + -1;
  r1.x = -_DecalFade + r0.z;
  r0.z = _DecalFade + r0.z;
  r0.z = max(-1, r0.z);
  r0.z = min(1, r0.z);
  r1.x = max(-1, r1.x);
  r1.x = min(1, r1.x);
  r0.zw = -r1.xx + r0.zw;
  r0.z = 1 / r0.z;
  r0.z = saturate(r0.w * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r1.xy = float2(1,1) / _DecalSheetProperties.xy;
  r1.zw = float2(_SheetXCoord, _SheetYCoord) * r1.xy;
  r0.xy = r0.xy * r1.xy + r1.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r2.xyzw = _EmissionMap.Sample(sampler_EmissionMap, r0.xy).xyzw;
  r0.xyw = _EmissionColor.xyz * r2.xyz;
  r0.z = r1.w * r0.z;
  r1.x = -13 + _EV;
  r1.x = exp2(r1.x);
  r1.yz = cmp(_EmissiveMode.xx == float2(2,1));
  r1.x = r1.z ? r1.x : 1;
  r1.z = cmp(_BT_NightLights != 1.000000);
  r1.y = r1.z ? r1.y : 0;
  r1.x = r1.y ? 0 : r1.x;
  r0.xyw = r1.xxx * r0.xyw;
  o3.xyz = r0.xyw * r0.zzz;
  o3.w = 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(INSTANCING_ON)
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
		vs_3aabc121d1148606_impl(v.position0, v.texcoord0.xy, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
		o.texcoord8 = o9;
		o.texcoord9 = o10;
	}
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC)
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
		uint o11 = 0;
		vs_9ec4659e392cdc37_impl(v.position0, v.texcoord0.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
		o.texcoord8 = o9;
		o.texcoord9 = o10;
		o.sv_instanceid0 = o11;
	}
#elif defined(INSTANCING_ON) && defined(_DYNAMIC)
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
		uint o11 = 0;
		vs_951b464132746e30_impl(v.position0, v.texcoord0.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
		o.texcoord8 = o9;
		o.texcoord9 = o10;
		o.sv_instanceid0 = o11;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(INSTANCING_ON) && !defined(_ALPHABLEND_ON) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_2e4a7446f14cec88_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_ff542a39a554451e_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(INSTANCING_ON) && defined(_ALPHABLEND_ON) && !defined(_NORMALMAP) || !defined(INSTANCING_ON) && !defined(_EMISSION) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_e586012bff93c21b_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(INSTANCING_ON) && defined(_EMISSION) && !defined(_METALLICGLOSSMAP) && !defined(_TEXTURE_SHEET) || !defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && defined(_EMISSION) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_14256903d1fc907d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && !defined(_ALPHABLEND_ON) && !defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_ceaa7f8b4580db09_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_3e9f3971d649ba8e_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHABLEND_ON) && !defined(_NORMALMAP) || defined(INSTANCING_ON) && !defined(_EMISSION) && defined(_NORMALMAP)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_047d45bf2f6dd7f4_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC) && defined(_EMISSION) && !defined(_METALLICGLOSSMAP) && !defined(_TEXTURE_SHEET) || defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && defined(_EMISSION) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_5ee0b2c56c10b949_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_DYNAMIC) && defined(_NORMALMAP) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_d9f4f053df80d554_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && defined(_DYNAMIC) && defined(_EMISSION) && !defined(_METALLICGLOSSMAP) && !defined(_TEXTURE_SHEET) || defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && defined(_DYNAMIC) && defined(_EMISSION) && !defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_ea8930c5cb95c064_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_47ce90282f072f51_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif !defined(INSTANCING_ON) && defined(_EMISSION) && !defined(_METALLICGLOSSMAP) && defined(_TEXTURE_SHEET) || !defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && defined(_EMISSION) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_2648a999eddacaa3_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_d7586ee5287bede6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && !defined(_DYNAMIC) && defined(_EMISSION) && !defined(_METALLICGLOSSMAP) && defined(_TEXTURE_SHEET) || defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && !defined(_DYNAMIC) && defined(_EMISSION) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_00965134b724a7e6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && defined(_ALPHATEST_ON) && defined(_DYNAMIC) && defined(_NORMALMAP) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_2c8c9ca4825f8ec7_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(INSTANCING_ON) && defined(_DYNAMIC) && defined(_EMISSION) && !defined(_METALLICGLOSSMAP) && defined(_TEXTURE_SHEET) || defined(INSTANCING_ON) && !defined(_ALPHATEST_ON) && defined(_DYNAMIC) && defined(_EMISSION) && defined(_TEXTURE_SHEET)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_5529bb599d2caeb3_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, i.texcoord8, i.texcoord9, i.sv_instanceid0, o0, o1, o2, o3);
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
	CustomEditor "BTDeferredDecalGUI"
}
