Shader "Hidden/Post FX/Ambient Occlusion"
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

Texture2D _CameraDepthNormalsTexture;
SamplerState sampler_CameraDepthNormalsTexture;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;

float4 _MainTex_TexelSize;
float4 _CameraDepthTexture_ST;
int _SampleCount;
float _Intensity;
float _Radius;
float _Downsample;

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

// vs 8dfe92c42a2981fd: 1 retail keyword combination(s)
void vs_8dfe92c42a2981fd_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float2 o2 : TEXCOORD2)
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
  r0.w = r0.x ? r0.y : v1.y;
  r0.xyz = v1.xyx;
  float4 _pk0 = 0;
  _pk0.xyzw = r0.xyzw;
  o1.xy = _pk0.xy;
  p1.xy = _pk0.zw;
  o2.xy = r0.zw;
  return;
}


// ps e061be0419f7b3ca: 1 retail keyword combination(s)
void ps_e061be0419f7b3ca_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
  r1.xyzw = _CameraDepthNormalsTexture.Sample(sampler_CameraDepthNormalsTexture, r0.xy).xyzw;
  r1.xyz = r1.xyz * float3(3.55539989,3.55539989,0) + float3(-1.77769995,-1.77769995,1);
  r0.z = dot(r1.xyz, r1.xyz);
  r0.z = 2 / r0.z;
  r1.yz = r0.zz * r1.xy;
  r1.w = -1 + r0.z;
  r2.xyz = float3(1,1,-1) * r1.yzw;
  r3.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.z = 1 + -unity_OrthoParams.w;
  r0.w = _ZBufferParams.x * r3.x;
  r1.x = -unity_OrthoParams.w * r0.w + 1;
  r0.w = r0.z * r0.w + _ZBufferParams.y;
  r0.w = r1.x / r0.w;
  r3.xy = cmp(r0.xy < float2(0,0));
  r1.x = (int)r3.y | (int)r3.x;
  r1.x = (int)r1.x & 1;
  r0.xy = cmp(float2(1,1) < r0.xy);
  r0.x = (int)r0.y | (int)r0.x;
  r0.x = r0.x ? 1 : 0;
  r0.x = (int)r0.x + (int)r1.x;
  r0.x = (int)r0.x;
  r0.y = cmp(9.99999975e-006 >= r0.w);
  r0.y = r0.y ? 1.000000 : 0;
  r0.x = r0.x + r0.y;
  r0.x = 100000000 * r0.x;
  r3.z = r0.w * _ProjectionParams.z + r0.x;
  r0.xy = w1.xy * float2(2,2) + float2(-1,-1);
  r0.xy = -float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) + r0.xy;
  r4.x = unity_CameraProjection[0][0];
  r4.y = unity_CameraProjection[1][1];
  r0.xy = r0.xy / r4.xy;
  r0.w = 1 + -r3.z;
  r0.w = unity_OrthoParams.w * r0.w + r3.z;
  r3.xy = r0.xy * r0.ww;
  r0.xy = _Downsample.xx * v1.xy;
  r0.xy = _ScreenParams.xy * r0.xy;
  r0.xy = floor(r0.xy);
  r0.x = dot(float2(0.0671105608,0.00583714992), r0.xy);
  r0.x = frac(r0.x);
  r0.x = 52.9829178 * r0.x;
  r0.x = frac(r0.x);
  r0.y = asint(_SampleCount);
  r5.x = 12.9898005;
  r0.w = 0;
  r1.x = 0;
  [loop] while (true) {
    r2.w = cmp((int)r1.x >= asint(_SampleCount));
    [branch] if (r2.w != 0) break;
    r2.w = (int)r1.x;
    r2.w = 1.00010002 * r2.w;
    r5.y = floor(r2.w);
    r2.w = 78.2330017 * r5.y;
    r2.w = sin(r2.w);
    r2.w = 43758.5469 * r2.w;
    r2.w = frac(r2.w);
    r2.w = r2.w + r0.x;
    r2.w = frac(r2.w);
    r6.z = r2.w * 2 + -1;
    r2.w = dot(r5.xy, float2(1,78.2330017));
    r2.w = sin(r2.w);
    r2.w = 43758.5469 * r2.w;
    r2.w = frac(r2.w);
    r2.w = r2.w + r0.x;
    r2.w = 6.28318548 * r2.w;
    sincos(r2.w, r7.x, r8.x);
    r2.w = -r6.z * r6.z + 1;
    r2.w = sqrt(r2.w);
    r8.y = r7.x;
    r6.xy = r8.xy * r2.ww;
    r2.w = 1 + r5.y;
    r2.w = r2.w / r0.y;
    r2.w = sqrt(r2.w);
    r2.w = _Radius * r2.w;
    r5.yzw = r6.xyz * r2.www;
    r2.w = dot(-r2.xyz, r5.yzw);
    r2.w = cmp(r2.w >= 0);
    r5.yzw = r2.www ? -r5.yzw : r5.yzw;
    r5.yzw = r5.yzw + r3.xyz;
    r4.zw = float2(unity_CameraProjection[0][1], unity_CameraProjection[1][1]) * r5.zz;
    r4.zw = float2(unity_CameraProjection[0][0], unity_CameraProjection[1][0]) * r5.yy + r4.zw;
    r4.zw = float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) * r5.ww + r4.zw;
    r2.w = 1 + -r5.w;
    r2.w = unity_OrthoParams.w * r2.w + r5.w;
    r4.zw = r4.zw / r2.ww;
    r4.zw = float2(1,1) + r4.zw;
    r5.yz = float2(0.5,0.5) * r4.zw;
    r5.yz = r5.yz * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
    r6.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r5.yz).xyzw;
    r2.w = _ZBufferParams.x * r6.x;
    r3.w = -unity_OrthoParams.w * r2.w + 1;
    r2.w = r0.z * r2.w + _ZBufferParams.y;
    r2.w = r3.w / r2.w;
    r6.xy = cmp(r5.yz < float2(0,0));
    r3.w = (int)r6.y | (int)r6.x;
    r3.w = (int)r3.w & 1;
    r5.yz = cmp(float2(1,1) < r5.yz);
    r5.y = (int)r5.z | (int)r5.y;
    r5.y = r5.y ? 1 : 0;
    r3.w = (int)r3.w + (int)r5.y;
    r3.w = (int)r3.w;
    r5.y = cmp(9.99999975e-006 >= r2.w);
    r5.y = r5.y ? 1.000000 : 0;
    r3.w = r5.y + r3.w;
    r3.w = 100000000 * r3.w;
    r6.z = r2.w * _ProjectionParams.z + r3.w;
    r4.zw = -float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) + r4.zw;
    r4.zw = float2(-1,-1) + r4.zw;
    r4.zw = r4.zw / r4.xy;
    r2.w = 1 + -r6.z;
    r2.w = unity_OrthoParams.w * r2.w + r6.z;
    r6.xy = r4.zw * r2.ww;
    r5.yzw = r6.xyz + -r3.xyz;
    r2.w = dot(r5.yzw, r2.xyz);
    r2.w = -r3.z * 0.00200000009 + r2.w;
    r2.w = max(0, r2.w);
    r3.w = dot(r5.yzw, r5.yzw);
    r3.w = 9.99999975e-005 + r3.w;
    r2.w = r2.w / r3.w;
    r0.w = r2.w + r0.w;
    r1.x = (int)r1.x + 1;
  }
  r0.x = _Radius * r0.w;
  r0.x = _Intensity * r0.x;
  r0.x = r0.x / r0.y;
  r0.x = log2(r0.x);
  r0.x = 0.600000024 * r0.x;
  o0.x = exp2(r0.x);
  o0.yzw = r1.yzw * float3(0.5,0.5,-0.5) + float3(0.5,0.5,0.5);
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
		vs_8dfe92c42a2981fd_impl(v.position0, v.texcoord0, o0, o1, p1, o2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2.xy = o2;
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
		ps_e061be0419f7b3ca_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, o0);
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

Texture2D _CameraDepthNormalsTexture;
SamplerState sampler_CameraDepthNormalsTexture;

float4 _MainTex_TexelSize;
float4 _CameraDepthTexture_ST;
int _SampleCount;
float _Intensity;
float _Radius;
float _Downsample;

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

// vs 8dfe92c42a2981fd: 1 retail keyword combination(s)
void vs_8dfe92c42a2981fd_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float2 o2 : TEXCOORD2)
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
  r0.w = r0.x ? r0.y : v1.y;
  r0.xyz = v1.xyx;
  float4 _pk0 = 0;
  _pk0.xyzw = r0.xyzw;
  o1.xy = _pk0.xy;
  p1.xy = _pk0.zw;
  o2.xy = r0.zw;
  return;
}


// ps e1c8b9b0efd31c5d: 1 retail keyword combination(s)
void ps_e1c8b9b0efd31c5d_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
  r1.xyzw = _CameraDepthNormalsTexture.Sample(sampler_CameraDepthNormalsTexture, r0.xy).xyzw;
  r2.xyz = r1.xyz * float3(3.55539989,3.55539989,0) + float3(-1.77769995,-1.77769995,1);
  r0.z = dot(r2.xyz, r2.xyz);
  r0.z = 2 / r0.z;
  r2.yz = r0.zz * r2.xy;
  r2.w = -1 + r0.z;
  r3.xyz = float3(1,1,-1) * r2.yzw;
  r0.z = dot(r1.zw, float2(1,0.00392156886));
  r1.xy = cmp(r0.xy < float2(0,0));
  r0.w = (int)r1.y | (int)r1.x;
  r0.xy = cmp(float2(1,1) < r0.xy);
  r0.x = (int)r0.y | (int)r0.x;
  r0.xw = r0.xw ? float2(1,1) : 0;
  r0.x = (int)r0.x + (int)r0.w;
  r0.x = (int)r0.x;
  r0.y = cmp(9.99999975e-006 >= r0.z);
  r0.y = r0.y ? 1.000000 : 0;
  r0.x = r0.x + r0.y;
  r0.x = 100000000 * r0.x;
  r0.x = r0.z * _ProjectionParams.z + r0.x;
  r0.z = -_ProjectionParams.z * 1.52587891e-005 + r0.x;
  r1.xy = w1.xy * float2(2,2) + float2(-1,-1);
  r1.xy = -float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) + r1.xy;
  r4.x = unity_CameraProjection[0][0];
  r4.y = unity_CameraProjection[1][1];
  r1.xy = r1.xy / r4.xy;
  r0.w = 1 + -r0.z;
  r0.w = unity_OrthoParams.w * r0.w + r0.z;
  r0.xy = r1.xy * r0.ww;
  r1.xy = _Downsample.xx * v1.xy;
  r1.xy = _ScreenParams.xy * r1.xy;
  r1.xy = floor(r1.xy);
  r0.w = dot(float2(0.0671105608,0.00583714992), r1.xy);
  r0.w = frac(r0.w);
  r0.w = 52.9829178 * r0.w;
  r0.w = frac(r0.w);
  r1.x = asint(_SampleCount);
  r5.x = 12.9898005;
  r1.yz = float2(0,0);
  [loop] while (true) {
    r1.w = cmp((int)r1.z >= asint(_SampleCount));
    [branch] if (r1.w != 0) break;
    r1.w = (int)r1.z;
    r1.w = 1.00010002 * r1.w;
    r5.y = floor(r1.w);
    r1.w = 78.2330017 * r5.y;
    r1.w = sin(r1.w);
    r1.w = 43758.5469 * r1.w;
    r1.w = frac(r1.w);
    r1.w = r1.w + r0.w;
    r1.w = frac(r1.w);
    r6.z = r1.w * 2 + -1;
    r1.w = dot(r5.xy, float2(1,78.2330017));
    r1.w = sin(r1.w);
    r1.w = 43758.5469 * r1.w;
    r1.w = frac(r1.w);
    r1.w = r1.w + r0.w;
    r1.w = 6.28318548 * r1.w;
    sincos(r1.w, r2.x, r7.x);
    r1.w = -r6.z * r6.z + 1;
    r1.w = sqrt(r1.w);
    r7.y = r2.x;
    r6.xy = r7.xy * r1.ww;
    r1.w = 1 + r5.y;
    r1.w = r1.w / r1.x;
    r1.w = sqrt(r1.w);
    r1.w = _Radius * r1.w;
    r5.yzw = r6.xyz * r1.www;
    r1.w = dot(-r3.xyz, r5.yzw);
    r1.w = cmp(r1.w >= 0);
    r5.yzw = r1.www ? -r5.yzw : r5.yzw;
    r5.yzw = r5.yzw + r0.xyz;
    r4.zw = float2(unity_CameraProjection[0][1], unity_CameraProjection[1][1]) * r5.zz;
    r4.zw = float2(unity_CameraProjection[0][0], unity_CameraProjection[1][0]) * r5.yy + r4.zw;
    r4.zw = float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) * r5.ww + r4.zw;
    r1.w = 1 + -r5.w;
    r1.w = unity_OrthoParams.w * r1.w + r5.w;
    r4.zw = r4.zw / r1.ww;
    r4.zw = float2(1,1) + r4.zw;
    r5.yz = float2(0.5,0.5) * r4.zw;
    r5.yz = r5.yz * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
    r6.xyzw = _CameraDepthNormalsTexture.Sample(sampler_CameraDepthNormalsTexture, r5.yz).xyzw;
    r1.w = dot(r6.zw, float2(1,0.00392156886));
    r6.xy = cmp(r5.yz < float2(0,0));
    r2.x = (int)r6.y | (int)r6.x;
    r2.x = (int)r2.x & 1;
    r5.yz = cmp(float2(1,1) < r5.yz);
    r3.w = (int)r5.z | (int)r5.y;
    r3.w = (int)r3.w & 1;
    r2.x = (int)r2.x + (int)r3.w;
    r2.x = (int)r2.x;
    r3.w = cmp(9.99999975e-006 >= r1.w);
    r3.w = r3.w ? 1.000000 : 0;
    r2.x = r3.w + r2.x;
    r2.x = 100000000 * r2.x;
    r6.z = r1.w * _ProjectionParams.z + r2.x;
    r4.zw = -float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) + r4.zw;
    r4.zw = float2(-1,-1) + r4.zw;
    r4.zw = r4.zw / r4.xy;
    r1.w = 1 + -r6.z;
    r1.w = unity_OrthoParams.w * r1.w + r6.z;
    r6.xy = r4.zw * r1.ww;
    r5.yzw = r6.xyz + -r0.xyz;
    r1.w = dot(r5.yzw, r3.xyz);
    r1.w = -r0.z * 0.00200000009 + r1.w;
    r1.w = max(0, r1.w);
    r2.x = dot(r5.yzw, r5.yzw);
    r2.x = 9.99999975e-005 + r2.x;
    r1.w = r1.w / r2.x;
    r1.y = r1.y + r1.w;
    r1.z = (int)r1.z + 1;
  }
  r0.x = _Radius * r1.y;
  r0.x = _Intensity * r0.x;
  r0.x = r0.x / r1.x;
  r0.x = log2(r0.x);
  r0.x = 0.600000024 * r0.x;
  o0.x = exp2(r0.x);
  o0.yzw = r2.yzw * float3(0.5,0.5,-0.5) + float3(0.5,0.5,0.5);
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
		vs_8dfe92c42a2981fd_impl(v.position0, v.texcoord0, o0, o1, p1, o2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2.xy = o2;
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
		ps_e1c8b9b0efd31c5d_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, o0);
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
			#pragma multi_compile _ _HEIGHT_AO

#define cmp -

Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _GroundHeightTex;
SamplerState sampler_GroundHeightTex;

float4 _MainTex_TexelSize;
float4 _CameraDepthTexture_ST;
int _SampleCount;
float _Intensity;
float _Radius;
float _Downsample;

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

// vs 8dfe92c42a2981fd: 2 retail keyword combination(s)
void vs_8dfe92c42a2981fd_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float2 o2 : TEXCOORD2)
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
  r0.w = r0.x ? r0.y : v1.y;
  r0.xyz = v1.xyx;
  float4 _pk0 = 0;
  _pk0.xyzw = r0.xyzw;
  o1.xy = _pk0.xy;
  p1.xy = _pk0.zw;
  o2.xy = r0.zw;
  return;
}


// ps ae5eccfdb2060c4e: 1 retail keyword combination(s)
void ps_ae5eccfdb2060c4e_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
  r1.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r0.z = dot(r1.xyz, r1.xyz);
  r0.z = cmp(r0.z != 0.000000);
  r0.z = r0.z ? -1 : -0;
  r1.xyz = r1.xyz * float3(2,2,2) + r0.zzz;
  r2.xyz = float3(unity_WorldToCamera[0][1], unity_WorldToCamera[1][1], unity_WorldToCamera[2][1]) * r1.yyy;
  r1.xyw = float3(unity_WorldToCamera[0][0], unity_WorldToCamera[1][0], unity_WorldToCamera[2][0]) * r1.xxx + r2.xyz;
  r1.xyz = float3(unity_WorldToCamera[0][2], unity_WorldToCamera[1][2], unity_WorldToCamera[2][2]) * r1.zzz + r1.xyw;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.z = 1 + -unity_OrthoParams.w;
  r0.w = _ZBufferParams.x * r2.x;
  r1.w = -unity_OrthoParams.w * r0.w + 1;
  r0.w = r0.z * r0.w + _ZBufferParams.y;
  r0.w = r1.w / r0.w;
  r2.xy = cmp(r0.xy < float2(0,0));
  r1.w = (int)r2.y | (int)r2.x;
  r1.w = (int)r1.w & 1;
  r0.xy = cmp(float2(1,1) < r0.xy);
  r0.x = (int)r0.y | (int)r0.x;
  r0.x = r0.x ? 1 : 0;
  r0.x = (int)r0.x + (int)r1.w;
  r0.x = (int)r0.x;
  r0.y = cmp(9.99999975e-006 >= r0.w);
  r0.y = r0.y ? 1.000000 : 0;
  r0.x = r0.x + r0.y;
  r0.x = 100000000 * r0.x;
  r2.z = r0.w * _ProjectionParams.z + r0.x;
  r0.xy = w1.xy * float2(2,2) + float2(-1,-1);
  r0.xy = -float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) + r0.xy;
  r3.x = unity_CameraProjection[0][0];
  r3.y = unity_CameraProjection[1][1];
  r0.xy = r0.xy / r3.xy;
  r0.w = 1 + -r2.z;
  r0.w = unity_OrthoParams.w * r0.w + r2.z;
  r2.xy = r0.xy * r0.ww;
  r0.xy = _Downsample.xx * v1.xy;
  r0.xy = _ScreenParams.xy * r0.xy;
  r0.xy = floor(r0.xy);
  r0.x = dot(float2(0.0671105608,0.00583714992), r0.xy);
  r0.x = frac(r0.x);
  r0.x = 52.9829178 * r0.x;
  r0.x = frac(r0.x);
  r0.y = asint(_SampleCount);
  r4.x = 12.9898005;
  r0.w = 0;
  r1.w = 0;
  [loop] while (true) {
    r2.w = cmp((int)r1.w >= asint(_SampleCount));
    [branch] if (r2.w != 0) break;
    r2.w = (int)r1.w;
    r2.w = 1.00010002 * r2.w;
    r4.y = floor(r2.w);
    r2.w = 78.2330017 * r4.y;
    r2.w = sin(r2.w);
    r2.w = 43758.5469 * r2.w;
    r2.w = frac(r2.w);
    r2.w = r2.w + r0.x;
    r2.w = frac(r2.w);
    r5.z = r2.w * 2 + -1;
    r2.w = dot(r4.xy, float2(1,78.2330017));
    r2.w = sin(r2.w);
    r2.w = 43758.5469 * r2.w;
    r2.w = frac(r2.w);
    r2.w = r2.w + r0.x;
    r2.w = 6.28318548 * r2.w;
    sincos(r2.w, r6.x, r7.x);
    r2.w = -r5.z * r5.z + 1;
    r2.w = sqrt(r2.w);
    r7.y = r6.x;
    r5.xy = r7.xy * r2.ww;
    r2.w = 1 + r4.y;
    r2.w = r2.w / r0.y;
    r2.w = sqrt(r2.w);
    r2.w = _Radius * r2.w;
    r4.yzw = r5.xyz * r2.www;
    r2.w = dot(-r1.xyz, r4.yzw);
    r2.w = cmp(r2.w >= 0);
    r4.yzw = r2.www ? -r4.yzw : r4.yzw;
    r4.yzw = r4.yzw + r2.xyz;
    r3.zw = float2(unity_CameraProjection[0][1], unity_CameraProjection[1][1]) * r4.zz;
    r3.zw = float2(unity_CameraProjection[0][0], unity_CameraProjection[1][0]) * r4.yy + r3.zw;
    r3.zw = float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) * r4.ww + r3.zw;
    r2.w = 1 + -r4.w;
    r2.w = unity_OrthoParams.w * r2.w + r4.w;
    r3.zw = r3.zw / r2.ww;
    r3.zw = float2(1,1) + r3.zw;
    r4.yz = float2(0.5,0.5) * r3.zw;
    r4.yz = r4.yz * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
    r5.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r4.yz).xyzw;
    r2.w = _ZBufferParams.x * r5.x;
    r4.w = -unity_OrthoParams.w * r2.w + 1;
    r2.w = r0.z * r2.w + _ZBufferParams.y;
    r2.w = r4.w / r2.w;
    r5.xy = cmp(r4.yz < float2(0,0));
    r4.w = (int)r5.y | (int)r5.x;
    r4.yz = cmp(float2(1,1) < r4.yz);
    r4.y = (int)r4.z | (int)r4.y;
    r4.yw = r4.yw ? float2(1,1) : 0;
    r4.y = (int)r4.y + (int)r4.w;
    r4.y = (int)r4.y;
    r4.z = cmp(9.99999975e-006 >= r2.w);
    r4.z = r4.z ? 1.000000 : 0;
    r4.y = r4.y + r4.z;
    r4.y = 100000000 * r4.y;
    r5.z = r2.w * _ProjectionParams.z + r4.y;
    r3.zw = -float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) + r3.zw;
    r3.zw = float2(-1,-1) + r3.zw;
    r3.zw = r3.zw / r3.xy;
    r2.w = 1 + -r5.z;
    r2.w = unity_OrthoParams.w * r2.w + r5.z;
    r5.xy = r3.zw * r2.ww;
    r4.yzw = r5.xyz + -r2.xyz;
    r2.w = dot(r4.yzw, r1.xyz);
    r2.w = -r2.z * 0.00200000009 + r2.w;
    r2.w = max(0, r2.w);
    r3.z = dot(r4.yzw, r4.yzw);
    r3.z = 9.99999975e-005 + r3.z;
    r2.w = r2.w / r3.z;
    r0.w = r2.w + r0.w;
    r1.w = (int)r1.w + 1;
  }
  r0.x = _Radius * r0.w;
  r0.x = _Intensity * r0.x;
  r0.x = r0.x / r0.y;
  r0.x = log2(r0.x);
  r0.x = 0.600000024 * r0.x;
  o0.x = exp2(r0.x);
  o0.yzw = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  return;
}


// ps b45ef3bc71bf1786: 1 retail keyword combination(s)
void ps_b45ef3bc71bf1786_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
  r1.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r0.z = dot(r1.xyz, r1.xyz);
  r0.z = cmp(r0.z != 0.000000);
  r0.z = r0.z ? -1 : -0;
  r1.xyz = r1.xyz * float3(2,2,2) + r0.zzz;
  r2.xyz = float3(unity_WorldToCamera[0][1], unity_WorldToCamera[1][1], unity_WorldToCamera[2][1]) * r1.yyy;
  r1.xyw = float3(unity_WorldToCamera[0][0], unity_WorldToCamera[1][0], unity_WorldToCamera[2][0]) * r1.xxx + r2.xyz;
  r1.xyz = float3(unity_WorldToCamera[0][2], unity_WorldToCamera[1][2], unity_WorldToCamera[2][2]) * r1.zzz + r1.xyw;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.z = 1 + -unity_OrthoParams.w;
  r0.w = _ZBufferParams.x * r2.x;
  r1.w = -unity_OrthoParams.w * r0.w + 1;
  r0.w = r0.z * r0.w + _ZBufferParams.y;
  r0.w = r1.w / r0.w;
  r2.xy = cmp(r0.xy < float2(0,0));
  r1.w = (int)r2.y | (int)r2.x;
  r1.w = (int)r1.w & 1;
  r0.xy = cmp(float2(1,1) < r0.xy);
  r0.x = (int)r0.y | (int)r0.x;
  r0.x = r0.x ? 1 : 0;
  r0.x = (int)r0.x + (int)r1.w;
  r0.x = (int)r0.x;
  r0.y = cmp(9.99999975e-006 >= r0.w);
  r0.y = r0.y ? 1.000000 : 0;
  r0.x = r0.x + r0.y;
  r0.x = 100000000 * r0.x;
  r2.z = r0.w * _ProjectionParams.z + r0.x;
  r0.xy = w1.xy * float2(2,2) + float2(-1,-1);
  r0.xy = -float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) + r0.xy;
  r3.x = unity_CameraProjection[0][0];
  r3.y = unity_CameraProjection[1][1];
  r0.xy = r0.xy / r3.xy;
  r0.w = 1 + -r2.z;
  r0.w = unity_OrthoParams.w * r0.w + r2.z;
  r2.xy = r0.xy * r0.ww;
  r0.xy = _Downsample.xx * v1.xy;
  r0.xy = _ScreenParams.xy * r0.xy;
  r0.xy = floor(r0.xy);
  r0.x = dot(float2(0.0671105608,0.00583714992), r0.xy);
  r0.x = frac(r0.x);
  r0.x = 52.9829178 * r0.x;
  r0.x = frac(r0.x);
  r0.y = asint(_SampleCount);
  r4.x = 12.9898005;
  r0.w = 0;
  r1.w = 0;
  [loop] while (true) {
    r2.w = cmp((int)r1.w >= asint(_SampleCount));
    [branch] if (r2.w != 0) break;
    r2.w = (int)r1.w;
    r2.w = 1.00010002 * r2.w;
    r4.y = floor(r2.w);
    r2.w = 78.2330017 * r4.y;
    r2.w = sin(r2.w);
    r2.w = 43758.5469 * r2.w;
    r2.w = frac(r2.w);
    r2.w = r2.w + r0.x;
    r2.w = frac(r2.w);
    r5.z = r2.w * 2 + -1;
    r2.w = dot(r4.xy, float2(1,78.2330017));
    r2.w = sin(r2.w);
    r2.w = 43758.5469 * r2.w;
    r2.w = frac(r2.w);
    r2.w = r2.w + r0.x;
    r2.w = 6.28318548 * r2.w;
    sincos(r2.w, r6.x, r7.x);
    r2.w = -r5.z * r5.z + 1;
    r2.w = sqrt(r2.w);
    r7.y = r6.x;
    r5.xy = r7.xy * r2.ww;
    r2.w = 1 + r4.y;
    r2.w = r2.w / r0.y;
    r2.w = sqrt(r2.w);
    r2.w = _Radius * r2.w;
    r4.yzw = r5.xyz * r2.www;
    r2.w = dot(-r1.xyz, r4.yzw);
    r2.w = cmp(r2.w >= 0);
    r4.yzw = r2.www ? -r4.yzw : r4.yzw;
    r4.yzw = r4.yzw + r2.xyz;
    r3.zw = float2(unity_CameraProjection[0][1], unity_CameraProjection[1][1]) * r4.zz;
    r3.zw = float2(unity_CameraProjection[0][0], unity_CameraProjection[1][0]) * r4.yy + r3.zw;
    r3.zw = float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) * r4.ww + r3.zw;
    r2.w = 1 + -r4.w;
    r2.w = unity_OrthoParams.w * r2.w + r4.w;
    r3.zw = r3.zw / r2.ww;
    r3.zw = float2(1,1) + r3.zw;
    r4.yz = float2(0.5,0.5) * r3.zw;
    r4.yz = r4.yz * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
    r5.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r4.yz).xyzw;
    r2.w = _ZBufferParams.x * r5.x;
    r4.w = -unity_OrthoParams.w * r2.w + 1;
    r2.w = r0.z * r2.w + _ZBufferParams.y;
    r2.w = r4.w / r2.w;
    r5.xy = cmp(r4.yz < float2(0,0));
    r4.w = (int)r5.y | (int)r5.x;
    r4.yz = cmp(float2(1,1) < r4.yz);
    r4.y = (int)r4.z | (int)r4.y;
    r4.yw = r4.yw ? float2(1,1) : 0;
    r4.y = (int)r4.y + (int)r4.w;
    r4.y = (int)r4.y;
    r4.z = cmp(9.99999975e-006 >= r2.w);
    r4.z = r4.z ? 1.000000 : 0;
    r4.y = r4.y + r4.z;
    r4.y = 100000000 * r4.y;
    r5.z = r2.w * _ProjectionParams.z + r4.y;
    r3.zw = -float2(unity_CameraProjection[0][2], unity_CameraProjection[1][2]) + r3.zw;
    r3.zw = float2(-1,-1) + r3.zw;
    r3.zw = r3.zw / r3.xy;
    r2.w = 1 + -r5.z;
    r2.w = unity_OrthoParams.w * r2.w + r5.z;
    r5.xy = r3.zw * r2.ww;
    r4.yzw = r5.xyz + -r2.xyz;
    r2.w = dot(r4.yzw, r1.xyz);
    r2.w = -r2.z * 0.00200000009 + r2.w;
    r2.w = max(0, r2.w);
    r3.z = dot(r4.yzw, r4.yzw);
    r3.z = 9.99999975e-005 + r3.z;
    r2.w = r2.w / r3.z;
    r0.w = r2.w + r0.w;
    r1.w = (int)r1.w + 1;
  }
  r0.x = _Radius * r0.w;
  r0.x = _Intensity * r0.x;
  r0.x = r0.x / r0.y;
  r0.x = log2(r0.x);
  r0.x = 0.600000024 * r0.x;
  r0.x = exp2(r0.x);
  r0.yzw = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r2.yyy;
  r0.yzw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r2.xxx + r0.yzw;
  r0.yzw = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r2.zzz + r0.yzw;
  r0.yzw = float3(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3]) + r0.yzw;
  r0.yw = float2(1024,1024) + r0.yw;
  r0.yw = float2(0.00048828125,0.00048828125) * r0.yw;
  r2.xyzw = _GroundHeightTex.Sample(sampler_GroundHeightTex, r0.yw).xyzw;
  r0.y = 50 + r2.x;
  r0.w = r2.x + -r0.y;
  r0.y = r0.z + -r0.y;
  r0.z = 1 / r0.w;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.y = 0.5 * r0.y;
  o0.x = max(r0.x, r0.y);
  o0.yzw = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
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
		vs_8dfe92c42a2981fd_impl(v.position0, v.texcoord0, o0, o1, p1, o2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2.xy = o2;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_HEIGHT_AO)
	{
		float4 o0 = 0;
		ps_ae5eccfdb2060c4e_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, o0);
		r.t0 = o0;
	}
#elif defined(_HEIGHT_AO)
	{
		float4 o0 = 0;
		ps_b45ef3bc71bf1786_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, o0);
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
Texture2D _CameraDepthNormalsTexture;
SamplerState sampler_CameraDepthNormalsTexture;

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
	float4 texcoord2 : TEXCOORD2;
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

// vs 8dfe92c42a2981fd: 1 retail keyword combination(s)
void vs_8dfe92c42a2981fd_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float2 o2 : TEXCOORD2)
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
  r0.w = r0.x ? r0.y : v1.y;
  r0.xyz = v1.xyx;
  float4 _pk0 = 0;
  _pk0.xyzw = r0.xyzw;
  o1.xy = _pk0.xy;
  p1.xy = _pk0.zw;
  o2.xy = r0.zw;
  return;
}


// ps 6c23262f412fab4b: 1 retail keyword combination(s)
void ps_6c23262f412fab4b_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthNormalsTexture.Sample(sampler_CameraDepthNormalsTexture, v2.xy).xyzw;
  r0.xyz = r0.xyz * float3(3.55539989,3.55539989,0) + float3(-1.77769995,-1.77769995,1);
  r0.z = dot(r0.xyz, r0.xyz);
  r0.z = 2 / r0.z;
  r1.yz = r0.zz * r0.xy;
  r1.w = -1 + r0.z;
  r0.xyz = float3(1,1,-1) * r1.yzw;
  o0.yzw = r1.yzw * float3(0.5,0.5,-0.5) + float3(0.5,0.5,0.5);
  r1.x = _MainTex_TexelSize.x;
  r1.y = 0;
  r2.xyzw = -r1.xyxy * float4(2.76923084,1.38461542,6.46153831,3.23076916) + v2.xyxy;
  r1.xyzw = r1.xyxy * float4(2.76923084,1.38461542,6.46153831,3.23076916) + v2.xyxy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r3.yzw = r3.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r0.xyz, r3.yzw);
  r0.w = -0.800000012 + r0.w;
  r0.w = saturate(5.00000048 * r0.w);
  r3.y = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r3.y * r0.w;
  r0.w = 0.31621623 * r0.w;
  r3.x = r3.x * r0.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v2.xy).xyzw;
  r3.x = r4.x * 0.227027029 + r3.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r3.yzw = r4.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r3.y = dot(r0.xyz, r3.yzw);
  r3.y = -0.800000012 + r3.y;
  r3.y = saturate(5.00000048 * r3.y);
  r3.z = r3.y * -2 + 3;
  r3.y = r3.y * r3.y;
  r3.y = r3.z * r3.y;
  r3.z = 0.31621623 * r3.y;
  r0.w = r3.y * 0.31621623 + r0.w;
  r3.x = r4.x * r3.z + r3.x;
  r2.yzw = r2.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = dot(r0.xyz, r2.yzw);
  r2.y = -0.800000012 + r2.y;
  r2.y = saturate(5.00000048 * r2.y);
  r2.z = r2.y * -2 + 3;
  r2.y = r2.y * r2.y;
  r2.y = r2.z * r2.y;
  r2.z = 0.0702702701 * r2.y;
  r0.w = r2.y * 0.0702702701 + r0.w;
  r2.x = r2.x * r2.z + r3.x;
  r1.yzw = r1.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = dot(r0.xyz, r1.yzw);
  r0.x = -0.800000012 + r0.x;
  r0.x = saturate(5.00000048 * r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.y = 0.0702702701 * r0.x;
  r0.x = r0.x * 0.0702702701 + r0.w;
  r0.x = 0.227027029 + r0.x;
  r0.y = r1.x * r0.y + r2.x;
  o0.x = r0.y / r0.x;
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
		vs_8dfe92c42a2981fd_impl(v.position0, v.texcoord0, o0, o1, p1, o2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2.xy = o2;
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
		ps_6c23262f412fab4b_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, o0);
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
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;

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
	float4 texcoord2 : TEXCOORD2;
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

// vs 8dfe92c42a2981fd: 1 retail keyword combination(s)
void vs_8dfe92c42a2981fd_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float2 o2 : TEXCOORD2)
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
  r0.w = r0.x ? r0.y : v1.y;
  r0.xyz = v1.xyx;
  float4 _pk0 = 0;
  _pk0.xyzw = r0.xyzw;
  o1.xy = _pk0.xy;
  p1.xy = _pk0.zw;
  o2.xy = r0.zw;
  return;
}


// ps cb9d856e2a8a92a6: 1 retail keyword combination(s)
void ps_cb9d856e2a8a92a6_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v2.xy).xyzw;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = cmp(r0.w != 0.000000);
  r0.w = r0.w ? -1 : -0;
  r0.xyz = r0.xyz * float3(2,2,2) + r0.www;
  r1.xyz = float3(unity_WorldToCamera[0][1], unity_WorldToCamera[1][1], unity_WorldToCamera[2][1]) * r0.yyy;
  r0.xyw = float3(unity_WorldToCamera[0][0], unity_WorldToCamera[1][0], unity_WorldToCamera[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_WorldToCamera[0][2], unity_WorldToCamera[1][2], unity_WorldToCamera[2][2]) * r0.zzz + r0.xyw;
  r1.x = _MainTex_TexelSize.x;
  r1.y = 0;
  r2.xyzw = -r1.xyxy * float4(2.76923084,1.38461542,6.46153831,3.23076916) + v2.xyxy;
  r1.xyzw = r1.xyxy * float4(2.76923084,1.38461542,6.46153831,3.23076916) + v2.xyxy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r3.yzw = r3.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = dot(r0.xyz, r3.yzw);
  r0.w = -0.800000012 + r0.w;
  r0.w = saturate(5.00000048 * r0.w);
  r3.y = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r3.y * r0.w;
  r0.w = 0.31621623 * r0.w;
  r3.x = r3.x * r0.w;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, v2.xy).xyzw;
  r3.x = r4.x * 0.227027029 + r3.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r3.yzw = r4.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r3.y = dot(r0.xyz, r3.yzw);
  r3.y = -0.800000012 + r3.y;
  r3.y = saturate(5.00000048 * r3.y);
  r3.z = r3.y * -2 + 3;
  r3.y = r3.y * r3.y;
  r3.y = r3.z * r3.y;
  r3.z = 0.31621623 * r3.y;
  r0.w = r3.y * 0.31621623 + r0.w;
  r3.x = r4.x * r3.z + r3.x;
  r2.yzw = r2.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = dot(r0.xyz, r2.yzw);
  r2.y = -0.800000012 + r2.y;
  r2.y = saturate(5.00000048 * r2.y);
  r2.z = r2.y * -2 + 3;
  r2.y = r2.y * r2.y;
  r2.y = r2.z * r2.y;
  r2.z = 0.0702702701 * r2.y;
  r0.w = r2.y * 0.0702702701 + r0.w;
  r2.x = r2.x * r2.z + r3.x;
  r1.yzw = r1.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.y = dot(r0.xyz, r1.yzw);
  o0.yzw = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r0.x = -0.800000012 + r1.y;
  r0.x = saturate(5.00000048 * r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.y = 0.0702702701 * r0.x;
  r0.x = r0.x * 0.0702702701 + r0.w;
  r0.x = 0.227027029 + r0.x;
  r0.y = r1.x * r0.y + r2.x;
  o0.x = r0.y / r0.x;
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
		vs_8dfe92c42a2981fd_impl(v.position0, v.texcoord0, o0, o1, p1, o2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2.xy = o2;
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
		ps_cb9d856e2a8a92a6_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, o0);
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
float _Downsample;

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

// vs 8dfe92c42a2981fd: 1 retail keyword combination(s)
void vs_8dfe92c42a2981fd_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float2 o2 : TEXCOORD2)
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
  r0.w = r0.x ? r0.y : v1.y;
  r0.xyz = v1.xyx;
  float4 _pk0 = 0;
  _pk0.xyzw = r0.xyzw;
  o1.xy = _pk0.xy;
  p1.xy = _pk0.zw;
  o2.xy = r0.zw;
  return;
}


// ps 8a9fb2cf5eee039e: 1 retail keyword combination(s)
void ps_8a9fb2cf5eee039e_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _MainTex_TexelSize.y / _Downsample;
  r0.yz = float2(1.38461542,3.23076916);
  r1.xyzw = float4(-0,-2.76923084,-0,-6.46153831) * r0.yxzx + v2.xyxy;
  r0.xyzw = float4(0,2.76923084,0,6.46153831) * r0.yxzx + v2.xyxy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r2.yzw = r2.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r3.xyzw = _MainTex.Sample(sampler_MainTex, v2.xy).xyzw;
  r3.yzw = r3.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = dot(r3.yzw, r2.yzw);
  r2.y = -0.800000012 + r2.y;
  r2.y = saturate(5.00000048 * r2.y);
  r2.z = r2.y * -2 + 3;
  r2.y = r2.y * r2.y;
  r2.y = r2.z * r2.y;
  r2.y = 0.31621623 * r2.y;
  r2.x = r2.x * r2.y;
  r2.x = r3.x * 0.227027029 + r2.x;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r4.yzw = r4.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r2.z = dot(r3.yzw, r4.yzw);
  r2.z = -0.800000012 + r2.z;
  r2.z = saturate(5.00000048 * r2.z);
  r2.w = r2.z * -2 + 3;
  r2.z = r2.z * r2.z;
  r2.z = r2.w * r2.z;
  r2.w = 0.31621623 * r2.z;
  r2.y = r2.z * 0.31621623 + r2.y;
  r2.x = r4.x * r2.w + r2.x;
  r1.yzw = r1.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.y = dot(r3.yzw, r1.yzw);
  r1.y = -0.800000012 + r1.y;
  r1.y = saturate(5.00000048 * r1.y);
  r1.z = r1.y * -2 + 3;
  r1.y = r1.y * r1.y;
  r1.y = r1.z * r1.y;
  r1.z = 0.0702702701 * r1.y;
  r1.y = r1.y * 0.0702702701 + r2.y;
  r1.x = r1.x * r1.z + r2.x;
  r0.yzw = r0.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r0.y = dot(r3.yzw, r0.yzw);
  o0.yzw = r3.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r0.y = -0.800000012 + r0.y;
  r0.y = saturate(5.00000048 * r0.y);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.z = 0.0702702701 * r0.y;
  r0.y = r0.y * 0.0702702701 + r1.y;
  r0.y = 0.227027029 + r0.y;
  r0.x = r0.x * r0.z + r1.x;
  o0.x = r0.x / r0.y;
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
		vs_8dfe92c42a2981fd_impl(v.position0, v.texcoord0, o0, o1, p1, o2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2.xy = o2;
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
		ps_8a9fb2cf5eee039e_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, o0);
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

Texture2D _OcclusionTexture;
SamplerState sampler_OcclusionTexture;
Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_TexelSize;
float _Downsample;

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

// vs 8dfe92c42a2981fd: 1 retail keyword combination(s)
void vs_8dfe92c42a2981fd_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float2 o2 : TEXCOORD2)
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
  r0.w = r0.x ? r0.y : v1.y;
  r0.xyz = v1.xyx;
  float4 _pk0 = 0;
  _pk0.xyzw = r0.xyzw;
  o1.xy = _pk0.xy;
  p1.xy = _pk0.zw;
  o2.xy = r0.zw;
  return;
}


// ps 0a223cdf5d5f22c9: 1 retail keyword combination(s)
void ps_0a223cdf5d5f22c9_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = _MainTex_TexelSize.xy / _Downsample.xx;
  r1.xy = v2.xy + -r0.xy;
  r1.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r1.xy).xyzw;
  r1.yzw = r1.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r2.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, v2.xy).xyzw;
  r2.yzw = r2.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.y = dot(r2.yzw, r1.yzw);
  r1.y = -0.800000012 + r1.y;
  r1.y = saturate(5.00000048 * r1.y);
  r1.z = r1.y * -2 + 3;
  r1.y = r1.y * r1.y;
  r1.y = r1.z * r1.y;
  r1.x = r1.x * r1.y + r2.x;
  r0.zw = -r0.yx;
  r3.xyzw = v2.xyxy + r0.xzwy;
  r0.xy = v2.xy + r0.xy;
  r0.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r0.xy).xyzw;
  r4.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r3.xy).xyzw;
  r3.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r3.zw).xyzw;
  r4.yzw = r4.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.yzw, r4.yzw);
  r1.z = -0.800000012 + r1.z;
  r1.z = saturate(5.00000048 * r1.z);
  r1.w = r1.z * -2 + 3;
  r1.z = r1.z * r1.z;
  r2.x = r1.w * r1.z;
  r1.y = r1.w * r1.z + r1.y;
  r1.x = r4.x * r2.x + r1.x;
  r3.yzw = r3.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.yzw, r3.yzw);
  r1.z = -0.800000012 + r1.z;
  r1.z = saturate(5.00000048 * r1.z);
  r1.w = r1.z * -2 + 3;
  r1.z = r1.z * r1.z;
  r2.x = r1.w * r1.z;
  r1.y = r1.w * r1.z + r1.y;
  r1.x = r3.x * r2.x + r1.x;
  r0.yzw = r0.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r0.y = dot(r2.yzw, r0.yzw);
  r0.y = -0.800000012 + r0.y;
  r0.y = saturate(5.00000048 * r0.y);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.w = r0.z * r0.y;
  r0.y = r0.z * r0.y + r1.y;
  r0.y = 1 + r0.y;
  r0.x = r0.x * r0.w + r1.x;
  r0.x = r0.x / r0.y;
  r0.x = 1 + -r0.x;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v2.xy).xyzw;
  o0.xyz = r1.xyz * r0.xxx;
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
		float2 o2 = 0;
		vs_8dfe92c42a2981fd_impl(v.position0, v.texcoord0, o0, o1, p1, o2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2.xy = o2;
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
		ps_0a223cdf5d5f22c9_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, o0);
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
			Blend Zero OneMinusSrcColor, Zero OneMinusSrcAlpha
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt

#define cmp -

Texture2D _OcclusionTexture;
SamplerState sampler_OcclusionTexture;
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;

float _Downsample;

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

// vs 3aef539b7f36c200: 1 retail keyword combination(s)
void vs_3aef539b7f36c200_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1)
{
  o0.xyzw = v0.xyzw;
  float4 _pk0 = 0;
  _pk0.xyzw = v1.xyxy * float4(1,-1,1,-1) + float4(0,1,0,1);
  o1.xy = _pk0.xy;
  p1.xy = _pk0.zw;
  return;
}


// ps 82f2656d441735be: 1 retail keyword combination(s)
void ps_82f2656d441735be_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-1,-1) + _ScreenParams.zw;
  r0.xy = r0.xy / _Downsample.xx;
  r1.xy = w1.xy + -r0.xy;
  r1.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r1.xy).xyzw;
  r1.yzw = r1.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r2.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, w1.xy).xyzw;
  r2.yzw = r2.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.y = dot(r2.yzw, r1.yzw);
  r1.y = -0.800000012 + r1.y;
  r1.y = saturate(5.00000048 * r1.y);
  r1.z = r1.y * -2 + 3;
  r1.y = r1.y * r1.y;
  r1.y = r1.z * r1.y;
  r1.x = r1.x * r1.y + r2.x;
  r0.zw = -r0.yx;
  r3.xyzw = w1.xyxy + r0.xzwy;
  r0.xy = w1.xy + r0.xy;
  r0.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r0.xy).xyzw;
  r4.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r3.xy).xyzw;
  r3.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r3.zw).xyzw;
  r4.yzw = r4.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.yzw, r4.yzw);
  r1.z = -0.800000012 + r1.z;
  r1.z = saturate(5.00000048 * r1.z);
  r1.w = r1.z * -2 + 3;
  r1.z = r1.z * r1.z;
  r2.x = r1.w * r1.z;
  r1.y = r1.w * r1.z + r1.y;
  r1.x = r4.x * r2.x + r1.x;
  r3.yzw = r3.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.yzw, r3.yzw);
  r1.z = -0.800000012 + r1.z;
  r1.z = saturate(5.00000048 * r1.z);
  r1.w = r1.z * -2 + 3;
  r1.z = r1.z * r1.z;
  r2.x = r1.w * r1.z;
  r1.y = r1.w * r1.z + r1.y;
  r1.x = r3.x * r2.x + r1.x;
  r0.yzw = r0.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r0.y = dot(r2.yzw, r0.yzw);
  r0.y = -0.800000012 + r0.y;
  r0.y = saturate(5.00000048 * r0.y);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.w = r0.z * r0.y;
  r0.y = r0.z * r0.y + r1.y;
  r0.y = 1 + r0.y;
  r0.x = r0.x * r0.w + r1.x;
  r0.xyz = r0.xxx / r0.yyy;
  r1.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, w1.xy).xyzw;
  r0.w = cmp(r1.w >= 0.899999976);
  r0.w = r0.w ? 1.000000 : 0;
  r0.w = r0.z * r0.w;
  o0.w = r0.w * -0.350000024 + r0.z;
  o1.xyz = r0.xyz;
  o0.xyz = float3(0,0,0);
  o1.w = 0;
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
		vs_3aef539b7f36c200_impl(v.position0, v.texcoord0, o0, o1, p1);
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
		float4 o1 = 0;
		ps_82f2656d441735be_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0, o1);
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

#define cmp -

Texture2D _OcclusionTexture;
SamplerState sampler_OcclusionTexture;
Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_TexelSize;
float _Downsample;

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

// vs 8dfe92c42a2981fd: 1 retail keyword combination(s)
void vs_8dfe92c42a2981fd_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float2 o2 : TEXCOORD2)
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
  r0.w = r0.x ? r0.y : v1.y;
  r0.xyz = v1.xyx;
  float4 _pk0 = 0;
  _pk0.xyzw = r0.xyzw;
  o1.xy = _pk0.xy;
  p1.xy = _pk0.zw;
  o2.xy = r0.zw;
  return;
}


// ps 838c615b7ff7296a: 1 retail keyword combination(s)
void ps_838c615b7ff7296a_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = _MainTex_TexelSize.xy / _Downsample.xx;
  r1.xy = v2.xy + -r0.xy;
  r1.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r1.xy).xyzw;
  r1.yzw = r1.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r2.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, v2.xy).xyzw;
  r2.yzw = r2.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.y = dot(r2.yzw, r1.yzw);
  r1.y = -0.800000012 + r1.y;
  r1.y = saturate(5.00000048 * r1.y);
  r1.z = r1.y * -2 + 3;
  r1.y = r1.y * r1.y;
  r1.y = r1.z * r1.y;
  r1.x = r1.x * r1.y + r2.x;
  r0.zw = -r0.yx;
  r3.xyzw = v2.xyxy + r0.xzwy;
  r0.xy = v2.xy + r0.xy;
  r0.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r0.xy).xyzw;
  r4.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r3.xy).xyzw;
  r3.xyzw = _OcclusionTexture.Sample(sampler_OcclusionTexture, r3.zw).xyzw;
  r4.yzw = r4.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.yzw, r4.yzw);
  r1.z = -0.800000012 + r1.z;
  r1.z = saturate(5.00000048 * r1.z);
  r1.w = r1.z * -2 + 3;
  r1.z = r1.z * r1.z;
  r2.x = r1.w * r1.z;
  r1.y = r1.w * r1.z + r1.y;
  r1.x = r4.x * r2.x + r1.x;
  r3.yzw = r3.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(r2.yzw, r3.yzw);
  r1.z = -0.800000012 + r1.z;
  r1.z = saturate(5.00000048 * r1.z);
  r1.w = r1.z * -2 + 3;
  r1.z = r1.z * r1.z;
  r2.x = r1.w * r1.z;
  r1.y = r1.w * r1.z + r1.y;
  r1.x = r3.x * r2.x + r1.x;
  r0.yzw = r0.yzw * float3(2,2,2) + float3(-1,-1,-1);
  r0.y = dot(r2.yzw, r0.yzw);
  r0.y = -0.800000012 + r0.y;
  r0.y = saturate(5.00000048 * r0.y);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.w = r0.z * r0.y;
  r0.y = r0.z * r0.y + r1.y;
  r0.y = 1 + r0.y;
  r0.x = r0.x * r0.w + r1.x;
  r0.x = r0.x / r0.y;
  o0.xyz = float3(1,1,1) + -r0.xxx;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, v2.xy).xyzw;
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
		float2 o2 = 0;
		vs_8dfe92c42a2981fd_impl(v.position0, v.texcoord0, o0, o1, p1, o2);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2.xy = o2;
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
		ps_838c615b7ff7296a_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2.xy, o0);
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
