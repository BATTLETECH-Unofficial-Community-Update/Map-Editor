Shader "Hidden/Post FX/FXAA"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			#pragma target 4.0
			#pragma multi_compile _ DITHERING
			#pragma multi_compile _ GRAIN

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;
Texture2D _DitheringTex;
SamplerState sampler_DitheringTex;
Texture2D _GrainTex;
SamplerState sampler_GrainTex;

float4 _MainTex_ST;
float4 _MainTex_TexelSize;
float3 _QualitySettings;
float4 _DitheringCoords;
float2 _Grain_Params1;
float4 _Grain_Params2;

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

// vs 4a840470d5c29811: 4 retail keyword combination(s)
void vs_4a840470d5c29811_impl(
  float4 v0 : POSITION0,
  float4 v1 : TEXCOORD0,
  inout float4 o0 : SV_POSITION0,
  inout float2 o1 : TEXCOORD0,
  inout float2 p1 : TEXCOORD1)
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
  p1.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  o1.xy = v1.xy;
  return;
}


// ps fb5a5cfe713c33f1: 1 retail keyword combination(s)
void ps_fb5a5cfe713c33f1_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.SampleLevel(sampler_MainTex, r0.xy, 0).xyzw;
  r2.xyzw = _MainTex_TexelSize.xyxy * float4(0,1,1,0) + r0.xyxy;
  r3.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xy, 0).xyzw;
  r2.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.zw, 0).xyzw;
  r4.xyzw = _MainTex_TexelSize.xyxy * float4(0,-1,-1,0) + r0.xyxy;
  r5.xyzw = _MainTex.SampleLevel(sampler_MainTex, r4.xy, 0).xyzw;
  r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r4.zw, 0).xyzw;
  r0.z = max(r3.y, r1.y);
  r0.w = min(r3.y, r1.y);
  r0.z = max(r2.y, r0.z);
  r0.w = min(r2.y, r0.w);
  r2.x = max(r5.y, r4.y);
  r2.z = min(r5.y, r4.y);
  r0.z = max(r2.x, r0.z);
  r0.w = min(r2.z, r0.w);
  r2.x = _QualitySettings.y * r0.z;
  r0.z = r0.z + -r0.w;
  r0.w = max(_QualitySettings.z, r2.x);
  r0.w = cmp(r0.z >= r0.w);
  [branch] if (r0.w != 0) {
    r2.xz = -_MainTex_TexelSize.xy + r0.xy;
    r6.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xz, 0).xyzw;
    r2.xz = _MainTex_TexelSize.xy + r0.xy;
    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xz, 0).xyzw;
    r8.xyzw = _MainTex_TexelSize.xyxy * float4(1,-1,-1,1) + r0.xyxy;
    r9.xyzw = _MainTex.SampleLevel(sampler_MainTex, r8.xy, 0).xyzw;
    r8.xyzw = _MainTex.SampleLevel(sampler_MainTex, r8.zw, 0).xyzw;
    r0.w = r5.y + r3.y;
    r2.x = r4.y + r2.y;
    r0.z = 1 / r0.z;
    r2.z = r2.x + r0.w;
    r0.w = r1.y * -2 + r0.w;
    r2.x = r1.y * -2 + r2.x;
    r2.w = r9.y + r7.y;
    r3.x = r9.y + r6.y;
    r3.z = r2.y * -2 + r2.w;
    r3.x = r5.y * -2 + r3.x;
    r3.w = r8.y + r6.y;
    r4.x = r8.y + r7.y;
    r0.w = abs(r0.w) * 2 + abs(r3.z);
    r2.x = abs(r2.x) * 2 + abs(r3.x);
    r3.x = r4.y * -2 + r3.w;
    r3.z = r3.y * -2 + r4.x;
    r0.w = abs(r3.x) + r0.w;
    r2.x = abs(r3.z) + r2.x;
    r2.w = r3.w + r2.w;
    r0.w = cmp(r0.w >= r2.x);
    r2.x = r2.z * 2 + r2.w;
    r2.z = r0.w ? r5.y : r4.y;
    r2.y = r0.w ? r3.y : r2.y;
    r2.w = r0.w ? _MainTex_TexelSize.y : _MainTex_TexelSize.x;
    r2.x = r2.x * 0.0833333358 + -r1.y;
    r3.xy = r2.zy + -r1.yy;
    r2.yz = r2.yz + r1.yy;
    r3.z = cmp(abs(r3.x) >= abs(r3.y));
    r3.x = max(abs(r3.x), abs(r3.y));
    r2.w = r3.z ? -r2.w : r2.w;
    r0.z = saturate(abs(r2.x) * r0.z);
    r2.x = r0.w ? _MainTex_TexelSize.x : 0;
    r3.y = r0.w ? 0 : _MainTex_TexelSize.y;
    r4.xy = r2.ww * float2(0.5,0.5) + r0.xy;
    r3.w = r0.w ? r0.x : r4.x;
    r4.x = r0.w ? r4.y : r0.y;
    r5.x = r3.w + -r2.x;
    r5.y = r4.x + -r3.y;
    r6.x = r3.w + r2.x;
    r6.y = r4.x + r3.y;
    r3.w = r0.z * -2 + 3;
    r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xy, 0).xyzw;
    r0.z = r0.z * r0.z;
    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xy, 0).xyzw;
    r2.y = r3.z ? r2.z : r2.y;
    r2.z = 0.25 * r3.x;
    r3.x = -r2.y * 0.5 + r1.y;
    r0.z = r3.w * r0.z;
    r3.x = cmp(r3.x < 0);
    r4.y = -r2.y * 0.5 + r4.y;
    r4.x = -r2.y * 0.5 + r7.y;
    r3.zw = cmp(abs(r4.yx) >= r2.zz);
    r5.z = r5.x + -r2.x;
    r5.x = r3.z ? r5.x : r5.z;
    r5.w = r5.y + -r3.y;
    r5.z = r3.z ? r5.y : r5.w;
    r5.yw = ~(int2)r3.zw;
    r5.y = (int)r5.w | (int)r5.y;
    r5.w = r6.x + r2.x;
    r6.x = r3.w ? r6.x : r5.w;
    r5.w = r6.y + r3.y;
    r6.z = r3.w ? r6.y : r5.w;
    [branch] if (r5.y != 0) {
      [branch] if (r3.z == 0) {
        r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
      } else {
        r7.x = r4.y;
      }
      [branch] if (r3.w == 0) {
        r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
      }
      r5.y = -r2.y * 0.5 + r7.x;
      r4.y = r3.z ? r7.x : r5.y;
      r3.z = -r2.y * 0.5 + r4.x;
      r4.x = r3.w ? r4.x : r3.z;
      r3.zw = cmp(abs(r4.yx) >= r2.zz);
      r5.y = r5.x + -r2.x;
      r5.x = r3.z ? r5.x : r5.y;
      r5.y = r5.z + -r3.y;
      r5.z = r3.z ? r5.z : r5.y;
      r5.yw = ~(int2)r3.zw;
      r5.y = (int)r5.w | (int)r5.y;
      r5.w = r6.x + r2.x;
      r6.x = r3.w ? r6.x : r5.w;
      r5.w = r6.z + r3.y;
      r6.z = r3.w ? r6.z : r5.w;
      [branch] if (r5.y != 0) {
        [branch] if (r3.z == 0) {
          r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
        } else {
          r7.x = r4.y;
        }
        [branch] if (r3.w == 0) {
          r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
        }
        r5.y = -r2.y * 0.5 + r7.x;
        r4.y = r3.z ? r7.x : r5.y;
        r3.z = -r2.y * 0.5 + r4.x;
        r4.x = r3.w ? r4.x : r3.z;
        r3.zw = cmp(abs(r4.yx) >= r2.zz);
        r5.y = r5.x + -r2.x;
        r5.x = r3.z ? r5.x : r5.y;
        r5.y = r5.z + -r3.y;
        r5.z = r3.z ? r5.z : r5.y;
        r5.yw = ~(int2)r3.zw;
        r5.y = (int)r5.w | (int)r5.y;
        r5.w = r6.x + r2.x;
        r6.x = r3.w ? r6.x : r5.w;
        r5.w = r6.z + r3.y;
        r6.z = r3.w ? r6.z : r5.w;
        [branch] if (r5.y != 0) {
          [branch] if (r3.z == 0) {
            r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
          } else {
            r7.x = r4.y;
          }
          [branch] if (r3.w == 0) {
            r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
          }
          r5.y = -r2.y * 0.5 + r7.x;
          r4.y = r3.z ? r7.x : r5.y;
          r3.z = -r2.y * 0.5 + r4.x;
          r4.x = r3.w ? r4.x : r3.z;
          r3.zw = cmp(abs(r4.yx) >= r2.zz);
          r5.y = r5.x + -r2.x;
          r5.x = r3.z ? r5.x : r5.y;
          r5.y = r5.z + -r3.y;
          r5.z = r3.z ? r5.z : r5.y;
          r5.yw = ~(int2)r3.zw;
          r5.y = (int)r5.w | (int)r5.y;
          r5.w = r6.x + r2.x;
          r6.x = r3.w ? r6.x : r5.w;
          r5.w = r6.z + r3.y;
          r6.z = r3.w ? r6.z : r5.w;
          [branch] if (r5.y != 0) {
            [branch] if (r3.z == 0) {
              r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
            } else {
              r7.x = r4.y;
            }
            [branch] if (r3.w == 0) {
              r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
            }
            r5.y = -r2.y * 0.5 + r7.x;
            r4.y = r3.z ? r7.x : r5.y;
            r3.z = -r2.y * 0.5 + r4.x;
            r4.x = r3.w ? r4.x : r3.z;
            r3.zw = cmp(abs(r4.yx) >= r2.zz);
            r5.y = -r2.x * 1.5 + r5.x;
            r5.x = r3.z ? r5.x : r5.y;
            r5.y = -r3.y * 1.5 + r5.z;
            r5.z = r3.z ? r5.z : r5.y;
            r5.yw = ~(int2)r3.zw;
            r5.y = (int)r5.w | (int)r5.y;
            r5.w = r2.x * 1.5 + r6.x;
            r6.x = r3.w ? r6.x : r5.w;
            r5.w = r3.y * 1.5 + r6.z;
            r6.z = r3.w ? r6.z : r5.w;
            [branch] if (r5.y != 0) {
              [branch] if (r3.z == 0) {
                r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
              } else {
                r7.x = r4.y;
              }
              [branch] if (r3.w == 0) {
                r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
              }
              r5.y = -r2.y * 0.5 + r7.x;
              r4.y = r3.z ? r7.x : r5.y;
              r3.z = -r2.y * 0.5 + r4.x;
              r4.x = r3.w ? r4.x : r3.z;
              r3.zw = cmp(abs(r4.yx) >= r2.zz);
              r5.y = -r2.x * 2 + r5.x;
              r5.x = r3.z ? r5.x : r5.y;
              r5.y = -r3.y * 2 + r5.z;
              r5.z = r3.z ? r5.z : r5.y;
              r5.yw = ~(int2)r3.zw;
              r5.y = (int)r5.w | (int)r5.y;
              r5.w = r2.x * 2 + r6.x;
              r6.x = r3.w ? r6.x : r5.w;
              r5.w = r3.y * 2 + r6.z;
              r6.z = r3.w ? r6.z : r5.w;
              [branch] if (r5.y != 0) {
                [branch] if (r3.z == 0) {
                  r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                } else {
                  r7.x = r4.y;
                }
                [branch] if (r3.w == 0) {
                  r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                }
                r5.y = -r2.y * 0.5 + r7.x;
                r4.y = r3.z ? r7.x : r5.y;
                r3.z = -r2.y * 0.5 + r4.x;
                r4.x = r3.w ? r4.x : r3.z;
                r3.zw = cmp(abs(r4.yx) >= r2.zz);
                r5.y = -r2.x * 2 + r5.x;
                r5.x = r3.z ? r5.x : r5.y;
                r5.y = -r3.y * 2 + r5.z;
                r5.z = r3.z ? r5.z : r5.y;
                r5.yw = ~(int2)r3.zw;
                r5.y = (int)r5.w | (int)r5.y;
                r5.w = r2.x * 2 + r6.x;
                r6.x = r3.w ? r6.x : r5.w;
                r5.w = r3.y * 2 + r6.z;
                r6.z = r3.w ? r6.z : r5.w;
                [branch] if (r5.y != 0) {
                  [branch] if (r3.z == 0) {
                    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                  } else {
                    r7.x = r4.y;
                  }
                  [branch] if (r3.w == 0) {
                    r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                  }
                  r5.y = -r2.y * 0.5 + r7.x;
                  r4.y = r3.z ? r7.x : r5.y;
                  r3.z = -r2.y * 0.5 + r4.x;
                  r4.x = r3.w ? r4.x : r3.z;
                  r3.zw = cmp(abs(r4.yx) >= r2.zz);
                  r5.y = -r2.x * 2 + r5.x;
                  r5.x = r3.z ? r5.x : r5.y;
                  r5.y = -r3.y * 2 + r5.z;
                  r5.z = r3.z ? r5.z : r5.y;
                  r5.yw = ~(int2)r3.zw;
                  r5.y = (int)r5.w | (int)r5.y;
                  r5.w = r2.x * 2 + r6.x;
                  r6.x = r3.w ? r6.x : r5.w;
                  r5.w = r3.y * 2 + r6.z;
                  r6.z = r3.w ? r6.z : r5.w;
                  [branch] if (r5.y != 0) {
                    [branch] if (r3.z == 0) {
                      r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                    } else {
                      r7.x = r4.y;
                    }
                    [branch] if (r3.w == 0) {
                      r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                    }
                    r5.y = -r2.y * 0.5 + r7.x;
                    r4.y = r3.z ? r7.x : r5.y;
                    r3.z = -r2.y * 0.5 + r4.x;
                    r4.x = r3.w ? r4.x : r3.z;
                    r3.zw = cmp(abs(r4.yx) >= r2.zz);
                    r5.y = -r2.x * 2 + r5.x;
                    r5.x = r3.z ? r5.x : r5.y;
                    r5.y = -r3.y * 2 + r5.z;
                    r5.z = r3.z ? r5.z : r5.y;
                    r5.yw = ~(int2)r3.zw;
                    r5.y = (int)r5.w | (int)r5.y;
                    r5.w = r2.x * 2 + r6.x;
                    r6.x = r3.w ? r6.x : r5.w;
                    r5.w = r3.y * 2 + r6.z;
                    r6.z = r3.w ? r6.z : r5.w;
                    [branch] if (r5.y != 0) {
                      [branch] if (r3.z == 0) {
                        r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                      } else {
                        r7.x = r4.y;
                      }
                      [branch] if (r3.w == 0) {
                        r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                      }
                      r5.y = -r2.y * 0.5 + r7.x;
                      r4.y = r3.z ? r7.x : r5.y;
                      r3.z = -r2.y * 0.5 + r4.x;
                      r4.x = r3.w ? r4.x : r3.z;
                      r3.zw = cmp(abs(r4.yx) >= r2.zz);
                      r5.y = -r2.x * 4 + r5.x;
                      r5.x = r3.z ? r5.x : r5.y;
                      r5.y = -r3.y * 4 + r5.z;
                      r5.z = r3.z ? r5.z : r5.y;
                      r5.yw = ~(int2)r3.zw;
                      r5.y = (int)r5.w | (int)r5.y;
                      r5.w = r2.x * 4 + r6.x;
                      r6.x = r3.w ? r6.x : r5.w;
                      r5.w = r3.y * 4 + r6.z;
                      r6.z = r3.w ? r6.z : r5.w;
                      [branch] if (r5.y != 0) {
                        [branch] if (r3.z == 0) {
                          r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                        } else {
                          r7.x = r4.y;
                        }
                        [branch] if (r3.w == 0) {
                          r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                        }
                        r4.z = -r2.y * 0.5 + r7.x;
                        r4.y = r3.z ? r7.x : r4.z;
                        r2.y = -r2.y * 0.5 + r4.x;
                        r4.x = r3.w ? r4.x : r2.y;
                        r2.yz = cmp(abs(r4.yx) >= r2.zz);
                        r3.z = -r2.x * 8 + r5.x;
                        r5.x = r2.y ? r5.x : r3.z;
                        r3.z = -r3.y * 8 + r5.z;
                        r5.z = r2.y ? r5.z : r3.z;
                        r2.x = r2.x * 8 + r6.x;
                        r6.x = r2.z ? r6.x : r2.x;
                        r2.x = r3.y * 8 + r6.z;
                        r6.z = r2.z ? r6.z : r2.x;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    r2.xz = -r5.xz + r0.xy;
    r2.x = r0.w ? r2.x : r2.z;
    r2.yz = r6.xz + -r0.xy;
    r2.y = r0.w ? r2.y : r2.z;
    r3.yz = cmp(r4.yx < float2(0,0));
    r2.z = r2.y + r2.x;
    r3.xy = cmp((int2)r3.xx != (int2)r3.yz);
    r2.z = 1 / r2.z;
    r3.z = cmp(r2.x < r2.y);
    r2.x = min(r2.x, r2.y);
    r2.y = r3.z ? r3.x : r3.y;
    r0.z = r0.z * r0.z;
    r2.x = r2.x * -r2.z + 0.5;
    r0.z = _QualitySettings.x * r0.z;
    r2.x = asfloat(asint(r2.x) & (int)r2.y);
    r0.z = max(r2.x, r0.z);
    r2.xy = r0.zz * r2.ww + r0.xy;
    r3.x = r0.w ? r0.x : r2.x;
    r3.y = r0.w ? r2.y : r0.y;
    r0.xyzw = _MainTex.SampleLevel(sampler_MainTex, r3.xy, 0).xyzw;
    o0.xyz = r0.xyz;
    o0.w = r1.y;
  } else {
    o0.xyzw = r1.xyzw;
  }
  return;
}


// ps 236baed351f34ec3: 1 retail keyword combination(s)
void ps_236baed351f34ec3_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.SampleLevel(sampler_MainTex, r0.xy, 0).xyzw;
  r2.xyzw = _MainTex_TexelSize.xyxy * float4(0,1,1,0) + r0.xyxy;
  r3.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xy, 0).xyzw;
  r2.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.zw, 0).xyzw;
  r4.xyzw = _MainTex_TexelSize.xyxy * float4(0,-1,-1,0) + r0.xyxy;
  r5.xyzw = _MainTex.SampleLevel(sampler_MainTex, r4.xy, 0).xyzw;
  r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r4.zw, 0).xyzw;
  r0.z = max(r3.y, r1.y);
  r0.w = min(r3.y, r1.y);
  r0.z = max(r2.y, r0.z);
  r0.w = min(r2.y, r0.w);
  r2.x = max(r5.y, r4.y);
  r2.z = min(r5.y, r4.y);
  r0.z = max(r2.x, r0.z);
  r0.w = min(r2.z, r0.w);
  r2.x = _QualitySettings.y * r0.z;
  r0.z = r0.z + -r0.w;
  r0.w = max(_QualitySettings.z, r2.x);
  r0.w = cmp(r0.z >= r0.w);
  [branch] if (r0.w != 0) {
    r2.xz = -_MainTex_TexelSize.xy + r0.xy;
    r6.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xz, 0).xyzw;
    r2.xz = _MainTex_TexelSize.xy + r0.xy;
    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xz, 0).xyzw;
    r8.xyzw = _MainTex_TexelSize.xyxy * float4(1,-1,-1,1) + r0.xyxy;
    r9.xyzw = _MainTex.SampleLevel(sampler_MainTex, r8.xy, 0).xyzw;
    r8.xyzw = _MainTex.SampleLevel(sampler_MainTex, r8.zw, 0).xyzw;
    r0.w = r5.y + r3.y;
    r2.x = r4.y + r2.y;
    r0.z = 1 / r0.z;
    r2.z = r2.x + r0.w;
    r0.w = r1.y * -2 + r0.w;
    r2.x = r1.y * -2 + r2.x;
    r2.w = r9.y + r7.y;
    r3.x = r9.y + r6.y;
    r3.z = r2.y * -2 + r2.w;
    r3.x = r5.y * -2 + r3.x;
    r3.w = r8.y + r6.y;
    r4.x = r8.y + r7.y;
    r0.w = abs(r0.w) * 2 + abs(r3.z);
    r2.x = abs(r2.x) * 2 + abs(r3.x);
    r3.x = r4.y * -2 + r3.w;
    r3.z = r3.y * -2 + r4.x;
    r0.w = abs(r3.x) + r0.w;
    r2.x = abs(r3.z) + r2.x;
    r2.w = r3.w + r2.w;
    r0.w = cmp(r0.w >= r2.x);
    r2.x = r2.z * 2 + r2.w;
    r2.z = r0.w ? r5.y : r4.y;
    r2.y = r0.w ? r3.y : r2.y;
    r2.w = r0.w ? _MainTex_TexelSize.y : _MainTex_TexelSize.x;
    r2.x = r2.x * 0.0833333358 + -r1.y;
    r3.xy = r2.zy + -r1.yy;
    r2.yz = r2.yz + r1.yy;
    r3.z = cmp(abs(r3.x) >= abs(r3.y));
    r3.x = max(abs(r3.x), abs(r3.y));
    r2.w = r3.z ? -r2.w : r2.w;
    r0.z = saturate(abs(r2.x) * r0.z);
    r2.x = r0.w ? _MainTex_TexelSize.x : 0;
    r3.y = r0.w ? 0 : _MainTex_TexelSize.y;
    r4.xy = r2.ww * float2(0.5,0.5) + r0.xy;
    r3.w = r0.w ? r0.x : r4.x;
    r4.x = r0.w ? r4.y : r0.y;
    r5.x = r3.w + -r2.x;
    r5.y = r4.x + -r3.y;
    r6.x = r3.w + r2.x;
    r6.y = r4.x + r3.y;
    r3.w = r0.z * -2 + 3;
    r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xy, 0).xyzw;
    r0.z = r0.z * r0.z;
    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xy, 0).xyzw;
    r2.y = r3.z ? r2.z : r2.y;
    r2.z = 0.25 * r3.x;
    r3.x = -r2.y * 0.5 + r1.y;
    r0.z = r3.w * r0.z;
    r3.x = cmp(r3.x < 0);
    r4.y = -r2.y * 0.5 + r4.y;
    r4.x = -r2.y * 0.5 + r7.y;
    r3.zw = cmp(abs(r4.yx) >= r2.zz);
    r5.z = r5.x + -r2.x;
    r5.x = r3.z ? r5.x : r5.z;
    r5.w = r5.y + -r3.y;
    r5.z = r3.z ? r5.y : r5.w;
    r5.yw = ~(int2)r3.zw;
    r5.y = (int)r5.w | (int)r5.y;
    r5.w = r6.x + r2.x;
    r6.x = r3.w ? r6.x : r5.w;
    r5.w = r6.y + r3.y;
    r6.z = r3.w ? r6.y : r5.w;
    [branch] if (r5.y != 0) {
      [branch] if (r3.z == 0) {
        r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
      } else {
        r7.x = r4.y;
      }
      [branch] if (r3.w == 0) {
        r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
      }
      r5.y = -r2.y * 0.5 + r7.x;
      r4.y = r3.z ? r7.x : r5.y;
      r3.z = -r2.y * 0.5 + r4.x;
      r4.x = r3.w ? r4.x : r3.z;
      r3.zw = cmp(abs(r4.yx) >= r2.zz);
      r5.y = r5.x + -r2.x;
      r5.x = r3.z ? r5.x : r5.y;
      r5.y = r5.z + -r3.y;
      r5.z = r3.z ? r5.z : r5.y;
      r5.yw = ~(int2)r3.zw;
      r5.y = (int)r5.w | (int)r5.y;
      r5.w = r6.x + r2.x;
      r6.x = r3.w ? r6.x : r5.w;
      r5.w = r6.z + r3.y;
      r6.z = r3.w ? r6.z : r5.w;
      [branch] if (r5.y != 0) {
        [branch] if (r3.z == 0) {
          r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
        } else {
          r7.x = r4.y;
        }
        [branch] if (r3.w == 0) {
          r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
        }
        r5.y = -r2.y * 0.5 + r7.x;
        r4.y = r3.z ? r7.x : r5.y;
        r3.z = -r2.y * 0.5 + r4.x;
        r4.x = r3.w ? r4.x : r3.z;
        r3.zw = cmp(abs(r4.yx) >= r2.zz);
        r5.y = r5.x + -r2.x;
        r5.x = r3.z ? r5.x : r5.y;
        r5.y = r5.z + -r3.y;
        r5.z = r3.z ? r5.z : r5.y;
        r5.yw = ~(int2)r3.zw;
        r5.y = (int)r5.w | (int)r5.y;
        r5.w = r6.x + r2.x;
        r6.x = r3.w ? r6.x : r5.w;
        r5.w = r6.z + r3.y;
        r6.z = r3.w ? r6.z : r5.w;
        [branch] if (r5.y != 0) {
          [branch] if (r3.z == 0) {
            r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
          } else {
            r7.x = r4.y;
          }
          [branch] if (r3.w == 0) {
            r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
          }
          r5.y = -r2.y * 0.5 + r7.x;
          r4.y = r3.z ? r7.x : r5.y;
          r3.z = -r2.y * 0.5 + r4.x;
          r4.x = r3.w ? r4.x : r3.z;
          r3.zw = cmp(abs(r4.yx) >= r2.zz);
          r5.y = r5.x + -r2.x;
          r5.x = r3.z ? r5.x : r5.y;
          r5.y = r5.z + -r3.y;
          r5.z = r3.z ? r5.z : r5.y;
          r5.yw = ~(int2)r3.zw;
          r5.y = (int)r5.w | (int)r5.y;
          r5.w = r6.x + r2.x;
          r6.x = r3.w ? r6.x : r5.w;
          r5.w = r6.z + r3.y;
          r6.z = r3.w ? r6.z : r5.w;
          [branch] if (r5.y != 0) {
            [branch] if (r3.z == 0) {
              r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
            } else {
              r7.x = r4.y;
            }
            [branch] if (r3.w == 0) {
              r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
            }
            r5.y = -r2.y * 0.5 + r7.x;
            r4.y = r3.z ? r7.x : r5.y;
            r3.z = -r2.y * 0.5 + r4.x;
            r4.x = r3.w ? r4.x : r3.z;
            r3.zw = cmp(abs(r4.yx) >= r2.zz);
            r5.y = -r2.x * 1.5 + r5.x;
            r5.x = r3.z ? r5.x : r5.y;
            r5.y = -r3.y * 1.5 + r5.z;
            r5.z = r3.z ? r5.z : r5.y;
            r5.yw = ~(int2)r3.zw;
            r5.y = (int)r5.w | (int)r5.y;
            r5.w = r2.x * 1.5 + r6.x;
            r6.x = r3.w ? r6.x : r5.w;
            r5.w = r3.y * 1.5 + r6.z;
            r6.z = r3.w ? r6.z : r5.w;
            [branch] if (r5.y != 0) {
              [branch] if (r3.z == 0) {
                r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
              } else {
                r7.x = r4.y;
              }
              [branch] if (r3.w == 0) {
                r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
              }
              r5.y = -r2.y * 0.5 + r7.x;
              r4.y = r3.z ? r7.x : r5.y;
              r3.z = -r2.y * 0.5 + r4.x;
              r4.x = r3.w ? r4.x : r3.z;
              r3.zw = cmp(abs(r4.yx) >= r2.zz);
              r5.y = -r2.x * 2 + r5.x;
              r5.x = r3.z ? r5.x : r5.y;
              r5.y = -r3.y * 2 + r5.z;
              r5.z = r3.z ? r5.z : r5.y;
              r5.yw = ~(int2)r3.zw;
              r5.y = (int)r5.w | (int)r5.y;
              r5.w = r2.x * 2 + r6.x;
              r6.x = r3.w ? r6.x : r5.w;
              r5.w = r3.y * 2 + r6.z;
              r6.z = r3.w ? r6.z : r5.w;
              [branch] if (r5.y != 0) {
                [branch] if (r3.z == 0) {
                  r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                } else {
                  r7.x = r4.y;
                }
                [branch] if (r3.w == 0) {
                  r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                }
                r5.y = -r2.y * 0.5 + r7.x;
                r4.y = r3.z ? r7.x : r5.y;
                r3.z = -r2.y * 0.5 + r4.x;
                r4.x = r3.w ? r4.x : r3.z;
                r3.zw = cmp(abs(r4.yx) >= r2.zz);
                r5.y = -r2.x * 2 + r5.x;
                r5.x = r3.z ? r5.x : r5.y;
                r5.y = -r3.y * 2 + r5.z;
                r5.z = r3.z ? r5.z : r5.y;
                r5.yw = ~(int2)r3.zw;
                r5.y = (int)r5.w | (int)r5.y;
                r5.w = r2.x * 2 + r6.x;
                r6.x = r3.w ? r6.x : r5.w;
                r5.w = r3.y * 2 + r6.z;
                r6.z = r3.w ? r6.z : r5.w;
                [branch] if (r5.y != 0) {
                  [branch] if (r3.z == 0) {
                    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                  } else {
                    r7.x = r4.y;
                  }
                  [branch] if (r3.w == 0) {
                    r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                  }
                  r5.y = -r2.y * 0.5 + r7.x;
                  r4.y = r3.z ? r7.x : r5.y;
                  r3.z = -r2.y * 0.5 + r4.x;
                  r4.x = r3.w ? r4.x : r3.z;
                  r3.zw = cmp(abs(r4.yx) >= r2.zz);
                  r5.y = -r2.x * 2 + r5.x;
                  r5.x = r3.z ? r5.x : r5.y;
                  r5.y = -r3.y * 2 + r5.z;
                  r5.z = r3.z ? r5.z : r5.y;
                  r5.yw = ~(int2)r3.zw;
                  r5.y = (int)r5.w | (int)r5.y;
                  r5.w = r2.x * 2 + r6.x;
                  r6.x = r3.w ? r6.x : r5.w;
                  r5.w = r3.y * 2 + r6.z;
                  r6.z = r3.w ? r6.z : r5.w;
                  [branch] if (r5.y != 0) {
                    [branch] if (r3.z == 0) {
                      r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                    } else {
                      r7.x = r4.y;
                    }
                    [branch] if (r3.w == 0) {
                      r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                    }
                    r5.y = -r2.y * 0.5 + r7.x;
                    r4.y = r3.z ? r7.x : r5.y;
                    r3.z = -r2.y * 0.5 + r4.x;
                    r4.x = r3.w ? r4.x : r3.z;
                    r3.zw = cmp(abs(r4.yx) >= r2.zz);
                    r5.y = -r2.x * 2 + r5.x;
                    r5.x = r3.z ? r5.x : r5.y;
                    r5.y = -r3.y * 2 + r5.z;
                    r5.z = r3.z ? r5.z : r5.y;
                    r5.yw = ~(int2)r3.zw;
                    r5.y = (int)r5.w | (int)r5.y;
                    r5.w = r2.x * 2 + r6.x;
                    r6.x = r3.w ? r6.x : r5.w;
                    r5.w = r3.y * 2 + r6.z;
                    r6.z = r3.w ? r6.z : r5.w;
                    [branch] if (r5.y != 0) {
                      [branch] if (r3.z == 0) {
                        r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                      } else {
                        r7.x = r4.y;
                      }
                      [branch] if (r3.w == 0) {
                        r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                      }
                      r5.y = -r2.y * 0.5 + r7.x;
                      r4.y = r3.z ? r7.x : r5.y;
                      r3.z = -r2.y * 0.5 + r4.x;
                      r4.x = r3.w ? r4.x : r3.z;
                      r3.zw = cmp(abs(r4.yx) >= r2.zz);
                      r5.y = -r2.x * 4 + r5.x;
                      r5.x = r3.z ? r5.x : r5.y;
                      r5.y = -r3.y * 4 + r5.z;
                      r5.z = r3.z ? r5.z : r5.y;
                      r5.yw = ~(int2)r3.zw;
                      r5.y = (int)r5.w | (int)r5.y;
                      r5.w = r2.x * 4 + r6.x;
                      r6.x = r3.w ? r6.x : r5.w;
                      r5.w = r3.y * 4 + r6.z;
                      r6.z = r3.w ? r6.z : r5.w;
                      [branch] if (r5.y != 0) {
                        [branch] if (r3.z == 0) {
                          r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                        } else {
                          r7.x = r4.y;
                        }
                        [branch] if (r3.w == 0) {
                          r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                        }
                        r4.z = -r2.y * 0.5 + r7.x;
                        r4.y = r3.z ? r7.x : r4.z;
                        r2.y = -r2.y * 0.5 + r4.x;
                        r4.x = r3.w ? r4.x : r2.y;
                        r2.yz = cmp(abs(r4.yx) >= r2.zz);
                        r3.z = -r2.x * 8 + r5.x;
                        r5.x = r2.y ? r5.x : r3.z;
                        r3.z = -r3.y * 8 + r5.z;
                        r5.z = r2.y ? r5.z : r3.z;
                        r2.x = r2.x * 8 + r6.x;
                        r6.x = r2.z ? r6.x : r2.x;
                        r2.x = r3.y * 8 + r6.z;
                        r6.z = r2.z ? r6.z : r2.x;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    r2.xz = -r5.xz + r0.xy;
    r2.x = r0.w ? r2.x : r2.z;
    r2.yz = r6.xz + -r0.xy;
    r2.y = r0.w ? r2.y : r2.z;
    r3.yz = cmp(r4.yx < float2(0,0));
    r2.z = r2.y + r2.x;
    r3.xy = cmp((int2)r3.xx != (int2)r3.yz);
    r2.z = 1 / r2.z;
    r3.z = cmp(r2.x < r2.y);
    r2.x = min(r2.x, r2.y);
    r2.y = r3.z ? r3.x : r3.y;
    r0.z = r0.z * r0.z;
    r2.x = r2.x * -r2.z + 0.5;
    r0.z = _QualitySettings.x * r0.z;
    r2.x = asfloat(asint(r2.x) & (int)r2.y);
    r0.z = max(r2.x, r0.z);
    r2.xy = r0.zz * r2.ww + r0.xy;
    r3.x = r0.w ? r0.x : r2.x;
    r3.y = r0.w ? r2.y : r0.y;
    r0.xyzw = _MainTex.SampleLevel(sampler_MainTex, r3.xy, 0).xyzw;
    r1.w = r1.y;
  } else {
    r0.xyz = r1.xyz;
  }
  r2.xy = v1.xy * _DitheringCoords.xy + _DitheringCoords.zw;
  r2.xyzw = _DitheringTex.Sample(sampler_DitheringTex, r2.xy).xyzw;
  r0.w = r2.w * 2 + -1;
  r2.x = cmp(0 < r0.w);
  r2.y = cmp(r0.w < 0);
  r2.x = (int)-r2.x + (int)r2.y;
  r2.x = (int)r2.x;
  r0.w = 1 + -abs(r0.w);
  r0.w = sqrt(r0.w);
  r0.w = 1 + -r0.w;
  r0.w = r2.x * r0.w;
  r1.xyz = r0.www * float3(0.00392156886,0.00392156886,0.00392156886) + r0.xyz;
  o0.xyzw = r1.xyzw;
  return;
}


// ps f56cec8e25a4228a: 1 retail keyword combination(s)
void ps_f56cec8e25a4228a_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.SampleLevel(sampler_MainTex, r0.xy, 0).xyzw;
  r2.xyzw = _MainTex_TexelSize.xyxy * float4(0,1,1,0) + r0.xyxy;
  r3.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xy, 0).xyzw;
  r2.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.zw, 0).xyzw;
  r4.xyzw = _MainTex_TexelSize.xyxy * float4(0,-1,-1,0) + r0.xyxy;
  r5.xyzw = _MainTex.SampleLevel(sampler_MainTex, r4.xy, 0).xyzw;
  r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r4.zw, 0).xyzw;
  r0.z = max(r3.y, r1.y);
  r0.w = min(r3.y, r1.y);
  r0.z = max(r2.y, r0.z);
  r0.w = min(r2.y, r0.w);
  r2.x = max(r5.y, r4.y);
  r2.z = min(r5.y, r4.y);
  r0.z = max(r2.x, r0.z);
  r0.w = min(r2.z, r0.w);
  r2.x = _QualitySettings.y * r0.z;
  r0.z = r0.z + -r0.w;
  r0.w = max(_QualitySettings.z, r2.x);
  r0.w = cmp(r0.z >= r0.w);
  [branch] if (r0.w != 0) {
    r2.xz = -_MainTex_TexelSize.xy + r0.xy;
    r6.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xz, 0).xyzw;
    r2.xz = _MainTex_TexelSize.xy + r0.xy;
    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xz, 0).xyzw;
    r8.xyzw = _MainTex_TexelSize.xyxy * float4(1,-1,-1,1) + r0.xyxy;
    r9.xyzw = _MainTex.SampleLevel(sampler_MainTex, r8.xy, 0).xyzw;
    r8.xyzw = _MainTex.SampleLevel(sampler_MainTex, r8.zw, 0).xyzw;
    r0.w = r5.y + r3.y;
    r2.x = r4.y + r2.y;
    r0.z = 1 / r0.z;
    r2.z = r2.x + r0.w;
    r0.w = r1.y * -2 + r0.w;
    r2.x = r1.y * -2 + r2.x;
    r2.w = r9.y + r7.y;
    r3.x = r9.y + r6.y;
    r3.z = r2.y * -2 + r2.w;
    r3.x = r5.y * -2 + r3.x;
    r3.w = r8.y + r6.y;
    r4.x = r8.y + r7.y;
    r0.w = abs(r0.w) * 2 + abs(r3.z);
    r2.x = abs(r2.x) * 2 + abs(r3.x);
    r3.x = r4.y * -2 + r3.w;
    r3.z = r3.y * -2 + r4.x;
    r0.w = abs(r3.x) + r0.w;
    r2.x = abs(r3.z) + r2.x;
    r2.w = r3.w + r2.w;
    r0.w = cmp(r0.w >= r2.x);
    r2.x = r2.z * 2 + r2.w;
    r2.z = r0.w ? r5.y : r4.y;
    r2.y = r0.w ? r3.y : r2.y;
    r2.w = r0.w ? _MainTex_TexelSize.y : _MainTex_TexelSize.x;
    r2.x = r2.x * 0.0833333358 + -r1.y;
    r3.xy = r2.zy + -r1.yy;
    r2.yz = r2.yz + r1.yy;
    r3.z = cmp(abs(r3.x) >= abs(r3.y));
    r3.x = max(abs(r3.x), abs(r3.y));
    r2.w = r3.z ? -r2.w : r2.w;
    r0.z = saturate(abs(r2.x) * r0.z);
    r2.x = r0.w ? _MainTex_TexelSize.x : 0;
    r3.y = r0.w ? 0 : _MainTex_TexelSize.y;
    r4.xy = r2.ww * float2(0.5,0.5) + r0.xy;
    r3.w = r0.w ? r0.x : r4.x;
    r4.x = r0.w ? r4.y : r0.y;
    r5.x = r3.w + -r2.x;
    r5.y = r4.x + -r3.y;
    r6.x = r3.w + r2.x;
    r6.y = r4.x + r3.y;
    r3.w = r0.z * -2 + 3;
    r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xy, 0).xyzw;
    r0.z = r0.z * r0.z;
    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xy, 0).xyzw;
    r2.y = r3.z ? r2.z : r2.y;
    r2.z = 0.25 * r3.x;
    r3.x = -r2.y * 0.5 + r1.y;
    r0.z = r3.w * r0.z;
    r3.x = cmp(r3.x < 0);
    r4.y = -r2.y * 0.5 + r4.y;
    r4.x = -r2.y * 0.5 + r7.y;
    r3.zw = cmp(abs(r4.yx) >= r2.zz);
    r5.z = r5.x + -r2.x;
    r5.x = r3.z ? r5.x : r5.z;
    r5.w = r5.y + -r3.y;
    r5.z = r3.z ? r5.y : r5.w;
    r5.yw = ~(int2)r3.zw;
    r5.y = (int)r5.w | (int)r5.y;
    r5.w = r6.x + r2.x;
    r6.x = r3.w ? r6.x : r5.w;
    r5.w = r6.y + r3.y;
    r6.z = r3.w ? r6.y : r5.w;
    [branch] if (r5.y != 0) {
      [branch] if (r3.z == 0) {
        r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
      } else {
        r7.x = r4.y;
      }
      [branch] if (r3.w == 0) {
        r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
      }
      r5.y = -r2.y * 0.5 + r7.x;
      r4.y = r3.z ? r7.x : r5.y;
      r3.z = -r2.y * 0.5 + r4.x;
      r4.x = r3.w ? r4.x : r3.z;
      r3.zw = cmp(abs(r4.yx) >= r2.zz);
      r5.y = r5.x + -r2.x;
      r5.x = r3.z ? r5.x : r5.y;
      r5.y = r5.z + -r3.y;
      r5.z = r3.z ? r5.z : r5.y;
      r5.yw = ~(int2)r3.zw;
      r5.y = (int)r5.w | (int)r5.y;
      r5.w = r6.x + r2.x;
      r6.x = r3.w ? r6.x : r5.w;
      r5.w = r6.z + r3.y;
      r6.z = r3.w ? r6.z : r5.w;
      [branch] if (r5.y != 0) {
        [branch] if (r3.z == 0) {
          r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
        } else {
          r7.x = r4.y;
        }
        [branch] if (r3.w == 0) {
          r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
        }
        r5.y = -r2.y * 0.5 + r7.x;
        r4.y = r3.z ? r7.x : r5.y;
        r3.z = -r2.y * 0.5 + r4.x;
        r4.x = r3.w ? r4.x : r3.z;
        r3.zw = cmp(abs(r4.yx) >= r2.zz);
        r5.y = r5.x + -r2.x;
        r5.x = r3.z ? r5.x : r5.y;
        r5.y = r5.z + -r3.y;
        r5.z = r3.z ? r5.z : r5.y;
        r5.yw = ~(int2)r3.zw;
        r5.y = (int)r5.w | (int)r5.y;
        r5.w = r6.x + r2.x;
        r6.x = r3.w ? r6.x : r5.w;
        r5.w = r6.z + r3.y;
        r6.z = r3.w ? r6.z : r5.w;
        [branch] if (r5.y != 0) {
          [branch] if (r3.z == 0) {
            r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
          } else {
            r7.x = r4.y;
          }
          [branch] if (r3.w == 0) {
            r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
          }
          r5.y = -r2.y * 0.5 + r7.x;
          r4.y = r3.z ? r7.x : r5.y;
          r3.z = -r2.y * 0.5 + r4.x;
          r4.x = r3.w ? r4.x : r3.z;
          r3.zw = cmp(abs(r4.yx) >= r2.zz);
          r5.y = r5.x + -r2.x;
          r5.x = r3.z ? r5.x : r5.y;
          r5.y = r5.z + -r3.y;
          r5.z = r3.z ? r5.z : r5.y;
          r5.yw = ~(int2)r3.zw;
          r5.y = (int)r5.w | (int)r5.y;
          r5.w = r6.x + r2.x;
          r6.x = r3.w ? r6.x : r5.w;
          r5.w = r6.z + r3.y;
          r6.z = r3.w ? r6.z : r5.w;
          [branch] if (r5.y != 0) {
            [branch] if (r3.z == 0) {
              r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
            } else {
              r7.x = r4.y;
            }
            [branch] if (r3.w == 0) {
              r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
            }
            r5.y = -r2.y * 0.5 + r7.x;
            r4.y = r3.z ? r7.x : r5.y;
            r3.z = -r2.y * 0.5 + r4.x;
            r4.x = r3.w ? r4.x : r3.z;
            r3.zw = cmp(abs(r4.yx) >= r2.zz);
            r5.y = -r2.x * 1.5 + r5.x;
            r5.x = r3.z ? r5.x : r5.y;
            r5.y = -r3.y * 1.5 + r5.z;
            r5.z = r3.z ? r5.z : r5.y;
            r5.yw = ~(int2)r3.zw;
            r5.y = (int)r5.w | (int)r5.y;
            r5.w = r2.x * 1.5 + r6.x;
            r6.x = r3.w ? r6.x : r5.w;
            r5.w = r3.y * 1.5 + r6.z;
            r6.z = r3.w ? r6.z : r5.w;
            [branch] if (r5.y != 0) {
              [branch] if (r3.z == 0) {
                r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
              } else {
                r7.x = r4.y;
              }
              [branch] if (r3.w == 0) {
                r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
              }
              r5.y = -r2.y * 0.5 + r7.x;
              r4.y = r3.z ? r7.x : r5.y;
              r3.z = -r2.y * 0.5 + r4.x;
              r4.x = r3.w ? r4.x : r3.z;
              r3.zw = cmp(abs(r4.yx) >= r2.zz);
              r5.y = -r2.x * 2 + r5.x;
              r5.x = r3.z ? r5.x : r5.y;
              r5.y = -r3.y * 2 + r5.z;
              r5.z = r3.z ? r5.z : r5.y;
              r5.yw = ~(int2)r3.zw;
              r5.y = (int)r5.w | (int)r5.y;
              r5.w = r2.x * 2 + r6.x;
              r6.x = r3.w ? r6.x : r5.w;
              r5.w = r3.y * 2 + r6.z;
              r6.z = r3.w ? r6.z : r5.w;
              [branch] if (r5.y != 0) {
                [branch] if (r3.z == 0) {
                  r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                } else {
                  r7.x = r4.y;
                }
                [branch] if (r3.w == 0) {
                  r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                }
                r5.y = -r2.y * 0.5 + r7.x;
                r4.y = r3.z ? r7.x : r5.y;
                r3.z = -r2.y * 0.5 + r4.x;
                r4.x = r3.w ? r4.x : r3.z;
                r3.zw = cmp(abs(r4.yx) >= r2.zz);
                r5.y = -r2.x * 2 + r5.x;
                r5.x = r3.z ? r5.x : r5.y;
                r5.y = -r3.y * 2 + r5.z;
                r5.z = r3.z ? r5.z : r5.y;
                r5.yw = ~(int2)r3.zw;
                r5.y = (int)r5.w | (int)r5.y;
                r5.w = r2.x * 2 + r6.x;
                r6.x = r3.w ? r6.x : r5.w;
                r5.w = r3.y * 2 + r6.z;
                r6.z = r3.w ? r6.z : r5.w;
                [branch] if (r5.y != 0) {
                  [branch] if (r3.z == 0) {
                    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                  } else {
                    r7.x = r4.y;
                  }
                  [branch] if (r3.w == 0) {
                    r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                  }
                  r5.y = -r2.y * 0.5 + r7.x;
                  r4.y = r3.z ? r7.x : r5.y;
                  r3.z = -r2.y * 0.5 + r4.x;
                  r4.x = r3.w ? r4.x : r3.z;
                  r3.zw = cmp(abs(r4.yx) >= r2.zz);
                  r5.y = -r2.x * 2 + r5.x;
                  r5.x = r3.z ? r5.x : r5.y;
                  r5.y = -r3.y * 2 + r5.z;
                  r5.z = r3.z ? r5.z : r5.y;
                  r5.yw = ~(int2)r3.zw;
                  r5.y = (int)r5.w | (int)r5.y;
                  r5.w = r2.x * 2 + r6.x;
                  r6.x = r3.w ? r6.x : r5.w;
                  r5.w = r3.y * 2 + r6.z;
                  r6.z = r3.w ? r6.z : r5.w;
                  [branch] if (r5.y != 0) {
                    [branch] if (r3.z == 0) {
                      r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                    } else {
                      r7.x = r4.y;
                    }
                    [branch] if (r3.w == 0) {
                      r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                    }
                    r5.y = -r2.y * 0.5 + r7.x;
                    r4.y = r3.z ? r7.x : r5.y;
                    r3.z = -r2.y * 0.5 + r4.x;
                    r4.x = r3.w ? r4.x : r3.z;
                    r3.zw = cmp(abs(r4.yx) >= r2.zz);
                    r5.y = -r2.x * 2 + r5.x;
                    r5.x = r3.z ? r5.x : r5.y;
                    r5.y = -r3.y * 2 + r5.z;
                    r5.z = r3.z ? r5.z : r5.y;
                    r5.yw = ~(int2)r3.zw;
                    r5.y = (int)r5.w | (int)r5.y;
                    r5.w = r2.x * 2 + r6.x;
                    r6.x = r3.w ? r6.x : r5.w;
                    r5.w = r3.y * 2 + r6.z;
                    r6.z = r3.w ? r6.z : r5.w;
                    [branch] if (r5.y != 0) {
                      [branch] if (r3.z == 0) {
                        r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                      } else {
                        r7.x = r4.y;
                      }
                      [branch] if (r3.w == 0) {
                        r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                      }
                      r5.y = -r2.y * 0.5 + r7.x;
                      r4.y = r3.z ? r7.x : r5.y;
                      r3.z = -r2.y * 0.5 + r4.x;
                      r4.x = r3.w ? r4.x : r3.z;
                      r3.zw = cmp(abs(r4.yx) >= r2.zz);
                      r5.y = -r2.x * 4 + r5.x;
                      r5.x = r3.z ? r5.x : r5.y;
                      r5.y = -r3.y * 4 + r5.z;
                      r5.z = r3.z ? r5.z : r5.y;
                      r5.yw = ~(int2)r3.zw;
                      r5.y = (int)r5.w | (int)r5.y;
                      r5.w = r2.x * 4 + r6.x;
                      r6.x = r3.w ? r6.x : r5.w;
                      r5.w = r3.y * 4 + r6.z;
                      r6.z = r3.w ? r6.z : r5.w;
                      [branch] if (r5.y != 0) {
                        [branch] if (r3.z == 0) {
                          r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                        } else {
                          r7.x = r4.y;
                        }
                        [branch] if (r3.w == 0) {
                          r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                        }
                        r4.z = -r2.y * 0.5 + r7.x;
                        r4.y = r3.z ? r7.x : r4.z;
                        r2.y = -r2.y * 0.5 + r4.x;
                        r4.x = r3.w ? r4.x : r2.y;
                        r2.yz = cmp(abs(r4.yx) >= r2.zz);
                        r3.z = -r2.x * 8 + r5.x;
                        r5.x = r2.y ? r5.x : r3.z;
                        r3.z = -r3.y * 8 + r5.z;
                        r5.z = r2.y ? r5.z : r3.z;
                        r2.x = r2.x * 8 + r6.x;
                        r6.x = r2.z ? r6.x : r2.x;
                        r2.x = r3.y * 8 + r6.z;
                        r6.z = r2.z ? r6.z : r2.x;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    r2.xz = -r5.xz + r0.xy;
    r2.x = r0.w ? r2.x : r2.z;
    r2.yz = r6.xz + -r0.xy;
    r2.y = r0.w ? r2.y : r2.z;
    r3.yz = cmp(r4.yx < float2(0,0));
    r2.z = r2.y + r2.x;
    r3.xy = cmp((int2)r3.xx != (int2)r3.yz);
    r2.z = 1 / r2.z;
    r3.z = cmp(r2.x < r2.y);
    r2.x = min(r2.x, r2.y);
    r2.y = r3.z ? r3.x : r3.y;
    r0.z = r0.z * r0.z;
    r2.x = r2.x * -r2.z + 0.5;
    r0.z = _QualitySettings.x * r0.z;
    r2.x = asfloat(asint(r2.x) & (int)r2.y);
    r0.z = max(r2.x, r0.z);
    r2.xy = r0.zz * r2.ww + r0.xy;
    r3.x = r0.w ? r0.x : r2.x;
    r3.y = r0.w ? r2.y : r0.y;
    r0.xyzw = _MainTex.SampleLevel(sampler_MainTex, r3.xy, 0).xyzw;
    r1.w = r1.y;
  } else {
    r0.xyz = r1.xyz;
  }
  r2.xy = v1.xy * _Grain_Params2.xy + _Grain_Params2.zw;
  r2.xyzw = _GrainTex.Sample(sampler_GrainTex, r2.xy).xyzw;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r0.w = sqrt(r0.w);
  r0.w = _Grain_Params1.x * -r0.w + 1;
  r2.xyz = r2.xyz * r0.xyz;
  r2.xyz = _Grain_Params1.yyy * r2.xyz;
  r1.xyz = r2.xyz * r0.www + r0.xyz;
  o0.xyzw = r1.xyzw;
  return;
}


// ps 75d14389449fca48: 1 retail keyword combination(s)
void ps_75d14389449fca48_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  r1.xyzw = _MainTex.SampleLevel(sampler_MainTex, r0.xy, 0).xyzw;
  r2.xyzw = _MainTex_TexelSize.xyxy * float4(0,1,1,0) + r0.xyxy;
  r3.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xy, 0).xyzw;
  r2.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.zw, 0).xyzw;
  r4.xyzw = _MainTex_TexelSize.xyxy * float4(0,-1,-1,0) + r0.xyxy;
  r5.xyzw = _MainTex.SampleLevel(sampler_MainTex, r4.xy, 0).xyzw;
  r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r4.zw, 0).xyzw;
  r0.z = max(r3.y, r1.y);
  r0.w = min(r3.y, r1.y);
  r0.z = max(r2.y, r0.z);
  r0.w = min(r2.y, r0.w);
  r2.x = max(r5.y, r4.y);
  r2.z = min(r5.y, r4.y);
  r0.z = max(r2.x, r0.z);
  r0.w = min(r2.z, r0.w);
  r2.x = _QualitySettings.y * r0.z;
  r0.z = r0.z + -r0.w;
  r0.w = max(_QualitySettings.z, r2.x);
  r0.w = cmp(r0.z >= r0.w);
  [branch] if (r0.w != 0) {
    r2.xz = -_MainTex_TexelSize.xy + r0.xy;
    r6.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xz, 0).xyzw;
    r2.xz = _MainTex_TexelSize.xy + r0.xy;
    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r2.xz, 0).xyzw;
    r8.xyzw = _MainTex_TexelSize.xyxy * float4(1,-1,-1,1) + r0.xyxy;
    r9.xyzw = _MainTex.SampleLevel(sampler_MainTex, r8.xy, 0).xyzw;
    r8.xyzw = _MainTex.SampleLevel(sampler_MainTex, r8.zw, 0).xyzw;
    r0.w = r5.y + r3.y;
    r2.x = r4.y + r2.y;
    r0.z = 1 / r0.z;
    r2.z = r2.x + r0.w;
    r0.w = r1.y * -2 + r0.w;
    r2.x = r1.y * -2 + r2.x;
    r2.w = r9.y + r7.y;
    r3.x = r9.y + r6.y;
    r3.z = r2.y * -2 + r2.w;
    r3.x = r5.y * -2 + r3.x;
    r3.w = r8.y + r6.y;
    r4.x = r8.y + r7.y;
    r0.w = abs(r0.w) * 2 + abs(r3.z);
    r2.x = abs(r2.x) * 2 + abs(r3.x);
    r3.x = r4.y * -2 + r3.w;
    r3.z = r3.y * -2 + r4.x;
    r0.w = abs(r3.x) + r0.w;
    r2.x = abs(r3.z) + r2.x;
    r2.w = r3.w + r2.w;
    r0.w = cmp(r0.w >= r2.x);
    r2.x = r2.z * 2 + r2.w;
    r2.z = r0.w ? r5.y : r4.y;
    r2.y = r0.w ? r3.y : r2.y;
    r2.w = r0.w ? _MainTex_TexelSize.y : _MainTex_TexelSize.x;
    r2.x = r2.x * 0.0833333358 + -r1.y;
    r3.xy = r2.zy + -r1.yy;
    r2.yz = r2.yz + r1.yy;
    r3.z = cmp(abs(r3.x) >= abs(r3.y));
    r3.x = max(abs(r3.x), abs(r3.y));
    r2.w = r3.z ? -r2.w : r2.w;
    r0.z = saturate(abs(r2.x) * r0.z);
    r2.x = r0.w ? _MainTex_TexelSize.x : 0;
    r3.y = r0.w ? 0 : _MainTex_TexelSize.y;
    r4.xy = r2.ww * float2(0.5,0.5) + r0.xy;
    r3.w = r0.w ? r0.x : r4.x;
    r4.x = r0.w ? r4.y : r0.y;
    r5.x = r3.w + -r2.x;
    r5.y = r4.x + -r3.y;
    r6.x = r3.w + r2.x;
    r6.y = r4.x + r3.y;
    r3.w = r0.z * -2 + 3;
    r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xy, 0).xyzw;
    r0.z = r0.z * r0.z;
    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xy, 0).xyzw;
    r2.y = r3.z ? r2.z : r2.y;
    r2.z = 0.25 * r3.x;
    r3.x = -r2.y * 0.5 + r1.y;
    r0.z = r3.w * r0.z;
    r3.x = cmp(r3.x < 0);
    r4.y = -r2.y * 0.5 + r4.y;
    r4.x = -r2.y * 0.5 + r7.y;
    r3.zw = cmp(abs(r4.yx) >= r2.zz);
    r5.z = r5.x + -r2.x;
    r5.x = r3.z ? r5.x : r5.z;
    r5.w = r5.y + -r3.y;
    r5.z = r3.z ? r5.y : r5.w;
    r5.yw = ~(int2)r3.zw;
    r5.y = (int)r5.w | (int)r5.y;
    r5.w = r6.x + r2.x;
    r6.x = r3.w ? r6.x : r5.w;
    r5.w = r6.y + r3.y;
    r6.z = r3.w ? r6.y : r5.w;
    [branch] if (r5.y != 0) {
      [branch] if (r3.z == 0) {
        r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
      } else {
        r7.x = r4.y;
      }
      [branch] if (r3.w == 0) {
        r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
      }
      r5.y = -r2.y * 0.5 + r7.x;
      r4.y = r3.z ? r7.x : r5.y;
      r3.z = -r2.y * 0.5 + r4.x;
      r4.x = r3.w ? r4.x : r3.z;
      r3.zw = cmp(abs(r4.yx) >= r2.zz);
      r5.y = r5.x + -r2.x;
      r5.x = r3.z ? r5.x : r5.y;
      r5.y = r5.z + -r3.y;
      r5.z = r3.z ? r5.z : r5.y;
      r5.yw = ~(int2)r3.zw;
      r5.y = (int)r5.w | (int)r5.y;
      r5.w = r6.x + r2.x;
      r6.x = r3.w ? r6.x : r5.w;
      r5.w = r6.z + r3.y;
      r6.z = r3.w ? r6.z : r5.w;
      [branch] if (r5.y != 0) {
        [branch] if (r3.z == 0) {
          r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
        } else {
          r7.x = r4.y;
        }
        [branch] if (r3.w == 0) {
          r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
        }
        r5.y = -r2.y * 0.5 + r7.x;
        r4.y = r3.z ? r7.x : r5.y;
        r3.z = -r2.y * 0.5 + r4.x;
        r4.x = r3.w ? r4.x : r3.z;
        r3.zw = cmp(abs(r4.yx) >= r2.zz);
        r5.y = r5.x + -r2.x;
        r5.x = r3.z ? r5.x : r5.y;
        r5.y = r5.z + -r3.y;
        r5.z = r3.z ? r5.z : r5.y;
        r5.yw = ~(int2)r3.zw;
        r5.y = (int)r5.w | (int)r5.y;
        r5.w = r6.x + r2.x;
        r6.x = r3.w ? r6.x : r5.w;
        r5.w = r6.z + r3.y;
        r6.z = r3.w ? r6.z : r5.w;
        [branch] if (r5.y != 0) {
          [branch] if (r3.z == 0) {
            r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
          } else {
            r7.x = r4.y;
          }
          [branch] if (r3.w == 0) {
            r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
          }
          r5.y = -r2.y * 0.5 + r7.x;
          r4.y = r3.z ? r7.x : r5.y;
          r3.z = -r2.y * 0.5 + r4.x;
          r4.x = r3.w ? r4.x : r3.z;
          r3.zw = cmp(abs(r4.yx) >= r2.zz);
          r5.y = r5.x + -r2.x;
          r5.x = r3.z ? r5.x : r5.y;
          r5.y = r5.z + -r3.y;
          r5.z = r3.z ? r5.z : r5.y;
          r5.yw = ~(int2)r3.zw;
          r5.y = (int)r5.w | (int)r5.y;
          r5.w = r6.x + r2.x;
          r6.x = r3.w ? r6.x : r5.w;
          r5.w = r6.z + r3.y;
          r6.z = r3.w ? r6.z : r5.w;
          [branch] if (r5.y != 0) {
            [branch] if (r3.z == 0) {
              r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
            } else {
              r7.x = r4.y;
            }
            [branch] if (r3.w == 0) {
              r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
            }
            r5.y = -r2.y * 0.5 + r7.x;
            r4.y = r3.z ? r7.x : r5.y;
            r3.z = -r2.y * 0.5 + r4.x;
            r4.x = r3.w ? r4.x : r3.z;
            r3.zw = cmp(abs(r4.yx) >= r2.zz);
            r5.y = -r2.x * 1.5 + r5.x;
            r5.x = r3.z ? r5.x : r5.y;
            r5.y = -r3.y * 1.5 + r5.z;
            r5.z = r3.z ? r5.z : r5.y;
            r5.yw = ~(int2)r3.zw;
            r5.y = (int)r5.w | (int)r5.y;
            r5.w = r2.x * 1.5 + r6.x;
            r6.x = r3.w ? r6.x : r5.w;
            r5.w = r3.y * 1.5 + r6.z;
            r6.z = r3.w ? r6.z : r5.w;
            [branch] if (r5.y != 0) {
              [branch] if (r3.z == 0) {
                r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
              } else {
                r7.x = r4.y;
              }
              [branch] if (r3.w == 0) {
                r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
              }
              r5.y = -r2.y * 0.5 + r7.x;
              r4.y = r3.z ? r7.x : r5.y;
              r3.z = -r2.y * 0.5 + r4.x;
              r4.x = r3.w ? r4.x : r3.z;
              r3.zw = cmp(abs(r4.yx) >= r2.zz);
              r5.y = -r2.x * 2 + r5.x;
              r5.x = r3.z ? r5.x : r5.y;
              r5.y = -r3.y * 2 + r5.z;
              r5.z = r3.z ? r5.z : r5.y;
              r5.yw = ~(int2)r3.zw;
              r5.y = (int)r5.w | (int)r5.y;
              r5.w = r2.x * 2 + r6.x;
              r6.x = r3.w ? r6.x : r5.w;
              r5.w = r3.y * 2 + r6.z;
              r6.z = r3.w ? r6.z : r5.w;
              [branch] if (r5.y != 0) {
                [branch] if (r3.z == 0) {
                  r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                } else {
                  r7.x = r4.y;
                }
                [branch] if (r3.w == 0) {
                  r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                }
                r5.y = -r2.y * 0.5 + r7.x;
                r4.y = r3.z ? r7.x : r5.y;
                r3.z = -r2.y * 0.5 + r4.x;
                r4.x = r3.w ? r4.x : r3.z;
                r3.zw = cmp(abs(r4.yx) >= r2.zz);
                r5.y = -r2.x * 2 + r5.x;
                r5.x = r3.z ? r5.x : r5.y;
                r5.y = -r3.y * 2 + r5.z;
                r5.z = r3.z ? r5.z : r5.y;
                r5.yw = ~(int2)r3.zw;
                r5.y = (int)r5.w | (int)r5.y;
                r5.w = r2.x * 2 + r6.x;
                r6.x = r3.w ? r6.x : r5.w;
                r5.w = r3.y * 2 + r6.z;
                r6.z = r3.w ? r6.z : r5.w;
                [branch] if (r5.y != 0) {
                  [branch] if (r3.z == 0) {
                    r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                  } else {
                    r7.x = r4.y;
                  }
                  [branch] if (r3.w == 0) {
                    r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                  }
                  r5.y = -r2.y * 0.5 + r7.x;
                  r4.y = r3.z ? r7.x : r5.y;
                  r3.z = -r2.y * 0.5 + r4.x;
                  r4.x = r3.w ? r4.x : r3.z;
                  r3.zw = cmp(abs(r4.yx) >= r2.zz);
                  r5.y = -r2.x * 2 + r5.x;
                  r5.x = r3.z ? r5.x : r5.y;
                  r5.y = -r3.y * 2 + r5.z;
                  r5.z = r3.z ? r5.z : r5.y;
                  r5.yw = ~(int2)r3.zw;
                  r5.y = (int)r5.w | (int)r5.y;
                  r5.w = r2.x * 2 + r6.x;
                  r6.x = r3.w ? r6.x : r5.w;
                  r5.w = r3.y * 2 + r6.z;
                  r6.z = r3.w ? r6.z : r5.w;
                  [branch] if (r5.y != 0) {
                    [branch] if (r3.z == 0) {
                      r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                    } else {
                      r7.x = r4.y;
                    }
                    [branch] if (r3.w == 0) {
                      r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                    }
                    r5.y = -r2.y * 0.5 + r7.x;
                    r4.y = r3.z ? r7.x : r5.y;
                    r3.z = -r2.y * 0.5 + r4.x;
                    r4.x = r3.w ? r4.x : r3.z;
                    r3.zw = cmp(abs(r4.yx) >= r2.zz);
                    r5.y = -r2.x * 2 + r5.x;
                    r5.x = r3.z ? r5.x : r5.y;
                    r5.y = -r3.y * 2 + r5.z;
                    r5.z = r3.z ? r5.z : r5.y;
                    r5.yw = ~(int2)r3.zw;
                    r5.y = (int)r5.w | (int)r5.y;
                    r5.w = r2.x * 2 + r6.x;
                    r6.x = r3.w ? r6.x : r5.w;
                    r5.w = r3.y * 2 + r6.z;
                    r6.z = r3.w ? r6.z : r5.w;
                    [branch] if (r5.y != 0) {
                      [branch] if (r3.z == 0) {
                        r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                      } else {
                        r7.x = r4.y;
                      }
                      [branch] if (r3.w == 0) {
                        r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                      }
                      r5.y = -r2.y * 0.5 + r7.x;
                      r4.y = r3.z ? r7.x : r5.y;
                      r3.z = -r2.y * 0.5 + r4.x;
                      r4.x = r3.w ? r4.x : r3.z;
                      r3.zw = cmp(abs(r4.yx) >= r2.zz);
                      r5.y = -r2.x * 4 + r5.x;
                      r5.x = r3.z ? r5.x : r5.y;
                      r5.y = -r3.y * 4 + r5.z;
                      r5.z = r3.z ? r5.z : r5.y;
                      r5.yw = ~(int2)r3.zw;
                      r5.y = (int)r5.w | (int)r5.y;
                      r5.w = r2.x * 4 + r6.x;
                      r6.x = r3.w ? r6.x : r5.w;
                      r5.w = r3.y * 4 + r6.z;
                      r6.z = r3.w ? r6.z : r5.w;
                      [branch] if (r5.y != 0) {
                        [branch] if (r3.z == 0) {
                          r7.xyzw = _MainTex.SampleLevel(sampler_MainTex, r5.xz, 0).yxzw;
                        } else {
                          r7.x = r4.y;
                        }
                        [branch] if (r3.w == 0) {
                          r4.xyzw = _MainTex.SampleLevel(sampler_MainTex, r6.xz, 0).yxzw;
                        }
                        r4.z = -r2.y * 0.5 + r7.x;
                        r4.y = r3.z ? r7.x : r4.z;
                        r2.y = -r2.y * 0.5 + r4.x;
                        r4.x = r3.w ? r4.x : r2.y;
                        r2.yz = cmp(abs(r4.yx) >= r2.zz);
                        r3.z = -r2.x * 8 + r5.x;
                        r5.x = r2.y ? r5.x : r3.z;
                        r3.z = -r3.y * 8 + r5.z;
                        r5.z = r2.y ? r5.z : r3.z;
                        r2.x = r2.x * 8 + r6.x;
                        r6.x = r2.z ? r6.x : r2.x;
                        r2.x = r3.y * 8 + r6.z;
                        r6.z = r2.z ? r6.z : r2.x;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    r2.xz = -r5.xz + r0.xy;
    r2.x = r0.w ? r2.x : r2.z;
    r2.yz = r6.xz + -r0.xy;
    r2.y = r0.w ? r2.y : r2.z;
    r3.yz = cmp(r4.yx < float2(0,0));
    r2.z = r2.y + r2.x;
    r3.xy = cmp((int2)r3.xx != (int2)r3.yz);
    r2.z = 1 / r2.z;
    r3.z = cmp(r2.x < r2.y);
    r2.x = min(r2.x, r2.y);
    r2.y = r3.z ? r3.x : r3.y;
    r0.z = r0.z * r0.z;
    r2.x = r2.x * -r2.z + 0.5;
    r0.z = _QualitySettings.x * r0.z;
    r2.x = asfloat(asint(r2.x) & (int)r2.y);
    r0.z = max(r2.x, r0.z);
    r2.xy = r0.zz * r2.ww + r0.xy;
    r3.x = r0.w ? r0.x : r2.x;
    r3.y = r0.w ? r2.y : r0.y;
    r0.xyzw = _MainTex.SampleLevel(sampler_MainTex, r3.xy, 0).xyzw;
    r1.w = r1.y;
  } else {
    r0.xyz = r1.xyz;
  }
  r2.xy = v1.xy * _Grain_Params2.xy + _Grain_Params2.zw;
  r2.xyzw = _GrainTex.Sample(sampler_GrainTex, r2.xy).xyzw;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r0.w = sqrt(r0.w);
  r0.w = _Grain_Params1.x * -r0.w + 1;
  r2.xyz = r2.xyz * r0.xyz;
  r2.xyz = _Grain_Params1.yyy * r2.xyz;
  r0.xyz = r2.xyz * r0.www + r0.xyz;
  r2.xy = v1.xy * _DitheringCoords.xy + _DitheringCoords.zw;
  r2.xyzw = _DitheringTex.Sample(sampler_DitheringTex, r2.xy).xyzw;
  r0.w = r2.w * 2 + -1;
  r2.x = cmp(0 < r0.w);
  r2.y = cmp(r0.w < 0);
  r2.x = (int)-r2.x + (int)r2.y;
  r2.x = (int)r2.x;
  r0.w = 1 + -abs(r0.w);
  r0.w = sqrt(r0.w);
  r0.w = 1 + -r0.w;
  r0.w = r2.x * r0.w;
  r1.xyz = r0.www * float3(0.00392156886,0.00392156886,0.00392156886) + r0.xyz;
  o0.xyzw = r1.xyzw;
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
		vs_4a840470d5c29811_impl(v.position0, v.texcoord0, o0, o1, p1);
		o.sv_position = o0;
		o.texcoord0.xy = o1;
		o.texcoord1.xy = p1;
	}
#else
	{ o = (v2f)0; }
#endif
	return o;
}

fout frag(v2f i)
{
	fout r;
#if !defined(DITHERING) && !defined(GRAIN)
	{
		float4 o0 = 0;
		ps_fb5a5cfe713c33f1_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(DITHERING) && !defined(GRAIN)
	{
		float4 o0 = 0;
		ps_236baed351f34ec3_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif !defined(DITHERING) && defined(GRAIN)
	{
		float4 o0 = 0;
		ps_f56cec8e25a4228a_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
		r.t0 = o0;
	}
#elif defined(DITHERING) && defined(GRAIN)
	{
		float4 o0 = 0;
		ps_75d14389449fca48_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
