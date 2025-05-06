#version 450

layout(location = 0) in vec3 f_WorldNormal;
layout(location = 1) in vec2 f_Texcoord;
layout(location = 2) in vec4 f_WorldPos;
layout(location = 3) in vec4 f_Color;

layout(location = 0) out vec4 outColor;

void main(){
	outColor = f_Color;
}