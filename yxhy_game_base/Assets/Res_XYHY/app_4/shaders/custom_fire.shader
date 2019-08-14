Shader "custom/fire"
{
	Properties 
	{
_T01("_T01", 2D) = "black" {}
_niuqu("_niuqu", 2D) = "white" {}
_mask("_mask", 2D) = "white" {}
_Color_T01("_Color_T01", Color) = (1,1,1,1)
_niuqu_sudu("_niuqu_sudu", Float) = 1
_niuqudu("_niuqudu", Float) = 0

	}
	
	SubShader 
	{
		Tags
		{
"Queue"="Transparent"
"IgnoreProjector"="False"
"RenderType"="Transparent"

		}

		
Cull Off
ZWrite Off
ZTest LEqual
ColorMask RGB
Blend SrcColor One
Fog{
Mode Off
}


		CGPROGRAM
#pragma surface surf BlinnPhongEditor 
#pragma target 2.0


sampler2D _T01;
sampler2D _niuqu;
sampler2D _mask;
float4 _Color_T01;
float _niuqu_sudu;
float _niuqudu;

			struct EditorSurfaceOutput {
				half3 Albedo;
				half3 Normal;
				half3 Emission;
				half3 Gloss;
				half Specular;
				half Alpha;
				half4 Custom;
			};
			
			inline half4 LightingBlinnPhongEditor_PrePass (EditorSurfaceOutput s, half4 light)
			{
				half3 spec = light.a * s.Gloss;
				half4 c;	
				c.rgb = (s.Albedo * light.rgb + light.rgb * spec) * s.Alpha;
				c.a = s.Alpha;
				return c;

			}

			inline half4 LightingBlinnPhongEditor (EditorSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
			{
				half3 h = normalize (lightDir + viewDir);
				
				half diff = max (0, dot ( lightDir, s.Normal ));
				
				float nh = max (0, dot (s.Normal, h));
				float spec = pow (nh, s.Specular*128.0);
				
				half4 res;
				res.rgb = _LightColor0.rgb * diff;
				res.w = spec * Luminance (_LightColor0.rgb);
				res *= atten * 2.0;

				return LightingBlinnPhongEditor_PrePass( s, res );
			}
			
			struct Input {
				float4 color : COLOR;
				float2 uv_T01;
				float2 uv_niuqu;
				float2 uv_mask;

			};

			void surf (Input IN, inout EditorSurfaceOutput o) {
				o.Normal = float3(0.0,0.0,1.0);
				o.Alpha = 1.0;
				o.Albedo = 0.0;
				o.Emission = 0.0;
				o.Gloss = 0.0;
				o.Specular = 0.0;
				o.Custom = 0.0;
				
				float4 Multiply0=_Time * _niuqu_sudu.xxxx;
				float4 UV_Pan0=float4((IN.uv_niuqu.xyxy).x,(IN.uv_niuqu.xyxy).y + Multiply0.x,(IN.uv_niuqu.xyxy).z,(IN.uv_niuqu.xyxy).w);
				float4 Tex2D1=tex2D(_niuqu,UV_Pan0.xy);
				float4 Multiply1=_niuqudu.xxxx * Tex2D1;
				float4 Add0=(IN.uv_T01.xyxy) + Multiply1;
				float4 Tex2D0=tex2D(_T01,Add0.xy);
				float4 Multiply4=_Color_T01 * Tex2D0;
				float4 Tex2D2=tex2D(_mask,(IN.uv_mask.xyxy).xy);
				float4 Multiply2=Multiply4 * Tex2D2;
				float4 Multiply3=IN.color * Multiply2;

				o.Emission = Multiply3;

				o.Normal = normalize(o.Normal);
			}
		ENDCG
	}
	Fallback "Diffuse"
}