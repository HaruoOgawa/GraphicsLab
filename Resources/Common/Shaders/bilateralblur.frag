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

const float KERNEL_RADIUS = 3;
  
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
  float fPad2;
} frag_ubo;

#ifdef USE_OPENGL
layout(binding = 3) uniform sampler2D texSource;
layout(binding = 5) uniform sampler2D texDepth;
#else
layout(binding = 3) uniform texture2D texSource;
layout(binding = 4) uniform sampler texSourceSampler;
layout(binding = 5) uniform texture2D texDepth;
layout(binding = 6) uniform sampler texDepthSampler;
#endif

layout(location = 0) out vec4 outColor;

vec3 GetTexSource(vec2 uv)
{
	vec4 col = vec4(0.0);

	#ifdef USE_OPENGL
	col.rgb = texture(texSource, uv).rgb;
	#else
	col.rgb = texture(sampler2D(texSource, texSourceSampler), uv).rgb;
	#endif

	return col.rgb;
}

float GetTexLinearDepth(vec2 uv)
{
	#ifdef USE_OPENGL
	float depth = texture(texDepth, uv).r;
	#else
	float depth = texture(sampler2D(texDepth, texDepthSampler), uv).r;
	#endif

    // LinearDepth(つまりNDC)に戻す
    float z = depth * 2.0 - 1.0;
    return (2.0 * near * far) / (far + near - z * (far - near));
}

//-------------------------------------------------------------------------

vec4 BlurFunction(vec2 uv, float r, vec4 center_c, float center_d, inout float w_total)
{
  vec4  c = GetTexSource( uv );
  float d = GetTexLinearDepth( uv );
  
  const float BlurSigma = float(KERNEL_RADIUS) * 0.5;
  const float BlurFalloff = 1.0 / (2.0*BlurSigma*BlurSigma);
  
  // グラフツールで見るとよりわかりやすいが、dの違いが大きいほど、ddiff*ddiffが大きくなり、wのexp2の値が小さくなる(Weightが小さくなる)
  float ddiff = (d - center_d) * frag_ubo.g_Sharpness;
  float w = exp2(-r*r*BlurFalloff - ddiff*ddiff);
  w_total += w;

  return c*w;
}

void main()
{
  vec4  center_c = GetTexSource( v2f_UV );
  float center_d = GetTexLinearDepth( v2f_UV );
  
  vec4  c_total = center_c;
  float w_total = 1.0;
  
  for (float r = 1; r <= KERNEL_RADIUS; ++r)
  {
    vec2 uv = v2f_UV + frag_ubo.g_InvResolutionDirection * r;
    c_total += BlurFunction(uv, r, center_c, center_d, w_total);  
  }
  
  for (float r = 1; r <= KERNEL_RADIUS; ++r)
  {
    vec2 uv = v2f_UV - g_InvResolutionDirection * r;
    c_total += BlurFunction(uv, r, center_c, center_d, w_total);  
  }

  out_Color = c_total/w_total;
}