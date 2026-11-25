Shader "Unlit/BT-IceSurface"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_NormalTex ("Normal", 2D) = "bump" {}
		_MaskTex ("Mask Texture", 2D) = "black" {}
		_SnowTex ("Snow Texture", 2D) = "white" {}
		_SnowNormalTex ("Snow Normal", 2D) = "bump" {}
		_SmoothnessTex ("Smoothness Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "Queue"="AlphaTest+4" }
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

Texture2D _MaskTex;
SamplerState sampler_MaskTex;
Texture2D _SnowTex;
SamplerState sampler_SnowTex;
Texture2D _SnowNormalTex;
SamplerState sampler_SnowNormalTex;
Texture2D _SmoothnessTex;
SamplerState sampler_SmoothnessTex;
Texture2D _NormalTex;
SamplerState sampler_NormalTex;

float4 BT_SHAr;
float4 BT_SHAg;
float4 BT_SHAb;
float4 BT_SHC;
float3 _Color;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 tangent0 : TANGENT0;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
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

// vs c55b02d9634eec10: 1 retail keyword combination(s)
void vs_c55b02d9634eec10_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TANGENT0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float3 o4 : TEXCOORD3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  o1.xy = float2(0.00999999978,0.00999999978) * r0.xy;
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v2.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v2.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v2.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz;
  r1.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.xyz = r1.zxy * r0.yzx;
  r0.xyz = r1.yzx * r0.zxy + -r2.xyz;
  o4.xyz = r1.xyz;
  r0.w = unity_WorldTransformParams.w * v2.w;
  o3.xyz = r0.xyz * r0.www;
  return;
}


// ps 9f5fdce3f958658d: 1 retail keyword combination(s)
void ps_9f5fdce3f958658d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.w = 1;
  r0.xyzw = _SnowTex.Sample(sampler_SnowTex, v1.xy).xyzw;
  r0.xyz = -_Color.xyz + r0.xyz;
  r1.xy = float2(0.5,0.5) * v1.xy;
  r1.xyzw = _MaskTex.Sample(sampler_MaskTex, r1.xy).xyzw;
  o0.xyz = r1.xxx * r0.xyz + _Color.xyz;
  r2.xyzw = _SmoothnessTex.Sample(sampler_SmoothnessTex, v1.xy).xyzw;
  r0.x = -r2.x + r0.w;
  o1.z = r1.x * r0.x + r2.x;
  o1.y = 1 + -r1.x;
  o1.xw = float2(0,0);
  r0.xyzw = _SnowNormalTex.Sample(sampler_SnowNormalTex, v1.xy).xyzw;
  r0.x = r0.x * r0.w;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.w = dot(r0.xy, r0.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.z = sqrt(r0.w);
  r2.xyzw = _NormalTex.Sample(sampler_NormalTex, v1.xy).xyzw;
  r2.x = r2.x * r2.w;
  r2.xy = r2.xy * float2(2,2) + float2(-1,-1);
  r0.w = dot(r2.xy, r2.xy);
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r2.z = sqrt(r0.w);
  r0.xyz = -r2.xyz + r0.xyz;
  r0.xyz = r1.xxx * r0.xyz + r2.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r1.xyz = v3.xyz * r0.yyy;
  r0.xyw = v2.xyz * r0.xxx + r1.xyz;
  r0.xyz = v4.xyz * r0.zzz + r0.xyw;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o2.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r0.x = dot(BT_SHAr.yw, float2(1,1));
  r0.y = dot(BT_SHAg.yw, float2(1,1));
  r0.z = dot(BT_SHAb.yw, float2(1,1));
  o3.xyz = -BT_SHC.xyz + r0.xyz;
  o3.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float3 o4 = 0;
		vs_c55b02d9634eec10_impl(v.position0, v.normal0.xyz, v.tangent0, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3.xyz = o4;
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
		ps_9f5fdce3f958658d_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0, o1, o2, o3);
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
