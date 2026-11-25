Shader "BattleTech/VFX/Additive"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[HDR] _ColorBB ("Black Body Tint", Color) = (0,0,0,1)
		[MaterialToggle(_ANIMATE)] _UseBiome ("Animate", Float) = 0
		_Speed ("Speed", Float) = 1
		[MaterialToggle(_VISFOW)] _VisFOW ("Visible in Fog of War", Float) = 0
		[MaterialToggle(_VERTCOLOR)] _VertColor ("Use Particle Color", Float) = 0
		[MaterialToggle(_STROBE)] _Strobe ("Use Strobe", Float) = 0
		_StrobeFrequency ("Strobe Frequency", Float) = 1
		_StrobeCap ("Strobe Cap", Float) = 0
		_DepthFade ("Depth Fade Factor", Float) = 1
	}
	SubShader
	{
		Tags { "IgnoreProjector"="true" "PreviewType"="Plane" "Queue"="Transparent+1" "RenderType"="Transparent" }
		LOD 100
		Pass
		{
			Blend One One
			ZWrite Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ SOFTPARTICLES_ON
			#pragma multi_compile _ _ANIMATE
			#pragma multi_compile _ _BT_FOGOFWAR
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _BT_SIM_GAME
			#pragma multi_compile _ _FOG_3D
			#pragma multi_compile _ _STROBE
			#pragma multi_compile _ _VERTCOLOR
			#pragma multi_compile _ _VFX_DEPTH_SAMPLE
			#pragma multi_compile _ _VISFOW

#define cmp -

Texture2D _FilteredShadowmap;
SamplerState sampler_FilteredShadowmap;
Texture2D _BT_FogOfWar;
SamplerState sampler_BT_FogOfWar;
Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _DepthDownsampleVFX;
SamplerState sampler_DepthDownsampleVFX;
Texture2D _LightTexture0;
SamplerState sampler_LightTexture0;
Texture2D _CameraDepthTexture2;
SamplerState sampler_CameraDepthTexture2;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _FogIntegrationTex;
SamplerState sampler_FogIntegrationTex;
Texture3D _FogIntegration3D;
SamplerState sampler_FogIntegration3D;
Texture2D _TransmittanceLUT;
SamplerState sampler_TransmittanceLUT;

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
float4 _ColorBB;
float _StrobeFrequency;
float _StrobeCap;
float4 _ScaleOffset;
float3 _VolumeSize;
float _Speed;

struct appdata
{
	float4 position0 : POSITION0;
	float4 color0 : COLOR0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
};

#if !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
};
#elif !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE)
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
#elif !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
};
#elif !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
};
#elif !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_VFX_DEPTH_SAMPLE)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
};
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE)
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
#elif !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
};
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 color0 : COLOR0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
};
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
};
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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

// vs 9170aa158ca163fe: 16 retail keyword combination(s)
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


// vs d2ccdaa55b8569ed: 16 retail keyword combination(s)
void vs_d2ccdaa55b8569ed_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
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
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o5.w = r2.w;
  o5.xy = r0.xw + r0.zz;
  return;
}


// vs b1d3c29de8a945c8: 32 retail keyword combination(s)
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


// vs 7c3e53c4878b7c95: 16 retail keyword combination(s)
void vs_7c3e53c4878b7c95_impl(
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


// vs d24686246f5e07a2: 16 retail keyword combination(s)
void vs_d24686246f5e07a2_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
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
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o5.w = r2.w;
  o5.xy = r0.xw + r0.zz;
  return;
}


// vs 21f5bf5cc6597359: 32 retail keyword combination(s)
void vs_21f5bf5cc6597359_impl(
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


// vs ee95dfa715ba0ab8: 8 retail keyword combination(s)
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


// vs e34bab1bcb698b47: 8 retail keyword combination(s)
void vs_e34bab1bcb698b47_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
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
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o5.w = r2.w;
  o5.xy = r0.xw + r0.zz;
  return;
}


// vs 5c4f27b9e35c5104: 16 retail keyword combination(s)
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


// vs 18d2c11eabd1c70f: 8 retail keyword combination(s)
void vs_18d2c11eabd1c70f_impl(
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


// vs dd0409fd7d3d8e1a: 8 retail keyword combination(s)
void vs_dd0409fd7d3d8e1a_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
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
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o5.w = r2.w;
  o5.xy = r0.xw + r0.zz;
  return;
}


// vs d2c5b1c57bc5ea51: 16 retail keyword combination(s)
void vs_d2c5b1c57bc5ea51_impl(
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


// vs b7272865e1aa8a93: 8 retail keyword combination(s)
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


// vs 6f3d0ac3312ade3e: 8 retail keyword combination(s)
void vs_6f3d0ac3312ade3e_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
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
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o5.w = r2.w;
  o5.xy = r0.xw + r0.zz;
  return;
}


// vs 0665dbc6bee222f3: 16 retail keyword combination(s)
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


// vs a04a30b88be774fb: 8 retail keyword combination(s)
void vs_a04a30b88be774fb_impl(
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


// vs 39b44f42dd89f7ff: 8 retail keyword combination(s)
void vs_39b44f42dd89f7ff_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
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
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o5.w = r2.w;
  o5.xy = r0.xw + r0.zz;
  return;
}


// vs 9ebee05258183dae: 16 retail keyword combination(s)
void vs_9ebee05258183dae_impl(
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


// vs 3de79d9ead78b4d1: 64 retail keyword combination(s)
void vs_3de79d9ead78b4d1_impl(
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
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  o3.xyz = float3(0,0,0);
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o4.xyz = r0.xyz * r0.www;
  o4.w = 1;
  return;
}


// vs 1dfc327c68d6ac62: 64 retail keyword combination(s)
void vs_1dfc327c68d6ac62_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  o3.xyz = float3(0,0,0);
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r2.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  o4.xyz = r2.xyz * r1.zzz;
  o4.w = 1;
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  o5.z = -r0.x;
  r0.x = _ProjectionParams.x * r1.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r1.xw;
  o5.w = r1.w;
  o5.xy = r0.xw + r0.zz;
  return;
}


// vs 92053edd914bcbb8: 128 retail keyword combination(s)
void vs_92053edd914bcbb8_impl(
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
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o0.xyzw = r1.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  p2.xy = r1.zw;
  o5.w = r1.w;
  o3.xyz = float3(0,0,0);
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r2.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  o4.xyz = r2.xyz * r1.zzz;
  o4.w = 1;
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  o5.z = -r0.x;
  r0.x = _ProjectionParams.x * r1.y;
  r1.xz = float2(0.5,0.5) * r1.xw;
  r1.w = 0.5 * r0.x;
  o5.xy = r1.xw + r1.zz;
  return;
}


// vs 8544e7e62ab56c42: 32 retail keyword combination(s)
void vs_8544e7e62ab56c42_impl(
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
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r0.xy = float2(1024,1024) + r0.xy;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  o3.xyz = float3(0,0,0);
  r0.w = saturate(dot(r0.xyz, float3(1,1,1)));
  o5.xyz = r0.xyz;
  o4.w = 1 + -r0.w;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o4.xyz = r0.xyz * r0.www;
  return;
}


// vs 5597586e97eb6085: 32 retail keyword combination(s)
void vs_5597586e97eb6085_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float3 o6 : TEXCOORD5)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r0.xy = float2(1024,1024) + r0.xy;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  o3.xyz = float3(0,0,0);
  r0.w = saturate(dot(r0.xyz, float3(1,1,1)));
  o6.xyz = r0.xyz;
  o4.w = 1 + -r0.w;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o4.xyz = r0.xyz * r0.www;
  r0.x = unity_MatrixV[2][1] * r1.y;
  r0.x = unity_MatrixV[2][0] * r1.x + r0.x;
  r0.x = unity_MatrixV[2][2] * r1.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r1.w + r0.x;
  o5.z = -r0.x;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o5.w = r2.w;
  o5.xy = r0.xw + r0.zz;
  return;
}


// vs 278dc83af5a88578: 64 retail keyword combination(s)
void vs_278dc83af5a88578_impl(
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
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r0.xy = float2(1024,1024) + r0.xy;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  p2.xy = r2.zw;
  o5.w = r2.w;
  o3.xyz = float3(0,0,0);
  r0.w = saturate(dot(r0.xyz, float3(1,1,1)));
  o6.xyz = r0.xyz;
  o4.w = 1 + -r0.w;
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o4.xyz = r0.xyz * r0.www;
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


// vs 9767084be007470c: 32 retail keyword combination(s)
void vs_9767084be007470c_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r0.xy = float2(1024,1024) + r0.xy;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  o5.xyz = r0.xyz;
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  o3.xyz = float3(0,0,0);
  r0.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r0.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r0.xyz;
  r0.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o4.xyz = r0.xyz * r0.www;
  o4.w = 1;
  return;
}


// vs e880c71d27244e1d: 32 retail keyword combination(s)
void vs_e880c71d27244e1d_impl(
  float4 v0 : POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : COLOR0,
  inout float4 o2 : TEXCOORD0,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float3 o6 : TEXCOORD5)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r0.xy = float2(1024,1024) + r0.xy;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  o6.xyz = r0.xyz;
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  o0.xyzw = r0.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  o3.xyz = float3(0,0,0);
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r2.xyz;
  r0.z = dot(r2.xyz, r2.xyz);
  r0.z = rsqrt(r0.z);
  o4.xyz = r2.xyz * r0.zzz;
  o4.w = 1;
  r0.z = unity_MatrixV[2][1] * r1.y;
  r0.z = unity_MatrixV[2][0] * r1.x + r0.z;
  r0.z = unity_MatrixV[2][2] * r1.z + r0.z;
  r0.z = unity_MatrixV[2][3] * r1.w + r0.z;
  o5.z = -r0.z;
  r0.y = _ProjectionParams.x * r0.y;
  r1.xzw = float3(0.5,0.5,0.5) * r0.xwy;
  o5.w = r0.w;
  o5.xy = r1.xw + r1.zz;
  return;
}


// vs 54dbb8243dc3084a: 64 retail keyword combination(s)
void vs_54dbb8243dc3084a_impl(
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
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * v0.yyyy;
  r0.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * v0.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * v0.zzzz + r0.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xy = float2(unity_ObjectToWorld[0][3], unity_ObjectToWorld[2][3]) * v0.ww + r0.xz;
  r0.xy = float2(1024,1024) + r0.xy;
  r0.xy = float2(0.00048828125,0.00048828125) * r0.xy;
  r0.xyzw = _BT_FogOfWar.SampleLevel(sampler_BT_FogOfWar, r0.xy, 0).xyzw;
  o6.xyz = r0.xyz;
  r0.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r0.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r0.xyzw;
  r0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r0.xyzw;
  o0.xyzw = r0.xyzw;
  o1.xyzw = v1.xyzw;
  o2.xy = v2.xy;
  p2.xy = r0.zw;
  o5.w = r0.w;
  o3.xyz = float3(0,0,0);
  r2.xyz = float3(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1]) * v3.yyy;
  r2.xyz = float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]) * v3.xxx + r2.xyz;
  r2.xyz = float3(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2]) * v3.zzz + r2.xyz;
  r0.z = dot(r2.xyz, r2.xyz);
  r0.z = rsqrt(r0.z);
  o4.xyz = r2.xyz * r0.zzz;
  o4.w = 1;
  r0.z = unity_MatrixV[2][1] * r1.y;
  r0.z = unity_MatrixV[2][0] * r1.x + r0.z;
  r0.z = unity_MatrixV[2][2] * r1.z + r0.z;
  r0.z = unity_MatrixV[2][3] * r1.w + r0.z;
  o5.z = -r0.z;
  r0.y = _ProjectionParams.x * r0.y;
  r0.xz = float2(0.5,0.5) * r0.xw;
  r0.w = 0.5 * r0.y;
  o5.xy = r0.xw + r0.zz;
  return;
}


// vs 4c87b7788c548c01: 16 retail keyword combination(s)
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


// vs 905ce018ebf6287a: 16 retail keyword combination(s)
void vs_905ce018ebf6287a_impl(
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
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r1.x = _ProjectionParams.w * r0.w;
  o6.z = -r0.w;
  o3.z = -r1.x;
  r0.w = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.w;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r1.xw + r1.zz;
  o3.xyw = r2.xyw;
  o6.xyw = r2.xyw;
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


// vs c01e89839ce05281: 32 retail keyword combination(s)
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


// vs f5102f5dc0008775: 16 retail keyword combination(s)
void vs_f5102f5dc0008775_impl(
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


// vs 80185ccb783a24d8: 16 retail keyword combination(s)
void vs_80185ccb783a24d8_impl(
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
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r1.x = _ProjectionParams.w * r0.w;
  o6.z = -r0.w;
  o3.z = -r1.x;
  r0.w = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.w;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r1.xw + r1.zz;
  o3.xyw = r2.xyw;
  o6.xyw = r2.xyw;
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


// vs 7fc5202a0f8acc6a: 32 retail keyword combination(s)
void vs_7fc5202a0f8acc6a_impl(
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


// vs c7a1379930e22a2f: 8 retail keyword combination(s)
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


// vs 26b87f341fbd4bef: 8 retail keyword combination(s)
void vs_26b87f341fbd4bef_impl(
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
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r1.x = _ProjectionParams.w * r0.w;
  o6.z = -r0.w;
  o3.z = -r1.x;
  r0.w = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.w;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r1.xw + r1.zz;
  o3.xyw = r2.xyw;
  o6.xyw = r2.xyw;
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


// vs 115af5b271429e16: 16 retail keyword combination(s)
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


// vs 602e6ac83cdf68e9: 8 retail keyword combination(s)
void vs_602e6ac83cdf68e9_impl(
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


// vs 176eaa0f735ffe41: 8 retail keyword combination(s)
void vs_176eaa0f735ffe41_impl(
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
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r1.x = _ProjectionParams.w * r0.w;
  o6.z = -r0.w;
  o3.z = -r1.x;
  r0.w = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.w;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r1.xw + r1.zz;
  o3.xyw = r2.xyw;
  o6.xyw = r2.xyw;
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


// vs 6ac8e01c0d3bf7d9: 16 retail keyword combination(s)
void vs_6ac8e01c0d3bf7d9_impl(
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


// vs 1f9194262c6c7816: 8 retail keyword combination(s)
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


// vs f94bab6362288308: 8 retail keyword combination(s)
void vs_f94bab6362288308_impl(
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
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r1.x = _ProjectionParams.w * r0.w;
  o6.z = -r0.w;
  o3.z = -r1.x;
  r0.w = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.w;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r1.xw + r1.zz;
  o3.xyw = r2.xyw;
  o6.xyw = r2.xyw;
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


// vs fe43d49810566ea6: 16 retail keyword combination(s)
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


// vs 2a01d8d4d00ffd4e: 8 retail keyword combination(s)
void vs_2a01d8d4d00ffd4e_impl(
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


// vs 23f40c066c8e7257: 8 retail keyword combination(s)
void vs_23f40c066c8e7257_impl(
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
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  r1.x = _ProjectionParams.w * r0.w;
  o6.z = -r0.w;
  o3.z = -r1.x;
  r0.w = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.w;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r1.xw + r1.zz;
  o3.xyw = r2.xyw;
  o6.xyw = r2.xyw;
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


// vs cc313cb78c03cfa6: 16 retail keyword combination(s)
void vs_cc313cb78c03cfa6_impl(
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


// ps 1d1f86c671e3450c: 12 retail keyword combination(s)
void ps_1d1f86c671e3450c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 6df7f86e2ae3260d: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_6df7f86e2ae3260d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 6df7f86e2ae3260d: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_6df7f86e2ae3260d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps b85852e57af45546: 12 retail keyword combination(s)
void ps_b85852e57af45546_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps e79ce1f7ea27a415: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_e79ce1f7ea27a415_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps e79ce1f7ea27a415: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_e79ce1f7ea27a415_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 3eac9f50b477c0aa: 12 retail keyword combination(s)
void ps_3eac9f50b477c0aa_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v4.www * r1.xyz;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


// ps 061fe30890b4a48f: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_061fe30890b4a48f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 061fe30890b4a48f: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_061fe30890b4a48f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 0a8835aae4018a12: 12 retail keyword combination(s)
void ps_0a8835aae4018a12_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v4.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  o0.xyzw = r1.xxxx * r0.xyzw;
  return;
}


// ps bd639b54834f4036: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_bd639b54834f4036_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps bd639b54834f4036: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_bd639b54834f4036_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 9be5fc82844ea671: 12 retail keyword combination(s)
void ps_9be5fc82844ea671_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  o0.w = r0.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


// ps 35bdb86d1c2562f7: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_35bdb86d1c2562f7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 35bdb86d1c2562f7: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_35bdb86d1c2562f7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps dcb605d7331f980a: 12 retail keyword combination(s)
void ps_dcb605d7331f980a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 142de69577b468de: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_142de69577b468de_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 142de69577b468de: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_142de69577b468de_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 3c956982db563583: 12 retail keyword combination(s)
void ps_3c956982db563583_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


// ps 5cabeb90b77c4fdb: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_5cabeb90b77c4fdb_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 5cabeb90b77c4fdb: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_5cabeb90b77c4fdb_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps b55b184ef94f554d: 12 retail keyword combination(s)
void ps_b55b184ef94f554d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v4.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  o0.xyzw = r1.xxxx * r0.xyzw;
  return;
}


// ps 58a6990dd4bb2e9b: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_58a6990dd4bb2e9b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 58a6990dd4bb2e9b: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_58a6990dd4bb2e9b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps e2052e03cd0b5878: 12 retail keyword combination(s)
void ps_e2052e03cd0b5878_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps f93e3380d276150e: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_f93e3380d276150e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps f93e3380d276150e: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_f93e3380d276150e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps d8ccadcacd4b4199: 12 retail keyword combination(s)
void ps_d8ccadcacd4b4199_impl(
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
  float4 r0;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 19e9c73a51d50f72: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_19e9c73a51d50f72_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 19e9c73a51d50f72: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_19e9c73a51d50f72_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 645651b9875767fc: 12 retail keyword combination(s)
void ps_645651b9875767fc_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v4.www * r1.xyz;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


// ps 76dcc88a667b3723: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_76dcc88a667b3723_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 76dcc88a667b3723: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_76dcc88a667b3723_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 393c083637eda7af: 12 retail keyword combination(s)
void ps_393c083637eda7af_impl(
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
  float4 r0,r1;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v4.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  o0.xyzw = r1.xxxx * r0.xyzw;
  return;
}


// ps 9f9e23d3580f4798: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_9f9e23d3580f4798_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 9f9e23d3580f4798: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_9f9e23d3580f4798_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps baee8334020952db: 12 retail keyword combination(s)
void ps_baee8334020952db_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  o0.w = r0.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


// ps 27865b9afe334717: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_27865b9afe334717_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 27865b9afe334717: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_27865b9afe334717_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 4fde9fd19f983d4b: 12 retail keyword combination(s)
void ps_4fde9fd19f983d4b_impl(
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
  float4 r0;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 9bfb0e9deda7c015: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_9bfb0e9deda7c015_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 9bfb0e9deda7c015: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_9bfb0e9deda7c015_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 7b773b6934f3c742: 12 retail keyword combination(s)
void ps_7b773b6934f3c742_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


// ps 5a16aeda147f643b: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_5a16aeda147f643b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 5a16aeda147f643b: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_5a16aeda147f643b_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 59a45a3f61f046e5: 12 retail keyword combination(s)
void ps_59a45a3f61f046e5_impl(
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
  float4 r0,r1;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v4.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  o0.xyzw = r1.xxxx * r0.xyzw;
  return;
}


// ps 44c099c1bbd0a585: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_44c099c1bbd0a585_impl(
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
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 44c099c1bbd0a585: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_44c099c1bbd0a585_impl(
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
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 7f3c4809e93e7c72: 2 retail keyword combination(s)
void ps_7f3c4809e93e7c72_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v5.www * r1.xyz;
  o0.w = r1.w;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 372eab68555a6a27: 2 retail keyword combination(s)
void ps_372eab68555a6a27_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  o0.w = r1.w;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 58e4dc5c001ba22c: 2 retail keyword combination(s)
void ps_58e4dc5c001ba22c_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 8fe439ee8ea5ca50: 2 retail keyword combination(s)
void ps_8fe439ee8ea5ca50_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r2.x = r1.z / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.z;
  r2.w = min(r2.w, r0.w);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.x = r3.w + -r2.w;
  r0.w = r0.w * r1.x + r2.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps b7bf31537f20f995: 2 retail keyword combination(s)
void ps_b7bf31537f20f995_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v5.www * r1.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps e9b1f764f0eb1570: 2 retail keyword combination(s)
void ps_e9b1f764f0eb1570_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.zw).xyzw;
  r0.z = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.z = 1 / r0.z;
  r0.z = saturate(-v6.z + r0.z);
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = r1.xyz * r0.zzz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps dbd8d1e5c5b3e939: 2 retail keyword combination(s)
void ps_dbd8d1e5c5b3e939_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 60a7e752dfd88774: 2 retail keyword combination(s)
void ps_60a7e752dfd88774_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 52cdf3d6a2c8020e: 2 retail keyword combination(s)
void ps_52cdf3d6a2c8020e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 73f60a63cea3569d: 2 retail keyword combination(s)
void ps_73f60a63cea3569d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps fb63adc25b100b32: 2 retail keyword combination(s)
void ps_fb63adc25b100b32_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps ef7b522225c275b1: 2 retail keyword combination(s)
void ps_ef7b522225c275b1_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r2.x = r1.z / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.z;
  r2.w = min(r2.w, r0.w);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.x = r3.w + -r2.w;
  r0.w = r0.w * r1.x + r2.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 8ce9f09ebecdf043: 2 retail keyword combination(s)
void ps_8ce9f09ebecdf043_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps 1a3c279b24428d85: 2 retail keyword combination(s)
void ps_1a3c279b24428d85_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.zw).xyzw;
  r0.z = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.z = 1 / r0.z;
  r0.z = saturate(-v6.z + r0.z);
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r2.xyz = r2.xyz * r0.zzz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps 93b32ede42d1d820: 2 retail keyword combination(s)
void ps_93b32ede42d1d820_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 983048df5131b10f: 2 retail keyword combination(s)
void ps_983048df5131b10f_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 5fb4e6dbe4c5ffe0: 2 retail keyword combination(s)
void ps_5fb4e6dbe4c5ffe0_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v5.www * r1.xyz;
  o0.w = r1.w;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps efc8be97e8a38a9c: 2 retail keyword combination(s)
void ps_efc8be97e8a38a9c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  o0.w = r1.w;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps d3009b71940450c3: 2 retail keyword combination(s)
void ps_d3009b71940450c3_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 8da7de7a28f5603e: 2 retail keyword combination(s)
void ps_8da7de7a28f5603e_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r2.x = r1.z / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.z;
  r2.w = min(r2.w, r0.w);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.x = r3.w + -r2.w;
  r0.w = r0.w * r1.x + r2.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 21c68c9cea825b0a: 2 retail keyword combination(s)
void ps_21c68c9cea825b0a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v5.www * r1.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps 1cd454cdbde4d650: 2 retail keyword combination(s)
void ps_1cd454cdbde4d650_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.zw).xyzw;
  r0.z = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.z = 1 / r0.z;
  r0.z = saturate(-v6.z + r0.z);
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = r1.xyz * r0.zzz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps 0ad578ec02322b73: 2 retail keyword combination(s)
void ps_0ad578ec02322b73_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps d9883cf94aeccb71: 2 retail keyword combination(s)
void ps_d9883cf94aeccb71_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps e2e08ba8b54cc724: 2 retail keyword combination(s)
void ps_e2e08ba8b54cc724_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 1dab3c84812a941e: 2 retail keyword combination(s)
void ps_1dab3c84812a941e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps e669024c8476282a: 2 retail keyword combination(s)
void ps_e669024c8476282a_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps f75a9e79887e9b2d: 2 retail keyword combination(s)
void ps_f75a9e79887e9b2d_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r2.x = r1.z / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.z;
  r2.w = min(r2.w, r0.w);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.x = r3.w + -r2.w;
  r0.w = r0.w * r1.x + r2.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps f8506d465630b908: 2 retail keyword combination(s)
void ps_f8506d465630b908_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps fef98b99fc858902: 2 retail keyword combination(s)
void ps_fef98b99fc858902_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.zw).xyzw;
  r0.z = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.z = 1 / r0.z;
  r0.z = saturate(-v6.z + r0.z);
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r2.xyz = r2.xyz * r0.zzz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps cdf269c902a0a9c4: 2 retail keyword combination(s)
void ps_cdf269c902a0a9c4_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 49dccf5182356dfc: 2 retail keyword combination(s)
void ps_49dccf5182356dfc_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps da634293e88febab: 2 retail keyword combination(s)
void ps_da634293e88febab_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = v5.www * r1.xyz;
  o0.w = r1.w;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 5bf9799f3affc4f4: 2 retail keyword combination(s)
void ps_5bf9799f3affc4f4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps e0fff85b6ea88cfa: 2 retail keyword combination(s)
void ps_e0fff85b6ea88cfa_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 665528cc4e889b3b: 2 retail keyword combination(s)
void ps_665528cc4e889b3b_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r2.y;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r2.www * r0.xyz;
  o0.w = r1.w;
  return;
}


// ps 735eac5c1ad0b3b0: 2 retail keyword combination(s)
void ps_735eac5c1ad0b3b0_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v5.www * r1.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 5f2091796937aecf: 2 retail keyword combination(s)
void ps_5f2091796937aecf_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = r1.xyz * r0.yyy;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 8667b51449e23562: 2 retail keyword combination(s)
void ps_8667b51449e23562_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 59864acf71cd3d65: 2 retail keyword combination(s)
void ps_59864acf71cd3d65_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps a83fafa08e830fa2: 2 retail keyword combination(s)
void ps_a83fafa08e830fa2_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 5d3ffa7b8ace838e: 2 retail keyword combination(s)
void ps_5d3ffa7b8ace838e_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps d2a0f98276ef210b: 2 retail keyword combination(s)
void ps_d2a0f98276ef210b_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 8300f023cf49b277: 2 retail keyword combination(s)
void ps_8300f023cf49b277_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r2.y;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r2.www * r0.xyz;
  o0.w = r1.w;
  return;
}


// ps b5d98aee92264ae7: 2 retail keyword combination(s)
void ps_b5d98aee92264ae7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 66328b3819656159: 2 retail keyword combination(s)
void ps_66328b3819656159_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r2.xyz = r2.xyz * r0.yyy;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps f06bc4328bffc012: 2 retail keyword combination(s)
void ps_f06bc4328bffc012_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps e27ce24f52b08719: 2 retail keyword combination(s)
void ps_e27ce24f52b08719_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 89c520443a6803ac: 2 retail keyword combination(s)
void ps_89c520443a6803ac_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = v5.www * r1.xyz;
  o0.w = r1.w;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 619c49cbe129763a: 2 retail keyword combination(s)
void ps_619c49cbe129763a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 7133d1fbfa492be5: 2 retail keyword combination(s)
void ps_7133d1fbfa492be5_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 31bc5c71c96bf220: 2 retail keyword combination(s)
void ps_31bc5c71c96bf220_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r2.y;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r2.www * r0.xyz;
  o0.w = r1.w;
  return;
}


// ps d9209afd4b909f00: 2 retail keyword combination(s)
void ps_d9209afd4b909f00_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v5.www * r1.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 26dcfee47bcacdd7: 2 retail keyword combination(s)
void ps_26dcfee47bcacdd7_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = r1.xyz * r0.yyy;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 9b3fac59b96dc981: 2 retail keyword combination(s)
void ps_9b3fac59b96dc981_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps aa42c4591427c828: 2 retail keyword combination(s)
void ps_aa42c4591427c828_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 82878e6ff42e6568: 2 retail keyword combination(s)
void ps_82878e6ff42e6568_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 1a4e2c7966c889e9: 2 retail keyword combination(s)
void ps_1a4e2c7966c889e9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 265194d61ce441fe: 2 retail keyword combination(s)
void ps_265194d61ce441fe_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 4c4ec6f0400b212b: 2 retail keyword combination(s)
void ps_4c4ec6f0400b212b_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r2.y;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r2.www * r0.xyz;
  o0.w = r1.w;
  return;
}


// ps 85f67dcd7b174651: 2 retail keyword combination(s)
void ps_85f67dcd7b174651_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 36d367d9d9b9c5a4: 2 retail keyword combination(s)
void ps_36d367d9d9b9c5a4_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.xy = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r2.xyz = r2.xyz * r0.yyy;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps f5ddfe14a3045dca: 2 retail keyword combination(s)
void ps_f5ddfe14a3045dca_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps fde6087a3a6021d2: 2 retail keyword combination(s)
void ps_fde6087a3a6021d2_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r0.zw = v2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps b556f5c7f44f6be1: 12 retail keyword combination(s)
void ps_b556f5c7f44f6be1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 948fe9515b9b951a: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_948fe9515b9b951a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 948fe9515b9b951a: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_948fe9515b9b951a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps b4f0399fe42e477c: 12 retail keyword combination(s)
void ps_b4f0399fe42e477c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 554a33f86e0291ba: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_554a33f86e0291ba_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 554a33f86e0291ba: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_554a33f86e0291ba_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps fdd6695ec0814f91: 12 retail keyword combination(s)
void ps_fdd6695ec0814f91_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v4.www * r1.xyz;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


// ps 9d131c509e9a7377: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_9d131c509e9a7377_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 9d131c509e9a7377: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_9d131c509e9a7377_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps e8040d47548b359f: 12 retail keyword combination(s)
void ps_e8040d47548b359f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v4.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  o0.xyzw = r1.xxxx * r0.xyzw;
  return;
}


// ps 6c43433533593467: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_6c43433533593467_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 6c43433533593467: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_6c43433533593467_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps cd33a6d7288a2dac: 12 retail keyword combination(s)
void ps_cd33a6d7288a2dac_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  o0.w = r0.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


// ps 1ddac73080f3c3a8: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_1ddac73080f3c3a8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 1ddac73080f3c3a8: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_1ddac73080f3c3a8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 4f568618211c8af6: 12 retail keyword combination(s)
void ps_4f568618211c8af6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps d7a76e637a03ef74: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_d7a76e637a03ef74_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps d7a76e637a03ef74: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_d7a76e637a03ef74_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps b8b3365ec1797f78: 12 retail keyword combination(s)
void ps_b8b3365ec1797f78_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


// ps 8be58d14dfcea62f: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_8be58d14dfcea62f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 8be58d14dfcea62f: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_8be58d14dfcea62f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 3c2aea2c61039773: 12 retail keyword combination(s)
void ps_3c2aea2c61039773_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v4.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  o0.xyzw = r1.xxxx * r0.xyzw;
  return;
}


// ps af28f7692d741f71: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_af28f7692d741f71_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps af28f7692d741f71: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_af28f7692d741f71_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  float2 w2 : TEXCOORD6,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 645eeba6cc52b2bb: 12 retail keyword combination(s)
void ps_645eeba6cc52b2bb_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 55d74355d64a591c: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_55d74355d64a591c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 55d74355d64a591c: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_55d74355d64a591c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 07d4c2c2e65e9075: 12 retail keyword combination(s)
void ps_07d4c2c2e65e9075_impl(
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
  float4 r0;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 301a8f8abd9bd97a: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_301a8f8abd9bd97a_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 301a8f8abd9bd97a: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_301a8f8abd9bd97a_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 4508763d0716b187: 12 retail keyword combination(s)
void ps_4508763d0716b187_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v4.www * r1.xyz;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


// ps ed1503ad88086707: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_ed1503ad88086707_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps ed1503ad88086707: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_ed1503ad88086707_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 30c94d564ce15b69: 12 retail keyword combination(s)
void ps_30c94d564ce15b69_impl(
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
  float4 r0,r1;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v4.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  o0.xyzw = r1.xxxx * r0.xyzw;
  return;
}


// ps 8d62b883babc86ef: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_8d62b883babc86ef_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 8d62b883babc86ef: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_8d62b883babc86ef_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 74f291489e8d0fc3: 12 retail keyword combination(s)
void ps_74f291489e8d0fc3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  o0.w = r0.w;
  o0.xyz = v4.www * r0.xyz;
  return;
}


// ps 9c09979bfc8bbcd0: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_9c09979bfc8bbcd0_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 9c09979bfc8bbcd0: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_9c09979bfc8bbcd0_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  return;
}


#endif
// ps 601eb4b920321e84: 12 retail keyword combination(s)
void ps_601eb4b920321e84_impl(
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
  float4 r0;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 196cedfba200e012: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_196cedfba200e012_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 196cedfba200e012: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_196cedfba200e012_impl(
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  o0.xyz = v4.www * r0.xyz;
  o0.w = r1.w;
  return;
}


#endif
// ps 83ce8f80f839b426: 12 retail keyword combination(s)
void ps_83ce8f80f839b426_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float3 v5 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


// ps cf80563ff5d23f98: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_cf80563ff5d23f98_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps cf80563ff5d23f98: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
void ps_cf80563ff5d23f98_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v5.xy / v5.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v5.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v4.www * r0.yzw;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps a3aa52cc7d186e4f: 12 retail keyword combination(s)
void ps_a3aa52cc7d186e4f_impl(
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
  float4 r0,r1;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v4.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  o0.xyzw = r1.xxxx * r0.xyzw;
  return;
}


// ps 157718d4cec9381f: 4 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_157718d4cec9381f_impl(
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
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 157718d4cec9381f: 8 retail keyword combination(s)
#if defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
void ps_157718d4cec9381f_impl(
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
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v5.xy / v5.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v5.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v4.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  o0.xyzw = r1.xyzw * r0.xxxx;
  return;
}


#endif
// ps 8cad04215ddd97e0: 2 retail keyword combination(s)
void ps_8cad04215ddd97e0_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v5.www * r1.xyz;
  o0.w = r1.w;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 0ce8d1f61279074d: 2 retail keyword combination(s)
void ps_0ce8d1f61279074d_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  o0.w = r1.w;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps fa5656e022683ede: 2 retail keyword combination(s)
void ps_fa5656e022683ede_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 5494bd7685c53129: 2 retail keyword combination(s)
void ps_5494bd7685c53129_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r2.x = r1.z / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.z;
  r2.w = min(r2.w, r0.w);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.x = r3.w + -r2.w;
  r0.w = r0.w * r1.x + r2.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps a5d3c680463d0c1c: 2 retail keyword combination(s)
void ps_a5d3c680463d0c1c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v5.www * r1.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps 4b7896791b842e96: 2 retail keyword combination(s)
void ps_4b7896791b842e96_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.zw).xyzw;
  r0.z = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.z = 1 / r0.z;
  r0.z = saturate(-v6.z + r0.z);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r1.xy = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = r1.xyz * r0.zzz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps e93d6a7121ca54f3: 2 retail keyword combination(s)
void ps_e93d6a7121ca54f3_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 0577ada4edf34fea: 2 retail keyword combination(s)
void ps_0577ada4edf34fea_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 6944a86a0def716f: 2 retail keyword combination(s)
void ps_6944a86a0def716f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 507820f16cd9da10: 2 retail keyword combination(s)
void ps_507820f16cd9da10_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 0660ffe342356e68: 2 retail keyword combination(s)
void ps_0660ffe342356e68_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps c249832144c513b7: 2 retail keyword combination(s)
void ps_c249832144c513b7_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r2.x = r1.z / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.z;
  r2.w = min(r2.w, r0.w);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.x = r3.w + -r2.w;
  r0.w = r0.w * r1.x + r2.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps abd485d09a66422a: 2 retail keyword combination(s)
void ps_abd485d09a66422a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps bd547b9b30896936: 2 retail keyword combination(s)
void ps_bd547b9b30896936_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.zw).xyzw;
  r0.z = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.z = 1 / r0.z;
  r0.z = saturate(-v6.z + r0.z);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r1.xy = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r2.xyz = r2.xyz * r0.zzz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps c46e85adada0b9d2: 2 retail keyword combination(s)
void ps_c46e85adada0b9d2_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 3f6923aa561782d9: 2 retail keyword combination(s)
void ps_3f6923aa561782d9_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps edfad4f48c92562a: 2 retail keyword combination(s)
void ps_edfad4f48c92562a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v5.www * r1.xyz;
  o0.w = r1.w;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 36050a293d29fc40: 2 retail keyword combination(s)
void ps_36050a293d29fc40_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = r1.xyz * r0.yyy;
  o0.w = r1.w;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 1c603e65ac861dc0: 2 retail keyword combination(s)
void ps_1c603e65ac861dc0_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 700d71ccb453800a: 2 retail keyword combination(s)
void ps_700d71ccb453800a_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r2.x = r1.z / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.z;
  r2.w = min(r2.w, r0.w);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.x = r3.w + -r2.w;
  r0.w = r0.w * r1.x + r2.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps fc304e481166e846: 2 retail keyword combination(s)
void ps_fc304e481166e846_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v5.www * r1.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps ff438da597437e22: 2 retail keyword combination(s)
void ps_ff438da597437e22_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.zw).xyzw;
  r0.z = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.z = 1 / r0.z;
  r0.z = saturate(-v6.z + r0.z);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r1.xy = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = r1.xyz * r0.zzz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps 9ffad3b0f656cd10: 2 retail keyword combination(s)
void ps_9ffad3b0f656cd10_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 113a1d63b5b94b1a: 2 retail keyword combination(s)
void ps_113a1d63b5b94b1a_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps dbed363f85f4f7c1: 2 retail keyword combination(s)
void ps_dbed363f85f4f7c1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.yzw = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps 015ef64c602f7f1f: 2 retail keyword combination(s)
void ps_015ef64c602f7f1f_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.yzw = r1.xyz * r0.yyy;
  r0.yzw = v5.www * r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  return;
}


// ps c391c58dc47216fc: 2 retail keyword combination(s)
void ps_c391c58dc47216fc_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 6ee835695e00c5aa: 2 retail keyword combination(s)
void ps_6ee835695e00c5aa_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.w = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.z = v3.z * r0.w;
  r1.z = floor(r1.z);
  r2.x = r1.z / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.z;
  r2.w = min(r2.w, r0.w);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r0.w = v3.z * r0.w + -r1.z;
  r1.x = r3.w + -r2.w;
  r0.w = r0.w * r1.x + r2.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 7ccd66e0611f6dd2: 2 retail keyword combination(s)
void ps_7ccd66e0611f6dd2_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps 715d674871dab1ef: 2 retail keyword combination(s)
void ps_715d674871dab1ef_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
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
  r2.y = floor(r0.w);
  r0.w = r1.y ? r1.z : -r1.z;
  r2.x = r0.w * _ScaleOffset.w + -1;
  r0.xy = r2.xy * r1.xx + r0.xy;
  r1.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r0.xy, 0).xyzw;
  r0.x = r2.w + -r1.w;
  r0.x = r0.z * r0.x + r1.w;
  r0.y = _Time.x * _StrobeFrequency;
  r0.y = sin(r0.y);
  r0.y = r0.y * 0.5 + 0.5;
  r0.y = -_StrobeCap + r0.y;
  r0.z = 1 + -_StrobeCap;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.zw = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.zw).xyzw;
  r0.z = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.z = 1 / r0.z;
  r0.z = saturate(-v6.z + r0.z);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r1.xy = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r2.xyz = r2.xyz * r0.zzz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  return;
}


// ps f1164f867b64117f: 2 retail keyword combination(s)
void ps_f1164f867b64117f_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 409587338e5ef15a: 2 retail keyword combination(s)
void ps_409587338e5ef15a_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r1.xy = r1.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r1.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r1.w = v3.z * r1.z;
  r1.w = floor(r1.w);
  r2.x = r1.w / _ScaleOffset.w;
  r2.y = cmp(r2.x >= -r2.x);
  r2.z = frac(abs(r2.x));
  r2.y = r2.y ? r2.z : -r2.z;
  r3.x = r2.y * _ScaleOffset.w + -1;
  r3.y = floor(r2.x);
  r1.xy = r1.xy / _ScaleOffset.ww;
  r2.x = 1 / _ScaleOffset.w;
  r2.yz = r3.xy * r2.xx + r1.xy;
  r2.w = 1 + r1.w;
  r2.w = min(r2.w, r1.z);
  r2.w = r2.w / _ScaleOffset.w;
  r3.x = cmp(r2.w >= -r2.w);
  r3.y = frac(abs(r2.w));
  r3.x = r3.x ? r3.y : -r3.y;
  r3.x = r3.x * _ScaleOffset.w + -1;
  r3.y = floor(r2.w);
  r1.xy = r3.xy * r2.xx + r1.xy;
  r2.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r2.yz, 0).xyzw;
  r3.xyzw = _FogIntegrationTex.SampleLevel(sampler_FogIntegrationTex, r1.xy, 0).xyzw;
  r1.x = v3.z * r1.z + -r1.w;
  r1.y = r3.w + -r2.w;
  r1.x = r1.x * r1.y + r2.w;
  o0.xyz = r1.xxx * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 0ce86319d1970eb3: 2 retail keyword combination(s)
void ps_0ce86319d1970eb3_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = v5.www * r1.xyz;
  o0.w = r1.w;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 9349f91b977b4e96: 2 retail keyword combination(s)
void ps_9349f91b977b4e96_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps c0fde21ae658b22e: 2 retail keyword combination(s)
void ps_c0fde21ae658b22e_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 9240cbf3febe3bbc: 2 retail keyword combination(s)
void ps_9240cbf3febe3bbc_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r2.y;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r2.www * r0.xyz;
  o0.w = r1.w;
  return;
}


// ps 7103209d963383d0: 2 retail keyword combination(s)
void ps_7103209d963383d0_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v5.www * r1.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 2d0e6b13282ab787: 2 retail keyword combination(s)
void ps_2d0e6b13282ab787_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r1.xy = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = r1.xyz * r0.yyy;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps f50ae5d5d618a2ac: 2 retail keyword combination(s)
void ps_f50ae5d5d618a2ac_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 49dce72bbfc6310e: 2 retail keyword combination(s)
void ps_49dce72bbfc6310e_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 8f43ef2ebfa06170: 2 retail keyword combination(s)
void ps_8f43ef2ebfa06170_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 1028f1b96fefc9d1: 2 retail keyword combination(s)
void ps_1028f1b96fefc9d1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps c188cde2eb7d8165: 2 retail keyword combination(s)
void ps_c188cde2eb7d8165_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps d1d29f19c9078c0d: 2 retail keyword combination(s)
void ps_d1d29f19c9078c0d_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r2.y;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r2.www * r0.xyz;
  o0.w = r1.w;
  return;
}


// ps 7455e088ab3d6cd0: 2 retail keyword combination(s)
void ps_7455e088ab3d6cd0_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 1357c08201de21fe: 2 retail keyword combination(s)
void ps_1357c08201de21fe_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v5.www * r0.yzw;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = float2(-0.0625,-0.1875) + v3.zz;
  r1.z = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r1.zz;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r1.x = r1.w ? r1.x : r1.y;
  r1.y = 8 * v3.z;
  r1.z = r1.z ? r1.y : r1.x;
  r1.xy = v3.xy / v3.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 580a4687f09d7fc0: 2 retail keyword combination(s)
void ps_580a4687f09d7fc0_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 10d105b98096e387: 2 retail keyword combination(s)
void ps_10d105b98096e387_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 20d3d115f62db18a: 2 retail keyword combination(s)
void ps_20d3d115f62db18a_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = v5.www * r1.xyz;
  o0.w = r1.w;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps b401dd01a02c5552: 2 retail keyword combination(s)
void ps_b401dd01a02c5552_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = r1.xyz * r0.xxx;
  o0.w = r1.w;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 15e9a972472bd61d: 2 retail keyword combination(s)
void ps_15e9a972472bd61d_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 92430dabce08fad8: 2 retail keyword combination(s)
void ps_92430dabce08fad8_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r2.y;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r2.www * r0.xyz;
  o0.w = r1.w;
  return;
}


// ps 9a888f12a9148781: 2 retail keyword combination(s)
void ps_9a888f12a9148781_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v5.www * r1.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps e8b3580d706c1a10: 2 retail keyword combination(s)
void ps_e8b3580d706c1a10_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r1.xy = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r1.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = r1.xyz * r0.yyy;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 69832abd86fee73d: 2 retail keyword combination(s)
void ps_69832abd86fee73d_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v5.www * r0.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 67c86f7b3a4349d9: 2 retail keyword combination(s)
void ps_67c86f7b3a4349d9_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps d40c0443d8e91dab: 2 retail keyword combination(s)
void ps_d40c0443d8e91dab_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r0.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps 602f1b465541c256: 2 retail keyword combination(s)
void ps_602f1b465541c256_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  o0.w = r1.w;
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  return;
}


// ps c1c3d74527fd5dc0: 2 retail keyword combination(s)
void ps_c1c3d74527fd5dc0_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r0.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 5e6cb2ab8390e70e: 2 retail keyword combination(s)
void ps_5e6cb2ab8390e70e_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.xyz = v5.www * r0.xyz;
  r1.xy = v3.xy / v3.ww;
  r0.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r0.w : r2.y;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r2.www * r0.xyz;
  o0.w = r1.w;
  return;
}


// ps 2d6d73b051cf9881: 2 retail keyword combination(s)
void ps_2d6d73b051cf9881_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float3 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.0625,-0.1875) + v3.zz;
  r0.z = 0.5 / _VolumeSize.z;
  r0.zw = float2(0.5,0.75) + r0.zz;
  r1.xy = float2(0.75,1) + -r0.zw;
  r0.xy = r1.xy * r0.xy;
  r0.xy = r0.xy * float2(8,1.23076928) + r0.zw;
  r0.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r0.x = r0.w ? r0.x : r0.y;
  r0.y = 8 * v3.z;
  r0.z = r0.z ? r0.y : r0.x;
  r0.xy = v3.xy / v3.ww;
  r0.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r0.xyz).xyzw;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.yz = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.yz).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r1.xyz = v5.www * r2.xyz;
  r1.xyzw = r1.xyzw * r0.xxxx;
  o0.xyz = r1.xyz * r0.www;
  o0.w = r1.w;
  return;
}


// ps 059692ca5c7f7822: 2 retail keyword combination(s)
void ps_059692ca5c7f7822_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float3 v7 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 + -_StrobeCap;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v6.xy / v6.ww;
  r1.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = saturate(-v6.z + r0.y);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.yzw = r2.xyz * r0.yyy;
  r1.xyz = v5.www * r0.yzw;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = float2(-0.0625,-0.1875) + v3.zz;
  r1.z = 0.5 / _VolumeSize.z;
  r1.zw = float2(0.5,0.75) + r1.zz;
  r2.xy = float2(0.75,1) + -r1.zw;
  r1.xy = r2.xy * r1.xy;
  r1.xy = r1.xy * float2(8,1.23076928) + r1.zw;
  r1.zw = cmp(v3.zz < float2(0.0625,0.1875));
  r1.x = r1.w ? r1.x : r1.y;
  r1.y = 8 * v3.z;
  r1.z = r1.z ? r1.y : r1.x;
  r1.xy = v3.xy / v3.ww;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps de50b103c29b82ec: 2 retail keyword combination(s)
void ps_de50b103c29b82ec_impl(
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
  float4 r0,r1,r2,r3;
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
  r0.x = _Time.x * _Speed + v2.x;
  r0.y = v2.y;
  r0.xy = r0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r0.xyzw = _MainTex.Sample(sampler_MainTex, r0.xy).xyzw;
  r0.xyzw = _ColorBB.xyzw * r0.xyzw;
  r1.xyz = v1.xyz * r0.xyz;
  r0.xyz = v5.www * r1.xyz;
  r1.x = _Time.x * _StrobeFrequency;
  r1.x = sin(r1.x);
  r1.x = r1.x * 0.5 + 0.5;
  r1.y = 1 + -_StrobeCap;
  r1.x = -_StrobeCap + r1.x;
  r1.y = 1 / r1.y;
  r1.x = saturate(r1.x * r1.y);
  r1.y = r1.x * -2 + 3;
  r1.x = r1.x * r1.x;
  r1.x = r1.y * r1.x;
  r0.xyzw = r1.xxxx * r0.xyzw;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


// ps 6e29ad2e8e4762c4: 2 retail keyword combination(s)
void ps_6e29ad2e8e4762c4_impl(
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v6.xy / v6.ww;
  r1.xyzw = _DepthDownsampleVFX.Sample(sampler_DepthDownsampleVFX, r0.xy).xyzw;
  r0.z = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r0.z = 1 / r0.z;
  r0.w = w2.x / w2.y;
  r0.w = _ZBufferParams.x * r0.w + _ZBufferParams.y;
  r0.w = 1 / r0.w;
  r0.z = cmp(r0.z < r0.w);
  clip(r0.z != 0 ? -1 : 1);
  r1.x = _Time.x * _Speed + v2.x;
  r1.y = v2.y;
  r0.zw = r1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.Sample(sampler_MainTex, r0.zw).xyzw;
  r1.xyzw = _ColorBB.xyzw * r1.xyzw;
  r2.xyz = v1.xyz * r1.xyz;
  r0.xyzw = _CameraDepthTexture2.Sample(sampler_CameraDepthTexture2, r0.xy).xyzw;
  r0.x = _ZBufferParams.z * r0.x + _ZBufferParams.w;
  r0.x = 1 / r0.x;
  r0.x = saturate(-v6.z + r0.x);
  r0.xyz = r2.xyz * r0.xxx;
  r1.xyz = v5.www * r0.xyz;
  r0.x = _Time.x * _StrobeFrequency;
  r0.x = sin(r0.x);
  r0.x = r0.x * 0.5 + 0.5;
  r0.y = 1 + -_StrobeCap;
  r0.x = -_StrobeCap + r0.x;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xy = v3.xy / v3.ww;
  r1.w = 8 * v3.z;
  r2.xy = cmp(v3.zz < float2(0.0625,0.1875));
  r2.z = 0.5 / _VolumeSize.z;
  r2.zw = float2(0.5,0.75) + r2.zz;
  r3.xy = float2(-0.0625,-0.1875) + v3.zz;
  r3.zw = float2(0.75,1) + -r2.zw;
  r3.xy = r3.xy * r3.zw;
  r2.zw = r3.xy * float2(8,1.23076928) + r2.zw;
  r2.y = r2.y ? r2.z : r2.w;
  r1.z = r2.x ? r1.w : r2.y;
  r1.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r1.xyz).xyzw;
  o0.xyz = r1.www * r0.xyz;
  o0.w = r0.w;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
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
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_d2ccdaa55b8569ed_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
	}
#elif !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE)
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
#elif !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		vs_7c3e53c4878b7c95_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_d24686246f5e07a2_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
	}
#elif !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_21f5bf5cc6597359_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_e34bab1bcb698b47_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_18d2c11eabd1c70f_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord5.xyz = o5;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_dd0409fd7d3d8e1a_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_d2c5b1c57bc5ea51_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_6f3d0ac3312ade3e_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_a04a30b88be774fb_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord5.xyz = o5;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_39b44f42dd89f7ff_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_9ebee05258183dae_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		vs_3de79d9ead78b4d1_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_1dfc327c68d6ac62_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_92053edd914bcbb8_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_8544e7e62ab56c42_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord5.xyz = o5;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_5597586e97eb6085_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_278dc83af5a88578_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float3 o5 = 0;
		vs_9767084be007470c_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord5.xyz = o5;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_e880c71d27244e1d_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_54dbb8243dc3084a_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5.xyz = o6;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
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
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		vs_905ce018ebf6287a_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE)
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
#elif !defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		vs_f5102f5dc0008775_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		vs_80185ccb783a24d8_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
	}
#elif !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float2 o2 = 0;
		float2 p2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		vs_7fc5202a0f8acc6a_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0.xy = o2;
		o.texcoord6.xy = p2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float3 o7 = 0;
		vs_26b87f341fbd4bef_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
		o.texcoord5.xyz = o7;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_602e6ac83cdf68e9_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float3 o7 = 0;
		vs_176eaa0f735ffe41_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
		o.texcoord5.xyz = o7;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && !defined(_VISFOW)
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
		vs_6ac8e01c0d3bf7d9_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6, o7);
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float3 o7 = 0;
		vs_f94bab6362288308_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
		o.texcoord5.xyz = o7;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
#elif !defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float3 o6 = 0;
		vs_2a01d8d4d00ffd4e_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord5.xyz = o6;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float3 o7 = 0;
		vs_23f40c066c8e7257_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.color0 = o1;
		o.texcoord0 = o2;
		o.texcoord1 = o3;
		o.texcoord2 = o4;
		o.texcoord3 = o5;
		o.texcoord4 = o6;
		o.texcoord5.xyz = o7;
	}
#elif defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VFX_DEPTH_SAMPLE) && defined(_VISFOW)
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
		vs_cc313cb78c03cfa6_impl(v.position0, v.color0, v.texcoord0.xy, v.normal0.xyz, o0, o1, o2, p2, o3, o4, o5, o6, o7);
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
#if !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_1d1f86c671e3450c_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_6df7f86e2ae3260d_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b85852e57af45546_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e79ce1f7ea27a415_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_3eac9f50b477c0aa_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_061fe30890b4a48f_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_0a8835aae4018a12_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_bd639b54834f4036_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9be5fc82844ea671_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_35bdb86d1c2562f7_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_dcb605d7331f980a_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_142de69577b468de_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_3c956982db563583_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5cabeb90b77c4fdb_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b55b184ef94f554d_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_58a6990dd4bb2e9b_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e2052e03cd0b5878_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_f93e3380d276150e_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d8ccadcacd4b4199_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_19e9c73a51d50f72_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_645651b9875767fc_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_76dcc88a667b3723_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_393c083637eda7af_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9f9e23d3580f4798_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_baee8334020952db_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_27865b9afe334717_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_4fde9fd19f983d4b_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9bfb0e9deda7c015_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_7b773b6934f3c742_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5a16aeda147f643b_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_59a45a3f61f046e5_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_44c099c1bbd0a585_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_7f3c4809e93e7c72_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_372eab68555a6a27_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_58e4dc5c001ba22c_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8fe439ee8ea5ca50_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b7bf31537f20f995_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e9b1f764f0eb1570_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_dbd8d1e5c5b3e939_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_60a7e752dfd88774_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_52cdf3d6a2c8020e_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_73f60a63cea3569d_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_fb63adc25b100b32_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_ef7b522225c275b1_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8ce9f09ebecdf043_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_1a3c279b24428d85_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_93b32ede42d1d820_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_983048df5131b10f_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5fb4e6dbe4c5ffe0_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_efc8be97e8a38a9c_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d3009b71940450c3_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8da7de7a28f5603e_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_21c68c9cea825b0a_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_1cd454cdbde4d650_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_0ad578ec02322b73_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d9883cf94aeccb71_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e2e08ba8b54cc724_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_1dab3c84812a941e_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e669024c8476282a_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_f75a9e79887e9b2d_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_f8506d465630b908_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_fef98b99fc858902_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_cdf269c902a0a9c4_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_49dccf5182356dfc_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_da634293e88febab_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5bf9799f3affc4f4_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e0fff85b6ea88cfa_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_665528cc4e889b3b_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_735eac5c1ad0b3b0_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5f2091796937aecf_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8667b51449e23562_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_59864acf71cd3d65_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_a83fafa08e830fa2_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5d3ffa7b8ace838e_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d2a0f98276ef210b_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8300f023cf49b277_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b5d98aee92264ae7_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_66328b3819656159_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_f06bc4328bffc012_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e27ce24f52b08719_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_89c520443a6803ac_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_619c49cbe129763a_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_7133d1fbfa492be5_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_31bc5c71c96bf220_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d9209afd4b909f00_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_26dcfee47bcacdd7_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9b3fac59b96dc981_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_aa42c4591427c828_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_82878e6ff42e6568_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_1a4e2c7966c889e9_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_265194d61ce441fe_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_4c4ec6f0400b212b_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_85f67dcd7b174651_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_36d367d9d9b9c5a4_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_f5ddfe14a3045dca_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && !defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_fde6087a3a6021d2_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b556f5c7f44f6be1_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_948fe9515b9b951a_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b4f0399fe42e477c_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_554a33f86e0291ba_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_fdd6695ec0814f91_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9d131c509e9a7377_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e8040d47548b359f_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_6c43433533593467_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_cd33a6d7288a2dac_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_1ddac73080f3c3a8_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_4f568618211c8af6_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d7a76e637a03ef74_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b8b3365ec1797f78_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8be58d14dfcea62f_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_3c2aea2c61039773_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_af28f7692d741f71_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_645eeba6cc52b2bb_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_55d74355d64a591c_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_07d4c2c2e65e9075_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_301a8f8abd9bd97a_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_4508763d0716b187_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_ed1503ad88086707_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_30c94d564ce15b69_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8d62b883babc86ef_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_74f291489e8d0fc3_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9c09979bfc8bbcd0_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_601eb4b920321e84_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_196cedfba200e012_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_83ce8f80f839b426_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_cf80563ff5d23f98_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_a3aa52cc7d186e4f_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && !defined(_BT_FORWARD_FOG) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE) || defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_SIM_GAME) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_157718d4cec9381f_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8cad04215ddd97e0_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_0ce8d1f61279074d_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_fa5656e022683ede_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5494bd7685c53129_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_a5d3c680463d0c1c_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_4b7896791b842e96_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e93d6a7121ca54f3_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_0577ada4edf34fea_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_6944a86a0def716f_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_507820f16cd9da10_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_0660ffe342356e68_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_c249832144c513b7_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_abd485d09a66422a_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_bd547b9b30896936_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_c46e85adada0b9d2_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_3f6923aa561782d9_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_edfad4f48c92562a_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_36050a293d29fc40_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_1c603e65ac861dc0_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_700d71ccb453800a_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_fc304e481166e846_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_ff438da597437e22_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9ffad3b0f656cd10_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_113a1d63b5b94b1a_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_dbed363f85f4f7c1_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_015ef64c602f7f1f_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_c391c58dc47216fc_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_6ee835695e00c5aa_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_7ccd66e0611f6dd2_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_715d674871dab1ef_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_f1164f867b64117f_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && !defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_409587338e5ef15a_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_0ce86319d1970eb3_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9349f91b977b4e96_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_c0fde21ae658b22e_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9240cbf3febe3bbc_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_7103209d963383d0_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_2d0e6b13282ab787_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_f50ae5d5d618a2ac_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_49dce72bbfc6310e_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_8f43ef2ebfa06170_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_1028f1b96fefc9d1_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_c188cde2eb7d8165_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d1d29f19c9078c0d_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_7455e088ab3d6cd0_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_1357c08201de21fe_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_580a4687f09d7fc0_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && !defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_10d105b98096e387_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_20d3d115f62db18a_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_b401dd01a02c5552_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_15e9a972472bd61d_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_92430dabce08fad8_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_9a888f12a9148781_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_e8b3580d706c1a10_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_69832abd86fee73d_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && !defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_67c86f7b3a4349d9_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_d40c0443d8e91dab_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_602f1b465541c256_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_c1c3d74527fd5dc0_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && !defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_5e6cb2ab8390e70e_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_2d6d73b051cf9881_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && !defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_059692ca5c7f7822_impl(i.sv_position, i.color0, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_de50b103c29b82ec_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
		r.t0 = o0;
	}
#elif defined(SOFTPARTICLES_ON) && defined(_ANIMATE) && defined(_BT_FOGOFWAR) && defined(_BT_FORWARD_FOG) && !defined(_BT_SIM_GAME) && defined(_FOG_3D) && defined(_STROBE) && defined(_VERTCOLOR) && defined(_VFX_DEPTH_SAMPLE)
	{
		float4 o0 = 0;
		ps_6e29ad2e8e4762c4_impl(i.sv_position, i.color0, i.texcoord0.xy, i.texcoord6.xy, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5.xyz, o0);
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
