Shader "Hidden/BT-SunFlareReflections"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Blend One One
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _BT_SUNLIGHT_CONTROL
			#pragma multi_compile _ _SPACE

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _TransmittanceLUT;
SamplerState sampler_TransmittanceLUT;
Texture2D _ReflectionTex;
SamplerState sampler_ReflectionTex;

float4 _LightColor0;
float4 _CameraDepthTexture_TexelSize;
float3 _BT_SunlightFlare;
float4 _ReflectionProp;
float4 _ReflectionColor;
float3 _BT_SunlightDirection;
float _BT_SunlightIntensity;
float4 _BT_SunlightColor;

struct appdata
{
	float4 position0 : POSITION0;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(_BT_SUNLIGHT_CONTROL)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};
#elif defined(_BT_SUNLIGHT_CONTROL) && !defined(_SPACE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
};
#elif defined(_BT_SUNLIGHT_CONTROL) && defined(_SPACE)
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

// vs e6f94d707a34acec: 2 retail keyword combination(s)
void vs_e6f94d707a34acec_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float3 o2 : TEXCOORD1)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = -_WorldSpaceLightPos0.xyz * _ProjectionParams.zzz;
  r0.xyz = r0.xyz * float3(0.899999976,0.899999976,0.899999976) + _WorldSpaceCameraPos.xyz;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r0.xyzw;
  r1.xz = float2(0.5,0.5) * r0.xw;
  r1.y = _ProjectionParams.x * r0.y;
  r1.w = 0.5 * r1.y;
  r1.xy = r1.xw + r1.zz;
  r0.xyz = r0.xyz / r0.www;
  r1.xy = r1.xy / r0.ww;
  r0.w = _ReflectionProp.x * -3 + 1.5;
  r0.xy = r0.xy * r0.ww;
  r0.w = min(abs(r0.x), abs(r0.y));
  r1.z = max(abs(r0.x), abs(r0.y));
  r1.z = 1 / r1.z;
  r0.w = r1.z * r0.w;
  r1.z = r0.w * r0.w;
  r1.w = r1.z * 0.0208350997 + -0.0851330012;
  r1.w = r1.z * r1.w + 0.180141002;
  r1.w = r1.z * r1.w + -0.330299497;
  r1.z = r1.z * r1.w + 0.999866009;
  r1.w = r1.z * r0.w;
  r2.x = cmp(abs(r0.y) < abs(r0.x));
  r1.w = r1.w * -2 + 1.57079637;
  r1.w = r2.x ? r1.w : 0;
  r0.w = r0.w * r1.z + r1.w;
  r1.z = cmp(r0.y < -r0.y);
  r1.z = r1.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r1.z + r0.w;
  r1.z = min(r0.x, r0.y);
  r1.w = max(r0.x, r0.y);
  r1.z = cmp(r1.z < -r1.z);
  r1.w = cmp(r1.w >= -r1.w);
  r1.z = r1.w ? r1.z : 0;
  r0.w = r1.z ? -r0.w : r0.w;
  sincos(-r0.w, r2.x, r3.x);
  r4.x = -r2.x;
  r4.y = r3.x;
  r3.x = dot(r4.yx, v0.xy);
  r4.z = r2.x;
  r0.w = dot(r4.zy, v0.xy);
  r1.z = _ScreenParams.x / _ScreenParams.y;
  r3.y = r1.z * r0.w;
  r3.z = v0.z;
  o0.xyz = r3.xyz * _ReflectionProp.yyy + r0.xyz;
  o1.xy = float2(1,1) + -v1.xy;
  r2.xyz = _BT_SunlightFlare.xyz * _LightColor0.xyz;
  r2.xyz = _ReflectionColor.xyz * r2.xyz;
  r0.zw = float2(0,0);
  r1.z = -1;
  [loop] while (true) {
    r1.w = cmp(1 < (int)r1.z);
    [branch] if (r1.w != 0) break;
    r3.x = (int)r1.z;
    r3.zw = r0.zw;
    r1.w = -1;
    [loop] while (true) {
      r2.w = cmp(1 < (int)r1.w);
      [branch] if (r2.w != 0) break;
      r3.y = (int)r1.w;
      r4.xy = _CameraDepthTexture_TexelSize.xy * r3.xy + r1.xy;
      r4.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r4.xy, 0).xyzw;
      r2.w = _ZBufferParams.x * r4.x + _ZBufferParams.y;
      r2.w = 1 / r2.w;
      r2.w = cmp(0.999000013 < r2.w);
      r2.w = r2.w ? 1.000000 : 0;
      r3.z = r3.z + r2.w;
      r3.w = 1 + r3.w;
      r1.w = (int)r1.w + 1;
    }
    r0.zw = r3.zw;
    r1.z = (int)r1.z + 1;
  }
  r0.z = r0.z / r0.w;
  r2.xyz = r2.xyz * r0.zzz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = sqrt(r0.x);
  r0.x = -0.100000001 + r0.x;
  r0.x = saturate(2.5 * r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyz = r2.xyz * r0.xxx;
  r1.zw = saturate(float2(10,10) * r1.xy);
  r2.xy = r1.zw * float2(-2,-2) + float2(3,3);
  r1.zw = r1.zw * r1.zw;
  r1.zw = r2.xy * r1.zw;
  r1.xy = float2(-1,-1) + r1.xy;
  r1.xy = saturate(float2(-9.99999809,-9.99999809) * r1.xy);
  r2.xy = r1.xy * float2(-2,-2) + float2(3,3);
  r1.xy = r1.xy * r1.xy;
  r1.xy = r2.xy * r1.xy;
  r0.w = r1.z * r1.x;
  r0.w = r0.w * r1.w;
  r0.w = r0.w * r1.y;
  o2.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// vs 2dd9b0a3170a8f16: 1 retail keyword combination(s)
void vs_2dd9b0a3170a8f16_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float3 o2 : TEXCOORD1)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = _ProjectionParams.zzz * -_BT_SunlightDirection.xyz;
  r0.xyz = r0.xyz * float3(0.899999976,0.899999976,0.899999976) + _WorldSpaceCameraPos.xyz;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r0.xyzw;
  r1.xz = float2(0.5,0.5) * r0.xw;
  r1.y = _ProjectionParams.x * r0.y;
  r1.w = 0.5 * r1.y;
  r1.xy = r1.xw + r1.zz;
  r0.xyz = r0.xyz / r0.www;
  r1.xy = r1.xy / r0.ww;
  r0.w = _ReflectionProp.x * -3 + 1.5;
  r0.xy = r0.xy * r0.ww;
  r0.w = min(abs(r0.x), abs(r0.y));
  r1.z = max(abs(r0.x), abs(r0.y));
  r1.z = 1 / r1.z;
  r0.w = r1.z * r0.w;
  r1.z = r0.w * r0.w;
  r1.w = r1.z * 0.0208350997 + -0.0851330012;
  r1.w = r1.z * r1.w + 0.180141002;
  r1.w = r1.z * r1.w + -0.330299497;
  r1.z = r1.z * r1.w + 0.999866009;
  r1.w = r1.z * r0.w;
  r2.x = cmp(abs(r0.y) < abs(r0.x));
  r1.w = r1.w * -2 + 1.57079637;
  r1.w = r2.x ? r1.w : 0;
  r0.w = r0.w * r1.z + r1.w;
  r1.z = cmp(r0.y < -r0.y);
  r1.z = r1.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r1.z + r0.w;
  r1.z = min(r0.x, r0.y);
  r1.w = max(r0.x, r0.y);
  r1.z = cmp(r1.z < -r1.z);
  r1.w = cmp(r1.w >= -r1.w);
  r1.z = r1.w ? r1.z : 0;
  r0.w = r1.z ? -r0.w : r0.w;
  sincos(-r0.w, r2.x, r3.x);
  r4.x = -r2.x;
  r4.y = r3.x;
  r3.x = dot(r4.yx, v0.xy);
  r4.z = r2.x;
  r0.w = dot(r4.zy, v0.xy);
  r1.z = _ScreenParams.x / _ScreenParams.y;
  r3.y = r1.z * r0.w;
  r3.z = v0.z;
  o0.xyz = r3.xyz * _ReflectionProp.yyy + r0.xyz;
  o1.xy = float2(1,1) + -v1.xy;
  r2.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r0.z = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.z = rsqrt(r0.z);
  r0.z = _BT_SunlightDirection.y * r0.z;
  r3.x = r0.z * 0.5 + 0.5;
  r3.y = 0;
  r3.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r3.xy, 0).xyzw;
  r2.xyz = r3.www * r2.xyz;
  r2.xyz = r2.xyz * r3.xyz;
  r2.xyz = _BT_SunlightFlare.xyz * r2.xyz;
  r2.xyz = _ReflectionColor.xyz * r2.xyz;
  r0.zw = float2(0,0);
  r1.z = -1;
  [loop] while (true) {
    r1.w = cmp(1 < (int)r1.z);
    [branch] if (r1.w != 0) break;
    r3.x = (int)r1.z;
    r3.zw = r0.zw;
    r1.w = -1;
    [loop] while (true) {
      r2.w = cmp(1 < (int)r1.w);
      [branch] if (r2.w != 0) break;
      r3.y = (int)r1.w;
      r4.xy = _CameraDepthTexture_TexelSize.xy * r3.xy + r1.xy;
      r4.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r4.xy, 0).xyzw;
      r2.w = _ZBufferParams.x * r4.x + _ZBufferParams.y;
      r2.w = 1 / r2.w;
      r2.w = cmp(0.999000013 < r2.w);
      r2.w = r2.w ? 1.000000 : 0;
      r3.z = r3.z + r2.w;
      r3.w = 1 + r3.w;
      r1.w = (int)r1.w + 1;
    }
    r0.zw = r3.zw;
    r1.z = (int)r1.z + 1;
  }
  r0.z = r0.z / r0.w;
  r2.xyz = r2.xyz * r0.zzz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = sqrt(r0.x);
  r0.x = -0.100000001 + r0.x;
  r0.x = saturate(2.5 * r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyz = r2.xyz * r0.xxx;
  r1.zw = saturate(float2(10,10) * r1.xy);
  r2.xy = r1.zw * float2(-2,-2) + float2(3,3);
  r1.zw = r1.zw * r1.zw;
  r1.zw = r2.xy * r1.zw;
  r1.xy = float2(-1,-1) + r1.xy;
  r1.xy = saturate(float2(-9.99999809,-9.99999809) * r1.xy);
  r2.xy = r1.xy * float2(-2,-2) + float2(3,3);
  r1.xy = r1.xy * r1.xy;
  r1.xy = r2.xy * r1.xy;
  r0.w = r1.z * r1.x;
  r0.w = r0.w * r1.w;
  r0.w = r0.w * r1.y;
  o2.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// vs 5954ed26102dcb1f: 1 retail keyword combination(s)
void vs_5954ed26102dcb1f_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float3 o2 : TEXCOORD1)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = _ProjectionParams.zzz * -_BT_SunlightDirection.xyz;
  r0.xyz = r0.xyz * float3(0.899999976,0.899999976,0.899999976) + _WorldSpaceCameraPos.xyz;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r0.xyzw;
  r1.xz = float2(0.5,0.5) * r0.xw;
  r1.y = _ProjectionParams.x * r0.y;
  r1.w = 0.5 * r1.y;
  r1.xy = r1.xw + r1.zz;
  r0.xyz = r0.xyz / r0.www;
  r1.xy = r1.xy / r0.ww;
  r0.w = _ReflectionProp.x * -3 + 1.5;
  r0.xy = r0.xy * r0.ww;
  r0.w = min(abs(r0.x), abs(r0.y));
  r1.z = max(abs(r0.x), abs(r0.y));
  r1.z = 1 / r1.z;
  r0.w = r1.z * r0.w;
  r1.z = r0.w * r0.w;
  r1.w = r1.z * 0.0208350997 + -0.0851330012;
  r1.w = r1.z * r1.w + 0.180141002;
  r1.w = r1.z * r1.w + -0.330299497;
  r1.z = r1.z * r1.w + 0.999866009;
  r1.w = r1.z * r0.w;
  r2.x = cmp(abs(r0.y) < abs(r0.x));
  r1.w = r1.w * -2 + 1.57079637;
  r1.w = r2.x ? r1.w : 0;
  r0.w = r0.w * r1.z + r1.w;
  r1.z = cmp(r0.y < -r0.y);
  r1.z = r1.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r1.z + r0.w;
  r1.z = min(r0.x, r0.y);
  r1.w = max(r0.x, r0.y);
  r1.z = cmp(r1.z < -r1.z);
  r1.w = cmp(r1.w >= -r1.w);
  r1.z = r1.w ? r1.z : 0;
  r0.w = r1.z ? -r0.w : r0.w;
  sincos(-r0.w, r2.x, r3.x);
  r4.x = -r2.x;
  r4.y = r3.x;
  r3.x = dot(r4.yx, v0.xy);
  r4.z = r2.x;
  r0.w = dot(r4.zy, v0.xy);
  r1.z = _ScreenParams.x / _ScreenParams.y;
  r3.y = r1.z * r0.w;
  r3.z = v0.z;
  o0.xyz = r3.xyz * _ReflectionProp.yyy + r0.xyz;
  o1.xy = float2(1,1) + -v1.xy;
  r2.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r2.xyz = _BT_SunlightFlare.xyz * r2.xyz;
  r2.xyz = _ReflectionColor.xyz * r2.xyz;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r0.zw = float2(0,0);
  r1.z = -1;
  [loop] while (true) {
    r1.w = cmp(1 < (int)r1.z);
    [branch] if (r1.w != 0) break;
    r3.x = (int)r1.z;
    r3.zw = r0.zw;
    r1.w = -1;
    [loop] while (true) {
      r2.w = cmp(1 < (int)r1.w);
      [branch] if (r2.w != 0) break;
      r3.y = (int)r1.w;
      r4.xy = _CameraDepthTexture_TexelSize.xy * r3.xy + r1.xy;
      r4.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r4.xy, 0).xyzw;
      r2.w = _ZBufferParams.x * r4.x + _ZBufferParams.y;
      r2.w = 1 / r2.w;
      r2.w = cmp(0.999000013 < r2.w);
      r2.w = r2.w ? 1.000000 : 0;
      r3.z = r3.z + r2.w;
      r3.w = 1 + r3.w;
      r1.w = (int)r1.w + 1;
    }
    r0.zw = r3.zw;
    r1.z = (int)r1.z + 1;
  }
  r0.z = r0.z / r0.w;
  r2.xyz = r2.xyz * r0.zzz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = sqrt(r0.x);
  r0.x = -0.100000001 + r0.x;
  r0.x = saturate(2.5 * r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyz = r2.xyz * r0.xxx;
  r1.zw = saturate(float2(10,10) * r1.xy);
  r2.xy = r1.zw * float2(-2,-2) + float2(3,3);
  r1.zw = r1.zw * r1.zw;
  r1.zw = r2.xy * r1.zw;
  r1.xy = float2(-1,-1) + r1.xy;
  r1.xy = saturate(float2(-9.99999809,-9.99999809) * r1.xy);
  r2.xy = r1.xy * float2(-2,-2) + float2(3,3);
  r1.xy = r1.xy * r1.xy;
  r1.xy = r2.xy * r1.xy;
  r0.w = r1.z * r1.x;
  r0.w = r0.w * r1.w;
  r0.w = r0.w * r1.y;
  o2.xyz = r0.xyz * r0.www;
  o0.w = 1;
  return;
}


// ps 19b5f71afae85c9f: 4 retail keyword combination(s)
void ps_19b5f71afae85c9f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _ReflectionTex.SampleLevel(sampler_ReflectionTex, v1.xy, _ReflectionProp.w).xyzw;
  r1.xyz = v2.xyz * r0.zzz;
  r2.xyz = v2.xyz * r0.www;
  r3.xyz = cmp(_ReflectionProp.zzz < float3(1,2,3));
  r1.xyz = r3.zzz ? r1.xyz : r2.xyz;
  r0.yzw = v2.xyz * r0.yyy;
  r2.xyz = v2.xyz * r0.xxx;
  r0.xyz = r3.yyy ? r0.yzw : r1.xyz;
  o0.xyz = r3.xxx ? r2.xyz : r0.xyz;
  o0.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(_BT_SUNLIGHT_CONTROL)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float3 o2 = 0;
		vs_e6f94d707a34acec_impl(v.position0, v.texcoord0.xy, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1.xyz = o2;
	}
#elif defined(_BT_SUNLIGHT_CONTROL) && !defined(_SPACE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float3 o2 = 0;
		vs_2dd9b0a3170a8f16_impl(v.position0, v.texcoord0.xy, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1.xyz = o2;
	}
#elif defined(_BT_SUNLIGHT_CONTROL) && defined(_SPACE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float3 o2 = 0;
		vs_5954ed26102dcb1f_impl(v.position0, v.texcoord0.xy, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1.xyz = o2;
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
		ps_19b5f71afae85c9f_impl(i.sv_position, i.texcoord0, i.texcoord1.xyz, o0);
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
