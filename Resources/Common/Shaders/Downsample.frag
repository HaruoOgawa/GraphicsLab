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

vec2 GetTextureSize()
{
  #ifdef USE_OPENGL
  vec2 texSize = textureSize(texImage, 0);
  #else
  vec2 texSize = textureSize(sampler2D(texImage, texSampler), 0);
  #endif

  return texSize;
}

void main()
{
    // 13タップの重み付きダウンサンプルフィルタ
    // CoD Advanced Warfareに使われた手法
    // SIGGRAPH 2014で発表された
    // サンプラーにバイリニアフィルタを設定しておく必要がある
    // (texture関数でサンプリングするときにフィルター処理が実行されるはず？)
    // この手法は13回バイリニアフィルタを実行するので、実質36テクセル分の平均化されたカラーを取得することができる
    // 重みをつけて影響度を変化させる
    // // 安いコストで低解像度にきっちり落とし込むことができるのでこれを使う
    // https://www.iryoku.com/next-generation-post-processing-in-call-of-duty-advanced-warfare/
    // https://github.com/bkaradzic/bgfx/blob/master/examples/38-bloom/fs_downsample.sc
    // https://learnopengl.com/Guest-Articles/2022/Phys.-Based-Bloom

	vec2 texSize = GetTextureSize();

    float x = 1.0 / texSize.x;
    float y = 1.0 / texSize.y;

    vec3 a = GetTexColor(vec2(v2f_UV.x - 2*x, v2f_UV.y + 2*y)).rgb;
    vec3 b = GetTexColor(vec2(v2f_UV.x,       v2f_UV.y + 2*y)).rgb;
    vec3 c = GetTexColor(vec2(v2f_UV.x + 2*x, v2f_UV.y + 2*y)).rgb;

    vec3 d = GetTexColor(vec2(v2f_UV.x - 2*x, v2f_UV.y)).rgb;
    vec3 e = GetTexColor(vec2(v2f_UV.x,       v2f_UV.y)).rgb;
    vec3 f = GetTexColor(vec2(v2f_UV.x + 2*x, v2f_UV.y)).rgb;

    vec3 g = GetTexColor(vec2(v2f_UV.x - 2*x, v2f_UV.y - 2*y)).rgb;
    vec3 h = GetTexColor(vec2(v2f_UV.x,       v2f_UV.y - 2*y)).rgb;
    vec3 i = GetTexColor(vec2(v2f_UV.x + 2*x, v2f_UV.y - 2*y)).rgb;

    vec3 j = GetTexColor(vec2(v2f_UV.x - x, v2f_UV.y + y)).rgb;
    vec3 k = GetTexColor(vec2(v2f_UV.x + x, v2f_UV.y + y)).rgb;
    vec3 l = GetTexColor(vec2(v2f_UV.x - x, v2f_UV.y - y)).rgb;
    vec3 m = GetTexColor(vec2(v2f_UV.x + x, v2f_UV.y - y)).rgb;

	vec3 downsample = vec3(0.0);
    
    // 重みは合計で１になるように
    downsample = e*0.125;             // 0.125       中心
    downsample += (j+k+l+m)*0.125;    // 0.5   / 4   四隅
    downsample += (b+d+f+h)*0.0625;   // 0.25  / 4   1つ外の上下左右
    downsample += (a+c+g+i)*0.03125;  // 0.125 / 4   1つ外の四隅

	outColor = vec4(downsample, 1.0);
}