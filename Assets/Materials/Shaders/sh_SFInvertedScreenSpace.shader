

Shader "SF/InvertedScreenSpace"
{
	Properties
	{
		_Bleed("Bleed", Range( 0 , 1)) = 0.535
		_Color("Color", Color) = (0,0,0,0)
		_UseColorScheme("Use Colorscheme", Range( 0 , 1)) = 0
		_Glow("Glow", Range( 0 , 1)) = 0.2
		_ScreenTexture("Screen Texture", 2D) = "white" {}
		_TextureOpacity("Texture Opacity", Range( 0 , 1)) = 1
		_TextureRepetition("Texture Repetition", Range( 0 , 1)) = 0.3
		_TexturePower("Texture Power", Range( 0 , 1)) = 0.2

	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float3 viewDir;
		};

		uniform sampler2D _ScreenTexture;
		uniform float _TextureRepetition;
		uniform float _TexturePower;
		uniform float _TextureOpacity;
		uniform float4 _Color;
		uniform float _Bleed;
		uniform float _Glow;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos14 = UnityObjectToClipPos( vertex3Pos );
			float4 computeScreenPos12 = ComputeScreenPos( unityObjectToClipPos14 );
			float temp_output_25_0 = ( _TextureRepetition * 10.0 );
			float2 appendResult27 = (float2(temp_output_25_0 , temp_output_25_0));
			float4 temp_cast_2 = (( _TexturePower * 5.0 )).xxxx;
			float3 worldNormal = i.worldNormal;
			float dotResult4 = dot( worldNormal , i.viewDir );
			float temp_output_32_0 = round( pow( ( 1.0 - dotResult4 ) , ( ( 1.0 - _Bleed ) * 7.0 ) ) );
			float4 lerpResult16 = lerp( ( pow( tex2D( _ScreenTexture, ( ( computeScreenPos12 / (computeScreenPos12).w ) * float4( appendResult27, 0.0 , 0.0 ) ).xy ) , temp_cast_2 ) * _TextureOpacity ) , ( _Color * temp_output_32_0 ) , temp_output_32_0);
			o.Emission = lerpResult16.rgb;
			o.Alpha = ( temp_output_32_0 * _Glow );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"

}

