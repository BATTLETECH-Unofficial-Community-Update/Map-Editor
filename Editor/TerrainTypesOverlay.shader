// UCU Map Kit: the Terrain Types view's drape (TerrainTypesView.cs). Unlit, alpha-blended, drawn over the ground whatever its
// depth: the terrain renders at a coarser LOD than its heights (heightmapPixelError), so a depth-tested drape just above the
// sampled heights is hidden wherever the rendered ground sits higher.
Shader "Hidden/UCU Map Kit/Terrain Types"
{
    Properties { _MainTex ("Cell types", 2D) = "white" {} }
    SubShader
    {
        Tags { "Queue" = "Overlay" "RenderType" = "Transparent" }
        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            struct v2f { float4 pos : SV_POSITION; float2 uv : TEXCOORD0; };
            v2f vert (appdata_base v) { v2f o; o.pos = UnityObjectToClipPos(v.vertex); o.uv = v.texcoord.xy; return o; }
            fixed4 frag (v2f i) : SV_Target { return tex2D(_MainTex, i.uv); }
            ENDCG
        }
    }
}
