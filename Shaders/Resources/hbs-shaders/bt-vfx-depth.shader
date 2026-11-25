Shader "Hidden/BT-VFX-Depth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0

#define cmp -

Texture2D _VFXTex;
SamplerState sampler_VFXTex;
Texture2D _DepthDownsampleVFX;
SamplerState sampler_DepthDownsampleVFX;
Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;


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


// ps eac8eaefb0f8e584: 1 retail keyword combination(s)
void ps_eac8eaefb0f8e584_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _DepthDownsampleVFX.Gather(sampler_DepthDownsampleVFX, v0.xy).xyzw;
  r0.xyzw = _ZBufferParams.xxxx * r0.xyzw + _ZBufferParams.yyyy;
  r0.xyzw = float4(1,1,1,1) / r0.xyzw;
  r1.x = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, v0.xy).x;
  r1.x = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.x = 1 / r1.x;
  r0.xyzw = -r1.xxxx + r0.xyzw;
  r1.xyzw = cmp(abs(r0.xyzw) < float4(0.00100000005,0.00100000005,0.00100000005,0.00100000005));
  r1.x = r1.y ? r1.x : 0;
  r1.x = r1.z ? r1.x : 0;
  r1.x = r1.w ? r1.x : 0;
  [branch] if (r1.x != 0) {
    r1.xyzw = _VFXTex.Sample(sampler_VFXTex, v0.xy).xyzw;
    o0.w = saturate(r1.w);
    o0.xyz = r1.xyz;
    return;
  }
  r1.xyzw = _VFXTex.Gather(sampler_VFXTex, v0.xy).xyzw;
  r2.xyzw = _VFXTex.GatherGreen(sampler_VFXTex, v0.xy).xyzw;
  r3.xyzw = _VFXTex.GatherBlue(sampler_VFXTex, v0.xy).xyzw;
  r4.xyzw = _VFXTex.GatherAlpha(sampler_VFXTex, v0.xy).xyzw;
  r4.xyzw = saturate(r4.xyzw);
  r5.xyz = cmp(abs(r0.xxx) < abs(r0.yzw));
  r0.x = r5.y ? r5.x : 0;
  r0.x = r5.z ? r0.x : 0;
  [branch] if (r0.x != 0) {
    o0.x = r1.x;
    o0.y = r2.x;
    o0.z = r3.x;
    o0.w = r4.x;
    return;
  } else {
    r0.xy = cmp(abs(r0.yy) < abs(r0.zw));
    r0.x = r0.y ? r0.x : 0;
    [branch] if (r0.x != 0) {
      o0.x = r1.y;
      o0.y = r2.y;
      o0.z = r3.y;
      o0.w = r4.y;
      return;
    } else {
      r0.x = cmp(abs(r0.z) < abs(r0.w));
      [branch] if (r0.x != 0) {
        o0.x = r1.z;
        o0.y = r2.z;
        o0.z = r3.z;
        o0.w = r4.z;
        return;
      } else {
        o0.x = r1.w;
        o0.y = r2.w;
        o0.z = r3.w;
        o0.w = r4.w;
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
		ps_eac8eaefb0f8e584_impl(i.texcoord0.xy, i.sv_position, o0);
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
