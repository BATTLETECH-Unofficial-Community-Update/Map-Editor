Shader "Hidden/BT-DepthBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			#pragma target 5.0
			#pragma multi_compile _ _BT_SIM_GAME

#define cmp -

Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;


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
};
#else
struct v2f
{
	float4 sv_position : SV_POSITION;
};
#endif

struct fout
{
	float t0 : SV_Target0;
};

// vs d63cf59fd19d3596: 2 retail keyword combination(s)
void vs_d63cf59fd19d3596_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float2 o0 : TEXCOORD0,
  inout float4 o1 : SV_POSITION0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v1.xy;
  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  o1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  return;
}


// ps 8a5805630bb7924e: 1 retail keyword combination(s)
#if !defined(_BT_SIM_GAME)
void ps_8a5805630bb7924e_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = _ScreenParams.xy * v0.xy;
  r0.x = r0.x + r0.y;
  r0.y = r0.x + r0.x;
  r0.y = cmp(r0.y >= -r0.y);
  r0.yz = r0.yy ? float2(2,0.5) : float2(-2,-0.5);
  r0.x = r0.x * r0.z;
  r0.x = frac(r0.x);
  r0.x = r0.y * r0.x;
  r0.x = cmp(r0.x == 0.000000);
  r1.xyzw = _CameraDepthTexture2.Gather(sampler_CameraDepthTexture2, v0.xy).xyzw;
  r0.yz = min(r1.xz, r1.yw);
  r1.xy = max(r1.xz, r1.yw);
  r0.w = max(r1.x, r1.y);
  r0.y = min(r0.y, r0.z);
  o0.x = r0.x ? r0.y : r0.w;
  return;
}


#endif
// ps 8a5805630bb7924e: 1 retail keyword combination(s)
#if defined(_BT_SIM_GAME)
void ps_8a5805630bb7924e_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = _ScreenParams.xy * v0.xy;
  r0.x = r0.x + r0.y;
  r0.y = r0.x + r0.x;
  r0.y = cmp(r0.y >= -r0.y);
  r0.yz = r0.yy ? float2(2,0.5) : float2(-2,-0.5);
  r0.x = r0.x * r0.z;
  r0.x = frac(r0.x);
  r0.x = r0.y * r0.x;
  r0.x = cmp(r0.x == 0.000000);
  r1.xyzw = _CameraDepthTexture.Gather(sampler_CameraDepthTexture, v0.xy).xyzw;
  r0.yz = min(r1.xz, r1.yw);
  r1.xy = max(r1.xz, r1.yw);
  r0.w = max(r1.x, r1.y);
  r0.y = min(r0.y, r0.z);
  o0.x = r0.x ? r0.y : r0.w;
  return;
}


#endif
v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_d63cf59fd19d3596_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.texcoord0.xy = o0;
		o.sv_position = o1;
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
		float o0 = 0;
		ps_8a5805630bb7924e_impl(i.texcoord0.xy, i.sv_position, o0);
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
