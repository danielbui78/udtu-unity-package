// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_STANDARD_INPUT_INCLUDED
#define UNITY_STANDARD_INPUT_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityPBSLighting.cginc" // TBD: remove
#include "UnityStandardUtils.cginc"

//---------------------------------------
// Directional lightmaps & Parallax require tangent space too
#if (_NORMALMAP || DIRLIGHTMAP_COMBINED || _PARALLAXMAP)
    #define _TANGENT_TO_WORLD 1
#endif

#if (_DETAIL_MULX2 || _DETAIL_MUL || _DETAIL_ADD || _DETAIL_LERP)
    #define _DETAIL 1
#endif

//---------------------------------------
//half4       _Color;
//half        _Cutoff;
half4       _Diffuse;
half        _AlphaClipThreshold;

//sampler2D   _MainTex;
//float4      _MainTex_ST;
sampler2D   _DiffuseMap;
float4      _DiffuseMap_ST;

sampler2D   _DetailAlbedoMap;
float4      _DetailAlbedoMap_ST;

//sampler2D   _BumpMap;
//half        _BumpScale;
sampler2D   _NormalMap;
half        _Normal;

sampler2D   _DetailMask;
sampler2D   _DetailNormalMap;
half        _DetailNormalMapScale;

half4       _SpecularColor;
//sampler2D   _SpecGlossMap;
sampler2D   _SpecularColorMap;
//sampler2D   _MetallicGlossMap;
sampler2D   _MetallicMap;
half        _Metallic;
//float       _Glossiness;
//float       _GlossMapScale;

float       _Roughness;
sampler2D   _RoughnessMap;

sampler2D   _OcclusionMap;
half        _OcclusionStrength;

//sampler2D   _ParallaxMap;
//half        _Parallax;
sampler2D   _HeightMap;
half        _Height;
half        _UVSec;

half4       _Emission;
sampler2D   _EmissionMap;

float       _Alpha;
sampler2D   _AlphaMap;


//-------------------------------------------------------------------------------------
// Input functions

struct VertexInput
{
    float4 vertex   : POSITION;
    half3 normal    : NORMAL;
    float2 uv0      : TEXCOORD0;
    float2 uv1      : TEXCOORD1;
#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
    float2 uv2      : TEXCOORD2;
#endif
#ifdef _TANGENT_TO_WORLD
    half4 tangent   : TANGENT;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

float4 TexCoords(VertexInput v)
{
    float4 texcoord;
    texcoord.xy = TRANSFORM_TEX(v.uv0, _DiffuseMap); // Always source from uv0
    texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? v.uv0 : v.uv1), _DetailAlbedoMap);
    return texcoord;
}

half DetailMask(float2 uv)
{
    return tex2D (_DetailMask, uv).a;
}

half3 Albedo(float4 texcoords)
{
    half3 albedo = _Diffuse.rgb * tex2D (_DiffuseMap, texcoords.xy).rgb;
#if _DETAIL
    #if (SHADER_TARGET < 30)
        // SM20: instruction count limitation
        // SM20: no detail mask
        half mask = 1;
    #else
        half mask = DetailMask(texcoords.xy);
    #endif
    half3 detailAlbedo = tex2D (_DetailAlbedoMap, texcoords.zw).rgb;
    #if _DETAIL_MULX2
        albedo *= LerpWhiteTo (detailAlbedo * unity_DiffuseSpaceDouble.rgb, mask);
    #elif _DETAIL_MUL
        albedo *= LerpWhiteTo (detailAlbedo, mask);
    #elif _DETAIL_ADD
        albedo += detailAlbedo * mask;
    #elif _DETAIL_LERP
        albedo = lerp (albedo, detailAlbedo, mask);
    #endif
#endif
    return albedo;
}

half Alpha(float2 uv)
{
#if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
    return _Diffuse.a;
#else

#ifdef _ALPHAMAP
    return tex2D(_AlphaMap, uv).r * _Alpha;
#else
    return tex2D(_DiffuseMap, uv).a * _Diffuse.a;
#endif

#endif
}

half Occlusion(float2 uv)
{
#if (SHADER_TARGET < 30)
    // SM20: instruction count limitation
    // SM20: simpler occlusion
    return tex2D(_OcclusionMap, uv).g;
#else
    half occ = tex2D(_OcclusionMap, uv).g;
    return LerpOneTo (occ, _OcclusionStrength);
#endif
}

half4 SpecularGloss(float2 uv)
{
    half4 sg;
//#ifdef _SPECGLOSSMAP
#ifdef _SPECULARCOLORMAP
#if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
        sg.rgb = tex2D(_SpecularColorMap, uv).rgb;
//added
        sg.rgb *= _SpecularColor.rgb;
        sg.a = tex2D(_DiffuseMap, uv).a;
    #else
        sg = tex2D(_SpecularColorMap, uv);
        //added
        sg *= 0.5f * _SpecularColor;
#endif
//    sg.a *= _GlossMapScale;
    sg.a *= 1.0f - _Roughness;
#else
//    sg.rgb = _SpecColor.rgb;
    sg.rgb = _SpecularColor.rgb;
#ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
//        sg.a = tex2D(_DiffuseMap, uv).a * _GlossMapScale;
        sg.a = tex2D(_DiffuseMap, uv).a * _Roughness;
#else
//        sg.a = _Glossiness;
        sg.a = 1.0f - _Roughness;
#endif
#endif
    return sg;
}

half2 MetallicGloss(float2 uv)
{
    half2 mg;

//#ifdef _METALLICGLOSSMAP
#ifdef _METALLICMAP
#ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        mg.r = tex2D(_MetallicMap, uv).r;
        mg.g = tex2D(_DiffuseMap, uv).a;
    #else
        mg = tex2D(_MetallicMap, uv).ra;
        // added
        mg.r *= _Metallic;
    #endif
//    mg.g *= _GlossMapScale;
    mg.g *= 1.0f - _Roughness;
#else
    mg.r = _Metallic;
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
//        mg.g = tex2D(_DiffuseMap, uv).a * _GlossMapScale;
        mg.g = tex2D(_DiffuseMap, uv).a * _Roughness;
#else
//        mg.g = _Glossiness;
    mg.g = 1.0f - _Roughness;
    #endif
#endif
    return mg;
}

half2 MetallicRough(float2 uv)
{
    half2 mg;
//#ifdef _METALLICGLOSSMAP
#ifdef _METALLICMAP
    mg.r = tex2D(_MetallicMap, uv).r;
    // added
    mg.r *= _Metallic;
#else
    mg.r = _Metallic;
#endif

//#ifdef _SPECGLOSSMAP
#ifdef _SPECULARCOLORMAP
    mg.g = 1.0f - tex2D(_SpecularColorMap, uv).r;
    //added
    mg.g *= _SpecularColor.r;
#else
//    mg.g = 1.0f - _Glossiness;
    mg.g = 1.0f - _Roughness;
#endif
    return mg;
}

half3 Emission(float2 uv)
{
#ifndef _EMISSION
    return 0;
#else
    return tex2D(_EmissionMap, uv).rgb * _Emission.rgb;
#endif
}

#ifdef _NORMALMAP
half3 NormalInTangentSpace(float4 texcoords)
{
    half3 normalTangent = UnpackScaleNormal(tex2D (_NormalMap, texcoords.xy), _Normal);

#if _DETAIL && defined(UNITY_ENABLE_DETAIL_NORMALMAP)
    half mask = DetailMask(texcoords.xy);
    half3 detailNormalTangent = UnpackScaleNormal(tex2D (_DetailNormalMap, texcoords.zw), _DetailNormalMapScale);
    #if _DETAIL_LERP
        normalTangent = lerp(
            normalTangent,
            detailNormalTangent,
            mask);
    #else
        normalTangent = lerp(
            normalTangent,
            BlendNormals(normalTangent, detailNormalTangent),
            mask);
    #endif
#endif

    return normalTangent;
}
#endif

float4 Parallax (float4 texcoords, half3 viewDir)
{
#if !defined(_PARALLAXMAP) || (SHADER_TARGET < 30)
    // Disable parallax on pre-SM3.0 shader target models
    return texcoords;
#else
    half h = tex2D (_HeightMap, texcoords.xy).g;
    float2 offset = ParallaxOffset1Step (h, _Height, viewDir);
    return float4(texcoords.xy + offset, texcoords.zw + offset);
#endif

}

#endif // UNITY_STANDARD_INPUT_INCLUDED
