// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Hidden/SceneViewSelected"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.01
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        struct Input
        {
            float4 position : POSITION;
            float2 uv : TEXCOORD0;
            float4 projPos : TEXCOORD1;
        };
        struct Varying
        {
            float4 position : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 projPos : TEXCOORD1;
        };
        Varying vertex(Input input)
        {
            Varying output;
            output.position = UnityObjectToClipPos(input.position);
            output.uv = input.uv;
            output.projPos = ComputeScreenPos(output.position);
            return output;
        }
        ENDCG
     
        Tags { "RenderType"="Opaque" }
         // #0: separable blur pass, either horizontal or vertical
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
         
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #pragma target 2.0
            #include "UnityCG.cginc"
            float2 _BlurDirection = float2(1,0);
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            // 9-tap Gaussian kernel, that blurs green & blue channels,
            // keeps red & alpha intact.
            static const half4 kCurveWeights[9] = {
                half4(0,0.0204001988,0.0204001988,0),
                half4(0,0.0577929595,0.0577929595,0),
                half4(0,0.1215916882,0.1215916882,0),
                half4(0,0.1899858519,0.1899858519,0),
                half4(1,0.2204586031,0.2204586031,1),
                half4(0,0.1899858519,0.1899858519,0),
                half4(0,0.1215916882,0.1215916882,0),
                half4(0,0.0577929595,0.0577929595,0),
                half4(0,0.0204001988,0.0204001988,0)
            };
            half4 fragment(Varying i) : SV_Target
            {
                float2 step = _MainTex_TexelSize.xy * _BlurDirection;
                float2 uv = i.uv - step * 4;
                half4 col = 0;
                for (int tap = 0; tap < 9; ++tap)
                {
                    col += tex2D(_MainTex, uv) * kCurveWeights[tap];
                    uv += step;
                }
     
                return col;
            }
            ENDCG
        }
        // #1: final postprocessing pass
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
 
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #pragma target 2.0
            #include "UnityCG.cginc"
 
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float3 _OutlineColor;

            half4 fragment(Varying i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv.xy);
                float saturateFac = 10;
     
                float alpha = saturate((col.b - col.r) * saturateFac);
 
                half4 outline = half4(_OutlineColor, alpha);
 
                return outline;
            }
            ENDCG
        }
    }
 
}