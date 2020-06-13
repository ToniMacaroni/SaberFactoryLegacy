

Shader "SF/GlowShader"
{
	Properties
	{
		_Color("Color", Color) = (0,0,0,0)
		_UseColorScheme("Use Colorscheme", Range( 0 , 1)) = 0
		_Glow("Glow", Range( 0 , 1)) = 0

	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			half filler;
		};

		uniform float4 _Color;
		uniform float _Glow;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Emission = _Color.rgb;
			o.Alpha = _Glow;
		}

		ENDCG
	}

}

