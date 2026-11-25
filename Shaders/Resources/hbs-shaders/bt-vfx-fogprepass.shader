Shader "Hidden/BT-VFX-FogPrepass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="VFXFog" }
		Pass
		{
			ZWrite On
			ZTest GEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _FOG_3D

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _FogIntegrationTex;
SamplerState sampler_FogIntegrationTex;
Texture3D _FogIntegration3D;
SamplerState sampler_FogIntegration3D;

float4 _ScaleOffset;
float4 _MainTex_ST;
float4 _TintColor;
float3 _VolumeSize;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
};
#elif defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
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
};

// vs b07575d4cec7dfce: 2 retail keyword combination(s)
void vs_b07575d4cec7dfce_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float4 v2 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float2 o2 : TEXCOORD0)
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
  o1.xyzw = v2.xyzw;
  o2.xy = v1.xy;
  return;
}


// vs e0ce468a9ccd9a38: 2 retail keyword combination(s)
void vs_e0ce468a9ccd9a38_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float4 v2 : COLOR0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD1)
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
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = v2.xyzw;
  o2.xy = v1.xy;
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o3.z = -r0.x;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o3.w = r1.w;
  o3.xy = r0.xw + r0.zz;
  return;
}


// ps b0aa3a704850990f: 2 retail keyword combination(s)
void ps_b0aa3a704850990f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = float4(0,0,0,0);
  return;
}


// ps 95943340f489c4c8: 1 retail keyword combination(s)
void ps_95943340f489c4c8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
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
  r0.xyw = r2.xyz + -r1.xyz;
  r0.xyz = r0.zzz * r0.xyw + r1.xyz;
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r0.w = v1.w * r1.w;
  r0.w = _TintColor.w * r0.w;
  r0.w = saturate(20 * r0.w);
  r1.x = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.x * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}


// ps 4d202c21971a0d18: 1 retail keyword combination(s)
void ps_4d202c21971a0d18_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
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
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r0.w = v1.w * r1.w;
  r0.w = _TintColor.w * r0.w;
  r0.w = saturate(20 * r0.w);
  r1.x = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.x * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		vs_b07575d4cec7dfce_impl(v.position0, v.texcoord0.xy, v.color0, o0, o1, o2);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
	}
#elif defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		vs_e0ce468a9ccd9a38_impl(v.position0, v.texcoord0.xy, v.color0, o0, o1, o2, o3);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
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
		ps_b0aa3a704850990f_impl(i.sv_position, i.color0, i.texcoord0.xy, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FORWARD_FOG) && !defined(_FOG_3D)
	{
		float4 o0 = 0;
		ps_95943340f489c4c8_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FORWARD_FOG) && defined(_FOG_3D)
	{
		float4 o0 = 0;
		ps_4d202c21971a0d18_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, o0);
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
