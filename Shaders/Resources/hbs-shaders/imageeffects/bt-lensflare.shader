// Upgrade NOTE: replaced 'glstate_matrix_projection' with 'UNITY_MATRIX_P'

Shader "Hidden/BT-LensFlare"
{
	Properties
	{
	}
	SubShader
	{
		Pass
		{
			Blend One One
			ZWrite Off
			ZTest Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _FlareTex;
SamplerState sampler_FlareTex;

float2 _FlareScale;
float4 _FlareShape;
float4 _FlareProps;

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

// vs aa09ed577080007d: 1 retail keyword combination(s)
void vs_aa09ed577080007d_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * float3(unity_ObjectToWorld[1][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[1][3]);
  r0.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[0][3], unity_ObjectToWorld[0][3]) + r0.xyz;
  r0.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * float3(unity_ObjectToWorld[2][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[2][3]) + r0.xyz;
  r0.xyz = float3(unity_MatrixV[0][3], unity_MatrixV[1][3], unity_MatrixV[2][3]) * float3(unity_ObjectToWorld[3][3], unity_ObjectToWorld[3][3], unity_ObjectToWorld[3][3]) + r0.xyz;
  r1.xy = _FlareScale.xy * v0.xy;
  r1.xy = r1.xy + r1.xy;
  r1.z = v0.w;
  r0.w = 1;
  r0.y = dot(r0.wy, r1.yz);
  r0.x = dot(r0.wx, r1.xz);
  r0.z = dot(r0.wz, v0.zw);
  r1.xyzw = float4(UNITY_MATRIX_P[0][1], UNITY_MATRIX_P[1][1], UNITY_MATRIX_P[2][1], UNITY_MATRIX_P[3][1]) * r0.yyyy;
  r1.xyzw = float4(UNITY_MATRIX_P[0][0], UNITY_MATRIX_P[1][0], UNITY_MATRIX_P[2][0], UNITY_MATRIX_P[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(UNITY_MATRIX_P[0][2], UNITY_MATRIX_P[1][2], UNITY_MATRIX_P[2][2], UNITY_MATRIX_P[3][2]) * r0.zzzz + r1.xyzw;
  o0.xyzw = float4(UNITY_MATRIX_P[0][3], UNITY_MATRIX_P[1][3], UNITY_MATRIX_P[2][3], UNITY_MATRIX_P[3][3]) * v0.wwww + r0.xyzw;
  o1.xy = v1.xy;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) + float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]);
  r1.xyz = float3(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[3][1]) * r0.yyy;
  r1.xyz = float3(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[3][0]) * r0.xxx + r1.xyz;
  r1.xyz = float3(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[3][2]) * r0.zzz + r1.xyz;
  r1.xyz = float3(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[3][3]) * r0.www + r1.xyz;
  r1.y = _ProjectionParams.x * r1.y;
  r2.xzw = float3(0.5,0.5,0.5) * r1.xzy;
  r1.xy = r2.xw + r2.zz;
  r1.xy = r1.xy / r1.zz;
  r1.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r1.xy, 0).xyzw;
  r1.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r1.x = 1 / r1.x;
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  r0.x = cmp(-r0.x < r1.x);
  r0.x = r0.x ? 1.000000 : 0;
  o2.w = _FlareProps.w * r0.x;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) + -_WorldSpaceCameraPos.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = dot(float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]), float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]));
  r0.w = rsqrt(r0.w);
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * r0.www;
  r0.x = dot(r1.xyz, -r0.xyz);
  r0.x = -_FlareShape.z + r0.x;
  r0.y = _FlareShape.y + -_FlareShape.z;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = dot(r0.yy, r0.xx);
  r0.y = cmp(0.5 < _FlareShape.x);
  r0.x = r0.y ? r0.x : 2;
  r0.yzw = _FlareProps.xyz * _FlareProps.www;
  o2.xyz = r0.yzw * r0.xxx;
  return;
}


// ps fcd67ba2de5e9afc: 1 retail keyword combination(s)
void ps_fcd67ba2de5e9afc_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _FlareTex.Sample(sampler_FlareTex, v1.xy).xyzw;
  r0.x = r0.x * r0.x;
  r0.x = 0.0500000007 * r0.x;
  r0.yzw = v2.xyz * v2.www;
  o0.xyz = r0.yzw * r0.xxx;
  o0.w = 0;
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
		vs_aa09ed577080007d_impl(v.position0, v.texcoord0.xy, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
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
		ps_fcd67ba2de5e9afc_impl(i.sv_position, i.texcoord0, i.texcoord1, o0);
		r.t0 = o0;
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
			Blend One One
			ZWrite Off
			ZTest Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _FlareTex;
SamplerState sampler_FlareTex;

float4 _FlareProps;
float4 _FlareShape;

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

// vs e05767568a78b711: 1 retail keyword combination(s)
void vs_e05767568a78b711_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) + -_WorldSpaceCameraPos.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r1.x = sqrt(r0.w);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = 0.00133333332 * r1.x;
  r0.w = min(1, r0.w);
  r0.w = 1 + -r0.w;
  r0.w = r0.w * r0.w;
  r1.x = r0.w * r0.w;
  r1.x = r1.x * r0.w;
  r0.w = r1.x * 3.5 + 0.5;
  r2.x = v1.y * 2 + -1;
  r2.y = r2.x * r0.w;
  r2.x = v1.x * 2 + -1;
  r3.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * float4(unity_ObjectToWorld[1][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[1][3]);
  r3.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[0][3], unity_ObjectToWorld[0][3], unity_ObjectToWorld[0][3]) + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * float4(unity_ObjectToWorld[2][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[2][3]) + r3.xyzw;
  r3.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * float4(unity_ObjectToWorld[3][3], unity_ObjectToWorld[3][3], unity_ObjectToWorld[3][3], unity_ObjectToWorld[3][3]) + r3.xyzw;
  r3.xyz = r3.xyz / r3.www;
  o0.xy = r2.xy * float2(1,0.0500000007) + r3.xy;
  o0.w = 1;
  o0.z = r3.z;
  o1.xy = v1.xy;
  r2.xy = cmp(float2(1,1) < r3.xy);
  r2.zw = cmp(r3.xy < float2(-1,-1));
  r0.w = (int)r2.z | (int)r2.x;
  r0.w = (int)r2.y | (int)r0.w;
  r0.w = (int)r2.w | (int)r0.w;
  r1.yzw = float3(1,0.00999999978,0.200000003);
  r2.xyz = _FlareProps.www * r1.xxy;
  r1.xyz = r2.xyz * r1.zwx;
  r1.w = dot(float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]), float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]));
  r1.w = rsqrt(r1.w);
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * r1.www;
  r0.x = dot(r2.xyz, -r0.xyz);
  r0.x = -_FlareShape.z + r0.x;
  r0.y = _FlareShape.y + -_FlareShape.z;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.y = cmp(0.5 < _FlareShape.x);
  r0.x = r0.y ? r0.x : 1;
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = float3(0.25,0.25,0.25) * r0.xyz;
  o2.xyz = r0.www ? float3(0,0,0) : r0.xyz;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007) + float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]);
  r1.xyz = float3(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[3][1]) * r0.yyy;
  r1.xyz = float3(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[3][0]) * r0.xxx + r1.xyz;
  r1.xyz = float3(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[3][2]) * r0.zzz + r1.xyz;
  r1.xyz = float3(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[3][3]) * r0.www + r1.xyz;
  r1.y = _ProjectionParams.x * r1.y;
  r2.xzw = float3(0.5,0.5,0.5) * r1.xzy;
  r1.xy = r2.xw + r2.zz;
  r1.xy = r1.xy / r1.zz;
  r1.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r1.xy, 0).xyzw;
  r1.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r1.x = 1 / r1.x;
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  r0.x = cmp(-r0.x < r1.x);
  r0.x = r0.x ? 1.000000 : 0;
  o2.w = _FlareProps.w * r0.x;
  return;
}


// ps 3296c7c74717ca72: 1 retail keyword combination(s)
void ps_3296c7c74717ca72_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _FlareTex.Sample(sampler_FlareTex, v1.xy).xyzw;
  r0.x = 0.200000003 * r0.x;
  r0.yzw = v2.xyz * v2.www;
  o0.xyz = r0.yzw * r0.xxx;
  o0.w = 0;
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
		vs_e05767568a78b711_impl(v.position0, v.texcoord0.xy, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
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
		ps_3296c7c74717ca72_impl(i.sv_position, i.texcoord0, i.texcoord1, o0);
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
