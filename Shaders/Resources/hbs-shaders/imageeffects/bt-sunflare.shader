Shader "Hidden/BT-SunFlare"
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
Texture2D _SunburstTex;
SamplerState sampler_SunburstTex;
Texture2D _TransmittanceLUT;
SamplerState sampler_TransmittanceLUT;
Texture2D _StreakTex;
SamplerState sampler_StreakTex;

float4 _CameraDepthTexture_TexelSize;
float3 _BT_SunlightDirection;
float3 _StreakColor;
float3 _CoreColor;
float3 _BT_SunlightFlare;
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
	float4 texcoord2 : TEXCOORD2;
};
#elif defined(_BT_SUNLIGHT_CONTROL) && defined(_SPACE)
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

// vs f34f7f1f69a19899: 2 retail keyword combination(s)
void vs_f34f7f1f69a19899_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float2 o2 : TEXCOORD1)
{
  float4 r0,r1,r2,r3;
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
  r0.w = _ScreenParams.x / _ScreenParams.y;
  r2.y = v0.y * r0.w;
  r3.xyzw = float4(-0.5,-0.5,-1,-1) + r1.xyxy;
  r0.w = dot(r3.xy, r3.xy);
  r0.w = rsqrt(r0.w);
  o2.xy = r3.yx * r0.ww;
  r1.zw = saturate(float2(20,20) * r1.xy);
  r2.zw = r1.zw * float2(-2,-2) + float2(3,3);
  r1.zw = r1.zw * r1.zw;
  r1.zw = r2.zw * r1.zw;
  r2.zw = saturate(float2(-19.9999962,-19.9999962) * r3.zw);
  r3.xy = r2.zw * float2(-2,-2) + float2(3,3);
  r2.zw = r2.zw * r2.zw;
  r2.zw = r3.xy * r2.zw;
  r0.w = r2.z * r1.z;
  r0.w = r0.w * r1.w;
  r0.w = r0.w * r2.w;
  r1.z = r0.w * -2 + 4;
  r2.xz = v0.xz;
  r2.xy = r2.xy * r1.zz;
  o0.xyz = r2.xyz + r0.xyz;
  r0.xy = float2(0,-1);
  [loop] while (true) {
    r0.z = cmp(1 < (int)r0.y);
    [branch] if (r0.z != 0) break;
    r2.x = (int)r0.y;
    r0.z = r0.x;
    r1.z = -1;
    [loop] while (true) {
      r1.w = cmp(1 < (int)r1.z);
      [branch] if (r1.w != 0) break;
      r2.y = (int)r1.z;
      r2.yz = _CameraDepthTexture_TexelSize.xy * r2.xy + r1.xy;
      r3.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r2.yz, 0).xyzw;
      r1.w = _ZBufferParams.x * r3.x + _ZBufferParams.y;
      r1.w = 1 / r1.w;
      r1.w = cmp(0.999000013 < r1.w);
      r1.w = r1.w ? 1.000000 : 0;
      r0.z = r1.w + r0.z;
      r1.z = (int)r1.z + 1;
    }
    r0.x = r0.z;
    r0.y = (int)r0.y + 1;
  }
  r0.x = r0.x * r0.w;
  o1.z = 0.111111112 * r0.x;
  o0.w = 1;
  o1.xy = v1.xy;
  return;
}


// vs 5de1cdffff9a6596: 1 retail keyword combination(s)
void vs_5de1cdffff9a6596_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2)
{
  float4 r0,r1,r2,r3;
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
  r0.w = _ScreenParams.x / _ScreenParams.y;
  r2.y = v0.y * r0.w;
  r3.xyzw = float4(-0.5,-0.5,-1,-1) + r1.xyxy;
  r0.w = dot(r3.xy, r3.xy);
  r0.w = rsqrt(r0.w);
  o2.xy = r3.yx * r0.ww;
  r1.zw = saturate(float2(20,20) * r1.xy);
  r2.zw = r1.zw * float2(-2,-2) + float2(3,3);
  r1.zw = r1.zw * r1.zw;
  r1.zw = r2.zw * r1.zw;
  r2.zw = saturate(float2(-19.9999962,-19.9999962) * r3.zw);
  r3.xy = r2.zw * float2(-2,-2) + float2(3,3);
  r2.zw = r2.zw * r2.zw;
  r2.zw = r3.xy * r2.zw;
  r0.w = r2.z * r1.z;
  r0.w = r0.w * r1.w;
  r0.w = r0.w * r2.w;
  r1.z = r0.w * -2 + 4;
  r2.xz = v0.xz;
  r2.xy = r2.xy * r1.zz;
  o0.xyz = r2.xyz + r0.xyz;
  r0.xy = float2(0,-1);
  [loop] while (true) {
    r0.z = cmp(1 < (int)r0.y);
    [branch] if (r0.z != 0) break;
    r2.x = (int)r0.y;
    r0.z = r0.x;
    r1.z = -1;
    [loop] while (true) {
      r1.w = cmp(1 < (int)r1.z);
      [branch] if (r1.w != 0) break;
      r2.y = (int)r1.z;
      r2.yz = _CameraDepthTexture_TexelSize.xy * r2.xy + r1.xy;
      r3.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r2.yz, 0).xyzw;
      r1.w = _ZBufferParams.x * r3.x + _ZBufferParams.y;
      r1.w = 1 / r1.w;
      r1.w = cmp(0.999000013 < r1.w);
      r1.w = r1.w ? 1.000000 : 0;
      r0.z = r1.w + r0.z;
      r1.z = (int)r1.z + 1;
    }
    r0.x = r0.z;
    r0.y = (int)r0.y + 1;
  }
  r0.x = r0.x * r0.w;
  o1.z = 0.111111112 * r0.x;
  r0.x = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.x = rsqrt(r0.x);
  r0.x = _BT_SunlightDirection.y * r0.x;
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 0;
  o3.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r0.xy, 0).xyzw;
  o0.w = 1;
  o1.xy = v1.xy;
  return;
}


// vs 1b53615338442148: 1 retail keyword combination(s)
void vs_1b53615338442148_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2)
{
  float4 r0,r1,r2,r3;
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
  r0.w = _ScreenParams.x / _ScreenParams.y;
  r2.y = v0.y * r0.w;
  r3.xyzw = float4(-0.5,-0.5,-1,-1) + r1.xyxy;
  r0.w = dot(r3.xy, r3.xy);
  r0.w = rsqrt(r0.w);
  o2.xy = r3.yx * r0.ww;
  r1.zw = saturate(float2(20,20) * r1.xy);
  r2.zw = r1.zw * float2(-2,-2) + float2(3,3);
  r1.zw = r1.zw * r1.zw;
  r1.zw = r2.zw * r1.zw;
  r2.zw = saturate(float2(-19.9999962,-19.9999962) * r3.zw);
  r3.xy = r2.zw * float2(-2,-2) + float2(3,3);
  r2.zw = r2.zw * r2.zw;
  r2.zw = r3.xy * r2.zw;
  r0.w = r2.z * r1.z;
  r0.w = r0.w * r1.w;
  r0.w = r0.w * r2.w;
  r1.z = r0.w * -2 + 4;
  r2.xz = v0.xz;
  r2.xy = r2.xy * r1.zz;
  o0.xyz = r2.xyz + r0.xyz;
  r0.xy = float2(0,-1);
  [loop] while (true) {
    r0.z = cmp(1 < (int)r0.y);
    [branch] if (r0.z != 0) break;
    r2.x = (int)r0.y;
    r0.z = r0.x;
    r1.z = -1;
    [loop] while (true) {
      r1.w = cmp(1 < (int)r1.z);
      [branch] if (r1.w != 0) break;
      r2.y = (int)r1.z;
      r2.yz = _CameraDepthTexture_TexelSize.xy * r2.xy + r1.xy;
      r3.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r2.yz, 0).xyzw;
      r1.w = _ZBufferParams.x * r3.x + _ZBufferParams.y;
      r1.w = 1 / r1.w;
      r1.w = cmp(0.999000013 < r1.w);
      r1.w = r1.w ? 1.000000 : 0;
      r0.z = r1.w + r0.z;
      r1.z = (int)r1.z + 1;
    }
    r0.x = r0.z;
    r0.y = (int)r0.y + 1;
  }
  r0.x = r0.x * r0.w;
  o1.z = 0.111111112 * r0.x;
  o0.w = 1;
  o3.xyzw = float4(1,1,1,1);
  o1.xy = v1.xy;
  return;
}


// ps 3aad9d21fd56616a: 2 retail keyword combination(s)
void ps_3aad9d21fd56616a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float2 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = v1.xyxy * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r0.xy = float2(2.5,2.5) * r0.xy;
  r0.zw = r0.zw * float2(0.5,0.5) + float2(0.5,0.5);
  r1.xyzw = _StreakTex.SampleLevel(sampler_StreakTex, r0.zw, 0).xyzw;
  r0.z = 0.5 * r1.x;
  r1.xyz = _StreakColor.xyz * r0.zzz;
  r0.z = v2.y * r0.y;
  r2.x = r0.x * v2.x + -r0.z;
  r2.y = dot(r0.yx, v2.xy);
  r0.xy = r2.xy * float2(0.5,0.5) + float2(0.5,0.5);
  r0.xyzw = _SunburstTex.SampleLevel(sampler_SunburstTex, r0.xy, 0).xyzw;
  r0.xyz = r0.xxx * _CoreColor.xyz + r1.xyz;
  o0.xyz = v1.zzz * r0.xyz;
  o0.w = 0;
  return;
}


// ps d6cbbcca9d6cab11: 2 retail keyword combination(s)
void ps_d6cbbcca9d6cab11_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = v1.xyxy * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r0.xy = float2(2.5,2.5) * r0.xy;
  r0.zw = r0.zw * float2(0.5,0.5) + float2(0.5,0.5);
  r1.xyzw = _StreakTex.SampleLevel(sampler_StreakTex, r0.zw, 0).xyzw;
  r0.z = 0.5 * r1.x;
  r1.xyz = _StreakColor.xyz * r0.zzz;
  r0.z = v2.y * r0.y;
  r2.x = r0.x * v2.x + -r0.z;
  r2.y = dot(r0.yx, v2.xy);
  r0.xy = r2.xy * float2(0.5,0.5) + float2(0.5,0.5);
  r0.xyzw = _SunburstTex.SampleLevel(sampler_SunburstTex, r0.xy, 0).xyzw;
  r0.xyz = r0.xxx * _CoreColor.xyz + r1.xyz;
  r1.xyz = _BT_SunlightColor.xyz * v3.xyz;
  r1.xyz = v3.www * r1.xyz;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r0.xyz = _BT_SunlightFlare.xyz * r0.xyz;
  r0.xyz = v1.zzz * r0.xyz;
  o0.xyz = float3(0.25,0.25,0.25) * r0.xyz;
  o0.w = 0;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(_BT_SUNLIGHT_CONTROL)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		vs_f34f7f1f69a19899_impl(v.position0, v.texcoord0.xy, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1.xy = o2;
	}
#elif defined(_BT_SUNLIGHT_CONTROL) && !defined(_SPACE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		vs_5de1cdffff9a6596_impl(v.position0, v.texcoord0.xy, o0, o1, o2, o3);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
	}
#elif defined(_BT_SUNLIGHT_CONTROL) && defined(_SPACE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		vs_1b53615338442148_impl(v.position0, v.texcoord0.xy, o0, o1, o2, o3);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_BT_SUNLIGHT_CONTROL)
	{
		float4 o0 = 0;
		ps_3aad9d21fd56616a_impl(i.sv_position, i.texcoord0, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SUNLIGHT_CONTROL)
	{
		float4 o0 = 0;
		ps_d6cbbcca9d6cab11_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
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
