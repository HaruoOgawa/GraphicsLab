#version 450

layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;

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

void main()
{
    vec3 col = l_ubo.color.rgb;
    float alpha = 1.0;
    
    outColor = vec4(col, alpha);
}