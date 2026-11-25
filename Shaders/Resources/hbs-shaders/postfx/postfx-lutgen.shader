Shader "Hidden/Post FX/Lut Generator"
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
			#pragma target 4.0

#define cmp -

Texture2D _Curves;
SamplerState sampler_Curves;

float4 _MainTex_ST;
float3 _Balance;
float3 _Lift;
float3 _InvGamma;
float3 _Gain;
float3 _Offset;
float3 _Power;
float3 _Slope;
float _HueShift;
float _Saturation;
float _Contrast;
float3 _ChannelMixerRed;
float3 _ChannelMixerGreen;
float3 _ChannelMixerBlue;
float4 _LutParams;

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

// vs 4a840470d5c29811: 1 retail keyword combination(s)
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


// ps 3f2ccf9135d48e9f: 1 retail keyword combination(s)
void ps_3f2ccf9135d48e9f_impl(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  inout float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.yz = -_LutParams.yz + v1.xy;
  r1.x = _LutParams.x * r0.y;
  r0.x = frac(r1.x);
  r1.x = r0.x / _LutParams.x;
  r0.w = -r1.x + r0.y;
  r0.xyz = r0.xzw * _LutParams.www + float3(-0.386036009,-0.386036009,-0.386036009);
  r0.xyz = float3(13.6054821,13.6054821,13.6054821) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = float3(-0.0479959995,-0.0479959995,-0.0479959995) + r0.xyz;
  r0.xyz = float3(0.179999992,0.179999992,0.179999992) * r0.xyz;
  r1.x = dot(float3(0.439700991,0.382977992,0.177334994), r0.xyz);
  r1.y = dot(float3(0.0897922963,0.813422978,0.0967615992), r0.xyz);
  r1.z = dot(float3(0.0175439995,0.111543998,0.870703995), r0.xyz);
  r0.xyz = max(float3(0,0,0), r1.xyz);
  r0.xyz = min(float3(65504,65504,65504), r0.xyz);
  r1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(1.525878e-005,1.525878e-005,1.525878e-005);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(9.72000027,9.72000027,9.72000027) + r1.xyz;
  r1.xyz = float3(0.0570776239,0.0570776239,0.0570776239) * r1.xyz;
  r2.xyz = log2(r0.xyz);
  r0.xyz = cmp(r0.xyz < float3(3.05175708e-005,3.05175708e-005,3.05175708e-005));
  r2.xyz = float3(9.72000027,9.72000027,9.72000027) + r2.xyz;
  r2.xyz = float3(0.0570776239,0.0570776239,0.0570776239) * r2.xyz;
  r0.xyz = r0.xyz ? r1.xyz : r2.xyz;
  r0.xyz = r0.xyz * _Slope.xyz + _Offset.xyz;
  r1.xyz = log2(r0.xyz);
  r1.xyz = _Power.xyz * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r2.xyz = cmp(float3(0,0,0) < r0.xyz);
  r0.xyz = r2.xyz ? r1.xyz : r0.xyz;
  r0.w = cmp(r0.y >= r0.z);
  r0.w = r0.w ? 1.000000 : 0;
  r1.xy = r0.zy;
  r2.xy = -r1.xy + r0.yz;
  r1.zw = float2(-1,0.666666687);
  r2.zw = float2(1,-1);
  r1.xyzw = r0.wwww * r2.xywz + r1.xywz;
  r0.w = cmp(r0.x >= r1.x);
  r0.w = r0.w ? 1.000000 : 0;
  r2.z = r1.w;
  r1.w = r0.x;
  r2.xyw = r1.wyx;
  r2.xyzw = r2.xyzw + -r1.xyzw;
  r1.xyzw = r0.wwww * r2.xyzw + r1.xyzw;
  r0.w = min(r1.w, r1.y);
  r0.w = r1.x + -r0.w;
  r2.x = r0.w * 6 + 9.99999975e-005;
  r1.y = r1.w + -r1.y;
  r1.y = r1.y / r2.x;
  r1.y = r1.z + r1.y;
  r1.x = 9.99999975e-005 + r1.x;
  r2.z = r0.w / r1.x;
  r2.x = abs(r1.y);
  r2.yw = float2(0.25,0.25);
  r1.xyzw = _Curves.Sample(sampler_Curves, r2.xy).yxzw;
  r2.xyzw = _Curves.Sample(sampler_Curves, r2.zw).zxyw;
  r2.x = saturate(r2.x);
  r0.w = r2.x + r2.x;
  r1.x = saturate(r1.x);
  r1.x = r1.x + r1.x;
  r0.w = r1.x * r0.w;
  r1.x = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r0.xyz = -r1.xxx + r0.xyz;
  r1.yw = float2(0.25,0.25);
  r2.xyzw = _Curves.Sample(sampler_Curves, r1.xy).wxyz;
  r2.x = saturate(r2.x);
  r1.y = r2.x + r2.x;
  r0.w = r1.y * r0.w;
  r0.w = _Saturation * r0.w;
  r0.xyz = r0.www * r0.xyz + r1.xxx;
  r0.xyz = float3(-0.413588405,-0.413588405,-0.413588405) + r0.xyz;
  r0.xyz = r0.xyz * _Contrast.xxx + float3(0.413588405,0.413588405,0.413588405);
  r2.xyzw = cmp(r0.xxyy < float4(-0.301369876,1.46799636,-0.301369876,1.46799636));
  r0.xyw = r0.xyz * float3(17.5200005,17.5200005,17.5200005) + float3(-9.72000027,-9.72000027,-9.72000027);
  r1.xy = cmp(r0.zz < float2(-0.301369876,1.46799636));
  r0.xyz = exp2(r0.xyw);
  r2.yw = r2.yw ? r0.xy : float2(65504,65504);
  r0.xyw = float3(-1.52587891e-005,-1.52587891e-005,-1.52587891e-005) + r0.xyz;
  r0.z = r1.y ? r0.z : 65504;
  r0.xyw = r0.xyw + r0.xyw;
  r2.xy = r2.xz ? r0.xy : r2.yw;
  r2.z = r1.x ? r0.w : r0.z;
  r0.x = dot(float3(1.45143926,-0.236510754,-0.214928567), r2.xyz);
  r0.y = dot(float3(-0.0765537769,1.17622972,-0.0996759236), r2.xyz);
  r0.z = dot(float3(0.00831614807,-0.00603244966,0.997716308), r2.xyz);
  r2.x = dot(float3(0.390404999,0.549941003,0.00892631989), r0.xyz);
  r2.y = dot(float3(0.070841603,0.963172019,0.00135775004), r0.xyz);
  r2.z = dot(float3(0.0231081992,0.128021002,0.936245024), r0.xyz);
  r0.xyz = _Balance.xyz * r2.xyz;
  r2.x = dot(float3(2.85846996,-1.62879002,-0.0248910002), r0.xyz);
  r2.y = dot(float3(-0.210181996,1.15820003,0.000324280991), r0.xyz);
  r2.z = dot(float3(-0.0418119989,-0.118169002,1.06867003), r0.xyz);
  r0.xyz = float3(1,1,1) + -_Lift.xyz;
  r0.xyz = _Gain.xyz * r0.xyz;
  r3.xyz = _Gain.xyz * _Lift.xyz;
  r0.xyz = r2.xyz * r0.xyz + r3.xyz;
  r2.xyz = log2(r0.xyz);
  r2.xyz = _InvGamma.xyz * r2.xyz;
  r2.xyz = exp2(r2.xyz);
  r3.xyz = cmp(float3(0,0,0) < r0.xyz);
  r0.xyw = r3.yzx ? r2.yzx : r0.yzx;
  r1.x = cmp(r0.x >= r0.y);
  r1.x = r1.x ? 1.000000 : 0;
  r2.xy = r0.yx;
  r3.xy = -r2.xy + r0.xy;
  r2.zw = float2(-1,0.666666687);
  r3.zw = float2(1,-1);
  r2.xyzw = r1.xxxx * r3.xyzw + r2.xyzw;
  r1.x = cmp(r0.w >= r2.x);
  r1.x = r1.x ? 1.000000 : 0;
  r0.xyz = r2.xyw;
  r2.xyw = r0.wyx;
  r2.xyzw = r2.xyzw + -r0.xyzw;
  r0.xyzw = r1.xxxx * r2.xyzw + r0.xyzw;
  r1.x = min(r0.w, r0.y);
  r1.x = -r1.x + r0.x;
  r1.y = r1.x * 6 + 9.99999975e-005;
  r0.y = r0.w + -r0.y;
  r0.y = r0.y / r1.y;
  r0.y = r0.z + r0.y;
  r1.z = _HueShift + abs(r0.y);
  r2.xyzw = _Curves.Sample(sampler_Curves, r1.zw).xyzw;
  r2.x = saturate(r2.x);
  r0.y = -0.5 + r2.x;
  r0.y = r1.z + r0.y;
  r0.z = cmp(1 < r0.y);
  r1.yz = float2(1,-1) + r0.yy;
  r0.z = r0.z ? r1.z : r0.y;
  r0.y = cmp(r0.y < 0);
  r0.y = r0.y ? r1.y : r0.z;
  r0.yzw = float3(1,0.666666687,0.333333343) + r0.yyy;
  r0.yzw = frac(r0.yzw);
  r0.yzw = r0.yzw * float3(6,6,6) + float3(-3,-3,-3);
  r0.yzw = saturate(float3(-1,-1,-1) + abs(r0.yzw));
  r0.yzw = float3(-1,-1,-1) + r0.yzw;
  r1.y = 9.99999975e-005 + r0.x;
  r1.x = r1.x / r1.y;
  r0.yzw = r1.xxx * r0.yzw + float3(1,1,1);
  r0.xyz = r0.xxx * r0.yzw;
  r1.x = dot(r0.xyz, _ChannelMixerRed.xyz);
  r1.y = dot(r0.xyz, _ChannelMixerGreen.xyz);
  r1.z = dot(r0.xyz, _ChannelMixerBlue.xyz);
  r0.x = dot(float3(1.70504999,-0.621789992,-0.0832599998), r1.xyz);
  r0.y = dot(float3(-0.130260006,1.1408,-0.0105499998), r1.xyz);
  r0.z = dot(float3(-0.0240000002,-0.128969997,1.15296996), r1.xyz);
  r0.xyz = float3(0.00390625,0.00390625,0.00390625) + r0.xyz;
  r0.w = 0.75;
  r1.xyzw = _Curves.Sample(sampler_Curves, r0.xw).wxyz;
  r1.x = saturate(r1.x);
  r2.xyzw = _Curves.Sample(sampler_Curves, r0.yw).xyzw;
  r0.xyzw = _Curves.Sample(sampler_Curves, r0.zw).xyzw;
  r1.z = saturate(r0.w);
  r1.y = saturate(r2.w);
  r0.xyz = float3(0.00390625,0.00390625,0.00390625) + r1.xyz;
  r0.w = 0.75;
  r1.xyzw = _Curves.Sample(sampler_Curves, r0.xw).xyzw;
  o0.x = saturate(r1.x);
  r1.xyzw = _Curves.Sample(sampler_Curves, r0.yw).xyzw;
  r0.xyzw = _Curves.Sample(sampler_Curves, r0.zw).xyzw;
  o0.z = saturate(r0.z);
  o0.y = saturate(r1.y);
  o0.w = 1;
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
#if 1
	{
		float4 o0 = 0;
		ps_3f2ccf9135d48e9f_impl(i.sv_position, i.texcoord0.xy, i.texcoord1.xy, o0);
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
