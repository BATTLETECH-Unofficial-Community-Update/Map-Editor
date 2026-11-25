Shader "Hidden/BT-LightQuad"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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

#define cmp -

struct _BT_LightSpriteBuffer_t { float val[8]; };
StructuredBuffer<_BT_LightSpriteBuffer_t> _BT_LightSpriteBuffer;


struct appdata
{
	uint sv_instanceid0 : SV_InstanceID;
	uint sv_vertexid0 : SV_VertexID;
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

// vs 7e56d52122746c1c: 1 retail keyword combination(s)
void vs_7e56d52122746c1c_impl(
  uint v0 : SV_VertexID0,
  uint v1 : SV_InstanceID0,
  inout float4 o0 : SV_POSITION0,
  inout float4 o1 : TEXCOORD0,
  inout float2 o2 : TEXCOORD1)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v0.x, vertex_id
// Needs manual fix for instruction:
// unknown dcl_: dcl_input_sgv v1.x, instance_id
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  float4 x0[6];
  float4 x1[6];
  x0[0].xy = float2(0.5,0.5);
  x0[1].xy = float2(-0.5,0.5);
  x0[2].xy = float2(-0.5,-0.5);
  x0[3].xy = float2(0.5,0.5);
  x0[4].xy = float2(-0.5,-0.5);
  x0[5].xy = float2(0.5,-0.5);
  x1[0].xy = float2(1,1);
  x1[1].xy = float2(0,1);
  x1[2].xy = float2(0,0);
  x1[3].xy = float2(1,1);
  x1[4].xy = float2(0,0);
  x1[5].xy = float2(1,0);
  r0.x = v0.x;
  r0.yz = x0[r0.x+0].xy;
  o2.xy = x1[r0.x+0].xy;
  r1.x = _BT_LightSpriteBuffer[v1.x].val[0/4];
  r1.y = _BT_LightSpriteBuffer[v1.x].val[0/4+1];
  r1.z = _BT_LightSpriteBuffer[v1.x].val[0/4+2];
  r1.w = _BT_LightSpriteBuffer[v1.x].val[0/4+3];
  r2.xyz = float3(unity_WorldToCamera[0][1], unity_WorldToCamera[1][1], unity_WorldToCamera[2][1]) * r1.yyy;
  r2.xyz = float3(unity_WorldToCamera[0][0], unity_WorldToCamera[1][0], unity_WorldToCamera[2][0]) * r1.xxx + r2.xyz;
  r1.xyz = float3(unity_WorldToCamera[0][2], unity_WorldToCamera[1][2], unity_WorldToCamera[2][2]) * r1.zzz + r2.xyz;
  r0.xy = r0.yz * r1.ww + r1.xy;
  r0.z = r1.z + -r1.w;
  r1.xyz = float3(unity_CameraToWorld[0][1], unity_CameraToWorld[1][1], unity_CameraToWorld[2][1]) * r0.yyy;
  r0.xyw = float3(unity_CameraToWorld[0][0], unity_CameraToWorld[1][0], unity_CameraToWorld[2][0]) * r0.xxx + r1.xyz;
  r0.xyz = float3(unity_CameraToWorld[0][2], unity_CameraToWorld[1][2], unity_CameraToWorld[2][2]) * r0.zzz + r0.xyw;
  r1.xyzw = float4(unity_ObjectToWorld[0][1], unity_ObjectToWorld[1][1], unity_ObjectToWorld[2][1], unity_ObjectToWorld[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0], unity_ObjectToWorld[3][0]) * r0.xxxx + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][2], unity_ObjectToWorld[1][2], unity_ObjectToWorld[2][2], unity_ObjectToWorld[3][2]) * r0.zzzz + r1.xyzw;
  r0.xyzw = float4(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3], unity_ObjectToWorld[3][3]) + r0.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][1], unity_MatrixVP[1][1], unity_MatrixVP[2][1], unity_MatrixVP[3][1]) * r0.yyyy;
  r1.xyzw = float4(unity_MatrixVP[0][0], unity_MatrixVP[1][0], unity_MatrixVP[2][0], unity_MatrixVP[3][0]) * r0.xxxx + r1.xyzw;
  r1.xyzw = float4(unity_MatrixVP[0][2], unity_MatrixVP[1][2], unity_MatrixVP[2][2], unity_MatrixVP[3][2]) * r0.zzzz + r1.xyzw;
  o0.xyzw = float4(unity_MatrixVP[0][3], unity_MatrixVP[1][3], unity_MatrixVP[2][3], unity_MatrixVP[3][3]) * r0.wwww + r1.xyzw;
  o1.x = _BT_LightSpriteBuffer[v1.x].val[16/4];
  o1.y = _BT_LightSpriteBuffer[v1.x].val[16/4+1];
  o1.z = _BT_LightSpriteBuffer[v1.x].val[16/4+2];
  o1.w = _BT_LightSpriteBuffer[v1.x].val[16/4+3];
  return;
}


// ps 4ba7f95f8e6ff589: 1 retail keyword combination(s)
void ps_4ba7f95f8e6ff589_impl(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float2 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.5,-0.5) + v2.xy;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = sqrt(r0.x);
  r0.x = -r0.x * 2 + 1;
  r0.x = max(0, r0.x);
  r0.y = r0.x * r0.x;
  r0.x = r0.x * r0.y;
  r0.xyz = v1.xyz * r0.xxx;
  o0.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r0.xyz;
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
		float2 o2 = 0;
		vs_7e56d52122746c1c_impl(v.sv_vertexid0, v.sv_instanceid0, o0, o1, o2);
		o.sv_position = o0;
		o.texcoord0 = o1;
		o.texcoord1.xy = o2;
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
		ps_4ba7f95f8e6ff589_impl(i.sv_position, i.texcoord0, i.texcoord1.xy, o0);
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
