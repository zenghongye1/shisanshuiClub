// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "DMJ/Majhong" {
Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _Tint ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
    _LightDir ("LightDir", Vector) = (0.5,0.5,0.5,1)
    _LightDir1 ("LightDir1", Vector) = (0.5,0.5,0.5,1)
    _Shininess ("Shininess", Range(0.01,50)) = 0.078125
    _Emission ("Emission", Range(0.01,1)) = 0.3
    _Intensity ("_Intensity", Float) = 1
}

SubShader {
    Cull Back
    Tags { "RenderType"="Opaque" }
    LOD 100
    
    Pass {
        Name "FORWARD"
        Tags { "LightMode" = "ForwardBase" }

        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 2.0
            #include "UnityCG.cginc"

            struct a2v {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                half3 worldNormal : TEXCOORD1;
                half3 lightDir : TEXCOORD2;
                half4 texcoord3 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Tint;
            uniform fixed4 _SpecColor;
            uniform half _Shininess;
            uniform half _Emission;
            uniform half _Intensity;
            uniform fixed3 _LightDir;
            uniform fixed3 _LightDir1;
            
            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);

                float3 lightDir = normalize((_LightDir - mul(unity_ObjectToWorld,v.vertex).xyz));
                half3 lightDir1_2 = normalize(_LightDir1);

                fixed3 ambient = (UNITY_LIGHTMODEL_AMBIENT.xyz * _Tint.xyz);
                half4 tmpvar_11 = half4(ambient + (_Tint.xyz * max (0.0, dot (normalize(worldNormal), lightDir1_2))),1);

                o.worldNormal = worldNormal;
                o.lightDir = lightDir;
                o.texcoord3 = saturate(tmpvar_11);

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                half3 n = normalize(i.worldNormal);
                half3 l = -i.lightDir;
                half lightPower = pow(max (0.0, dot ((l - (2.0 * (dot (n, l) * n))), n)), _Shininess);
                half4 specular = _SpecColor * lightPower;

                fixed4 ret;
                ret = tex2D (_MainTex, i.texcoord);
                ret = (ret * i.texcoord3 * _Intensity) + specular + (ret * _Emission);
                return ret;
            }
        ENDCG
    }
}
}