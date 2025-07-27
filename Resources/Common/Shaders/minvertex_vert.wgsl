struct VertUniformBuffer {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVPMat: mat4x4<f32>,
}

struct gl_PerVertex {
    @builtin(position) gl_Position: vec4<f32>,
    gl_PointSize: f32,
    gl_ClipDistance: array<f32, 1>,
    gl_CullDistance: array<f32, 1>,
}

struct VertexOutput {
    @builtin(position) gl_Position: vec4<f32>,
    @location(0) member: vec2<f32>,
    @location(1) member_1: vec4<f32>,
}

@group(0) @binding(0) 
var<uniform> v_ubo: VertUniformBuffer;
var<private> inPosition_1: vec3<f32>;
var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
var<private> v2f_UV: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> v2f_ProjPos: vec4<f32>;
var<private> inNormal_1: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
var<private> inBone0_1: vec4<u32>;
var<private> inWeights0_1: vec4<f32>;

fn main_1() {
    var ProjPos: vec4<f32>;

    let _e17 = v_ubo.proj;
    let _e19 = v_ubo.view;
    let _e22 = v_ubo.model;
    let _e24 = inPosition_1;
    ProjPos = (((_e17 * _e19) * _e22) * vec4<f32>(_e24.x, _e24.y, _e24.z, 1f));
    let _e30 = ProjPos;
    unnamed.gl_Position = _e30;
    let _e32 = inTexcoord_1;
    v2f_UV = _e32;
    let _e33 = ProjPos;
    v2f_ProjPos = _e33;
    return;
}

@vertex 
fn main(@location(0) inPosition: vec3<f32>, @location(2) inTexcoord: vec2<f32>, @location(1) inNormal: vec3<f32>, @location(3) inTangent: vec4<f32>, @location(4) inBone0_: vec4<u32>, @location(5) inWeights0_: vec4<f32>) -> VertexOutput {
    inPosition_1 = inPosition;
    inTexcoord_1 = inTexcoord;
    inNormal_1 = inNormal;
    inTangent_1 = inTangent;
    inBone0_1 = inBone0_;
    inWeights0_1 = inWeights0_;
    main_1();
    let _e17 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e17);
    let _e19 = unnamed.gl_Position;
    let _e20 = v2f_UV;
    let _e21 = v2f_ProjPos;
    return VertexOutput(_e19, _e20, _e21);
}
