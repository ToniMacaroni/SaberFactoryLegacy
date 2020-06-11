

Shader "SF/Metallic"
{
	Properties
	{
		_ReflectionTexture("Reflection Texture", 2D) = "black" {}
		_Power("Power", Float) = 0.634
		_Brightness("Brightness", Float) = 0.28

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

		uniform sampler2D _ReflectionTexture;
		uniform float _Power;
		uniform float _Brightness;

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
			float3 temp_cast_1 = (( pow( tex2D( _ReflectionTexture, appendResult18.xy ).r , ( _Power * 5.0 ) ) * _Brightness )).xxx;
			o.Emission = temp_cast_1;
			o.Alpha = 0.0;
		}

		ENDCG
	}

}

