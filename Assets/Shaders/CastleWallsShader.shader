Shader "Custom/CastleWallsShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex + float2(_Time.y, 0.) / 10.) * _Color;
            float2 st = IN.uv_MainTex + float2(_Time.y, 0.);
            float scale = 1.;
            float2 scaledSt = st * scale;
            float2 stUV = frac(scaledSt);
            float2 stID = floor(scaledSt);

            float brickMask = 1. - smoothstep(0.2, 0.3, c.xyz/3.);

            float brickHighlights = 1. - smoothstep(0.05, 0.2, c.xyz/3.);


            //o.Albedo = c.rgb + float3(1.,1., 1.) * IN.uv_MainTex.y/8.;
            o.Albedo = float3(0., sin(st.x) / 2. + 1., sin(st.y + 0.5) / 2. + 1.) * brickMask * 0.4 + float3(brickHighlights,brickHighlights,brickHighlights);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
