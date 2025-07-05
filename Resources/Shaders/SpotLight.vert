#version 450

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inNormal;
layout(location = 2) in vec2 inTexcoord;
layout(location = 3) in vec4 inTangent;
layout(location = 4) in uvec4 inBone0;
layout(location = 5) in vec4 inWeights0;

layout(location = 0) out vec2 v2f_UV;
layout(location = 1) out vec4 v2f_ProjPos;

layout(binding = 0) uniform VertUniformBuffer{
	mat4 model;
    mat4 view;
    mat4 proj;
    mat4 lightVPMat;

    float angle; // 初期値: 45° (0.0 ~ 89.0の間の値しか取れない)
    float height; // 初期値: 1.0
} v_ubo;

void main()
{
    vec4 pos = vec4(inPosition, 1.0);

    // 高さの割合
    // 円柱はプリミティブ作成段階で高さ１・半径１の想定
    // 
    // ただしYの範囲が-0.5 ~ 0.5なのでその分補正する
    // float HeightRate = 1.0 - (pos.y + 0.5) / 1.0;
    float HeightRate = (pos.y) / 1.0;

    float angle = radians(v_ubo.angle);
    float subAngle = 3.1415 * 0.5 - angle;
    float height = v_ubo.height;

    // XZ方向の拡大率
    // 正弦定理より => A / sin(a) = B / sin(b) = C / sin(c)
    float XZExpandRate = (height / sin(subAngle)) * sin(angle);

    // Y方向の拡大率
    float YExpandRate = height / 1.0;

    // ライトの変形
    vec3 DeformedScale = vec3(XZExpandRate * HeightRate, YExpandRate, XZExpandRate * HeightRate);

    pos *= mat4(
        DeformedScale.x, 0.0, 0.0, 0.0,
        0.0, DeformedScale.y, 0.0, 0.0,
        0.0, 0.0, DeformedScale.z, 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    //
	vec4 ProjPos = v_ubo.proj * v_ubo.view * v_ubo.model * pos;

	gl_Position = ProjPos;
	v2f_UV = inTexcoord;
	v2f_ProjPos = ProjPos;
}