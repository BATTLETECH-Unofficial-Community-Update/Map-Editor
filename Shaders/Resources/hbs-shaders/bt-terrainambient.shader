Shader "Hidden/BT-TerrainAmbient"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma exclude_renderers nomrt
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ DIRLIGHTMAP_OFF
			#pragma multi_compile _ DIRLIGHTMAP_SEPARATE
			#pragma multi_compile _ DYNAMICLIGHTMAP_OFF
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_OFF
			#pragma multi_compile _ UNITY_HDR_ON

#define cmp -


float _TilingFactor;
float4 _BT_SunlightDirection;
float4 BT_SHAr;
float4 BT_SHAg;
float4 BT_SHAb;
float4 BT_SHBr;
float4 BT_SHBg;
float4 BT_SHBb;
float4 BT_SHC;

struct appdata
{
	float4 position0 : POSITION0;
	float4 normal0 : NORMAL0;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};

#if !defined(DYNAMICLIGHTMAP_ON)
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
	float4 texcoord7 : TEXCOORD7;
};
#elif defined(DYNAMICLIGHTMAP_ON)
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
	float4 texcoord7 : TEXCOORD7;
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

// vs d8ef705a8ffc438e: 3 retail keyword combination(s)
void vs_d8ef705a8ffc438e_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  float2 v2 : TEXCOORD1,
  float3 v3 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7)
{
  float4 r0,r1,r2;
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
  o1.xy = v1.xy;
  r1.xyzw = _TilingFactor.xxxx * r0.xzxy;
  o1.zw = -r1.xy * float2(0.001953125,0.001953125) + float2(1,1);
  r1.xy = _TilingFactor.xx * r0.zy;
  o2.xyzw = float4(0.001953125,0.001953125,0.001953125,0.001953125) * r1.zwxy;
  r1.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o8.xyz = r0.xyz;
  r0.x = dot(r1.xyz, r1.xyz);
  o3.xyz = r1.xyz;
  o3.w = sqrt(r0.x);
  o4.xyzw = float4(0,0,0,0);
  r0.xyz = float3(0,1,0) * v3.zxy;
  r0.xyz = v3.yzx * float3(1,0,0) + -r0.xyz;
  r0.w = dot(r0.xy, r0.xy);
  r0.w = rsqrt(r0.w);
  o5.xyz = r0.xyz * r0.www;
  o5.w = _BT_SunlightDirection.x;
  r1.xyz = v3.zxy * r0.yzx;
  r0.xyz = v3.yzx * r0.zxy + -r1.xyz;
  r0.xyz = -unity_WorldTransformParams.www * r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o6.xyz = r0.xyz * r0.www;
  o6.w = _BT_SunlightDirection.y;
  r0.x = dot(v3.xyz, v3.xyz);
  r0.x = rsqrt(r0.x);
  o7.xyz = v3.xyz * r0.xxx;
  o7.w = _BT_SunlightDirection.z;
  o8.w = 1;
  return;
}


// vs 70bfab99e1b6dfa8: 1 retail keyword combination(s)
void vs_70bfab99e1b6dfa8_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float2 v3 : TEXCOORD2,
  float3 v4 : NORMAL0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float4 o2 : TEXCOORD1,
  inout float4 o3 : TEXCOORD2,
  inout float4 o4 : TEXCOORD3,
  inout float4 o5 : TEXCOORD4,
  inout float4 o6 : TEXCOORD5,
  inout float4 o7 : TEXCOORD6,
  inout float4 o8 : TEXCOORD7)
{
  float4 r0,r1,r2;
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
  o1.xy = v1.xy;
  r1.xyzw = _TilingFactor.xxxx * r0.xzxy;
  o1.zw = -r1.xy * float2(0.001953125,0.001953125) + float2(1,1);
  r1.xy = _TilingFactor.xx * r0.zy;
  o2.xyzw = float4(0.001953125,0.001953125,0.001953125,0.001953125) * r1.zwxy;
  r1.xyz = -_WorldSpaceCameraPos.xyz + r0.xyz;
  o8.xyz = r0.xyz;
  r0.x = dot(r1.xyz, r1.xyz);
  o3.xyz = r1.xyz;
  o3.w = sqrt(r0.x);
  o4.zw = v3.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  o4.xy = float2(0,0);
  r0.xyz = float3(0,1,0) * v4.zxy;
  r0.xyz = v4.yzx * float3(1,0,0) + -r0.xyz;
  r0.w = dot(r0.xy, r0.xy);
  r0.w = rsqrt(r0.w);
  o5.xyz = r0.xyz * r0.www;
  o5.w = _BT_SunlightDirection.x;
  r1.xyz = v4.zxy * r0.yzx;
  r0.xyz = v4.yzx * r0.zxy + -r1.xyz;
  r0.xyz = -unity_WorldTransformParams.www * r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o6.xyz = r0.xyz * r0.www;
  o6.w = _BT_SunlightDirection.y;
  r0.x = dot(v4.xyz, v4.xyz);
  r0.x = rsqrt(r0.x);
  o7.xyz = v4.xyz * r0.xxx;
  o7.w = _BT_SunlightDirection.z;
  o8.w = 1;
  return;
}


// ps 004d5227fc0157b8: 3 retail keyword combination(s)
void ps_004d5227fc0157b8_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v7.y * v7.y;
  r0.x = v7.x * v7.x + -r0.x;
  r1.xyzw = v7.xyzz * v7.yzzx;
  r2.x = dot(BT_SHBr.xyzw, r1.xyzw);
  r2.y = dot(BT_SHBg.xyzw, r1.xyzw);
  r2.z = dot(BT_SHBb.xyzw, r1.xyzw);
  r0.xyz = BT_SHC.xyz * r0.xxx + r2.xyz;
  r1.xyz = v7.xyz;
  r1.w = 1;
  r2.x = dot(BT_SHAr.xyzw, r1.xyzw);
  r2.y = dot(BT_SHAg.xyzw, r1.xyzw);
  r2.z = dot(BT_SHAb.xyzw, r1.xyzw);
  o0.xyz = r2.xyz + r0.xyz;
  o0.w = 1;
  o1.xyzw = float4(0,1,0,1);
  return;
}


// ps fe3a67badbc94a37: 1 retail keyword combination(s)
void ps_fe3a67badbc94a37_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  inout float4 o0 : SV_Target0,
  inout float4 o1 : SV_Target1)
{
  o0.xyzw = unity_DynamicLightmap.Sample(samplerunity_DynamicLightmap, v4.zw).xyzw;
  o1.xyzw = unity_DynamicDirectionality.Sample(samplerunity_DynamicLightmap, v4.zw).xyzw;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if !defined(DYNAMICLIGHTMAP_ON)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float4 o7 = 0;
		float4 o8 = 0;
		vs_d8ef705a8ffc438e_impl(v.position0, v.texcoord0, v.texcoord1.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6, o7, o8);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
	}
#elif defined(DYNAMICLIGHTMAP_ON)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float4 o2 = 0;
		float4 o3 = 0;
		float4 o4 = 0;
		float4 o5 = 0;
		float4 o6 = 0;
		float4 o7 = 0;
		float4 o8 = 0;
		vs_70bfab99e1b6dfa8_impl(v.position0, v.texcoord0, v.texcoord1, v.texcoord2.xy, v.normal0.xyz, o0, o1, o2, o3, o4, o5, o6, o7, o8);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1 = o2;
		o.texcoord2 = o3;
		o.texcoord3 = o4;
		o.texcoord4 = o5;
		o.texcoord5 = o6;
		o.texcoord6 = o7;
		o.texcoord7 = o8;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(DYNAMICLIGHTMAP_ON)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		ps_004d5227fc0157b8_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, o0, o1);
		r.t0 = o0;
		r.t1 = o1;
	}
#elif defined(DYNAMICLIGHTMAP_ON)
	{
		float4 o0 = 0;
		float4 o1 = 0;
		ps_fe3a67badbc94a37_impl(i.sv_position, i.texcoord0, i.texcoord1, i.texcoord2, i.texcoord3, i.texcoord4, i.texcoord5, i.texcoord6, i.texcoord7, o0, o1);
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
	}
}
