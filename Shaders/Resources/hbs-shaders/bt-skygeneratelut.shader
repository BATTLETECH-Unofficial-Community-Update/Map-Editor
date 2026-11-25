Shader "Hidden/BT-SkyGenerateLUT"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SkyArray ("Array", 2DArray) = "white" {}
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

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2DArray _SkyArray;
SamplerState sampler_SkyArray;

float _Slice;
float _UseArray;

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

// vs 1e6a4e267f6f91ed: 1 retail keyword combination(s)
void vs_1e6a4e267f6f91ed_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float3 o0 : TEXCOORD0,
  inout float4 o1 : SV_POSITION0)
{
  o0.xy = v1.xy * float2(1,-1) + float2(0,1);
  o0.z = _Slice;
  o1.xyzw = v0.xyzw * float4(2,2,0,0) + float4(0,0,0,1);
  return;
}


// ps 7eb1c63ac4aea415: 1 retail keyword combination(s)
void ps_7eb1c63ac4aea415_impl(
  float3 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = cmp(_UseArray < 0.5);
  [branch] if (r0.x != 0) {
    o0.xyzw = _MainTex.Sample(sampler_MainTex, v0.xy).xyzw;
  } else {
    o0.xyzw = _SkyArray.Sample(sampler_SkyArray, v0.xyz).xyzw;
  }
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float3 o0 = 0;
		float4 o1 = 0;
		vs_1e6a4e267f6f91ed_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.texcoord0.xyz = o0;
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
		ps_7eb1c63ac4aea415_impl(i.texcoord0.xyz, i.sv_position, o0);
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

Texture2D _SampleTex;
SamplerState sampler_SampleTex;

float _Slice;

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

// vs 1e6a4e267f6f91ed: 1 retail keyword combination(s)
void vs_1e6a4e267f6f91ed_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float3 o0 : TEXCOORD0,
  inout float4 o1 : SV_POSITION0)
{
  o0.xy = v1.xy * float2(1,-1) + float2(0,1);
  o0.z = _Slice;
  o1.xyzw = v0.xyzw * float4(2,2,0,0) + float4(0,0,0,1);
  return;
}


// ps 70edc4a8ad5ab4a3: 1 retail keyword combination(s)
void ps_70edc4a8ad5ab4a3_impl(
  float3 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = _SampleTex.Sample(sampler_SampleTex, v0.xy).xyzw;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float3 o0 = 0;
		float4 o1 = 0;
		vs_1e6a4e267f6f91ed_impl(v.position0, v.texcoord0.xy, o0, o1);
		o.texcoord0.xyz = o0;
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
		ps_70edc4a8ad5ab4a3_impl(i.texcoord0.xyz, i.sv_position, o0);
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
