﻿Shader "Custom/Base_BlinnPhong" { //how shader shows up in editor
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
		#pragma surface surf BlinnPhong fullforwardshadows

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
