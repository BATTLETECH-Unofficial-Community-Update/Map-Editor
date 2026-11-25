Shader "BattleTech/VFX/BT-VFX-Fade"
{
	Properties
	{
		_Color ("Color", Color) = (0,0,0,1)
		_Distance ("Distance", Float) = 10
	}
	SubShader
	{
		Tags { "IgnoreProjector"="true" "PreviewType"="Plane" "Queue"="Transparent" "RenderType"="Transparent" }
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _FOG_3D

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _FogIntegrationTex;
SamplerState sampler_FogIntegrationTex;
Texture3D _FogIntegration3D;
SamplerState sampler_FogIntegration3D;

float4 _Color;
float _Distance;
float4 _ScaleOffset;
float3 _VolumeSize;

struct appdata
{
	float4 position0 : POSITION0;
};

#if !defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};
#elif defined(_BT_FORWARD_FOG)
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

// vs 1ea665fa8eca19ec: 2 retail keyword combination(s)
void vs_1ea665fa8eca19ec_impl(
  float4 v0 : POSITION0,
  inout float4 o0 : SV_POSITION0,
  inout float o1 : TEXCOORD0,
  inout float3 p1 : TEXCOORD1,
  inout float4 o2 : TEXCOORD2)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  r2.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r0.yyy;
  r2.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * r0.www + r0.xyz;
  p1.xyz = float3(-1,-1,1) * r0.xyz;
  r0.x = r1.z / r1.w;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  o1.x = 1 / r0.x;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o2.zw = r1.zw;
  o2.xy = r0.xw + r0.zz;
  return;
}


// vs 710841acb2a79ef3: 2 retail keyword combination(s)
void vs_710841acb2a79ef3_impl(
  float4 v0 : POSITION0,
  inout float4 o0 : SV_POSITION0,
  inout float o1 : TEXCOORD0,
  inout float3 p1 : TEXCOORD1,
  inout float4 o2 : TEXCOORD2,
  inout float4 o3 : TEXCOORD3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  r2.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * r0.yyy;
  r2.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * r0.xxx + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * r0.zzz + r2.xyz;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * r0.www + r0.xyz;
  p1.xyz = float3(-1,-1,1) * r0.xyz;
  r0.x = _ProjectionParams.w * r0.z;
  o3.z = -r0.x;
  r0.x = r1.z / r1.w;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  o1.x = 1 / r0.x;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  r1.xy = r0.xw + r0.zz;
  o2.xyzw = r1.xyzw;
  o3.xyw = r1.xyw;
  return;
}


// ps 6f0f35250371deae: 2 retail keyword combination(s)
void ps_6f0f35250371deae_impl(
  float4 v0 : SV_POSITION0,
  float v1 : TEXCOORD0,
  float3 w1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy / v2.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = -v1.x + r0.x;
  o0.w = saturate(abs(r0.x) / _Distance);
  o0.xyz = _Color.xyz;
  return;
}


// ps 67bf5ce18b86df86: 1 retail keyword combination(s)
void ps_67bf5ce18b86df86_impl(
  float4 v0 : SV_POSITION0,
  float v1 : TEXCOORD0,
  float3 w1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r0.xy = r0.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r0.w = v3.z * r0.z;
  r0.w = floor(r0.w);
  r1.x = 1 + r0.w;
  r1.x = min(r1.x, r0.z);
  r0.z = v3.z * r0.z + -r0.w;
  r0.xyw = r0.xyw / _ScaleOffset.www;
  r1.x = r1.x / _ScaleOffset.w;
  r1.y = cmp(r1.x >= -r1.x);
  r1.z = frac(abs(r1.x));
  r2.y = floor(r1.x);
  r1.x = r1.y ? r1.z : -r1.z;
  r2.x = r1.x * _ScaleOffset.w + -1;
  r1.x = 1 / _ScaleOffset.w;
  r1.yz = r2.xy * r1.xx + r0.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.yz, 0).xyzw;
  r1.y = cmp(r0.w >= -r0.w);
  r1.z = frac(abs(r0.w));
  r3.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r3.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r3.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r2.xyzw = r2.xyzw + -r1.xyzw;
  r0.xyzw = r0.zzzz * r2.xyzw + r1.xyzw;
  o0.xyz = _Color.xyz * r0.www + r0.xyz;
  r0.xy = v2.xy / v2.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = -v1.x + r0.x;
  o0.w = saturate(abs(r0.x) / _Distance);
  return;
}


// ps dfa299e03109205a: 1 retail keyword combination(s)
void ps_dfa299e03109205a_impl(
  float4 v0 : SV_POSITION0,
  float v1 : TEXCOORD0,
  float3 w1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  o0.xyz = _Color.xyz * r0.www + r0.xyz;
  r0.xy = v2.xy / v2.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = -v1.x + r0.x;
  o0.w = saturate(abs(r0.x) / _Distance);
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float o1 = 0;
		float3 p1 = 0;
		float4 o2 = 0;
		vs_1ea665fa8eca19ec_impl(v.position0, o0, o1, p1, o2);
		o.sv_position = o0;
		o.texcoord0.x = o1;
		o.texcoord1.xyz = p1;
		o.texcoord2 = o2;
	}
#elif defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float o1 = 0;
		float3 p1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		vs_710841acb2a79ef3_impl(v.position0, o0, o1, p1, o2, o3);
		o.sv_position = o0;
		o.texcoord0.x = o1;
		o.texcoord1.xyz = p1;
		o.texcoord2 = o2;
		o.texcoord3 = o3;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		ps_6f0f35250371deae_impl(i.sv_position, i.texcoord0.x, i.texcoord1.xyz, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FORWARD_FOG) && !defined(_FOG_3D)
	{
		float4 o0 = 0;
		ps_67bf5ce18b86df86_impl(i.sv_position, i.texcoord0.x, i.texcoord1.xyz, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FORWARD_FOG) && defined(_FOG_3D)
	{
		float4 o0 = 0;
		ps_dfa299e03109205a_impl(i.sv_position, i.texcoord0.x, i.texcoord1.xyz, i.texcoord2, i.texcoord3, o0);
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
