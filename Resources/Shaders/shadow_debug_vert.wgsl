struct UniformBufferObject {
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
}

@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
var<private> inPosition_1: vec3<f32>;
var<private> fragTexCoord: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> inNormal_1: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
var<private> inJoint0_1: vec4<u32>;
var<private> inWeights0_1: vec4<f32>;

fn main_1() {
    var mvmat: mat4x4<f32>;

    let _e20 = ubo.view;
    let _e22 = ubo.model;
    mvmat = (_e20 * _e22);
    mvmat[0][0u] = 5f;
    mvmat[0][1u] = 0f;
    mvmat[0][2u] = 0f;
    mvmat[1][0u] = 0f;
    mvmat[1][1u] = 5f;
    mvmat[1][2u] = 0f;
    mvmat[2][0u] = 0f;
    mvmat[2][1u] = 0f;
    mvmat[2][2u] = 5f;
    let _e43 = ubo.proj;
    let _e44 = mvmat;
    let _e46 = inPosition_1;
    unnamed.gl_Position = ((_e43 * _e44) * vec4<f32>(_e46.x, _e46.y, _e46.z, 1f));
    let _e53 = inTexcoord_1;
    fragTexCoord = _e53;
    return;
}

@vertex 
fn main(@location(0) inPosition: vec3<f32>, @location(2) inTexcoord: vec2<f32>, @location(1) inNormal: vec3<f32>, @location(3) inTangent: vec4<f32>, @location(4) inJoint0_: vec4<u32>, @location(5) inWeights0_: vec4<f32>) -> VertexOutput {
    inPosition_1 = inPosition;
    inTexcoord_1 = inTexcoord;
    inNormal_1 = inNormal;
    inTangent_1 = inTangent;
    inJoint0_1 = inJoint0_;
    inWeights0_1 = inWeights0_;
    main_1();
    let _e16 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e16);
    let _e18 = unnamed.gl_Position;
    let _e19 = fragTexCoord;
    return VertexOutput(_e18, _e19);
}
