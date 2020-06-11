

Shader "SF/_TwoSidedUnlit"
{
	Properties
	{
		_Tex("Tex", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_UseColorScheme("Use Colorscheme", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color;
		uniform sampler2D _Tex;
		uniform float4 _Tex_ST;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_Tex = i.uv_texcoord * _Tex_ST.xy + _Tex_ST.zw;
			o.Emission = ( _Color * tex2D( _Tex, uv_Tex ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}

}

