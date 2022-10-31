// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Body" {
Properties {
    _Diffuse("Diffuse", Color) = (1,1,1,1)
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _BumpMap("Bump Map", 2D) = "black"{}
    _BumpScale ("Bump Scale", Range(0.1, 30.0)) = 10.0
    _Specular ("高光贴图", 2D) = "white" {}
    _SpeRange ("高光范围", Range(0.0, 20.0)) = 1.0
    _specularColor ("高光颜色", Color) = (1.0, 1.0, 1.0, 1.0)

}

SubShader {
    Tags { "RenderType"="Opaque" }

    Pass {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata_t {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 tangent : TANGENT;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };
            fixed4 _Diffuse;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float4 _BumpMap_TexelSize;
            float _BumpScale;

            sampler2D _Specular;
            float4 _Specular_ST;
            half _SpeRange;
            float4 _specularColor;



            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //unity自身的diffuse也是带了环境光，这里我们也增加一下环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.xyz;
				//归一化法线，即使在vert归一化也不行，从vert到frag阶段有差值处理，传入的法线方向并不是vertex shader直接传出的
				fixed3 worldNormal1 = normalize(i.worldNormal);
				//采样bump贴图,需要知道该点的斜率，xy方向分别求，所以对于一个点需要采样四次
				fixed bumpValueU = tex2D(_BumpMap, i.uv + fixed2(-1.0 * _BumpMap_TexelSize.x, 0)).r - tex2D(_BumpMap, i.uv + fixed2(1.0 * _BumpMap_TexelSize.x, 0)).r;
				fixed bumpValueV = tex2D(_BumpMap, i.uv + fixed2(0, -1.0 * _BumpMap_TexelSize.y)).r - tex2D(_BumpMap, i.uv + fixed2(0, 1.0 * _BumpMap_TexelSize.y)).r;
				//用上面的斜率来修改法线的偏移值
				fixed3 worldNormal = fixed3(worldNormal1.x * bumpValueU * _BumpScale, worldNormal1.y * bumpValueV * _BumpScale, worldNormal1.z);
 
				//把光照方向归一化
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//根据半兰伯特模型计算像素的光照信息
				fixed3 lambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
				//最终输出颜色为lambert光强*材质diffuse颜色*光颜色
				fixed3 diffuse = lambert * _Diffuse.xyz * _LightColor0.xyz + ambient;

				// 世界空间下反射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

				// Get the view direction in world space
				// 世界空间下视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, i.pos).xyz);

				// Compute specular term
				fixed4 scolor = tex2D(_Specular, i.uv);
				fixed3 specular = _LightColor0.rgb * _specularColor.rgb * scolor * pow(saturate(dot(reflectDir, viewDir)), _SpeRange);



				//进行纹理采样
				fixed4 color = tex2D(_MainTex, i.uv);
				return fixed4(diffuse * color.rgb + specular, 1.0);
            }
        ENDCG
    }
}
FallBack "Diffuse"

}
