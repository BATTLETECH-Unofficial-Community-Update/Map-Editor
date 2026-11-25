Shader "BattleTech/VFX/Distortion"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Base", 2D) = "white" {}
		_Refraction ("Refraction", Range(0,1)) = 1
		_DistortTex ("Distortion (R,G)", 2D) = "bump" {}
		_DistortSpeed ("UV Distortion Speed (X,Y)", Vector) = (0,0,0,0)
		_DepthFade ("Depth Fade Factor", Float) = 1
		[MaterialToggle(_FRESNEL)] _Fresnel ("Use Fresnel", Float) = 0
		_FresnelPower ("Fresnel Power", Float) = 2
	}
	SubShader
	{
		Tags { "Queue"="Overlay" }
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _FRESNEL
			#pragma multi_compile _ _VFX_DEPTH_SAMPLE

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _DepthDownsampleVFX;
SamplerState sampler_DepthDownsampleVFX;
Texture2D _DistortTex;
SamplerState sampler_DistortTex;
Texture2D _BT_BlurTexture;
SamplerState sampler_BT_BlurTexture;

float4 _Color;
float4 _DistortSpeed;
float4 _MainTex_ST;
float _FresnelPower;
float _Refraction;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord7 : TEXCOORD7;
	float4 texcoord8 : TEXCOORD8;
};
#elif defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord6 : TEXCOORD6;
	float4 texcoord7 : TEXCOORD7;
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
};

// vs 0b81732d64f3b040: 1 retail keyword combination(s)
void vs_0b81732d64f3b040_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD1,
  inout float4 o4 : TEXCOORD7,
  inout float3 o5 : TEXCOORD8)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r0.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r0.w = _ProjectionParams.x * r1.y;
  r2.w = 0.5 * r0.w;
  r2.xz = float2(0.5,0.5) * r1.xw;
  o3.zw = r1.zw;
  o3.xy = r2.xw + r2.zz;
  r1.x = dot(v3.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(v3.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(v3.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  o4.xyz = r1.xyz * r0.www;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o5.xyz = r0.xyz * r0.www;
  return;
}


// vs 27c39059b9dc00b2: 1 retail keyword combination(s)
void vs_27c39059b9dc00b2_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float2 o2 : TEXCOORD0,
  inout float2 p2 : TEXCOORD6,
  inout float4 o3 : TEXCOORD1,
  inout float4 o4 : TEXCOORD7,
  inout float3 o5 : TEXCOORD8)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r0.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = v1.xyzw;
  p2.xy = r1.zw;
  o3.zw = r1.zw;
  o2.xy = v2.xy;
  r0.w = _ProjectionParams.x * r1.y;
  r1.xz = float2(0.5,0.5) * r1.xw;
  r1.w = 0.5 * r0.w;
  o3.xy = r1.xw + r1.zz;
  r1.x = dot(v3.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r1.y = dot(v3.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r1.z = dot(v3.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  o4.xyz = r1.xyz * r0.www;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o5.xyz = r0.xyz * r0.www;
  return;
}


// ps c10850ead3a9e132: 1 retail keyword combination(s)
void ps_c10850ead3a9e132_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD7,
  float3 v5 : TEXCOORD8,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v4.xyz, v4.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v4.xyz * r0.xxx;
  r0.w = dot(v5.xyz, v5.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v5.xyz * r0.www;
  r0.x = dot(r0.xyz, -r1.xyz);
  r0.x = log2(r0.x);
  r0.x = _FresnelPower * r0.x;
  r0.x = exp2(r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r0.y = _Color.w * r1.w;
  r0.y = v1.w * r0.y;
  o0.w = saturate(r0.y * r0.x);
  r0.xy = _DistortSpeed.xy * _Time.xx + v2.xy;
  r0.xyzw = _DistortTex.Sample(sampler_DistortTex, r0.xy).xyzw;
  r0.xy = r0.yw * float2(2,2) + float2(-1,-1);
  r0.xy = _Refraction.xx * r0.xy;
  r0.zw = v3.xy / v3.ww;
  r0.xy = r0.xy * float2(0.0500000007,0.0500000007) + r0.zw;
  r0.xyzw = _BT_BlurTexture.Sample(sampler_BT_BlurTexture, r0.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  return;
}


// ps 5a963e25213939fc: 1 retail keyword combination(s)
void ps_5a963e25213939fc_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD7,
  float3 v5 : TEXCOORD8,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.zw = _DistortSpeed.xy * _Time.xx + v2.xy;
  r2.xyzw = _DistortTex.Sample(sampler_DistortTex, r0.zw).xyzw;
  r0.zw = r2.yw * float2(2,2) + float2(-1,-1);
  r0.zw = _Refraction.xx * r0.zw;
  r0.xy = r0.zw * float2(0.0500000007,0.0500000007) + r0.xy;
  r0.xyzw = _BT_BlurTexture.Sample(sampler_BT_BlurTexture, r0.xy).xyzw;
  o0.xyz = _Color.xyz * r0.xyz;
  r0.x = _Color.w * r1.w;
  r0.x = v1.w * r0.x;
  r0.y = dot(v4.xyz, v4.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v4.xyz * r0.yyy;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  r0.y = dot(r0.yzw, -r1.xyz);
  r0.y = log2(r0.y);
  r0.y = _FresnelPower * r0.y;
  r0.y = exp2(r0.y);
  o0.w = saturate(r0.x * r0.y);
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_0b81732d64f3b040_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord7 = o4;
		o.texcoord8.xyz = o5;
	}
#elif defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_27c39059b9dc00b2_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord1 = o3;
		o.texcoord7 = o4;
		o.texcoord8.xyz = o5;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_c10850ead3a9e132_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord7, i.texcoord8.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5a963e25213939fc_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord7, i.texcoord8.xyz, o0);
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
