

Shader "SF/Metallic"
{
	Properties
	{
		_ReflectionTexture("!Reflection Texture", 2D) = "black" {}
		_Contrast("Contrast", Float) = 0.634
		_ShineBrightness("Shine Brightness", Float) = 0.4
		_Color("Color", Color) = (0.1415094,0.6044365,1,0)
		_UseColorScheme("Use Colorscheme", Range( 0 , 1)) = 0
		_BaseBrightness("Base Brightness", Range( 0 , 1)) = 0.1

	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
		};

		uniform float4 _Color;
		uniform float _BaseBrightness;
		uniform sampler2D _ReflectionTexture;
		uniform float _Contrast;
		uniform float _ShineBrightness;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 worldNormal = i.worldNormal;
			float dotResult14 = dot( worldNormal , i.viewDir );
			float dotResult17 = dot( (worldNormal).xzy , (i.viewDir).zyx );
			float4 appendResult18 = (float4(dotResult14 , dotResult17 , 0.0 , 0.0));
			o.Emission = ( _Color * ( (0.0 + (_BaseBrightness - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) + ( pow( tex2D( _ReflectionTexture, appendResult18.xy ).r , ( _Contrast * 5.0 ) ) * _ShineBrightness ) ) ).rgb;
			o.Alpha = 0.0;
		}

		ENDCG
	}

}

