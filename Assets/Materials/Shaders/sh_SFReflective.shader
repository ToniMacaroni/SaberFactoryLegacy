Shader "SF/Reflective"
{
	Properties
	{
		_MainTex("Albedo Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_UseColorScheme("Use Colorscheme", Range( 0 , 1)) = 0
		[NoScaleOffset]
		_NormalTex("Normal Texture", 2D) = "bump" {}
		[NoScaleOffset]
		[HideInInspector]_Cubemap("_Cubemap", Cube) = "black" {}
		_Gloss("Gloss", Range(0, 1)) = 0.5
		_Reflectivity("Reflectivity", Range(0, 1)) = 0.5
		_LightStrength("Light Intensity", Range(0, 1)) = 0.01
		_LightDir("_Light Direction", Vector) = (-1, -1, 0)
	}

		SubShader
		{
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float2 uv : TEXCOORD0;
					float3 wNormal : TEXCOORD1;
					float3 wTangent : TEXCOORD2;
					float3 wBitangent : TEXCOORD3;
					float3 eyeVec : TEXCOORD4;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float4 _Color;
				sampler2D _NormalTex;
				samplerCUBE _Cubemap;

				float _Gloss;
				float _Reflectivity;

				float _LightStrength;
				float3 _LightDir;

				v2f vert(appdata v)
				{
					v2f o;

					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.wNormal = UnityObjectToWorldNormal(v.normal);
					o.wTangent = UnityObjectToWorldNormal(v.tangent.xyz);
					o.wBitangent = cross(o.wNormal, o.wTangent) * v.tangent.w * unity_WorldTransformParams.w;

					float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.eyeVec = normalize(worldPos - _WorldSpaceCameraPos);

					return o;
				}

				#define DIFFUSE_MIP_LEVEL 8
				#define GLOSSY_MIP_COUNT 6

				half3 SampleTexCube(samplerCUBE cube, half3 normal, half mip)
				{
					return texCUBElod(cube, half4(normal, mip));
				}

				fixed4 frag(v2f i) : SV_Target
				{
					half3 mainTex = tex2D(_MainTex, i.uv);
					half3 normalTex = tex2D(_NormalTex, i.uv) * 2 - 1;

					half oneMinusReflectivity = 1 - _Reflectivity;
					half roughness = 1 - _Gloss;
					half3 N = normalize(i.wTangent * normalTex.r + i.wBitangent * normalTex.g + i.wNormal * normalTex.b);
					half3 eyeVec = normalize(i.eyeVec);
					half3 R = reflect(eyeVec, N);

					half3 albedoColor = lerp(0, mainTex.rgb, oneMinusReflectivity)*_Color;

					half3 directDiffuse = saturate(dot(N, normalize(_LightDir)*-1));

					half3 indirectDiffuse = SampleTexCube(_Cubemap, N, DIFFUSE_MIP_LEVEL);
					half3 diffuse = albedoColor * (directDiffuse * _LightStrength + indirectDiffuse);

					half3 indirectSpecular = SampleTexCube(_Cubemap, R, roughness * GLOSSY_MIP_COUNT) * _Reflectivity;

					half4 color = 0;
					color.rgb = diffuse + indirectSpecular;

					return color;
				}
				ENDCG
			}
		}
}