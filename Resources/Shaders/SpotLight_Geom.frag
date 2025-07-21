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

    float type; // ライトのタイプ
    float radius; // ライトの有効範囲
    float intensity; // ライトの強さ
    float angle; // ライトの有効範囲

	float height; // ライトの有効範囲
	float fPad0;
	float fPad1;
	float fPad2;

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
#endif

float GetDepth(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    float Depth = texture(gDepthTexture, ScreenUV).r;
#else
    float Depth = texture(sampler2D(gDepthTexture, gDepthTextureSampler), ScreenUV).r;
#endif

    return Depth;
}

void main()
{
    // デファードレンダリングにおいて半透明オブジェクトをうまく取り扱うことはできないので諦めましょう
    // 半透明オブジェクトは深度をあまり気にしなくていいものを上から乗算する感じで使っていきます
    /*vec2 ScreenUV = v2f_ProjPos.xy / v2f_ProjPos.w;
    ScreenUV = ScreenUV * 0.5 + 0.5;

    float gDepth = GetDepth(ScreenUV);

    float lightDepth = v2f_ProjPos.z / v2f_ProjPos.w;
    lightDepth = lightDepth * 0.5 + 0.5;

    if(gDepth <= lightDepth)
    {
        discard;
    }
    else*/
    {
        vec3 col = l_ubo.color.rgb * l_ubo.intensity;
        float alpha = 1.0 * 0.75;

        // Spot Light
        vec3 baseDir = normalize(l_ubo.dir.xyz);
        vec3 l2g = v2f_WorldPos.xyz - l_ubo.pos.xyz;
        vec3 l2g_norm = normalize(l2g);

        // スポットライトの範囲内であれば描画可能
        // 角度チェック
        // これ、コーンのメッシュは外側にあるからl2g_angleは常に同じ値が返ってきている。Screen座標での見え方によって変える必要がある
        float coneAngle = radians(l_ubo.angle);
        float l2g_angle = acos(dot(baseDir, l2g_norm));

        alpha *= (clamp(l2g_angle, 0.0, coneAngle) / coneAngle);

        // 高さ(長さ)チェック
        // l2gをbaseDirに射影してその長さがHeight以下なら範囲内である
        float height = l_ubo.height;
        float len = length(l2g) * cos(l2g_angle);

        alpha *= (1.0 - clamp(len, 0.0, height) / height);

        outColor = vec4(col, alpha);
    }
}