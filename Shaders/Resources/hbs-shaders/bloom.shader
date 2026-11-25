Shader "Hidden/Image Effects/Cinematic/Bloom"
{
	Properties
	{
		_MainTex ("_MainTex", 2D) = "white" {}
		_BaseTex ("_BaseTex", 2D) = "white" {}
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
			#pragma multi_compile _ UNITY_COLORSPACE_GAMMA

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_ST;
float2 _MainTex_TexelSize;
float _PrefilterOffs;
float _Threshold;
float3 _Curve;

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
	float4 t0 : SV_Target0;
};

// vs 663c60dd7aa20a75: 2 retail keyword combination(s)
void vs_663c60dd7aa20a75_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0)
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
  o1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps a904cb7f95d05a01: 1 retail keyword combination(s)
void ps_a904cb7f95d05a01_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = _MainTex_TexelSize.xy * _PrefilterOffs.xx + v1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyz = min(float3(65000,65000,65000), r0.xyz);
  r0.w = max(r0.x, r0.y);
  r0.w = max(r0.w, r0.z);
  r1.x = -_Curve.x + r0.w;
  r1.x = max(0, r1.x);
  r1.x = min(_Curve.y, r1.x);
  r1.x = r1.x * r1.x;
  r1.x = _Curve.z * r1.x;
  r1.y = -_Threshold + r0.w;
  r0.w = max(9.99999975e-006, r0.w);
  r1.x = max(r1.x, r1.y);
  r0.w = r1.x / r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}


// ps 4253f252bc2c24bf: 1 retail keyword combination(s)
void ps_4253f252bc2c24bf_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = _MainTex_TexelSize.xy * _PrefilterOffs.xx + v1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyz = min(float3(65000,65000,65000), r0.xyz);
  r1.xyz = r0.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r1.xyz = r0.xyz * r1.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  r0.xyz = r1.xyz * r0.xyz;
  r0.w = max(r0.x, r0.y);
  r0.w = max(r0.w, r0.z);
  r1.x = -_Curve.x + r0.w;
  r1.x = max(0, r1.x);
  r1.x = min(_Curve.y, r1.x);
  r1.x = r1.x * r1.x;
  r1.x = _Curve.z * r1.x;
  r1.y = -_Threshold + r0.w;
  r0.w = max(9.99999975e-006, r0.w);
  r1.x = max(r1.x, r1.y);
  r0.w = r1.x / r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float2 o1 = 0;
		vs_663c60dd7aa20a75_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
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
		ps_a904cb7f95d05a01_impl(i.sv_position, i.texcoord0.xy, o0);
		r.t0 = o0;
	}
#elif defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		ps_4253f252bc2c24bf_impl(i.sv_position, i.texcoord0.xy, o0);
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

float4 _MainTex_ST;
float2 _MainTex_TexelSize;
float _PrefilterOffs;
float _Threshold;
float3 _Curve;

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
	float4 t0 : SV_Target0;
};

// vs 663c60dd7aa20a75: 2 retail keyword combination(s)
void vs_663c60dd7aa20a75_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0)
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
  o1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps 8a7622539b25ee63: 1 retail keyword combination(s)
void ps_8a7622539b25ee63_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex_TexelSize.xyxy * _PrefilterOffs.xxxx + v1.xyxy;
  r1.xyzw = -_MainTex_TexelSize.xxxy * float4(1,0,0,1) + r0.zwzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r1.xyz = min(float3(65000,65000,65000), r1.xyz);
  r2.xyz = min(float3(65000,65000,65000), r2.xyz);
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyzw = _MainTex_TexelSize.xxxy * float4(1,0,0,1) + r0.xyzw;
  r3.xyz = min(float3(65000,65000,65000), r3.xyz);
  r4.xyz = r3.xyz + r2.xyz;
  r5.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyz = min(float3(65000,65000,65000), r0.xyz);
  r5.xyz = min(float3(65000,65000,65000), r5.xyz);
  r4.xyz = r5.xyz + r4.xyz;
  r6.xyz = min(r3.xyz, r2.xyz);
  r2.xyz = max(r3.xyz, r2.xyz);
  r2.xyz = max(r2.xyz, r5.xyz);
  r3.xyz = min(r6.xyz, r5.xyz);
  r3.xyz = r4.xyz + -r3.xyz;
  r2.xyz = r3.xyz + -r2.xyz;
  r3.xyz = r2.xyz + r1.xyz;
  r3.xyz = r3.xyz + r0.xyz;
  r4.xyz = min(r2.xyz, r1.xyz);
  r1.xyz = max(r2.xyz, r1.xyz);
  r1.xyz = max(r1.xyz, r0.xyz);
  r0.xyz = min(r4.xyz, r0.xyz);
  r0.xyz = r3.xyz + -r0.xyz;
  r0.xyz = r0.xyz + -r1.xyz;
  r0.w = max(r0.x, r0.y);
  r0.w = max(r0.w, r0.z);
  r1.x = -_Curve.x + r0.w;
  r1.x = max(0, r1.x);
  r1.x = min(_Curve.y, r1.x);
  r1.x = r1.x * r1.x;
  r1.x = _Curve.z * r1.x;
  r1.y = -_Threshold + r0.w;
  r0.w = max(9.99999975e-006, r0.w);
  r1.x = max(r1.x, r1.y);
  r0.w = r1.x / r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}


// ps f3226d6c1790a747: 1 retail keyword combination(s)
void ps_f3226d6c1790a747_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex_TexelSize.xyxy * _PrefilterOffs.xxxx + v1.xyxy;
  r1.xyzw = -_MainTex_TexelSize.xxxy * float4(1,0,0,1) + r0.zwzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r1.xyz = min(float3(65000,65000,65000), r1.xyz);
  r2.xyz = min(float3(65000,65000,65000), r2.xyz);
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyzw = _MainTex_TexelSize.xxxy * float4(1,0,0,1) + r0.xyzw;
  r3.xyz = min(float3(65000,65000,65000), r3.xyz);
  r4.xyz = r3.xyz + r2.xyz;
  r5.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyz = min(float3(65000,65000,65000), r0.xyz);
  r5.xyz = min(float3(65000,65000,65000), r5.xyz);
  r4.xyz = r5.xyz + r4.xyz;
  r6.xyz = min(r3.xyz, r2.xyz);
  r2.xyz = max(r3.xyz, r2.xyz);
  r2.xyz = max(r2.xyz, r5.xyz);
  r3.xyz = min(r6.xyz, r5.xyz);
  r3.xyz = r4.xyz + -r3.xyz;
  r2.xyz = r3.xyz + -r2.xyz;
  r3.xyz = r2.xyz + r1.xyz;
  r3.xyz = r3.xyz + r0.xyz;
  r4.xyz = min(r2.xyz, r1.xyz);
  r1.xyz = max(r2.xyz, r1.xyz);
  r1.xyz = max(r1.xyz, r0.xyz);
  r0.xyz = min(r4.xyz, r0.xyz);
  r0.xyz = r3.xyz + -r0.xyz;
  r0.xyz = r0.xyz + -r1.xyz;
  r1.xyz = r0.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r1.xyz = r0.xyz * r1.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  r0.xyz = r1.xyz * r0.xyz;
  r0.w = max(r0.x, r0.y);
  r0.w = max(r0.w, r0.z);
  r1.x = -_Curve.x + r0.w;
  r1.x = max(0, r1.x);
  r1.x = min(_Curve.y, r1.x);
  r1.x = r1.x * r1.x;
  r1.x = _Curve.z * r1.x;
  r1.y = -_Threshold + r0.w;
  r0.w = max(9.99999975e-006, r0.w);
  r1.x = max(r1.x, r1.y);
  r0.w = r1.x / r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float2 o1 = 0;
		vs_663c60dd7aa20a75_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
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
		ps_8a7622539b25ee63_impl(i.sv_position, i.texcoord0.xy, o0);
		r.t0 = o0;
	}
#elif defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		ps_f3226d6c1790a747_impl(i.sv_position, i.texcoord0.xy, o0);
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
float2 _MainTex_TexelSize;

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
	float4 t0 : SV_Target0;
};

// vs 663c60dd7aa20a75: 1 retail keyword combination(s)
void vs_663c60dd7aa20a75_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0)
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
  o1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps 1479c7ef44400600: 1 retail keyword combination(s)
void ps_1479c7ef44400600_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex_TexelSize.xyxy * float4(-1,-1,1,-1) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xyzw = _MainTex_TexelSize.xyxy * float4(-1,1,1,1) + v1.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r0.xyz = r2.xyz + r0.xyz;
  r0.xyz = r0.xyz + r1.xyz;
  o0.xyz = float3(0.25,0.25,0.25) * r0.xyz;
  o0.w = 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float2 o1 = 0;
		vs_663c60dd7aa20a75_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
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
		ps_1479c7ef44400600_impl(i.sv_position, i.texcoord0.xy, o0);
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
float2 _MainTex_TexelSize;

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
	float4 t0 : SV_Target0;
};

// vs 663c60dd7aa20a75: 1 retail keyword combination(s)
void vs_663c60dd7aa20a75_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0)
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
  o1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps e6b5fda8f020035d: 1 retail keyword combination(s)
void ps_e6b5fda8f020035d_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex_TexelSize.xyxy * float4(-1,-1,1,-1) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.w = max(r1.x, r1.y);
  r0.w = max(r0.w, r1.z);
  r0.w = 1 + r0.w;
  r0.w = 1 / r0.w;
  r1.xyz = r1.xyz * r0.www;
  r1.w = max(r0.x, r0.y);
  r1.w = max(r1.w, r0.z);
  r1.w = 1 + r1.w;
  r1.w = 1 / r1.w;
  r0.xyz = r0.xyz * r1.www + r1.xyz;
  r0.w = r1.w + r0.w;
  r1.xyzw = _MainTex_TexelSize.xyxy * float4(-1,1,1,1) + v1.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r1.w = max(r2.x, r2.y);
  r1.w = max(r1.w, r2.z);
  r1.w = 1 + r1.w;
  r1.w = 1 / r1.w;
  r0.xyz = r2.xyz * r1.www + r0.xyz;
  r0.w = r1.w + r0.w;
  r1.w = max(r1.x, r1.y);
  r1.w = max(r1.w, r1.z);
  r1.w = 1 + r1.w;
  r1.w = 1 / r1.w;
  r0.xyz = r1.xyz * r1.www + r0.xyz;
  r0.w = r1.w + r0.w;
  r0.w = 1 / r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float2 o1 = 0;
		vs_663c60dd7aa20a75_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
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
		ps_e6b5fda8f020035d_impl(i.sv_position, i.texcoord0.xy, o0);
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
float2 _MainTex_TexelSize;

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
	float4 t0 : SV_Target0;
};

// vs 663c60dd7aa20a75: 1 retail keyword combination(s)
void vs_663c60dd7aa20a75_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0)
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
  o1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps 1479c7ef44400600: 1 retail keyword combination(s)
void ps_1479c7ef44400600_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex_TexelSize.xyxy * float4(-1,-1,1,-1) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xyzw = _MainTex_TexelSize.xyxy * float4(-1,1,1,1) + v1.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r0.xyz = r2.xyz + r0.xyz;
  r0.xyz = r0.xyz + r1.xyz;
  o0.xyz = float3(0.25,0.25,0.25) * r0.xyz;
  o0.w = 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float2 o1 = 0;
		vs_663c60dd7aa20a75_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
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
		ps_1479c7ef44400600_impl(i.sv_position, i.texcoord0.xy, o0);
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

Texture2D _BaseTex;
SamplerState sampler_BaseTex;
Texture2D _MainTex;
SamplerState sampler_MainTex;

float2 _BaseTex_TexelSize;
float4 _MainTex_ST;
float4 _BaseTex_ST;
float2 _MainTex_TexelSize;
float _SampleScale;

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

// vs 667e1a0533641c51: 1 retail keyword combination(s)
void vs_667e1a0533641c51_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
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
  r0.x = cmp(_BaseTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  r0.zw = v1.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
  p1.y = r0.x ? r0.y : r0.w;
  p1.x = r0.z;
  o1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps 0f6cec8a0ba2a86e: 1 retail keyword combination(s)
void ps_0f6cec8a0ba2a86e_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(-1,-1,1,1) * _MainTex_TexelSize.xyxy;
  r1.x = 0.5 * _SampleScale;
  r2.xyzw = r0.xyzy * r1.xxxx + v1.xyxy;
  r0.xyzw = r0.xwzw * r1.xxxx + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r1.xyz = r2.xyz + r1.xyz;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyz = r2.xyz + r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xyzw = _BaseTex.Sample(sampler_BaseTex, w1.xy).xyzw;
  o0.xyz = r0.xyz * float3(0.25,0.25,0.25) + r1.xyz;
  o0.w = 0;
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
		vs_667e1a0533641c51_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_0f6cec8a0ba2a86e_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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

Texture2D _BaseTex;
SamplerState sampler_BaseTex;
Texture2D _MainTex;
SamplerState sampler_MainTex;

float2 _BaseTex_TexelSize;
float4 _MainTex_ST;
float4 _BaseTex_ST;
float2 _MainTex_TexelSize;
float _SampleScale;

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

// vs 667e1a0533641c51: 1 retail keyword combination(s)
void vs_667e1a0533641c51_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
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
  r0.x = cmp(_BaseTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  r0.zw = v1.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
  p1.y = r0.x ? r0.y : r0.w;
  p1.x = r0.z;
  o1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps 40fc00ad3fb13982: 1 retail keyword combination(s)
void ps_40fc00ad3fb13982_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 1;
  r0.z = _SampleScale;
  r0.xyzw = _MainTex_TexelSize.xyxy * r0.xxzz;
  r1.zw = float2(-1,0);
  r1.x = _SampleScale;
  r2.xyzw = -r0.xywy * r1.xxwx + v1.xyxy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + r3.xyz;
  r3.xy = -r0.zy * r1.zx + v1.xy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r3.xy).xyzw;
  r2.xyz = r3.xyz + r2.xyz;
  r3.xyzw = r0.zwxw * r1.zwxw + v1.xyxy;
  r4.xyzw = r0.zywy * r1.zxwx + v1.xyxy;
  r0.xy = r0.xy * r1.xx + v1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r3.xy).xyzw;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r3.zw).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + r2.xyz;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = r2.xyz * float3(4,4,4) + r1.xyz;
  r1.xyz = r3.xyz * float3(2,2,2) + r1.xyz;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r4.zw).xyzw;
  r1.xyz = r2.xyz + r1.xyz;
  r1.xyz = r3.xyz * float3(2,2,2) + r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xyzw = _BaseTex.Sample(sampler_BaseTex, w1.xy).xyzw;
  o0.xyz = r0.xyz * float3(0.0625,0.0625,0.0625) + r1.xyz;
  o0.w = 0;
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
		vs_667e1a0533641c51_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_40fc00ad3fb13982_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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

Texture2D _BaseTex;
SamplerState sampler_BaseTex;
Texture2D _MainTex;
SamplerState sampler_MainTex;

float2 _BaseTex_TexelSize;
float4 _MainTex_ST;
float4 _BaseTex_ST;
float2 _MainTex_TexelSize;
float _SampleScale;
float _Intensity;

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

// vs 667e1a0533641c51: 2 retail keyword combination(s)
void vs_667e1a0533641c51_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
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
  r0.x = cmp(_BaseTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  r0.zw = v1.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
  p1.y = r0.x ? r0.y : r0.w;
  p1.x = r0.z;
  o1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps f8e1dedfe5cfa66f: 1 retail keyword combination(s)
void ps_f8e1dedfe5cfa66f_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(-1,-1,1,1) * _MainTex_TexelSize.xyxy;
  r1.x = 0.5 * _SampleScale;
  r2.xyzw = r0.xyzy * r1.xxxx + v1.xyxy;
  r0.xyzw = r0.xwzw * r1.xxxx + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r1.xyz = r2.xyz + r1.xyz;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyz = r2.xyz + r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = _Intensity.xxx * r0.xyz;
  r1.xyzw = _BaseTex.Sample(sampler_BaseTex, w1.xy).xyzw;
  o0.xyz = r0.xyz * float3(0.25,0.25,0.25) + r1.xyz;
  o0.w = r1.w;
  return;
}


// ps d41b8f7adc2c30cb: 1 retail keyword combination(s)
void ps_d41b8f7adc2c30cb_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(-1,-1,1,1) * _MainTex_TexelSize.xyxy;
  r1.x = 0.5 * _SampleScale;
  r2.xyzw = r0.xyzy * r1.xxxx + v1.xyxy;
  r0.xyzw = r0.xwzw * r1.xxxx + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r1.xyz = r2.xyz + r1.xyz;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyz = r2.xyz + r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = _Intensity.xxx * r0.xyz;
  r0.xyz = float3(0.25,0.25,0.25) * r0.xyz;
  r1.xyzw = _BaseTex.Sample(sampler_BaseTex, w1.xy).xyzw;
  r2.xyz = r1.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r2.xyz = r1.xyz * r2.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  r0.xyz = r1.xyz * r2.xyz + r0.xyz;
  o0.w = r1.w;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.416666657,0.416666657,0.416666657) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = r0.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
  o0.xyz = max(float3(0,0,0), r0.xyz);
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
		vs_667e1a0533641c51_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_f8e1dedfe5cfa66f_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		ps_d41b8f7adc2c30cb_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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

Texture2D _BaseTex;
SamplerState sampler_BaseTex;
Texture2D _MainTex;
SamplerState sampler_MainTex;

float2 _BaseTex_TexelSize;
float4 _MainTex_ST;
float4 _BaseTex_ST;
float2 _MainTex_TexelSize;
float _SampleScale;
float _Intensity;

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

// vs 667e1a0533641c51: 2 retail keyword combination(s)
void vs_667e1a0533641c51_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
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
  r0.x = cmp(_BaseTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  r0.zw = v1.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
  p1.y = r0.x ? r0.y : r0.w;
  p1.x = r0.z;
  o1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  return;
}


// ps d3c9326e7509ebd2: 1 retail keyword combination(s)
void ps_d3c9326e7509ebd2_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 1;
  r0.z = _SampleScale;
  r0.xyzw = _MainTex_TexelSize.xyxy * r0.xxzz;
  r1.zw = float2(-1,0);
  r1.x = _SampleScale;
  r2.xyzw = -r0.xywy * r1.xxwx + v1.xyxy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + r3.xyz;
  r3.xy = -r0.zy * r1.zx + v1.xy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r3.xy).xyzw;
  r2.xyz = r3.xyz + r2.xyz;
  r3.xyzw = r0.zwxw * r1.zwxw + v1.xyxy;
  r4.xyzw = r0.zywy * r1.zxwx + v1.xyxy;
  r0.xy = r0.xy * r1.xx + v1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r3.xy).xyzw;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r3.zw).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + r2.xyz;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = r2.xyz * float3(4,4,4) + r1.xyz;
  r1.xyz = r3.xyz * float3(2,2,2) + r1.xyz;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r4.zw).xyzw;
  r1.xyz = r2.xyz + r1.xyz;
  r1.xyz = r3.xyz * float3(2,2,2) + r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = _Intensity.xxx * r0.xyz;
  r1.xyzw = _BaseTex.Sample(sampler_BaseTex, w1.xy).xyzw;
  o0.xyz = r0.xyz * float3(0.0625,0.0625,0.0625) + r1.xyz;
  o0.w = r1.w;
  return;
}


// ps 141e957d5dd9b8da: 1 retail keyword combination(s)
void ps_141e957d5dd9b8da_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xw = float2(1,0);
  r0.z = _SampleScale;
  r0.xyzw = _MainTex_TexelSize.xyxy * r0.xxzw;
  r1.x = _SampleScale;
  r2.xyzw = -r0.xywy * r1.xxxx + v1.xyxy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r2.xyz = r2.xyz * float3(2,2,2) + r3.xyz;
  r1.z = -1;
  r1.yw = -r0.zy * r1.zx + v1.xy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r1.yw).xyzw;
  r2.xyz = r3.xyz + r2.xyz;
  r3.xyzw = r0.zwxw * r1.zxxx + v1.xyxy;
  r4.xyzw = r0.zywy * r1.zxxx + v1.xyxy;
  r0.xy = r0.xy * r1.xx + v1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r3.xy).xyzw;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r3.zw).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + r2.xyz;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xyz = r2.xyz * float3(4,4,4) + r1.xyz;
  r1.xyz = r3.xyz * float3(2,2,2) + r1.xyz;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r4.zw).xyzw;
  r1.xyz = r2.xyz + r1.xyz;
  r1.xyz = r3.xyz * float3(2,2,2) + r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = _Intensity.xxx * r0.xyz;
  r0.xyz = float3(0.0625,0.0625,0.0625) * r0.xyz;
  r1.xyzw = _BaseTex.Sample(sampler_BaseTex, w1.xy).xyzw;
  r2.xyz = r1.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r2.xyz = r1.xyz * r2.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  r0.xyz = r1.xyz * r2.xyz + r0.xyz;
  o0.w = r1.w;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.416666657,0.416666657,0.416666657) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = r0.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
  o0.xyz = max(float3(0,0,0), r0.xyz);
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
		vs_667e1a0533641c51_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_d3c9326e7509ebd2_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		ps_141e957d5dd9b8da_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
