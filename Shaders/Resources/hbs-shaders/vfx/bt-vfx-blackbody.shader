Shader "BattleTech/VFX/Blackbody"
{
	Properties
	{
		_Color ("Base Color", Color) = (0,0,0,1)
		_MainTex ("Base", 2D) = "white" {}
		_MainTex_Rotation ("Base Rotation: UV Pivot(X,Y), Speed(W)", Vector) = (0.5,0.5,0,0)
		_TemperatureKelvin ("Temperature (Kelvin)", Float) = 1
		[HDR] _ColorBB ("Black Body Tint", Color) = (0,0,0,1)
		_NoiseTex ("Temperature Noise", 2D) = "white" {}
		_NoiseTex_Rotation ("Noise Rotation: UV Pivot(X,Y), Speed(W)", Vector) = (0.5,0.5,0,0)
		_PanDir ("Noise Pan Direction (X,Y),(Z,W)", Vector) = (0,0,0,0)
		_NoiseMult ("Temperature Noise Scale", Range(0,1)) = 1
		_AlphaETex ("Alpha Eroded Texture", 2D) = "white" {}
		_AlphaETex_Rotation ("Alpha Erosion Rotation: UV Pivot(X,Y), Speed(W)", Vector) = (0.5,0.5,0,0)
		_AlphaEMult ("Alpha Erosion Alpha Boost", Float) = 1
		_AlphaECutoff ("Alpha Erosion Alpha Cutoff", Float) = 0.5
		[MaterialToggle(_IGNORE_TEMP)] _IgnoreTemp ("Ignore Color Temp/Use Tint", Float) = 0
		[MaterialToggle(_VISFOW)] _VisFOW ("Visible in Fog of War", Float) = 0
		_DepthFade ("Depth Fade Factor", Float) = 1
	}
	SubShader
	{
		Tags { "Queue"="Transparent+1" }
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _BT_FOGOFWAR
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _FOG_3D
			#pragma multi_compile _ _IGNORE_TEMP
			#pragma multi_compile _ _VFX_DEPTH_SAMPLE
			#pragma multi_compile _ _VISFOW

#define cmp -

Texture2D _FilteredShadowmap;
SamplerState sampler_FilteredShadowmap;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _DepthDownsampleVFX;
SamplerState sampler_DepthDownsampleVFX;
Texture2D _LightTexture0;
SamplerState sampler_LightTexture0;
Texture2D _NoiseTex;
SamplerState sampler_NoiseTex;
Texture2D _TransmittanceLUT;
SamplerState sampler_TransmittanceLUT;
Texture2D _BT_FogOfWar;
SamplerState sampler_BT_FogOfWar;
Texture2D _AlphaETex;
SamplerState sampler_AlphaETex;
Texture2D _ColorTempLUT;
SamplerState sampler_ColorTempLUT;
Texture2D _FogIntegrationTex;
SamplerState sampler_FogIntegrationTex;
Texture3D _FogIntegration3D;
SamplerState sampler_FogIntegration3D;

float4x4 unity_WorldToLight;
float4 BT_SHAr;
float4 BT_SHAg;
float4 BT_SHAb;
float4 BT_SHC;
float _C;
float _BT_SunlightIntensity;
float _BT_CloudCover;
float4 _BT_SunlightColor;
float3 _BT_SunlightDirection;
float4 _BT_GlobalWind;
float4 _BT_GlobalWind_Properties;
float _MinLightInfluence;
float _MinShadowInfluence;
float _BT_CloudOpacity;
float _BT_CloudSoftness;
float4 _MainTex_ST;
float4 _TintColor;
float4 _Color;
float4 _MainTex_Rotation;
float4 _AlphaETex_ST;
float4 _AlphaETex_Rotation;
float _TemperatureKelvin;
float4 _NoiseTex_ST;
float4 _NoiseTex_Rotation;
float _NoiseMult;
float4 _PanDir;
float4 _SurveyedSettings;
float4 _RevealedSettings;
float4 _FogOfWarSettings;
float4 _ScaleOffset;
float3 _VolumeSize;
float4 _ColorBB;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord6 : TEXCOORD6;
};
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord6 : TEXCOORD6;
};
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord6 : TEXCOORD6;
};
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord6 : TEXCOORD6;
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord6 : TEXCOORD6;
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord6 : TEXCOORD6;
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

// vs 9170aa158ca163fe: 8 retail keyword combination(s)
void vs_9170aa158ca163fe_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r1.yzw = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r3.xyz;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xyz;
  r1.xyz = r2.xyz * r1.www + r1.xyz;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r0.w = _C * r1.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r2.x);
  r1.xy = _Time.xx * -_BT_GlobalWind.xz;
  r1.xy = _BT_GlobalWind_Properties.xx * r1.xy;
  r1.xz = float2(1000,1000) * r1.xy;
  r1.y = 0;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r0.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r0.xx + r1.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r0.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r1.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r1.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r1.x = r0.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r1.xy, 0).xyzw;
  r0.yzw = r1.xyz * r1.www;
  r1.x = 0.100000001 + -_BT_SunlightDirection.y;
  r1.x = saturate(5 * r1.x);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r1.xyz, _BT_SunlightDirection.xyz));
  o4.xyz = r1.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r1.xyz = _BT_SunlightColor.xyz * r0.www;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r2.x = dot(BT_SHAr.yw, float2(1,1));
  r2.y = dot(BT_SHAg.yw, float2(1,1));
  r2.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xyz = -BT_SHC.xyz + r2.xyz;
  o3.xyz = r1.xyz * r0.xyz + r2.xyz;
  o4.w = 1;
  return;
}


// vs b1d3c29de8a945c8: 8 retail keyword combination(s)
void vs_b1d3c29de8a945c8_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float2 o2 : TEXCOORD0,
  inout float2 p2 : TEXCOORD6,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  p2.xy = r2.zw;
  o5.w = r2.w;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r3.x = dot(r3.xyz, r3.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r3.y = dot(r4.xyz, r4.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r3.z = dot(r4.xyz, r4.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r3.w = dot(r4.xyz, r4.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.yzw = r3.yzw + r4.xyz;
  r3.yzw = max(float3(0,0,0), r3.yzw);
  r4.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r4.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r4.xyz;
  r4.xyz = r4.xyz * r3.yyy;
  r5.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r5.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r5.xyz;
  r4.xyz = r5.xyz * r3.xxx + r4.xyz;
  r5.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r5.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r5.xyz;
  r3.xyz = r5.xyz * r3.zzz + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r4.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r4.xyz;
  r3.xyz = r4.xyz * r3.www + r3.xyz;
  r4.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r3.xy, 0).xyzw;
  r0.w = _C * r3.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r4.x);
  r3.xy = _Time.xx * -_BT_GlobalWind.xz;
  r3.xy = _BT_GlobalWind_Properties.xx * r3.xy;
  r3.xz = float2(1000,1000) * r3.xy;
  r3.y = 0;
  r0.xyz = r3.xyz + r0.xyz;
  r3.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r0.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r0.xx + r3.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r0.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r3.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r3.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r3.x = r0.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r3.xy, 0).xyzw;
  r0.yzw = r3.xyz * r3.www;
  r2.z = 0.100000001 + -_BT_SunlightDirection.y;
  r2.z = saturate(5 * r2.z);
  r3.x = r2.z * -2 + 3;
  r2.z = r2.z * r2.z;
  r2.z = r3.x * r2.z;
  r0.yzw = r2.zzz * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r3.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r3.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r3.xyz;
  r3.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r3.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = saturate(dot(r3.xyz, _BT_SunlightDirection.xyz));
  o4.xyz = r3.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r3.xyz = _BT_SunlightColor.xyz * r0.www;
  r3.xyz = _BT_SunlightIntensity.xxx * r3.xyz;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r4.x = dot(BT_SHAr.yw, float2(1,1));
  r4.y = dot(BT_SHAg.yw, float2(1,1));
  r4.z = dot(BT_SHAb.yw, float2(1,1));
  r4.xyz = -BT_SHC.xyz + r4.xyz;
  o3.xyz = r3.xyz * r0.xyz + r4.xyz;
  o4.w = 1;
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  o5.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r1.w = 0.5 * r0.x;
  o5.xy = r1.xw + r1.zz;
  return;
}


// vs ee95dfa715ba0ab8: 4 retail keyword combination(s)
void vs_ee95dfa715ba0ab8_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float3 o5 : TEXCOORD5)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r1.yzw = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r3.xyz;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xyz;
  r1.xyz = r2.xyz * r1.www + r1.xyz;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r0.w = _C * r1.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r2.x);
  r1.xy = _Time.xx * -_BT_GlobalWind.xz;
  r1.xy = _BT_GlobalWind_Properties.xx * r1.xy;
  r1.xz = float2(1000,1000) * r1.xy;
  r1.y = 0;
  r1.xyz = r1.xyz + r0.xyz;
  r0.xy = float2(1024,1024) + r0.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r2.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  r0.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r1.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r1.xx + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r1.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r1.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r1.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r1.x = r0.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r1.xy, 0).xyzw;
  r0.yzw = r1.xyz * r1.www;
  r1.x = 0.100000001 + -_BT_SunlightDirection.y;
  r1.x = saturate(5 * r1.x);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r1.xyz, _BT_SunlightDirection.xyz));
  o4.xyz = r1.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r1.xyz = _BT_SunlightColor.xyz * r0.www;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r3.xyz = -BT_SHC.xyz + r3.xyz;
  o3.xyz = r1.xyz * r0.xyz + r3.xyz;
  r0.x = saturate(dot(r2.xyz, float3(1,1,1)));
  o5.xyz = r2.xyz;
  o4.w = 1 + -r0.x;
  return;
}


// vs 5c4f27b9e35c5104: 4 retail keyword combination(s)
void vs_5c4f27b9e35c5104_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float2 o2 : TEXCOORD0,
  inout float2 p2 : TEXCOORD6,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float3 o6 : TEXCOORD5)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  p2.xy = r2.zw;
  o5.w = r2.w;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r3.x = dot(r3.xyz, r3.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r3.y = dot(r4.xyz, r4.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r3.z = dot(r4.xyz, r4.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r3.w = dot(r4.xyz, r4.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.yzw = r3.yzw + r4.xyz;
  r3.yzw = max(float3(0,0,0), r3.yzw);
  r4.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r4.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r4.xyz;
  r4.xyz = r4.xyz * r3.yyy;
  r5.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r5.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r5.xyz;
  r4.xyz = r5.xyz * r3.xxx + r4.xyz;
  r5.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r5.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r5.xyz;
  r3.xyz = r5.xyz * r3.zzz + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r4.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r4.xyz;
  r3.xyz = r4.xyz * r3.www + r3.xyz;
  r4.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r3.xy, 0).xyzw;
  r0.w = _C * r3.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r4.x);
  r3.xy = _Time.xx * -_BT_GlobalWind.xz;
  r3.xy = _BT_GlobalWind_Properties.xx * r3.xy;
  r3.xz = float2(1000,1000) * r3.xy;
  r3.y = 0;
  r3.xyz = r3.xyz + r0.xyz;
  r0.xy = float2(1024,1024) + r0.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r4.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  r0.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r3.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r3.xx + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r3.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r3.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r3.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r3.x = r0.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r3.xy, 0).xyzw;
  r0.yzw = r3.xyz * r3.www;
  r2.z = 0.100000001 + -_BT_SunlightDirection.y;
  r2.z = saturate(5 * r2.z);
  r3.x = r2.z * -2 + 3;
  r2.z = r2.z * r2.z;
  r2.z = r3.x * r2.z;
  r0.yzw = r2.zzz * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r3.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r3.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r3.xyz;
  r3.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r3.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = saturate(dot(r3.xyz, _BT_SunlightDirection.xyz));
  o4.xyz = r3.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r3.xyz = _BT_SunlightColor.xyz * r0.www;
  r3.xyz = _BT_SunlightIntensity.xxx * r3.xyz;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r5.x = dot(BT_SHAr.yw, float2(1,1));
  r5.y = dot(BT_SHAg.yw, float2(1,1));
  r5.z = dot(BT_SHAb.yw, float2(1,1));
  r5.xyz = -BT_SHC.xyz + r5.xyz;
  o3.xyz = r3.xyz * r0.xyz + r5.xyz;
  r0.x = saturate(dot(r4.xyz, float3(1,1,1)));
  o6.xyz = r4.xyz;
  o4.w = 1 + -r0.x;
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  o5.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r1.w = 0.5 * r0.x;
  o5.xy = r1.xw + r1.zz;
  return;
}


// vs b7272865e1aa8a93: 4 retail keyword combination(s)
void vs_b7272865e1aa8a93_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float3 o5 : TEXCOORD5)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r1.yzw = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r3.xyz;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xyz;
  r1.xyz = r2.xyz * r1.www + r1.xyz;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r0.w = _C * r1.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r2.x);
  r1.xy = _Time.xx * -_BT_GlobalWind.xz;
  r1.xy = _BT_GlobalWind_Properties.xx * r1.xy;
  r1.xz = float2(1000,1000) * r1.xy;
  r1.y = 0;
  r1.xyz = r1.xyz + r0.xyz;
  r0.xy = float2(1024,1024) + r0.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r2.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  o5.xyz = r2.xyz;
  r0.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r1.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r1.xx + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r1.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r1.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r1.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r1.x = r0.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r1.xy, 0).xyzw;
  r0.yzw = r1.xyz * r1.www;
  r1.x = 0.100000001 + -_BT_SunlightDirection.y;
  r1.x = saturate(5 * r1.x);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r1.xyz, _BT_SunlightDirection.xyz));
  o4.xyz = r1.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r1.xyz = _BT_SunlightColor.xyz * r0.www;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r2.x = dot(BT_SHAr.yw, float2(1,1));
  r2.y = dot(BT_SHAg.yw, float2(1,1));
  r2.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xyz = -BT_SHC.xyz + r2.xyz;
  o3.xyz = r1.xyz * r0.xyz + r2.xyz;
  o4.w = 1;
  return;
}


// vs 0665dbc6bee222f3: 4 retail keyword combination(s)
void vs_0665dbc6bee222f3_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float2 o2 : TEXCOORD0,
  inout float2 p2 : TEXCOORD6,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float3 o6 : TEXCOORD5)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  p2.xy = r2.zw;
  o5.w = r2.w;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r3.x = dot(r3.xyz, r3.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r3.y = dot(r4.xyz, r4.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r3.z = dot(r4.xyz, r4.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r3.w = dot(r4.xyz, r4.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.yzw = r3.yzw + r4.xyz;
  r3.yzw = max(float3(0,0,0), r3.yzw);
  r4.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r4.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r4.xyz;
  r4.xyz = r4.xyz * r3.yyy;
  r5.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r5.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r5.xyz;
  r4.xyz = r5.xyz * r3.xxx + r4.xyz;
  r5.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r5.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r5.xyz;
  r5.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r5.xyz;
  r3.xyz = r5.xyz * r3.zzz + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r4.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r4.xyz;
  r4.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r4.xyz;
  r3.xyz = r4.xyz * r3.www + r3.xyz;
  r4.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r3.xy, 0).xyzw;
  r0.w = _C * r3.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r4.x);
  r3.xy = _Time.xx * -_BT_GlobalWind.xz;
  r3.xy = _BT_GlobalWind_Properties.xx * r3.xy;
  r3.xz = float2(1000,1000) * r3.xy;
  r3.y = 0;
  r3.xyz = r3.xyz + r0.xyz;
  r0.xy = float2(1024,1024) + r0.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r4.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  o6.xyz = r4.xyz;
  r0.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r3.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r3.xx + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r3.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r3.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r3.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r3.x = r0.y * 0.5 + 0.5;
  r3.y = 0.5;
  r3.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r3.xy, 0).xyzw;
  r0.yzw = r3.xyz * r3.www;
  r2.z = 0.100000001 + -_BT_SunlightDirection.y;
  r2.z = saturate(5 * r2.z);
  r3.x = r2.z * -2 + 3;
  r2.z = r2.z * r2.z;
  r2.z = r3.x * r2.z;
  r0.yzw = r2.zzz * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r3.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r3.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r3.xyz;
  r3.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r3.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = saturate(dot(r3.xyz, _BT_SunlightDirection.xyz));
  o4.xyz = r3.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r3.xyz = _BT_SunlightColor.xyz * r0.www;
  r3.xyz = _BT_SunlightIntensity.xxx * r3.xyz;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r4.x = dot(BT_SHAr.yw, float2(1,1));
  r4.y = dot(BT_SHAg.yw, float2(1,1));
  r4.z = dot(BT_SHAb.yw, float2(1,1));
  r4.xyz = -BT_SHC.xyz + r4.xyz;
  o3.xyz = r3.xyz * r0.xyz + r4.xyz;
  o4.w = 1;
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  o5.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r1.w = 0.5 * r0.x;
  o5.xy = r1.xw + r1.zz;
  return;
}


// vs 4c87b7788c548c01: 8 retail keyword combination(s)
void vs_4c87b7788c548c01_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD1,
  inout float4 o4 : TEXCOORD2,
  inout float4 o5 : TEXCOORD3)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r0.w = _ProjectionParams.w * r0.w;
  o3.z = -r0.w;
  r0.w = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.w;
  r1.xz = float2(0.5,0.5) * r2.xw;
  o3.w = r2.w;
  o3.xy = r1.xw + r1.zz;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r1.yzw = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r3.xyz;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xyz;
  r1.xyz = r2.xyz * r1.www + r1.xyz;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r0.w = _C * r1.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r2.x);
  r1.xy = _Time.xx * -_BT_GlobalWind.xz;
  r1.xy = _BT_GlobalWind_Properties.xx * r1.xy;
  r1.xz = float2(1000,1000) * r1.xy;
  r1.y = 0;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r0.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r0.xx + r1.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r0.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r1.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r1.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r1.x = r0.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r1.xy, 0).xyzw;
  r0.yzw = r1.xyz * r1.www;
  r1.x = 0.100000001 + -_BT_SunlightDirection.y;
  r1.x = saturate(5 * r1.x);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r1.xyz, _BT_SunlightDirection.xyz));
  o5.xyz = r1.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r1.xyz = _BT_SunlightColor.xyz * r0.www;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r2.x = dot(BT_SHAr.yw, float2(1,1));
  r2.y = dot(BT_SHAg.yw, float2(1,1));
  r2.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xyz = -BT_SHC.xyz + r2.xyz;
  o4.xyz = r1.xyz * r0.xyz + r2.xyz;
  o5.w = 1;
  return;
}


// vs c01e89839ce05281: 8 retail keyword combination(s)
void vs_c01e89839ce05281_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float2 o2 : TEXCOORD0,
  inout float2 p2 : TEXCOORD6,
  inout float4 o3 : TEXCOORD1,
  inout float4 o4 : TEXCOORD2,
  inout float4 o5 : TEXCOORD3,
  inout float4 o6 : TEXCOORD4)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r3.zw = r2.zw;
  p2.xy = r3.zw;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r1.x = _ProjectionParams.w * r0.w;
  o6.z = -r0.w;
  o3.z = -r1.x;
  r0.w = _ProjectionParams.x * r2.y;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r1.w = 0.5 * r0.w;
  r3.xy = r1.xw + r1.zz;
  o3.xyw = r3.xyw;
  o6.xyw = r3.xyw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r1.yzw = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r3.xyz;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xyz;
  r1.xyz = r2.xyz * r1.www + r1.xyz;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r0.w = _C * r1.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r2.x);
  r1.xy = _Time.xx * -_BT_GlobalWind.xz;
  r1.xy = _BT_GlobalWind_Properties.xx * r1.xy;
  r1.xz = float2(1000,1000) * r1.xy;
  r1.y = 0;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r0.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r0.xx + r1.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r0.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r1.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r1.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r1.x = r0.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r1.xy, 0).xyzw;
  r0.yzw = r1.xyz * r1.www;
  r1.x = 0.100000001 + -_BT_SunlightDirection.y;
  r1.x = saturate(5 * r1.x);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r1.xyz, _BT_SunlightDirection.xyz));
  o5.xyz = r1.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r1.xyz = _BT_SunlightColor.xyz * r0.www;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r2.x = dot(BT_SHAr.yw, float2(1,1));
  r2.y = dot(BT_SHAg.yw, float2(1,1));
  r2.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xyz = -BT_SHC.xyz + r2.xyz;
  o4.xyz = r1.xyz * r0.xyz + r2.xyz;
  o5.w = 1;
  return;
}


// vs c7a1379930e22a2f: 4 retail keyword combination(s)
void vs_c7a1379930e22a2f_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD1,
  inout float4 o4 : TEXCOORD2,
  inout float4 o5 : TEXCOORD3,
  inout float3 o6 : TEXCOORD5)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r0.w = _ProjectionParams.w * r0.w;
  o3.z = -r0.w;
  r0.w = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.w;
  r1.xz = float2(0.5,0.5) * r2.xw;
  o3.w = r2.w;
  o3.xy = r1.xw + r1.zz;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r1.yzw = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r3.xyz;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xyz;
  r1.xyz = r2.xyz * r1.www + r1.xyz;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r0.w = _C * r1.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r2.x);
  r1.xy = _Time.xx * -_BT_GlobalWind.xz;
  r1.xy = _BT_GlobalWind_Properties.xx * r1.xy;
  r1.xz = float2(1000,1000) * r1.xy;
  r1.y = 0;
  r1.xyz = r1.xyz + r0.xyz;
  r0.xy = float2(1024,1024) + r0.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r2.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  r0.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r1.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r1.xx + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r1.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r1.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r1.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r1.x = r0.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r1.xy, 0).xyzw;
  r0.yzw = r1.xyz * r1.www;
  r1.x = 0.100000001 + -_BT_SunlightDirection.y;
  r1.x = saturate(5 * r1.x);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r1.xyz, _BT_SunlightDirection.xyz));
  o5.xyz = r1.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r1.xyz = _BT_SunlightColor.xyz * r0.www;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r3.xyz = -BT_SHC.xyz + r3.xyz;
  o4.xyz = r1.xyz * r0.xyz + r3.xyz;
  r0.x = saturate(dot(r2.xyz, float3(1,1,1)));
  o6.xyz = r2.xyz;
  o5.w = 1 + -r0.x;
  return;
}


// vs 115af5b271429e16: 4 retail keyword combination(s)
void vs_115af5b271429e16_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float2 o2 : TEXCOORD0,
  inout float2 p2 : TEXCOORD6,
  inout float4 o3 : TEXCOORD1,
  inout float4 o4 : TEXCOORD2,
  inout float4 o5 : TEXCOORD3,
  inout float4 o6 : TEXCOORD4,
  inout float3 o7 : TEXCOORD5)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r3.zw = r2.zw;
  p2.xy = r3.zw;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r1.x = _ProjectionParams.w * r0.w;
  o6.z = -r0.w;
  o3.z = -r1.x;
  r0.w = _ProjectionParams.x * r2.y;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r1.w = 0.5 * r0.w;
  r3.xy = r1.xw + r1.zz;
  o3.xyw = r3.xyw;
  o6.xyw = r3.xyw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r1.yzw = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r3.xyz;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xyz;
  r1.xyz = r2.xyz * r1.www + r1.xyz;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r0.w = _C * r1.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r2.x);
  r1.xy = _Time.xx * -_BT_GlobalWind.xz;
  r1.xy = _BT_GlobalWind_Properties.xx * r1.xy;
  r1.xz = float2(1000,1000) * r1.xy;
  r1.y = 0;
  r1.xyz = r1.xyz + r0.xyz;
  r0.xy = float2(1024,1024) + r0.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r2.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  r0.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r1.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r1.xx + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r1.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r1.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r1.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r1.x = r0.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r1.xy, 0).xyzw;
  r0.yzw = r1.xyz * r1.www;
  r1.x = 0.100000001 + -_BT_SunlightDirection.y;
  r1.x = saturate(5 * r1.x);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r1.xyz, _BT_SunlightDirection.xyz));
  o5.xyz = r1.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r1.xyz = _BT_SunlightColor.xyz * r0.www;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r3.x = dot(BT_SHAr.yw, float2(1,1));
  r3.y = dot(BT_SHAg.yw, float2(1,1));
  r3.z = dot(BT_SHAb.yw, float2(1,1));
  r3.xyz = -BT_SHC.xyz + r3.xyz;
  o4.xyz = r1.xyz * r0.xyz + r3.xyz;
  r0.x = saturate(dot(r2.xyz, float3(1,1,1)));
  o7.xyz = r2.xyz;
  o5.w = 1 + -r0.x;
  return;
}


// vs 1f9194262c6c7816: 4 retail keyword combination(s)
void vs_1f9194262c6c7816_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD1,
  inout float4 o4 : TEXCOORD2,
  inout float4 o5 : TEXCOORD3,
  inout float3 o6 : TEXCOORD5)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r0.w = _ProjectionParams.w * r0.w;
  o3.z = -r0.w;
  r0.w = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.w;
  r1.xz = float2(0.5,0.5) * r2.xw;
  o3.w = r2.w;
  o3.xy = r1.xw + r1.zz;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r1.yzw = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r3.xyz;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xyz;
  r1.xyz = r2.xyz * r1.www + r1.xyz;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r0.w = _C * r1.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r2.x);
  r1.xy = _Time.xx * -_BT_GlobalWind.xz;
  r1.xy = _BT_GlobalWind_Properties.xx * r1.xy;
  r1.xz = float2(1000,1000) * r1.xy;
  r1.y = 0;
  r1.xyz = r1.xyz + r0.xyz;
  r0.xy = float2(1024,1024) + r0.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r2.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  o6.xyz = r2.xyz;
  r0.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r1.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r1.xx + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r1.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r1.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r1.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r1.x = r0.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r1.xy, 0).xyzw;
  r0.yzw = r1.xyz * r1.www;
  r1.x = 0.100000001 + -_BT_SunlightDirection.y;
  r1.x = saturate(5 * r1.x);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r1.xyz, _BT_SunlightDirection.xyz));
  o5.xyz = r1.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r1.xyz = _BT_SunlightColor.xyz * r0.www;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r2.x = dot(BT_SHAr.yw, float2(1,1));
  r2.y = dot(BT_SHAg.yw, float2(1,1));
  r2.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xyz = -BT_SHC.xyz + r2.xyz;
  o4.xyz = r1.xyz * r0.xyz + r2.xyz;
  o5.w = 1;
  return;
}


// vs fe43d49810566ea6: 4 retail keyword combination(s)
void vs_fe43d49810566ea6_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float2 o2 : TEXCOORD0,
  inout float2 p2 : TEXCOORD6,
  inout float4 o3 : TEXCOORD1,
  inout float4 o4 : TEXCOORD2,
  inout float4 o5 : TEXCOORD3,
  inout float4 o6 : TEXCOORD4,
  inout float3 o7 : TEXCOORD5)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  r3.zw = r2.zw;
  p2.xy = r3.zw;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r1.x = _ProjectionParams.w * r0.w;
  o6.z = -r0.w;
  o3.z = -r1.x;
  r0.w = _ProjectionParams.x * r2.y;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r1.w = 0.5 * r0.w;
  r3.xy = r1.xw + r1.zz;
  o3.xyw = r3.xyw;
  o6.xyw = r3.xyw;
  r1.xyz = -unity_ShadowSplitSpheres[0].xyz + r0.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[1].xyz + r0.xyz;
  r1.y = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[2].xyz + r0.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r2.xyz = -unity_ShadowSplitSpheres[3].xyz + r0.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.xyzw = cmp(r1.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r2.xyz = r1.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r1.xyzw = r1.xyzw ? float4(1,1,1,1) : 0;
  r1.yzw = r1.yzw + r2.xyz;
  r1.yzw = max(float3(0,0,0), r1.yzw);
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) + r2.xyz;
  r2.xyz = r2.xyz * r1.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) + r3.xyz;
  r2.xyz = r3.xyz * r1.xxx + r2.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * r0.yyy;
  r3.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * r0.xxx + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * r0.zzz + r3.xyz;
  r3.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) + r3.xyz;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * r0.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * r0.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * r0.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) + r2.xyz;
  r1.xyz = r2.xyz * r1.www + r1.xyz;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r0.w = _C * r1.z;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(r0.w / r2.x);
  r1.xy = _Time.xx * -_BT_GlobalWind.xz;
  r1.xy = _BT_GlobalWind_Properties.xx * r1.xy;
  r1.xz = float2(1000,1000) * r1.xy;
  r1.y = 0;
  r1.xyz = r1.xyz + r0.xyz;
  r0.xy = float2(1024,1024) + r0.xz;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r2.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  o7.xyz = r2.xyz;
  r0.xy = float2(unity_WorldToLight[0][1], unity_WorldToLight[1][1]) * r1.yy;
  r0.xy = float2(unity_WorldToLight[0][0], unity_WorldToLight[1][0]) * r1.xx + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][2], unity_WorldToLight[1][2]) * r1.zz + r0.xy;
  r0.xy = float2(unity_WorldToLight[0][3], unity_WorldToLight[1][3]) + r0.xy;
  r0.xy = float2(0.5,0.5) * r0.xy;
  r1.xyzw = _LightTexture0.SampleLevel(sampler_LightTexture0, r0.xy, _BT_CloudSoftness).xyzw;
  r0.x = -0.25 + _BT_CloudCover;
  r0.x = r1.w + -r0.x;
  r0.x = saturate(r0.x + r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x + -1;
  r0.x = _BT_CloudOpacity * r0.x + 1;
  r0.x = r0.w * r0.x;
  r0.x = max(_MinShadowInfluence, r0.x);
  r0.y = dot(_BT_SunlightDirection.xyz, _BT_SunlightDirection.xyz);
  r0.y = rsqrt(r0.y);
  r0.y = _BT_SunlightDirection.y * r0.y;
  r1.x = r0.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.SampleLevel(sampler_TransmittanceLUT, r1.xy, 0).xyzw;
  r0.yzw = r1.xyz * r1.www;
  r1.x = 0.100000001 + -_BT_SunlightDirection.y;
  r1.x = saturate(5 * r1.x);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r1.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r1.xyz;
  r1.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r1.xyz, _BT_SunlightDirection.xyz));
  o5.xyz = r1.xyz;
  r0.w = -1 + r0.w;
  r0.w = _MinLightInfluence * r0.w + 1;
  r1.xyz = _BT_SunlightColor.xyz * r0.www;
  r1.xyz = _BT_SunlightIntensity.xxx * r1.xyz;
  r1.xyz = float3(0.25,0.25,0.25) * r1.xyz;
  r2.x = dot(BT_SHAr.yw, float2(1,1));
  r2.y = dot(BT_SHAg.yw, float2(1,1));
  r2.z = dot(BT_SHAb.yw, float2(1,1));
  r2.xyz = -BT_SHC.xyz + r2.xyz;
  o4.xyz = r1.xyz * r0.xyz + r2.xyz;
  o5.w = 1;
  return;
}


// ps 2078bff65bb3f9b4: 4 retail keyword combination(s)
void ps_2078bff65bb3f9b4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r0.xy = -_NoiseTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xyzw = _NoiseTex_Rotation.xyxy + r1.xyxy;
  r0.xyzw = _Time.yyyy * _PanDir.xyzw + r0.xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.xy).xyzw;
  r0.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.zw).xyzw;
  r0.x = max(r1.x, r0.x);
  r0.x = -1 + r0.x;
  r0.x = _NoiseMult * r0.x + 1;
  r0.y = _TemperatureKelvin * v1.x;
  r0.z = r0.y * r0.x + -1000;
  r0.x = r0.y * r0.x;
  r0.x = saturate(0.00100000005 * r0.x);
  r1.x = saturate(5.2631578e-005 * r0.z);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r0.y = r1.x * 10 + 5;
  r0.yzw = r2.xyz * r0.yyy;
  r1.x = r0.x * -2 + 3;
  r1.y = r0.x * r0.x;
  r1.x = r1.x * r1.y;
  r0.yzw = r1.xxx * r0.yzw;
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xy = -_MainTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _MainTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xy = _MainTex_Rotation.xy + r2.xy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r1.xyz = r2.xyz * r1.xyz;
  r1.w = v1.w * r1.w;
  r1.w = _Color.w * r1.w;
  o0.xyz = v3.xyz * r1.xyz + r0.yzw;
  r0.yz = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.yz = -_AlphaETex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r0.yz = _AlphaETex_Rotation.xy + r1.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.yz).xyzw;
  r0.y = -1 + r2.w;
  r0.x = r0.x * r0.y + 1;
  o0.w = r1.w * r0.x;
  return;
}


// ps fa1ade804ad1d2c5: 4 retail keyword combination(s)
void ps_fa1ade804ad1d2c5_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.z = r1.y * r1.x;
  r2.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r2.xy = -_AlphaETex_Rotation.xy + r2.xy;
  r1.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r1.w, r3.x, r4.x);
  r5.x = sin(-r1.w);
  r5.y = r4.x;
  r5.z = r3.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r2.xy).xyzw;
  r1.z = saturate(0.00100000005 * r1.z);
  r1.w = -1 + r2.w;
  r1.w = r1.z * r1.w + 1;
  r1.x = r1.y * r1.x + -1000;
  r1.x = saturate(5.2631578e-005 * r1.x);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r1.x = r1.x * 10 + 5;
  r2.xyz = r2.xyz * r1.xxx;
  r1.x = r1.z * -2 + 3;
  r1.y = r1.z * r1.z;
  r1.x = r1.x * r1.y;
  r1.xyz = r2.xyz * r1.xxx;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.w;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r0.xyz = r2.xyz * r0.xyz;
  o0.xyz = v3.xyz * r0.xyz + r1.xyz;
  return;
}


// ps d6d88547f4b9eba3: 4 retail keyword combination(s)
void ps_d6d88547f4b9eba3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r0.xy = -_NoiseTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xyzw = _NoiseTex_Rotation.xyxy + r1.xyxy;
  r0.xyzw = _Time.yyyy * _PanDir.xyzw + r0.xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.xy).xyzw;
  r0.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.zw).xyzw;
  r0.x = max(r1.x, r0.x);
  r0.x = -1 + r0.x;
  r0.x = _NoiseMult * r0.x + 1;
  r0.y = _TemperatureKelvin * v1.x;
  r0.z = r0.y * r0.x + -1000;
  r0.x = r0.y * r0.x;
  r0.x = saturate(0.00100000005 * r0.x);
  r1.x = saturate(5.2631578e-005 * r0.z);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r0.y = r1.x * 10 + 5;
  r0.yzw = r2.xyz * r0.yyy;
  r1.x = r0.x * -2 + 3;
  r1.y = r0.x * r0.x;
  r1.x = r1.x * r1.y;
  r0.yzw = r1.xxx * r0.yzw;
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xy = -_MainTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _MainTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xy = _MainTex_Rotation.xy + r2.xy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r1.xyz = r2.xyz * r1.xyz;
  r1.w = v1.w * r1.w;
  r1.w = _Color.w * r1.w;
  r0.yzw = v3.xyz * r1.xyz + r0.yzw;
  r1.x = dot(r0.yzw, float3(0.212599993,0.715200007,0.0722000003));
  r2.xyz = r0.yzw / r1.xxx;
  r2.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r2.xyz);
  r2.xyz = float3(-1,-1,-1) + r2.xyz;
  r3.xyz = _RevealedSettings.zzz * r2.xyz + float3(1,1,1);
  r2.xyz = _SurveyedSettings.zzz * r2.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r1.xxx;
  r1.xyz = r3.xyz * r1.xxx;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.yzw;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.yzw;
  r1.xyz = v5.zzz * r1.xyz;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.yzw;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.yzw;
  r1.xyz = r2.xyz * v5.yyy + r1.xyz;
  r2.x = v5.x + v5.y;
  r2.x = saturate(v5.z + r2.x);
  r2.x = 1 + -r2.x;
  o0.xyz = r0.yzw * r2.xxx + r1.xyz;
  r0.yz = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.yz = -_AlphaETex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r0.yz = _AlphaETex_Rotation.xy + r1.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.yz).xyzw;
  r0.y = -1 + r2.w;
  r0.x = r0.x * r0.y + 1;
  o0.w = r1.w * r0.x;
  return;
}


// ps 5f72f1226120c58a: 4 retail keyword combination(s)
void ps_5f72f1226120c58a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.z = r1.y * r1.x;
  r2.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r2.xy = -_AlphaETex_Rotation.xy + r2.xy;
  r1.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r1.w, r3.x, r4.x);
  r5.x = sin(-r1.w);
  r5.y = r4.x;
  r5.z = r3.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r2.xy).xyzw;
  r1.z = saturate(0.00100000005 * r1.z);
  r1.w = -1 + r2.w;
  r1.w = r1.z * r1.w + 1;
  r1.x = r1.y * r1.x + -1000;
  r1.x = saturate(5.2631578e-005 * r1.x);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r1.x = r1.x * 10 + 5;
  r2.xyz = r2.xyz * r1.xxx;
  r1.x = r1.z * -2 + 3;
  r1.y = r1.z * r1.z;
  r1.x = r1.x * r1.y;
  r1.xyz = r2.xyz * r1.xxx;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.w;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r0.xyz = r2.xyz * r0.xyz;
  r0.xyz = v3.xyz * r0.xyz + r1.xyz;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r1.xyz = r0.xyz / r0.www;
  r1.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r1.xyz);
  r1.xyz = float3(-1,-1,-1) + r1.xyz;
  r2.xyz = _SurveyedSettings.zzz * r1.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.xyz;
  r1.xyz = _RevealedSettings.zzz * r1.xyz + float3(1,1,1);
  r1.xyz = r1.xyz * r0.www;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.xyz;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.xyz;
  r1.xyz = v6.zzz * r1.xyz;
  r1.xyz = r2.xyz * v6.yyy + r1.xyz;
  r0.w = v6.x + v6.y;
  r0.w = saturate(v6.z + r0.w);
  r0.w = 1 + -r0.w;
  o0.xyz = r0.xyz * r0.www + r1.xyz;
  return;
}


// ps 23248e3ced8ba678: 2 retail keyword combination(s)
void ps_23248e3ced8ba678_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r0.xy = r0.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r0.w = v3.z * r0.z;
  r0.w = floor(r0.w);
  r1.x = 1 + r0.w;
  r1.x = min(r1.x, r0.z);
  r0.z = v3.z * r0.z + -r0.w;
  r0.xyw = r0.xyw / _ScaleOffset.www;
  r1.x = r1.x / _ScaleOffset.w;
  r1.y = cmp(r1.x >= -r1.x);
  r1.z = frac(abs(r1.x));
  r2.y = floor(r1.x);
  r1.x = r1.y ? r1.z : -r1.z;
  r2.x = r1.x * _ScaleOffset.w + -1;
  r1.x = 1 / _ScaleOffset.w;
  r1.yz = r2.xy * r1.xx + r0.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.yz, 0).xyzw;
  r1.y = cmp(r0.w >= -r0.w);
  r1.z = frac(abs(r0.w));
  r3.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r3.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r3.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r2.xyzw = r2.xyzw + -r1.xyzw;
  r0.xyzw = r0.zzzz * r2.xyzw + r1.xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.y = _TemperatureKelvin * v1.x;
  r1.z = r1.y * r1.x + -1000;
  r1.x = r1.y * r1.x;
  r1.x = saturate(0.00100000005 * r1.x);
  r2.x = saturate(5.2631578e-005 * r1.z);
  r2.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r2.xy).xyzw;
  r1.y = r2.x * 10 + 5;
  r1.yzw = r3.xyz * r1.yyy;
  r2.x = r1.x * -2 + 3;
  r2.y = r1.x * r1.x;
  r2.x = r2.x * r2.y;
  r1.yzw = r2.xxx * r1.yzw;
  r2.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xy = -_MainTex_Rotation.xy + r2.xy;
  r2.z = _Time.y * _MainTex_Rotation.w;
  sincos(r2.z, r3.x, r4.x);
  r5.x = sin(-r2.z);
  r5.z = r3.x;
  r5.y = r4.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _MainTex_Rotation.xy + r3.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r3.xyz = _TintColor.xyz * v1.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r2.w = v1.w * r2.w;
  r2.w = _Color.w * r2.w;
  r1.yzw = v4.xyz * r2.xyz + r1.yzw;
  o0.xyz = r1.yzw * r0.www + r0.xyz;
  r0.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.xy = -_AlphaETex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.z, r2.x, r3.x);
  r4.x = sin(-r0.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r0.xy, r4.yz);
  r2.y = dot(r0.xy, r4.xy);
  r0.xy = _AlphaETex_Rotation.xy + r2.xy;
  r0.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.xy).xyzw;
  r0.x = -1 + r0.w;
  r0.x = r1.x * r0.x + 1;
  o0.w = r2.w * r0.x;
  return;
}


// ps 820c5f18f11f7ce3: 2 retail keyword combination(s)
void ps_820c5f18f11f7ce3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.z = r1.y * r1.x;
  r2.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r2.xy = -_AlphaETex_Rotation.xy + r2.xy;
  r1.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r1.w, r3.x, r4.x);
  r5.x = sin(-r1.w);
  r5.y = r4.x;
  r5.z = r3.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r2.xy).xyzw;
  r1.z = saturate(0.00100000005 * r1.z);
  r1.w = -1 + r2.w;
  r1.w = r1.z * r1.w + 1;
  r1.x = r1.y * r1.x + -1000;
  r1.x = saturate(5.2631578e-005 * r1.x);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r1.x = r1.x * 10 + 5;
  r2.xyz = r2.xyz * r1.xxx;
  r1.x = r1.z * -2 + 3;
  r1.y = r1.z * r1.z;
  r1.x = r1.x * r1.y;
  r1.xyz = r2.xyz * r1.xxx;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.w;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r0.xyz = r2.xyz * r0.xyz;
  r0.xyz = v4.xyz * r0.xyz + r1.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  return;
}


// ps 665a7babda16b133: 2 retail keyword combination(s)
void ps_665a7babda16b133_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r0.xy = r0.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r0.w = v3.z * r0.z;
  r0.w = floor(r0.w);
  r1.x = 1 + r0.w;
  r1.x = min(r1.x, r0.z);
  r0.z = v3.z * r0.z + -r0.w;
  r0.xyw = r0.xyw / _ScaleOffset.www;
  r1.x = r1.x / _ScaleOffset.w;
  r1.y = cmp(r1.x >= -r1.x);
  r1.z = frac(abs(r1.x));
  r2.y = floor(r1.x);
  r1.x = r1.y ? r1.z : -r1.z;
  r2.x = r1.x * _ScaleOffset.w + -1;
  r1.x = 1 / _ScaleOffset.w;
  r1.yz = r2.xy * r1.xx + r0.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.yz, 0).xyzw;
  r1.y = cmp(r0.w >= -r0.w);
  r1.z = frac(abs(r0.w));
  r3.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r3.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r3.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r2.xyzw = r2.xyzw + -r1.xyzw;
  r0.xyzw = r0.zzzz * r2.xyzw + r1.xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.y = _TemperatureKelvin * v1.x;
  r1.z = r1.y * r1.x + -1000;
  r1.x = r1.y * r1.x;
  r1.x = saturate(0.00100000005 * r1.x);
  r2.x = saturate(5.2631578e-005 * r1.z);
  r2.y = 0;
  r3.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r2.xy).xyzw;
  r1.y = r2.x * 10 + 5;
  r1.yzw = r3.xyz * r1.yyy;
  r2.x = r1.x * -2 + 3;
  r2.y = r1.x * r1.x;
  r2.x = r2.x * r2.y;
  r1.yzw = r2.xxx * r1.yzw;
  r2.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xy = -_MainTex_Rotation.xy + r2.xy;
  r2.z = _Time.y * _MainTex_Rotation.w;
  sincos(r2.z, r3.x, r4.x);
  r5.x = sin(-r2.z);
  r5.z = r3.x;
  r5.y = r4.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _MainTex_Rotation.xy + r3.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r3.xyz = _TintColor.xyz * v1.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r2.w = v1.w * r2.w;
  r2.w = _Color.w * r2.w;
  r1.yzw = v4.xyz * r2.xyz + r1.yzw;
  r2.x = dot(r1.yzw, float3(0.212599993,0.715200007,0.0722000003));
  r3.xyz = r1.yzw / r2.xxx;
  r3.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r3.xyz);
  r3.xyz = float3(-1,-1,-1) + r3.xyz;
  r4.xyz = _RevealedSettings.zzz * r3.xyz + float3(1,1,1);
  r3.xyz = _SurveyedSettings.zzz * r3.xyz + float3(1,1,1);
  r3.xyz = r3.xyz * r2.xxx;
  r2.xyz = r4.xyz * r2.xxx;
  r2.xyz = r2.xyz * _RevealedSettings.xxx + -r1.yzw;
  r2.xyz = _FogOfWarSettings.www * r2.xyz + r1.yzw;
  r2.xyz = v6.zzz * r2.xyz;
  r3.xyz = r3.xyz * _SurveyedSettings.xxx + -r1.yzw;
  r3.xyz = _FogOfWarSettings.zzz * r3.xyz + r1.yzw;
  r2.xyz = r3.xyz * v6.yyy + r2.xyz;
  r3.x = v6.x + v6.y;
  r3.x = saturate(v6.z + r3.x);
  r3.x = 1 + -r3.x;
  r1.yzw = r1.yzw * r3.xxx + r2.xyz;
  o0.xyz = r1.yzw * r0.www + r0.xyz;
  r0.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.xy = -_AlphaETex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.z, r2.x, r3.x);
  r4.x = sin(-r0.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r0.xy, r4.yz);
  r2.y = dot(r0.xy, r4.xy);
  r0.xy = _AlphaETex_Rotation.xy + r2.xy;
  r0.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.xy).xyzw;
  r0.x = -1 + r0.w;
  r0.x = r1.x * r0.x + 1;
  o0.w = r2.w * r0.x;
  return;
}


// ps 8173b80cabb2ad08: 2 retail keyword combination(s)
void ps_8173b80cabb2ad08_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.z = r1.y * r1.x;
  r2.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r2.xy = -_AlphaETex_Rotation.xy + r2.xy;
  r1.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r1.w, r3.x, r4.x);
  r5.x = sin(-r1.w);
  r5.y = r4.x;
  r5.z = r3.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r2.xy).xyzw;
  r1.z = saturate(0.00100000005 * r1.z);
  r1.w = -1 + r2.w;
  r1.w = r1.z * r1.w + 1;
  r1.x = r1.y * r1.x + -1000;
  r1.x = saturate(5.2631578e-005 * r1.x);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r1.x = r1.x * 10 + 5;
  r2.xyz = r2.xyz * r1.xxx;
  r1.x = r1.z * -2 + 3;
  r1.y = r1.z * r1.z;
  r1.x = r1.x * r1.y;
  r1.xyz = r2.xyz * r1.xxx;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.w;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r0.xyz = r2.xyz * r0.xyz;
  r0.xyz = v4.xyz * r0.xyz + r1.xyz;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r1.xyz = r0.xyz / r0.www;
  r1.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r1.xyz);
  r1.xyz = float3(-1,-1,-1) + r1.xyz;
  r2.xyz = _SurveyedSettings.zzz * r1.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.xyz;
  r1.xyz = _RevealedSettings.zzz * r1.xyz + float3(1,1,1);
  r1.xyz = r1.xyz * r0.www;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.xyz;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.xyz;
  r1.xyz = v7.zzz * r1.xyz;
  r1.xyz = r2.xyz * v7.yyy + r1.xyz;
  r0.w = v7.x + v7.y;
  r0.w = saturate(v7.z + r0.w);
  r0.w = 1 + -r0.w;
  r0.xyz = r0.xyz * r0.www + r1.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  return;
}


// ps b18c1c3f4e8e6510: 2 retail keyword combination(s)
void ps_b18c1c3f4e8e6510_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r0.xy = -_NoiseTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xyzw = _NoiseTex_Rotation.xyxy + r1.xyxy;
  r0.xyzw = _Time.yyyy * _PanDir.xyzw + r0.xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.xy).xyzw;
  r0.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.zw).xyzw;
  r0.x = max(r1.x, r0.x);
  r0.x = -1 + r0.x;
  r0.x = _NoiseMult * r0.x + 1;
  r0.y = _TemperatureKelvin * v1.x;
  r0.z = r0.y * r0.x + -1000;
  r0.x = r0.y * r0.x;
  r0.x = saturate(0.00100000005 * r0.x);
  r1.x = saturate(5.2631578e-005 * r0.z);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r0.y = r1.x * 10 + 5;
  r0.yzw = r2.xyz * r0.yyy;
  r1.x = r0.x * -2 + 3;
  r1.y = r0.x * r0.x;
  r1.x = r1.x * r1.y;
  r0.yzw = r1.xxx * r0.yzw;
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xy = -_MainTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _MainTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xy = _MainTex_Rotation.xy + r2.xy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r1.xyz = r2.xyz * r1.xyz;
  r1.w = v1.w * r1.w;
  r1.w = _Color.w * r1.w;
  r0.yzw = v4.xyz * r1.xyz + r0.yzw;
  r1.xy = float2(-0.0625,-0.1875) + v3.zz;
  r1.z = 0.5 / _VolumeSize.z;
  r2.xy = float2(0.5,0.75) + r1.zz;
  r2.zw = float2(0.75,1) + -r2.xy;
  r1.xy = r2.zw * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r2.xy;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r1.x = r2.y ? r1.x : r1.y;
  r1.y = 8 * v3.z;
  r1.z = r2.x ? r1.y : r1.x;
  r1.xy = v3.xy / v3.ww;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.yzw * r2.www + r2.xyz;
  r0.yz = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.yz = -_AlphaETex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r0.yz = _AlphaETex_Rotation.xy + r1.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.yz).xyzw;
  r0.y = -1 + r2.w;
  r0.x = r0.x * r0.y + 1;
  o0.w = r1.w * r0.x;
  return;
}


// ps 4bab419692e33908: 2 retail keyword combination(s)
void ps_4bab419692e33908_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.z = r1.y * r1.x;
  r2.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r2.xy = -_AlphaETex_Rotation.xy + r2.xy;
  r1.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r1.w, r3.x, r4.x);
  r5.x = sin(-r1.w);
  r5.y = r4.x;
  r5.z = r3.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r2.xy).xyzw;
  r1.z = saturate(0.00100000005 * r1.z);
  r1.w = -1 + r2.w;
  r1.w = r1.z * r1.w + 1;
  r1.x = r1.y * r1.x + -1000;
  r1.x = saturate(5.2631578e-005 * r1.x);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r1.x = r1.x * 10 + 5;
  r2.xyz = r2.xyz * r1.xxx;
  r1.x = r1.z * -2 + 3;
  r1.y = r1.z * r1.z;
  r1.x = r1.x * r1.y;
  r1.xyz = r2.xyz * r1.xxx;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.w;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r0.xyz = r2.xyz * r0.xyz;
  r0.xyz = v4.xyz * r0.xyz + r1.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  return;
}


// ps 5ad7328b4ca2e30a: 2 retail keyword combination(s)
void ps_5ad7328b4ca2e30a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r0.xy = -_NoiseTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xyzw = _NoiseTex_Rotation.xyxy + r1.xyxy;
  r0.xyzw = _Time.yyyy * _PanDir.xyzw + r0.xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.xy).xyzw;
  r0.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.zw).xyzw;
  r0.x = max(r1.x, r0.x);
  r0.x = -1 + r0.x;
  r0.x = _NoiseMult * r0.x + 1;
  r0.y = _TemperatureKelvin * v1.x;
  r0.z = r0.y * r0.x + -1000;
  r0.x = r0.y * r0.x;
  r0.x = saturate(0.00100000005 * r0.x);
  r1.x = saturate(5.2631578e-005 * r0.z);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r0.y = r1.x * 10 + 5;
  r0.yzw = r2.xyz * r0.yyy;
  r1.x = r0.x * -2 + 3;
  r1.y = r0.x * r0.x;
  r1.x = r1.x * r1.y;
  r0.yzw = r1.xxx * r0.yzw;
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xy = -_MainTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _MainTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xy = _MainTex_Rotation.xy + r2.xy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r1.xyz = r2.xyz * r1.xyz;
  r1.w = v1.w * r1.w;
  r1.w = _Color.w * r1.w;
  r0.yzw = v4.xyz * r1.xyz + r0.yzw;
  r1.x = dot(r0.yzw, float3(0.212599993,0.715200007,0.0722000003));
  r2.xyz = r0.yzw / r1.xxx;
  r2.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r2.xyz);
  r2.xyz = float3(-1,-1,-1) + r2.xyz;
  r3.xyz = _RevealedSettings.zzz * r2.xyz + float3(1,1,1);
  r2.xyz = _SurveyedSettings.zzz * r2.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r1.xxx;
  r1.xyz = r3.xyz * r1.xxx;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.yzw;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.yzw;
  r1.xyz = v6.zzz * r1.xyz;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.yzw;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.yzw;
  r1.xyz = r2.xyz * v6.yyy + r1.xyz;
  r2.x = v6.x + v6.y;
  r2.x = saturate(v6.z + r2.x);
  r2.x = 1 + -r2.x;
  r0.yzw = r0.yzw * r2.xxx + r1.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v3.zz;
  r1.z = 0.5 / _VolumeSize.z;
  r2.xy = float2(0.5,0.75) + r1.zz;
  r2.zw = float2(0.75,1) + -r2.xy;
  r1.xy = r2.zw * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r2.xy;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r1.x = r2.y ? r1.x : r1.y;
  r1.y = 8 * v3.z;
  r1.z = r2.x ? r1.y : r1.x;
  r1.xy = v3.xy / v3.ww;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.yzw * r2.www + r2.xyz;
  r0.yz = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.yz = -_AlphaETex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r0.yz = _AlphaETex_Rotation.xy + r1.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.yz).xyzw;
  r0.y = -1 + r2.w;
  r0.x = r0.x * r0.y + 1;
  o0.w = r1.w * r0.x;
  return;
}


// ps ad49cde736467bc9: 2 retail keyword combination(s)
void ps_ad49cde736467bc9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.z = r1.y * r1.x;
  r2.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r2.xy = -_AlphaETex_Rotation.xy + r2.xy;
  r1.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r1.w, r3.x, r4.x);
  r5.x = sin(-r1.w);
  r5.y = r4.x;
  r5.z = r3.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r2.xy).xyzw;
  r1.z = saturate(0.00100000005 * r1.z);
  r1.w = -1 + r2.w;
  r1.w = r1.z * r1.w + 1;
  r1.x = r1.y * r1.x + -1000;
  r1.x = saturate(5.2631578e-005 * r1.x);
  r1.y = 0;
  r2.xyzw = _ColorTempLUT.Sample(sampler_ColorTempLUT, r1.xy).xyzw;
  r1.x = r1.x * 10 + 5;
  r2.xyz = r2.xyz * r1.xxx;
  r1.x = r1.z * -2 + 3;
  r1.y = r1.z * r1.z;
  r1.x = r1.x * r1.y;
  r1.xyz = r2.xyz * r1.xxx;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.w;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r0.xyz = r2.xyz * r0.xyz;
  r0.xyz = v4.xyz * r0.xyz + r1.xyz;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r1.xyz = r0.xyz / r0.www;
  r1.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r1.xyz);
  r1.xyz = float3(-1,-1,-1) + r1.xyz;
  r2.xyz = _SurveyedSettings.zzz * r1.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.xyz;
  r1.xyz = _RevealedSettings.zzz * r1.xyz + float3(1,1,1);
  r1.xyz = r1.xyz * r0.www;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.xyz;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.xyz;
  r1.xyz = v7.zzz * r1.xyz;
  r1.xyz = r2.xyz * v7.yyy + r1.xyz;
  r0.w = v7.x + v7.y;
  r0.w = saturate(v7.z + r0.w);
  r0.w = 1 + -r0.w;
  r0.xyz = r0.xyz * r0.www + r1.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  return;
}


// ps bb678a74913eaea9: 4 retail keyword combination(s)
void ps_bb678a74913eaea9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.xy = -_AlphaETex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _AlphaETex_Rotation.xy + r1.xy;
  r0.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.xy).xyzw;
  r0.x = -1 + r0.w;
  r0.yz = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r0.yz = -_NoiseTex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _NoiseTex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r1.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r0.y = max(r2.x, r1.x);
  r0.y = -1 + r0.y;
  r0.y = _NoiseMult * r0.y + 1;
  r0.z = _TemperatureKelvin * v1.x;
  r0.z = r0.z * r0.y;
  r1.xyz = _ColorBB.xyz * r0.yyy;
  r0.y = saturate(0.00100000005 * r0.z);
  r0.x = r0.y * r0.x + 1;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.yz = -_MainTex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _MainTex_Rotation.w;
  sincos(r0.w, r2.x, r3.x);
  r4.x = sin(-r0.w);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r0.yz, r4.yz);
  r2.y = dot(r0.yz, r4.xy);
  r0.yz = _MainTex_Rotation.xy + r2.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r0.y = v1.w * r2.w;
  r0.y = _Color.w * r0.y;
  o0.w = r0.y * r0.x;
  r0.xyz = _TintColor.xyz * v1.xyz;
  r0.xyz = r0.xyz * r2.xyz;
  o0.xyz = v3.xyz * r0.xyz + r1.xyz;
  return;
}


// ps b532dde7ddbd5bff: 4 retail keyword combination(s)
void ps_b532dde7ddbd5bff_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.y = r1.y * r1.x;
  r1.zw = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r1.zw = -_AlphaETex_Rotation.xy + r1.zw;
  r2.x = _Time.y * _AlphaETex_Rotation.w;
  sincos(r2.x, r3.x, r4.x);
  r2.x = sin(-r2.x);
  r2.y = r4.x;
  r2.z = r3.x;
  r3.x = dot(r1.zw, r2.yz);
  r3.y = dot(r1.zw, r2.xy);
  r1.zw = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r1.zw).xyzw;
  r1.y = saturate(0.00100000005 * r1.y);
  r1.z = -1 + r2.w;
  r1.y = r1.y * r1.z + 1;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.y;
  r1.yzw = _TintColor.xyz * v1.xyz;
  r0.xyz = r1.yzw * r0.xyz;
  r1.xyz = _ColorBB.xyz * r1.xxx;
  o0.xyz = v3.xyz * r0.xyz + r1.xyz;
  return;
}


// ps 7cb84ab3fbab5273: 4 retail keyword combination(s)
void ps_7cb84ab3fbab5273_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r0.xy = -_NoiseTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xyzw = _NoiseTex_Rotation.xyxy + r1.xyxy;
  r0.xyzw = _Time.yyyy * _PanDir.xyzw + r0.xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.xy).xyzw;
  r0.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.zw).xyzw;
  r0.x = max(r1.x, r0.x);
  r0.x = -1 + r0.x;
  r0.x = _NoiseMult * r0.x + 1;
  r0.yzw = _ColorBB.xyz * r0.xxx;
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xy = -_MainTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _MainTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xy = _MainTex_Rotation.xy + r2.xy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r1.xyz = r2.xyz * r1.xyz;
  r1.w = v1.w * r1.w;
  r1.w = _Color.w * r1.w;
  r0.yzw = v3.xyz * r1.xyz + r0.yzw;
  r1.x = dot(r0.yzw, float3(0.212599993,0.715200007,0.0722000003));
  r2.xyz = r0.yzw / r1.xxx;
  r2.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r2.xyz);
  r2.xyz = float3(-1,-1,-1) + r2.xyz;
  r3.xyz = _RevealedSettings.zzz * r2.xyz + float3(1,1,1);
  r2.xyz = _SurveyedSettings.zzz * r2.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r1.xxx;
  r1.xyz = r3.xyz * r1.xxx;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.yzw;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.yzw;
  r1.xyz = v5.zzz * r1.xyz;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.yzw;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.yzw;
  r1.xyz = r2.xyz * v5.yyy + r1.xyz;
  r2.x = v5.x + v5.y;
  r2.x = saturate(v5.z + r2.x);
  r2.x = 1 + -r2.x;
  o0.xyz = r0.yzw * r2.xxx + r1.xyz;
  r0.y = _TemperatureKelvin * v1.x;
  r0.x = r0.y * r0.x;
  r0.x = saturate(0.00100000005 * r0.x);
  r0.yz = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.yz = -_AlphaETex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r0.yz = _AlphaETex_Rotation.xy + r1.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.yz).xyzw;
  r0.y = -1 + r2.w;
  r0.x = r0.x * r0.y + 1;
  o0.w = r1.w * r0.x;
  return;
}


// ps a983eca29cbaa975: 4 retail keyword combination(s)
void ps_a983eca29cbaa975_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.y = r1.y * r1.x;
  r1.zw = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r1.zw = -_AlphaETex_Rotation.xy + r1.zw;
  r2.x = _Time.y * _AlphaETex_Rotation.w;
  sincos(r2.x, r3.x, r4.x);
  r2.x = sin(-r2.x);
  r2.y = r4.x;
  r2.z = r3.x;
  r3.x = dot(r1.zw, r2.yz);
  r3.y = dot(r1.zw, r2.xy);
  r1.zw = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r1.zw).xyzw;
  r1.y = saturate(0.00100000005 * r1.y);
  r1.z = -1 + r2.w;
  r1.y = r1.y * r1.z + 1;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.y;
  r1.yzw = _TintColor.xyz * v1.xyz;
  r0.xyz = r1.yzw * r0.xyz;
  r1.xyz = _ColorBB.xyz * r1.xxx;
  r0.xyz = v3.xyz * r0.xyz + r1.xyz;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r1.xyz = r0.xyz / r0.www;
  r1.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r1.xyz);
  r1.xyz = float3(-1,-1,-1) + r1.xyz;
  r2.xyz = _SurveyedSettings.zzz * r1.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.xyz;
  r1.xyz = _RevealedSettings.zzz * r1.xyz + float3(1,1,1);
  r1.xyz = r1.xyz * r0.www;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.xyz;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.xyz;
  r1.xyz = v6.zzz * r1.xyz;
  r1.xyz = r2.xyz * v6.yyy + r1.xyz;
  r0.w = v6.x + v6.y;
  r0.w = saturate(v6.z + r0.w);
  r0.w = 1 + -r0.w;
  o0.xyz = r0.xyz * r0.www + r1.xyz;
  return;
}


// ps 392439e205cb7e41: 2 retail keyword combination(s)
void ps_392439e205cb7e41_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r0.xy = r0.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r0.w = v3.z * r0.z;
  r0.w = floor(r0.w);
  r1.x = 1 + r0.w;
  r1.x = min(r1.x, r0.z);
  r0.z = v3.z * r0.z + -r0.w;
  r0.xyw = r0.xyw / _ScaleOffset.www;
  r1.x = r1.x / _ScaleOffset.w;
  r1.y = cmp(r1.x >= -r1.x);
  r1.z = frac(abs(r1.x));
  r2.y = floor(r1.x);
  r1.x = r1.y ? r1.z : -r1.z;
  r2.x = r1.x * _ScaleOffset.w + -1;
  r1.x = 1 / _ScaleOffset.w;
  r1.yz = r2.xy * r1.xx + r0.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.yz, 0).xyzw;
  r1.y = cmp(r0.w >= -r0.w);
  r1.z = frac(abs(r0.w));
  r3.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r3.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r3.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r2.xyzw = r2.xyzw + -r1.xyzw;
  r0.xyzw = r0.zzzz * r2.xyzw + r1.xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.yzw = _ColorBB.xyz * r1.xxx;
  r2.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xy = -_MainTex_Rotation.xy + r2.xy;
  r2.z = _Time.y * _MainTex_Rotation.w;
  sincos(r2.z, r3.x, r4.x);
  r5.x = sin(-r2.z);
  r5.z = r3.x;
  r5.y = r4.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _MainTex_Rotation.xy + r3.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r3.xyz = _TintColor.xyz * v1.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r2.w = v1.w * r2.w;
  r2.w = _Color.w * r2.w;
  r1.yzw = v4.xyz * r2.xyz + r1.yzw;
  o0.xyz = r1.yzw * r0.www + r0.xyz;
  r0.x = _TemperatureKelvin * v1.x;
  r0.x = r0.x * r1.x;
  r0.x = saturate(0.00100000005 * r0.x);
  r0.yz = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.yz = -_AlphaETex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r0.yz = _AlphaETex_Rotation.xy + r1.xy;
  r1.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.yz).xyzw;
  r0.y = -1 + r1.w;
  r0.x = r0.x * r0.y + 1;
  o0.w = r2.w * r0.x;
  return;
}


// ps d860fd45237f774c: 2 retail keyword combination(s)
void ps_d860fd45237f774c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.y = r1.y * r1.x;
  r1.zw = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r1.zw = -_AlphaETex_Rotation.xy + r1.zw;
  r2.x = _Time.y * _AlphaETex_Rotation.w;
  sincos(r2.x, r3.x, r4.x);
  r2.x = sin(-r2.x);
  r2.y = r4.x;
  r2.z = r3.x;
  r3.x = dot(r1.zw, r2.yz);
  r3.y = dot(r1.zw, r2.xy);
  r1.zw = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r1.zw).xyzw;
  r1.y = saturate(0.00100000005 * r1.y);
  r1.z = -1 + r2.w;
  r1.y = r1.y * r1.z + 1;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.y;
  r1.yzw = _TintColor.xyz * v1.xyz;
  r0.xyz = r1.yzw * r0.xyz;
  r1.xyz = _ColorBB.xyz * r1.xxx;
  r0.xyz = v4.xyz * r0.xyz + r1.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  return;
}


// ps 2828ba7a1448ce39: 2 retail keyword combination(s)
void ps_2828ba7a1448ce39_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.ww;
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r0.xy = r0.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r0.w = v3.z * r0.z;
  r0.w = floor(r0.w);
  r1.x = 1 + r0.w;
  r1.x = min(r1.x, r0.z);
  r0.z = v3.z * r0.z + -r0.w;
  r0.xyw = r0.xyw / _ScaleOffset.www;
  r1.x = r1.x / _ScaleOffset.w;
  r1.y = cmp(r1.x >= -r1.x);
  r1.z = frac(abs(r1.x));
  r2.y = floor(r1.x);
  r1.x = r1.y ? r1.z : -r1.z;
  r2.x = r1.x * _ScaleOffset.w + -1;
  r1.x = 1 / _ScaleOffset.w;
  r1.yz = r2.xy * r1.xx + r0.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.yz, 0).xyzw;
  r1.y = cmp(r0.w >= -r0.w);
  r1.z = frac(abs(r0.w));
  r3.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r3.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r3.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r2.xyzw = r2.xyzw + -r1.xyzw;
  r0.xyzw = r0.zzzz * r2.xyzw + r1.xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.yzw = _ColorBB.xyz * r1.xxx;
  r2.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r2.xy = -_MainTex_Rotation.xy + r2.xy;
  r2.z = _Time.y * _MainTex_Rotation.w;
  sincos(r2.z, r3.x, r4.x);
  r5.x = sin(-r2.z);
  r5.z = r3.x;
  r5.y = r4.x;
  r3.x = dot(r2.xy, r5.yz);
  r3.y = dot(r2.xy, r5.xy);
  r2.xy = _MainTex_Rotation.xy + r3.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r2.xy).xyzw;
  r3.xyz = _TintColor.xyz * v1.xyz;
  r2.xyz = r3.xyz * r2.xyz;
  r2.w = v1.w * r2.w;
  r2.w = _Color.w * r2.w;
  r1.yzw = v4.xyz * r2.xyz + r1.yzw;
  r2.x = dot(r1.yzw, float3(0.212599993,0.715200007,0.0722000003));
  r3.xyz = r1.yzw / r2.xxx;
  r3.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r3.xyz);
  r3.xyz = float3(-1,-1,-1) + r3.xyz;
  r4.xyz = _RevealedSettings.zzz * r3.xyz + float3(1,1,1);
  r3.xyz = _SurveyedSettings.zzz * r3.xyz + float3(1,1,1);
  r3.xyz = r3.xyz * r2.xxx;
  r2.xyz = r4.xyz * r2.xxx;
  r2.xyz = r2.xyz * _RevealedSettings.xxx + -r1.yzw;
  r2.xyz = _FogOfWarSettings.www * r2.xyz + r1.yzw;
  r2.xyz = v6.zzz * r2.xyz;
  r3.xyz = r3.xyz * _SurveyedSettings.xxx + -r1.yzw;
  r3.xyz = _FogOfWarSettings.zzz * r3.xyz + r1.yzw;
  r2.xyz = r3.xyz * v6.yyy + r2.xyz;
  r3.x = v6.x + v6.y;
  r3.x = saturate(v6.z + r3.x);
  r3.x = 1 + -r3.x;
  r1.yzw = r1.yzw * r3.xxx + r2.xyz;
  o0.xyz = r1.yzw * r0.www + r0.xyz;
  r0.x = _TemperatureKelvin * v1.x;
  r0.x = r0.x * r1.x;
  r0.x = saturate(0.00100000005 * r0.x);
  r0.yz = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.yz = -_AlphaETex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r0.yz = _AlphaETex_Rotation.xy + r1.xy;
  r1.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.yz).xyzw;
  r0.y = -1 + r1.w;
  r0.x = r0.x * r0.y + 1;
  o0.w = r2.w * r0.x;
  return;
}


// ps 3ba6696f211787f3: 2 retail keyword combination(s)
void ps_3ba6696f211787f3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.y = r1.y * r1.x;
  r1.zw = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r1.zw = -_AlphaETex_Rotation.xy + r1.zw;
  r2.x = _Time.y * _AlphaETex_Rotation.w;
  sincos(r2.x, r3.x, r4.x);
  r2.x = sin(-r2.x);
  r2.y = r4.x;
  r2.z = r3.x;
  r3.x = dot(r1.zw, r2.yz);
  r3.y = dot(r1.zw, r2.xy);
  r1.zw = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r1.zw).xyzw;
  r1.y = saturate(0.00100000005 * r1.y);
  r1.z = -1 + r2.w;
  r1.y = r1.y * r1.z + 1;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.y;
  r1.yzw = _TintColor.xyz * v1.xyz;
  r0.xyz = r1.yzw * r0.xyz;
  r1.xyz = _ColorBB.xyz * r1.xxx;
  r0.xyz = v4.xyz * r0.xyz + r1.xyz;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r1.xyz = r0.xyz / r0.www;
  r1.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r1.xyz);
  r1.xyz = float3(-1,-1,-1) + r1.xyz;
  r2.xyz = _SurveyedSettings.zzz * r1.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.xyz;
  r1.xyz = _RevealedSettings.zzz * r1.xyz + float3(1,1,1);
  r1.xyz = r1.xyz * r0.www;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.xyz;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.xyz;
  r1.xyz = v7.zzz * r1.xyz;
  r1.xyz = r2.xyz * v7.yyy + r1.xyz;
  r0.w = v7.x + v7.y;
  r0.w = saturate(v7.z + r0.w);
  r0.w = 1 + -r0.w;
  r0.xyz = r0.xyz * r0.www + r1.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r1.xyw = r1.xyz / _ScaleOffset.www;
  r2.x = cmp(r1.w >= -r1.w);
  r2.y = frac(abs(r1.w));
  r2.x = r2.x ? r2.y : -r2.y;
  r2.x = r2.x * _ScaleOffset.w + -1;
  r2.y = floor(r1.w);
  r1.w = 1 / _ScaleOffset.w;
  r2.xy = r2.xy * r1.ww + r1.xy;
  r2.z = 1 + r1.z;
  r2.z = min(r2.z, r0.w);
  r2.z = r2.z / _ScaleOffset.w;
  r2.w = cmp(r2.z >= -r2.z);
  r3.x = frac(abs(r2.z));
  r2.w = r2.w ? r3.x : -r3.x;
  r3.x = r2.w * _ScaleOffset.w + -1;
  r3.y = floor(r2.z);
  r1.xy = r3.xy * r1.ww + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.xy, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.xyzw = r3.xyzw + -r2.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r2.xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  return;
}


// ps 3df8e30b49d6d567: 2 retail keyword combination(s)
void ps_3df8e30b49d6d567_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.xy = -_AlphaETex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _AlphaETex_Rotation.xy + r1.xy;
  r0.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.xy).xyzw;
  r0.x = -1 + r0.w;
  r0.yz = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r0.yz = -_NoiseTex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _NoiseTex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r1.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r0.y = max(r2.x, r1.x);
  r0.y = -1 + r0.y;
  r0.y = _NoiseMult * r0.y + 1;
  r0.z = _TemperatureKelvin * v1.x;
  r0.z = r0.z * r0.y;
  r1.xyz = _ColorBB.xyz * r0.yyy;
  r0.y = saturate(0.00100000005 * r0.z);
  r0.x = r0.y * r0.x + 1;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.yz = -_MainTex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _MainTex_Rotation.w;
  sincos(r0.w, r2.x, r3.x);
  r4.x = sin(-r0.w);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r0.yz, r4.yz);
  r2.y = dot(r0.yz, r4.xy);
  r0.yz = _MainTex_Rotation.xy + r2.xy;
  r2.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r0.y = v1.w * r2.w;
  r0.y = _Color.w * r0.y;
  o0.w = r0.y * r0.x;
  r0.xyz = _TintColor.xyz * v1.xyz;
  r0.xyz = r0.xyz * r2.xyz;
  r0.xyz = v4.xyz * r0.xyz + r1.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r0.ww;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.w = r1.w ? r1.x : r1.y;
  r1.x = 8 * v3.z;
  r1.z = r1.z ? r1.x : r0.w;
  r1.xy = v3.xy / v3.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  return;
}


// ps 70a84d177df71b4c: 2 retail keyword combination(s)
void ps_70a84d177df71b4c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.y = r1.y * r1.x;
  r1.zw = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r1.zw = -_AlphaETex_Rotation.xy + r1.zw;
  r2.x = _Time.y * _AlphaETex_Rotation.w;
  sincos(r2.x, r3.x, r4.x);
  r2.x = sin(-r2.x);
  r2.y = r4.x;
  r2.z = r3.x;
  r3.x = dot(r1.zw, r2.yz);
  r3.y = dot(r1.zw, r2.xy);
  r1.zw = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r1.zw).xyzw;
  r1.y = saturate(0.00100000005 * r1.y);
  r1.z = -1 + r2.w;
  r1.y = r1.y * r1.z + 1;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.y;
  r1.yzw = _TintColor.xyz * v1.xyz;
  r0.xyz = r1.yzw * r0.xyz;
  r1.xyz = _ColorBB.xyz * r1.xxx;
  r0.xyz = v4.xyz * r0.xyz + r1.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  return;
}


// ps b09f88bb62194d63: 2 retail keyword combination(s)
void ps_b09f88bb62194d63_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r0.xy = -_NoiseTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xyzw = _NoiseTex_Rotation.xyxy + r1.xyxy;
  r0.xyzw = _Time.yyyy * _PanDir.xyzw + r0.xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.xy).xyzw;
  r0.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r0.zw).xyzw;
  r0.x = max(r1.x, r0.x);
  r0.x = -1 + r0.x;
  r0.x = _NoiseMult * r0.x + 1;
  r0.yzw = _ColorBB.xyz * r0.xxx;
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xy = -_MainTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _MainTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.z = r2.x;
  r4.y = r3.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xy = _MainTex_Rotation.xy + r2.xy;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r2.xyz = _TintColor.xyz * v1.xyz;
  r1.xyz = r2.xyz * r1.xyz;
  r1.w = v1.w * r1.w;
  r1.w = _Color.w * r1.w;
  r0.yzw = v4.xyz * r1.xyz + r0.yzw;
  r1.x = dot(r0.yzw, float3(0.212599993,0.715200007,0.0722000003));
  r2.xyz = r0.yzw / r1.xxx;
  r2.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r2.xyz);
  r2.xyz = float3(-1,-1,-1) + r2.xyz;
  r3.xyz = _RevealedSettings.zzz * r2.xyz + float3(1,1,1);
  r2.xyz = _SurveyedSettings.zzz * r2.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r1.xxx;
  r1.xyz = r3.xyz * r1.xxx;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.yzw;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.yzw;
  r1.xyz = v6.zzz * r1.xyz;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.yzw;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.yzw;
  r1.xyz = r2.xyz * v6.yyy + r1.xyz;
  r2.x = v6.x + v6.y;
  r2.x = saturate(v6.z + r2.x);
  r2.x = 1 + -r2.x;
  r0.yzw = r0.yzw * r2.xxx + r1.xyz;
  r1.xy = float2(-0.0625,-0.1875) + v3.zz;
  r1.z = 0.5 / _VolumeSize.z;
  r2.xy = float2(0.5,0.75) + r1.zz;
  r2.zw = float2(0.75,1) + -r2.xy;
  r1.xy = r2.zw * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r2.xy;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r1.x = r2.y ? r1.x : r1.y;
  r1.y = 8 * v3.z;
  r1.z = r2.x ? r1.y : r1.x;
  r1.xy = v3.xy / v3.ww;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.yzw * r2.www + r2.xyz;
  r0.y = _TemperatureKelvin * v1.x;
  r0.x = r0.y * r0.x;
  r0.x = saturate(0.00100000005 * r0.x);
  r0.yz = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r0.yz = -_AlphaETex_Rotation.xy + r0.yz;
  r0.w = _Time.y * _AlphaETex_Rotation.w;
  sincos(r0.w, r1.x, r2.x);
  r3.x = sin(-r0.w);
  r3.z = r1.x;
  r3.y = r2.x;
  r1.x = dot(r0.yz, r3.yz);
  r1.y = dot(r0.yz, r3.xy);
  r0.yz = _AlphaETex_Rotation.xy + r1.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r0.yz).xyzw;
  r0.y = -1 + r2.w;
  r0.x = r0.x * r0.y + 1;
  o0.w = r1.w * r0.x;
  return;
}


// ps dadc82ae04d94627: 2 retail keyword combination(s)
void ps_dadc82ae04d94627_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r0.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = w2.x / w2.y;
  r0.y = _ZBufferParams.x * r0.y + _ZBufferParams.y;
  r0.y = 1 / r0.y;
  r0.x = cmp(r0.x < r0.y);
  clip(r0.x != 0 ? -1 : 1);
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xy = -_MainTex_Rotation.xy + r0.xy;
  r0.z = _Time.y * _MainTex_Rotation.w;
  sincos(r0.z, r1.x, r2.x);
  r3.x = sin(-r0.z);
  r3.y = r2.x;
  r3.z = r1.x;
  r1.x = dot(r0.xy, r3.yz);
  r1.y = dot(r0.xy, r3.xy);
  r0.xy = _MainTex_Rotation.xy + r1.xy;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xy = v2.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
  r1.xy = -_NoiseTex_Rotation.xy + r1.xy;
  r1.z = _Time.y * _NoiseTex_Rotation.w;
  sincos(r1.z, r2.x, r3.x);
  r4.x = sin(-r1.z);
  r4.y = r3.x;
  r4.z = r2.x;
  r2.x = dot(r1.xy, r4.yz);
  r2.y = dot(r1.xy, r4.xy);
  r1.xyzw = _NoiseTex_Rotation.xyxy + r2.xyxy;
  r1.xyzw = _Time.yyyy * _PanDir.xyzw + r1.xyzw;
  r2.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.xy).xyzw;
  r1.xyzw = _NoiseTex.Sample(sampler_NoiseTex, r1.zw).xyzw;
  r1.x = max(r2.x, r1.x);
  r1.y = _TemperatureKelvin * v1.x;
  r1.x = -1 + r1.x;
  r1.x = _NoiseMult * r1.x + 1;
  r1.y = r1.y * r1.x;
  r1.zw = v2.xy * _AlphaETex_ST.xy + _AlphaETex_ST.zw;
  r1.zw = -_AlphaETex_Rotation.xy + r1.zw;
  r2.x = _Time.y * _AlphaETex_Rotation.w;
  sincos(r2.x, r3.x, r4.x);
  r2.x = sin(-r2.x);
  r2.y = r4.x;
  r2.z = r3.x;
  r3.x = dot(r1.zw, r2.yz);
  r3.y = dot(r1.zw, r2.xy);
  r1.zw = _AlphaETex_Rotation.xy + r3.xy;
  r2.xyzw = _AlphaETex.Sample(sampler_AlphaETex, r1.zw).xyzw;
  r1.y = saturate(0.00100000005 * r1.y);
  r1.z = -1 + r2.w;
  r1.y = r1.y * r1.z + 1;
  r0.w = v1.w * r0.w;
  r0.w = _Color.w * r0.w;
  o0.w = r0.w * r1.y;
  r1.yzw = _TintColor.xyz * v1.xyz;
  r0.xyz = r1.yzw * r0.xyz;
  r1.xyz = _ColorBB.xyz * r1.xxx;
  r0.xyz = v4.xyz * r0.xyz + r1.xyz;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r1.xyz = r0.xyz / r0.www;
  r1.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r1.xyz);
  r1.xyz = float3(-1,-1,-1) + r1.xyz;
  r2.xyz = _SurveyedSettings.zzz * r1.xyz + float3(1,1,1);
  r2.xyz = r2.xyz * r0.www;
  r2.xyz = r2.xyz * _SurveyedSettings.xxx + -r0.xyz;
  r2.xyz = _FogOfWarSettings.zzz * r2.xyz + r0.xyz;
  r1.xyz = _RevealedSettings.zzz * r1.xyz + float3(1,1,1);
  r1.xyz = r1.xyz * r0.www;
  r1.xyz = r1.xyz * _RevealedSettings.xxx + -r0.xyz;
  r1.xyz = _FogOfWarSettings.www * r1.xyz + r0.xyz;
  r1.xyz = v7.zzz * r1.xyz;
  r1.xyz = r2.xyz * v7.yyy + r1.xyz;
  r0.w = v7.x + v7.y;
  r0.w = saturate(v7.z + r0.w);
  r0.w = 1 + -r0.w;
  r0.xyz = r0.xyz * r0.www + r1.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r1.w = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r1.ww;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r1.w = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r1.w;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r0.xyz * r1.www + r1.xyz;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		vs_9170aa158ca163fe_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
	}
#elif !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_b1d3c29de8a945c8_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_ee95dfa715ba0ab8_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord5.xyz = o5;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_5c4f27b9e35c5104_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_b7272865e1aa8a93_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord5.xyz = o5;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_0665dbc6bee222f3_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_4c87b7788c548c01_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		vs_c01e89839ce05281_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_c7a1379930e22a2f_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float3 o7 = 0;
		vs_115af5b271429e16_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
		o.texcoord5.xyz = o7;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_1f9194262c6c7816_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float3 o7 = 0;
		vs_fe43d49810566ea6_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
		o.texcoord5.xyz = o7;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_2078bff65bb3f9b4_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_fa1ade804ad1d2c5_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d6d88547f4b9eba3_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5f72f1226120c58a_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && !defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_23248e3ced8ba678_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && !defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_820c5f18f11f7ce3_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && !defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_665a7babda16b133_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && !defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8173b80cabb2ad08_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && !defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b18c1c3f4e8e6510_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && !defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_4bab419692e33908_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && !defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5ad7328b4ca2e30a_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && !defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_ad49cde736467bc9_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_bb678a74913eaea9_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b532dde7ddbd5bff_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_7cb84ab3fbab5273_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_a983eca29cbaa975_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_392439e205cb7e41_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d860fd45237f774c_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_2828ba7a1448ce39_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_FOG_3D) && defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_3ba6696f211787f3_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_3df8e30b49d6d567_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_70a84d177df71b4c_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && defined(_IGNORE_TEMP) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b09f88bb62194d63_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && defined(_FOG_3D) && defined(_IGNORE_TEMP) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_dadc82ae04d94627_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
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
