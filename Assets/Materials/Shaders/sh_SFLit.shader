

Shader "SF/Lit"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_UseColorScheme("Use Colorscheme", Range( 0 , 1)) = 0
		_MainTex ("Texture", 2D) = "white" {}
		_LightStrength ("Light Intensity", Range(0, 1)) = 0.5
		_LightDir ("_Light Direction", Vector) = (-1, -1, 0)
		_Ambient ("Ambient Lighting", Range (0, 1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD1;
				float3 normal : NORMAL;
			};

			float4 _Color;
			float _Ambient;
			float _LightStrength;
			float3 _LightDir;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 lightDir = normalize(_LightDir) * -1.0;
				float shadow = max(dot(lightDir,i.normal)*_LightStrength,0);

				fixed4 col = _Color * tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex));

				col = col * clamp(col * _Ambient + shadow,0.0,1.0);

				return float4(col.rgb, 0.0);
			}
			ENDCG
		}
	}
}
