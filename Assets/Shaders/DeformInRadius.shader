Shader "Custom/DeformInRadius" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Radius("Radius", float) = 1
		_VectorPos("Vector Position", Vector) = (0,0,0,0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _VectorPos;
		float _Radius;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void vert(inout appdata_full v)
		{

			float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

			//worldpos
			float3 dis = distance(_VectorPos.xyz, worldPos);
			//satureate used for lighting but is being used as a clamp in this case 
			float3 sphere = 1 - (saturate(dis / _Radius));
			float3 dir = worldPos - _VectorPos.xyz;
			v.vertex.xyz += normalize(dir) * sphere;

			//if (distance(sphere, (0,0,0)) > 0)
			//{
			//	//sets direction based on where the vertex is in the world
			//	float3 dir = worldPos - _VectorPos.xyz;
			//	v.vertex.xyz += normalize(dir) * sphere;
			//}

		}
		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
