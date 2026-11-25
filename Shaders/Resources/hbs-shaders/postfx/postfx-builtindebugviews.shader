Shader "Hidden/Post FX/Builtin Debug Views"
{
	Properties
	{
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

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;

float4 _MainTex_ST;
float4 _CameraDepthTexture_ST;
float _DepthScale;

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

// vs 4a840470d5c29811: 1 retail keyword combination(s)
void vs_4a840470d5c29811_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1)
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
  return;
}


// ps d20796f6d0ef355e: 1 retail keyword combination(s)
void ps_d20796f6d0ef355e_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.x = _DepthScale * r0.x;
  r0.y = r0.x * 0.305306017 + 0.682171106;
  r0.y = r0.x * r0.y + 0.0125228781;
  o0.xyz = r0.xxx * r0.yyy;
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
		vs_4a840470d5c29811_impl(v.position0, v.texcoord0, o0, o1, p1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
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
		ps_d20796f6d0ef355e_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ SOURCE_GBUFFER

#define cmp -

Texture2D _CameraDepthNormalsTexture;
SamplerState sampler_CameraDepthNormalsTexture;
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;

float4 _MainTex_ST;
float4 _CameraDepthNormalsTexture_ST;

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

// vs 4a840470d5c29811: 2 retail keyword combination(s)
void vs_4a840470d5c29811_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1)
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
  return;
}


// ps f7fa5076b016bae5: 1 retail keyword combination(s)
void ps_f7fa5076b016bae5_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _CameraDepthNormalsTexture_ST.xy + _CameraDepthNormalsTexture_ST.zw;
  r0.xyzw = _CameraDepthNormalsTexture.Sample(sampler_CameraDepthNormalsTexture, r0.xy).xyzw;
  r0.xyz = r0.xyz * float3(3.55539989,3.55539989,0) + float3(-1.77769995,-1.77769995,1);
  r0.z = dot(r0.xyz, r0.xyz);
  r0.z = 2 / r0.z;
  r1.xy = r0.zz * r0.xy;
  r1.z = -1 + r0.z;
  o0.xyz = float3(1,1,-1) * r1.xyz;
  o0.w = 1;
  return;
}


// ps 48cce37249e81e16: 1 retail keyword combination(s)
void ps_48cce37249e81e16_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _CameraDepthNormalsTexture_ST.xy + _CameraDepthNormalsTexture_ST.zw;
  r0.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyz = float3(unity_WorldToCamera[0][1], unity_WorldToCamera[1][1], unity_WorldToCamera[2][1]) * r0.yyy;
  r0.xyw = float3(unity_WorldToCamera[0][0], unity_WorldToCamera[1][0], unity_WorldToCamera[2][0]) * r0.xxx + r1.xyz;
  o0.xyz = float3(unity_WorldToCamera[0][2], unity_WorldToCamera[1][2], unity_WorldToCamera[2][2]) * r0.zzz + r0.xyw;
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
		vs_4a840470d5c29811_impl(v.position0, v.texcoord0, o0, o1, p1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(SOURCE_GBUFFER)
	{
		float4 o0 = 0;
		ps_f7fa5076b016bae5_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(SOURCE_GBUFFER)
	{
		float4 o0 = 0;
		ps_48cce37249e81e16_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_ST;
float _Opacity;

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

// vs 4a840470d5c29811: 1 retail keyword combination(s)
void vs_4a840470d5c29811_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1)
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
  return;
}


// ps e1005440103697fe: 1 retail keyword combination(s)
void ps_e1005440103697fe_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = _Opacity.xxx * r0.xyz;
  o0.w = r0.w;
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
		vs_4a840470d5c29811_impl(v.position0, v.texcoord0, o0, o1, p1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
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
		ps_e1005440103697fe_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ UNITY_COLORSPACE_GAMMA

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _CameraMotionVectorsTexture;
SamplerState sampler_CameraMotionVectorsTexture;

float4 _MainTex_ST;
float _Opacity;
float _Amplitude;

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

// vs 4a840470d5c29811: 2 retail keyword combination(s)
void vs_4a840470d5c29811_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1)
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
  return;
}


// ps 4bab0e5fc3e96fce: 1 retail keyword combination(s)
void ps_4bab0e5fc3e96fce_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraMotionVectorsTexture.Sample(sampler_CameraMotionVectorsTexture, v1.xy).xyzw;
  r0.yz = _Amplitude.xx * r0.xy;
  r0.xw = -r0.zz;
  r1.x = max(abs(r0.y), abs(r0.x));
  r1.x = 1 / r1.x;
  r1.y = min(abs(r0.y), abs(r0.x));
  r1.x = r1.y * r1.x;
  r1.y = r1.x * r1.x;
  r1.z = r1.y * 0.0208350997 + -0.0851330012;
  r1.z = r1.y * r1.z + 0.180141002;
  r1.z = r1.y * r1.z + -0.330299497;
  r1.y = r1.y * r1.z + 0.999866009;
  r1.z = r1.x * r1.y;
  r1.z = r1.z * -2 + 1.57079637;
  r1.w = cmp(abs(r0.x) < abs(r0.y));
  r1.z = r1.w ? r1.z : 0;
  r1.x = r1.x * r1.y + r1.z;
  r0.z = cmp(r0.x < r0.z);
  r0.z = r0.z ? asfloat(0xc0490fdb) : 0;
  r0.z = r1.x + r0.z;
  r1.x = min(r0.y, r0.x);
  r1.x = cmp(r1.x < -r1.x);
  r0.x = max(r0.y, r0.x);
  r0.y = dot(r0.yw, r0.yw);
  r0.y = saturate(sqrt(r0.y));
  r0.y = _Opacity * r0.y;
  r0.x = cmp(r0.x >= -r0.x);
  r0.x = r0.x ? r1.x : 0;
  r0.x = r0.x ? -r0.z : r0.z;
  r0.x = r0.x * 0.318309873 + 1;
  r0.xzw = r0.xxx * float3(3,3,3) + float3(-3,-2,-4);
  r0.xzw = saturate(abs(r0.xzw) * float3(1,-1,-1) + float3(-1,2,2));
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  o0.w = r1.w;
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.416666657,0.416666657,0.416666657) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r1.xyz = r1.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r0.xzw = -r1.xyz + r0.xzw;
  r0.xyz = r0.yyy * r0.xzw + r1.xyz;
  r1.xyz = r0.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r1.xyz = r0.xyz * r1.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  o0.xyz = r1.xyz * r0.xyz;
  return;
}


// ps 1a2d9bc2dd6673ee: 1 retail keyword combination(s)
void ps_1a2d9bc2dd6673ee_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraMotionVectorsTexture.Sample(sampler_CameraMotionVectorsTexture, v1.xy).xyzw;
  r0.yz = _Amplitude.xx * r0.xy;
  r0.xw = -r0.zz;
  r1.x = max(abs(r0.y), abs(r0.x));
  r1.x = 1 / r1.x;
  r1.y = min(abs(r0.y), abs(r0.x));
  r1.x = r1.y * r1.x;
  r1.y = r1.x * r1.x;
  r1.z = r1.y * 0.0208350997 + -0.0851330012;
  r1.z = r1.y * r1.z + 0.180141002;
  r1.z = r1.y * r1.z + -0.330299497;
  r1.y = r1.y * r1.z + 0.999866009;
  r1.z = r1.x * r1.y;
  r1.z = r1.z * -2 + 1.57079637;
  r1.w = cmp(abs(r0.x) < abs(r0.y));
  r1.z = r1.w ? r1.z : 0;
  r1.x = r1.x * r1.y + r1.z;
  r0.z = cmp(r0.x < r0.z);
  r0.z = r0.z ? asfloat(0xc0490fdb) : 0;
  r0.z = r1.x + r0.z;
  r1.x = min(r0.y, r0.x);
  r1.x = cmp(r1.x < -r1.x);
  r0.x = max(r0.y, r0.x);
  r0.y = dot(r0.yw, r0.yw);
  r0.y = saturate(sqrt(r0.y));
  r0.y = _Opacity * r0.y;
  r0.x = cmp(r0.x >= -r0.x);
  r0.x = r0.x ? r1.x : 0;
  r0.x = r0.x ? -r0.z : r0.z;
  r0.x = r0.x * 0.318309873 + 1;
  r0.xzw = r0.xxx * float3(3,3,3) + float3(-3,-2,-4);
  r0.xzw = saturate(abs(r0.xzw) * float3(1,-1,-1) + float3(-1,2,2));
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.xzw = -r1.xyz + r0.xzw;
  o0.xyz = r0.yyy * r0.xzw + r1.xyz;
  o0.w = r1.w;
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
		vs_4a840470d5c29811_impl(v.position0, v.texcoord0, o0, o1, p1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		ps_4bab0e5fc3e96fce_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		ps_1a2d9bc2dd6673ee_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

#define cmp -

Texture2D _CameraMotionVectorsTexture;
SamplerState sampler_CameraMotionVectorsTexture;

float _Opacity;
float _Amplitude;
float4 _Scale;

struct appdata
{
	float4 position0 : POSITION0;
	float4 texcoord0 : TEXCOORD0;
};

#if 1
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
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
	float4 t0 : SV_Target0;
};

// vs 48029fee8821a33f: 1 retail keyword combination(s)
void vs_48029fee8821a33f_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float4 o2 : COLOR0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.y = -abs(v0.x);
  r0.x = v0.x;
  r0.zw = v1.xy * float2(1,-1) + float2(0,1);
  r1.xyzw = _CameraMotionVectorsTexture.SampleLevel(sampler_CameraMotionVectorsTexture, r0.zw, 0).xyzw;
  r1.xy = _Amplitude.xx * r1.xy;
  r1.zw = -r1.yy;
  r0.z = dot(r1.xz, r1.xz);
  r0.w = saturate(sqrt(r0.z));
  r0.z = rsqrt(r0.z);
  r2.xy = r1.xw * r0.zz;
  r3.x = dot(r1.xw, v0.yz);
  r0.xy = r0.xy * r0.ww;
  o2.w = saturate(_Opacity * r0.w);
  r0.xy = float2(0.300000012,0.300000012) * r0.xy;
  r2.z = -r2.x;
  r4.y = dot(r2.zy, r0.xy);
  r4.x = dot(r2.yx, r0.xy);
  r0.xy = _Scale.xy * r4.xy;
  r3.y = dot(-r1.yx, v0.yz);
  r0.xy = r3.xy * _Scale.xy + r0.xy;
  r0.xy = v1.xy * float2(2,2) + r0.xy;
  r0.xy = _ScreenParams.xy * r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r0.xy = round(r0.xy);
  r0.zw = float2(0.5,0.5) + r0.xy;
  o1.xy = r0.xy;
  r0.xy = float2(-1,-1) + _ScreenParams.zw;
  r0.xy = r0.zw * r0.xy;
  o0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  o0.zw = float2(0,1);
  r0.x = abs(r1.y);
  r0.y = max(abs(r1.x), r0.x);
  r0.y = 1 / r0.y;
  r0.z = min(abs(r1.x), r0.x);
  r0.x = cmp(r0.x < abs(r1.x));
  r0.y = r0.z * r0.y;
  r0.z = r0.y * r0.y;
  r0.w = r0.z * 0.0208350997 + -0.0851330012;
  r0.w = r0.z * r0.w + 0.180141002;
  r0.w = r0.z * r0.w + -0.330299497;
  r0.z = r0.z * r0.w + 0.999866009;
  r0.w = r0.y * r0.z;
  r0.w = r0.w * -2 + 1.57079637;
  r0.x = r0.x ? r0.w : 0;
  r0.x = r0.y * r0.z + r0.x;
  r0.y = cmp(-r1.y < r1.y);
  r0.y = r0.y ? asfloat(0xc0490fdb) : 0;
  r0.x = r0.x + r0.y;
  r0.y = min(r1.x, -r1.y);
  r0.z = max(r1.x, -r1.y);
  r0.z = cmp(r0.z >= -r0.z);
  r0.y = cmp(r0.y < -r0.y);
  r0.y = r0.z ? r0.y : 0;
  r0.x = r0.y ? -r0.x : r0.x;
  r0.x = r0.x * 0.318309873 + 1;
  r0.xyz = r0.xxx * float3(3,3,3) + float3(-3,-2,-4);
  r0.xyz = saturate(abs(r0.xyz) * float3(1,-1,-1) + float3(-1,2,2));
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r0.xyz = r1.xyz * float3(0.5,0.5,0.5) + r0.xyz;
  r1.xyz = r0.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r1.xyz = r0.xyz * r1.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  o2.xyz = saturate(r1.xyz * r0.xyz);
  return;
}


// ps e6e2e3a3f466ce67: 1 retail keyword combination(s)
void ps_e6e2e3a3f466ce67_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float4 v2 : COLOR0,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = frac(v1.xy);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = sqrt(r0.x);
  r0.y = r0.x * 0.431833118 + 0.682171106;
  r0.x = 1.41442716 * r0.x;
  r0.y = r0.x * r0.y + 0.0125228781;
  r0.x = r0.x * r0.y;
  o0.w = v2.w * r0.x;
  o0.xyz = v2.xyz;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float2 o1 = 0;
		float4 o2 = 0;
		vs_48029fee8821a33f_impl(v.position0, v.texcoord0, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.color0 = o2;
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
		ps_e6e2e3a3f466ce67_impl(i.sv_position, i.texcoord0.xy, i.color0, o0);
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
