Shader "Unlit/SpecularForwardAdd"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,0,0,1)
		_Ambient("Ambient", Range(0,1)) = 0.25
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_Shininess ("Shininess", float) = 10
		_BumpMap("Bump Map", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
		Tags{ "Lightmode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};
			//Fill data 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertexClip : SV_POSITION;
				float4 vertexWorld : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				half3 tspace0 : TEXCOORD3;
				half3 tspace1 : TEXCOORD4;
				half3 tspace2 : TEXCOORD5;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float4 _Color;
			float _Ambient;
			//float4 _SpecColor;
			float _Shininess;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertexClip = UnityObjectToClipPos(v.vertex);
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				UNITY_TRANSFER_FOG(o,o.vertex);
				//calulate normal maps
				half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBitangent = cross(worldNormal, worldTangent) * tangentSign;
				//still normal map stuff
				o.tspace0 = half3(worldTangent.x, worldBitangent.x, worldNormal.x);
				o.tspace1 = half3(worldTangent.y, worldBitangent.y, worldNormal.y);
				o.tspace2 = half3(worldTangent.z, worldBitangent.z, worldNormal.z);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{


				float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));
				float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));

				half3 tNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				half3 worldNormal;
				worldNormal.x = dot(i.tspace0, tNormal);
				worldNormal.y = dot(i.tspace1, tNormal);
				worldNormal.z = dot(i.tspace2, tNormal);
				float3 normalDirection = normalize(worldNormal);
				float nl = max(_Ambient, max(dot(normalDirection, _WorldSpaceLightPos0.xyz), dot(normalDirection, lightDirection)));
				fixed4 albedo = tex2D(_MainTex, i.uv);
				float4 diffuseTerm = nl * (albedo * _Color) * _LightColor0;

				//directional light
				//float nl = max(_Ambient, dot(normalDirection, lightDirection));
				//float4 diffuseTerm = nl * (tex2D(_MainTex, i.uv) * _Color) * _LightColor0;
				//specular
				float3 reflectionDirection = reflect(-lightDirection, normalDirection);
				float3 specularDot = max(0.0, dot(viewDirection, reflectionDirection));
				float3 specular = pow(specularDot, _Shininess);
				float4 specularTerm = float4(specular, 1) * _SpecColor * _LightColor0;
				//final color 
				float4 finalColor = diffuseTerm + specularTerm;
				return finalColor;
			}
			ENDCG
		}
		Pass
		{
		Tags{"Lightmode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma multi_compile_fwdadd

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};
			//Fill data 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertexClip : SV_POSITION;
				float4 vertexWorld : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				half3 tspace0 : TEXCOORD3;
				half3 tspace1 : TEXCOORD4;
				half3 tspace2 : TEXCOORD5;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float4 _Color;
			//float4 _SpecColor;
			float _Shininess;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertexClip = UnityObjectToClipPos(v.vertex);
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				UNITY_TRANSFER_FOG(o,o.vertex);
				//calulate normal maps
				half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBitangent = cross(worldNormal, worldTangent) * tangentSign;
				//still normal map stuff
				o.tspace0 = half3(worldTangent.x, worldBitangent.x, worldNormal.x);
				o.tspace1 = half3(worldTangent.y, worldBitangent.y, worldNormal.y);
				o.tspace2 = half3(worldTangent.z, worldBitangent.z, worldNormal.z);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{


				float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));
				float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));

				half3 tNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				half3 worldNormal;
				worldNormal.x = dot(i.tspace0, tNormal);
				worldNormal.y = dot(i.tspace1, tNormal);
				worldNormal.z = dot(i.tspace2, tNormal);
				float3 normalDirection = normalize(worldNormal);
				float nl = max(dot(normalDirection, _WorldSpaceLightPos0.xyz), dot(normalDirection, lightDirection));
				fixed4 albedo = tex2D(_MainTex, i.uv);
				float4 diffuseTerm = nl * (albedo * _Color) * _LightColor0;

				//directional light
				//float nl = max(_Ambient, dot(normalDirection, lightDirection));
				//float4 diffuseTerm = nl * (tex2D(_MainTex, i.uv) * _Color) * _LightColor0;
				//specular
				float3 reflectionDirection = reflect(-lightDirection, normalDirection);
				float3 specularDot = max(0.0, dot(viewDirection, reflectionDirection));
				float3 specular = pow(specularDot, _Shininess);
				float4 specularTerm = float4(specular, 1) * _SpecColor * _LightColor0;
				//final color 
				float4 finalColor = diffuseTerm + specularTerm;
				return finalColor;
			}
				ENDCG
		}
	}
}
