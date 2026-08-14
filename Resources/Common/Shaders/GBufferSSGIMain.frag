#version 450

layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;

layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outBackupMain;

layout(binding = 1) uniform LightUniformBuffer{
	mat4 model;
    mat4 view;
    mat4 proj;
	mat4 mPad3;

    int frame;
    int iPad0;
    int iPad1;
    int iPad2;

    float maxDistance;
    float near;
    float far;
    float fPad2;
} l_ubo;

#ifdef USE_OPENGL
layout(binding = 2) uniform sampler2D gPositionTexture;
layout(binding = 4) uniform sampler2D gNormalTexture;
layout(binding = 6) uniform sampler2D gAlbedoTexture;
layout(binding = 8) uniform sampler2D gDepthTexture;
layout(binding = 10) uniform sampler2D gCustomParam0Texture;
layout(binding = 12) uniform sampler2D gEmissionTexture;
layout(binding = 14) uniform sampler2D gIndirectLightTexture;
layout(binding = 16) uniform sampler2D historyTexture;

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
layout(binding = 16) uniform texture2D historyTexture;
layout(binding = 17) uniform sampler historyTextureSampler;
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

vec2 GetTextureSize()
{
    #ifdef USE_OPENGL
	vec2 texSize = textureSize(gPositionTexture, 0);
	#else
	vec2 texSize = textureSize(sampler2D(gPositionTexture, gPositionTextureSampler), 0);
	#endif

    return texSize;
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

float GetTexLinearDepth(vec2 uv)
{
	#ifdef USE_OPENGL
	float depth = texture(gDepthTexture, uv).r;
	#else
	float depth = texture(sampler2D(gDepthTexture, gDepthTextureSampler), uv).r;
	#endif

  // NDCのデプスだと差が小さすぎるのでカメラからの実際の距離に戻す
  float z = depth * 2.0 - 1.0;
  return (2.0 * l_ubo.near * l_ubo.far) / (l_ubo.far + l_ubo.near - z * (l_ubo.far - l_ubo.near));
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

vec3 GetHistory(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec3 History = texture(historyTexture, ScreenUV).rgb;
#else
    vec3 History = texture(sampler2D(historyTexture, historyTextureSampler), ScreenUV).rgb;
#endif

    return History;
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

// Interleaved Gradient Noise
// https://blog.demofox.org/2022/01/01/interleaved-gradient-noise-a-different-kind-of-low-discrepancy-sequence/
// ピクセル座標を受け取る前提。0 ~ 1のUV座標ではなく0 ~ 1920のようなピクセル座標
float IGN(vec2 pixel, int frame)
{
    int newFrame = frame % 64;

    float x = pixel.x + 5.588238 * float(newFrame);
    float y = pixel.y + 5.588238 * float(newFrame);

    return mod(52.9829189 * mod(0.06711056 * x + 0.00583715 * y, 1.0), 1.0);
}

/*
* ハッシュベースノイズ関数
* https://www.reedbeta.com/blog/quick-and-easy-gpu-random-numbers-in-d3d11/
* https://jcgt.org/published/0009/03/02/
* https://burtleburtle.net/bob/hash/doobs.html
*/
uint JenkinsHash(uint x)
{
    x += (x << 10u);
    x ^= (x >> 6u);
    x += (x << 3u);
    x ^= (x >> 11u);
    x += (x << 15u);
    return x;
}

uint JenkinsHash(uvec2 v) { return JenkinsHash(v.x ^ JenkinsHash(v.y)); }
uint JenkinsHash(uvec3 v) { return JenkinsHash(v.x ^ JenkinsHash(v.yz)); }

// ハッシュ済みのビット列から[0,1)のfloatを組み立てる
float ConstructFloat(uint m)
{
    const uint ieeeMantissa = 0x007FFFFFu; // 仮数部のビットマスク
    const uint ieeeOne      = 0x3F800000u; // float 1.0 のビットパターン
    m &= ieeeMantissa;                      // 仮数部だけ残す
    m |= ieeeOne;                           // 指数部を1.0の形に固定 → 値は[1,2)
    return uintBitsToFloat(m) - 1.0;        // [1,2) -> [0,1)
}

float GenerateHashedRandomFloat(uvec3 v)
{
    return ConstructFloat(JenkinsHash(v));
}

// 呼ぶたびに違う値を返すための簡易シード(グローバル変数、フラグメントごとに独立)
float g_HashSeed = 0.0;

float GenerateRandomValue(vec2 screenUV, vec2 texSize, int frame)
{
    g_HashSeed += 1.0;
    uvec3 seed = uvec3(uvec2(screenUV * texSize), uint(float(frame) + g_HashSeed));
    return GenerateHashedRandomFloat(seed);
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
           normal * sqrt(max(0.0, 1.0 - randVal.x));
}

vec3 GetRandomVector(vec2 ScreenUV, vec3 worldNormal, vec2 texSize, int index)
{
    float noise1 = GenerateRandomValue(ScreenUV, texSize, l_ubo.frame);
    float noise2 = GenerateRandomValue(ScreenUV, texSize, l_ubo.frame);

    vec3 randNormal = GetCosGemisphereSample(noise1, noise2, worldNormal);
    return normalize(randNormal);
}

vec3 Raymarch(vec2 ScreenUV, vec3 randVec, vec3 worldPos, vec2 texSize)
{
    mat4 VMat = l_ubo.view;
    mat4 PMat = l_ubo.proj;

    // 透視投影で歪むのでカメラ座標系で計算
    vec4 viewPos = VMat * vec4(worldPos, 1.0);
    vec4 viewDir = VMat * vec4(randVec, 0.0);

    vec3 ro = viewPos.xyz;
    vec3 rd = normalize(viewDir.xyz);
    
    float stepCount = 32.0;

    float stepSize = l_ubo.maxDistance * 1.0 / stepCount;
    float stepSum = 0.0;

    // ステップサイズをノイズでずらす
    // ステップサイズが一定だとカメラから遠い場所で縞模様が発生するのでその対策
    float jitter = GenerateRandomValue(ScreenUV, texSize, l_ubo.frame);

    // 初期位置を0 ~ 1ステップ分ずらす
    // 自己衝突対策
    stepSum = stepSize * jitter;

    vec2 resultUV = vec2(0.0);
    float collided = 0.0;

    float tickness = 0.1;

    for(float i = 0.0; i < stepCount; i++)
    {
        vec3 p = ro + rd * stepSum;

        vec4 projPos = PMat * vec4(p, 1.0);

        vec2 currentUV = (projPos.xy / projPos.w) * 0.5 + 0.5;
        // float currentDepth = (projPos.z / projPos.w) * 0.5 + 0.5;
        // プロジェクション座標系の深度だと、透視投影によりnearに近いほど値の幅が広く、farに近いほど値が圧縮されてしまう
        // それによってtickness=0.1をNDC座標で使い、カメラから少し離れた場所ではワールド座標換算で数mから数十mの厚みを許容してしまうことになる
        // その対策としてカメラ座標系におけるZの値を深度とする
        float currentDepth_View = -p.z; // View空間は-Z方向を向いている(OpenGL右手系なので)

        // float realDepth = GetDepth(currentUV);
        float realDepth_View = GetTexLinearDepth(currentUV);

        // ノイズ対策で範囲外なら抜ける
        if(currentUV.x < 0.0 || currentUV.x > 1.0 || currentUV.y < 0.0 || currentUV.y > 1.0)
        {
            break;
        }

        // 実際の深度の方が小さい場合は衝突したとして判定する
        // float diff = (currentDepth - realDepth); // 厚み判定. 突き抜けすぎを抑制
        float diff = (currentDepth_View - realDepth_View); // 厚み判定. 突き抜けすぎを抑制
        if(diff > 0.0 && diff < tickness)
        {
            vec3 hitWorldNormal = GetWorldNormal(currentUV);
            if(dot(rd, hitWorldNormal) < 0.0)
            {
                // レイ方向とヒット法線が逆方向の場合のみ衝突判定とする
                // そうでない場合は面の裏側からの衝突なのでループは終了するが色は乗せない
                resultUV = currentUV;
                collided = 1.0;
            }

            break;
        }

        stepSum += stepSize;
    }

    return vec3(resultUV, collided);
}

vec3 ComputeSSGI(GBufferResult gResult, vec2 ScreenUV)
{
    vec3 worldPos = gResult.worldPos;
    vec3 worldNormal = gResult.worldNormal;
    vec2 texSize = GetTextureSize();

    int RAY_COUNT = 4;
    float sampleWeight = 1.0 / float(RAY_COUNT);

    vec3 resultSSGI = vec3(0.0);

    for(int i = 0; i < RAY_COUNT; i++)
    {
        // コサイン加重ランダムベクトルの計算
        vec3 randVec = GetRandomVector(ScreenUV, worldNormal, texSize, i);

        // ランダムベクトルをもとにレイマーチ( vec3(ScreenUV, collided) )
        vec3 rayResult = Raymarch(ScreenUV, randVec, worldPos, texSize);

        // 衝突していればそのピクセルにおける光をDiffuseLightとして返す
        if(rayResult.z == 1.0)
        {
            resultSSGI += GetIndirectLight(rayResult.xy) * sampleWeight;
        }
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

    vec4 col = vec4(0.0, 0.0, 0.0, 1.0);

    if(gResult.materialType == 1.0)
    {
        // SSGI
        col.rgb = ComputeSSGI(gResult, ScreenUV);
    }

    // NaNガード
    if(isnan(col.r) || isnan(col.g) || isnan(col.b) || isnan(col.a))
    {
        col.rgb = vec3(0.0);
    }

    // そこまで重要な要素ではないが、デバッグウィンドウで適切な見た目で確認できるように明示的に透明度1で描画する
    // UI描画がアルファブレンドなので透明度0にすると背景色と混ざって適切に確認できなくなる
    outColor = vec4(col.rgb, 1.0);

    outBackupMain = vec4(GetIndirectLight(ScreenUV), 1.0);
}