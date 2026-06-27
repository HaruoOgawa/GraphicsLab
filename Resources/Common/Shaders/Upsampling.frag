#version 450

layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;

#ifdef USE_OPENGL
layout(binding = 0) uniform sampler2D texImage;
#else
layout(binding = 0) uniform texture2D texImage;
layout(binding = 1) uniform sampler texSampler;
#endif

layout(binding = 2) uniform FragUniformBuffer
{
	mat4 mPad0;
	mat4 mPad1;
	mat4 mPad2;
	mat4 mPad3;

	float filterRadius;
	float fPad0;
	float fPad1;
	float fPad2;
} frag_ubo;

layout(location = 0) out vec4 outColor;

vec3 GetTexColor(vec2 texcoord)
{
	vec4 col = vec4(0.0);

	#ifdef USE_OPENGL
	col.rgb = texture(texImage, texcoord).rgb;
	#else
	col.rgb = texture(sampler2D(texImage, texSampler), texcoord).rgb;
	#endif

	return col.rgb;
}

void main()
{
    float x = frag_ubo.filterRadius;
    float y = frag_ubo.filterRadius;

    vec3 a = GetTexColor(vec2(v2f_UV.x - x, v2f_UV.y + y)).rgb;
    vec3 b = GetTexColor(vec2(v2f_UV.x,     v2f_UV.y + y)).rgb;
    vec3 c = GetTexColor(vec2(v2f_UV.x + x, v2f_UV.y + y)).rgb;

    vec3 d = GetTexColor(vec2(v2f_UV.x - x, v2f_UV.y)).rgb;
    vec3 e = GetTexColor(vec2(v2f_UV.x,     v2f_UV.y)).rgb;
    vec3 f = GetTexColor(vec2(v2f_UV.x + x, v2f_UV.y)).rgb;

    vec3 g = GetTexColor(vec2(v2f_UV.x - x, v2f_UV.y - y)).rgb;
    vec3 h = GetTexColor(vec2(v2f_UV.x,     v2f_UV.y - y)).rgb;
    vec3 i = GetTexColor(vec2(v2f_UV.x + x, v2f_UV.y - y)).rgb;

    // 3x3 tent filter
	vec3 upsample = vec3(0.0);
    upsample = e*4.0;
    upsample += (b+d+f+h)*2.0;
    upsample += (a+c+g+i);
    upsample *= 1.0 / 16.0;

	outColor = vec4(upsample, 1.0);
}