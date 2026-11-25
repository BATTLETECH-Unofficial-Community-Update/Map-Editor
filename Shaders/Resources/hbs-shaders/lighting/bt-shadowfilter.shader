Shader "Hidden/BT-ShadowFilter"
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
			#pragma target 4.0

#define cmp -

Texture2D _DirShadowmap;
SamplerState sampler_DirShadowmap;

float4 _DirShadowmap_TexelSize;
float _C;

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
	float t0 : SV_Target0;
};

// vs 9a54fa21a87da014: 1 retail keyword combination(s)
void vs_9a54fa21a87da014_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float2 o0 : TEXCOORD0,
  inout float2 p0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v1.xy;
  p0.xy = float2(0,0);
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


// ps 0362fbeb66827356: 1 retail keyword combination(s)
void ps_0362fbeb66827356_impl(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  float4 v1 : SV_POSITION0,
  inout float o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _DirShadowmap_TexelSize.zwzw * v0.xyxy;
  r0.xyzw = floor(r0.xyzw);
  r1.xyzw = float4(0.5,0.5,0.5,0.5) * _DirShadowmap_TexelSize.xyxy;
  r0.xyzw = r0.xyzw * _DirShadowmap_TexelSize.xyxy + r1.xyzw;
  r1.xyzw = _DirShadowmap_TexelSize.xyxy * float4(-1,-1,1,-1) + r0.zwzw;
  r2.xyzw = r0.zwzw + r0.zwzw;
  r0.xyzw = _DirShadowmap_TexelSize.xyxy * float4(-1,1,1,1) + r0.xyzw;
  r3.xyzw = floor(r2.zwzw);
  r2.xyzw = ceil(r2.xyzw);
  r2.xyzw = float4(0.5,0.5,0.5,0.5) * r2.xyzw;
  r3.xyzw = float4(0.5,0.5,0.5,0.5) * r3.xyzw;
  r1.xyzw = max(r3.xyzw, r1.xyzw);
  r0.xyzw = max(r3.xyzw, r0.xyzw);
  r0.xyzw = min(r0.xyzw, r2.xyzw);
  r1.xyzw = min(r1.xyzw, r2.xyzw);
  r2.xyzw = _DirShadowmap.Sample(sampler_DirShadowmap, r1.xy).xyzw;
  r1.xyzw = _DirShadowmap.Sample(sampler_DirShadowmap, r1.zw).xyzw;
  r2.y = r1.x;
  r1.xyzw = _DirShadowmap.Sample(sampler_DirShadowmap, r0.xy).xyzw;
  r0.xyzw = _DirShadowmap.Sample(sampler_DirShadowmap, r0.zw).xyzw;
  r2.w = r0.x;
  r2.z = r1.x;
  r0.xyzw = _C.xxxx * r2.xyzw;
  r0.xyzw = float4(1.44269502,1.44269502,1.44269502,1.44269502) * r0.xyzw;
  r0.xyzw = exp2(r0.xyzw);
  o0.x = dot(r0.xyzw, float4(0.25,0.25,0.25,0.25));
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float2 p0 = 0;
		float4 o1 = 0;
		vs_9a54fa21a87da014_impl(v.position0, v.texcoord0.xy, o0, p0, o1);
		o.texcoord0.xy = o0;
		o.texcoord1.xy = p0;
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
		ps_0362fbeb66827356_impl(i.texcoord0.xy, i.texcoord1.xy, i.sv_position, o0);
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
	float t0 : SV_Target0;
};

// vs 9a54fa21a87da014: 1 retail keyword combination(s)
void vs_9a54fa21a87da014_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float2 o0 : TEXCOORD0,
  inout float2 p0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v1.xy;
  p0.xy = float2(0,0);
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


// ps 45c61954ebd28fa8: 1 retail keyword combination(s)
void ps_45c61954ebd28fa8_impl(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  float4 v1 : SV_POSITION0,
  inout float o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v0.xy).xyzw;
  o0.x = r0.x;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float2 p0 = 0;
		float4 o1 = 0;
		vs_9a54fa21a87da014_impl(v.position0, v.texcoord0.xy, o0, p0, o1);
		o.texcoord0.xy = o0;
		o.texcoord1.xy = p0;
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
		ps_45c61954ebd28fa8_impl(i.texcoord0.xy, i.texcoord1.xy, i.sv_position, o0);
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

float4 _MainTex_TexelSize;

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
	float t0 : SV_Target0;
};

// vs 9a54fa21a87da014: 1 retail keyword combination(s)
void vs_9a54fa21a87da014_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float2 o0 : TEXCOORD0,
  inout float2 p0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v1.xy;
  p0.xy = float2(0,0);
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


// ps 39491594694636d2: 1 retail keyword combination(s)
void ps_39491594694636d2_impl(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  float4 v1 : SV_POSITION0,
  inout float o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = -_MainTex_TexelSize.xyyy * float4(1,1,0,1) + v0.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.x = r0.x * 2 + r1.x;
  r0.yz = -_MainTex_TexelSize.xy * float2(-1,1) + v0.xy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r0.x = r1.x + r0.x;
  r1.xyzw = _MainTex_TexelSize.xyxy * float4(-1,0,1,0) + v0.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r0.x = r2.x * 2 + r0.x;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, v0.xy).xyzw;
  r0.x = r2.x * 4 + r0.x;
  r0.x = r1.x * 2 + r0.x;
  r1.xyzw = _MainTex_TexelSize.xyyy * float4(-1,1,0,1) + v0.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r0.x = r2.x + r0.x;
  r0.x = r1.x * 2 + r0.x;
  r0.yz = _MainTex_TexelSize.xy * float2(1,1) + v0.xy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r0.x = r1.x + r0.x;
  o0.x = 0.0625 * r0.x;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float2 p0 = 0;
		float4 o1 = 0;
		vs_9a54fa21a87da014_impl(v.position0, v.texcoord0.xy, o0, p0, o1);
		o.texcoord0.xy = o0;
		o.texcoord1.xy = p0;
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
		ps_39491594694636d2_impl(i.texcoord0.xy, i.texcoord1.xy, i.sv_position, o0);
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

float4 _MainTex_TexelSize;
float2 _Direction;

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
	float t0 : SV_Target0;
};

// vs d66a4abad8762eaa: 1 retail keyword combination(s)
void vs_d66a4abad8762eaa_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float2 o0 : TEXCOORD0,
  inout float2 p0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  p0.xy = _Direction.xy * _MainTex_TexelSize.xy;
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


// ps 77bf0d029a3f2b90: 1 retail keyword combination(s)
void ps_77bf0d029a3f2b90_impl(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  float4 v1 : SV_POSITION0,
  inout float o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = -w0.xy * float2(3,3) + v0.xy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xy = w0.xy + r0.xy;
  r0.zw = v0.xy + v0.xy;
  r1.yz = floor(r0.zw);
  r0.zw = ceil(r0.zw);
  r0.zw = float2(0.5,0.5) * r0.zw;
  r1.yz = float2(0.5,0.5) * r1.yz;
  r0.xy = max(r1.yz, r0.xy);
  r0.xy = min(r0.xy, r0.zw);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xy = w0.xy + r0.xy;
  r0.xy = max(r0.xy, r1.yz);
  r0.xy = min(r0.xy, r0.zw);
  r1.w = 0.0855000019 * r2.x;
  r1.x = r1.x * 0.0205000006 + r1.w;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xy = w0.xy + r0.xy;
  r0.xy = max(r0.xy, r1.yz);
  r0.xy = min(r0.xy, r0.zw);
  r1.x = r2.x * 0.231999993 + r1.x;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xy = w0.xy + r0.xy;
  r0.xy = max(r0.xy, r1.yz);
  r0.xy = min(r0.xy, r0.zw);
  r1.x = r2.x * 0.324000001 + r1.x;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xy = w0.xy + r0.xy;
  r0.xy = max(r0.xy, r1.yz);
  r0.xy = min(r0.xy, r0.zw);
  r1.x = r2.x * 0.231999993 + r1.x;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xy = w0.xy + r0.xy;
  r0.xy = max(r0.xy, r1.yz);
  r0.xy = min(r0.xy, r0.zw);
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.y = r2.x * 0.0855000019 + r1.x;
  o0.x = r0.x * 0.0205000006 + r0.y;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float2 p0 = 0;
		float4 o1 = 0;
		vs_d66a4abad8762eaa_impl(v.position0, v.texcoord0.xy, o0, p0, o1);
		o.texcoord0.xy = o0;
		o.texcoord1.xy = p0;
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
		ps_77bf0d029a3f2b90_impl(i.texcoord0.xy, i.texcoord1.xy, i.sv_position, o0);
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

Texture2D _BT_ShadowMap;
SamplerState sampler_BT_ShadowMap;
Texture2D _ShadowDummyTex;
SamplerState sampler_ShadowDummyTex;

float4 _BT_ShadowMap_TexelSize;

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
	float t0 : SV_Target0;
};

// vs 9a54fa21a87da014: 1 retail keyword combination(s)
void vs_9a54fa21a87da014_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float2 o0 : TEXCOORD0,
  inout float2 p0 : TEXCOORD1,
  inout float4 o1 : SV_POSITION0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v1.xy;
  p0.xy = float2(0,0);
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


// ps b39cab8be7bccad4: 1 retail keyword combination(s)
void ps_b39cab8be7bccad4_impl(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  float4 v1 : SV_POSITION0,
  inout float o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _BT_ShadowMap_TexelSize.zwzw * v0.xyxy;
  r0.xyzw = floor(r0.xyzw);
  r1.xyzw = float4(0.5,0.5,0.5,0.5) * _BT_ShadowMap_TexelSize.xyxy;
  r0.xyzw = r0.xyzw * _BT_ShadowMap_TexelSize.xyxy + r1.xyzw;
  r1.xyzw = _BT_ShadowMap_TexelSize.xyxy * float4(-1,-1,1,-1) + r0.zwzw;
  r2.xyzw = r0.zwzw + r0.zwzw;
  r0.xyzw = _BT_ShadowMap_TexelSize.xyxy * float4(-1,1,1,1) + r0.xyzw;
  r3.xyzw = floor(r2.zwzw);
  r2.xyzw = ceil(r2.xyzw);
  r2.xyzw = float4(0.5,0.5,0.5,0.5) * r2.xyzw;
  r3.xyzw = float4(0.5,0.5,0.5,0.5) * r3.xyzw;
  r1.xyzw = max(r3.xyzw, r1.xyzw);
  r0.xyzw = max(r3.xyzw, r0.xyzw);
  r0.xyzw = min(r0.xyzw, r2.xyzw);
  r1.xyzw = min(r1.xyzw, r2.xyzw);
  r2.xyzw = _BT_ShadowMap.Sample(sampler_ShadowDummyTex, r1.xy).xyzw;
  r1.xyzw = _BT_ShadowMap.Sample(sampler_ShadowDummyTex, r1.zw).xyzw;
  r2.y = r1.x;
  r1.xyzw = _BT_ShadowMap.Sample(sampler_ShadowDummyTex, r0.xy).xyzw;
  r0.xyzw = _BT_ShadowMap.Sample(sampler_ShadowDummyTex, r0.zw).xyzw;
  r2.w = r0.x;
  r2.z = r1.x;
  r0.xyzw = float4(57.7078018,57.7078018,57.7078018,57.7078018) * r2.xyzw;
  r0.xyzw = exp2(r0.xyzw);
  r0.x = dot(r0.xyzw, float4(0.25,0.25,0.25,0.25));
  r1.xyzw = _ShadowDummyTex.Sample(sampler_ShadowDummyTex, v0.xy).xyzw;
  o0.x = r1.x + r0.x;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float2 p0 = 0;
		float4 o1 = 0;
		vs_9a54fa21a87da014_impl(v.position0, v.texcoord0.xy, o0, p0, o1);
		o.texcoord0.xy = o0;
		o.texcoord1.xy = p0;
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
		ps_b39cab8be7bccad4_impl(i.texcoord0.xy, i.texcoord1.xy, i.sv_position, o0);
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
