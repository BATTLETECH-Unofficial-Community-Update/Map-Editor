Shader "Hidden/Post FX/Uber Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_AutoExposure ("_AutoExposure", 2D) = "white" {}
		_BloomTex ("_BloomTex", 2D) = "white" {}
		_Bloom_DirtTex ("_Bloom_DirtTex", 2D) = "white" {}
		_GrainTex ("_GrainTex", 2D) = "white" {}
		_LogLut ("_LogLut", 2D) = "white" {}
		_UserLut ("_UserLut", 2D) = "white" {}
		_Vignette_Mask ("_Vignette_Mask", 2D) = "white" {}
		_ChromaticAberration_Spectrum ("_ChromaticAberration_Spectrum", 2D) = "white" {}
		_DitheringTex ("_DitheringTex", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ DEPTH_OF_FIELD
			#pragma multi_compile _ DEPTH_OF_FIELD_COC_VIEW

#define cmp -

Texture2D _AutoExposure;
SamplerState sampler_AutoExposure;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _DepthOfFieldTex;
SamplerState sampler_DepthOfFieldTex;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _DepthOfFieldCoCTex;
SamplerState sampler_DepthOfFieldCoCTex;

float4 _MainTex_TexelSize;
float4 _MainTex_ST;
float3 _DepthOfFieldParams;
float _DepthOfFieldFade;

struct appdata
{
	float4 position0 : POSITION0;
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
};

// vs 8b5406e96db510df: 3 retail keyword combination(s)
void vs_8b5406e96db510df_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float2 o2 : TEXCOORD2,
  inout float2 p2 : TEXCOORD3)
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
  p1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = v1.xy;
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  r0.y = r0.x ? r0.y : v1.y;
  r0.x = v1.x;
  p2.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o2.xy = r0.xy;
  return;
}


// ps db2ac03cce5569a8: 1 retail keyword combination(s)
void ps_db2ac03cce5569a8_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  float2 w2 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _AutoExposure.Sample(sampler_AutoExposure, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, w1.xy).xyzw;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = 1;
  return;
}


// ps 29f1db5ca6dccf01: 1 retail keyword combination(s)
void ps_29f1db5ca6dccf01_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  float2 w2 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _DepthOfFieldCoCTex.Sample(sampler_DepthOfFieldCoCTex, w2.xy).xyzw;
  r0.x = -0.5 + r0.x;
  r0.x = r0.x + r0.x;
  r0.y = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r0.x = r0.x * _DepthOfFieldParams.z + -r0.y;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.z = r0.y * r0.x;
  r1.xyzw = _DepthOfFieldTex.Sample(sampler_DepthOfFieldTex, w2.xy).xyzw;
  r0.x = r0.y * r0.x + r1.w;
  r0.x = -r0.z * r1.w + r0.x;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, w1.xy).xyzw;
  r3.xyzw = _AutoExposure.Sample(sampler_AutoExposure, v1.xy).xyzw;
  r0.yzw = r3.xxx * r2.xyz;
  r1.xyz = r1.xyz * r3.xxx + -r0.yzw;
  r1.xyz = r1.xyz * r0.xxx;
  o0.xyz = _DepthOfFieldFade.xxx * r1.xyz + r0.yzw;
  o0.w = 1;
  return;
}


// ps 6be1bb3159f4cbe8: 1 retail keyword combination(s)
void ps_6be1bb3159f4cbe8_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  float2 w2 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, w2.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.y = -_DepthOfFieldParams.x + r0.x;
  r0.y = _DepthOfFieldParams.y * r0.y;
  r0.x = r0.y / r0.x;
  r0.x = 80 * r0.x;
  r0.y = saturate(r0.x);
  r0.x = saturate(-r0.x);
  r0.xzw = r0.xxx * float3(0,1,1) + float3(1,0,0);
  r1.xyz = float3(0.400000006,0.400000006,0.400000006) + -r0.xww;
  r0.xyz = r0.yyy * r1.xyz + r0.xzw;
  r1.xyzw = _AutoExposure.Sample(sampler_AutoExposure, v1.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, w1.xy).xyzw;
  r1.xyz = r2.xyz * r1.xxx;
  r0.w = dot(r1.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r0.w = 0.5 + r0.w;
  r0.xyz = r0.xyz * r0.www;
  r1.xyz = r0.xzz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r1.xyz = r0.xzz * r1.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  o0.xyz = r1.xyz * r0.xyz;
  o0.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float2 o1 = 0;
		float2 p1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		vs_8b5406e96db510df_impl(v.position0, v.texcoord0, o0, o1, p1, o2, p2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2.xy = o2;
		o.texcoord3.xy = p2;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(DEPTH_OF_FIELD) && !defined(DEPTH_OF_FIELD_COC_VIEW)
	{
		float4 o0 = 0;
		ps_db2ac03cce5569a8_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, i.texcoord3.xy, o0);
		r.t0 = o0;
	}
#elif defined(DEPTH_OF_FIELD)
	{
		float4 o0 = 0;
		ps_29f1db5ca6dccf01_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, i.texcoord3.xy, o0);
		r.t0 = o0;
	}
#elif defined(DEPTH_OF_FIELD_COC_VIEW)
	{
		float4 o0 = 0;
		ps_6be1bb3159f4cbe8_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, i.texcoord3.xy, o0);
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
