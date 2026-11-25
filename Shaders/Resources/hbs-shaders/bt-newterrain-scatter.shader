Shader "NewTerrain/TerrainScatter"
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
		_OcclusionStrength ("Strength", Range(0,1)) = 1
		_OcclusionMap ("Occlusion", 2D) = "white" {}
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
			#pragma multi_compile _ INSTANCING_ON

#define cmp -

Texture2D _BT_TerrainRadiance;
SamplerState sampler_BT_TerrainRadiance;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _MetallicGlossMap;
SamplerState sampler_MetallicGlossMap;
Texture2D _BumpMap;
SamplerState sampler_BumpMap;
Texture2D _OcclusionMap;
SamplerState sampler_OcclusionMap;

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
float4 _MainTex_ST;
float4 _Color;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	uint sv_instanceid0 : SV_InstanceID;
	float4 tangent0 : TANGENT0;
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
};
#elif defined(INSTANCING_ON)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
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

// vs 8a6496e7d10745ea: 1 retail keyword combination(s)
void vs_8a6496e7d10745ea_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TANGENT0,
  float2 v3 : TEXCOORD0,
  inout float2 o0 : TEXCOORD0,
  inout float4 o1 : SV_POSITION0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r0.xy = float2(1024,1024) + r0.xy;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_TerrainRadiance.SampleLevel(sampler_BT_TerrainRadiance, r0.xy, 0).xyzw;
  o2.xyz = r0.xyz;
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  o1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v2.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v2.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v2.zzz + r0.xyz;
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
  r0.w = unity_WorldTransformParams.w * v2.w;
  o4.xyz = r0.xyz * r0.www;
  o4.w = 0;
  o5.w = 0;
  return;
}


// vs 2133f1ac0656cb8f: 1 retail keyword combination(s)
void vs_2133f1ac0656cb8f_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TANGENT0,
  float2 v3 : TEXCOORD0,
  uint v4 : SV_InstanceID0,
  inout float2 o0 : TEXCOORD0,
  inout float4 o1 : SV_POSITION0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v4.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.x = (int)v4.x + asint(unity_BaseInstanceID);
  r0.x = (uint)r0.x << 3;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][1]) * v0.yyyy;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][0]) * v0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][2]) * v0.zzzz + r1.xyzw;
  r2.xyzw = float4(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[3][3]) + r1.xyzw;
  r0.yz = float2(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][3], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][3]) * v0.ww + r1.xz;
  r0.yz = float2(1024,1024) + r0.yz;
  r0.yz = float2(0.00048828125,0.00048828125) * r0.yz;
  r1.xyzw = _BT_TerrainRadiance.SampleLevel(sampler_BT_TerrainRadiance, r0.yz, 0).xyzw;
  o2.xyz = r1.xyz;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r2.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r2.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r2.zzzz + r1.xyzw;
  o1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r2.wwww + r1.xyzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][1]) * v2.yyy;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][0]) * v2.xxx + r0.yzw;
  r0.yzw = float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_ObjectToWorldArray[2][2]) * v2.zzz + r0.yzw;
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r0.yzw = r1.xxx * r0.yzw;
  o3.xyz = r0.yzw;
  o3.w = 0;
  r1.x = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][0], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][0]));
  r1.y = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][1], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][1]));
  r1.z = dot(v1.xyz, float3(unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[0][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[1][2], unity_Builtins0Array[(uint)(r0.x) / 8u].unity_WorldToObjectArray[2][2]));
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r1.xyz = r1.xyz * r0.xxx;
  r2.xyz = r1.zxy * r0.zwy;
  r0.xyz = r1.yzx * r0.wyz + -r2.xyz;
  o5.xyz = r1.xyz;
  r0.w = unity_WorldTransformParams.w * v2.w;
  o4.xyz = r0.xyz * r0.www;
  o4.w = 0;
  o5.w = 0;
  return;
}


// ps f7ae8653c5dddea3: 2 retail keyword combination(s)
void ps_f7ae8653c5dddea3_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v0.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.xyzw = _OcclusionMap.Sample(sampler_OcclusionMap, v0.xy).xyzw;
  o0.w = r0.x;
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
  o3.xyz = v2.xyz;
  o3.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(INSTANCING_ON)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_8a6496e7d10745ea_impl(v.position0, v.normal0.xyz, v.tangent0, v.texcoord0.xy, o0, o1, o2, o3, o4, o5);
		o.texcoord0.xy = o0;
		o.sv_position = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
	}
#elif defined(INSTANCING_ON)
	{
		float2 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_2133f1ac0656cb8f_impl(v.position0, v.normal0.xyz, v.tangent0, v.texcoord0.xy, v.sv_instanceid0, o0, o1, o2, o3, o4, o5);
		o.texcoord0.xy = o0;
		o.sv_position = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
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
		float4 o2 = 0;
		float4 o3 = 0;
		ps_f7ae8653c5dddea3_impl(i.texcoord0.xy, i.sv_position, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0, o1, o2, o3);
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
