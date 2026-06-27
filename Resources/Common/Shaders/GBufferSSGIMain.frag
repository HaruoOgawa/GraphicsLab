#version 450

layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;

layout(location = 0) out vec4 outColor;

layout(binding = 1) uniform LightUniformBuffer{
	mat4 model;
    mat4 view;
    mat4 proj;
	mat4 mPad3;

    int frame;
    int iPad0;
    int iPad1;
    int iPad2;
} l_ubo;

#ifdef USE_OPENGL
layout(binding = 2) uniform sampler2D gPositionTexture;
layout(binding = 4) uniform sampler2D gNormalTexture;
layout(binding = 6) uniform sampler2D gAlbedoTexture;
layout(binding = 8) uniform sampler2D gDepthTexture;
layout(binding = 10) uniform sampler2D gCustomParam0Texture;
layout(binding = 12) uniform sampler2D gEmissionTexture;
layout(binding = 14) uniform sampler2D gIndirectLightTexture;
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
layout(binding = 14) uniform texture2D gIndirectLightTexture;
layout(binding = 15) uniform sampler gIndirectLightTextureSampler;
#endif

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

float rand(vec2 st)
{
    return fract(sin(dot(st ,vec2(12.9898,78.233))) * 43758.5453);
}

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

vec3 GetIndirectLight(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec3 IndirectLight = texture(gIndirectLightTexture, ScreenUV).rgb;
#else
    vec3 IndirectLight = texture(sampler2D(gIndirectLightTexture, gIndirectLightTextureSampler), ScreenUV).rgb;
#endif

    return IndirectLight;
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

// IGN : https://blog.demofox.org/2022/01/01/interleaved-gradient-noise-a-different-kind-of-low-discrepancy-sequence/
float IGN(vec2 seed, float frame)
{
    frame = mod(frame, 64.0);
    float x = seed.x + 5.588238 * frame;
    float y = seed.y + 5.588238 * frame;

    return mod(52.9829189 * mod(0.06711056 * x + 0.00583715 * y, 1.0), 1.0);
}

// 半球上のコサイン加重ランダムベクトル(Cosine weighted randam normal)
// パストレやモンテカルロ法でも使う面の法線を基準にランダムな反射・屈折ベクトルを生成する手法
// これはMalley's Methodによる求め方
// https://gamehacker1999.github.io/posts/SSGI/
// https://cseweb.ucsd.edu/~tzli/cse272/wi2023/lectures/malley_method.pdf
// https://pema.dev/obsidian/math/light-transport/cosine-weighted-sampling.html
vec3 GetCosGemisphereSample(float rand1, float rand2, vec3 normal)
{
    // Tangent, BioTangentの計算
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 side = vec3(1.0, 0.0, 0.0);
    vec3 dir = (abs(dot(normal, up)) < 0.9)? up : side;

    vec3 tmpT = normalize(cross(dir, normal));
    vec3 bioTangent = normalize(cross(normal, tmpT));
    vec3 tangent = normalize(cross(bioTangent, normal));

    //
    vec2 randVal = vec2(rand1, rand2);

    float r = sqrt(randVal.x);
    float phi = 2.0 * PI * randVal.y;

    return tangent * (r * cos(phi)) +
           bioTangent * (r * sin(phi)) +
           normal * sqrt(max(0.0, 1.0 - r * r));
}

vec3 GetRandomVector(vec2 ScreenUV, vec3 worldNormal)
{
    vec2 st = ScreenUV;

    float noise = IGN(st, float(l_ubo.frame));

    vec3 randNormal = GetCosGemisphereSample(noise, noise, worldNormal);
    return normalize(randNormal);
}

vec3 Raymarch(vec2 ScreenUV, vec3 randVec, vec3 worldPos)
{
    mat4 VMat = l_ubo.view;
    mat4 PMat = l_ubo.proj;

    // 透視投影で歪むのでカメラ座標系で計算
    vec4 viewPos = VMat * vec4(worldPos, 1.0);
    vec4 viewDir = VMat * vec4(randVec, 0.0);

    vec3 ro = viewPos.xyz;
    vec3 rd = normalize(viewDir.xyz);
    
    float step = 0.1;
    float stepSum = 0.0;

    vec2 resultUV = vec2(0.0);
    float collided = 0.0;

    for(int i = 0; i < 32; i++)
    {
        vec3 p = ro + rd * stepSum;

        vec4 projPos = PMat * vec4(p, 1.0);

        vec2 currentUV = (projPos.xy / projPos.w) * 0.5 + 0.5;
        float currentDepth = (projPos.z / projPos.w) * 0.5 + 0.5;

        float realDepth = GetDepth(currentUV);    

        // 実際の深度の方が小さい場合は衝突したとして判定する
        if(realDepth < currentDepth)
        {
            resultUV = currentUV;
            collided = 1.0;
            break;
        }

        stepSum += step;
    }

    return vec3(resultUV, collided);
}

vec3 ComputeSSGI(GBufferResult gResult, vec2 ScreenUV)
{
    vec3 worldPos = gResult.worldPos;
    vec3 worldNormal = gResult.worldNormal;

    // コサイン加重ランダムベクトルの計算
    vec3 randVec = GetRandomVector(ScreenUV, worldNormal);

    // ランダムベクトルをもとにレイマーチ( vec3(ScreenUV, collided) )
    vec3 rayResult = Raymarch(ScreenUV, randVec, worldPos);

    // 衝突していればそのピクセルにおける光をDiffuseLightとして返す
    vec3 resultSSGI = vec3(0.0);

    if(rayResult.z == 1.0)
    {
        resultSSGI = GetIndirectLight(rayResult.xy);
    }

    return resultSSGI;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main()
{
    vec2 ScreenUV = v2f_ProjPos.xy / v2f_ProjPos.w;
    ScreenUV = ScreenUV * 0.5 + 0.5;

    // Get Param
    GBufferResult gResult = GetGBuffer(ScreenUV);
	
    vec3 col = vec3(0.0);

    if(gResult.materialType == 1.0)
    {
        // SSGI
        col.rgb = ComputeSSGI(gResult, ScreenUV);
    }
    
    outColor = vec4(col, 1.0);
}