Shader "Hidden/BT-ConvertToSDF"
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

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;

float4 _MainTex_TexelSize;

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

// vs 00fa9f706d1a32b2: 1 retail keyword combination(s)
void vs_00fa9f706d1a32b2_impl(
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


// ps ebb327e073914d29: 1 retail keyword combination(s)
void ps_ebb327e073914d29_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(sampler_MainTex, v0.xy).xyzw;
  r1.x = cmp(r0.w >= 0.5);
  r1.y = r1.x ? 1.000000 : 0;
  r1.z = r1.x ? 0 : 1;
  r2.xy = -_MainTex_TexelSize.xx;
  r1.w = 16 * _MainTex_TexelSize.x;
  r1.w = abs(r1.w);
  r2.x = abs(r2.x) / r1.w;
  r2.z = 0;
  r3.yz = float2(0,0);
  r3.xw = _MainTex_TexelSize.xy;
  r4.x = 0;
  r4.y = -_MainTex_TexelSize.y;
  r5.w = -1;
  r6.xyz = r0.xyz;
  r2.w = 0;
  r4.zw = float2(0,-16);
  [loop] while (true) {
    r6.w = cmp(16 < (int)r4.w);
    [branch] if (r6.w != 0) break;
    r7.xyz = r6.xyz;
    r8.x = r2.w;
    r8.y = r4.z;
    r6.w = r4.w;
    r7.w = -16;
    [loop] while (true) {
      r8.z = cmp(16 < (int)r7.w);
      [branch] if (r8.z != 0) break;
      r9.x = (int)r6.w;
      r9.y = (int)r7.w;
      r8.zw = _MainTex_TexelSize.xy * r9.xy;
      r9.xy = _MainTex_TexelSize.xy * r9.xy + v0.xy;
      r9.z = cmp((int)r6.w == 0);
      r9.w = cmp((int)r7.w == 0);
      r9.z = r9.w ? r9.z : 0;
      [branch] if (r9.z != 0) {
        r10.xyzw = r9.xyxy + r3.xyzw;
        r11.xyzw = _MainTex.SampleLevel(sampler_MainTex, r10.xy, 0).xyzw;
        r9.z = cmp(r11.w >= 0.5);
        r10.xy = r9.xy + r2.yz;
        r11.xyzw = _MainTex.SampleLevel(sampler_MainTex, r10.xy, 0).xyzw;
        r9.w = cmp(r11.w >= 0.5);
        r9.zw = r9.zw ? float2(1,1) : 0;
        r10.xyzw = _MainTex.SampleLevel(sampler_MainTex, r10.zw, 0).xyzw;
        r10.x = cmp(r10.w >= 0.5);
        r10.yz = r9.xy + r4.xy;
        r11.xyzw = _MainTex.SampleLevel(sampler_MainTex, r10.yz, 0).xyzw;
        r10.y = cmp(r11.w >= 0.5);
        r10.xy = r10.xy ? float2(1,1) : 0;
        r9.zw = cmp(r1.yy != r9.zw);
        r9.z = (int)r9.w | (int)r9.z;
        r9.w = cmp(r1.y != r10.x);
        r9.z = (int)r9.w | (int)r9.z;
        r9.w = cmp(r1.y != r10.y);
        r9.z = (int)r9.w | (int)r9.z;
        r9.z = r1.x ? r9.z : 0;
        [branch] if (r9.z != 0) {
          r7.xyz = r0.xyz;
          r8.x = 0.5;
          r6.w = 0;
          break;
        } else {
          r9.z = r8.x;
        }
        r10.xyz = r8.yyy ? r7.xyz : r0.xyz;
        r6.w = 0;
        r7.w = 1;
        r8.x = r9.z;
        r7.xyz = r10.xyz;
        continue;
      }
      r9.xyzw = _MainTex.SampleLevel(sampler_MainTex, r9.xy, 0).xyzw;
      r8.z = dot(r8.zw, r8.zw);
      r8.z = sqrt(r8.z);
      r8.z = r8.z / r1.w;
      r8.w = r8.z + -r2.x;
      r8.z = r1.x ? r8.w : r8.z;
      r8.z = r8.z * -0.5 + 0.5;
      r8.w = cmp(r8.x < r8.z);
      r9.w = cmp(r9.w >= 0.5);
      r9.w = r9.w ? 1.000000 : 0;
      r9.w = cmp(r1.z == r9.w);
      r10.x = r9.w ? r8.z : r8.x;
      r11.xzw = r7.xyz;
      r11.y = r8.y;
      r5.xyz = r9.xyz;
      r9.xyzw = r1.xxxx ? r11.xzwy : r5.xyzw;
      r7.xyz = r8.www ? r9.xyz : r7.xyz;
      r10.y = r9.w;
      r11.x = r8.x;
      r8.xy = r8.ww ? r10.xy : r11.xy;
      r7.w = (int)r7.w + 1;
    }
    r6.xyz = r7.xyz;
    r2.w = r8.x;
    r4.z = r8.y;
    r4.w = (int)r6.w + 1;
  }
  o0.xyz = r6.xyz;
  r0.x = cmp(0.5 < r0.w);
  r0.y = 1 + -r2.w;
  o0.w = r0.x ? r0.y : r2.w;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_00fa9f706d1a32b2_impl(v.position0, v.texcoord0.xy, o0, o1);
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
		ps_ebb327e073914d29_impl(i.texcoord0.xy, i.sv_position, o0);
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
			#pragma target 4.0

#define cmp -

Texture2D _MainTex;
SamplerState sampler_MainTex;


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

// vs 00fa9f706d1a32b2: 1 retail keyword combination(s)
void vs_00fa9f706d1a32b2_impl(
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


// ps 76e5e517046a4a01: 1 retail keyword combination(s)
void ps_76e5e517046a4a01_impl(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  inout float4 o0 : SV_Target0)
{
  o0.xyzw = _MainTex.Sample(sampler_MainTex, v0.xy).xyzw;
  return;
}


v2f vert(appdata v)
{
	v2f o = (v2f)0;
#if 1
	{
		float2 o0 = 0;
		float4 o1 = 0;
		vs_00fa9f706d1a32b2_impl(v.position0, v.texcoord0.xy, o0, o1);
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
		ps_76e5e517046a4a01_impl(i.texcoord0.xy, i.sv_position, o0);
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
