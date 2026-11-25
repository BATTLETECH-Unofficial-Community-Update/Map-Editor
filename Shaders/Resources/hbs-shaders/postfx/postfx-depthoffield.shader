Shader "Hidden/Post FX/Depth Of Field"
{
	Properties
	{
		_MainTex ("_MainTex", 2D) = "black" {}
	}
	SubShader
	{
		Pass
		{
			Name "CoC Calculation"
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

float4 _MainTex_TexelSize;
float _Distance;
float _LensCoeff;
float _RcpMaxCoC;

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


// ps 3c037b2fba667122: 1 retail keyword combination(s)
void ps_3c037b2fba667122_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.y = -_Distance + r0.x;
  r0.x = max(9.99999975e-006, r0.x);
  r0.y = _LensCoeff * r0.y;
  r0.x = r0.y / r0.x;
  r0.x = 0.5 * r0.x;
  r0.x = r0.x * _RcpMaxCoC + 0.5;
  o0.xyzw = saturate(r0.xxxx);
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
		ps_3c037b2fba667122_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "CoC Temporal Filter"
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0

#define cmp -

Texture2D _CoCTex;
SamplerState sampler_CoCTex;
Texture2D _CameraMotionVectorsTexture;
SamplerState sampler_CameraMotionVectorsTexture;
Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_TexelSize;
float3 _TaaParams;

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

// vs aff50ecf260d4fba: 1 retail keyword combination(s)
void vs_aff50ecf260d4fba_impl(
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


// ps eeb03ca6663d18c2: 1 retail keyword combination(s)
void ps_eeb03ca6663d18c2_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0,-1) * _MainTex_TexelSize.yy;
  r1.xy = -_TaaParams.xy + v1.xy;
  r0.w = _CoCTex.Sample(sampler_CoCTex, r1.xy).x;
  r1.xyzw = -_MainTex_TexelSize.xyyy * float4(1,0,0,1) + v1.xyxy;
  r1.x = _CoCTex.Sample(sampler_CoCTex, r1.xy).x;
  r0.z = _CoCTex.Sample(sampler_CoCTex, r1.zw).x;
  r1.y = cmp(r1.x < r0.w);
  r2.z = r1.y ? r1.x : r0.w;
  r1.x = max(r1.x, r0.w);
  r1.x = max(r1.x, r0.z);
  r1.z = cmp(r0.z < r2.z);
  r3.xy = float2(1,0) * _MainTex_TexelSize.xy;
  r3.zw = -r3.xy;
  r2.xy = r1.yy ? r3.zw : 0;
  r0.xyz = r1.zzz ? r0.xyz : r2.xyz;
  r2.xy = float2(0,1) * _MainTex_TexelSize.yy;
  r4.xyzw = _MainTex_TexelSize.yyxy * float4(0,1,1,0) + v1.xyxy;
  r2.z = _CoCTex.Sample(sampler_CoCTex, r4.xy).x;
  r1.y = _CoCTex.Sample(sampler_CoCTex, r4.zw).x;
  r1.z = cmp(r2.z < r0.z);
  r1.x = max(r2.z, r1.x);
  r1.x = max(r1.x, r1.y);
  r0.xyz = r1.zzz ? r2.xyz : r0.xyz;
  r1.z = cmp(r1.y < r0.z);
  r0.z = min(r0.z, r1.y);
  r0.xy = r1.zz ? r3.xy : r0.xy;
  r0.xy = v1.xy + r0.xy;
  r0.xy = _CameraMotionVectorsTexture.Sample(sampler_CameraMotionVectorsTexture, r0.xy).xy;
  r0.xy = v1.xy + -r0.xy;
  r0.x = _MainTex.Sample(sampler_MainTex, r0.xy).x;
  r0.x = max(r0.x, r0.z);
  r0.x = min(r0.x, r1.x);
  r0.x = r0.x + -r0.w;
  o0.xyzw = _TaaParams.zzzz * r0.xxxx + r0.wwww;
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
		vs_aff50ecf260d4fba_impl(v.position0, v.texcoord0, o0, o1, p1);
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
		ps_eeb03ca6663d18c2_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Downsample and Prefilter"
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile _ UNITY_COLORSPACE_GAMMA

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _CoCTex;
SamplerState sampler_CoCTex;

float4 _MainTex_TexelSize;
float _MaxCoC;

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

// vs aff50ecf260d4fba: 2 retail keyword combination(s)
void vs_aff50ecf260d4fba_impl(
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


// ps c216d0c56c1fe8c5: 1 retail keyword combination(s)
void ps_c216d0c56c1fe8c5_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + v1.xyxy;
  r1.xyz = _MainTex.Sample(sampler_MainTex, r0.zw).xyz;
  r0.xyz = _MainTex.Sample(sampler_MainTex, r0.xy).xyz;
  r0.w = max(r1.y, r1.z);
  r0.w = max(r1.x, r0.w);
  r0.w = 1 + r0.w;
  r2.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + w1.xyxy;
  r1.w = _CoCTex.Sample(sampler_CoCTex, r2.zw).x;
  r2.x = _CoCTex.Sample(sampler_CoCTex, r2.xy).x;
  r2.x = r2.x * 2 + -1;
  r1.w = r1.w * 2 + -1;
  r0.w = abs(r1.w) / r0.w;
  r1.xyz = r1.xyz * r0.www;
  r2.y = max(r0.y, r0.z);
  r2.y = max(r2.y, r0.x);
  r2.y = 1 + r2.y;
  r2.y = abs(r2.x) / r2.y;
  r0.xyz = r0.xyz * r2.yyy + r1.xyz;
  r0.w = r2.y + r0.w;
  r3.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + v1.xyxy;
  r1.xyz = _MainTex.Sample(sampler_MainTex, r3.xy).xyz;
  r2.yzw = _MainTex.Sample(sampler_MainTex, r3.zw).xyz;
  r3.x = max(r1.y, r1.z);
  r3.x = max(r3.x, r1.x);
  r3.x = 1 + r3.x;
  r4.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + w1.xyxy;
  r3.y = _CoCTex.Sample(sampler_CoCTex, r4.xy).x;
  r3.z = _CoCTex.Sample(sampler_CoCTex, r4.zw).x;
  r3.z = r3.z * 2 + -1;
  r3.y = r3.y * 2 + -1;
  r3.x = abs(r3.y) / r3.x;
  r3.y = min(r3.y, r3.z);
  r0.xyz = r1.xyz * r3.xxx + r0.xyz;
  r0.w = r3.x + r0.w;
  r1.x = max(r2.z, r2.w);
  r1.x = max(r2.y, r1.x);
  r1.x = 1 + r1.x;
  r1.x = abs(r3.z) / r1.x;
  r0.xyz = r2.yzw * r1.xxx + r0.xyz;
  r0.w = r1.x + r0.w;
  r0.w = max(9.99999975e-006, r0.w);
  r0.xyz = r0.xyz / r0.www;
  r0.w = min(r3.y, r1.w);
  r1.x = max(r3.y, r1.w);
  r1.x = max(r2.x, r1.x);
  r0.w = min(r2.x, r0.w);
  r1.y = cmp(r1.x < -r0.w);
  r0.w = r1.y ? r0.w : r1.x;
  r0.w = _MaxCoC * r0.w;
  r1.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.x = 1 / r1.x;
  r1.x = saturate(r1.x * abs(r0.w));
  o0.w = r0.w;
  r0.w = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r0.w = r1.x * r0.w;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps b7ae86eb5c15ae34: 1 retail keyword combination(s)
void ps_b7ae86eb5c15ae34_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + v1.xyxy;
  r1.xyz = _MainTex.Sample(sampler_MainTex, r0.zw).xyz;
  r0.xyz = _MainTex.Sample(sampler_MainTex, r0.xy).xyz;
  r0.w = max(r1.y, r1.z);
  r0.w = max(r1.x, r0.w);
  r0.w = 1 + r0.w;
  r2.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + w1.xyxy;
  r1.w = _CoCTex.Sample(sampler_CoCTex, r2.zw).x;
  r2.x = _CoCTex.Sample(sampler_CoCTex, r2.xy).x;
  r2.x = r2.x * 2 + -1;
  r1.w = r1.w * 2 + -1;
  r0.w = abs(r1.w) / r0.w;
  r1.xyz = r1.xyz * r0.www;
  r2.y = max(r0.y, r0.z);
  r2.y = max(r2.y, r0.x);
  r2.y = 1 + r2.y;
  r2.y = abs(r2.x) / r2.y;
  r0.xyz = r0.xyz * r2.yyy + r1.xyz;
  r0.w = r2.y + r0.w;
  r3.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + v1.xyxy;
  r1.xyz = _MainTex.Sample(sampler_MainTex, r3.xy).xyz;
  r2.yzw = _MainTex.Sample(sampler_MainTex, r3.zw).xyz;
  r3.x = max(r1.y, r1.z);
  r3.x = max(r3.x, r1.x);
  r3.x = 1 + r3.x;
  r4.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + w1.xyxy;
  r3.y = _CoCTex.Sample(sampler_CoCTex, r4.xy).x;
  r3.z = _CoCTex.Sample(sampler_CoCTex, r4.zw).x;
  r3.z = r3.z * 2 + -1;
  r3.y = r3.y * 2 + -1;
  r3.x = abs(r3.y) / r3.x;
  r3.y = min(r3.y, r3.z);
  r0.xyz = r1.xyz * r3.xxx + r0.xyz;
  r0.w = r3.x + r0.w;
  r1.x = max(r2.z, r2.w);
  r1.x = max(r2.y, r1.x);
  r1.x = 1 + r1.x;
  r1.x = abs(r3.z) / r1.x;
  r0.xyz = r2.yzw * r1.xxx + r0.xyz;
  r0.w = r1.x + r0.w;
  r0.w = max(9.99999975e-006, r0.w);
  r0.xyz = r0.xyz / r0.www;
  r0.w = min(r3.y, r1.w);
  r1.x = max(r3.y, r1.w);
  r1.x = max(r2.x, r1.x);
  r0.w = min(r2.x, r0.w);
  r1.y = cmp(r1.x < -r0.w);
  r0.w = r1.y ? r0.w : r1.x;
  r0.w = _MaxCoC * r0.w;
  r1.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.x = 1 / r1.x;
  r1.x = saturate(r1.x * abs(r0.w));
  o0.w = r0.w;
  r0.w = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r0.w = r1.x * r0.w;
  r0.xyz = r0.xyz * r0.www;
  r1.xyz = r0.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r1.xyz = r0.xyz * r1.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  o0.xyz = r1.xyz * r0.xyz;
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
		vs_aff50ecf260d4fba_impl(v.position0, v.texcoord0, o0, o1, p1);
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
		ps_c216d0c56c1fe8c5_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		ps_b7ae86eb5c15ae34_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Bokeh Filter (small)"
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
float _MaxCoC;
float _RcpAspect;

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


// ps 279b904ac00493ed: 1 retail keyword combination(s)
void ps_279b904ac00493ed_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 0, 0, 0, 0},
                              { 0.545454562, 0, 0, 0},
                              { 0.168554723, 0.518758118, 0, 0},
                              { -0.441282034, 0.320610106, 0, 0},
                              { -0.441281974, -0.320610195, 0, 0},
                              { 0.168554798, -0.518758118, 0, 0},
                              { 1.000000, 0, 0, 0},
                              { 0.809017, 0.587785244, 0, 0},
                              { 0.309016973, 0.951056540, 0, 0},
                              { -0.309017032, 0.951056480, 0, 0},
                              { -0.809017062, 0.587785184, 0, 0},
                              { -1.000000, 0, 0, 0},
                              { -0.809016943, -0.587785363, 0, 0},
                              { -0.309016645, -0.951056600, 0, 0},
                              { 0.309017122, -0.951056480, 0, 0},
                              { 0.809016943, -0.587785304, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.w = 1;
  r2.xyzw = float4(0,0,0,0);
  r3.xyzw = float4(0,0,0,0);
  r0.y = 0;
  [loop] while (true) {
    r0.z = cmp((int)r0.y >= 16);
    [branch] if (r0.z != 0) break;
    r4.yz = icb[r0.y+0].xy * _MaxCoC.xx;
    r0.z = dot(r4.yz, r4.yz);
    r0.z = sqrt(r0.z);
    r4.x = _RcpAspect * r4.y;
    r4.xy = r4.xz * float2(0.5,1) + v1.xy;
    r4.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
    r5.x = (int)r0.y;
    r5.x = cmp(r5.x >= 8);
    r5.x = r5.x ? 1 : 0.600000024;
    r6.xyzw = r5.xxxx * r4.xyzw;
    r4.x = min(r6.w, r0.w);
    r4.x = max(0, r4.x);
    r4.x = r4.x + -r0.z;
    r4.x = _MainTex_TexelSize.y * 2 + r4.x;
    r4.x = saturate(r4.x / r0.x);
    r0.z = -r4.w * r5.x + -r0.z;
    r0.z = _MainTex_TexelSize.y * 2 + r0.z;
    r0.z = saturate(r0.z / r0.x);
    r4.y = cmp(-r6.w >= _MainTex_TexelSize.y);
    r4.y = r4.y ? 1.000000 : 0;
    r0.z = r4.y * r0.z;
    r1.xyz = r6.xyz;
    r2.xyzw = r1.xyzw * r4.xxxx + r2.xyzw;
    r3.xyzw = r1.xyzw * r0.zzzz + r3.xyzw;
    r0.y = (int)r0.y + 1;
  }
  r0.x = cmp(r2.w == 0.000000);
  r0.x = r0.x ? 1.000000 : 0;
  r0.x = r2.w + r0.x;
  r0.xyz = r2.xyz / r0.xxx;
  r0.w = cmp(r3.w == 0.000000);
  r0.w = r0.w ? 1.000000 : 0;
  r0.w = r3.w + r0.w;
  r1.xyz = r3.xyz / r0.www;
  r0.w = 0.196349546 * r3.w;
  r0.w = min(1, r0.w);
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = r0.www * r1.xyz + r0.xyz;
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
		ps_279b904ac00493ed_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Bokeh Filter (medium)"
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
float _MaxCoC;
float _RcpAspect;

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


// ps 3cdb874d81815303: 1 retail keyword combination(s)
void ps_3cdb874d81815303_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 0, 0, 0, 0},
                              { 0.533333361, 0, 0, 0},
                              { 0.332527906, 0.416976810, 0, 0},
                              { -0.118677847, 0.519961596, 0, 0},
                              { -0.480516732, 0.231404707, 0, 0},
                              { -0.480516732, -0.231404677, 0, 0},
                              { -0.118677631, -0.519961655, 0, 0},
                              { 0.332527846, -0.416976899, 0, 0},
                              { 1.000000, 0, 0, 0},
                              { 0.900968850, 0.433883756, 0, 0},
                              { 0.623489797, 0.781831503, 0, 0},
                              { 0.222520977, 0.974927902, 0, 0},
                              { -0.222520947, 0.974927902, 0, 0},
                              { -0.623490, 0.781831384, 0, 0},
                              { -0.900968850, 0.433883816, 0, 0},
                              { -1.000000, 0, 0, 0},
                              { -0.900968850, -0.433883756, 0, 0},
                              { -0.623489618, -0.781831622, 0, 0},
                              { -0.222520545, -0.974928, 0, 0},
                              { 0.222521499, -0.974927783, 0, 0},
                              { 0.623489678, -0.781831622, 0, 0},
                              { 0.900968850, -0.433883756, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.w = 1;
  r2.xyzw = float4(0,0,0,0);
  r3.xyzw = float4(0,0,0,0);
  r0.y = 0;
  [loop] while (true) {
    r0.z = cmp((int)r0.y >= 22);
    [branch] if (r0.z != 0) break;
    r4.yz = icb[r0.y+0].xy * _MaxCoC.xx;
    r0.z = dot(r4.yz, r4.yz);
    r0.z = sqrt(r0.z);
    r4.x = _RcpAspect * r4.y;
    r4.xy = r4.xz * float2(0.5,1) + v1.xy;
    r4.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
    r5.x = (int)r0.y;
    r5.x = cmp(r5.x >= 8);
    r5.x = r5.x ? 1 : 0.600000024;
    r6.xyzw = r5.xxxx * r4.xyzw;
    r4.x = min(r6.w, r0.w);
    r4.x = max(0, r4.x);
    r4.x = r4.x + -r0.z;
    r4.x = _MainTex_TexelSize.y * 2 + r4.x;
    r4.x = saturate(r4.x / r0.x);
    r0.z = -r4.w * r5.x + -r0.z;
    r0.z = _MainTex_TexelSize.y * 2 + r0.z;
    r0.z = saturate(r0.z / r0.x);
    r4.y = cmp(-r6.w >= _MainTex_TexelSize.y);
    r4.y = r4.y ? 1.000000 : 0;
    r0.z = r4.y * r0.z;
    r1.xyz = r6.xyz;
    r2.xyzw = r1.xyzw * r4.xxxx + r2.xyzw;
    r3.xyzw = r1.xyzw * r0.zzzz + r3.xyzw;
    r0.y = (int)r0.y + 1;
  }
  r0.x = cmp(r2.w == 0.000000);
  r0.x = r0.x ? 1.000000 : 0;
  r0.x = r2.w + r0.x;
  r0.xyz = r2.xyz / r0.xxx;
  r0.w = cmp(r3.w == 0.000000);
  r0.w = r0.w ? 1.000000 : 0;
  r0.w = r3.w + r0.w;
  r1.xyz = r3.xyz / r0.www;
  r0.w = 0.142799661 * r3.w;
  r0.w = min(1, r0.w);
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = r0.www * r1.xyz + r0.xyz;
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
		ps_3cdb874d81815303_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Bokeh Filter (large)"
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
float _MaxCoC;
float _RcpAspect;

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


// ps 40e131b91fec1acd: 1 retail keyword combination(s)
void ps_40e131b91fec1acd_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 0, 0, 0, 0},
                              { 0.363636374, 0, 0, 0},
                              { 0.226723567, 0.284302384, 0, 0},
                              { -0.0809167102, 0.354519248, 0, 0},
                              { -0.327625036, 0.157775939, 0, 0},
                              { -0.327625036, -0.157775909, 0, 0},
                              { -0.0809165612, -0.354519278, 0, 0},
                              { 0.226723522, -0.284302413, 0, 0},
                              { 0.681818187, 0, 0, 0},
                              { 0.614297, 0.295829833, 0, 0},
                              { 0.425106674, 0.533066928, 0, 0},
                              { 0.151718855, 0.664723575, 0, 0},
                              { -0.151718825, 0.664723575, 0, 0},
                              { -0.425106794, 0.533066869, 0, 0},
                              { -0.614297, 0.295829862, 0, 0},
                              { -0.681818187, 0, 0, 0},
                              { -0.614297, -0.295829833, 0, 0},
                              { -0.425106555, -0.533067048, 0, 0},
                              { -0.151718557, -0.664723635, 0, 0},
                              { 0.151719198, -0.664723516, 0, 0},
                              { 0.425106615, -0.533067048, 0, 0},
                              { 0.614297, -0.295829833, 0, 0},
                              { 1.000000, 0, 0, 0},
                              { 0.955572784, 0.294755191, 0, 0},
                              { 0.826238751, 0.563320100, 0, 0},
                              { 0.623489797, 0.781831503, 0, 0},
                              { 0.365340978, 0.930873752, 0, 0},
                              { 0.074730, 0.997203827, 0, 0},
                              { -0.222520947, 0.974927902, 0, 0},
                              { -0.500000060, 0.866025388, 0, 0},
                              { -0.733051956, 0.680172682, 0, 0},
                              { -0.900968850, 0.433883816, 0, 0},
                              { -0.988830864, 0.149042085, 0, 0},
                              { -0.988830805, -0.149042487, 0, 0},
                              { -0.900968850, -0.433883756, 0, 0},
                              { -0.733051836, -0.680172801, 0, 0},
                              { -0.499999911, -0.866025448, 0, 0},
                              { -0.222521, -0.974927902, 0, 0},
                              { 0.0747302920, -0.997203767, 0, 0},
                              { 0.365341485, -0.930873573, 0, 0},
                              { 0.623489678, -0.781831622, 0, 0},
                              { 0.826238811, -0.563320, 0, 0},
                              { 0.955572903, -0.294754833, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.w = 1;
  r2.xyzw = float4(0,0,0,0);
  r3.xyzw = float4(0,0,0,0);
  r0.y = 0;
  [loop] while (true) {
    r0.z = cmp((int)r0.y >= 43);
    [branch] if (r0.z != 0) break;
    r4.yz = icb[r0.y+0].xy * _MaxCoC.xx;
    r0.z = dot(r4.yz, r4.yz);
    r0.z = sqrt(r0.z);
    r4.x = _RcpAspect * r4.y;
    r4.xy = r4.xz * float2(0.5,1) + v1.xy;
    r4.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
    r5.x = (int)r0.y;
    r5.x = cmp(r5.x >= 8);
    r5.x = r5.x ? 1 : 0.600000024;
    r6.xyzw = r5.xxxx * r4.xyzw;
    r4.x = min(r6.w, r0.w);
    r4.x = max(0, r4.x);
    r4.x = r4.x + -r0.z;
    r4.x = _MainTex_TexelSize.y * 2 + r4.x;
    r4.x = saturate(r4.x / r0.x);
    r0.z = -r4.w * r5.x + -r0.z;
    r0.z = _MainTex_TexelSize.y * 2 + r0.z;
    r0.z = saturate(r0.z / r0.x);
    r4.y = cmp(-r6.w >= _MainTex_TexelSize.y);
    r4.y = r4.y ? 1.000000 : 0;
    r0.z = r4.y * r0.z;
    r1.xyz = r6.xyz;
    r2.xyzw = r1.xyzw * r4.xxxx + r2.xyzw;
    r3.xyzw = r1.xyzw * r0.zzzz + r3.xyzw;
    r0.y = (int)r0.y + 1;
  }
  r0.x = cmp(r2.w == 0.000000);
  r0.x = r0.x ? 1.000000 : 0;
  r0.x = r2.w + r0.x;
  r0.xyz = r2.xyz / r0.xxx;
  r0.w = cmp(r3.w == 0.000000);
  r0.w = r0.w ? 1.000000 : 0;
  r0.w = r3.w + r0.w;
  r1.xyz = r3.xyz / r0.www;
  r0.w = 0.0730602965 * r3.w;
  r0.w = min(1, r0.w);
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = r0.www * r1.xyz + r0.xyz;
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
		ps_40e131b91fec1acd_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Bokeh Filter (very large)"
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
float _MaxCoC;
float _RcpAspect;

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


// ps 6f757848a14e2a4d: 1 retail keyword combination(s)
void ps_6f757848a14e2a4d_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 0, 0, 0, 0},
                              { 0.275862098, 0, 0, 0},
                              { 0.171997204, 0.215677679, 0, 0},
                              { -0.0613850951, 0.268945664, 0, 0},
                              { -0.248543158, 0.119692102, 0, 0},
                              { -0.248543158, -0.119692080, 0, 0},
                              { -0.0613849834, -0.268945694, 0, 0},
                              { 0.171997175, -0.215677708, 0, 0},
                              { 0.517241359, 0, 0, 0},
                              { 0.466018349, 0.224422619, 0, 0},
                              { 0.322494715, 0.404395580, 0, 0},
                              { 0.115097053, 0.504273057, 0, 0},
                              { -0.115097038, 0.504273057, 0, 0},
                              { -0.322494805, 0.404395521, 0, 0},
                              { -0.466018349, 0.224422649, 0, 0},
                              { -0.517241359, 0, 0, 0},
                              { -0.466018349, -0.224422619, 0, 0},
                              { -0.322494626, -0.404395640, 0, 0},
                              { -0.115096830, -0.504273117, 0, 0},
                              { 0.115097322, -0.504273, 0, 0},
                              { 0.322494656, -0.404395640, 0, 0},
                              { 0.466018349, -0.224422619, 0, 0},
                              { 0.758620679, 0, 0, 0},
                              { 0.724917293, 0.223607376, 0, 0},
                              { 0.626801789, 0.427346289, 0, 0},
                              { 0.472992241, 0.593113542, 0, 0},
                              { 0.277155221, 0.706180096, 0, 0},
                              { 0.0566917248, 0.756499469, 0, 0},
                              { -0.168809, 0.739600480, 0, 0},
                              { -0.379310399, 0.656984746, 0, 0},
                              { -0.556108356, 0.515993059, 0, 0},
                              { -0.683493614, 0.329153240, 0, 0},
                              { -0.750147521, 0.113066405, 0, 0},
                              { -0.750147521, -0.113066711, 0, 0},
                              { -0.683493614, -0.329153180, 0, 0},
                              { -0.556108296, -0.515993178, 0, 0},
                              { -0.379310280, -0.656984806, 0, 0},
                              { -0.168809041, -0.739600480, 0, 0},
                              { 0.0566919446, -0.756499410, 0, 0},
                              { 0.277155608, -0.706179917, 0, 0},
                              { 0.472992152, -0.593113661, 0, 0},
                              { 0.626801848, -0.427346200, 0, 0},
                              { 0.724917352, -0.223607108, 0, 0},
                              { 1.000000, 0, 0, 0},
                              { 0.974927902, 0.222520933, 0, 0},
                              { 0.900968850, 0.433883756, 0, 0},
                              { 0.781831503, 0.623489797, 0, 0},
                              { 0.623489797, 0.781831503, 0, 0},
                              { 0.433883637, 0.900968909, 0, 0},
                              { 0.222520977, 0.974927902, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { -0.222520947, 0.974927902, 0, 0},
                              { -0.433883846, 0.900968850, 0, 0},
                              { -0.623490, 0.781831384, 0, 0},
                              { -0.781831682, 0.623489559, 0, 0},
                              { -0.900968850, 0.433883816, 0, 0},
                              { -0.974927902, 0.222520933, 0, 0},
                              { -1.000000, 0, 0, 0},
                              { -0.974927902, -0.222520873, 0, 0},
                              { -0.900968850, -0.433883756, 0, 0},
                              { -0.781831384, -0.623489916, 0, 0},
                              { -0.623489618, -0.781831622, 0, 0},
                              { -0.433883458, -0.900969, 0, 0},
                              { -0.222520545, -0.974928, 0, 0},
                              { 0, -1.000000, 0, 0},
                              { 0.222521499, -0.974927783, 0, 0},
                              { 0.433883488, -0.900968969, 0, 0},
                              { 0.623489678, -0.781831622, 0, 0},
                              { 0.781831443, -0.623489857, 0, 0},
                              { 0.900968850, -0.433883756, 0, 0},
                              { 0.974927902, -0.222520858, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.w = 1;
  r2.xyzw = float4(0,0,0,0);
  r3.xyzw = float4(0,0,0,0);
  r0.y = 0;
  [loop] while (true) {
    r0.z = cmp((int)r0.y >= 71);
    [branch] if (r0.z != 0) break;
    r4.yz = icb[r0.y+0].xy * _MaxCoC.xx;
    r0.z = dot(r4.yz, r4.yz);
    r0.z = sqrt(r0.z);
    r4.x = _RcpAspect * r4.y;
    r4.xy = r4.xz * float2(0.5,1) + v1.xy;
    r4.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
    r5.x = (int)r0.y;
    r5.x = cmp(r5.x >= 8);
    r5.x = r5.x ? 1 : 0.600000024;
    r6.xyzw = r5.xxxx * r4.xyzw;
    r4.x = min(r6.w, r0.w);
    r4.x = max(0, r4.x);
    r4.x = r4.x + -r0.z;
    r4.x = _MainTex_TexelSize.y * 2 + r4.x;
    r4.x = saturate(r4.x / r0.x);
    r0.z = -r4.w * r5.x + -r0.z;
    r0.z = _MainTex_TexelSize.y * 2 + r0.z;
    r0.z = saturate(r0.z / r0.x);
    r4.y = cmp(-r6.w >= _MainTex_TexelSize.y);
    r4.y = r4.y ? 1.000000 : 0;
    r0.z = r4.y * r0.z;
    r1.xyz = r6.xyz;
    r2.xyzw = r1.xyzw * r4.xxxx + r2.xyzw;
    r3.xyzw = r1.xyzw * r0.zzzz + r3.xyzw;
    r0.y = (int)r0.y + 1;
  }
  r0.x = cmp(r2.w == 0.000000);
  r0.x = r0.x ? 1.000000 : 0;
  r0.x = r2.w + r0.x;
  r0.xyz = r2.xyz / r0.xxx;
  r0.w = cmp(r3.w == 0.000000);
  r0.w = r0.w ? 1.000000 : 0;
  r0.w = r3.w + r0.w;
  r1.xyz = r3.xyz / r0.www;
  r0.w = 0.0442477837 * r3.w;
  r0.w = min(1, r0.w);
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = r0.www * r1.xyz + r0.xyz;
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
		ps_6f757848a14e2a4d_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Postfilter"
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


// ps bec4217ad6bf9865: 1 retail keyword combination(s)
void ps_bec4217ad6bf9865_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyzw = r1.xyzw + r0.xyzw;
  r1.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + v1.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r0.xyzw = r2.xyzw + r0.xyzw;
  r0.xyzw = r0.xyzw + r1.xyzw;
  o0.xyzw = float4(0.25,0.25,0.25,0.25) * r0.xyzw;
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
		ps_bec4217ad6bf9865_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
	SubShader
	{
		Pass
		{
			Name "CoC Calculation"
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

float4 _MainTex_TexelSize;
float _Distance;
float _LensCoeff;
float _RcpMaxCoC;

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


// ps 3c037b2fba667122: 1 retail keyword combination(s)
void ps_3c037b2fba667122_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.y = -_Distance + r0.x;
  r0.x = max(9.99999975e-006, r0.x);
  r0.y = _LensCoeff * r0.y;
  r0.x = r0.y / r0.x;
  r0.x = 0.5 * r0.x;
  r0.x = r0.x * _RcpMaxCoC + 0.5;
  o0.xyzw = saturate(r0.xxxx);
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
		ps_3c037b2fba667122_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "CoC Temporal Filter"
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

#define cmp -

Texture2D _CoCTex;
SamplerState sampler_CoCTex;
Texture2D _CameraMotionVectorsTexture;
SamplerState sampler_CameraMotionVectorsTexture;
Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_TexelSize;
float3 _TaaParams;

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


// ps 7727a753767f1d9e: 1 retail keyword combination(s)
void ps_7727a753767f1d9e_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0,-1) * _MainTex_TexelSize.yy;
  r1.xy = -_TaaParams.xy + v1.xy;
  r1.xyzw = _CoCTex.Sample(sampler_CoCTex, r1.xy).xyzw;
  r2.xyzw = -_MainTex_TexelSize.xyyy * float4(1,0,0,1) + v1.xyxy;
  r3.xyzw = _CoCTex.Sample(sampler_CoCTex, r2.xy).xyzw;
  r2.xyzw = _CoCTex.Sample(sampler_CoCTex, r2.zw).xyzw;
  r0.w = cmp(r3.x < r1.x);
  r4.z = r0.w ? r3.x : r1.x;
  r1.y = max(r3.x, r1.x);
  r1.y = max(r1.y, r2.x);
  r1.z = cmp(r2.x < r4.z);
  r0.z = r2.x;
  r2.xy = float2(1,0) * _MainTex_TexelSize.xy;
  r2.zw = -r2.xy;
  r4.xy = r0.ww ? r2.zw : 0;
  r0.xyz = r1.zzz ? r0.xyz : r4.xyz;
  r3.xy = float2(0,1) * _MainTex_TexelSize.yy;
  r4.xyzw = _MainTex_TexelSize.yyxy * float4(0,1,1,0) + v1.xyxy;
  r5.xyzw = _CoCTex.Sample(sampler_CoCTex, r4.xy).xyzw;
  r4.xyzw = _CoCTex.Sample(sampler_CoCTex, r4.zw).xyzw;
  r0.w = cmp(r5.x < r0.z);
  r3.z = r5.x;
  r1.y = max(r5.x, r1.y);
  r1.y = max(r1.y, r4.x);
  r0.xyz = r0.www ? r3.xyz : r0.xyz;
  r0.w = cmp(r4.x < r0.z);
  r0.z = min(r0.z, r4.x);
  r0.xy = r0.ww ? r2.xy : r0.xy;
  r0.xy = v1.xy + r0.xy;
  r2.xyzw = _CameraMotionVectorsTexture.Sample(sampler_CameraMotionVectorsTexture, r0.xy).xyzw;
  r0.xy = v1.xy + -r2.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.x = max(r2.x, r0.z);
  r0.x = min(r0.x, r1.y);
  r0.x = r0.x + -r1.x;
  o0.xyzw = _TaaParams.zzzz * r0.xxxx + r1.xxxx;
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
		ps_7727a753767f1d9e_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Downsample and Prefilter"
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
Texture2D _CoCTex;
SamplerState sampler_CoCTex;

float4 _MainTex_TexelSize;
float _MaxCoC;

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


// ps 105895ed080b6d7f: 1 retail keyword combination(s)
void ps_105895ed080b6d7f_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.w = max(r1.y, r1.z);
  r0.w = max(r1.x, r0.w);
  r0.w = 1 + r0.w;
  r2.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + w1.xyxy;
  r3.xyzw = _CoCTex.Sample(sampler_CoCTex, r2.zw).xyzw;
  r2.xyzw = _CoCTex.Sample(sampler_CoCTex, r2.xy).xyzw;
  r1.w = r2.x * 2 + -1;
  r2.x = r3.x * 2 + -1;
  r0.w = abs(r2.x) / r0.w;
  r1.xyz = r1.xyz * r0.www;
  r2.y = max(r0.y, r0.z);
  r2.y = max(r2.y, r0.x);
  r2.y = 1 + r2.y;
  r2.y = abs(r1.w) / r2.y;
  r0.xyz = r0.xyz * r2.yyy + r1.xyz;
  r0.w = r2.y + r0.w;
  r3.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + v1.xyxy;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, r3.xy).xyzw;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r3.zw).xyzw;
  r1.x = max(r4.y, r4.z);
  r1.x = max(r4.x, r1.x);
  r1.x = 1 + r1.x;
  r5.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + w1.xyxy;
  r6.xyzw = _CoCTex.Sample(sampler_CoCTex, r5.xy).xyzw;
  r5.xyzw = _CoCTex.Sample(sampler_CoCTex, r5.zw).xyzw;
  r1.y = r5.x * 2 + -1;
  r1.z = r6.x * 2 + -1;
  r1.x = abs(r1.z) / r1.x;
  r1.z = min(r1.z, r1.y);
  r0.xyz = r4.xyz * r1.xxx + r0.xyz;
  r0.w = r1.x + r0.w;
  r1.x = max(r3.y, r3.z);
  r1.x = max(r3.x, r1.x);
  r1.x = 1 + r1.x;
  r1.x = abs(r1.y) / r1.x;
  r0.xyz = r3.xyz * r1.xxx + r0.xyz;
  r0.w = r1.x + r0.w;
  r0.w = max(9.99999975e-006, r0.w);
  r0.xyz = r0.xyz / r0.www;
  r0.w = min(r2.x, r1.z);
  r1.x = max(r2.x, r1.z);
  r1.x = max(r1.w, r1.x);
  r0.w = min(r1.w, r0.w);
  r1.y = cmp(r1.x < -r0.w);
  r0.w = r1.y ? r0.w : r1.x;
  r0.w = _MaxCoC * r0.w;
  r1.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.x = 1 / r1.x;
  r1.x = saturate(r1.x * abs(r0.w));
  o0.w = r0.w;
  r0.w = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r0.w = r1.x * r0.w;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps e2698475586fe33a: 1 retail keyword combination(s)
void ps_e2698475586fe33a_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.w = max(r1.y, r1.z);
  r0.w = max(r1.x, r0.w);
  r0.w = 1 + r0.w;
  r2.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + w1.xyxy;
  r3.xyzw = _CoCTex.Sample(sampler_CoCTex, r2.zw).xyzw;
  r2.xyzw = _CoCTex.Sample(sampler_CoCTex, r2.xy).xyzw;
  r1.w = r2.x * 2 + -1;
  r2.x = r3.x * 2 + -1;
  r0.w = abs(r2.x) / r0.w;
  r1.xyz = r1.xyz * r0.www;
  r2.y = max(r0.y, r0.z);
  r2.y = max(r2.y, r0.x);
  r2.y = 1 + r2.y;
  r2.y = abs(r1.w) / r2.y;
  r0.xyz = r0.xyz * r2.yyy + r1.xyz;
  r0.w = r2.y + r0.w;
  r3.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + v1.xyxy;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, r3.xy).xyzw;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r3.zw).xyzw;
  r1.x = max(r4.y, r4.z);
  r1.x = max(r4.x, r1.x);
  r1.x = 1 + r1.x;
  r5.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + w1.xyxy;
  r6.xyzw = _CoCTex.Sample(sampler_CoCTex, r5.xy).xyzw;
  r5.xyzw = _CoCTex.Sample(sampler_CoCTex, r5.zw).xyzw;
  r1.y = r5.x * 2 + -1;
  r1.z = r6.x * 2 + -1;
  r1.x = abs(r1.z) / r1.x;
  r1.z = min(r1.z, r1.y);
  r0.xyz = r4.xyz * r1.xxx + r0.xyz;
  r0.w = r1.x + r0.w;
  r1.x = max(r3.y, r3.z);
  r1.x = max(r3.x, r1.x);
  r1.x = 1 + r1.x;
  r1.x = abs(r1.y) / r1.x;
  r0.xyz = r3.xyz * r1.xxx + r0.xyz;
  r0.w = r1.x + r0.w;
  r0.w = max(9.99999975e-006, r0.w);
  r0.xyz = r0.xyz / r0.www;
  r0.w = min(r2.x, r1.z);
  r1.x = max(r2.x, r1.z);
  r1.x = max(r1.w, r1.x);
  r0.w = min(r1.w, r0.w);
  r1.y = cmp(r1.x < -r0.w);
  r0.w = r1.y ? r0.w : r1.x;
  r0.w = _MaxCoC * r0.w;
  r1.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.x = 1 / r1.x;
  r1.x = saturate(r1.x * abs(r0.w));
  o0.w = r0.w;
  r0.w = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r0.w = r1.x * r0.w;
  r0.xyz = r0.xyz * r0.www;
  r1.xyz = r0.xyz * float3(0.305306017,0.305306017,0.305306017) + float3(0.682171106,0.682171106,0.682171106);
  r1.xyz = r0.xyz * r1.xyz + float3(0.0125228781,0.0125228781,0.0125228781);
  o0.xyz = r1.xyz * r0.xyz;
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
		ps_105895ed080b6d7f_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(UNITY_COLORSPACE_GAMMA)
	{
		float4 o0 = 0;
		ps_e2698475586fe33a_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Bokeh Filter (small)"
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
float _MaxCoC;
float _RcpAspect;

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


// ps 279b904ac00493ed: 1 retail keyword combination(s)
void ps_279b904ac00493ed_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 0, 0, 0, 0},
                              { 0.545454562, 0, 0, 0},
                              { 0.168554723, 0.518758118, 0, 0},
                              { -0.441282034, 0.320610106, 0, 0},
                              { -0.441281974, -0.320610195, 0, 0},
                              { 0.168554798, -0.518758118, 0, 0},
                              { 1.000000, 0, 0, 0},
                              { 0.809017, 0.587785244, 0, 0},
                              { 0.309016973, 0.951056540, 0, 0},
                              { -0.309017032, 0.951056480, 0, 0},
                              { -0.809017062, 0.587785184, 0, 0},
                              { -1.000000, 0, 0, 0},
                              { -0.809016943, -0.587785363, 0, 0},
                              { -0.309016645, -0.951056600, 0, 0},
                              { 0.309017122, -0.951056480, 0, 0},
                              { 0.809016943, -0.587785304, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.w = 1;
  r2.xyzw = float4(0,0,0,0);
  r3.xyzw = float4(0,0,0,0);
  r0.y = 0;
  [loop] while (true) {
    r0.z = cmp((int)r0.y >= 16);
    [branch] if (r0.z != 0) break;
    r4.yz = icb[r0.y+0].xy * _MaxCoC.xx;
    r0.z = dot(r4.yz, r4.yz);
    r0.z = sqrt(r0.z);
    r4.x = _RcpAspect * r4.y;
    r4.xy = r4.xz * float2(0.5,1) + v1.xy;
    r4.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
    r5.x = (int)r0.y;
    r5.x = cmp(r5.x >= 8);
    r5.x = r5.x ? 1 : 0.600000024;
    r6.xyzw = r5.xxxx * r4.xyzw;
    r4.x = min(r6.w, r0.w);
    r4.x = max(0, r4.x);
    r4.x = r4.x + -r0.z;
    r4.x = _MainTex_TexelSize.y * 2 + r4.x;
    r4.x = saturate(r4.x / r0.x);
    r0.z = -r4.w * r5.x + -r0.z;
    r0.z = _MainTex_TexelSize.y * 2 + r0.z;
    r0.z = saturate(r0.z / r0.x);
    r4.y = cmp(-r6.w >= _MainTex_TexelSize.y);
    r4.y = r4.y ? 1.000000 : 0;
    r0.z = r4.y * r0.z;
    r1.xyz = r6.xyz;
    r2.xyzw = r1.xyzw * r4.xxxx + r2.xyzw;
    r3.xyzw = r1.xyzw * r0.zzzz + r3.xyzw;
    r0.y = (int)r0.y + 1;
  }
  r0.x = cmp(r2.w == 0.000000);
  r0.x = r0.x ? 1.000000 : 0;
  r0.x = r2.w + r0.x;
  r0.xyz = r2.xyz / r0.xxx;
  r0.w = cmp(r3.w == 0.000000);
  r0.w = r0.w ? 1.000000 : 0;
  r0.w = r3.w + r0.w;
  r1.xyz = r3.xyz / r0.www;
  r0.w = 0.196349546 * r3.w;
  r0.w = min(1, r0.w);
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = r0.www * r1.xyz + r0.xyz;
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
		ps_279b904ac00493ed_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Bokeh Filter (medium)"
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
float _MaxCoC;
float _RcpAspect;

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


// ps 3cdb874d81815303: 1 retail keyword combination(s)
void ps_3cdb874d81815303_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 0, 0, 0, 0},
                              { 0.533333361, 0, 0, 0},
                              { 0.332527906, 0.416976810, 0, 0},
                              { -0.118677847, 0.519961596, 0, 0},
                              { -0.480516732, 0.231404707, 0, 0},
                              { -0.480516732, -0.231404677, 0, 0},
                              { -0.118677631, -0.519961655, 0, 0},
                              { 0.332527846, -0.416976899, 0, 0},
                              { 1.000000, 0, 0, 0},
                              { 0.900968850, 0.433883756, 0, 0},
                              { 0.623489797, 0.781831503, 0, 0},
                              { 0.222520977, 0.974927902, 0, 0},
                              { -0.222520947, 0.974927902, 0, 0},
                              { -0.623490, 0.781831384, 0, 0},
                              { -0.900968850, 0.433883816, 0, 0},
                              { -1.000000, 0, 0, 0},
                              { -0.900968850, -0.433883756, 0, 0},
                              { -0.623489618, -0.781831622, 0, 0},
                              { -0.222520545, -0.974928, 0, 0},
                              { 0.222521499, -0.974927783, 0, 0},
                              { 0.623489678, -0.781831622, 0, 0},
                              { 0.900968850, -0.433883756, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.w = 1;
  r2.xyzw = float4(0,0,0,0);
  r3.xyzw = float4(0,0,0,0);
  r0.y = 0;
  [loop] while (true) {
    r0.z = cmp((int)r0.y >= 22);
    [branch] if (r0.z != 0) break;
    r4.yz = icb[r0.y+0].xy * _MaxCoC.xx;
    r0.z = dot(r4.yz, r4.yz);
    r0.z = sqrt(r0.z);
    r4.x = _RcpAspect * r4.y;
    r4.xy = r4.xz * float2(0.5,1) + v1.xy;
    r4.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
    r5.x = (int)r0.y;
    r5.x = cmp(r5.x >= 8);
    r5.x = r5.x ? 1 : 0.600000024;
    r6.xyzw = r5.xxxx * r4.xyzw;
    r4.x = min(r6.w, r0.w);
    r4.x = max(0, r4.x);
    r4.x = r4.x + -r0.z;
    r4.x = _MainTex_TexelSize.y * 2 + r4.x;
    r4.x = saturate(r4.x / r0.x);
    r0.z = -r4.w * r5.x + -r0.z;
    r0.z = _MainTex_TexelSize.y * 2 + r0.z;
    r0.z = saturate(r0.z / r0.x);
    r4.y = cmp(-r6.w >= _MainTex_TexelSize.y);
    r4.y = r4.y ? 1.000000 : 0;
    r0.z = r4.y * r0.z;
    r1.xyz = r6.xyz;
    r2.xyzw = r1.xyzw * r4.xxxx + r2.xyzw;
    r3.xyzw = r1.xyzw * r0.zzzz + r3.xyzw;
    r0.y = (int)r0.y + 1;
  }
  r0.x = cmp(r2.w == 0.000000);
  r0.x = r0.x ? 1.000000 : 0;
  r0.x = r2.w + r0.x;
  r0.xyz = r2.xyz / r0.xxx;
  r0.w = cmp(r3.w == 0.000000);
  r0.w = r0.w ? 1.000000 : 0;
  r0.w = r3.w + r0.w;
  r1.xyz = r3.xyz / r0.www;
  r0.w = 0.142799661 * r3.w;
  r0.w = min(1, r0.w);
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = r0.www * r1.xyz + r0.xyz;
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
		ps_3cdb874d81815303_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Bokeh Filter (large)"
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
float _MaxCoC;
float _RcpAspect;

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


// ps 40e131b91fec1acd: 1 retail keyword combination(s)
void ps_40e131b91fec1acd_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 0, 0, 0, 0},
                              { 0.363636374, 0, 0, 0},
                              { 0.226723567, 0.284302384, 0, 0},
                              { -0.0809167102, 0.354519248, 0, 0},
                              { -0.327625036, 0.157775939, 0, 0},
                              { -0.327625036, -0.157775909, 0, 0},
                              { -0.0809165612, -0.354519278, 0, 0},
                              { 0.226723522, -0.284302413, 0, 0},
                              { 0.681818187, 0, 0, 0},
                              { 0.614297, 0.295829833, 0, 0},
                              { 0.425106674, 0.533066928, 0, 0},
                              { 0.151718855, 0.664723575, 0, 0},
                              { -0.151718825, 0.664723575, 0, 0},
                              { -0.425106794, 0.533066869, 0, 0},
                              { -0.614297, 0.295829862, 0, 0},
                              { -0.681818187, 0, 0, 0},
                              { -0.614297, -0.295829833, 0, 0},
                              { -0.425106555, -0.533067048, 0, 0},
                              { -0.151718557, -0.664723635, 0, 0},
                              { 0.151719198, -0.664723516, 0, 0},
                              { 0.425106615, -0.533067048, 0, 0},
                              { 0.614297, -0.295829833, 0, 0},
                              { 1.000000, 0, 0, 0},
                              { 0.955572784, 0.294755191, 0, 0},
                              { 0.826238751, 0.563320100, 0, 0},
                              { 0.623489797, 0.781831503, 0, 0},
                              { 0.365340978, 0.930873752, 0, 0},
                              { 0.074730, 0.997203827, 0, 0},
                              { -0.222520947, 0.974927902, 0, 0},
                              { -0.500000060, 0.866025388, 0, 0},
                              { -0.733051956, 0.680172682, 0, 0},
                              { -0.900968850, 0.433883816, 0, 0},
                              { -0.988830864, 0.149042085, 0, 0},
                              { -0.988830805, -0.149042487, 0, 0},
                              { -0.900968850, -0.433883756, 0, 0},
                              { -0.733051836, -0.680172801, 0, 0},
                              { -0.499999911, -0.866025448, 0, 0},
                              { -0.222521, -0.974927902, 0, 0},
                              { 0.0747302920, -0.997203767, 0, 0},
                              { 0.365341485, -0.930873573, 0, 0},
                              { 0.623489678, -0.781831622, 0, 0},
                              { 0.826238811, -0.563320, 0, 0},
                              { 0.955572903, -0.294754833, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.w = 1;
  r2.xyzw = float4(0,0,0,0);
  r3.xyzw = float4(0,0,0,0);
  r0.y = 0;
  [loop] while (true) {
    r0.z = cmp((int)r0.y >= 43);
    [branch] if (r0.z != 0) break;
    r4.yz = icb[r0.y+0].xy * _MaxCoC.xx;
    r0.z = dot(r4.yz, r4.yz);
    r0.z = sqrt(r0.z);
    r4.x = _RcpAspect * r4.y;
    r4.xy = r4.xz * float2(0.5,1) + v1.xy;
    r4.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
    r5.x = (int)r0.y;
    r5.x = cmp(r5.x >= 8);
    r5.x = r5.x ? 1 : 0.600000024;
    r6.xyzw = r5.xxxx * r4.xyzw;
    r4.x = min(r6.w, r0.w);
    r4.x = max(0, r4.x);
    r4.x = r4.x + -r0.z;
    r4.x = _MainTex_TexelSize.y * 2 + r4.x;
    r4.x = saturate(r4.x / r0.x);
    r0.z = -r4.w * r5.x + -r0.z;
    r0.z = _MainTex_TexelSize.y * 2 + r0.z;
    r0.z = saturate(r0.z / r0.x);
    r4.y = cmp(-r6.w >= _MainTex_TexelSize.y);
    r4.y = r4.y ? 1.000000 : 0;
    r0.z = r4.y * r0.z;
    r1.xyz = r6.xyz;
    r2.xyzw = r1.xyzw * r4.xxxx + r2.xyzw;
    r3.xyzw = r1.xyzw * r0.zzzz + r3.xyzw;
    r0.y = (int)r0.y + 1;
  }
  r0.x = cmp(r2.w == 0.000000);
  r0.x = r0.x ? 1.000000 : 0;
  r0.x = r2.w + r0.x;
  r0.xyz = r2.xyz / r0.xxx;
  r0.w = cmp(r3.w == 0.000000);
  r0.w = r0.w ? 1.000000 : 0;
  r0.w = r3.w + r0.w;
  r1.xyz = r3.xyz / r0.www;
  r0.w = 0.0730602965 * r3.w;
  r0.w = min(1, r0.w);
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = r0.www * r1.xyz + r0.xyz;
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
		ps_40e131b91fec1acd_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Bokeh Filter (very large)"
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
float _MaxCoC;
float _RcpAspect;

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


// ps 6f757848a14e2a4d: 1 retail keyword combination(s)
void ps_6f757848a14e2a4d_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 0, 0, 0, 0},
                              { 0.275862098, 0, 0, 0},
                              { 0.171997204, 0.215677679, 0, 0},
                              { -0.0613850951, 0.268945664, 0, 0},
                              { -0.248543158, 0.119692102, 0, 0},
                              { -0.248543158, -0.119692080, 0, 0},
                              { -0.0613849834, -0.268945694, 0, 0},
                              { 0.171997175, -0.215677708, 0, 0},
                              { 0.517241359, 0, 0, 0},
                              { 0.466018349, 0.224422619, 0, 0},
                              { 0.322494715, 0.404395580, 0, 0},
                              { 0.115097053, 0.504273057, 0, 0},
                              { -0.115097038, 0.504273057, 0, 0},
                              { -0.322494805, 0.404395521, 0, 0},
                              { -0.466018349, 0.224422649, 0, 0},
                              { -0.517241359, 0, 0, 0},
                              { -0.466018349, -0.224422619, 0, 0},
                              { -0.322494626, -0.404395640, 0, 0},
                              { -0.115096830, -0.504273117, 0, 0},
                              { 0.115097322, -0.504273, 0, 0},
                              { 0.322494656, -0.404395640, 0, 0},
                              { 0.466018349, -0.224422619, 0, 0},
                              { 0.758620679, 0, 0, 0},
                              { 0.724917293, 0.223607376, 0, 0},
                              { 0.626801789, 0.427346289, 0, 0},
                              { 0.472992241, 0.593113542, 0, 0},
                              { 0.277155221, 0.706180096, 0, 0},
                              { 0.0566917248, 0.756499469, 0, 0},
                              { -0.168809, 0.739600480, 0, 0},
                              { -0.379310399, 0.656984746, 0, 0},
                              { -0.556108356, 0.515993059, 0, 0},
                              { -0.683493614, 0.329153240, 0, 0},
                              { -0.750147521, 0.113066405, 0, 0},
                              { -0.750147521, -0.113066711, 0, 0},
                              { -0.683493614, -0.329153180, 0, 0},
                              { -0.556108296, -0.515993178, 0, 0},
                              { -0.379310280, -0.656984806, 0, 0},
                              { -0.168809041, -0.739600480, 0, 0},
                              { 0.0566919446, -0.756499410, 0, 0},
                              { 0.277155608, -0.706179917, 0, 0},
                              { 0.472992152, -0.593113661, 0, 0},
                              { 0.626801848, -0.427346200, 0, 0},
                              { 0.724917352, -0.223607108, 0, 0},
                              { 1.000000, 0, 0, 0},
                              { 0.974927902, 0.222520933, 0, 0},
                              { 0.900968850, 0.433883756, 0, 0},
                              { 0.781831503, 0.623489797, 0, 0},
                              { 0.623489797, 0.781831503, 0, 0},
                              { 0.433883637, 0.900968909, 0, 0},
                              { 0.222520977, 0.974927902, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { -0.222520947, 0.974927902, 0, 0},
                              { -0.433883846, 0.900968850, 0, 0},
                              { -0.623490, 0.781831384, 0, 0},
                              { -0.781831682, 0.623489559, 0, 0},
                              { -0.900968850, 0.433883816, 0, 0},
                              { -0.974927902, 0.222520933, 0, 0},
                              { -1.000000, 0, 0, 0},
                              { -0.974927902, -0.222520873, 0, 0},
                              { -0.900968850, -0.433883756, 0, 0},
                              { -0.781831384, -0.623489916, 0, 0},
                              { -0.623489618, -0.781831622, 0, 0},
                              { -0.433883458, -0.900969, 0, 0},
                              { -0.222520545, -0.974928, 0, 0},
                              { 0, -1.000000, 0, 0},
                              { 0.222521499, -0.974927783, 0, 0},
                              { 0.433883488, -0.900968969, 0, 0},
                              { 0.623489678, -0.781831622, 0, 0},
                              { 0.781831443, -0.623489857, 0, 0},
                              { 0.900968850, -0.433883756, 0, 0},
                              { 0.974927902, -0.222520858, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r0.x = _MainTex_TexelSize.y + _MainTex_TexelSize.y;
  r1.w = 1;
  r2.xyzw = float4(0,0,0,0);
  r3.xyzw = float4(0,0,0,0);
  r0.y = 0;
  [loop] while (true) {
    r0.z = cmp((int)r0.y >= 71);
    [branch] if (r0.z != 0) break;
    r4.yz = icb[r0.y+0].xy * _MaxCoC.xx;
    r0.z = dot(r4.yz, r4.yz);
    r0.z = sqrt(r0.z);
    r4.x = _RcpAspect * r4.y;
    r4.xy = r4.xz * float2(0.5,1) + v1.xy;
    r4.xyzw = _MainTex.Sample(sampler_MainTex, r4.xy).xyzw;
    r5.x = (int)r0.y;
    r5.x = cmp(r5.x >= 8);
    r5.x = r5.x ? 1 : 0.600000024;
    r6.xyzw = r5.xxxx * r4.xyzw;
    r4.x = min(r6.w, r0.w);
    r4.x = max(0, r4.x);
    r4.x = r4.x + -r0.z;
    r4.x = _MainTex_TexelSize.y * 2 + r4.x;
    r4.x = saturate(r4.x / r0.x);
    r0.z = -r4.w * r5.x + -r0.z;
    r0.z = _MainTex_TexelSize.y * 2 + r0.z;
    r0.z = saturate(r0.z / r0.x);
    r4.y = cmp(-r6.w >= _MainTex_TexelSize.y);
    r4.y = r4.y ? 1.000000 : 0;
    r0.z = r4.y * r0.z;
    r1.xyz = r6.xyz;
    r2.xyzw = r1.xyzw * r4.xxxx + r2.xyzw;
    r3.xyzw = r1.xyzw * r0.zzzz + r3.xyzw;
    r0.y = (int)r0.y + 1;
  }
  r0.x = cmp(r2.w == 0.000000);
  r0.x = r0.x ? 1.000000 : 0;
  r0.x = r2.w + r0.x;
  r0.xyz = r2.xyz / r0.xxx;
  r0.w = cmp(r3.w == 0.000000);
  r0.w = r0.w ? 1.000000 : 0;
  r0.w = r3.w + r0.w;
  r1.xyz = r3.xyz / r0.www;
  r0.w = 0.0442477837 * r3.w;
  r0.w = min(1, r0.w);
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = r0.www * r1.xyz + r0.xyz;
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
		ps_6f757848a14e2a4d_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			Name "Postfilter"
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


// ps bec4217ad6bf9865: 1 retail keyword combination(s)
void ps_bec4217ad6bf9865_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = -_MainTex_TexelSize.xyxy * float4(0.5,0.5,-0.5,0.5) + v1.xyxy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.xyzw = r1.xyzw + r0.xyzw;
  r1.xyzw = _MainTex_TexelSize.xyxy * float4(-0.5,0.5,0.5,0.5) + v1.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r0.xyzw = r2.xyzw + r0.xyzw;
  r0.xyzw = r0.xyzw + r1.xyzw;
  o0.xyzw = float4(0.25,0.25,0.25,0.25) * r0.xyzw;
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
		ps_bec4217ad6bf9865_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
