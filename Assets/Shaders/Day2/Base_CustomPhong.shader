Shader "Custom/Base_PBRPhong" { //how shader shows up in editor
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "white" {}
		_MainTex2("Albedo 2", 2D) = "white" {} // default white texture
		_NormalMap2("Normal Map 2 Electric Boogaloo", 2D) = "white" {}
		_Shininess("Shininess", Range(0.3,1)) = 0.5
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_AlbedoLerp("Lerp value", Range(0,1)) = 0.0
	}	//public variables
	SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Phong fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MainTex2;
		sampler2D _NormalMap;
		sampler2D _NormalMap2;
		struct Input {
			float2 uv_MainTex;
			float2 uv_MainTex2;
		};

		float _Shininess;
		fixed4 _Color;
		float _AlbedoLerp;
		//properly gets lights
		inline void LightingPhong_GI(SurfaceOutput s, UnityGIInput data, UnityGI gi)
		{
			gi = UnityGlobalIllumination(data, 1.0, s.Normal);
		}

		inline fixed4 LightingPhong(SurfaceOutput s, half3 viewDir, UnityGI gi)
		{
			const float PI = 3.141592653589732;
			UnityLight light = gi.light;
			//angle light is hitting the normal (doesn't take negatives)
			float nl = max(0.0, dot(s.Normal, light.dir)); //angle light hits normal
			//albedo color multiplied by light color multiplied by normal angle
			float3 diffuseTerm = nl * s.Albedo.rgb * light.color; //blends color of light and normal based on nl
			
			float3 norm = (_Shininess + 2) / (2 * PI);

			float3 reflectionDirection = reflect(-light.dir, s.Normal); //Lights always bounce opposite of what they hit
			float3 specularDot = max(0.0 , dot(viewDir, reflectionDirection)); //how much specular we get based on reflection
			float3 specular = norm * pow(specularDot, _Shininess); //Increases our specular
			float3 specularTerm = specular * _SpecColor.rgb * light.color.rgb; // combining light with color
			float3 finalColor = diffuseTerm + specularTerm; // specular is always additive color

			fixed4 c;
			c.rgb = finalColor;
			c.a = s.Alpha;
			#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
				c.rgb += s.Albedo + gi.indirect.diffuse;
			#endif
			return c;
		}

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			fixed4 c2 = tex2D(_MainTex2, IN.uv_MainTex2);
			fixed4 col = lerp(c, c2, _AlbedoLerp) * _Color;
			o.Albedo = col.rgb;
			/*fixed3 normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
			fixed3 normal2 = UnpackNormal(tex2D(_NormalMap2, IN.uv_MainTex2));
			o.Normal = normal;*/
			o.Normal = UnpackNormal(lerp(tex2D(_NormalMap, IN.uv_MainTex), tex2D(_NormalMap2, IN.uv_MainTex2), _AlbedoLerp));

			// Metallic and smoothness come from slider variables
			o.Specular = _Shininess;
			o.Gloss = col.a;
			o.Alpha = 1.0;
		}
		ENDCG
		}
		FallBack "Diffuse"
}
