Shader "Terrain/BT-Terrain-AddPass"
{
	Properties
	{
		[HideInInspector] _Control ("Control (RGBA)", 2D) = "red" {}
		[HideInInspector] _ControlA ("Control A(RGBA)", 2D) = "red" {}
		[HideInInspector] _ControlB ("Control B(RGBA)", 2D) = "red" {}
		[HideInInspector] _HSV ("HSV", 2D) = "gray" {}
		[HideInInspector] _AlbedoArray ("Albedo Array", 2DArray) = "white" {}
		[HideInInspector] _NormalArray ("Normal Array", 2DArray) = "white" {}
		[HideInInspector] _TilingFactor ("Tiling Factor", Float) = 16
		_MainTex ("Main Tex", 2D) = "white" {}
		_WindColor ("Wind Color", Color) = (0,0,0,0)
		_WindTexture ("Wind Texture", 2D) = "black" {}
	}
	SubShader
	{
		Tags { "Queue"="Transparent-2" }
		Pass
		{
			Name "FORWARD"
			Tags { "LightMode"="ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ DIRLIGHTMAP_OFF
			#pragma multi_compile _ DIRLIGHTMAP_SEPARATE
			#pragma multi_compile _ DYNAMICLIGHTMAP_OFF
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_OFF
			#pragma multi_compile _ UNITY_HDR_ON
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _FOG_3D

#define cmp -

Texture2D _WindTexture;
SamplerState sampler_WindTexture;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _TransmittanceLUT;
SamplerState sampler_TransmittanceLUT;
Texture2D _FilteredShadowmap;
SamplerState sampler_FilteredShadowmap;

float4 _BT_GlobalWind;
float _BT_SunlightIntensity;
float4 _BT_SunlightColor;
float _C;
float4 _WindColor;
float4 _BT_GlobalWind_Properties;
float4 _BT_SunlightDirection;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};

#if !defined(DYNAMICLIGHTMAP_ON) && !defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord6 : TEXCOORD6;
};
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
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

// vs 881a7cc2b1ad079d: 6 retail keyword combination(s)
void vs_881a7cc2b1ad079d_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.xyz + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  r0.w = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.w = rsqrt(r0.w);
  r3.xy = _BT_GlobalWind.xz * r0.ww;
  r3.zw = abs(r3.xy);
  r0.w = max(r3.z, r3.w);
  r0.w = 1 / r0.w;
  r4.x = min(r3.z, r3.w);
  r3.z = cmp(r3.w < r3.z);
  r0.w = r4.x * r0.w;
  r3.w = r0.w * r0.w;
  r4.x = r3.w * 0.0208350997 + -0.0851330012;
  r4.x = r3.w * r4.x + 0.180141002;
  r4.x = r3.w * r4.x + -0.330299497;
  r3.w = r3.w * r4.x + 0.999866009;
  r4.x = r3.w * r0.w;
  r4.x = r4.x * -2 + 1.57079637;
  r3.z = r3.z ? r4.x : 0;
  r0.w = r0.w * r3.w + r3.z;
  r3.z = cmp(-r3.y < r3.y);
  r3.z = r3.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r3.z + r0.w;
  r3.z = min(r3.x, -r3.y);
  r3.x = max(r3.x, -r3.y);
  r3.x = cmp(r3.x >= -r3.x);
  r3.y = cmp(r3.z < -r3.z);
  r3.x = r3.x ? r3.y : 0;
  r0.w = r3.x ? -r0.w : r0.w;
  sincos(-r0.w, r3.x, r4.x);
  r3.xy = v2.yx * r3.xx;
  r5.x = v2.x * r4.x + -r3.x;
  r5.y = v2.y * r4.x + r3.y;
  o1.xy = r5.xy + r5.xy;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r3.xyz * r0.www;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  o3.w = -r0.w;
  o3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o5.xyz = r0.xyz;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o4.zw = r2.zw;
  o4.xy = r0.xw + r0.zz;
  o5.w = 1;
  o6.xyzw = float4(0,0,0,0);
  return;
}


// vs a35f2c7487043639: 6 retail keyword combination(s)
void vs_a35f2c7487043639_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.xyz + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  r0.w = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.w = rsqrt(r0.w);
  r3.xy = _BT_GlobalWind.xz * r0.ww;
  r3.zw = abs(r3.xy);
  r0.w = max(r3.z, r3.w);
  r0.w = 1 / r0.w;
  r4.x = min(r3.z, r3.w);
  r3.z = cmp(r3.w < r3.z);
  r0.w = r4.x * r0.w;
  r3.w = r0.w * r0.w;
  r4.x = r3.w * 0.0208350997 + -0.0851330012;
  r4.x = r3.w * r4.x + 0.180141002;
  r4.x = r3.w * r4.x + -0.330299497;
  r3.w = r3.w * r4.x + 0.999866009;
  r4.x = r3.w * r0.w;
  r4.x = r4.x * -2 + 1.57079637;
  r3.z = r3.z ? r4.x : 0;
  r0.w = r0.w * r3.w + r3.z;
  r3.z = cmp(-r3.y < r3.y);
  r3.z = r3.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r3.z + r0.w;
  r3.z = min(r3.x, -r3.y);
  r3.x = max(r3.x, -r3.y);
  r3.x = cmp(r3.x >= -r3.x);
  r3.y = cmp(r3.z < -r3.z);
  r3.x = r3.x ? r3.y : 0;
  r0.w = r3.x ? -r0.w : r0.w;
  sincos(-r0.w, r3.x, r4.x);
  r3.xy = v2.yx * r3.xx;
  r5.x = v2.x * r4.x + -r3.x;
  r5.y = v2.y * r4.x + r3.y;
  o1.xy = r5.xy + r5.xy;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r3.xyz * r0.www;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  o3.w = -r0.w;
  r0.w = _ProjectionParams.w * r0.w;
  o7.z = -r0.w;
  o3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o5.xyz = r0.xyz;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r0.xw + r0.zz;
  o4.xyzw = r2.xyzw;
  o7.xyw = r2.xyw;
  o5.w = 1;
  o6.xyzw = float4(0,0,0,0);
  return;
}


// vs 8c4ef276488b8d2a: 2 retail keyword combination(s)
void vs_8c4ef276488b8d2a_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float2 v4 : TEXCOORD2,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.xyz + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  r0.w = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.w = rsqrt(r0.w);
  r3.xy = _BT_GlobalWind.xz * r0.ww;
  r3.zw = abs(r3.xy);
  r0.w = max(r3.z, r3.w);
  r0.w = 1 / r0.w;
  r4.x = min(r3.z, r3.w);
  r3.z = cmp(r3.w < r3.z);
  r0.w = r4.x * r0.w;
  r3.w = r0.w * r0.w;
  r4.x = r3.w * 0.0208350997 + -0.0851330012;
  r4.x = r3.w * r4.x + 0.180141002;
  r4.x = r3.w * r4.x + -0.330299497;
  r3.w = r3.w * r4.x + 0.999866009;
  r4.x = r3.w * r0.w;
  r4.x = r4.x * -2 + 1.57079637;
  r3.z = r3.z ? r4.x : 0;
  r0.w = r0.w * r3.w + r3.z;
  r3.z = cmp(-r3.y < r3.y);
  r3.z = r3.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r3.z + r0.w;
  r3.z = min(r3.x, -r3.y);
  r3.x = max(r3.x, -r3.y);
  r3.x = cmp(r3.x >= -r3.x);
  r3.y = cmp(r3.z < -r3.z);
  r3.x = r3.x ? r3.y : 0;
  r0.w = r3.x ? -r0.w : r0.w;
  sincos(-r0.w, r3.x, r4.x);
  r3.xy = v2.yx * r3.xx;
  r5.x = v2.x * r4.x + -r3.x;
  r5.y = v2.y * r4.x + r3.y;
  o1.xy = r5.xy + r5.xy;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r3.xyz * r0.www;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  o3.w = -r0.w;
  o3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o5.xyz = r0.xyz;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o4.zw = r2.zw;
  o4.xy = r0.xw + r0.zz;
  o5.w = 1;
  o6.zw = v4.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o6.xy = float2(0,0);
  return;
}


// vs a2b04f4126f0ec72: 2 retail keyword combination(s)
void vs_a2b04f4126f0ec72_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float2 v4 : TEXCOORD2,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.xyz + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  r0.w = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.w = rsqrt(r0.w);
  r3.xy = _BT_GlobalWind.xz * r0.ww;
  r3.zw = abs(r3.xy);
  r0.w = max(r3.z, r3.w);
  r0.w = 1 / r0.w;
  r4.x = min(r3.z, r3.w);
  r3.z = cmp(r3.w < r3.z);
  r0.w = r4.x * r0.w;
  r3.w = r0.w * r0.w;
  r4.x = r3.w * 0.0208350997 + -0.0851330012;
  r4.x = r3.w * r4.x + 0.180141002;
  r4.x = r3.w * r4.x + -0.330299497;
  r3.w = r3.w * r4.x + 0.999866009;
  r4.x = r3.w * r0.w;
  r4.x = r4.x * -2 + 1.57079637;
  r3.z = r3.z ? r4.x : 0;
  r0.w = r0.w * r3.w + r3.z;
  r3.z = cmp(-r3.y < r3.y);
  r3.z = r3.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r3.z + r0.w;
  r3.z = min(r3.x, -r3.y);
  r3.x = max(r3.x, -r3.y);
  r3.x = cmp(r3.x >= -r3.x);
  r3.y = cmp(r3.z < -r3.z);
  r3.x = r3.x ? r3.y : 0;
  r0.w = r3.x ? -r0.w : r0.w;
  sincos(-r0.w, r3.x, r4.x);
  r3.xy = v2.yx * r3.xx;
  r5.x = v2.x * r4.x + -r3.x;
  r5.y = v2.y * r4.x + r3.y;
  o1.xy = r5.xy + r5.xy;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r3.xyz * r0.www;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  o3.w = -r0.w;
  r0.w = _ProjectionParams.w * r0.w;
  o7.z = -r0.w;
  o3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o5.xyz = r0.xyz;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r0.xw + r0.zz;
  o4.xyzw = r2.xyzw;
  o7.xyw = r2.xyw;
  o5.w = 1;
  o6.zw = v4.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o6.xy = float2(0,0);
  return;
}


// ps c61bcaeee81872a6: 8 retail keyword combination(s)
void ps_c61bcaeee81872a6_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * v5.yyy;
  r0.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * v5.xxx + r0.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * v5.zzz + r0.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * v5.www + r0.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * v5.www + r1.xyz;
  r2.xyz = -unity_ShadowSplitSpheres[0].xyz + v5.xyz;
  r2.x = dot(r2.xyz, r2.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[1].xyz + v5.xyz;
  r2.y = dot(r3.xyz, r3.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[2].xyz + v5.xyz;
  r2.z = dot(r3.xyz, r3.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[3].xyz + v5.xyz;
  r2.w = dot(r3.xyz, r3.xyz);
  r2.xyzw = cmp(r2.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r3.xyz = r2.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r2.yzw = r2.yzw + r3.xyz;
  r2.yzw = max(float3(0,0,0), r2.yzw);
  r1.xyz = r2.yyy * r1.xyz;
  r0.xyz = r0.xyz * r2.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * v5.www + r1.xyz;
  r0.xyz = r1.xyz * r2.zzz + r0.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * v5.www + r1.xyz;
  r0.xyz = r1.xyz * r2.www + r0.xyz;
  r0.z = _C * r0.z;
  r0.x = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r0.xy, 0).x;
  r0.y = 1.44269502 * r0.z;
  r0.y = exp2(r0.y);
  r0.x = saturate(r0.y / r0.x);
  r0.y = 0.100000001 + -_BT_SunlightDirection.y;
  r0.y = saturate(5 * r0.y);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r1.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r1.xy).xyzw;
  r1.xyz = r1.xyz * r1.www;
  r0.yzw = r1.xyz * r0.yyy;
  r1.x = dot(v2.xyz, v2.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v2.yxz * r1.xxx;
  r1.y = saturate(dot(-r1.yxz, _BT_SunlightDirection.xyz));
  r1.x = saturate(r1.x);
  r1.x = r1.x * r1.x;
  r0.yzw = r1.yyy * r0.yzw;
  r0.yzw = _BT_SunlightColor.xyz * r0.yzw;
  r0.yzw = _BT_SunlightIntensity.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = _WindColor.xyz * r0.xyz;
  r0.xy = float2(20,20) * v1.xy;
  r0.x = _WindTexture.Sample(sampler_WindTexture, r0.xy).w;
  r2.xz = float2(0,0);
  r2.yw = float2(2,16) * _Time.xx;
  r0.yz = v1.xy * float2(10,1) + r2.xy;
  r0.y = _WindTexture.Sample(sampler_WindTexture, r0.yz).w;
  r0.x = r0.x * 0.5 + r0.y;
  r0.yz = v1.xy * float2(60,30) + r2.zw;
  r1.yz = v1.xy + r2.xy;
  r0.w = _WindTexture.Sample(sampler_WindTexture, r1.yz).w;
  r0.w = r0.w * 0.5 + 0.5;
  r0.y = _WindTexture.Sample(sampler_WindTexture, r0.yz).w;
  r0.x = r0.y * 0.25 + r0.x;
  r0.x = _WindColor.w * r0.x;
  r0.x = r0.x * r0.w;
  r0.yz = v4.xy / v4.ww;
  r0.y = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).x;
  r0.y = _ZBufferParams.z * r0.y + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = -v3.w + r0.y;
  r0.z = r0.y * r0.y;
  r0.y = -10 + r0.y;
  r0.z = min(1, r0.z);
  r0.x = r0.x * r0.z;
  r0.z = -500 + v3.w;
  r0.yz = saturate(float2(-0.200000003,-0.00999999978) * r0.yz);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r0.x = r0.x * r0.z;
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.z = saturate(0.5 * _BT_GlobalWind_Properties.x);
  r0.w = r0.z * -2 + 3;
  r0.yz = r0.xz * r0.xz;
  r0.z = r0.w * r0.z;
  r0.y = r0.y * r0.z;
  r0.x = r0.x * r0.y;
  o0.w = r0.x * r1.x;
  return;
}


// ps 2b83009f8c231abf: 8 retail keyword combination(s)
void ps_2b83009f8c231abf_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * v5.yyy;
  r0.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * v5.xxx + r0.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * v5.zzz + r0.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * v5.www + r0.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * v5.www + r1.xyz;
  r2.xyz = -unity_ShadowSplitSpheres[0].xyz + v5.xyz;
  r2.x = dot(r2.xyz, r2.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[1].xyz + v5.xyz;
  r2.y = dot(r3.xyz, r3.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[2].xyz + v5.xyz;
  r2.z = dot(r3.xyz, r3.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[3].xyz + v5.xyz;
  r2.w = dot(r3.xyz, r3.xyz);
  r2.xyzw = cmp(r2.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r3.xyz = r2.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r2.yzw = r2.yzw + r3.xyz;
  r2.yzw = max(float3(0,0,0), r2.yzw);
  r1.xyz = r2.yyy * r1.xyz;
  r0.xyz = r0.xyz * r2.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * v5.www + r1.xyz;
  r0.xyz = r1.xyz * r2.zzz + r0.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * v5.www + r1.xyz;
  r0.xyz = r1.xyz * r2.www + r0.xyz;
  r0.z = _C * r0.z;
  r0.x = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r0.xy, 0).x;
  r0.y = 1.44269502 * r0.z;
  r0.y = exp2(r0.y);
  r0.x = saturate(r0.y / r0.x);
  r0.y = 0.100000001 + -_BT_SunlightDirection.y;
  r0.y = saturate(5 * r0.y);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r1.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r1.xy).xyzw;
  r1.xyz = r1.xyz * r1.www;
  r0.yzw = r1.xyz * r0.yyy;
  r1.x = dot(v2.xyz, v2.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v2.yxz * r1.xxx;
  r1.y = saturate(dot(-r1.yxz, _BT_SunlightDirection.xyz));
  r1.x = saturate(r1.x);
  r1.x = r1.x * r1.x;
  r0.yzw = r1.yyy * r0.yzw;
  r0.yzw = _BT_SunlightColor.xyz * r0.yzw;
  r0.yzw = _BT_SunlightIntensity.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = _WindColor.xyz * r0.xyz;
  r0.xy = float2(20,20) * v1.xy;
  r0.x = _WindTexture.Sample(sampler_WindTexture, r0.xy).w;
  r2.xz = float2(0,0);
  r2.yw = float2(2,16) * _Time.xx;
  r0.yz = v1.xy * float2(10,1) + r2.xy;
  r0.y = _WindTexture.Sample(sampler_WindTexture, r0.yz).w;
  r0.x = r0.x * 0.5 + r0.y;
  r0.yz = v1.xy * float2(60,30) + r2.zw;
  r1.yz = v1.xy + r2.xy;
  r0.w = _WindTexture.Sample(sampler_WindTexture, r1.yz).w;
  r0.w = r0.w * 0.5 + 0.5;
  r0.y = _WindTexture.Sample(sampler_WindTexture, r0.yz).w;
  r0.x = r0.y * 0.25 + r0.x;
  r0.x = _WindColor.w * r0.x;
  r0.x = r0.x * r0.w;
  r0.yz = v4.xy / v4.ww;
  r0.y = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).x;
  r0.y = _ZBufferParams.z * r0.y + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = -v3.w + r0.y;
  r0.z = r0.y * r0.y;
  r0.y = -10 + r0.y;
  r0.z = min(1, r0.z);
  r0.x = r0.x * r0.z;
  r0.z = -500 + v3.w;
  r0.yz = saturate(float2(-0.200000003,-0.00999999978) * r0.yz);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r0.x = r0.x * r0.z;
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.z = saturate(0.5 * _BT_GlobalWind_Properties.x);
  r0.w = r0.z * -2 + 3;
  r0.yz = r0.xz * r0.xz;
  r0.z = r0.w * r0.z;
  r0.y = r0.y * r0.z;
  r0.x = r0.x * r0.y;
  o0.w = r0.x * r1.x;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		vs_881a7cc2b1ad079d_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float4 o7 = 0;
		vs_a35f2c7487043639_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		vs_8c4ef276488b8d2a_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1, v.texcoord2.xy, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float4 o7 = 0;
		vs_a2b04f4126f0ec72_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1, v.texcoord2.xy, o0, o1, o2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		ps_c61bcaeee81872a6_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		ps_2b83009f8c231abf_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, o0);
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
		Tags { "Queue"="Transparent-2" }
		Pass
		{
			Name "FORWARD"
			Tags { "LightMode"="ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ DIRLIGHTMAP_OFF
			#pragma multi_compile _ DIRLIGHTMAP_SEPARATE
			#pragma multi_compile _ DYNAMICLIGHTMAP_OFF
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_OFF
			#pragma multi_compile _ UNITY_HDR_ON
			#pragma multi_compile _ _BT_FORWARD_FOG
			#pragma multi_compile _ _FOG_3D

#define cmp -

Texture2D _WindTexture;
SamplerState sampler_WindTexture;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _TransmittanceLUT;
SamplerState sampler_TransmittanceLUT;
Texture2D _FilteredShadowmap;
SamplerState sampler_FilteredShadowmap;
Texture2D _FogIntegrationTex;
SamplerState sampler_FogIntegrationTex;
Texture3D _FogIntegration3D;
SamplerState sampler_FogIntegration3D;

float4 _BT_GlobalWind;
float _BT_SunlightIntensity;
float4 _BT_SunlightColor;
float4 _WindColor;
float4 _BT_GlobalWind_Properties;
float4 _BT_SunlightDirection;
float _C;
float4 _ScaleOffset;
float3 _VolumeSize;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};

#if !defined(DYNAMICLIGHTMAP_ON) && !defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
	float4 texcoord6 : TEXCOORD6;
};
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	float4 texcoord4 : TEXCOORD4;
	float4 texcoord5 : TEXCOORD5;
};
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_BT_FORWARD_FOG)
struct v2f
{
	float4 sv_position : SV_POSITION;
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

// vs c661b29a82feb50a: 6 retail keyword combination(s)
void vs_c661b29a82feb50a_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.xyz + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  r0.w = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.w = rsqrt(r0.w);
  r3.xy = _BT_GlobalWind.xz * r0.ww;
  r3.zw = abs(r3.xy);
  r0.w = max(r3.z, r3.w);
  r0.w = 1 / r0.w;
  r4.x = min(r3.z, r3.w);
  r3.z = cmp(r3.w < r3.z);
  r0.w = r4.x * r0.w;
  r3.w = r0.w * r0.w;
  r4.x = r3.w * 0.0208350997 + -0.0851330012;
  r4.x = r3.w * r4.x + 0.180141002;
  r4.x = r3.w * r4.x + -0.330299497;
  r3.w = r3.w * r4.x + 0.999866009;
  r4.x = r3.w * r0.w;
  r4.x = r4.x * -2 + 1.57079637;
  r3.z = r3.z ? r4.x : 0;
  r0.w = r0.w * r3.w + r3.z;
  r3.z = cmp(-r3.y < r3.y);
  r3.z = r3.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r3.z + r0.w;
  r3.z = min(r3.x, -r3.y);
  r3.x = max(r3.x, -r3.y);
  r3.x = cmp(r3.x >= -r3.x);
  r3.y = cmp(r3.z < -r3.z);
  r3.x = r3.x ? r3.y : 0;
  r0.w = r3.x ? -r0.w : r0.w;
  sincos(-r0.w, r3.x, r4.x);
  r3.xy = v2.yx * r3.xx;
  r5.x = v2.x * r4.x + -r3.x;
  r5.y = v2.y * r4.x + r3.y;
  o1.xy = r5.xy + r5.xy;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r3.xyz * r0.www;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  o3.w = -r0.w;
  o3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o5.xyz = r0.xyz;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o4.zw = r2.zw;
  o4.xy = r0.xw + r0.zz;
  o5.w = 1;
  o6.xyzw = float4(0,0,0,0);
  return;
}


// vs 7bd8f005aef06d64: 6 retail keyword combination(s)
void vs_7bd8f005aef06d64_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float2 v3 : TEXCOORD1,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.xyz + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  r0.w = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.w = rsqrt(r0.w);
  r3.xy = _BT_GlobalWind.xz * r0.ww;
  r3.zw = abs(r3.xy);
  r0.w = max(r3.z, r3.w);
  r0.w = 1 / r0.w;
  r4.x = min(r3.z, r3.w);
  r3.z = cmp(r3.w < r3.z);
  r0.w = r4.x * r0.w;
  r3.w = r0.w * r0.w;
  r4.x = r3.w * 0.0208350997 + -0.0851330012;
  r4.x = r3.w * r4.x + 0.180141002;
  r4.x = r3.w * r4.x + -0.330299497;
  r3.w = r3.w * r4.x + 0.999866009;
  r4.x = r3.w * r0.w;
  r4.x = r4.x * -2 + 1.57079637;
  r3.z = r3.z ? r4.x : 0;
  r0.w = r0.w * r3.w + r3.z;
  r3.z = cmp(-r3.y < r3.y);
  r3.z = r3.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r3.z + r0.w;
  r3.z = min(r3.x, -r3.y);
  r3.x = max(r3.x, -r3.y);
  r3.x = cmp(r3.x >= -r3.x);
  r3.y = cmp(r3.z < -r3.z);
  r3.x = r3.x ? r3.y : 0;
  r0.w = r3.x ? -r0.w : r0.w;
  sincos(-r0.w, r3.x, r4.x);
  r3.xy = v2.yx * r3.xx;
  r5.x = v2.x * r4.x + -r3.x;
  r5.y = v2.y * r4.x + r3.y;
  o1.xy = r5.xy + r5.xy;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r3.xyz * r0.www;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  o3.w = -r0.w;
  o3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o5.xyz = r0.xyz;
  r0.x = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.x;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r1.xw + r1.zz;
  o4.xyzw = r2.xyzw;
  o7.xyw = r2.xyw;
  o5.w = 1;
  o6.xyzw = float4(0,0,0,0);
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * -r0.wwww;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * -r0.wwww + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * -r0.wwww + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  return;
}


// vs d628b89b18a8dcaf: 2 retail keyword combination(s)
void vs_d628b89b18a8dcaf_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float2 v4 : TEXCOORD2,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.xyz + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  r0.w = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.w = rsqrt(r0.w);
  r3.xy = _BT_GlobalWind.xz * r0.ww;
  r3.zw = abs(r3.xy);
  r0.w = max(r3.z, r3.w);
  r0.w = 1 / r0.w;
  r4.x = min(r3.z, r3.w);
  r3.z = cmp(r3.w < r3.z);
  r0.w = r4.x * r0.w;
  r3.w = r0.w * r0.w;
  r4.x = r3.w * 0.0208350997 + -0.0851330012;
  r4.x = r3.w * r4.x + 0.180141002;
  r4.x = r3.w * r4.x + -0.330299497;
  r3.w = r3.w * r4.x + 0.999866009;
  r4.x = r3.w * r0.w;
  r4.x = r4.x * -2 + 1.57079637;
  r3.z = r3.z ? r4.x : 0;
  r0.w = r0.w * r3.w + r3.z;
  r3.z = cmp(-r3.y < r3.y);
  r3.z = r3.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r3.z + r0.w;
  r3.z = min(r3.x, -r3.y);
  r3.x = max(r3.x, -r3.y);
  r3.x = cmp(r3.x >= -r3.x);
  r3.y = cmp(r3.z < -r3.z);
  r3.x = r3.x ? r3.y : 0;
  r0.w = r3.x ? -r0.w : r0.w;
  sincos(-r0.w, r3.x, r4.x);
  r3.xy = v2.yx * r3.xx;
  r5.x = v2.x * r4.x + -r3.x;
  r5.y = v2.y * r4.x + r3.y;
  o1.xy = r5.xy + r5.xy;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r3.xyz * r0.www;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  o3.w = -r0.w;
  o3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o5.xyz = r0.xyz;
  r0.x = _ProjectionParams.x * r2.y;
  r0.w = 0.5 * r0.x;
  r0.xz = float2(0.5,0.5) * r2.xw;
  o4.zw = r2.zw;
  o4.xy = r0.xw + r0.zz;
  o5.w = 1;
  o6.zw = v4.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o6.xy = float2(0,0);
  return;
}


// vs 2a683c82ac730ed7: 2 retail keyword combination(s)
void vs_2a683c82ac730ed7_impl(
  float4 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float2 v4 : TEXCOORD2,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v1.xyz + v0.xyz;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r1.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.xyz = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]) * v0.www + r0.xyz;
  r2.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r1.yyyy;
  r2.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r1.xxxx + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r1.zzzz + r2.xyzw;
  r2.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r1.wwww + r2.xyzw;
  o0.xyzw = r2.xyzw;
  r0.w = dot(_BT_GlobalWind.xz, _BT_GlobalWind.xz);
  r0.w = rsqrt(r0.w);
  r3.xy = _BT_GlobalWind.xz * r0.ww;
  r3.zw = abs(r3.xy);
  r0.w = max(r3.z, r3.w);
  r0.w = 1 / r0.w;
  r4.x = min(r3.z, r3.w);
  r3.z = cmp(r3.w < r3.z);
  r0.w = r4.x * r0.w;
  r3.w = r0.w * r0.w;
  r4.x = r3.w * 0.0208350997 + -0.0851330012;
  r4.x = r3.w * r4.x + 0.180141002;
  r4.x = r3.w * r4.x + -0.330299497;
  r3.w = r3.w * r4.x + 0.999866009;
  r4.x = r3.w * r0.w;
  r4.x = r4.x * -2 + 1.57079637;
  r3.z = r3.z ? r4.x : 0;
  r0.w = r0.w * r3.w + r3.z;
  r3.z = cmp(-r3.y < r3.y);
  r3.z = r3.z ? asfloat(0xc0490fdb) : 0;
  r0.w = r3.z + r0.w;
  r3.z = min(r3.x, -r3.y);
  r3.x = max(r3.x, -r3.y);
  r3.x = cmp(r3.x >= -r3.x);
  r3.y = cmp(r3.z < -r3.z);
  r3.x = r3.x ? r3.y : 0;
  r0.w = r3.x ? -r0.w : r0.w;
  sincos(-r0.w, r3.x, r4.x);
  r3.xy = v2.yx * r3.xx;
  r5.x = v2.x * r4.x + -r3.x;
  r5.y = v2.y * r4.x + r3.y;
  o1.xy = r5.xy + r5.xy;
  r3.x = dot(v1.xyz, float3(unity_WorldToObject[0][0], unity_WorldToObject[1][0], unity_WorldToObject[2][0]));
  r3.y = dot(v1.xyz, float3(unity_WorldToObject[0][1], unity_WorldToObject[1][1], unity_WorldToObject[2][1]));
  r3.z = dot(v1.xyz, float3(unity_WorldToObject[0][2], unity_WorldToObject[1][2], unity_WorldToObject[2][2]));
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r3.xyz * r0.www;
  r0.w = unity_MatrixV[2][1] * r1.y;
  r0.w = unity_MatrixV[2][0] * r1.x + r0.w;
  r0.w = unity_MatrixV[2][2] * r1.z + r0.w;
  r0.w = unity_MatrixV[2][3] * r1.w + r0.w;
  o3.w = -r0.w;
  o3.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o5.xyz = r0.xyz;
  r0.x = _ProjectionParams.x * r2.y;
  r1.w = 0.5 * r0.x;
  r1.xz = float2(0.5,0.5) * r2.xw;
  r2.xy = r1.xw + r1.zz;
  o4.xyzw = r2.xyzw;
  o7.xyw = r2.xyw;
  o5.w = 1;
  o6.zw = v4.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o6.xy = float2(0,0);
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * -r0.wwww;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * -r0.wwww + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * -r0.wwww + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r0.y = unity_MatrixV[2][1] * r0.y;
  r0.x = unity_MatrixV[2][0] * r0.x + r0.y;
  r0.x = unity_MatrixV[2][2] * r0.z + r0.x;
  r0.x = unity_MatrixV[2][3] * r0.w + r0.x;
  r0.x = _ProjectionParams.w * r0.x;
  o7.z = -r0.x;
  return;
}


// ps 320cd3b7b1b441d9: 8 retail keyword combination(s)
void ps_320cd3b7b1b441d9_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * v5.yyy;
  r0.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * v5.xxx + r0.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * v5.zzz + r0.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * v5.www + r0.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * v5.www + r1.xyz;
  r2.xyz = -unity_ShadowSplitSpheres[0].xyz + v5.xyz;
  r2.x = dot(r2.xyz, r2.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[1].xyz + v5.xyz;
  r2.y = dot(r3.xyz, r3.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[2].xyz + v5.xyz;
  r2.z = dot(r3.xyz, r3.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[3].xyz + v5.xyz;
  r2.w = dot(r3.xyz, r3.xyz);
  r2.xyzw = cmp(r2.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r3.xyz = r2.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r2.yzw = r2.yzw + r3.xyz;
  r2.yzw = max(float3(0,0,0), r2.yzw);
  r1.xyz = r2.yyy * r1.xyz;
  r0.xyz = r0.xyz * r2.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * v5.www + r1.xyz;
  r0.xyz = r1.xyz * r2.zzz + r0.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * v5.www + r1.xyz;
  r0.xyz = r1.xyz * r2.www + r0.xyz;
  r0.z = _C * r0.z;
  r1.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r0.xy, 0).xyzw;
  r0.x = 1.44269502 * r0.z;
  r0.x = exp2(r0.x);
  r0.x = saturate(r0.x / r1.x);
  r0.y = 0.100000001 + -_BT_SunlightDirection.y;
  r0.y = saturate(5 * r0.y);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r1.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r1.xy).xyzw;
  r1.xyz = r1.xyz * r1.www;
  r0.yzw = r1.xyz * r0.yyy;
  r1.x = dot(v2.xyz, v2.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v2.yxz * r1.xxx;
  r1.y = saturate(dot(-r1.yxz, _BT_SunlightDirection.xyz));
  r1.x = saturate(r1.x);
  r1.x = r1.x * r1.x;
  r0.yzw = r1.yyy * r0.yzw;
  r0.yzw = _BT_SunlightColor.xyz * r0.yzw;
  r0.yzw = _BT_SunlightIntensity.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  o0.xyz = _WindColor.xyz * r0.xyz;
  r0.xy = float2(20,20) * v1.xy;
  r0.xyzw = _WindTexture.Sample(sampler_WindTexture, r0.xy).xyzw;
  r2.xz = float2(0,0);
  r2.yw = float2(2,16) * _Time.xx;
  r0.xy = v1.xy * float2(10,1) + r2.xy;
  r3.xyzw = _WindTexture.Sample(sampler_WindTexture, r0.xy).xyzw;
  r0.x = r0.w * 0.5 + r3.w;
  r0.yz = v1.xy * float2(60,30) + r2.zw;
  r1.yz = v1.xy + r2.xy;
  r2.xyzw = _WindTexture.Sample(sampler_WindTexture, r1.yz).xyzw;
  r0.w = r2.w * 0.5 + 0.5;
  r2.xyzw = _WindTexture.Sample(sampler_WindTexture, r0.yz).xyzw;
  r0.x = r2.w * 0.25 + r0.x;
  r0.x = _WindColor.w * r0.x;
  r0.yz = v4.xy / v4.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r2.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = -v3.w + r0.y;
  r0.xz = r0.xy * r0.wy;
  r0.y = -10 + r0.y;
  r0.z = min(1, r0.z);
  r0.x = r0.x * r0.z;
  r0.z = -500 + v3.w;
  r0.yz = saturate(float2(-0.200000003,-0.00999999978) * r0.yz);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r0.x = r0.x * r0.z;
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.z = saturate(0.5 * _BT_GlobalWind_Properties.x);
  r0.w = r0.z * -2 + 3;
  r0.yz = r0.xz * r0.xz;
  r0.z = r0.w * r0.z;
  r0.y = r0.y * r0.z;
  r0.x = r0.x * r0.y;
  o0.w = r0.x * r1.x;
  return;
}


// ps 7885d879ce3f05d1: 4 retail keyword combination(s)
void ps_7885d879ce3f05d1_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v7.xy / v7.ww;
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r0.xy = r0.xy * float2(0.850000024,0.850000024) + float2(0.5,0.5);
  r0.z = _ScaleOffset.w * _ScaleOffset.w + -1;
  r0.w = v7.z * r0.z;
  r0.w = floor(r0.w);
  r1.x = 1 + r0.w;
  r1.x = min(r1.x, r0.z);
  r0.z = v7.z * r0.z + -r0.w;
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
  r1.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * v5.www + r1.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * v5.yyy;
  r2.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * v5.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * v5.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * v5.www + r2.xyz;
  r3.xyz = -unity_ShadowSplitSpheres[0].xyz + v5.xyz;
  r3.x = dot(r3.xyz, r3.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[1].xyz + v5.xyz;
  r3.y = dot(r4.xyz, r4.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[2].xyz + v5.xyz;
  r3.z = dot(r4.xyz, r4.xyz);
  r4.xyz = -unity_ShadowSplitSpheres[3].xyz + v5.xyz;
  r3.w = dot(r4.xyz, r4.xyz);
  r3.xyzw = cmp(r3.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r4.xyz = r3.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r3.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
  r3.yzw = r3.yzw + r4.xyz;
  r3.yzw = max(float3(0,0,0), r3.yzw);
  r2.xyz = r3.yyy * r2.xyz;
  r1.xyz = r1.xyz * r3.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * v5.yyy;
  r2.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * v5.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * v5.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * v5.www + r2.xyz;
  r1.xyz = r2.xyz * r3.zzz + r1.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * v5.yyy;
  r2.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * v5.xxx + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * v5.zzz + r2.xyz;
  r2.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * v5.www + r2.xyz;
  r1.xyz = r2.xyz * r3.www + r1.xyz;
  r1.z = _C * r1.z;
  r2.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r1.xy, 0).xyzw;
  r1.x = 1.44269502 * r1.z;
  r1.x = exp2(r1.x);
  r1.x = saturate(r1.x / r2.x);
  r1.y = 0.100000001 + -_BT_SunlightDirection.y;
  r1.y = saturate(5 * r1.y);
  r1.z = r1.y * -2 + 3;
  r1.y = r1.y * r1.y;
  r1.y = r1.z * r1.y;
  r2.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r2.y = 0.5;
  r2.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r2.xy).xyzw;
  r2.xyz = r2.xyz * r2.www;
  r1.yzw = r2.xyz * r1.yyy;
  r2.x = dot(v2.xyz, v2.xyz);
  r2.x = rsqrt(r2.x);
  r2.xyz = v2.yxz * r2.xxx;
  r2.y = saturate(dot(-r2.yxz, _BT_SunlightDirection.xyz));
  r2.x = saturate(r2.x);
  r2.x = r2.x * r2.x;
  r1.yzw = r2.yyy * r1.yzw;
  r1.yzw = _BT_SunlightColor.xyz * r1.yzw;
  r1.yzw = _BT_SunlightIntensity.xxx * r1.yzw;
  r1.xyz = r1.yzw * r1.xxx;
  r1.xyz = _WindColor.xyz * r1.xyz;
  o0.xyz = r1.xyz * r0.www + r0.xyz;
  r0.xy = float2(20,20) * v1.xy;
  r0.xyzw = _WindTexture.Sample(sampler_WindTexture, r0.xy).xyzw;
  r1.xz = float2(0,0);
  r1.yw = float2(2,16) * _Time.xx;
  r0.xy = v1.xy * float2(10,1) + r1.xy;
  r3.xyzw = _WindTexture.Sample(sampler_WindTexture, r0.xy).xyzw;
  r0.x = r0.w * 0.5 + r3.w;
  r0.yz = v1.xy * float2(60,30) + r1.zw;
  r1.xy = v1.xy + r1.xy;
  r1.xyzw = _WindTexture.Sample(sampler_WindTexture, r1.xy).xyzw;
  r0.w = r1.w * 0.5 + 0.5;
  r1.xyzw = _WindTexture.Sample(sampler_WindTexture, r0.yz).xyzw;
  r0.x = r1.w * 0.25 + r0.x;
  r0.x = _WindColor.w * r0.x;
  r0.yz = v4.xy / v4.ww;
  r1.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r1.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = -v3.w + r0.y;
  r0.xz = r0.xy * r0.wy;
  r0.y = -10 + r0.y;
  r0.z = min(1, r0.z);
  r0.x = r0.x * r0.z;
  r0.z = -500 + v3.w;
  r0.yz = saturate(float2(-0.200000003,-0.00999999978) * r0.yz);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r0.x = r0.x * r0.z;
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.z = saturate(0.5 * _BT_GlobalWind_Properties.x);
  r0.w = r0.z * -2 + 3;
  r0.yz = r0.xz * r0.xz;
  r0.z = r0.w * r0.z;
  r0.y = r0.y * r0.z;
  r0.x = r0.x * r0.y;
  o0.w = r0.x * r2.x;
  return;
}


// ps 673e815fb314cd0c: 4 retail keyword combination(s)
void ps_673e815fb314cd0c_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1]) * v5.yyy;
  r0.xyz = float3(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0]) * v5.xxx + r0.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2]) * v5.zzz + r0.xyz;
  r0.xyz = float3(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3]) * v5.www + r0.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3]) * v5.www + r1.xyz;
  r2.xyz = -unity_ShadowSplitSpheres[0].xyz + v5.xyz;
  r2.x = dot(r2.xyz, r2.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[1].xyz + v5.xyz;
  r2.y = dot(r3.xyz, r3.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[2].xyz + v5.xyz;
  r2.z = dot(r3.xyz, r3.xyz);
  r3.xyz = -unity_ShadowSplitSpheres[3].xyz + v5.xyz;
  r2.w = dot(r3.xyz, r3.xyz);
  r2.xyzw = cmp(r2.xyzw < unity_ShadowSplitSqRadii.xyzw);
  r3.xyz = r2.xyz ? float3(-1,-1,-1) : float3(-0,-0,-0);
  r2.xyzw = r2.xyzw ? float4(1,1,1,1) : 0;
  r2.yzw = r2.yzw + r3.xyz;
  r2.yzw = max(float3(0,0,0), r2.yzw);
  r1.xyz = r2.yyy * r1.xyz;
  r0.xyz = r0.xyz * r2.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3]) * v5.www + r1.xyz;
  r0.xyz = r1.xyz * r2.zzz + r0.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1]) * v5.yyy;
  r1.xyz = float3(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0]) * v5.xxx + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2]) * v5.zzz + r1.xyz;
  r1.xyz = float3(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3]) * v5.www + r1.xyz;
  r0.xyz = r1.xyz * r2.www + r0.xyz;
  r0.z = _C * r0.z;
  r1.xyzw = _FilteredShadowmap.SampleLevel(sampler_FilteredShadowmap, r0.xy, 0).xyzw;
  r0.x = 1.44269502 * r0.z;
  r0.x = exp2(r0.x);
  r0.x = saturate(r0.x / r1.x);
  r0.y = 0.100000001 + -_BT_SunlightDirection.y;
  r0.y = saturate(5 * r0.y);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r1.x = _BT_SunlightDirection.y * 0.5 + 0.5;
  r1.y = 0.5;
  r1.xyzw = _TransmittanceLUT.Sample(sampler_TransmittanceLUT, r1.xy).xyzw;
  r1.xyz = r1.xyz * r1.www;
  r0.yzw = r1.xyz * r0.yyy;
  r1.x = dot(v2.xyz, v2.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v2.yxz * r1.xxx;
  r1.y = saturate(dot(-r1.yxz, _BT_SunlightDirection.xyz));
  r1.x = saturate(r1.x);
  r1.x = r1.x * r1.x;
  r0.yzw = r1.yyy * r0.yzw;
  r0.yzw = _BT_SunlightColor.xyz * r0.yzw;
  r0.yzw = _BT_SunlightIntensity.xxx * r0.yzw;
  r0.xyz = r0.yzw * r0.xxx;
  r0.xyz = _WindColor.xyz * r0.xyz;
  r1.yz = float2(-0.0625,-0.1875) + v7.zz;
  r0.w = 0.5 / _VolumeSize.z;
  r2.xy = float2(0.5,0.75) + r0.ww;
  r2.zw = float2(0.75,1) + -r2.xy;
  r1.yz = r2.zw * r1.yz;
  r1.yz = r1.yz * float2(8,1.23076928) + r2.xy;
  r2.xy = cmp(v7.zz < float2(0.0625,0.1875));
  r0.w = r2.y ? r1.y : r1.z;
  r1.y = 8 * v7.z;
  r2.z = r2.x ? r1.y : r0.w;
  r2.xy = v7.xy / v7.ww;
  r2.xyzw = _FogIntegration3D.Sample(sampler_FogIntegration3D, r2.xyz).xyzw;
  o0.xyz = r0.xyz * r2.www + r2.xyz;
  r0.xy = float2(20,20) * v1.xy;
  r0.xyzw = _WindTexture.Sample(sampler_WindTexture, r0.xy).xyzw;
  r2.xz = float2(0,0);
  r2.yw = float2(2,16) * _Time.xx;
  r0.xy = v1.xy * float2(10,1) + r2.xy;
  r3.xyzw = _WindTexture.Sample(sampler_WindTexture, r0.xy).xyzw;
  r0.x = r0.w * 0.5 + r3.w;
  r0.yz = v1.xy * float2(60,30) + r2.zw;
  r1.yz = v1.xy + r2.xy;
  r2.xyzw = _WindTexture.Sample(sampler_WindTexture, r1.yz).xyzw;
  r0.w = r2.w * 0.5 + 0.5;
  r2.xyzw = _WindTexture.Sample(sampler_WindTexture, r0.yz).xyzw;
  r0.x = r2.w * 0.25 + r0.x;
  r0.x = _WindColor.w * r0.x;
  r0.yz = v4.xy / v4.ww;
  r2.xyzw = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, r0.yz).xyzw;
  r0.y = _ZBufferParams.z * r2.x + _ZBufferParams.w;
  r0.y = 1 / r0.y;
  r0.y = -v3.w + r0.y;
  r0.xz = r0.xy * r0.wy;
  r0.y = -10 + r0.y;
  r0.z = min(1, r0.z);
  r0.x = r0.x * r0.z;
  r0.z = -500 + v3.w;
  r0.yz = saturate(float2(-0.200000003,-0.00999999978) * r0.yz);
  r0.w = r0.z * -2 + 3;
  r0.z = r0.z * r0.z;
  r0.z = r0.w * r0.z;
  r0.x = r0.x * r0.z;
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.z = saturate(0.5 * _BT_GlobalWind_Properties.x);
  r0.w = r0.z * -2 + 3;
  r0.yz = r0.xz * r0.xz;
  r0.z = r0.w * r0.z;
  r0.y = r0.y * r0.z;
  r0.x = r0.x * r0.y;
  o0.w = r0.x * r1.x;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(DYNAMICLIGHTMAP_ON) && !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		vs_c661b29a82feb50a_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
	}
#elif !defined(DYNAMICLIGHTMAP_ON) && defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float4 o7 = 0;
		vs_7bd8f005aef06d64_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1.xy, o0, o1, o2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		vs_d628b89b18a8dcaf_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1, v.texcoord2.xy, o0, o1, o2, o3, o4, o5, o6);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
	}
#elif defined(DYNAMICLIGHTMAP_ON) && defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float4 o7 = 0;
		vs_2a683c82ac730ed7_impl(v.position0, v.normal0.xyz, v.texcoord0, v.texcoord1, v.texcoord2.xy, o0, o1, o2, o3, o4, o5, o6, o7);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_BT_FORWARD_FOG)
	{
		float4 o0 = 0;
		ps_320cd3b7b1b441d9_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FORWARD_FOG) && !defined(_FOG_3D)
	{
		float4 o0 = 0;
		ps_7885d879ce3f05d1_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, o0);
		r.t0 = o0;
	}
#elif defined(_BT_FORWARD_FOG) && defined(_FOG_3D)
	{
		float4 o0 = 0;
		ps_673e815fb314cd0c_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, o0);
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
