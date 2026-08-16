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
layout(binding = 16) uniform sampler2D gSrcTexture;

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
layout(binding = 16) uniform texture2D gSrcTexture;
layout(binding = 17) uniform sampler gSrcTextureSampler;
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

vec3 GetSource(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec3 src = texture(gSrcTexture, ScreenUV).rgb;
#else
    vec3 src = texture(sampler2D(gSrcTexture, gSrcTextureSampler), ScreenUV).rgb;
#endif

    return src;
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

vec3 Raymarch(vec2 ScreenUV, vec3 refVec, vec3 worldPos, vec2 texSize)
{
    mat4 VMat = l_ubo.view;
    mat4 PMat = l_ubo.proj;

    // 透視投影で歪むのでカメラ座標系で計算
    vec4 viewPos = VMat * vec4(worldPos, 1.0);
    vec4 viewDir = VMat * vec4(refVec, 0.0);

    vec3 ro = viewPos.xyz;
    vec3 rd = normalize(viewDir.xyz);
    
    float stepCount = 32.0;

    float stepSize = l_ubo.maxDistance * 1.0 / stepCount;
    float stepSum = 0.0;

    // ステップサイズをノイズでずらす
    // ステップサイズが一定だとカメラから遠い場所で縞模様が発生するのでその対策
    float jitter = 0.01;

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

vec3 ComputeSSR(GBufferResult gResult, vec2 ScreenUV)
{
    vec3 worldPos = gResult.worldPos;
    vec3 worldNormal = gResult.worldNormal;
    vec2 texSize = GetTextureSize();

    vec3 resultSSR = vec3(0.0);

    // 反射ベクトル
    // GLSLのreflectは視線→入射点の方向でベクトルを渡す。いつものライティング計算みたいに反転させておく必要はない
    vec3 viewDir = normalize(worldPos - l_ubo.cameraPos.xyz);
    vec3 refVec = reflect(viewDir, worldNormal);

    // 反射ベクトルをもとにレイマーチ( vec3(ScreenUV, collided) )
    vec3 rayResult = Raymarch(ScreenUV, refVec, worldPos, texSize);

    // 衝突していればそのピクセルにおける光をDiffuseLightとして返す
    if(rayResult.z == 1.0)
    {
        resultSSR = GetSource(rayResult.xy);
    }

    return resultSSR;
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
        // SSR
        col.rgb = ComputeSSR(gResult, ScreenUV);
    }

    // NaNガード
    if(isnan(col.r) || isnan(col.g) || isnan(col.b) || isnan(col.a))
    {
        col.rgb = vec3(0.0);
    }

    // そこまで重要な要素ではないが、デバッグウィンドウで適切な見た目で確認できるように明示的に透明度1で描画する
    // UI描画がアルファブレンドなので透明度0にすると背景色と混ざって適切に確認できなくなる
    outColor = vec4(col.rgb, 1.0);

    outBackupMain = vec4(GetSource(ScreenUV), 1.0);
}