Shader "HBS/Horizon Displacement"
{
	Properties
	{
		[BlockInfo(1.0,1.0,1.0,1.0)] dummy_begin ("Features", Float) = 1
		[KeywordEnum(One, Two, Three, Four)] _LayerCount ("   Layer count", Float) = 3
		[KeywordEnum(Ambient, Cubemap, SkyshopSH, UnitySH)] [HideInInspector] _IBLDiff ("   Diffuse Ambient Lighting Mode", Float) = 3
		[PropBlockKeyword(_DETAIL)] _Detail ("    Enable Detail Textures", Float) = 0
		[BlockInfo(1.0,0.5,0.5,0.8, 1, indent)] dummy_main ("Main settings", Float) = 1
		[HideByProp(dummy_main)] _MapScaleOffset ("Mask Scale (XY), Offset (ZW) [m]", Vector) = (1000,1000,0,0)
		[HideByProp(dummy_main)] _Anchor ("World Shift (XYZ) [m]", Vector) = (0,0,0,0)
		[HideByProp(dummy_main, _LayerCount.1.2.3, 0)] _MaskRBlend1GBlend2BBlend3AWater ("   Mask (R)Blend 1 (G)Blend 2 (B)Blend 3 (A)Water", 2D) = "white" {}
		[HideByProp(dummy_main)] _Tint ("         Color Tint", Color) = (0.5,0.5,0.5,1)
		[HideByProp(_Emissiveness, dummy_main)] _EmissionColor ("         Emission color (RGB)", Color) = (0,0,0,0)
		[HideByProp(dummy_main)] _AmbientOverrideAAmount ("         Ambient Override/Amount", Color) = (0.5086505,0.5635247,0.6176471,0)
		[HideByProp(_IBLDiff.1.2.3, dummy_main)] _AmbientIBL ("         Ambient > diff IBL", Range(0,1)) = 1
		[HideByProp(_Normalmaps, dummy_main)] _GlobalNormalmapIntensity ("         Normalmap intensity from Layers (set below)", Range(0,1)) = 1
		[BlockInfo(0.5,1.0,0.5,1.0, 1, indent)] dummy_layer1 ("Layer 1 properties", Float) = 0
		[HideByProp(dummy_layer1)] _BaseColormap ("   Colormap (RGB) + A", 2D) = "white" {}
		[HideByProp(dummy_layer1)] _TintSaturation ("   Tint / Saturation", Color) = (0.5,0.5,0.5,0.5)
		[PropBlock(dummy_layer1)] _BaseGloss ("       A = Gloss", Float) = 0
		[PropBlock(dummy_layer1)] _BaseEmission ("       A = Emission", Float) = 0
		[HideByProp(dummy_layer1,_Normalmaps, 0)] _BaseNormalmap ("   Normalmap", 2D) = "bump" {}
		[HideByProp(dummy_layer1)] _SpecGloss ("   Spec / Gloss", Color) = (0.1,0.1,0.1,0.2)
		[HideByProp(dummy_layer1)] _BaseDetailIntensity ("   detail intensity", Range(0,1)) = 1
		[BlockInfo(0.5,1.0,0.5,1.0, 1, _Detail)] dummy_detail ("Detail settings", Float) = 1
		[HideByProp(dummy_detail, _Detail)] _DetailColormap ("   Detail colormap", 2D) = "gray" {}
		[HideByProp(dummy_detail, _Detail)] _DetailColormapIntensity ("   Detail colormap intensity", Range(0,1)) = 1
		[HideByProp(dummy_detail, _Detail)] _DetailNormalmap ("   Detail normalmap", 2D) = "bump" {}
		[HideByProp(dummy_detail, _Detail)] _DetailNormalmapIntensity ("   Detail normalmap intensity", Range(0,1)) = 1
		[BlockInfo(0.9,0.9,1.0,1.0, 1, _IBLDiff.1.2.3)] dummy_ambient ("Diffuse Ambient Lighting", Float) = 1
		[HideByProp(dummy_ambient, _IBLDiff.1.2.3)] _DiffIBLMulti ("   Exposure", Float) = 1
		[BlockInfo(0.9,0.9,1.0,1.0, 1, _IBLSpec)] dummy_specular ("Specular Ambient Lighting", Float) = 1
		[HideByProp(dummy_specular, _IBLSpec)] _IBLSpecRoughMIP ("     Rough MIP Level", Float) = 5
		[HideByProp(dummy_specular, _IBLSpec)] _IBLMIPDim_Rough ("     Rough Multi", Float) = 1
		[HideByProp(dummy_specular, _IBLSpec)] _IBLSpecGlossMIP ("     Glossy MIP Level", Float) = 0
		[HideByProp(dummy_specular, _IBLSpec)] _IBLMIPDim_Gloss ("     Glossy Multi", Float) = 1
		[BlockInfo(1.0,1.0,1.0,1.0, 1, indent)] dummy_displacement ("Displacement", Float) = 1
		[HideByProp(dummy_displacement)] _Parallax ("   Height [m]", Float) = 100
		[HideByProp(dummy_displacement,0)] _ParallaxMap ("   Heightmap (A/R/G/B)", 2D) = "black" {}
		[PropBlock(dummy_displacement)] _ReduceByVertexAlpha ("       Flatten by Vertex Color (A)", Float) = 0
		[PropBlock(dummy_displacement)] _ReduceByUVBorder ("       Flatten by UVs (near 0 and 1)", Float) = 0
		[HideByProp(dummy_displacement, _ReduceByUVBorder)] _ReduceByUVBorderLength ("       Flatten Strength", Range(0,0.95)) = 0.5
	}
	SubShader
	{
		Tags { "IgnoreProjector"="true" "Queue"="Geometry" "RenderType"="Opaque" }
		Pass
		{
			Name "Deferred"
			Tags { "LightMode"="Deferred" "ShadowSupport"="true" }
			ZWrite On

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

#define cmp -

Texture2D _ParallaxMap;
SamplerState sampler_ParallaxMap;
Texture2D _BaseColormap;
SamplerState sampler_BaseColormap;
Texture2D _DetailColormap;
SamplerState sampler_DetailColormap;

float4 _BaseColormap_ST;
float4 _MapScaleOffset;
float3 _Anchor;
float _Parallax;
float _ReduceByVertexAlpha;
float _ReduceByUVBorder;
float _ReduceByUVBorderLength;
float4 _TintSaturation;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(SHADOWS_SCREEN)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(SHADOWS_SCREEN)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord8 : TEXCOORD8;
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

// vs 7f51a7baf524e070: 6 retail keyword combination(s)
void vs_7f51a7baf524e070_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float2 o3 : TEXCOORD2,
  inout float2 p3 : TEXCOORD3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.5,-0.5) + v2.xy;
  r0.xy = r0.xy + r0.xy;
  r0.x = max(abs(r0.x), abs(r0.y));
  r0.x = -_ReduceByUVBorderLength + r0.x;
  r0.y = 1 + -_ReduceByUVBorderLength;
  r0.x = saturate(r0.x / r0.y);
  r0.x = _ReduceByUVBorder * -r0.x + 1;
  r0.yz = float2(unity_ObjectToWorld[0][1], unity_ObjectToWorld[2][1]) * v0.yy;
  r0.yz = float2(unity_ObjectToWorld[0][0], unity_ObjectToWorld[2][0]) * v0.xx + r0.yz;
  r0.yz = float2(unity_ObjectToWorld[0][2], unity_ObjectToWorld[2][2]) * v0.zz + r0.yz;
  r0.yz = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.yz;
  r0.yz = -_Anchor.xz + r0.yz;
  r0.yz = _MapScaleOffset.zw + r0.yz;
  r0.yz = r0.yz / _MapScaleOffset.xy;
  r0.yz = r0.yz * _BaseColormap_ST.xy + _BaseColormap_ST.zw;
  r1.xyzw = _ParallaxMap.SampleLevel(sampler_ParallaxMap, r0.yz, 0).xyzw;
  r0.y = _Parallax * r1.w;
  o2.xyz = r1.xyz;
  r0.y = unity_WorldToObject[1][1] * r0.y;
  r0.z = -1 + v3.w;
  r0.z = _ReduceByVertexAlpha * r0.z + 1;
  r0.y = r0.y * r0.z;
  r0.x = r0.y * r0.x;
  r0.xyz = v1.xyz * r0.xxx + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r1.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r1.xyz = _WorldSpaceCameraPos.xyz + -r0.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  o1.w = sqrt(r0.w);
  o1.xyz = r0.xyz;
  r0.xy = -_Anchor.xz + r0.xz;
  r0.xy = _MapScaleOffset.zw + r0.xy;
  r0.xy = r0.xy / _MapScaleOffset.xy;
  p3.xy = r0.xy * _BaseColormap_ST.xy + _BaseColormap_ST.zw;
  o3.xy = r0.xy;
  return;
}


// vs beb24ac1411880e3: 6 retail keyword combination(s)
void vs_beb24ac1411880e3_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float2 o3 : TEXCOORD2,
  inout float2 p3 : TEXCOORD3,
  inout float4 o4 : TEXCOORD8)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.5,-0.5) + v2.xy;
  r0.xy = r0.xy + r0.xy;
  r0.x = max(abs(r0.x), abs(r0.y));
  r0.x = -_ReduceByUVBorderLength + r0.x;
  r0.y = 1 + -_ReduceByUVBorderLength;
  r0.x = saturate(r0.x / r0.y);
  r0.x = _ReduceByUVBorder * -r0.x + 1;
  r0.yz = float2(unity_ObjectToWorld[0][1], unity_ObjectToWorld[2][1]) * v0.yy;
  r0.yz = float2(unity_ObjectToWorld[0][0], unity_ObjectToWorld[2][0]) * v0.xx + r0.yz;
  r0.yz = float2(unity_ObjectToWorld[0][2], unity_ObjectToWorld[2][2]) * v0.zz + r0.yz;
  r0.yz = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.yz;
  r0.yz = -_Anchor.xz + r0.yz;
  r0.yz = _MapScaleOffset.zw + r0.yz;
  r0.yz = r0.yz / _MapScaleOffset.xy;
  r0.yz = r0.yz * _BaseColormap_ST.xy + _BaseColormap_ST.zw;
  r1.xyzw = _ParallaxMap.SampleLevel(sampler_ParallaxMap, r0.yz, 0).xyzw;
  r0.y = _Parallax * r1.w;
  o2.xyz = r1.xyz;
  r0.y = unity_WorldToObject[1][1] * r0.y;
  r0.z = -1 + v3.w;
  r0.z = _ReduceByVertexAlpha * r0.z + 1;
  r0.y = r0.y * r0.z;
  r0.x = r0.y * r0.x;
  r0.xyz = v1.xyz * r0.xxx + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r1.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r1.xyzw;
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyz = _WorldSpaceCameraPos.xyz + -r0.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  o1.w = sqrt(r0.w);
  o1.xyz = r0.xyz;
  r0.xy = -_Anchor.xz + r0.xz;
  r0.xy = _MapScaleOffset.zw + r0.xy;
  r0.xy = r0.xy / _MapScaleOffset.xy;
  p3.xy = r0.xy * _BaseColormap_ST.xy + _BaseColormap_ST.zw;
  o3.xy = r0.xy;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o4.zw = r1.zw;
  o4.xy = r0.xw + r0.zz;
  return;
}


// ps 8973c024e3c27e2d: 3 retail keyword combination(s)
void ps_8973c024e3c27e2d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float2 v3 : TEXCOORD2,
  float2 w3 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(1,1,1,1) + -_TintSaturation.xyzw;
  r1.xyzw = _BaseColormap.Sample(sampler_BaseColormap, w3.xy).xyzw;
  r2.xyzw = float4(1,1,1,1) + -r1.xyzw;
  r2.xyzw = r2.xyzw + r2.xyzw;
  r0.xyzw = -r2.xyzw * r0.xyzw + float4(1,1,1,1);
  r2.x = dot(r1.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r2.x = cmp(r2.x < 0.5);
  r3.xyzw = _TintSaturation.xyzw + _TintSaturation.xyzw;
  r1.xyzw = r3.xyzw * r1.xyzw;
  r0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  r1.xy = float2(12,12) * w3.xy;
  r1.xyzw = _DetailColormap.Sample(sampler_DetailColormap, r1.xy).xyzw;
  o0.xyzw = r1.xyzw * r0.xyzw;
  o1.xyzw = float4(0,0.5,0.100000001,0);
  r0.xy = v2.xy * float2(-1,1) + float2(1,0);
  r0.xz = r0.xy * float2(2,2) + float2(-1,-1);
  r0.w = dot(r0.xz, r0.xz);
  r0.w = sqrt(r0.w);
  r0.y = 1 + -r0.w;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.xyz = max(float3(-1,-1,-1), r0.xyz);
  r0.xyz = min(float3(1,1,1), r0.xyz);
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(0,0,0,0);
  return;
}


// ps c7f5ed096bb15c39: 3 retail keyword combination(s)
void ps_c7f5ed096bb15c39_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float2 v3 : TEXCOORD2,
  float2 w3 : TEXCOORD3,
  float4 v4 : TEXCOORD8,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(1,1,1,1) + -_TintSaturation.xyzw;
  r1.xyzw = _BaseColormap.Sample(sampler_BaseColormap, w3.xy).xyzw;
  r2.xyzw = float4(1,1,1,1) + -r1.xyzw;
  r2.xyzw = r2.xyzw + r2.xyzw;
  r0.xyzw = -r2.xyzw * r0.xyzw + float4(1,1,1,1);
  r2.x = dot(r1.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r2.x = cmp(r2.x < 0.5);
  r3.xyzw = _TintSaturation.xyzw + _TintSaturation.xyzw;
  r1.xyzw = r3.xyzw * r1.xyzw;
  r0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  r1.xy = float2(12,12) * w3.xy;
  r1.xyzw = _DetailColormap.Sample(sampler_DetailColormap, r1.xy).xyzw;
  o0.xyzw = r1.xyzw * r0.xyzw;
  o1.xyzw = float4(0,0.5,0.100000001,0);
  r0.xy = v2.xy * float2(-1,1) + float2(1,0);
  r0.xz = r0.xy * float2(2,2) + float2(-1,-1);
  r0.w = dot(r0.xz, r0.xz);
  r0.w = sqrt(r0.w);
  r0.y = 1 + -r0.w;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.xyz = max(float3(-1,-1,-1), r0.xyz);
  r0.xyz = min(float3(1,1,1), r0.xyz);
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  o3.xyzw = float4(0,0,0,0);
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(SHADOWS_SCREEN)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float2 o3 = 0;
		float2 p3 = 0;
		vs_7f51a7baf524e070_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.color0, o0, o1, o2, o3, p3);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2.xy = o3;
		o.texcoord3.xy = p3;
	}
#elif defined(SHADOWS_SCREEN)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float2 o3 = 0;
		float2 p3 = 0;
		float4 o4 = 0;
		vs_beb24ac1411880e3_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.color0, o0, o1, o2, o3, p3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2.xy = o3;
		o.texcoord3.xy = p3;
		o.texcoord8 = o4;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(SHADOWS_SCREEN)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_8973c024e3c27e2d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2.xy, i.texcoord3.xy, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(SHADOWS_SCREEN)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_c7f5ed096bb15c39_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2.xy, i.texcoord3.xy, i.texcoord8, o0, o1, o2, o3);
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
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" "ShadowSupport"="true" }
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ SHADOWS_CUBE
			#pragma multi_compile _ SHADOWS_DEPTH
			#pragma multi_compile _ _WATER_OFF

#define cmp -

Texture2D _ParallaxMap;
SamplerState sampler_ParallaxMap;

float4 _BaseColormap_ST;
float4 _MapScaleOffset;
float3 _Anchor;
float _Parallax;
float _ReduceByVertexAlpha;
float _ReduceByUVBorder;
float _ReduceByUVBorderLength;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
};

#if defined(SHADOWS_DEPTH)
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#elif !defined(SHADOWS_DEPTH)
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
};

// vs 2b383771762fcc7b: 1 retail keyword combination(s)
void vs_2b383771762fcc7b_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : COLOR0,
  inout float4 o0 : SV_POSITION0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(unity_ObjectToWorld[0][1], unity_ObjectToWorld[2][1]) * v0.yy;
  r0.xy = float2(unity_ObjectToWorld[0][0], unity_ObjectToWorld[2][0]) * v0.xx + r0.xy;
  r0.xy = float2(unity_ObjectToWorld[0][2], unity_ObjectToWorld[2][2]) * v0.zz + r0.xy;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xy;
  r0.xy = -_Anchor.xz + r0.xy;
  r0.xy = _MapScaleOffset.zw + r0.xy;
  r0.xy = r0.xy / _MapScaleOffset.xy;
  r0.xy = r0.xy * _BaseColormap_ST.xy + _BaseColormap_ST.zw;
  r0.xyzw = _ParallaxMap.SampleLevel(sampler_ParallaxMap, r0.xy, 0).xyzw;
  r1.x = dot(r0.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(r0.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(r0.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.x = _Parallax * r0.w;
  r0.x = unity_WorldToObject[1][1] * r0.x;
  r0.y = dot(r1.xyz, r1.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = r1.xyz * r0.yyy;
  r1.x = -1 + v3.w;
  r1.x = _ReduceByVertexAlpha * r1.x + 1;
  r0.x = r1.x * r0.x;
  r1.xy = float2(-0.5,-0.5) + v2.xy;
  r1.xy = r1.xy + r1.xy;
  r1.x = max(abs(r1.x), abs(r1.y));
  r1.x = -_ReduceByUVBorderLength + r1.x;
  r1.y = 1 + -_ReduceByUVBorderLength;
  r1.x = saturate(r1.x / r1.y);
  r1.x = _ReduceByUVBorder * -r1.x + 1;
  r0.x = r0.x * r1.x + v0.y;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.xxxx;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r1.xyzw;
  r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  r0.x = dot(r2.xyz, r2.xyz);
  r0.x = rsqrt(r0.x);
  r2.xyz = r2.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r2.xyz);
  r0.x = -r0.x * r0.x + 1;
  r0.x = sqrt(r0.x);
  r0.x = unity_LightShadowBias.z * r0.x;
  r0.xyz = -r0.yzw * r0.xxx + r1.xyz;
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


// vs d45b65a7a1985aa1: 1 retail keyword combination(s)
void vs_d45b65a7a1985aa1_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  float4 v3 : COLOR0,
  inout float4 o0 : SV_POSITION0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(unity_ObjectToWorld[0][1], unity_ObjectToWorld[2][1]) * v0.yy;
  r0.xy = float2(unity_ObjectToWorld[0][0], unity_ObjectToWorld[2][0]) * v0.xx + r0.xy;
  r0.xy = float2(unity_ObjectToWorld[0][2], unity_ObjectToWorld[2][2]) * v0.zz + r0.xy;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xy;
  r0.xy = -_Anchor.xz + r0.xy;
  r0.xy = _MapScaleOffset.zw + r0.xy;
  r0.xy = r0.xy / _MapScaleOffset.xy;
  r0.xy = r0.xy * _BaseColormap_ST.xy + _BaseColormap_ST.zw;
  r0.xyzw = _ParallaxMap.SampleLevel(sampler_ParallaxMap, r0.xy, 0).xyzw;
  r1.x = dot(r0.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(r0.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(r0.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.x = _Parallax * r0.w;
  r0.x = unity_WorldToObject[1][1] * r0.x;
  r0.y = dot(r1.xyz, r1.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = r1.xyz * r0.yyy;
  r1.x = -1 + v3.w;
  r1.x = _ReduceByVertexAlpha * r1.x + 1;
  r0.x = r1.x * r0.x;
  r1.xy = float2(-0.5,-0.5) + v2.xy;
  r1.xy = r1.xy + r1.xy;
  r1.x = max(abs(r1.x), abs(r1.y));
  r1.x = -_ReduceByUVBorderLength + r1.x;
  r1.y = 1 + -_ReduceByUVBorderLength;
  r1.x = saturate(r1.x / r1.y);
  r1.x = _ReduceByUVBorder * -r1.x + 1;
  r0.x = r0.x * r1.x + v0.y;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.xxxx;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) * v0.wwww + r1.xyzw;
  r2.xyz = -r1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
  r0.x = dot(r2.xyz, r2.xyz);
  r0.x = rsqrt(r0.x);
  r2.xyz = r2.xyz * r0.xxx;
  r0.x = dot(r0.yzw, r2.xyz);
  r0.x = -r0.x * r0.x + 1;
  r0.x = sqrt(r0.x);
  r0.x = unity_LightShadowBias.z * r0.x;
  r0.xyz = -r0.yzw * r0.xxx + r1.xyz;
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


// ps 8dc2c81abf29c14b: 2 retail keyword combination(s)
void ps_8dc2c81abf29c14b_impl(
  float4 v0 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = float4(0,0,0,0);
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if defined(SHADOWS_DEPTH)
	{
		float4 o0 = 0;
		vs_2b383771762fcc7b_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.color0, o0);
		o.sv_position = o0;
	}
#elif !defined(SHADOWS_DEPTH)
	{
		float4 o0 = 0;
		vs_d45b65a7a1985aa1_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, v.color0, o0);
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
		ps_8dc2c81abf29c14b_impl(i.sv_position, o0);
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
