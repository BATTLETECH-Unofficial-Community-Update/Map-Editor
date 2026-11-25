Shader "Hidden/BT-DistantTerrain"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "Queue"="AlphaTest+2" "RenderType"="Opaque" }
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

#define cmp -

Texture2D _BT_TerrainAlbedo;
SamplerState sampler_BT_TerrainAlbedo;
Texture2D _BT_TerrainNormal;
SamplerState sampler_BT_TerrainNormal;

float4 BT_SHAr;
float4 BT_SHAg;
float4 BT_SHAb;
float4 BT_SHBr;
float4 BT_SHBg;
float4 BT_SHBb;
float4 BT_SHC;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
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
	float4 t3 : SV_Target3;
};

// vs ca01a9cb31b85ce5: 1 retail keyword combination(s)
void vs_ca01a9cb31b85ce5_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float3 o2 : TEXCOORD1)
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
  o1.xy = v1.yx;
  r0.x = dot(v2.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v2.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v2.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r0.xyz * r0.www;
  return;
}


// ps 4908004ee7fc2b16: 1 retail keyword combination(s)
void ps_4908004ee7fc2b16_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.w = 1;
  r0.xyzw = _BT_TerrainAlbedo.Sample(sampler_BT_TerrainAlbedo, v1.xy).xyzw;
  o0.xyz = r0.xyz;
  o1.z = r0.w;
  o1.xyw = float3(0,0.5,0);
  r0.xyz = float3(0,1,0) * v2.yzx;
  r0.xyz = v2.zxy * float3(0,0,1) + -r0.xyz;
  r1.xyzw = _BT_TerrainNormal.Sample(sampler_BT_TerrainNormal, v1.xy).xyzw;
  r1.xy = r1.wy * float2(2,2) + float2(-1,-1);
  r0.xyz = r1.yyy * r0.xyz;
  r0.xyz = r1.xxx * float3(1,0,0) + r0.xyz;
  r0.w = dot(r1.xy, r1.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = sqrt(r0.w);
  r0.xyz = v2.xyz * r0.www + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0.333333343;
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
  o3.xyz = r2.xyz + r1.xyz;
  o3.w = 0;
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
		vs_ca01a9cb31b85ce5_impl(v.position0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2);
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
	fout r;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		ps_4908004ee7fc2b16_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0, o1, o2, o3);
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
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ SHADOWS_CUBE
			#pragma multi_compile _ SHADOWS_DEPTH

#define cmp -



struct appdata
{
	float4 position0 : POSITION0;
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


// ps 5b3349ebfd951ea3: 2 retail keyword combination(s)
void ps_5b3349ebfd951ea3_impl(
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
		vs_aa4b0478faaa884a_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0);
		o.sv_position = o0;
	}
#elif !defined(SHADOWS_DEPTH)
	{
		float4 o0 = 0;
		vs_d4c082007ab5ea9a_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0);
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
		ps_5b3349ebfd951ea3_impl(o0);
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
