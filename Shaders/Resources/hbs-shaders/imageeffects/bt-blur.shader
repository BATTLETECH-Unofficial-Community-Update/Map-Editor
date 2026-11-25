Shader "Hidden/BT-Blur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Cull Off
			ZWrite Off
			ZTest Always

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile _ _DEPTHAWARE

			UNITY_DECLARE_TEX2D(_MainTex);
			UNITY_DECLARE_TEX2D(_CameraDepthTexture);

			float4 _MainTex_TexelSize;
			float2 _Direction;
			float _BlurSize;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 dir : TEXCOORD1;
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.dir = _MainTex_TexelSize.xy * _Direction * _BlurSize;
				o.uv = v.uv;
				o.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)));
				return o;
			}

			#if defined(_DEPTHAWARE)
			float LinearEyeDepthAt(float2 uv)
			{
				return 1.0 / (_ZBufferParams.z * _CameraDepthTexture.Gather(sampler_CameraDepthTexture, uv).x + _ZBufferParams.w);
			}
			#endif

			float4 frag(v2f i) : SV_Target
			{
				float2 p0 = i.uv - i.dir * 3.0;
				float2 p1 = p0 + i.dir;
				float2 p2 = p1 + i.dir;
				float2 p3 = p2 + i.dir;
				float2 p4 = p3 + i.dir;
				float2 p5 = p4 + i.dir;
				float2 p6 = p5 + i.dir;
			#if defined(_DEPTHAWARE)
				float centerDepth = LinearEyeDepthAt(i.uv);
				float4 sum = 0.0;
				float wsum = 0.0;
				bool k0 = LinearEyeDepthAt(p0) - centerDepth < 1.0;
				sum = k0 ? UNITY_SAMPLE_TEX2D(_MainTex, p0) * 0.0205 : 0.0;
				wsum = k0 ? 0.0205 : 0.0;
				bool k1 = LinearEyeDepthAt(p1) - centerDepth < 1.0;
				sum = k1 ? UNITY_SAMPLE_TEX2D(_MainTex, p1) * 0.0855 + sum : sum;
				wsum = k1 ? wsum + 0.0855 : wsum;
				bool k2 = LinearEyeDepthAt(p2) - centerDepth < 1.0;
				sum = k2 ? UNITY_SAMPLE_TEX2D(_MainTex, p2) * 0.232 + sum : sum;
				wsum = k2 ? wsum + 0.232 : wsum;
				bool k3 = LinearEyeDepthAt(p3) - centerDepth < 1.0;
				sum = k3 ? UNITY_SAMPLE_TEX2D(_MainTex, p3) * 0.324 + sum : sum;
				wsum = k3 ? wsum + 0.324 : wsum;
				bool k4 = LinearEyeDepthAt(p4) - centerDepth < 1.0;
				sum = k4 ? UNITY_SAMPLE_TEX2D(_MainTex, p4) * 0.232 + sum : sum;
				wsum = k4 ? wsum + 0.232 : wsum;
				bool k5 = LinearEyeDepthAt(p5) - centerDepth < 1.0;
				sum = k5 ? UNITY_SAMPLE_TEX2D(_MainTex, p5) * 0.0855 + sum : sum;
				wsum = k5 ? wsum + 0.0855 : wsum;
				bool k6 = LinearEyeDepthAt(p6) - centerDepth < 1.0;
				sum = k6 ? UNITY_SAMPLE_TEX2D(_MainTex, p6) * 0.0205 + sum : sum;
				wsum = k6 ? wsum + 0.0205 : wsum;
				return sum / wsum;
			#else
				return UNITY_SAMPLE_TEX2D(_MainTex, p0) * 0.0205
					+ UNITY_SAMPLE_TEX2D(_MainTex, p1) * 0.0855
					+ UNITY_SAMPLE_TEX2D(_MainTex, p2) * 0.232
					+ UNITY_SAMPLE_TEX2D(_MainTex, p3) * 0.324
					+ UNITY_SAMPLE_TEX2D(_MainTex, p4) * 0.232
					+ UNITY_SAMPLE_TEX2D(_MainTex, p5) * 0.0855
					+ UNITY_SAMPLE_TEX2D(_MainTex, p6) * 0.0205;
			#endif
			}
			ENDCG
		}
		Pass
		{
			Cull Off
			ZWrite Off
			ZTest Always

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile _ _BT_SIM_GAME

			UNITY_DECLARE_TEX2D(_MainTex);
			UNITY_DECLARE_TEX2D(_BT_ElementUI);

			float _Threshold;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)));
				o.uv = v.uv;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float4 src = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
				float3 rgb = src.rgb;
			#if !defined(_BT_SIM_GAME)
				float4 ui = UNITY_SAMPLE_TEX2D(_BT_ElementUI, i.uv);
				rgb = lerp(ui.rgb * saturate(ui.a), src.rgb, saturate(src.a));
			#else
				rgb = src.rgb * saturate(src.a);
			#endif
				float br = max(max(rgb.r, rgb.g), rgb.b);
				float x = br + 0.00001;
				float knee = clamp(x, 0.0, 0.00002);
				float soft = knee * knee * 25000.0;
				float contrib = max(br - _Threshold, soft) / x;
				return float4(rgb * contrib, src.a);
			}
			ENDCG
		}
	}
}
