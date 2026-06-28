#version 450

layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;

const float KERNEL_RADIUS = 3;
  
layout(binding = 2) uniform FragUniformBuffer
{
	mat4 mPad0;
	mat4 mPad1;
	mat4 mPad2;
	mat4 mPad3;
} frag_ubo;

#ifdef USE_OPENGL
layout(binding = 3) uniform sampler2D newSSGITexture;
layout(binding = 5) uniform sampler2D temporalTexture;
#else
layout(binding = 3) uniform texture2D newSSGITexture;
layout(binding = 4) uniform sampler newSSGITextureSampler;
layout(binding = 5) uniform texture2D temporalTexture;
layout(binding = 6) uniform sampler temporalTextureSampler;
#endif

layout(location = 0) out vec4 outColor;

vec4 GetNewSSGI(vec2 uv)
{
	vec4 col = vec4(0.0);

	#ifdef USE_OPENGL
	col = texture(newSSGITexture, uv);
	#else
	col = texture(sampler2D(newSSGITexture, newSSGITextureSampler), uv);
	#endif

	return col;
}

vec4 GetTemporalTexture(vec2 uv)
{
	vec4 col = vec4(0.0);

	#ifdef USE_OPENGL
	col = texture(temporalTexture, uv);
	#else
	col = texture(sampler2D(temporalTexture, temporalTextureSampler), uv);
	#endif

	return col;
}

void main()
{
  vec4 newSSGI = GetNewSSGI(v2f_UV);
  vec4 ta = GetTemporalTexture(v2f_UV);

  vec3 col = mix(newSSGI.rgb, ta.rgb, 0.9);

  outColor = vec4(col, 1.0);
}