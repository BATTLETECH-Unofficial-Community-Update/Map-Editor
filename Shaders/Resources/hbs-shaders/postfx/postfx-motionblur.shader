Shader "Hidden/Post FX/Motion Blur"
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

Texture2D _CameraMotionVectorsTexture;
SamplerState sampler_CameraMotionVectorsTexture;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;

float4 _MainTex_ST;
float4 _CameraMotionVectorsTexture_TexelSize;
float _VelocityScale;
float _RcpMaxBlurRadius;

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


// ps a366c2c9e0e72048: 1 retail keyword combination(s)
void ps_a366c2c9e0e72048_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 0.5 * _VelocityScale;
  r0.xy = _CameraMotionVectorsTexture_TexelSize.zw * r0.xx;
  r1.xyzw = _CameraMotionVectorsTexture.Sample(sampler_CameraMotionVectorsTexture, v1.xy).xyzw;
  r0.xy = r1.xy * r0.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.z = sqrt(r0.z);
  r0.z = _RcpMaxBlurRadius * r0.z;
  r0.z = max(1, r0.z);
  r0.xy = r0.xy / r0.zz;
  r0.xy = r0.xy * _RcpMaxBlurRadius.xx + float2(1,1);
  o0.xy = float2(0.5,0.5) * r0.xy;
  r0.x = 1 + -unity_OrthoParams.w;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.y = _ZBufferParams.x * r1.x;
  r0.x = r0.x * r0.y + _ZBufferParams.y;
  r0.y = -unity_OrthoParams.w * r0.y + 1;
  o0.z = r0.y / r0.x;
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
		ps_a366c2c9e0e72048_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
float4 _MainTex_TexelSize;
float _MaxBlurRadius;

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


// ps d25830c2f74aa54f: 1 retail keyword combination(s)
void ps_d25830c2f74aa54f_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,-0.5,0.5,-0.5) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  r0.zw = r1.xy * float2(2,2) + float2(-1,-1);
  r0.xyzw = _MaxBlurRadius.xxxx * r0.xyzw;
  r1.x = dot(r0.zw, r0.zw);
  r1.y = dot(r0.xy, r0.xy);
  r1.x = cmp(r1.x < r1.y);
  r0.xy = r1.xx ? r0.xy : r0.zw;
  r0.z = dot(r0.xy, r0.xy);
  r1.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + v1.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r1.xy = r1.xy * float2(2,2) + float2(-1,-1);
  r1.zw = r2.xy * float2(2,2) + float2(-1,-1);
  r1.xyzw = _MaxBlurRadius.xxxx * r1.xyzw;
  r0.w = dot(r1.zw, r1.zw);
  r0.z = cmp(r0.z < r0.w);
  r0.xy = r0.zz ? r1.zw : r0.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.w = dot(r1.xy, r1.xy);
  r0.z = cmp(r0.z < r0.w);
  o0.xy = r0.zz ? r1.xy : r0.xy;
  o0.zw = float2(0,0);
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
		ps_d25830c2f74aa54f_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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


// ps 8f4064a919d78271: 1 retail keyword combination(s)
void ps_8f4064a919d78271_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,-0.5,0.5,-0.5) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.z = dot(r1.xy, r1.xy);
  r0.w = dot(r0.xy, r0.xy);
  r0.z = cmp(r0.z < r0.w);
  r0.xy = r0.zz ? r0.xy : r1.xy;
  r0.z = dot(r0.xy, r0.xy);
  r1.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + v1.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r0.w = dot(r2.xy, r2.xy);
  r0.z = cmp(r0.z < r0.w);
  r0.xy = r0.zz ? r2.xy : r0.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.w = dot(r1.xy, r1.xy);
  r0.z = cmp(r0.z < r0.w);
  o0.xy = r0.zz ? r1.xy : r0.xy;
  o0.zw = float2(0,0);
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
		ps_8f4064a919d78271_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
float4 _MainTex_TexelSize;
int _TileMaxLoop;
float2 _TileMaxOffs;

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


// ps a664c10391bb9354: 1 retail keyword combination(s)
void ps_a664c10391bb9354_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = _MainTex_TexelSize.xy * _TileMaxOffs.xy + v1.xy;
  r1.yz = float2(0,0);
  r1.xw = _MainTex_TexelSize.xy;
  r0.zw = float2(0,0);
  r2.x = 0;
  [loop] while (true) {
    r2.y = cmp((int)r2.x >= asint(_TileMaxLoop));
    [branch] if (r2.y != 0) break;
    r2.y = (int)r2.x;
    r2.yz = r1.xy * r2.yy + r0.xy;
    r3.xy = r0.zw;
    r2.w = 0;
    [loop] while (true) {
      r3.z = cmp((int)r2.w >= asint(_TileMaxLoop));
      [branch] if (r3.z != 0) break;
      r3.z = (int)r2.w;
      r3.zw = r1.zw * r3.zz + r2.yz;
      r4.xyzw = _MainTex.Sample(sampler_MainTex, r3.zw).xyzw;
      r3.z = dot(r3.xy, r3.xy);
      r3.w = dot(r4.xy, r4.xy);
      r3.z = cmp(r3.z < r3.w);
      r3.xy = r3.zz ? r4.xy : r3.xy;
      r2.w = (int)r2.w + 1;
    }
    r0.zw = r3.xy;
    r2.x = (int)r2.x + 1;
  }
  o0.xy = r0.zw;
  o0.zw = float2(0,0);
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
		ps_a664c10391bb9354_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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


// ps 72a4305bda91cc71: 1 retail keyword combination(s)
void ps_72a4305bda91cc71_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex_TexelSize.yyxy * float4(0,1,1,1) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.z = dot(r1.xy, r1.xy);
  r0.w = dot(r0.xy, r0.xy);
  r0.z = cmp(r0.z < r0.w);
  r0.xy = r0.zz ? r0.xy : r1.xy;
  r0.z = dot(r0.xy, r0.xy);
  r1.xyzw = _MainTex_TexelSize.xyxy * float4(1,0,-1,1) + v1.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r0.w = dot(r2.xy, r2.xy);
  r0.z = cmp(r0.w < r0.z);
  r0.xy = r0.zz ? r0.xy : r2.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.w = dot(r1.xy, r1.xy);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.zw = float2(1.00999999,1.00999999) * r2.xy;
  r2.x = dot(r1.zw, r1.zw);
  r0.w = cmp(r2.x < r0.w);
  r1.xy = r0.ww ? r1.xy : r1.zw;
  r0.w = dot(r1.xy, r1.xy);
  r2.xyzw = -_MainTex_TexelSize.xyxy * float4(-1,1,1,0) + v1.xyxy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r1.z = dot(r3.xy, r3.xy);
  r0.w = cmp(r1.z < r0.w);
  r1.xy = r0.ww ? r1.xy : r3.xy;
  r0.w = dot(r1.xy, r1.xy);
  r0.z = cmp(r0.w < r0.z);
  r0.xy = r0.zz ? r0.xy : r1.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.w = dot(r2.xy, r2.xy);
  r1.xyzw = -_MainTex_TexelSize.xyyy * float4(1,1,0,1) + v1.xyxy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.z = dot(r3.xy, r3.xy);
  r0.w = cmp(r1.z < r0.w);
  r1.zw = r0.ww ? r2.xy : r3.xy;
  r0.w = dot(r1.zw, r1.zw);
  r2.x = dot(r1.xy, r1.xy);
  r0.w = cmp(r2.x < r0.w);
  r1.xy = r0.ww ? r1.zw : r1.xy;
  r0.w = dot(r1.xy, r1.xy);
  r0.z = cmp(r0.w < r0.z);
  r0.xy = r0.zz ? r0.xy : r1.xy;
  o0.xy = float2(0.990099013,0.990099013) * r0.xy;
  o0.zw = float2(0,0);
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
		ps_72a4305bda91cc71_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
Texture2D _VelocityTex;
SamplerState sampler_VelocityTex;
Texture2D _NeighborMaxTex;
SamplerState sampler_NeighborMaxTex;

float4 _MainTex_TexelSize;
float2 _VelocityTex_TexelSize;
float2 _NeighborMaxTex_TexelSize;
float _MaxBlurRadius;
float _LoopCount;

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

// vs 1b5050a9a3704e6e: 1 retail keyword combination(s)
void vs_1b5050a9a3704e6e_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps 0bf6678c428372f1: 1 retail keyword combination(s)
void ps_0bf6678c428372f1_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r1.xy = float2(2,0) + w1.xy;
  r1.xy = _ScreenParams.xy * r1.xy;
  r1.xy = floor(r1.xy);
  r1.x = dot(float2(0.0671105608,0.00583714992), r1.xy);
  r1.x = frac(r1.x);
  r1.x = 52.9829178 * r1.x;
  r1.x = frac(r1.x);
  r1.x = 6.28318548 * r1.x;
  sincos(r1.x, r1.x, r2.x);
  r2.y = r1.x;
  r1.xy = _NeighborMaxTex_TexelSize.xy * r2.xy;
  r1.xy = r1.xy * float2(0.25,0.25) + w1.xy;
  r1.xyzw = _NeighborMaxTex.Sample(sampler_NeighborMaxTex, r1.xy).xyzw;
  r1.z = dot(r1.xy, r1.xy);
  r1.z = sqrt(r1.z);
  r1.w = cmp(r1.z < 2);
  [branch] if (r1.w != 0) {
    o0.xyzw = r0.xyzw;
    return;
  }
  r2.xyzw = _VelocityTex.SampleLevel(sampler_VelocityTex, w1.xy, 0).xyzw;
  r2.xy = r2.xy * float2(2,2) + float2(-1,-1);
  r2.xy = _MaxBlurRadius.xx * r2.xy;
  r1.w = dot(r2.xy, r2.xy);
  r1.w = sqrt(r1.w);
  r3.xy = max(float2(0.5,1), r1.ww);
  r1.w = 1 / r2.z;
  r2.w = r3.x + r3.x;
  r2.w = cmp(r1.z < r2.w);
  r3.x = r1.z / r3.x;
  r2.xy = r3.xx * r2.xy;
  r2.xy = r2.ww ? r2.xy : r1.xy;
  r2.w = 0.5 * r1.z;
  r2.w = min(_LoopCount, r2.w);
  r2.w = floor(r2.w);
  r3.x = 1 / r2.w;
  r3.zw = _ScreenParams.xy * v1.xy;
  r3.zw = floor(r3.zw);
  r3.z = dot(float2(0.0671105608,0.00583714992), r3.zw);
  r3.z = frac(r3.z);
  r3.zw = float2(52.9829178,0.25) * r3.zx;
  r3.z = frac(r3.z);
  r3.z = -0.5 + r3.z;
  r4.x = -r3.x * 0.5 + 1;
  r5.w = 1;
  r6.xyzw = float4(0,0,0,0);
  r4.y = r4.x;
  r4.z = 0;
  r4.w = r3.y;
  [loop] while (true) {
    r7.x = cmp(r3.w >= r4.y);
    [branch] if (r7.x != 0) break;
    r7.xy = float2(0.25,0.5) * r4.zz;
    r7.xy = frac(r7.xy);
    r7.xy = cmp(float2(0.499000013,0.499000013) < r7.xy);
    r7.xz = r7.xx ? r2.xy : r1.xy;
    r7.w = r7.y ? -r4.y : r4.y;
    r7.w = r3.z * r3.x + r7.w;
    r7.xz = r7.xz * r7.ww;
    r8.xy = r7.xz * _MainTex_TexelSize.xy + v1.xy;
    r7.xz = r7.xz * _VelocityTex_TexelSize.xy + w1.xy;
    r8.xyzw = _MainTex.SampleLevel(sampler_MainTex, r8.xy, 0).xyzw;
    r9.xyzw = _VelocityTex.SampleLevel(sampler_VelocityTex, r7.xz, 0).xyzw;
    r7.xz = r9.xy * float2(2,2) + float2(-1,-1);
    r7.xz = _MaxBlurRadius.xx * r7.xz;
    r8.w = -r9.z + r2.z;
    r8.w = r8.w * r1.w;
    r8.w = saturate(20 * r8.w);
    r7.x = dot(r7.xz, r7.xz);
    r7.x = sqrt(r7.x);
    r7.x = r7.x + -r4.w;
    r7.x = r8.w * r7.x + r4.w;
    r7.z = saturate(-r1.z * abs(r7.w) + r7.x);
    r7.z = r7.z / r7.x;
    r7.w = 1.20000005 + -r4.y;
    r7.z = r7.z * r7.w;
    r5.xyz = r8.xyz;
    r6.xyzw = r5.xyzw * r7.zzzz + r6.xyzw;
    r4.w = max(r7.x, r4.w);
    r5.x = r4.y + -r3.x;
    r4.y = r7.y ? r5.x : r4.y;
    r4.z = 1 + r4.z;
  }
  r1.x = dot(r4.ww, r2.ww);
  r1.x = 1.20000005 / r1.x;
  r2.xyz = r0.xyz;
  r2.w = 1;
  r1.xyzw = r2.xyzw * r1.xxxx + r6.xyzw;
  o0.xyz = r1.xyz / r1.www;
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
		vs_1b5050a9a3704e6e_impl(v.position0, v.texcoord0, o0, o1, p1);
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
		ps_0bf6678c428372f1_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			#pragma exclude_renderers nomrt
			#pragma multi_compile _ UNITY_COLORSPACE_GAMMA

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
	float4 t0 : SV_Target0;
	float4 t1 : SV_Target1;
};

// vs c54afaaf18b83e83: 2 retail keyword combination(s)
void vs_c54afaaf18b83e83_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1)
{
  o0.xyzw = v0.xyzw;
  o1.xy = v1.xy * float2(1,-1) + float2(0,1);
  p1.xy = float2(0,0);
  return;
}


// ps a20715125f0cd0e6: 1 retail keyword combination(s)
void ps_a20715125f0cd0e6_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.416666657,0.416666657,0.416666657) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = r0.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  o0.xyzw = dot(float3(0.298999995,0.587000012,0.114), r0.xyz);
  r0.x = _ScreenParams.x * v1.x;
  r0.x = 0.5 * r0.x;
  r0.y = floor(r0.x);
  r0.x = frac(r0.x);
  r0.x = cmp(0.5 < r0.x);
  r0.xzw = r0.xxx ? float3(0.5,-0.418687999,-0.0813120008) : float3(-0.168735996,-0.331263989,0.5);
  r0.y = r0.y * 2 + 1;
  r1.x = -1 + _ScreenParams.z;
  r1.x = r1.x * r0.y;
  r1.y = v1.y;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.416666657,0.416666657,0.416666657) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r1.xyz = r1.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r0.x = dot(r0.xzw, r1.xyz);
  o1.xyzw = float4(0.5,0.5,0.5,0.5) + r0.xxxx;
  return;
}


// ps fa46076c7f638137: 1 retail keyword combination(s)
void ps_fa46076c7f638137_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyzw = dot(float3(0.298999995,0.587000012,0.114), r0.xyz);
  r0.x = _ScreenParams.x * v1.x;
  r0.x = 0.5 * r0.x;
  r0.y = floor(r0.x);
  r0.x = frac(r0.x);
  r0.x = cmp(0.5 < r0.x);
  r0.xzw = r0.xxx ? float3(0.5,-0.418687999,-0.0813120008) : float3(-0.168735996,-0.331263989,0.5);
  r0.y = r0.y * 2 + 1;
  r1.x = -1 + _ScreenParams.z;
  r1.x = r1.x * r0.y;
  r1.y = v1.y;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r0.x = dot(r0.xzw, r1.xyz);
  o1.xyzw = float4(0.5,0.5,0.5,0.5) + r0.xxxx;
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
		vs_c54afaaf18b83e83_impl(v.position0, v.texcoord0, o0, o1, p1);
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
		float4 o1 = 0;
		ps_a20715125f0cd0e6_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0, o1);
		r.t0 = o0;
		r.t1 = o1;
	}
#elif defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		ps_fa46076c7f638137_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0, o1);
		r.t0 = o0;
		r.t1 = o1;
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
Texture2D _History1LumaTex;
SamplerState sampler_History1LumaTex;
Texture2D _History1ChromaTex;
SamplerState sampler_History1ChromaTex;
Texture2D _History2LumaTex;
SamplerState sampler_History2LumaTex;
Texture2D _History2ChromaTex;
SamplerState sampler_History2ChromaTex;
Texture2D _History3LumaTex;
SamplerState sampler_History3LumaTex;
Texture2D _History3ChromaTex;
SamplerState sampler_History3ChromaTex;
Texture2D _History4LumaTex;
SamplerState sampler_History4LumaTex;
Texture2D _History4ChromaTex;
SamplerState sampler_History4ChromaTex;

float4 _MainTex_TexelSize;
float _History1Weight;
float _History2Weight;
float _History3Weight;
float _History4Weight;

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

// vs 1b5050a9a3704e6e: 2 retail keyword combination(s)
void vs_1b5050a9a3704e6e_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps 80f66f8546087020: 1 retail keyword combination(s)
void ps_80f66f8546087020_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = r0.w;
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.416666657,0.416666657,0.416666657) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = r0.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r1.xyzw = _History1LumaTex.Sample(sampler_History1LumaTex, w1.xy).xyzw;
  r0.w = _MainTex_TexelSize.z * w1.x;
  r0.w = 0.5 * r0.w;
  r0.w = floor(r0.w);
  r0.w = r0.w * 2 + 0.5;
  r2.z = r0.w * _MainTex_TexelSize.x + _MainTex_TexelSize.x;
  r2.x = _MainTex_TexelSize.x * r0.w;
  r2.yw = w1.yy;
  r3.xyzw = _History1ChromaTex.Sample(sampler_History1ChromaTex, r2.zw).xyzw;
  r0.w = -0.5 + r3.x;
  r3.xy = float2(1.40199995,0.714139998) * r0.ww;
  r4.xyzw = _History1ChromaTex.Sample(sampler_History1ChromaTex, r2.xy).xyzw;
  r0.w = -0.5 + r4.x;
  r3.z = r0.w * -0.344139993 + -r3.y;
  r3.w = 1.77199996 * r0.w;
  r1.xyz = r3.xzw + r1.xxx;
  r0.xyz = r1.xyz * _History1Weight.xxx + r0.xyz;
  r1.xyzw = _History2LumaTex.Sample(sampler_History2LumaTex, w1.xy).xyzw;
  r3.xyzw = _History2ChromaTex.Sample(sampler_History2ChromaTex, r2.zw).xyzw;
  r0.w = -0.5 + r3.x;
  r3.xy = float2(1.40199995,0.714139998) * r0.ww;
  r4.xyzw = _History2ChromaTex.Sample(sampler_History2ChromaTex, r2.xy).xyzw;
  r0.w = -0.5 + r4.x;
  r3.z = r0.w * -0.344139993 + -r3.y;
  r3.w = 1.77199996 * r0.w;
  r1.xyz = r3.xzw + r1.xxx;
  r0.xyz = r1.xyz * _History2Weight.xxx + r0.xyz;
  r1.xyzw = _History3ChromaTex.Sample(sampler_History3ChromaTex, r2.zw).xyzw;
  r3.xyzw = _History4ChromaTex.Sample(sampler_History4ChromaTex, r2.zw).xyzw;
  r0.w = -0.5 + r3.x;
  r3.xy = float2(1.40199995,0.714139998) * r0.ww;
  r0.w = -0.5 + r1.x;
  r1.xy = float2(1.40199995,0.714139998) * r0.ww;
  r4.xyzw = _History3ChromaTex.Sample(sampler_History3ChromaTex, r2.xy).xyzw;
  r2.xyzw = _History4ChromaTex.Sample(sampler_History4ChromaTex, r2.xy).xyzw;
  r0.w = -0.5 + r2.x;
  r2.x = -0.5 + r4.x;
  r1.z = r2.x * -0.344139993 + -r1.y;
  r1.w = 1.77199996 * r2.x;
  r2.xyzw = _History3LumaTex.Sample(sampler_History3LumaTex, w1.xy).xyzw;
  r1.xyz = r2.xxx + r1.xzw;
  r0.xyz = r1.xyz * _History3Weight.xxx + r0.xyz;
  r3.z = r0.w * -0.344139993 + -r3.y;
  r3.w = 1.77199996 * r0.w;
  r1.xyzw = _History4LumaTex.Sample(sampler_History4LumaTex, w1.xy).xyzw;
  r1.xyz = r1.xxx + r3.xzw;
  r0.xyz = r1.xyz * _History4Weight.xxx + r0.xyz;
  r0.w = _History2Weight + _History1Weight;
  r0.w = _History3Weight + r0.w;
  r0.w = _History4Weight + r0.w;
  r0.w = 1 + r0.w;
  r0.xyz = r0.xyz / r0.www;
  r1.xyz = r0.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r1.xyz = r0.xyz * r1.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  o0.xyz = r1.xyz * r0.xyz;
  return;
}


// ps d39ada3f34e2a6fc: 1 retail keyword combination(s)
void ps_d39ada3f34e2a6fc_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _History1LumaTex.Sample(sampler_History1LumaTex, w1.xy).xyzw;
  r0.y = _MainTex_TexelSize.z * w1.x;
  r0.y = 0.5 * r0.y;
  r0.y = floor(r0.y);
  r0.y = r0.y * 2 + 0.5;
  r1.z = r0.y * _MainTex_TexelSize.x + _MainTex_TexelSize.x;
  r1.x = _MainTex_TexelSize.x * r0.y;
  r1.yw = w1.yy;
  r2.xyzw = _History1ChromaTex.Sample(sampler_History1ChromaTex, r1.zw).xyzw;
  r0.y = -0.5 + r2.x;
  r2.xy = float2(1.40199995,0.714139998) * r0.yy;
  r3.xyzw = _History1ChromaTex.Sample(sampler_History1ChromaTex, r1.xy).xyzw;
  r0.y = -0.5 + r3.x;
  r2.z = r0.y * -0.344139993 + -r2.y;
  r2.w = 1.77199996 * r0.y;
  r0.xyz = r2.xzw + r0.xxx;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.xyz = r0.xyz * _History1Weight.xxx + r2.xyz;
  o0.w = r2.w;
  r2.xyzw = _History2LumaTex.Sample(sampler_History2LumaTex, w1.xy).xyzw;
  r3.xyzw = _History2ChromaTex.Sample(sampler_History2ChromaTex, r1.zw).xyzw;
  r0.w = -0.5 + r3.x;
  r3.xy = float2(1.40199995,0.714139998) * r0.ww;
  r4.xyzw = _History2ChromaTex.Sample(sampler_History2ChromaTex, r1.xy).xyzw;
  r0.w = -0.5 + r4.x;
  r3.z = r0.w * -0.344139993 + -r3.y;
  r3.w = 1.77199996 * r0.w;
  r2.xyz = r3.xzw + r2.xxx;
  r0.xyz = r2.xyz * _History2Weight.xxx + r0.xyz;
  r2.xyzw = _History3ChromaTex.Sample(sampler_History3ChromaTex, r1.zw).xyzw;
  r3.xyzw = _History4ChromaTex.Sample(sampler_History4ChromaTex, r1.zw).xyzw;
  r0.w = -0.5 + r3.x;
  r3.xy = float2(1.40199995,0.714139998) * r0.ww;
  r0.w = -0.5 + r2.x;
  r2.xy = float2(1.40199995,0.714139998) * r0.ww;
  r4.xyzw = _History3ChromaTex.Sample(sampler_History3ChromaTex, r1.xy).xyzw;
  r1.xyzw = _History4ChromaTex.Sample(sampler_History4ChromaTex, r1.xy).xyzw;
  r0.w = -0.5 + r1.x;
  r1.x = -0.5 + r4.x;
  r2.z = r1.x * -0.344139993 + -r2.y;
  r2.w = 1.77199996 * r1.x;
  r1.xyzw = _History3LumaTex.Sample(sampler_History3LumaTex, w1.xy).xyzw;
  r1.xyz = r1.xxx + r2.xzw;
  r0.xyz = r1.xyz * _History3Weight.xxx + r0.xyz;
  r3.z = r0.w * -0.344139993 + -r3.y;
  r3.w = 1.77199996 * r0.w;
  r1.xyzw = _History4LumaTex.Sample(sampler_History4LumaTex, w1.xy).xyzw;
  r1.xyz = r1.xxx + r3.xzw;
  r0.xyz = r1.xyz * _History4Weight.xxx + r0.xyz;
  r0.w = _History2Weight + _History1Weight;
  r0.w = _History3Weight + r0.w;
  r0.w = _History4Weight + r0.w;
  r0.w = 1 + r0.w;
  o0.xyz = r0.xyz / r0.www;
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
		vs_1b5050a9a3704e6e_impl(v.position0, v.texcoord0, o0, o1, p1);
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
		ps_80f66f8546087020_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		ps_d39ada3f34e2a6fc_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
Texture2D _History1LumaTex;
SamplerState sampler_History1LumaTex;
Texture2D _History2LumaTex;
SamplerState sampler_History2LumaTex;
Texture2D _History3LumaTex;
SamplerState sampler_History3LumaTex;
Texture2D _History4LumaTex;
SamplerState sampler_History4LumaTex;

float4 _MainTex_TexelSize;
float _History1Weight;
float _History2Weight;
float _History3Weight;
float _History4Weight;

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

// vs 1b5050a9a3704e6e: 1 retail keyword combination(s)
void vs_1b5050a9a3704e6e_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps b0e307193f174657: 1 retail keyword combination(s)
void ps_b0e307193f174657_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _History1LumaTex.Sample(sampler_History1LumaTex, v1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.xyz = r0.xyz * _History1Weight.xxx + r1.xyz;
  o0.w = r1.w;
  r1.xyzw = _History2LumaTex.Sample(sampler_History2LumaTex, v1.xy).xyzw;
  r0.xyz = r1.xyz * _History2Weight.xxx + r0.xyz;
  r1.xyzw = _History3LumaTex.Sample(sampler_History3LumaTex, v1.xy).xyzw;
  r0.xyz = r1.xyz * _History3Weight.xxx + r0.xyz;
  r1.xyzw = _History4LumaTex.Sample(sampler_History4LumaTex, v1.xy).xyzw;
  r0.xyz = r1.xyz * _History4Weight.xxx + r0.xyz;
  r0.w = _History2Weight + _History1Weight;
  r0.w = _History3Weight + r0.w;
  r0.w = _History4Weight + r0.w;
  r0.w = 1 + r0.w;
  o0.xyz = r0.xyz / r0.www;
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
		vs_1b5050a9a3704e6e_impl(v.position0, v.texcoord0, o0, o1, p1);
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
		ps_b0e307193f174657_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
