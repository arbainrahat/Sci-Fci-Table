Shader "DistanceGradient/Color/LowPoly/3ColorLowPoly"
{
	Properties
	{
		// Top Color Public Variables

		_ColorTop ("Top Tint", Color) = (1, 1, 1, 1)

		[Gamma] _MetallicTop ("Top Metallic", Range(0, 1)) = 0
		_SmoothnessTop ("Top Smoothness", Range(0, 1)) = 0.5
		
		// Split Variables For Between the Tenth and Top Textures

		_SplitTop ("Top Split Distance", Float) = 20.0
		_BlendTop ("Top Blend Factor", Range(0,1)) = 0.5

		// Second Texture Public Variables

		_Color2 ("Second Tint", Color) = (1, 1, 1, 1)

		[Gamma] _Metallic2 ("Second Metallic", Range(0, 1)) = 0
		_Smoothness2 ("Second Smoothness", Range(0, 1)) = 0.5
		
		// Split Variables For Between the Base and Second Textures

		_Split1 ("First Split Distance", Float) = 10.0
		_Blend1 ("First Blend Factor", Range(0,1)) = 0.5

		// Base Texture Public Variables

		_ColorBase ("Base Tint", Color) = (1, 1, 1, 1)

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
			#pragma geometry geom
			#pragma fragment frag
			
			#define FORWARD_BASE_PASS

			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			struct vertexData
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2g
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 localPos : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float currentDistance : TEXCOORD3;
				float smooth : TEXCOORD4;
				SHADOW_COORDS(5)

#if defined(VERTEXLIGHT_ON)
				float3 vertexLightColor : TEXCOORD6;
#endif
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 localPos : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float currentDistance : TEXCOORD3;
				float3 faceNormal : TEXCOORD4;
				float smooth : TEXCOORD5;
				SHADOW_COORDS(6)

#if defined(VERTEXLIGHT_ON)
				float3 vertexLightColor : TEXCOORD7;
#endif
			};

				// Top Texture Public Variables

			float4 _ColorTop;

			float _MetallicTop;
			float _SmoothnessTop;

				// Top Split Public Variables

			float _SplitTop;
			float _BlendTop;

				// Second Texture Public Variables

			float4 _Color2;
			
			float _Metallic2;
			float _Smoothness2;

				// First Split Public Variables

			float _Split1;
			float _Blend1;

				// Base Texture Public Variables

			float4 _ColorBase;
		
			float _MetallicBase;
			float _SmoothnessBase;
			float _Split0;

				// Overarching Variables

			float _NoiseMultiplier;

				// Variables Set From Scripts

			float4 _CentrePoint;
			float4 _DirectionScalars;

			void ComputeVertexLightColor (vertexData v, inout v2g i) {
#if defined(VERTEXLIGHT_ON)
					i.vertexLightColor = Shade4PointLights(
						unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
						unity_LightColor[0].rgb, unity_LightColor[1].rgb,
						unity_LightColor[2].rgb, unity_LightColor[3].rgb,
						unity_4LightAtten0, i.worldPos, i.worldNormal
					);
#endif
			}

			v2g vert (vertexData v)
			{
				v2g o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.localPos = v.vertex.xyz;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.currentDistance = distance(_CentrePoint.xyz * _DirectionScalars * (1 + _NoiseMultiplier), o.localPos * (_DirectionScalars.xyz * (1 + _NoiseMultiplier))) + (_NoiseMultiplier * frac(sin(dot(o.localPos, float3(12.9898, 78.233, 45.5432))) * 43758));
				float useSmooth = _SmoothnessBase * step(o.currentDistance, _Split0 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_SmoothnessBase, _Smoothness2, _Blend1 * smoothstep(_Split0 * (1 + _NoiseMultiplier), _Split1 * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split0 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _Split1 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_Smoothness2, _SmoothnessTop, _BlendTop * smoothstep(_Split1 * (1 + _NoiseMultiplier), _SplitTop * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split1 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _SplitTop * (1 + _NoiseMultiplier));
				useSmooth += _SmoothnessTop * step(_SplitTop * (1 + _NoiseMultiplier), o.currentDistance);
				o.smooth = useSmooth;

				TRANSFER_SHADOW(o);

				ComputeVertexLightColor(v, o);

				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
				float3 A = IN[1].worldPos.xyz - IN[0].worldPos.xyz;
				float3 B = IN[2].worldPos.xyz - IN[0].worldPos.xyz;
				float3 fn = normalize(cross(A, B));

				g2f o;
				o.pos = IN[0].pos;
				o.worldPos = IN[0].worldPos;
				o.faceNormal = fn;
				o.localPos = IN[0].localPos;
				o.worldNormal = IN[0].worldNormal;
				o.currentDistance = IN[0].currentDistance;
				o.smooth = IN[0].smooth;
#if defined (SHADOWS_SCREEN) 
				o._ShadowCoord = IN[0]._ShadowCoord;
#endif
#if defined (VERTEXLIGHT_ON) 
				o.vertexLightColor = IN[0].vertexLightColor;
#endif
				triStream.Append(o);

				o.pos = IN[1].pos;
				o.worldPos = IN[1].worldPos;
				o.faceNormal = fn;
				o.localPos = IN[1].localPos;
				o.worldNormal = IN[1].worldNormal;
				o.currentDistance = IN[1].currentDistance;
				o.smooth = IN[1].smooth;
#if defined (SHADOWS_SCREEN) 
				o._ShadowCoord = IN[1]._ShadowCoord;
#endif
#if defined (VERTEXLIGHT_ON) 
				o.vertexLightColor = IN[1].vertexLightColor;
#endif
				triStream.Append(o);

				o.pos = IN[2].pos;
				o.worldPos = IN[2].worldPos;
				o.faceNormal = fn;
				o.localPos = IN[2].localPos;
				o.worldNormal = IN[2].worldNormal;
				o.currentDistance = IN[2].currentDistance;
#if defined (SHADOWS_SCREEN) 
				o._ShadowCoord = IN[2]._ShadowCoord;
#endif
#if defined (VERTEXLIGHT_ON) 
				o.vertexLightColor = IN[2].vertexLightColor;
#endif
				o.smooth = IN[2].smooth;
				triStream.Append(o);
			}


			UnityLight CreateLight (g2f i) {
				UnityLight light;

#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
				light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
#else
				light.dir = _WorldSpaceLightPos0.xyz;
#endif

#if defined(SHADOWS_SCREEN)
				float attenuation = SHADOW_ATTENUATION(i);
#else
				UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
#endif

				light.color = _LightColor0.rgb * attenuation;
				light.ndotl = DotClamped(i.faceNormal, light.dir);
				return light;
			}

			UnityIndirect CreateIndirectLight (g2f i) {
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

#if defined(VERTEXLIGHT_ON)
				indirectLight.diffuse = i.vertexLightColor;
#endif

#if defined(FORWARD_BASE_PASS)
				indirectLight.diffuse += max(0, ShadeSH9(float4(i.faceNormal, 1)));
#endif

				return indirectLight;
			}

			fixed4 frag (g2f i) : SV_Target
			{
				//Remove this if performance is an issue
				//(the error from not renormalizing is usually very small)
				i.faceNormal = normalize(i.faceNormal);

				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 specularTint;
				float oneMinusReflectivity;

				UnityLight direct = CreateLight(i);
				UnityIndirect indirect = CreateIndirectLight(i);
	
				// Get Pixel Color for Base Texture

				float3 albedoBase = DiffuseAndSpecularFromMetallic(_ColorBase, _MetallicBase, specularTint, oneMinusReflectivity);
				
				// Get Pixel Color for Second Texture

				float3 albedo2 = DiffuseAndSpecularFromMetallic(_Color2, _Metallic2, specularTint, oneMinusReflectivity);

				// Get Pixel Color for Top Texture

				float3 albedoTop = DiffuseAndSpecularFromMetallic(_ColorTop, _MetallicTop, specularTint, oneMinusReflectivity);

				// !!!! NEED THIS TO STOP METALLIC VALUES FROM TOP TEXTURE BLEEDING THROUGH TO OTHER TEXTURES IF METALLIC != 0 !!!!

				float3 albedoClear = float3 (0.0, 0.0, 0.0);
				albedoClear = DiffuseAndSpecularFromMetallic(albedoClear, 0, specularTint, oneMinusReflectivity);

				// Get the Pixel Output Based on Distance

				float3 c = albedoBase * step(i.currentDistance, _Split0 * (1 + _NoiseMultiplier));
				c += lerp(albedoBase, albedo2, _Blend1 * smoothstep(_Split0 * (1 + _NoiseMultiplier), _Split1 * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split0 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _Split1 * (1 + _NoiseMultiplier));
				c += lerp(albedo2, albedoTop, _BlendTop * smoothstep(_Split1 * (1 + _NoiseMultiplier), _SplitTop * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split1 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _SplitTop * (1 + _NoiseMultiplier));
				c += albedoTop * step(_SplitTop * (1 + _NoiseMultiplier), i.currentDistance);

				float4 col = UNITY_BRDF_PBS(
					c, specularTint,
					oneMinusReflectivity, i.smooth,
					i.faceNormal, viewDir,
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
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			struct vertexData
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2g
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 localPos : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float currentDistance : TEXCOORD3;
				float smooth : TEXCOORD4;
				SHADOW_COORDS(5)

#if defined(VERTEXLIGHT_ON)
				float3 vertexLightColor : TEXCOORD6;
#endif
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 localPos : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float currentDistance : TEXCOORD3;
				float3 faceNormal : TEXCOORD4;
				float smooth : TEXCOORD5;
				SHADOW_COORDS(6)

#if defined(VERTEXLIGHT_ON)
				float3 vertexLightColor : TEXCOORD7;
#endif
			};

				// Top Texture Public Variables

			float4 _ColorTop;

			float _MetallicTop;
			float _SmoothnessTop;

				// Top Split Public Variables

			float _SplitTop;
			float _BlendTop;

				// Second Texture Public Variables

			float4 _Color2;
			
			float _Metallic2;
			float _Smoothness2;

				// First Split Public Variables

			float _Split1;
			float _Blend1;

				// Base Texture Public Variables

			float4 _ColorBase;
		
			float _MetallicBase;
			float _SmoothnessBase;
			float _Split0;

				// Overarching Variables

			float _NoiseMultiplier;

				// Variables Set From Scripts

			float4 _CentrePoint;
			float4 _DirectionScalars;

			void ComputeVertexLightColor (vertexData v, inout v2g i) {
#if defined(VERTEXLIGHT_ON)
					i.vertexLightColor = Shade4PointLights(
						unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
						unity_LightColor[0].rgb, unity_LightColor[1].rgb,
						unity_LightColor[2].rgb, unity_LightColor[3].rgb,
						unity_4LightAtten0, i.worldPos, i.worldNormal
					);
#endif
			}

			v2g vert (vertexData v)
			{
				v2g o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.localPos = v.vertex.xyz;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.currentDistance = distance(_CentrePoint.xyz * _DirectionScalars * (1 + _NoiseMultiplier), o.localPos * (_DirectionScalars.xyz * (1 + _NoiseMultiplier))) + (_NoiseMultiplier * frac(sin(dot(o.localPos, float3(12.9898, 78.233, 45.5432))) * 43758));
				float useSmooth = _SmoothnessBase * step(o.currentDistance, _Split0 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_SmoothnessBase, _Smoothness2, _Blend1 * smoothstep(_Split0 * (1 + _NoiseMultiplier), _Split1 * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split0 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _Split1 * (1 + _NoiseMultiplier));
				useSmooth += lerp(_Smoothness2, _SmoothnessTop, _BlendTop * smoothstep(_Split1 * (1 + _NoiseMultiplier), _SplitTop * (1 + _NoiseMultiplier), o.currentDistance)) * step(_Split1 * (1 + _NoiseMultiplier), o.currentDistance) * step(o.currentDistance, _SplitTop * (1 + _NoiseMultiplier));
				useSmooth += _SmoothnessTop * step(_SplitTop * (1 + _NoiseMultiplier), o.currentDistance);
				o.smooth = useSmooth;
				TRANSFER_SHADOW(o);

				ComputeVertexLightColor(v, o);

				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
				float3 A = IN[1].worldPos.xyz - IN[0].worldPos.xyz;
				float3 B = IN[2].worldPos.xyz - IN[0].worldPos.xyz;
				float3 fn = normalize(cross(A, B));

				g2f o;
				o.pos = IN[0].pos;
				o.worldPos = IN[0].worldPos;
				o.faceNormal = fn;
				o.localPos = IN[0].localPos;
				o.worldNormal = IN[0].worldNormal;
				o.currentDistance = IN[0].currentDistance;
				o.smooth = IN[0].smooth;
#if defined (SHADOWS_SCREEN) || defined(SHADOWS_CUBE) || defined (SHADOWS_DEPTH)
				o._ShadowCoord = IN[0]._ShadowCoord;
#endif
#if defined (VERTEXLIGHT_ON)
				o.vertexLightColor = IN[0].vertexLightColor;
#endif
				triStream.Append(o);

				o.pos = IN[1].pos;
				o.worldPos = IN[1].worldPos;
				o.faceNormal = fn;
				o.localPos = IN[1].localPos;
				o.worldNormal = IN[1].worldNormal;
				o.currentDistance = IN[1].currentDistance;
				o.smooth = IN[1].smooth;
#if defined (SHADOWS_SCREEN) || defined(SHADOWS_CUBE) || defined (SHADOWS_DEPTH)
				o._ShadowCoord = IN[1]._ShadowCoord;
#endif
#if defined (VERTEXLIGHT_ON)
				o.vertexLightColor = IN[1].vertexLightColor;
#endif
				triStream.Append(o);

				o.pos = IN[2].pos;
				o.worldPos = IN[2].worldPos;
				o.faceNormal = fn;
				o.localPos = IN[2].localPos;
				o.worldNormal = IN[2].worldNormal;
				o.currentDistance = IN[2].currentDistance;
				o.smooth = IN[2].smooth;
#if defined (SHADOWS_SCREEN) || defined(SHADOWS_CUBE) || defined (SHADOWS_DEPTH)
				o._ShadowCoord = IN[2]._ShadowCoord;
#endif
#if defined (VERTEXLIGHT_ON)
				o.vertexLightColor = IN[2].vertexLightColor;
#endif
				triStream.Append(o);
			}


			UnityLight CreateLight (g2f i) {
				UnityLight light;

#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
				light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
#else
				light.dir = _WorldSpaceLightPos0.xyz;
#endif

#if defined(SHADOWS_SCREEN)
				float attenuation = SHADOW_ATTENUATION(i);
#else
				UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
#endif

				light.color = _LightColor0.rgb * attenuation;
				light.ndotl = DotClamped(i.faceNormal, light.dir);
				return light;
			}

			UnityIndirect CreateIndirectLight (g2f i) {
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

#if defined(VERTEXLIGHT_ON)
				indirectLight.diffuse = i.vertexLightColor;
#endif

#if defined(FORWARD_BASE_PASS)
				indirectLight.diffuse += max(0, ShadeSH9(float4(i.faceNormal, 1)));
#endif

				return indirectLight;
			}

			fixed4 frag (g2f i) : SV_Target
			{
				//Remove this if performance is an issue
				//(the error from not renormalizing is usually very small)
				i.faceNormal = normalize(i.faceNormal);

				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 specularTint;
				float oneMinusReflectivity;

				UnityLight direct = CreateLight(i);
				UnityIndirect indirect = CreateIndirectLight(i);
	
				// Get Pixel Color for Base Texture

				float3 albedoBase = DiffuseAndSpecularFromMetallic(_ColorBase, _MetallicBase, specularTint, oneMinusReflectivity);
				
				// Get Pixel Color for Second Texture

				float3 albedo2 = DiffuseAndSpecularFromMetallic(_Color2, _Metallic2, specularTint, oneMinusReflectivity);

				// Get Pixel Color for Top Texture

				float3 albedoTop = DiffuseAndSpecularFromMetallic(_ColorTop, _MetallicTop, specularTint, oneMinusReflectivity);

				// !!!! NEED THIS TO STOP METALLIC VALUES FROM TOP TEXTURE BLEEDING THROUGH TO OTHER TEXTURES IF METALLIC != 0 !!!!

				float3 albedoClear = float3 (0.0, 0.0, 0.0);
				albedoClear = DiffuseAndSpecularFromMetallic(albedoClear, 0, specularTint, oneMinusReflectivity);

				// Get the Pixel Output Based on Distance

				float3 c = albedoBase * step(i.currentDistance, _Split0 * (1 + _NoiseMultiplier));
				c += lerp(albedoBase, albedo2, _Blend1 * smoothstep(_Split0 * (1 + _NoiseMultiplier), _Split1 * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split0 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _Split1 * (1 + _NoiseMultiplier));
				c += lerp(albedo2, albedoTop, _BlendTop * smoothstep(_Split1 * (1 + _NoiseMultiplier), _SplitTop * (1 + _NoiseMultiplier), i.currentDistance)) * step(_Split1 * (1 + _NoiseMultiplier), i.currentDistance) * step(i.currentDistance, _SplitTop * (1 + _NoiseMultiplier));
				c += albedoTop * step(_SplitTop * (1 + _NoiseMultiplier), i.currentDistance);

				float4 col = UNITY_BRDF_PBS(
					c, specularTint,
					oneMinusReflectivity, i.smooth,
					i.faceNormal, viewDir,
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