Shader "BattleTech/VFX/VFX-Deferred"
{
	Properties
	{
		_TintColor ("Base Color", Color) = (0,0,0,1)
		_MainTex ("Base", 2D) = "white" {}
		[HDR] _ColorBB ("Emissive", Color) = (0,0,0,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		[Gamma] _Metallic ("Metallic", Range(0,1)) = 0
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
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

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture3D _DitherMaskLOD;
SamplerState sampler_DitherMaskLOD;

float4 _MainTex_ST;
float4 _ColorBB;
float4 _TintColor;
float _Cutoff;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 normal0 : NORMAL0;
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

// vs 2e5c6cf661c1ba72: 1 retail keyword combination(s)
void vs_2e5c6cf661c1ba72_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3)
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
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  o2.xyz = r1.xyz * r1.www;
  o3.xyzw = v1.xyzw;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o4.zw = r0.zw;
  r0.xy = r1.xw + r1.zz;
  r0.xy = _ScreenParams.xy * r0.xy;
  o4.xy = float2(0.25,0.25) * r0.xy;
  return;
}


// ps 84bc0843a441c47e: 1 retail keyword combination(s)
void ps_84bc0843a441c47e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1,
  inout float4 o2 : SV_Target2,
  inout float4 o3 : SV_Target3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.w = -_Cutoff + r0.w;
  r0.w = cmp(r0.w < 0);
  clip(r0.w != 0 ? -1 : 1);
  r1.xy = v4.xy / v4.ww;
  r2.xyzw = _TintColor.xyzw * v3.xyzw;
  r1.z = 0.9375 * r2.w;
  o0.xyz = r2.xyz * r0.xyz;
  r0.xyzw = _DitherMaskLOD.Sample(sampler_DitherMaskLOD, r1.xyz).xyzw;
  r0.x = -0.00999999978 + r0.w;
  r0.x = cmp(r0.x < 0);
  clip(r0.x != 0 ? -1 : 1);
  o0.w = 1;
  o1.xyzw = float4(0,0,0,0);
  o2.xyz = v2.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o2.w = 0;
  r0.x = v2.y * v2.y;
  r0.x = v2.x * v2.x + -r0.x;
  r1.xyzw = v2.xyzz * v2.yzzx;
  r2.x = dot(unity_SHBr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHBg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHBb.xyzw, r1.xyzw);
  r0.xyz = unity_SHC.xyz * r0.xxx + r2.xyz;
  r1.xyz = v2.xyz;
  r1.w = 1;
  r2.x = dot(unity_SHAr.xyzw, r1.xyzw);
  r2.y = dot(unity_SHAg.xyzw, r1.xyzw);
  r2.z = dot(unity_SHAb.xyzw, r1.xyzw);
  r0.xyz = r2.xyz + r0.xyz;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  o3.xyz = _ColorBB.xyz + r0.xyz;
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
		float4 o4 = 0;
		vs_2e5c6cf661c1ba72_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
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
		ps_84bc0843a441c47e_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0, o1, o2, o3);
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
