﻿Shader "DistanceGradient/Terrain/Smooth/4TerrainSmooth"
{
	Properties
	{
		// Top Texture Public Variables

		_TintTop ("Top Tint", Color) = (1, 1, 1, 1)
		_TextureTop ("Top Texture", 2D) = "white" {}
		_TexTopTileX ("Top X Tiling", Float) = 1.0
		_TexTopTileY ("Top Y Tiling", Float) = 1.0
		_TexTopTileZ ("Top Z Tiling", Float) = 1.0
		_TexTopBlendSharpness ("Top Blend Sharpness", Range(0.001, 5)) = 1.0
		[Gamma] _MetallicTop ("Top Metallic", Range(0, 1)) = 0
		_SmoothnessTop ("Top Smoothness", Range(0, 1)) = 0.5
		
		// Split Variables For Between the Tenth and Top Textures

		_SplitTop ("Top Split Distance", Float) = 30.0
		_BlendTop ("Top Blend Factor", Range(0,1)) = 0.5

		// Third Texture Public Variables

		_Tint3 ("Third Tint", Color) = (1, 1, 1, 1)
		_Texture3 ("Third Texture", 2D) = "white" {}
		_Tex3TileX ("Third X Tiling", Float) = 1.0
		_Tex3TileY ("Third Y Tiling", Float) = 1.0
		_Tex3TileZ ("Third Z Tiling", Float) = 1.0
		_Tex3BlendSharpness ("Third Blend Sharpness", Range(0.001, 5)) = 1.0
		[Gamma] _Metallic3 ("Third Metallic", Range(0, 1)) = 0
		_Smoothness3 ("Third Smoothness", Range(0, 1)) = 0.5
		
		// Split Variables For Between the Second and Third Textures

		_Split2 ("Second Split Distance", Float) = 20.0
		_Blend2 ("Second Blend Factor", Range(0,1)) = 0.5

		// Second Texture Public Variables

		_Tint2 ("Second Tint", Color) = (1, 1, 1, 1)
		_Texture2 ("Second Texture", 2D) = "white" {}
		_Tex2TileX ("Second X Tiling", Float) = 1.0
		_Tex2TileY ("Second Y Tiling", Float) = 1.0
		_Tex2TileZ ("Second Z Tiling", Float) = 1.0
		_Tex2BlendSharpness ("Second Blend Sharpness", Range(0.001, 5)) = 1.0
		[Gamma] _Metallic2 ("Second Metallic", Range(0, 1)) = 0
		_Smoothness2 ("Second Smoothness", Range(0, 1)) = 0.5
		
		// Split Variables For Between the Base and Second Textures

		_Split1 ("First Split Distance", Float) = 10.0
		_Blend1 ("First Blend Factor", Range(0,1)) = 0.5

		// Base Texture Public Variables

		_TintBase ("Base Tint", Color) = (1, 1, 1, 1)
		_TextureBase ("Base Texture", 2D) = "white" {}
		_TexBaseTileX ("Base X Tiling", Float) = 1.0
		_TexBaseTileY ("Base Y Tiling", Float) = 1.0
		_TexBaseTileZ ("Base Z Tiling", Float) = 1.0
		_TexBaseBlendSharpness ("Base Blend Sharpness", Range(0.001, 5)) = 1.0
		[Gamma] _MetallicBase ("Base Metallic", Range(0, 1)) = 0
		_SmoothnessBase ("Base Smoothness", Range(0, 1)) = 0.5
		_Split0 ("Base Split Distance", Float) = 0.001

		// Overarching Variables

		_NoiseMultiplier ("Noise Multiplier", Range(0, 4)) = 0.0

		// Variables Set From Scripts (Hidden Here to Prevent Conflicts Between Script and Shader)

		[HideInInspector]
		_CentrePoint ("Center Point", Vector) = (0, 0, 0, 0)
		[HideInInspector]
		_DirectionScalars ("Direction Scalars", Vector) = (0, 0, 0, 0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma target 4.0

			#pragma multi_compile _ SHADOWS_SCREEN
			#pragma multi_compile _ VERTEXLIGHT_ON

			#pragma vertex vert
			#pragma fragment frag
			
			#define FORWARD_BASE_PASS

			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			struct vertexData
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 normal : TEXCOORD0;
				float3 localPos : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float currentDistance : TEXCOORD3;
				float smooth : TEXCOORD4;
				float3 localNormal : TEXCOORD5;

				SHADOW_COORDS(6)

#if defined(VERTEXLIGHT_ON)
					float3 vertexLightColor : TEXCOORD7;
#endif
			};

				// Top Texture Public Variables

			float4 _TintTop;
			sampler2D _TextureTop;
			float _TexTopTileX;
			float _TexTopTileY;
			float _TexTopTileZ;
			float _TexTopBlendSharpness;
			float _MetallicTop;
			float _SmoothnessTop;

				// Top Split Public Variables

			float _SplitTop;
			float _BlendTop;

				// Third Texture Public Variables

			float4 _Tint3;
			sampler2D _Texture3;
			float _Tex3TileX;
			float _Tex3TileY;
			float _Tex3TileZ;
			float _Tex3BlendSharpness;
			float _Metallic3;
			float _Smoothness3;

				// Second Split Public Variables

			float _Split2;
			float _Blend2;

				// Second Texture Public Variables

			float4 _Tint2;
			sampler2D _Texture2;
			float _Tex2TileX;
			float _Tex2TileY;
			float _Tex2TileZ;
			float _Tex2BlendSharpness;
			float _Metallic2;
			float _Smoothness2;

				// First Split Public Variables

			float _Split1;
			float _Blend1;

				// Base Texture Public Variables

			float4 _TintBase;
			sampler2D _TextureBase;
			float _TexBaseTileX;
			float _TexBaseTileY;
			float _TexBaseTileZ;
			float _TexBaseBlendSharpness;
			float _MetallicBase;
			float _SmoothnessBase;
			float _Split0;

				// Overarching Variables

			float _NoiseMultiplier;

				// Variables Set From Scripts

			float4 _CentrePoint;
			float4 _DirectionScalars;

			void ComputeVertexLightColor (vertexData v, inout v2f i) {
#if defined(VERTEXLIGHT_ON)
					i.vertexLightColor = Shade4PointLights(
						unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
						unity_LightColor[0].rgb, unity_LightColor[1].rgb,
						unity_LightColor[2].rgb, unity_LightColor[3].rgb,
						unity_4LightAtten0, i.worldPos, i.normal
					);
#endif
			}

			v2f vert (vertexData v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.localPos = v.vertex.xyz;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.currentDistance = distance(_CentrePoint.xyz * _DirectionScalars * (1 + _NoiseMultiplier), o.localPos * (_DirectionScalars.xyz * (1 + _NoiseMultiplier))) + (_NoiseMultiplier * frac(sin(dot(o.localPos, float3(12.9898, 78.233, 45.5432))) * 43758));
				float useSmooth = _SmoothnessBase * step(o.currentDistance, _Split0 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_SmoothnessBase, _Smoothness2, _Blend1 * smoothstep(_Split0 * (1 + _NoiseMultiplier), _Split1 * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split0 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _Split1 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_Smoothness2, _Smoothness3, _Blend2 * smoothstep(_Split1 * (1 + _NoiseMultiplier), _Split2 * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split1 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _Split2 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_Smoothness3, _SmoothnessTop, _BlendTop * smoothstep(_Split2 * (1 + _NoiseMultiplier), _SplitTop * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split2 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _SplitTop * (1 + _NoiseMultiplier));
				useSmooth += _SmoothnessTop * step(_SplitTop * (1 + _NoiseMultiplier), o.currentDistance);
				o.smooth = useSmooth;
				o.localNormal = v.normal;
				TRANSFER_SHADOW(o);
				ComputeVertexLightColor(v, o);

				return o;
			}

			UnityLight CreateLight (v2f i) {
				UnityLight light;

#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
					light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
#else
					light.dir = _WorldSpaceLightPos0.xyz;
#endif

				UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

				light.color = _LightColor0.rgb * attenuation;
				light.ndotl = DotClamped(i.normal, light.dir);
				return light;
			}

			UnityIndirect CreateIndirectLight (v2f i) {
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

#if defined(VERTEXLIGHT_ON)
					indirectLight.diffuse = i.vertexLightColor;
#endif

#if defined(FORWARD_BASE_PASS)
					indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
#endif

				return indirectLight;
			}

			float4 GetTriplanar(sampler2D tex, v2f i, float tileX, float tileY, float tileZ, float blendSharpness) {

				float2 xUV = i.localPos.yz / tileX;
				float2 yUV = i.localPos.xz / tileY;
				float2 zUV = i.localPos.xy / tileZ;

				float4 xTex = tex2D(tex, xUV);
				float4 yTex = tex2D(tex, yUV);
				float4 zTex = tex2D(tex, zUV);

				float3 blendWeights = pow (abs(i.localNormal), blendSharpness);

				blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);

				float4 triBlend = xTex * blendWeights.x + yTex * blendWeights.y + zTex * blendWeights.z;
				return triBlend;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//Remove this if performance is an issue
				//(the error from not renormalizing is usually very small)
				i.normal = normalize(i.normal);

				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 specularTint;
				float oneMinusReflectivity;

				UnityLight direct = CreateLight(i);
				UnityIndirect indirect = CreateIndirectLight(i);
	
				// Get Pixel Color for Base Texture

				float3 albedoBase = GetTriplanar(_TextureBase, i, _TexBaseTileX, _TexBaseTileY, _TexBaseTileZ, _TexBaseBlendSharpness).rgb * _TintBase.rgb;
				albedoBase = DiffuseAndSpecularFromMetallic(albedoBase, _MetallicBase, specularTint, oneMinusReflectivity);
				

				// Get Pixel Color for Second Texture

				float3 albedo2 = GetTriplanar(_Texture2, i, _Tex2TileX, _Tex2TileY, _Tex2TileZ, _Tex2BlendSharpness).rgb * _Tint2.rgb;
				albedo2 = DiffuseAndSpecularFromMetallic(albedo2, _Metallic2, specularTint, oneMinusReflectivity);

				// Get Pixel Color for Third Texture

				float3 albedo3 = GetTriplanar(_Texture3, i, _Tex3TileX, _Tex3TileY, _Tex3TileZ, _Tex3BlendSharpness).rgb * _Tint3.rgb;
				albedo3 = DiffuseAndSpecularFromMetallic(albedo3, _Metallic3, specularTint, oneMinusReflectivity);

				// Get Pixel Color for Top Texture

				float3 albedoTop = GetTriplanar(_TextureTop, i, _TexTopTileX, _TexTopTileY, _TexTopTileZ, _TexTopBlendSharpness).rgb * _TintTop.rgb;
				albedoTop = DiffuseAndSpecularFromMetallic(albedoTop, _MetallicTop, specularTint, oneMinusReflectivity);

				// !!!! NEED THIS TO STOP METALLIC VALUES FROM TOP TEXTURE BLEEDING THROUGH TO OTHER TEXTURES IF METALLIC != 0 !!!!

				float3 albedoClear = float3 (0.0, 0.0, 0.0);
				albedoClear = DiffuseAndSpecularFromMetallic(albedoClear, 0, specularTint, oneMinusReflectivity);

				// Get the Pixel Output Based on Distance

				float3 c = albedoBase * step(i.currentDistance, _Split0 * (1 + _NoiseMultiplier));
				c += lerp(albedoBase, albedo2, _Blend1 * smoothstep(_Split0 * (1 + _NoiseMultiplier), _Split1 * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split0 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _Split1 * (1 + _NoiseMultiplier));
				c += lerp(albedo2, albedo3, _Blend2 * smoothstep(_Split1 * (1 + _NoiseMultiplier), _Split2 * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split1 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _Split2 * (1 + _NoiseMultiplier));
				c += lerp(albedo3, albedoTop, _BlendTop * smoothstep(_Split2 * (1 + _NoiseMultiplier), _SplitTop * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split2 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _SplitTop * (1 + _NoiseMultiplier));
				c += albedoTop * step(_SplitTop * (1 + _NoiseMultiplier), i.currentDistance);

				float4 col = UNITY_BRDF_PBS(
					c, specularTint,
					oneMinusReflectivity, i.smooth,
					i.normal, viewDir,
					direct, indirect
				);
				col.a = 1;
				return col; 
			}
			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }
			Blend One One
			ZWrite Off

			CGPROGRAM

			#pragma target 4.0

			#pragma multi_compile_fwdadd_fullshadows

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			struct vertexData
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 normal : TEXCOORD0;
				float3 localPos : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float currentDistance : TEXCOORD3;
				float smooth : TEXCOORD4;
				float3 localNormal : TEXCOORD5;

				SHADOW_COORDS(6)

#if defined(VERTEXLIGHT_ON)
					float3 vertexLightColor : TEXCOORD7;
#endif
			};

				// Top Texture Public Variables

			float4 _TintTop;
			sampler2D _TextureTop;
			float _TexTopTileX;
			float _TexTopTileY;
			float _TexTopTileZ;
			float _TexTopBlendSharpness;
			float _MetallicTop;
			float _SmoothnessTop;

				// Top Split Public Variables

			float _SplitTop;
			float _BlendTop;

				// Third Texture Public Variables

			float4 _Tint3;
			sampler2D _Texture3;
			float _Tex3TileX;
			float _Tex3TileY;
			float _Tex3TileZ;
			float _Tex3BlendSharpness;
			float _Metallic3;
			float _Smoothness3;

				// Second Split Public Variables

			float _Split2;
			float _Blend2;

				// Second Texture Public Variables

			float4 _Tint2;
			sampler2D _Texture2;
			float _Tex2TileX;
			float _Tex2TileY;
			float _Tex2TileZ;
			float _Tex2BlendSharpness;
			float _Metallic2;
			float _Smoothness2;

				// First Split Public Variables

			float _Split1;
			float _Blend1;

				// Base Texture Public Variables

			float4 _TintBase;
			sampler2D _TextureBase;
			float _TexBaseTileX;
			float _TexBaseTileY;
			float _TexBaseTileZ;
			float _TexBaseBlendSharpness;
			float _MetallicBase;
			float _SmoothnessBase;
			float _Split0;

				// Overarching Variables

			float _NoiseMultiplier;

				// Variables Set From Scripts

			float4 _CentrePoint;
			float4 _DirectionScalars;

			void ComputeVertexLightColor (vertexData v, inout v2f i) {
#if defined(VERTEXLIGHT_ON)
					i.vertexLightColor = Shade4PointLights(
						unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
						unity_LightColor[0].rgb, unity_LightColor[1].rgb,
						unity_LightColor[2].rgb, unity_LightColor[3].rgb,
						unity_4LightAtten0, i.worldPos, i.normal
					);
#endif
			}

			v2f vert (vertexData v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.localPos = v.vertex.xyz;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.currentDistance = distance(_CentrePoint.xyz * _DirectionScalars * (1 + _NoiseMultiplier), o.localPos * (_DirectionScalars.xyz * (1 + _NoiseMultiplier))) + (_NoiseMultiplier * frac(sin(dot(o.localPos, float3(12.9898, 78.233, 45.5432))) * 43758));
				float useSmooth = _SmoothnessBase * step(o.currentDistance, _Split0 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_SmoothnessBase, _Smoothness2, _Blend1 * smoothstep(_Split0 * (1 + _NoiseMultiplier), _Split1 * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split0 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _Split1 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_Smoothness2, _Smoothness3, _Blend2 * smoothstep(_Split1 * (1 + _NoiseMultiplier), _Split2 * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split1 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _Split2 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_Smoothness3, _SmoothnessTop, _BlendTop * smoothstep(_Split2 * (1 + _NoiseMultiplier), _SplitTop * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split2 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _SplitTop * (1 + _NoiseMultiplier));
				useSmooth += _SmoothnessTop * step(_SplitTop * (1 + _NoiseMultiplier), o.currentDistance);
				o.smooth = useSmooth;
				o.localNormal = v.normal;
				TRANSFER_SHADOW(o);
				ComputeVertexLightColor(v, o);

				return o;
			}

			UnityLight CreateLight (v2f i) {
				UnityLight light;

#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
					light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
#else
					light.dir = _WorldSpaceLightPos0.xyz;
#endif

				UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

				light.color = _LightColor0.rgb * attenuation;
				light.ndotl = DotClamped(i.normal, light.dir);
				return light;
			}

			UnityIndirect CreateIndirectLight (v2f i) {
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

#if defined(VERTEXLIGHT_ON)
					indirectLight.diffuse = i.vertexLightColor;
#endif

#if defined(FORWARD_BASE_PASS)
					indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
#endif

				return indirectLight;
			}

			float4 GetTriplanar(sampler2D tex, v2f i, float tileX, float tileY, float tileZ, float blendSharpness) {

				float2 xUV = i.localPos.yz / tileX;
				float2 yUV = i.localPos.xz / tileY;
				float2 zUV = i.localPos.xy / tileZ;

				float4 xTex = tex2D(tex, xUV);
				float4 yTex = tex2D(tex, yUV);
				float4 zTex = tex2D(tex, zUV);

				float3 blendWeights = pow (abs(i.localNormal), blendSharpness);

				blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);

				float4 triBlend = xTex * blendWeights.x + yTex * blendWeights.y + zTex * blendWeights.z;
				return triBlend;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//Remove this if performance is an issue
				//(the error from not renormalizing is usually very small)
				i.normal = normalize(i.normal);

				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 specularTint;
				float oneMinusReflectivity;

				UnityLight direct = CreateLight(i);
				UnityIndirect indirect = CreateIndirectLight(i);
	
				// Get Pixel Color for Base Texture

				float3 albedoBase = GetTriplanar(_TextureBase, i, _TexBaseTileX, _TexBaseTileY, _TexBaseTileZ, _TexBaseBlendSharpness).rgb * _TintBase.rgb;
				albedoBase = DiffuseAndSpecularFromMetallic(albedoBase, _MetallicBase, specularTint, oneMinusReflectivity);
				

				// Get Pixel Color for Second Texture

				float3 albedo2 = GetTriplanar(_Texture2, i, _Tex2TileX, _Tex2TileY, _Tex2TileZ, _Tex2BlendSharpness).rgb * _Tint2.rgb;
				albedo2 = DiffuseAndSpecularFromMetallic(albedo2, _Metallic2, specularTint, oneMinusReflectivity);

				// Get Pixel Color for Third Texture

				float3 albedo3 = GetTriplanar(_Texture3, i, _Tex3TileX, _Tex3TileY, _Tex3TileZ, _Tex3BlendSharpness).rgb * _Tint3.rgb;
				albedo3 = DiffuseAndSpecularFromMetallic(albedo3, _Metallic3, specularTint, oneMinusReflectivity);

				// Get Pixel Color for Top Texture

				float3 albedoTop = GetTriplanar(_TextureTop, i, _TexTopTileX, _TexTopTileY, _TexTopTileZ, _TexTopBlendSharpness).rgb * _TintTop.rgb;
				albedoTop = DiffuseAndSpecularFromMetallic(albedoTop, _MetallicTop, specularTint, oneMinusReflectivity);

				// !!!! NEED THIS TO STOP METALLIC VALUES FROM TOP TEXTURE BLEEDING THROUGH TO OTHER TEXTURES IF METALLIC != 0 !!!!

				float3 albedoClear = float3 (0.0, 0.0, 0.0);
				albedoClear = DiffuseAndSpecularFromMetallic(albedoClear, 0, specularTint, oneMinusReflectivity);

				// Get the Pixel Output Based on Distance

				float3 c = albedoBase * step(i.currentDistance, _Split0 * (1 + _NoiseMultiplier));
				c += lerp(albedoBase, albedo2, _Blend1 * smoothstep(_Split0 * (1 + _NoiseMultiplier), _Split1 * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split0 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _Split1 * (1 + _NoiseMultiplier));
				c += lerp(albedo2, albedo3, _Blend2 * smoothstep(_Split1 * (1 + _NoiseMultiplier), _Split2 * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split1 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _Split2 * (1 + _NoiseMultiplier));
				c += lerp(albedo3, albedoTop, _BlendTop * smoothstep(_Split2 * (1 + _NoiseMultiplier), _SplitTop * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split2 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _SplitTop * (1 + _NoiseMultiplier));
				c += albedoTop * step(_SplitTop * (1 + _NoiseMultiplier), i.currentDistance);

				float4 col = UNITY_BRDF_PBS(
					c, specularTint,
					oneMinusReflectivity, i.smooth,
					i.normal, viewDir,
					direct, indirect
				);
				col.a = 1;
				return col; 
			}
			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ShadowCaster" }

			CGPROGRAM

			#pragma target 4.0

			#pragma multi_compile_shadowcaster

			#pragma vertex shadowVert
			#pragma fragment shadowFrag

			#include "UnityCG.cginc"

			struct vertexData {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

#if defined(SHADOWS_CUBE)
				struct v2f {
					float4 position : SV_POSITION;
					float3 lightVec : TEXCOORD0;
				};

				v2f shadowVert (vertexData v) {
					v2f i;
					i.position = UnityObjectToClipPos(v.vertex);
					i.lightVec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz;
					return i;
				}
	
				float4 shadowFrag (v2f i) : SV_TARGET {
					float depth = length(i.lightVec) + unity_LightShadowBias.x;
					depth *= _LightPositionRange.w;
					return UnityEncodeCubeShadowDepth(depth);
				}
#else
			float4 shadowVert (vertexData v) : SV_POSITION {
				float4 position = UnityClipSpaceShadowCasterPos(v.vertex.xyz, v.normal);
				return UnityApplyLinearShadowBias(position);
			}

			half4 shadowFrag () : SV_TARGET {
				return 0;
			}
#endif


			ENDCG
		}
	}
}