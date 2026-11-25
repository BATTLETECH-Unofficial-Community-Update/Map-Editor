Shader "Hidden/Post FX/Screen Space Reflection"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
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

Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;
Texture2D _CameraGBufferTexture1;
SamplerState sampler_CameraGBufferTexture1;
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;

float4 _MainTex_TexelSize;
float4 _ProjInfo;
float4x4 _WorldToCameraMatrix;
float4x4 _CameraToWorldMatrix;
float4x4 _ProjectToPixelMatrix;
float2 _ScreenSize;
float _RayStepSize;
float _MaxRayTraceDistance;
float _LayerThickness;
float _FresnelFade;
float _FresnelFadePower;
int _TreatBackfaceHitAsMiss;
int _AllowBackwardsRays;
float _ScreenEdgeFading;
int _MaxSteps;
int _TraceBehindObjects;

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

// vs 426fc50bff782225: 1 retail keyword combination(s)
void vs_426fc50bff782225_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps 1805243ee0da349f: 1 retail keyword combination(s)
void ps_1805243ee0da349f_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, w1.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r1.z = -r0.x;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, w1.xy).xyzw;
  r0.y = cmp(r1.z < -1000);
  r0.z = cmp(r2.z < 0.25);
  r0.y = (int)r0.z | (int)r0.y;
  [branch] if (r0.y == 0) {
    r0.yz = _MainTex_TexelSize.zw * w1.xy;
    r0.yz = r0.yz * _ProjInfo.xy + _ProjInfo.zw;
    r1.xy = r0.yz * r1.zz;
    r2.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, w1.xy).xyzw;
    r0.yzw = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r2.xyz = float3(_WorldToCameraMatrix[0][1], _WorldToCameraMatrix[1][1], _WorldToCameraMatrix[2][1]) * r0.zzz;
    r2.xyz = float3(_WorldToCameraMatrix[0][0], _WorldToCameraMatrix[1][0], _WorldToCameraMatrix[2][0]) * r0.yyy + r2.xyz;
    r0.yzw = float3(_WorldToCameraMatrix[0][2], _WorldToCameraMatrix[1][2], _WorldToCameraMatrix[2][2]) * r0.www + r2.xyz;
    r1.w = dot(r1.xyz, r1.xyz);
    r1.w = rsqrt(r1.w);
    r2.xyz = r1.xyz * r1.www;
    r1.w = dot(r0.yzw, -r2.xyz);
    r1.w = r1.w + r1.w;
    r3.xyz = r0.yzw * r1.www + r2.xyz;
    r1.w = dot(r3.xyz, r3.xyz);
    r1.w = rsqrt(r1.w);
    r3.xyz = r3.xyz * r1.www;
    r1.w = cmp(asint(_AllowBackwardsRays) == 0);
    r2.w = cmp(0 < r3.z);
    r1.w = r1.w ? r2.w : 0;
    [branch] if (r1.w == 0) {
      r1.w = 4 * _RayStepSize;
      r2.w = 0.00999999978 * r0.x;
      r2.w = max(0.00100000005, r2.w);
      r0.yzw = r0.yzw * r2.www + r1.xyz;
      r2.w = cmp(asint(_TraceBehindObjects) == 1);
      r4.xy = float2(1,1) / _ScreenSize.xy;
      r3.w = r3.z * _MaxRayTraceDistance + r0.w;
      r3.w = cmp(-0.00999999978 < r3.w);
      r4.z = -0.00999999978 + -r0.w;
      r4.z = r4.z / r3.z;
      r3.w = r3.w ? r4.z : _MaxRayTraceDistance;
      r5.xyz = r3.xyz * r3.www + r0.yzw;
      r6.xyz = float3(_ProjectToPixelMatrix[0][1], _ProjectToPixelMatrix[1][1], _ProjectToPixelMatrix[3][1]) * r0.zzz;
      r6.xyz = float3(_ProjectToPixelMatrix[0][0], _ProjectToPixelMatrix[1][0], _ProjectToPixelMatrix[3][0]) * r0.yyy + r6.xyz;
      r6.xyz = float3(_ProjectToPixelMatrix[0][2], _ProjectToPixelMatrix[1][2], _ProjectToPixelMatrix[3][2]) * r0.www + r6.xyz;
      r6.xyz = float3(_ProjectToPixelMatrix[0][3], _ProjectToPixelMatrix[1][3], _ProjectToPixelMatrix[3][3]) + r6.xyz;
      r7.xyz = float3(_ProjectToPixelMatrix[0][1], _ProjectToPixelMatrix[1][1], _ProjectToPixelMatrix[3][1]) * r5.yyy;
      r7.xyz = float3(_ProjectToPixelMatrix[0][0], _ProjectToPixelMatrix[1][0], _ProjectToPixelMatrix[3][0]) * r5.xxx + r7.xyz;
      r7.xyz = float3(_ProjectToPixelMatrix[0][2], _ProjectToPixelMatrix[1][2], _ProjectToPixelMatrix[3][2]) * r5.zzz + r7.xyz;
      r7.xyz = float3(_ProjectToPixelMatrix[0][3], _ProjectToPixelMatrix[1][3], _ProjectToPixelMatrix[3][3]) + r7.xyz;
      r3.w = 1 / r6.z;
      r4.z = 1 / r7.z;
      r6.zw = r6.yx * r3.ww;
      r7.zw = r7.xy * r4.zz;
      r8.xyz = r3.www * r0.yzw;
      r5.xyz = r5.xyz * r4.zzz;
      r9.xy = float2(-0.5,-0.5) + _ScreenSize.yx;
      r9.zw = cmp(r9.xy < r7.wz);
      r10.xy = cmp(r7.wz < float2(0.5,0.5));
      r10.xy = (int2)r9.zw | (int2)r10.xy;
      r9.xy = r9.zw ? -r9.xy : float2(-0.5,-0.5);
      r9.xy = r7.yx * r4.zz + r9.xy;
      r7.xy = r7.yx * r4.zz + -r6.zw;
      r7.xy = r9.xy / r7.xy;
      r4.w = r10.x ? r7.x : 0;
      r5.w = max(r4.w, r7.y);
      r4.w = r10.y ? r5.w : r4.w;
      r7.xy = r6.xy * r3.ww + -r7.zw;
      r7.xy = r4.ww * r7.xy + r7.zw;
      r5.w = -r4.z + r3.w;
      r4.z = r4.w * r5.w + r4.z;
      r9.xyz = r0.yzw * r3.www + -r5.xyz;
      r5.xyz = r4.www * r9.xyz + r5.xyz;
      r7.zw = r6.xy * r3.ww + -r7.xy;
      r4.w = dot(r7.zw, r7.zw);
      r4.w = cmp(r4.w < 9.99999975e-005);
      r7.zw = r6.xy * r3.ww + float2(0.00999999978,0.00999999978);
      r7.xy = r4.ww ? r7.zw : r7.xy;
      r7.zw = -r6.xy * r3.ww + r7.xy;
      r4.w = cmp(abs(r7.z) < abs(r7.w));
      r6.xy = r4.ww ? r6.zw : r6.wz;
      r7.xyz = r4.www ? r7.ywz : r7.xzw;
      r5.w = cmp(0 < r7.y);
      r6.z = cmp(r7.y < 0);
      r5.w = (int)-r5.w + (int)r6.z;
      r9.x = (int)r5.w;
      r5.w = r9.x / r7.y;
      r9.y = r5.w * r7.z;
      r5.xyz = -r0.yzw * r3.www + r5.xyz;
      r5.xyz = r5.xyz * r5.www;
      r0.y = r4.z + -r3.w;
      r0.y = r0.y * r5.w;
      r0.z = trunc(r1.w);
      r5.xyw = r5.xyz * r0.zzz;
      r1.w = r0.y * r0.z;
      r4.z = r9.x * r7.x;
      r6.z = 100000 + -_LayerThickness;
      r6.z = cmp(r0.w >= r6.z);
      r6.w = cmp(100000 >= r0.w);
      r6.z = r6.w ? r6.z : 0;
      r7.x = r8.z;
      r7.y = r3.w;
      r7.zw = float2(-1,-1);
      r10.xy = r6.xy;
      r6.w = 0;
      r8.w = r6.z;
      r11.y = r0.w;
      r9.z = r6.z;
      [loop] while (true) {
        r9.w = r10.x * r9.x;
        r9.w = cmp(r4.z >= r9.w);
        r10.z = cmp((int)r6.w < asint(_MaxSteps));
        r9.w = r9.w ? r10.z : 0;
        r10.z = ~(int)r9.z;
        r9.w = r9.w ? r10.z : 0;
        [branch] if (r9.w == 0) break;
        r9.w = r5.w * 0.5 + r7.x;
        r10.z = r1.w * 0.5 + r7.y;
        r11.x = r9.w / r10.z;
        r9.w = cmp(r11.x < r11.y);
        r10.zw = r9.ww ? r11.xy : r11.yx;
        r7.zw = r4.ww ? r10.yx : r10.xy;
        r11.zw = r7.zw * r4.xy;
        r12.xyzw = _CameraDepthTexture2.SampleLevel(sampler_CameraDepthTexture2, r11.zw, 0).xyzw;
        r9.w = _ZBufferParams.z * r12.x + _ZBufferParams.w;
        r9.w = 1 / r9.w;
        r10.z = cmp(-r9.w >= r10.z);
        r9.w = -_LayerThickness + -r9.w;
        r9.w = cmp(r10.w >= r9.w);
        r8.w = r9.w ? r10.z : 0;
        r9.z = r2.w ? r8.w : r10.z;
        r10.xy = r9.xy * r0.zz + r10.xy;
        r7.x = r5.z * r0.z + r7.x;
        r7.y = r0.y * r0.z + r7.y;
        r6.w = (int)r6.w + 1;
        r11.y = r11.x;
      }
      r4.z = -r5.z * r0.z + r7.x;
      r0.y = -r0.y * r0.z + r7.y;
      r0.z = (int)r6.w;
      r4.xy = r5.xy * r0.zz + r8.xy;
      r0.y = 1 / r0.y;
      r5.xy = r7.zw / _ScreenSize.xy;
      r1.xyz = r4.xyz * r0.yyy + -r1.xyz;
      o0.z = dot(r1.xyz, r3.xyz);
      [branch] if (r8.w != 0) {
        r0.y = r0.z + r0.z;
        r0.z = asint(_MaxSteps);
        r0.y = r0.y / r0.z;
        r0.y = -1 + r0.y;
        r0.y = max(0, r0.y);
        r0.y = 1 + -r0.y;
        r0.x = saturate(0.00100000005 * r0.x);
        r0.x = -0.5 + r0.x;
        r0.x = r0.x + r0.x;
        r0.x = max(0, r0.x);
        r0.z = r0.x * -2 + 3;
        r0.xy = r0.xy * r0.xy;
        r0.x = -r0.z * r0.x + 1;
        r0.x = r0.y * r0.x;
        r0.y = dot(r3.xyz, r2.xyz);
        r0.y = log2(abs(r0.y));
        r0.y = _FresnelFadePower * r0.y;
        r0.y = exp2(r0.y);
        r0.z = 1 + -_FresnelFade;
        r0.w = 1 + -r0.y;
        r0.y = r0.z * r0.w + r0.y;
        r0.y = max(0, r0.y);
        r0.x = r0.x * r0.y;
        r0.y = cmp(0 < asint(_TreatBackfaceHitAsMiss));
        [branch] if (r0.y != 0) {
          r1.xyzw = _CameraGBufferTexture2.SampleLevel(sampler_CameraGBufferTexture2, r5.xy, 0).xyzw;
          r0.yzw = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
          r1.xyz = float3(_CameraToWorldMatrix[0][1], _CameraToWorldMatrix[1][1], _CameraToWorldMatrix[2][1]) * r3.yyy;
          r1.xyz = float3(_CameraToWorldMatrix[0][0], _CameraToWorldMatrix[1][0], _CameraToWorldMatrix[2][0]) * r3.xxx + r1.xyz;
          r1.xyz = float3(_CameraToWorldMatrix[0][2], _CameraToWorldMatrix[1][2], _CameraToWorldMatrix[2][2]) * r3.zzz + r1.xyz;
          r0.y = dot(r0.yzw, r1.xyz);
          r0.y = cmp(0 < r0.y);
          r0.x = r0.y ? 0 : r0.x;
        }
      } else {
        r0.x = 0;
      }
      r0.yz = float2(1,1) + -r5.xy;
      r0.y = min(r0.y, r0.z);
      r0.z = min(r5.x, r5.x);
      r0.y = min(r0.y, r0.z);
      r0.z = _ScreenEdgeFading * 0.100000001 + 0.00100000005;
      r0.y = saturate(r0.y / r0.z);
      r0.y = log2(r0.y);
      r0.y = 0.200000003 * r0.y;
      r0.y = exp2(r0.y);
      r0.y = r0.y * r0.y;
      o0.w = r0.y * r0.x;
      o0.xy = r5.xy;
    } else {
      o0.xyzw = float4(0,0,0,0);
    }
  } else {
    o0.xyzw = float4(0,0,0,0);
  }
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
		vs_426fc50bff782225_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_1805243ee0da349f_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			#pragma multi_compile _ _BT_SIM_GAME

#define cmp -

Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _CameraGBufferTexture1;
SamplerState sampler_CameraGBufferTexture1;
Texture2D _FinalReflectionTexture;
SamplerState sampler_FinalReflectionTexture;
Texture2D _CameraGBufferTexture0;
SamplerState sampler_CameraGBufferTexture0;
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;
Texture2D _CameraReflectionsTexture;
SamplerState sampler_CameraReflectionsTexture;

float4 _MainTex_TexelSize;
float4 _ProjInfo;
float4x4 _CameraToWorldMatrix;
int _AdditiveReflection;
float _SSRMultiplier;

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

// vs 426fc50bff782225: 2 retail keyword combination(s)
void vs_426fc50bff782225_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps da4376cb01176dba: 2 retail keyword combination(s)
void ps_da4376cb01176dba_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, w1.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.z = -r0.x;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, w1.xy).xyzw;
  r0.w = cmp(r2.z < 0.25);
  r2.y = cmp(r0.z < -1000);
  r0.w = (int)r0.w | (int)r2.y;
  [branch] if (r0.w != 0) {
    o0.xyzw = r1.xyzw;
    return;
  }
  r3.xyzw = _FinalReflectionTexture.Sample(sampler_FinalReflectionTexture, w1.xy).wxyz;
  r0.w = cmp(r3.x == 0.000000);
  [branch] if (r0.w != 0) {
    o0.xyzw = r1.xyzw;
    return;
  }
  r2.yw = _MainTex_TexelSize.zw * w1.xy;
  r2.yw = r2.yw * _ProjInfo.xy + _ProjInfo.zw;
  r0.xy = r2.yw * r0.zz;
  r4.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, w1.xy).xyzw;
  r4.xyz = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r4.xyz;
  r4.xyz = r2.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
  r0.w = -r2.x * 0.959999979 + 0.959999979;
  r5.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, w1.xy).xyzw;
  r2.xyw = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r5.x = dot(r0.xyz, r0.xyz);
  r5.x = rsqrt(r5.x);
  r0.xyz = r5.xxx * r0.xyz;
  r5.xyz = float3(_CameraToWorldMatrix[0][1], _CameraToWorldMatrix[1][1], _CameraToWorldMatrix[2][1]) * r0.yyy;
  r5.xyz = float3(_CameraToWorldMatrix[0][0], _CameraToWorldMatrix[1][0], _CameraToWorldMatrix[2][0]) * r0.xxx + r5.xyz;
  r0.xyz = float3(_CameraToWorldMatrix[0][2], _CameraToWorldMatrix[1][2], _CameraToWorldMatrix[2][2]) * r0.zzz + r5.xyz;
  r0.x = saturate(dot(r2.xyw, -r0.xyz));
  r0.y = 1 + -r2.z;
  r0.y = r0.y * r0.y;
  r0.y = r0.y * r0.y + 1;
  r0.y = 1 / r0.y;
  r0.z = 1 + -r0.w;
  r0.z = saturate(r2.z + r0.z);
  r2.xyz = r0.yyy * r3.yzw;
  r0.x = 1 + -r0.x;
  r0.y = r0.x * r0.x;
  r0.y = r0.y * r0.y;
  r0.x = r0.y * r0.x;
  r0.yzw = r0.zzz + -r4.xyz;
  r0.xyz = r0.xxx * r0.yzw + r4.xyz;
  r0.xyz = r2.xyz * r0.xyz;
  r0.xyz = _SSRMultiplier.xxx * r0.xyz;
  r2.xyzw = _CameraReflectionsTexture.Sample(sampler_CameraReflectionsTexture, w1.xy).xyzw;
  r2.w = 0;
  r5.xyzw = -r2.xyzw + r1.xyzw;
  r5.xyzw = max(float4(0,0,0,0), r5.xyzw);
  r3.x = saturate(r3.x);
  r3.yzw = r0.xyz * r4.www + -r2.xyz;
  r2.xyz = r3.xxx * r3.yzw + r2.xyz;
  r0.xyz = r3.xxx * r0.xyz;
  r1.xyzw = _AdditiveReflection.xxxx ? r1.xyzw : r5.xyzw;
  r0.xyz = _AdditiveReflection.xxx ? r0.xyz : r2.xyz;
  r0.w = 0;
  o0.xyzw = r1.xyzw + r0.xyzw;
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
		vs_426fc50bff782225_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_da4376cb01176dba_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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

Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;
Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_TexelSize;
int _HighlightSuppression;
float4 _Axis;

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

// vs 426fc50bff782225: 1 retail keyword combination(s)
void vs_426fc50bff782225_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps 2f503244ffe0fe2e: 1 retail keyword combination(s)
void ps_2f503244ffe0fe2e_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, w1.xy).xyzw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xy = _Axis.xy * _MainTex_TexelSize.xy;
  r2.xyzw = r1.xyxy * float4(-8,-8,-6,-6) + w1.xyxy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r0.w = 0.0524999984 * r3.w;
  r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r2.xy).xyzw;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = saturate(dot(r0.xyz, r4.xyz));
  r1.w = r1.z * r0.w;
  r4.xyz = float3(1,1,1) + r3.xyz;
  r4.xyz = r3.xyz / r4.xyz;
  r3.xyz = _HighlightSuppression.xxx ? r4.xyz : r3.xyz;
  r4.xyzw = _MainTex.Sample(sampler_MainTex, r2.zw).xyzw;
  r2.x = 0.075000003 * r4.w;
  r5.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r2.zw).xyzw;
  r2.yzw = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = saturate(dot(r0.xyz, r2.yzw));
  r2.x = r2.x * r2.y;
  r0.w = r0.w * r1.z + r2.x;
  r2.yzw = float3(1,1,1) + r4.xyz;
  r2.yzw = r4.xyz / r2.yzw;
  r4.xyz = _HighlightSuppression.xxx ? r2.yzw : r4.xyz;
  r5.xyzw = r1.xyxy * float4(-4,-4,-2,-2) + w1.xyxy;
  r6.xyzw = _MainTex.Sample(sampler_MainTex, r5.xy).xyzw;
  r1.z = 0.109999999 * r6.w;
  r7.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r5.xy).xyzw;
  r2.yzw = r7.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = saturate(dot(r0.xyz, r2.yzw));
  r2.z = r2.y * r1.z;
  r0.w = r1.z * r2.y + r0.w;
  r7.xyz = float3(1,1,1) + r6.xyz;
  r7.xyz = r6.xyz / r7.xyz;
  r6.xyz = _HighlightSuppression.xxx ? r7.xyz : r6.xyz;
  r7.xyzw = _MainTex.Sample(sampler_MainTex, r5.zw).xyzw;
  r1.z = 0.150000006 * r7.w;
  r5.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r5.zw).xyzw;
  r5.xyz = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = saturate(dot(r0.xyz, r5.xyz));
  r2.w = r2.y * r1.z;
  r0.w = r1.z * r2.y + r0.w;
  r5.xyz = float3(1,1,1) + r7.xyz;
  r5.xyz = r7.xyz / r5.xyz;
  r7.xyz = _HighlightSuppression.xxx ? r5.xyz : r7.xyz;
  r5.xyzw = _MainTex.Sample(sampler_MainTex, w1.xy).xyzw;
  r1.z = 0.224999994 * r5.w;
  r2.y = dot(r0.xyz, r0.xyz);
  r2.y = min(1, r2.y);
  r8.x = r2.y * r1.z;
  r0.w = r1.z * r2.y + r0.w;
  r8.yzw = float3(1,1,1) + r5.xyz;
  r8.yzw = r5.xyz / r8.yzw;
  r5.xyz = _HighlightSuppression.xxx ? r8.yzw : r5.xyz;
  r8.yz = r1.xy * float2(2,2) + w1.xy;
  r9.xyzw = _MainTex.Sample(sampler_MainTex, r8.yz).xyzw;
  r1.z = 0.150000006 * r9.w;
  r10.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r8.yz).xyzw;
  r8.yzw = r10.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = saturate(dot(r0.xyz, r8.yzw));
  r8.y = r2.y * r1.z;
  r0.w = r1.z * r2.y + r0.w;
  r10.xyz = float3(1,1,1) + r9.xyz;
  r10.xyz = r9.xyz / r10.xyz;
  r9.xyz = _HighlightSuppression.xxx ? r10.xyz : r9.xyz;
  r10.xyzw = r1.xyxy * float4(4,4,6,6) + w1.xyxy;
  r11.xyzw = _MainTex.Sample(sampler_MainTex, r10.xy).xyzw;
  r1.z = 0.109999999 * r11.w;
  r12.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r10.xy).xyzw;
  r12.xyz = r12.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = saturate(dot(r0.xyz, r12.xyz));
  r8.z = r2.y * r1.z;
  r0.w = r1.z * r2.y + r0.w;
  r12.xyz = float3(1,1,1) + r11.xyz;
  r12.xyz = r11.xyz / r12.xyz;
  r11.xyz = _HighlightSuppression.xxx ? r12.xyz : r11.xyz;
  r12.xyzw = _MainTex.Sample(sampler_MainTex, r10.zw).xyzw;
  r1.z = 0.075000003 * r12.w;
  r10.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r10.zw).xyzw;
  r10.xyz = r10.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.y = saturate(dot(r0.xyz, r10.xyz));
  r8.w = r2.y * r1.z;
  r0.w = r1.z * r2.y + r0.w;
  r10.xyz = float3(1,1,1) + r12.xyz;
  r10.xyz = r12.xyz / r10.xyz;
  r12.xyz = _HighlightSuppression.xxx ? r10.xyz : r12.xyz;
  r1.xy = r1.xy * float2(8,8) + w1.xy;
  r10.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.z = 0.0524999984 * r10.w;
  r13.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r1.xy).xyzw;
  r13.xyz = r13.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = saturate(dot(r0.xyz, r13.xyz));
  r0.y = r1.z * r0.x;
  r0.x = r1.z * r0.x + r0.w;
  r1.xyz = float3(1,1,1) + r10.xyz;
  r1.xyz = r10.xyz / r1.xyz;
  r10.xyz = _HighlightSuppression.xxx ? r1.xyz : r10.xyz;
  r0.z = cmp(0.00999999978 < r0.x);
  [branch] if (r0.z != 0) {
    r13.xyzw = r4.xyzw * r2.xxxx;
    r1.xyzw = r3.xyzw * r1.wwww + r13.xyzw;
    r1.xyzw = r6.xyzw * r2.zzzz + r1.xyzw;
    r1.xyzw = r7.xyzw * r2.wwww + r1.xyzw;
    r1.xyzw = r5.xyzw * r8.xxxx + r1.xyzw;
    r1.xyzw = r9.xyzw * r8.yyyy + r1.xyzw;
    r1.xyzw = r11.xyzw * r8.zzzz + r1.xyzw;
    r1.xyzw = r12.xyzw * r8.wwww + r1.xyzw;
    r1.xyzw = r10.xyzw * r0.yyyy + r1.xyzw;
    r0.x = 1 / r0.x;
    r0.y = max(2, r0.x);
    r0.y = sqrt(r0.y);
    r0.y = r1.w * r0.y;
    o0.w = min(1, r0.y);
    r0.yzw = r1.xyz * r0.xxx;
    r1.xyz = -r1.xyz * r0.xxx + float3(1,1,1);
    r1.xyz = r0.yzw / r1.xyz;
    o0.xyz = _HighlightSuppression.xxx ? r1.xyz : r0.yzw;
    return;
  } else {
    r0.xyz = r4.xyz + r3.xyz;
    r0.xyz = r0.xyz + r6.xyz;
    r0.xyz = r0.xyz + r7.xyz;
    r0.xyz = r0.xyz + r5.xyz;
    r0.xyz = r0.xyz + r9.xyz;
    r0.xyz = r0.xyz + r11.xyz;
    r0.xyz = r0.xyz + r12.xyz;
    r0.xyz = r0.xyz + r10.xyz;
    r1.xyz = float3(0.111111112,0.111111112,0.111111112) * r0.xyz;
    r0.xyz = -r0.xyz * float3(0.111111112,0.111111112,0.111111112) + float3(1,1,1);
    r0.xyz = r1.xyz / r0.xyz;
    o0.xyz = _HighlightSuppression.xxx ? r0.xyz : r1.xyz;
    o0.w = 0;
    return;
  }
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
		vs_426fc50bff782225_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_2f503244ffe0fe2e_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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

Texture2D _CameraGBufferTexture1;
SamplerState sampler_CameraGBufferTexture1;
Texture2D _HitPointTexture;
SamplerState sampler_HitPointTexture;
Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;
Texture2D _ReflectionTexture0;
SamplerState sampler_ReflectionTexture0;
Texture2D _ReflectionTexture1;
SamplerState sampler_ReflectionTexture1;

float4 _MainTex_TexelSize;
float4 _ProjInfo;
float4x4 _WorldToCameraMatrix;
int _HalfResolution;
float _ScreenEdgeFading;
float _PixelsPerMeterAtOneMeter;

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

// vs 426fc50bff782225: 1 retail keyword combination(s)
void vs_426fc50bff782225_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps 733a4f51ed171bc5: 1 retail keyword combination(s)
void ps_733a4f51ed171bc5_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, w1.xy).xyzw;
  r0.x = 1 + -r0.z;
  r1.xyzw = _HitPointTexture.Sample(sampler_HitPointTexture, w1.xy).xyzw;
  r2.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, w1.xy).xyzw;
  r0.y = _ZBufferParams.z * r2.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r2.z = -r0.y;
  r0.yz = _MainTex_TexelSize.zw * w1.xy;
  r0.yz = r0.yz * _ProjInfo.xy + _ProjInfo.zw;
  r2.xy = r0.yz * r2.zz;
  r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, w1.xy).xyzw;
  r0.yzw = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyw = float3(_WorldToCameraMatrix[0][1], _WorldToCameraMatrix[1][1], _WorldToCameraMatrix[2][1]) * r0.zzz;
  r1.xyw = float3(_WorldToCameraMatrix[0][0], _WorldToCameraMatrix[1][0], _WorldToCameraMatrix[2][0]) * r0.yyy + r1.xyw;
  r0.yzw = float3(_WorldToCameraMatrix[0][2], _WorldToCameraMatrix[1][2], _WorldToCameraMatrix[2][2]) * r0.www + r1.xyw;
  r1.x = dot(r2.xyz, r2.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyw = r2.xyz * r1.xxx;
  r2.x = dot(r0.yzw, -r1.xyw);
  r2.x = r2.x + r2.x;
  r0.yzw = r0.yzw * r2.xxx + r1.xyw;
  r0.y = dot(r0.yzw, r0.yzw);
  r0.y = rsqrt(r0.y);
  r0.y = r0.w * r0.y;
  r0.y = r0.y * r1.z + r2.z;
  r0.z = log2(r0.x);
  r0.z = 1.33333337 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = r0.z * r1.z;
  r0.z = _PixelsPerMeterAtOneMeter * r0.z;
  r0.y = r0.z / r0.y;
  r0.z = cmp(asint(_HalfResolution) == 1);
  r0.w = 0.5 * r0.y;
  r0.y = r0.z ? r0.w : r0.y;
  r0.y = 15 + r0.y;
  r0.y = 0.0625 * r0.y;
  r0.y = log2(r0.y);
  r0.y = min(4, r0.y);
  r0.y = max(0, r0.y);
  r0.z = (int)r0.y;
  r0.w = trunc(r0.y);
  r0.y = r0.y + -r0.w;
  [branch] if (r0.z == 0) {
    r1.xyzw = _ReflectionTexture0.SampleLevel(sampler_ReflectionTexture0, w1.xy, 0).xyzw;
  } else {
    r1.xyzw = _ReflectionTexture1.SampleLevel(sampler_ReflectionTexture1, w1.xy, 0).xyzw;
  }
  r2.xyzw = _ReflectionTexture1.SampleLevel(sampler_ReflectionTexture1, w1.xy, 0).xyzw;
  r2.xyz = r2.xyz + -r1.xyz;
  o0.xyz = r0.yyy * r2.xyz + r1.xyz;
  r0.y = min(r2.w, r1.w);
  r0.y = min(1, r0.y);
  r0.zw = float2(1,1) + -w1.xy;
  r0.z = min(r0.z, r0.w);
  r0.z = min(w1.x, r0.z);
  r0.w = _ScreenEdgeFading * 0.100000001 + 0.00100000005;
  r0.z = saturate(r0.z / r0.w);
  r0.z = log2(r0.z);
  r0.z = 0.200000003 * r0.z;
  r0.z = exp2(r0.z);
  r0.y = r0.y * r0.z;
  r0.x = saturate(0.300000012 * r0.x);
  r0.x = 1 + -r0.x;
  o0.w = r0.y * r0.x;
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
		vs_426fc50bff782225_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_733a4f51ed171bc5_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
float2 _ReflectionBufferSize;
int _LastMip;

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

// vs 426fc50bff782225: 1 retail keyword combination(s)
void vs_426fc50bff782225_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps 251bef95caab6d97: 1 retail keyword combination(s)
void ps_251bef95caab6d97_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (-asint(_LastMip));
  r0.x = exp2(r0.x);
  r0.xy = _ReflectionBufferSize.xy * r0.xx;
  r0.xy = floor(r0.xy);
  r0.zw = w1.xy * r0.xy + float2(-0.5,-0.5);
  r0.xy = float2(1,1) / r0.xy;
  r0.zw = floor(r0.zw);
  r0.zw = float2(0.5,0.5) + r0.zw;
  r1.xy = r0.zw * r0.xy;
  r1.zw = r0.zw * r0.xy + r0.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r1.xw).xyzw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.zy).xyzw;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r1.xyzw = min(r3.xyzw, r1.xyzw);
  r0.xyzw = min(r2.xyzw, r0.xyzw);
  o0.xyzw = min(r1.xyzw, r0.xyzw);
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
		vs_426fc50bff782225_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_251bef95caab6d97_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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

Texture2D _HitPointTexture;
SamplerState sampler_HitPointTexture;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _CameraReflectionsTexture;
SamplerState sampler_CameraReflectionsTexture;

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

// vs 426fc50bff782225: 1 retail keyword combination(s)
void vs_426fc50bff782225_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps e49725a0805958a7: 1 retail keyword combination(s)
void ps_e49725a0805958a7_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraReflectionsTexture.Sample(sampler_CameraReflectionsTexture, w1.xy).xyzw;
  r1.xyzw = _HitPointTexture.Sample(sampler_HitPointTexture, w1.xy).xyzw;
  r0.w = cmp(0 < r1.w);
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  o0.w = r1.w;
  o0.xyz = r0.www ? r2.xyz : r0.xyz;
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
		vs_426fc50bff782225_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_e49725a0805958a7_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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

Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;
Texture2D _CameraGBufferTexture1;
SamplerState sampler_CameraGBufferTexture1;

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

// vs 426fc50bff782225: 1 retail keyword combination(s)
void vs_426fc50bff782225_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps e2f2e76346211b8b: 1 retail keyword combination(s)
void ps_e2f2e76346211b8b_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, w1.xy).xyzw;
  o0.xyz = r0.xyz;
  r0.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, w1.xy).xyzw;
  o0.w = r0.z;
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
		vs_426fc50bff782225_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_e2f2e76346211b8b_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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

Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;

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

// vs 426fc50bff782225: 1 retail keyword combination(s)
void vs_426fc50bff782225_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps 1c8ef40e0416cfdd: 1 retail keyword combination(s)
void ps_1c8ef40e0416cfdd_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, w1.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  o0.x = -r0.x;
  o0.yzw = float3(0,0,0);
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
		vs_426fc50bff782225_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_1c8ef40e0416cfdd_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
float _ReflectionBlur;
int _HighlightSuppression;

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

// vs 426fc50bff782225: 1 retail keyword combination(s)
void vs_426fc50bff782225_impl(
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
  r0.x = cmp(_MainTex_TexelSize.y < 0);
  r0.y = 1 + -v1.y;
  p1.y = r0.x ? r0.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  return;
}


// ps f4887fcb75ee90c1: 1 retail keyword combination(s)
void ps_f4887fcb75ee90c1_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { -0.326212, -0.405810, 0, 0},
                              { -0.840144, -0.073580, 0, 0},
                              { -0.695914, 0.457137, 0, 0},
                              { -0.203345, 0.620716, 0, 0},
                              { 0.962340, -0.194983, 0, 0},
                              { 0.473434, -0.480026, 0, 0},
                              { 0.519456, 0.767022, 0, 0},
                              { 0.185461, -0.893124, 0, 0},
                              { 0.507431, 0.064425, 0, 0},
                              { 0.896420, 0.412458, 0, 0},
                              { -0.321940, -0.932615, 0, 0},
                              { -0.791559, -0.597710, 0, 0} };
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ReflectionBlur * _MainTex_TexelSize.x;
  r1.xyzw = float4(0,0,0,0);
  r0.y = 0;
  [loop] while (true) {
    r0.z = cmp((int)r0.y >= 4);
    [branch] if (r0.z != 0) break;
    r0.zw = icb[r0.y+0].xy * r0.xx + w1.xy;
    r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
    r3.xyz = float3(1,1,1) + r2.xyz;
    r3.xyz = r2.xyz / r3.xyz;
    r2.xyz = _HighlightSuppression.xxx ? r3.xyz : r2.xyz;
    r1.xyzw = r2.xyzw + r1.xyzw;
    r0.y = (int)r0.y + 1;
  }
  r0.xyzw = float4(0.25,0.25,0.25,0.25) * r1.xyzw;
  r1.xyz = -r1.xyz * float3(0.25,0.25,0.25) + float3(1,1,1);
  r1.xyz = r0.xyz / r1.xyz;
  o0.xyz = _HighlightSuppression.xxx ? r1.xyz : r0.xyz;
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
		vs_426fc50bff782225_impl(v.position0, v.texcoord0.xy, o0, o1, p1);
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
		ps_f4887fcb75ee90c1_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
	Fallback "Diffuse"
}
