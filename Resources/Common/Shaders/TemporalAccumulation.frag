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
layout(binding = 3) uniform sampler2D newTexture;
layout(binding = 5) uniform sampler2D temporalTexture;
layout(binding = 7) uniform sampler2D velocityTexture;
#else
layout(binding = 3) uniform texture2D newTexture;
layout(binding = 4) uniform sampler newTextureSampler;
layout(binding = 5) uniform texture2D temporalTexture;
layout(binding = 6) uniform sampler temporalTextureSampler;
layout(binding = 7) uniform texture2D velocityTexture;
layout(binding = 8) uniform sampler velocityTextureSampler;
#endif

layout(location = 0) out vec4 outColor;

vec4 GetNewTexture(vec2 uv)
{
	vec4 col = vec4(0.0);

	#ifdef USE_OPENGL
	col = texture(newTexture, uv);
	#else
	col = texture(sampler2D(newTexture, newTextureSampler), uv);
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

vec2 GetVelocityTexture(vec2 uv)
{
	#ifdef USE_OPENGL
	vec2 velocity = texture(velocityTexture, uv).rg;
	#else
	vec2 velocity = texture(sampler2D(velocityTexture, velocityTextureSampler), uv).rg;
	#endif

	return velocity;
}

vec2 GetTextureSize()
{
  #ifdef USE_OPENGL
  vec2 texSize = textureSize(newTexture, 0);
  #else
  vec2 texSize = textureSize(sampler2D(newTexture, newTextureSampler), 0);
  #endif

  return texSize;
}


vec4 SampleHistory(vec2 st)
{
	vec2 velocity = GetVelocityTexture(st);
	vec2 prevUV = st - velocity;

	vec4 col = GetTemporalTexture(prevUV);

	// カラークランプ
	// 過去に蓄積されたピクセルカラーが現在のピクセルカラーよりも大きく乖離しすぎないように色のAABBを作ってクランプする
	// https://www.elopezr.com/temporal-aa-and-the-quest-for-the-holy-trail/
	vec3 minColor = vec3(9999.0);
	vec3 maxColor = vec3(-9999.0);
	vec2 texSize = GetTextureSize();

	// 3x3でサンプリングする
	for(int y = -1; y <= 1; y++)
	{
		for(int x = -1; x <= 1; x++)
		{
			vec3 current = GetNewTexture(st + vec2(float(x), float(y)) / texSize).rgb;
			minColor = min(minColor, current);
			maxColor = max(maxColor, current);
		}
	}

	vec3 result = clamp(col.rgb, minColor, maxColor);

	return vec4(result, 1.0);
}

void main()
{
	vec4 new = GetNewTexture(v2f_UV);
	vec4 old = SampleHistory(v2f_UV);

	outColor = mix(new, old, 0.9);
}