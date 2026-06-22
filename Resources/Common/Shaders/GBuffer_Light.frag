#version 450

layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;

layout(location = 0) out vec4 outColor;

layout(binding = 1) uniform LightUniformBuffer{
	mat4 lightVPMat;
	mat4 mPad1;
	mat4 mPad2;
	mat4 mPad3;

    float type; // ライトのタイプ
    float radius; // ライトの有効範囲
    float intensity; // ライトの強さ
    float angle; // ライトの有効範囲

	float height; // ライトの有効範囲
	float mipCount;
	float ShadowMapX;
	float ShadowMapY;

	int useIBL;
	int useShadowMap;
	int ForceLighting;
	int iPad2;

    vec4 dir;
    vec4 pos;
    vec4 color;
    vec4 cameraPos;
} l_ubo;

#ifdef USE_OPENGL
layout(binding = 2) uniform sampler2D gPositionTexture;
layout(binding = 4) uniform sampler2D gNormalTexture;
layout(binding = 6) uniform sampler2D gAlbedoTexture;
layout(binding = 8) uniform sampler2D gDepthTexture;
layout(binding = 10) uniform sampler2D gCustomParam0Texture;
layout(binding = 12) uniform sampler2D gEmissionTexture;
layout(binding = 14) uniform sampler2D IBL_Diffuse_Texture;
layout(binding = 16) uniform sampler2D IBL_Specular_Texture;
layout(binding = 18) uniform sampler2D IBL_GGXLUT_Texture;
layout(binding = 20) uniform sampler2D shadowmapTexture;
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
layout(binding = 14) uniform texture2D IBL_Diffuse_Texture;
layout(binding = 15) uniform sampler IBL_Diffuse_TextureSampler;
layout(binding = 16) uniform texture2D IBL_Specular_Texture;
layout(binding = 17) uniform sampler IBL_Specular_TextureSampler;
layout(binding = 18) uniform texture2D IBL_GGXLUT_Texture;
layout(binding = 19) uniform sampler IBL_GGXLUT_TextureSampler;
layout(binding = 20) uniform texture2D shadowmapTexture;
layout(binding = 21) uniform sampler shadowmapTextureSampler;
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

struct LightParam
{
    vec3 dir;
    vec3 color;
    float attenuation; // 減衰(intensityやradiusを使った計算結果)
	bool enabled;
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

LightParam GetLightParam(GBufferResult gResult)
{
    LightParam light;

    if(l_ubo.type == 1.0)
    {
        // Directional Light
        light.dir = normalize(l_ubo.dir.xyz);
        light.color = l_ubo.color.rgb;
        light.attenuation = l_ubo.intensity;
		light.enabled = true;
    }
    else if(l_ubo.type == 2.0)
    {
        // Point Light
		vec3 l2v = gResult.worldPos.xyz - l_ubo.pos.xyz;
        light.dir = normalize(l2v);
        light.color = l_ubo.color.rgb;

		float len = length(l2v);

		// https://github.com/KhronosGroup/glTF/blob/main/extensions/2.0/Khronos/KHR_lights_punctual/README.md#range-property
        light.attenuation = l_ubo.intensity * max( min(1.0 - pow((len / l_ubo.radius), 4.0), 1.0), 0.0 ) / pow(len, 2.0);
        // light.attenuation = l_ubo.intensity * (1.0 - len / l_ubo.radius);

		// ライト球の範囲外なら描画しない
		light.enabled = (len <= l_ubo.radius); 
    }
	else if(l_ubo.type == 3.0)
	{
		// Spot Light
		vec3 baseDir = normalize(l_ubo.dir.xyz);
		vec3 l2g = gResult.worldPos.xyz - l_ubo.pos.xyz;
		vec3 l2g_norm = normalize(l2g);

		// スポットライトの範囲内であれば描画可能
		// 角度チェック
		float coneAngle = radians(l_ubo.angle);
		float l2g_angle = acos(dot(baseDir, l2g_norm));
		bool ValidAngle = (l2g_angle >= 0.0 && l2g_angle <= coneAngle);

		// 高さ(長さ)チェック
		// l2gをbaseDirに射影してその長さがHeight以下なら範囲内である
		float height = l_ubo.height;
		float prjlen = length(l2g) * cos(l2g_angle);
		bool ValidHeight = (prjlen >= 0 && prjlen < height);

		// 半径チェック
		// スポットライト底面の半径
		float sinFactor = sin(coneAngle) / sin(3.1415 * 0.5 - coneAngle);
		// float spotR = sinFactor * height;
		float spotR = sinFactor * prjlen;
		// l2gからその射影ベクトルに垂直なベクトルの長さ
		vec3 l2g_perp = l2g - (prjlen * baseDir);
		float l2gR = length(l2g_perp);
		// l2gRが半径内であれば描画(角度付きのコーンではなく、上端と下端を底面の半径にした円柱で描画判定)
		bool ValidRadius = (l2gR <= spotR);

		// 現在のl2g射影ベクトルの高さにおける半径
		// float cH_spotR = sinFactor * prjlen;

		// 減衰
		// float attenuation = max( min(1.0 - pow((l2gR / spotR), 4.0), 1.0), 0.0 ) / pow(l2gR, 2.0);
		// attenuation = clamp(attenuation, 0.0, 1.0);
		// float attenuation = smoothstep(1.0, 0.5, l2gR / spotR);
		// float attenuation = smoothstep(1.0, 0.0, l2gR / spotR);
		float attenuation = 1.0;

		//
		light.dir = l2g_norm;
        light.color = l_ubo.color.rgb;
        light.attenuation = l_ubo.intensity * attenuation * l_ubo.color.a;
		// light.enabled = (ValidAngle && ValidRadius && ValidHeight);
		light.enabled = (ValidAngle && ValidRadius);
	}

    return light;
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

PBRParam CreatePBRParam(PBRData pbr, LightParam light)
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
vec3 ComputeDirectLight(GBufferResult gResult, LightParam light)
{
	// PBRData準備
	PBRData pbr;
	pbr.Albedo = gResult.albedo.rgb;
	pbr.Metallic = gResult.metallicRoughness.r;
	pbr.Roughness = gResult.metallicRoughness.g;
	pbr.WorldNormal = gResult.worldNormal.xyz;
	pbr.ViewDir = normalize(gResult.worldPos.xyz - l_ubo.cameraPos.xyz);

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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main()
{
    vec2 ScreenUV = v2f_ProjPos.xy / v2f_ProjPos.w;
    ScreenUV = ScreenUV * 0.5 + 0.5;

    // Get Param
    GBufferResult gResult = GetGBuffer(ScreenUV);
    LightParam light = GetLightParam(gResult);
	
	// スポットライトでかつForceLightingがtrueならベースカラーを白にする
	// これが黒になっているといくらライティングしても黒のままなのでライトの影響を受けない
	if(l_ubo.ForceLighting == 1 && l_ubo.type == 3.0)
	{
		gResult.albedo = vec4(1.0);
	}

    // Compute Color
    vec3 col = vec3(0.0);
    if(gResult.materialType == 1.0 && light.enabled)
    {
        // PBR
        col = ComputeDirectLight(gResult, light);
    }
    else
    {
        // 何も描画しない
        // ライトは加算描画なので黒でいい
        col = vec3(0.0, 0.0, 0.0);
    }

    outColor = vec4(col, 1.0);
}