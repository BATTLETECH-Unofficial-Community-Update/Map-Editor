Shader "Hidden/Post FX/Temporal Anti-aliasing"
{
	Properties
	{
		_MainTex ("_MainTex", 2D) = "black" {}
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
			#pragma target 5.0
			#pragma exclude_renderers nomrt

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _CameraMotionVectorsTexture;
SamplerState sampler_CameraMotionVectorsTexture;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _HistoryTex;
SamplerState sampler_HistoryTex;

float4 _MainTex_TexelSize;
float _EV;
float4 _CameraDepthTexture_TexelSize;
float2 _Jitter;
float4 _SharpenParameters;
float4 _FinalBlendParameters;

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
	float4 t1 : SV_Target1;
};

// vs 8a241b6ded54d498: 1 retail keyword combination(s)
void vs_8a241b6ded54d498_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0)
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
  o1.y = r0.x ? r0.y : v1.y;
  o1.xzw = v1.xxy;
  return;
}


// ps eb962f3963c3f640: 1 retail keyword combination(s)
void ps_eb962f3963c3f640_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.w = -_MainTex_TexelSize.y;
  r1.x = cmp(_MainTex_TexelSize.y < 0);
  r1.yz = float2(1,-1) * _Jitter.xy;
  r1.xy = r1.xx ? r1.yz : _Jitter.xy;
  r1.xy = v1.xy + -r1.xy;
  r0.xz = float2(0,0);
  r0.zw = r1.xy + r0.zw;
  r2.xyz = _MainTex.Sample(sampler_MainTex, r0.zw).xyz;
  r0.z = -13 + _EV;
  r0.z = exp2(r0.z);
  r2.xyz = r2.xyz / r0.zzz;
  r0.w = max(r2.y, r2.z);
  r0.w = max(r2.x, r0.w);
  r0.w = 1 + r0.w;
  r0.w = 1 / r0.w;
  r2.xyz = r2.xyz * r0.www;
  r0.y = _MainTex_TexelSize.y;
  r0.xy = r1.xy + r0.xy;
  r0.xyw = _MainTex.Sample(sampler_MainTex, r0.xy).xyz;
  r3.xyz = r0.xyw / r0.zzz;
  r1.z = max(r3.y, r3.z);
  r1.z = max(r3.x, r1.z);
  r1.z = 1 + r1.z;
  r1.z = 1 / r1.z;
  r4.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = r3.xyz * r1.zzz;
  r5.z = -_MainTex_TexelSize.x;
  r5.yw = float2(0,0);
  r1.zw = r5.zw + r1.xy;
  r6.xyz = _MainTex.Sample(sampler_MainTex, r1.zw).xyz;
  r6.xyz = r6.xyz / r0.zzz;
  r1.z = max(r6.y, r6.z);
  r1.z = max(r6.x, r1.z);
  r1.z = 1 + r1.z;
  r1.z = 1 / r1.z;
  r4.xyz = r6.xyz * r1.zzz + r4.xyz;
  r6.xyz = r6.xyz * r1.zzz;
  r5.x = _MainTex_TexelSize.x;
  r1.zw = r5.xy + r1.xy;
  r5.xyz = _MainTex.Sample(sampler_MainTex, r1.xy).xyz;
  r1.xyz = _MainTex.Sample(sampler_MainTex, r1.zw).xyz;
  r7.xyz = r1.xyz / r0.zzz;
  r0.xyw = r1.xyz + r0.xyw;
  r1.x = max(r7.y, r7.z);
  r1.x = max(r7.x, r1.x);
  r1.x = 1 + r1.x;
  r1.x = 1 / r1.x;
  r1.yzw = r7.xyz * r1.xxx + r4.xyz;
  r4.xyz = r7.xyz * r1.xxx;
  r7.xyz = r5.xyz + r5.xyz;
  r0.xyw = r0.xyw * float3(4,4,4) + -r7.xyz;
  r0.xyw = -r0.xyw * float3(0.166666999,0.166666999,0.166666999) + r5.xyz;
  r0.xyw = _SharpenParameters.xxx * r0.xyw;
  r0.xyw = r0.xyw * float3(2.71828198,2.71828198,2.71828198) + r5.xyz;
  r0.xyw = max(float3(0,0,0), r0.xyw);
  r0.xyw = r0.xyw / r0.zzz;
  r1.x = max(r0.y, r0.w);
  r1.x = max(r1.x, r0.x);
  r1.x = 1 + r1.x;
  r1.x = 1 / r1.x;
  r1.yzw = r0.xyw * r1.xxx + r1.yzw;
  r5.xyz = r1.xxx * r0.xyw;
  r0.xyw = float3(0.200000003,0.200000003,0.200000003) * r1.yzw;
  r0.x = dot(r0.xyw, float3(0.0396819152,0.45802179,0.00609653955));
  r0.y = dot(r5.xyz, float3(0.0396819152,0.45802179,0.00609653955));
  r0.x = r0.x + -r0.y;
  r1.xyz = min(r3.xyz, r2.xyz);
  r2.xyz = max(r3.xyz, r2.xyz);
  r3.xyz = min(r6.xyz, r4.xyz);
  r4.xyz = max(r6.xyz, r4.xyz);
  r2.xyz = max(r4.xyz, r2.xyz);
  r2.xyz = max(r2.xyz, r5.xyz);
  r2.xyz = abs(r0.xxx) * float3(4,4,4) + r2.xyz;
  r1.xyz = min(r3.xyz, r1.xyz);
  r1.xyz = min(r1.xyz, r5.xyz);
  r0.xyw = -abs(r0.xxx) * float3(4,4,4) + r1.xyz;
  r1.xyz = r2.xyz + r0.xyw;
  r0.xyw = r2.xyz + -r0.xyw;
  r0.xyw = float3(0.5,0.5,0.5) * r0.xyw;
  r1.xyz = float3(0.5,0.5,0.5) * r1.xyz;
  r2.xy = -_CameraDepthTexture_TexelSize.xy + v1.zw;
  r2.z = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r2.xy).x;
  r3.z = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.zw).x;
  r2.w = cmp(r2.z >= r3.z);
  r2.w = r2.w ? 1.000000 : 0;
  r2.xy = float2(-1,-1);
  r3.xy = float2(0,0);
  r2.xyz = -r3.yyz + r2.xyz;
  r2.xyz = r2.www * r2.xyz + r3.xyz;
  r3.xy = float2(1,-1);
  r4.xyzw = _CameraDepthTexture_TexelSize.xyxy * float4(1,-1,-1,1) + v1.zwzw;
  r3.z = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r4.xy).x;
  r4.z = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r4.zw).x;
  r2.w = cmp(r3.z >= r2.z);
  r2.w = r2.w ? 1.000000 : 0;
  r3.xyz = r3.xyz + -r2.yyz;
  r2.xyz = r2.www * r3.xyz + r2.xyz;
  r4.xyw = float3(-1,1,0);
  r2.w = cmp(r4.z >= r2.z);
  r2.w = r2.w ? 1.000000 : 0;
  r3.xyz = r4.xyz + -r2.xyz;
  r2.xyz = r2.www * r3.xyz + r2.xyz;
  r3.xy = _CameraDepthTexture_TexelSize.xy + v1.zw;
  r2.w = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r3.xy).x;
  r2.z = cmp(r2.w >= r2.z);
  r2.z = r2.z ? 1.000000 : 0;
  r3.xy = float2(1,1) + -r2.xy;
  r2.xy = r2.zz * r3.xy + r2.xy;
  r2.xy = r2.xy * _CameraDepthTexture_TexelSize.xy + v1.zw;
  r2.xy = _CameraMotionVectorsTexture.Sample(sampler_CameraMotionVectorsTexture, r2.xy).xy;
  r2.zw = v1.zw + -r2.xy;
  r2.x = dot(r2.xy, r2.xy);
  r2.x = sqrt(r2.x);
  r3.xyzw = _HistoryTex.Sample(sampler_HistoryTex, r2.zw).xyzw;
  r2.yzw = r3.xyz / r0.zzz;
  r1.w = r3.w;
  r3.x = max(r2.z, r2.w);
  r3.x = max(r3.x, r2.y);
  r3.x = 1 + r3.x;
  r3.x = 1 / r3.x;
  r4.xyz = r2.yzw * r3.xxx + -r1.xyz;
  r3.xyz = r3.xxx * r2.yzw;
  r0.xyw = r4.xyz / r0.xyw;
  r0.y = max(abs(r0.y), abs(r0.w));
  r0.x = max(abs(r0.x), r0.y);
  r4.xyzw = r4.xyzw / r0.xxxx;
  r0.x = cmp(1 < r0.x);
  r4.xyzw = r4.xyzw + r1.xyzw;
  r3.w = r1.w;
  r1.xyzw = r0.xxxx ? r4.xyzw : r3.xyzw;
  r0.x = -_MainTex_TexelSize.z * 0.00200000009 + r2.x;
  r0.y = _FinalBlendParameters.z * r2.x;
  r0.w = 0.00150000001 * _MainTex_TexelSize.z;
  r0.w = 1 / r0.w;
  r0.x = saturate(r0.x * r0.w);
  r0.w = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.w * r0.x;
  r5.w = min(1, r0.x);
  r2.xyzw = -r5.xyzw + r1.xyzw;
  r1.xyzw = asint(r1.xyzw) & int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000);
  r1.xyzw = cmp((int4)r1.xyzw != int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000));
  r0.xw = r1.zw ? r1.xy : 0;
  r0.x = (int)r0.w & (int)r0.x;
  r0.w = _FinalBlendParameters.y + -_FinalBlendParameters.x;
  r0.y = r0.y * r0.w + _FinalBlendParameters.x;
  r0.y = max(_FinalBlendParameters.y, r0.y);
  r0.y = min(_FinalBlendParameters.x, r0.y);
  r1.xyzw = r0.yyyy * r2.xyzw + r5.xyzw;
  r0.y = max(r1.y, r1.z);
  r0.y = max(r1.x, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = 1 / r0.y;
  r1.xyz = r1.xyz * r0.yyy;
  r0.y = max(r5.y, r5.z);
  r0.y = max(r5.x, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = 1 / r0.y;
  r5.xyz = r5.xyz * r0.yyy;
  r1.xyzw = r0.xxxx ? r1.xyzw : r5.xyzw;
  r0.xyz = r1.xyz * r0.zzz;
  o0.xyz = r0.xyz;
  o1.xyz = r0.xyz;
  o0.w = r1.w;
  o1.w = 0.949999988 * r1.w;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		vs_8a241b6ded54d498_impl(v.position0, v.texcoord0, o0, o1);
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
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		ps_eb962f3963c3f640_impl(i.sv_position, i.texcoord0, o0, o1);
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
			#pragma target 5.0
			#pragma exclude_renderers nomrt

#define cmp -

Texture2D _CameraMotionVectorsTexture;
SamplerState sampler_CameraMotionVectorsTexture;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _HistoryTex;
SamplerState sampler_HistoryTex;

float4 _MainTex_TexelSize;
float _EV;
float2 _Jitter;
float4 _SharpenParameters;
float4 _FinalBlendParameters;

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
	float4 t1 : SV_Target1;
};

// vs 8a241b6ded54d498: 1 retail keyword combination(s)
void vs_8a241b6ded54d498_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0)
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
  o1.y = r0.x ? r0.y : v1.y;
  o1.xzw = v1.xxy;
  return;
}


// ps b609fcfc8111b340: 1 retail keyword combination(s)
void ps_b609fcfc8111b340_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.w = -_MainTex_TexelSize.y;
  r1.x = cmp(_MainTex_TexelSize.y < 0);
  r1.yz = float2(1,-1) * _Jitter.xy;
  r1.xy = r1.xx ? r1.yz : _Jitter.xy;
  r1.xy = v1.xy + -r1.xy;
  r0.xz = float2(0,0);
  r0.zw = r1.xy + r0.zw;
  r2.xyz = _MainTex.Sample(sampler_MainTex, r0.zw).xyz;
  r0.z = -13 + _EV;
  r0.z = exp2(r0.z);
  r2.xyz = r2.xyz / r0.zzz;
  r0.w = max(r2.y, r2.z);
  r0.w = max(r2.x, r0.w);
  r0.w = 1 + r0.w;
  r0.w = 1 / r0.w;
  r2.xyz = r2.xyz * r0.www;
  r0.y = _MainTex_TexelSize.y;
  r0.xy = r1.xy + r0.xy;
  r0.xyw = _MainTex.Sample(sampler_MainTex, r0.xy).xyz;
  r3.xyz = r0.xyw / r0.zzz;
  r1.z = max(r3.y, r3.z);
  r1.z = max(r3.x, r1.z);
  r1.z = 1 + r1.z;
  r1.z = 1 / r1.z;
  r4.xyz = r3.xyz * r1.zzz + r2.xyz;
  r3.xyz = r3.xyz * r1.zzz;
  r5.z = -_MainTex_TexelSize.x;
  r5.yw = float2(0,0);
  r1.zw = r5.zw + r1.xy;
  r6.xyz = _MainTex.Sample(sampler_MainTex, r1.zw).xyz;
  r6.xyz = r6.xyz / r0.zzz;
  r1.z = max(r6.y, r6.z);
  r1.z = max(r6.x, r1.z);
  r1.z = 1 + r1.z;
  r1.z = 1 / r1.z;
  r4.xyz = r6.xyz * r1.zzz + r4.xyz;
  r6.xyz = r6.xyz * r1.zzz;
  r5.x = _MainTex_TexelSize.x;
  r1.zw = r5.xy + r1.xy;
  r5.xyz = _MainTex.Sample(sampler_MainTex, r1.xy).xyz;
  r1.xyz = _MainTex.Sample(sampler_MainTex, r1.zw).xyz;
  r7.xyz = r1.xyz / r0.zzz;
  r0.xyw = r1.xyz + r0.xyw;
  r1.x = max(r7.y, r7.z);
  r1.x = max(r7.x, r1.x);
  r1.x = 1 + r1.x;
  r1.x = 1 / r1.x;
  r1.yzw = r7.xyz * r1.xxx + r4.xyz;
  r4.xyz = r7.xyz * r1.xxx;
  r7.xyz = r5.xyz + r5.xyz;
  r0.xyw = r0.xyw * float3(4,4,4) + -r7.xyz;
  r0.xyw = -r0.xyw * float3(0.166666999,0.166666999,0.166666999) + r5.xyz;
  r0.xyw = _SharpenParameters.xxx * r0.xyw;
  r0.xyw = r0.xyw * float3(2.71828198,2.71828198,2.71828198) + r5.xyz;
  r0.xyw = max(float3(0,0,0), r0.xyw);
  r0.xyw = r0.xyw / r0.zzz;
  r1.x = max(r0.y, r0.w);
  r1.x = max(r1.x, r0.x);
  r1.x = 1 + r1.x;
  r1.x = 1 / r1.x;
  r1.yzw = r0.xyw * r1.xxx + r1.yzw;
  r5.xyz = r1.xxx * r0.xyw;
  r0.xyw = float3(0.200000003,0.200000003,0.200000003) * r1.yzw;
  r0.x = dot(r0.xyw, float3(0.0396819152,0.45802179,0.00609653955));
  r0.y = dot(r5.xyz, float3(0.0396819152,0.45802179,0.00609653955));
  r0.x = r0.x + -r0.y;
  r1.xyz = min(r3.xyz, r2.xyz);
  r2.xyz = max(r3.xyz, r2.xyz);
  r3.xyz = min(r6.xyz, r4.xyz);
  r4.xyz = max(r6.xyz, r4.xyz);
  r2.xyz = max(r4.xyz, r2.xyz);
  r2.xyz = max(r2.xyz, r5.xyz);
  r2.xyz = abs(r0.xxx) * float3(4,4,4) + r2.xyz;
  r1.xyz = min(r3.xyz, r1.xyz);
  r1.xyz = min(r1.xyz, r5.xyz);
  r0.xyw = -abs(r0.xxx) * float3(4,4,4) + r1.xyz;
  r1.xyz = r2.xyz + -r0.xyw;
  r0.xyw = r2.xyz + r0.xyw;
  r2.xyz = float3(0.5,0.5,0.5) * r0.xyw;
  r0.xyw = float3(0.5,0.5,0.5) * r1.xyz;
  r1.xy = _CameraMotionVectorsTexture.Sample(sampler_CameraMotionVectorsTexture, v1.zw).xy;
  r1.zw = v1.zw + -r1.xy;
  r1.x = dot(r1.xy, r1.xy);
  r1.x = sqrt(r1.x);
  r3.xyzw = _HistoryTex.Sample(sampler_HistoryTex, r1.zw).xyzw;
  r1.yzw = r3.xyz / r0.zzz;
  r2.w = r3.w;
  r3.x = max(r1.z, r1.w);
  r3.x = max(r3.x, r1.y);
  r3.x = 1 + r3.x;
  r3.x = 1 / r3.x;
  r4.xyz = r1.yzw * r3.xxx + -r2.xyz;
  r3.xyz = r3.xxx * r1.yzw;
  r0.xyw = r4.xyz / r0.xyw;
  r0.y = max(abs(r0.y), abs(r0.w));
  r0.x = max(abs(r0.x), r0.y);
  r4.w = 0;
  r4.xyzw = r4.xyzw / r0.xxxx;
  r0.x = cmp(1 < r0.x);
  r4.xyzw = r4.xyzw + r2.xyzw;
  r3.w = r2.w;
  r2.xyzw = r0.xxxx ? r4.xyzw : r3.xyzw;
  r0.x = -_MainTex_TexelSize.z * 0.00200000009 + r1.x;
  r0.y = _FinalBlendParameters.z * r1.x;
  r0.w = 0.00150000001 * _MainTex_TexelSize.z;
  r0.w = 1 / r0.w;
  r0.x = saturate(r0.x * r0.w);
  r0.w = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.w * r0.x;
  r5.w = min(1, r0.x);
  r1.xyzw = -r5.xyzw + r2.xyzw;
  r2.xyzw = asint(r2.xyzw) & int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000);
  r2.xyzw = cmp((int4)r2.xyzw != int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000));
  r0.xw = r2.zw ? r2.xy : 0;
  r0.x = (int)r0.w & (int)r0.x;
  r0.w = _FinalBlendParameters.y + -_FinalBlendParameters.x;
  r0.y = r0.y * r0.w + _FinalBlendParameters.x;
  r0.y = max(_FinalBlendParameters.y, r0.y);
  r0.y = min(_FinalBlendParameters.x, r0.y);
  r1.xyzw = r0.yyyy * r1.xyzw + r5.xyzw;
  r0.y = max(r1.y, r1.z);
  r0.y = max(r1.x, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = 1 / r0.y;
  r1.xyz = r1.xyz * r0.yyy;
  r0.y = max(r5.y, r5.z);
  r0.y = max(r5.x, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = 1 / r0.y;
  r5.xyz = r5.xyz * r0.yyy;
  r1.xyzw = r0.xxxx ? r1.xyzw : r5.xyzw;
  r0.xyz = r1.xyz * r0.zzz;
  o0.xyz = r0.xyz;
  o1.xyz = r0.xyz;
  o0.w = r1.w;
  o1.w = 0.949999988 * r1.w;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		vs_8a241b6ded54d498_impl(v.position0, v.texcoord0, o0, o1);
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
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		ps_b609fcfc8111b340_impl(i.sv_position, i.texcoord0, o0, o1);
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
			#pragma target 5.0

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_ST;

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

// vs 2c0fb6ee3f6f7cc2: 1 retail keyword combination(s)
void vs_2c0fb6ee3f6f7cc2_impl(
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
  p1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = v1.xy;
  return;
}


// ps f1e21d5f69593ca0: 1 retail keyword combination(s)
void ps_f1e21d5f69593ca0_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = _MainTex.Sample(sampler_MainTex, v1.xy).xyz;
  o0.xyz = r0.xyz;
  o0.w = 0;
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
		vs_2c0fb6ee3f6f7cc2_impl(v.position0, v.texcoord0, o0, o1, p1);
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
		ps_f1e21d5f69593ca0_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _CameraMotionVectorsTexture;
SamplerState sampler_CameraMotionVectorsTexture;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _HistoryTex;
SamplerState sampler_HistoryTex;

float4 _MainTex_TexelSize;
float _EV;
float4 _CameraDepthTexture_TexelSize;
float2 _Jitter;
float4 _SharpenParameters;
float4 _FinalBlendParameters;

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
	float4 t1 : SV_Target1;
};

// vs d7d51214a8525a98: 1 retail keyword combination(s)
void vs_d7d51214a8525a98_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0)
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
  o1.y = r0.x ? r0.y : v1.y;
  o1.xzw = v1.xxy;
  return;
}


// ps c6e2e980720d141e: 1 retail keyword combination(s)
void ps_c6e2e980720d141e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.w = -_MainTex_TexelSize.y;
  r1.x = cmp(_MainTex_TexelSize.y < 0);
  r1.yz = float2(1,-1) * _Jitter.xy;
  r1.xy = r1.xx ? r1.yz : _Jitter.xy;
  r1.xy = v1.xy + -r1.xy;
  r0.xz = float2(0,0);
  r0.zw = r1.xy + r0.zw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.z = -13 + _EV;
  r0.z = exp2(r0.z);
  r2.xyz = r2.xyz / r0.zzz;
  r0.w = max(r2.y, r2.z);
  r0.w = max(r2.x, r0.w);
  r0.w = 1 + r0.w;
  r0.w = 1 / r0.w;
  r2.xyz = r2.xyz * r0.www;
  r0.y = _MainTex_TexelSize.y;
  r0.xy = r1.xy + r0.xy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyw = r3.xyz / r0.zzz;
  r1.z = max(r0.y, r0.w);
  r1.z = max(r1.z, r0.x);
  r1.z = 1 + r1.z;
  r1.z = 1 / r1.z;
  r4.xyz = r0.xyw * r1.zzz + r2.xyz;
  r0.xyw = r1.zzz * r0.xyw;
  r5.z = -_MainTex_TexelSize.x;
  r5.yw = float2(0,0);
  r1.zw = r5.zw + r1.xy;
  r6.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r6.xyz = r6.xyz / r0.zzz;
  r1.z = max(r6.y, r6.z);
  r1.z = max(r6.x, r1.z);
  r1.z = 1 + r1.z;
  r1.z = 1 / r1.z;
  r4.xyz = r6.xyz * r1.zzz + r4.xyz;
  r6.xyz = r6.xyz * r1.zzz;
  r5.x = _MainTex_TexelSize.x;
  r1.zw = r5.xy + r1.xy;
  r5.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r7.xyz = r1.xyz / r0.zzz;
  r1.xyz = r3.xyz + r1.xyz;
  r1.w = max(r7.y, r7.z);
  r1.w = max(r7.x, r1.w);
  r1.w = 1 + r1.w;
  r1.w = 1 / r1.w;
  r3.xyz = r7.xyz * r1.www + r4.xyz;
  r4.xyz = r7.xyz * r1.www;
  r7.xyz = r5.xyz + r5.xyz;
  r1.xyz = r1.xyz * float3(4,4,4) + -r7.xyz;
  r1.xyz = -r1.xyz * float3(0.166666999,0.166666999,0.166666999) + r5.xyz;
  r1.xyz = _SharpenParameters.xxx * r1.xyz;
  r1.xyz = r1.xyz * float3(2.71828198,2.71828198,2.71828198) + r5.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r1.xyz = r1.xyz / r0.zzz;
  r1.w = max(r1.y, r1.z);
  r1.w = max(r1.x, r1.w);
  r1.w = 1 + r1.w;
  r1.w = 1 / r1.w;
  r3.xyz = r1.xyz * r1.www + r3.xyz;
  r1.xyz = r1.xyz * r1.www;
  r3.xyz = float3(0.200000003,0.200000003,0.200000003) * r3.xyz;
  r2.w = dot(r3.xyz, float3(0.0396819152,0.45802179,0.00609653955));
  r3.x = dot(r1.xyz, float3(0.0396819152,0.45802179,0.00609653955));
  r2.w = -r3.x + r2.w;
  r3.xyz = min(r0.xyw, r2.xyz);
  r0.xyw = max(r0.xyw, r2.xyz);
  r2.xyz = min(r6.xyz, r4.xyz);
  r4.xyz = max(r6.xyz, r4.xyz);
  r0.xyw = max(r4.xyz, r0.xyw);
  r0.xyw = max(r0.xyw, r1.xyz);
  r0.xyw = abs(r2.www) * float3(4,4,4) + r0.xyw;
  r2.xyz = min(r3.xyz, r2.xyz);
  r2.xyz = min(r2.xyz, r1.xyz);
  r2.xyz = -abs(r2.www) * float3(4,4,4) + r2.xyz;
  r3.xyz = r2.xyz + r0.xyw;
  r0.xyw = -r2.xyz + r0.xyw;
  r0.xyw = float3(0.5,0.5,0.5) * r0.xyw;
  r2.xyz = float3(0.5,0.5,0.5) * r3.xyz;
  r3.xy = -_CameraDepthTexture_TexelSize.xy + v1.zw;
  r3.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r3.xy).yzxw;
  r4.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v1.zw).yzxw;
  r3.w = cmp(r3.z >= r4.z);
  r3.w = r3.w ? 1.000000 : 0;
  r3.xy = float2(-1,-1);
  r4.xy = float2(0,0);
  r3.xyz = -r4.yyz + r3.xyz;
  r3.xyz = r3.www * r3.xyz + r4.xyz;
  r4.xy = float2(1,-1);
  r5.xyzw = _CameraDepthTexture_TexelSize.xyxy * float4(1,-1,-1,1) + v1.zwzw;
  r6.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r5.xy).xyzw;
  r5.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r5.zw).yzxw;
  r4.z = r6.x;
  r3.w = cmp(r6.x >= r3.z);
  r3.w = r3.w ? 1.000000 : 0;
  r4.xyz = r4.xyz + -r3.yyz;
  r3.xyz = r3.www * r4.xyz + r3.xyz;
  r5.xyw = float3(-1,1,0);
  r3.w = cmp(r5.z >= r3.z);
  r3.w = r3.w ? 1.000000 : 0;
  r4.xyz = r5.xyz + -r3.xyz;
  r3.xyz = r3.www * r4.xyz + r3.xyz;
  r4.xy = _CameraDepthTexture_TexelSize.xy + v1.zw;
  r4.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r4.xy).xyzw;
  r3.z = cmp(r4.x >= r3.z);
  r3.z = r3.z ? 1.000000 : 0;
  r4.xy = float2(1,1) + -r3.xy;
  r3.xy = r3.zz * r4.xy + r3.xy;
  r3.xy = r3.xy * _CameraDepthTexture_TexelSize.xy + v1.zw;
  r3.xyzw = _CameraMotionVectorsTexture.Sample(sampler_CameraMotionVectorsTexture, r3.xy).xyzw;
  r3.zw = v1.zw + -r3.xy;
  r3.x = dot(r3.xy, r3.xy);
  r3.x = sqrt(r3.x);
  r4.xyzw = _HistoryTex.Sample(sampler_HistoryTex, r3.zw).xyzw;
  r3.yzw = r4.xyz / r0.zzz;
  r2.w = r4.w;
  r4.x = max(r3.z, r3.w);
  r4.x = max(r4.x, r3.y);
  r4.x = 1 + r4.x;
  r4.x = 1 / r4.x;
  r5.xyz = r3.yzw * r4.xxx + -r2.xyz;
  r4.xyz = r4.xxx * r3.yzw;
  r0.xyw = r5.xyz / r0.xyw;
  r0.y = max(abs(r0.y), abs(r0.w));
  r0.x = max(abs(r0.x), r0.y);
  r5.xyzw = r5.xyzw / r0.xxxx;
  r0.x = cmp(1 < r0.x);
  r5.xyzw = r5.xyzw + r2.xyzw;
  r4.w = r2.w;
  r2.xyzw = r0.xxxx ? r5.xyzw : r4.xyzw;
  r0.x = -_MainTex_TexelSize.z * 0.00200000009 + r3.x;
  r0.y = _FinalBlendParameters.z * r3.x;
  r0.w = 0.00150000001 * _MainTex_TexelSize.z;
  r0.w = 1 / r0.w;
  r0.x = saturate(r0.x * r0.w);
  r0.w = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.w * r0.x;
  r1.w = min(1, r0.x);
  r3.xyzw = r2.xyzw + -r1.xyzw;
  r2.xyzw = asint(r2.xyzw) & int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000);
  r2.xyzw = cmp((int4)r2.xyzw != int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000));
  r0.xw = r2.zw ? r2.xy : 0;
  r0.x = (int)r0.w & (int)r0.x;
  r0.w = _FinalBlendParameters.y + -_FinalBlendParameters.x;
  r0.y = r0.y * r0.w + _FinalBlendParameters.x;
  r0.y = max(_FinalBlendParameters.y, r0.y);
  r0.y = min(_FinalBlendParameters.x, r0.y);
  r2.xyzw = r0.yyyy * r3.xyzw + r1.xyzw;
  r0.y = max(r2.y, r2.z);
  r0.y = max(r2.x, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = 1 / r0.y;
  r2.xyz = r2.xyz * r0.yyy;
  r0.y = max(r1.y, r1.z);
  r0.y = max(r1.x, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = 1 / r0.y;
  r1.xyz = r1.xyz * r0.yyy;
  r1.xyzw = r0.xxxx ? r2.xyzw : r1.xyzw;
  r0.xyz = r1.xyz * r0.zzz;
  o0.xyz = r0.xyz;
  o1.xyz = r0.xyz;
  o0.w = r1.w;
  o1.w = 0.949999988 * r1.w;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		vs_d7d51214a8525a98_impl(v.position0, v.texcoord0, o0, o1);
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
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		ps_c6e2e980720d141e_impl(i.sv_position, i.texcoord0, o0, o1);
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
			#pragma exclude_renderers nomrt

#define cmp -

Texture2D _CameraMotionVectorsTexture;
SamplerState sampler_CameraMotionVectorsTexture;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _HistoryTex;
SamplerState sampler_HistoryTex;

float4 _MainTex_TexelSize;
float _EV;
float2 _Jitter;
float4 _SharpenParameters;
float4 _FinalBlendParameters;

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
	float4 t1 : SV_Target1;
};

// vs d7d51214a8525a98: 1 retail keyword combination(s)
void vs_d7d51214a8525a98_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0)
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
  o1.y = r0.x ? r0.y : v1.y;
  o1.xzw = v1.xxy;
  return;
}


// ps c666f9f818fa3291: 1 retail keyword combination(s)
void ps_c666f9f818fa3291_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.w = -_MainTex_TexelSize.y;
  r1.x = cmp(_MainTex_TexelSize.y < 0);
  r1.yz = float2(1,-1) * _Jitter.xy;
  r1.xy = r1.xx ? r1.yz : _Jitter.xy;
  r1.xy = v1.xy + -r1.xy;
  r0.xz = float2(0,0);
  r0.zw = r1.xy + r0.zw;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r0.z = -13 + _EV;
  r0.z = exp2(r0.z);
  r2.xyz = r2.xyz / r0.zzz;
  r0.w = max(r2.y, r2.z);
  r0.w = max(r2.x, r0.w);
  r0.w = 1 + r0.w;
  r0.w = 1 / r0.w;
  r2.xyz = r2.xyz * r0.www;
  r0.y = _MainTex_TexelSize.y;
  r0.xy = r1.xy + r0.xy;
  r3.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyw = r3.xyz / r0.zzz;
  r1.z = max(r0.y, r0.w);
  r1.z = max(r1.z, r0.x);
  r1.z = 1 + r1.z;
  r1.z = 1 / r1.z;
  r4.xyz = r0.xyw * r1.zzz + r2.xyz;
  r0.xyw = r1.zzz * r0.xyw;
  r5.z = -_MainTex_TexelSize.x;
  r5.yw = float2(0,0);
  r1.zw = r5.zw + r1.xy;
  r6.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r6.xyz = r6.xyz / r0.zzz;
  r1.z = max(r6.y, r6.z);
  r1.z = max(r6.x, r1.z);
  r1.z = 1 + r1.z;
  r1.z = 1 / r1.z;
  r4.xyz = r6.xyz * r1.zzz + r4.xyz;
  r6.xyz = r6.xyz * r1.zzz;
  r5.x = _MainTex_TexelSize.x;
  r1.zw = r5.xy + r1.xy;
  r5.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.zw).xyzw;
  r7.xyz = r1.xyz / r0.zzz;
  r1.xyz = r3.xyz + r1.xyz;
  r1.w = max(r7.y, r7.z);
  r1.w = max(r7.x, r1.w);
  r1.w = 1 + r1.w;
  r1.w = 1 / r1.w;
  r3.xyz = r7.xyz * r1.www + r4.xyz;
  r4.xyz = r7.xyz * r1.www;
  r7.xyz = r5.xyz + r5.xyz;
  r1.xyz = r1.xyz * float3(4,4,4) + -r7.xyz;
  r1.xyz = -r1.xyz * float3(0.166666999,0.166666999,0.166666999) + r5.xyz;
  r1.xyz = _SharpenParameters.xxx * r1.xyz;
  r1.xyz = r1.xyz * float3(2.71828198,2.71828198,2.71828198) + r5.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r1.xyz = r1.xyz / r0.zzz;
  r1.w = max(r1.y, r1.z);
  r1.w = max(r1.x, r1.w);
  r1.w = 1 + r1.w;
  r1.w = 1 / r1.w;
  r3.xyz = r1.xyz * r1.www + r3.xyz;
  r1.xyz = r1.xyz * r1.www;
  r3.xyz = float3(0.200000003,0.200000003,0.200000003) * r3.xyz;
  r2.w = dot(r3.xyz, float3(0.0396819152,0.45802179,0.00609653955));
  r3.x = dot(r1.xyz, float3(0.0396819152,0.45802179,0.00609653955));
  r2.w = -r3.x + r2.w;
  r3.xyz = min(r0.xyw, r2.xyz);
  r0.xyw = max(r0.xyw, r2.xyz);
  r2.xyz = min(r6.xyz, r4.xyz);
  r4.xyz = max(r6.xyz, r4.xyz);
  r0.xyw = max(r4.xyz, r0.xyw);
  r0.xyw = max(r0.xyw, r1.xyz);
  r0.xyw = abs(r2.www) * float3(4,4,4) + r0.xyw;
  r2.xyz = min(r3.xyz, r2.xyz);
  r2.xyz = min(r2.xyz, r1.xyz);
  r2.xyz = -abs(r2.www) * float3(4,4,4) + r2.xyz;
  r3.xyz = -r2.xyz + r0.xyw;
  r0.xyw = r2.xyz + r0.xyw;
  r2.xyz = float3(0.5,0.5,0.5) * r0.xyw;
  r0.xyw = float3(0.5,0.5,0.5) * r3.xyz;
  r3.xyzw = _CameraMotionVectorsTexture.Sample(sampler_CameraMotionVectorsTexture, v1.zw).xyzw;
  r3.zw = v1.zw + -r3.xy;
  r3.x = dot(r3.xy, r3.xy);
  r3.x = sqrt(r3.x);
  r4.xyzw = _HistoryTex.Sample(sampler_HistoryTex, r3.zw).xyzw;
  r3.yzw = r4.xyz / r0.zzz;
  r2.w = r4.w;
  r4.x = max(r3.z, r3.w);
  r4.x = max(r4.x, r3.y);
  r4.x = 1 + r4.x;
  r4.x = 1 / r4.x;
  r5.xyz = r3.yzw * r4.xxx + -r2.xyz;
  r4.xyz = r4.xxx * r3.yzw;
  r0.xyw = r5.xyz / r0.xyw;
  r0.y = max(abs(r0.y), abs(r0.w));
  r0.x = max(abs(r0.x), r0.y);
  r5.w = 0;
  r5.xyzw = r5.xyzw / r0.xxxx;
  r0.x = cmp(1 < r0.x);
  r5.xyzw = r5.xyzw + r2.xyzw;
  r4.w = r2.w;
  r2.xyzw = r0.xxxx ? r5.xyzw : r4.xyzw;
  r0.x = -_MainTex_TexelSize.z * 0.00200000009 + r3.x;
  r0.y = _FinalBlendParameters.z * r3.x;
  r0.w = 0.00150000001 * _MainTex_TexelSize.z;
  r0.w = 1 / r0.w;
  r0.x = saturate(r0.x * r0.w);
  r0.w = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.w * r0.x;
  r1.w = min(1, r0.x);
  r3.xyzw = r2.xyzw + -r1.xyzw;
  r2.xyzw = asint(r2.xyzw) & int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000);
  r2.xyzw = cmp((int4)r2.xyzw != int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000));
  r0.xw = r2.zw ? r2.xy : 0;
  r0.x = (int)r0.w & (int)r0.x;
  r0.w = _FinalBlendParameters.y + -_FinalBlendParameters.x;
  r0.y = r0.y * r0.w + _FinalBlendParameters.x;
  r0.y = max(_FinalBlendParameters.y, r0.y);
  r0.y = min(_FinalBlendParameters.x, r0.y);
  r2.xyzw = r0.yyyy * r3.xyzw + r1.xyzw;
  r0.y = max(r2.y, r2.z);
  r0.y = max(r2.x, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = 1 / r0.y;
  r2.xyz = r2.xyz * r0.yyy;
  r0.y = max(r1.y, r1.z);
  r0.y = max(r1.x, r0.y);
  r0.y = 1 + -r0.y;
  r0.y = 1 / r0.y;
  r1.xyz = r1.xyz * r0.yyy;
  r1.xyzw = r0.xxxx ? r2.xyzw : r1.xyzw;
  r0.xyz = r1.xyz * r0.zzz;
  o0.xyz = r0.xyz;
  o1.xyz = r0.xyz;
  o0.w = r1.w;
  o1.w = 0.949999988 * r1.w;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		vs_d7d51214a8525a98_impl(v.position0, v.texcoord0, o0, o1);
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
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		ps_c666f9f818fa3291_impl(i.sv_position, i.texcoord0, o0, o1);
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

Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_ST;

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

// vs 4a840470d5c29811: 1 retail keyword combination(s)
void vs_4a840470d5c29811_impl(
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
  p1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = v1.xy;
  return;
}


// ps 7186d6556c8c55cb: 1 retail keyword combination(s)
void ps_7186d6556c8c55cb_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  o0.xyz = r0.xyz;
  o0.w = 0;
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
		vs_4a840470d5c29811_impl(v.position0, v.texcoord0, o0, o1, p1);
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
		ps_7186d6556c8c55cb_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
