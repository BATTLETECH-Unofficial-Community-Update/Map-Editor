Shader "Hidden/TerrainEngine/Details/Vertexlit"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		[Gamma] _Metallic ("Metallic", Range(0,1)) = 0
		_MetallicGlossMap ("Metallic", 2D) = "white" {}
		_BumpScale ("Scale", Float) = 1
		_BumpMap ("Normal Map", 2D) = "bump" {}
		[MaterialToggle(_PLACED)] _PlacedObject ("PlacedObject", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
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
			#pragma multi_compile _ _DETAIL_BIOME
			#pragma multi_compile _ _PLACED
			#pragma multi_compile _ _PROBEARRAY

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _BT_DetailAlbedo;
SamplerState sampler_BT_DetailAlbedo;
Texture2D _BT_TerrainRadiance;
SamplerState sampler_BT_TerrainRadiance;
Texture2D _MetallicGlossMap;
SamplerState sampler_MetallicGlossMap;
Texture2D _BT_DetailMetallic;
SamplerState sampler_BT_DetailMetallic;
Texture2D _BumpMap;
SamplerState sampler_BumpMap;
Texture2D _BT_DetailNormal;
SamplerState sampler_BT_DetailNormal;

float4 _MainTex_ST;
float4 BT_SHAr;
float4 BT_SHAg;
float4 BT_SHAb;
float4 BT_SHBr;
float4 BT_SHBg;
float4 BT_SHBb;
float4 BT_SHC;
float _BT_DetailDistance;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 tangent0 : TANGENT0;
	float4 texcoord0 : TEXCOORD0;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
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

// vs c4c6c668c2bf3725: 4 retail keyword combination(s)
void vs_c4c6c668c2bf3725_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TANGENT0,
  float2 v3 : TEXCOORD0,
  inout float2 o0 : TEXCOORD0,
  inout float4 o1 : SV_POSITION0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float3 o6 : TEXCOORD5)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r1.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o6.xyz = r0.xyz;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = sqrt(r0.x);
  r0.x = -_BT_DetailDistance * 0.899999976 + r0.x;
  r0.y = 0.100000024 * _BT_DetailDistance;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.x = sqrt(r0.x);
  r0.x = -r0.x * 2 + v0.y;
  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.xxxx;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  o1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r1.x = r0.y * r0.y;
  r1.x = r0.x * r0.x + -r1.x;
  r2.xyzw = r0.xyzz * r0.yzzx;
  r3.x = dot(BT_SHBr.xyzw, r2.xyzw);
  r3.y = dot(BT_SHBg.xyzw, r2.xyzw);
  r3.z = dot(BT_SHBb.xyzw, r2.xyzw);
  r1.xyz = BT_SHC.xyz * r1.xxx + r3.xyz;
  r0.w = 1;
  r2.x = dot(BT_SHAr.xyzw, r0.xyzw);
  r2.y = dot(BT_SHAg.xyzw, r0.xyzw);
  r2.z = dot(BT_SHAb.xyzw, r0.xyzw);
  o2.xyz = r2.xyz + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v2.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v2.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v2.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  o3.xyz = r1.xyz;
  o3.w = 0;
  r2.xyz = r1.yzx * r0.zxy;
  r1.xyz = r0.yzx * r1.zxy + -r2.xyz;
  o5.xyz = r0.xyz;
  r0.x = unity_WorldTransformParams.w * v2.w;
  o4.xyz = r1.xyz * r0.xxx;
  o4.w = 0;
  o5.w = 0;
  return;
}


// ps 67d3108c6f0c052c: 1 retail keyword combination(s)
void ps_67d3108c6f0c052c_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v0.xy).xyzw;
  o0.xyz = r0.xyz;
  o0.w = 1;
  o1.xyzw = float4(0,0.5,0.100000001,1);
  o2.xyz = v5.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r0.xy = float2(1024,1024) + v6.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_TerrainRadiance.Sample(sampler_BT_TerrainRadiance, r0.xy).xyzw;
  o3.xyz = r0.xyz;
  o3.w = 1;
  return;
}


// ps c2285afd6a8dfece: 2 retail keyword combination(s)
void ps_c2285afd6a8dfece_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v0.xy).xyzw;
  o0.xyz = r0.xyz;
  o0.w = 1;
  r0.xyzw = _MetallicGlossMap.Sample(sampler_MetallicGlossMap, v0.xy).xyzw;
  o1.xz = r0.xw;
  o1.yw = float2(0.5,1);
  r0.xyzw = _BumpMap.Sample(sampler_BumpMap, v0.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
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
  o2.w = 0;
  r0.xy = float2(1024,1024) + v6.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_TerrainRadiance.Sample(sampler_BT_TerrainRadiance, r0.xy).xyzw;
  o3.xyz = r0.xyz;
  o3.w = 1;
  return;
}


// ps 2ac0eba03ab0e7e7: 1 retail keyword combination(s)
void ps_2ac0eba03ab0e7e7_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BT_DetailAlbedo.Sample(sampler_BT_DetailAlbedo, v0.xy).xyzw;
  o0.xyz = r0.xyz;
  o0.w = 1;
  r0.xyzw = _BT_DetailMetallic.Sample(sampler_BT_DetailMetallic, v0.xy).xyzw;
  o1.xz = r0.xw;
  o1.yw = float2(0.5,1);
  r0.xyzw = _BT_DetailNormal.Sample(sampler_BT_DetailNormal, v0.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
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
  o2.w = 0;
  r0.xy = float2(1024,1024) + v6.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_TerrainRadiance.Sample(sampler_BT_TerrainRadiance, r0.xy).xyzw;
  o3.xyz = r0.xyz;
  o3.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_c4c6c668c2bf3725_impl(v.position0, v.normal0.xyz, v.tangent0, v.texcoord0.xy, o0, o1, o2, o3, o4, o5, o6);
		o.texcoord0.xy = o0;
		o.sv_position = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_DETAIL_BIOME) && !defined(_PLACED)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_67d3108c6f0c052c_impl(i.texcoord0.xy, i.sv_position, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(_PLACED)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_c2285afd6a8dfece_impl(i.texcoord0.xy, i.sv_position, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
		r.t0 = o0;
		r.t1 = o1;
		r.t2 = o2;
		r.t3 = o3;
	}
#elif defined(_DETAIL_BIOME) && !defined(_PLACED)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_2ac0eba03ab0e7e7_impl(i.texcoord0.xy, i.sv_position, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0, o1, o2, o3);
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
