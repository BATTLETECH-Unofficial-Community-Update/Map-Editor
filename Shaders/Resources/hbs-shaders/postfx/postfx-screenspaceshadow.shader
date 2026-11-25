Shader "Hidden/Post FX/Screen Space Shadow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Blend DstColor Zero
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _TAA_ACTIVE

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;
Texture2D _DitheringTex;
SamplerState sampler_DitheringTex;

float4 _MainTex_TexelSize;
float3 _BT_SunlightDirection;
float _RejectionDepth;
float _StepSize;
float _StartOffset;
int _MaxSteps;
float _MaxDistance;
float _ExpC;
float4 _DitheringTex_TexelSize;

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

// vs af96bfaa51f60302: 2 retail keyword combination(s)
void vs_af96bfaa51f60302_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1,
  inout float4 o2 : TEXCOORD2,
  inout float4 o3 : TEXCOORD3)
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
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r0.xyzw;
  r1.x = cmp(_MainTex_TexelSize.y < 0);
  r1.y = 1 + -v1.y;
  p1.y = r1.x ? r1.y : v1.y;
  float4 _pk0 = 0;
  _pk0.xyz = v1.xyx;
  o1.xy = _pk0.xy;
  p1.x = _pk0.z;
  r1.xyz = float3(unity_WorldToCamera[0][1], unity_WorldToCamera[1][1], unity_WorldToCamera[2][1]) * -_BT_SunlightDirection.yyy;
  r1.xyz = float3(unity_WorldToCamera[0][0], unity_WorldToCamera[1][0], unity_WorldToCamera[2][0]) * -_BT_SunlightDirection.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToCamera[0][2], unity_WorldToCamera[1][2], unity_WorldToCamera[2][2]) * -_BT_SunlightDirection.zzz + r1.xyz;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  o2.xyz = r1.xyz * r1.www;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o3.zw = r0.zw;
  o3.xy = r1.xw + r1.zz;
  return;
}


// ps 73e6e741683e13aa: 1 retail keyword combination(s)
void ps_73e6e741683e13aa_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, w1.xy, 0).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = w1.xy;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = float3(1,1,-1) * r0.xyz;
  r0.xyz = r0.xyz / r0.www;
  r0.w = cmp(_MaxDistance < r0.z);
  [branch] if (r0.w != 0) {
    o0.xyzw = float4(1,1,1,1);
    return;
  }
  r0.w = -0.199999988 * _MaxDistance;
  r1.x = -_MaxDistance + r0.z;
  r0.w = 1 / r0.w;
  r0.w = saturate(r1.x * r0.w);
  r1.x = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.x * r0.w;
  r1.xy = float2(-0.5,-0.5) + w1.xy;
  r1.xy = abs(r1.xy) + abs(r1.xy);
  r1.xy = r1.xy * r1.xy;
  r1.xy = r1.xy * r1.xy;
  r1.xy = r1.xy * r1.xy;
  r1.x = dot(r1.xy, r1.xy);
  r1.x = 1 + -r1.x;
  r1.x = max(0, r1.x);
  r0.w = r1.x * r0.w;
  r1.xyzw = _CameraGBufferTexture2.SampleLevel(sampler_CameraGBufferTexture2, w1.xy, 0).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.xyz = float3(unity_WorldToCamera[0][1], unity_WorldToCamera[1][1], unity_WorldToCamera[2][1]) * r1.yyy;
  r1.xyw = float3(unity_WorldToCamera[0][0], unity_WorldToCamera[1][0], unity_WorldToCamera[2][0]) * r1.xxx + r2.xyz;
  r1.xyz = float3(unity_WorldToCamera[0][2], unity_WorldToCamera[1][2], unity_WorldToCamera[2][2]) * r1.zzz + r1.xyw;
  r1.w = saturate(-r1.z);
  r1.w = 1 + -r1.w;
  r1.w = r1.w * r1.w;
  r1.w = r1.w * 3 + 1;
  r2.x = saturate(r0.z / _MaxDistance);
  r2.x = r2.x * r2.x;
  r2.y = 0.5 + -_StartOffset;
  r2.y = r2.x * r2.y + _StartOffset;
  r0.xyz = r1.xyz * r2.yyy + r0.xyz;
  r1.x = r2.x * 0.230769217 + 0.769230783;
  r1.xw = float2(_StepSize, _RejectionDepth) * r1.xw;
  r1.y = asint(_MaxSteps);
  r1.y = 1 / r1.y;
  r1.x = r1.x * r1.y;
  r1.x = 10 * r1.x;
  r1.yz = float2(1,0);
  [loop] while (true) {
    r2.x = cmp((int)r1.z >= asint(_MaxSteps));
    [branch] if (r2.x != 0) break;
    r2.x = (int)r1.z;
    r2.x = r2.x * r1.x;
    r2.xyz = v2.xyz * r2.xxx + r0.xyz;
    r3.xyz = float3(unity_CameraProjection[0][1], unity_CameraProjection[1][1], unity_CameraProjection[3][1]) * r2.yyy;
    r2.xyw = float3(unity_CameraProjection[0][0], unity_CameraProjection[1][0], unity_CameraProjection[3][0]) * r2.xxx + r3.xyz;
    r2.xyw = float3(unity_CameraProjection[0][2], unity_CameraProjection[1][2], unity_CameraProjection[3][2]) * -r2.zzz + r2.xyw;
    r2.xyw = float3(unity_CameraProjection[0][3], unity_CameraProjection[1][3], unity_CameraProjection[3][3]) + r2.xyw;
    r2.xy = r2.xy / r2.ww;
    r3.xy = float2(1,1) + r2.xy;
    r2.xy = cmp(r3.xy < float2(0,0));
    r2.x = (int)r2.y | (int)r2.x;
    r2.yw = cmp(float2(2,2) < r3.xy);
    r2.y = (int)r2.w | (int)r2.y;
    r2.x = (int)r2.y | (int)r2.x;
    [branch] if (r2.x != 0) {
      break;
    }
    r2.xy = float2(0.5,0.5) * r3.xy;
    r4.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r2.xy, 0).xyzw;
    r3.z = 1 + -r4.x;
    r2.xyw = r3.xyz * float3(1,1,2) + float3(-1,-1,-1);
    r3.xy = float2(unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r2.yy;
    r2.xy = float2(unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r2.xx + r3.xy;
    r2.xy = float2(unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r2.ww + r2.xy;
    r2.xy = float2(unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r2.xy;
    r2.x = -r2.x / r2.y;
    r2.x = r2.z + -r2.x;
    r2.y = cmp(0 < r2.x);
    r2.z = cmp(r2.x < r1.w);
    r2.y = r2.z ? r2.y : 0;
    r2.x = -_ExpC * r2.x;
    r2.x = 1.44269502 * r2.x;
    r2.x = exp2(r2.x);
    r2.x = r2.x * r1.y;
    r2.x = r2.y ? r2.x : r1.y;
    r2.y = cmp(r2.x < 0.00999999978);
    [branch] if (r2.y != 0) {
      r1.y = r2.x;
      break;
    }
    r1.y = r2.x;
    r1.z = (int)r1.z + 1;
  }
  r0.x = -1 + r1.y;
  o0.xyzw = r0.wwww * r0.xxxx + float4(1,1,1,1);
  return;
}


// ps a172865534ad3639: 1 retail keyword combination(s)
void ps_a172865534ad3639_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, w1.xy, 0).xyzw;
  r0.z = 1 + -r0.x;
  r0.xy = w1.xy;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r0.xyzw;
  r0.xyz = float3(1,1,-1) * r0.xyz;
  r0.xyz = r0.xyz / r0.www;
  r0.w = cmp(_MaxDistance < r0.z);
  [branch] if (r0.w != 0) {
    o0.xyzw = float4(1,1,1,1);
    return;
  }
  r0.w = -0.199999988 * _MaxDistance;
  r1.x = -_MaxDistance + r0.z;
  r0.w = 1 / r0.w;
  r0.w = saturate(r1.x * r0.w);
  r1.x = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = r1.x * r0.w;
  r1.xy = float2(-0.5,-0.5) + w1.xy;
  r1.xy = abs(r1.xy) + abs(r1.xy);
  r1.xy = r1.xy * r1.xy;
  r1.xy = r1.xy * r1.xy;
  r1.xy = r1.xy * r1.xy;
  r1.x = dot(r1.xy, r1.xy);
  r1.x = 1 + -r1.x;
  r1.x = max(0, r1.x);
  r0.w = r1.x * r0.w;
  r1.xyzw = _CameraGBufferTexture2.SampleLevel(sampler_CameraGBufferTexture2, w1.xy, 0).xyzw;
  r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.xyz = float3(unity_WorldToCamera[0][1], unity_WorldToCamera[1][1], unity_WorldToCamera[2][1]) * r1.yyy;
  r1.xyw = float3(unity_WorldToCamera[0][0], unity_WorldToCamera[1][0], unity_WorldToCamera[2][0]) * r1.xxx + r2.xyz;
  r1.xyz = float3(unity_WorldToCamera[0][2], unity_WorldToCamera[1][2], unity_WorldToCamera[2][2]) * r1.zzz + r1.xyw;
  r1.w = saturate(-r1.z);
  r1.w = 1 + -r1.w;
  r1.w = r1.w * r1.w;
  r1.w = r1.w * 3 + 1;
  r2.xy = v3.xy / v3.ww;
  r2.zw = _ScreenParams.xy * _DitheringTex_TexelSize.xy;
  r2.xy = r2.xy * r2.zw;
  r2.xyzw = _DitheringTex.Sample(sampler_DitheringTex, r2.xy).xyzw;
  r2.x = r2.w * 2 + -1;
  r2.z = r2.x * 0.100000001 + v2.z;
  r2.xy = v2.xy;
  r3.x = dot(r2.xyz, r2.xyz);
  r3.x = rsqrt(r3.x);
  r2.xyz = r3.xxx * r2.xyz;
  r2.w = r2.w * 0.0999999642 + 0.949999988;
  r3.x = saturate(r0.z / _MaxDistance);
  r3.x = r3.x * r3.x;
  r3.y = 0.5 + -_StartOffset;
  r3.y = r3.x * r3.y + _StartOffset;
  r0.xyz = r1.xyz * r3.yyy + r0.xyz;
  r1.x = r3.x * 0.230769217 + 0.769230783;
  r1.xw = float2(_StepSize, _RejectionDepth) * r1.xw;
  r1.y = asint(_MaxSteps);
  r1.y = 1 / r1.y;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r2.w;
  r1.x = 10 * r1.x;
  r1.yz = float2(1,0);
  [loop] while (true) {
    r2.w = cmp((int)r1.z >= asint(_MaxSteps));
    [branch] if (r2.w != 0) break;
    r2.w = (int)r1.z;
    r2.w = r2.w * r1.x;
    r3.xyz = r2.xyz * r2.www + r0.xyz;
    r4.xyz = float3(unity_CameraProjection[0][1], unity_CameraProjection[1][1], unity_CameraProjection[3][1]) * r3.yyy;
    r3.xyw = float3(unity_CameraProjection[0][0], unity_CameraProjection[1][0], unity_CameraProjection[3][0]) * r3.xxx + r4.xyz;
    r3.xyw = float3(unity_CameraProjection[0][2], unity_CameraProjection[1][2], unity_CameraProjection[3][2]) * -r3.zzz + r3.xyw;
    r3.xyw = float3(unity_CameraProjection[0][3], unity_CameraProjection[1][3], unity_CameraProjection[3][3]) + r3.xyw;
    r3.xy = r3.xy / r3.ww;
    r4.xy = float2(1,1) + r3.xy;
    r3.xy = cmp(r4.xy < float2(0,0));
    r2.w = (int)r3.y | (int)r3.x;
    r3.xy = cmp(float2(2,2) < r4.xy);
    r3.x = (int)r3.y | (int)r3.x;
    r2.w = (int)r2.w | (int)r3.x;
    [branch] if (r2.w != 0) {
      break;
    }
    r3.xy = float2(0.5,0.5) * r4.xy;
    r5.xyzw = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, r3.xy, 0).xyzw;
    r4.z = 1 + -r5.x;
    r3.xyw = r4.xyz * float3(1,1,2) + float3(-1,-1,-1);
    r4.xy = float2(unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r3.yy;
    r3.xy = float2(unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r3.xx + r4.xy;
    r3.xy = float2(unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r3.ww + r3.xy;
    r3.xy = float2(unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r3.xy;
    r2.w = -r3.x / r3.y;
    r2.w = r3.z + -r2.w;
    r3.x = cmp(0 < r2.w);
    r3.y = cmp(r2.w < r1.w);
    r3.x = r3.y ? r3.x : 0;
    r2.w = -_ExpC * r2.w;
    r2.w = 1.44269502 * r2.w;
    r2.w = exp2(r2.w);
    r2.w = r2.w * r1.y;
    r2.w = r3.x ? r2.w : r1.y;
    r3.x = cmp(r2.w < 0.00999999978);
    [branch] if (r3.x != 0) {
      r1.y = r2.w;
      break;
    }
    r1.y = r2.w;
    r1.z = (int)r1.z + 1;
  }
  r0.x = -1 + r1.y;
  o0.xyzw = r0.wwww * r0.xxxx + float4(1,1,1,1);
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
		float4 o2 = 0;
		float4 o3 = 0;
		vs_af96bfaa51f60302_impl(v.position0, v.texcoord0.xy, o0, o1, p1, o2, o3);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
		o.texcoord2 = o2;
		o.texcoord3 = o3;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_73e6e741683e13aa_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_a172865534ad3639_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, i.texcoord2, i.texcoord3, o0);
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
			Blend DstColor Zero
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

// vs 3d618cd305009673: 1 retail keyword combination(s)
void vs_3d618cd305009673_impl(
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


// ps 077c727e4bd5493c: 1 retail keyword combination(s)
void ps_077c727e4bd5493c_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = _MainTex.Sample(sampler_MainTex, v1.xy).xyzw;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float2 o1 = 0;
		vs_3d618cd305009673_impl(v.position0, v.texcoord0.xy, o0, o1);
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
		ps_077c727e4bd5493c_impl(i.sv_position, i.texcoord0.xy, o0);
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
