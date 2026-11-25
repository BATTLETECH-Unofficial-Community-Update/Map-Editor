Shader "Hidden/BT-DecalBake"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			ColorMask RGBA
			ZWrite Off
			ZTest Always
			Cull Off
			Blend One Zero

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;

float4x4 _WorldToDecal;

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

// vs a61d67c723c1a402: 1 retail keyword combination(s)
void vs_a61d67c723c1a402_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float2 v2 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float3 o3 : TEXCOORD2)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * float2(1,-1) + float2(0,1);
  o0.xy = r0.xy * float2(2,2) + float2(-1,-1);
  o0.zw = float2(0,1);
  o1.xy = v2.xy;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r0.xyz;
  o2.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r0.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r0.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r0.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o3.xyz = r0.xyz * r0.www;
  return;
}


// ps 1748f96fea525988: 1 retail keyword combination(s)
void ps_1748f96fea525988_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float3 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(_WorldToDecal[0][1], _WorldToDecal[1][1], _WorldToDecal[2][1], _WorldToDecal[3][1]) * v3.yyyy;
  r0.xyzw = float4(_WorldToDecal[0][0], _WorldToDecal[1][0], _WorldToDecal[2][0], _WorldToDecal[3][0]) * v3.xxxx + r0.xyzw;
  r0.xyzw = float4(_WorldToDecal[0][2], _WorldToDecal[1][2], _WorldToDecal[2][2], _WorldToDecal[3][2]) * v3.zzzz + r0.xyzw;
  r0.x = dot(r0.xyzw, r0.xyzw);
  r0.x = rsqrt(r0.x);
  r0.x = r0.y * r0.x;
  r0.x = cmp(r0.x < 0.5);
  r0.yzw = float3(_WorldToDecal[1][1], _WorldToDecal[0][1], _WorldToDecal[2][1]) * v2.yyy;
  r0.yzw = float3(_WorldToDecal[1][0], _WorldToDecal[0][0], _WorldToDecal[2][0]) * v2.xxx + r0.yzw;
  r0.yzw = float3(_WorldToDecal[1][2], _WorldToDecal[0][2], _WorldToDecal[2][2]) * v2.zzz + r0.yzw;
  r0.yzw = float3(_WorldToDecal[1][3], _WorldToDecal[0][3], _WorldToDecal[2][3]) + r0.yzw;
  r0.yzw = float3(0.5,0.5,0.5) + r0.zwy;
  r1.xyz = cmp(r0.wyz < float3(0,0,0));
  r2.xyz = cmp(float3(1,1,1) < r0.wyz);
  r0.yz = saturate(r0.yz);
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r0.y = (int)r1.x | (int)r2.x;
  r0.y = (int)r1.y | (int)r0.y;
  r0.y = (int)r2.y | (int)r0.y;
  r0.y = (int)r1.z | (int)r0.y;
  r0.y = (int)r2.z | (int)r0.y;
  r0.x = (int)r0.x | (int)r0.y;
  r0.x = r0.x ? 0 : r3.w;
  r0.y = -0.100000001 + r0.x;
  r0.y = cmp(r0.y < 0);
  clip(r0.y != 0 ? -1 : 1);
  r0.y = cmp(r0.x >= 0.00999999978);
  o0.w = r0.x;
  r0.x = r0.y ? 1.000000 : 0;
  o0.xyz = r0.xxx * r3.xyz;
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
		float3 o3 = 0;
		vs_a61d67c723c1a402_impl(v.position0, v.normal0.xyz, v.texcoord0.xy, o0, o1, o2, o3);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2.xyz = o3;
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
		ps_1748f96fea525988_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2.xyz, o0);
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
