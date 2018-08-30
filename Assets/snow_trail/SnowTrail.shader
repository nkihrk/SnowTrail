Shader "Custom/SnowTrail"
{

    Properties
    {
        _Color ("Color", color) = (1, 1, 1, 0)
        _MainTex ("Base (RGB)", 2D) = "white" { }
        _DispTex ("Disp Texture", 2D) = "gray" { }
        _NormalMap ("Normalmap", 2D) = "bump" { }
        _SpecColor ("Spec color", color) = (0.5, 0.5, 0.5, 0.5)
        _MinDist ("Min Distance", Range(0.1, 50)) = 10
        _MaxDist ("Max Distance", Range(0.1, 50)) = 25
        _TessFactor ("Tessellation", Range(1, 50)) = 10
        _Displacement ("Displacement", Range(0, 1.0)) = 0.3
    }

    SubShader
    {

        Tags { "RenderType" = "Opaque" }
        
        CGPROGRAM
        
        #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessDistance nolightmap
        #pragma target 5.0
        #include "Tessellation.cginc"

        float _TessFactor;
        float _Displacement;
        float _MinDist;
        float _MaxDist;
        sampler2D _DispTex;
        sampler2D _MainTex;
        sampler2D _NormalMap;
        fixed4 _Color;

        struct appdata
        {
            float4 vertex: POSITION;
            float4 tangent: TANGENT;
            float3 normal: NORMAL;
            float2 texcoord: TEXCOORD0;
        };

        struct Input
        {
            float2 uv_MainTex;
        };

        float4 tessDistance(appdata v0, appdata v1, appdata v2)
        {
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _MinDist, _MaxDist, _TessFactor);
        }

        void disp(inout appdata v)
        {
            float d = tex2Dlod(_DispTex, float4(1 - v.texcoord.x, v.texcoord.y, 0, 0)).r * _Displacement;
            v.vertex.xyz += v.normal * (1 - d);
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Specular = 0.2;
            o.Gloss = 1.0;
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
        }
        
        ENDCG
        
    }

    FallBack "Diffuse"
}