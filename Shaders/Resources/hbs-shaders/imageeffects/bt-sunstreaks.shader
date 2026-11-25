Shader "Hidden/BT-SunStreaks"
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
			#pragma multi_compile _ _BT_SUNLIGHT_CONTROL
			#pragma multi_compile _ _SPACE

#define cmp -

Texture2D _TransmittanceLUT;
SamplerState sampler_TransmittanceLUT;
Texture2D _ScatteringDepth;
SamplerState sampler_ScatteringDepth;
Texture2D _ScatteringTex;
SamplerState sampler_ScatteringTex;

float4 _LightColor0;
float4 _ScatteringProps;
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
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(_BT_SUNLIGHT_CONTROL) && !defined(_SPACE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(_BT_SUNLIGHT_CONTROL) && defined(_SPACE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
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

// vs 295e6ee92c08adf8: 2 retail keyword combination(s)
void vs_295e6ee92c08adf8_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ScreenParams.x / _ScreenParams.y;
  r0.y = v0.y * r0.x;
  r1.xyz = -_WorldSpaceLightPos0.xyz * _ProjectionParams.zzz;
  r1.xyz = r1.xyz * float3(0.899999976,0.899999976,0.899999976) + _WorldSpaceCameraPos.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r1.xyzw;
  r2.xyz = r1.xyz / r1.www;
  r0.xz = v0.xz;
  r0.xyz = r0.xyz * _ScatteringProps.xxx + r2.xyz;
  o0.xyz = r0.xyz;
  o0.w = 1;
  o1.xy = v1.xy;
  o2.xyz = _LightColor0.xyz;
  o3.z = r0.z;
  r2.x = 0.5;
  r2.y = _ProjectionParams.x;
  r0.xy = r2.xy * r0.xy;
  r2.xyz = r2.xyx * r1.xyw;
  o4.zw = r1.zw;
  r0.z = 0.5 * r0.y;
  o3.xy = float2(0.5,0.5) + r0.xz;
  o3.w = 1;
  r2.w = 0.5 * r2.y;
  o4.xy = r2.xw + r2.zz;
  return;
}


// vs 34c43637829af90f: 1 retail keyword combination(s)
void vs_34c43637829af90f_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ScreenParams.x / _ScreenParams.y;
  r0.y = v0.y * r0.x;
  r1.xyz = _ProjectionParams.zzz * -_BT_SunlightDirection.xyz;
  r1.xyz = r1.xyz * float3(0.899999976,0.899999976,0.899999976) + _WorldSpaceCameraPos.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r1.xyzw;
  r2.xyz = r1.xyz / r1.www;
  r0.xz = v0.xz;
  r0.xyz = r0.xyz * _ScatteringProps.xxx + r2.xyz;
  o0.xyz = r0.xyz;
  o0.w = 1;
  o1.xy = v1.xy;
  r2.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  r2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  r0.w = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.w = rsqrt(r0.w);
  r0.w = _BT_SunlightDirection.y * r0.w;
  r3.z = r0.w * 0.5 + 0.5;
  r3.xw = float2(0.5,0);
  r4.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r3.zw, 0).xyzw;
  r2.xyz = r4.www * r2.xyz;
  o2.xyz = r2.xyz * r4.xyz;
  o3.z = r0.z;
  r3.y = _ProjectionParams.x;
  r0.xy = r3.xy * r0.xy;
  r2.xyz = r3.xyx * r1.xyw;
  o4.zw = r1.zw;
  r0.z = 0.5 * r0.y;
  o3.xy = float2(0.5,0.5) + r0.xz;
  o3.w = 1;
  r2.w = 0.5 * r2.y;
  o4.xy = r2.xw + r2.zz;
  return;
}


// vs 80fc04e8c5e55295: 1 retail keyword combination(s)
void vs_80fc04e8c5e55295_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _ScreenParams.x / _ScreenParams.y;
  r0.y = v0.y * r0.x;
  r1.xyz = _ProjectionParams.zzz * -_BT_SunlightDirection.xyz;
  r1.xyz = r1.xyz * float3(0.899999976,0.899999976,0.899999976) + _WorldSpaceCameraPos.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r1.xyzw;
  r2.xyz = r1.xyz / r1.www;
  r0.xz = v0.xz;
  r0.xyz = r0.xyz * _ScatteringProps.xxx + r2.xyz;
  o0.xyz = r0.xyz;
  o0.w = 1;
  o1.xy = v1.xy;
  r2.xyz = _BT_SunlightColor.xyz * _BT_SunlightIntensity.xxx;
  o2.xyz = float3(0.25,0.25,0.25) * r2.xyz;
  o3.z = r0.z;
  r2.x = 0.5;
  r2.y = _ProjectionParams.x;
  r0.xy = r2.xy * r0.xy;
  r2.xyz = r2.xyx * r1.xyw;
  o4.zw = r1.zw;
  r0.z = 0.5 * r0.y;
  o3.xy = float2(0.5,0.5) + r0.xz;
  o3.w = 1;
  r2.w = 0.5 * r2.y;
  o4.xy = r2.xw + r2.zz;
  return;
}


// ps 697e752c5d3cf794: 4 retail keyword combination(s)
void ps_697e752c5d3cf794_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _ScatteringDepth.Sample(sampler_ScatteringDepth, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.x = cmp(r0.x < 0.25);
  [branch] if (r0.x != 0) {
    o0.xyzw = float4(0,0,0,1);
    return;
  }
  r0.xyzw = _ScatteringTex.Sample(sampler_ScatteringTex, v1.xy).xyzw;
  o0.xyz = v2.xyz * r0.xyz;
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
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		vs_295e6ee92c08adf8_impl(v.position0, v.texcoord0.xy, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
	}
#elif defined(_BT_SUNLIGHT_CONTROL) && !defined(_SPACE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		vs_34c43637829af90f_impl(v.position0, v.texcoord0.xy, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
	}
#elif defined(_BT_SUNLIGHT_CONTROL) && defined(_SPACE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		vs_80fc04e8c5e55295_impl(v.position0, v.texcoord0.xy, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
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
		ps_697e752c5d3cf794_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
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
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _BT_SUNLIGHT_CONTROL
			#pragma multi_compile _ _LIGHTQUAL_HIGH
			#pragma multi_compile _ _LIGHTQUAL_LOW
			#pragma multi_compile _ _LIGHTQUAL_MED

#define cmp -

Texture2D _ScatteringRT0;
SamplerState sampler_ScatteringRT0;

float3 _BT_SunlightDirection;
float3 _ScatteringColor;
float4 _ScatteringProps;

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
};
#elif defined(_BT_SUNLIGHT_CONTROL)
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

// vs a9cc6a275a512855: 3 retail keyword combination(s)
void vs_a9cc6a275a512855_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = float2(2,2) * v0.xy;
  o0.zw = float2(0.100000001,1);
  r0.xyz = _WorldSpaceLightPos0.xyz * _ProjectionParams.zzz;
  r0.xyz = r0.xyz * float3(0.899999976,0.899999976,0.899999976) + _WorldSpaceCameraPos.xyz;
  r1.xyz = float3(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[3][1]) * r0.yyy;
  r0.xyw = float3(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[3][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[3][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[3][3]) + r0.xyz;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xzy;
  r0.xy = r1.xw + r1.zz;
  o1.zw = r0.xy / r0.zz;
  o1.xy = v1.xy * float2(1,-1) + float2(0,1);
  return;
}


// vs 2b120816f430f840: 3 retail keyword combination(s)
void vs_2b120816f430f840_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = float2(2,2) * v0.xy;
  o0.zw = float2(0.100000001,1);
  r0.xyz = _ProjectionParams.zzz * -_BT_SunlightDirection.xyz;
  r0.xyz = r0.xyz * float3(0.899999976,0.899999976,0.899999976) + _WorldSpaceCameraPos.xyz;
  r1.xyz = float3(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[3][1]) * r0.yyy;
  r0.xyw = float3(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[3][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[3][2]) * r0.zzz + r0.xyw;
  r0.xyz = float3(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[3][3]) + r0.xyz;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xzy;
  r0.xy = r1.xw + r1.zz;
  o1.zw = r0.xy / r0.zz;
  o1.xy = v1.xy * float2(1,-1) + float2(0,1);
  return;
}


// ps b5932a85e4572d40: 2 retail keyword combination(s)
void ps_b5932a85e4572d40_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.zw + -v1.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.w = rsqrt(r0.z);
  r0.xy = r0.xy * r0.ww;
  r0.z = sqrt(r0.z);
  r1.xyzw = float4(0,0,0,0);
  r2.xy = v1.xy;
  r0.w = 0;
  r2.z = 0;
  [loop] while (true) {
    r2.w = cmp((int)r2.z >= 32);
    [branch] if (r2.w != 0) break;
    r2.w = (int)r2.z;
    r3.x = _ScatteringProps.y * r2.w;
    r3.x = cmp(r0.z < r3.x);
    [branch] if (r3.x != 0) {
      break;
    }
    r2.w = 32 + -r2.w;
    r2.w = 0.03125 * r2.w;
    r3.xyzw = _ScatteringRT0.SampleLevel(sampler_ScatteringRT0, r2.xy, 0).xyzw;
    r1.xyzw = r3.xyzw * r2.wwww + r1.xyzw;
    r2.xy = r0.xy * _ScatteringProps.yy + r2.xy;
    r0.w = 1 + r0.w;
    r2.z = (int)r2.z + 1;
  }
  r0.x = 32 / r0.w;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xyzw = _ScatteringRT0.Sample(sampler_ScatteringRT0, v1.xy).xyzw;
  r0.xyzw = r0.xyzw * _ScatteringProps.zzzz + r1.xyzw;
  o0.xyz = _ScatteringColor.xyz * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps bf141e82d00dfdb1: 2 retail keyword combination(s)
void ps_bf141e82d00dfdb1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.zw + -v1.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.w = rsqrt(r0.z);
  r0.xy = r0.xy * r0.ww;
  r0.z = sqrt(r0.z);
  r1.xyzw = float4(0,0,0,0);
  r2.xy = v1.xy;
  r0.w = 0;
  r2.z = 0;
  [loop] while (true) {
    r2.w = cmp((int)r2.z >= 24);
    [branch] if (r2.w != 0) break;
    r2.w = (int)r2.z;
    r3.x = _ScatteringProps.y * r2.w;
    r3.x = cmp(r0.z < r3.x);
    [branch] if (r3.x != 0) {
      break;
    }
    r2.w = 24 + -r2.w;
    r2.w = 0.0416666679 * r2.w;
    r3.xyzw = _ScatteringRT0.SampleLevel(sampler_ScatteringRT0, r2.xy, 0).xyzw;
    r1.xyzw = r3.xyzw * r2.wwww + r1.xyzw;
    r2.xy = r0.xy * _ScatteringProps.yy + r2.xy;
    r0.w = 1 + r0.w;
    r2.z = (int)r2.z + 1;
  }
  r0.x = 24 / r0.w;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xyzw = _ScatteringRT0.Sample(sampler_ScatteringRT0, v1.xy).xyzw;
  r0.xyzw = r0.xyzw * _ScatteringProps.zzzz + r1.xyzw;
  o0.xyz = _ScatteringColor.xyz * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 3c5241e72085c759: 2 retail keyword combination(s)
void ps_3c5241e72085c759_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.zw + -v1.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.w = rsqrt(r0.z);
  r0.xy = r0.xy * r0.ww;
  r0.z = sqrt(r0.z);
  r1.xyzw = float4(0,0,0,0);
  r2.xy = v1.xy;
  r0.w = 0;
  r2.z = 0;
  [loop] while (true) {
    r2.w = cmp((int)r2.z >= 16);
    [branch] if (r2.w != 0) break;
    r2.w = (int)r2.z;
    r3.x = _ScatteringProps.y * r2.w;
    r3.x = cmp(r0.z < r3.x);
    [branch] if (r3.x != 0) {
      break;
    }
    r2.w = 16 + -r2.w;
    r2.w = 0.0625 * r2.w;
    r3.xyzw = _ScatteringRT0.SampleLevel(sampler_ScatteringRT0, r2.xy, 0).xyzw;
    r1.xyzw = r3.xyzw * r2.wwww + r1.xyzw;
    r2.xy = r0.xy * _ScatteringProps.yy + r2.xy;
    r0.w = 1 + r0.w;
    r2.z = (int)r2.z + 1;
  }
  r0.x = 16 / r0.w;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xyzw = _ScatteringRT0.Sample(sampler_ScatteringRT0, v1.xy).xyzw;
  r0.xyzw = r0.xyzw * _ScatteringProps.zzzz + r1.xyzw;
  o0.xyz = _ScatteringColor.xyz * r0.xyz;
  o0.w = r0.w;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(_BT_SUNLIGHT_CONTROL)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		vs_a9cc6a275a512855_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.sv_position = o0;
		o.texcoord0 = o1;
	}
#elif defined(_BT_SUNLIGHT_CONTROL)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		vs_2b120816f430f840_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.sv_position = o0;
		o.texcoord0 = o1;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_LIGHTQUAL_LOW) && !defined(_LIGHTQUAL_MED)
	{
		float4 o0 = 0;
		ps_b5932a85e4572d40_impl(i.sv_position, i.texcoord0, o0);
		r.t0 = o0;
	}
#elif defined(_LIGHTQUAL_MED)
	{
		float4 o0 = 0;
		ps_bf141e82d00dfdb1_impl(i.sv_position, i.texcoord0, o0);
		r.t0 = o0;
	}
#elif defined(_LIGHTQUAL_LOW)
	{
		float4 o0 = 0;
		ps_3c5241e72085c759_impl(i.sv_position, i.texcoord0, o0);
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
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _ScatteringDepth;
SamplerState sampler_ScatteringDepth;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;


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

// vs c092b87cfad70f19: 1 retail keyword combination(s)
void vs_c092b87cfad70f19_impl(
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
  o1.xy = v1.xy;
  return;
}


// ps a798565592eca096: 1 retail keyword combination(s)
void ps_a798565592eca096_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _ScatteringDepth.Gather(sampler_ScatteringDepth, v1.xy).xyzw;
  r0.xyzw = _ZBufferParams.xxxx * r0.xyzw + _ZBufferParams.yyyy;
  r0.xyzw = float4(1,1,1,1) / r0.xyzw;
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.xy).x;
  r1.x = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyzw = -r1.xxxx + r0.xyzw;
  r1.xyzw = cmp(abs(r0.xyzw) < float4(0.25,0.25,0.25,0.25));
  r1.x = r1.y ? r1.x : 0;
  r1.x = r1.z ? r1.x : 0;
  r1.x = r1.w ? r1.x : 0;
  [branch] if (r1.x != 0) {
    o0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
    return;
  }
  r1.xyzw = _MainTex.Gather(sampler_MainTex, v1.xy).xyzw;
  r2.xyzw = _MainTex.GatherGreen(sampler_MainTex, v1.xy).xyzw;
  r3.xyzw = _MainTex.GatherBlue(sampler_MainTex, v1.xy).xyzw;
  r4.xyz = cmp(abs(r0.xxx) < abs(r0.yzw));
  r0.x = r4.y ? r4.x : 0;
  r0.x = r4.z ? r0.x : 0;
  [branch] if (r0.x != 0) {
    o0.x = r1.x;
    o0.y = r2.x;
    o0.z = r3.x;
    o0.w = 1;
    return;
  } else {
    r0.xy = cmp(abs(r0.yy) < abs(r0.zw));
    r0.x = r0.y ? r0.x : 0;
    [branch] if (r0.x != 0) {
      o0.x = r1.y;
      o0.y = r2.y;
      o0.z = r3.y;
      o0.w = 1;
      return;
    } else {
      r0.x = cmp(abs(r0.z) < abs(r0.w));
      [branch] if (r0.x != 0) {
        o0.x = r1.z;
        o0.y = r2.z;
        o0.z = r3.z;
        o0.w = 1;
        return;
      } else {
        o0.x = r1.w;
        o0.y = r2.w;
        o0.z = r3.w;
        o0.w = 1;
        return;
      }
    }
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
		vs_c092b87cfad70f19_impl(v.position0, v.texcoord0.xy, o0, o1);
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
		ps_a798565592eca096_impl(i.sv_position, i.texcoord0.xy, o0);
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
