Shader "Unlit/BT-Ice9"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_HeightTex ("Ice Height Texture", 2D) = "black" {}
		_MinSamples ("Minimum Samples", Float) = 4
		_MaxSamples ("Maximum Samples", Float) = 16
		_Extinction ("Extinction", Float) = 1
		_HeightScale ("Height Scale", Float) = 1
		_RefactionFactor ("Refraction Factor", Range(0,1)) = 0.5
		_BlueNoiseTex ("Blue Noise Texture", 2D) = "grey" {}
		_G ("G Factor", Range(-1,1)) = 0
		_IceColor ("Ice Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			Blend One One
			ZWrite Off
			Offset 0, -1

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _BT_FOGOFWAR
			#pragma multi_compile _ _EFFECTS_LOW
			#pragma multi_compile _ _EFFECTS_MED
			#pragma multi_compile _ _TAA_ACTIVE

#define cmp -

Texture2D _CameraGBufferTexture1;
SamplerState sampler_CameraGBufferTexture1;
Texture2D _BlueNoiseTex;
SamplerState sampler_BlueNoiseTex;
Texture2D _DitheringTex;
SamplerState sampler_DitheringTex;
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;
Texture2D _HeightTex;
SamplerState sampler_HeightTex;
Texture2D _BT_TerrainHeight;
SamplerState sampler_BT_TerrainHeight;
Texture2D _FilteredShadowmap;
SamplerState sampler_FilteredShadowmap;
Texture2D _TransmittanceLUT;
SamplerState sampler_TransmittanceLUT;
Texture2D _FOWGridTexture;
SamplerState sampler_FOWGridTexture;
Texture2D _BT_FogOfWar;
SamplerState sampler_BT_FogOfWar;

float4 BT_SHAr;
float4 BT_SHAg;
float4 BT_SHAb;
float4 BT_SHC;
float4 _BlueNoiseTex_TexelSize;
float _MinSamples;
float _MaxSamples;
float _Extinction;
float _HeightScale;
float3 _BT_SunlightDirection;
float _BT_SunlightIntensity;
float4 _BT_SunlightColor;
float _G;
float3 _IceColor;
float _C;
float4 _DitheringTex_TexelSize;
float _BT_Exposure_Value;
float4 _SurveyedSettings;
float4 _RevealedSettings;
float3 _GridColor;
float _FOWGridScale;
float4 _FogOfWarSettings;
float4 _FogGridFade;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 tangent0 : TANGENT0;
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

// vs 078b47b278cf9ea3: 12 retail keyword combination(s)
void vs_078b47b278cf9ea3_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  float4 v3 : TANGENT0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(0,0.100000001,0) + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r0.xyzw;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v0.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v0.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v0.zzz + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r1.xyz;
  o1.xyz = r1.xyz;
  o2.xyz = -_WorldSpaceCameraPos.xyz + r1.xyz;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o3.zw = r0.zw;
  o3.xy = r1.xw + r1.zz;
  return;
}


// ps b0d185a7160fe1d5: 1 retail keyword combination(s)
void ps_b0d185a7160fe1d5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.z = dot(v2.xyz, v2.xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = v2.xyz * r0.zzz;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r0.xy).xyzw;
  r0.zw = _ScreenParams.xy * r0.xy;
  r0.zw = _BlueNoiseTex_TexelSize.xy * r0.zw;
  r3.xyzw = _BlueNoiseTex.Sample(sampler_BlueNoiseTex, r0.zw).xyzw;
  r2.xzw = -r3.www * r1.xyz;
  r2.xzw = r2.xzw * float3(0.75,0.75,0.75) + v1.xyz;
  r0.zw = float2(0.00999999978,0.00999999978) * r2.xw;
  r3.xy = ddx(r0.zw);
  r0.zw = ddy(r0.zw);
  r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = 5 / -r1.y;
  r0.x = min(5, r0.x);
  r0.y = saturate(-r1.y);
  r1.w = _MinSamples + -_MaxSamples;
  r0.y = r0.y * r1.w + _MaxSamples;
  r0.x = r0.x / r0.y;
  r1.w = dot(r1.xyz, r4.xyz);
  r3.z = -r1.w * r1.w + 1;
  r3.z = -r3.z * 0.48999998 + 1;
  r3.w = sqrt(r3.z);
  r1.w = r1.w * 0.699999988 + r3.w;
  r3.z = cmp(r3.z >= 0);
  r4.xyz = r1.www * r4.xyz;
  r4.xyz = r1.xyz * float3(0.699999988,0.699999988,0.699999988) + -r4.xyz;
  r4.xyz = r3.zzz ? r4.xyz : 0;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  r0.y = (int)r0.y;
  r5.xyz = v1.xyz;
  r1.w = 0;
  [loop] while (true) {
    r3.z = cmp((int)r1.w >= (int)r0.y);
    [branch] if (r3.z != 0) break;
    r3.zw = float2(0.00999999978,0.00999999978) * r5.xz;
    r6.xyzw = _HeightTex.SampleGrad(sampler_HeightTex, r3.zw, r3.xy, r0.zw).xyzw;
    r3.z = _HeightScale * r6.x;
    r6.xy = float2(1024,1024) + r5.xz;
    r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
    r6.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r6.xy, 0).xyzw;
    r3.w = -r5.y + r2.z;
    r3.z = cmp(r3.z < r3.w);
    r3.w = cmp(r5.y < r6.x);
    r3.z = (int)r3.w | (int)r3.z;
    [branch] if (r3.z != 0) {
      break;
    }
    r5.xyz = r4.xyz * r0.xxx + r5.xyz;
    r1.w = (int)r1.w + 1;
  }
  r0.x = max(9.99999997e-007, _Extinction);
  r0.yzw = -r5.xyz + r2.xzw;
  r0.y = dot(r0.yzw, r0.yzw);
  r0.y = sqrt(r0.y);
  r0.x = -r0.x * r0.y;
  r0.x = 1.44269502 * r0.x;
  r0.x = exp2(r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, r1.xyz);
  r0.z = 1 + -_G;
  r0.z = r0.z * r0.z;
  r0.w = _G * _G + 1;
  r0.y = dot(r0.yy, _G.xx);
  r0.y = r0.w + -r0.y;
  r0.y = log2(r0.y);
  r0.y = 1.5 * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 12.566371 * r0.y;
  r0.y = r0.z / r0.y;
  r1.xyz = _IceColor.xyz * _BT_SunlightColor.xyz;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r2.xzw;
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r2.xzw;
  r5.xyz = -unity_ShadowSplitSpheres[2].xyz + r2.xzw;
  r6.xyz = -unity_ShadowSplitSpheres[3].xyz + r2.xzw;
  r3.x = dot(r3.xyz, r3.xyz);
  r3.y = dot(r4.xyz, r4.xyz);
  r3.z = dot(r5.xyz, r5.xyz);
  r3.w = dot(r6.xyz, r6.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyz = r4.yzw + r3.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r4.yzw = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r2.zzz;
  r4.yzw = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r2.xxx + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r2.www + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r4.yzw;
  r5.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r2.zzz;
  r5.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r2.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r2.www + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r5.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r2.zzz;
  r6.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r2.xxx + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r2.www + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r6.xyz;
  r7.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r2.zzz;
  r7.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r2.xxx + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r2.www + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xzw;
  r5.xyz = r5.xyz * r3.xxx;
  r4.xyz = r4.yzw * r4.xxx + r5.xyz;
  r3.xyw = r6.xyz * r3.yyy + r4.xyz;
  r2.xzw = r2.xzw * r3.zzz + r3.xyw;
  r3.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r2.xz, 0).xyzw;
  r0.z = _C * r2.w;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = saturate(r0.z / r3.x);
  r1.xyz = r1.xyz * r0.zzz;
  r3.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r3.xy).xyzw;
  r2.xzw = r3.xyz * r3.www;
  r0.yzw = r2.xzw * r0.yyy;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xzw = -BT_SHC.xyz + r3.xyz;
  r2.xzw = float3(0.200000003,0.200000003,0.200000003) * r2.xzw;
  r0.yzw = r1.xyz * r0.yzw + r2.xzw;
  r0.x = r0.x * r2.y;
  o0.xyz = r0.yzw * r0.xxx;
  o0.w = 0;
  return;
}


// ps 470e89703a1b0a3b: 1 retail keyword combination(s)
void ps_470e89703a1b0a3b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.z = dot(v2.xyz, v2.xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = v2.xyz * r0.zzz;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r0.xy).xyzw;
  r0.zw = _ScreenParams.xy * r0.xy;
  r0.zw = _DitheringTex_TexelSize.xy * r0.zw;
  r3.xyzw = _DitheringTex.Sample(sampler_DitheringTex, r0.zw).xyzw;
  r0.z = r3.w * 2 + -1;
  r2.xzw = r1.xyz * r0.zzz + v1.xyz;
  r0.zw = float2(0.00999999978,0.00999999978) * r2.xw;
  r3.xy = ddx(r0.zw);
  r0.zw = ddy(r0.zw);
  r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = 5 / -r1.y;
  r0.x = min(5, r0.x);
  r0.y = saturate(-r1.y);
  r1.w = _MinSamples + -_MaxSamples;
  r0.y = r0.y * r1.w + _MaxSamples;
  r0.x = r0.x / r0.y;
  r1.w = dot(r1.xyz, r4.xyz);
  r3.z = -r1.w * r1.w + 1;
  r3.z = -r3.z * 0.48999998 + 1;
  r3.w = sqrt(r3.z);
  r1.w = r1.w * 0.699999988 + r3.w;
  r3.z = cmp(r3.z >= 0);
  r4.xyz = r1.www * r4.xyz;
  r4.xyz = r1.xyz * float3(0.699999988,0.699999988,0.699999988) + -r4.xyz;
  r4.xyz = r3.zzz ? r4.xyz : 0;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  r0.y = (int)r0.y;
  r5.xyz = v1.xyz;
  r1.w = 0;
  [loop] while (true) {
    r3.z = cmp((int)r1.w >= (int)r0.y);
    [branch] if (r3.z != 0) break;
    r3.zw = float2(0.00999999978,0.00999999978) * r5.xz;
    r6.xyzw = _HeightTex.SampleGrad(sampler_HeightTex, r3.zw, r3.xy, r0.zw).xyzw;
    r3.z = _HeightScale * r6.x;
    r6.xy = float2(1024,1024) + r5.xz;
    r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
    r6.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r6.xy, 0).xyzw;
    r3.w = -r5.y + r2.z;
    r3.z = cmp(r3.z < r3.w);
    r3.w = cmp(r5.y < r6.x);
    r3.z = (int)r3.w | (int)r3.z;
    [branch] if (r3.z != 0) {
      break;
    }
    r5.xyz = r4.xyz * r0.xxx + r5.xyz;
    r1.w = (int)r1.w + 1;
  }
  r0.x = max(9.99999997e-007, _Extinction);
  r0.yzw = -r5.xyz + r2.xzw;
  r0.y = dot(r0.yzw, r0.yzw);
  r0.y = sqrt(r0.y);
  r0.x = -r0.x * r0.y;
  r0.x = 1.44269502 * r0.x;
  r0.x = exp2(r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, r1.xyz);
  r0.z = 1 + -_G;
  r0.z = r0.z * r0.z;
  r0.w = _G * _G + 1;
  r0.y = dot(r0.yy, _G.xx);
  r0.y = r0.w + -r0.y;
  r0.y = log2(r0.y);
  r0.y = 1.5 * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 12.566371 * r0.y;
  r0.y = r0.z / r0.y;
  r1.xyz = _IceColor.xyz * _BT_SunlightColor.xyz;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r2.xzw;
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r2.xzw;
  r5.xyz = -unity_ShadowSplitSpheres[2].xyz + r2.xzw;
  r6.xyz = -unity_ShadowSplitSpheres[3].xyz + r2.xzw;
  r3.x = dot(r3.xyz, r3.xyz);
  r3.y = dot(r4.xyz, r4.xyz);
  r3.z = dot(r5.xyz, r5.xyz);
  r3.w = dot(r6.xyz, r6.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyz = r4.yzw + r3.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r4.yzw = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r2.zzz;
  r4.yzw = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r2.xxx + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r2.www + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r4.yzw;
  r5.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r2.zzz;
  r5.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r2.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r2.www + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r5.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r2.zzz;
  r6.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r2.xxx + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r2.www + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r6.xyz;
  r7.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r2.zzz;
  r7.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r2.xxx + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r2.www + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xzw;
  r5.xyz = r5.xyz * r3.xxx;
  r4.xyz = r4.yzw * r4.xxx + r5.xyz;
  r3.xyw = r6.xyz * r3.yyy + r4.xyz;
  r2.xzw = r2.xzw * r3.zzz + r3.xyw;
  r3.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r2.xz, 0).xyzw;
  r0.z = _C * r2.w;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = saturate(r0.z / r3.x);
  r1.xyz = r1.xyz * r0.zzz;
  r3.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r3.xy).xyzw;
  r2.xzw = r3.xyz * r3.www;
  r0.yzw = r2.xzw * r0.yyy;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xzw = -BT_SHC.xyz + r3.xyz;
  r2.xzw = float3(0.200000003,0.200000003,0.200000003) * r2.xzw;
  r0.yzw = r1.xyz * r0.yzw + r2.xzw;
  r0.x = r0.x * r2.y;
  o0.xyz = r0.yzw * r0.xxx;
  o0.w = 0;
  return;
}


// ps 5687670b97aea3d4: 1 retail keyword combination(s)
void ps_5687670b97aea3d4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.z = dot(v2.xyz, v2.xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = v2.xyz * r0.zzz;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r0.xy).xyzw;
  r0.zw = _ScreenParams.xy * r0.xy;
  r0.zw = _BlueNoiseTex_TexelSize.xy * r0.zw;
  r3.xyzw = _BlueNoiseTex.Sample(sampler_BlueNoiseTex, r0.zw).xyzw;
  r2.xzw = -r3.www * r1.xyz;
  r2.xzw = r2.xzw * float3(0.75,0.75,0.75) + v1.xyz;
  r0.zw = float2(0.00999999978,0.00999999978) * r2.xw;
  r3.xy = ddx(r0.zw);
  r0.zw = ddy(r0.zw);
  r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = 5 / -r1.y;
  r0.x = min(5, r0.x);
  r0.y = saturate(-r1.y);
  r1.w = _MinSamples + -_MaxSamples;
  r0.y = r0.y * r1.w + _MaxSamples;
  r0.y = 0.5 * r0.y;
  r0.x = r0.x / r0.y;
  r1.w = dot(r1.xyz, r4.xyz);
  r3.z = -r1.w * r1.w + 1;
  r3.z = -r3.z * 0.48999998 + 1;
  r3.w = sqrt(r3.z);
  r1.w = r1.w * 0.699999988 + r3.w;
  r3.z = cmp(r3.z >= 0);
  r4.xyz = r1.www * r4.xyz;
  r4.xyz = r1.xyz * float3(0.699999988,0.699999988,0.699999988) + -r4.xyz;
  r4.xyz = r3.zzz ? r4.xyz : 0;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  r0.y = (int)r0.y;
  r5.xyz = v1.xyz;
  r1.w = 0;
  [loop] while (true) {
    r3.z = cmp((int)r1.w >= (int)r0.y);
    [branch] if (r3.z != 0) break;
    r3.zw = float2(0.00999999978,0.00999999978) * r5.xz;
    r6.xyzw = _HeightTex.SampleGrad(sampler_HeightTex, r3.zw, r3.xy, r0.zw).xyzw;
    r3.z = _HeightScale * r6.x;
    r6.xy = float2(1024,1024) + r5.xz;
    r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
    r6.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r6.xy, 0).xyzw;
    r3.w = -r5.y + r2.z;
    r3.z = cmp(r3.z < r3.w);
    r3.w = cmp(r5.y < r6.x);
    r3.z = (int)r3.w | (int)r3.z;
    [branch] if (r3.z != 0) {
      break;
    }
    r5.xyz = r4.xyz * r0.xxx + r5.xyz;
    r1.w = (int)r1.w + 1;
  }
  r0.x = max(9.99999997e-007, _Extinction);
  r0.yzw = -r5.xyz + r2.xzw;
  r0.y = dot(r0.yzw, r0.yzw);
  r0.y = sqrt(r0.y);
  r0.x = -r0.x * r0.y;
  r0.x = 1.44269502 * r0.x;
  r0.x = exp2(r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, r1.xyz);
  r0.z = 1 + -_G;
  r0.z = r0.z * r0.z;
  r0.w = _G * _G + 1;
  r0.y = dot(r0.yy, _G.xx);
  r0.y = r0.w + -r0.y;
  r0.y = log2(r0.y);
  r0.y = 1.5 * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 12.566371 * r0.y;
  r0.y = r0.z / r0.y;
  r1.xyz = _IceColor.xyz * _BT_SunlightColor.xyz;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r2.xzw;
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r2.xzw;
  r5.xyz = -unity_ShadowSplitSpheres[2].xyz + r2.xzw;
  r6.xyz = -unity_ShadowSplitSpheres[3].xyz + r2.xzw;
  r3.x = dot(r3.xyz, r3.xyz);
  r3.y = dot(r4.xyz, r4.xyz);
  r3.z = dot(r5.xyz, r5.xyz);
  r3.w = dot(r6.xyz, r6.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyz = r4.yzw + r3.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r4.yzw = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r2.zzz;
  r4.yzw = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r2.xxx + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r2.www + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r4.yzw;
  r5.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r2.zzz;
  r5.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r2.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r2.www + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r5.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r2.zzz;
  r6.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r2.xxx + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r2.www + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r6.xyz;
  r7.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r2.zzz;
  r7.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r2.xxx + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r2.www + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xzw;
  r5.xyz = r5.xyz * r3.xxx;
  r4.xyz = r4.yzw * r4.xxx + r5.xyz;
  r3.xyw = r6.xyz * r3.yyy + r4.xyz;
  r2.xzw = r2.xzw * r3.zzz + r3.xyw;
  r3.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r2.xz, 0).xyzw;
  r0.z = _C * r2.w;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = saturate(r0.z / r3.x);
  r1.xyz = r1.xyz * r0.zzz;
  r3.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r3.xy).xyzw;
  r2.xzw = r3.xyz * r3.www;
  r0.yzw = r2.xzw * r0.yyy;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xzw = -BT_SHC.xyz + r3.xyz;
  r2.xzw = float3(0.200000003,0.200000003,0.200000003) * r2.xzw;
  r0.yzw = r1.xyz * r0.yzw + r2.xzw;
  r0.x = r0.x * r2.y;
  o0.xyz = r0.yzw * r0.xxx;
  o0.w = 0;
  return;
}


// ps 9d70a19555c38056: 1 retail keyword combination(s)
void ps_9d70a19555c38056_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.z = dot(v2.xyz, v2.xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = v2.xyz * r0.zzz;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r0.xy).xyzw;
  r0.zw = _ScreenParams.xy * r0.xy;
  r0.zw = _DitheringTex_TexelSize.xy * r0.zw;
  r3.xyzw = _DitheringTex.Sample(sampler_DitheringTex, r0.zw).xyzw;
  r0.z = r3.w * 2 + -1;
  r2.xzw = r1.xyz * r0.zzz + v1.xyz;
  r0.zw = float2(0.00999999978,0.00999999978) * r2.xw;
  r3.xy = ddx(r0.zw);
  r0.zw = ddy(r0.zw);
  r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = 5 / -r1.y;
  r0.x = min(5, r0.x);
  r0.y = saturate(-r1.y);
  r1.w = _MinSamples + -_MaxSamples;
  r0.y = r0.y * r1.w + _MaxSamples;
  r0.y = 0.5 * r0.y;
  r0.x = r0.x / r0.y;
  r1.w = dot(r1.xyz, r4.xyz);
  r3.z = -r1.w * r1.w + 1;
  r3.z = -r3.z * 0.48999998 + 1;
  r3.w = sqrt(r3.z);
  r1.w = r1.w * 0.699999988 + r3.w;
  r3.z = cmp(r3.z >= 0);
  r4.xyz = r1.www * r4.xyz;
  r4.xyz = r1.xyz * float3(0.699999988,0.699999988,0.699999988) + -r4.xyz;
  r4.xyz = r3.zzz ? r4.xyz : 0;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  r0.y = (int)r0.y;
  r5.xyz = v1.xyz;
  r1.w = 0;
  [loop] while (true) {
    r3.z = cmp((int)r1.w >= (int)r0.y);
    [branch] if (r3.z != 0) break;
    r3.zw = float2(0.00999999978,0.00999999978) * r5.xz;
    r6.xyzw = _HeightTex.SampleGrad(sampler_HeightTex, r3.zw, r3.xy, r0.zw).xyzw;
    r3.z = _HeightScale * r6.x;
    r6.xy = float2(1024,1024) + r5.xz;
    r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
    r6.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r6.xy, 0).xyzw;
    r3.w = -r5.y + r2.z;
    r3.z = cmp(r3.z < r3.w);
    r3.w = cmp(r5.y < r6.x);
    r3.z = (int)r3.w | (int)r3.z;
    [branch] if (r3.z != 0) {
      break;
    }
    r5.xyz = r4.xyz * r0.xxx + r5.xyz;
    r1.w = (int)r1.w + 1;
  }
  r0.x = max(9.99999997e-007, _Extinction);
  r0.yzw = -r5.xyz + r2.xzw;
  r0.y = dot(r0.yzw, r0.yzw);
  r0.y = sqrt(r0.y);
  r0.x = -r0.x * r0.y;
  r0.x = 1.44269502 * r0.x;
  r0.x = exp2(r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, r1.xyz);
  r0.z = 1 + -_G;
  r0.z = r0.z * r0.z;
  r0.w = _G * _G + 1;
  r0.y = dot(r0.yy, _G.xx);
  r0.y = r0.w + -r0.y;
  r0.y = log2(r0.y);
  r0.y = 1.5 * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 12.566371 * r0.y;
  r0.y = r0.z / r0.y;
  r1.xyz = _IceColor.xyz * _BT_SunlightColor.xyz;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r2.xzw;
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r2.xzw;
  r5.xyz = -unity_ShadowSplitSpheres[2].xyz + r2.xzw;
  r6.xyz = -unity_ShadowSplitSpheres[3].xyz + r2.xzw;
  r3.x = dot(r3.xyz, r3.xyz);
  r3.y = dot(r4.xyz, r4.xyz);
  r3.z = dot(r5.xyz, r5.xyz);
  r3.w = dot(r6.xyz, r6.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyz = r4.yzw + r3.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r4.yzw = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r2.zzz;
  r4.yzw = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r2.xxx + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r2.www + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r4.yzw;
  r5.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r2.zzz;
  r5.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r2.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r2.www + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r5.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r2.zzz;
  r6.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r2.xxx + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r2.www + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r6.xyz;
  r7.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r2.zzz;
  r7.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r2.xxx + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r2.www + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xzw;
  r5.xyz = r5.xyz * r3.xxx;
  r4.xyz = r4.yzw * r4.xxx + r5.xyz;
  r3.xyw = r6.xyz * r3.yyy + r4.xyz;
  r2.xzw = r2.xzw * r3.zzz + r3.xyw;
  r3.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r2.xz, 0).xyzw;
  r0.z = _C * r2.w;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = saturate(r0.z / r3.x);
  r1.xyz = r1.xyz * r0.zzz;
  r3.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r3.xy).xyzw;
  r2.xzw = r3.xyz * r3.www;
  r0.yzw = r2.xzw * r0.yyy;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xzw = -BT_SHC.xyz + r3.xyz;
  r2.xzw = float3(0.200000003,0.200000003,0.200000003) * r2.xzw;
  r0.yzw = r1.xyz * r0.yzw + r2.xzw;
  r0.x = r0.x * r2.y;
  o0.xyz = r0.yzw * r0.xxx;
  o0.w = 0;
  return;
}


// ps 460a8a7c3f2a4238: 4 retail keyword combination(s)
void ps_460a8a7c3f2a4238_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = float4(0,0,0,0);
  return;
}


// ps e7fd9701af27abab: 1 retail keyword combination(s)
void ps_e7fd9701af27abab_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.z = dot(v2.xyz, v2.xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = v2.xyz * r0.zzz;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r0.xy).xyzw;
  r0.zw = _ScreenParams.xy * r0.xy;
  r0.zw = _BlueNoiseTex_TexelSize.xy * r0.zw;
  r3.xyzw = _BlueNoiseTex.Sample(sampler_BlueNoiseTex, r0.zw).xyzw;
  r2.xzw = -r3.www * r1.xyz;
  r2.xzw = r2.xzw * float3(0.75,0.75,0.75) + v1.xyz;
  r0.zw = float2(0.00999999978,0.00999999978) * r2.xw;
  r3.xy = ddx(r0.zw);
  r0.zw = ddy(r0.zw);
  r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = 5 / -r1.y;
  r0.x = min(5, r0.x);
  r0.y = saturate(-r1.y);
  r1.w = _MinSamples + -_MaxSamples;
  r0.y = r0.y * r1.w + _MaxSamples;
  r0.x = r0.x / r0.y;
  r1.w = dot(r1.xyz, r4.xyz);
  r3.z = -r1.w * r1.w + 1;
  r3.z = -r3.z * 0.48999998 + 1;
  r3.w = sqrt(r3.z);
  r1.w = r1.w * 0.699999988 + r3.w;
  r3.z = cmp(r3.z >= 0);
  r4.xyz = r1.www * r4.xyz;
  r4.xyz = r1.xyz * float3(0.699999988,0.699999988,0.699999988) + -r4.xyz;
  r4.xyz = r3.zzz ? r4.xyz : 0;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  r0.y = (int)r0.y;
  r5.xyz = v1.xyz;
  r1.w = 0;
  [loop] while (true) {
    r3.z = cmp((int)r1.w >= (int)r0.y);
    [branch] if (r3.z != 0) break;
    r3.zw = float2(0.00999999978,0.00999999978) * r5.xz;
    r6.xyzw = _HeightTex.SampleGrad(sampler_HeightTex, r3.zw, r3.xy, r0.zw).xyzw;
    r3.z = _HeightScale * r6.x;
    r6.xy = float2(1024,1024) + r5.xz;
    r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
    r6.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r6.xy, 0).xyzw;
    r3.w = -r5.y + r2.z;
    r3.z = cmp(r3.z < r3.w);
    r3.w = cmp(r5.y < r6.x);
    r3.z = (int)r3.w | (int)r3.z;
    [branch] if (r3.z != 0) {
      break;
    }
    r5.xyz = r4.xyz * r0.xxx + r5.xyz;
    r1.w = (int)r1.w + 1;
  }
  r0.x = max(9.99999997e-007, _Extinction);
  r0.yzw = -r5.xyz + r2.xzw;
  r0.y = dot(r0.yzw, r0.yzw);
  r0.y = sqrt(r0.y);
  r0.x = -r0.x * r0.y;
  r0.x = 1.44269502 * r0.x;
  r0.x = exp2(r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, r1.xyz);
  r0.z = 1 + -_G;
  r0.z = r0.z * r0.z;
  r0.w = _G * _G + 1;
  r0.y = dot(r0.yy, _G.xx);
  r0.y = r0.w + -r0.y;
  r0.y = log2(r0.y);
  r0.y = 1.5 * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 12.566371 * r0.y;
  r0.y = r0.z / r0.y;
  r1.xyz = _IceColor.xyz * _BT_SunlightColor.xyz;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r2.xzw;
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r2.xzw;
  r5.xyz = -unity_ShadowSplitSpheres[2].xyz + r2.xzw;
  r6.xyz = -unity_ShadowSplitSpheres[3].xyz + r2.xzw;
  r3.x = dot(r3.xyz, r3.xyz);
  r3.y = dot(r4.xyz, r4.xyz);
  r3.z = dot(r5.xyz, r5.xyz);
  r3.w = dot(r6.xyz, r6.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyz = r4.yzw + r3.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r4.yzw = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r2.zzz;
  r4.yzw = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r2.xxx + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r2.www + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r4.yzw;
  r5.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r2.zzz;
  r5.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r2.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r2.www + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r5.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r2.zzz;
  r6.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r2.xxx + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r2.www + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r6.xyz;
  r7.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r2.zzz;
  r7.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r2.xxx + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r2.www + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xzw;
  r5.xyz = r5.xyz * r3.xxx;
  r4.xyz = r4.yzw * r4.xxx + r5.xyz;
  r3.xyw = r6.xyz * r3.yyy + r4.xyz;
  r2.xzw = r2.xzw * r3.zzz + r3.xyw;
  r3.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r2.xz, 0).xyzw;
  r0.z = _C * r2.w;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = saturate(r0.z / r3.x);
  r1.xyz = r1.xyz * r0.zzz;
  r3.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r3.xy).xyzw;
  r2.xzw = r3.xyz * r3.www;
  r0.yzw = r2.xzw * r0.yyy;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xzw = -BT_SHC.xyz + r3.xyz;
  r2.xzw = float3(0.200000003,0.200000003,0.200000003) * r2.xzw;
  r0.yzw = r1.xyz * r0.yzw + r2.xzw;
  r0.x = r0.x * r2.y;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyzw = float4(0.5,0.5,2,8) * float4(_GridColor.x, _GridColor.y, _GridColor.z, _FOWGridScale);
  r0.w = -13 + _BT_Exposure_Value;
  r0.w = exp2(r0.w);
  r2.xy = v1.xz / r1.ww;
  r2.xy = frac(r2.xy);
  r2.xyzw = _FOWGridTexture.Sample(sampler_FOWGridTexture, r2.xy).xyzw;
  r2.xyz = -_WorldSpaceCameraPos.xyz + v1.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.w = sqrt(r1.w);
  r2.x = _FogGridFade.x + -_FogGridFade.y;
  r1.w = -_FogGridFade.y + r1.w;
  r2.x = 1 / r2.x;
  r1.w = saturate(r2.x * r1.w);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r1.w = r2.w * r1.w;
  r2.x = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r2.yzw = r0.xyz / r2.xxx;
  r2.yzw = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r2.yzw);
  r3.xy = float2(1024,1024) + v1.xz;
  r3.zw = float2(0.00048828125,0.00048828125) * r3.xy;
  r4.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r3.zw, 0).xyzw;
  r4.xyz = float3(-0.400000006,-0.400000006,-0.400000006) + r4.xyz;
  r4.xyz = saturate(float3(4.99999952,4.99999952,4.99999952) * r4.xyz);
  r5.xyz = r4.xyz * float3(-2,-2,-2) + float3(3,3,3);
  r4.xyz = r4.xyz * r4.xyz;
  r4.xyz = r5.xyz * r4.xyz;
  r5.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r3.zw, 2).xyzw;
  r5.xyz = float3(0.649999976,0.649999976,0.649999976) * r5.xyz;
  r4.xyz = r4.xyz * float3(0.349999994,0.349999994,0.349999994) + r5.xyz;
  r3.zw = cmp(float2(2048,2048) < r3.xy);
  r3.xy = cmp(r3.xy < float2(0,0));
  r3.x = (int)r3.x | (int)r3.z;
  r3.x = (int)r3.w | (int)r3.x;
  r3.x = (int)r3.y | (int)r3.x;
  r3.xyz = r3.xxx ? float3(0,1,0) : r4.xyz;
  r2.yzw = float3(-1,-1,-1) + r2.yzw;
  r4.xyz = _SurveyedSettings.zzz * r2.yzw + float3(1,1,1);
  r4.xyz = r4.xyz * r2.xxx;
  r4.xyz = r4.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r4.xyz = _FogOfWarSettings.zzz * r4.xyz + r0.xyz;
  r2.yzw = _RevealedSettings.zzz * r2.yzw + float3(1,1,1);
  r2.xyz = r2.yzw * r2.xxx;
  r2.xyz = r2.xyz * _RevealedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.www * r2.xyz + r0.xyz;
  r1.xyz = r1.xyz * r0.www + -r4.xyz;
  r1.xyz = r1.www * r1.xyz + r4.xyz;
  r2.xyz = r2.xyz * r3.zzz;
  r1.xyz = r1.xyz * r3.yyy + r2.xyz;
  r0.w = r3.x + r3.y;
  r0.w = saturate(r0.w + r3.z);
  r0.w = 1 + -r0.w;
  o0.xyz = r0.xyz * r0.www + r1.xyz;
  o0.w = 0;
  return;
}


// ps af051821fb152b77: 1 retail keyword combination(s)
void ps_af051821fb152b77_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.z = dot(v2.xyz, v2.xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = v2.xyz * r0.zzz;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r0.xy).xyzw;
  r0.zw = _ScreenParams.xy * r0.xy;
  r0.zw = _DitheringTex_TexelSize.xy * r0.zw;
  r3.xyzw = _DitheringTex.Sample(sampler_DitheringTex, r0.zw).xyzw;
  r0.z = r3.w * 2 + -1;
  r2.xzw = r1.xyz * r0.zzz + v1.xyz;
  r0.zw = float2(0.00999999978,0.00999999978) * r2.xw;
  r3.xy = ddx(r0.zw);
  r0.zw = ddy(r0.zw);
  r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = 5 / -r1.y;
  r0.x = min(5, r0.x);
  r0.y = saturate(-r1.y);
  r1.w = _MinSamples + -_MaxSamples;
  r0.y = r0.y * r1.w + _MaxSamples;
  r0.x = r0.x / r0.y;
  r1.w = dot(r1.xyz, r4.xyz);
  r3.z = -r1.w * r1.w + 1;
  r3.z = -r3.z * 0.48999998 + 1;
  r3.w = sqrt(r3.z);
  r1.w = r1.w * 0.699999988 + r3.w;
  r3.z = cmp(r3.z >= 0);
  r4.xyz = r1.www * r4.xyz;
  r4.xyz = r1.xyz * float3(0.699999988,0.699999988,0.699999988) + -r4.xyz;
  r4.xyz = r3.zzz ? r4.xyz : 0;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  r0.y = (int)r0.y;
  r5.xyz = v1.xyz;
  r1.w = 0;
  [loop] while (true) {
    r3.z = cmp((int)r1.w >= (int)r0.y);
    [branch] if (r3.z != 0) break;
    r3.zw = float2(0.00999999978,0.00999999978) * r5.xz;
    r6.xyzw = _HeightTex.SampleGrad(sampler_HeightTex, r3.zw, r3.xy, r0.zw).xyzw;
    r3.z = _HeightScale * r6.x;
    r6.xy = float2(1024,1024) + r5.xz;
    r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
    r6.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r6.xy, 0).xyzw;
    r3.w = -r5.y + r2.z;
    r3.z = cmp(r3.z < r3.w);
    r3.w = cmp(r5.y < r6.x);
    r3.z = (int)r3.w | (int)r3.z;
    [branch] if (r3.z != 0) {
      break;
    }
    r5.xyz = r4.xyz * r0.xxx + r5.xyz;
    r1.w = (int)r1.w + 1;
  }
  r0.x = max(9.99999997e-007, _Extinction);
  r0.yzw = -r5.xyz + r2.xzw;
  r0.y = dot(r0.yzw, r0.yzw);
  r0.y = sqrt(r0.y);
  r0.x = -r0.x * r0.y;
  r0.x = 1.44269502 * r0.x;
  r0.x = exp2(r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, r1.xyz);
  r0.z = 1 + -_G;
  r0.z = r0.z * r0.z;
  r0.w = _G * _G + 1;
  r0.y = dot(r0.yy, _G.xx);
  r0.y = r0.w + -r0.y;
  r0.y = log2(r0.y);
  r0.y = 1.5 * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 12.566371 * r0.y;
  r0.y = r0.z / r0.y;
  r1.xyz = _IceColor.xyz * _BT_SunlightColor.xyz;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r2.xzw;
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r2.xzw;
  r5.xyz = -unity_ShadowSplitSpheres[2].xyz + r2.xzw;
  r6.xyz = -unity_ShadowSplitSpheres[3].xyz + r2.xzw;
  r3.x = dot(r3.xyz, r3.xyz);
  r3.y = dot(r4.xyz, r4.xyz);
  r3.z = dot(r5.xyz, r5.xyz);
  r3.w = dot(r6.xyz, r6.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyz = r4.yzw + r3.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r4.yzw = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r2.zzz;
  r4.yzw = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r2.xxx + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r2.www + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r4.yzw;
  r5.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r2.zzz;
  r5.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r2.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r2.www + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r5.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r2.zzz;
  r6.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r2.xxx + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r2.www + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r6.xyz;
  r7.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r2.zzz;
  r7.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r2.xxx + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r2.www + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xzw;
  r5.xyz = r5.xyz * r3.xxx;
  r4.xyz = r4.yzw * r4.xxx + r5.xyz;
  r3.xyw = r6.xyz * r3.yyy + r4.xyz;
  r2.xzw = r2.xzw * r3.zzz + r3.xyw;
  r3.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r2.xz, 0).xyzw;
  r0.z = _C * r2.w;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = saturate(r0.z / r3.x);
  r1.xyz = r1.xyz * r0.zzz;
  r3.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r3.xy).xyzw;
  r2.xzw = r3.xyz * r3.www;
  r0.yzw = r2.xzw * r0.yyy;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xzw = -BT_SHC.xyz + r3.xyz;
  r2.xzw = float3(0.200000003,0.200000003,0.200000003) * r2.xzw;
  r0.yzw = r1.xyz * r0.yzw + r2.xzw;
  r0.x = r0.x * r2.y;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyzw = float4(0.5,0.5,2,8) * float4(_GridColor.x, _GridColor.y, _GridColor.z, _FOWGridScale);
  r0.w = -13 + _BT_Exposure_Value;
  r0.w = exp2(r0.w);
  r2.xy = v1.xz / r1.ww;
  r2.xy = frac(r2.xy);
  r2.xyzw = _FOWGridTexture.Sample(sampler_FOWGridTexture, r2.xy).xyzw;
  r2.xyz = -_WorldSpaceCameraPos.xyz + v1.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.w = sqrt(r1.w);
  r2.x = _FogGridFade.x + -_FogGridFade.y;
  r1.w = -_FogGridFade.y + r1.w;
  r2.x = 1 / r2.x;
  r1.w = saturate(r2.x * r1.w);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r1.w = r2.w * r1.w;
  r2.x = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r2.yzw = r0.xyz / r2.xxx;
  r2.yzw = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r2.yzw);
  r3.xy = float2(1024,1024) + v1.xz;
  r3.zw = float2(0.00048828125,0.00048828125) * r3.xy;
  r4.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r3.zw, 0).xyzw;
  r4.xyz = float3(-0.400000006,-0.400000006,-0.400000006) + r4.xyz;
  r4.xyz = saturate(float3(4.99999952,4.99999952,4.99999952) * r4.xyz);
  r5.xyz = r4.xyz * float3(-2,-2,-2) + float3(3,3,3);
  r4.xyz = r4.xyz * r4.xyz;
  r4.xyz = r5.xyz * r4.xyz;
  r5.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r3.zw, 2).xyzw;
  r5.xyz = float3(0.649999976,0.649999976,0.649999976) * r5.xyz;
  r4.xyz = r4.xyz * float3(0.349999994,0.349999994,0.349999994) + r5.xyz;
  r3.zw = cmp(float2(2048,2048) < r3.xy);
  r3.xy = cmp(r3.xy < float2(0,0));
  r3.x = (int)r3.x | (int)r3.z;
  r3.x = (int)r3.w | (int)r3.x;
  r3.x = (int)r3.y | (int)r3.x;
  r3.xyz = r3.xxx ? float3(0,1,0) : r4.xyz;
  r2.yzw = float3(-1,-1,-1) + r2.yzw;
  r4.xyz = _SurveyedSettings.zzz * r2.yzw + float3(1,1,1);
  r4.xyz = r4.xyz * r2.xxx;
  r4.xyz = r4.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r4.xyz = _FogOfWarSettings.zzz * r4.xyz + r0.xyz;
  r2.yzw = _RevealedSettings.zzz * r2.yzw + float3(1,1,1);
  r2.xyz = r2.yzw * r2.xxx;
  r2.xyz = r2.xyz * _RevealedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.www * r2.xyz + r0.xyz;
  r1.xyz = r1.xyz * r0.www + -r4.xyz;
  r1.xyz = r1.www * r1.xyz + r4.xyz;
  r2.xyz = r2.xyz * r3.zzz;
  r1.xyz = r1.xyz * r3.yyy + r2.xyz;
  r0.w = r3.x + r3.y;
  r0.w = saturate(r0.w + r3.z);
  r0.w = 1 + -r0.w;
  o0.xyz = r0.xyz * r0.www + r1.xyz;
  o0.w = 0;
  return;
}


// ps da9a65a73e8053f6: 1 retail keyword combination(s)
void ps_da9a65a73e8053f6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.z = dot(v2.xyz, v2.xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = v2.xyz * r0.zzz;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r0.xy).xyzw;
  r0.zw = _ScreenParams.xy * r0.xy;
  r0.zw = _BlueNoiseTex_TexelSize.xy * r0.zw;
  r3.xyzw = _BlueNoiseTex.Sample(sampler_BlueNoiseTex, r0.zw).xyzw;
  r2.xzw = -r3.www * r1.xyz;
  r2.xzw = r2.xzw * float3(0.75,0.75,0.75) + v1.xyz;
  r0.zw = float2(0.00999999978,0.00999999978) * r2.xw;
  r3.xy = ddx(r0.zw);
  r0.zw = ddy(r0.zw);
  r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = 5 / -r1.y;
  r0.x = min(5, r0.x);
  r0.y = saturate(-r1.y);
  r1.w = _MinSamples + -_MaxSamples;
  r0.y = r0.y * r1.w + _MaxSamples;
  r0.y = 0.5 * r0.y;
  r0.x = r0.x / r0.y;
  r1.w = dot(r1.xyz, r4.xyz);
  r3.z = -r1.w * r1.w + 1;
  r3.z = -r3.z * 0.48999998 + 1;
  r3.w = sqrt(r3.z);
  r1.w = r1.w * 0.699999988 + r3.w;
  r3.z = cmp(r3.z >= 0);
  r4.xyz = r1.www * r4.xyz;
  r4.xyz = r1.xyz * float3(0.699999988,0.699999988,0.699999988) + -r4.xyz;
  r4.xyz = r3.zzz ? r4.xyz : 0;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  r0.y = (int)r0.y;
  r5.xyz = v1.xyz;
  r1.w = 0;
  [loop] while (true) {
    r3.z = cmp((int)r1.w >= (int)r0.y);
    [branch] if (r3.z != 0) break;
    r3.zw = float2(0.00999999978,0.00999999978) * r5.xz;
    r6.xyzw = _HeightTex.SampleGrad(sampler_HeightTex, r3.zw, r3.xy, r0.zw).xyzw;
    r3.z = _HeightScale * r6.x;
    r6.xy = float2(1024,1024) + r5.xz;
    r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
    r6.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r6.xy, 0).xyzw;
    r3.w = -r5.y + r2.z;
    r3.z = cmp(r3.z < r3.w);
    r3.w = cmp(r5.y < r6.x);
    r3.z = (int)r3.w | (int)r3.z;
    [branch] if (r3.z != 0) {
      break;
    }
    r5.xyz = r4.xyz * r0.xxx + r5.xyz;
    r1.w = (int)r1.w + 1;
  }
  r0.x = max(9.99999997e-007, _Extinction);
  r0.yzw = -r5.xyz + r2.xzw;
  r0.y = dot(r0.yzw, r0.yzw);
  r0.y = sqrt(r0.y);
  r0.x = -r0.x * r0.y;
  r0.x = 1.44269502 * r0.x;
  r0.x = exp2(r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, r1.xyz);
  r0.z = 1 + -_G;
  r0.z = r0.z * r0.z;
  r0.w = _G * _G + 1;
  r0.y = dot(r0.yy, _G.xx);
  r0.y = r0.w + -r0.y;
  r0.y = log2(r0.y);
  r0.y = 1.5 * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 12.566371 * r0.y;
  r0.y = r0.z / r0.y;
  r1.xyz = _IceColor.xyz * _BT_SunlightColor.xyz;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r2.xzw;
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r2.xzw;
  r5.xyz = -unity_ShadowSplitSpheres[2].xyz + r2.xzw;
  r6.xyz = -unity_ShadowSplitSpheres[3].xyz + r2.xzw;
  r3.x = dot(r3.xyz, r3.xyz);
  r3.y = dot(r4.xyz, r4.xyz);
  r3.z = dot(r5.xyz, r5.xyz);
  r3.w = dot(r6.xyz, r6.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyz = r4.yzw + r3.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r4.yzw = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r2.zzz;
  r4.yzw = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r2.xxx + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r2.www + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r4.yzw;
  r5.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r2.zzz;
  r5.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r2.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r2.www + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r5.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r2.zzz;
  r6.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r2.xxx + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r2.www + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r6.xyz;
  r7.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r2.zzz;
  r7.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r2.xxx + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r2.www + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xzw;
  r5.xyz = r5.xyz * r3.xxx;
  r4.xyz = r4.yzw * r4.xxx + r5.xyz;
  r3.xyw = r6.xyz * r3.yyy + r4.xyz;
  r2.xzw = r2.xzw * r3.zzz + r3.xyw;
  r3.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r2.xz, 0).xyzw;
  r0.z = _C * r2.w;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = saturate(r0.z / r3.x);
  r1.xyz = r1.xyz * r0.zzz;
  r3.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r3.xy).xyzw;
  r2.xzw = r3.xyz * r3.www;
  r0.yzw = r2.xzw * r0.yyy;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xzw = -BT_SHC.xyz + r3.xyz;
  r2.xzw = float3(0.200000003,0.200000003,0.200000003) * r2.xzw;
  r0.yzw = r1.xyz * r0.yzw + r2.xzw;
  r0.x = r0.x * r2.y;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyzw = float4(0.5,0.5,2,8) * float4(_GridColor.x, _GridColor.y, _GridColor.z, _FOWGridScale);
  r0.w = -13 + _BT_Exposure_Value;
  r0.w = exp2(r0.w);
  r2.xy = v1.xz / r1.ww;
  r2.xy = frac(r2.xy);
  r2.xyzw = _FOWGridTexture.Sample(sampler_FOWGridTexture, r2.xy).xyzw;
  r2.xyz = -_WorldSpaceCameraPos.xyz + v1.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.w = sqrt(r1.w);
  r2.x = _FogGridFade.x + -_FogGridFade.y;
  r1.w = -_FogGridFade.y + r1.w;
  r2.x = 1 / r2.x;
  r1.w = saturate(r2.x * r1.w);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r1.w = r2.w * r1.w;
  r2.x = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r2.yzw = r0.xyz / r2.xxx;
  r2.yzw = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r2.yzw);
  r3.xy = float2(1024,1024) + v1.xz;
  r3.zw = float2(0.00048828125,0.00048828125) * r3.xy;
  r4.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r3.zw, 0).xyzw;
  r4.xyz = float3(-0.400000006,-0.400000006,-0.400000006) + r4.xyz;
  r4.xyz = saturate(float3(4.99999952,4.99999952,4.99999952) * r4.xyz);
  r5.xyz = r4.xyz * float3(-2,-2,-2) + float3(3,3,3);
  r4.xyz = r4.xyz * r4.xyz;
  r4.xyz = r5.xyz * r4.xyz;
  r5.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r3.zw, 2).xyzw;
  r5.xyz = float3(0.649999976,0.649999976,0.649999976) * r5.xyz;
  r4.xyz = r4.xyz * float3(0.349999994,0.349999994,0.349999994) + r5.xyz;
  r3.zw = cmp(float2(2048,2048) < r3.xy);
  r3.xy = cmp(r3.xy < float2(0,0));
  r3.x = (int)r3.x | (int)r3.z;
  r3.x = (int)r3.w | (int)r3.x;
  r3.x = (int)r3.y | (int)r3.x;
  r3.xyz = r3.xxx ? float3(0,1,0) : r4.xyz;
  r2.yzw = float3(-1,-1,-1) + r2.yzw;
  r4.xyz = _SurveyedSettings.zzz * r2.yzw + float3(1,1,1);
  r4.xyz = r4.xyz * r2.xxx;
  r4.xyz = r4.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r4.xyz = _FogOfWarSettings.zzz * r4.xyz + r0.xyz;
  r2.yzw = _RevealedSettings.zzz * r2.yzw + float3(1,1,1);
  r2.xyz = r2.yzw * r2.xxx;
  r2.xyz = r2.xyz * _RevealedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.www * r2.xyz + r0.xyz;
  r1.xyz = r1.xyz * r0.www + -r4.xyz;
  r1.xyz = r1.www * r1.xyz + r4.xyz;
  r2.xyz = r2.xyz * r3.zzz;
  r1.xyz = r1.xyz * r3.yyy + r2.xyz;
  r0.w = r3.x + r3.y;
  r0.w = saturate(r0.w + r3.z);
  r0.w = 1 + -r0.w;
  o0.xyz = r0.xyz * r0.www + r1.xyz;
  o0.w = 0;
  return;
}


// ps d24ec65715645f40: 1 retail keyword combination(s)
void ps_d24ec65715645f40_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.z = dot(v2.xyz, v2.xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = v2.xyz * r0.zzz;
  r2.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, r0.xy).xyzw;
  r0.zw = _ScreenParams.xy * r0.xy;
  r0.zw = _DitheringTex_TexelSize.xy * r0.zw;
  r3.xyzw = _DitheringTex.Sample(sampler_DitheringTex, r0.zw).xyzw;
  r0.z = r3.w * 2 + -1;
  r2.xzw = r1.xyz * r0.zzz + v1.xyz;
  r0.zw = float2(0.00999999978,0.00999999978) * r2.xw;
  r3.xy = ddx(r0.zw);
  r0.zw = ddy(r0.zw);
  r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, r0.xy).xyzw;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = 5 / -r1.y;
  r0.x = min(5, r0.x);
  r0.y = saturate(-r1.y);
  r1.w = _MinSamples + -_MaxSamples;
  r0.y = r0.y * r1.w + _MaxSamples;
  r0.y = 0.5 * r0.y;
  r0.x = r0.x / r0.y;
  r1.w = dot(r1.xyz, r4.xyz);
  r3.z = -r1.w * r1.w + 1;
  r3.z = -r3.z * 0.48999998 + 1;
  r3.w = sqrt(r3.z);
  r1.w = r1.w * 0.699999988 + r3.w;
  r3.z = cmp(r3.z >= 0);
  r4.xyz = r1.www * r4.xyz;
  r4.xyz = r1.xyz * float3(0.699999988,0.699999988,0.699999988) + -r4.xyz;
  r4.xyz = r3.zzz ? r4.xyz : 0;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  r0.y = (int)r0.y;
  r5.xyz = v1.xyz;
  r1.w = 0;
  [loop] while (true) {
    r3.z = cmp((int)r1.w >= (int)r0.y);
    [branch] if (r3.z != 0) break;
    r3.zw = float2(0.00999999978,0.00999999978) * r5.xz;
    r6.xyzw = _HeightTex.SampleGrad(sampler_HeightTex, r3.zw, r3.xy, r0.zw).xyzw;
    r3.z = _HeightScale * r6.x;
    r6.xy = float2(1024,1024) + r5.xz;
    r6.xy = float2(0.00048828125,0.00048828125) * r6.xy;
    r6.xyzw = _BT_TerrainHeight.SampleLevel(sampler_BT_TerrainHeight, r6.xy, 0).xyzw;
    r3.w = -r5.y + r2.z;
    r3.z = cmp(r3.z < r3.w);
    r3.w = cmp(r5.y < r6.x);
    r3.z = (int)r3.w | (int)r3.z;
    [branch] if (r3.z != 0) {
      break;
    }
    r5.xyz = r4.xyz * r0.xxx + r5.xyz;
    r1.w = (int)r1.w + 1;
  }
  r0.x = max(9.99999997e-007, _Extinction);
  r0.yzw = -r5.xyz + r2.xzw;
  r0.y = dot(r0.yzw, r0.yzw);
  r0.y = sqrt(r0.y);
  r0.x = -r0.x * r0.y;
  r0.x = 1.44269502 * r0.x;
  r0.x = exp2(r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, r1.xyz);
  r0.z = 1 + -_G;
  r0.z = r0.z * r0.z;
  r0.w = _G * _G + 1;
  r0.y = dot(r0.yy, _G.xx);
  r0.y = r0.w + -r0.y;
  r0.y = log2(r0.y);
  r0.y = 1.5 * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 12.566371 * r0.y;
  r0.y = r0.z / r0.y;
  r1.xyz = _IceColor.xyz * _BT_SunlightColor.xyz;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r2.xzw;
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r2.xzw;
  r5.xyz = -unity_ShadowSplitSpheres[2].xyz + r2.xzw;
  r6.xyz = -unity_ShadowSplitSpheres[3].xyz + r2.xzw;
  r3.x = dot(r3.xyz, r3.xyz);
  r3.y = dot(r4.xyz, r4.xyz);
  r3.z = dot(r5.xyz, r5.xyz);
  r3.w = dot(r6.xyz, r6.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyz = r4.yzw + r3.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r4.yzw = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r2.zzz;
  r4.yzw = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r2.xxx + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r2.www + r4.yzw;
  r4.yzw = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r4.yzw;
  r5.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r2.zzz;
  r5.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r2.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r2.www + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r5.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r2.zzz;
  r6.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r2.xxx + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r2.www + r6.xyz;
  r6.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r6.xyz;
  r7.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r2.zzz;
  r7.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r2.xxx + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r2.www + r7.xyz;
  r2.xzw = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xzw;
  r5.xyz = r5.xyz * r3.xxx;
  r4.xyz = r4.yzw * r4.xxx + r5.xyz;
  r3.xyw = r6.xyz * r3.yyy + r4.xyz;
  r2.xzw = r2.xzw * r3.zzz + r3.xyw;
  r3.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r2.xz, 0).xyzw;
  r0.z = _C * r2.w;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = saturate(r0.z / r3.x);
  r1.xyz = r1.xyz * r0.zzz;
  r3.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r3.xy).xyzw;
  r2.xzw = r3.xyz * r3.www;
  r0.yzw = r2.xzw * r0.yyy;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xzw = -BT_SHC.xyz + r3.xyz;
  r2.xzw = float3(0.200000003,0.200000003,0.200000003) * r2.xzw;
  r0.yzw = r1.xyz * r0.yzw + r2.xzw;
  r0.x = r0.x * r2.y;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyzw = float4(0.5,0.5,2,8) * float4(_GridColor.x, _GridColor.y, _GridColor.z, _FOWGridScale);
  r0.w = -13 + _BT_Exposure_Value;
  r0.w = exp2(r0.w);
  r2.xy = v1.xz / r1.ww;
  r2.xy = frac(r2.xy);
  r2.xyzw = _FOWGridTexture.Sample(sampler_FOWGridTexture, r2.xy).xyzw;
  r2.xyz = -_WorldSpaceCameraPos.xyz + v1.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.w = sqrt(r1.w);
  r2.x = _FogGridFade.x + -_FogGridFade.y;
  r1.w = -_FogGridFade.y + r1.w;
  r2.x = 1 / r2.x;
  r1.w = saturate(r2.x * r1.w);
  r2.x = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r1.w = r2.x * r1.w;
  r1.w = r2.w * r1.w;
  r2.x = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r2.yzw = r0.xyz / r2.xxx;
  r2.yzw = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r2.yzw);
  r3.xy = float2(1024,1024) + v1.xz;
  r3.zw = float2(0.00048828125,0.00048828125) * r3.xy;
  r4.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r3.zw, 0).xyzw;
  r4.xyz = float3(-0.400000006,-0.400000006,-0.400000006) + r4.xyz;
  r4.xyz = saturate(float3(4.99999952,4.99999952,4.99999952) * r4.xyz);
  r5.xyz = r4.xyz * float3(-2,-2,-2) + float3(3,3,3);
  r4.xyz = r4.xyz * r4.xyz;
  r4.xyz = r5.xyz * r4.xyz;
  r5.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r3.zw, 2).xyzw;
  r5.xyz = float3(0.649999976,0.649999976,0.649999976) * r5.xyz;
  r4.xyz = r4.xyz * float3(0.349999994,0.349999994,0.349999994) + r5.xyz;
  r3.zw = cmp(float2(2048,2048) < r3.xy);
  r3.xy = cmp(r3.xy < float2(0,0));
  r3.x = (int)r3.x | (int)r3.z;
  r3.x = (int)r3.w | (int)r3.x;
  r3.x = (int)r3.y | (int)r3.x;
  r3.xyz = r3.xxx ? float3(0,1,0) : r4.xyz;
  r2.yzw = float3(-1,-1,-1) + r2.yzw;
  r4.xyz = _SurveyedSettings.zzz * r2.yzw + float3(1,1,1);
  r4.xyz = r4.xyz * r2.xxx;
  r4.xyz = r4.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r4.xyz = _FogOfWarSettings.zzz * r4.xyz + r0.xyz;
  r2.yzw = _RevealedSettings.zzz * r2.yzw + float3(1,1,1);
  r2.xyz = r2.yzw * r2.xxx;
  r2.xyz = r2.xyz * _RevealedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.www * r2.xyz + r0.xyz;
  r1.xyz = r1.xyz * r0.www + -r4.xyz;
  r1.xyz = r1.www * r1.xyz + r4.xyz;
  r2.xyz = r2.xyz * r3.zzz;
  r1.xyz = r1.xyz * r3.yyy + r2.xyz;
  r0.w = r3.x + r3.y;
  r0.w = saturate(r0.w + r3.z);
  r0.w = 1 + -r0.w;
  o0.xyz = r0.xyz * r0.www + r1.xyz;
  o0.w = 0;
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
		vs_078b47b278cf9ea3_impl(v.position0, v.texcoord0.xy, v.normal0.xyz, v.tangent0, o0, o1, o2, o3);
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
#if !defined(_BT_FOGOFWAR) && !defined(_EFFECTS_LOW) && !defined(_EFFECTS_MED) && !defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_b0d185a7160fe1d5_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && !defined(_EFFECTS_LOW) && !defined(_EFFECTS_MED) && defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_470e89703a1b0a3b_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_EFFECTS_MED) && !defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_5687670b97aea3d4_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_EFFECTS_MED) && defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_9d70a19555c38056_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif defined(_EFFECTS_LOW)
	{
		float4 o0 = 0;
		ps_460a8a7c3f2a4238_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_EFFECTS_LOW) && !defined(_EFFECTS_MED) && !defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_e7fd9701af27abab_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_EFFECTS_LOW) && !defined(_EFFECTS_MED) && defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_af051821fb152b77_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_EFFECTS_MED) && !defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_da9a65a73e8053f6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_EFFECTS_MED) && defined(_TAA_ACTIVE)
	{
		float4 o0 = 0;
		ps_d24ec65715645f40_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, o0);
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
