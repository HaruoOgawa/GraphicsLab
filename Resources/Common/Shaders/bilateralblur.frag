#version 450

/*
 * Copyright (c) 2014-2021, NVIDIA CORPORATION.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-FileCopyrightText: Copyright (c) 2014-2021 NVIDIA CORPORATION
 * SPDX-License-Identifier: Apache-2.0
 */


layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;
  
layout(binding = 2) uniform FragUniformBuffer
{
	mat4 mPad0;
	mat4 mPad1;
	mat4 mPad2;
	mat4 mPad3;

  vec2  g_InvResolutionDirection; // either set x to 1/width or y to 1/height
  vec2 v2Pad;

  float g_Sharpness;
  float near;
  float far;
  float nExponent;

  int kernelRadius;
  int iPad0;
  int iPad1;
  int iPad2;
} frag_ubo;

#ifdef USE_OPENGL
layout(binding = 3) uniform sampler2D texSource;
layout(binding = 5) uniform sampler2D texDepth;
layout(binding = 7) uniform sampler2D texNormal;
#else
layout(binding = 3) uniform texture2D texSource;
layout(binding = 4) uniform sampler texSourceSampler;
layout(binding = 5) uniform texture2D texDepth;
layout(binding = 6) uniform sampler texDepthSampler;
layout(binding = 7) uniform texture2D texNormal;
layout(binding = 8) uniform sampler texNormalSampler;
#endif

layout(location = 0) out vec4 outColor;

vec4 GetTexSource(vec2 uv)
{
	vec4 col = vec4(0.0);

	#ifdef USE_OPENGL
	col = texture(texSource, uv);
	#else
	col = texture(sampler2D(texSource, texSourceSampler), uv);
	#endif

	return col;
}

float GetTexLinearDepth(vec2 uv)
{
	#ifdef USE_OPENGL
	float depth = texture(texDepth, uv).r;
	#else
	float depth = texture(sampler2D(texDepth, texDepthSampler), uv).r;
	#endif

  // NDCのデプスだと差が小さすぎるのでカメラからの実際の距離に戻す
  float z = depth * 2.0 - 1.0;
  return (2.0 * frag_ubo.near * frag_ubo.far) / (frag_ubo.far + frag_ubo.near - z * (frag_ubo.far - frag_ubo.near));
}

vec3 GetWorldNormal(vec2 uv)
{
	#ifdef USE_OPENGL
	vec3 worldNormal = normalize(texture(texNormal, uv).rgb);
	#else
	vec3 worldNormal = normalize(texture(sampler2D(texNormal, texNormalSampler), uv).rgb);
	#endif

	return worldNormal;
}

vec2 GetTextureSize()
{
  #ifdef USE_OPENGL
  vec2 texSize = textureSize(texSource, 0);
  #else
  vec2 texSize = textureSize(sampler2D(texSource, texSourceSampler), 0);
  #endif

  return texSize;
}

//-------------------------------------------------------------------------

vec4 BlurFunction(vec2 uv, float r, vec4 center_c, float center_d, vec3 center_n, inout float w_total)
{
  vec4  c = GetTexSource(uv);
  float d = GetTexLinearDepth(uv);
  vec3  n = GetWorldNormal(uv);
  
  const float BlurSigma = float(frag_ubo.kernelRadius) * 0.5;
  const float BlurFalloff = 1.0 / (2.0*BlurSigma*BlurSigma);
  
  // 深度が離れているほど重みを減らす
  // グラフツールで見るとよりわかりやすいが、dの違いが大きいほど、ddiff*ddiffが大きくなり、wのexp2の値が小さくなる(Weightが小さくなる)
  float ddiff = (d - center_d) * frag_ubo.g_Sharpness;

  // 法線が離れるほど重みを減らす
  float normalDot = dot(center_n, n);
  float normalWeight = pow(max(normalDot, 0.0), frag_ubo.nExponent); 

  //
  float w = exp2(-r*r*BlurFalloff - ddiff*ddiff) * normalWeight;
  w_total += w;

  return c*w;
}

void main()
{
  vec4  center_c = GetTexSource( v2f_UV );
  float center_d = GetTexLinearDepth( v2f_UV );
  vec3 center_n = GetWorldNormal( v2f_UV );
  
  vec4  c_total = center_c;
  float w_total = 1.0;

  vec2 texSize = GetTextureSize();
  vec2 dir = frag_ubo.g_InvResolutionDirection;
  dir.x = dir.x / texSize.x;
  dir.y = dir.y / texSize.y;
  
  for (float r = 1; r <= float(frag_ubo.kernelRadius); ++r)
  {
    vec2 uv = v2f_UV + dir * r;
    c_total += BlurFunction(uv, r, center_c, center_d, center_n, w_total);  
  }
  
  for (float r = 1; r <= float(frag_ubo.kernelRadius); ++r)
  {
    vec2 uv = v2f_UV - dir * r;
    c_total += BlurFunction(uv, r, center_c, center_d, center_n, w_total);  
  }

  outColor = c_total/w_total;
}