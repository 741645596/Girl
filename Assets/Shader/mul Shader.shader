// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/mul Shader" {
    Properties {
        _MainTex ("主纹理 (RGB)", 2D) = "white" {}
        _bump ("法线贴图", 2D) = "white" {}
        _BunpZ ("法线深度调节", Range(0.0, 1.0)) = 0.0
        _Specular ("高光贴图", 2D) = "white" {}
        _SpeRange ("高光范围", Range(0.0, 20.0)) = 1.0
        _specularColor ("高光颜色", Color) = (1.0, 1.0, 1.0, 1.0)

    }
    SubShader {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" "Queue"="Overlay"}
        LOD 200

        Pass{
            Zwrite Off
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert 
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _bump;
            fixed _BunpZ;
            sampler2D _Specular;
            half _SpeRange;
            fixed4 _specularColor;
            fixed3 _LightColor0;

            struct vertIN{
                float4 vertex : POSITION;
                fixed2 tex : TEXCOORD0;
                fixed3 normal : NORMAL;
                fixed3 tangent : TANGENT;
            };

            struct vertOUT{
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                fixed3 nDir : NORMAL;
                fixed3 tDir : TANGENT;
                fixed3 bDir : BINORMAL;
                fixed3 LDir : TEXCOORD1;
                fixed3 rDir : TEXCOORD2;
                fixed3 vDir : TEXCOORD3;
                fixed3 reflectDir : TEXCOORD4;
                //float3 view : TEXCOORD4;
            };

            vertOUT vert(vertIN i){
                vertOUT o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.uv = TRANSFORM_TEX(i.tex,_MainTex);
                o.nDir = normalize(mul(float4(i.normal,0),unity_ObjectToWorld).xyz);
                o.tDir = normalize(mul(unity_ObjectToWorld,float4(i.tangent,0)).xyz);
                o.bDir = normalize(cross(o.nDir,o.tDir));
                o.LDir = normalize(_WorldSpaceLightPos0);
                o.rDir = normalize(reflect(-o.LDir,o.nDir));
                o.vDir = normalize(WorldSpaceViewDir(i.vertex));
                o.reflectDir = normalize(reflect(-o.vDir,o.nDir));

                //o.view = WorldSpaceViewDir(i.vertex);
                return o;
            }

            fixed4 frag(vertOUT ou):COLOR{
                //half h = tex2D(_HeighMap,ou.uv).w;
                //float2 offset = ParallaxOffset(h,_Height,ou.vDir);

                half2 uv = ou.uv; //+ offset;
                fixed4 c = tex2D(_MainTex,uv);
                fixed Diff = saturate(dot(ou.nDir,ou.LDir));

                fixed3 bump = UnpackNormal(tex2D(_bump,uv));
                    bump.z = _BunpZ;
                fixed3x3 TangentSpace = fixed3x3(
                    ou.tDir,
                    ou.bDir,
                    ou.nDir
                );
                fixed3 bumpDir = normalize(mul(TangentSpace,bump));
                fixed bumpDiff = max(0,dot(ou.LDir,bumpDir));

                fixed3 specular = tex2D(_Specular,uv);
                fixed specularDiff = bumpDiff*pow(dot(ou.rDir,ou.vDir),_SpeRange);

                //fixed3 cube = texCUBE(_Cubemap,ou.reflectDir)/2;

                c.rgb *=(bumpDiff*_LightColor0 + specularDiff*specular);
                return c;
            }
            ENDCG
        }
    } 
    //FallBack "Diffuse"
}
