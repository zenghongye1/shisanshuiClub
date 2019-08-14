Shader "custom/fresnel" 
{
	Properties 
	{						
		_RimColor( "Rim Color", Color ) = ( 0,0.8741257,1,1 )
		_RimPower ("Rim Power", Range(0.5,8.0)) = 1.4
	}

	SubShader 
	{
		Tags {"RenderType"="Transparent"}
		LOD 150				
	
		CGPROGRAM
		#pragma surface surf Lambert alpha

		struct Input 
		{                    
          float3 viewDir;
		  INTERNAL_DATA
		};

		float4 _RimColor;
		float _RimPower;

		void surf (Input IN, inout SurfaceOutput o) 
		{   
			//o.Normal = half3(0,0,1);               		
			half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			half4 clr = _RimColor * pow (rim, _RimPower);
			o.Emission = clr.rgb;
			o.Alpha = clr.a;
		}

		ENDCG
	}

	Fallback "Mobile/Diffuse"
}
