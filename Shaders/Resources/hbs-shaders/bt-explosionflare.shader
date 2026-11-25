Shader "Hidden/BT-ExplosionFlare"
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

#define cmp -

Texture2D _DepthDownsampleVFX;
SamplerState sampler_DepthDownsampleVFX;

float4 _ExplosionColor;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
};

#if 1
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

// vs 66933487ab8fa6f7: 1 retail keyword combination(s)
void vs_66933487ab8fa6f7_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float3 o4 : TEXCOORD3)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  o4.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  o0.xyzw = r0.xyzw;
  o1.xy = v1.xy;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o2.zw = r0.zw;
  o2.xy = r1.xw + r1.zz;
  r0.xyz = float3(unity_MatrixV[0][1], unity_MatrixV[1][1], unity_MatrixV[2][1]) * v2.yyy;
  r0.xyz = float3(unity_MatrixV[0][0], unity_MatrixV[1][0], unity_MatrixV[2][0]) * v2.xxx + r0.xyz;
  o3.xyz = float3(unity_MatrixV[0][2], unity_MatrixV[1][2], unity_MatrixV[2][2]) * v2.zzz + r0.xyz;
  return;
}


// ps a520b5899b84ab67: 1 retail keyword combination(s)
void ps_a520b5899b84ab67_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float3 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v2.xyz / v2.www;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.y = _ZBufferParams.z * r0.z + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.z = cmp(r0.x < r0.y);
  [branch] if (r0.z != 0) {
    o0.xyzw = float4(0,0,0,1);
    return;
  }
  r0.x = r0.x + -r0.y;
  r0.x = 0.0199999996 * abs(r0.x);
  r0.x = min(1, r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.y = abs(v3.z) * abs(v3.z);
  r1.xyz = -_WorldSpaceCameraPos.xyz + v4.xyz;
  r0.z = dot(r1.xyz, r1.xyz);
  r0.z = sqrt(r0.z);
  r0.z = -10 + r0.z;
  r0.z = saturate(0.0250000004 * r0.z);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.yz = r0.yw * r0.yz;
  r1.xyzw = _ExplosionColor.xyzw * r0.yyyy;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyzw = r1.xyzw * r0.zzzz;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float3 o4 = 0;
		vs_66933487ab8fa6f7_impl(v.position0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3.xyz = o4;
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
		ps_a520b5899b84ab67_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3.xyz, o0);
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
			#pragma multi_compile _ _LIGHTQUAL_HIGH
			#pragma multi_compile _ _LIGHTQUAL_LOW
			#pragma multi_compile _ _LIGHTQUAL_MED

#define cmp -

Texture2D _FlareRT0;
SamplerState sampler_FlareRT0;

float4 _ExplosionPos;

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

// vs 3310c2d1c7255728: 3 retail keyword combination(s)
void vs_3310c2d1c7255728_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = float2(2,2) * v0.xy;
  o0.zw = float2(0.100000001,1);
  o1.xy = v1.xy * float2(1,-1) + float2(0,1);
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * _ExplosionPos.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * _ExplosionPos.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * _ExplosionPos.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) + r0.xyzw;
  r1.x = _ProjectionParams.x * r0.y;
  r1.w = 0.5 * r1.x;
  r1.xz = float2(0.5,0.5) * r0.xw;
  r0.xy = r1.xw + r1.zz;
  o2.xyzw = r0.xyzw / r0.wwww;
  return;
}


// ps 842ad7195c554c8b: 1 retail keyword combination(s)
void ps_842ad7195c554c8b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy + -v1.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.z = rsqrt(r0.z);
  r0.xy = r0.xy * r0.zz;
  r0.zw = v1.xy;
  r1.xyzw = float4(0,0,0,0);
  r2.x = 0;
  [loop] while (true) {
    r2.y = cmp((int)r2.x >= 32);
    [branch] if (r2.y != 0) break;
    r2.yz = v2.xy + -r0.zw;
    r2.y = dot(r0.xy, r2.yz);
    r2.y = cmp(r2.y < 0);
    [branch] if (r2.y != 0) {
      break;
    }
    r2.y = (int)r2.x;
    r2.y = 32 + -r2.y;
    r2.y = 0.03125 * r2.y;
    r3.xyzw = _FlareRT0.SampleLevel(sampler_FlareRT0, r0.zw, 0).xyzw;
    r2.y = r2.y * r2.y;
    r2.y = r2.y * r2.y;
    r1.xyz = r3.xyz * r2.yyy + r1.xyz;
    r0.zw = r0.xy * float2(0.00200000009,0.00200000009) + r0.zw;
    r1.w = 1 + r1.w;
    r2.x = (int)r2.x + 1;
  }
  r0.x = 32 / r1.w;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = 1;
  return;
}


// ps 5aa59618e898e324: 1 retail keyword combination(s)
void ps_5aa59618e898e324_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy + -v1.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.z = rsqrt(r0.z);
  r0.xy = r0.xy * r0.zz;
  r0.zw = v1.xy;
  r1.xyzw = float4(0,0,0,0);
  r2.x = 0;
  [loop] while (true) {
    r2.y = cmp((int)r2.x >= 24);
    [branch] if (r2.y != 0) break;
    r2.yz = v2.xy + -r0.zw;
    r2.y = dot(r0.xy, r2.yz);
    r2.y = cmp(r2.y < 0);
    [branch] if (r2.y != 0) {
      break;
    }
    r2.y = (int)r2.x;
    r2.y = 24 + -r2.y;
    r2.y = 0.0416666679 * r2.y;
    r3.xyzw = _FlareRT0.SampleLevel(sampler_FlareRT0, r0.zw, 0).xyzw;
    r2.y = r2.y * r2.y;
    r2.y = r2.y * r2.y;
    r1.xyz = r3.xyz * r2.yyy + r1.xyz;
    r0.zw = r0.xy * float2(0.00266666664,0.00266666664) + r0.zw;
    r1.w = 1 + r1.w;
    r2.x = (int)r2.x + 1;
  }
  r0.x = 24 / r1.w;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = 1;
  return;
}


// ps dda64a6cf33f764c: 1 retail keyword combination(s)
void ps_dda64a6cf33f764c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy + -v1.xy;
  r0.z = dot(r0.xy, r0.xy);
  r0.z = rsqrt(r0.z);
  r0.xy = r0.xy * r0.zz;
  r0.zw = v1.xy;
  r1.xyzw = float4(0,0,0,0);
  r2.x = 0;
  [loop] while (true) {
    r2.y = cmp((int)r2.x >= 16);
    [branch] if (r2.y != 0) break;
    r2.yz = v2.xy + -r0.zw;
    r2.y = dot(r0.xy, r2.yz);
    r2.y = cmp(r2.y < 0);
    [branch] if (r2.y != 0) {
      break;
    }
    r2.y = (int)r2.x;
    r2.y = 16 + -r2.y;
    r2.y = 0.0625 * r2.y;
    r3.xyzw = _FlareRT0.SampleLevel(sampler_FlareRT0, r0.zw, 0).xyzw;
    r2.y = r2.y * r2.y;
    r2.y = r2.y * r2.y;
    r1.xyz = r3.xyz * r2.yyy + r1.xyz;
    r0.zw = r0.xy * float2(0.00400000019,0.00400000019) + r0.zw;
    r1.w = 1 + r1.w;
    r2.x = (int)r2.x + 1;
  }
  r0.x = 16 / r1.w;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		vs_3310c2d1c7255728_impl(v.position0, v.texcoord0.xy, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
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
		ps_842ad7195c554c8b_impl(i.sv_position, i.texcoord0, i.texcoord1, o0);
		r.t0 = o0;
	}
#elif defined(_LIGHTQUAL_MED)
	{
		float4 o0 = 0;
		ps_5aa59618e898e324_impl(i.sv_position, i.texcoord0, i.texcoord1, o0);
		r.t0 = o0;
	}
#elif defined(_LIGHTQUAL_LOW)
	{
		float4 o0 = 0;
		ps_dda64a6cf33f764c_impl(i.sv_position, i.texcoord0, i.texcoord1, o0);
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

Texture2D _FlareRT1;
SamplerState sampler_FlareRT1;
Texture2D _DepthDownsampleVFX;
SamplerState sampler_DepthDownsampleVFX;
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

// vs d63cf59fd19d3596: 1 retail keyword combination(s)
void vs_d63cf59fd19d3596_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float2 o0 : TEXCOORD0,
  inout float4 o1 : SV_POSITION0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

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


// ps da9af6cad919c273: 1 retail keyword combination(s)
void ps_da9af6cad919c273_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _DepthDownsampleVFX.Gather(sampler_DepthDownsampleVFX, v0.xy).xyzw;
  r0.xyzw = _ZBufferParams.xxxx * r0.xyzw + _ZBufferParams.yyyy;
  r0.xyzw = float4(1,1,1,1) / r0.xyzw;
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.x = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyzw = -r1.xxxx + r0.xyzw;
  r1.xyzw = cmp(abs(r0.xyzw) < float4(0.0500000007,0.0500000007,0.0500000007,0.0500000007));
  r1.x = r1.y ? r1.x : 0;
  r1.x = r1.z ? r1.x : 0;
  r1.x = r1.w ? r1.x : 0;
  [branch] if (r1.x != 0) {
    o0.xyzw = _FlareRT1.Sample(sampler_FlareRT1, v0.xy).xyzw;
    return;
  }
  r1.xyzw = _FlareRT1.Gather(sampler_FlareRT1, v0.xy).xyzw;
  r2.xyzw = _FlareRT1.GatherGreen(sampler_FlareRT1, v0.xy).xyzw;
  r3.xyzw = _FlareRT1.GatherBlue(sampler_FlareRT1, v0.xy).xyzw;
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
		float2 o0 = 0;
		float4 o1 = 0;
		vs_d63cf59fd19d3596_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.texcoord0.xy = o0;
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
		float4 o0 = 0;
		ps_da9af6cad919c273_impl(i.texcoord0.xy, i.sv_position, o0);
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
