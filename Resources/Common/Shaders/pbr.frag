#version 450

layout(location = 0) in vec3 f_WorldNormal;
layout(location = 1) in vec2 f_Texcoord;
layout(location = 2) in vec4 f_WorldPos;
layout(location = 3) in vec3 f_WorldTangent;
layout(location = 4) in vec3 f_WorldBioTangent;
layout(location = 5) in vec4 f_LightSpacePos;

layout(location = 0) out vec4 outColor;

layout(binding = 0) uniform UniformBufferObject{
	mat4 model;
    mat4 view;
    mat4 proj;
	mat4 lightVMat;
	mat4 lightPMat;

	vec4 lightDir;
	vec4 lightColor;
	vec4 cameraPos;

	vec4 baseColorFactor;
	vec4 emissiveFactor;
	vec4 spatialCullPos;
	vec4 ambientColor;

    float time;
    float metallicFactor;
    float roughnessFactor;
    float normalMapScale;

	float occlusionStrength;
    float mipCount;
    float ShadowMapX;
    float ShadowMapY;

	float emissiveStrength;
	float fPad0;
    float fPad1;
    float fPad2;

    int   useBaseColorTexture;
    int   useMetallicRoughnessTexture;
    int   useEmissiveTexture;
    int   useNormalTexture;
    
    int   useOcclusionTexture;
    int   useCubeMap;
    int   useShadowMap;
    int   useIBL;

    int   useSkinMeshAnimation;
    int   useDirCubemap;
    int   pad1;
    int   pad2;
} ubo;

#ifdef USE_OPENGL
layout(binding = 2) uniform sampler2D baseColorTexture;
layout(binding = 4) uniform sampler2D metallicRoughnessTexture;
layout(binding = 6) uniform sampler2D emissiveTexture;
layout(binding = 8) uniform sampler2D normalTexture;
layout(binding = 10) uniform sampler2D occlusionTexture;
layout(binding = 12) uniform samplerCube cubemapTexture;
layout(binding = 14) uniform sampler2D shadowmapTexture;
layout(binding = 16) uniform sampler2D IBL_Diffuse_Texture;
layout(binding = 18) uniform sampler2D IBL_Specular_Texture;
layout(binding = 20) uniform sampler2D IBL_GGXLUT_Texture;
layout(binding = 22) uniform sampler2D cubeMap2DTexture;
#else
layout(binding = 2) uniform texture2D baseColorTexture;
layout(binding = 3) uniform sampler baseColorTextureSampler;

layout(binding = 4) uniform texture2D metallicRoughnessTexture;
layout(binding = 5) uniform sampler metallicRoughnessTextureSampler;

layout(binding = 6) uniform texture2D emissiveTexture;
layout(binding = 7) uniform sampler emissiveTextureSampler;

layout(binding = 8) uniform texture2D normalTexture;
layout(binding = 9) uniform sampler normalTextureSampler;

layout(binding = 10) uniform texture2D occlusionTexture;
layout(binding = 11) uniform sampler occlusionTextureSampler;

layout(binding = 12) uniform textureCube cubemapTexture;
layout(binding = 13) uniform sampler cubemapTextureSampler;

layout(binding = 14) uniform texture2D shadowmapTexture;
layout(binding = 15) uniform sampler shadowmapTextureSampler;

layout(binding = 16) uniform texture2D IBL_Diffuse_Texture;
layout(binding = 17) uniform sampler IBL_Diffuse_TextureSampler;

layout(binding = 18) uniform texture2D IBL_Specular_Texture;
layout(binding = 19) uniform sampler IBL_Specular_TextureSampler;

layout(binding = 20) uniform texture2D IBL_GGXLUT_Texture;
layout(binding = 21) uniform sampler IBL_GGXLUT_TextureSampler;

layout(binding = 22) uniform texture2D cubeMap2DTexture;
layout(binding = 23) uniform sampler cubeMap2DTextureSampler;
#endif

// 最低反射率
// 非金属でも0.04%は鏡面反射する
#define MIN_REFLECTIVITY 0.04
#define PI 3.14159265

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

struct LightData
{
    vec3 dir;
    vec3 color;
    float attenuation;
};

struct PBRParam
{
    vec3 Albedo;
    float Metallic;
    float Roughness;
    float NdH;
    float LdH;
    float NdL;
    float NdV;
    float VdH;
};

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

PBRParam CreatePBRParam(PBRData pbr, LightData light)
{
    // PBRParamを構築
    PBRParam param;
    
    vec3 l = normalize(-light.dir);
    vec3 v = normalize(-pbr.ViewDir);
    vec3 n = normalize(pbr.WorldNormal);
    vec3 h = normalize(l + v); // ハーフベクトル : ライト方向と視線方向の中間ベクトル
    
    float NdH = clamp(dot(n, h), 0.0, 1.0);
    float LdH = clamp(dot(l, h), 0.0, 1.0);
    float NdL = clamp(dot(n, l), 0.0, 1.0);
    float NdV = clamp(dot(n, v), 0.0, 1.0);
    float VdH = clamp(dot(v, h), 0.0, 1.0);
    
    param.Albedo = pbr.Albedo;
    param.Metallic = pbr.Metallic;
    
    // Roughnessが0.0の時の鏡面反射が消えてしまうので最小値を最小反射率にする
    param.Roughness = max(MIN_REFLECTIVITY, pbr.Roughness);
    
    param.NdH = NdH;
    param.LdH = LdH;
    param.NdL = NdL;
    param.NdV = NdV;
    param.VdH = VdH;
    
    return param;
}

// マイクロファセット(微小面法線分布関数)(Microfacet Distribution). Distributionは分布に意味
// 分布関数なので統計学的に求められた数式
// マイクロファセット → 微小平面
// 特定のハーフベクトル方向を向いたマイクロファセットの面積密度を表す
// つまりその方向を向いてるマイクロファセットが表面上にどれぐらい存在するか
// https://learnopengl.com/PBR/Theory#:~:text=GGX%20for%20G.-,Normal%20distribution%20function,-The%20normal%20distribution
float CalcMicrofacet(PBRParam param)
{
    float r = param.Roughness;
    //float a = r * r;
    float a = r;
    float a2 = max(0.001, a * a);
    
    float f = pow(param.NdH, 2.0) * (a2 - 1.0) + 1.0;
    
    return a2 / (PI * f * f);
}

// 幾何減衰項(Geometric Occlusion)
// マイクロファセットの微小平面が光の経路を遮断することにより失われてしまう光の減衰量を計算する関数
// → マイクロファセットの自己遮断・相互遮断によって反射に寄与できるマイクロファセットの割合を減衰させる関数
float CalcGeometricOcculusion(PBRParam param)
{
    //float k = param.Roughness * param.Roughness;
    float k = param.Roughness;

    // 実際の数式を簡略した方を使う
    float attenuationL = param.NdV / (param.NdV * (1.0 - k) + k);
    float attenuationV = param.NdL / (param.NdL * (1.0 - k) + k);

    return attenuationL * attenuationV;
}

// フレネル項
// フレネル反射とはView方向に応じて反射率が変化する物理現象のことである 
// 平面を斜めらか見るほど、反射される光の割合が増加する
// https://marmoset.co/posts/basic-theory-of-physically-based-rendering/
// この画像がわかりやすい --> https://marmoset.co/wp-content/uploads/2016/11/pbr_theory_fresnel.png
// GGXのフレネル項の式は、よく光学の分野で見聞きするようなフレネルの式の近似式である(https://ja.wikipedia.org/wiki/%E3%83%95%E3%83%AC%E3%83%8D%E3%83%AB%E3%81%AE%E5%BC%8F)
// https://learnopengl.com/PBR/Theory#:~:text=return%20ggx1%20*%20ggx2%3B%0A%7D-,Fresnel%20equation,-The%20Fresnel%20equation
vec3 CalcFrenelReflection(vec3 Albedo, float Metallic, float NdV)
{
    // フレネル反射は視線ベクトルと法線の角度が大きいほど(斜めから見るほど)明るくなる現象
    vec3 F0 = mix(vec3(MIN_REFLECTIVITY, MIN_REFLECTIVITY, MIN_REFLECTIVITY), Albedo, Metallic);
    return F0 + (1.0 - F0) * pow(1.0 - NdV, 5.0);
}

// ディフューズBRDF(拡散反射)
vec3 CalcDiffuseBRDF(PBRData pbr)
{
    // どれだけ金属であるかを表すMetallic(0.0 ~ 1.0)の値を反転させたものを拡散反射色に乗算して金属であるほどこの色が乗らないようにする
    // 金属はほとんどが鏡面反射で拡散反射しなくなるのを表現する
    
    // 非金属の反射率は0.04(非金属でも0.04%は鏡面反射する)
    // これを考慮して拡散反射光が乗る割合の範囲を 0.0 ~ 0.96 にする
    // Metallicをひっくり返して金属であるほど拡散反射色が乗らないようにする
    float OneMinusReflectivity = (1.0 - MIN_REFLECTIVITY) - pbr.Metallic * (1.0 - MIN_REFLECTIVITY);
    
    // 最終結果
    // 最小値を0にしないと値がマイナスになって複数ライトを加算してもマイナスから復帰しなくて色がでなくなる
    vec3 col = pbr.Albedo * OneMinusReflectivity;
    col.r = max(0.0, col.r);
    col.g = max(0.0, col.g);
    col.b = max(0.0, col.b);
    
    return col;
}

// スペキュラーBRDF(鏡面反射)
vec3 CalcSpecularBRDF(PBRParam param)
{
    // クックトランスモデルによるスペキュラーGGX計算
    float  D = CalcMicrofacet(param); // 微小面法分布関数
    float  G = CalcGeometricOcculusion(param); // 幾何減衰項
    vec3 F = CalcFrenelReflection(param.Albedo, param.Metallic, param.NdV); // フレネル項
    
    // 最小値を0にしないと値がマイナスになって複数ライトを加算してもマイナスから復帰しなくて色がでなくなる
    vec3 spec = (D * G * F) / (4.0 * param.NdV * param.NdL);
    spec.r = max(0.0, spec.r);
    spec.g = max(0.0, spec.g);
    spec.b = max(0.0, spec.b);
    
    return spec;
}

// 直接光のPBR
vec3 ComputeDirectLight(PBRData pbr, LightData light)
{
    // PBRParamを構築
    PBRParam param = CreatePBRParam(pbr, light);
    
    // 拡散反射
    vec3 DiffuseCol = CalcDiffuseBRDF(pbr);
    
    // 鏡面反射
    vec3 SpecularCol = CalcSpecularBRDF(param);
    
    // 結果を組み合わせる
    vec3 ResultCol = param.NdL * (DiffuseCol + SpecularCol) * light.color * light.attenuation;
    
    return ResultCol;
}

vec2 CastDirToSt(vec3 Dir)
{
	float theta = acos(Dir.y);
	float phi = atan(Dir.z, Dir.x);

	vec2 st = vec2(phi / (2.0 * PI), theta / PI);

	return st;
}

vec3 CalcReflectionProbe(PBRData pbr)
{
    vec3 v = normalize(pbr.ViewDir);
    vec3 reflectV = reflect(v, pbr.WorldNormal);
    
    vec3 reflectColor = vec3(0.0);
    if(ubo.useCubeMap != 0)
	{
		float mipCount = ubo.mipCount;
		float lod = mipCount * pbr.Roughness;
		#ifdef USE_OPENGL
		reflectColor = SRGBtoLINEAR(textureLod(cubemapTexture, reflectV, lod).rgb);
		#else
		reflectColor = SRGBtoLINEAR(textureLod(samplerCube(cubemapTexture, cubemapTextureSampler), reflectV, lod).rgb);
		#endif
	}
	else if(ubo.useDirCubemap != 0)
	{
		vec2 st = CastDirToSt(reflectV);
		
		float mipCount = ubo.mipCount;
		float lod = mipCount * pbr.Roughness;
		#ifdef USE_OPENGL
		reflectColor = SRGBtoLINEAR(textureLod(cubeMap2DTexture, st, lod).rgb);
		#else
		reflectColor = SRGBtoLINEAR(textureLod(sampler2D(cubeMap2DTexture, cubeMap2DTextureSampler), st, lod).rgb);
		#endif
	}

	return reflectColor;
}

// 間接光のPBR
vec3 ComputeIndirectLight(PBRData pbr)
{
    vec3 ResultCol = vec3(0.0, 0.0, 0.0);
    
    // リフレクションプローブによる間接照明
    ResultCol += CalcReflectionProbe(pbr);
    
    // フレネル反射
    vec3 v = normalize(-pbr.ViewDir);
    vec3 n = normalize(pbr.WorldNormal);
    
    float NdV = clamp(dot(n, v), 0.0, 1.0);
    
    ResultCol *= CalcFrenelReflection(pbr.Albedo, pbr.Metallic, NdV);
    
    return ResultCol;
}

vec4 CalcBaseColor()
{
	// ベースカラーの取得. ベースカラーは単純な表面色
	vec4 baseColor;
	if(ubo.useBaseColorTexture != 0)
	{
		#ifdef USE_OPENGL
		baseColor = texture(baseColorTexture, f_Texcoord);
		#else
		baseColor = texture(sampler2D(baseColorTexture, baseColorTextureSampler), f_Texcoord);
		#endif

		// PBR計算に使うのでリニア空間にする
        baseColor.rgb = SRGBtoLINEAR(baseColor.rgb);
	}
	else
	{
		baseColor = ubo.baseColorFactor;
	}

	return baseColor;
}

vec3 CalcEmissive()
{
    vec3 emissive = ubo.emissiveFactor.rgb * ubo.emissiveStrength;
	if(ubo.useEmissiveTexture != 0)
	{
		#ifdef USE_OPENGL
		emissive *= SRGBtoLINEAR(texture(emissiveTexture, f_Texcoord).rgb);
		#else
		emissive *= SRGBtoLINEAR(texture(sampler2D(emissiveTexture, emissiveTextureSampler), f_Texcoord).rgb);
		#endif
	}

    return emissive;
}

void main()
{
    vec4 col = vec4(0.0, 0.0, 0.0, 1.0);

    //
	vec4 baseColor = CalcBaseColor();

    // PBRData準備
	PBRData pbr;
	pbr.Albedo = baseColor.rgb;
	pbr.Metallic = ubo.metallicFactor;
	pbr.Roughness = ubo.roughnessFactor;
	pbr.WorldNormal = f_WorldNormal;
	pbr.ViewDir = normalize(f_WorldPos.xyz - ubo.cameraPos.xyz);

    // LightData準備
	LightData light;
	light.dir = ubo.lightDir.xyz;
	light.color = ubo.lightColor.rgb;
	light.attenuation = 1.0;

    // Direct Light
    col.rgb += ComputeDirectLight(pbr, light);

    // Indirect Light
    col.rgb += ComputeIndirectLight(pbr);

    // Emissive(自己発光)
	col.rgb += CalcEmissive();

    // ガンマ補正(リニア空間からガンマ空間に戻す)
    col.rgb = LINEARtoSRGB(col.rgb);

	outColor = col;
}