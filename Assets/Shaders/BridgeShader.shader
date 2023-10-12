Shader "Custom/BridgeShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _SecondTex ("Albedo (RGB)", 2D) = "white" {}
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
        sampler2D _SecondTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_SecondTex;
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

        float sdStar5(in float2 p, in float r, in float rf)
        {
            const float2 k1 = float2(0.809016994375, -0.587785252292);
            const float2 k2 = float2(-k1.x,k1.y);
            p.x = abs(p.x);
            p -= 2.0*max(dot(k1,p),0.0)*k1;
            p -= 2.0*max(dot(k2,p),0.0)*k2;
            p.x = abs(p.x);
            p.y -= r;
            float2 ba = rf*float2(-k1.y,k1.x) - float2(0,1);
            float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
            return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float2 st = IN.uv_MainTex;
            float2 st2 = 1. - IN.uv_SecondTex + float2(2.4, 2. + _Time.y);
            float scale2 = 0.3;
            float2 scaledSt2 = st2 * scale2;
            fixed4 c = tex2D (_MainTex, st) * _Color;
            fixed4 c2 = tex2D (_SecondTex, scaledSt2) * _Color;

            
            float3 starContent = c2.rgb;

            float starD = sdStar5(st - float2(-1.25 + cos(_Time.y)/2., -2.5 + sin(_Time.y)/2.), 1.5, 0.5);

            float starMask = smoothstep(0., 0.1, starD);

            o.Albedo = c.rgb * starMask 
            + (1. - starMask) * starContent
            ;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
