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
} l_ubo;

#ifdef USE_OPENGL
layout(binding = 2) uniform sampler2D gPositionTexture;
layout(binding = 4) uniform sampler2D gNormalTexture;
layout(binding = 6) uniform sampler2D gAlbedoTexture;
layout(binding = 8) uniform sampler2D gDepthTexture;
layout(binding = 10) uniform sampler2D gCustomParam0Texture;
layout(binding = 12) uniform sampler2D gEmissionTexture;
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

mat3 calcTBNMatrix(vec3 normal)
{
    vec3 T, B;
    vec3 N = normalize(normal);

    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 side = vec3(1.0, 0.0, 0.0);

    vec3 dir = (abs(dot(N, up)) < 0.9)? up : side;

    vec3 tmpT = normalize(cross(dir, N));
    B = normalize(cross(N, tmpT));

    T = normalize(cross(B, N));

    mat3 TBM = mat3(T, B, N);

    return TBM;
}

vec3 GetRandomSemiSpherePos(float radius, float i)
{
    float theta = rand(vec2(i, 129.645)) * (PI * 0.5); // 0 ~ PI/2
    float phi = rand(vec2(85.222, i)) * (2.0 * PI); // 0 ~ 2PI

    float x = radius * sin(theta) * cos(phi);
    float y = radius * sin(theta) * sin(phi);
    float z = radius * cos(theta);

    return vec3(x, y, z);
}

float ComputeSSAO(GBufferResult gResult)
{
    vec3 worldPos = gResult.worldPos;
    vec3 worldNormal = gResult.worldNormal;

    mat3 TBM = calcTBNMatrix(worldNormal);
    mat4 VPMat = l_ubo.proj * l_ubo.view;

    float resultAO = 0.0;
    float loop = 32.0;
    float numOf = 0.0;

    float aoRadius = 0.1;

    // SSAOのサンプリング
    for(float i = 0.0; i < loop; i++)
    {
        // Z軸正方向を向いた半球内のランダムオフセットを取得
        vec3 ssphPos = GetRandomSemiSpherePos(aoRadius, i);

        // TBN座標系に変換
        vec3 tbn_ssphPos = TBM * ssphPos;

        // 空間内のランダムな位置を算出
        vec3 worldSSPhPos = worldPos + tbn_ssphPos;

        // プロジェクション座標系にして理想的な深度を計算
        vec4 projSSPhPos = VPMat * vec4(worldSSPhPos, 1.0);
        float idealDepth = projSSPhPos.z / projSSPhPos.w;
        idealDepth = idealDepth * 0.5 + 0.5;

        // そのピクセルにおける実際の深度を取得
        vec2 projUV = projSSPhPos.xy / projSSPhPos.w;
        projUV = projUV * 0.5 + 0.5;

        // UVの範囲外はスキップする
        if(projUV.x < 0.0 || projUV.x > 1.0 || projUV.y < 0.0 || projUV.y > 1.0) continue;

        float actualDepth = GetDepth(projUV);

        // 実際の深度が理想的な深度よりも小さければ遮蔽されていると判断して暗い色を加算する
        resultAO += (actualDepth < idealDepth) ? 0.0 : 1.0;

        numOf++;
    }

    resultAO /= numOf;

    resultAO = pow(resultAO, 2.0);    

    return resultAO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main()
{
    vec2 ScreenUV = v2f_ProjPos.xy / v2f_ProjPos.w;
    ScreenUV = ScreenUV * 0.5 + 0.5;

    // Get Param
    GBufferResult gResult = GetGBuffer(ScreenUV);
	
    vec3 col = vec3(1.0);

    if(gResult.materialType == 1.0)
    {
        // SSAO
        col.rgb = vec3(ComputeSSAO(gResult));
    }
    
    outColor = vec4(col, 1.0);
}