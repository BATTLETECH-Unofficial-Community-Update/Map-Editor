Shader "Hidden/BT-SaveShadowParams"
{
	Properties
	{
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

#define cmp -


float4x4 _BT_PreviousVP;
struct u3_t { float val[128]; };
RWStructuredBuffer<u3_t> u3 : register(u3);

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


// ps 2374862e992971dd: 1 retail keyword combination(s)
void ps_2374862e992971dd_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  u3[0].val[0/4] = unity_WorldToShadow[0][0][0];
  u3[0].val[0/4+1] = unity_WorldToShadow[0][1][0];
  u3[0].val[0/4+2] = unity_WorldToShadow[0][2][0];
  u3[0].val[0/4+3] = unity_WorldToShadow[0][3][0];
  u3[0].val[16/4] = unity_WorldToShadow[0][0][1];
  u3[0].val[16/4+1] = unity_WorldToShadow[0][1][1];
  u3[0].val[16/4+2] = unity_WorldToShadow[0][2][1];
  u3[0].val[16/4+3] = unity_WorldToShadow[0][3][1];
  u3[0].val[32/4] = unity_WorldToShadow[0][0][2];
  u3[0].val[32/4+1] = unity_WorldToShadow[0][1][2];
  u3[0].val[32/4+2] = unity_WorldToShadow[0][2][2];
  u3[0].val[32/4+3] = unity_WorldToShadow[0][3][2];
  u3[0].val[48/4] = unity_WorldToShadow[0][0][3];
  u3[0].val[48/4+1] = unity_WorldToShadow[0][1][3];
  u3[0].val[48/4+2] = unity_WorldToShadow[0][2][3];
  u3[0].val[48/4+3] = unity_WorldToShadow[0][3][3];
  u3[0].val[64/4] = unity_WorldToShadow[1][0][0];
  u3[0].val[64/4+1] = unity_WorldToShadow[1][1][0];
  u3[0].val[64/4+2] = unity_WorldToShadow[1][2][0];
  u3[0].val[64/4+3] = unity_WorldToShadow[1][3][0];
  u3[0].val[80/4] = unity_WorldToShadow[1][0][1];
  u3[0].val[80/4+1] = unity_WorldToShadow[1][1][1];
  u3[0].val[80/4+2] = unity_WorldToShadow[1][2][1];
  u3[0].val[80/4+3] = unity_WorldToShadow[1][3][1];
  u3[0].val[96/4] = unity_WorldToShadow[1][0][2];
  u3[0].val[96/4+1] = unity_WorldToShadow[1][1][2];
  u3[0].val[96/4+2] = unity_WorldToShadow[1][2][2];
  u3[0].val[96/4+3] = unity_WorldToShadow[1][3][2];
  u3[0].val[112/4] = unity_WorldToShadow[1][0][3];
  u3[0].val[112/4+1] = unity_WorldToShadow[1][1][3];
  u3[0].val[112/4+2] = unity_WorldToShadow[1][2][3];
  u3[0].val[112/4+3] = unity_WorldToShadow[1][3][3];
  u3[0].val[128/4] = unity_WorldToShadow[2][0][0];
  u3[0].val[128/4+1] = unity_WorldToShadow[2][1][0];
  u3[0].val[128/4+2] = unity_WorldToShadow[2][2][0];
  u3[0].val[128/4+3] = unity_WorldToShadow[2][3][0];
  u3[0].val[144/4] = unity_WorldToShadow[2][0][1];
  u3[0].val[144/4+1] = unity_WorldToShadow[2][1][1];
  u3[0].val[144/4+2] = unity_WorldToShadow[2][2][1];
  u3[0].val[144/4+3] = unity_WorldToShadow[2][3][1];
  u3[0].val[160/4] = unity_WorldToShadow[2][0][2];
  u3[0].val[160/4+1] = unity_WorldToShadow[2][1][2];
  u3[0].val[160/4+2] = unity_WorldToShadow[2][2][2];
  u3[0].val[160/4+3] = unity_WorldToShadow[2][3][2];
  u3[0].val[176/4] = unity_WorldToShadow[2][0][3];
  u3[0].val[176/4+1] = unity_WorldToShadow[2][1][3];
  u3[0].val[176/4+2] = unity_WorldToShadow[2][2][3];
  u3[0].val[176/4+3] = unity_WorldToShadow[2][3][3];
  u3[0].val[192/4] = unity_WorldToShadow[3][0][0];
  u3[0].val[192/4+1] = unity_WorldToShadow[3][1][0];
  u3[0].val[192/4+2] = unity_WorldToShadow[3][2][0];
  u3[0].val[192/4+3] = unity_WorldToShadow[3][3][0];
  u3[0].val[208/4] = unity_WorldToShadow[3][0][1];
  u3[0].val[208/4+1] = unity_WorldToShadow[3][1][1];
  u3[0].val[208/4+2] = unity_WorldToShadow[3][2][1];
  u3[0].val[208/4+3] = unity_WorldToShadow[3][3][1];
  u3[0].val[224/4] = unity_WorldToShadow[3][0][2];
  u3[0].val[224/4+1] = unity_WorldToShadow[3][1][2];
  u3[0].val[224/4+2] = unity_WorldToShadow[3][2][2];
  u3[0].val[224/4+3] = unity_WorldToShadow[3][3][2];
  u3[0].val[240/4] = unity_WorldToShadow[3][0][3];
  u3[0].val[240/4+1] = unity_WorldToShadow[3][1][3];
  u3[0].val[240/4+2] = unity_WorldToShadow[3][2][3];
  u3[0].val[240/4+3] = unity_WorldToShadow[3][3][3];
  u3[0].val[256/4] = unity_CameraToWorld[0][0];
  u3[0].val[256/4+1] = unity_CameraToWorld[1][0];
  u3[0].val[256/4+2] = unity_CameraToWorld[2][0];
  u3[0].val[256/4+3] = unity_CameraToWorld[3][0];
  u3[0].val[272/4] = unity_CameraToWorld[0][1];
  u3[0].val[272/4+1] = unity_CameraToWorld[1][1];
  u3[0].val[272/4+2] = unity_CameraToWorld[2][1];
  u3[0].val[272/4+3] = unity_CameraToWorld[3][1];
  u3[0].val[288/4] = unity_CameraToWorld[0][2];
  u3[0].val[288/4+1] = unity_CameraToWorld[1][2];
  u3[0].val[288/4+2] = unity_CameraToWorld[2][2];
  u3[0].val[288/4+3] = unity_CameraToWorld[3][2];
  u3[0].val[304/4] = unity_CameraToWorld[0][3];
  u3[0].val[304/4+1] = unity_CameraToWorld[1][3];
  u3[0].val[304/4+2] = unity_CameraToWorld[2][3];
  u3[0].val[304/4+3] = unity_CameraToWorld[3][3];
  r0.x = unity_ShadowSplitSqRadii.x;
  r0.y = _LightShadowData.x;
  r0.z = _ProjectionParams.x;
  r0.w = _ZBufferParams.x;
  u3[0].val[320/4] = r0.x;
  u3[0].val[320/4+1] = r0.y;
  u3[0].val[320/4+2] = r0.z;
  u3[0].val[320/4+3] = r0.w;
  r0.x = unity_ShadowSplitSqRadii.y;
  r0.y = _LightShadowData.y;
  r0.z = _ProjectionParams.y;
  r0.w = _ZBufferParams.y;
  u3[0].val[336/4] = r0.x;
  u3[0].val[336/4+1] = r0.y;
  u3[0].val[336/4+2] = r0.z;
  u3[0].val[336/4+3] = r0.w;
  r0.x = unity_ShadowSplitSqRadii.z;
  r0.y = _LightShadowData.z;
  r0.z = _ProjectionParams.z;
  r0.w = _ZBufferParams.z;
  u3[0].val[352/4] = r0.x;
  u3[0].val[352/4+1] = r0.y;
  u3[0].val[352/4+2] = r0.z;
  u3[0].val[352/4+3] = r0.w;
  r0.x = unity_ShadowSplitSqRadii.w;
  r0.y = _LightShadowData.w;
  r0.z = _ProjectionParams.w;
  r0.w = _ZBufferParams.w;
  u3[0].val[368/4] = r0.x;
  u3[0].val[368/4+1] = r0.y;
  u3[0].val[368/4+2] = r0.z;
  u3[0].val[368/4+3] = r0.w;
  r0.x = unity_ShadowSplitSpheres[0].x;
  r0.y = unity_ShadowSplitSpheres[1].x;
  r0.z = unity_ShadowSplitSpheres[2].x;
  r0.w = unity_ShadowSplitSpheres[3].x;
  u3[0].val[384/4] = r0.x;
  u3[0].val[384/4+1] = r0.y;
  u3[0].val[384/4+2] = r0.z;
  u3[0].val[384/4+3] = r0.w;
  r0.x = unity_ShadowSplitSpheres[0].y;
  r0.y = unity_ShadowSplitSpheres[1].y;
  r0.z = unity_ShadowSplitSpheres[2].y;
  r0.w = unity_ShadowSplitSpheres[3].y;
  u3[0].val[400/4] = r0.x;
  u3[0].val[400/4+1] = r0.y;
  u3[0].val[400/4+2] = r0.z;
  u3[0].val[400/4+3] = r0.w;
  r0.x = unity_ShadowSplitSpheres[0].z;
  r0.y = unity_ShadowSplitSpheres[1].z;
  r0.z = unity_ShadowSplitSpheres[2].z;
  r0.w = unity_ShadowSplitSpheres[3].z;
  u3[0].val[416/4] = r0.x;
  u3[0].val[416/4+1] = r0.y;
  u3[0].val[416/4+2] = r0.z;
  u3[0].val[416/4+3] = r0.w;
  r0.x = unity_ShadowSplitSpheres[0].w;
  r0.y = unity_ShadowSplitSpheres[1].w;
  r0.z = unity_ShadowSplitSpheres[2].w;
  r0.w = unity_ShadowSplitSpheres[3].w;
  u3[0].val[432/4] = r0.x;
  u3[0].val[432/4+1] = r0.y;
  u3[0].val[432/4+2] = r0.z;
  u3[0].val[432/4+3] = r0.w;
  u3[0].val[448/4] = _BT_PreviousVP[0][0];
  u3[0].val[448/4+1] = _BT_PreviousVP[1][0];
  u3[0].val[448/4+2] = _BT_PreviousVP[2][0];
  u3[0].val[448/4+3] = _BT_PreviousVP[3][0];
  u3[0].val[464/4] = _BT_PreviousVP[0][1];
  u3[0].val[464/4+1] = _BT_PreviousVP[1][1];
  u3[0].val[464/4+2] = _BT_PreviousVP[2][1];
  u3[0].val[464/4+3] = _BT_PreviousVP[3][1];
  u3[0].val[480/4] = _BT_PreviousVP[0][2];
  u3[0].val[480/4+1] = _BT_PreviousVP[1][2];
  u3[0].val[480/4+2] = _BT_PreviousVP[2][2];
  u3[0].val[480/4+3] = _BT_PreviousVP[3][2];
  u3[0].val[496/4] = _BT_PreviousVP[0][3];
  u3[0].val[496/4+1] = _BT_PreviousVP[1][3];
  u3[0].val[496/4+2] = _BT_PreviousVP[2][3];
  u3[0].val[496/4+3] = _BT_PreviousVP[3][3];
  r0.xy = float2(4,4) * v0.xy;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r1.x = dot(float4(unity_WorldToShadow[0][0][0], unity_WorldToShadow[0][1][0], unity_WorldToShadow[0][2][0], unity_WorldToShadow[0][3][0]), icb[r0.x+0].xyzw);
  r1.y = dot(float4(unity_WorldToShadow[0][0][1], unity_WorldToShadow[0][1][1], unity_WorldToShadow[0][2][1], unity_WorldToShadow[0][3][1]), icb[r0.x+0].xyzw);
  r1.z = dot(float4(unity_WorldToShadow[0][0][2], unity_WorldToShadow[0][1][2], unity_WorldToShadow[0][2][2], unity_WorldToShadow[0][3][2]), icb[r0.x+0].xyzw);
  r1.w = dot(float4(unity_WorldToShadow[0][0][3], unity_WorldToShadow[0][1][3], unity_WorldToShadow[0][2][3], unity_WorldToShadow[0][3][3]), icb[r0.x+0].xyzw);
  o0.x = dot(r1.xyzw, icb[r0.y+0].xyzw);
  r1.x = dot(float4(unity_WorldToShadow[1][0][0], unity_WorldToShadow[1][1][0], unity_WorldToShadow[1][2][0], unity_WorldToShadow[1][3][0]), icb[r0.x+0].xyzw);
  r1.y = dot(float4(unity_WorldToShadow[1][0][1], unity_WorldToShadow[1][1][1], unity_WorldToShadow[1][2][1], unity_WorldToShadow[1][3][1]), icb[r0.x+0].xyzw);
  r1.z = dot(float4(unity_WorldToShadow[1][0][2], unity_WorldToShadow[1][1][2], unity_WorldToShadow[1][2][2], unity_WorldToShadow[1][3][2]), icb[r0.x+0].xyzw);
  r1.w = dot(float4(unity_WorldToShadow[1][0][3], unity_WorldToShadow[1][1][3], unity_WorldToShadow[1][2][3], unity_WorldToShadow[1][3][3]), icb[r0.x+0].xyzw);
  o0.y = dot(r1.xyzw, icb[r0.y+0].xyzw);
  r1.x = dot(float4(unity_WorldToShadow[2][0][0], unity_WorldToShadow[2][1][0], unity_WorldToShadow[2][2][0], unity_WorldToShadow[2][3][0]), icb[r0.x+0].xyzw);
  r1.y = dot(float4(unity_WorldToShadow[2][0][1], unity_WorldToShadow[2][1][1], unity_WorldToShadow[2][2][1], unity_WorldToShadow[2][3][1]), icb[r0.x+0].xyzw);
  r1.z = dot(float4(unity_WorldToShadow[2][0][2], unity_WorldToShadow[2][1][2], unity_WorldToShadow[2][2][2], unity_WorldToShadow[2][3][2]), icb[r0.x+0].xyzw);
  r1.w = dot(float4(unity_WorldToShadow[2][0][3], unity_WorldToShadow[2][1][3], unity_WorldToShadow[2][2][3], unity_WorldToShadow[2][3][3]), icb[r0.x+0].xyzw);
  o0.z = dot(r1.xyzw, icb[r0.y+0].xyzw);
  r1.x = dot(float4(unity_WorldToShadow[3][0][0], unity_WorldToShadow[3][1][0], unity_WorldToShadow[3][2][0], unity_WorldToShadow[3][3][0]), icb[r0.x+0].xyzw);
  r1.y = dot(float4(unity_WorldToShadow[3][0][1], unity_WorldToShadow[3][1][1], unity_WorldToShadow[3][2][1], unity_WorldToShadow[3][3][1]), icb[r0.x+0].xyzw);
  r1.z = dot(float4(unity_WorldToShadow[3][0][2], unity_WorldToShadow[3][1][2], unity_WorldToShadow[3][2][2], unity_WorldToShadow[3][3][2]), icb[r0.x+0].xyzw);
  r1.w = dot(float4(unity_WorldToShadow[3][0][3], unity_WorldToShadow[3][1][3], unity_WorldToShadow[3][2][3], unity_WorldToShadow[3][3][3]), icb[r0.x+0].xyzw);
  o0.w = dot(r1.xyzw, icb[r0.y+0].xyzw);
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
		ps_2374862e992971dd_impl(i.texcoord0.xy, i.sv_position, o0);
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
			#pragma target 5.0

#define cmp -


float4x4 _BT_PreviousVP;
float4x4 _BT_InvVP;

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


// ps f119bbbb9004edfc: 1 retail keyword combination(s)
void ps_f119bbbb9004edfc_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(4,4) * v0.xy;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r1.x = dot(float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]), icb[r0.x+0].xyzw);
  r1.y = dot(float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]), icb[r0.x+0].xyzw);
  r1.z = dot(float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]), icb[r0.x+0].xyzw);
  r1.w = dot(float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]), icb[r0.x+0].xyzw);
  o0.x = dot(r1.xyzw, icb[r0.y+0].xyzw);
  r1.xyzw = icb[r0.x+0].xxxx * unity_ShadowFadeCenterAndType.xyzw;
  r1.xyzw = icb[r0.x+0].yyyy * _LightShadowData.xyzw + r1.xyzw;
  r1.xyzw = icb[r0.x+0].zzzz * _ProjectionParams.xyzw + r1.xyzw;
  r1.xyzw = icb[r0.x+0].wwww * _ZBufferParams.xyzw + r1.xyzw;
  o0.y = dot(r1.xyzw, icb[r0.y+0].xyzw);
  r1.x = dot(float4(_BT_InvVP[0][0], _BT_InvVP[1][0], _BT_InvVP[2][0], _BT_InvVP[3][0]), icb[r0.x+0].xyzw);
  r1.y = dot(float4(_BT_InvVP[0][1], _BT_InvVP[1][1], _BT_InvVP[2][1], _BT_InvVP[3][1]), icb[r0.x+0].xyzw);
  r1.z = dot(float4(_BT_InvVP[0][2], _BT_InvVP[1][2], _BT_InvVP[2][2], _BT_InvVP[3][2]), icb[r0.x+0].xyzw);
  r1.w = dot(float4(_BT_InvVP[0][3], _BT_InvVP[1][3], _BT_InvVP[2][3], _BT_InvVP[3][3]), icb[r0.x+0].xyzw);
  o0.z = dot(r1.xyzw, icb[r0.y+0].xyzw);
  r1.x = dot(float4(_BT_PreviousVP[0][0], _BT_PreviousVP[1][0], _BT_PreviousVP[2][0], _BT_PreviousVP[3][0]), icb[r0.x+0].xyzw);
  r1.y = dot(float4(_BT_PreviousVP[0][1], _BT_PreviousVP[1][1], _BT_PreviousVP[2][1], _BT_PreviousVP[3][1]), icb[r0.x+0].xyzw);
  r1.z = dot(float4(_BT_PreviousVP[0][2], _BT_PreviousVP[1][2], _BT_PreviousVP[2][2], _BT_PreviousVP[3][2]), icb[r0.x+0].xyzw);
  r1.w = dot(float4(_BT_PreviousVP[0][3], _BT_PreviousVP[1][3], _BT_PreviousVP[2][3], _BT_PreviousVP[3][3]), icb[r0.x+0].xyzw);
  o0.w = dot(r1.xyzw, icb[r0.y+0].xyzw);
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
		ps_f119bbbb9004edfc_impl(i.texcoord0.xy, i.sv_position, o0);
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
			ColorMask B

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0

#define cmp -


float4x4 _PreviousVP;

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


// ps 061cf06464d5f8d8: 1 retail keyword combination(s)
void ps_061cf06464d5f8d8_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(4,4) * v0.xy;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r1.x = dot(float4(_PreviousVP[0][0], _PreviousVP[1][0], _PreviousVP[2][0], _PreviousVP[3][0]), icb[r0.x+0].xyzw);
  r1.y = dot(float4(_PreviousVP[0][1], _PreviousVP[1][1], _PreviousVP[2][1], _PreviousVP[3][1]), icb[r0.x+0].xyzw);
  r1.z = dot(float4(_PreviousVP[0][2], _PreviousVP[1][2], _PreviousVP[2][2], _PreviousVP[3][2]), icb[r0.x+0].xyzw);
  r1.w = dot(float4(_PreviousVP[0][3], _PreviousVP[1][3], _PreviousVP[2][3], _PreviousVP[3][3]), icb[r0.x+0].xyzw);
  o0.z = dot(r1.xyzw, icb[r0.y+0].xyzw);
  o0.xyw = float3(0,0,0);
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
		ps_061cf06464d5f8d8_impl(i.texcoord0.xy, i.sv_position, o0);
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
