Shader "Hidden/BT-DrawLights"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Blend One One
			ZWrite Off
			ZTest Always
			Cull Off
			ColorMask RGB
			Stencil { Ref 1 ReadMask 1 WriteMask 1 Comp Greater Pass Replace }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile _ _BT_SHADOWS
			#pragma multi_compile _ _BT_SIM_GAME
			#pragma multi_compile _ _LIGHTQUAL_HIGH
			#pragma multi_compile _ _LIGHTQUAL_LOW
			#pragma multi_compile _ _LIGHTQUAL_MED
			#pragma multi_compile _ _SIMPLE_PASS

#define cmp -

Texture2D _CameraGBufferTexture0;
SamplerState sampler_CameraGBufferTexture0;
Texture2D _CameraGBufferTexture1;
SamplerState sampler_CameraGBufferTexture1;
Texture2D _CameraGBufferTexture2;
SamplerState sampler_CameraGBufferTexture2;
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture2D _BT_ShadowMap;
SamplerComparisonState sampler_BT_ShadowMap;
Texture2D _BT_PreIntegratedSSS;
SamplerState sampler_BT_PreIntegratedSSS;
Texture2D _BT_SkinTransmission;
SamplerState sampler_BT_SkinTransmission;
Texture3D<int4> _BT_ListEntries;
SamplerState sampler_BT_ListEntries;
Texture2D _TileID;
Texture2D _ShadowDummyTex;
SamplerState sampler_ShadowDummyTex;
struct _BT_LightBuffer_t { float val[16]; };
StructuredBuffer<_BT_LightBuffer_t> _BT_LightBuffer;
struct _BT_LinkListBuffer_t { uint val[1]; };
StructuredBuffer<_BT_LinkListBuffer_t> _BT_LinkListBuffer;

float3 _GlobalProjection;
float4x4 _BT_LightMatrix[256];
float _BTLightingTileSize;
float _BTScreenWidth;
float _BTScreenHeight;
float _BT_ClusterBounds[8];
float _MatIDMask;
float4 _BT_ShadowMap_TexelSize;
float4 _BT_ShadowMapParams;
float _BT_MaxShadowDist;

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

// vs cbf2e6439936bc93: 24 retail keyword combination(s)
void vs_cbf2e6439936bc93_impl(
  float4 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  inout float4 o0 : TEXCOORD0,
  inout float4 o1 : SV_POSITION0,
  inout float3 o2 : TEXCOORD1)
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
  r1.x = _ProjectionParams.x * r0.y;
  r1.w = 0.5 * r1.x;
  r1.xz = float2(0.5,0.5) * r0.xw;
  o1.xyzw = r0.xyzw;
  o0.zw = r1.xw + r1.zz;
  o0.xy = v1.xy;
  r0.xy = v0.xy * float2(2,2) + float2(-1,-1);
  o2.xy = _GlobalProjection.xy * r0.xy;
  o2.z = 1;
  return;
}


// ps 75890df19dcb4ea3: 1 retail keyword combination(s)
void ps_75890df19dcb4ea3_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyzw = _BT_ListEntries.Load(r0.xywz).xyzw;
  r1.y = cmp((int)r0.x >= 0);
  [branch] if (r1.y != 0) {
    r1.yzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyz;
    r2.xyz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xzw;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xyz = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r1.yzw;
    r4.xyz = r2.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r2.x = -r2.x * 0.959999979 + 0.959999979;
    r1.yzw = r2.xxx * r1.yzw;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r2.x = dot(r3.xyz, r3.xyz);
    r2.x = rsqrt(r2.x);
    r3.xyz = r3.xyz * r2.xxx;
    r5.z = 1 + -r1.x;
    r5.xy = v0.zw;
    r5.xyz = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r5.yyyy;
    r6.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r5.xxxx + r6.xyzw;
    r5.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r5.zzzz + r6.xyzw;
    r5.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r5.xyzw;
    r5.xyz = r5.xyz / r5.www;
    r6.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r5.yyyy;
    r6.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r5.xxxx + r6.xyzw;
    r5.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r5.zzzz + r6.xyzw;
    r5.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r5.xyzw;
    r6.xyz = -_WorldSpaceCameraPos.xyz + r5.xyz;
    r1.x = dot(r6.xyz, r6.xyz);
    r1.x = rsqrt(r1.x);
    r7.xyz = r6.xyz * r1.xxx;
    r2.x = dot(r3.xyz, -r7.xyz);
    r2.w = max(0, r2.x);
    r4.w = min(1, r2.w);
    r0.y = (int)r0.y + (int)r0.x;
    r3.w = cmp(r3.w == 0.666666687);
    r2.y = 1 + -r2.y;
    r6.w = r2.y * r2.y;
    r7.w = cmp(r2.x < 0);
    r8.x = 9.99999975e-006 + -r2.x;
    r8.xyz = -r7.xyz * r8.xxx + r3.xyz;
    r8.xyz = r7.www ? r8.xyz : r3.xyz;
    r7.w = -r2.y * r2.y + 1;
    r8.w = r4.w * r7.w + r6.w;
    r9.x = r6.w * r6.w;
    r9.y = 0.318309873 * r9.x;
    r9.z = 0.5 * r6.w;
    r9.w = r6.w * -0.337748349 + 1;
    r10.x = 1 + -r4.w;
    r10.y = r10.x * r10.x;
    r10.y = r10.y * r10.y;
    r10.x = r10.y * r10.x;
    r10.yzw = float3(1,1,1) + -r4.xyz;
    r11.yzw = float3(0,0,0);
    r12.xyz = float3(0,0,0);
    r12.w = r0.x;
    [loop] while (true) {
      r13.x = cmp((int)r12.w >= (int)r0.y);
      [branch] if (r13.x != 0) break;
      r13.x = _BT_LinkListBuffer[r12.w].val[0/4];
      r14.x = _BT_LightBuffer[r13.x].val[0/4];
      r14.y = _BT_LightBuffer[r13.x].val[0/4+1];
      r14.z = _BT_LightBuffer[r13.x].val[0/4+2];
      r14.w = _BT_LightBuffer[r13.x].val[0/4+3];
      r13.y = _BT_LightBuffer[r13.x].val[32/4];
      r14.xyz = -r14.xyz + r5.xyz;
      r13.z = dot(r14.xyz, r14.xyz);
      r13.w = r14.w * r14.w;
      r15.x = max(0.100000001, r13.z);
      r13.w = r15.x / r13.w;
      r13.w = -r13.w * r13.w + 1;
      r13.w = max(0, r13.w);
      r13.w = r13.w * r13.w;
      r13.y = r14.w * r13.y + r15.x;
      r13.y = 1 / r13.y;
      r13.y = r13.y * r13.w;
      r13.w = cmp(r13.y != 0.000000);
      [branch] if (r13.w != 0) {
        r15.x = _BT_LightBuffer[r13.x].val[16/4];
        r15.y = _BT_LightBuffer[r13.x].val[16/4+1];
        r15.z = _BT_LightBuffer[r13.x].val[16/4+2];
        r13.x = _BT_LightBuffer[r13.x].val[60/4];
        r13.z = rsqrt(r13.z);
        r16.xyz = r14.xyz * r13.zzz;
        r15.xyz = r15.xyz * r13.yyy;
        r13.y = dot(r3.xyz, -r16.xyz);
        r11.x = max(0, r13.y);
        r13.y = 0.800000012 + r13.y;
        r13.y = saturate(0.555555582 * r13.y);
        r13.y = r13.y * r13.y;
        r13.y = r13.y * r13.y;
        r13.y = r13.y * 1.38888896 + -r11.x;
        r17.x = r2.z * r13.y + r11.x;
        r13.y = saturate(dot(r3.xyz, r16.xyz));
        r18.xyz = r13.yyy * r1.yzw;
        r18.xyz = r18.xyz * r15.xyz;
        r18.xyz = r18.xyz * r2.zzz;
        r17.yzw = float3(0.25,0.25,0.25) * r18.xyz;
        r17.xyzw = r3.wwww ? r17.xyzw : r11.xyzw;
        r11.x = cmp(0 != r13.x);
        r13.xyz = -r14.xyz * r13.zzz + -r7.xyz;
        r13.w = dot(r13.xyz, r13.xyz);
        r13.w = max(0.00100000005, r13.w);
        r13.w = rsqrt(r13.w);
        r13.xyz = r13.xyz * r13.www;
        r13.w = dot(r8.xyz, r13.xyz);
        r13.x = dot(-r16.xyz, r13.xyz);
        r13.xw = max(float2(0,0), r13.xw);
        r13.y = r17.x * r7.w + r6.w;
        r13.y = r13.y * r4.w;
        r13.y = r17.x * r8.w + r13.y;
        r13.y = 9.99999975e-006 + r13.y;
        r13.y = 0.5 / r13.y;
        r13.z = r13.w * r9.x + -r13.w;
        r13.z = r13.z * r13.w + 1;
        r13.z = r13.z * r13.z + 1.00000001e-007;
        r13.z = r9.y / r13.z;
        r13.w = 1 + -r17.x;
        r14.x = r13.w * r13.w;
        r14.x = r14.x * r14.x;
        r13.w = r14.x * r13.w;
        r14.x = r13.x + r13.x;
        r14.x = r14.x * r13.x;
        r14.x = r14.x * r6.w + r9.z;
        r14.x = -1 + r14.x;
        r13.w = r14.x * r13.w + 1;
        r14.x = r14.x * r10.x + 1;
        r13.w = r14.x * r13.w;
        r13.w = r13.w * r9.w;
        r13.y = r13.y * r13.z;
        r13.yz = r13.yw * r17.xx;
        r13.y = 3.14159274 * r13.y;
        r13.y = max(0, r13.y);
        r14.xyz = r15.xyz * r13.zzz;
        r13.yzw = r13.yyy * r15.xyz;
        r13.x = 1 + -r13.x;
        r14.w = r13.x * r13.x;
        r14.w = r14.w * r14.w;
        r13.x = r14.w * r13.x;
        r15.xyz = r10.yzw * r13.xxx + r4.xyz;
        r13.xyz = r15.xyz * r13.yzw;
        r11.x = r11.x ? 1.000000 : 0;
        r13.xyz = r13.xyz * r11.xxx;
        r13.xyz = r1.yzw * r14.xyz + r13.xyz;
        r13.xyz = r17.yzw + r13.xyz;
      } else {
        r13.xyz = float3(0,0,0);
      }
      r12.xyz = r13.xyz + r12.xyz;
      r12.w = (int)r12.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r11.yzw = float3(0,0,0);
    r13.xyz = r12.xyz;
    r0.y = r12.w;
    [loop] while (true) {
      r0.z = cmp((int)r0.y >= (int)r0.x);
      [branch] if (r0.z != 0) break;
      r0.z = _BT_LinkListBuffer[r0.y].val[0/4];
      r14.x = _BT_LightBuffer[r0.z].val[0/4];
      r14.y = _BT_LightBuffer[r0.z].val[0/4+1];
      r14.z = _BT_LightBuffer[r0.z].val[0/4+2];
      r14.w = _BT_LightBuffer[r0.z].val[0/4+3];
      r13.w = _BT_LightBuffer[r0.z].val[32/4];
      r15.x = _BT_LightBuffer[r0.z].val[48/4];
      r15.y = _BT_LightBuffer[r0.z].val[48/4+1];
      r15.z = (uint)r0.z << 2;
      r13.w = frac(r13.w);
      r14.xyz = -r14.xyz + r5.xyz;
      r15.w = dot(r14.xyz, r14.xyz);
      r16.x = r14.w * r14.w;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r15.z) / 4u][0][1], _BT_LightMatrix[(uint)(r15.z) / 4u][1][1], _BT_LightMatrix[(uint)(r15.z) / 4u][2][1], _BT_LightMatrix[(uint)(r15.z) / 4u][3][1]) * r5.yyyy;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r15.z) / 4u][0][0], _BT_LightMatrix[(uint)(r15.z) / 4u][1][0], _BT_LightMatrix[(uint)(r15.z) / 4u][2][0], _BT_LightMatrix[(uint)(r15.z) / 4u][3][0]) * r5.xxxx + r17.xyzw;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r15.z) / 4u][0][2], _BT_LightMatrix[(uint)(r15.z) / 4u][1][2], _BT_LightMatrix[(uint)(r15.z) / 4u][2][2], _BT_LightMatrix[(uint)(r15.z) / 4u][3][2]) * r5.zzzz + r17.xyzw;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r15.z) / 4u][0][3], _BT_LightMatrix[(uint)(r15.z) / 4u][1][3], _BT_LightMatrix[(uint)(r15.z) / 4u][2][3], _BT_LightMatrix[(uint)(r15.z) / 4u][3][3]) * r5.wwww + r17.xyzw;
      r15.z = max(0.100000001, r15.w);
      r16.x = r15.z / r16.x;
      r16.x = -r16.x * r16.x + 1;
      r16.x = max(0, r16.x);
      r16.x = r16.x * r16.x;
      r13.w = r14.w * r13.w + r15.z;
      r13.w = 1 / r13.w;
      r13.w = r13.w * r16.x;
      r16.xyz = r17.xyz / r17.www;
      r14.w = cmp(0 >= r16.z);
      r16.zw = cmp(float2(1,1) < r16.xy);
      r14.w = (int)r14.w | (int)r16.z;
      r17.xy = cmp(r16.xy < float2(-1,-1));
      r14.w = (int)r14.w | (int)r17.x;
      r14.w = (int)r16.w | (int)r14.w;
      r14.w = (int)r17.y | (int)r14.w;
      r15.x = r15.x / r15.y;
      r15.x = min(0.99000001, r15.x);
      r15.y = dot(r16.xy, r16.xy);
      r15.y = sqrt(r15.y);
      r15.y = min(1, r15.y);
      r15.xy = float2(-1,-1) + r15.xy;
      r15.x = 1 / r15.x;
      r15.x = r15.y * r15.x;
      r15.x = min(1, r15.x);
      r15.y = r15.x * -2 + 3;
      r15.x = r15.x * r15.x;
      r15.x = r15.y * r15.x;
      r15.y = cmp(r15.x != 0.000000);
      r15.x = r15.y ? r15.x : 0;
      r14.w = r14.w ? 0 : r15.x;
      r13.w = r14.w * r13.w;
      r14.w = cmp(r13.w != 0.000000);
      [branch] if (r14.w != 0) {
        r15.x = _BT_LightBuffer[r0.z].val[16/4];
        r15.y = _BT_LightBuffer[r0.z].val[16/4+1];
        r15.z = _BT_LightBuffer[r0.z].val[16/4+2];
        r0.z = _BT_LightBuffer[r0.z].val[60/4];
        r14.w = rsqrt(r15.w);
        r16.xyz = r14.xyz * r14.www;
        r15.xyz = r15.xyz * r13.www;
        r13.w = dot(r3.xyz, -r16.xyz);
        r11.x = max(0, r13.w);
        r13.w = 0.800000012 + r13.w;
        r13.w = saturate(0.555555582 * r13.w);
        r13.w = r13.w * r13.w;
        r13.w = r13.w * r13.w;
        r13.w = r13.w * 1.38888896 + -r11.x;
        r17.x = r2.z * r13.w + r11.x;
        r13.w = saturate(dot(r3.xyz, r16.xyz));
        r18.xyz = r13.www * r1.yzw;
        r18.xyz = r18.xyz * r15.xyz;
        r18.xyz = r18.xyz * r2.zzz;
        r17.yzw = float3(0.25,0.25,0.25) * r18.xyz;
        r17.xyzw = r3.wwww ? r17.xyzw : r11.xyzw;
        r0.z = cmp(0 != r0.z);
        r14.xyz = -r14.xyz * r14.www + -r7.xyz;
        r11.x = dot(r14.xyz, r14.xyz);
        r11.x = max(0.00100000005, r11.x);
        r11.x = rsqrt(r11.x);
        r14.xyz = r14.xyz * r11.xxx;
        r11.x = dot(r8.xyz, r14.xyz);
        r11.x = max(0, r11.x);
        r13.w = dot(-r16.xyz, r14.xyz);
        r13.w = max(0, r13.w);
        r14.x = r17.x * r7.w + r6.w;
        r14.x = r14.x * r4.w;
        r14.x = r17.x * r8.w + r14.x;
        r14.x = 9.99999975e-006 + r14.x;
        r14.x = 0.5 / r14.x;
        r14.y = r11.x * r9.x + -r11.x;
        r11.x = r14.y * r11.x + 1;
        r11.x = r11.x * r11.x + 1.00000001e-007;
        r11.x = r9.y / r11.x;
        r14.y = 1 + -r17.x;
        r14.z = r14.y * r14.y;
        r14.z = r14.z * r14.z;
        r14.y = r14.z * r14.y;
        r14.z = r13.w + r13.w;
        r14.z = r14.z * r13.w;
        r14.z = r14.z * r6.w + r9.z;
        r14.z = -1 + r14.z;
        r14.y = r14.z * r14.y + 1;
        r14.z = r14.z * r10.x + 1;
        r14.y = r14.y * r14.z;
        r14.y = r14.y * r9.w;
        r11.x = r14.x * r11.x;
        r11.x = r11.x * r17.x;
        r11.x = 3.14159274 * r11.x;
        r11.x = max(0, r11.x);
        r14.x = r14.y * r17.x;
        r14.xyz = r15.xyz * r14.xxx;
        r15.xyz = r11.xxx * r15.xyz;
        r11.x = 1 + -r13.w;
        r13.w = r11.x * r11.x;
        r13.w = r13.w * r13.w;
        r11.x = r13.w * r11.x;
        r16.xyz = r10.yzw * r11.xxx + r4.xyz;
        r15.xyz = r16.xyz * r15.xyz;
        r0.z = r0.z ? 1.000000 : 0;
        r15.xyz = r15.xyz * r0.zzz;
        r14.xyz = r1.yzw * r14.xyz + r15.xyz;
        r14.xyz = r17.yzw + r14.xyz;
      } else {
        r14.xyz = float3(0,0,0);
      }
      r13.xyz = r14.xyz + r13.xyz;
      r0.y = (int)r0.y + 1;
    }
    r0.x = (int)r0.w + (int)r0.x;
    r1.yzw = float3(25,25,25) * r1.yzw;
    r0.z = r2.x + r2.x;
    r7.xyz = r3.xyz * -r0.zzz + -r7.xyz;
    r0.z = -r6.w * 0.5 + 1;
    r0.w = r2.w * r0.z + r9.z;
    r2.x = r6.w * r6.w + -1;
    r2.z = r9.x * r9.x;
    r2.w = 1 + -r2.w;
    r3.w = r2.w * r2.w;
    r3.w = r3.w * r3.w;
    r2.w = r3.w * r2.w;
    r8.xyz = r13.xyz;
    r3.w = r0.y;
    [loop] while (true) {
      r4.w = cmp((int)r3.w >= (int)r0.x);
      [branch] if (r4.w != 0) break;
      r4.w = _BT_LinkListBuffer[r3.w].val[0/4];
      r11.x = _BT_LightBuffer[r4.w].val[0/4];
      r11.y = _BT_LightBuffer[r4.w].val[0/4+1];
      r11.z = _BT_LightBuffer[r4.w].val[0/4+2];
      r11.w = _BT_LightBuffer[r4.w].val[0/4+3];
      r9.x = _BT_LightBuffer[r4.w].val[16/4];
      r9.y = _BT_LightBuffer[r4.w].val[16/4+1];
      r9.w = _BT_LightBuffer[r4.w].val[16/4+2];
      r5.w = _BT_LightBuffer[r4.w].val[32/4];
      r12.x = _BT_LightBuffer[r4.w].val[48/4];
      r12.y = _BT_LightBuffer[r4.w].val[48/4+1];
      r12.z = _BT_LightBuffer[r4.w].val[48/4+2];
      r4.w = r11.w * r11.w;
      r4.w = 1 / r4.w;
      r12.xyz = r12.xyz * r5.www + r11.xyz;
      r11.xyz = r11.xyz + -r5.xyz;
      r12.xyz = r12.xyz + -r5.xyz;
      r5.w = dot(r11.xyz, r11.xyz);
      r6.w = sqrt(r5.w);
      r7.w = dot(r12.xyz, r12.xyz);
      r7.w = sqrt(r7.w);
      r8.w = dot(r11.xyz, r3.xyz);
      r10.x = r6.w + r6.w;
      r8.w = r8.w / r10.x;
      r10.x = dot(r12.xyz, r3.xyz);
      r11.w = r7.w + r7.w;
      r10.x = r10.x / r11.w;
      r8.w = saturate(r10.x + r8.w);
      r14.xyz = r12.xyz + -r11.xyz;
      r10.x = dot(r7.xyz, r11.xyz);
      r11.w = dot(r7.xyz, r14.xyz);
      r12.w = dot(r11.xyz, r14.xyz);
      r13.w = dot(r14.xyz, r14.xyz);
      r5.w = r11.w * r5.w;
      r5.w = r12.w * r10.x + -r5.w;
      r10.x = r13.w * r10.x;
      r10.x = r12.w * r11.w + -r10.x;
      r5.w = saturate(r5.w / r10.x);
      r15.xyz = r14.yzx * r11.zxy;
      r15.xyz = r11.yzx * r14.zxy + -r15.xyz;
      r16.xyz = r14.zxy * r7.yzx;
      r16.xyz = r14.yzx * r7.zxy + -r16.xyz;
      r10.x = dot(r15.xyz, r16.xyz);
      r11.w = 1 + -r5.w;
      r10.x = cmp(r10.x >= 0);
      r10.x = r10.x ? 1.000000 : 0;
      r5.w = -r11.w + r5.w;
      r5.w = r10.x * r5.w + r11.w;
      r14.xyz = r14.xyz * r5.www + r11.xyz;
      r5.w = dot(r14.xyz, r7.xyz);
      r15.xyz = r5.www * r7.xyz + -r14.xyz;
      r5.w = dot(r15.xyz, r15.xyz);
      r5.w = sqrt(r5.w);
      r5.w = 0.100000001 / r5.w;
      r5.w = min(1, r5.w);
      r14.xyz = r15.xyz * r5.www + r14.xyz;
      r5.w = dot(r14.xyz, r14.xyz);
      r5.w = sqrt(r5.w);
      r14.xyz = r14.xyz / r5.www;
      r10.x = dot(r11.xyz, r12.xyz);
      r6.w = r6.w * r7.w + r10.x;
      r6.w = 0.5 * r6.w;
      r4.w = r6.w * r4.w;
      r4.w = sqrt(r4.w);
      r6.w = r4.w * 4 + 1;
      r6.w = r6.w * r6.w;
      r6.w = 1 / r6.w;
      r6.w = -0.0399999991 + r6.w;
      r6.w = 1.04166675 * r6.w;
      r4.w = cmp(r4.w >= 1);
      r4.w = r4.w ? 0 : r6.w;
      r9.xyw = r9.xyw * r4.www;
      r11.xyz = -r6.xyz * r1.xxx + r14.xyz;
      r4.w = dot(r11.xyz, r11.xyz);
      r4.w = max(0.00100000005, r4.w);
      r4.w = rsqrt(r4.w);
      r11.xyz = r11.xyz * r4.www;
      r4.w = dot(r3.xyz, r11.xyz);
      r4.w = max(0, r4.w);
      r6.w = dot(r14.xyz, r11.xyz);
      r6.w = max(0, r6.w);
      r7.w = r8.w * r0.z + r9.z;
      r7.w = r7.w * r0.w + 9.99999975e-006;
      r7.w = 1 / r7.w;
      r4.w = r4.w * r4.w;
      r4.w = r4.w * r2.x + 1;
      r4.w = max(9.99999997e-007, r4.w);
      r5.w = r5.w + r5.w;
      r5.w = 0.100000001 / r5.w;
      r5.w = r2.y * r2.y + r5.w;
      r5.w = min(1, r5.w);
      r5.w = r5.w * r5.w;
      r10.x = 3.14159274 * r4.w;
      r4.w = r10.x * r4.w;
      r4.w = r4.w * r5.w;
      r4.w = r2.z / r4.w;
      r5.w = 1 + -r8.w;
      r10.x = r5.w * r5.w;
      r10.x = r10.x * r10.x;
      r5.w = r10.x * r5.w;
      r10.x = r6.w * r6.w;
      r10.x = dot(r10.xx, r2.yy);
      r10.x = -0.5 + r10.x;
      r5.w = r10.x * r5.w + 1;
      r10.x = r10.x * r2.w + 1;
      r5.w = r10.x * r5.w;
      r4.w = r7.w * r4.w;
      r4.w = 0.785398185 * r4.w;
      r4.w = r4.w * r8.w;
      r4.w = max(0, r4.w);
      r5.w = r5.w * r8.w;
      r11.xyz = r9.xyw * r5.www;
      r9.xyw = r4.www * r9.xyw;
      r4.w = 1 + -r6.w;
      r5.w = r4.w * r4.w;
      r5.w = r5.w * r5.w;
      r4.w = r5.w * r4.w;
      r12.xyz = r10.yzw * r4.www + r4.xyz;
      r9.xyw = r12.xyz * r9.xyw;
      r9.xyw = r1.yzw * r11.xyz + r9.xyw;
      r8.xyz = r9.xyw + r8.xyz;
      r3.w = (int)r3.w + 1;
    }
    r0.xyz = float3(8,8,8) * r8.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 512d5af8744d2bbf: 2 retail keyword combination(s)
void ps_512d5af8744d2bbf_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r1.yzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyz;
    r2.xyz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xzw;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xyz = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r1.yzw;
    r4.xyz = r2.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r0.w = -r2.x * 0.959999979 + 0.959999979;
    r1.yzw = r1.yzw * r0.www;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r0.w = dot(r3.xyz, r3.xyz);
    r0.w = rsqrt(r0.w);
    r3.xyz = r3.xyz * r0.www;
    r5.z = 1 + -r1.x;
    r5.xy = v0.zw;
    r5.xyz = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r5.yyyy;
    r6.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r5.xxxx + r6.xyzw;
    r5.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r5.zzzz + r6.xyzw;
    r5.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r5.xyzw;
    r5.xyz = r5.xyz / r5.www;
    r6.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r5.yyyy;
    r6.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r5.xxxx + r6.xyzw;
    r5.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r5.zzzz + r6.xyzw;
    r5.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r5.xyzw;
    r6.xyz = -_WorldSpaceCameraPos.xyz + r5.xyz;
    r0.w = dot(r6.xyz, r6.xyz);
    r0.w = rsqrt(r0.w);
    r6.xyz = r6.xyz * r0.www;
    r0.w = dot(r3.xyz, -r6.xyz);
    r1.x = saturate(r0.w);
    r0.y = (int)r0.y + (int)r0.x;
    r2.x = cmp(r3.w == 0.666666687);
    r2.y = 1 + -r2.y;
    r2.w = r2.y * r2.y;
    r3.w = cmp(r0.w < 0);
    r0.w = 9.99999975e-006 + -r0.w;
    r7.xyz = -r6.xyz * r0.www + r3.xyz;
    r7.xyz = r3.www ? r7.xyz : r3.xyz;
    r0.w = -r2.y * r2.y + 1;
    r2.y = r1.x * r0.w + r2.w;
    r3.w = r2.w * r2.w;
    r4.w = 0.318309873 * r3.w;
    r6.w = 0.5 * r2.w;
    r7.w = r2.w * -0.337748349 + 1;
    r8.x = 1 + -r1.x;
    r8.y = r8.x * r8.x;
    r8.y = r8.y * r8.y;
    r8.x = r8.y * r8.x;
    r8.yzw = float3(1,1,1) + -r4.xyz;
    r9.yzw = float3(0,0,0);
    r10.xyz = float3(0,0,0);
    r10.w = r0.x;
    [loop] while (true) {
      r11.x = cmp((int)r10.w >= (int)r0.y);
      [branch] if (r11.x != 0) break;
      r11.x = _BT_LinkListBuffer[r10.w].val[0/4];
      r12.x = _BT_LightBuffer[r11.x].val[0/4];
      r12.y = _BT_LightBuffer[r11.x].val[0/4+1];
      r12.z = _BT_LightBuffer[r11.x].val[0/4+2];
      r12.w = _BT_LightBuffer[r11.x].val[0/4+3];
      r11.y = _BT_LightBuffer[r11.x].val[32/4];
      r12.xyz = -r12.xyz + r5.xyz;
      r11.z = dot(r12.xyz, r12.xyz);
      r11.w = r12.w * r12.w;
      r13.x = max(0.100000001, r11.z);
      r11.w = r13.x / r11.w;
      r11.w = -r11.w * r11.w + 1;
      r11.w = max(0, r11.w);
      r11.w = r11.w * r11.w;
      r11.y = r12.w * r11.y + r13.x;
      r11.y = 1 / r11.y;
      r11.y = r11.y * r11.w;
      r11.w = cmp(r11.y != 0.000000);
      [branch] if (r11.w != 0) {
        r13.x = _BT_LightBuffer[r11.x].val[16/4];
        r13.y = _BT_LightBuffer[r11.x].val[16/4+1];
        r13.z = _BT_LightBuffer[r11.x].val[16/4+2];
        r11.x = _BT_LightBuffer[r11.x].val[60/4];
        r11.z = rsqrt(r11.z);
        r14.xyz = r12.xyz * r11.zzz;
        r13.xyz = r13.xyz * r11.yyy;
        r11.y = dot(r3.xyz, -r14.xyz);
        r9.x = max(0, r11.y);
        r11.y = 0.800000012 + r11.y;
        r11.y = saturate(0.555555582 * r11.y);
        r11.y = r11.y * r11.y;
        r11.y = r11.y * r11.y;
        r11.y = r11.y * 1.38888896 + -r9.x;
        r15.x = r2.z * r11.y + r9.x;
        r11.y = saturate(dot(r3.xyz, r14.xyz));
        r16.xyz = r11.yyy * r1.yzw;
        r16.xyz = r16.xyz * r13.xyz;
        r16.xyz = r16.xyz * r2.zzz;
        r15.yzw = float3(0.25,0.25,0.25) * r16.xyz;
        r15.xyzw = r2.xxxx ? r15.xyzw : r9.xyzw;
        r9.x = cmp(0 != r11.x);
        r11.xyz = -r12.xyz * r11.zzz + -r6.xyz;
        r11.w = dot(r11.xyz, r11.xyz);
        r11.w = max(0.00100000005, r11.w);
        r11.w = rsqrt(r11.w);
        r11.xyz = r11.xyz * r11.www;
        r11.w = dot(r7.xyz, r11.xyz);
        r11.x = dot(-r14.xyz, r11.xyz);
        r11.xw = max(float2(0,0), r11.xw);
        r11.y = r15.x * r0.w + r2.w;
        r11.y = r11.y * r1.x;
        r11.y = r15.x * r2.y + r11.y;
        r11.y = 9.99999975e-006 + r11.y;
        r11.y = 0.5 / r11.y;
        r11.z = r11.w * r3.w + -r11.w;
        r11.z = r11.z * r11.w + 1;
        r11.z = r11.z * r11.z + 1.00000001e-007;
        r11.z = r4.w / r11.z;
        r11.w = 1 + -r15.x;
        r12.x = r11.w * r11.w;
        r12.x = r12.x * r12.x;
        r11.w = r12.x * r11.w;
        r12.x = r11.x + r11.x;
        r12.x = r12.x * r11.x;
        r12.x = r12.x * r2.w + r6.w;
        r12.x = -1 + r12.x;
        r11.w = r12.x * r11.w + 1;
        r12.x = r12.x * r8.x + 1;
        r11.w = r12.x * r11.w;
        r11.w = r11.w * r7.w;
        r11.y = r11.y * r11.z;
        r11.y = 3.14159274 * r11.y;
        r11.yz = r11.yw * r15.xx;
        r11.y = max(0, r11.y);
        r12.xyz = r13.xyz * r11.zzz;
        r11.yzw = r11.yyy * r13.xyz;
        r11.x = 1 + -r11.x;
        r12.w = r11.x * r11.x;
        r12.w = r12.w * r12.w;
        r11.x = r12.w * r11.x;
        r13.xyz = r8.yzw * r11.xxx + r4.xyz;
        r11.xyz = r13.xyz * r11.yzw;
        r9.x = r9.x ? 1.000000 : 0;
        r11.xyz = r11.xyz * r9.xxx;
        r11.xyz = r1.yzw * r12.xyz + r11.xyz;
        r11.xyz = r15.yzw + r11.xyz;
      } else {
        r11.xyz = float3(0,0,0);
      }
      r10.xyz = r11.xyz + r10.xyz;
      r10.w = (int)r10.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r9.yzw = float3(0,0,0);
    r11.xyz = r10.xyz;
    r0.y = r10.w;
    [loop] while (true) {
      r0.z = cmp((int)r0.y >= (int)r0.x);
      [branch] if (r0.z != 0) break;
      r0.z = _BT_LinkListBuffer[r0.y].val[0/4];
      r12.x = _BT_LightBuffer[r0.z].val[0/4];
      r12.y = _BT_LightBuffer[r0.z].val[0/4+1];
      r12.z = _BT_LightBuffer[r0.z].val[0/4+2];
      r12.w = _BT_LightBuffer[r0.z].val[0/4+3];
      r11.w = _BT_LightBuffer[r0.z].val[32/4];
      r13.x = _BT_LightBuffer[r0.z].val[48/4];
      r13.y = _BT_LightBuffer[r0.z].val[48/4+1];
      r13.z = (uint)r0.z << 2;
      r11.w = frac(r11.w);
      r12.xyz = -r12.xyz + r5.xyz;
      r13.w = dot(r12.xyz, r12.xyz);
      r14.x = r12.w * r12.w;
      r15.xyzw = float4(_BT_LightMatrix[(uint)(r13.z) / 4u][0][1], _BT_LightMatrix[(uint)(r13.z) / 4u][1][1], _BT_LightMatrix[(uint)(r13.z) / 4u][2][1], _BT_LightMatrix[(uint)(r13.z) / 4u][3][1]) * r5.yyyy;
      r15.xyzw = float4(_BT_LightMatrix[(uint)(r13.z) / 4u][0][0], _BT_LightMatrix[(uint)(r13.z) / 4u][1][0], _BT_LightMatrix[(uint)(r13.z) / 4u][2][0], _BT_LightMatrix[(uint)(r13.z) / 4u][3][0]) * r5.xxxx + r15.xyzw;
      r15.xyzw = float4(_BT_LightMatrix[(uint)(r13.z) / 4u][0][2], _BT_LightMatrix[(uint)(r13.z) / 4u][1][2], _BT_LightMatrix[(uint)(r13.z) / 4u][2][2], _BT_LightMatrix[(uint)(r13.z) / 4u][3][2]) * r5.zzzz + r15.xyzw;
      r15.xyzw = float4(_BT_LightMatrix[(uint)(r13.z) / 4u][0][3], _BT_LightMatrix[(uint)(r13.z) / 4u][1][3], _BT_LightMatrix[(uint)(r13.z) / 4u][2][3], _BT_LightMatrix[(uint)(r13.z) / 4u][3][3]) * r5.wwww + r15.xyzw;
      r13.z = max(0.100000001, r13.w);
      r14.x = r13.z / r14.x;
      r14.x = -r14.x * r14.x + 1;
      r14.x = max(0, r14.x);
      r14.x = r14.x * r14.x;
      r11.w = r12.w * r11.w + r13.z;
      r11.w = 1 / r11.w;
      r11.w = r11.w * r14.x;
      r14.xyz = r15.xyz / r15.www;
      r12.w = cmp(0 >= r14.z);
      r14.zw = cmp(float2(1,1) < r14.xy);
      r12.w = (int)r12.w | (int)r14.z;
      r15.xy = cmp(r14.xy < float2(-1,-1));
      r12.w = (int)r12.w | (int)r15.x;
      r12.w = (int)r14.w | (int)r12.w;
      r12.w = (int)r15.y | (int)r12.w;
      r13.x = r13.x / r13.y;
      r13.x = min(0.99000001, r13.x);
      r13.y = dot(r14.xy, r14.xy);
      r13.y = sqrt(r13.y);
      r13.y = min(1, r13.y);
      r13.xy = float2(-1,-1) + r13.xy;
      r13.x = 1 / r13.x;
      r13.x = r13.y * r13.x;
      r13.x = min(1, r13.x);
      r13.y = r13.x * -2 + 3;
      r13.x = r13.x * r13.x;
      r13.x = r13.y * r13.x;
      r13.y = cmp(r13.x != 0.000000);
      r13.x = r13.y ? r13.x : 0;
      r12.w = r12.w ? 0 : r13.x;
      r11.w = r12.w * r11.w;
      r12.w = cmp(r11.w != 0.000000);
      [branch] if (r12.w != 0) {
        r13.x = _BT_LightBuffer[r0.z].val[16/4];
        r13.y = _BT_LightBuffer[r0.z].val[16/4+1];
        r13.z = _BT_LightBuffer[r0.z].val[16/4+2];
        r0.z = _BT_LightBuffer[r0.z].val[60/4];
        r12.w = rsqrt(r13.w);
        r14.xyz = r12.xyz * r12.www;
        r13.xyz = r13.xyz * r11.www;
        r11.w = dot(r3.xyz, -r14.xyz);
        r9.x = max(0, r11.w);
        r11.w = 0.800000012 + r11.w;
        r11.w = saturate(0.555555582 * r11.w);
        r11.w = r11.w * r11.w;
        r11.w = r11.w * r11.w;
        r11.w = r11.w * 1.38888896 + -r9.x;
        r15.x = r2.z * r11.w + r9.x;
        r11.w = saturate(dot(r3.xyz, r14.xyz));
        r16.xyz = r11.www * r1.yzw;
        r16.xyz = r16.xyz * r13.xyz;
        r16.xyz = r16.xyz * r2.zzz;
        r15.yzw = float3(0.25,0.25,0.25) * r16.xyz;
        r15.xyzw = r2.xxxx ? r15.xyzw : r9.xyzw;
        r0.z = cmp(0 != r0.z);
        r12.xyz = -r12.xyz * r12.www + -r6.xyz;
        r9.x = dot(r12.xyz, r12.xyz);
        r9.x = max(0.00100000005, r9.x);
        r9.x = rsqrt(r9.x);
        r12.xyz = r12.xyz * r9.xxx;
        r9.x = dot(r7.xyz, r12.xyz);
        r9.x = max(0, r9.x);
        r11.w = dot(-r14.xyz, r12.xyz);
        r11.w = max(0, r11.w);
        r12.x = r15.x * r0.w + r2.w;
        r12.x = r12.x * r1.x;
        r12.x = r15.x * r2.y + r12.x;
        r12.x = 9.99999975e-006 + r12.x;
        r12.x = 0.5 / r12.x;
        r12.y = r9.x * r3.w + -r9.x;
        r9.x = r12.y * r9.x + 1;
        r9.x = r9.x * r9.x + 1.00000001e-007;
        r9.x = r4.w / r9.x;
        r12.y = 1 + -r15.x;
        r12.z = r12.y * r12.y;
        r12.z = r12.z * r12.z;
        r12.y = r12.z * r12.y;
        r12.z = r11.w + r11.w;
        r12.z = r12.z * r11.w;
        r12.z = r12.z * r2.w + r6.w;
        r12.z = -1 + r12.z;
        r12.y = r12.z * r12.y + 1;
        r12.z = r12.z * r8.x + 1;
        r12.y = r12.y * r12.z;
        r12.y = r12.y * r7.w;
        r9.x = r12.x * r9.x;
        r9.x = 3.14159274 * r9.x;
        r9.x = r9.x * r15.x;
        r9.x = max(0, r9.x);
        r12.x = r12.y * r15.x;
        r12.xyz = r13.xyz * r12.xxx;
        r13.xyz = r9.xxx * r13.xyz;
        r9.x = 1 + -r11.w;
        r11.w = r9.x * r9.x;
        r11.w = r11.w * r11.w;
        r9.x = r11.w * r9.x;
        r14.xyz = r8.yzw * r9.xxx + r4.xyz;
        r13.xyz = r14.xyz * r13.xyz;
        r0.z = r0.z ? 1.000000 : 0;
        r13.xyz = r13.xyz * r0.zzz;
        r12.xyz = r1.yzw * r12.xyz + r13.xyz;
        r12.xyz = r15.yzw + r12.xyz;
      } else {
        r12.xyz = float3(0,0,0);
      }
      r11.xyz = r12.xyz + r11.xyz;
      r0.y = (int)r0.y + 1;
    }
    r0.xyz = float3(8,8,8) * r11.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 5ce00b55e3b3e68b: 1 retail keyword combination(s)
void ps_5ce00b55e3b3e68b_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyzw = _BT_ListEntries.Load(r0.xywz).xyzw;
  r1.y = cmp((int)r0.x >= 0);
  [branch] if (r1.y != 0) {
    r1.yzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyz;
    r2.xy = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyz = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyz;
    r4.xyz = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r1.yzw;
    r4.xyz = r2.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r2.x = -r2.x * 0.959999979 + 0.959999979;
    r1.yzw = r2.xxx * r1.yzw;
    r2.xzw = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r3.x = dot(r2.xzw, r2.xzw);
    r3.x = rsqrt(r3.x);
    r2.xzw = r3.xxx * r2.xzw;
    r3.z = 1 + -r1.x;
    r3.xy = v0.zw;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r5.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r3.yyyy;
    r5.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r3.xxxx + r5.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r3.zzzz + r5.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r3.xyzw;
    r3.xyz = r3.xyz / r3.www;
    r5.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r3.yyyy;
    r5.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r3.xxxx + r5.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r3.zzzz + r5.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r3.xyzw;
    r5.xyz = -_WorldSpaceCameraPos.xyz + r3.xyz;
    r1.x = dot(r5.xyz, r5.xyz);
    r1.x = rsqrt(r1.x);
    r6.xyz = r5.xyz * r1.xxx;
    r4.w = dot(r2.xzw, -r6.xyz);
    r5.w = max(0, r4.w);
    r6.w = min(1, r5.w);
    r0.y = (int)r0.y + (int)r0.x;
    r2.y = 1 + -r2.y;
    r7.x = r2.y * r2.y;
    r7.y = cmp(r4.w < 0);
    r7.z = 9.99999975e-006 + -r4.w;
    r8.xyz = -r6.xyz * r7.zzz + r2.xzw;
    r7.yzw = r7.yyy ? r8.xyz : r2.xzw;
    r8.x = -r2.y * r2.y + 1;
    r8.y = r6.w * r8.x + r7.x;
    r8.z = r7.x * r7.x;
    r8.w = 0.318309873 * r8.z;
    r9.x = 0.5 * r7.x;
    r9.y = r7.x * -0.337748349 + 1;
    r9.z = 1 + -r6.w;
    r9.w = r9.z * r9.z;
    r9.w = r9.w * r9.w;
    r9.z = r9.w * r9.z;
    r10.xyz = float3(1,1,1) + -r4.xyz;
    r11.xyz = float3(0,0,0);
    r9.w = r0.x;
    [loop] while (true) {
      r10.w = cmp((int)r9.w >= (int)r0.y);
      [branch] if (r10.w != 0) break;
      r10.w = _BT_LinkListBuffer[r9.w].val[0/4];
      r12.x = _BT_LightBuffer[r10.w].val[0/4];
      r12.y = _BT_LightBuffer[r10.w].val[0/4+1];
      r12.z = _BT_LightBuffer[r10.w].val[0/4+2];
      r12.w = _BT_LightBuffer[r10.w].val[0/4+3];
      r11.w = _BT_LightBuffer[r10.w].val[32/4];
      r12.xyz = -r12.xyz + r3.xyz;
      r13.x = dot(r12.xyz, r12.xyz);
      r13.y = r12.w * r12.w;
      r13.z = max(0.100000001, r13.x);
      r13.y = r13.z / r13.y;
      r13.y = -r13.y * r13.y + 1;
      r13.y = max(0, r13.y);
      r13.y = r13.y * r13.y;
      r11.w = r12.w * r11.w + r13.z;
      r11.w = 1 / r11.w;
      r11.w = r11.w * r13.y;
      r12.w = cmp(r11.w != 0.000000);
      [branch] if (r12.w != 0) {
        r13.y = _BT_LightBuffer[r10.w].val[16/4];
        r13.z = _BT_LightBuffer[r10.w].val[16/4+1];
        r13.w = _BT_LightBuffer[r10.w].val[16/4+2];
        r10.w = _BT_LightBuffer[r10.w].val[60/4];
        r12.w = rsqrt(r13.x);
        r14.xyz = r12.xyz * r12.www;
        r13.xyz = r13.yzw * r11.www;
        r11.w = dot(r2.xzw, -r14.xyz);
        r11.w = max(0, r11.w);
        r10.w = cmp(r10.w >= 0);
        r12.xyz = -r12.xyz * r12.www + -r6.xyz;
        r12.w = dot(r12.xyz, r12.xyz);
        r12.w = max(0.00100000005, r12.w);
        r12.w = rsqrt(r12.w);
        r12.xyz = r12.xyz * r12.www;
        r12.w = dot(r7.yzw, r12.xyz);
        r12.x = dot(-r14.xyz, r12.xyz);
        r12.xw = max(float2(0,0), r12.xw);
        r12.y = r11.w * r8.x + r7.x;
        r12.y = r12.y * r6.w;
        r12.y = r11.w * r8.y + r12.y;
        r12.y = 9.99999975e-006 + r12.y;
        r12.y = 0.5 / r12.y;
        r12.z = r12.w * r8.z + -r12.w;
        r12.z = r12.z * r12.w + 1;
        r12.z = r12.z * r12.z + 1.00000001e-007;
        r12.z = r8.w / r12.z;
        r12.w = 1 + -r11.w;
        r13.w = r12.w * r12.w;
        r13.w = r13.w * r13.w;
        r12.w = r13.w * r12.w;
        r13.w = r12.x + r12.x;
        r13.w = r13.w * r12.x;
        r13.w = r13.w * r7.x + r9.x;
        r13.w = -1 + r13.w;
        r12.w = r13.w * r12.w + 1;
        r13.w = r13.w * r9.z + 1;
        r12.w = r13.w * r12.w;
        r12.w = r12.w * r9.y;
        r12.y = r12.y * r12.z;
        r12.y = r12.y * r11.w;
        r12.y = 3.14159274 * r12.y;
        r12.y = max(0, r12.y);
        r11.w = r12.w * r11.w;
        r14.xyz = r13.xyz * r11.www;
        r12.yzw = r12.yyy * r13.xyz;
        r11.w = 1 + -r12.x;
        r12.x = r11.w * r11.w;
        r12.x = r12.x * r12.x;
        r11.w = r12.x * r11.w;
        r13.xyz = r10.xyz * r11.www + r4.xyz;
        r12.xyz = r13.xyz * r12.yzw;
        r10.w = r10.w ? 1.000000 : 0;
        r12.xyz = r12.xyz * r10.www;
        r12.xyz = r1.yzw * r14.xyz + r12.xyz;
      } else {
        r12.xyz = float3(0,0,0);
      }
      r11.xyz = r12.xyz + r11.xyz;
      r9.w = (int)r9.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r12.xyz = r11.xyz;
    r0.y = r9.w;
    [loop] while (true) {
      r0.z = cmp((int)r0.y >= (int)r0.x);
      [branch] if (r0.z != 0) break;
      r0.z = _BT_LinkListBuffer[r0.y].val[0/4];
      r13.x = _BT_LightBuffer[r0.z].val[0/4];
      r13.y = _BT_LightBuffer[r0.z].val[0/4+1];
      r13.z = _BT_LightBuffer[r0.z].val[0/4+2];
      r13.w = _BT_LightBuffer[r0.z].val[0/4+3];
      r10.w = _BT_LightBuffer[r0.z].val[32/4];
      r14.x = _BT_LightBuffer[r0.z].val[48/4];
      r14.y = _BT_LightBuffer[r0.z].val[48/4+1];
      r11.w = (uint)r0.z << 2;
      r10.w = frac(r10.w);
      r13.xyz = -r13.xyz + r3.xyz;
      r12.w = dot(r13.xyz, r13.xyz);
      r14.z = r13.w * r13.w;
      r15.xyzw = float4(_BT_LightMatrix[(uint)(r11.w) / 4u][0][1], _BT_LightMatrix[(uint)(r11.w) / 4u][1][1], _BT_LightMatrix[(uint)(r11.w) / 4u][2][1], _BT_LightMatrix[(uint)(r11.w) / 4u][3][1]) * r3.yyyy;
      r15.xyzw = float4(_BT_LightMatrix[(uint)(r11.w) / 4u][0][0], _BT_LightMatrix[(uint)(r11.w) / 4u][1][0], _BT_LightMatrix[(uint)(r11.w) / 4u][2][0], _BT_LightMatrix[(uint)(r11.w) / 4u][3][0]) * r3.xxxx + r15.xyzw;
      r15.xyzw = float4(_BT_LightMatrix[(uint)(r11.w) / 4u][0][2], _BT_LightMatrix[(uint)(r11.w) / 4u][1][2], _BT_LightMatrix[(uint)(r11.w) / 4u][2][2], _BT_LightMatrix[(uint)(r11.w) / 4u][3][2]) * r3.zzzz + r15.xyzw;
      r15.xyzw = float4(_BT_LightMatrix[(uint)(r11.w) / 4u][0][3], _BT_LightMatrix[(uint)(r11.w) / 4u][1][3], _BT_LightMatrix[(uint)(r11.w) / 4u][2][3], _BT_LightMatrix[(uint)(r11.w) / 4u][3][3]) * r3.wwww + r15.xyzw;
      r11.w = max(0.100000001, r12.w);
      r14.z = r11.w / r14.z;
      r14.z = -r14.z * r14.z + 1;
      r14.z = max(0, r14.z);
      r14.z = r14.z * r14.z;
      r10.w = r13.w * r10.w + r11.w;
      r10.w = 1 / r10.w;
      r10.w = r10.w * r14.z;
      r15.xyz = r15.xyz / r15.www;
      r11.w = cmp(0 >= r15.z);
      r14.zw = cmp(float2(1,1) < r15.xy);
      r11.w = (int)r11.w | (int)r14.z;
      r15.zw = cmp(r15.xy < float2(-1,-1));
      r11.w = (int)r11.w | (int)r15.z;
      r11.w = (int)r14.w | (int)r11.w;
      r11.w = (int)r15.w | (int)r11.w;
      r13.w = r14.x / r14.y;
      r13.w = min(0.99000001, r13.w);
      r14.x = dot(r15.xy, r15.xy);
      r14.x = sqrt(r14.x);
      r14.x = min(1, r14.x);
      r13.w = -1 + r13.w;
      r14.x = -1 + r14.x;
      r13.w = 1 / r13.w;
      r13.w = r14.x * r13.w;
      r13.w = min(1, r13.w);
      r14.x = r13.w * -2 + 3;
      r13.w = r13.w * r13.w;
      r13.w = r14.x * r13.w;
      r14.x = cmp(r13.w != 0.000000);
      r13.w = r14.x ? r13.w : 0;
      r11.w = r11.w ? 0 : r13.w;
      r10.w = r11.w * r10.w;
      r11.w = cmp(r10.w != 0.000000);
      [branch] if (r11.w != 0) {
        r14.x = _BT_LightBuffer[r0.z].val[16/4];
        r14.y = _BT_LightBuffer[r0.z].val[16/4+1];
        r14.z = _BT_LightBuffer[r0.z].val[16/4+2];
        r0.z = _BT_LightBuffer[r0.z].val[60/4];
        r11.w = rsqrt(r12.w);
        r15.xyz = r13.xyz * r11.www;
        r14.xyz = r14.xyz * r10.www;
        r10.w = dot(r2.xzw, -r15.xyz);
        r10.w = max(0, r10.w);
        r0.z = cmp(r0.z >= 0);
        r13.xyz = -r13.xyz * r11.www + -r6.xyz;
        r11.w = dot(r13.xyz, r13.xyz);
        r11.w = max(0.00100000005, r11.w);
        r11.w = rsqrt(r11.w);
        r13.xyz = r13.xyz * r11.www;
        r11.w = dot(r7.yzw, r13.xyz);
        r11.w = max(0, r11.w);
        r12.w = dot(-r15.xyz, r13.xyz);
        r12.w = max(0, r12.w);
        r13.x = r10.w * r8.x + r7.x;
        r13.x = r13.x * r6.w;
        r13.x = r10.w * r8.y + r13.x;
        r13.x = 9.99999975e-006 + r13.x;
        r13.x = 0.5 / r13.x;
        r13.y = r11.w * r8.z + -r11.w;
        r11.w = r13.y * r11.w + 1;
        r11.w = r11.w * r11.w + 1.00000001e-007;
        r11.w = r8.w / r11.w;
        r13.y = 1 + -r10.w;
        r13.z = r13.y * r13.y;
        r13.z = r13.z * r13.z;
        r13.y = r13.z * r13.y;
        r13.z = r12.w + r12.w;
        r13.z = r13.z * r12.w;
        r13.z = r13.z * r7.x + r9.x;
        r13.z = -1 + r13.z;
        r13.y = r13.z * r13.y + 1;
        r13.z = r13.z * r9.z + 1;
        r13.y = r13.y * r13.z;
        r13.y = r13.y * r9.y;
        r11.w = r13.x * r11.w;
        r11.w = r11.w * r10.w;
        r11.w = 3.14159274 * r11.w;
        r11.w = max(0, r11.w);
        r10.w = r13.y * r10.w;
        r13.xyz = r14.xyz * r10.www;
        r14.xyz = r11.www * r14.xyz;
        r10.w = 1 + -r12.w;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r15.xyz = r10.xyz * r10.www + r4.xyz;
        r14.xyz = r15.xyz * r14.xyz;
        r0.z = r0.z ? 1.000000 : 0;
        r14.xyz = r14.xyz * r0.zzz;
        r13.xyz = r1.yzw * r13.xyz + r14.xyz;
      } else {
        r13.xyz = float3(0,0,0);
      }
      r12.xyz = r13.xyz + r12.xyz;
      r0.y = (int)r0.y + 1;
    }
    r0.x = (int)r0.w + (int)r0.x;
    r1.yzw = float3(25,25,25) * r1.yzw;
    r0.z = r4.w + r4.w;
    r6.xyz = r2.xzw * -r0.zzz + -r6.xyz;
    r0.z = -r7.x * 0.5 + 1;
    r0.w = r5.w * r0.z + r9.x;
    r3.w = r7.x * r7.x + -1;
    r4.w = r8.z * r8.z;
    r5.w = 1 + -r5.w;
    r6.w = r5.w * r5.w;
    r6.w = r6.w * r6.w;
    r5.w = r6.w * r5.w;
    r7.xyz = r12.xyz;
    r6.w = r0.y;
    [loop] while (true) {
      r7.w = cmp((int)r6.w >= (int)r0.x);
      [branch] if (r7.w != 0) break;
      r7.w = _BT_LinkListBuffer[r6.w].val[0/4];
      r8.x = _BT_LightBuffer[r7.w].val[0/4];
      r8.y = _BT_LightBuffer[r7.w].val[0/4+1];
      r8.z = _BT_LightBuffer[r7.w].val[0/4+2];
      r8.w = _BT_LightBuffer[r7.w].val[0/4+3];
      r9.y = _BT_LightBuffer[r7.w].val[16/4];
      r9.z = _BT_LightBuffer[r7.w].val[16/4+1];
      r9.w = _BT_LightBuffer[r7.w].val[16/4+2];
      r10.w = _BT_LightBuffer[r7.w].val[32/4];
      r11.x = _BT_LightBuffer[r7.w].val[48/4];
      r11.y = _BT_LightBuffer[r7.w].val[48/4+1];
      r11.z = _BT_LightBuffer[r7.w].val[48/4+2];
      r7.w = r8.w * r8.w;
      r7.w = 1 / r7.w;
      r11.xyz = r11.xyz * r10.www + r8.xyz;
      r8.xyz = r8.xyz + -r3.xyz;
      r11.xyz = r11.xyz + -r3.xyz;
      r8.w = dot(r8.xyz, r8.xyz);
      r10.w = sqrt(r8.w);
      r11.w = dot(r11.xyz, r11.xyz);
      r11.w = sqrt(r11.w);
      r12.w = dot(r8.xyz, r2.xzw);
      r13.x = r10.w + r10.w;
      r12.w = r12.w / r13.x;
      r13.x = dot(r11.xyz, r2.xzw);
      r13.y = r11.w + r11.w;
      r13.x = r13.x / r13.y;
      r12.w = saturate(r13.x + r12.w);
      r13.xyz = r11.xyz + -r8.xyz;
      r13.w = dot(r6.xyz, r8.xyz);
      r14.x = dot(r6.xyz, r13.xyz);
      r14.y = dot(r8.xyz, r13.xyz);
      r14.z = dot(r13.xyz, r13.xyz);
      r8.w = r14.x * r8.w;
      r8.w = r14.y * r13.w + -r8.w;
      r13.w = r14.z * r13.w;
      r13.w = r14.y * r14.x + -r13.w;
      r8.w = saturate(r8.w / r13.w);
      r14.xyz = r13.yzx * r8.zxy;
      r14.xyz = r8.yzx * r13.zxy + -r14.xyz;
      r15.xyz = r13.zxy * r6.yzx;
      r15.xyz = r13.yzx * r6.zxy + -r15.xyz;
      r13.w = dot(r14.xyz, r15.xyz);
      r14.x = 1 + -r8.w;
      r13.w = cmp(r13.w >= 0);
      r13.w = r13.w ? 1.000000 : 0;
      r8.w = -r14.x + r8.w;
      r8.w = r13.w * r8.w + r14.x;
      r13.xyz = r13.xyz * r8.www + r8.xyz;
      r8.w = dot(r13.xyz, r6.xyz);
      r14.xyz = r8.www * r6.xyz + -r13.xyz;
      r8.w = dot(r14.xyz, r14.xyz);
      r8.w = sqrt(r8.w);
      r8.w = 0.100000001 / r8.w;
      r8.w = min(1, r8.w);
      r13.xyz = r14.xyz * r8.www + r13.xyz;
      r8.w = dot(r13.xyz, r13.xyz);
      r8.w = sqrt(r8.w);
      r13.xyz = r13.xyz / r8.www;
      r8.x = dot(r8.xyz, r11.xyz);
      r8.x = r10.w * r11.w + r8.x;
      r8.x = 0.5 * r8.x;
      r7.w = r8.x * r7.w;
      r7.w = sqrt(r7.w);
      r8.x = r7.w * 4 + 1;
      r8.x = r8.x * r8.x;
      r8.x = 1 / r8.x;
      r8.x = -0.0399999991 + r8.x;
      r8.x = 1.04166675 * r8.x;
      r7.w = cmp(r7.w >= 1);
      r7.w = r7.w ? 0 : r8.x;
      r8.xyz = r9.yzw * r7.www;
      r9.yzw = -r5.xyz * r1.xxx + r13.xyz;
      r7.w = dot(r9.yzw, r9.yzw);
      r7.w = max(0.00100000005, r7.w);
      r7.w = rsqrt(r7.w);
      r9.yzw = r9.yzw * r7.www;
      r7.w = dot(r2.xzw, r9.yzw);
      r7.w = max(0, r7.w);
      r9.y = dot(r13.xyz, r9.yzw);
      r9.y = max(0, r9.y);
      r9.z = r12.w * r0.z + r9.x;
      r9.z = r9.z * r0.w + 9.99999975e-006;
      r9.z = 1 / r9.z;
      r7.w = r7.w * r7.w;
      r7.w = r7.w * r3.w + 1;
      r7.w = max(9.99999997e-007, r7.w);
      r8.w = r8.w + r8.w;
      r8.w = 0.100000001 / r8.w;
      r8.w = r2.y * r2.y + r8.w;
      r8.w = min(1, r8.w);
      r8.w = r8.w * r8.w;
      r9.w = 3.14159274 * r7.w;
      r7.w = r9.w * r7.w;
      r7.w = r7.w * r8.w;
      r7.w = r4.w / r7.w;
      r8.w = 1 + -r12.w;
      r9.w = r8.w * r8.w;
      r9.w = r9.w * r9.w;
      r8.w = r9.w * r8.w;
      r9.w = r9.y * r9.y;
      r9.w = dot(r9.ww, r2.yy);
      r9.w = -0.5 + r9.w;
      r8.w = r9.w * r8.w + 1;
      r9.w = r9.w * r5.w + 1;
      r8.w = r9.w * r8.w;
      r7.w = r9.z * r7.w;
      r7.w = 0.785398185 * r7.w;
      r7.w = r7.w * r12.w;
      r7.w = max(0, r7.w);
      r8.w = r8.w * r12.w;
      r11.xyz = r8.xyz * r8.www;
      r8.xyz = r7.www * r8.xyz;
      r7.w = 1 + -r9.y;
      r8.w = r7.w * r7.w;
      r8.w = r8.w * r8.w;
      r7.w = r8.w * r7.w;
      r9.yzw = r10.xyz * r7.www + r4.xyz;
      r8.xyz = r9.yzw * r8.xyz;
      r8.xyz = r1.yzw * r11.xyz + r8.xyz;
      r7.xyz = r8.xyz + r7.xyz;
      r6.w = (int)r6.w + 1;
    }
    r0.xyz = float3(8,8,8) * r7.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 2886cad062b81550: 2 retail keyword combination(s)
void ps_2886cad062b81550_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r1.yzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyz;
    r2.xy = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyz = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyz;
    r4.xyz = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r1.yzw;
    r4.xyz = r2.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r0.w = -r2.x * 0.959999979 + 0.959999979;
    r1.yzw = r1.yzw * r0.www;
    r2.xzw = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r0.w = dot(r2.xzw, r2.xzw);
    r0.w = rsqrt(r0.w);
    r2.xzw = r2.xzw * r0.www;
    r3.z = 1 + -r1.x;
    r3.xy = v0.zw;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r5.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r3.yyyy;
    r5.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r3.xxxx + r5.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r3.zzzz + r5.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r3.xyzw;
    r3.xyz = r3.xyz / r3.www;
    r5.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r3.yyyy;
    r5.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r3.xxxx + r5.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r3.zzzz + r5.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r3.xyzw;
    r5.xyz = -_WorldSpaceCameraPos.xyz + r3.xyz;
    r0.w = dot(r5.xyz, r5.xyz);
    r0.w = rsqrt(r0.w);
    r5.xyz = r5.xyz * r0.www;
    r0.w = dot(r2.xzw, -r5.xyz);
    r1.x = saturate(r0.w);
    r0.y = (int)r0.y + (int)r0.x;
    r2.y = 1 + -r2.y;
    r4.w = r2.y * r2.y;
    r5.w = cmp(r0.w < 0);
    r0.w = 9.99999975e-006 + -r0.w;
    r6.xyz = -r5.xyz * r0.www + r2.xzw;
    r6.xyz = r5.www ? r6.xyz : r2.xzw;
    r0.w = -r2.y * r2.y + 1;
    r2.y = r1.x * r0.w + r4.w;
    r5.w = r4.w * r4.w;
    r6.w = 0.318309873 * r5.w;
    r7.x = 0.5 * r4.w;
    r7.y = r4.w * -0.337748349 + 1;
    r7.z = 1 + -r1.x;
    r7.w = r7.z * r7.z;
    r7.w = r7.w * r7.w;
    r7.z = r7.w * r7.z;
    r8.xyz = float3(1,1,1) + -r4.xyz;
    r9.xyz = float3(0,0,0);
    r7.w = r0.x;
    [loop] while (true) {
      r8.w = cmp((int)r7.w >= (int)r0.y);
      [branch] if (r8.w != 0) break;
      r8.w = _BT_LinkListBuffer[r7.w].val[0/4];
      r10.x = _BT_LightBuffer[r8.w].val[0/4];
      r10.y = _BT_LightBuffer[r8.w].val[0/4+1];
      r10.z = _BT_LightBuffer[r8.w].val[0/4+2];
      r10.w = _BT_LightBuffer[r8.w].val[0/4+3];
      r9.w = _BT_LightBuffer[r8.w].val[32/4];
      r10.xyz = -r10.xyz + r3.xyz;
      r11.x = dot(r10.xyz, r10.xyz);
      r11.y = r10.w * r10.w;
      r11.z = max(0.100000001, r11.x);
      r11.y = r11.z / r11.y;
      r11.y = -r11.y * r11.y + 1;
      r11.y = max(0, r11.y);
      r11.y = r11.y * r11.y;
      r9.w = r10.w * r9.w + r11.z;
      r9.w = 1 / r9.w;
      r9.w = r9.w * r11.y;
      r10.w = cmp(r9.w != 0.000000);
      [branch] if (r10.w != 0) {
        r11.y = _BT_LightBuffer[r8.w].val[16/4];
        r11.z = _BT_LightBuffer[r8.w].val[16/4+1];
        r11.w = _BT_LightBuffer[r8.w].val[16/4+2];
        r8.w = _BT_LightBuffer[r8.w].val[60/4];
        r10.w = rsqrt(r11.x);
        r12.xyz = r10.xyz * r10.www;
        r11.xyz = r11.yzw * r9.www;
        r9.w = dot(r2.xzw, -r12.xyz);
        r9.w = max(0, r9.w);
        r8.w = cmp(r8.w >= 0);
        r10.xyz = -r10.xyz * r10.www + -r5.xyz;
        r10.w = dot(r10.xyz, r10.xyz);
        r10.w = max(0.00100000005, r10.w);
        r10.w = rsqrt(r10.w);
        r10.xyz = r10.xyz * r10.www;
        r10.w = dot(r6.xyz, r10.xyz);
        r10.x = dot(-r12.xyz, r10.xyz);
        r10.xw = max(float2(0,0), r10.xw);
        r10.y = r9.w * r0.w + r4.w;
        r10.y = r10.y * r1.x;
        r10.y = r9.w * r2.y + r10.y;
        r10.y = 9.99999975e-006 + r10.y;
        r10.y = 0.5 / r10.y;
        r10.z = r10.w * r5.w + -r10.w;
        r10.z = r10.z * r10.w + 1;
        r10.z = r10.z * r10.z + 1.00000001e-007;
        r10.z = r6.w / r10.z;
        r10.w = 1 + -r9.w;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r11.w = r10.x + r10.x;
        r11.w = r11.w * r10.x;
        r11.w = r11.w * r4.w + r7.x;
        r11.w = -1 + r11.w;
        r10.w = r11.w * r10.w + 1;
        r11.w = r11.w * r7.z + 1;
        r10.w = r11.w * r10.w;
        r10.w = r10.w * r7.y;
        r10.y = r10.y * r10.z;
        r10.y = 3.14159274 * r10.y;
        r10.y = r10.y * r9.w;
        r10.y = max(0, r10.y);
        r9.w = r10.w * r9.w;
        r12.xyz = r11.xyz * r9.www;
        r10.yzw = r10.yyy * r11.xyz;
        r9.w = 1 + -r10.x;
        r10.x = r9.w * r9.w;
        r10.x = r10.x * r10.x;
        r9.w = r10.x * r9.w;
        r11.xyz = r8.xyz * r9.www + r4.xyz;
        r10.xyz = r11.xyz * r10.yzw;
        r8.w = r8.w ? 1.000000 : 0;
        r10.xyz = r10.xyz * r8.www;
        r10.xyz = r1.yzw * r12.xyz + r10.xyz;
      } else {
        r10.xyz = float3(0,0,0);
      }
      r9.xyz = r10.xyz + r9.xyz;
      r7.w = (int)r7.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r10.xyz = r9.xyz;
    r0.y = r7.w;
    [loop] while (true) {
      r0.z = cmp((int)r0.y >= (int)r0.x);
      [branch] if (r0.z != 0) break;
      r0.z = _BT_LinkListBuffer[r0.y].val[0/4];
      r11.x = _BT_LightBuffer[r0.z].val[0/4];
      r11.y = _BT_LightBuffer[r0.z].val[0/4+1];
      r11.z = _BT_LightBuffer[r0.z].val[0/4+2];
      r11.w = _BT_LightBuffer[r0.z].val[0/4+3];
      r8.w = _BT_LightBuffer[r0.z].val[32/4];
      r12.x = _BT_LightBuffer[r0.z].val[48/4];
      r12.y = _BT_LightBuffer[r0.z].val[48/4+1];
      r9.w = (uint)r0.z << 2;
      r8.w = frac(r8.w);
      r11.xyz = -r11.xyz + r3.xyz;
      r10.w = dot(r11.xyz, r11.xyz);
      r12.z = r11.w * r11.w;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][1], _BT_LightMatrix[(uint)(r9.w) / 4u][1][1], _BT_LightMatrix[(uint)(r9.w) / 4u][2][1], _BT_LightMatrix[(uint)(r9.w) / 4u][3][1]) * r3.yyyy;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][0], _BT_LightMatrix[(uint)(r9.w) / 4u][1][0], _BT_LightMatrix[(uint)(r9.w) / 4u][2][0], _BT_LightMatrix[(uint)(r9.w) / 4u][3][0]) * r3.xxxx + r13.xyzw;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][2], _BT_LightMatrix[(uint)(r9.w) / 4u][1][2], _BT_LightMatrix[(uint)(r9.w) / 4u][2][2], _BT_LightMatrix[(uint)(r9.w) / 4u][3][2]) * r3.zzzz + r13.xyzw;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][3], _BT_LightMatrix[(uint)(r9.w) / 4u][1][3], _BT_LightMatrix[(uint)(r9.w) / 4u][2][3], _BT_LightMatrix[(uint)(r9.w) / 4u][3][3]) * r3.wwww + r13.xyzw;
      r9.w = max(0.100000001, r10.w);
      r12.z = r9.w / r12.z;
      r12.z = -r12.z * r12.z + 1;
      r12.z = max(0, r12.z);
      r12.z = r12.z * r12.z;
      r8.w = r11.w * r8.w + r9.w;
      r8.w = 1 / r8.w;
      r8.w = r8.w * r12.z;
      r13.xyz = r13.xyz / r13.www;
      r9.w = cmp(0 >= r13.z);
      r12.zw = cmp(float2(1,1) < r13.xy);
      r9.w = (int)r9.w | (int)r12.z;
      r13.zw = cmp(r13.xy < float2(-1,-1));
      r9.w = (int)r9.w | (int)r13.z;
      r9.w = (int)r12.w | (int)r9.w;
      r9.w = (int)r13.w | (int)r9.w;
      r11.w = r12.x / r12.y;
      r11.w = min(0.99000001, r11.w);
      r12.x = dot(r13.xy, r13.xy);
      r12.x = sqrt(r12.x);
      r12.x = min(1, r12.x);
      r11.w = -1 + r11.w;
      r12.x = -1 + r12.x;
      r11.w = 1 / r11.w;
      r11.w = r12.x * r11.w;
      r11.w = min(1, r11.w);
      r12.x = r11.w * -2 + 3;
      r11.w = r11.w * r11.w;
      r11.w = r12.x * r11.w;
      r12.x = cmp(r11.w != 0.000000);
      r11.w = r12.x ? r11.w : 0;
      r9.w = r9.w ? 0 : r11.w;
      r8.w = r9.w * r8.w;
      r9.w = cmp(r8.w != 0.000000);
      [branch] if (r9.w != 0) {
        r12.x = _BT_LightBuffer[r0.z].val[16/4];
        r12.y = _BT_LightBuffer[r0.z].val[16/4+1];
        r12.z = _BT_LightBuffer[r0.z].val[16/4+2];
        r0.z = _BT_LightBuffer[r0.z].val[60/4];
        r9.w = rsqrt(r10.w);
        r13.xyz = r11.xyz * r9.www;
        r12.xyz = r12.xyz * r8.www;
        r8.w = dot(r2.xzw, -r13.xyz);
        r8.w = max(0, r8.w);
        r0.z = cmp(r0.z >= 0);
        r11.xyz = -r11.xyz * r9.www + -r5.xyz;
        r9.w = dot(r11.xyz, r11.xyz);
        r9.w = max(0.00100000005, r9.w);
        r9.w = rsqrt(r9.w);
        r11.xyz = r11.xyz * r9.www;
        r9.w = dot(r6.xyz, r11.xyz);
        r9.w = max(0, r9.w);
        r10.w = dot(-r13.xyz, r11.xyz);
        r10.w = max(0, r10.w);
        r11.x = r8.w * r0.w + r4.w;
        r11.x = r11.x * r1.x;
        r11.x = r8.w * r2.y + r11.x;
        r11.x = 9.99999975e-006 + r11.x;
        r11.x = 0.5 / r11.x;
        r11.y = r9.w * r5.w + -r9.w;
        r9.w = r11.y * r9.w + 1;
        r9.w = r9.w * r9.w + 1.00000001e-007;
        r9.w = r6.w / r9.w;
        r11.y = 1 + -r8.w;
        r11.z = r11.y * r11.y;
        r11.z = r11.z * r11.z;
        r11.y = r11.z * r11.y;
        r11.z = r10.w + r10.w;
        r11.z = r11.z * r10.w;
        r11.z = r11.z * r4.w + r7.x;
        r11.z = -1 + r11.z;
        r11.y = r11.z * r11.y + 1;
        r11.z = r11.z * r7.z + 1;
        r11.y = r11.y * r11.z;
        r11.y = r11.y * r7.y;
        r9.w = r11.x * r9.w;
        r9.w = 3.14159274 * r9.w;
        r9.w = r9.w * r8.w;
        r9.w = max(0, r9.w);
        r8.w = r11.y * r8.w;
        r11.xyz = r12.xyz * r8.www;
        r12.xyz = r9.www * r12.xyz;
        r8.w = 1 + -r10.w;
        r9.w = r8.w * r8.w;
        r9.w = r9.w * r9.w;
        r8.w = r9.w * r8.w;
        r13.xyz = r8.xyz * r8.www + r4.xyz;
        r12.xyz = r13.xyz * r12.xyz;
        r0.z = r0.z ? 1.000000 : 0;
        r12.xyz = r12.xyz * r0.zzz;
        r11.xyz = r1.yzw * r11.xyz + r12.xyz;
      } else {
        r11.xyz = float3(0,0,0);
      }
      r10.xyz = r11.xyz + r10.xyz;
      r0.y = (int)r0.y + 1;
    }
    r0.xyz = float3(8,8,8) * r10.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps f477de119b48453e: 1 retail keyword combination(s)
void ps_f477de119b48453e_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyzw = _BT_ListEntries.Load(r0.xywz).xyzw;
  r1.y = cmp((int)r0.x >= 0);
  [branch] if (r1.y != 0) {
    r1.yzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyz;
    r2.xyz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xzw;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xyz = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r1.yzw;
    r4.xyz = r2.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r2.x = -r2.x * 0.959999979 + 0.959999979;
    r1.yzw = r2.xxx * r1.yzw;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r2.x = dot(r3.xyz, r3.xyz);
    r2.x = rsqrt(r2.x);
    r3.xyz = r3.xyz * r2.xxx;
    r5.z = 1 + -r1.x;
    r5.xy = v0.zw;
    r5.xyz = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r5.yyyy;
    r6.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r5.xxxx + r6.xyzw;
    r5.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r5.zzzz + r6.xyzw;
    r5.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r5.xyzw;
    r5.xyz = r5.xyz / r5.www;
    r6.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r5.yyyy;
    r6.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r5.xxxx + r6.xyzw;
    r5.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r5.zzzz + r6.xyzw;
    r5.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r5.xyzw;
    r6.xyz = -_WorldSpaceCameraPos.xyz + r5.xyz;
    r1.x = dot(r6.xyz, r6.xyz);
    r1.x = rsqrt(r1.x);
    r7.xyz = r6.xyz * r1.xxx;
    r2.x = dot(r3.xyz, -r7.xyz);
    r2.w = max(0, r2.x);
    r4.w = min(1, r2.w);
    r0.y = (int)r0.y + (int)r0.x;
    r3.w = cmp(r3.w == 0.666666687);
    r2.y = 1 + -r2.y;
    r6.w = r2.y * r2.y;
    r7.w = cmp(r2.x < 0);
    r8.x = 9.99999975e-006 + -r2.x;
    r8.xyz = -r7.xyz * r8.xxx + r3.xyz;
    r8.xyz = r7.www ? r8.xyz : r3.xyz;
    r7.w = -r2.y * r2.y + 1;
    r8.w = r4.w * r7.w + r6.w;
    r9.x = r6.w * r6.w;
    r9.y = 0.318309873 * r9.x;
    r9.z = 0.5 * r6.w;
    r9.w = r6.w * -0.337748349 + 1;
    r10.x = 1 + -r4.w;
    r10.y = r10.x * r10.x;
    r10.y = r10.y * r10.y;
    r10.x = r10.y * r10.x;
    r10.yzw = float3(1,1,1) + -r4.xyz;
    r11.yzw = float3(0,0,0);
    r12.xyz = float3(0,0,0);
    r12.w = r0.x;
    [loop] while (true) {
      r13.x = cmp((int)r12.w >= (int)r0.y);
      [branch] if (r13.x != 0) break;
      r13.x = _BT_LinkListBuffer[r12.w].val[0/4];
      r14.x = _BT_LightBuffer[r13.x].val[0/4];
      r14.y = _BT_LightBuffer[r13.x].val[0/4+1];
      r14.z = _BT_LightBuffer[r13.x].val[0/4+2];
      r14.w = _BT_LightBuffer[r13.x].val[0/4+3];
      r13.y = _BT_LightBuffer[r13.x].val[32/4];
      r14.xyz = -r14.xyz + r5.xyz;
      r13.z = dot(r14.xyz, r14.xyz);
      r13.w = r14.w * r14.w;
      r15.x = max(0.100000001, r13.z);
      r13.w = r15.x / r13.w;
      r13.w = -r13.w * r13.w + 1;
      r13.w = max(0, r13.w);
      r13.w = r13.w * r13.w;
      r13.y = r14.w * r13.y + r15.x;
      r13.y = 1 / r13.y;
      r13.y = r13.y * r13.w;
      r13.w = cmp(r13.y != 0.000000);
      [branch] if (r13.w != 0) {
        r15.x = _BT_LightBuffer[r13.x].val[16/4];
        r15.y = _BT_LightBuffer[r13.x].val[16/4+1];
        r15.z = _BT_LightBuffer[r13.x].val[16/4+2];
        r13.x = _BT_LightBuffer[r13.x].val[60/4];
        r13.z = rsqrt(r13.z);
        r16.xyz = r14.xyz * r13.zzz;
        r15.xyz = r15.xyz * r13.yyy;
        r13.y = dot(r3.xyz, -r16.xyz);
        r11.x = max(0, r13.y);
        r13.y = 0.800000012 + r13.y;
        r13.y = saturate(0.555555582 * r13.y);
        r13.y = r13.y * r13.y;
        r13.y = r13.y * r13.y;
        r13.y = r13.y * 1.38888896 + -r11.x;
        r17.x = r2.z * r13.y + r11.x;
        r13.y = saturate(dot(r3.xyz, r16.xyz));
        r18.xyz = r13.yyy * r1.yzw;
        r18.xyz = r18.xyz * r15.xyz;
        r18.xyz = r18.xyz * r2.zzz;
        r17.yzw = float3(0.25,0.25,0.25) * r18.xyz;
        r17.xyzw = r3.wwww ? r17.xyzw : r11.xyzw;
        r11.x = cmp(0 != r13.x);
        r13.xyz = -r14.xyz * r13.zzz + -r7.xyz;
        r13.w = dot(r13.xyz, r13.xyz);
        r13.w = max(0.00100000005, r13.w);
        r13.w = rsqrt(r13.w);
        r13.xyz = r13.xyz * r13.www;
        r13.w = dot(r8.xyz, r13.xyz);
        r13.x = dot(-r16.xyz, r13.xyz);
        r13.xw = max(float2(0,0), r13.xw);
        r13.y = r17.x * r7.w + r6.w;
        r13.y = r13.y * r4.w;
        r13.y = r17.x * r8.w + r13.y;
        r13.y = 9.99999975e-006 + r13.y;
        r13.y = 0.5 / r13.y;
        r13.z = r13.w * r9.x + -r13.w;
        r13.z = r13.z * r13.w + 1;
        r13.z = r13.z * r13.z + 1.00000001e-007;
        r13.z = r9.y / r13.z;
        r13.w = 1 + -r17.x;
        r14.x = r13.w * r13.w;
        r14.x = r14.x * r14.x;
        r13.w = r14.x * r13.w;
        r14.x = r13.x + r13.x;
        r14.x = r14.x * r13.x;
        r14.x = r14.x * r6.w + r9.z;
        r14.x = -1 + r14.x;
        r13.w = r14.x * r13.w + 1;
        r14.x = r14.x * r10.x + 1;
        r13.w = r14.x * r13.w;
        r13.w = r13.w * r9.w;
        r13.y = r13.y * r13.z;
        r13.yz = r13.yw * r17.xx;
        r13.y = 3.14159274 * r13.y;
        r13.y = max(0, r13.y);
        r14.xyz = r15.xyz * r13.zzz;
        r13.yzw = r13.yyy * r15.xyz;
        r13.x = 1 + -r13.x;
        r14.w = r13.x * r13.x;
        r14.w = r14.w * r14.w;
        r13.x = r14.w * r13.x;
        r15.xyz = r10.yzw * r13.xxx + r4.xyz;
        r13.xyz = r15.xyz * r13.yzw;
        r11.x = r11.x ? 1.000000 : 0;
        r13.xyz = r13.xyz * r11.xxx;
        r13.xyz = r1.yzw * r14.xyz + r13.xyz;
        r13.xyz = r17.yzw + r13.xyz;
      } else {
        r13.xyz = float3(0,0,0);
      }
      r12.xyz = r13.xyz + r12.xyz;
      r12.w = (int)r12.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r0.y = sqrt(_BT_ShadowMapParams.z);
    r0.z = _BT_MaxShadowDist * _BT_MaxShadowDist;
    r11.x = 0.5 * r0.z;
    r11.x = 1 / r11.x;
    r13.yzw = float3(0,0,0);
    r14.xz = _BT_ShadowMap_TexelSize.xx;
    r14.y = 0.142857149;
    r15.xz = _BT_ShadowMap_TexelSize.yy;
    r15.y = 0.142857149;
    r16.y = 7;
    r11.yzw = r12.xyz;
    r14.w = r12.w;
    [loop] while (true) {
      r15.w = cmp((int)r14.w >= (int)r0.x);
      [branch] if (r15.w != 0) break;
      r15.w = _BT_LinkListBuffer[r14.w].val[0/4];
      r17.x = _BT_LightBuffer[r15.w].val[0/4];
      r17.y = _BT_LightBuffer[r15.w].val[0/4+1];
      r17.z = _BT_LightBuffer[r15.w].val[0/4+2];
      r17.w = _BT_LightBuffer[r15.w].val[0/4+3];
      r16.w = _BT_LightBuffer[r15.w].val[32/4];
      r18.x = _BT_LightBuffer[r15.w].val[48/4];
      r18.y = _BT_LightBuffer[r15.w].val[48/4+1];
      r18.z = _BT_LightBuffer[r15.w].val[48/4+2];
      r18.w = _BT_LightBuffer[r15.w].val[48/4+3];
      r19.x = (uint)r15.w << 2;
      r16.w = frac(r16.w);
      r19.yzw = -r17.xyz + r5.xyz;
      r20.x = dot(r19.yzw, r19.yzw);
      r20.y = r17.w * r17.w;
      r21.xyzw = float4(_BT_LightMatrix[(uint)(r19.x) / 4u][0][1], _BT_LightMatrix[(uint)(r19.x) / 4u][1][1], _BT_LightMatrix[(uint)(r19.x) / 4u][2][1], _BT_LightMatrix[(uint)(r19.x) / 4u][3][1]) * r5.yyyy;
      r21.xyzw = float4(_BT_LightMatrix[(uint)(r19.x) / 4u][0][0], _BT_LightMatrix[(uint)(r19.x) / 4u][1][0], _BT_LightMatrix[(uint)(r19.x) / 4u][2][0], _BT_LightMatrix[(uint)(r19.x) / 4u][3][0]) * r5.xxxx + r21.xyzw;
      r21.xyzw = float4(_BT_LightMatrix[(uint)(r19.x) / 4u][0][2], _BT_LightMatrix[(uint)(r19.x) / 4u][1][2], _BT_LightMatrix[(uint)(r19.x) / 4u][2][2], _BT_LightMatrix[(uint)(r19.x) / 4u][3][2]) * r5.zzzz + r21.xyzw;
      r21.xyzw = float4(_BT_LightMatrix[(uint)(r19.x) / 4u][0][3], _BT_LightMatrix[(uint)(r19.x) / 4u][1][3], _BT_LightMatrix[(uint)(r19.x) / 4u][2][3], _BT_LightMatrix[(uint)(r19.x) / 4u][3][3]) * r5.wwww + r21.xyzw;
      r19.x = max(0.100000001, r20.x);
      r20.y = r19.x / r20.y;
      r20.y = -r20.y * r20.y + 1;
      r20.y = max(0, r20.y);
      r20.y = r20.y * r20.y;
      r16.w = r17.w * r16.w + r19.x;
      r16.w = 1 / r16.w;
      r16.w = r16.w * r20.y;
      r20.yzw = r21.xyz / r21.www;
      r17.w = cmp(0 >= r20.w);
      r21.xy = cmp(float2(1,1) < r20.yz);
      r17.w = (int)r17.w | (int)r21.x;
      r21.xz = cmp(r20.yz < float2(-1,-1));
      r17.w = (int)r17.w | (int)r21.x;
      r17.w = (int)r21.y | (int)r17.w;
      r17.w = (int)r21.z | (int)r17.w;
      [branch] if (r17.w == 0) {
        r17.w = r18.x / r18.y;
        r17.w = min(0.99000001, r17.w);
        r18.x = dot(r20.yz, r20.yz);
        r18.x = sqrt(r18.x);
        r18.x = min(1, r18.x);
        r17.w = -1 + r17.w;
        r18.x = -1 + r18.x;
        r17.w = 1 / r17.w;
        r17.w = r18.x * r17.w;
        r17.w = min(1, r17.w);
        r18.x = r17.w * -2 + 3;
        r17.w = r17.w * r17.w;
        r17.w = r18.x * r17.w;
        r18.x = cmp(r17.w != 0.000000);
        [branch] if (r18.x != 0) {
          r18.x = cmp(-1 < r18.z);
          [branch] if (r18.x != 0) {
            r18.xy = r20.yz * float2(0.5,0.5) + float2(0.5,0.5);
            r17.xyz = _WorldSpaceCameraPos.xyz + -r17.xyz;
            r17.x = dot(r17.xyz, r17.xyz);
            r17.y = r18.z / r0.y;
            r17.z = cmp(r17.y >= -r17.y);
            r18.z = frac(abs(r17.y));
            r17.z = r17.z ? r18.z : -r18.z;
            r17.z = r17.z * r0.y;
            r17.y = floor(r17.y);
            r21.xy = r17.zy / r0.yy;
            r17.yz = r18.xy / r0.yy;
            r17.yz = r17.yz + r21.xy;
            r18.x = r20.w + abs(r18.w);
            r17.yz = r17.yz * _BT_ShadowMap_TexelSize.zw + float2(0.5,0.5);
            r18.yz = floor(r17.yz);
            r18.yz = float2(-0.5,-0.5) + r18.yz;
            r17.yz = frac(r17.yz);
            r19.x = 3 * r17.y;
            r20.yz = -r17.yz * float2(3,3) + float2(4,4);
            r21.xy = r17.yz * float2(3,3) + float2(1,1);
            r21.zw = -r17.yz * float2(2,2) + float2(3,3);
            r20.yw = r21.zw / r20.yz;
            r22.xy = float2(-2,-2) + r20.yw;
            r20.yw = float2(3,3) + r17.yz;
            r23.xy = _BT_ShadowMap_TexelSize.xy * r20.yw;
            r17.yz = r17.yz / r21.xy;
            r17.yz = float2(2,2) + r17.yz;
            r22.z = r23.x;
            r22.w = r17.y;
            r24.xyz = r22.xzw * r14.xyz;
            r23.z = r22.y;
            r23.w = r17.z;
            r22.xyw = r23.zyw * r15.xyz;
            r16.xz = r19.xx * float2(-1,1) + float2(4,1);
            r20.yzw = r20.zzz * r16.xyz;
            r24.w = r22.x;
            r23.xyzw = r18.yzyz * _BT_ShadowMap_TexelSize.xyxy + r24.xwyw;
            r17.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r23.xy, r18.x).x;
            r17.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r23.zw, r18.x).x;
            r17.z = r20.z * r17.z;
            r17.y = r20.y * r17.y + r17.z;
            r20.yz = r18.yz * _BT_ShadowMap_TexelSize.xy + r24.zw;
            r17.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.yz, r18.x).x;
            r17.y = r20.w * r17.z + r17.y;
            r20.yz = float2(7,7) * r16.xz;
            r22.z = r24.x;
            r23.xyzw = r18.yzyz * _BT_ShadowMap_TexelSize.xyxy + r22.zyzw;
            r17.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r23.xy, r18.x).x;
            r17.y = r20.y * r17.z + r17.y;
            r22.xz = r24.yz;
            r24.xyzw = r18.yzyz * _BT_ShadowMap_TexelSize.xyxy + r22.xyzy;
            r17.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r24.xy, r18.x).x;
            r17.y = r17.z * 49 + r17.y;
            r17.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r24.zw, r18.x).x;
            r17.y = r20.z * r17.z + r17.y;
            r20.yzw = r21.yyy * r16.xyz;
            r16.x = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r23.zw, r18.x).x;
            r16.x = r20.y * r16.x + r17.y;
            r21.xyzw = r18.yzyz * _BT_ShadowMap_TexelSize.xyxy + r22.xwzw;
            r16.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.xy, r18.x).x;
            r16.x = r20.z * r16.z + r16.x;
            r16.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.zw, r18.x).x;
            r16.x = r20.w * r16.z + r16.x;
            r16.z = 0.0069444445 * r16.x;
            r17.x = -r0.z * 0.5 + r17.x;
            r17.x = saturate(r17.x * r11.x);
            r17.y = r17.x * -2 + 3;
            r17.x = r17.x * r17.x;
            r17.x = r17.y * r17.x;
            r16.x = -r16.x * 0.0069444445 + 1;
            r16.x = r17.x * r16.x + r16.z;
            r17.w = r17.w * r16.x;
          }
        } else {
          r17.w = 0;
        }
      } else {
        r17.w = 0;
      }
      r16.x = r17.w * r16.w;
      r16.z = cmp(r16.x != 0.000000);
      [branch] if (r16.z != 0) {
        r17.x = _BT_LightBuffer[r15.w].val[16/4];
        r17.y = _BT_LightBuffer[r15.w].val[16/4+1];
        r17.z = _BT_LightBuffer[r15.w].val[16/4+2];
        r15.w = rsqrt(r20.x);
        r18.xyz = r19.yzw * r15.www;
        r16.xzw = r17.xyz * r16.xxx;
        r17.x = dot(r3.xyz, -r18.xyz);
        r13.x = max(0, r17.x);
        r17.x = 0.800000012 + r17.x;
        r17.x = saturate(0.555555582 * r17.x);
        r17.x = r17.x * r17.x;
        r17.x = r17.x * r17.x;
        r17.x = r17.x * 1.38888896 + -r13.x;
        r17.x = r2.z * r17.x + r13.x;
        r19.x = saturate(dot(r3.xyz, r18.xyz));
        r20.xyz = r19.xxx * r1.yzw;
        r20.xyz = r20.xyz * r16.xzw;
        r20.xyz = r20.xyz * r2.zzz;
        r17.yzw = float3(0.25,0.25,0.25) * r20.xyz;
        r17.xyzw = r3.wwww ? r17.xyzw : r13.xyzw;
        r13.x = cmp(0 != r18.w);
        r19.xyz = -r19.yzw * r15.www + -r7.xyz;
        r15.w = dot(r19.xyz, r19.xyz);
        r15.w = max(0.00100000005, r15.w);
        r15.w = rsqrt(r15.w);
        r19.xyz = r19.xyz * r15.www;
        r15.w = dot(r8.xyz, r19.xyz);
        r15.w = max(0, r15.w);
        r18.x = dot(-r18.xyz, r19.xyz);
        r18.x = max(0, r18.x);
        r18.y = r17.x * r7.w + r6.w;
        r18.y = r18.y * r4.w;
        r18.y = r17.x * r8.w + r18.y;
        r18.y = 9.99999975e-006 + r18.y;
        r18.y = 0.5 / r18.y;
        r18.z = r15.w * r9.x + -r15.w;
        r15.w = r18.z * r15.w + 1;
        r15.w = r15.w * r15.w + 1.00000001e-007;
        r15.w = r9.y / r15.w;
        r18.z = 1 + -r17.x;
        r18.w = r18.z * r18.z;
        r18.w = r18.w * r18.w;
        r18.z = r18.w * r18.z;
        r18.w = r18.x + r18.x;
        r18.w = r18.w * r18.x;
        r18.w = r18.w * r6.w + r9.z;
        r18.w = -1 + r18.w;
        r18.z = r18.w * r18.z + 1;
        r18.w = r18.w * r10.x + 1;
        r18.z = r18.z * r18.w;
        r18.z = r18.z * r9.w;
        r15.w = r18.y * r15.w;
        r15.w = r15.w * r17.x;
        r15.w = 3.14159274 * r15.w;
        r15.w = max(0, r15.w);
        r17.x = r18.z * r17.x;
        r18.yzw = r17.xxx * r16.xzw;
        r16.xzw = r15.www * r16.xzw;
        r15.w = 1 + -r18.x;
        r17.x = r15.w * r15.w;
        r17.x = r17.x * r17.x;
        r15.w = r17.x * r15.w;
        r19.xyz = r10.yzw * r15.www + r4.xyz;
        r16.xzw = r19.xyz * r16.xzw;
        r13.x = r13.x ? 1.000000 : 0;
        r16.xzw = r16.xzw * r13.xxx;
        r16.xzw = r1.yzw * r18.yzw + r16.xzw;
        r16.xzw = r17.yzw + r16.xzw;
      } else {
        r16.xzw = float3(0,0,0);
      }
      r11.yzw = r16.xzw + r11.yzw;
      r14.w = (int)r14.w + 1;
    }
    r0.x = (int)r0.w + (int)r0.x;
    r0.yzw = float3(25,25,25) * r1.yzw;
    r1.y = r2.x + r2.x;
    r1.yzw = r3.xyz * -r1.yyy + -r7.xyz;
    r2.x = -r6.w * 0.5 + 1;
    r2.z = r2.w * r2.x + r9.z;
    r3.w = r6.w * r6.w + -1;
    r4.w = r9.x * r9.x;
    r2.w = 1 + -r2.w;
    r5.w = r2.w * r2.w;
    r5.w = r5.w * r5.w;
    r2.w = r5.w * r2.w;
    r7.xyz = r11.yzw;
    r5.w = r14.w;
    [loop] while (true) {
      r6.w = cmp((int)r5.w >= (int)r0.x);
      [branch] if (r6.w != 0) break;
      r6.w = _BT_LinkListBuffer[r5.w].val[0/4];
      r8.x = _BT_LightBuffer[r6.w].val[0/4];
      r8.y = _BT_LightBuffer[r6.w].val[0/4+1];
      r8.z = _BT_LightBuffer[r6.w].val[0/4+2];
      r8.w = _BT_LightBuffer[r6.w].val[0/4+3];
      r9.x = _BT_LightBuffer[r6.w].val[16/4];
      r9.y = _BT_LightBuffer[r6.w].val[16/4+1];
      r9.w = _BT_LightBuffer[r6.w].val[16/4+2];
      r7.w = _BT_LightBuffer[r6.w].val[32/4];
      r12.x = _BT_LightBuffer[r6.w].val[48/4];
      r12.y = _BT_LightBuffer[r6.w].val[48/4+1];
      r12.z = _BT_LightBuffer[r6.w].val[48/4+2];
      r6.w = r8.w * r8.w;
      r6.w = 1 / r6.w;
      r12.xyz = r12.xyz * r7.www + r8.xyz;
      r8.xyz = r8.xyz + -r5.xyz;
      r12.xyz = r12.xyz + -r5.xyz;
      r7.w = dot(r8.xyz, r8.xyz);
      r8.w = sqrt(r7.w);
      r10.x = dot(r12.xyz, r12.xyz);
      r10.x = sqrt(r10.x);
      r11.x = dot(r8.xyz, r3.xyz);
      r12.w = r8.w + r8.w;
      r11.x = r11.x / r12.w;
      r12.w = dot(r12.xyz, r3.xyz);
      r13.x = r10.x + r10.x;
      r12.w = r12.w / r13.x;
      r11.x = saturate(r12.w + r11.x);
      r13.xyz = r12.xyz + -r8.xyz;
      r12.w = dot(r1.yzw, r8.xyz);
      r13.w = dot(r1.yzw, r13.xyz);
      r14.x = dot(r8.xyz, r13.xyz);
      r14.y = dot(r13.xyz, r13.xyz);
      r7.w = r13.w * r7.w;
      r7.w = r14.x * r12.w + -r7.w;
      r12.w = r14.y * r12.w;
      r12.w = r14.x * r13.w + -r12.w;
      r7.w = saturate(r7.w / r12.w);
      r14.xyz = r13.yzx * r8.zxy;
      r14.xyz = r8.yzx * r13.zxy + -r14.xyz;
      r15.xyz = r13.zxy * r1.zwy;
      r15.xyz = r13.yzx * r1.wyz + -r15.xyz;
      r12.w = dot(r14.xyz, r15.xyz);
      r13.w = 1 + -r7.w;
      r12.w = cmp(r12.w >= 0);
      r12.w = r12.w ? 1.000000 : 0;
      r7.w = -r13.w + r7.w;
      r7.w = r12.w * r7.w + r13.w;
      r13.xyz = r13.xyz * r7.www + r8.xyz;
      r7.w = dot(r13.xyz, r1.yzw);
      r14.xyz = r7.www * r1.yzw + -r13.xyz;
      r7.w = dot(r14.xyz, r14.xyz);
      r7.w = sqrt(r7.w);
      r7.w = 0.100000001 / r7.w;
      r7.w = min(1, r7.w);
      r13.xyz = r14.xyz * r7.www + r13.xyz;
      r7.w = dot(r13.xyz, r13.xyz);
      r7.w = sqrt(r7.w);
      r13.xyz = r13.xyz / r7.www;
      r8.x = dot(r8.xyz, r12.xyz);
      r8.x = r8.w * r10.x + r8.x;
      r8.x = 0.5 * r8.x;
      r6.w = r8.x * r6.w;
      r6.w = sqrt(r6.w);
      r8.x = r6.w * 4 + 1;
      r8.x = r8.x * r8.x;
      r8.x = 1 / r8.x;
      r8.x = -0.0399999991 + r8.x;
      r8.x = 1.04166675 * r8.x;
      r6.w = cmp(r6.w >= 1);
      r6.w = r6.w ? 0 : r8.x;
      r8.xyz = r9.xyw * r6.www;
      r9.xyw = -r6.xyz * r1.xxx + r13.xyz;
      r6.w = dot(r9.xyw, r9.xyw);
      r6.w = max(0.00100000005, r6.w);
      r6.w = rsqrt(r6.w);
      r9.xyw = r9.xyw * r6.www;
      r6.w = dot(r3.xyz, r9.xyw);
      r6.w = max(0, r6.w);
      r8.w = dot(r13.xyz, r9.xyw);
      r8.w = max(0, r8.w);
      r9.x = r11.x * r2.x + r9.z;
      r9.x = r9.x * r2.z + 9.99999975e-006;
      r9.x = 1 / r9.x;
      r6.w = r6.w * r6.w;
      r6.w = r6.w * r3.w + 1;
      r6.w = max(9.99999997e-007, r6.w);
      r7.w = r7.w + r7.w;
      r7.w = 0.100000001 / r7.w;
      r7.w = r2.y * r2.y + r7.w;
      r7.w = min(1, r7.w);
      r7.w = r7.w * r7.w;
      r9.y = 3.14159274 * r6.w;
      r6.w = r9.y * r6.w;
      r6.w = r6.w * r7.w;
      r6.w = r4.w / r6.w;
      r7.w = 1 + -r11.x;
      r9.y = r7.w * r7.w;
      r9.y = r9.y * r9.y;
      r7.w = r9.y * r7.w;
      r9.y = r8.w * r8.w;
      r9.y = dot(r9.yy, r2.yy);
      r9.y = -0.5 + r9.y;
      r7.w = r9.y * r7.w + 1;
      r9.y = r9.y * r2.w + 1;
      r7.w = r9.y * r7.w;
      r6.w = r9.x * r6.w;
      r6.w = 0.785398185 * r6.w;
      r6.w = r6.w * r11.x;
      r6.w = max(0, r6.w);
      r7.w = r7.w * r11.x;
      r9.xyw = r8.xyz * r7.www;
      r8.xyz = r6.www * r8.xyz;
      r6.w = 1 + -r8.w;
      r7.w = r6.w * r6.w;
      r7.w = r7.w * r7.w;
      r6.w = r7.w * r6.w;
      r12.xyz = r10.yzw * r6.www + r4.xyz;
      r8.xyz = r12.xyz * r8.xyz;
      r8.xyz = r0.yzw * r9.xyw + r8.xyz;
      r7.xyz = r8.xyz + r7.xyz;
      r5.w = (int)r5.w + 1;
    }
    r0.xyz = float3(8,8,8) * r7.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps fb12431c83fd11d0: 2 retail keyword combination(s)
void ps_fb12431c83fd11d0_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r1.yzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyz;
    r2.xyz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xzw;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xyz = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r1.yzw;
    r4.xyz = r2.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r0.w = -r2.x * 0.959999979 + 0.959999979;
    r1.yzw = r1.yzw * r0.www;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r0.w = dot(r3.xyz, r3.xyz);
    r0.w = rsqrt(r0.w);
    r3.xyz = r3.xyz * r0.www;
    r5.z = 1 + -r1.x;
    r5.xy = v0.zw;
    r5.xyz = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r5.yyyy;
    r6.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r5.xxxx + r6.xyzw;
    r5.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r5.zzzz + r6.xyzw;
    r5.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r5.xyzw;
    r5.xyz = r5.xyz / r5.www;
    r6.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r5.yyyy;
    r6.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r5.xxxx + r6.xyzw;
    r5.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r5.zzzz + r6.xyzw;
    r5.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r5.xyzw;
    r6.xyz = -_WorldSpaceCameraPos.xyz + r5.xyz;
    r0.w = dot(r6.xyz, r6.xyz);
    r0.w = rsqrt(r0.w);
    r6.xyz = r6.xyz * r0.www;
    r0.w = dot(r3.xyz, -r6.xyz);
    r1.x = saturate(r0.w);
    r0.y = (int)r0.y + (int)r0.x;
    r2.x = cmp(r3.w == 0.666666687);
    r2.y = 1 + -r2.y;
    r2.w = r2.y * r2.y;
    r3.w = cmp(r0.w < 0);
    r0.w = 9.99999975e-006 + -r0.w;
    r7.xyz = -r6.xyz * r0.www + r3.xyz;
    r7.xyz = r3.www ? r7.xyz : r3.xyz;
    r0.w = -r2.y * r2.y + 1;
    r2.y = r1.x * r0.w + r2.w;
    r3.w = r2.w * r2.w;
    r4.w = 0.318309873 * r3.w;
    r6.w = 0.5 * r2.w;
    r7.w = r2.w * -0.337748349 + 1;
    r8.x = 1 + -r1.x;
    r8.y = r8.x * r8.x;
    r8.y = r8.y * r8.y;
    r8.x = r8.y * r8.x;
    r8.yzw = float3(1,1,1) + -r4.xyz;
    r9.yzw = float3(0,0,0);
    r10.xyz = float3(0,0,0);
    r10.w = r0.x;
    [loop] while (true) {
      r11.x = cmp((int)r10.w >= (int)r0.y);
      [branch] if (r11.x != 0) break;
      r11.x = _BT_LinkListBuffer[r10.w].val[0/4];
      r12.x = _BT_LightBuffer[r11.x].val[0/4];
      r12.y = _BT_LightBuffer[r11.x].val[0/4+1];
      r12.z = _BT_LightBuffer[r11.x].val[0/4+2];
      r12.w = _BT_LightBuffer[r11.x].val[0/4+3];
      r11.y = _BT_LightBuffer[r11.x].val[32/4];
      r12.xyz = -r12.xyz + r5.xyz;
      r11.z = dot(r12.xyz, r12.xyz);
      r11.w = r12.w * r12.w;
      r13.x = max(0.100000001, r11.z);
      r11.w = r13.x / r11.w;
      r11.w = -r11.w * r11.w + 1;
      r11.w = max(0, r11.w);
      r11.w = r11.w * r11.w;
      r11.y = r12.w * r11.y + r13.x;
      r11.y = 1 / r11.y;
      r11.y = r11.y * r11.w;
      r11.w = cmp(r11.y != 0.000000);
      [branch] if (r11.w != 0) {
        r13.x = _BT_LightBuffer[r11.x].val[16/4];
        r13.y = _BT_LightBuffer[r11.x].val[16/4+1];
        r13.z = _BT_LightBuffer[r11.x].val[16/4+2];
        r11.x = _BT_LightBuffer[r11.x].val[60/4];
        r11.z = rsqrt(r11.z);
        r14.xyz = r12.xyz * r11.zzz;
        r13.xyz = r13.xyz * r11.yyy;
        r11.y = dot(r3.xyz, -r14.xyz);
        r9.x = max(0, r11.y);
        r11.y = 0.800000012 + r11.y;
        r11.y = saturate(0.555555582 * r11.y);
        r11.y = r11.y * r11.y;
        r11.y = r11.y * r11.y;
        r11.y = r11.y * 1.38888896 + -r9.x;
        r15.x = r2.z * r11.y + r9.x;
        r11.y = saturate(dot(r3.xyz, r14.xyz));
        r16.xyz = r11.yyy * r1.yzw;
        r16.xyz = r16.xyz * r13.xyz;
        r16.xyz = r16.xyz * r2.zzz;
        r15.yzw = float3(0.25,0.25,0.25) * r16.xyz;
        r15.xyzw = r2.xxxx ? r15.xyzw : r9.xyzw;
        r9.x = cmp(0 != r11.x);
        r11.xyz = -r12.xyz * r11.zzz + -r6.xyz;
        r11.w = dot(r11.xyz, r11.xyz);
        r11.w = max(0.00100000005, r11.w);
        r11.w = rsqrt(r11.w);
        r11.xyz = r11.xyz * r11.www;
        r11.w = dot(r7.xyz, r11.xyz);
        r11.x = dot(-r14.xyz, r11.xyz);
        r11.xw = max(float2(0,0), r11.xw);
        r11.y = r15.x * r0.w + r2.w;
        r11.y = r11.y * r1.x;
        r11.y = r15.x * r2.y + r11.y;
        r11.y = 9.99999975e-006 + r11.y;
        r11.y = 0.5 / r11.y;
        r11.z = r11.w * r3.w + -r11.w;
        r11.z = r11.z * r11.w + 1;
        r11.z = r11.z * r11.z + 1.00000001e-007;
        r11.z = r4.w / r11.z;
        r11.w = 1 + -r15.x;
        r12.x = r11.w * r11.w;
        r12.x = r12.x * r12.x;
        r11.w = r12.x * r11.w;
        r12.x = r11.x + r11.x;
        r12.x = r12.x * r11.x;
        r12.x = r12.x * r2.w + r6.w;
        r12.x = -1 + r12.x;
        r11.w = r12.x * r11.w + 1;
        r12.x = r12.x * r8.x + 1;
        r11.w = r12.x * r11.w;
        r11.w = r11.w * r7.w;
        r11.y = r11.y * r11.z;
        r11.y = 3.14159274 * r11.y;
        r11.yz = r11.yw * r15.xx;
        r11.y = max(0, r11.y);
        r12.xyz = r13.xyz * r11.zzz;
        r11.yzw = r11.yyy * r13.xyz;
        r11.x = 1 + -r11.x;
        r12.w = r11.x * r11.x;
        r12.w = r12.w * r12.w;
        r11.x = r12.w * r11.x;
        r13.xyz = r8.yzw * r11.xxx + r4.xyz;
        r11.xyz = r13.xyz * r11.yzw;
        r9.x = r9.x ? 1.000000 : 0;
        r11.xyz = r11.xyz * r9.xxx;
        r11.xyz = r1.yzw * r12.xyz + r11.xyz;
        r11.xyz = r15.yzw + r11.xyz;
      } else {
        r11.xyz = float3(0,0,0);
      }
      r10.xyz = r11.xyz + r10.xyz;
      r10.w = (int)r10.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r0.y = sqrt(_BT_ShadowMapParams.z);
    r0.z = _BT_MaxShadowDist * _BT_MaxShadowDist;
    r9.x = 0.5 * r0.z;
    r9.x = 1 / r9.x;
    r11.yzw = float3(0,0,0);
    r12.xz = _BT_ShadowMap_TexelSize.xx;
    r12.y = 0.142857149;
    r13.xz = _BT_ShadowMap_TexelSize.yy;
    r13.y = 0.142857149;
    r14.y = 7;
    r9.yzw = r10.xyz;
    r12.w = r10.w;
    [loop] while (true) {
      r13.w = cmp((int)r12.w >= (int)r0.x);
      [branch] if (r13.w != 0) break;
      r13.w = _BT_LinkListBuffer[r12.w].val[0/4];
      r15.x = _BT_LightBuffer[r13.w].val[0/4];
      r15.y = _BT_LightBuffer[r13.w].val[0/4+1];
      r15.z = _BT_LightBuffer[r13.w].val[0/4+2];
      r15.w = _BT_LightBuffer[r13.w].val[0/4+3];
      r14.w = _BT_LightBuffer[r13.w].val[32/4];
      r16.x = _BT_LightBuffer[r13.w].val[48/4];
      r16.y = _BT_LightBuffer[r13.w].val[48/4+1];
      r16.z = _BT_LightBuffer[r13.w].val[48/4+2];
      r16.w = _BT_LightBuffer[r13.w].val[48/4+3];
      r17.x = (uint)r13.w << 2;
      r14.w = frac(r14.w);
      r17.yzw = -r15.xyz + r5.xyz;
      r18.x = dot(r17.yzw, r17.yzw);
      r18.y = r15.w * r15.w;
      r19.xyzw = float4(_BT_LightMatrix[(uint)(r17.x) / 4u][0][1], _BT_LightMatrix[(uint)(r17.x) / 4u][1][1], _BT_LightMatrix[(uint)(r17.x) / 4u][2][1], _BT_LightMatrix[(uint)(r17.x) / 4u][3][1]) * r5.yyyy;
      r19.xyzw = float4(_BT_LightMatrix[(uint)(r17.x) / 4u][0][0], _BT_LightMatrix[(uint)(r17.x) / 4u][1][0], _BT_LightMatrix[(uint)(r17.x) / 4u][2][0], _BT_LightMatrix[(uint)(r17.x) / 4u][3][0]) * r5.xxxx + r19.xyzw;
      r19.xyzw = float4(_BT_LightMatrix[(uint)(r17.x) / 4u][0][2], _BT_LightMatrix[(uint)(r17.x) / 4u][1][2], _BT_LightMatrix[(uint)(r17.x) / 4u][2][2], _BT_LightMatrix[(uint)(r17.x) / 4u][3][2]) * r5.zzzz + r19.xyzw;
      r19.xyzw = float4(_BT_LightMatrix[(uint)(r17.x) / 4u][0][3], _BT_LightMatrix[(uint)(r17.x) / 4u][1][3], _BT_LightMatrix[(uint)(r17.x) / 4u][2][3], _BT_LightMatrix[(uint)(r17.x) / 4u][3][3]) * r5.wwww + r19.xyzw;
      r17.x = max(0.100000001, r18.x);
      r18.y = r17.x / r18.y;
      r18.y = -r18.y * r18.y + 1;
      r18.y = max(0, r18.y);
      r18.y = r18.y * r18.y;
      r14.w = r15.w * r14.w + r17.x;
      r14.w = 1 / r14.w;
      r14.w = r14.w * r18.y;
      r18.yzw = r19.xyz / r19.www;
      r15.w = cmp(0 >= r18.w);
      r19.xy = cmp(float2(1,1) < r18.yz);
      r15.w = (int)r15.w | (int)r19.x;
      r19.xz = cmp(r18.yz < float2(-1,-1));
      r15.w = (int)r15.w | (int)r19.x;
      r15.w = (int)r19.y | (int)r15.w;
      r15.w = (int)r19.z | (int)r15.w;
      [branch] if (r15.w == 0) {
        r15.w = r16.x / r16.y;
        r15.w = min(0.99000001, r15.w);
        r16.x = dot(r18.yz, r18.yz);
        r16.x = sqrt(r16.x);
        r16.x = min(1, r16.x);
        r15.w = -1 + r15.w;
        r16.x = -1 + r16.x;
        r15.w = 1 / r15.w;
        r15.w = r16.x * r15.w;
        r15.w = min(1, r15.w);
        r16.x = r15.w * -2 + 3;
        r15.w = r15.w * r15.w;
        r15.w = r16.x * r15.w;
        r16.x = cmp(r15.w != 0.000000);
        [branch] if (r16.x != 0) {
          r16.x = cmp(-1 < r16.z);
          [branch] if (r16.x != 0) {
            r16.xy = r18.yz * float2(0.5,0.5) + float2(0.5,0.5);
            r15.xyz = _WorldSpaceCameraPos.xyz + -r15.xyz;
            r15.x = dot(r15.xyz, r15.xyz);
            r15.y = r16.z / r0.y;
            r15.z = cmp(r15.y >= -r15.y);
            r16.z = frac(abs(r15.y));
            r15.z = r15.z ? r16.z : -r16.z;
            r15.z = r15.z * r0.y;
            r15.y = floor(r15.y);
            r19.xy = r15.zy / r0.yy;
            r15.yz = r16.xy / r0.yy;
            r15.yz = r15.yz + r19.xy;
            r16.x = r18.w + abs(r16.w);
            r15.yz = r15.yz * _BT_ShadowMap_TexelSize.zw + float2(0.5,0.5);
            r16.yz = floor(r15.yz);
            r16.yz = float2(-0.5,-0.5) + r16.yz;
            r15.yz = frac(r15.yz);
            r17.x = 3 * r15.y;
            r18.yz = -r15.yz * float2(3,3) + float2(4,4);
            r19.xy = r15.yz * float2(3,3) + float2(1,1);
            r19.zw = -r15.yz * float2(2,2) + float2(3,3);
            r18.yw = r19.zw / r18.yz;
            r20.xy = float2(-2,-2) + r18.yw;
            r18.yw = float2(3,3) + r15.yz;
            r21.xy = _BT_ShadowMap_TexelSize.xy * r18.yw;
            r15.yz = r15.yz / r19.xy;
            r15.yz = float2(2,2) + r15.yz;
            r20.z = r21.x;
            r20.w = r15.y;
            r22.xyz = r20.xzw * r12.xyz;
            r21.z = r20.y;
            r21.w = r15.z;
            r20.xyw = r21.zyw * r13.xyz;
            r14.xz = r17.xx * float2(-1,1) + float2(4,1);
            r18.yzw = r18.zzz * r14.xyz;
            r22.w = r20.x;
            r21.xyzw = r16.yzyz * _BT_ShadowMap_TexelSize.xyxy + r22.xwyw;
            r15.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.xy, r16.x).x;
            r15.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.zw, r16.x).x;
            r15.z = r18.z * r15.z;
            r15.y = r18.y * r15.y + r15.z;
            r18.yz = r16.yz * _BT_ShadowMap_TexelSize.xy + r22.zw;
            r15.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r18.yz, r16.x).x;
            r15.y = r18.w * r15.z + r15.y;
            r18.yz = float2(7,7) * r14.xz;
            r20.z = r22.x;
            r21.xyzw = r16.yzyz * _BT_ShadowMap_TexelSize.xyxy + r20.zyzw;
            r15.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.xy, r16.x).x;
            r15.y = r18.y * r15.z + r15.y;
            r20.xz = r22.yz;
            r22.xyzw = r16.yzyz * _BT_ShadowMap_TexelSize.xyxy + r20.xyzy;
            r15.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r22.xy, r16.x).x;
            r15.y = r15.z * 49 + r15.y;
            r15.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r22.zw, r16.x).x;
            r15.y = r18.z * r15.z + r15.y;
            r18.yzw = r19.yyy * r14.xyz;
            r14.x = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.zw, r16.x).x;
            r14.x = r18.y * r14.x + r15.y;
            r19.xyzw = r16.yzyz * _BT_ShadowMap_TexelSize.xyxy + r20.xwzw;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.xy, r16.x).x;
            r14.x = r18.z * r14.z + r14.x;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.zw, r16.x).x;
            r14.x = r18.w * r14.z + r14.x;
            r14.z = 0.0069444445 * r14.x;
            r15.x = -r0.z * 0.5 + r15.x;
            r15.x = saturate(r15.x * r9.x);
            r15.y = r15.x * -2 + 3;
            r15.x = r15.x * r15.x;
            r15.x = r15.y * r15.x;
            r14.x = -r14.x * 0.0069444445 + 1;
            r14.x = r15.x * r14.x + r14.z;
            r15.w = r15.w * r14.x;
          }
        } else {
          r15.w = 0;
        }
      } else {
        r15.w = 0;
      }
      r14.x = r15.w * r14.w;
      r14.z = cmp(r14.x != 0.000000);
      [branch] if (r14.z != 0) {
        r15.x = _BT_LightBuffer[r13.w].val[16/4];
        r15.y = _BT_LightBuffer[r13.w].val[16/4+1];
        r15.z = _BT_LightBuffer[r13.w].val[16/4+2];
        r13.w = rsqrt(r18.x);
        r16.xyz = r17.yzw * r13.www;
        r14.xzw = r15.xyz * r14.xxx;
        r15.x = dot(r3.xyz, -r16.xyz);
        r11.x = max(0, r15.x);
        r15.x = 0.800000012 + r15.x;
        r15.x = saturate(0.555555582 * r15.x);
        r15.x = r15.x * r15.x;
        r15.x = r15.x * r15.x;
        r15.x = r15.x * 1.38888896 + -r11.x;
        r15.x = r2.z * r15.x + r11.x;
        r17.x = saturate(dot(r3.xyz, r16.xyz));
        r18.xyz = r17.xxx * r1.yzw;
        r18.xyz = r18.xyz * r14.xzw;
        r18.xyz = r18.xyz * r2.zzz;
        r15.yzw = float3(0.25,0.25,0.25) * r18.xyz;
        r15.xyzw = r2.xxxx ? r15.xyzw : r11.xyzw;
        r11.x = cmp(0 != r16.w);
        r17.xyz = -r17.yzw * r13.www + -r6.xyz;
        r13.w = dot(r17.xyz, r17.xyz);
        r13.w = max(0.00100000005, r13.w);
        r13.w = rsqrt(r13.w);
        r17.xyz = r17.xyz * r13.www;
        r13.w = dot(r7.xyz, r17.xyz);
        r13.w = max(0, r13.w);
        r16.x = dot(-r16.xyz, r17.xyz);
        r16.x = max(0, r16.x);
        r16.y = r15.x * r0.w + r2.w;
        r16.y = r16.y * r1.x;
        r16.y = r15.x * r2.y + r16.y;
        r16.y = 9.99999975e-006 + r16.y;
        r16.y = 0.5 / r16.y;
        r16.z = r13.w * r3.w + -r13.w;
        r13.w = r16.z * r13.w + 1;
        r13.w = r13.w * r13.w + 1.00000001e-007;
        r13.w = r4.w / r13.w;
        r16.z = 1 + -r15.x;
        r16.w = r16.z * r16.z;
        r16.w = r16.w * r16.w;
        r16.z = r16.w * r16.z;
        r16.w = r16.x + r16.x;
        r16.w = r16.w * r16.x;
        r16.w = r16.w * r2.w + r6.w;
        r16.w = -1 + r16.w;
        r16.z = r16.w * r16.z + 1;
        r16.w = r16.w * r8.x + 1;
        r16.z = r16.z * r16.w;
        r16.z = r16.z * r7.w;
        r13.w = r16.y * r13.w;
        r13.w = 3.14159274 * r13.w;
        r13.w = r13.w * r15.x;
        r13.w = max(0, r13.w);
        r15.x = r16.z * r15.x;
        r16.yzw = r15.xxx * r14.xzw;
        r14.xzw = r13.www * r14.xzw;
        r13.w = 1 + -r16.x;
        r15.x = r13.w * r13.w;
        r15.x = r15.x * r15.x;
        r13.w = r15.x * r13.w;
        r17.xyz = r8.yzw * r13.www + r4.xyz;
        r14.xzw = r17.xyz * r14.xzw;
        r11.x = r11.x ? 1.000000 : 0;
        r14.xzw = r14.xzw * r11.xxx;
        r14.xzw = r1.yzw * r16.yzw + r14.xzw;
        r14.xzw = r15.yzw + r14.xzw;
      } else {
        r14.xzw = float3(0,0,0);
      }
      r9.yzw = r14.xzw + r9.yzw;
      r12.w = (int)r12.w + 1;
    }
    r0.xyz = float3(8,8,8) * r9.yzw;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 42a7d45dd9e446fa: 1 retail keyword combination(s)
void ps_42a7d45dd9e446fa_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyzw = _BT_ListEntries.Load(r0.xywz).xyzw;
  r1.y = cmp((int)r0.x >= 0);
  [branch] if (r1.y != 0) {
    r1.yzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyz;
    r2.xy = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyz = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyz;
    r4.xyz = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r1.yzw;
    r4.xyz = r2.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r2.x = -r2.x * 0.959999979 + 0.959999979;
    r1.yzw = r2.xxx * r1.yzw;
    r2.xzw = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r3.x = dot(r2.xzw, r2.xzw);
    r3.x = rsqrt(r3.x);
    r2.xzw = r3.xxx * r2.xzw;
    r3.z = 1 + -r1.x;
    r3.xy = v0.zw;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r5.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r3.yyyy;
    r5.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r3.xxxx + r5.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r3.zzzz + r5.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r3.xyzw;
    r3.xyz = r3.xyz / r3.www;
    r5.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r3.yyyy;
    r5.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r3.xxxx + r5.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r3.zzzz + r5.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r3.xyzw;
    r5.xyz = -_WorldSpaceCameraPos.xyz + r3.xyz;
    r1.x = dot(r5.xyz, r5.xyz);
    r1.x = rsqrt(r1.x);
    r6.xyz = r5.xyz * r1.xxx;
    r4.w = dot(r2.xzw, -r6.xyz);
    r5.w = max(0, r4.w);
    r6.w = min(1, r5.w);
    r0.y = (int)r0.y + (int)r0.x;
    r2.y = 1 + -r2.y;
    r7.x = r2.y * r2.y;
    r7.y = cmp(r4.w < 0);
    r7.z = 9.99999975e-006 + -r4.w;
    r8.xyz = -r6.xyz * r7.zzz + r2.xzw;
    r7.yzw = r7.yyy ? r8.xyz : r2.xzw;
    r8.x = -r2.y * r2.y + 1;
    r8.y = r6.w * r8.x + r7.x;
    r8.z = r7.x * r7.x;
    r8.w = 0.318309873 * r8.z;
    r9.x = 0.5 * r7.x;
    r9.y = r7.x * -0.337748349 + 1;
    r9.z = 1 + -r6.w;
    r9.w = r9.z * r9.z;
    r9.w = r9.w * r9.w;
    r9.z = r9.w * r9.z;
    r10.xyz = float3(1,1,1) + -r4.xyz;
    r11.xyz = float3(0,0,0);
    r9.w = r0.x;
    [loop] while (true) {
      r10.w = cmp((int)r9.w >= (int)r0.y);
      [branch] if (r10.w != 0) break;
      r10.w = _BT_LinkListBuffer[r9.w].val[0/4];
      r12.x = _BT_LightBuffer[r10.w].val[0/4];
      r12.y = _BT_LightBuffer[r10.w].val[0/4+1];
      r12.z = _BT_LightBuffer[r10.w].val[0/4+2];
      r12.w = _BT_LightBuffer[r10.w].val[0/4+3];
      r11.w = _BT_LightBuffer[r10.w].val[32/4];
      r12.xyz = -r12.xyz + r3.xyz;
      r13.x = dot(r12.xyz, r12.xyz);
      r13.y = r12.w * r12.w;
      r13.z = max(0.100000001, r13.x);
      r13.y = r13.z / r13.y;
      r13.y = -r13.y * r13.y + 1;
      r13.y = max(0, r13.y);
      r13.y = r13.y * r13.y;
      r11.w = r12.w * r11.w + r13.z;
      r11.w = 1 / r11.w;
      r11.w = r11.w * r13.y;
      r12.w = cmp(r11.w != 0.000000);
      [branch] if (r12.w != 0) {
        r13.y = _BT_LightBuffer[r10.w].val[16/4];
        r13.z = _BT_LightBuffer[r10.w].val[16/4+1];
        r13.w = _BT_LightBuffer[r10.w].val[16/4+2];
        r10.w = _BT_LightBuffer[r10.w].val[60/4];
        r12.w = rsqrt(r13.x);
        r14.xyz = r12.xyz * r12.www;
        r13.xyz = r13.yzw * r11.www;
        r11.w = dot(r2.xzw, -r14.xyz);
        r11.w = max(0, r11.w);
        r10.w = cmp(r10.w >= 0);
        r12.xyz = -r12.xyz * r12.www + -r6.xyz;
        r12.w = dot(r12.xyz, r12.xyz);
        r12.w = max(0.00100000005, r12.w);
        r12.w = rsqrt(r12.w);
        r12.xyz = r12.xyz * r12.www;
        r12.w = dot(r7.yzw, r12.xyz);
        r12.x = dot(-r14.xyz, r12.xyz);
        r12.xw = max(float2(0,0), r12.xw);
        r12.y = r11.w * r8.x + r7.x;
        r12.y = r12.y * r6.w;
        r12.y = r11.w * r8.y + r12.y;
        r12.y = 9.99999975e-006 + r12.y;
        r12.y = 0.5 / r12.y;
        r12.z = r12.w * r8.z + -r12.w;
        r12.z = r12.z * r12.w + 1;
        r12.z = r12.z * r12.z + 1.00000001e-007;
        r12.z = r8.w / r12.z;
        r12.w = 1 + -r11.w;
        r13.w = r12.w * r12.w;
        r13.w = r13.w * r13.w;
        r12.w = r13.w * r12.w;
        r13.w = r12.x + r12.x;
        r13.w = r13.w * r12.x;
        r13.w = r13.w * r7.x + r9.x;
        r13.w = -1 + r13.w;
        r12.w = r13.w * r12.w + 1;
        r13.w = r13.w * r9.z + 1;
        r12.w = r13.w * r12.w;
        r12.w = r12.w * r9.y;
        r12.y = r12.y * r12.z;
        r12.y = r12.y * r11.w;
        r12.y = 3.14159274 * r12.y;
        r12.y = max(0, r12.y);
        r11.w = r12.w * r11.w;
        r14.xyz = r13.xyz * r11.www;
        r12.yzw = r12.yyy * r13.xyz;
        r11.w = 1 + -r12.x;
        r12.x = r11.w * r11.w;
        r12.x = r12.x * r12.x;
        r11.w = r12.x * r11.w;
        r13.xyz = r10.xyz * r11.www + r4.xyz;
        r12.xyz = r13.xyz * r12.yzw;
        r10.w = r10.w ? 1.000000 : 0;
        r12.xyz = r12.xyz * r10.www;
        r12.xyz = r1.yzw * r14.xyz + r12.xyz;
      } else {
        r12.xyz = float3(0,0,0);
      }
      r11.xyz = r12.xyz + r11.xyz;
      r9.w = (int)r9.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r0.y = sqrt(_BT_ShadowMapParams.z);
    r0.z = _BT_MaxShadowDist * _BT_MaxShadowDist;
    r10.w = 0.5 * r0.z;
    r10.w = 1 / r10.w;
    r12.xz = _BT_ShadowMap_TexelSize.xx;
    r12.y = 0.142857149;
    r13.xz = _BT_ShadowMap_TexelSize.yy;
    r13.y = 0.142857149;
    r14.y = 7;
    r15.xyz = r11.xyz;
    r11.w = r9.w;
    [loop] while (true) {
      r12.w = cmp((int)r11.w >= (int)r0.x);
      [branch] if (r12.w != 0) break;
      r12.w = _BT_LinkListBuffer[r11.w].val[0/4];
      r16.x = _BT_LightBuffer[r12.w].val[0/4];
      r16.y = _BT_LightBuffer[r12.w].val[0/4+1];
      r16.z = _BT_LightBuffer[r12.w].val[0/4+2];
      r16.w = _BT_LightBuffer[r12.w].val[0/4+3];
      r13.w = _BT_LightBuffer[r12.w].val[32/4];
      r17.x = _BT_LightBuffer[r12.w].val[48/4];
      r17.y = _BT_LightBuffer[r12.w].val[48/4+1];
      r17.z = _BT_LightBuffer[r12.w].val[48/4+2];
      r17.w = _BT_LightBuffer[r12.w].val[48/4+3];
      r14.w = (uint)r12.w << 2;
      r13.w = frac(r13.w);
      r18.xyz = -r16.xyz + r3.xyz;
      r15.w = dot(r18.xyz, r18.xyz);
      r18.w = r16.w * r16.w;
      r19.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][1], _BT_LightMatrix[(uint)(r14.w) / 4u][1][1], _BT_LightMatrix[(uint)(r14.w) / 4u][2][1], _BT_LightMatrix[(uint)(r14.w) / 4u][3][1]) * r3.yyyy;
      r19.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][0], _BT_LightMatrix[(uint)(r14.w) / 4u][1][0], _BT_LightMatrix[(uint)(r14.w) / 4u][2][0], _BT_LightMatrix[(uint)(r14.w) / 4u][3][0]) * r3.xxxx + r19.xyzw;
      r19.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][2], _BT_LightMatrix[(uint)(r14.w) / 4u][1][2], _BT_LightMatrix[(uint)(r14.w) / 4u][2][2], _BT_LightMatrix[(uint)(r14.w) / 4u][3][2]) * r3.zzzz + r19.xyzw;
      r19.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][3], _BT_LightMatrix[(uint)(r14.w) / 4u][1][3], _BT_LightMatrix[(uint)(r14.w) / 4u][2][3], _BT_LightMatrix[(uint)(r14.w) / 4u][3][3]) * r3.wwww + r19.xyzw;
      r14.w = max(0.100000001, r15.w);
      r18.w = r14.w / r18.w;
      r18.w = -r18.w * r18.w + 1;
      r18.w = max(0, r18.w);
      r18.w = r18.w * r18.w;
      r13.w = r16.w * r13.w + r14.w;
      r13.w = 1 / r13.w;
      r13.w = r13.w * r18.w;
      r19.xyz = r19.xyz / r19.www;
      r14.w = cmp(0 >= r19.z);
      r20.xy = cmp(float2(1,1) < r19.xy);
      r14.w = (int)r14.w | (int)r20.x;
      r20.xz = cmp(r19.xy < float2(-1,-1));
      r14.w = (int)r14.w | (int)r20.x;
      r14.w = (int)r20.y | (int)r14.w;
      r14.w = (int)r20.z | (int)r14.w;
      [branch] if (r14.w == 0) {
        r14.w = r17.x / r17.y;
        r14.w = min(0.99000001, r14.w);
        r16.w = dot(r19.xy, r19.xy);
        r16.w = sqrt(r16.w);
        r16.w = min(1, r16.w);
        r14.w = -1 + r14.w;
        r16.w = -1 + r16.w;
        r14.w = 1 / r14.w;
        r14.w = r16.w * r14.w;
        r14.w = min(1, r14.w);
        r16.w = r14.w * -2 + 3;
        r14.w = r14.w * r14.w;
        r14.w = r16.w * r14.w;
        r16.w = cmp(r14.w != 0.000000);
        [branch] if (r16.w != 0) {
          r16.w = cmp(-1 < r17.z);
          [branch] if (r16.w != 0) {
            r17.xy = r19.xy * float2(0.5,0.5) + float2(0.5,0.5);
            r16.xyz = _WorldSpaceCameraPos.xyz + -r16.xyz;
            r16.x = dot(r16.xyz, r16.xyz);
            r16.y = r17.z / r0.y;
            r16.z = cmp(r16.y >= -r16.y);
            r16.w = frac(abs(r16.y));
            r16.z = r16.z ? r16.w : -r16.w;
            r16.z = r16.z * r0.y;
            r16.y = floor(r16.y);
            r19.xy = r16.zy / r0.yy;
            r16.yz = r17.xy / r0.yy;
            r16.yz = r16.yz + r19.xy;
            r16.w = r19.z + abs(r17.w);
            r16.yz = r16.yz * _BT_ShadowMap_TexelSize.zw + float2(0.5,0.5);
            r17.xy = floor(r16.yz);
            r17.xy = float2(-0.5,-0.5) + r17.xy;
            r16.yz = frac(r16.yz);
            r17.z = 3 * r16.y;
            r19.xy = -r16.yz * float2(3,3) + float2(4,4);
            r19.zw = r16.yz * float2(3,3) + float2(1,1);
            r20.xy = -r16.yz * float2(2,2) + float2(3,3);
            r20.xy = r20.xy / r19.xy;
            r20.xy = float2(-2,-2) + r20.xy;
            r21.xy = float2(3,3) + r16.yz;
            r21.xy = _BT_ShadowMap_TexelSize.xy * r21.xy;
            r16.yz = r16.yz / r19.zw;
            r16.yz = float2(2,2) + r16.yz;
            r20.z = r21.x;
            r20.w = r16.y;
            r22.xyz = r20.xzw * r12.xyz;
            r21.z = r20.y;
            r21.w = r16.z;
            r20.xyw = r21.zyw * r13.xyz;
            r14.xz = r17.zz * float2(-1,1) + float2(4,1);
            r19.xyz = r19.yyy * r14.xyz;
            r22.w = r20.x;
            r21.xyzw = r17.xyxy * _BT_ShadowMap_TexelSize.xyxy + r22.xwyw;
            r16.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.xy, r16.w).x;
            r16.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.zw, r16.w).x;
            r16.z = r19.y * r16.z;
            r16.y = r19.x * r16.y + r16.z;
            r19.xy = r17.xy * _BT_ShadowMap_TexelSize.xy + r22.zw;
            r16.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.xy, r16.w).x;
            r16.y = r19.z * r16.z + r16.y;
            r19.xy = float2(7,7) * r14.xz;
            r20.z = r22.x;
            r21.xyzw = r17.xyxy * _BT_ShadowMap_TexelSize.xyxy + r20.zyzw;
            r16.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.xy, r16.w).x;
            r16.y = r19.x * r16.z + r16.y;
            r20.xz = r22.yz;
            r22.xyzw = r17.xyxy * _BT_ShadowMap_TexelSize.xyxy + r20.xyzy;
            r16.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r22.xy, r16.w).x;
            r16.y = r16.z * 49 + r16.y;
            r16.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r22.zw, r16.w).x;
            r16.y = r19.y * r16.z + r16.y;
            r19.xyz = r19.www * r14.xyz;
            r14.x = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.zw, r16.w).x;
            r14.x = r19.x * r14.x + r16.y;
            r20.xyzw = r17.xyxy * _BT_ShadowMap_TexelSize.xyxy + r20.xwzw;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.xy, r16.w).x;
            r14.x = r19.y * r14.z + r14.x;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.zw, r16.w).x;
            r14.x = r19.z * r14.z + r14.x;
            r14.z = 0.0069444445 * r14.x;
            r16.x = -r0.z * 0.5 + r16.x;
            r16.x = saturate(r16.x * r10.w);
            r16.y = r16.x * -2 + 3;
            r16.x = r16.x * r16.x;
            r16.x = r16.y * r16.x;
            r14.x = -r14.x * 0.0069444445 + 1;
            r14.x = r16.x * r14.x + r14.z;
            r14.w = r14.w * r14.x;
          }
        } else {
          r14.w = 0;
        }
      } else {
        r14.w = 0;
      }
      r13.w = r14.w * r13.w;
      r14.x = cmp(r13.w != 0.000000);
      [branch] if (r14.x != 0) {
        r14.x = _BT_LightBuffer[r12.w].val[16/4];
        r14.z = _BT_LightBuffer[r12.w].val[16/4+1];
        r14.w = _BT_LightBuffer[r12.w].val[16/4+2];
        r12.w = rsqrt(r15.w);
        r16.xyz = r18.xyz * r12.www;
        r14.xzw = r14.xzw * r13.www;
        r13.w = dot(r2.xzw, -r16.xyz);
        r13.w = max(0, r13.w);
        r15.w = cmp(r17.w >= 0);
        r17.xyz = -r18.xyz * r12.www + -r6.xyz;
        r12.w = dot(r17.xyz, r17.xyz);
        r12.w = max(0.00100000005, r12.w);
        r12.w = rsqrt(r12.w);
        r17.xyz = r17.xyz * r12.www;
        r12.w = dot(r7.yzw, r17.xyz);
        r12.w = max(0, r12.w);
        r16.x = dot(-r16.xyz, r17.xyz);
        r16.x = max(0, r16.x);
        r16.y = r13.w * r8.x + r7.x;
        r16.y = r16.y * r6.w;
        r16.y = r13.w * r8.y + r16.y;
        r16.y = 9.99999975e-006 + r16.y;
        r16.y = 0.5 / r16.y;
        r16.z = r12.w * r8.z + -r12.w;
        r12.w = r16.z * r12.w + 1;
        r12.w = r12.w * r12.w + 1.00000001e-007;
        r12.w = r8.w / r12.w;
        r16.z = 1 + -r13.w;
        r16.w = r16.z * r16.z;
        r16.w = r16.w * r16.w;
        r16.z = r16.w * r16.z;
        r16.w = r16.x + r16.x;
        r16.w = r16.w * r16.x;
        r16.w = r16.w * r7.x + r9.x;
        r16.w = -1 + r16.w;
        r16.z = r16.w * r16.z + 1;
        r16.w = r16.w * r9.z + 1;
        r16.z = r16.z * r16.w;
        r16.z = r16.z * r9.y;
        r12.w = r16.y * r12.w;
        r12.w = r12.w * r13.w;
        r12.w = 3.14159274 * r12.w;
        r12.w = max(0, r12.w);
        r13.w = r16.z * r13.w;
        r16.yzw = r14.xzw * r13.www;
        r14.xzw = r12.www * r14.xzw;
        r12.w = 1 + -r16.x;
        r13.w = r12.w * r12.w;
        r13.w = r13.w * r13.w;
        r12.w = r13.w * r12.w;
        r17.xyz = r10.xyz * r12.www + r4.xyz;
        r14.xzw = r17.xyz * r14.xzw;
        r12.w = r15.w ? 1.000000 : 0;
        r14.xzw = r14.xzw * r12.www;
        r14.xzw = r1.yzw * r16.yzw + r14.xzw;
      } else {
        r14.xzw = float3(0,0,0);
      }
      r15.xyz = r15.xyz + r14.xzw;
      r11.w = (int)r11.w + 1;
    }
    r0.x = (int)r0.w + (int)r0.x;
    r0.yzw = float3(25,25,25) * r1.yzw;
    r1.y = r4.w + r4.w;
    r1.yzw = r2.xzw * -r1.yyy + -r6.xyz;
    r3.w = -r7.x * 0.5 + 1;
    r4.w = r5.w * r3.w + r9.x;
    r6.x = r7.x * r7.x + -1;
    r6.y = r8.z * r8.z;
    r5.w = 1 + -r5.w;
    r6.z = r5.w * r5.w;
    r6.z = r6.z * r6.z;
    r5.w = r6.z * r5.w;
    r7.xyz = r15.xyz;
    r6.z = r11.w;
    [loop] while (true) {
      r6.w = cmp((int)r6.z >= (int)r0.x);
      [branch] if (r6.w != 0) break;
      r6.w = _BT_LinkListBuffer[r6.z].val[0/4];
      r8.x = _BT_LightBuffer[r6.w].val[0/4];
      r8.y = _BT_LightBuffer[r6.w].val[0/4+1];
      r8.z = _BT_LightBuffer[r6.w].val[0/4+2];
      r8.w = _BT_LightBuffer[r6.w].val[0/4+3];
      r9.y = _BT_LightBuffer[r6.w].val[16/4];
      r9.z = _BT_LightBuffer[r6.w].val[16/4+1];
      r9.w = _BT_LightBuffer[r6.w].val[16/4+2];
      r7.w = _BT_LightBuffer[r6.w].val[32/4];
      r11.x = _BT_LightBuffer[r6.w].val[48/4];
      r11.y = _BT_LightBuffer[r6.w].val[48/4+1];
      r11.z = _BT_LightBuffer[r6.w].val[48/4+2];
      r6.w = r8.w * r8.w;
      r6.w = 1 / r6.w;
      r11.xyz = r11.xyz * r7.www + r8.xyz;
      r8.xyz = r8.xyz + -r3.xyz;
      r11.xyz = r11.xyz + -r3.xyz;
      r7.w = dot(r8.xyz, r8.xyz);
      r8.w = sqrt(r7.w);
      r10.w = dot(r11.xyz, r11.xyz);
      r10.w = sqrt(r10.w);
      r12.x = dot(r8.xyz, r2.xzw);
      r12.y = r8.w + r8.w;
      r12.x = r12.x / r12.y;
      r12.y = dot(r11.xyz, r2.xzw);
      r12.z = r10.w + r10.w;
      r12.y = r12.y / r12.z;
      r12.x = saturate(r12.x + r12.y);
      r12.yzw = r11.xyz + -r8.xyz;
      r13.x = dot(r1.yzw, r8.xyz);
      r13.y = dot(r1.yzw, r12.yzw);
      r13.z = dot(r8.xyz, r12.yzw);
      r13.w = dot(r12.yzw, r12.yzw);
      r7.w = r13.y * r7.w;
      r7.w = r13.z * r13.x + -r7.w;
      r13.x = r13.w * r13.x;
      r13.x = r13.z * r13.y + -r13.x;
      r7.w = saturate(r7.w / r13.x);
      r13.xyz = r12.zwy * r8.zxy;
      r13.xyz = r8.yzx * r12.wyz + -r13.xyz;
      r14.xyz = r12.wyz * r1.zwy;
      r14.xyz = r12.zwy * r1.wyz + -r14.xyz;
      r13.x = dot(r13.xyz, r14.xyz);
      r13.y = 1 + -r7.w;
      r13.x = cmp(r13.x >= 0);
      r13.x = r13.x ? 1.000000 : 0;
      r7.w = -r13.y + r7.w;
      r7.w = r13.x * r7.w + r13.y;
      r12.yzw = r12.yzw * r7.www + r8.xyz;
      r7.w = dot(r12.yzw, r1.yzw);
      r13.xyz = r7.www * r1.yzw + -r12.yzw;
      r7.w = dot(r13.xyz, r13.xyz);
      r7.w = sqrt(r7.w);
      r7.w = 0.100000001 / r7.w;
      r7.w = min(1, r7.w);
      r12.yzw = r13.xyz * r7.www + r12.yzw;
      r7.w = dot(r12.yzw, r12.yzw);
      r7.w = sqrt(r7.w);
      r12.yzw = r12.yzw / r7.www;
      r8.x = dot(r8.xyz, r11.xyz);
      r8.x = r8.w * r10.w + r8.x;
      r8.x = 0.5 * r8.x;
      r6.w = r8.x * r6.w;
      r6.w = sqrt(r6.w);
      r8.x = r6.w * 4 + 1;
      r8.x = r8.x * r8.x;
      r8.x = 1 / r8.x;
      r8.x = -0.0399999991 + r8.x;
      r8.x = 1.04166675 * r8.x;
      r6.w = cmp(r6.w >= 1);
      r6.w = r6.w ? 0 : r8.x;
      r8.xyz = r9.yzw * r6.www;
      r9.yzw = -r5.xyz * r1.xxx + r12.yzw;
      r6.w = dot(r9.yzw, r9.yzw);
      r6.w = max(0.00100000005, r6.w);
      r6.w = rsqrt(r6.w);
      r9.yzw = r9.yzw * r6.www;
      r6.w = dot(r2.xzw, r9.yzw);
      r6.w = max(0, r6.w);
      r8.w = dot(r12.yzw, r9.yzw);
      r8.w = max(0, r8.w);
      r9.y = r12.x * r3.w + r9.x;
      r9.y = r9.y * r4.w + 9.99999975e-006;
      r9.y = 1 / r9.y;
      r6.w = r6.w * r6.w;
      r6.w = r6.w * r6.x + 1;
      r6.w = max(9.99999997e-007, r6.w);
      r7.w = r7.w + r7.w;
      r7.w = 0.100000001 / r7.w;
      r7.w = r2.y * r2.y + r7.w;
      r7.w = min(1, r7.w);
      r7.w = r7.w * r7.w;
      r9.z = 3.14159274 * r6.w;
      r6.w = r9.z * r6.w;
      r6.w = r6.w * r7.w;
      r6.w = r6.y / r6.w;
      r7.w = 1 + -r12.x;
      r9.z = r7.w * r7.w;
      r9.z = r9.z * r9.z;
      r7.w = r9.z * r7.w;
      r9.z = r8.w + r8.w;
      r9.z = r9.z * r8.w;
      r9.z = r9.z * r2.y + -0.5;
      r7.w = r9.z * r7.w + 1;
      r9.z = r9.z * r5.w + 1;
      r7.w = r9.z * r7.w;
      r6.w = r9.y * r6.w;
      r6.w = 0.785398185 * r6.w;
      r6.w = r6.w * r12.x;
      r6.w = max(0, r6.w);
      r7.w = r7.w * r12.x;
      r9.yzw = r8.xyz * r7.www;
      r8.xyz = r6.www * r8.xyz;
      r6.w = 1 + -r8.w;
      r7.w = r6.w * r6.w;
      r7.w = r7.w * r7.w;
      r6.w = r7.w * r6.w;
      r11.xyz = r10.xyz * r6.www + r4.xyz;
      r8.xyz = r11.xyz * r8.xyz;
      r8.xyz = r0.yzw * r9.yzw + r8.xyz;
      r7.xyz = r8.xyz + r7.xyz;
      r6.z = (int)r6.z + 1;
    }
    r0.xyz = float3(8,8,8) * r7.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 3a72a9ab62909f3a: 2 retail keyword combination(s)
void ps_3a72a9ab62909f3a_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r1.yzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyz;
    r2.xy = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyz = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyz;
    r4.xyz = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r1.yzw;
    r4.xyz = r2.xxx * r4.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r0.w = -r2.x * 0.959999979 + 0.959999979;
    r1.yzw = r1.yzw * r0.www;
    r2.xzw = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r0.w = dot(r2.xzw, r2.xzw);
    r0.w = rsqrt(r0.w);
    r2.xzw = r2.xzw * r0.www;
    r3.z = 1 + -r1.x;
    r3.xy = v0.zw;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r5.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r3.yyyy;
    r5.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r3.xxxx + r5.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r3.zzzz + r5.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r3.xyzw;
    r3.xyz = r3.xyz / r3.www;
    r5.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r3.yyyy;
    r5.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r3.xxxx + r5.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r3.zzzz + r5.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r3.xyzw;
    r5.xyz = -_WorldSpaceCameraPos.xyz + r3.xyz;
    r0.w = dot(r5.xyz, r5.xyz);
    r0.w = rsqrt(r0.w);
    r5.xyz = r5.xyz * r0.www;
    r0.w = dot(r2.xzw, -r5.xyz);
    r1.x = saturate(r0.w);
    r0.y = (int)r0.y + (int)r0.x;
    r2.y = 1 + -r2.y;
    r4.w = r2.y * r2.y;
    r5.w = cmp(r0.w < 0);
    r0.w = 9.99999975e-006 + -r0.w;
    r6.xyz = -r5.xyz * r0.www + r2.xzw;
    r6.xyz = r5.www ? r6.xyz : r2.xzw;
    r0.w = -r2.y * r2.y + 1;
    r2.y = r1.x * r0.w + r4.w;
    r5.w = r4.w * r4.w;
    r6.w = 0.318309873 * r5.w;
    r7.x = 0.5 * r4.w;
    r7.y = r4.w * -0.337748349 + 1;
    r7.z = 1 + -r1.x;
    r7.w = r7.z * r7.z;
    r7.w = r7.w * r7.w;
    r7.z = r7.w * r7.z;
    r8.xyz = float3(1,1,1) + -r4.xyz;
    r9.xyz = float3(0,0,0);
    r7.w = r0.x;
    [loop] while (true) {
      r8.w = cmp((int)r7.w >= (int)r0.y);
      [branch] if (r8.w != 0) break;
      r8.w = _BT_LinkListBuffer[r7.w].val[0/4];
      r10.x = _BT_LightBuffer[r8.w].val[0/4];
      r10.y = _BT_LightBuffer[r8.w].val[0/4+1];
      r10.z = _BT_LightBuffer[r8.w].val[0/4+2];
      r10.w = _BT_LightBuffer[r8.w].val[0/4+3];
      r9.w = _BT_LightBuffer[r8.w].val[32/4];
      r10.xyz = -r10.xyz + r3.xyz;
      r11.x = dot(r10.xyz, r10.xyz);
      r11.y = r10.w * r10.w;
      r11.z = max(0.100000001, r11.x);
      r11.y = r11.z / r11.y;
      r11.y = -r11.y * r11.y + 1;
      r11.y = max(0, r11.y);
      r11.y = r11.y * r11.y;
      r9.w = r10.w * r9.w + r11.z;
      r9.w = 1 / r9.w;
      r9.w = r9.w * r11.y;
      r10.w = cmp(r9.w != 0.000000);
      [branch] if (r10.w != 0) {
        r11.y = _BT_LightBuffer[r8.w].val[16/4];
        r11.z = _BT_LightBuffer[r8.w].val[16/4+1];
        r11.w = _BT_LightBuffer[r8.w].val[16/4+2];
        r8.w = _BT_LightBuffer[r8.w].val[60/4];
        r10.w = rsqrt(r11.x);
        r12.xyz = r10.xyz * r10.www;
        r11.xyz = r11.yzw * r9.www;
        r9.w = dot(r2.xzw, -r12.xyz);
        r9.w = max(0, r9.w);
        r8.w = cmp(r8.w >= 0);
        r10.xyz = -r10.xyz * r10.www + -r5.xyz;
        r10.w = dot(r10.xyz, r10.xyz);
        r10.w = max(0.00100000005, r10.w);
        r10.w = rsqrt(r10.w);
        r10.xyz = r10.xyz * r10.www;
        r10.w = dot(r6.xyz, r10.xyz);
        r10.x = dot(-r12.xyz, r10.xyz);
        r10.xw = max(float2(0,0), r10.xw);
        r10.y = r9.w * r0.w + r4.w;
        r10.y = r10.y * r1.x;
        r10.y = r9.w * r2.y + r10.y;
        r10.y = 9.99999975e-006 + r10.y;
        r10.y = 0.5 / r10.y;
        r10.z = r10.w * r5.w + -r10.w;
        r10.z = r10.z * r10.w + 1;
        r10.z = r10.z * r10.z + 1.00000001e-007;
        r10.z = r6.w / r10.z;
        r10.w = 1 + -r9.w;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r11.w = r10.x + r10.x;
        r11.w = r11.w * r10.x;
        r11.w = r11.w * r4.w + r7.x;
        r11.w = -1 + r11.w;
        r10.w = r11.w * r10.w + 1;
        r11.w = r11.w * r7.z + 1;
        r10.w = r11.w * r10.w;
        r10.w = r10.w * r7.y;
        r10.y = r10.y * r10.z;
        r10.y = 3.14159274 * r10.y;
        r10.y = r10.y * r9.w;
        r10.y = max(0, r10.y);
        r9.w = r10.w * r9.w;
        r12.xyz = r11.xyz * r9.www;
        r10.yzw = r10.yyy * r11.xyz;
        r9.w = 1 + -r10.x;
        r10.x = r9.w * r9.w;
        r10.x = r10.x * r10.x;
        r9.w = r10.x * r9.w;
        r11.xyz = r8.xyz * r9.www + r4.xyz;
        r10.xyz = r11.xyz * r10.yzw;
        r8.w = r8.w ? 1.000000 : 0;
        r10.xyz = r10.xyz * r8.www;
        r10.xyz = r1.yzw * r12.xyz + r10.xyz;
      } else {
        r10.xyz = float3(0,0,0);
      }
      r9.xyz = r10.xyz + r9.xyz;
      r7.w = (int)r7.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r0.y = sqrt(_BT_ShadowMapParams.z);
    r0.z = _BT_MaxShadowDist * _BT_MaxShadowDist;
    r8.w = 0.5 * r0.z;
    r8.w = 1 / r8.w;
    r10.xz = _BT_ShadowMap_TexelSize.xx;
    r10.y = 0.142857149;
    r11.xz = _BT_ShadowMap_TexelSize.yy;
    r11.y = 0.142857149;
    r12.y = 7;
    r13.xyz = r9.xyz;
    r9.w = r7.w;
    [loop] while (true) {
      r10.w = cmp((int)r9.w >= (int)r0.x);
      [branch] if (r10.w != 0) break;
      r10.w = _BT_LinkListBuffer[r9.w].val[0/4];
      r14.x = _BT_LightBuffer[r10.w].val[0/4];
      r14.y = _BT_LightBuffer[r10.w].val[0/4+1];
      r14.z = _BT_LightBuffer[r10.w].val[0/4+2];
      r14.w = _BT_LightBuffer[r10.w].val[0/4+3];
      r11.w = _BT_LightBuffer[r10.w].val[32/4];
      r15.x = _BT_LightBuffer[r10.w].val[48/4];
      r15.y = _BT_LightBuffer[r10.w].val[48/4+1];
      r15.z = _BT_LightBuffer[r10.w].val[48/4+2];
      r15.w = _BT_LightBuffer[r10.w].val[48/4+3];
      r12.w = (uint)r10.w << 2;
      r11.w = frac(r11.w);
      r16.xyz = -r14.xyz + r3.xyz;
      r13.w = dot(r16.xyz, r16.xyz);
      r16.w = r14.w * r14.w;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][1], _BT_LightMatrix[(uint)(r12.w) / 4u][1][1], _BT_LightMatrix[(uint)(r12.w) / 4u][2][1], _BT_LightMatrix[(uint)(r12.w) / 4u][3][1]) * r3.yyyy;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][0], _BT_LightMatrix[(uint)(r12.w) / 4u][1][0], _BT_LightMatrix[(uint)(r12.w) / 4u][2][0], _BT_LightMatrix[(uint)(r12.w) / 4u][3][0]) * r3.xxxx + r17.xyzw;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][2], _BT_LightMatrix[(uint)(r12.w) / 4u][1][2], _BT_LightMatrix[(uint)(r12.w) / 4u][2][2], _BT_LightMatrix[(uint)(r12.w) / 4u][3][2]) * r3.zzzz + r17.xyzw;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][3], _BT_LightMatrix[(uint)(r12.w) / 4u][1][3], _BT_LightMatrix[(uint)(r12.w) / 4u][2][3], _BT_LightMatrix[(uint)(r12.w) / 4u][3][3]) * r3.wwww + r17.xyzw;
      r12.w = max(0.100000001, r13.w);
      r16.w = r12.w / r16.w;
      r16.w = -r16.w * r16.w + 1;
      r16.w = max(0, r16.w);
      r16.w = r16.w * r16.w;
      r11.w = r14.w * r11.w + r12.w;
      r11.w = 1 / r11.w;
      r11.w = r11.w * r16.w;
      r17.xyz = r17.xyz / r17.www;
      r12.w = cmp(0 >= r17.z);
      r18.xy = cmp(float2(1,1) < r17.xy);
      r12.w = (int)r12.w | (int)r18.x;
      r18.xz = cmp(r17.xy < float2(-1,-1));
      r12.w = (int)r12.w | (int)r18.x;
      r12.w = (int)r18.y | (int)r12.w;
      r12.w = (int)r18.z | (int)r12.w;
      [branch] if (r12.w == 0) {
        r12.w = r15.x / r15.y;
        r12.w = min(0.99000001, r12.w);
        r14.w = dot(r17.xy, r17.xy);
        r14.w = sqrt(r14.w);
        r14.w = min(1, r14.w);
        r12.w = -1 + r12.w;
        r14.w = -1 + r14.w;
        r12.w = 1 / r12.w;
        r12.w = r14.w * r12.w;
        r12.w = min(1, r12.w);
        r14.w = r12.w * -2 + 3;
        r12.w = r12.w * r12.w;
        r12.w = r14.w * r12.w;
        r14.w = cmp(r12.w != 0.000000);
        [branch] if (r14.w != 0) {
          r14.w = cmp(-1 < r15.z);
          [branch] if (r14.w != 0) {
            r15.xy = r17.xy * float2(0.5,0.5) + float2(0.5,0.5);
            r14.xyz = _WorldSpaceCameraPos.xyz + -r14.xyz;
            r14.x = dot(r14.xyz, r14.xyz);
            r14.y = r15.z / r0.y;
            r14.z = cmp(r14.y >= -r14.y);
            r14.w = frac(abs(r14.y));
            r14.z = r14.z ? r14.w : -r14.w;
            r14.z = r14.z * r0.y;
            r14.y = floor(r14.y);
            r17.xy = r14.zy / r0.yy;
            r14.yz = r15.xy / r0.yy;
            r14.yz = r14.yz + r17.xy;
            r14.w = r17.z + abs(r15.w);
            r14.yz = r14.yz * _BT_ShadowMap_TexelSize.zw + float2(0.5,0.5);
            r15.xy = floor(r14.yz);
            r15.xy = float2(-0.5,-0.5) + r15.xy;
            r14.yz = frac(r14.yz);
            r15.z = 3 * r14.y;
            r17.xy = -r14.yz * float2(3,3) + float2(4,4);
            r17.zw = r14.yz * float2(3,3) + float2(1,1);
            r18.xy = -r14.yz * float2(2,2) + float2(3,3);
            r18.xy = r18.xy / r17.xy;
            r18.xy = float2(-2,-2) + r18.xy;
            r19.xy = float2(3,3) + r14.yz;
            r19.xy = _BT_ShadowMap_TexelSize.xy * r19.xy;
            r14.yz = r14.yz / r17.zw;
            r14.yz = float2(2,2) + r14.yz;
            r18.z = r19.x;
            r18.w = r14.y;
            r20.xyz = r18.xzw * r10.xyz;
            r19.z = r18.y;
            r19.w = r14.z;
            r18.xyw = r19.zyw * r11.xyz;
            r12.xz = r15.zz * float2(-1,1) + float2(4,1);
            r17.xyz = r17.yyy * r12.xyz;
            r20.w = r18.x;
            r19.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r20.xwyw;
            r14.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.xy, r14.w).x;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.zw, r14.w).x;
            r14.z = r17.y * r14.z;
            r14.y = r17.x * r14.y + r14.z;
            r17.xy = r15.xy * _BT_ShadowMap_TexelSize.xy + r20.zw;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r17.xy, r14.w).x;
            r14.y = r17.z * r14.z + r14.y;
            r17.xy = float2(7,7) * r12.xz;
            r18.z = r20.x;
            r19.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r18.zyzw;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.xy, r14.w).x;
            r14.y = r17.x * r14.z + r14.y;
            r18.xz = r20.yz;
            r20.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r18.xyzy;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.xy, r14.w).x;
            r14.y = r14.z * 49 + r14.y;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.zw, r14.w).x;
            r14.y = r17.y * r14.z + r14.y;
            r17.xyz = r17.www * r12.xyz;
            r12.x = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.zw, r14.w).x;
            r12.x = r17.x * r12.x + r14.y;
            r18.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r18.xwzw;
            r12.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r18.xy, r14.w).x;
            r12.x = r17.y * r12.z + r12.x;
            r12.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r18.zw, r14.w).x;
            r12.x = r17.z * r12.z + r12.x;
            r12.z = 0.0069444445 * r12.x;
            r14.x = -r0.z * 0.5 + r14.x;
            r14.x = saturate(r14.x * r8.w);
            r14.y = r14.x * -2 + 3;
            r14.x = r14.x * r14.x;
            r14.x = r14.y * r14.x;
            r12.x = -r12.x * 0.0069444445 + 1;
            r12.x = r14.x * r12.x + r12.z;
            r12.w = r12.w * r12.x;
          }
        } else {
          r12.w = 0;
        }
      } else {
        r12.w = 0;
      }
      r11.w = r12.w * r11.w;
      r12.x = cmp(r11.w != 0.000000);
      [branch] if (r12.x != 0) {
        r12.x = _BT_LightBuffer[r10.w].val[16/4];
        r12.z = _BT_LightBuffer[r10.w].val[16/4+1];
        r12.w = _BT_LightBuffer[r10.w].val[16/4+2];
        r10.w = rsqrt(r13.w);
        r14.xyz = r16.xyz * r10.www;
        r12.xzw = r12.xzw * r11.www;
        r11.w = dot(r2.xzw, -r14.xyz);
        r11.w = max(0, r11.w);
        r13.w = cmp(r15.w >= 0);
        r15.xyz = -r16.xyz * r10.www + -r5.xyz;
        r10.w = dot(r15.xyz, r15.xyz);
        r10.w = max(0.00100000005, r10.w);
        r10.w = rsqrt(r10.w);
        r15.xyz = r15.xyz * r10.www;
        r10.w = dot(r6.xyz, r15.xyz);
        r10.w = max(0, r10.w);
        r14.x = dot(-r14.xyz, r15.xyz);
        r14.x = max(0, r14.x);
        r14.y = r11.w * r0.w + r4.w;
        r14.y = r14.y * r1.x;
        r14.y = r11.w * r2.y + r14.y;
        r14.y = 9.99999975e-006 + r14.y;
        r14.y = 0.5 / r14.y;
        r14.z = r10.w * r5.w + -r10.w;
        r10.w = r14.z * r10.w + 1;
        r10.w = r10.w * r10.w + 1.00000001e-007;
        r10.w = r6.w / r10.w;
        r14.z = 1 + -r11.w;
        r14.w = r14.z * r14.z;
        r14.w = r14.w * r14.w;
        r14.z = r14.w * r14.z;
        r14.w = r14.x + r14.x;
        r14.w = r14.w * r14.x;
        r14.w = r14.w * r4.w + r7.x;
        r14.w = -1 + r14.w;
        r14.z = r14.w * r14.z + 1;
        r14.w = r14.w * r7.z + 1;
        r14.z = r14.z * r14.w;
        r14.z = r14.z * r7.y;
        r10.w = r14.y * r10.w;
        r10.w = 3.14159274 * r10.w;
        r10.w = r10.w * r11.w;
        r10.w = max(0, r10.w);
        r11.w = r14.z * r11.w;
        r14.yzw = r12.xzw * r11.www;
        r12.xzw = r10.www * r12.xzw;
        r10.w = 1 + -r14.x;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r15.xyz = r8.xyz * r10.www + r4.xyz;
        r12.xzw = r15.xyz * r12.xzw;
        r10.w = r13.w ? 1.000000 : 0;
        r12.xzw = r12.xzw * r10.www;
        r12.xzw = r1.yzw * r14.yzw + r12.xzw;
      } else {
        r12.xzw = float3(0,0,0);
      }
      r13.xyz = r13.xyz + r12.xzw;
      r9.w = (int)r9.w + 1;
    }
    r0.xyz = float3(8,8,8) * r13.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 8c02cf530ae4e32a: 1 retail keyword combination(s)
void ps_8c02cf530ae4e32a_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyzw = _BT_ListEntries.Load(r0.xywz).xyzw;
  r1.y = cmp((int)r0.x >= 0);
  [branch] if (r1.y != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r3.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xyzw;
    r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r1.yz = cmp(r4.ww == float2(0.666666687,0.333333343));
    r1.w = (int)r1.z | (int)r1.y;
    r5.xy = r3.xy * float2(2,2) + float2(-1,-1);
    r6.xyz = float3(1,1,1) + -abs(r5.xyx);
    r7.z = r6.x + -abs(r5.y);
    r3.y = cmp(r7.z >= 0);
    r5.zw = cmp(r5.xy >= float2(0,0));
    r5.zw = r5.zw ? float2(1,1) : float2(-1,-1);
    r5.zw = r6.yz * r5.zw;
    r7.xy = r3.yy ? r5.xy : r5.zw;
    r3.y = dot(r7.xyz, r7.xyz);
    r3.y = rsqrt(r3.y);
    r5.xyz = r7.xyz * r3.yyy;
    r6.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,1) + r2.xyzw;
    r7.xyz = r3.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r3.x = -r3.x * 0.959999979 + 0.959999979;
    r8.xyz = r3.xxx * r2.xyz;
    r6.w = 0.0195999984;
    r8.w = r7.x;
    r6.xyzw = r1.wwww ? r6.xyzw : r8.xyzw;
    r2.xyz = r1.www ? r5.xyz : 0;
    r5.yz = r1.ww ? float2(0.0195999984,0.0195999984) : r7.yz;
    r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r1.w = dot(r4.xyz, r4.xyz);
    r1.w = rsqrt(r1.w);
    r4.xyz = r4.xyz * r1.www;
    r7.z = 1 + -r1.x;
    r7.xy = v0.zw;
    r7.xyz = r7.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r8.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r7.yyyy;
    r8.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r7.xxxx + r8.xyzw;
    r8.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r7.zzzz + r8.xyzw;
    r8.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r8.xyzw;
    r7.xyz = r8.xyz / r8.www;
    r8.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r7.yyyy;
    r8.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r7.xxxx + r8.xyzw;
    r8.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r7.zzzz + r8.xyzw;
    r8.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r8.xyzw;
    r7.xyz = -_WorldSpaceCameraPos.xyz + r8.xyz;
    r1.x = dot(r7.xyz, r7.xyz);
    r1.x = rsqrt(r1.x);
    r9.xyz = r7.xyz * r1.xxx;
    r1.w = cmp(0 < r4.w);
    r3.x = 0.5 * r7.w;
    r10.xyz = r6.xyz * r3.xxx;
    r5.x = r6.w;
    r11.xyz = r5.xyz * r2.www;
    r10.w = r11.x;
    r6.xyzw = r1.wwww ? r10.xyzw : r6.xyzw;
    r5.yz = r1.ww ? r11.yz : r5.yz;
    r1.w = dot(r4.xyz, -r9.xyz);
    r3.x = max(0, r1.w);
    r3.y = min(1, r3.x);
    r0.y = (int)r0.y + (int)r0.x;
    r4.w = r2.w * r2.w;
    r4.w = r4.w * r4.w;
    r4.w = r4.w * r4.w;
    r5.x = r6.w;
    r10.xyz = r5.xyz * r4.www;
    r5.w = 1 + -r3.z;
    r6.w = r5.w * r5.w;
    r7.w = cmp(r1.w < 0);
    r9.w = 9.99999975e-006 + -r1.w;
    r11.xyz = -r9.xyz * r9.www + r4.xyz;
    r11.xyz = r7.www ? r11.xyz : r4.xyz;
    r7.w = -r5.w * r5.w + 1;
    r9.w = r3.y * r7.w + r6.w;
    r10.w = r6.w * r6.w;
    r11.w = 0.318309873 * r10.w;
    r12.xyz = -r5.xyz * r4.www + float3(1,1,1);
    r4.w = dot(r2.xyz, -r9.xyz);
    r12.w = cmp(r4.w < 0);
    r13.x = 9.99999975e-006 + -r4.w;
    r13.xyz = -r9.xyz * r13.xxx + r2.xyz;
    r13.xyz = r12.www ? r13.xyz : r2.xyz;
    r12.w = r3.w * 10 + 5;
    r13.w = -r4.w * r4.w + 1;
    r13.w = sqrt(r13.w);
    r14.xy = float2(0.0349065885,-0.052359879) * r12.ww;
    sincos(r14.x, r14.x, r15.x);
    sincos(r14.y, r16.x, r17.x);
    r12.w = 0.5 * r6.w;
    r14.y = r6.w * -0.337748349 + 1;
    r14.z = 1 + -r3.y;
    r14.w = r14.z * r14.z;
    r14.w = r14.w * r14.w;
    r14.z = r14.w * r14.z;
    r2.w = r2.w * 0.75 + 0.25;
    r18.yw = r3.ww;
    r15.yzw = float3(0,0,0);
    r3.w = r0.x;
    [loop] while (true) {
      r14.w = cmp((int)r3.w >= (int)r0.y);
      [branch] if (r14.w != 0) break;
      r14.w = _BT_LinkListBuffer[r3.w].val[0/4];
      r19.x = _BT_LightBuffer[r14.w].val[0/4];
      r19.y = _BT_LightBuffer[r14.w].val[0/4+1];
      r19.z = _BT_LightBuffer[r14.w].val[0/4+2];
      r19.w = _BT_LightBuffer[r14.w].val[0/4+3];
      r16.y = _BT_LightBuffer[r14.w].val[32/4];
      r17.yzw = -r19.xyz + r8.xyz;
      r16.z = dot(r17.yzw, r17.yzw);
      r16.w = r19.w * r19.w;
      r19.x = max(0.100000001, r16.z);
      r16.w = r19.x / r16.w;
      r16.w = -r16.w * r16.w + 1;
      r16.w = max(0, r16.w);
      r16.w = r16.w * r16.w;
      r16.y = r19.w * r16.y + r19.x;
      r16.y = 1 / r16.y;
      r16.y = r16.y * r16.w;
      r16.w = cmp(r16.y != 0.000000);
      [branch] if (r16.w != 0) {
        r19.x = _BT_LightBuffer[r14.w].val[16/4];
        r19.y = _BT_LightBuffer[r14.w].val[16/4+1];
        r19.z = _BT_LightBuffer[r14.w].val[16/4+2];
        r14.w = _BT_LightBuffer[r14.w].val[60/4];
        r16.z = rsqrt(r16.z);
        r20.xyz = r17.yzw * r16.zzz;
        r19.xyz = r19.xyz * r16.yyy;
        r16.y = dot(r4.xyz, -r20.xyz);
        r16.y = max(0, r16.y);
        [branch] if (r1.y != 0) {
          r16.w = cmp(r14.w >= 0);
          r21.xyz = -r17.yzw * r16.zzz + -r9.xyz;
          r19.w = dot(r21.xyz, r21.xyz);
          r19.w = max(0.00100000005, r19.w);
          r19.w = rsqrt(r19.w);
          r21.xyz = r21.xyz * r19.www;
          r19.w = dot(r11.xyz, r21.xyz);
          r19.w = max(0, r19.w);
          r20.w = dot(-r20.xyz, r21.xyz);
          r20.w = max(0, r20.w);
          r21.x = r16.y * r7.w + r6.w;
          r21.x = r21.x * r3.y;
          r21.x = r16.y * r9.w + r21.x;
          r21.x = 9.99999975e-006 + r21.x;
          r21.x = 0.5 / r21.x;
          r21.y = r19.w * r10.w + -r19.w;
          r19.w = r21.y * r19.w + 1;
          r19.w = r19.w * r19.w + 1.00000001e-007;
          r19.w = r11.w / r19.w;
          r19.w = r21.x * r19.w;
          r19.w = r19.w * r16.y;
          r19.w = 3.14159274 * r19.w;
          r19.w = max(0, r19.w);
          r21.xyz = r19.www * r19.xyz;
          r19.w = 1 + -r20.w;
          r20.w = r19.w * r19.w;
          r20.w = r20.w * r20.w;
          r19.w = r20.w * r19.w;
          r22.xyz = r12.xyz * r19.www + r10.xyz;
          r21.xyz = r22.xyz * r21.xyz;
          r16.w = r16.w ? 1.000000 : 0;
          r19.w = dot(r13.xyz, -r20.xyz);
          r18.x = r19.w * 0.5 + 0.5;
          r22.xyz = _BT_PreIntegratedSSS.SampleLevel(sampler_BT_PreIntegratedSSS, r18.xy, 0).xyz;
          r22.xyz = r22.xyz * r19.xyz;
          r22.xyz = r22.xyz * r6.xyz;
          r21.xyz = r21.xyz * r16.www + r22.xyz;
        } else {
          [branch] if (r1.z != 0) {
            r16.w = dot(r2.xyz, -r20.xyz);
            r18.x = -r16.w * r16.w + 1;
            r18.x = sqrt(r18.x);
            r19.w = r18.x * r14.x;
            r19.w = -r16.w * r15.x + -r19.w;
            r20.w = -r19.w * r19.w + 1;
            r20.w = sqrt(r20.w);
            r20.w = r20.w * r13.w;
            r19.w = r19.w * r4.w + r20.w;
            r19.w = max(0, r19.w);
            r20.w = r18.x * r16.x;
            r16.w = -r16.w * r17.x + -r20.w;
            r20.w = -r16.w * r16.w + 1;
            r20.w = sqrt(r20.w);
            r20.w = r20.w * r13.w;
            r16.w = r16.w * r4.w + r20.w;
            r16.w = max(0, r16.w);
            r18.x = 0.00999999978 * r18.x;
            r19.w = log2(r19.w);
            r19.w = 30.3999996 * r19.w;
            r19.w = exp2(r19.w);
            r19.w = 0.0500000007 * r19.w;
            r16.w = log2(r16.w);
            r16.w = 15.8000002 * r16.w;
            r16.w = exp2(r16.w);
            r16.w = 0.100000001 * r16.w;
            r22.xyz = r18.xxx * r19.xyz;
            r23.xyz = r19.www * r19.xyz;
            r23.xyz = r23.xyz * r3.zzz;
            r23.xyz = float3(1.5,1.5,1.5) * r23.xyz;
            r22.xyz = r22.xyz * r6.xyz + r23.xyz;
            r23.xyz = r16.www * r19.xyz;
            r23.xyz = r23.xyz * r6.xyz;
            r23.xyz = r23.xyz * r3.zzz;
            r22.xyz = r23.xyz * float3(1.5,1.5,1.5) + r22.xyz;
            r23.xyz = -r17.yzw * r16.zzz + -r9.xyz;
            r16.w = dot(r23.xyz, r23.xyz);
            r16.w = max(0.00100000005, r16.w);
            r16.w = rsqrt(r16.w);
            r23.xyz = r23.xyz * r16.www;
            r16.w = dot(-r20.xyz, r23.xyz);
            r16.w = max(0, r16.w);
            r18.x = 1 + -r16.y;
            r19.w = r18.x * r18.x;
            r19.w = r19.w * r19.w;
            r18.x = r19.w * r18.x;
            r19.w = r16.w + r16.w;
            r16.w = r19.w * r16.w;
            r16.w = r16.w * r6.w + r12.w;
            r16.w = -1 + r16.w;
            r18.x = r16.w * r18.x + 1;
            r16.w = r16.w * r14.z + 1;
            r16.w = r18.x * r16.w;
            r16.w = r16.w * r14.y;
            r16.w = r16.w * r16.y;
            r23.xyz = r19.xyz * r16.www;
            r23.xyz = r23.xyz * r6.xyz;
            r22.xyz = r23.xyz * float3(0.25,0.25,0.25) + r22.xyz;
            r21.xyz = r22.xyz * r2.www;
          } else {
            r14.w = cmp(r14.w >= 0);
            r17.yzw = -r17.yzw * r16.zzz + -r9.xyz;
            r16.z = dot(r17.yzw, r17.yzw);
            r16.z = max(0.00100000005, r16.z);
            r16.z = rsqrt(r16.z);
            r17.yzw = r17.yzw * r16.zzz;
            r16.z = dot(r11.xyz, r17.yzw);
            r16.w = dot(-r20.xyz, r17.yzw);
            r16.zw = max(float2(0,0), r16.zw);
            r17.y = r16.y * r7.w + r6.w;
            r17.y = r17.y * r3.y;
            r17.y = r16.y * r9.w + r17.y;
            r17.y = 9.99999975e-006 + r17.y;
            r17.y = 0.5 / r17.y;
            r17.z = r16.z * r10.w + -r16.z;
            r16.z = r17.z * r16.z + 1;
            r16.z = r16.z * r16.z + 1.00000001e-007;
            r16.z = r11.w / r16.z;
            r17.z = 1 + -r16.y;
            r17.w = r17.z * r17.z;
            r17.w = r17.w * r17.w;
            r17.z = r17.w * r17.z;
            r17.w = r16.w + r16.w;
            r17.w = r17.w * r16.w;
            r17.w = r17.w * r6.w + r12.w;
            r17.w = -1 + r17.w;
            r17.z = r17.w * r17.z + 1;
            r17.w = r17.w * r14.z + 1;
            r17.z = r17.z * r17.w;
            r17.z = r17.z * r14.y;
            r16.z = r17.y * r16.z;
            r16.z = r16.z * r16.y;
            r16.z = 3.14159274 * r16.z;
            r16.z = max(0, r16.z);
            r16.y = r17.z * r16.y;
            r17.yzw = r19.xyz * r16.yyy;
            r19.xyz = r16.zzz * r19.xyz;
            r16.y = 1 + -r16.w;
            r16.z = r16.y * r16.y;
            r16.z = r16.z * r16.z;
            r16.y = r16.z * r16.y;
            r16.yzw = r12.xyz * r16.yyy + r10.xyz;
            r16.yzw = r19.xyz * r16.yzw;
            r14.w = r14.w ? 1.000000 : 0;
            r16.yzw = r16.yzw * r14.www;
            r21.xyz = r6.xyz * r17.yzw + r16.yzw;
          }
        }
      } else {
        r21.xyz = float3(0,0,0);
      }
      r15.yzw = r21.xyz + r15.yzw;
      r3.w = (int)r3.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r16.yzw = r15.yzw;
    r0.y = r3.w;
    [loop] while (true) {
      r0.z = cmp((int)r0.y >= (int)r0.x);
      [branch] if (r0.z != 0) break;
      r0.z = _BT_LinkListBuffer[r0.y].val[0/4];
      r19.x = _BT_LightBuffer[r0.z].val[0/4];
      r19.y = _BT_LightBuffer[r0.z].val[0/4+1];
      r19.z = _BT_LightBuffer[r0.z].val[0/4+2];
      r19.w = _BT_LightBuffer[r0.z].val[0/4+3];
      r14.w = _BT_LightBuffer[r0.z].val[32/4];
      r17.y = _BT_LightBuffer[r0.z].val[48/4];
      r17.z = _BT_LightBuffer[r0.z].val[48/4+1];
      r17.w = (uint)r0.z << 2;
      r14.w = frac(r14.w);
      r19.xyz = -r19.xyz + r8.xyz;
      r18.x = dot(r19.xyz, r19.xyz);
      r18.y = r19.w * r19.w;
      r20.xyzw = float4(_BT_LightMatrix[(uint)(r17.w) / 4u][0][1], _BT_LightMatrix[(uint)(r17.w) / 4u][1][1], _BT_LightMatrix[(uint)(r17.w) / 4u][2][1], _BT_LightMatrix[(uint)(r17.w) / 4u][3][1]) * r8.yyyy;
      r20.xyzw = float4(_BT_LightMatrix[(uint)(r17.w) / 4u][0][0], _BT_LightMatrix[(uint)(r17.w) / 4u][1][0], _BT_LightMatrix[(uint)(r17.w) / 4u][2][0], _BT_LightMatrix[(uint)(r17.w) / 4u][3][0]) * r8.xxxx + r20.xyzw;
      r20.xyzw = float4(_BT_LightMatrix[(uint)(r17.w) / 4u][0][2], _BT_LightMatrix[(uint)(r17.w) / 4u][1][2], _BT_LightMatrix[(uint)(r17.w) / 4u][2][2], _BT_LightMatrix[(uint)(r17.w) / 4u][3][2]) * r8.zzzz + r20.xyzw;
      r20.xyzw = float4(_BT_LightMatrix[(uint)(r17.w) / 4u][0][3], _BT_LightMatrix[(uint)(r17.w) / 4u][1][3], _BT_LightMatrix[(uint)(r17.w) / 4u][2][3], _BT_LightMatrix[(uint)(r17.w) / 4u][3][3]) * r8.wwww + r20.xyzw;
      r17.w = max(0.100000001, r18.x);
      r18.y = r17.w / r18.y;
      r18.y = -r18.y * r18.y + 1;
      r18.y = max(0, r18.y);
      r18.y = r18.y * r18.y;
      r14.w = r19.w * r14.w + r17.w;
      r14.w = 1 / r14.w;
      r14.w = r14.w * r18.y;
      r20.xyz = r20.xyz / r20.www;
      r17.w = cmp(0 >= r20.z);
      r20.zw = cmp(float2(1,1) < r20.xy);
      r17.w = (int)r17.w | (int)r20.z;
      r21.xy = cmp(r20.xy < float2(-1,-1));
      r17.w = (int)r17.w | (int)r21.x;
      r17.w = (int)r20.w | (int)r17.w;
      r17.w = (int)r21.y | (int)r17.w;
      r17.y = r17.y / r17.z;
      r17.y = min(0.99000001, r17.y);
      r17.z = dot(r20.xy, r20.xy);
      r17.z = sqrt(r17.z);
      r17.z = min(1, r17.z);
      r17.yz = float2(-1,-1) + r17.yz;
      r17.y = 1 / r17.y;
      r17.y = r17.z * r17.y;
      r17.y = min(1, r17.y);
      r17.z = r17.y * -2 + 3;
      r17.y = r17.y * r17.y;
      r17.y = r17.z * r17.y;
      r17.z = cmp(r17.y != 0.000000);
      r17.y = r17.z ? r17.y : 0;
      r17.y = r17.w ? 0 : r17.y;
      r14.w = r17.y * r14.w;
      r17.y = cmp(r14.w != 0.000000);
      [branch] if (r17.y != 0) {
        r17.y = _BT_LightBuffer[r0.z].val[16/4];
        r17.z = _BT_LightBuffer[r0.z].val[16/4+1];
        r17.w = _BT_LightBuffer[r0.z].val[16/4+2];
        r0.z = _BT_LightBuffer[r0.z].val[60/4];
        r18.x = rsqrt(r18.x);
        r20.xyz = r19.xyz * r18.xxx;
        r17.yzw = r17.yzw * r14.www;
        r14.w = dot(r4.xyz, -r20.xyz);
        r14.w = max(0, r14.w);
        [branch] if (r1.y != 0) {
          r18.y = cmp(r0.z >= 0);
          r21.xyz = -r19.xyz * r18.xxx + -r9.xyz;
          r19.w = dot(r21.xyz, r21.xyz);
          r19.w = max(0.00100000005, r19.w);
          r19.w = rsqrt(r19.w);
          r21.xyz = r21.xyz * r19.www;
          r19.w = dot(r11.xyz, r21.xyz);
          r19.w = max(0, r19.w);
          r20.w = dot(-r20.xyz, r21.xyz);
          r20.w = max(0, r20.w);
          r21.x = r14.w * r7.w + r6.w;
          r21.x = r21.x * r3.y;
          r21.x = r14.w * r9.w + r21.x;
          r21.x = 9.99999975e-006 + r21.x;
          r21.x = 0.5 / r21.x;
          r21.y = r19.w * r10.w + -r19.w;
          r19.w = r21.y * r19.w + 1;
          r19.w = r19.w * r19.w + 1.00000001e-007;
          r19.w = r11.w / r19.w;
          r19.w = r21.x * r19.w;
          r19.w = r19.w * r14.w;
          r19.w = 3.14159274 * r19.w;
          r19.w = max(0, r19.w);
          r21.xyz = r19.www * r17.yzw;
          r19.w = 1 + -r20.w;
          r20.w = r19.w * r19.w;
          r20.w = r20.w * r20.w;
          r19.w = r20.w * r19.w;
          r22.xyz = r12.xyz * r19.www + r10.xyz;
          r21.xyz = r22.xyz * r21.xyz;
          r18.y = r18.y ? 1.000000 : 0;
          r19.w = dot(r13.xyz, -r20.xyz);
          r18.z = r19.w * 0.5 + 0.5;
          r22.xyz = _BT_PreIntegratedSSS.SampleLevel(sampler_BT_PreIntegratedSSS, r18.zw, 0).xyz;
          r22.xyz = r22.xyz * r17.yzw;
          r22.xyz = r22.xyz * r6.xyz;
          r21.xyz = r21.xyz * r18.yyy + r22.xyz;
        } else {
          [branch] if (r1.z != 0) {
            r18.y = dot(r2.xyz, -r20.xyz);
            r18.z = -r18.y * r18.y + 1;
            r18.z = sqrt(r18.z);
            r19.w = r18.z * r14.x;
            r19.w = -r18.y * r15.x + -r19.w;
            r20.w = -r19.w * r19.w + 1;
            r20.w = sqrt(r20.w);
            r20.w = r20.w * r13.w;
            r19.w = r19.w * r4.w + r20.w;
            r19.w = max(0, r19.w);
            r20.w = r18.z * r16.x;
            r18.y = -r18.y * r17.x + -r20.w;
            r20.w = -r18.y * r18.y + 1;
            r20.w = sqrt(r20.w);
            r20.w = r20.w * r13.w;
            r18.y = r18.y * r4.w + r20.w;
            r18.y = max(0, r18.y);
            r19.w = log2(r19.w);
            r19.w = 30.3999996 * r19.w;
            r19.w = exp2(r19.w);
            r19.w = 0.0500000007 * r19.w;
            r18.y = log2(r18.y);
            r18.yz = float2(15.8000002,0.00999999978) * r18.yz;
            r18.y = exp2(r18.y);
            r18.y = 0.100000001 * r18.y;
            r22.xyz = r18.zzz * r17.yzw;
            r23.xyz = r19.www * r17.yzw;
            r23.xyz = r23.xyz * r3.zzz;
            r23.xyz = float3(1.5,1.5,1.5) * r23.xyz;
            r22.xyz = r22.xyz * r6.xyz + r23.xyz;
            r23.xyz = r18.yyy * r17.yzw;
            r23.xyz = r23.xyz * r6.xyz;
            r23.xyz = r23.xyz * r3.zzz;
            r22.xyz = r23.xyz * float3(1.5,1.5,1.5) + r22.xyz;
            r23.xyz = -r19.xyz * r18.xxx + -r9.xyz;
            r18.y = dot(r23.xyz, r23.xyz);
            r18.y = max(0.00100000005, r18.y);
            r18.y = rsqrt(r18.y);
            r23.xyz = r23.xyz * r18.yyy;
            r18.y = dot(-r20.xyz, r23.xyz);
            r18.y = max(0, r18.y);
            r18.z = 1 + -r14.w;
            r19.w = r18.z * r18.z;
            r19.w = r19.w * r19.w;
            r18.z = r19.w * r18.z;
            r19.w = r18.y + r18.y;
            r18.y = r19.w * r18.y;
            r18.y = r18.y * r6.w + r12.w;
            r18.y = -1 + r18.y;
            r18.z = r18.y * r18.z + 1;
            r18.y = r18.y * r14.z + 1;
            r18.y = r18.z * r18.y;
            r18.y = r18.y * r14.y;
            r18.y = r18.y * r14.w;
            r23.xyz = r18.yyy * r17.yzw;
            r23.xyz = r23.xyz * r6.xyz;
            r22.xyz = r23.xyz * float3(0.25,0.25,0.25) + r22.xyz;
            r21.xyz = r22.xyz * r2.www;
          } else {
            r0.z = cmp(r0.z >= 0);
            r18.xyz = -r19.xyz * r18.xxx + -r9.xyz;
            r19.x = dot(r18.xyz, r18.xyz);
            r19.x = max(0.00100000005, r19.x);
            r19.x = rsqrt(r19.x);
            r18.xyz = r19.xxx * r18.xyz;
            r19.x = dot(r11.xyz, r18.xyz);
            r19.x = max(0, r19.x);
            r18.x = dot(-r20.xyz, r18.xyz);
            r18.x = max(0, r18.x);
            r18.y = r14.w * r7.w + r6.w;
            r18.y = r18.y * r3.y;
            r18.y = r14.w * r9.w + r18.y;
            r18.y = 9.99999975e-006 + r18.y;
            r18.y = 0.5 / r18.y;
            r18.z = r19.x * r10.w + -r19.x;
            r18.z = r18.z * r19.x + 1;
            r18.z = r18.z * r18.z + 1.00000001e-007;
            r18.z = r11.w / r18.z;
            r19.x = 1 + -r14.w;
            r19.y = r19.x * r19.x;
            r19.y = r19.y * r19.y;
            r19.x = r19.y * r19.x;
            r19.y = r18.x + r18.x;
            r19.y = r19.y * r18.x;
            r19.y = r19.y * r6.w + r12.w;
            r19.y = -1 + r19.y;
            r19.x = r19.y * r19.x + 1;
            r19.y = r19.y * r14.z + 1;
            r19.x = r19.x * r19.y;
            r19.x = r19.x * r14.y;
            r18.y = r18.y * r18.z;
            r18.y = r18.y * r14.w;
            r18.y = 3.14159274 * r18.y;
            r18.y = max(0, r18.y);
            r14.w = r19.x * r14.w;
            r19.xyz = r17.yzw * r14.www;
            r17.yzw = r18.yyy * r17.yzw;
            r14.w = 1 + -r18.x;
            r18.x = r14.w * r14.w;
            r18.x = r18.x * r18.x;
            r14.w = r18.x * r14.w;
            r18.xyz = r12.xyz * r14.www + r10.xyz;
            r17.yzw = r18.xyz * r17.yzw;
            r0.z = r0.z ? 1.000000 : 0;
            r17.yzw = r17.yzw * r0.zzz;
            r21.xyz = r6.xyz * r19.xyz + r17.yzw;
          }
        }
      } else {
        r21.xyz = float3(0,0,0);
      }
      r16.yzw = r21.xyz + r16.yzw;
      r0.y = (int)r0.y + 1;
    }
    r0.x = (int)r0.w + (int)r0.x;
    r2.xyz = float3(25,25,25) * r6.xyz;
    r0.z = r1.w + r1.w;
    r1.yzw = r4.xyz * -r0.zzz + -r9.xyz;
    r0.z = -r6.w * 0.5 + 1;
    r0.w = r3.x * r0.z + r12.w;
    r2.w = r6.w * r6.w + -1;
    r3.y = r10.w * r10.w;
    r3.x = 1 + -r3.x;
    r3.z = r3.x * r3.x;
    r3.z = r3.z * r3.z;
    r3.x = r3.z * r3.x;
    r6.xyz = float3(1,1,1) + -r5.xyz;
    r9.xyz = r16.yzw;
    r3.z = r0.y;
    [loop] while (true) {
      r3.w = cmp((int)r3.z >= (int)r0.x);
      [branch] if (r3.w != 0) break;
      r3.w = _BT_LinkListBuffer[r3.z].val[0/4];
      r10.x = _BT_LightBuffer[r3.w].val[0/4];
      r10.y = _BT_LightBuffer[r3.w].val[0/4+1];
      r10.z = _BT_LightBuffer[r3.w].val[0/4+2];
      r10.w = _BT_LightBuffer[r3.w].val[0/4+3];
      r11.x = _BT_LightBuffer[r3.w].val[16/4];
      r11.y = _BT_LightBuffer[r3.w].val[16/4+1];
      r11.z = _BT_LightBuffer[r3.w].val[16/4+2];
      r4.w = _BT_LightBuffer[r3.w].val[32/4];
      r12.x = _BT_LightBuffer[r3.w].val[48/4];
      r12.y = _BT_LightBuffer[r3.w].val[48/4+1];
      r12.z = _BT_LightBuffer[r3.w].val[48/4+2];
      r3.w = r10.w * r10.w;
      r3.w = 1 / r3.w;
      r12.xyz = r12.xyz * r4.www + r10.xyz;
      r10.xyz = r10.xyz + -r8.xyz;
      r12.xyz = r12.xyz + -r8.xyz;
      r4.w = dot(r10.xyz, r10.xyz);
      r6.w = sqrt(r4.w);
      r7.w = dot(r12.xyz, r12.xyz);
      r7.w = sqrt(r7.w);
      r8.w = dot(r10.xyz, r4.xyz);
      r9.w = r6.w + r6.w;
      r8.w = r8.w / r9.w;
      r9.w = dot(r12.xyz, r4.xyz);
      r10.w = r7.w + r7.w;
      r9.w = r9.w / r10.w;
      r8.w = saturate(r9.w + r8.w);
      r13.xyz = r12.xyz + -r10.xyz;
      r9.w = dot(r1.yzw, r10.xyz);
      r10.w = dot(r1.yzw, r13.xyz);
      r11.w = dot(r10.xyz, r13.xyz);
      r13.w = dot(r13.xyz, r13.xyz);
      r4.w = r10.w * r4.w;
      r4.w = r11.w * r9.w + -r4.w;
      r9.w = r13.w * r9.w;
      r9.w = r11.w * r10.w + -r9.w;
      r4.w = saturate(r4.w / r9.w);
      r14.xyz = r13.yzx * r10.zxy;
      r14.xyz = r10.yzx * r13.zxy + -r14.xyz;
      r15.xyz = r13.zxy * r1.zwy;
      r15.xyz = r13.yzx * r1.wyz + -r15.xyz;
      r9.w = dot(r14.xyz, r15.xyz);
      r10.w = 1 + -r4.w;
      r9.w = cmp(r9.w >= 0);
      r9.w = r9.w ? 1.000000 : 0;
      r4.w = -r10.w + r4.w;
      r4.w = r9.w * r4.w + r10.w;
      r13.xyz = r13.xyz * r4.www + r10.xyz;
      r4.w = dot(r13.xyz, r1.yzw);
      r14.xyz = r4.www * r1.yzw + -r13.xyz;
      r4.w = dot(r14.xyz, r14.xyz);
      r4.w = sqrt(r4.w);
      r4.w = 0.100000001 / r4.w;
      r4.w = min(1, r4.w);
      r13.xyz = r14.xyz * r4.www + r13.xyz;
      r4.w = dot(r13.xyz, r13.xyz);
      r4.w = sqrt(r4.w);
      r13.xyz = r13.xyz / r4.www;
      r9.w = dot(r10.xyz, r12.xyz);
      r6.w = r6.w * r7.w + r9.w;
      r6.w = 0.5 * r6.w;
      r3.w = r6.w * r3.w;
      r3.w = sqrt(r3.w);
      r6.w = r3.w * 4 + 1;
      r6.w = r6.w * r6.w;
      r6.w = 1 / r6.w;
      r6.w = -0.0399999991 + r6.w;
      r6.w = 1.04166675 * r6.w;
      r3.w = cmp(r3.w >= 1);
      r3.w = r3.w ? 0 : r6.w;
      r10.xyz = r11.xyz * r3.www;
      r11.xyz = -r7.xyz * r1.xxx + r13.xyz;
      r3.w = dot(r11.xyz, r11.xyz);
      r3.w = max(0.00100000005, r3.w);
      r3.w = rsqrt(r3.w);
      r11.xyz = r11.xyz * r3.www;
      r3.w = dot(r4.xyz, r11.xyz);
      r3.w = max(0, r3.w);
      r6.w = dot(r13.xyz, r11.xyz);
      r6.w = max(0, r6.w);
      r7.w = r8.w * r0.z + r12.w;
      r7.w = r7.w * r0.w + 9.99999975e-006;
      r7.w = 1 / r7.w;
      r3.w = r3.w * r3.w;
      r3.w = r3.w * r2.w + 1;
      r3.w = max(9.99999997e-007, r3.w);
      r4.w = r4.w + r4.w;
      r4.w = 0.100000001 / r4.w;
      r4.w = r5.w * r5.w + r4.w;
      r4.w = min(1, r4.w);
      r4.w = r4.w * r4.w;
      r9.w = 3.14159274 * r3.w;
      r3.w = r9.w * r3.w;
      r3.w = r3.w * r4.w;
      r3.w = r3.y / r3.w;
      r4.w = 1 + -r8.w;
      r9.w = r4.w * r4.w;
      r9.w = r9.w * r9.w;
      r4.w = r9.w * r4.w;
      r9.w = r6.w + r6.w;
      r9.w = r9.w * r6.w;
      r9.w = r9.w * r5.w + -0.5;
      r4.w = r9.w * r4.w + 1;
      r9.w = r9.w * r3.x + 1;
      r4.w = r9.w * r4.w;
      r3.w = r7.w * r3.w;
      r3.w = 0.785398185 * r3.w;
      r3.w = r3.w * r8.w;
      r3.w = max(0, r3.w);
      r4.w = r4.w * r8.w;
      r11.xyz = r10.xyz * r4.www;
      r10.xyz = r3.www * r10.xyz;
      r3.w = 1 + -r6.w;
      r4.w = r3.w * r3.w;
      r4.w = r4.w * r4.w;
      r3.w = r4.w * r3.w;
      r12.xyz = r6.xyz * r3.www + r5.xyz;
      r10.xyz = r12.xyz * r10.xyz;
      r10.xyz = r2.xyz * r11.xyz + r10.xyz;
      r9.xyz = r10.xyz + r9.xyz;
      r3.z = (int)r3.z + 1;
    }
    r0.xyz = float3(8,8,8) * r9.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 3d473d880ff170ab: 1 retail keyword combination(s)
void ps_3d473d880ff170ab_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r3.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xyzw;
    r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r1.yz = cmp(r4.ww == float2(0.666666687,0.333333343));
    r0.w = (int)r1.z | (int)r1.y;
    r5.xy = r3.xy * float2(2,2) + float2(-1,-1);
    r6.xyz = float3(1,1,1) + -abs(r5.xyx);
    r7.z = r6.x + -abs(r5.y);
    r1.w = cmp(r7.z >= 0);
    r5.zw = cmp(r5.xy >= float2(0,0));
    r5.zw = r5.zw ? float2(1,1) : float2(-1,-1);
    r5.zw = r6.yz * r5.zw;
    r7.xy = r1.ww ? r5.xy : r5.zw;
    r1.w = dot(r7.xyz, r7.xyz);
    r1.w = rsqrt(r1.w);
    r5.xyz = r7.xyz * r1.www;
    r6.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,1) + r2.xyzw;
    r7.xyz = r3.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r1.w = -r3.x * 0.959999979 + 0.959999979;
    r8.xyz = r2.xyz * r1.www;
    r6.w = 0.0195999984;
    r8.w = r7.x;
    r6.xyzw = r0.wwww ? r6.xyzw : r8.xyzw;
    r2.xyz = r0.www ? r5.xyz : 0;
    r5.yz = r0.ww ? float2(0.0195999984,0.0195999984) : r7.yz;
    r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r0.w = dot(r4.xyz, r4.xyz);
    r0.w = rsqrt(r0.w);
    r4.xyz = r4.xyz * r0.www;
    r7.z = 1 + -r1.x;
    r7.xy = v0.zw;
    r7.xyz = r7.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r8.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r7.yyyy;
    r8.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r7.xxxx + r8.xyzw;
    r8.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r7.zzzz + r8.xyzw;
    r8.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r8.xyzw;
    r7.xyz = r8.xyz / r8.www;
    r8.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r7.yyyy;
    r8.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r7.xxxx + r8.xyzw;
    r8.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r7.zzzz + r8.xyzw;
    r8.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r8.xyzw;
    r7.xyz = -_WorldSpaceCameraPos.xyz + r8.xyz;
    r0.w = dot(r7.xyz, r7.xyz);
    r0.w = rsqrt(r0.w);
    r7.xyz = r7.xyz * r0.www;
    r0.w = cmp(0 < r4.w);
    r1.x = 0.5 * r7.w;
    r9.xyz = r6.xyz * r1.xxx;
    r5.x = r6.w;
    r10.xyz = r5.xyz * r2.www;
    r9.w = r10.x;
    r6.xyzw = r0.wwww ? r9.xyzw : r6.xyzw;
    r5.yz = r0.ww ? r10.yz : r5.yz;
    r0.w = dot(r4.xyz, -r7.xyz);
    r1.x = saturate(r0.w);
    r0.y = (int)r0.y + (int)r0.x;
    r1.w = r2.w * r2.w;
    r1.w = r1.w * r1.w;
    r1.w = r1.w * r1.w;
    r5.x = r6.w;
    r9.xyz = r5.xyz * r1.www;
    r3.x = 1 + -r3.z;
    r3.y = r3.x * r3.x;
    r4.w = cmp(r0.w < 0);
    r0.w = 9.99999975e-006 + -r0.w;
    r10.xyz = -r7.xyz * r0.www + r4.xyz;
    r10.xyz = r4.www ? r10.xyz : r4.xyz;
    r0.w = -r3.x * r3.x + 1;
    r3.x = r1.x * r0.w + r3.y;
    r4.w = r3.y * r3.y;
    r5.w = 0.318309873 * r4.w;
    r5.xyz = -r5.xyz * r1.www + float3(1,1,1);
    r1.w = dot(r2.xyz, -r7.xyz);
    r6.w = cmp(r1.w < 0);
    r7.w = 9.99999975e-006 + -r1.w;
    r11.xyz = -r7.xyz * r7.www + r2.xyz;
    r11.xyz = r6.www ? r11.xyz : r2.xyz;
    r6.w = r3.w * 10 + 5;
    r7.w = -r1.w * r1.w + 1;
    r7.w = sqrt(r7.w);
    r12.xy = float2(0.0349065885,-0.052359879) * r6.ww;
    sincos(r12.x, r12.x, r13.x);
    sincos(r12.y, r14.x, r15.x);
    r6.w = 0.5 * r3.y;
    r9.w = r3.y * -0.337748349 + 1;
    r10.w = 1 + -r1.x;
    r11.w = r10.w * r10.w;
    r11.w = r11.w * r11.w;
    r10.w = r11.w * r10.w;
    r2.w = r2.w * 0.75 + 0.25;
    r16.yw = r3.ww;
    r12.yzw = float3(0,0,0);
    r3.w = r0.x;
    [loop] while (true) {
      r11.w = cmp((int)r3.w >= (int)r0.y);
      [branch] if (r11.w != 0) break;
      r11.w = _BT_LinkListBuffer[r3.w].val[0/4];
      r17.x = _BT_LightBuffer[r11.w].val[0/4];
      r17.y = _BT_LightBuffer[r11.w].val[0/4+1];
      r17.z = _BT_LightBuffer[r11.w].val[0/4+2];
      r17.w = _BT_LightBuffer[r11.w].val[0/4+3];
      r13.y = _BT_LightBuffer[r11.w].val[32/4];
      r14.yzw = -r17.xyz + r8.xyz;
      r13.z = dot(r14.yzw, r14.yzw);
      r13.w = r17.w * r17.w;
      r15.y = max(0.100000001, r13.z);
      r13.w = r15.y / r13.w;
      r13.w = -r13.w * r13.w + 1;
      r13.w = max(0, r13.w);
      r13.w = r13.w * r13.w;
      r13.y = r17.w * r13.y + r15.y;
      r13.y = 1 / r13.y;
      r13.y = r13.y * r13.w;
      r13.w = cmp(r13.y != 0.000000);
      [branch] if (r13.w != 0) {
        r15.y = _BT_LightBuffer[r11.w].val[16/4];
        r15.z = _BT_LightBuffer[r11.w].val[16/4+1];
        r15.w = _BT_LightBuffer[r11.w].val[16/4+2];
        r11.w = _BT_LightBuffer[r11.w].val[60/4];
        r13.z = rsqrt(r13.z);
        r17.xyz = r14.yzw * r13.zzz;
        r15.yzw = r15.yzw * r13.yyy;
        r13.y = dot(r4.xyz, -r17.xyz);
        r13.y = max(0, r13.y);
        [branch] if (r1.y != 0) {
          r13.w = cmp(r11.w >= 0);
          r18.xyz = -r14.yzw * r13.zzz + -r7.xyz;
          r17.w = dot(r18.xyz, r18.xyz);
          r17.w = max(0.00100000005, r17.w);
          r17.w = rsqrt(r17.w);
          r18.xyz = r18.xyz * r17.www;
          r17.w = dot(r10.xyz, r18.xyz);
          r17.w = max(0, r17.w);
          r18.x = dot(-r17.xyz, r18.xyz);
          r18.x = max(0, r18.x);
          r18.y = r13.y * r0.w + r3.y;
          r18.y = r18.y * r1.x;
          r18.y = r13.y * r3.x + r18.y;
          r18.y = 9.99999975e-006 + r18.y;
          r18.y = 0.5 / r18.y;
          r18.z = r17.w * r4.w + -r17.w;
          r17.w = r18.z * r17.w + 1;
          r17.w = r17.w * r17.w + 1.00000001e-007;
          r17.w = r5.w / r17.w;
          r17.w = r18.y * r17.w;
          r17.w = 3.14159274 * r17.w;
          r17.w = r17.w * r13.y;
          r17.w = max(0, r17.w);
          r18.yzw = r17.www * r15.yzw;
          r17.w = 1 + -r18.x;
          r18.x = r17.w * r17.w;
          r18.x = r18.x * r18.x;
          r17.w = r18.x * r17.w;
          r19.xyz = r5.xyz * r17.www + r9.xyz;
          r18.xyz = r19.xyz * r18.yzw;
          r13.w = r13.w ? 1.000000 : 0;
          r17.w = dot(r11.xyz, -r17.xyz);
          r16.x = r17.w * 0.5 + 0.5;
          r19.xyz = _BT_PreIntegratedSSS.SampleLevel(sampler_BT_PreIntegratedSSS, r16.xy, 0).xyz;
          r19.xyz = r19.xyz * r15.yzw;
          r19.xyz = r19.xyz * r6.xyz;
          r18.xyz = r18.xyz * r13.www + r19.xyz;
        } else {
          [branch] if (r1.z != 0) {
            r13.w = dot(r2.xyz, -r17.xyz);
            r16.x = -r13.w * r13.w + 1;
            r16.x = sqrt(r16.x);
            r17.w = r16.x * r12.x;
            r17.w = -r13.w * r13.x + -r17.w;
            r18.w = -r17.w * r17.w + 1;
            r18.w = sqrt(r18.w);
            r18.w = r18.w * r7.w;
            r17.w = r17.w * r1.w + r18.w;
            r17.w = max(0, r17.w);
            r18.w = r16.x * r14.x;
            r13.w = -r13.w * r15.x + -r18.w;
            r18.w = -r13.w * r13.w + 1;
            r18.w = sqrt(r18.w);
            r18.w = r18.w * r7.w;
            r13.w = r13.w * r1.w + r18.w;
            r13.w = max(0, r13.w);
            r16.x = 0.00999999978 * r16.x;
            r17.w = log2(r17.w);
            r17.w = 30.3999996 * r17.w;
            r17.w = exp2(r17.w);
            r17.w = 0.0500000007 * r17.w;
            r13.w = log2(r13.w);
            r13.w = 15.8000002 * r13.w;
            r13.w = exp2(r13.w);
            r13.w = 0.100000001 * r13.w;
            r19.xyz = r16.xxx * r15.yzw;
            r20.xyz = r17.www * r15.yzw;
            r20.xyz = r20.xyz * r3.zzz;
            r20.xyz = float3(1.5,1.5,1.5) * r20.xyz;
            r19.xyz = r19.xyz * r6.xyz + r20.xyz;
            r20.xyz = r13.www * r15.yzw;
            r20.xyz = r20.xyz * r6.xyz;
            r20.xyz = r20.xyz * r3.zzz;
            r19.xyz = r20.xyz * float3(1.5,1.5,1.5) + r19.xyz;
            r20.xyz = -r14.yzw * r13.zzz + -r7.xyz;
            r13.w = dot(r20.xyz, r20.xyz);
            r13.w = max(0.00100000005, r13.w);
            r13.w = rsqrt(r13.w);
            r20.xyz = r20.xyz * r13.www;
            r13.w = dot(-r17.xyz, r20.xyz);
            r13.w = max(0, r13.w);
            r16.x = 1 + -r13.y;
            r17.w = r16.x * r16.x;
            r17.w = r17.w * r17.w;
            r16.x = r17.w * r16.x;
            r17.w = r13.w + r13.w;
            r13.w = r17.w * r13.w;
            r13.w = r13.w * r3.y + r6.w;
            r13.w = -1 + r13.w;
            r16.x = r13.w * r16.x + 1;
            r13.w = r13.w * r10.w + 1;
            r13.w = r16.x * r13.w;
            r13.w = r13.w * r9.w;
            r13.w = r13.w * r13.y;
            r20.xyz = r15.yzw * r13.www;
            r20.xyz = r20.xyz * r6.xyz;
            r19.xyz = r20.xyz * float3(0.25,0.25,0.25) + r19.xyz;
            r18.xyz = r19.xyz * r2.www;
          } else {
            r11.w = cmp(r11.w >= 0);
            r14.yzw = -r14.yzw * r13.zzz + -r7.xyz;
            r13.z = dot(r14.yzw, r14.yzw);
            r13.z = max(0.00100000005, r13.z);
            r13.z = rsqrt(r13.z);
            r14.yzw = r14.yzw * r13.zzz;
            r13.z = dot(r10.xyz, r14.yzw);
            r13.w = dot(-r17.xyz, r14.yzw);
            r13.zw = max(float2(0,0), r13.zw);
            r14.y = r13.y * r0.w + r3.y;
            r14.y = r14.y * r1.x;
            r14.y = r13.y * r3.x + r14.y;
            r14.y = 9.99999975e-006 + r14.y;
            r14.y = 0.5 / r14.y;
            r14.z = r13.z * r4.w + -r13.z;
            r13.z = r14.z * r13.z + 1;
            r13.z = r13.z * r13.z + 1.00000001e-007;
            r13.z = r5.w / r13.z;
            r14.z = 1 + -r13.y;
            r14.w = r14.z * r14.z;
            r14.w = r14.w * r14.w;
            r14.z = r14.w * r14.z;
            r14.w = r13.w + r13.w;
            r14.w = r14.w * r13.w;
            r14.w = r14.w * r3.y + r6.w;
            r14.w = -1 + r14.w;
            r14.z = r14.w * r14.z + 1;
            r14.w = r14.w * r10.w + 1;
            r14.z = r14.z * r14.w;
            r14.z = r14.z * r9.w;
            r13.z = r14.y * r13.z;
            r13.z = 3.14159274 * r13.z;
            r13.z = r13.z * r13.y;
            r13.z = max(0, r13.z);
            r13.y = r14.z * r13.y;
            r14.yzw = r15.yzw * r13.yyy;
            r15.yzw = r13.zzz * r15.yzw;
            r13.y = 1 + -r13.w;
            r13.z = r13.y * r13.y;
            r13.z = r13.z * r13.z;
            r13.y = r13.z * r13.y;
            r13.yzw = r5.xyz * r13.yyy + r9.xyz;
            r13.yzw = r15.yzw * r13.yzw;
            r11.w = r11.w ? 1.000000 : 0;
            r13.yzw = r13.yzw * r11.www;
            r18.xyz = r6.xyz * r14.yzw + r13.yzw;
          }
        }
      } else {
        r18.xyz = float3(0,0,0);
      }
      r12.yzw = r18.xyz + r12.yzw;
      r3.w = (int)r3.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r13.yzw = r12.yzw;
    r0.y = r3.w;
    [loop] while (true) {
      r0.z = cmp((int)r0.y >= (int)r0.x);
      [branch] if (r0.z != 0) break;
      r0.z = _BT_LinkListBuffer[r0.y].val[0/4];
      r17.x = _BT_LightBuffer[r0.z].val[0/4];
      r17.y = _BT_LightBuffer[r0.z].val[0/4+1];
      r17.z = _BT_LightBuffer[r0.z].val[0/4+2];
      r17.w = _BT_LightBuffer[r0.z].val[0/4+3];
      r11.w = _BT_LightBuffer[r0.z].val[32/4];
      r14.y = _BT_LightBuffer[r0.z].val[48/4];
      r14.z = _BT_LightBuffer[r0.z].val[48/4+1];
      r14.w = (uint)r0.z << 2;
      r11.w = frac(r11.w);
      r15.yzw = -r17.xyz + r8.xyz;
      r16.x = dot(r15.yzw, r15.yzw);
      r16.y = r17.w * r17.w;
      r18.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][1], _BT_LightMatrix[(uint)(r14.w) / 4u][1][1], _BT_LightMatrix[(uint)(r14.w) / 4u][2][1], _BT_LightMatrix[(uint)(r14.w) / 4u][3][1]) * r8.yyyy;
      r18.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][0], _BT_LightMatrix[(uint)(r14.w) / 4u][1][0], _BT_LightMatrix[(uint)(r14.w) / 4u][2][0], _BT_LightMatrix[(uint)(r14.w) / 4u][3][0]) * r8.xxxx + r18.xyzw;
      r18.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][2], _BT_LightMatrix[(uint)(r14.w) / 4u][1][2], _BT_LightMatrix[(uint)(r14.w) / 4u][2][2], _BT_LightMatrix[(uint)(r14.w) / 4u][3][2]) * r8.zzzz + r18.xyzw;
      r18.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][3], _BT_LightMatrix[(uint)(r14.w) / 4u][1][3], _BT_LightMatrix[(uint)(r14.w) / 4u][2][3], _BT_LightMatrix[(uint)(r14.w) / 4u][3][3]) * r8.wwww + r18.xyzw;
      r14.w = max(0.100000001, r16.x);
      r16.y = r14.w / r16.y;
      r16.y = -r16.y * r16.y + 1;
      r16.y = max(0, r16.y);
      r16.y = r16.y * r16.y;
      r11.w = r17.w * r11.w + r14.w;
      r11.w = 1 / r11.w;
      r11.w = r11.w * r16.y;
      r17.xyz = r18.xyz / r18.www;
      r14.w = cmp(0 >= r17.z);
      r17.zw = cmp(float2(1,1) < r17.xy);
      r14.w = (int)r14.w | (int)r17.z;
      r18.xy = cmp(r17.xy < float2(-1,-1));
      r14.w = (int)r14.w | (int)r18.x;
      r14.w = (int)r17.w | (int)r14.w;
      r14.w = (int)r18.y | (int)r14.w;
      r14.y = r14.y / r14.z;
      r14.y = min(0.99000001, r14.y);
      r14.z = dot(r17.xy, r17.xy);
      r14.z = sqrt(r14.z);
      r14.z = min(1, r14.z);
      r14.yz = float2(-1,-1) + r14.yz;
      r14.y = 1 / r14.y;
      r14.y = r14.z * r14.y;
      r14.y = min(1, r14.y);
      r14.z = r14.y * -2 + 3;
      r14.y = r14.y * r14.y;
      r14.y = r14.z * r14.y;
      r14.z = cmp(r14.y != 0.000000);
      r14.y = r14.z ? r14.y : 0;
      r14.y = r14.w ? 0 : r14.y;
      r11.w = r14.y * r11.w;
      r14.y = cmp(r11.w != 0.000000);
      [branch] if (r14.y != 0) {
        r14.y = _BT_LightBuffer[r0.z].val[16/4];
        r14.z = _BT_LightBuffer[r0.z].val[16/4+1];
        r14.w = _BT_LightBuffer[r0.z].val[16/4+2];
        r0.z = _BT_LightBuffer[r0.z].val[60/4];
        r16.x = rsqrt(r16.x);
        r17.xyz = r16.xxx * r15.yzw;
        r14.yzw = r14.yzw * r11.www;
        r11.w = dot(r4.xyz, -r17.xyz);
        r11.w = max(0, r11.w);
        [branch] if (r1.y != 0) {
          r16.y = cmp(r0.z >= 0);
          r18.xyz = -r15.yzw * r16.xxx + -r7.xyz;
          r17.w = dot(r18.xyz, r18.xyz);
          r17.w = max(0.00100000005, r17.w);
          r17.w = rsqrt(r17.w);
          r18.xyz = r18.xyz * r17.www;
          r17.w = dot(r10.xyz, r18.xyz);
          r17.w = max(0, r17.w);
          r18.x = dot(-r17.xyz, r18.xyz);
          r18.x = max(0, r18.x);
          r18.y = r11.w * r0.w + r3.y;
          r18.y = r18.y * r1.x;
          r18.y = r11.w * r3.x + r18.y;
          r18.y = 9.99999975e-006 + r18.y;
          r18.y = 0.5 / r18.y;
          r18.z = r17.w * r4.w + -r17.w;
          r17.w = r18.z * r17.w + 1;
          r17.w = r17.w * r17.w + 1.00000001e-007;
          r17.w = r5.w / r17.w;
          r17.w = r18.y * r17.w;
          r17.w = 3.14159274 * r17.w;
          r17.w = r17.w * r11.w;
          r17.w = max(0, r17.w);
          r18.yzw = r17.www * r14.yzw;
          r17.w = 1 + -r18.x;
          r18.x = r17.w * r17.w;
          r18.x = r18.x * r18.x;
          r17.w = r18.x * r17.w;
          r19.xyz = r5.xyz * r17.www + r9.xyz;
          r18.xyz = r19.xyz * r18.yzw;
          r16.y = r16.y ? 1.000000 : 0;
          r17.w = dot(r11.xyz, -r17.xyz);
          r16.z = r17.w * 0.5 + 0.5;
          r19.xyz = _BT_PreIntegratedSSS.SampleLevel(sampler_BT_PreIntegratedSSS, r16.zw, 0).xyz;
          r19.xyz = r19.xyz * r14.yzw;
          r19.xyz = r19.xyz * r6.xyz;
          r18.xyz = r18.xyz * r16.yyy + r19.xyz;
        } else {
          [branch] if (r1.z != 0) {
            r16.y = dot(r2.xyz, -r17.xyz);
            r16.z = -r16.y * r16.y + 1;
            r16.z = sqrt(r16.z);
            r17.w = r16.z * r12.x;
            r17.w = -r16.y * r13.x + -r17.w;
            r18.w = -r17.w * r17.w + 1;
            r18.w = sqrt(r18.w);
            r18.w = r18.w * r7.w;
            r17.w = r17.w * r1.w + r18.w;
            r17.w = max(0, r17.w);
            r18.w = r16.z * r14.x;
            r16.y = -r16.y * r15.x + -r18.w;
            r18.w = -r16.y * r16.y + 1;
            r18.w = sqrt(r18.w);
            r18.w = r18.w * r7.w;
            r16.y = r16.y * r1.w + r18.w;
            r16.y = max(0, r16.y);
            r17.w = log2(r17.w);
            r17.w = 30.3999996 * r17.w;
            r17.w = exp2(r17.w);
            r17.w = 0.0500000007 * r17.w;
            r16.y = log2(r16.y);
            r16.yz = float2(15.8000002,0.00999999978) * r16.yz;
            r16.y = exp2(r16.y);
            r16.y = 0.100000001 * r16.y;
            r19.xyz = r16.zzz * r14.yzw;
            r20.xyz = r17.www * r14.yzw;
            r20.xyz = r20.xyz * r3.zzz;
            r20.xyz = float3(1.5,1.5,1.5) * r20.xyz;
            r19.xyz = r19.xyz * r6.xyz + r20.xyz;
            r20.xyz = r16.yyy * r14.yzw;
            r20.xyz = r20.xyz * r6.xyz;
            r20.xyz = r20.xyz * r3.zzz;
            r19.xyz = r20.xyz * float3(1.5,1.5,1.5) + r19.xyz;
            r20.xyz = -r15.yzw * r16.xxx + -r7.xyz;
            r16.y = dot(r20.xyz, r20.xyz);
            r16.y = max(0.00100000005, r16.y);
            r16.y = rsqrt(r16.y);
            r20.xyz = r20.xyz * r16.yyy;
            r16.y = dot(-r17.xyz, r20.xyz);
            r16.y = max(0, r16.y);
            r16.z = 1 + -r11.w;
            r17.w = r16.z * r16.z;
            r17.w = r17.w * r17.w;
            r16.z = r17.w * r16.z;
            r17.w = r16.y + r16.y;
            r16.y = r17.w * r16.y;
            r16.y = r16.y * r3.y + r6.w;
            r16.y = -1 + r16.y;
            r16.z = r16.y * r16.z + 1;
            r16.y = r16.y * r10.w + 1;
            r16.y = r16.z * r16.y;
            r16.y = r16.y * r9.w;
            r16.y = r16.y * r11.w;
            r20.xyz = r16.yyy * r14.yzw;
            r20.xyz = r20.xyz * r6.xyz;
            r19.xyz = r20.xyz * float3(0.25,0.25,0.25) + r19.xyz;
            r18.xyz = r19.xyz * r2.www;
          } else {
            r0.z = cmp(r0.z >= 0);
            r15.yzw = -r15.yzw * r16.xxx + -r7.xyz;
            r16.x = dot(r15.yzw, r15.yzw);
            r16.x = max(0.00100000005, r16.x);
            r16.x = rsqrt(r16.x);
            r15.yzw = r16.xxx * r15.yzw;
            r16.x = dot(r10.xyz, r15.yzw);
            r16.x = max(0, r16.x);
            r15.y = dot(-r17.xyz, r15.yzw);
            r15.y = max(0, r15.y);
            r15.z = r11.w * r0.w + r3.y;
            r15.z = r15.z * r1.x;
            r15.z = r11.w * r3.x + r15.z;
            r15.z = 9.99999975e-006 + r15.z;
            r15.z = 0.5 / r15.z;
            r15.w = r16.x * r4.w + -r16.x;
            r15.w = r15.w * r16.x + 1;
            r15.w = r15.w * r15.w + 1.00000001e-007;
            r15.w = r5.w / r15.w;
            r16.x = 1 + -r11.w;
            r16.y = r16.x * r16.x;
            r16.y = r16.y * r16.y;
            r16.x = r16.y * r16.x;
            r16.y = r15.y + r15.y;
            r16.y = r16.y * r15.y;
            r16.y = r16.y * r3.y + r6.w;
            r16.y = -1 + r16.y;
            r16.x = r16.y * r16.x + 1;
            r16.y = r16.y * r10.w + 1;
            r16.x = r16.x * r16.y;
            r16.x = r16.x * r9.w;
            r15.z = r15.z * r15.w;
            r15.z = 3.14159274 * r15.z;
            r15.z = r15.z * r11.w;
            r15.z = max(0, r15.z);
            r11.w = r16.x * r11.w;
            r16.xyz = r14.yzw * r11.www;
            r14.yzw = r15.zzz * r14.yzw;
            r11.w = 1 + -r15.y;
            r15.y = r11.w * r11.w;
            r15.y = r15.y * r15.y;
            r11.w = r15.y * r11.w;
            r15.yzw = r5.xyz * r11.www + r9.xyz;
            r14.yzw = r15.yzw * r14.yzw;
            r0.z = r0.z ? 1.000000 : 0;
            r14.yzw = r14.yzw * r0.zzz;
            r18.xyz = r6.xyz * r16.xyz + r14.yzw;
          }
        }
      } else {
        r18.xyz = float3(0,0,0);
      }
      r13.yzw = r18.xyz + r13.yzw;
      r0.y = (int)r0.y + 1;
    }
    r0.xyz = float3(8,8,8) * r13.yzw;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 4372c39de71933c6: 2 retail keyword combination(s)
void ps_4372c39de71933c6_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r1.yz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xy = cmp(r3.ww == float2(0.666666687,0.333333343));
    r0.w = (int)r4.y | (int)r4.x;
    r5.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r4.xzw = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r2.xyz;
    r4.xzw = r1.yyy * r4.xzw + float3(0.0399999991,0.0399999991,0.0399999991);
    r1.w = 0.100000001 * r1.z;
    r1.y = -r1.y * 0.959999979 + 0.959999979;
    r6.xyz = r2.xyz * r1.yyy;
    r5.w = 0.0195999984;
    r6.w = r4.x;
    r5.xyzw = r0.wwww ? r5.xyzw : r6.xyzw;
    r2.yz = r0.ww ? float2(0.0195999984,0.0195999984) : r4.zw;
    r0.w = r0.w ? r1.w : r1.z;
    r6.xyz = float3(0.100000001,0.100000001,0.100000001) * r5.xyz;
    r2.x = r5.w;
    r1.yzw = float3(0.5,0.5,0.5) * r2.xyz;
    r6.w = r1.y;
    r5.xyzw = r4.yyyy ? r6.xyzw : r5.xyzw;
    r2.yz = r4.yy ? r1.zw : r2.yz;
    r1.yzw = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r3.x = dot(r1.yzw, r1.yzw);
    r3.x = rsqrt(r3.x);
    r1.yzw = r3.xxx * r1.yzw;
    r3.z = 1 + -r1.x;
    r3.xy = v0.zw;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r4.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r3.yyyy;
    r4.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r3.xxxx + r4.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r3.zzzz + r4.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r3.xyzw;
    r3.xyz = r3.xyz / r3.www;
    r4.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r3.yyyy;
    r4.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r3.xxxx + r4.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r3.zzzz + r4.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r3.xyzw;
    r4.xyz = -_WorldSpaceCameraPos.xyz + r3.xyz;
    r1.x = dot(r4.xyz, r4.xyz);
    r1.x = rsqrt(r1.x);
    r4.xyz = r4.xyz * r1.xxx;
    r1.x = dot(r1.yzw, -r4.xyz);
    r4.w = saturate(r1.x);
    r0.y = (int)r0.y + (int)r0.x;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.x = r5.w;
    r6.xyz = r2.xyz * r2.www;
    r0.w = 1 + -r0.w;
    r5.w = r0.w * r0.w;
    r6.w = cmp(r1.x < 0);
    r1.x = 9.99999975e-006 + -r1.x;
    r7.xyz = -r4.xyz * r1.xxx + r1.yzw;
    r7.xyz = r6.www ? r7.xyz : r1.yzw;
    r0.w = -r0.w * r0.w + 1;
    r1.x = r4.w * r0.w + r5.w;
    r6.w = r5.w * r5.w;
    r7.w = 0.318309873 * r6.w;
    r8.x = 0.5 * r5.w;
    r8.y = r5.w * -0.337748349 + 1;
    r8.z = 1 + -r4.w;
    r8.w = r8.z * r8.z;
    r8.w = r8.w * r8.w;
    r8.z = r8.w * r8.z;
    r2.xyz = -r2.xyz * r2.www + float3(1,1,1);
    r9.xyz = float3(0,0,0);
    r2.w = r0.x;
    [loop] while (true) {
      r8.w = cmp((int)r2.w >= (int)r0.y);
      [branch] if (r8.w != 0) break;
      r8.w = _BT_LinkListBuffer[r2.w].val[0/4];
      r10.x = _BT_LightBuffer[r8.w].val[0/4];
      r10.y = _BT_LightBuffer[r8.w].val[0/4+1];
      r10.z = _BT_LightBuffer[r8.w].val[0/4+2];
      r10.w = _BT_LightBuffer[r8.w].val[0/4+3];
      r9.w = _BT_LightBuffer[r8.w].val[32/4];
      r10.xyz = -r10.xyz + r3.xyz;
      r11.x = dot(r10.xyz, r10.xyz);
      r11.y = r10.w * r10.w;
      r11.z = max(0.100000001, r11.x);
      r11.y = r11.z / r11.y;
      r11.y = -r11.y * r11.y + 1;
      r11.y = max(0, r11.y);
      r11.y = r11.y * r11.y;
      r9.w = r10.w * r9.w + r11.z;
      r9.w = 1 / r9.w;
      r9.w = r9.w * r11.y;
      r10.w = cmp(r9.w != 0.000000);
      [branch] if (r10.w != 0) {
        r11.y = _BT_LightBuffer[r8.w].val[16/4];
        r11.z = _BT_LightBuffer[r8.w].val[16/4+1];
        r11.w = _BT_LightBuffer[r8.w].val[16/4+2];
        r8.w = _BT_LightBuffer[r8.w].val[60/4];
        r10.w = rsqrt(r11.x);
        r12.xyz = r10.xyz * r10.www;
        r11.xyz = r11.yzw * r9.www;
        r9.w = dot(r1.yzw, -r12.xyz);
        r9.w = max(0, r9.w);
        r8.w = cmp(r8.w >= 0);
        r10.xyz = -r10.xyz * r10.www + -r4.xyz;
        r10.w = dot(r10.xyz, r10.xyz);
        r10.w = max(0.00100000005, r10.w);
        r10.w = rsqrt(r10.w);
        r10.xyz = r10.xyz * r10.www;
        r10.w = dot(r7.xyz, r10.xyz);
        r10.x = dot(-r12.xyz, r10.xyz);
        r10.xw = max(float2(0,0), r10.xw);
        r10.y = r9.w * r0.w + r5.w;
        r10.y = r10.y * r4.w;
        r10.y = r9.w * r1.x + r10.y;
        r10.y = 9.99999975e-006 + r10.y;
        r10.y = 0.5 / r10.y;
        r10.z = r10.w * r6.w + -r10.w;
        r10.z = r10.z * r10.w + 1;
        r10.z = r10.z * r10.z + 1.00000001e-007;
        r10.z = r7.w / r10.z;
        r10.w = 1 + -r9.w;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r11.w = r10.x + r10.x;
        r11.w = r11.w * r10.x;
        r11.w = r11.w * r5.w + r8.x;
        r11.w = -1 + r11.w;
        r10.w = r11.w * r10.w + 1;
        r11.w = r11.w * r8.z + 1;
        r10.w = r11.w * r10.w;
        r10.w = r10.w * r8.y;
        r10.y = r10.y * r10.z;
        r10.y = 3.14159274 * r10.y;
        r10.y = r10.y * r9.w;
        r10.y = max(0, r10.y);
        r9.w = r10.w * r9.w;
        r12.xyz = r11.xyz * r9.www;
        r10.yzw = r10.yyy * r11.xyz;
        r9.w = 1 + -r10.x;
        r10.x = r9.w * r9.w;
        r10.x = r10.x * r10.x;
        r9.w = r10.x * r9.w;
        r11.xyz = r2.xyz * r9.www + r6.xyz;
        r10.xyz = r11.xyz * r10.yzw;
        r8.w = r8.w ? 1.000000 : 0;
        r10.xyz = r10.xyz * r8.www;
        r10.xyz = r5.xyz * r12.xyz + r10.xyz;
      } else {
        r10.xyz = float3(0,0,0);
      }
      r9.xyz = r10.xyz + r9.xyz;
      r2.w = (int)r2.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r10.xyz = r9.xyz;
    r0.y = r2.w;
    [loop] while (true) {
      r0.z = cmp((int)r0.y >= (int)r0.x);
      [branch] if (r0.z != 0) break;
      r0.z = _BT_LinkListBuffer[r0.y].val[0/4];
      r11.x = _BT_LightBuffer[r0.z].val[0/4];
      r11.y = _BT_LightBuffer[r0.z].val[0/4+1];
      r11.z = _BT_LightBuffer[r0.z].val[0/4+2];
      r11.w = _BT_LightBuffer[r0.z].val[0/4+3];
      r8.w = _BT_LightBuffer[r0.z].val[32/4];
      r12.x = _BT_LightBuffer[r0.z].val[48/4];
      r12.y = _BT_LightBuffer[r0.z].val[48/4+1];
      r9.w = (uint)r0.z << 2;
      r8.w = frac(r8.w);
      r11.xyz = -r11.xyz + r3.xyz;
      r10.w = dot(r11.xyz, r11.xyz);
      r12.z = r11.w * r11.w;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][1], _BT_LightMatrix[(uint)(r9.w) / 4u][1][1], _BT_LightMatrix[(uint)(r9.w) / 4u][2][1], _BT_LightMatrix[(uint)(r9.w) / 4u][3][1]) * r3.yyyy;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][0], _BT_LightMatrix[(uint)(r9.w) / 4u][1][0], _BT_LightMatrix[(uint)(r9.w) / 4u][2][0], _BT_LightMatrix[(uint)(r9.w) / 4u][3][0]) * r3.xxxx + r13.xyzw;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][2], _BT_LightMatrix[(uint)(r9.w) / 4u][1][2], _BT_LightMatrix[(uint)(r9.w) / 4u][2][2], _BT_LightMatrix[(uint)(r9.w) / 4u][3][2]) * r3.zzzz + r13.xyzw;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][3], _BT_LightMatrix[(uint)(r9.w) / 4u][1][3], _BT_LightMatrix[(uint)(r9.w) / 4u][2][3], _BT_LightMatrix[(uint)(r9.w) / 4u][3][3]) * r3.wwww + r13.xyzw;
      r9.w = max(0.100000001, r10.w);
      r12.z = r9.w / r12.z;
      r12.z = -r12.z * r12.z + 1;
      r12.z = max(0, r12.z);
      r12.z = r12.z * r12.z;
      r8.w = r11.w * r8.w + r9.w;
      r8.w = 1 / r8.w;
      r8.w = r8.w * r12.z;
      r13.xyz = r13.xyz / r13.www;
      r9.w = cmp(0 >= r13.z);
      r12.zw = cmp(float2(1,1) < r13.xy);
      r9.w = (int)r9.w | (int)r12.z;
      r13.zw = cmp(r13.xy < float2(-1,-1));
      r9.w = (int)r9.w | (int)r13.z;
      r9.w = (int)r12.w | (int)r9.w;
      r9.w = (int)r13.w | (int)r9.w;
      r11.w = r12.x / r12.y;
      r11.w = min(0.99000001, r11.w);
      r12.x = dot(r13.xy, r13.xy);
      r12.x = sqrt(r12.x);
      r12.x = min(1, r12.x);
      r11.w = -1 + r11.w;
      r12.x = -1 + r12.x;
      r11.w = 1 / r11.w;
      r11.w = r12.x * r11.w;
      r11.w = min(1, r11.w);
      r12.x = r11.w * -2 + 3;
      r11.w = r11.w * r11.w;
      r11.w = r12.x * r11.w;
      r12.x = cmp(r11.w != 0.000000);
      r11.w = r12.x ? r11.w : 0;
      r9.w = r9.w ? 0 : r11.w;
      r8.w = r9.w * r8.w;
      r9.w = cmp(r8.w != 0.000000);
      [branch] if (r9.w != 0) {
        r12.x = _BT_LightBuffer[r0.z].val[16/4];
        r12.y = _BT_LightBuffer[r0.z].val[16/4+1];
        r12.z = _BT_LightBuffer[r0.z].val[16/4+2];
        r0.z = _BT_LightBuffer[r0.z].val[60/4];
        r9.w = rsqrt(r10.w);
        r13.xyz = r11.xyz * r9.www;
        r12.xyz = r12.xyz * r8.www;
        r8.w = dot(r1.yzw, -r13.xyz);
        r8.w = max(0, r8.w);
        r0.z = cmp(r0.z >= 0);
        r11.xyz = -r11.xyz * r9.www + -r4.xyz;
        r9.w = dot(r11.xyz, r11.xyz);
        r9.w = max(0.00100000005, r9.w);
        r9.w = rsqrt(r9.w);
        r11.xyz = r11.xyz * r9.www;
        r9.w = dot(r7.xyz, r11.xyz);
        r9.w = max(0, r9.w);
        r10.w = dot(-r13.xyz, r11.xyz);
        r10.w = max(0, r10.w);
        r11.x = r8.w * r0.w + r5.w;
        r11.x = r11.x * r4.w;
        r11.x = r8.w * r1.x + r11.x;
        r11.x = 9.99999975e-006 + r11.x;
        r11.x = 0.5 / r11.x;
        r11.y = r9.w * r6.w + -r9.w;
        r9.w = r11.y * r9.w + 1;
        r9.w = r9.w * r9.w + 1.00000001e-007;
        r9.w = r7.w / r9.w;
        r11.y = 1 + -r8.w;
        r11.z = r11.y * r11.y;
        r11.z = r11.z * r11.z;
        r11.y = r11.z * r11.y;
        r11.z = r10.w + r10.w;
        r11.z = r11.z * r10.w;
        r11.z = r11.z * r5.w + r8.x;
        r11.z = -1 + r11.z;
        r11.y = r11.z * r11.y + 1;
        r11.z = r11.z * r8.z + 1;
        r11.y = r11.y * r11.z;
        r11.y = r11.y * r8.y;
        r9.w = r11.x * r9.w;
        r9.w = 3.14159274 * r9.w;
        r9.w = r9.w * r8.w;
        r9.w = max(0, r9.w);
        r8.w = r11.y * r8.w;
        r11.xyz = r12.xyz * r8.www;
        r12.xyz = r9.www * r12.xyz;
        r8.w = 1 + -r10.w;
        r9.w = r8.w * r8.w;
        r9.w = r9.w * r9.w;
        r8.w = r9.w * r8.w;
        r13.xyz = r2.xyz * r8.www + r6.xyz;
        r12.xyz = r13.xyz * r12.xyz;
        r0.z = r0.z ? 1.000000 : 0;
        r12.xyz = r12.xyz * r0.zzz;
        r11.xyz = r5.xyz * r11.xyz + r12.xyz;
      } else {
        r11.xyz = float3(0,0,0);
      }
      r10.xyz = r11.xyz + r10.xyz;
      r0.y = (int)r0.y + 1;
    }
    r0.xyz = float3(8,8,8) * r10.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 6488bfbd163c3458: 1 retail keyword combination(s)
void ps_6488bfbd163c3458_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyzw = _BT_ListEntries.Load(r0.xywz).xyzw;
  r1.y = cmp((int)r0.x >= 0);
  [branch] if (r1.y != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r1.yz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xy = cmp(r3.ww == float2(0.666666687,0.333333343));
    r1.w = (int)r4.y | (int)r4.x;
    r4.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r5.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,1) + r2.xyzw;
    r5.xyz = r1.yyy * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r1.y = -r1.y * 0.959999979 + 0.959999979;
    r6.xyz = r2.xyz * r1.yyy;
    r4.w = 0.0195999984;
    r6.w = r5.x;
    r4.xyzw = r1.wwww ? r4.xyzw : r6.xyzw;
    r2.yz = r1.ww ? float2(0.0195999984,0.0195999984) : r5.yz;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r1.y = dot(r3.xyz, r3.xyz);
    r1.y = rsqrt(r1.y);
    r3.xyz = r3.xyz * r1.yyy;
    r5.z = 1 + -r1.x;
    r5.xy = v0.zw;
    r1.xyw = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r1.yyyy;
    r6.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r1.xxxx + r6.xyzw;
    r6.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r1.wwww + r6.xyzw;
    r6.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r6.xyzw;
    r1.xyw = r6.xyz / r6.www;
    r6.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r1.yyyy;
    r6.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r1.xxxx + r6.xyzw;
    r6.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r1.wwww + r6.xyzw;
    r6.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r6.xyzw;
    r1.xyw = -_WorldSpaceCameraPos.xyz + r6.xyz;
    r5.x = dot(r1.xyw, r1.xyw);
    r5.x = rsqrt(r5.x);
    r7.xyz = r5.xxx * r1.xyw;
    r3.w = cmp(0 < r3.w);
    r5.y = 0.5 * r5.w;
    r8.xyz = r5.yyy * r4.xyz;
    r2.x = r4.w;
    r5.yzw = r2.xyz * r2.www;
    r8.w = r5.y;
    r4.xyzw = r3.wwww ? r8.xyzw : r4.xyzw;
    r2.yz = r3.ww ? r5.zw : r2.yz;
    r3.w = dot(r3.xyz, -r7.xyz);
    r5.y = max(0, r3.w);
    r5.z = min(1, r5.y);
    r0.y = (int)r0.y + (int)r0.x;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.x = r4.w;
    r8.xyz = r2.xyz * r2.www;
    r1.z = 1 + -r1.z;
    r4.w = r1.z * r1.z;
    r5.w = cmp(r3.w < 0);
    r7.w = 9.99999975e-006 + -r3.w;
    r9.xyz = -r7.xyz * r7.www + r3.xyz;
    r9.xyz = r5.www ? r9.xyz : r3.xyz;
    r5.w = -r1.z * r1.z + 1;
    r7.w = r5.z * r5.w + r4.w;
    r8.w = r4.w * r4.w;
    r9.w = 0.318309873 * r8.w;
    r10.x = 0.5 * r4.w;
    r10.y = r4.w * -0.337748349 + 1;
    r10.z = 1 + -r5.z;
    r10.w = r10.z * r10.z;
    r10.w = r10.w * r10.w;
    r10.z = r10.w * r10.z;
    r11.xyz = -r2.xyz * r2.www + float3(1,1,1);
    r12.xyz = float3(0,0,0);
    r2.w = r0.x;
    [loop] while (true) {
      r10.w = cmp((int)r2.w >= (int)r0.y);
      [branch] if (r10.w != 0) break;
      r10.w = _BT_LinkListBuffer[r2.w].val[0/4];
      r13.x = _BT_LightBuffer[r10.w].val[0/4];
      r13.y = _BT_LightBuffer[r10.w].val[0/4+1];
      r13.z = _BT_LightBuffer[r10.w].val[0/4+2];
      r13.w = _BT_LightBuffer[r10.w].val[0/4+3];
      r11.w = _BT_LightBuffer[r10.w].val[32/4];
      r13.xyz = -r13.xyz + r6.xyz;
      r12.w = dot(r13.xyz, r13.xyz);
      r14.x = r13.w * r13.w;
      r14.y = max(0.100000001, r12.w);
      r14.x = r14.y / r14.x;
      r14.x = -r14.x * r14.x + 1;
      r14.x = max(0, r14.x);
      r14.x = r14.x * r14.x;
      r11.w = r13.w * r11.w + r14.y;
      r11.w = 1 / r11.w;
      r11.w = r11.w * r14.x;
      r13.w = cmp(r11.w != 0.000000);
      [branch] if (r13.w != 0) {
        r14.x = _BT_LightBuffer[r10.w].val[16/4];
        r14.y = _BT_LightBuffer[r10.w].val[16/4+1];
        r14.z = _BT_LightBuffer[r10.w].val[16/4+2];
        r10.w = _BT_LightBuffer[r10.w].val[60/4];
        r12.w = rsqrt(r12.w);
        r15.xyz = r13.xyz * r12.www;
        r14.xyz = r14.xyz * r11.www;
        r11.w = dot(r3.xyz, -r15.xyz);
        r11.w = max(0, r11.w);
        r10.w = cmp(r10.w >= 0);
        r13.xyz = -r13.xyz * r12.www + -r7.xyz;
        r12.w = dot(r13.xyz, r13.xyz);
        r12.w = max(0.00100000005, r12.w);
        r12.w = rsqrt(r12.w);
        r13.xyz = r13.xyz * r12.www;
        r12.w = dot(r9.xyz, r13.xyz);
        r12.w = max(0, r12.w);
        r13.x = dot(-r15.xyz, r13.xyz);
        r13.x = max(0, r13.x);
        r13.y = r11.w * r5.w + r4.w;
        r13.y = r13.y * r5.z;
        r13.y = r11.w * r7.w + r13.y;
        r13.y = 9.99999975e-006 + r13.y;
        r13.y = 0.5 / r13.y;
        r13.z = r12.w * r8.w + -r12.w;
        r12.w = r13.z * r12.w + 1;
        r12.w = r12.w * r12.w + 1.00000001e-007;
        r12.w = r9.w / r12.w;
        r13.z = 1 + -r11.w;
        r13.w = r13.z * r13.z;
        r13.w = r13.w * r13.w;
        r13.z = r13.w * r13.z;
        r13.w = r13.x + r13.x;
        r13.w = r13.w * r13.x;
        r13.w = r13.w * r4.w + r10.x;
        r13.w = -1 + r13.w;
        r13.z = r13.w * r13.z + 1;
        r13.w = r13.w * r10.z + 1;
        r13.z = r13.z * r13.w;
        r13.z = r13.z * r10.y;
        r12.w = r13.y * r12.w;
        r12.w = 3.14159274 * r12.w;
        r12.w = r12.w * r11.w;
        r12.w = max(0, r12.w);
        r11.w = r13.z * r11.w;
        r13.yzw = r14.xyz * r11.www;
        r14.xyz = r12.www * r14.xyz;
        r11.w = 1 + -r13.x;
        r12.w = r11.w * r11.w;
        r12.w = r12.w * r12.w;
        r11.w = r12.w * r11.w;
        r15.xyz = r11.xyz * r11.www + r8.xyz;
        r14.xyz = r15.xyz * r14.xyz;
        r10.w = r10.w ? 1.000000 : 0;
        r14.xyz = r14.xyz * r10.www;
        r13.xyz = r4.xyz * r13.yzw + r14.xyz;
      } else {
        r13.xyz = float3(0,0,0);
      }
      r12.xyz = r13.xyz + r12.xyz;
      r2.w = (int)r2.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r13.xyz = r12.xyz;
    r0.y = r2.w;
    [loop] while (true) {
      r0.z = cmp((int)r0.y >= (int)r0.x);
      [branch] if (r0.z != 0) break;
      r0.z = _BT_LinkListBuffer[r0.y].val[0/4];
      r14.x = _BT_LightBuffer[r0.z].val[0/4];
      r14.y = _BT_LightBuffer[r0.z].val[0/4+1];
      r14.z = _BT_LightBuffer[r0.z].val[0/4+2];
      r14.w = _BT_LightBuffer[r0.z].val[0/4+3];
      r10.w = _BT_LightBuffer[r0.z].val[32/4];
      r15.x = _BT_LightBuffer[r0.z].val[48/4];
      r15.y = _BT_LightBuffer[r0.z].val[48/4+1];
      r11.w = (uint)r0.z << 2;
      r10.w = frac(r10.w);
      r14.xyz = -r14.xyz + r6.xyz;
      r12.w = dot(r14.xyz, r14.xyz);
      r13.w = r14.w * r14.w;
      r16.xyzw = float4(_BT_LightMatrix[(uint)(r11.w) / 4u][0][1], _BT_LightMatrix[(uint)(r11.w) / 4u][1][1], _BT_LightMatrix[(uint)(r11.w) / 4u][2][1], _BT_LightMatrix[(uint)(r11.w) / 4u][3][1]) * r6.yyyy;
      r16.xyzw = float4(_BT_LightMatrix[(uint)(r11.w) / 4u][0][0], _BT_LightMatrix[(uint)(r11.w) / 4u][1][0], _BT_LightMatrix[(uint)(r11.w) / 4u][2][0], _BT_LightMatrix[(uint)(r11.w) / 4u][3][0]) * r6.xxxx + r16.xyzw;
      r16.xyzw = float4(_BT_LightMatrix[(uint)(r11.w) / 4u][0][2], _BT_LightMatrix[(uint)(r11.w) / 4u][1][2], _BT_LightMatrix[(uint)(r11.w) / 4u][2][2], _BT_LightMatrix[(uint)(r11.w) / 4u][3][2]) * r6.zzzz + r16.xyzw;
      r16.xyzw = float4(_BT_LightMatrix[(uint)(r11.w) / 4u][0][3], _BT_LightMatrix[(uint)(r11.w) / 4u][1][3], _BT_LightMatrix[(uint)(r11.w) / 4u][2][3], _BT_LightMatrix[(uint)(r11.w) / 4u][3][3]) * r6.wwww + r16.xyzw;
      r11.w = max(0.100000001, r12.w);
      r13.w = r11.w / r13.w;
      r13.w = -r13.w * r13.w + 1;
      r13.w = max(0, r13.w);
      r13.w = r13.w * r13.w;
      r10.w = r14.w * r10.w + r11.w;
      r10.w = 1 / r10.w;
      r10.w = r10.w * r13.w;
      r16.xyz = r16.xyz / r16.www;
      r11.w = cmp(0 >= r16.z);
      r15.zw = cmp(float2(1,1) < r16.xy);
      r11.w = (int)r11.w | (int)r15.z;
      r16.zw = cmp(r16.xy < float2(-1,-1));
      r11.w = (int)r11.w | (int)r16.z;
      r11.w = (int)r15.w | (int)r11.w;
      r11.w = (int)r16.w | (int)r11.w;
      r13.w = r15.x / r15.y;
      r13.w = min(0.99000001, r13.w);
      r14.w = dot(r16.xy, r16.xy);
      r14.w = sqrt(r14.w);
      r14.w = min(1, r14.w);
      r13.w = -1 + r13.w;
      r14.w = -1 + r14.w;
      r13.w = 1 / r13.w;
      r13.w = r14.w * r13.w;
      r13.w = min(1, r13.w);
      r14.w = r13.w * -2 + 3;
      r13.w = r13.w * r13.w;
      r13.w = r14.w * r13.w;
      r14.w = cmp(r13.w == 0.000000);
      r11.w = (int)r11.w | (int)r14.w;
      r11.w = r11.w ? 0 : r13.w;
      r10.w = r11.w * r10.w;
      r11.w = cmp(r10.w != 0.000000);
      [branch] if (r11.w != 0) {
        r15.x = _BT_LightBuffer[r0.z].val[16/4];
        r15.y = _BT_LightBuffer[r0.z].val[16/4+1];
        r15.z = _BT_LightBuffer[r0.z].val[16/4+2];
        r0.z = _BT_LightBuffer[r0.z].val[60/4];
        r11.w = rsqrt(r12.w);
        r16.xyz = r14.xyz * r11.www;
        r15.xyz = r15.xyz * r10.www;
        r10.w = dot(r3.xyz, -r16.xyz);
        r10.w = max(0, r10.w);
        r0.z = cmp(r0.z >= 0);
        r14.xyz = -r14.xyz * r11.www + -r7.xyz;
        r11.w = dot(r14.xyz, r14.xyz);
        r11.w = max(0.00100000005, r11.w);
        r11.w = rsqrt(r11.w);
        r14.xyz = r14.xyz * r11.www;
        r11.w = dot(r9.xyz, r14.xyz);
        r11.w = max(0, r11.w);
        r12.w = dot(-r16.xyz, r14.xyz);
        r12.w = max(0, r12.w);
        r13.w = r10.w * r5.w + r4.w;
        r13.w = r13.w * r5.z;
        r13.w = r10.w * r7.w + r13.w;
        r13.w = 9.99999975e-006 + r13.w;
        r13.w = 0.5 / r13.w;
        r14.x = r11.w * r8.w + -r11.w;
        r11.w = r14.x * r11.w + 1;
        r11.w = r11.w * r11.w + 1.00000001e-007;
        r11.w = r9.w / r11.w;
        r14.x = 1 + -r10.w;
        r14.y = r14.x * r14.x;
        r14.y = r14.y * r14.y;
        r14.x = r14.y * r14.x;
        r14.y = r12.w + r12.w;
        r14.y = r14.y * r12.w;
        r14.y = r14.y * r4.w + r10.x;
        r14.y = -1 + r14.y;
        r14.x = r14.y * r14.x + 1;
        r14.y = r14.y * r10.z + 1;
        r14.x = r14.x * r14.y;
        r14.x = r14.x * r10.y;
        r11.w = r13.w * r11.w;
        r11.w = 3.14159274 * r11.w;
        r11.w = r11.w * r10.w;
        r11.w = max(0, r11.w);
        r10.w = r14.x * r10.w;
        r14.xyz = r15.xyz * r10.www;
        r15.xyz = r11.www * r15.xyz;
        r10.w = 1 + -r12.w;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r16.xyz = r11.xyz * r10.www + r8.xyz;
        r15.xyz = r16.xyz * r15.xyz;
        r0.z = r0.z ? 1.000000 : 0;
        r15.xyz = r15.xyz * r0.zzz;
        r14.xyz = r4.xyz * r14.xyz + r15.xyz;
      } else {
        r14.xyz = float3(0,0,0);
      }
      r13.xyz = r14.xyz + r13.xyz;
      r0.y = (int)r0.y + 1;
    }
    r0.x = (int)r0.w + (int)r0.x;
    r4.xyz = float3(25,25,25) * r4.xyz;
    r0.z = r3.w + r3.w;
    r7.xyz = r3.xyz * -r0.zzz + -r7.xyz;
    r0.z = -r4.w * 0.5 + 1;
    r0.w = r5.y * r0.z + r10.x;
    r2.w = r4.w * r4.w + -1;
    r3.w = r8.w * r8.w;
    r4.w = 1 + -r5.y;
    r5.y = r4.w * r4.w;
    r5.y = r5.y * r5.y;
    r4.w = r5.y * r4.w;
    r5.yzw = float3(1,1,1) + -r2.xyz;
    r8.xyz = r13.xyz;
    r6.w = r0.y;
    [loop] while (true) {
      r7.w = cmp((int)r6.w >= (int)r0.x);
      [branch] if (r7.w != 0) break;
      r7.w = _BT_LinkListBuffer[r6.w].val[0/4];
      r9.x = _BT_LightBuffer[r7.w].val[0/4];
      r9.y = _BT_LightBuffer[r7.w].val[0/4+1];
      r9.z = _BT_LightBuffer[r7.w].val[0/4+2];
      r9.w = _BT_LightBuffer[r7.w].val[0/4+3];
      r10.y = _BT_LightBuffer[r7.w].val[16/4];
      r10.z = _BT_LightBuffer[r7.w].val[16/4+1];
      r10.w = _BT_LightBuffer[r7.w].val[16/4+2];
      r8.w = _BT_LightBuffer[r7.w].val[32/4];
      r11.x = _BT_LightBuffer[r7.w].val[48/4];
      r11.y = _BT_LightBuffer[r7.w].val[48/4+1];
      r11.z = _BT_LightBuffer[r7.w].val[48/4+2];
      r7.w = r9.w * r9.w;
      r7.w = 1 / r7.w;
      r11.xyz = r11.xyz * r8.www + r9.xyz;
      r9.xyz = r9.xyz + -r6.xyz;
      r11.xyz = r11.xyz + -r6.xyz;
      r8.w = dot(r9.xyz, r9.xyz);
      r9.w = sqrt(r8.w);
      r11.w = dot(r11.xyz, r11.xyz);
      r11.w = sqrt(r11.w);
      r12.x = dot(r9.xyz, r3.xyz);
      r12.y = r9.w + r9.w;
      r12.x = r12.x / r12.y;
      r12.y = dot(r11.xyz, r3.xyz);
      r12.z = r11.w + r11.w;
      r12.y = r12.y / r12.z;
      r12.x = saturate(r12.x + r12.y);
      r12.yzw = r11.xyz + -r9.xyz;
      r13.w = dot(r7.xyz, r9.xyz);
      r14.x = dot(r7.xyz, r12.yzw);
      r14.y = dot(r9.xyz, r12.yzw);
      r14.z = dot(r12.yzw, r12.yzw);
      r8.w = r14.x * r8.w;
      r8.w = r14.y * r13.w + -r8.w;
      r13.w = r14.z * r13.w;
      r13.w = r14.y * r14.x + -r13.w;
      r8.w = saturate(r8.w / r13.w);
      r14.xyz = r12.zwy * r9.zxy;
      r14.xyz = r9.yzx * r12.wyz + -r14.xyz;
      r15.xyz = r12.wyz * r7.yzx;
      r15.xyz = r12.zwy * r7.zxy + -r15.xyz;
      r13.w = dot(r14.xyz, r15.xyz);
      r14.x = 1 + -r8.w;
      r13.w = cmp(r13.w >= 0);
      r13.w = r13.w ? 1.000000 : 0;
      r8.w = -r14.x + r8.w;
      r8.w = r13.w * r8.w + r14.x;
      r12.yzw = r12.yzw * r8.www + r9.xyz;
      r8.w = dot(r12.yzw, r7.xyz);
      r14.xyz = r8.www * r7.xyz + -r12.yzw;
      r8.w = dot(r14.xyz, r14.xyz);
      r8.w = sqrt(r8.w);
      r8.w = 0.100000001 / r8.w;
      r8.w = min(1, r8.w);
      r12.yzw = r14.xyz * r8.www + r12.yzw;
      r8.w = dot(r12.yzw, r12.yzw);
      r8.w = sqrt(r8.w);
      r12.yzw = r12.yzw / r8.www;
      r9.x = dot(r9.xyz, r11.xyz);
      r9.x = r9.w * r11.w + r9.x;
      r9.x = 0.5 * r9.x;
      r7.w = r9.x * r7.w;
      r7.w = sqrt(r7.w);
      r9.x = r7.w * 4 + 1;
      r9.x = r9.x * r9.x;
      r9.x = 1 / r9.x;
      r9.x = -0.0399999991 + r9.x;
      r9.x = 1.04166675 * r9.x;
      r7.w = cmp(r7.w >= 1);
      r7.w = r7.w ? 0 : r9.x;
      r9.xyz = r10.yzw * r7.www;
      r10.yzw = -r1.xyw * r5.xxx + r12.yzw;
      r7.w = dot(r10.yzw, r10.yzw);
      r7.w = max(0.00100000005, r7.w);
      r7.w = rsqrt(r7.w);
      r10.yzw = r10.yzw * r7.www;
      r7.w = dot(r3.xyz, r10.yzw);
      r7.w = max(0, r7.w);
      r9.w = dot(r12.yzw, r10.yzw);
      r9.w = max(0, r9.w);
      r10.y = r12.x * r0.z + r10.x;
      r10.y = r10.y * r0.w + 9.99999975e-006;
      r10.y = 1 / r10.y;
      r7.w = r7.w * r7.w;
      r7.w = r7.w * r2.w + 1;
      r7.w = max(9.99999997e-007, r7.w);
      r8.w = r8.w + r8.w;
      r8.w = 0.100000001 / r8.w;
      r8.w = r1.z * r1.z + r8.w;
      r8.w = min(1, r8.w);
      r8.w = r8.w * r8.w;
      r10.z = 3.14159274 * r7.w;
      r7.w = r10.z * r7.w;
      r7.w = r7.w * r8.w;
      r7.w = r3.w / r7.w;
      r8.w = 1 + -r12.x;
      r10.z = r8.w * r8.w;
      r10.z = r10.z * r10.z;
      r8.w = r10.z * r8.w;
      r10.z = r9.w + r9.w;
      r10.z = r10.z * r9.w;
      r10.z = r10.z * r1.z + -0.5;
      r8.w = r10.z * r8.w + 1;
      r10.z = r10.z * r4.w + 1;
      r8.w = r10.z * r8.w;
      r7.w = r10.y * r7.w;
      r7.w = 0.785398185 * r7.w;
      r7.w = r7.w * r12.x;
      r7.w = max(0, r7.w);
      r8.w = r8.w * r12.x;
      r10.yzw = r9.xyz * r8.www;
      r9.xyz = r7.www * r9.xyz;
      r7.w = 1 + -r9.w;
      r8.w = r7.w * r7.w;
      r8.w = r8.w * r8.w;
      r7.w = r8.w * r7.w;
      r11.xyz = r5.yzw * r7.www + r2.xyz;
      r9.xyz = r11.xyz * r9.xyz;
      r9.xyz = r4.xyz * r10.yzw + r9.xyz;
      r8.xyz = r9.xyz + r8.xyz;
      r6.w = (int)r6.w + 1;
    }
    r0.xyz = float3(8,8,8) * r8.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps 1dd33a5e8df76164: 1 retail keyword combination(s)
void ps_1dd33a5e8df76164_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r1.yz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xy = cmp(r3.ww == float2(0.666666687,0.333333343));
    r0.w = (int)r4.y | (int)r4.x;
    r4.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r5.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,1) + r2.xyzw;
    r5.xyz = r1.yyy * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r1.y = -r1.y * 0.959999979 + 0.959999979;
    r6.xyz = r2.xyz * r1.yyy;
    r4.w = 0.0195999984;
    r6.w = r5.x;
    r4.xyzw = r0.wwww ? r4.xyzw : r6.xyzw;
    r2.yz = r0.ww ? float2(0.0195999984,0.0195999984) : r5.yz;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r0.w = dot(r3.xyz, r3.xyz);
    r0.w = rsqrt(r0.w);
    r3.xyz = r3.xyz * r0.www;
    r5.z = 1 + -r1.x;
    r5.xy = v0.zw;
    r1.xyw = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r1.yyyy;
    r6.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r1.xxxx + r6.xyzw;
    r6.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r1.wwww + r6.xyzw;
    r6.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r6.xyzw;
    r1.xyw = r6.xyz / r6.www;
    r6.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r1.yyyy;
    r6.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r1.xxxx + r6.xyzw;
    r6.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r1.wwww + r6.xyzw;
    r6.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r6.xyzw;
    r1.xyw = -_WorldSpaceCameraPos.xyz + r6.xyz;
    r0.w = dot(r1.xyw, r1.xyw);
    r0.w = rsqrt(r0.w);
    r1.xyw = r1.xyw * r0.www;
    r0.w = cmp(0 < r3.w);
    r3.w = 0.5 * r5.w;
    r5.xyz = r4.xyz * r3.www;
    r2.x = r4.w;
    r7.xyz = r2.xyz * r2.www;
    r5.w = r7.x;
    r4.xyzw = r0.wwww ? r5.xyzw : r4.xyzw;
    r2.yz = r0.ww ? r7.yz : r2.yz;
    r0.w = dot(r3.xyz, -r1.xyw);
    r3.w = saturate(r0.w);
    r0.y = (int)r0.y + (int)r0.x;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.x = r4.w;
    r5.xyz = r2.xyz * r2.www;
    r1.z = 1 + -r1.z;
    r4.w = r1.z * r1.z;
    r5.w = cmp(r0.w < 0);
    r0.w = 9.99999975e-006 + -r0.w;
    r7.xyz = -r1.xyw * r0.www + r3.xyz;
    r7.xyz = r5.www ? r7.xyz : r3.xyz;
    r0.w = -r1.z * r1.z + 1;
    r1.z = r3.w * r0.w + r4.w;
    r5.w = r4.w * r4.w;
    r7.w = 0.318309873 * r5.w;
    r8.x = 0.5 * r4.w;
    r8.y = r4.w * -0.337748349 + 1;
    r8.z = 1 + -r3.w;
    r8.w = r8.z * r8.z;
    r8.w = r8.w * r8.w;
    r8.z = r8.w * r8.z;
    r2.xyz = -r2.xyz * r2.www + float3(1,1,1);
    r9.xyz = float3(0,0,0);
    r2.w = r0.x;
    [loop] while (true) {
      r8.w = cmp((int)r2.w >= (int)r0.y);
      [branch] if (r8.w != 0) break;
      r8.w = _BT_LinkListBuffer[r2.w].val[0/4];
      r10.x = _BT_LightBuffer[r8.w].val[0/4];
      r10.y = _BT_LightBuffer[r8.w].val[0/4+1];
      r10.z = _BT_LightBuffer[r8.w].val[0/4+2];
      r10.w = _BT_LightBuffer[r8.w].val[0/4+3];
      r9.w = _BT_LightBuffer[r8.w].val[32/4];
      r10.xyz = -r10.xyz + r6.xyz;
      r11.x = dot(r10.xyz, r10.xyz);
      r11.y = r10.w * r10.w;
      r11.z = max(0.100000001, r11.x);
      r11.y = r11.z / r11.y;
      r11.y = -r11.y * r11.y + 1;
      r11.y = max(0, r11.y);
      r11.y = r11.y * r11.y;
      r9.w = r10.w * r9.w + r11.z;
      r9.w = 1 / r9.w;
      r9.w = r9.w * r11.y;
      r10.w = cmp(r9.w != 0.000000);
      [branch] if (r10.w != 0) {
        r11.y = _BT_LightBuffer[r8.w].val[16/4];
        r11.z = _BT_LightBuffer[r8.w].val[16/4+1];
        r11.w = _BT_LightBuffer[r8.w].val[16/4+2];
        r8.w = _BT_LightBuffer[r8.w].val[60/4];
        r10.w = rsqrt(r11.x);
        r12.xyz = r10.xyz * r10.www;
        r11.xyz = r11.yzw * r9.www;
        r9.w = dot(r3.xyz, -r12.xyz);
        r9.w = max(0, r9.w);
        r8.w = cmp(r8.w >= 0);
        r10.xyz = -r10.xyz * r10.www + -r1.xyw;
        r10.w = dot(r10.xyz, r10.xyz);
        r10.w = max(0.00100000005, r10.w);
        r10.w = rsqrt(r10.w);
        r10.xyz = r10.xyz * r10.www;
        r10.w = dot(r7.xyz, r10.xyz);
        r10.x = dot(-r12.xyz, r10.xyz);
        r10.xw = max(float2(0,0), r10.xw);
        r10.y = r9.w * r0.w + r4.w;
        r10.y = r10.y * r3.w;
        r10.y = r9.w * r1.z + r10.y;
        r10.y = 9.99999975e-006 + r10.y;
        r10.y = 0.5 / r10.y;
        r10.z = r10.w * r5.w + -r10.w;
        r10.z = r10.z * r10.w + 1;
        r10.z = r10.z * r10.z + 1.00000001e-007;
        r10.z = r7.w / r10.z;
        r10.w = 1 + -r9.w;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r11.w = r10.x + r10.x;
        r11.w = r11.w * r10.x;
        r11.w = r11.w * r4.w + r8.x;
        r11.w = -1 + r11.w;
        r10.w = r11.w * r10.w + 1;
        r11.w = r11.w * r8.z + 1;
        r10.w = r11.w * r10.w;
        r10.w = r10.w * r8.y;
        r10.y = r10.y * r10.z;
        r10.y = 3.14159274 * r10.y;
        r10.y = r10.y * r9.w;
        r10.y = max(0, r10.y);
        r9.w = r10.w * r9.w;
        r12.xyz = r11.xyz * r9.www;
        r10.yzw = r10.yyy * r11.xyz;
        r9.w = 1 + -r10.x;
        r10.x = r9.w * r9.w;
        r10.x = r10.x * r10.x;
        r9.w = r10.x * r9.w;
        r11.xyz = r2.xyz * r9.www + r5.xyz;
        r10.xyz = r11.xyz * r10.yzw;
        r8.w = r8.w ? 1.000000 : 0;
        r10.xyz = r10.xyz * r8.www;
        r10.xyz = r4.xyz * r12.xyz + r10.xyz;
      } else {
        r10.xyz = float3(0,0,0);
      }
      r9.xyz = r10.xyz + r9.xyz;
      r2.w = (int)r2.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r10.xyz = r9.xyz;
    r0.y = r2.w;
    [loop] while (true) {
      r0.z = cmp((int)r0.y >= (int)r0.x);
      [branch] if (r0.z != 0) break;
      r0.z = _BT_LinkListBuffer[r0.y].val[0/4];
      r11.x = _BT_LightBuffer[r0.z].val[0/4];
      r11.y = _BT_LightBuffer[r0.z].val[0/4+1];
      r11.z = _BT_LightBuffer[r0.z].val[0/4+2];
      r11.w = _BT_LightBuffer[r0.z].val[0/4+3];
      r8.w = _BT_LightBuffer[r0.z].val[32/4];
      r12.x = _BT_LightBuffer[r0.z].val[48/4];
      r12.y = _BT_LightBuffer[r0.z].val[48/4+1];
      r9.w = (uint)r0.z << 2;
      r8.w = frac(r8.w);
      r11.xyz = -r11.xyz + r6.xyz;
      r10.w = dot(r11.xyz, r11.xyz);
      r12.z = r11.w * r11.w;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][1], _BT_LightMatrix[(uint)(r9.w) / 4u][1][1], _BT_LightMatrix[(uint)(r9.w) / 4u][2][1], _BT_LightMatrix[(uint)(r9.w) / 4u][3][1]) * r6.yyyy;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][0], _BT_LightMatrix[(uint)(r9.w) / 4u][1][0], _BT_LightMatrix[(uint)(r9.w) / 4u][2][0], _BT_LightMatrix[(uint)(r9.w) / 4u][3][0]) * r6.xxxx + r13.xyzw;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][2], _BT_LightMatrix[(uint)(r9.w) / 4u][1][2], _BT_LightMatrix[(uint)(r9.w) / 4u][2][2], _BT_LightMatrix[(uint)(r9.w) / 4u][3][2]) * r6.zzzz + r13.xyzw;
      r13.xyzw = float4(_BT_LightMatrix[(uint)(r9.w) / 4u][0][3], _BT_LightMatrix[(uint)(r9.w) / 4u][1][3], _BT_LightMatrix[(uint)(r9.w) / 4u][2][3], _BT_LightMatrix[(uint)(r9.w) / 4u][3][3]) * r6.wwww + r13.xyzw;
      r9.w = max(0.100000001, r10.w);
      r12.z = r9.w / r12.z;
      r12.z = -r12.z * r12.z + 1;
      r12.z = max(0, r12.z);
      r12.z = r12.z * r12.z;
      r8.w = r11.w * r8.w + r9.w;
      r8.w = 1 / r8.w;
      r8.w = r8.w * r12.z;
      r13.xyz = r13.xyz / r13.www;
      r9.w = cmp(0 >= r13.z);
      r12.zw = cmp(float2(1,1) < r13.xy);
      r9.w = (int)r9.w | (int)r12.z;
      r13.zw = cmp(r13.xy < float2(-1,-1));
      r9.w = (int)r9.w | (int)r13.z;
      r9.w = (int)r12.w | (int)r9.w;
      r9.w = (int)r13.w | (int)r9.w;
      r11.w = r12.x / r12.y;
      r11.w = min(0.99000001, r11.w);
      r12.x = dot(r13.xy, r13.xy);
      r12.x = sqrt(r12.x);
      r12.x = min(1, r12.x);
      r11.w = -1 + r11.w;
      r12.x = -1 + r12.x;
      r11.w = 1 / r11.w;
      r11.w = r12.x * r11.w;
      r11.w = min(1, r11.w);
      r12.x = r11.w * -2 + 3;
      r11.w = r11.w * r11.w;
      r11.w = r12.x * r11.w;
      r12.x = cmp(r11.w != 0.000000);
      r11.w = r12.x ? r11.w : 0;
      r9.w = r9.w ? 0 : r11.w;
      r8.w = r9.w * r8.w;
      r9.w = cmp(r8.w != 0.000000);
      [branch] if (r9.w != 0) {
        r12.x = _BT_LightBuffer[r0.z].val[16/4];
        r12.y = _BT_LightBuffer[r0.z].val[16/4+1];
        r12.z = _BT_LightBuffer[r0.z].val[16/4+2];
        r0.z = _BT_LightBuffer[r0.z].val[60/4];
        r9.w = rsqrt(r10.w);
        r13.xyz = r11.xyz * r9.www;
        r12.xyz = r12.xyz * r8.www;
        r8.w = dot(r3.xyz, -r13.xyz);
        r8.w = max(0, r8.w);
        r0.z = cmp(r0.z >= 0);
        r11.xyz = -r11.xyz * r9.www + -r1.xyw;
        r9.w = dot(r11.xyz, r11.xyz);
        r9.w = max(0.00100000005, r9.w);
        r9.w = rsqrt(r9.w);
        r11.xyz = r11.xyz * r9.www;
        r9.w = dot(r7.xyz, r11.xyz);
        r9.w = max(0, r9.w);
        r10.w = dot(-r13.xyz, r11.xyz);
        r10.w = max(0, r10.w);
        r11.x = r8.w * r0.w + r4.w;
        r11.x = r11.x * r3.w;
        r11.x = r8.w * r1.z + r11.x;
        r11.x = 9.99999975e-006 + r11.x;
        r11.x = 0.5 / r11.x;
        r11.y = r9.w * r5.w + -r9.w;
        r9.w = r11.y * r9.w + 1;
        r9.w = r9.w * r9.w + 1.00000001e-007;
        r9.w = r7.w / r9.w;
        r11.y = 1 + -r8.w;
        r11.z = r11.y * r11.y;
        r11.z = r11.z * r11.z;
        r11.y = r11.z * r11.y;
        r11.z = r10.w + r10.w;
        r11.z = r11.z * r10.w;
        r11.z = r11.z * r4.w + r8.x;
        r11.z = -1 + r11.z;
        r11.y = r11.z * r11.y + 1;
        r11.z = r11.z * r8.z + 1;
        r11.y = r11.y * r11.z;
        r11.y = r11.y * r8.y;
        r9.w = r11.x * r9.w;
        r9.w = 3.14159274 * r9.w;
        r9.w = r9.w * r8.w;
        r9.w = max(0, r9.w);
        r8.w = r11.y * r8.w;
        r11.xyz = r12.xyz * r8.www;
        r12.xyz = r9.www * r12.xyz;
        r8.w = 1 + -r10.w;
        r9.w = r8.w * r8.w;
        r9.w = r9.w * r9.w;
        r8.w = r9.w * r8.w;
        r13.xyz = r2.xyz * r8.www + r5.xyz;
        r12.xyz = r13.xyz * r12.xyz;
        r0.z = r0.z ? 1.000000 : 0;
        r12.xyz = r12.xyz * r0.zzz;
        r11.xyz = r4.xyz * r11.xyz + r12.xyz;
      } else {
        r11.xyz = float3(0,0,0);
      }
      r10.xyz = r11.xyz + r10.xyz;
      r0.y = (int)r0.y + 1;
    }
    r0.xyz = float3(8,8,8) * r10.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps f3614ade12199000: 1 retail keyword combination(s)
void ps_f3614ade12199000_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28,r29,r30;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyzw = _BT_ListEntries.Load(r0.xywz).xyzw;
  r1.y = cmp((int)r0.x >= 0);
  [branch] if (r1.y != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r3.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xyzw;
    r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r1.yz = cmp(r4.ww == float2(0.666666687,0.333333343));
    r1.w = (int)r1.z | (int)r1.y;
    r5.xy = r3.xy * float2(2,2) + float2(-1,-1);
    r6.xyz = float3(1,1,1) + -abs(r5.xyx);
    r7.z = r6.x + -abs(r5.y);
    r3.y = cmp(r7.z >= 0);
    r5.zw = cmp(r5.xy >= float2(0,0));
    r5.zw = r5.zw ? float2(1,1) : float2(-1,-1);
    r5.zw = r6.yz * r5.zw;
    r7.xy = r3.yy ? r5.xy : r5.zw;
    r3.y = dot(r7.xyz, r7.xyz);
    r3.y = rsqrt(r3.y);
    r5.xyz = r7.xyz * r3.yyy;
    r6.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,1) + r2.xyzw;
    r7.xyz = r3.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r3.x = -r3.x * 0.959999979 + 0.959999979;
    r8.xyz = r3.xxx * r2.xyz;
    r6.w = 0.0195999984;
    r8.w = r7.x;
    r6.xyzw = r1.wwww ? r6.xyzw : r8.xyzw;
    r2.xyz = r1.www ? r5.xyz : 0;
    r5.yz = r1.ww ? float2(0.0195999984,0.0195999984) : r7.yz;
    r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r1.w = dot(r4.xyz, r4.xyz);
    r1.w = rsqrt(r1.w);
    r4.xyz = r4.xyz * r1.www;
    r7.z = 1 + -r1.x;
    r7.xy = v0.zw;
    r7.xyz = r7.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r8.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r7.yyyy;
    r8.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r7.xxxx + r8.xyzw;
    r8.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r7.zzzz + r8.xyzw;
    r8.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r8.xyzw;
    r7.xyz = r8.xyz / r8.www;
    r8.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r7.yyyy;
    r8.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r7.xxxx + r8.xyzw;
    r8.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r7.zzzz + r8.xyzw;
    r8.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r8.xyzw;
    r7.xyz = -_WorldSpaceCameraPos.xyz + r8.xyz;
    r1.x = dot(r7.xyz, r7.xyz);
    r1.x = rsqrt(r1.x);
    r9.xyz = r7.xyz * r1.xxx;
    r1.w = cmp(0 < r4.w);
    r3.x = 0.5 * r7.w;
    r10.xyz = r6.xyz * r3.xxx;
    r5.x = r6.w;
    r11.xyz = r5.xyz * r2.www;
    r10.w = r11.x;
    r6.xyzw = r1.wwww ? r10.xyzw : r6.xyzw;
    r5.yz = r1.ww ? r11.yz : r5.yz;
    r1.w = dot(r4.xyz, -r9.xyz);
    r3.x = max(0, r1.w);
    r3.y = min(1, r3.x);
    r0.y = (int)r0.y + (int)r0.x;
    r4.w = r2.w * r2.w;
    r4.w = r4.w * r4.w;
    r4.w = r4.w * r4.w;
    r5.x = r6.w;
    r10.xyz = r5.xyz * r4.www;
    r5.w = 1 + -r3.z;
    r6.w = r5.w * r5.w;
    r7.w = cmp(r1.w < 0);
    r9.w = 9.99999975e-006 + -r1.w;
    r11.xyz = -r9.xyz * r9.www + r4.xyz;
    r11.xyz = r7.www ? r11.xyz : r4.xyz;
    r7.w = -r5.w * r5.w + 1;
    r9.w = r3.y * r7.w + r6.w;
    r10.w = r6.w * r6.w;
    r11.w = 0.318309873 * r10.w;
    r12.xyz = -r5.xyz * r4.www + float3(1,1,1);
    r4.w = dot(r2.xyz, -r9.xyz);
    r12.w = cmp(r4.w < 0);
    r13.x = 9.99999975e-006 + -r4.w;
    r13.xyz = -r9.xyz * r13.xxx + r2.xyz;
    r13.xyz = r12.www ? r13.xyz : r2.xyz;
    r12.w = r3.w * 10 + 5;
    r13.w = -r4.w * r4.w + 1;
    r13.w = sqrt(r13.w);
    r14.xy = float2(0.0349065885,-0.052359879) * r12.ww;
    sincos(r14.x, r14.x, r15.x);
    sincos(r14.y, r16.x, r17.x);
    r12.w = 0.5 * r6.w;
    r14.y = r6.w * -0.337748349 + 1;
    r14.z = 1 + -r3.y;
    r14.w = r14.z * r14.z;
    r14.w = r14.w * r14.w;
    r14.z = r14.w * r14.z;
    r2.w = r2.w * 0.75 + 0.25;
    r18.yw = r3.ww;
    r15.yzw = float3(0,0,0);
    r3.w = r0.x;
    [loop] while (true) {
      r14.w = cmp((int)r3.w >= (int)r0.y);
      [branch] if (r14.w != 0) break;
      r14.w = _BT_LinkListBuffer[r3.w].val[0/4];
      r19.x = _BT_LightBuffer[r14.w].val[0/4];
      r19.y = _BT_LightBuffer[r14.w].val[0/4+1];
      r19.z = _BT_LightBuffer[r14.w].val[0/4+2];
      r19.w = _BT_LightBuffer[r14.w].val[0/4+3];
      r16.y = _BT_LightBuffer[r14.w].val[32/4];
      r17.yzw = -r19.xyz + r8.xyz;
      r16.z = dot(r17.yzw, r17.yzw);
      r16.w = r19.w * r19.w;
      r19.x = max(0.100000001, r16.z);
      r16.w = r19.x / r16.w;
      r16.w = -r16.w * r16.w + 1;
      r16.w = max(0, r16.w);
      r16.w = r16.w * r16.w;
      r16.y = r19.w * r16.y + r19.x;
      r16.y = 1 / r16.y;
      r16.y = r16.y * r16.w;
      r16.w = cmp(r16.y != 0.000000);
      [branch] if (r16.w != 0) {
        r19.x = _BT_LightBuffer[r14.w].val[16/4];
        r19.y = _BT_LightBuffer[r14.w].val[16/4+1];
        r19.z = _BT_LightBuffer[r14.w].val[16/4+2];
        r14.w = _BT_LightBuffer[r14.w].val[60/4];
        r16.z = rsqrt(r16.z);
        r20.xyz = r17.yzw * r16.zzz;
        r19.xyz = r19.xyz * r16.yyy;
        r16.y = dot(r4.xyz, -r20.xyz);
        r16.y = max(0, r16.y);
        [branch] if (r1.y != 0) {
          r16.w = cmp(r14.w >= 0);
          r21.xyz = -r17.yzw * r16.zzz + -r9.xyz;
          r19.w = dot(r21.xyz, r21.xyz);
          r19.w = max(0.00100000005, r19.w);
          r19.w = rsqrt(r19.w);
          r21.xyz = r21.xyz * r19.www;
          r19.w = dot(r11.xyz, r21.xyz);
          r19.w = max(0, r19.w);
          r20.w = dot(-r20.xyz, r21.xyz);
          r20.w = max(0, r20.w);
          r21.x = r16.y * r7.w + r6.w;
          r21.x = r21.x * r3.y;
          r21.x = r16.y * r9.w + r21.x;
          r21.x = 9.99999975e-006 + r21.x;
          r21.x = 0.5 / r21.x;
          r21.y = r19.w * r10.w + -r19.w;
          r19.w = r21.y * r19.w + 1;
          r19.w = r19.w * r19.w + 1.00000001e-007;
          r19.w = r11.w / r19.w;
          r19.w = r21.x * r19.w;
          r19.w = r19.w * r16.y;
          r19.w = 3.14159274 * r19.w;
          r19.w = max(0, r19.w);
          r21.xyz = r19.www * r19.xyz;
          r19.w = 1 + -r20.w;
          r20.w = r19.w * r19.w;
          r20.w = r20.w * r20.w;
          r19.w = r20.w * r19.w;
          r22.xyz = r12.xyz * r19.www + r10.xyz;
          r21.xyz = r22.xyz * r21.xyz;
          r16.w = r16.w ? 1.000000 : 0;
          r19.w = dot(r13.xyz, -r20.xyz);
          r18.x = r19.w * 0.5 + 0.5;
          r22.xyz = _BT_PreIntegratedSSS.SampleLevel(sampler_BT_PreIntegratedSSS, r18.xy, 0).xyz;
          r22.xyz = r22.xyz * r19.xyz;
          r22.xyz = r22.xyz * r6.xyz;
          r21.xyz = r21.xyz * r16.www + r22.xyz;
        } else {
          [branch] if (r1.z != 0) {
            r16.w = dot(r2.xyz, -r20.xyz);
            r18.x = -r16.w * r16.w + 1;
            r18.x = sqrt(r18.x);
            r19.w = r18.x * r14.x;
            r19.w = -r16.w * r15.x + -r19.w;
            r20.w = -r19.w * r19.w + 1;
            r20.w = sqrt(r20.w);
            r20.w = r20.w * r13.w;
            r19.w = r19.w * r4.w + r20.w;
            r19.w = max(0, r19.w);
            r20.w = r18.x * r16.x;
            r16.w = -r16.w * r17.x + -r20.w;
            r20.w = -r16.w * r16.w + 1;
            r20.w = sqrt(r20.w);
            r20.w = r20.w * r13.w;
            r16.w = r16.w * r4.w + r20.w;
            r16.w = max(0, r16.w);
            r18.x = 0.00999999978 * r18.x;
            r19.w = log2(r19.w);
            r19.w = 30.3999996 * r19.w;
            r19.w = exp2(r19.w);
            r19.w = 0.0500000007 * r19.w;
            r16.w = log2(r16.w);
            r16.w = 15.8000002 * r16.w;
            r16.w = exp2(r16.w);
            r16.w = 0.100000001 * r16.w;
            r22.xyz = r18.xxx * r19.xyz;
            r23.xyz = r19.www * r19.xyz;
            r23.xyz = r23.xyz * r3.zzz;
            r23.xyz = float3(1.5,1.5,1.5) * r23.xyz;
            r22.xyz = r22.xyz * r6.xyz + r23.xyz;
            r23.xyz = r16.www * r19.xyz;
            r23.xyz = r23.xyz * r6.xyz;
            r23.xyz = r23.xyz * r3.zzz;
            r22.xyz = r23.xyz * float3(1.5,1.5,1.5) + r22.xyz;
            r23.xyz = -r17.yzw * r16.zzz + -r9.xyz;
            r16.w = dot(r23.xyz, r23.xyz);
            r16.w = max(0.00100000005, r16.w);
            r16.w = rsqrt(r16.w);
            r23.xyz = r23.xyz * r16.www;
            r16.w = dot(-r20.xyz, r23.xyz);
            r16.w = max(0, r16.w);
            r18.x = 1 + -r16.y;
            r19.w = r18.x * r18.x;
            r19.w = r19.w * r19.w;
            r18.x = r19.w * r18.x;
            r19.w = r16.w + r16.w;
            r16.w = r19.w * r16.w;
            r16.w = r16.w * r6.w + r12.w;
            r16.w = -1 + r16.w;
            r18.x = r16.w * r18.x + 1;
            r16.w = r16.w * r14.z + 1;
            r16.w = r18.x * r16.w;
            r16.w = r16.w * r14.y;
            r16.w = r16.w * r16.y;
            r23.xyz = r19.xyz * r16.www;
            r23.xyz = r23.xyz * r6.xyz;
            r22.xyz = r23.xyz * float3(0.25,0.25,0.25) + r22.xyz;
            r21.xyz = r22.xyz * r2.www;
          } else {
            r14.w = cmp(r14.w >= 0);
            r17.yzw = -r17.yzw * r16.zzz + -r9.xyz;
            r16.z = dot(r17.yzw, r17.yzw);
            r16.z = max(0.00100000005, r16.z);
            r16.z = rsqrt(r16.z);
            r17.yzw = r17.yzw * r16.zzz;
            r16.z = dot(r11.xyz, r17.yzw);
            r16.w = dot(-r20.xyz, r17.yzw);
            r16.zw = max(float2(0,0), r16.zw);
            r17.y = r16.y * r7.w + r6.w;
            r17.y = r17.y * r3.y;
            r17.y = r16.y * r9.w + r17.y;
            r17.y = 9.99999975e-006 + r17.y;
            r17.y = 0.5 / r17.y;
            r17.z = r16.z * r10.w + -r16.z;
            r16.z = r17.z * r16.z + 1;
            r16.z = r16.z * r16.z + 1.00000001e-007;
            r16.z = r11.w / r16.z;
            r17.z = 1 + -r16.y;
            r17.w = r17.z * r17.z;
            r17.w = r17.w * r17.w;
            r17.z = r17.w * r17.z;
            r17.w = r16.w + r16.w;
            r17.w = r17.w * r16.w;
            r17.w = r17.w * r6.w + r12.w;
            r17.w = -1 + r17.w;
            r17.z = r17.w * r17.z + 1;
            r17.w = r17.w * r14.z + 1;
            r17.z = r17.z * r17.w;
            r17.z = r17.z * r14.y;
            r16.z = r17.y * r16.z;
            r16.z = r16.z * r16.y;
            r16.z = 3.14159274 * r16.z;
            r16.z = max(0, r16.z);
            r16.y = r17.z * r16.y;
            r17.yzw = r19.xyz * r16.yyy;
            r19.xyz = r16.zzz * r19.xyz;
            r16.y = 1 + -r16.w;
            r16.z = r16.y * r16.y;
            r16.z = r16.z * r16.z;
            r16.y = r16.z * r16.y;
            r16.yzw = r12.xyz * r16.yyy + r10.xyz;
            r16.yzw = r19.xyz * r16.yzw;
            r14.w = r14.w ? 1.000000 : 0;
            r16.yzw = r16.yzw * r14.www;
            r21.xyz = r6.xyz * r17.yzw + r16.yzw;
          }
        }
      } else {
        r21.xyz = float3(0,0,0);
      }
      r15.yzw = r21.xyz + r15.yzw;
      r3.w = (int)r3.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r0.y = sqrt(_BT_ShadowMapParams.z);
    r0.z = _BT_MaxShadowDist * _BT_MaxShadowDist;
    r14.w = 0.5 * r0.z;
    r14.w = 1 / r14.w;
    r16.y = _ShadowDummyTex.SampleLevel(sampler_ShadowDummyTex, float2(0,0), 0).x;
    r19.xz = _BT_ShadowMap_TexelSize.xx;
    r19.y = 0.142857149;
    r20.xz = _BT_ShadowMap_TexelSize.yy;
    r20.y = 0.142857149;
    r21.y = 7;
    r18.y = 0.5;
    r17.yzw = r15.yzw;
    r16.z = r3.w;
    [loop] while (true) {
      r16.w = cmp((int)r16.z >= (int)r0.x);
      [branch] if (r16.w != 0) break;
      r16.w = _BT_LinkListBuffer[r16.z].val[0/4];
      r22.x = _BT_LightBuffer[r16.w].val[0/4];
      r22.y = _BT_LightBuffer[r16.w].val[0/4+1];
      r22.z = _BT_LightBuffer[r16.w].val[0/4+2];
      r22.w = _BT_LightBuffer[r16.w].val[0/4+3];
      r19.w = _BT_LightBuffer[r16.w].val[32/4];
      r23.x = _BT_LightBuffer[r16.w].val[48/4];
      r23.y = _BT_LightBuffer[r16.w].val[48/4+1];
      r23.z = _BT_LightBuffer[r16.w].val[48/4+2];
      r23.w = _BT_LightBuffer[r16.w].val[48/4+3];
      r20.w = (uint)r16.w << 2;
      r19.w = frac(r19.w);
      r24.xyz = -r22.xyz + r8.xyz;
      r21.w = dot(r24.xyz, r24.xyz);
      r24.w = r22.w * r22.w;
      r25.xyzw = float4(_BT_LightMatrix[(uint)(r20.w) / 4u][0][1], _BT_LightMatrix[(uint)(r20.w) / 4u][1][1], _BT_LightMatrix[(uint)(r20.w) / 4u][2][1], _BT_LightMatrix[(uint)(r20.w) / 4u][3][1]) * r8.yyyy;
      r25.xyzw = float4(_BT_LightMatrix[(uint)(r20.w) / 4u][0][0], _BT_LightMatrix[(uint)(r20.w) / 4u][1][0], _BT_LightMatrix[(uint)(r20.w) / 4u][2][0], _BT_LightMatrix[(uint)(r20.w) / 4u][3][0]) * r8.xxxx + r25.xyzw;
      r25.xyzw = float4(_BT_LightMatrix[(uint)(r20.w) / 4u][0][2], _BT_LightMatrix[(uint)(r20.w) / 4u][1][2], _BT_LightMatrix[(uint)(r20.w) / 4u][2][2], _BT_LightMatrix[(uint)(r20.w) / 4u][3][2]) * r8.zzzz + r25.xyzw;
      r25.xyzw = float4(_BT_LightMatrix[(uint)(r20.w) / 4u][0][3], _BT_LightMatrix[(uint)(r20.w) / 4u][1][3], _BT_LightMatrix[(uint)(r20.w) / 4u][2][3], _BT_LightMatrix[(uint)(r20.w) / 4u][3][3]) * r8.wwww + r25.xyzw;
      r20.w = max(0.100000001, r21.w);
      r24.w = r20.w / r24.w;
      r24.w = -r24.w * r24.w + 1;
      r24.w = max(0, r24.w);
      r24.w = r24.w * r24.w;
      r19.w = r22.w * r19.w + r20.w;
      r19.w = 1 / r19.w;
      r19.w = r19.w * r24.w;
      r25.xyz = r25.xyz / r25.www;
      r20.w = cmp(0 >= r25.z);
      r26.xy = cmp(float2(1,1) < r25.xy);
      r20.w = (int)r20.w | (int)r26.x;
      r26.xz = cmp(r25.xy < float2(-1,-1));
      r20.w = (int)r20.w | (int)r26.x;
      r20.w = (int)r26.y | (int)r20.w;
      r20.w = (int)r26.z | (int)r20.w;
      [branch] if (r20.w == 0) {
        r24.w = r23.x / r23.y;
        r24.w = min(0.99000001, r24.w);
        r25.w = dot(r25.xy, r25.xy);
        r25.w = sqrt(r25.w);
        r25.w = min(1, r25.w);
        r24.w = -1 + r24.w;
        r25.w = -1 + r25.w;
        r24.w = 1 / r24.w;
        r24.w = r25.w * r24.w;
        r24.w = min(1, r24.w);
        r25.w = r24.w * -2 + 3;
        r24.w = r24.w * r24.w;
        r24.w = r25.w * r24.w;
        r25.w = cmp(r24.w != 0.000000);
        [branch] if (r25.w != 0) {
          r25.w = cmp(-1 < r23.z);
          [branch] if (r25.w != 0) {
            r26.xy = r25.xy * float2(0.5,0.5) + float2(0.5,0.5);
            r22.xyz = _WorldSpaceCameraPos.xyz + -r22.xyz;
            r22.x = dot(r22.xyz, r22.xyz);
            r22.y = r23.z / r0.y;
            r22.z = cmp(r22.y >= -r22.y);
            r25.w = frac(abs(r22.y));
            r22.z = r22.z ? r25.w : -r25.w;
            r22.z = r22.z * r0.y;
            r22.y = floor(r22.y);
            r27.xy = r22.zy / r0.yy;
            r22.yz = r26.xy / r0.yy;
            r22.yz = r22.yz + r27.xy;
            r25.w = r25.z + abs(r23.w);
            r22.yz = r22.yz * _BT_ShadowMap_TexelSize.zw + float2(0.5,0.5);
            r26.xy = floor(r22.yz);
            r26.xy = float2(-0.5,-0.5) + r26.xy;
            r22.yz = frac(r22.yz);
            r26.z = 3 * r22.y;
            r27.xy = -r22.yz * float2(3,3) + float2(4,4);
            r27.zw = r22.yz * float2(3,3) + float2(1,1);
            r28.xy = -r22.yz * float2(2,2) + float2(3,3);
            r28.xy = r28.xy / r27.xy;
            r28.xy = float2(-2,-2) + r28.xy;
            r29.xy = float2(3,3) + r22.yz;
            r29.xy = _BT_ShadowMap_TexelSize.xy * r29.xy;
            r22.yz = r22.yz / r27.zw;
            r22.yz = float2(2,2) + r22.yz;
            r28.z = r29.x;
            r28.w = r22.y;
            r30.xyz = r28.xzw * r19.xyz;
            r29.z = r28.y;
            r29.w = r22.z;
            r28.xyw = r29.zyw * r20.xyz;
            r21.xz = r26.zz * float2(-1,1) + float2(4,1);
            r27.xyz = r27.yyy * r21.xyz;
            r30.w = r28.x;
            r29.xyzw = r26.xyxy * _BT_ShadowMap_TexelSize.xyxy + r30.xwyw;
            r22.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r29.xy, r25.w).x;
            r22.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r29.zw, r25.w).x;
            r22.z = r27.y * r22.z;
            r22.y = r27.x * r22.y + r22.z;
            r26.zw = r26.xy * _BT_ShadowMap_TexelSize.xy + r30.zw;
            r22.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r26.zw, r25.w).x;
            r22.y = r27.z * r22.z + r22.y;
            r26.zw = float2(7,7) * r21.xz;
            r28.z = r30.x;
            r29.xyzw = r26.xyxy * _BT_ShadowMap_TexelSize.xyxy + r28.zyzw;
            r22.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r29.xy, r25.w).x;
            r22.y = r26.z * r22.z + r22.y;
            r28.xz = r30.yz;
            r30.xyzw = r26.xyxy * _BT_ShadowMap_TexelSize.xyxy + r28.xyzy;
            r22.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r30.xy, r25.w).x;
            r22.y = r22.z * 49 + r22.y;
            r22.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r30.zw, r25.w).x;
            r22.y = r26.w * r22.z + r22.y;
            r27.xyz = r27.www * r21.xyz;
            r21.x = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r29.zw, r25.w).x;
            r21.x = r27.x * r21.x + r22.y;
            r26.xyzw = r26.xyxy * _BT_ShadowMap_TexelSize.xyxy + r28.xwzw;
            r21.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r26.xy, r25.w).x;
            r21.x = r27.y * r21.z + r21.x;
            r21.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r26.zw, r25.w).x;
            r21.x = r27.z * r21.z + r21.x;
            r21.z = 0.0069444445 * r21.x;
            r22.x = -r0.z * 0.5 + r22.x;
            r22.x = saturate(r22.x * r14.w);
            r22.y = r22.x * -2 + 3;
            r22.x = r22.x * r22.x;
            r22.x = r22.y * r22.x;
            r21.x = -r21.x * 0.0069444445 + 1;
            r21.x = r22.x * r21.x + r21.z;
            r24.w = r24.w * r21.x;
          }
        } else {
          r24.w = 0;
        }
      } else {
        r24.w = 0;
      }
      r21.x = r24.w * r19.w;
      r21.z = cmp(r21.x != 0.000000);
      [branch] if (r21.z != 0) {
        r22.x = _BT_LightBuffer[r16.w].val[16/4];
        r22.y = _BT_LightBuffer[r16.w].val[16/4+1];
        r22.z = _BT_LightBuffer[r16.w].val[16/4+2];
        r16.w = rsqrt(r21.w);
        r26.xyz = r24.xyz * r16.www;
        r21.xzw = r22.xyz * r21.xxx;
        r24.w = dot(r4.xyz, -r26.xyz);
        r24.w = max(0, r24.w);
        [branch] if (r1.y != 0) {
          r25.w = cmp(r23.w >= 0);
          r27.xyz = -r24.xyz * r16.www + -r9.xyz;
          r26.w = dot(r27.xyz, r27.xyz);
          r26.w = max(0.00100000005, r26.w);
          r26.w = rsqrt(r26.w);
          r27.xyz = r27.xyz * r26.www;
          r26.w = dot(r11.xyz, r27.xyz);
          r26.w = max(0, r26.w);
          r27.x = dot(-r26.xyz, r27.xyz);
          r27.x = max(0, r27.x);
          r27.y = r24.w * r7.w + r6.w;
          r27.y = r27.y * r3.y;
          r27.y = r24.w * r9.w + r27.y;
          r27.y = 9.99999975e-006 + r27.y;
          r27.y = 0.5 / r27.y;
          r27.z = r26.w * r10.w + -r26.w;
          r26.w = r27.z * r26.w + 1;
          r26.w = r26.w * r26.w + 1.00000001e-007;
          r26.w = r11.w / r26.w;
          r26.w = r27.y * r26.w;
          r26.w = r26.w * r24.w;
          r26.w = 3.14159274 * r26.w;
          r26.w = max(0, r26.w);
          r27.yzw = r26.www * r21.xzw;
          r26.w = 1 + -r27.x;
          r27.x = r26.w * r26.w;
          r27.x = r27.x * r27.x;
          r26.w = r27.x * r26.w;
          r28.xyz = r12.xyz * r26.www + r10.xyz;
          r27.xyz = r28.xyz * r27.yzw;
          r25.w = r25.w ? 1.000000 : 0;
          r26.w = dot(r13.xyz, -r26.xyz);
          r18.z = r26.w * 0.5 + 0.5;
          r28.xyz = _BT_PreIntegratedSSS.SampleLevel(sampler_BT_PreIntegratedSSS, r18.zw, 0).xyz;
          r28.xyz = r28.xyz * r21.xzw;
          r28.xyz = r28.xyz * r6.xyz;
          r27.xyz = r27.xyz * r25.www + r28.xyz;
          [branch] if (r20.w == 0) {
            r18.z = r23.x / r23.y;
            r18.z = min(0.99000001, r18.z);
            r20.w = dot(r25.xy, r25.xy);
            r20.w = sqrt(r20.w);
            r20.w = min(1, r20.w);
            r18.z = -1 + r18.z;
            r20.w = -1 + r20.w;
            r18.z = 1 / r18.z;
            r18.z = r20.w * r18.z;
            r18.z = min(1, r18.z);
            r20.w = r18.z * -2 + 3;
            r18.z = r18.z * r18.z;
            r18.z = r20.w * r18.z;
            r20.w = cmp(-1 < r23.z);
            [branch] if (r20.w != 0) {
              r23.xy = r25.xy * float2(0.5,0.5) + float2(0.5,0.5);
              r20.w = r23.z / r0.y;
              r23.z = cmp(r20.w >= -r20.w);
              r25.x = frac(abs(r20.w));
              r23.z = r23.z ? r25.x : -r25.x;
              r23.z = r23.z * r0.y;
              r25.x = r23.z / r0.y;
              r20.w = floor(r20.w);
              r25.y = r20.w / r0.y;
              r23.xy = r23.xy / r0.yy;
              r23.xy = r23.xy + r25.xy;
              r20.w = 1 + -r25.z;
              r23.z = 0.5 * r22.w;
              r25.x = -0.5 + r22.w;
              r20.w = -r20.w * r25.x + r22.w;
              r20.w = r23.z / r20.w;
              r28.xyzw = _BT_ShadowMap.Gather(sampler_ShadowDummyTex, r23.xy, int2(-1, -1)).xyzw;
              r28.xyzw = float4(1,1,1,1) + -r28.xyzw;
              r28.xyzw = -r28.xyzw * r25.xxxx + r22.wwww;
              r28.xyzw = r23.zzzz / r28.xyzw;
              r28.xyzw = -r28.xyzw + r20.wwww;
              r28.xyzw = float4(40,40,40,40) * abs(r28.xyzw);
              r28.xyzw = min(float4(1,1,1,1), r28.xyzw);
              r25.y = dot(r28.xyzw, float4(1,1,1,1));
              r25.y = r25.y + r16.y;
              r28.xyzw = _BT_ShadowMap.Gather(sampler_ShadowDummyTex, r23.xy, int2(1, -1)).xyzw;
              r28.xyzw = float4(1,1,1,1) + -r28.xyzw;
              r28.xyzw = -r28.xyzw * r25.xxxx + r22.wwww;
              r28.xyzw = r23.zzzz / r28.xyzw;
              r28.xyzw = -r28.xyzw + r20.wwww;
              r28.xyzw = float4(40,40,40,40) * abs(r28.xyzw);
              r28.xyzw = min(float4(1,1,1,1), r28.xyzw);
              r25.z = dot(r28.xyzw, float4(1,1,1,1));
              r25.y = r25.y + r25.z;
              r28.xyzw = _BT_ShadowMap.Gather(sampler_ShadowDummyTex, r23.xy, int2(-1, 1)).xyzw;
              r28.xyzw = float4(1,1,1,1) + -r28.xyzw;
              r28.xyzw = -r28.xyzw * r25.xxxx + r22.wwww;
              r28.xyzw = r23.zzzz / r28.xyzw;
              r28.xyzw = -r28.xyzw + r20.wwww;
              r28.xyzw = float4(40,40,40,40) * abs(r28.xyzw);
              r28.xyzw = min(float4(1,1,1,1), r28.xyzw);
              r25.z = dot(r28.xyzw, float4(1,1,1,1));
              r25.y = r25.y + r25.z;
              r28.xyzw = _BT_ShadowMap.Gather(sampler_ShadowDummyTex, r23.xy, int2(1, 1)).xyzw;
              r28.xyzw = float4(1,1,1,1) + -r28.xyzw;
              r28.xyzw = -r28.xyzw * r25.xxxx + r22.wwww;
              r28.xyzw = r23.zzzz / r28.xyzw;
              r28.xyzw = -r28.xyzw + r20.wwww;
              r28.xyzw = float4(40,40,40,40) * abs(r28.xyzw);
              r28.xyzw = min(float4(1,1,1,1), r28.xyzw);
              r20.w = dot(r28.xyzw, float4(1,1,1,1));
              r20.w = r25.y + r20.w;
              r18.x = saturate(0.0625 * r20.w);
              r23.xyz = _BT_SkinTransmission.SampleLevel(sampler_BT_SkinTransmission, r18.xy, 0).xyz;
            } else {
              r23.xyz = float3(0,0,0);
            }
            r23.xyz = r23.xyz * r18.zzz;
          } else {
            r23.xyz = float3(0,0,0);
          }
          r18.x = dot(-r2.xyz, -r26.xyz);
          r18.x = 0.300000012 + r18.x;
          r18.x = max(0, r18.x);
          r23.xyz = r23.xyz * r19.www;
          r22.xyz = r23.xyz * r22.xyz;
          r22.xyz = r22.xyz * r18.xxx;
          r22.xyz = r22.xyz * r6.xyz;
          r22.xyz = r22.xyz * r18.www + r27.xyz;
        } else {
          [branch] if (r1.z != 0) {
            r18.x = dot(r2.xyz, -r26.xyz);
            r18.z = -r18.x * r18.x + 1;
            r18.z = sqrt(r18.z);
            r19.w = r18.z * r14.x;
            r19.w = -r18.x * r15.x + -r19.w;
            r20.w = -r19.w * r19.w + 1;
            r20.w = sqrt(r20.w);
            r20.w = r20.w * r13.w;
            r19.w = r19.w * r4.w + r20.w;
            r19.w = max(0, r19.w);
            r20.w = r18.z * r16.x;
            r18.x = -r18.x * r17.x + -r20.w;
            r20.w = -r18.x * r18.x + 1;
            r20.w = sqrt(r20.w);
            r20.w = r20.w * r13.w;
            r18.x = r18.x * r4.w + r20.w;
            r18.x = max(0, r18.x);
            r19.w = log2(r19.w);
            r19.w = 30.3999996 * r19.w;
            r19.w = exp2(r19.w);
            r19.w = 0.0500000007 * r19.w;
            r18.x = log2(r18.x);
            r18.xz = float2(15.8000002,0.00999999978) * r18.xz;
            r18.x = exp2(r18.x);
            r18.x = 0.100000001 * r18.x;
            r23.xyz = r18.zzz * r21.xzw;
            r25.xyz = r19.www * r21.xzw;
            r25.xyz = r25.xyz * r3.zzz;
            r25.xyz = float3(1.5,1.5,1.5) * r25.xyz;
            r23.xyz = r23.xyz * r6.xyz + r25.xyz;
            r25.xyz = r18.xxx * r21.xzw;
            r25.xyz = r25.xyz * r6.xyz;
            r25.xyz = r25.xyz * r3.zzz;
            r23.xyz = r25.xyz * float3(1.5,1.5,1.5) + r23.xyz;
            r25.xyz = -r24.xyz * r16.www + -r9.xyz;
            r18.x = dot(r25.xyz, r25.xyz);
            r18.x = max(0.00100000005, r18.x);
            r18.x = rsqrt(r18.x);
            r25.xyz = r25.xyz * r18.xxx;
            r18.x = dot(-r26.xyz, r25.xyz);
            r18.x = max(0, r18.x);
            r18.z = 1 + -r24.w;
            r19.w = r18.z * r18.z;
            r19.w = r19.w * r19.w;
            r18.z = r19.w * r18.z;
            r19.w = r18.x + r18.x;
            r18.x = r19.w * r18.x;
            r18.x = r18.x * r6.w + r12.w;
            r18.x = -1 + r18.x;
            r18.z = r18.x * r18.z + 1;
            r18.x = r18.x * r14.z + 1;
            r18.x = r18.z * r18.x;
            r18.x = r18.x * r14.y;
            r18.x = r18.x * r24.w;
            r25.xyz = r21.xzw * r18.xxx;
            r25.xyz = r25.xyz * r6.xyz;
            r23.xyz = r25.xyz * float3(0.25,0.25,0.25) + r23.xyz;
            r22.xyz = r23.xyz * r2.www;
          } else {
            r18.x = cmp(r23.w >= 0);
            r23.xyz = -r24.xyz * r16.www + -r9.xyz;
            r16.w = dot(r23.xyz, r23.xyz);
            r16.w = max(0.00100000005, r16.w);
            r16.w = rsqrt(r16.w);
            r23.xyz = r23.xyz * r16.www;
            r16.w = dot(r11.xyz, r23.xyz);
            r16.w = max(0, r16.w);
            r18.z = dot(-r26.xyz, r23.xyz);
            r18.z = max(0, r18.z);
            r19.w = r24.w * r7.w + r6.w;
            r19.w = r19.w * r3.y;
            r19.w = r24.w * r9.w + r19.w;
            r19.w = 9.99999975e-006 + r19.w;
            r19.w = 0.5 / r19.w;
            r20.w = r16.w * r10.w + -r16.w;
            r16.w = r20.w * r16.w + 1;
            r16.w = r16.w * r16.w + 1.00000001e-007;
            r16.w = r11.w / r16.w;
            r20.w = 1 + -r24.w;
            r22.w = r20.w * r20.w;
            r22.w = r22.w * r22.w;
            r20.w = r22.w * r20.w;
            r22.w = r18.z + r18.z;
            r22.w = r22.w * r18.z;
            r22.w = r22.w * r6.w + r12.w;
            r22.w = -1 + r22.w;
            r20.w = r22.w * r20.w + 1;
            r22.w = r22.w * r14.z + 1;
            r20.w = r22.w * r20.w;
            r20.w = r20.w * r14.y;
            r16.w = r19.w * r16.w;
            r16.w = r16.w * r24.w;
            r16.w = 3.14159274 * r16.w;
            r16.w = max(0, r16.w);
            r19.w = r20.w * r24.w;
            r23.xyz = r21.xzw * r19.www;
            r21.xzw = r16.www * r21.xzw;
            r16.w = 1 + -r18.z;
            r18.z = r16.w * r16.w;
            r18.z = r18.z * r18.z;
            r16.w = r18.z * r16.w;
            r24.xyz = r12.xyz * r16.www + r10.xyz;
            r21.xzw = r24.xyz * r21.xzw;
            r16.w = r18.x ? 1.000000 : 0;
            r21.xzw = r21.xzw * r16.www;
            r22.xyz = r6.xyz * r23.xyz + r21.xzw;
          }
        }
      } else {
        r22.xyz = float3(0,0,0);
      }
      r17.yzw = r22.xyz + r17.yzw;
      r16.z = (int)r16.z + 1;
    }
    r0.x = (int)r0.w + (int)r0.x;
    r0.yzw = float3(25,25,25) * r6.xyz;
    r1.y = r1.w + r1.w;
    r1.yzw = r4.xyz * -r1.yyy + -r9.xyz;
    r2.x = -r6.w * 0.5 + 1;
    r2.y = r3.x * r2.x + r12.w;
    r2.z = r6.w * r6.w + -1;
    r2.w = r10.w * r10.w;
    r3.x = 1 + -r3.x;
    r3.y = r3.x * r3.x;
    r3.y = r3.y * r3.y;
    r3.x = r3.y * r3.x;
    r3.yzw = float3(1,1,1) + -r5.xyz;
    r6.xyz = r17.yzw;
    r4.w = r16.z;
    [loop] while (true) {
      r6.w = cmp((int)r4.w >= (int)r0.x);
      [branch] if (r6.w != 0) break;
      r6.w = _BT_LinkListBuffer[r4.w].val[0/4];
      r9.x = _BT_LightBuffer[r6.w].val[0/4];
      r9.y = _BT_LightBuffer[r6.w].val[0/4+1];
      r9.z = _BT_LightBuffer[r6.w].val[0/4+2];
      r9.w = _BT_LightBuffer[r6.w].val[0/4+3];
      r10.x = _BT_LightBuffer[r6.w].val[16/4];
      r10.y = _BT_LightBuffer[r6.w].val[16/4+1];
      r10.z = _BT_LightBuffer[r6.w].val[16/4+2];
      r7.w = _BT_LightBuffer[r6.w].val[32/4];
      r11.x = _BT_LightBuffer[r6.w].val[48/4];
      r11.y = _BT_LightBuffer[r6.w].val[48/4+1];
      r11.z = _BT_LightBuffer[r6.w].val[48/4+2];
      r6.w = r9.w * r9.w;
      r6.w = 1 / r6.w;
      r11.xyz = r11.xyz * r7.www + r9.xyz;
      r9.xyz = r9.xyz + -r8.xyz;
      r11.xyz = r11.xyz + -r8.xyz;
      r7.w = dot(r9.xyz, r9.xyz);
      r8.w = sqrt(r7.w);
      r9.w = dot(r11.xyz, r11.xyz);
      r9.w = sqrt(r9.w);
      r10.w = dot(r9.xyz, r4.xyz);
      r11.w = r8.w + r8.w;
      r10.w = r10.w / r11.w;
      r11.w = dot(r11.xyz, r4.xyz);
      r12.x = r9.w + r9.w;
      r11.w = r11.w / r12.x;
      r10.w = saturate(r11.w + r10.w);
      r12.xyz = r11.xyz + -r9.xyz;
      r11.w = dot(r1.yzw, r9.xyz);
      r13.x = dot(r1.yzw, r12.xyz);
      r13.y = dot(r9.xyz, r12.xyz);
      r13.z = dot(r12.xyz, r12.xyz);
      r7.w = r13.x * r7.w;
      r7.w = r13.y * r11.w + -r7.w;
      r11.w = r13.z * r11.w;
      r11.w = r13.y * r13.x + -r11.w;
      r7.w = saturate(r7.w / r11.w);
      r13.xyz = r12.yzx * r9.zxy;
      r13.xyz = r9.yzx * r12.zxy + -r13.xyz;
      r14.xyz = r12.zxy * r1.zwy;
      r14.xyz = r12.yzx * r1.wyz + -r14.xyz;
      r11.w = dot(r13.xyz, r14.xyz);
      r13.x = 1 + -r7.w;
      r11.w = cmp(r11.w >= 0);
      r11.w = r11.w ? 1.000000 : 0;
      r7.w = -r13.x + r7.w;
      r7.w = r11.w * r7.w + r13.x;
      r12.xyz = r12.xyz * r7.www + r9.xyz;
      r7.w = dot(r12.xyz, r1.yzw);
      r13.xyz = r7.www * r1.yzw + -r12.xyz;
      r7.w = dot(r13.xyz, r13.xyz);
      r7.w = sqrt(r7.w);
      r7.w = 0.100000001 / r7.w;
      r7.w = min(1, r7.w);
      r12.xyz = r13.xyz * r7.www + r12.xyz;
      r7.w = dot(r12.xyz, r12.xyz);
      r7.w = sqrt(r7.w);
      r12.xyz = r12.xyz / r7.www;
      r9.x = dot(r9.xyz, r11.xyz);
      r8.w = r8.w * r9.w + r9.x;
      r8.w = 0.5 * r8.w;
      r6.w = r8.w * r6.w;
      r6.w = sqrt(r6.w);
      r8.w = r6.w * 4 + 1;
      r8.w = r8.w * r8.w;
      r8.w = 1 / r8.w;
      r8.w = -0.0399999991 + r8.w;
      r8.w = 1.04166675 * r8.w;
      r6.w = cmp(r6.w >= 1);
      r6.w = r6.w ? 0 : r8.w;
      r9.xyz = r10.xyz * r6.www;
      r10.xyz = -r7.xyz * r1.xxx + r12.xyz;
      r6.w = dot(r10.xyz, r10.xyz);
      r6.w = max(0.00100000005, r6.w);
      r6.w = rsqrt(r6.w);
      r10.xyz = r10.xyz * r6.www;
      r6.w = dot(r4.xyz, r10.xyz);
      r6.w = max(0, r6.w);
      r8.w = dot(r12.xyz, r10.xyz);
      r8.w = max(0, r8.w);
      r9.w = r10.w * r2.x + r12.w;
      r9.w = r9.w * r2.y + 9.99999975e-006;
      r9.w = 1 / r9.w;
      r6.w = r6.w * r6.w;
      r6.w = r6.w * r2.z + 1;
      r6.w = max(9.99999997e-007, r6.w);
      r7.w = r7.w + r7.w;
      r7.w = 0.100000001 / r7.w;
      r7.w = r5.w * r5.w + r7.w;
      r7.w = min(1, r7.w);
      r7.w = r7.w * r7.w;
      r10.x = 3.14159274 * r6.w;
      r6.w = r10.x * r6.w;
      r6.w = r6.w * r7.w;
      r6.w = r2.w / r6.w;
      r7.w = 1 + -r10.w;
      r10.x = r7.w * r7.w;
      r10.x = r10.x * r10.x;
      r7.w = r10.x * r7.w;
      r10.x = r8.w + r8.w;
      r10.x = r10.x * r8.w;
      r10.x = r10.x * r5.w + -0.5;
      r7.w = r10.x * r7.w + 1;
      r10.x = r10.x * r3.x + 1;
      r7.w = r10.x * r7.w;
      r6.w = r9.w * r6.w;
      r6.w = 0.785398185 * r6.w;
      r6.w = r6.w * r10.w;
      r6.w = max(0, r6.w);
      r7.w = r7.w * r10.w;
      r10.xyz = r9.xyz * r7.www;
      r9.xyz = r6.www * r9.xyz;
      r6.w = 1 + -r8.w;
      r7.w = r6.w * r6.w;
      r7.w = r7.w * r7.w;
      r6.w = r7.w * r6.w;
      r11.xyz = r3.yzw * r6.www + r5.xyz;
      r9.xyz = r11.xyz * r9.xyz;
      r9.xyz = r0.yzw * r10.xyz + r9.xyz;
      r6.xyz = r9.xyz + r6.xyz;
      r4.w = (int)r4.w + 1;
    }
    r0.xyz = float3(8,8,8) * r6.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps be179f5b613d51af: 1 retail keyword combination(s)
void ps_be179f5b613d51af_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r3.xyzw = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xyzw;
    r4.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r1.yz = cmp(r4.ww == float2(0.666666687,0.333333343));
    r0.w = (int)r1.z | (int)r1.y;
    r5.xy = r3.xy * float2(2,2) + float2(-1,-1);
    r6.xyz = float3(1,1,1) + -abs(r5.xyx);
    r7.z = r6.x + -abs(r5.y);
    r1.w = cmp(r7.z >= 0);
    r5.zw = cmp(r5.xy >= float2(0,0));
    r5.zw = r5.zw ? float2(1,1) : float2(-1,-1);
    r5.zw = r6.yz * r5.zw;
    r7.xy = r1.ww ? r5.xy : r5.zw;
    r1.w = dot(r7.xyz, r7.xyz);
    r1.w = rsqrt(r1.w);
    r5.xyz = r7.xyz * r1.www;
    r6.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r7.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,1) + r2.xyzw;
    r7.xyz = r3.xxx * r7.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r1.w = -r3.x * 0.959999979 + 0.959999979;
    r8.xyz = r2.xyz * r1.www;
    r6.w = 0.0195999984;
    r8.w = r7.x;
    r6.xyzw = r0.wwww ? r6.xyzw : r8.xyzw;
    r2.xyz = r0.www ? r5.xyz : 0;
    r5.yz = r0.ww ? float2(0.0195999984,0.0195999984) : r7.yz;
    r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r0.w = dot(r4.xyz, r4.xyz);
    r0.w = rsqrt(r0.w);
    r4.xyz = r4.xyz * r0.www;
    r7.z = 1 + -r1.x;
    r7.xy = v0.zw;
    r7.xyz = r7.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r8.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r7.yyyy;
    r8.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r7.xxxx + r8.xyzw;
    r8.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r7.zzzz + r8.xyzw;
    r8.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r8.xyzw;
    r7.xyz = r8.xyz / r8.www;
    r8.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r7.yyyy;
    r8.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r7.xxxx + r8.xyzw;
    r8.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r7.zzzz + r8.xyzw;
    r8.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r8.xyzw;
    r7.xyz = -_WorldSpaceCameraPos.xyz + r8.xyz;
    r0.w = dot(r7.xyz, r7.xyz);
    r0.w = rsqrt(r0.w);
    r7.xyz = r7.xyz * r0.www;
    r0.w = cmp(0 < r4.w);
    r1.x = 0.5 * r7.w;
    r9.xyz = r6.xyz * r1.xxx;
    r5.x = r6.w;
    r10.xyz = r5.xyz * r2.www;
    r9.w = r10.x;
    r6.xyzw = r0.wwww ? r9.xyzw : r6.xyzw;
    r5.yz = r0.ww ? r10.yz : r5.yz;
    r0.w = dot(r4.xyz, -r7.xyz);
    r1.x = saturate(r0.w);
    r0.y = (int)r0.y + (int)r0.x;
    r1.w = r2.w * r2.w;
    r1.w = r1.w * r1.w;
    r1.w = r1.w * r1.w;
    r5.x = r6.w;
    r9.xyz = r5.xyz * r1.www;
    r3.x = 1 + -r3.z;
    r3.y = r3.x * r3.x;
    r4.w = cmp(r0.w < 0);
    r0.w = 9.99999975e-006 + -r0.w;
    r10.xyz = -r7.xyz * r0.www + r4.xyz;
    r10.xyz = r4.www ? r10.xyz : r4.xyz;
    r0.w = -r3.x * r3.x + 1;
    r3.x = r1.x * r0.w + r3.y;
    r4.w = r3.y * r3.y;
    r5.w = 0.318309873 * r4.w;
    r5.xyz = -r5.xyz * r1.www + float3(1,1,1);
    r1.w = dot(r2.xyz, -r7.xyz);
    r6.w = cmp(r1.w < 0);
    r7.w = 9.99999975e-006 + -r1.w;
    r11.xyz = -r7.xyz * r7.www + r2.xyz;
    r11.xyz = r6.www ? r11.xyz : r2.xyz;
    r6.w = r3.w * 10 + 5;
    r7.w = -r1.w * r1.w + 1;
    r7.w = sqrt(r7.w);
    r12.xy = float2(0.0349065885,-0.052359879) * r6.ww;
    sincos(r12.x, r12.x, r13.x);
    sincos(r12.y, r14.x, r15.x);
    r6.w = 0.5 * r3.y;
    r9.w = r3.y * -0.337748349 + 1;
    r10.w = 1 + -r1.x;
    r11.w = r10.w * r10.w;
    r11.w = r11.w * r11.w;
    r10.w = r11.w * r10.w;
    r2.w = r2.w * 0.75 + 0.25;
    r16.yw = r3.ww;
    r12.yzw = float3(0,0,0);
    r3.w = r0.x;
    [loop] while (true) {
      r11.w = cmp((int)r3.w >= (int)r0.y);
      [branch] if (r11.w != 0) break;
      r11.w = _BT_LinkListBuffer[r3.w].val[0/4];
      r17.x = _BT_LightBuffer[r11.w].val[0/4];
      r17.y = _BT_LightBuffer[r11.w].val[0/4+1];
      r17.z = _BT_LightBuffer[r11.w].val[0/4+2];
      r17.w = _BT_LightBuffer[r11.w].val[0/4+3];
      r13.y = _BT_LightBuffer[r11.w].val[32/4];
      r14.yzw = -r17.xyz + r8.xyz;
      r13.z = dot(r14.yzw, r14.yzw);
      r13.w = r17.w * r17.w;
      r15.y = max(0.100000001, r13.z);
      r13.w = r15.y / r13.w;
      r13.w = -r13.w * r13.w + 1;
      r13.w = max(0, r13.w);
      r13.w = r13.w * r13.w;
      r13.y = r17.w * r13.y + r15.y;
      r13.y = 1 / r13.y;
      r13.y = r13.y * r13.w;
      r13.w = cmp(r13.y != 0.000000);
      [branch] if (r13.w != 0) {
        r15.y = _BT_LightBuffer[r11.w].val[16/4];
        r15.z = _BT_LightBuffer[r11.w].val[16/4+1];
        r15.w = _BT_LightBuffer[r11.w].val[16/4+2];
        r11.w = _BT_LightBuffer[r11.w].val[60/4];
        r13.z = rsqrt(r13.z);
        r17.xyz = r14.yzw * r13.zzz;
        r15.yzw = r15.yzw * r13.yyy;
        r13.y = dot(r4.xyz, -r17.xyz);
        r13.y = max(0, r13.y);
        [branch] if (r1.y != 0) {
          r13.w = cmp(r11.w >= 0);
          r18.xyz = -r14.yzw * r13.zzz + -r7.xyz;
          r17.w = dot(r18.xyz, r18.xyz);
          r17.w = max(0.00100000005, r17.w);
          r17.w = rsqrt(r17.w);
          r18.xyz = r18.xyz * r17.www;
          r17.w = dot(r10.xyz, r18.xyz);
          r17.w = max(0, r17.w);
          r18.x = dot(-r17.xyz, r18.xyz);
          r18.x = max(0, r18.x);
          r18.y = r13.y * r0.w + r3.y;
          r18.y = r18.y * r1.x;
          r18.y = r13.y * r3.x + r18.y;
          r18.y = 9.99999975e-006 + r18.y;
          r18.y = 0.5 / r18.y;
          r18.z = r17.w * r4.w + -r17.w;
          r17.w = r18.z * r17.w + 1;
          r17.w = r17.w * r17.w + 1.00000001e-007;
          r17.w = r5.w / r17.w;
          r17.w = r18.y * r17.w;
          r17.w = 3.14159274 * r17.w;
          r17.w = r17.w * r13.y;
          r17.w = max(0, r17.w);
          r18.yzw = r17.www * r15.yzw;
          r17.w = 1 + -r18.x;
          r18.x = r17.w * r17.w;
          r18.x = r18.x * r18.x;
          r17.w = r18.x * r17.w;
          r19.xyz = r5.xyz * r17.www + r9.xyz;
          r18.xyz = r19.xyz * r18.yzw;
          r13.w = r13.w ? 1.000000 : 0;
          r17.w = dot(r11.xyz, -r17.xyz);
          r16.x = r17.w * 0.5 + 0.5;
          r19.xyz = _BT_PreIntegratedSSS.SampleLevel(sampler_BT_PreIntegratedSSS, r16.xy, 0).xyz;
          r19.xyz = r19.xyz * r15.yzw;
          r19.xyz = r19.xyz * r6.xyz;
          r18.xyz = r18.xyz * r13.www + r19.xyz;
        } else {
          [branch] if (r1.z != 0) {
            r13.w = dot(r2.xyz, -r17.xyz);
            r16.x = -r13.w * r13.w + 1;
            r16.x = sqrt(r16.x);
            r17.w = r16.x * r12.x;
            r17.w = -r13.w * r13.x + -r17.w;
            r18.w = -r17.w * r17.w + 1;
            r18.w = sqrt(r18.w);
            r18.w = r18.w * r7.w;
            r17.w = r17.w * r1.w + r18.w;
            r17.w = max(0, r17.w);
            r18.w = r16.x * r14.x;
            r13.w = -r13.w * r15.x + -r18.w;
            r18.w = -r13.w * r13.w + 1;
            r18.w = sqrt(r18.w);
            r18.w = r18.w * r7.w;
            r13.w = r13.w * r1.w + r18.w;
            r13.w = max(0, r13.w);
            r16.x = 0.00999999978 * r16.x;
            r17.w = log2(r17.w);
            r17.w = 30.3999996 * r17.w;
            r17.w = exp2(r17.w);
            r17.w = 0.0500000007 * r17.w;
            r13.w = log2(r13.w);
            r13.w = 15.8000002 * r13.w;
            r13.w = exp2(r13.w);
            r13.w = 0.100000001 * r13.w;
            r19.xyz = r16.xxx * r15.yzw;
            r20.xyz = r17.www * r15.yzw;
            r20.xyz = r20.xyz * r3.zzz;
            r20.xyz = float3(1.5,1.5,1.5) * r20.xyz;
            r19.xyz = r19.xyz * r6.xyz + r20.xyz;
            r20.xyz = r13.www * r15.yzw;
            r20.xyz = r20.xyz * r6.xyz;
            r20.xyz = r20.xyz * r3.zzz;
            r19.xyz = r20.xyz * float3(1.5,1.5,1.5) + r19.xyz;
            r20.xyz = -r14.yzw * r13.zzz + -r7.xyz;
            r13.w = dot(r20.xyz, r20.xyz);
            r13.w = max(0.00100000005, r13.w);
            r13.w = rsqrt(r13.w);
            r20.xyz = r20.xyz * r13.www;
            r13.w = dot(-r17.xyz, r20.xyz);
            r13.w = max(0, r13.w);
            r16.x = 1 + -r13.y;
            r17.w = r16.x * r16.x;
            r17.w = r17.w * r17.w;
            r16.x = r17.w * r16.x;
            r17.w = r13.w + r13.w;
            r13.w = r17.w * r13.w;
            r13.w = r13.w * r3.y + r6.w;
            r13.w = -1 + r13.w;
            r16.x = r13.w * r16.x + 1;
            r13.w = r13.w * r10.w + 1;
            r13.w = r16.x * r13.w;
            r13.w = r13.w * r9.w;
            r13.w = r13.w * r13.y;
            r20.xyz = r15.yzw * r13.www;
            r20.xyz = r20.xyz * r6.xyz;
            r19.xyz = r20.xyz * float3(0.25,0.25,0.25) + r19.xyz;
            r18.xyz = r19.xyz * r2.www;
          } else {
            r11.w = cmp(r11.w >= 0);
            r14.yzw = -r14.yzw * r13.zzz + -r7.xyz;
            r13.z = dot(r14.yzw, r14.yzw);
            r13.z = max(0.00100000005, r13.z);
            r13.z = rsqrt(r13.z);
            r14.yzw = r14.yzw * r13.zzz;
            r13.z = dot(r10.xyz, r14.yzw);
            r13.w = dot(-r17.xyz, r14.yzw);
            r13.zw = max(float2(0,0), r13.zw);
            r14.y = r13.y * r0.w + r3.y;
            r14.y = r14.y * r1.x;
            r14.y = r13.y * r3.x + r14.y;
            r14.y = 9.99999975e-006 + r14.y;
            r14.y = 0.5 / r14.y;
            r14.z = r13.z * r4.w + -r13.z;
            r13.z = r14.z * r13.z + 1;
            r13.z = r13.z * r13.z + 1.00000001e-007;
            r13.z = r5.w / r13.z;
            r14.z = 1 + -r13.y;
            r14.w = r14.z * r14.z;
            r14.w = r14.w * r14.w;
            r14.z = r14.w * r14.z;
            r14.w = r13.w + r13.w;
            r14.w = r14.w * r13.w;
            r14.w = r14.w * r3.y + r6.w;
            r14.w = -1 + r14.w;
            r14.z = r14.w * r14.z + 1;
            r14.w = r14.w * r10.w + 1;
            r14.z = r14.z * r14.w;
            r14.z = r14.z * r9.w;
            r13.z = r14.y * r13.z;
            r13.z = 3.14159274 * r13.z;
            r13.z = r13.z * r13.y;
            r13.z = max(0, r13.z);
            r13.y = r14.z * r13.y;
            r14.yzw = r15.yzw * r13.yyy;
            r15.yzw = r13.zzz * r15.yzw;
            r13.y = 1 + -r13.w;
            r13.z = r13.y * r13.y;
            r13.z = r13.z * r13.z;
            r13.y = r13.z * r13.y;
            r13.yzw = r5.xyz * r13.yyy + r9.xyz;
            r13.yzw = r15.yzw * r13.yzw;
            r11.w = r11.w ? 1.000000 : 0;
            r13.yzw = r13.yzw * r11.www;
            r18.xyz = r6.xyz * r14.yzw + r13.yzw;
          }
        }
      } else {
        r18.xyz = float3(0,0,0);
      }
      r12.yzw = r18.xyz + r12.yzw;
      r3.w = (int)r3.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r0.y = sqrt(_BT_ShadowMapParams.z);
    r0.z = _BT_MaxShadowDist * _BT_MaxShadowDist;
    r11.w = 0.5 * r0.z;
    r11.w = 1 / r11.w;
    r13.y = _ShadowDummyTex.SampleLevel(sampler_ShadowDummyTex, float2(0,0), 0).x;
    r17.xz = _BT_ShadowMap_TexelSize.xx;
    r17.y = 0.142857149;
    r18.xz = _BT_ShadowMap_TexelSize.yy;
    r18.y = 0.142857149;
    r19.y = 7;
    r16.y = 0.5;
    r14.yzw = r12.yzw;
    r13.z = r3.w;
    [loop] while (true) {
      r13.w = cmp((int)r13.z >= (int)r0.x);
      [branch] if (r13.w != 0) break;
      r13.w = _BT_LinkListBuffer[r13.z].val[0/4];
      r20.x = _BT_LightBuffer[r13.w].val[0/4];
      r20.y = _BT_LightBuffer[r13.w].val[0/4+1];
      r20.z = _BT_LightBuffer[r13.w].val[0/4+2];
      r20.w = _BT_LightBuffer[r13.w].val[0/4+3];
      r15.y = _BT_LightBuffer[r13.w].val[32/4];
      r21.x = _BT_LightBuffer[r13.w].val[48/4];
      r21.y = _BT_LightBuffer[r13.w].val[48/4+1];
      r21.z = _BT_LightBuffer[r13.w].val[48/4+2];
      r21.w = _BT_LightBuffer[r13.w].val[48/4+3];
      r15.z = (uint)r13.w << 2;
      r15.y = frac(r15.y);
      r22.xyz = -r20.xyz + r8.xyz;
      r15.w = dot(r22.xyz, r22.xyz);
      r17.w = r20.w * r20.w;
      r23.xyzw = float4(_BT_LightMatrix[(uint)(r15.z) / 4u][0][1], _BT_LightMatrix[(uint)(r15.z) / 4u][1][1], _BT_LightMatrix[(uint)(r15.z) / 4u][2][1], _BT_LightMatrix[(uint)(r15.z) / 4u][3][1]) * r8.yyyy;
      r23.xyzw = float4(_BT_LightMatrix[(uint)(r15.z) / 4u][0][0], _BT_LightMatrix[(uint)(r15.z) / 4u][1][0], _BT_LightMatrix[(uint)(r15.z) / 4u][2][0], _BT_LightMatrix[(uint)(r15.z) / 4u][3][0]) * r8.xxxx + r23.xyzw;
      r23.xyzw = float4(_BT_LightMatrix[(uint)(r15.z) / 4u][0][2], _BT_LightMatrix[(uint)(r15.z) / 4u][1][2], _BT_LightMatrix[(uint)(r15.z) / 4u][2][2], _BT_LightMatrix[(uint)(r15.z) / 4u][3][2]) * r8.zzzz + r23.xyzw;
      r23.xyzw = float4(_BT_LightMatrix[(uint)(r15.z) / 4u][0][3], _BT_LightMatrix[(uint)(r15.z) / 4u][1][3], _BT_LightMatrix[(uint)(r15.z) / 4u][2][3], _BT_LightMatrix[(uint)(r15.z) / 4u][3][3]) * r8.wwww + r23.xyzw;
      r15.z = max(0.100000001, r15.w);
      r17.w = r15.z / r17.w;
      r17.w = -r17.w * r17.w + 1;
      r17.w = max(0, r17.w);
      r17.w = r17.w * r17.w;
      r15.y = r20.w * r15.y + r15.z;
      r15.y = 1 / r15.y;
      r15.y = r15.y * r17.w;
      r23.xyz = r23.xyz / r23.www;
      r15.z = cmp(0 >= r23.z);
      r24.xy = cmp(float2(1,1) < r23.xy);
      r15.z = (int)r15.z | (int)r24.x;
      r24.xz = cmp(r23.xy < float2(-1,-1));
      r15.z = (int)r15.z | (int)r24.x;
      r15.z = (int)r24.y | (int)r15.z;
      r15.z = (int)r24.z | (int)r15.z;
      [branch] if (r15.z == 0) {
        r17.w = r21.x / r21.y;
        r17.w = min(0.99000001, r17.w);
        r18.w = dot(r23.xy, r23.xy);
        r18.w = sqrt(r18.w);
        r18.w = min(1, r18.w);
        r17.w = -1 + r17.w;
        r18.w = -1 + r18.w;
        r17.w = 1 / r17.w;
        r17.w = r18.w * r17.w;
        r17.w = min(1, r17.w);
        r18.w = r17.w * -2 + 3;
        r17.w = r17.w * r17.w;
        r17.w = r18.w * r17.w;
        r18.w = cmp(r17.w != 0.000000);
        [branch] if (r18.w != 0) {
          r18.w = cmp(-1 < r21.z);
          [branch] if (r18.w != 0) {
            r24.xy = r23.xy * float2(0.5,0.5) + float2(0.5,0.5);
            r20.xyz = _WorldSpaceCameraPos.xyz + -r20.xyz;
            r18.w = dot(r20.xyz, r20.xyz);
            r19.w = r21.z / r0.y;
            r20.x = cmp(r19.w >= -r19.w);
            r20.y = frac(abs(r19.w));
            r20.x = r20.x ? r20.y : -r20.y;
            r20.x = r20.x * r0.y;
            r20.x = r20.x / r0.y;
            r19.w = floor(r19.w);
            r20.y = r19.w / r0.y;
            r24.xy = r24.xy / r0.yy;
            r20.xy = r24.xy + r20.xy;
            r19.w = r23.z + abs(r21.w);
            r20.xy = r20.xy * _BT_ShadowMap_TexelSize.zw + float2(0.5,0.5);
            r24.xy = floor(r20.xy);
            r24.xy = float2(-0.5,-0.5) + r24.xy;
            r20.xy = frac(r20.xy);
            r20.z = 3 * r20.x;
            r24.zw = -r20.xy * float2(3,3) + float2(4,4);
            r25.xy = r20.xy * float2(3,3) + float2(1,1);
            r25.zw = -r20.xy * float2(2,2) + float2(3,3);
            r25.zw = r25.zw / r24.zw;
            r26.xy = float2(-2,-2) + r25.zw;
            r25.zw = float2(3,3) + r20.xy;
            r27.xy = _BT_ShadowMap_TexelSize.xy * r25.zw;
            r20.xy = r20.xy / r25.xy;
            r20.xy = float2(2,2) + r20.xy;
            r26.z = r27.x;
            r26.w = r20.x;
            r28.xyz = r26.xzw * r17.xyz;
            r27.z = r26.y;
            r27.w = r20.y;
            r26.xyw = r27.zyw * r18.xyz;
            r19.xz = r20.zz * float2(-1,1) + float2(4,1);
            r20.xyz = r24.www * r19.xyz;
            r28.w = r26.x;
            r27.xyzw = r24.xyxy * _BT_ShadowMap_TexelSize.xyxy + r28.xwyw;
            r22.w = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r27.xy, r19.w).x;
            r23.w = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r27.zw, r19.w).x;
            r20.y = r23.w * r20.y;
            r20.x = r20.x * r22.w + r20.y;
            r24.zw = r24.xy * _BT_ShadowMap_TexelSize.xy + r28.zw;
            r20.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r24.zw, r19.w).x;
            r20.x = r20.z * r20.y + r20.x;
            r20.yz = float2(7,7) * r19.xz;
            r26.z = r28.x;
            r27.xyzw = r24.xyxy * _BT_ShadowMap_TexelSize.xyxy + r26.zyzw;
            r22.w = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r27.xy, r19.w).x;
            r20.x = r20.y * r22.w + r20.x;
            r26.xz = r28.yz;
            r28.xyzw = r24.xyxy * _BT_ShadowMap_TexelSize.xyxy + r26.xyzy;
            r20.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r28.xy, r19.w).x;
            r20.x = r20.y * 49 + r20.x;
            r20.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r28.zw, r19.w).x;
            r20.x = r20.z * r20.y + r20.x;
            r25.xyz = r25.yyy * r19.xyz;
            r19.x = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r27.zw, r19.w).x;
            r19.x = r25.x * r19.x + r20.x;
            r24.xyzw = r24.xyxy * _BT_ShadowMap_TexelSize.xyxy + r26.xwzw;
            r19.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r24.xy, r19.w).x;
            r19.x = r25.y * r19.z + r19.x;
            r19.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r24.zw, r19.w).x;
            r19.x = r25.z * r19.z + r19.x;
            r19.z = 0.0069444445 * r19.x;
            r18.w = -r0.z * 0.5 + r18.w;
            r18.w = saturate(r18.w * r11.w);
            r19.w = r18.w * -2 + 3;
            r18.w = r18.w * r18.w;
            r18.w = r19.w * r18.w;
            r19.x = -r19.x * 0.0069444445 + 1;
            r18.w = r18.w * r19.x + r19.z;
            r17.w = r18.w * r17.w;
          }
        } else {
          r17.w = 0;
        }
      } else {
        r17.w = 0;
      }
      r17.w = r17.w * r15.y;
      r18.w = cmp(r17.w != 0.000000);
      [branch] if (r18.w != 0) {
        r19.x = _BT_LightBuffer[r13.w].val[16/4];
        r19.z = _BT_LightBuffer[r13.w].val[16/4+1];
        r19.w = _BT_LightBuffer[r13.w].val[16/4+2];
        r13.w = rsqrt(r15.w);
        r20.xyz = r22.xyz * r13.www;
        r24.xyz = r19.xzw * r17.www;
        r15.w = dot(r4.xyz, -r20.xyz);
        r15.w = max(0, r15.w);
        [branch] if (r1.y != 0) {
          r17.w = cmp(r21.w >= 0);
          r25.xyz = -r22.xyz * r13.www + -r7.xyz;
          r18.w = dot(r25.xyz, r25.xyz);
          r18.w = max(0.00100000005, r18.w);
          r18.w = rsqrt(r18.w);
          r25.xyz = r25.xyz * r18.www;
          r18.w = dot(r10.xyz, r25.xyz);
          r18.w = max(0, r18.w);
          r22.w = dot(-r20.xyz, r25.xyz);
          r22.w = max(0, r22.w);
          r23.w = r15.w * r0.w + r3.y;
          r23.w = r23.w * r1.x;
          r23.w = r15.w * r3.x + r23.w;
          r23.w = 9.99999975e-006 + r23.w;
          r23.w = 0.5 / r23.w;
          r24.w = r18.w * r4.w + -r18.w;
          r18.w = r24.w * r18.w + 1;
          r18.w = r18.w * r18.w + 1.00000001e-007;
          r18.w = r5.w / r18.w;
          r18.w = r23.w * r18.w;
          r18.w = 3.14159274 * r18.w;
          r18.w = r18.w * r15.w;
          r18.w = max(0, r18.w);
          r25.xyz = r18.www * r24.xyz;
          r18.w = 1 + -r22.w;
          r22.w = r18.w * r18.w;
          r22.w = r22.w * r22.w;
          r18.w = r22.w * r18.w;
          r26.xyz = r5.xyz * r18.www + r9.xyz;
          r25.xyz = r26.xyz * r25.xyz;
          r17.w = r17.w ? 1.000000 : 0;
          r18.w = dot(r11.xyz, -r20.xyz);
          r16.z = r18.w * 0.5 + 0.5;
          r26.xyz = _BT_PreIntegratedSSS.SampleLevel(sampler_BT_PreIntegratedSSS, r16.zw, 0).xyz;
          r26.xyz = r26.xyz * r24.xyz;
          r26.xyz = r26.xyz * r6.xyz;
          r25.xyz = r25.xyz * r17.www + r26.xyz;
          [branch] if (r15.z == 0) {
            r15.z = r21.x / r21.y;
            r15.z = min(0.99000001, r15.z);
            r16.z = dot(r23.xy, r23.xy);
            r16.z = sqrt(r16.z);
            r16.z = min(1, r16.z);
            r15.z = -1 + r15.z;
            r16.z = -1 + r16.z;
            r15.z = 1 / r15.z;
            r15.z = r16.z * r15.z;
            r15.z = min(1, r15.z);
            r16.z = r15.z * -2 + 3;
            r15.z = r15.z * r15.z;
            r15.z = r16.z * r15.z;
            r16.z = cmp(-1 < r21.z);
            [branch] if (r16.z != 0) {
              r21.xy = r23.xy * float2(0.5,0.5) + float2(0.5,0.5);
              r16.z = r21.z / r0.y;
              r17.w = cmp(r16.z >= -r16.z);
              r18.w = frac(abs(r16.z));
              r17.w = r17.w ? r18.w : -r18.w;
              r17.w = r17.w * r0.y;
              r23.x = r17.w / r0.y;
              r16.z = floor(r16.z);
              r23.y = r16.z / r0.y;
              r21.xy = r21.xy / r0.yy;
              r21.xy = r21.xy + r23.xy;
              r16.z = 1 + -r23.z;
              r17.w = 0.5 * r20.w;
              r18.w = -0.5 + r20.w;
              r16.z = -r16.z * r18.w + r20.w;
              r16.z = r17.w / r16.z;
              r23.xyzw = _BT_ShadowMap.Gather(sampler_ShadowDummyTex, r21.xy, int2(-1, -1)).xyzw;
              r23.xyzw = float4(1,1,1,1) + -r23.xyzw;
              r23.xyzw = -r23.xyzw * r18.wwww + r20.wwww;
              r23.xyzw = r17.wwww / r23.xyzw;
              r23.xyzw = -r23.xyzw + r16.zzzz;
              r23.xyzw = float4(40,40,40,40) * abs(r23.xyzw);
              r23.xyzw = min(float4(1,1,1,1), r23.xyzw);
              r21.z = dot(r23.xyzw, float4(1,1,1,1));
              r21.z = r21.z + r13.y;
              r23.xyzw = _BT_ShadowMap.Gather(sampler_ShadowDummyTex, r21.xy, int2(1, -1)).xyzw;
              r23.xyzw = float4(1,1,1,1) + -r23.xyzw;
              r23.xyzw = -r23.xyzw * r18.wwww + r20.wwww;
              r23.xyzw = r17.wwww / r23.xyzw;
              r23.xyzw = -r23.xyzw + r16.zzzz;
              r23.xyzw = float4(40,40,40,40) * abs(r23.xyzw);
              r23.xyzw = min(float4(1,1,1,1), r23.xyzw);
              r22.w = dot(r23.xyzw, float4(1,1,1,1));
              r21.z = r22.w + r21.z;
              r23.xyzw = _BT_ShadowMap.Gather(sampler_ShadowDummyTex, r21.xy, int2(-1, 1)).xyzw;
              r23.xyzw = float4(1,1,1,1) + -r23.xyzw;
              r23.xyzw = -r23.xyzw * r18.wwww + r20.wwww;
              r23.xyzw = r17.wwww / r23.xyzw;
              r23.xyzw = -r23.xyzw + r16.zzzz;
              r23.xyzw = float4(40,40,40,40) * abs(r23.xyzw);
              r23.xyzw = min(float4(1,1,1,1), r23.xyzw);
              r22.w = dot(r23.xyzw, float4(1,1,1,1));
              r21.z = r22.w + r21.z;
              r23.xyzw = _BT_ShadowMap.Gather(sampler_ShadowDummyTex, r21.xy, int2(1, 1)).xyzw;
              r23.xyzw = float4(1,1,1,1) + -r23.xyzw;
              r23.xyzw = -r23.xyzw * r18.wwww + r20.wwww;
              r23.xyzw = r17.wwww / r23.xyzw;
              r23.xyzw = -r23.xyzw + r16.zzzz;
              r23.xyzw = float4(40,40,40,40) * abs(r23.xyzw);
              r23.xyzw = min(float4(1,1,1,1), r23.xyzw);
              r16.z = dot(r23.xyzw, float4(1,1,1,1));
              r16.z = r21.z + r16.z;
              r16.x = saturate(0.0625 * r16.z);
              r21.xyz = _BT_SkinTransmission.SampleLevel(sampler_BT_SkinTransmission, r16.xy, 0).xyz;
            } else {
              r21.xyz = float3(0,0,0);
            }
            r21.xyz = r21.xyz * r15.zzz;
          } else {
            r21.xyz = float3(0,0,0);
          }
          r15.z = dot(-r2.xyz, -r20.xyz);
          r15.z = 0.300000012 + r15.z;
          r15.z = max(0, r15.z);
          r21.xyz = r21.xyz * r15.yyy;
          r19.xzw = r21.xyz * r19.xzw;
          r19.xzw = r19.xzw * r15.zzz;
          r19.xzw = r19.xzw * r6.xyz;
          r19.xzw = r19.xzw * r16.www + r25.xyz;
        } else {
          [branch] if (r1.z != 0) {
            r15.y = dot(r2.xyz, -r20.xyz);
            r15.z = -r15.y * r15.y + 1;
            r15.z = sqrt(r15.z);
            r16.x = r15.z * r12.x;
            r16.x = -r15.y * r13.x + -r16.x;
            r16.z = -r16.x * r16.x + 1;
            r16.z = sqrt(r16.z);
            r16.z = r16.z * r7.w;
            r16.x = r16.x * r1.w + r16.z;
            r16.x = max(0, r16.x);
            r16.z = r15.z * r14.x;
            r15.y = -r15.y * r15.x + -r16.z;
            r16.z = -r15.y * r15.y + 1;
            r16.z = sqrt(r16.z);
            r16.z = r16.z * r7.w;
            r15.y = r15.y * r1.w + r16.z;
            r15.y = max(0, r15.y);
            r16.x = log2(r16.x);
            r16.x = 30.3999996 * r16.x;
            r16.x = exp2(r16.x);
            r16.x = 0.0500000007 * r16.x;
            r15.y = log2(r15.y);
            r15.yz = float2(15.8000002,0.00999999978) * r15.yz;
            r15.y = exp2(r15.y);
            r15.y = 0.100000001 * r15.y;
            r21.xyz = r15.zzz * r24.xyz;
            r23.xyz = r16.xxx * r24.xyz;
            r23.xyz = r23.xyz * r3.zzz;
            r23.xyz = float3(1.5,1.5,1.5) * r23.xyz;
            r21.xyz = r21.xyz * r6.xyz + r23.xyz;
            r23.xyz = r15.yyy * r24.xyz;
            r23.xyz = r23.xyz * r6.xyz;
            r23.xyz = r23.xyz * r3.zzz;
            r21.xyz = r23.xyz * float3(1.5,1.5,1.5) + r21.xyz;
            r23.xyz = -r22.xyz * r13.www + -r7.xyz;
            r15.y = dot(r23.xyz, r23.xyz);
            r15.y = max(0.00100000005, r15.y);
            r15.y = rsqrt(r15.y);
            r23.xyz = r23.xyz * r15.yyy;
            r15.y = dot(-r20.xyz, r23.xyz);
            r15.y = max(0, r15.y);
            r15.z = 1 + -r15.w;
            r16.x = r15.z * r15.z;
            r16.x = r16.x * r16.x;
            r15.z = r16.x * r15.z;
            r16.x = r15.y + r15.y;
            r15.y = r16.x * r15.y;
            r15.y = r15.y * r3.y + r6.w;
            r15.y = -1 + r15.y;
            r15.z = r15.y * r15.z + 1;
            r15.y = r15.y * r10.w + 1;
            r15.y = r15.z * r15.y;
            r15.y = r15.y * r9.w;
            r15.y = r15.y * r15.w;
            r23.xyz = r24.xyz * r15.yyy;
            r23.xyz = r23.xyz * r6.xyz;
            r21.xyz = r23.xyz * float3(0.25,0.25,0.25) + r21.xyz;
            r19.xzw = r21.xyz * r2.www;
          } else {
            r15.y = cmp(r21.w >= 0);
            r21.xyz = -r22.xyz * r13.www + -r7.xyz;
            r13.w = dot(r21.xyz, r21.xyz);
            r13.w = max(0.00100000005, r13.w);
            r13.w = rsqrt(r13.w);
            r21.xyz = r21.xyz * r13.www;
            r13.w = dot(r10.xyz, r21.xyz);
            r13.w = max(0, r13.w);
            r15.z = dot(-r20.xyz, r21.xyz);
            r15.z = max(0, r15.z);
            r16.x = r15.w * r0.w + r3.y;
            r16.x = r16.x * r1.x;
            r16.x = r15.w * r3.x + r16.x;
            r16.x = 9.99999975e-006 + r16.x;
            r16.x = 0.5 / r16.x;
            r16.z = r13.w * r4.w + -r13.w;
            r13.w = r16.z * r13.w + 1;
            r13.w = r13.w * r13.w + 1.00000001e-007;
            r13.w = r5.w / r13.w;
            r16.z = 1 + -r15.w;
            r17.w = r16.z * r16.z;
            r17.w = r17.w * r17.w;
            r16.z = r17.w * r16.z;
            r17.w = r15.z + r15.z;
            r17.w = r17.w * r15.z;
            r17.w = r17.w * r3.y + r6.w;
            r17.w = -1 + r17.w;
            r16.z = r17.w * r16.z + 1;
            r17.w = r17.w * r10.w + 1;
            r16.z = r17.w * r16.z;
            r16.z = r16.z * r9.w;
            r13.w = r16.x * r13.w;
            r13.w = 3.14159274 * r13.w;
            r13.w = r13.w * r15.w;
            r13.w = max(0, r13.w);
            r15.w = r16.z * r15.w;
            r20.xyz = r24.xyz * r15.www;
            r21.xyz = r13.www * r24.xyz;
            r13.w = 1 + -r15.z;
            r15.z = r13.w * r13.w;
            r15.z = r15.z * r15.z;
            r13.w = r15.z * r13.w;
            r22.xyz = r5.xyz * r13.www + r9.xyz;
            r21.xyz = r22.xyz * r21.xyz;
            r13.w = r15.y ? 1.000000 : 0;
            r15.yzw = r21.xyz * r13.www;
            r19.xzw = r6.xyz * r20.xyz + r15.yzw;
          }
        }
      } else {
        r19.xzw = float3(0,0,0);
      }
      r14.yzw = r19.xzw + r14.yzw;
      r13.z = (int)r13.z + 1;
    }
    r0.xyz = float3(8,8,8) * r14.yzw;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps b5a46274f5991730: 2 retail keyword combination(s)
void ps_b5a46274f5991730_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r1.yz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xy = cmp(r3.ww == float2(0.666666687,0.333333343));
    r0.w = (int)r4.y | (int)r4.x;
    r5.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r4.xzw = float3(-0.0399999991,-0.0399999991,-0.0399999991) + r2.xyz;
    r4.xzw = r1.yyy * r4.xzw + float3(0.0399999991,0.0399999991,0.0399999991);
    r1.w = 0.100000001 * r1.z;
    r1.y = -r1.y * 0.959999979 + 0.959999979;
    r6.xyz = r2.xyz * r1.yyy;
    r5.w = 0.0195999984;
    r6.w = r4.x;
    r5.xyzw = r0.wwww ? r5.xyzw : r6.xyzw;
    r2.yz = r0.ww ? float2(0.0195999984,0.0195999984) : r4.zw;
    r0.w = r0.w ? r1.w : r1.z;
    r6.xyz = float3(0.100000001,0.100000001,0.100000001) * r5.xyz;
    r2.x = r5.w;
    r1.yzw = float3(0.5,0.5,0.5) * r2.xyz;
    r6.w = r1.y;
    r5.xyzw = r4.yyyy ? r6.xyzw : r5.xyzw;
    r2.yz = r4.yy ? r1.zw : r2.yz;
    r1.yzw = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r3.x = dot(r1.yzw, r1.yzw);
    r3.x = rsqrt(r3.x);
    r1.yzw = r3.xxx * r1.yzw;
    r3.z = 1 + -r1.x;
    r3.xy = v0.zw;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r4.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r3.yyyy;
    r4.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r3.xxxx + r4.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r3.zzzz + r4.xyzw;
    r3.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r3.xyzw;
    r3.xyz = r3.xyz / r3.www;
    r4.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r3.yyyy;
    r4.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r3.xxxx + r4.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r3.zzzz + r4.xyzw;
    r3.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r3.xyzw;
    r4.xyz = -_WorldSpaceCameraPos.xyz + r3.xyz;
    r1.x = dot(r4.xyz, r4.xyz);
    r1.x = rsqrt(r1.x);
    r4.xyz = r4.xyz * r1.xxx;
    r1.x = dot(r1.yzw, -r4.xyz);
    r4.w = saturate(r1.x);
    r0.y = (int)r0.y + (int)r0.x;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.x = r5.w;
    r6.xyz = r2.xyz * r2.www;
    r0.w = 1 + -r0.w;
    r5.w = r0.w * r0.w;
    r6.w = cmp(r1.x < 0);
    r1.x = 9.99999975e-006 + -r1.x;
    r7.xyz = -r4.xyz * r1.xxx + r1.yzw;
    r7.xyz = r6.www ? r7.xyz : r1.yzw;
    r0.w = -r0.w * r0.w + 1;
    r1.x = r4.w * r0.w + r5.w;
    r6.w = r5.w * r5.w;
    r7.w = 0.318309873 * r6.w;
    r8.x = 0.5 * r5.w;
    r8.y = r5.w * -0.337748349 + 1;
    r8.z = 1 + -r4.w;
    r8.w = r8.z * r8.z;
    r8.w = r8.w * r8.w;
    r8.z = r8.w * r8.z;
    r2.xyz = -r2.xyz * r2.www + float3(1,1,1);
    r9.xyz = float3(0,0,0);
    r2.w = r0.x;
    [loop] while (true) {
      r8.w = cmp((int)r2.w >= (int)r0.y);
      [branch] if (r8.w != 0) break;
      r8.w = _BT_LinkListBuffer[r2.w].val[0/4];
      r10.x = _BT_LightBuffer[r8.w].val[0/4];
      r10.y = _BT_LightBuffer[r8.w].val[0/4+1];
      r10.z = _BT_LightBuffer[r8.w].val[0/4+2];
      r10.w = _BT_LightBuffer[r8.w].val[0/4+3];
      r9.w = _BT_LightBuffer[r8.w].val[32/4];
      r10.xyz = -r10.xyz + r3.xyz;
      r11.x = dot(r10.xyz, r10.xyz);
      r11.y = r10.w * r10.w;
      r11.z = max(0.100000001, r11.x);
      r11.y = r11.z / r11.y;
      r11.y = -r11.y * r11.y + 1;
      r11.y = max(0, r11.y);
      r11.y = r11.y * r11.y;
      r9.w = r10.w * r9.w + r11.z;
      r9.w = 1 / r9.w;
      r9.w = r9.w * r11.y;
      r10.w = cmp(r9.w != 0.000000);
      [branch] if (r10.w != 0) {
        r11.y = _BT_LightBuffer[r8.w].val[16/4];
        r11.z = _BT_LightBuffer[r8.w].val[16/4+1];
        r11.w = _BT_LightBuffer[r8.w].val[16/4+2];
        r8.w = _BT_LightBuffer[r8.w].val[60/4];
        r10.w = rsqrt(r11.x);
        r12.xyz = r10.xyz * r10.www;
        r11.xyz = r11.yzw * r9.www;
        r9.w = dot(r1.yzw, -r12.xyz);
        r9.w = max(0, r9.w);
        r8.w = cmp(r8.w >= 0);
        r10.xyz = -r10.xyz * r10.www + -r4.xyz;
        r10.w = dot(r10.xyz, r10.xyz);
        r10.w = max(0.00100000005, r10.w);
        r10.w = rsqrt(r10.w);
        r10.xyz = r10.xyz * r10.www;
        r10.w = dot(r7.xyz, r10.xyz);
        r10.x = dot(-r12.xyz, r10.xyz);
        r10.xw = max(float2(0,0), r10.xw);
        r10.y = r9.w * r0.w + r5.w;
        r10.y = r10.y * r4.w;
        r10.y = r9.w * r1.x + r10.y;
        r10.y = 9.99999975e-006 + r10.y;
        r10.y = 0.5 / r10.y;
        r10.z = r10.w * r6.w + -r10.w;
        r10.z = r10.z * r10.w + 1;
        r10.z = r10.z * r10.z + 1.00000001e-007;
        r10.z = r7.w / r10.z;
        r10.w = 1 + -r9.w;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r11.w = r10.x + r10.x;
        r11.w = r11.w * r10.x;
        r11.w = r11.w * r5.w + r8.x;
        r11.w = -1 + r11.w;
        r10.w = r11.w * r10.w + 1;
        r11.w = r11.w * r8.z + 1;
        r10.w = r11.w * r10.w;
        r10.w = r10.w * r8.y;
        r10.y = r10.y * r10.z;
        r10.y = 3.14159274 * r10.y;
        r10.y = r10.y * r9.w;
        r10.y = max(0, r10.y);
        r9.w = r10.w * r9.w;
        r12.xyz = r11.xyz * r9.www;
        r10.yzw = r10.yyy * r11.xyz;
        r9.w = 1 + -r10.x;
        r10.x = r9.w * r9.w;
        r10.x = r10.x * r10.x;
        r9.w = r10.x * r9.w;
        r11.xyz = r2.xyz * r9.www + r6.xyz;
        r10.xyz = r11.xyz * r10.yzw;
        r8.w = r8.w ? 1.000000 : 0;
        r10.xyz = r10.xyz * r8.www;
        r10.xyz = r5.xyz * r12.xyz + r10.xyz;
      } else {
        r10.xyz = float3(0,0,0);
      }
      r9.xyz = r10.xyz + r9.xyz;
      r2.w = (int)r2.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r0.y = sqrt(_BT_ShadowMapParams.z);
    r0.z = _BT_MaxShadowDist * _BT_MaxShadowDist;
    r8.w = 0.5 * r0.z;
    r8.w = 1 / r8.w;
    r10.xz = _BT_ShadowMap_TexelSize.xx;
    r10.y = 0.142857149;
    r11.xz = _BT_ShadowMap_TexelSize.yy;
    r11.y = 0.142857149;
    r12.y = 7;
    r13.xyz = r9.xyz;
    r9.w = r2.w;
    [loop] while (true) {
      r10.w = cmp((int)r9.w >= (int)r0.x);
      [branch] if (r10.w != 0) break;
      r10.w = _BT_LinkListBuffer[r9.w].val[0/4];
      r14.x = _BT_LightBuffer[r10.w].val[0/4];
      r14.y = _BT_LightBuffer[r10.w].val[0/4+1];
      r14.z = _BT_LightBuffer[r10.w].val[0/4+2];
      r14.w = _BT_LightBuffer[r10.w].val[0/4+3];
      r11.w = _BT_LightBuffer[r10.w].val[32/4];
      r15.x = _BT_LightBuffer[r10.w].val[48/4];
      r15.y = _BT_LightBuffer[r10.w].val[48/4+1];
      r15.z = _BT_LightBuffer[r10.w].val[48/4+2];
      r15.w = _BT_LightBuffer[r10.w].val[48/4+3];
      r12.w = (uint)r10.w << 2;
      r11.w = frac(r11.w);
      r16.xyz = -r14.xyz + r3.xyz;
      r13.w = dot(r16.xyz, r16.xyz);
      r16.w = r14.w * r14.w;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][1], _BT_LightMatrix[(uint)(r12.w) / 4u][1][1], _BT_LightMatrix[(uint)(r12.w) / 4u][2][1], _BT_LightMatrix[(uint)(r12.w) / 4u][3][1]) * r3.yyyy;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][0], _BT_LightMatrix[(uint)(r12.w) / 4u][1][0], _BT_LightMatrix[(uint)(r12.w) / 4u][2][0], _BT_LightMatrix[(uint)(r12.w) / 4u][3][0]) * r3.xxxx + r17.xyzw;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][2], _BT_LightMatrix[(uint)(r12.w) / 4u][1][2], _BT_LightMatrix[(uint)(r12.w) / 4u][2][2], _BT_LightMatrix[(uint)(r12.w) / 4u][3][2]) * r3.zzzz + r17.xyzw;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][3], _BT_LightMatrix[(uint)(r12.w) / 4u][1][3], _BT_LightMatrix[(uint)(r12.w) / 4u][2][3], _BT_LightMatrix[(uint)(r12.w) / 4u][3][3]) * r3.wwww + r17.xyzw;
      r12.w = max(0.100000001, r13.w);
      r16.w = r12.w / r16.w;
      r16.w = -r16.w * r16.w + 1;
      r16.w = max(0, r16.w);
      r16.w = r16.w * r16.w;
      r11.w = r14.w * r11.w + r12.w;
      r11.w = 1 / r11.w;
      r11.w = r11.w * r16.w;
      r17.xyz = r17.xyz / r17.www;
      r12.w = cmp(0 >= r17.z);
      r18.xy = cmp(float2(1,1) < r17.xy);
      r12.w = (int)r12.w | (int)r18.x;
      r18.xz = cmp(r17.xy < float2(-1,-1));
      r12.w = (int)r12.w | (int)r18.x;
      r12.w = (int)r18.y | (int)r12.w;
      r12.w = (int)r18.z | (int)r12.w;
      [branch] if (r12.w == 0) {
        r12.w = r15.x / r15.y;
        r12.w = min(0.99000001, r12.w);
        r14.w = dot(r17.xy, r17.xy);
        r14.w = sqrt(r14.w);
        r14.w = min(1, r14.w);
        r12.w = -1 + r12.w;
        r14.w = -1 + r14.w;
        r12.w = 1 / r12.w;
        r12.w = r14.w * r12.w;
        r12.w = min(1, r12.w);
        r14.w = r12.w * -2 + 3;
        r12.w = r12.w * r12.w;
        r12.w = r14.w * r12.w;
        r14.w = cmp(r12.w != 0.000000);
        [branch] if (r14.w != 0) {
          r14.w = cmp(-1 < r15.z);
          [branch] if (r14.w != 0) {
            r15.xy = r17.xy * float2(0.5,0.5) + float2(0.5,0.5);
            r14.xyz = _WorldSpaceCameraPos.xyz + -r14.xyz;
            r14.x = dot(r14.xyz, r14.xyz);
            r14.y = r15.z / r0.y;
            r14.z = cmp(r14.y >= -r14.y);
            r14.w = frac(abs(r14.y));
            r14.z = r14.z ? r14.w : -r14.w;
            r14.z = r14.z * r0.y;
            r14.y = floor(r14.y);
            r17.xy = r14.zy / r0.yy;
            r14.yz = r15.xy / r0.yy;
            r14.yz = r14.yz + r17.xy;
            r14.w = r17.z + abs(r15.w);
            r14.yz = r14.yz * _BT_ShadowMap_TexelSize.zw + float2(0.5,0.5);
            r15.xy = floor(r14.yz);
            r15.xy = float2(-0.5,-0.5) + r15.xy;
            r14.yz = frac(r14.yz);
            r15.z = 3 * r14.y;
            r17.xy = -r14.yz * float2(3,3) + float2(4,4);
            r17.zw = r14.yz * float2(3,3) + float2(1,1);
            r18.xy = -r14.yz * float2(2,2) + float2(3,3);
            r18.xy = r18.xy / r17.xy;
            r18.xy = float2(-2,-2) + r18.xy;
            r19.xy = float2(3,3) + r14.yz;
            r19.xy = _BT_ShadowMap_TexelSize.xy * r19.xy;
            r14.yz = r14.yz / r17.zw;
            r14.yz = float2(2,2) + r14.yz;
            r18.z = r19.x;
            r18.w = r14.y;
            r20.xyz = r18.xzw * r10.xyz;
            r19.z = r18.y;
            r19.w = r14.z;
            r18.xyw = r19.zyw * r11.xyz;
            r12.xz = r15.zz * float2(-1,1) + float2(4,1);
            r17.xyz = r17.yyy * r12.xyz;
            r20.w = r18.x;
            r19.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r20.xwyw;
            r14.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.xy, r14.w).x;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.zw, r14.w).x;
            r14.z = r17.y * r14.z;
            r14.y = r17.x * r14.y + r14.z;
            r17.xy = r15.xy * _BT_ShadowMap_TexelSize.xy + r20.zw;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r17.xy, r14.w).x;
            r14.y = r17.z * r14.z + r14.y;
            r17.xy = float2(7,7) * r12.xz;
            r18.z = r20.x;
            r19.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r18.zyzw;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.xy, r14.w).x;
            r14.y = r17.x * r14.z + r14.y;
            r18.xz = r20.yz;
            r20.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r18.xyzy;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.xy, r14.w).x;
            r14.y = r14.z * 49 + r14.y;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.zw, r14.w).x;
            r14.y = r17.y * r14.z + r14.y;
            r17.xyz = r17.www * r12.xyz;
            r12.x = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.zw, r14.w).x;
            r12.x = r17.x * r12.x + r14.y;
            r18.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r18.xwzw;
            r12.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r18.xy, r14.w).x;
            r12.x = r17.y * r12.z + r12.x;
            r12.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r18.zw, r14.w).x;
            r12.x = r17.z * r12.z + r12.x;
            r12.z = 0.0069444445 * r12.x;
            r14.x = -r0.z * 0.5 + r14.x;
            r14.x = saturate(r14.x * r8.w);
            r14.y = r14.x * -2 + 3;
            r14.x = r14.x * r14.x;
            r14.x = r14.y * r14.x;
            r12.x = -r12.x * 0.0069444445 + 1;
            r12.x = r14.x * r12.x + r12.z;
            r12.w = r12.w * r12.x;
          }
        } else {
          r12.w = 0;
        }
      } else {
        r12.w = 0;
      }
      r11.w = r12.w * r11.w;
      r12.x = cmp(r11.w != 0.000000);
      [branch] if (r12.x != 0) {
        r12.x = _BT_LightBuffer[r10.w].val[16/4];
        r12.z = _BT_LightBuffer[r10.w].val[16/4+1];
        r12.w = _BT_LightBuffer[r10.w].val[16/4+2];
        r10.w = rsqrt(r13.w);
        r14.xyz = r16.xyz * r10.www;
        r12.xzw = r12.xzw * r11.www;
        r11.w = dot(r1.yzw, -r14.xyz);
        r11.w = max(0, r11.w);
        r13.w = cmp(r15.w >= 0);
        r15.xyz = -r16.xyz * r10.www + -r4.xyz;
        r10.w = dot(r15.xyz, r15.xyz);
        r10.w = max(0.00100000005, r10.w);
        r10.w = rsqrt(r10.w);
        r15.xyz = r15.xyz * r10.www;
        r10.w = dot(r7.xyz, r15.xyz);
        r10.w = max(0, r10.w);
        r14.x = dot(-r14.xyz, r15.xyz);
        r14.x = max(0, r14.x);
        r14.y = r11.w * r0.w + r5.w;
        r14.y = r14.y * r4.w;
        r14.y = r11.w * r1.x + r14.y;
        r14.y = 9.99999975e-006 + r14.y;
        r14.y = 0.5 / r14.y;
        r14.z = r10.w * r6.w + -r10.w;
        r10.w = r14.z * r10.w + 1;
        r10.w = r10.w * r10.w + 1.00000001e-007;
        r10.w = r7.w / r10.w;
        r14.z = 1 + -r11.w;
        r14.w = r14.z * r14.z;
        r14.w = r14.w * r14.w;
        r14.z = r14.w * r14.z;
        r14.w = r14.x + r14.x;
        r14.w = r14.w * r14.x;
        r14.w = r14.w * r5.w + r8.x;
        r14.w = -1 + r14.w;
        r14.z = r14.w * r14.z + 1;
        r14.w = r14.w * r8.z + 1;
        r14.z = r14.z * r14.w;
        r14.z = r14.z * r8.y;
        r10.w = r14.y * r10.w;
        r10.w = 3.14159274 * r10.w;
        r10.w = r10.w * r11.w;
        r10.w = max(0, r10.w);
        r11.w = r14.z * r11.w;
        r14.yzw = r12.xzw * r11.www;
        r12.xzw = r10.www * r12.xzw;
        r10.w = 1 + -r14.x;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r15.xyz = r2.xyz * r10.www + r6.xyz;
        r12.xzw = r15.xyz * r12.xzw;
        r10.w = r13.w ? 1.000000 : 0;
        r12.xzw = r12.xzw * r10.www;
        r12.xzw = r5.xyz * r14.yzw + r12.xzw;
      } else {
        r12.xzw = float3(0,0,0);
      }
      r13.xyz = r13.xyz + r12.xzw;
      r9.w = (int)r9.w + 1;
    }
    r0.xyz = float3(8,8,8) * r13.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps d3422d72c196fa5b: 1 retail keyword combination(s)
void ps_d3422d72c196fa5b_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyzw = _BT_ListEntries.Load(r0.xywz).xyzw;
  r1.y = cmp((int)r0.x >= 0);
  [branch] if (r1.y != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r1.yz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xy = cmp(r3.ww == float2(0.666666687,0.333333343));
    r1.w = (int)r4.y | (int)r4.x;
    r4.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r5.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,1) + r2.xyzw;
    r5.xyz = r1.yyy * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r1.y = -r1.y * 0.959999979 + 0.959999979;
    r6.xyz = r2.xyz * r1.yyy;
    r4.w = 0.0195999984;
    r6.w = r5.x;
    r4.xyzw = r1.wwww ? r4.xyzw : r6.xyzw;
    r2.yz = r1.ww ? float2(0.0195999984,0.0195999984) : r5.yz;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r1.y = dot(r3.xyz, r3.xyz);
    r1.y = rsqrt(r1.y);
    r3.xyz = r3.xyz * r1.yyy;
    r5.z = 1 + -r1.x;
    r5.xy = v0.zw;
    r1.xyw = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r1.yyyy;
    r6.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r1.xxxx + r6.xyzw;
    r6.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r1.wwww + r6.xyzw;
    r6.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r6.xyzw;
    r1.xyw = r6.xyz / r6.www;
    r6.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r1.yyyy;
    r6.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r1.xxxx + r6.xyzw;
    r6.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r1.wwww + r6.xyzw;
    r6.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r6.xyzw;
    r1.xyw = -_WorldSpaceCameraPos.xyz + r6.xyz;
    r5.x = dot(r1.xyw, r1.xyw);
    r5.x = rsqrt(r5.x);
    r7.xyz = r5.xxx * r1.xyw;
    r3.w = cmp(0 < r3.w);
    r5.y = 0.5 * r5.w;
    r8.xyz = r5.yyy * r4.xyz;
    r2.x = r4.w;
    r5.yzw = r2.xyz * r2.www;
    r8.w = r5.y;
    r4.xyzw = r3.wwww ? r8.xyzw : r4.xyzw;
    r2.yz = r3.ww ? r5.zw : r2.yz;
    r3.w = dot(r3.xyz, -r7.xyz);
    r5.y = max(0, r3.w);
    r5.z = min(1, r5.y);
    r0.y = (int)r0.y + (int)r0.x;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.x = r4.w;
    r8.xyz = r2.xyz * r2.www;
    r1.z = 1 + -r1.z;
    r4.w = r1.z * r1.z;
    r5.w = cmp(r3.w < 0);
    r7.w = 9.99999975e-006 + -r3.w;
    r9.xyz = -r7.xyz * r7.www + r3.xyz;
    r9.xyz = r5.www ? r9.xyz : r3.xyz;
    r5.w = -r1.z * r1.z + 1;
    r7.w = r5.z * r5.w + r4.w;
    r8.w = r4.w * r4.w;
    r9.w = 0.318309873 * r8.w;
    r10.x = 0.5 * r4.w;
    r10.y = r4.w * -0.337748349 + 1;
    r10.z = 1 + -r5.z;
    r10.w = r10.z * r10.z;
    r10.w = r10.w * r10.w;
    r10.z = r10.w * r10.z;
    r11.xyz = -r2.xyz * r2.www + float3(1,1,1);
    r12.xyz = float3(0,0,0);
    r2.w = r0.x;
    [loop] while (true) {
      r10.w = cmp((int)r2.w >= (int)r0.y);
      [branch] if (r10.w != 0) break;
      r10.w = _BT_LinkListBuffer[r2.w].val[0/4];
      r13.x = _BT_LightBuffer[r10.w].val[0/4];
      r13.y = _BT_LightBuffer[r10.w].val[0/4+1];
      r13.z = _BT_LightBuffer[r10.w].val[0/4+2];
      r13.w = _BT_LightBuffer[r10.w].val[0/4+3];
      r11.w = _BT_LightBuffer[r10.w].val[32/4];
      r13.xyz = -r13.xyz + r6.xyz;
      r12.w = dot(r13.xyz, r13.xyz);
      r14.x = r13.w * r13.w;
      r14.y = max(0.100000001, r12.w);
      r14.x = r14.y / r14.x;
      r14.x = -r14.x * r14.x + 1;
      r14.x = max(0, r14.x);
      r14.x = r14.x * r14.x;
      r11.w = r13.w * r11.w + r14.y;
      r11.w = 1 / r11.w;
      r11.w = r11.w * r14.x;
      r13.w = cmp(r11.w != 0.000000);
      [branch] if (r13.w != 0) {
        r14.x = _BT_LightBuffer[r10.w].val[16/4];
        r14.y = _BT_LightBuffer[r10.w].val[16/4+1];
        r14.z = _BT_LightBuffer[r10.w].val[16/4+2];
        r10.w = _BT_LightBuffer[r10.w].val[60/4];
        r12.w = rsqrt(r12.w);
        r15.xyz = r13.xyz * r12.www;
        r14.xyz = r14.xyz * r11.www;
        r11.w = dot(r3.xyz, -r15.xyz);
        r11.w = max(0, r11.w);
        r10.w = cmp(r10.w >= 0);
        r13.xyz = -r13.xyz * r12.www + -r7.xyz;
        r12.w = dot(r13.xyz, r13.xyz);
        r12.w = max(0.00100000005, r12.w);
        r12.w = rsqrt(r12.w);
        r13.xyz = r13.xyz * r12.www;
        r12.w = dot(r9.xyz, r13.xyz);
        r12.w = max(0, r12.w);
        r13.x = dot(-r15.xyz, r13.xyz);
        r13.x = max(0, r13.x);
        r13.y = r11.w * r5.w + r4.w;
        r13.y = r13.y * r5.z;
        r13.y = r11.w * r7.w + r13.y;
        r13.y = 9.99999975e-006 + r13.y;
        r13.y = 0.5 / r13.y;
        r13.z = r12.w * r8.w + -r12.w;
        r12.w = r13.z * r12.w + 1;
        r12.w = r12.w * r12.w + 1.00000001e-007;
        r12.w = r9.w / r12.w;
        r13.z = 1 + -r11.w;
        r13.w = r13.z * r13.z;
        r13.w = r13.w * r13.w;
        r13.z = r13.w * r13.z;
        r13.w = r13.x + r13.x;
        r13.w = r13.w * r13.x;
        r13.w = r13.w * r4.w + r10.x;
        r13.w = -1 + r13.w;
        r13.z = r13.w * r13.z + 1;
        r13.w = r13.w * r10.z + 1;
        r13.z = r13.z * r13.w;
        r13.z = r13.z * r10.y;
        r12.w = r13.y * r12.w;
        r12.w = r12.w * r11.w;
        r12.w = 3.14159274 * r12.w;
        r12.w = max(0, r12.w);
        r11.w = r13.z * r11.w;
        r13.yzw = r14.xyz * r11.www;
        r14.xyz = r12.www * r14.xyz;
        r11.w = 1 + -r13.x;
        r12.w = r11.w * r11.w;
        r12.w = r12.w * r12.w;
        r11.w = r12.w * r11.w;
        r15.xyz = r11.xyz * r11.www + r8.xyz;
        r14.xyz = r15.xyz * r14.xyz;
        r10.w = r10.w ? 1.000000 : 0;
        r14.xyz = r14.xyz * r10.www;
        r13.xyz = r4.xyz * r13.yzw + r14.xyz;
      } else {
        r13.xyz = float3(0,0,0);
      }
      r12.xyz = r13.xyz + r12.xyz;
      r2.w = (int)r2.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r0.y = sqrt(_BT_ShadowMapParams.z);
    r0.z = _BT_MaxShadowDist * _BT_MaxShadowDist;
    r10.w = 0.5 * r0.z;
    r10.w = 1 / r10.w;
    r13.xz = _BT_ShadowMap_TexelSize.xx;
    r13.y = 0.142857149;
    r14.xz = _BT_ShadowMap_TexelSize.yy;
    r14.y = 0.142857149;
    r15.y = 7;
    r16.xyz = r12.xyz;
    r11.w = r2.w;
    [loop] while (true) {
      r12.w = cmp((int)r11.w >= (int)r0.x);
      [branch] if (r12.w != 0) break;
      r12.w = _BT_LinkListBuffer[r11.w].val[0/4];
      r17.x = _BT_LightBuffer[r12.w].val[0/4];
      r17.y = _BT_LightBuffer[r12.w].val[0/4+1];
      r17.z = _BT_LightBuffer[r12.w].val[0/4+2];
      r17.w = _BT_LightBuffer[r12.w].val[0/4+3];
      r13.w = _BT_LightBuffer[r12.w].val[32/4];
      r18.x = _BT_LightBuffer[r12.w].val[48/4];
      r18.y = _BT_LightBuffer[r12.w].val[48/4+1];
      r18.z = _BT_LightBuffer[r12.w].val[48/4+2];
      r18.w = _BT_LightBuffer[r12.w].val[48/4+3];
      r14.w = (uint)r12.w << 2;
      r13.w = frac(r13.w);
      r19.xyz = -r17.xyz + r6.xyz;
      r15.w = dot(r19.xyz, r19.xyz);
      r16.w = r17.w * r17.w;
      r20.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][1], _BT_LightMatrix[(uint)(r14.w) / 4u][1][1], _BT_LightMatrix[(uint)(r14.w) / 4u][2][1], _BT_LightMatrix[(uint)(r14.w) / 4u][3][1]) * r6.yyyy;
      r20.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][0], _BT_LightMatrix[(uint)(r14.w) / 4u][1][0], _BT_LightMatrix[(uint)(r14.w) / 4u][2][0], _BT_LightMatrix[(uint)(r14.w) / 4u][3][0]) * r6.xxxx + r20.xyzw;
      r20.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][2], _BT_LightMatrix[(uint)(r14.w) / 4u][1][2], _BT_LightMatrix[(uint)(r14.w) / 4u][2][2], _BT_LightMatrix[(uint)(r14.w) / 4u][3][2]) * r6.zzzz + r20.xyzw;
      r20.xyzw = float4(_BT_LightMatrix[(uint)(r14.w) / 4u][0][3], _BT_LightMatrix[(uint)(r14.w) / 4u][1][3], _BT_LightMatrix[(uint)(r14.w) / 4u][2][3], _BT_LightMatrix[(uint)(r14.w) / 4u][3][3]) * r6.wwww + r20.xyzw;
      r14.w = max(0.100000001, r15.w);
      r16.w = r14.w / r16.w;
      r16.w = -r16.w * r16.w + 1;
      r16.w = max(0, r16.w);
      r16.w = r16.w * r16.w;
      r13.w = r17.w * r13.w + r14.w;
      r13.w = 1 / r13.w;
      r13.w = r13.w * r16.w;
      r20.xyz = r20.xyz / r20.www;
      r14.w = cmp(0 >= r20.z);
      r21.xy = cmp(float2(1,1) < r20.xy);
      r14.w = (int)r14.w | (int)r21.x;
      r21.xz = cmp(r20.xy < float2(-1,-1));
      r14.w = (int)r14.w | (int)r21.x;
      r14.w = (int)r21.y | (int)r14.w;
      r14.w = (int)r21.z | (int)r14.w;
      [branch] if (r14.w == 0) {
        r14.w = r18.x / r18.y;
        r14.w = min(0.99000001, r14.w);
        r16.w = dot(r20.xy, r20.xy);
        r16.w = sqrt(r16.w);
        r16.w = min(1, r16.w);
        r14.w = -1 + r14.w;
        r16.w = -1 + r16.w;
        r14.w = 1 / r14.w;
        r14.w = r16.w * r14.w;
        r14.w = min(1, r14.w);
        r16.w = r14.w * -2 + 3;
        r14.w = r14.w * r14.w;
        r14.w = r16.w * r14.w;
        r16.w = cmp(r14.w != 0.000000);
        [branch] if (r16.w != 0) {
          r16.w = cmp(-1 < r18.z);
          [branch] if (r16.w != 0) {
            r18.xy = r20.xy * float2(0.5,0.5) + float2(0.5,0.5);
            r17.xyz = _WorldSpaceCameraPos.xyz + -r17.xyz;
            r16.w = dot(r17.xyz, r17.xyz);
            r17.x = r18.z / r0.y;
            r17.y = cmp(r17.x >= -r17.x);
            r17.z = frac(abs(r17.x));
            r17.y = r17.y ? r17.z : -r17.z;
            r17.y = r17.y * r0.y;
            r17.x = floor(r17.x);
            r20.xy = r17.yx / r0.yy;
            r17.xy = r18.xy / r0.yy;
            r17.xy = r17.xy + r20.xy;
            r17.z = r20.z + abs(r18.w);
            r17.xy = r17.xy * _BT_ShadowMap_TexelSize.zw + float2(0.5,0.5);
            r18.xy = floor(r17.xy);
            r18.xy = float2(-0.5,-0.5) + r18.xy;
            r17.xy = frac(r17.xy);
            r17.w = 3 * r17.x;
            r20.xy = -r17.xy * float2(3,3) + float2(4,4);
            r20.zw = r17.xy * float2(3,3) + float2(1,1);
            r21.xy = -r17.xy * float2(2,2) + float2(3,3);
            r21.xy = r21.xy / r20.xy;
            r21.xy = float2(-2,-2) + r21.xy;
            r22.xy = float2(3,3) + r17.xy;
            r22.xy = _BT_ShadowMap_TexelSize.xy * r22.xy;
            r17.xy = r17.xy / r20.zw;
            r17.xy = float2(2,2) + r17.xy;
            r21.z = r22.x;
            r21.w = r17.x;
            r23.xyz = r21.xzw * r13.xyz;
            r22.z = r21.y;
            r22.w = r17.y;
            r21.xyw = r22.zyw * r14.xyz;
            r15.xz = r17.ww * float2(-1,1) + float2(4,1);
            r17.xyw = r20.yyy * r15.xyz;
            r23.w = r21.x;
            r22.xyzw = r18.xyxy * _BT_ShadowMap_TexelSize.xyxy + r23.xwyw;
            r18.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r22.xy, r17.z).x;
            r19.w = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r22.zw, r17.z).x;
            r17.y = r19.w * r17.y;
            r17.x = r17.x * r18.z + r17.y;
            r20.xy = r18.xy * _BT_ShadowMap_TexelSize.xy + r23.zw;
            r17.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.xy, r17.z).x;
            r17.x = r17.w * r17.y + r17.x;
            r17.yw = float2(7,7) * r15.xz;
            r21.z = r23.x;
            r22.xyzw = r18.xyxy * _BT_ShadowMap_TexelSize.xyxy + r21.zyzw;
            r18.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r22.xy, r17.z).x;
            r17.x = r17.y * r18.z + r17.x;
            r21.xz = r23.yz;
            r23.xyzw = r18.xyxy * _BT_ShadowMap_TexelSize.xyxy + r21.xyzy;
            r17.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r23.xy, r17.z).x;
            r17.x = r17.y * 49 + r17.x;
            r17.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r23.zw, r17.z).x;
            r17.x = r17.w * r17.y + r17.x;
            r20.xyz = r20.www * r15.xyz;
            r15.x = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r22.zw, r17.z).x;
            r15.x = r20.x * r15.x + r17.x;
            r21.xyzw = r18.xyxy * _BT_ShadowMap_TexelSize.xyxy + r21.xwzw;
            r15.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.xy, r17.z).x;
            r15.x = r20.y * r15.z + r15.x;
            r15.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r21.zw, r17.z).x;
            r15.x = r20.z * r15.z + r15.x;
            r15.z = 0.0069444445 * r15.x;
            r16.w = -r0.z * 0.5 + r16.w;
            r16.w = saturate(r16.w * r10.w);
            r17.x = r16.w * -2 + 3;
            r16.w = r16.w * r16.w;
            r16.w = r17.x * r16.w;
            r15.x = -r15.x * 0.0069444445 + 1;
            r15.x = r16.w * r15.x + r15.z;
            r14.w = r15.x * r14.w;
          }
        } else {
          r14.w = 0;
        }
      } else {
        r14.w = 0;
      }
      r13.w = r14.w * r13.w;
      r14.w = cmp(r13.w != 0.000000);
      [branch] if (r14.w != 0) {
        r17.x = _BT_LightBuffer[r12.w].val[16/4];
        r17.y = _BT_LightBuffer[r12.w].val[16/4+1];
        r17.z = _BT_LightBuffer[r12.w].val[16/4+2];
        r12.w = rsqrt(r15.w);
        r15.xzw = r19.xyz * r12.www;
        r17.xyz = r17.xyz * r13.www;
        r13.w = dot(r3.xyz, -r15.xzw);
        r13.w = max(0, r13.w);
        r14.w = cmp(r18.w >= 0);
        r18.xyz = -r19.xyz * r12.www + -r7.xyz;
        r12.w = dot(r18.xyz, r18.xyz);
        r12.w = max(0.00100000005, r12.w);
        r12.w = rsqrt(r12.w);
        r18.xyz = r18.xyz * r12.www;
        r12.w = dot(r9.xyz, r18.xyz);
        r12.w = max(0, r12.w);
        r15.x = dot(-r15.xzw, r18.xyz);
        r15.x = max(0, r15.x);
        r15.z = r13.w * r5.w + r4.w;
        r15.z = r15.z * r5.z;
        r15.z = r13.w * r7.w + r15.z;
        r15.z = 9.99999975e-006 + r15.z;
        r15.z = 0.5 / r15.z;
        r15.w = r12.w * r8.w + -r12.w;
        r12.w = r15.w * r12.w + 1;
        r12.w = r12.w * r12.w + 1.00000001e-007;
        r12.w = r9.w / r12.w;
        r15.w = 1 + -r13.w;
        r16.w = r15.w * r15.w;
        r16.w = r16.w * r16.w;
        r15.w = r16.w * r15.w;
        r16.w = r15.x + r15.x;
        r16.w = r16.w * r15.x;
        r16.w = r16.w * r4.w + r10.x;
        r16.w = -1 + r16.w;
        r15.w = r16.w * r15.w + 1;
        r16.w = r16.w * r10.z + 1;
        r15.w = r16.w * r15.w;
        r15.w = r15.w * r10.y;
        r12.w = r15.z * r12.w;
        r12.w = r12.w * r13.w;
        r12.w = 3.14159274 * r12.w;
        r12.w = max(0, r12.w);
        r13.w = r15.w * r13.w;
        r18.xyz = r17.xyz * r13.www;
        r17.xyz = r12.www * r17.xyz;
        r12.w = 1 + -r15.x;
        r13.w = r12.w * r12.w;
        r13.w = r13.w * r13.w;
        r12.w = r13.w * r12.w;
        r15.xzw = r11.xyz * r12.www + r8.xyz;
        r15.xzw = r17.xyz * r15.xzw;
        r12.w = r14.w ? 1.000000 : 0;
        r15.xzw = r15.xzw * r12.www;
        r15.xzw = r4.xyz * r18.xyz + r15.xzw;
      } else {
        r15.xzw = float3(0,0,0);
      }
      r16.xyz = r16.xyz + r15.xzw;
      r11.w = (int)r11.w + 1;
    }
    r0.x = (int)r0.w + (int)r0.x;
    r0.yzw = float3(25,25,25) * r4.xyz;
    r2.w = r3.w + r3.w;
    r4.xyz = r3.xyz * -r2.www + -r7.xyz;
    r2.w = -r4.w * 0.5 + 1;
    r3.w = r5.y * r2.w + r10.x;
    r4.w = r4.w * r4.w + -1;
    r5.z = r8.w * r8.w;
    r5.y = 1 + -r5.y;
    r5.w = r5.y * r5.y;
    r5.w = r5.w * r5.w;
    r5.y = r5.w * r5.y;
    r7.xyz = float3(1,1,1) + -r2.xyz;
    r8.xyz = r16.xyz;
    r5.w = r11.w;
    [loop] while (true) {
      r6.w = cmp((int)r5.w >= (int)r0.x);
      [branch] if (r6.w != 0) break;
      r6.w = _BT_LinkListBuffer[r5.w].val[0/4];
      r9.x = _BT_LightBuffer[r6.w].val[0/4];
      r9.y = _BT_LightBuffer[r6.w].val[0/4+1];
      r9.z = _BT_LightBuffer[r6.w].val[0/4+2];
      r9.w = _BT_LightBuffer[r6.w].val[0/4+3];
      r10.y = _BT_LightBuffer[r6.w].val[16/4];
      r10.z = _BT_LightBuffer[r6.w].val[16/4+1];
      r10.w = _BT_LightBuffer[r6.w].val[16/4+2];
      r7.w = _BT_LightBuffer[r6.w].val[32/4];
      r11.x = _BT_LightBuffer[r6.w].val[48/4];
      r11.y = _BT_LightBuffer[r6.w].val[48/4+1];
      r11.z = _BT_LightBuffer[r6.w].val[48/4+2];
      r6.w = r9.w * r9.w;
      r6.w = 1 / r6.w;
      r11.xyz = r11.xyz * r7.www + r9.xyz;
      r9.xyz = r9.xyz + -r6.xyz;
      r11.xyz = r11.xyz + -r6.xyz;
      r7.w = dot(r9.xyz, r9.xyz);
      r8.w = sqrt(r7.w);
      r9.w = dot(r11.xyz, r11.xyz);
      r9.w = sqrt(r9.w);
      r12.x = dot(r9.xyz, r3.xyz);
      r12.y = r8.w + r8.w;
      r12.x = r12.x / r12.y;
      r12.y = dot(r11.xyz, r3.xyz);
      r12.z = r9.w + r9.w;
      r12.y = r12.y / r12.z;
      r12.x = saturate(r12.x + r12.y);
      r12.yzw = r11.xyz + -r9.xyz;
      r13.x = dot(r4.xyz, r9.xyz);
      r13.y = dot(r4.xyz, r12.yzw);
      r13.z = dot(r9.xyz, r12.yzw);
      r13.w = dot(r12.yzw, r12.yzw);
      r7.w = r13.y * r7.w;
      r7.w = r13.z * r13.x + -r7.w;
      r13.x = r13.w * r13.x;
      r13.x = r13.z * r13.y + -r13.x;
      r7.w = saturate(r7.w / r13.x);
      r13.xyz = r12.zwy * r9.zxy;
      r13.xyz = r9.yzx * r12.wyz + -r13.xyz;
      r14.xyz = r12.wyz * r4.yzx;
      r14.xyz = r12.zwy * r4.zxy + -r14.xyz;
      r13.x = dot(r13.xyz, r14.xyz);
      r13.y = 1 + -r7.w;
      r13.x = cmp(r13.x >= 0);
      r13.x = r13.x ? 1.000000 : 0;
      r7.w = -r13.y + r7.w;
      r7.w = r13.x * r7.w + r13.y;
      r12.yzw = r12.yzw * r7.www + r9.xyz;
      r7.w = dot(r12.yzw, r4.xyz);
      r13.xyz = r7.www * r4.xyz + -r12.yzw;
      r7.w = dot(r13.xyz, r13.xyz);
      r7.w = sqrt(r7.w);
      r7.w = 0.100000001 / r7.w;
      r7.w = min(1, r7.w);
      r12.yzw = r13.xyz * r7.www + r12.yzw;
      r7.w = dot(r12.yzw, r12.yzw);
      r7.w = sqrt(r7.w);
      r12.yzw = r12.yzw / r7.www;
      r9.x = dot(r9.xyz, r11.xyz);
      r8.w = r8.w * r9.w + r9.x;
      r8.w = 0.5 * r8.w;
      r6.w = r8.w * r6.w;
      r6.w = sqrt(r6.w);
      r8.w = r6.w * 4 + 1;
      r8.w = r8.w * r8.w;
      r8.w = 1 / r8.w;
      r8.w = -0.0399999991 + r8.w;
      r8.w = 1.04166675 * r8.w;
      r6.w = cmp(r6.w >= 1);
      r6.w = r6.w ? 0 : r8.w;
      r9.xyz = r10.yzw * r6.www;
      r10.yzw = -r1.xyw * r5.xxx + r12.yzw;
      r6.w = dot(r10.yzw, r10.yzw);
      r6.w = max(0.00100000005, r6.w);
      r6.w = rsqrt(r6.w);
      r10.yzw = r10.yzw * r6.www;
      r6.w = dot(r3.xyz, r10.yzw);
      r6.w = max(0, r6.w);
      r8.w = dot(r12.yzw, r10.yzw);
      r8.w = max(0, r8.w);
      r9.w = r12.x * r2.w + r10.x;
      r9.w = r9.w * r3.w + 9.99999975e-006;
      r9.w = 1 / r9.w;
      r6.w = r6.w * r6.w;
      r6.w = r6.w * r4.w + 1;
      r6.w = max(9.99999997e-007, r6.w);
      r7.w = r7.w + r7.w;
      r7.w = 0.100000001 / r7.w;
      r7.w = r1.z * r1.z + r7.w;
      r7.w = min(1, r7.w);
      r7.w = r7.w * r7.w;
      r10.y = 3.14159274 * r6.w;
      r6.w = r10.y * r6.w;
      r6.w = r6.w * r7.w;
      r6.w = r5.z / r6.w;
      r7.w = 1 + -r12.x;
      r10.y = r7.w * r7.w;
      r10.y = r10.y * r10.y;
      r7.w = r10.y * r7.w;
      r10.y = r8.w * r8.w;
      r10.y = dot(r10.yy, r1.zz);
      r10.y = -0.5 + r10.y;
      r7.w = r10.y * r7.w + 1;
      r10.y = r10.y * r5.y + 1;
      r7.w = r10.y * r7.w;
      r6.w = r9.w * r6.w;
      r6.w = 0.785398185 * r6.w;
      r6.w = r6.w * r12.x;
      r6.w = max(0, r6.w);
      r7.w = r7.w * r12.x;
      r10.yzw = r9.xyz * r7.www;
      r9.xyz = r6.www * r9.xyz;
      r6.w = 1 + -r8.w;
      r7.w = r6.w * r6.w;
      r7.w = r7.w * r7.w;
      r6.w = r7.w * r6.w;
      r11.xyz = r7.xyz * r6.www + r2.xyz;
      r9.xyz = r11.xyz * r9.xyz;
      r9.xyz = r0.yzw * r10.yzw + r9.xyz;
      r8.xyz = r9.xyz + r8.xyz;
      r5.w = (int)r5.w + 1;
    }
    r0.xyz = float3(8,8,8) * r8.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


// ps dfb459c1e199e04f: 1 retail keyword combination(s)
void ps_dfb459c1e199e04f_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _BTScreenWidth * v0.x;
  r0.y = _BTScreenHeight * v0.y;
  r0.xy = r0.xy / _BTLightingTileSize.xx;
  r0.xy = floor(r0.xy);
  r0.xy = (uint2)r0.xy;
  r0.z = 0;
  r1.x = _TileID.Load(r0.xyz).x;
  r1.x = cmp(r1.x != _MatIDMask);
  [branch] if (r1.x != 0) {
    clip(-1 != 0 ? -1 : 1);
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r1.y = _ZBufferParams.x * r1.x + _ZBufferParams.y;
  r1.y = 1 / r1.y;
  r1.z = cmp(0.999000013 < r1.y);
  [branch] if (r1.z != 0) {
    o0.xyzw = float4(0,0,0,0);
    return;
  }
  r1.z = cmp(r1.y >= _BT_ClusterBounds[1]);
  [branch] if (r1.z != 0) {
    r1.z = cmp(r1.y >= _BT_ClusterBounds[2]);
    [branch] if (r1.z != 0) {
      r1.z = cmp(r1.y >= _BT_ClusterBounds[3]);
      [branch] if (r1.z != 0) {
        r1.z = cmp(r1.y < _BT_ClusterBounds[4]);
        r1.w = cmp(r1.y < _BT_ClusterBounds[5]);
        r2.x = cmp(r1.y < _BT_ClusterBounds[6]);
        r1.y = cmp(r1.y < _BT_ClusterBounds[7]);
        r1.y = r1.y ? 6 : 7;
        r1.y = r2.x ? 5 : r1.y;
        r1.y = r1.w ? 4 : r1.y;
        r0.w = r1.z ? 3 : r1.y;
      } else {
        r0.w = 2;
      }
    } else {
      r0.w = 1;
    }
  } else {
    r0.w = 0;
  }
  r0.xyz = _BT_ListEntries.Load(r0.xywz).xyz;
  r0.w = cmp((int)r0.x >= 0);
  [branch] if (r0.w != 0) {
    r2.xyzw = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0, v0.xy).xyzw;
    r1.yz = _CameraGBufferTexture1.Sample(sampler_CameraGBufferTexture1, v0.xy).xz;
    r3.xyzw = _CameraGBufferTexture2.Sample(sampler_CameraGBufferTexture2, v0.xy).xyzw;
    r4.xy = cmp(r3.ww == float2(0.666666687,0.333333343));
    r0.w = (int)r4.y | (int)r4.x;
    r4.xyz = float3(0.980400026,0.980400026,0.980400026) * r2.xyz;
    r5.xyzw = float4(-0.0399999991,-0.0399999991,-0.0399999991,1) + r2.xyzw;
    r5.xyz = r1.yyy * r5.xyz + float3(0.0399999991,0.0399999991,0.0399999991);
    r1.y = -r1.y * 0.959999979 + 0.959999979;
    r6.xyz = r2.xyz * r1.yyy;
    r4.w = 0.0195999984;
    r6.w = r5.x;
    r4.xyzw = r0.wwww ? r4.xyzw : r6.xyzw;
    r2.yz = r0.ww ? float2(0.0195999984,0.0195999984) : r5.yz;
    r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r0.w = dot(r3.xyz, r3.xyz);
    r0.w = rsqrt(r0.w);
    r3.xyz = r3.xyz * r0.www;
    r5.z = 1 + -r1.x;
    r5.xy = v0.zw;
    r1.xyw = r5.xyz * float3(2,2,2) + float3(-1,-1,-1);
    r6.xyzw = float4(unity_CameraInvProjection[0][1], unity_CameraInvProjection[1][1], unity_CameraInvProjection[2][1], unity_CameraInvProjection[3][1]) * r1.yyyy;
    r6.xyzw = float4(unity_CameraInvProjection[0][0], unity_CameraInvProjection[1][0], unity_CameraInvProjection[2][0], unity_CameraInvProjection[3][0]) * r1.xxxx + r6.xyzw;
    r6.xyzw = float4(unity_CameraInvProjection[0][2], unity_CameraInvProjection[1][2], unity_CameraInvProjection[2][2], unity_CameraInvProjection[3][2]) * r1.wwww + r6.xyzw;
    r6.xyzw = float4(unity_CameraInvProjection[0][3], unity_CameraInvProjection[1][3], unity_CameraInvProjection[2][3], unity_CameraInvProjection[3][3]) + r6.xyzw;
    r1.xyw = r6.xyz / r6.www;
    r6.xyzw = float4(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1], unity_CameraToWorld[3][1]) * r1.yyyy;
    r6.xyzw = float4(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0], unity_CameraToWorld[3][0]) * r1.xxxx + r6.xyzw;
    r6.xyzw = float4(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2], unity_CameraToWorld[3][2]) * -r1.wwww + r6.xyzw;
    r6.xyzw = float4(unity_CameraToWorld[0][3], unity_CameraToWorld[1][3], unity_CameraToWorld[2][3], unity_CameraToWorld[3][3]) + r6.xyzw;
    r1.xyw = -_WorldSpaceCameraPos.xyz + r6.xyz;
    r0.w = dot(r1.xyw, r1.xyw);
    r0.w = rsqrt(r0.w);
    r1.xyw = r1.xyw * r0.www;
    r0.w = cmp(0 < r3.w);
    r3.w = 0.5 * r5.w;
    r5.xyz = r4.xyz * r3.www;
    r2.x = r4.w;
    r7.xyz = r2.xyz * r2.www;
    r5.w = r7.x;
    r4.xyzw = r0.wwww ? r5.xyzw : r4.xyzw;
    r2.yz = r0.ww ? r7.yz : r2.yz;
    r0.w = dot(r3.xyz, -r1.xyw);
    r3.w = saturate(r0.w);
    r0.y = (int)r0.y + (int)r0.x;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r2.w;
    r2.x = r4.w;
    r5.xyz = r2.xyz * r2.www;
    r1.z = 1 + -r1.z;
    r4.w = r1.z * r1.z;
    r5.w = cmp(r0.w < 0);
    r0.w = 9.99999975e-006 + -r0.w;
    r7.xyz = -r1.xyw * r0.www + r3.xyz;
    r7.xyz = r5.www ? r7.xyz : r3.xyz;
    r0.w = -r1.z * r1.z + 1;
    r1.z = r3.w * r0.w + r4.w;
    r5.w = r4.w * r4.w;
    r7.w = 0.318309873 * r5.w;
    r8.x = 0.5 * r4.w;
    r8.y = r4.w * -0.337748349 + 1;
    r8.z = 1 + -r3.w;
    r8.w = r8.z * r8.z;
    r8.w = r8.w * r8.w;
    r8.z = r8.w * r8.z;
    r2.xyz = -r2.xyz * r2.www + float3(1,1,1);
    r9.xyz = float3(0,0,0);
    r2.w = r0.x;
    [loop] while (true) {
      r8.w = cmp((int)r2.w >= (int)r0.y);
      [branch] if (r8.w != 0) break;
      r8.w = _BT_LinkListBuffer[r2.w].val[0/4];
      r10.x = _BT_LightBuffer[r8.w].val[0/4];
      r10.y = _BT_LightBuffer[r8.w].val[0/4+1];
      r10.z = _BT_LightBuffer[r8.w].val[0/4+2];
      r10.w = _BT_LightBuffer[r8.w].val[0/4+3];
      r9.w = _BT_LightBuffer[r8.w].val[32/4];
      r10.xyz = -r10.xyz + r6.xyz;
      r11.x = dot(r10.xyz, r10.xyz);
      r11.y = r10.w * r10.w;
      r11.z = max(0.100000001, r11.x);
      r11.y = r11.z / r11.y;
      r11.y = -r11.y * r11.y + 1;
      r11.y = max(0, r11.y);
      r11.y = r11.y * r11.y;
      r9.w = r10.w * r9.w + r11.z;
      r9.w = 1 / r9.w;
      r9.w = r9.w * r11.y;
      r10.w = cmp(r9.w != 0.000000);
      [branch] if (r10.w != 0) {
        r11.y = _BT_LightBuffer[r8.w].val[16/4];
        r11.z = _BT_LightBuffer[r8.w].val[16/4+1];
        r11.w = _BT_LightBuffer[r8.w].val[16/4+2];
        r8.w = _BT_LightBuffer[r8.w].val[60/4];
        r10.w = rsqrt(r11.x);
        r12.xyz = r10.xyz * r10.www;
        r11.xyz = r11.yzw * r9.www;
        r9.w = dot(r3.xyz, -r12.xyz);
        r9.w = max(0, r9.w);
        r8.w = cmp(r8.w >= 0);
        r10.xyz = -r10.xyz * r10.www + -r1.xyw;
        r10.w = dot(r10.xyz, r10.xyz);
        r10.w = max(0.00100000005, r10.w);
        r10.w = rsqrt(r10.w);
        r10.xyz = r10.xyz * r10.www;
        r10.w = dot(r7.xyz, r10.xyz);
        r10.x = dot(-r12.xyz, r10.xyz);
        r10.xw = max(float2(0,0), r10.xw);
        r10.y = r9.w * r0.w + r4.w;
        r10.y = r10.y * r3.w;
        r10.y = r9.w * r1.z + r10.y;
        r10.y = 9.99999975e-006 + r10.y;
        r10.y = 0.5 / r10.y;
        r10.z = r10.w * r5.w + -r10.w;
        r10.z = r10.z * r10.w + 1;
        r10.z = r10.z * r10.z + 1.00000001e-007;
        r10.z = r7.w / r10.z;
        r10.w = 1 + -r9.w;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r11.w = r10.x + r10.x;
        r11.w = r11.w * r10.x;
        r11.w = r11.w * r4.w + r8.x;
        r11.w = -1 + r11.w;
        r10.w = r11.w * r10.w + 1;
        r11.w = r11.w * r8.z + 1;
        r10.w = r11.w * r10.w;
        r10.w = r10.w * r8.y;
        r10.y = r10.y * r10.z;
        r10.y = 3.14159274 * r10.y;
        r10.y = r10.y * r9.w;
        r10.y = max(0, r10.y);
        r9.w = r10.w * r9.w;
        r12.xyz = r11.xyz * r9.www;
        r10.yzw = r10.yyy * r11.xyz;
        r9.w = 1 + -r10.x;
        r10.x = r9.w * r9.w;
        r10.x = r10.x * r10.x;
        r9.w = r10.x * r9.w;
        r11.xyz = r2.xyz * r9.www + r5.xyz;
        r10.xyz = r11.xyz * r10.yzw;
        r8.w = r8.w ? 1.000000 : 0;
        r10.xyz = r10.xyz * r8.www;
        r10.xyz = r4.xyz * r12.xyz + r10.xyz;
      } else {
        r10.xyz = float3(0,0,0);
      }
      r9.xyz = r10.xyz + r9.xyz;
      r2.w = (int)r2.w + 1;
    }
    r0.x = (int)r0.z + (int)r0.y;
    r0.y = sqrt(_BT_ShadowMapParams.z);
    r0.z = _BT_MaxShadowDist * _BT_MaxShadowDist;
    r8.w = 0.5 * r0.z;
    r8.w = 1 / r8.w;
    r10.xz = _BT_ShadowMap_TexelSize.xx;
    r10.y = 0.142857149;
    r11.xz = _BT_ShadowMap_TexelSize.yy;
    r11.y = 0.142857149;
    r12.y = 7;
    r13.xyz = r9.xyz;
    r9.w = r2.w;
    [loop] while (true) {
      r10.w = cmp((int)r9.w >= (int)r0.x);
      [branch] if (r10.w != 0) break;
      r10.w = _BT_LinkListBuffer[r9.w].val[0/4];
      r14.x = _BT_LightBuffer[r10.w].val[0/4];
      r14.y = _BT_LightBuffer[r10.w].val[0/4+1];
      r14.z = _BT_LightBuffer[r10.w].val[0/4+2];
      r14.w = _BT_LightBuffer[r10.w].val[0/4+3];
      r11.w = _BT_LightBuffer[r10.w].val[32/4];
      r15.x = _BT_LightBuffer[r10.w].val[48/4];
      r15.y = _BT_LightBuffer[r10.w].val[48/4+1];
      r15.z = _BT_LightBuffer[r10.w].val[48/4+2];
      r15.w = _BT_LightBuffer[r10.w].val[48/4+3];
      r12.w = (uint)r10.w << 2;
      r11.w = frac(r11.w);
      r16.xyz = -r14.xyz + r6.xyz;
      r13.w = dot(r16.xyz, r16.xyz);
      r16.w = r14.w * r14.w;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][1], _BT_LightMatrix[(uint)(r12.w) / 4u][1][1], _BT_LightMatrix[(uint)(r12.w) / 4u][2][1], _BT_LightMatrix[(uint)(r12.w) / 4u][3][1]) * r6.yyyy;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][0], _BT_LightMatrix[(uint)(r12.w) / 4u][1][0], _BT_LightMatrix[(uint)(r12.w) / 4u][2][0], _BT_LightMatrix[(uint)(r12.w) / 4u][3][0]) * r6.xxxx + r17.xyzw;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][2], _BT_LightMatrix[(uint)(r12.w) / 4u][1][2], _BT_LightMatrix[(uint)(r12.w) / 4u][2][2], _BT_LightMatrix[(uint)(r12.w) / 4u][3][2]) * r6.zzzz + r17.xyzw;
      r17.xyzw = float4(_BT_LightMatrix[(uint)(r12.w) / 4u][0][3], _BT_LightMatrix[(uint)(r12.w) / 4u][1][3], _BT_LightMatrix[(uint)(r12.w) / 4u][2][3], _BT_LightMatrix[(uint)(r12.w) / 4u][3][3]) * r6.wwww + r17.xyzw;
      r12.w = max(0.100000001, r13.w);
      r16.w = r12.w / r16.w;
      r16.w = -r16.w * r16.w + 1;
      r16.w = max(0, r16.w);
      r16.w = r16.w * r16.w;
      r11.w = r14.w * r11.w + r12.w;
      r11.w = 1 / r11.w;
      r11.w = r11.w * r16.w;
      r17.xyz = r17.xyz / r17.www;
      r12.w = cmp(0 >= r17.z);
      r18.xy = cmp(float2(1,1) < r17.xy);
      r12.w = (int)r12.w | (int)r18.x;
      r18.xz = cmp(r17.xy < float2(-1,-1));
      r12.w = (int)r12.w | (int)r18.x;
      r12.w = (int)r18.y | (int)r12.w;
      r12.w = (int)r18.z | (int)r12.w;
      [branch] if (r12.w == 0) {
        r12.w = r15.x / r15.y;
        r12.w = min(0.99000001, r12.w);
        r14.w = dot(r17.xy, r17.xy);
        r14.w = sqrt(r14.w);
        r14.w = min(1, r14.w);
        r12.w = -1 + r12.w;
        r14.w = -1 + r14.w;
        r12.w = 1 / r12.w;
        r12.w = r14.w * r12.w;
        r12.w = min(1, r12.w);
        r14.w = r12.w * -2 + 3;
        r12.w = r12.w * r12.w;
        r12.w = r14.w * r12.w;
        r14.w = cmp(r12.w != 0.000000);
        [branch] if (r14.w != 0) {
          r14.w = cmp(-1 < r15.z);
          [branch] if (r14.w != 0) {
            r15.xy = r17.xy * float2(0.5,0.5) + float2(0.5,0.5);
            r14.xyz = _WorldSpaceCameraPos.xyz + -r14.xyz;
            r14.x = dot(r14.xyz, r14.xyz);
            r14.y = r15.z / r0.y;
            r14.z = cmp(r14.y >= -r14.y);
            r14.w = frac(abs(r14.y));
            r14.z = r14.z ? r14.w : -r14.w;
            r14.z = r14.z * r0.y;
            r14.y = floor(r14.y);
            r17.xy = r14.zy / r0.yy;
            r14.yz = r15.xy / r0.yy;
            r14.yz = r14.yz + r17.xy;
            r14.w = r17.z + abs(r15.w);
            r14.yz = r14.yz * _BT_ShadowMap_TexelSize.zw + float2(0.5,0.5);
            r15.xy = floor(r14.yz);
            r15.xy = float2(-0.5,-0.5) + r15.xy;
            r14.yz = frac(r14.yz);
            r15.z = 3 * r14.y;
            r17.xy = -r14.yz * float2(3,3) + float2(4,4);
            r17.zw = r14.yz * float2(3,3) + float2(1,1);
            r18.xy = -r14.yz * float2(2,2) + float2(3,3);
            r18.xy = r18.xy / r17.xy;
            r18.xy = float2(-2,-2) + r18.xy;
            r19.xy = float2(3,3) + r14.yz;
            r19.xy = _BT_ShadowMap_TexelSize.xy * r19.xy;
            r14.yz = r14.yz / r17.zw;
            r14.yz = float2(2,2) + r14.yz;
            r18.z = r19.x;
            r18.w = r14.y;
            r20.xyz = r18.xzw * r10.xyz;
            r19.z = r18.y;
            r19.w = r14.z;
            r18.xyw = r19.zyw * r11.xyz;
            r12.xz = r15.zz * float2(-1,1) + float2(4,1);
            r17.xyz = r17.yyy * r12.xyz;
            r20.w = r18.x;
            r19.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r20.xwyw;
            r14.y = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.xy, r14.w).x;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.zw, r14.w).x;
            r14.z = r17.y * r14.z;
            r14.y = r17.x * r14.y + r14.z;
            r17.xy = r15.xy * _BT_ShadowMap_TexelSize.xy + r20.zw;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r17.xy, r14.w).x;
            r14.y = r17.z * r14.z + r14.y;
            r17.xy = float2(7,7) * r12.xz;
            r18.z = r20.x;
            r19.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r18.zyzw;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.xy, r14.w).x;
            r14.y = r17.x * r14.z + r14.y;
            r18.xz = r20.yz;
            r20.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r18.xyzy;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.xy, r14.w).x;
            r14.y = r14.z * 49 + r14.y;
            r14.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r20.zw, r14.w).x;
            r14.y = r17.y * r14.z + r14.y;
            r17.xyz = r17.www * r12.xyz;
            r12.x = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r19.zw, r14.w).x;
            r12.x = r17.x * r12.x + r14.y;
            r18.xyzw = r15.xyxy * _BT_ShadowMap_TexelSize.xyxy + r18.xwzw;
            r12.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r18.xy, r14.w).x;
            r12.x = r17.y * r12.z + r12.x;
            r12.z = _BT_ShadowMap.SampleCmpLevelZero(sampler_BT_ShadowMap, r18.zw, r14.w).x;
            r12.x = r17.z * r12.z + r12.x;
            r12.z = 0.0069444445 * r12.x;
            r14.x = -r0.z * 0.5 + r14.x;
            r14.x = saturate(r14.x * r8.w);
            r14.y = r14.x * -2 + 3;
            r14.x = r14.x * r14.x;
            r14.x = r14.y * r14.x;
            r12.x = -r12.x * 0.0069444445 + 1;
            r12.x = r14.x * r12.x + r12.z;
            r12.w = r12.w * r12.x;
          }
        } else {
          r12.w = 0;
        }
      } else {
        r12.w = 0;
      }
      r11.w = r12.w * r11.w;
      r12.x = cmp(r11.w != 0.000000);
      [branch] if (r12.x != 0) {
        r12.x = _BT_LightBuffer[r10.w].val[16/4];
        r12.z = _BT_LightBuffer[r10.w].val[16/4+1];
        r12.w = _BT_LightBuffer[r10.w].val[16/4+2];
        r10.w = rsqrt(r13.w);
        r14.xyz = r16.xyz * r10.www;
        r12.xzw = r12.xzw * r11.www;
        r11.w = dot(r3.xyz, -r14.xyz);
        r11.w = max(0, r11.w);
        r13.w = cmp(r15.w >= 0);
        r15.xyz = -r16.xyz * r10.www + -r1.xyw;
        r10.w = dot(r15.xyz, r15.xyz);
        r10.w = max(0.00100000005, r10.w);
        r10.w = rsqrt(r10.w);
        r15.xyz = r15.xyz * r10.www;
        r10.w = dot(r7.xyz, r15.xyz);
        r10.w = max(0, r10.w);
        r14.x = dot(-r14.xyz, r15.xyz);
        r14.x = max(0, r14.x);
        r14.y = r11.w * r0.w + r4.w;
        r14.y = r14.y * r3.w;
        r14.y = r11.w * r1.z + r14.y;
        r14.y = 9.99999975e-006 + r14.y;
        r14.y = 0.5 / r14.y;
        r14.z = r10.w * r5.w + -r10.w;
        r10.w = r14.z * r10.w + 1;
        r10.w = r10.w * r10.w + 1.00000001e-007;
        r10.w = r7.w / r10.w;
        r14.z = 1 + -r11.w;
        r14.w = r14.z * r14.z;
        r14.w = r14.w * r14.w;
        r14.z = r14.w * r14.z;
        r14.w = r14.x + r14.x;
        r14.w = r14.w * r14.x;
        r14.w = r14.w * r4.w + r8.x;
        r14.w = -1 + r14.w;
        r14.z = r14.w * r14.z + 1;
        r14.w = r14.w * r8.z + 1;
        r14.z = r14.z * r14.w;
        r14.z = r14.z * r8.y;
        r10.w = r14.y * r10.w;
        r10.w = 3.14159274 * r10.w;
        r10.w = r10.w * r11.w;
        r10.w = max(0, r10.w);
        r11.w = r14.z * r11.w;
        r14.yzw = r12.xzw * r11.www;
        r12.xzw = r10.www * r12.xzw;
        r10.w = 1 + -r14.x;
        r11.w = r10.w * r10.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r15.xyz = r2.xyz * r10.www + r5.xyz;
        r12.xzw = r15.xyz * r12.xzw;
        r10.w = r13.w ? 1.000000 : 0;
        r12.xzw = r12.xzw * r10.www;
        r12.xzw = r4.xyz * r14.yzw + r12.xzw;
      } else {
        r12.xzw = float3(0,0,0);
      }
      r13.xyz = r13.xyz + r12.xzw;
      r9.w = (int)r9.w + 1;
    }
    r0.xyz = float3(8,8,8) * r13.xyz;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = max(float3(0,0,0), r0.xyz);
  o0.w = 1;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float4 o0 = 0;
		float4 o1 = 0;
		float3 o2 = 0;
		vs_cbf2e6439936bc93_impl(v.position0, v.texcoord0.xy, o0, o1, o2);
		o.texcoord0 = o0;
		o.sv_position = o1;
		o.texcoord1.xyz = o2;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && !defined(_LIGHTQUAL_LOW) && !defined(_LIGHTQUAL_MED) && !defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_75890df19dcb4ea3_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_LOW) && !defined(_SIMPLE_PASS) || !defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_MED) && !defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_512d5af8744d2bbf_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && !defined(_LIGHTQUAL_LOW) && !defined(_LIGHTQUAL_MED) && defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_5ce00b55e3b3e68b_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_LOW) && defined(_SIMPLE_PASS) || !defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_MED) && defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_2886cad062b81550_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && !defined(_LIGHTQUAL_LOW) && !defined(_LIGHTQUAL_MED) && !defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_f477de119b48453e_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_LOW) && !defined(_SIMPLE_PASS) || defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_MED) && !defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_fb12431c83fd11d0_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && !defined(_LIGHTQUAL_LOW) && !defined(_LIGHTQUAL_MED) && defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_42a7d45dd9e446fa_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_LOW) && defined(_SIMPLE_PASS) || defined(_BT_SHADOWS) && !defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_MED) && defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_3a72a9ab62909f3a_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && !defined(_LIGHTQUAL_LOW) && !defined(_LIGHTQUAL_MED) && !defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_8c02cf530ae4e32a_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_MED) && !defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_3d473d880ff170ab_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_LOW)
	{
		float4 o0 = 0;
		ps_4372c39de71933c6_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && !defined(_LIGHTQUAL_LOW) && !defined(_LIGHTQUAL_MED) && defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_6488bfbd163c3458_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif !defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_MED) && defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_1dd33a5e8df76164_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && !defined(_LIGHTQUAL_LOW) && !defined(_LIGHTQUAL_MED) && !defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_f3614ade12199000_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_MED) && !defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_be179f5b613d51af_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_LOW)
	{
		float4 o0 = 0;
		ps_b5a46274f5991730_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && !defined(_LIGHTQUAL_LOW) && !defined(_LIGHTQUAL_MED) && defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_d3422d72c196fa5b_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
		r.t0 = o0;
	}
#elif defined(_BT_SHADOWS) && defined(_BT_SIM_GAME) && defined(_LIGHTQUAL_MED) && defined(_SIMPLE_PASS)
	{
		float4 o0 = 0;
		ps_dfb459c1e199e04f_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
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
