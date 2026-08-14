#version 450

layout(location = 0) in vec2 fUV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;

#ifdef USE_OPENGL
layout(binding = 0) uniform sampler2D texImage;
#else
layout(binding = 0) uniform texture2D texImage;
layout(binding = 1) uniform sampler texSampler;
#endif

layout(location = 0) out vec4 outColor;

vec4 GetTexCol(vec2 st)
{
    #ifdef USE_OPENGL
	vec4 col = texture(texImage, st);
	#else
	vec4 col = texture(sampler2D(texImage, texSampler), st);
	#endif

    return col;
}

// HDR Tone Mapping
// ACES近似式（Narkowicz氏による軽量版）
vec3 tonemapACES(vec3 color) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
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

void main()
{
	vec2 st = fUV;

	vec4 col = GetTexCol(st);

	// ガンマ補正
    col.rgb = LINEARtoSRGB(col.rgb);

	outColor = col;
}