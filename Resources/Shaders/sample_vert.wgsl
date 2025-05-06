struct gl_PerVertex {
    @builtin(position) gl_Position: vec4<f32>,
    gl_PointSize: f32,
    gl_ClipDistance: array<f32,1u>,
    gl_CullDistance: array<f32,1u>,
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

var<private> perVertexStruct: gl_PerVertex = gl_PerVertex(vec4<f32>(0.0, 0.0, 0.0, 1.0), 1.0, array<f32,1u>(0.0), array<f32,1u>(0.0));
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
    let _e24 = ubo.proj;
    let _e26 = ubo.view;
    let _e29 = ubo.model;
    let _e31 = inPosition_1;
    perVertexStruct.gl_Position = (((_e24 * _e26) * _e29) * vec4<f32>(_e31.x, _e31.y, _e31.z, 1.0));
    let _e39 = ubo.model;
    let _e40 = inNormal_1;
    f_WorldNormal = (_e39 * vec4<f32>(_e40.x, _e40.y, _e40.z, 0.0)).xyz;
    let _e47 = inTexcoord_1;
    f_Texcoord = _e47;
    let _e49 = ubo.model;
    let _e50 = inPosition_1;
    f_WorldPos = (_e49 * vec4<f32>(_e50.x, _e50.y, _e50.z, 1.0));
    let _e57 = ubo.color;
    f_Color = _e57;
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
    let _e19 = perVertexStruct.gl_Position.y;
    perVertexStruct.gl_Position.y = -(_e19);
    let _e21 = perVertexStruct.gl_Position;
    let _e22 = f_WorldNormal;
    let _e23 = f_Texcoord;
    let _e24 = f_WorldPos;
    let _e25 = f_Color;
    return VertexOutput(_e21, _e22, _e23, _e24, _e25);
}
