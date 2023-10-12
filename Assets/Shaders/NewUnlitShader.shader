Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue" = "Overlay" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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

            float hash21(float2 v){
                return frac(23425.32 * sin(v.x*542.02 + v.y * 456.834));
            }

            float noise21(float2 uv){
  
                float2 scaleUV = floor(uv);
                float2 unitUV = frac(uv);
  
                float2 noiseUV = scaleUV;
  
                float value1 = hash21(noiseUV);
                float value2 = hash21(noiseUV + float2(1.,0.));
                float value3 = hash21(noiseUV + float2(0.,1.));
                float value4 = hash21(noiseUV + float2(1.,1.));
  
                unitUV = smoothstep(float2(0., 0.),float2(1., 1.),unitUV);
  
                float bresult = lerp(value1, value2, unitUV.x);
                float tresult = lerp(value3,value4,unitUV.x);
  
                return lerp(bresult,tresult,unitUV.y);
            }

            float fBM(float2 uv){
                float result = 0.;
                for(int i = 0; i <  8; i++){
                result = result + (noise21(uv * pow(2.,float(i))) / pow(2.,float(i)+1.));
                }
  
                return result;
            }

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
                //// apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                //return col;

                float2 st = i.uv;
                st.y = -st.y;
  
                // used late in step function. Makes step requirement higher as going away from source
                float fireSensitivity = distance(float2(.5, -1.),st);
  
                // scroll noise
                st.y -= _Time.y; 


  
                // scale for noise
                float scale = 13.;
                float2 scaledSt = st * scale;
                float2 stID = floor(scaledSt);
                float2 stUV = frac(scaledSt);

                // noise
                float fireNoise = noise21(scaledSt);
  
                // fire masks
                float bigFireMask = step(fireSensitivity * 1.5, fireNoise);
                float mediumFireMask = step(fireSensitivity * 2., fireNoise);
                float smallFireMask = step(fireSensitivity * 3.0, fireNoise);
  
                // making each mask not overlap others. Could have probably used max min stuff idk
                bigFireMask *= 1. - mediumFireMask;
                mediumFireMask *= 1. - smallFireMask;
  
                // combining masks
                float3 combinedFire = float3(bigFireMask , bigFireMask , bigFireMask) * float3(1., 0.25, 0.) // red
                + float3(mediumFireMask,mediumFireMask,mediumFireMask) * float3 (1., .5, 0.) // orange
                + float3(smallFireMask,smallFireMask,smallFireMask) * float3(1., 1., 0.); // yellow
                

                float transparentMask = 1. - smoothstep(0.7, 0.8, (tex.r + tex.g + tex.b) / 3.);

                // output
                fixed4 col = float4(combinedFire, transparentMask);
                return col;

            }
            ENDCG

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
        }
    }
}
