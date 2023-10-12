Shader "Unlit/FirstUnlitShader"
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
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #define PI 3.14159265

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 tex = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);

                float2 st = i.uv;
  
                float scale = 1.;
                float2 scaled_st = st * scale;
                float2 stID = floor(scaled_st);
                float2 stUV = frac(scaled_st);
  
                float radius = 0.02;
                float ballSmooth = 0.003;
  
                float trailStretch = 1.2;
  
                float y = abs(sin(_Time.y*2.))/2. + radius/2.;
  
                float x = frac(_Time.y/7.) * trailStretch - (trailStretch-1.)/2.;
  
                //float chromaticAberration = distance(vec2(x,y), stUV)/5.;
                float chromaticAberration = abs(0.5 - x)/30.;
  
                float3 ball = float3(
                  1.- smoothstep(radius, radius + ballSmooth, distance(float2(x + chromaticAberration,y), stUV)),
                  1.- smoothstep(radius, radius + ballSmooth, distance(float2(x,y), stUV)),
                  1.- smoothstep(radius, radius + ballSmooth, distance(float2(x - chromaticAberration,y), stUV))
                );
  
  
                // stuff below is for the wave!
                float wave1 = (sin(scale*st.x * PI - _Time.y))/3. * sin(_Time.y);
                float wave2 = (sin(scale/2.*st.x * PI + _Time.y *0.3))/3. * sin(_Time.y);
                float wave3 = (sin(scale*1.5*st.x * PI + _Time.y *0.7))/3. * sin(_Time.y);
  
                float3 oscillation = float3(sin(_Time.y)/4.+ 0.5,
                         sin(_Time.y / 3.)/4. + 0.5,
                         sin(_Time.y * 1.5)/4. + 0.5);
  
                float3 col = float3(smoothstep(wave1 / 2.- 0.005 + oscillation.x, wave1 / 2.  + oscillation.x, st.y),
                smoothstep(wave2 / 2.- 0.1 + oscillation.y, wave2 / 2. + oscillation.y, st.y),
                  smoothstep(wave3 / 2.- 0.045  + oscillation.z, wave3 / 2. + oscillation.z, st.y));
  

                return float4(ball + col, 1.);
            }
            ENDCG
        }
    }
}
