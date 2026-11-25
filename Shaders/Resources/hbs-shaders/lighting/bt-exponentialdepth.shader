// <copyright file="bt-exponentialdepth.shader" company="BattleTech">
//     Copyright (c) BattleTech. All rights reserved.
// </copyright>
//
// RECOVERED from the retail Shader asset, not hand-written.
//
//   source asset : Assets\Resources\lighting\bt-exponentialdepth.asset
//   retail GUID  : 3d2e3fed7e2ecd9439f351fcb316b199
//   retail form  : Shader "Hidden/BT-ExponentialDepth", 1 SubShader, 1 pass, 32 program entries
//                  (4 unique VS, 6 unique PS) over {_HAIR, _SKIPSHADOW, _ALPHATEST_ON,
//                  _ALPHABLEND_ON, _ALPHAPREMULTIPLY_ON}
//
// The name is VESTIGIAL. Not one retail pixel program writes exponential depth: they are
// `mov o0.xyzw, l(0,0,0,0)` plus discards, so the depth in the shadow atlas is the rasteriser's
// SV_Position.z. What the vertex programs add is a NORMAL-OFFSET BIAS:
//
//     toEye = normalize(_WorldSpaceCameraPos - posWS)      // the SHADOW camera, i.e. the light
//     n     = normalize(normal)
//     posWS -= n * (sqrt(1 - dot(n, toEye)^2) * 0.005)     // 0.005 is a retail literal
//
// `BTLightController.RenderShadow` (`:469-483`) renders this through
// `shadowCamera.RenderWithShader(shadowShader, "RenderType")`, so this SubShader must declare the
// same RenderType tag as the materials being rendered. The portrait rig's shaders are both
// `RenderType = Opaque` and the retail asset's own SubShader tag is `Opaque`, so the tag is carried
// verbatim and matches.
//
// STATE, from the retail asset's m_State: blend off (src One, dst Zero, ColMask 15 on rt0..7),
// zClip 1, zTest 4 (LEqual), zWrite 1 (On), culling 2 (Back), offset 0/0, alphaToMask 0, stencil
// pass/fail/zFail 0/0/0 with comp 8 (Always) on both faces -> stencil unused.
//
// DIFFERENTIAL STATUS: see diff/diff.tsv. Every one of the 32 retail (stage x combination) programs
// is compiled from this file with the same defines and compared instruction for instruction against
// the retail DXBC.
Shader "Hidden/BT-ExponentialDepth"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "PerformanceChecks"="False" "RenderType"="Opaque" }
		Pass
		{
			Blend Off
			ColorMask RGBA
			Cull Back
			ZClip On
			ZTest LEqual
			ZWrite On
			Offset 0, 0

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _ALPHABLEND_ON
			#pragma multi_compile _ _ALPHAPREMULTIPLY_ON
			#pragma multi_compile _ _ALPHATEST_ON
			#pragma multi_compile _ _HAIR
			#pragma multi_compile _ _SKIPSHADOW

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture3D _DitherMaskLOD;
SamplerState sampler_DitherMaskLOD;

float4 _MainTex_ST;
float4 _Color;
float _Cutoff;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(_ALPHABLEND_ON) && !defined(_ALPHAPREMULTIPLY_ON) && !defined(_ALPHATEST_ON)
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#elif defined(_ALPHATEST_ON)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord1 : TEXCOORD1;
};
#elif defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
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

// vs 70b5ba79e5a5543c: 4 retail keyword combination(s)
void vs_70b5ba79e5a5543c_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) + r0.xyz;
  r1.xyz = _WorldSpaceCameraPos.xyz + -r0.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r2.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r2.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(r2.xyz, r1.xyz);
  r0.w = -r0.w * r0.w + 1;
  r0.w = sqrt(r0.w);
  r0.w = 0.00499999989 * r0.w;
  r0.xyz = -r2.xyz * r0.www + r0.xyz;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r0.xyzw;
  return;
}


// vs 481ddc3cae839967: 4 retail keyword combination(s)
void vs_481ddc3cae839967_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD1)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) + r0.xyz;
  r1.xyz = _WorldSpaceCameraPos.xyz + -r0.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r2.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r2.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(r2.xyz, r1.xyz);
  r0.w = -r0.w * r0.w + 1;
  r0.w = sqrt(r0.w);
  r0.w = 0.00499999989 * r0.w;
  r0.xyz = -r2.xyz * r0.www + r0.xyz;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r0.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// vs 5ec64a6af4484f49: 8 retail keyword combination(s)
void vs_5ec64a6af4484f49_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD1,
  inout float4 o2 : TEXCOORD2)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) + r0.xyz;
  r1.xyz = _WorldSpaceCameraPos.xyz + -r0.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r2.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r2.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = dot(r2.xyz, r1.xyz);
  r0.w = -r0.w * r0.w + 1;
  r0.w = sqrt(r0.w);
  r0.w = 0.00499999989 * r0.w;
  r0.xyz = -r2.xyz * r0.www + r0.xyz;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r0.xyzw;
  o0.xyzw = r0.xyzw;
  o2.xyzw = r0.xyzw;
  o1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
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


// ps 36468a64c0bd2231: 2 retail keyword combination(s)
void ps_36468a64c0bd2231_impl(
  float4 v0 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  clip(-1 != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  return;
}


// ps 5d8c6264c00a104f: 2 retail keyword combination(s)
void ps_5d8c6264c00a104f_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = r0.w * _Color.w + -_Cutoff;
  r0.x = cmp(r0.x < 0);
  clip(r0.x != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  return;
}


// ps cae04c4b46dade1d: 2 retail keyword combination(s)
void ps_cae04c4b46dade1d_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  clip(-1 != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = r0.w * _Color.w + -_Cutoff;
  r0.x = cmp(r0.x < 0);
  clip(r0.x != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  return;
}


// ps 2533e8b8e0962423: 3 retail keyword combination(s)
void ps_2533e8b8e0962423_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _Color.w * r0.w;
  r0.z = 0.9375 * r0.x;
  r0.xy = float2(0.25,0.25) * v2.xy;
  r0.xyzw = _DitherMaskLOD.Sample(sampler_DitherMaskLOD, r0.xyz).xyzw;
  r0.x = -0.00999999978 + r0.w;
  r0.x = cmp(r0.x < 0);
  clip(r0.x != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  return;
}


// ps 60736bd1ddce6d4f: 4 retail keyword combination(s)
void ps_60736bd1ddce6d4f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  clip(-1 != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _Color.w * r0.w;
  r0.z = 0.9375 * r0.x;
  r0.xy = float2(0.25,0.25) * v2.xy;
  r0.xyzw = _DitherMaskLOD.Sample(sampler_DitherMaskLOD, r0.xyz).xyzw;
  r0.x = -0.00999999978 + r0.w;
  r0.x = cmp(r0.x < 0);
  clip(r0.x != 0 ? -1 : 1);
  o0.xyzw = float4(0,0,0,0);
  return;
}


// ps f8e9d619ca9bc6b7: 1 retail keyword combination(s)
void ps_f8e9d619ca9bc6b7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  clip(-1 != 0 ? -1 : 1);
  clip(-1 != 0 ? -1 : 1);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _Color.w * r0.w;
  r0.z = 0.9375 * r0.x;
  r0.xy = float2(0.25,0.25) * v2.xy;
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
#if !defined(_ALPHABLEND_ON) && !defined(_ALPHAPREMULTIPLY_ON) && !defined(_ALPHATEST_ON)
	{
		float4 o0 = 0;
		vs_70b5ba79e5a5543c_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0);
		o.sv_position = o0;
	}
#elif defined(_ALPHATEST_ON)
	{
		float4 o0 = 0;
		float2 o1 = 0;
		vs_481ddc3cae839967_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0, o1);
		o.sv_position = o0;
		o.texcoord1.xy = o1;
	}
#elif defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		vs_5ec64a6af4484f49_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord1 = o1;
		o.texcoord2 = o2;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_ALPHABLEND_ON) && !defined(_ALPHAPREMULTIPLY_ON) && !defined(_ALPHATEST_ON) && !defined(_SKIPSHADOW)
	{
		float4 o0 = 0;
		ps_8dc2c81abf29c14b_impl(i.sv_position, o0);
		r.t0 = o0;
	}
#elif !defined(_ALPHABLEND_ON) && !defined(_ALPHAPREMULTIPLY_ON) && !defined(_ALPHATEST_ON) && defined(_SKIPSHADOW)
	{
		float4 o0 = 0;
		ps_36468a64c0bd2231_impl(i.sv_position, o0);
		r.t0 = o0;
	}
#elif defined(_ALPHATEST_ON) && !defined(_SKIPSHADOW)
	{
		float4 o0 = 0;
		ps_5d8c6264c00a104f_impl(i.sv_position, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(_ALPHATEST_ON) && defined(_SKIPSHADOW)
	{
		float4 o0 = 0;
		ps_cae04c4b46dade1d_impl(i.sv_position, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(_ALPHABLEND_ON) && !defined(_HAIR) && !defined(_SKIPSHADOW) || defined(_ALPHAPREMULTIPLY_ON) && !defined(_SKIPSHADOW)
	{
		float4 o0 = 0;
		ps_2533e8b8e0962423_impl(i.sv_position, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif defined(_ALPHABLEND_ON) && defined(_HAIR) && !defined(_SKIPSHADOW) || defined(_ALPHABLEND_ON) && !defined(_HAIR) && defined(_SKIPSHADOW) || defined(_ALPHAPREMULTIPLY_ON) && defined(_SKIPSHADOW)
	{
		float4 o0 = 0;
		ps_60736bd1ddce6d4f_impl(i.sv_position, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif defined(_ALPHABLEND_ON) && defined(_HAIR) && defined(_SKIPSHADOW)
	{
		float4 o0 = 0;
		ps_f8e9d619ca9bc6b7_impl(i.sv_position, i.texcoord1, i.texcoord2, o0);
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
