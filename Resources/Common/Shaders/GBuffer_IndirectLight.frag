#version 450

layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;

layout(location = 0) out vec4 outColor;

layout(binding = 1) uniform LightUniformBuffer{
	mat4 mPad0;
	mat4 mPad1;
	mat4 mPad2;
	mat4 mPad3;

	int useIBL;
	int useCubeMap;
	int useDirCubemap;
	int iPad2;

    float mipCount;
    float fPad0;
    float fPad1;
    float fPad2;

    vec4 ambientColor;
    vec4 cameraPos;
} l_ubo;

#ifdef USE_OPENGL
layout(binding = 2) uniform sampler2D gPositionTexture;
layout(binding = 4) uniform sampler2D gNormalTexture;
layout(binding = 6) uniform sampler2D gAlbedoTexture;
layout(binding = 8) uniform sampler2D gDepthTexture;
layout(binding = 10) uniform sampler2D gCustomParam0Texture;
layout(binding = 12) uniform sampler2D gEmissionTexture;
layout(binding = 14) uniform sampler2D gVelocityTexture;
layout(binding = 16) uniform sampler2D IBL_Diffuse_Texture;
layout(binding = 18) uniform sampler2D IBL_Specular_Texture;
layout(binding = 20) uniform sampler2D IBL_GGXLUT_Texture;
layout(binding = 22) uniform sampler2D gDirectLightTexture;
layout(binding = 24) uniform sampler2D gSSAOBlurTexture;
#else
layout(binding = 2) uniform texture2D gPositionTexture;
layout(binding = 3) uniform sampler gPositionTextureSampler;
layout(binding = 4) uniform texture2D gNormalTexture;
layout(binding = 5) uniform sampler gNormalTextureSampler;
layout(binding = 6) uniform texture2D gAlbedoTexture;
layout(binding = 7) uniform sampler gAlbedoTextureSampler;
layout(binding = 8) uniform texture2D gDepthTexture;
layout(binding = 9) uniform sampler gDepthTextureSampler;
layout(binding = 10) uniform texture2D gCustomParam0Texture;
layout(binding = 11) uniform sampler gCustomParam0TextureSampler;
layout(binding = 12) uniform texture2D gEmissionTexture;
layout(binding = 13) uniform sampler gEmissionTextureSampler;
layout(binding = 14) uniform texture2D gVelocityTexture;
layout(binding = 15) uniform sampler gVelocityTextureSampler;
layout(binding = 16) uniform texture2D IBL_Diffuse_Texture;
layout(binding = 17) uniform sampler IBL_Diffuse_TextureSampler;
layout(binding = 18) uniform texture2D IBL_Specular_Texture;
layout(binding = 19) uniform sampler IBL_Specular_TextureSampler;
layout(binding = 20) uniform texture2D IBL_GGXLUT_Texture;
layout(binding = 21) uniform sampler IBL_GGXLUT_TextureSampler;
layout(binding = 22) uniform texture2D gDirectLightTexture;
layout(binding = 23) uniform sampler gDirectLightTextureSampler;
layout(binding = 24) uniform texture2D gSSAOBlurTexture;
layout(binding = 25) uniform sampler gSSAOBlurTextureSampler;
#endif

// 最低反射率
// 非金属でも0.04%は鏡面反射する
#define MIN_REFLECTIVITY 0.04
#define PI 3.14159265

struct GBufferResult
{
    vec3 worldPos;
    vec3 worldNormal;
    vec4 albedo;
    float depth;
    float materialType;
    vec2 metallicRoughness;
	vec3 emissive;
};

// PBR関連データ
struct PBRData
{
    vec3 Albedo;
    float Metallic;
    float Roughness;
    vec3 WorldNormal;
    vec3 WorldPos;
    vec3 ViewDir;
};

vec3 GetWorldPos(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec3 WorldPos = texture(gPositionTexture, ScreenUV).rgb;
#else
    vec3 WorldPos = texture(sampler2D(gPositionTexture, gPositionTextureSampler), ScreenUV).rgb;
#endif

    return WorldPos;
}

vec3 GetWorldNormal(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec3 WorldNormal = texture(gNormalTexture, ScreenUV).rgb;
#else
    vec3 WorldNormal = texture(sampler2D(gNormalTexture, gNormalTextureSampler), ScreenUV).rgb;
#endif

    return WorldNormal;
}

vec4 GetAlbedo(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec4 Albedo = texture(gAlbedoTexture, ScreenUV);
#else
    vec4 Albedo = texture(sampler2D(gAlbedoTexture, gAlbedoTextureSampler), ScreenUV);
#endif

    return Albedo;
}

float GetDepth(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    float Depth = texture(gDepthTexture, ScreenUV).r;
#else
    float Depth = texture(sampler2D(gDepthTexture, gDepthTextureSampler), ScreenUV).r;
#endif

    return Depth;
}

vec4 GetCustomParam0(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec4 CustomParam0 = texture(gCustomParam0Texture, ScreenUV);
#else
    vec4 CustomParam0 = texture(sampler2D(gCustomParam0Texture, gCustomParam0TextureSampler), ScreenUV);
#endif

    return CustomParam0;
}

vec4 GetEmission(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec4 Emission = texture(gEmissionTexture, ScreenUV);
#else
    vec4 Emission = texture(sampler2D(gEmissionTexture, gEmissionTextureSampler), ScreenUV);
#endif

    return Emission;
}

vec3 GetDirectLight(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec3 DirectLight = texture(gDirectLightTexture, ScreenUV).rgb;
#else
    vec3 DirectLight = texture(sampler2D(gDirectLightTexture, gDirectLightTextureSampler), ScreenUV).rgb;
#endif

    return DirectLight;
}

float GetSSAOBlur(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    float SSAOBlur = texture(gSSAOBlurTexture, ScreenUV).r;
#else
    float SSAOBlur = texture(sampler2D(gSSAOBlurTexture, gSSAOBlurTextureSampler), ScreenUV).r;
#endif

    return SSAOBlur;
}

GBufferResult GetGBuffer(vec2 ScreenUV)
{
    GBufferResult gResult;

    gResult.worldPos = GetWorldPos(ScreenUV);
    gResult.worldNormal = GetWorldNormal(ScreenUV);
    gResult.albedo = GetAlbedo(ScreenUV);
    gResult.depth = GetDepth(ScreenUV);

    vec4 CustomParam0 = GetCustomParam0(ScreenUV);
    gResult.materialType = CustomParam0.r;
    gResult.metallicRoughness = CustomParam0.gb;

	gResult.emissive = GetEmission(ScreenUV).rgb;

    return gResult;
}

// Linearは光学に則した色空間。PBRはリニア空間で計算する
// sRGB(ガンマ)はモニターに使われる色空間で人間の色の知覚に則している。最終的な色はガンマ空間に直す必要がある
// https://www.willgibbons.com/linear-workflow/#:~:text=sRGB%20is%20a%20non%2Dlinear,curve%20applied%20to%20the%20brightness.
// https://lettier.github.io/3d-game-shaders-for-beginners/gamma-correction.html
vec3 SRGBtoLINEAR(vec3 srgbIn)
{
	return pow(srgbIn.xyz, vec3(2.2));
}

vec3 LINEARtoSRGB(vec3 srgbIn)
{
	return pow(srgbIn.xyz, vec3(1.0 / 2.2));
}

vec2 CastDirToSt(vec3 Dir)
{
	float theta = acos(Dir.y);
	float phi = atan(Dir.z, Dir.x);

	vec2 st = vec2(phi / (2.0 * PI), theta / PI);

	return st;
}

vec2 GetSphericalTexcoord(vec3 Dir)
{
	float theta = acos(Dir.y);
	float phi = atan(Dir.z, Dir.x);

	vec2 st = vec2(phi / (2.0 * PI), theta / PI);

	return st;
}

vec3 GetIndirectDiffuse(vec3 n)
{
    #ifdef USE_OPENGL
    vec3 diffuseLight = (texture(IBL_Diffuse_Texture, GetSphericalTexcoord(n)).rgb);
    #else
    vec3 diffuseLight = (texture(sampler2D(IBL_Diffuse_Texture, IBL_Diffuse_TextureSampler), GetSphericalTexcoord(n)).rgb);
    #endif

    return diffuseLight;
}

vec3 GetGGXRadiance(vec3 n, vec3 v, float roughenss, float mipCount)
{
	float lod = mipCount * roughenss;

    #ifdef USE_OPENGL
    vec3 specularLight = (textureLod(IBL_Specular_Texture, GetSphericalTexcoord(reflect(v, n)), lod).rgb);
    #else
    vec3 specularLight = (textureLod(sampler2D(IBL_Specular_Texture, IBL_Specular_TextureSampler), GetSphericalTexcoord(reflect(v, n)), lod).rgb);
    #endif

    return specularLight;
}

vec3 GetSpecularBRDF(float NdV, float roughenss, vec3 F0)
{
    vec2 uv = vec2(NdV, roughenss);

    #ifdef USE_OPENGL
	vec3 brdf = (texture(IBL_GGXLUT_Texture, uv).rgb);
	#else
	vec3 brdf = (texture(sampler2D(IBL_GGXLUT_Texture, IBL_GGXLUT_TextureSampler), uv).rgb);
	#endif

    vec3 F = F0 + (1.0 - F0) * pow(1.0 - NdV, 5.0);

    return (F * brdf.x + brdf.y);
}

// IBL
vec3 ComputeIBL(PBRData pbr) 
{
    vec3 n = normalize(pbr.WorldNormal);
    vec3 v = normalize(-pbr.ViewDir);
    float NdV = clamp(dot(n, v), 0.0, 1.0);
    
    // 金属材質
    vec3 metal_fresnel = GetSpecularBRDF(NdV, pbr.Roughness, pbr.Albedo);
    vec3 metal_specularBRDF = GetGGXRadiance(n, v, pbr.Roughness, l_ubo.mipCount);
    vec3 metal_specular_color = metal_fresnel * metal_specularBRDF;
    // 金属材質では拡散反射分が不要.
    
    // 非金属
    vec3 dielectric_fresnel = GetSpecularBRDF(NdV, pbr.Roughness, vec3(MIN_REFLECTIVITY, MIN_REFLECTIVITY, MIN_REFLECTIVITY));
    vec3 dielectric_diffuse = GetIndirectDiffuse(n) * pbr.Albedo;
    vec3 dielectric_specularBRDF = GetGGXRadiance(n, v, pbr.Roughness, l_ubo.mipCount);

    // フレネルパラメータにより2つの成分を合成.
    vec3 dielectric_color = mix(dielectric_diffuse, dielectric_specularBRDF, dielectric_fresnel);

    // 求められた2つの結果をメタリックパラメータで合成する.
    vec3 finalColor = mix(dielectric_color, metal_specular_color, pbr.Metallic);
    
    // Bloomで爆発するのである程度で抑える
    finalColor = clamp(finalColor, vec3(0.0), vec3(3.0));

    return finalColor;
}

// 間接光のPBR
vec3 ComputeIndirectLight(GBufferResult gResult, vec2 ScreenUV)
{
    // PBRData準備
	PBRData pbr;
	pbr.Albedo = gResult.albedo.rgb;
	pbr.Metallic = gResult.metallicRoughness.r;
	pbr.Roughness = gResult.metallicRoughness.g;
	pbr.WorldNormal = gResult.worldNormal.xyz;
	pbr.ViewDir = normalize(gResult.worldPos.xyz - l_ubo.cameraPos.xyz);

    vec3 ResultCol = vec3(0.0, 0.0, 0.0);

    if(l_ubo.useIBL != 0)
	{
		// IBL
		ResultCol += ComputeIBL(pbr);
	}
	else if(l_ubo.useCubeMap != 0 || l_ubo.useDirCubemap != 0)
	{
		// リフレクションプローブによる間接照明
	}
	else
	{
		// IBLやリフレクションプローブが有効な時はそれらが間接光の役割を果たすが、そうでない時はAmbientLight(単純な色の加算)を使用する
		// https://cgworld.jp/terms/%E3%82%A2%E3%83%B3%E3%83%93%E3%82%A8%E3%83%B3%E3%83%88.html
		vec3 gi_diffuse = l_ubo.ambientColor.rgb;
		ResultCol += gi_diffuse;
	}
    
    // フレネル反射
    vec3 n = normalize(pbr.WorldNormal);
    vec3 v = normalize(-pbr.ViewDir);
    
    float NdV = clamp(dot(n, v), 0.0, 1.0);
    
    //ResultCol *= CalcFrenelReflection(pbr.Albedo, pbr.Metallic, NdV);

    // AO
    //float ao = GetSSAOBlur(ScreenUV);
    //ResultCol *= ao;
    
    return ResultCol;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main()
{
    vec2 ScreenUV = v2f_ProjPos.xy / v2f_ProjPos.w;
    ScreenUV = ScreenUV * 0.5 + 0.5;

    // Get Param
    GBufferResult gResult = GetGBuffer(ScreenUV);
	
    // Compute Color
    vec3 col = vec3(0.0);
    
    if(gResult.materialType == 1.0)
    {
        // Indirect Light
        col.rgb += ComputeIndirectLight(gResult, ScreenUV);

        // Direct Light
        col.rgb += GetDirectLight(ScreenUV);
    }
    else
    {
        // 何も描画しない
        // ライトは加算描画なので黒でいい
        col = vec3(0.0, 0.0, 0.0);
    }
    
    outColor = vec4(col, 1.0);
}