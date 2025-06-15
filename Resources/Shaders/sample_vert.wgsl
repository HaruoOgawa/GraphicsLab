struct gl_PerVertex {
    @builtin(position) gl_Position: vec4<f32>,
    gl_PointSize: f32,
    gl_ClipDistance: array<f32, 1>,
    gl_CullDistance: array<f32, 1>,
}

struct UniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVPMat: mat4x4<f32>,
    color: vec4<f32>,
    useTexture: i32,
    pad0_: i32,
    pad1_: i32,
    pad2_: i32,
}

struct VertexOutput {
    @builtin(position) gl_Position: vec4<f32>,
    @location(0) member: vec3<f32>,
    @location(1) member_1: vec2<f32>,
    @location(2) member_2: vec4<f32>,
    @location(3) member_3: vec4<f32>,
}

var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> inPosition_1: vec3<f32>;
var<private> f_WorldNormal: vec3<f32>;
var<private> inNormal_1: vec3<f32>;
var<private> f_Texcoord: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> f_WorldPos: vec4<f32>;
var<private> f_Color: vec4<f32>;
var<private> inTangent_1: vec4<f32>;
var<private> inJoint0_1: vec4<u32>;
var<private> inWeights0_1: vec4<f32>;

fn main_1() {
    let _e20 = ubo.proj;
    let _e22 = ubo.view;
    let _e25 = ubo.model;
    let _e27 = inPosition_1;
    unnamed.gl_Position = (((_e20 * _e22) * _e25) * vec4<f32>(_e27.x, _e27.y, _e27.z, 1f));
    let _e35 = ubo.model;
    let _e36 = inNormal_1;
    f_WorldNormal = (_e35 * vec4<f32>(_e36.x, _e36.y, _e36.z, 0f)).xyz;
    let _e43 = inTexcoord_1;
    f_Texcoord = _e43;
    let _e45 = ubo.model;
    let _e46 = inPosition_1;
    f_WorldPos = (_e45 * vec4<f32>(_e46.x, _e46.y, _e46.z, 1f));
    let _e53 = ubo.color;
    f_Color = _e53;
    return;
}

@vertex 
fn main(@location(0) inPosition: vec3<f32>, @location(1) inNormal: vec3<f32>, @location(2) inTexcoord: vec2<f32>, @location(3) inTangent: vec4<f32>, @location(4) inJoint0_: vec4<u32>, @location(5) inWeights0_: vec4<f32>) -> VertexOutput {
    inPosition_1 = inPosition;
    inNormal_1 = inNormal;
    inTexcoord_1 = inTexcoord;
    inTangent_1 = inTangent;
    inJoint0_1 = inJoint0_;
    inWeights0_1 = inWeights0_;
    main_1();
    let _e19 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e19);
    let _e21 = unnamed.gl_Position;
    let _e22 = f_WorldNormal;
    let _e23 = f_Texcoord;
    let _e24 = f_WorldPos;
    let _e25 = f_Color;
    return VertexOutput(_e21, _e22, _e23, _e24, _e25);
}
