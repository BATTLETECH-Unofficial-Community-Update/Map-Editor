Shader "Hidden/BT-DrawLightsDebug"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DebugMode ("DebugMode", Float) = 0
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
			#pragma multi_compile _ _BT_SIM_GAME

#define cmp -

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
Texture3D<int4> _BT_ListEntries;
SamplerState sampler_BT_ListEntries;

float3 _GlobalProjection;
float _BTLightingTileSize;
float _BTScreenWidth;
float _BTScreenHeight;
float _BT_ClusterBounds[8];
float _DebugMode;

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

// vs 96721b335cc67c24: 2 retail keyword combination(s)
void vs_96721b335cc67c24_impl(
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


// ps b3d272b6072beeaa: 2 retail keyword combination(s)
void ps_b3d272b6072beeaa_impl(
  float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  float3 v2 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, v0.xy).x;
  r0.x = _ZBufferParams.x * r0.x + _ZBufferParams.y;
  r0.x = 1 / r0.x;
  r0.y = cmp(_DebugMode == 1.000000);
  [branch] if (r0.y != 0) {
    r0.z = cmp(r0.x >= _BT_ClusterBounds[1]);
    [branch] if (r0.z != 0) {
      r0.z = cmp(r0.x >= _BT_ClusterBounds[2]);
      [branch] if (r0.z != 0) {
        r0.z = cmp(r0.x >= _BT_ClusterBounds[3]);
        [branch] if (r0.z != 0) {
          r0.z = cmp(r0.x < _BT_ClusterBounds[4]);
          r0.w = cmp(r0.x < _BT_ClusterBounds[5]);
          r1.x = cmp(r0.x < _BT_ClusterBounds[6]);
          r1.y = cmp(r0.x < _BT_ClusterBounds[7]);
          r1.y = r1.y ? 6 : 7;
          r1.x = r1.x ? 5 : r1.y;
          r0.w = r0.w ? 4 : r1.x;
          r0.z = r0.z ? 3 : r0.w;
        } else {
          r0.z = 2;
        }
      } else {
        r0.z = 1;
      }
    } else {
      r0.z = 0;
    }
    r1.xyzw = cmp((int4)r0.zzzz == int4(1,2,3,4));
    r2.xy = cmp((int2)r0.zz == int2(5,6));
    r0.w = r2.y ? 1.000000 : 0;
    r2.xyz = r2.xxx ? float3(0,1,1) : r0.www;
    r2.xyz = r1.www ? float3(1,0,1) : r2.xyz;
    r2.xyz = r1.zzz ? float3(1,1,0) : r2.xyz;
    r1.yzw = r1.yyy ? float3(0,0,1) : r2.xyz;
    r1.xyz = r1.xxx ? float3(0,1,0) : r1.yzw;
    r1.xyz = r0.zzz ? r1.xyz : float3(1,0,0);
  }
  [branch] if (r0.y == 0) {
    r2.x = _BTScreenWidth * v0.x;
    r2.y = _BTScreenHeight * v0.y;
    r0.yz = r2.xy / _BTLightingTileSize.xx;
    r0.yz = floor(r0.yz);
    r2.xy = (uint2)r0.yz;
    r0.y = cmp(r0.x >= _BT_ClusterBounds[1]);
    [branch] if (r0.y != 0) {
      r0.y = cmp(r0.x >= _BT_ClusterBounds[2]);
      [branch] if (r0.y != 0) {
        r0.y = cmp(r0.x >= _BT_ClusterBounds[3]);
        [branch] if (r0.y != 0) {
          r0.y = cmp(r0.x < _BT_ClusterBounds[4]);
          r0.z = cmp(r0.x < _BT_ClusterBounds[5]);
          r0.w = cmp(r0.x < _BT_ClusterBounds[6]);
          r0.x = cmp(r0.x < _BT_ClusterBounds[7]);
          r0.x = r0.x ? 6 : 7;
          r0.x = r0.w ? 5 : r0.x;
          r0.x = r0.z ? 4 : r0.x;
          r2.z = r0.y ? 3 : r0.x;
        } else {
          r2.z = 2;
        }
      } else {
        r2.z = 1;
      }
    } else {
      r2.z = 0;
    }
    r2.w = 0;
    r0.xyzw = _BT_ListEntries.Load(r2.xyzw).xyzw;
    r1.w = cmp((int)r0.x >= 0);
    [branch] if (r1.w != 0) {
      r0.y = (int)r0.y + (int)r0.x;
      r2.x = 0;
      r2.y = r0.x;
      [loop] while (true) {
        r1.w = cmp((int)r2.y >= (int)r0.y);
        [branch] if (r1.w != 0) break;
        r2.xy = (int2)r2.xy + int2(1,1);
      }
      r0.x = (int)r0.z + (int)r0.y;
      r0.yz = r2.xy;
      [loop] while (true) {
        r1.w = cmp((int)r0.z >= (int)r0.x);
        [branch] if (r1.w != 0) break;
        r0.yz = (int2)r0.yz + int2(1,1);
      }
      r0.x = (int)r0.w + (int)r0.x;
      r2.xy = r0.yz;
      [loop] while (true) {
        r0.w = cmp((int)r2.y >= (int)r0.x);
        [branch] if (r0.w != 0) break;
        r2.xy = (int2)r2.xy + int2(1,1);
      }
      r0.x = (uint)r2.x;
      r0.xy = float2(-1,-9) + r0.xx;
      r0.xy = saturate(float2(0.142857149,0.0434782617) * r0.xy);
      r0.zw = r0.xy * float2(-2,-2) + float2(3,3);
      r0.xy = r0.xy * r0.xy;
      r0.xy = r0.zw * r0.xy;
      r0.xzw = r0.xxx * float3(0,1,-1) + float3(0,0,1);
      r2.yz = cmp(int2(8,32) < (uint2)r2.xx);
      r3.xyz = r0.yyy * float3(0,-1,0) + float3(1,1,0);
      r0.xyz = r2.yyy ? r3.xyz : r0.xzw;
      r0.xyz = r2.zzz ? float3(1,0,1) : r0.xyz;
      r1.xyz = r2.xxx ? r0.xyz : float3(0,0,0);
    } else {
      r1.xyz = float3(0,0,0);
    }
  }
  o0.xyz = saturate(r1.xyz);
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
		vs_96721b335cc67c24_impl(v.position0, v.texcoord0.xy, o0, o1, o2);
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
#if 1
	{
		float4 o0 = 0;
		ps_b3d272b6072beeaa_impl(i.texcoord0, i.sv_position, i.texcoord1.xyz, o0);
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
