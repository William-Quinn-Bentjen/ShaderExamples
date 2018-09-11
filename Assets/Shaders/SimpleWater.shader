Shader "Custom/SimpleWater" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0

		_WaveSpeed("Wave Speed", float) = 30
		_WaveAmp("Wave Amplitude", float) = 1
		_NoiseTex("Noise Texure", 2D) = "white" {}
		_NoiseNormalMap("Noise Normal", 2D) = "white" {}
		_SecondNoiseNormalMap("Second Noise Normal", 2D) = "white" {}
		_ScrollSpeed("Scroll Speed", Vector) = (1,1,1,1)
		_Tess("Tessalation", Range(1,8)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert tessellate:tess

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		

		struct Input {
			float2 uv_MainTex;
			float2 uv_NoiseTex;
			float2 uv_NoiseNormalMap;
			float2 uv_SecondNoiseNormalMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		sampler2D _NoiseTex;
		sampler2D _NoiseNormalMap;
		sampler2D _SecondNoiseNormalMap;
		fixed4 _ScrollSpeed;
		float _WaveSpeed;
		float _WaveAmp;
		uniform float _Tess;

		float4 tess()
		{
			return _Tess;
		}
		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here

		UNITY_INSTANCING_BUFFER_END(Props)

		void vert(inout appdata_full v)
		{
			float noiseSample = tex2Dlod(_NoiseNormalMap, float4(v.texcoord.xy + _ScrollSpeed.xy, 0, 0));
			//float noiseSample2 = tex2Dlod(_SecondNoiseNormalMap, float4(v.texcoord.xy + _ScrollSpeed.zw, 0 ,0));
			float wave = sin(_Time * _WaveSpeed * noiseSample * _Time.x/*lerp(noiseSample, noiseSample2, _SinTime/2)*/) * _WaveAmp;
			v.vertex.y += wave;
			v.normal.y += wave;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex.xy + _ScrollSpeed.xy * _Time /** _SinTime*/);
			fixed4 c2 = tex2D(_NoiseTex, IN.uv_NoiseTex.xy + _ScrollSpeed.zw /** _CosTime*/);
			o.Albedo = c.rgb * _Color;// lerp(c, c2, (_SinTime / 4 + 1)).rgb * _Color;//c.rgb;
			
			o.Normal = UnpackNormal(tex2D(_NoiseNormalMap, IN.uv_NoiseNormalMap + _ScrollSpeed.xy * _Time) + tex2D(_SecondNoiseNormalMap, IN.uv_SecondNoiseNormalMap + _ScrollSpeed.zw * _Time));
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
