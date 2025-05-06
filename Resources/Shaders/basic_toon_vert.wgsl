struct UniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVPMat: mat4x4<f32>,
    edgeSize: f32,
    fPad0_: f32,
    fPad1_: f32,
    fPad2_: f32,
    useSkinMeshAnimation: i32,
    pad0_: i32,
    pad1_: i32,
    pad2_: i32,
}

struct SkinMatrixBuffer {
    SkinMat: array<mat4x4<f32>,1024u>,
}

struct gl_PerVertex {
    @builtin(position) gl_Position: vec4<f32>,
    gl_PointSize: f32,
    gl_ClipDistance: array<f32,1u>,
    gl_CullDistance: array<f32,1u>,
}

struct VertexOutput {
    @builtin(position) gl_Position: vec4<f32>,
    @location(0) member: vec3<f32>,
    @location(1) member_1: vec2<f32>,
    @location(2) member_2: vec4<f32>,
    @location(3) member_3: vec3<f32>,
    @location(4) member_4: vec3<f32>,
    @location(5) member_5: vec4<f32>,
    @location(6) member_6: vec2<f32>,
}

var<private> inNormal_1: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
var<private> inPosition_1: vec3<f32>;
@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> inWeights0_1: vec4<f32>;
@group(0) @binding(1) 
var<uniform> r_SkinMatrixBuffer: SkinMatrixBuffer;
var<private> inBone0_1: vec4<u32>;
var<private> perVertexStruct: gl_PerVertex = gl_PerVertex(vec4<f32>(0.0, 0.0, 0.0, 1.0), 1.0, array<f32,1u>(0.0), array<f32,1u>(0.0));
var<private> f_WorldNormal: vec3<f32>;
var<private> f_Texcoord: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> f_WorldPos: vec4<f32>;
var<private> f_WorldTangent: vec3<f32>;
var<private> f_WorldBioTangent: vec3<f32>;
var<private> f_LightSpacePos: vec4<f32>;
var<private> f_SphereUV: vec2<f32>;

fn main_1() {
    var BioTangent: vec3<f32>;
    var LocalPos: vec3<f32>;
    var SkinMat: mat4x4<f32>;
    var WorldPos: vec4<f32>;
    var WorldNormal: vec3<f32>;
    var WorldTangent: vec3<f32>;
    var WorldBioTangent: vec3<f32>;
    var VNormal: vec4<f32>;
    var SphereUV: vec2<f32>;

    let _e42 = inNormal_1;
    let _e43 = inTangent_1;
    BioTangent = cross(_e42, _e43.xyz);
    let _e46 = inPosition_1;
    LocalPos = _e46;
    let _e48 = ubo.useSkinMeshAnimation;
    if (_e48 != 0) {
        let _e51 = inWeights0_1[0u];
        let _e53 = inBone0_1[0u];
        let _e56 = r_SkinMatrixBuffer.SkinMat[_e53];
        let _e57 = (_e56 * _e51);
        let _e59 = inWeights0_1[1u];
        let _e61 = inBone0_1[1u];
        let _e64 = r_SkinMatrixBuffer.SkinMat[_e61];
        let _e65 = (_e64 * _e59);
        let _e78 = mat4x4<f32>((_e57[0] + _e65[0]), (_e57[1] + _e65[1]), (_e57[2] + _e65[2]), (_e57[3] + _e65[3]));
        let _e80 = inWeights0_1[2u];
        let _e82 = inBone0_1[2u];
        let _e85 = r_SkinMatrixBuffer.SkinMat[_e82];
        let _e86 = (_e85 * _e80);
        let _e99 = mat4x4<f32>((_e78[0] + _e86[0]), (_e78[1] + _e86[1]), (_e78[2] + _e86[2]), (_e78[3] + _e86[3]));
        let _e101 = inWeights0_1[3u];
        let _e103 = inBone0_1[3u];
        let _e106 = r_SkinMatrixBuffer.SkinMat[_e103];
        let _e107 = (_e106 * _e101);
        SkinMat = mat4x4<f32>((_e99[0] + _e107[0]), (_e99[1] + _e107[1]), (_e99[2] + _e107[2]), (_e99[3] + _e107[3]));
        let _e121 = SkinMat;
        let _e122 = LocalPos;
        WorldPos = (_e121 * vec4<f32>(_e122.x, _e122.y, _e122.z, 1.0));
        let _e128 = SkinMat;
        let _e129 = inNormal_1;
        WorldNormal = normalize((_e128 * vec4<f32>(_e129.x, _e129.y, _e129.z, 0.0)).xyz);
        let _e137 = SkinMat;
        let _e138 = inTangent_1;
        WorldTangent = normalize((_e137 * _e138).xyz);
        let _e142 = SkinMat;
        let _e143 = BioTangent;
        WorldBioTangent = normalize((_e142 * vec4<f32>(_e143.x, _e143.y, _e143.z, 0.0)).xyz);
    } else {
        let _e152 = ubo.model;
        let _e153 = LocalPos;
        WorldPos = (_e152 * vec4<f32>(_e153.x, _e153.y, _e153.z, 1.0));
        let _e160 = ubo.model;
        let _e161 = inNormal_1;
        WorldNormal = normalize((_e160 * vec4<f32>(_e161.x, _e161.y, _e161.z, 0.0)).xyz);
        let _e170 = ubo.model;
        let _e171 = inTangent_1;
        WorldTangent = normalize((_e170 * _e171).xyz);
        let _e176 = ubo.model;
        let _e177 = BioTangent;
        WorldBioTangent = normalize((_e176 * vec4<f32>(_e177.x, _e177.y, _e177.z, 0.0)).xyz);
    }
    let _e186 = ubo.view;
    let _e187 = WorldNormal;
    VNormal = (_e186 * vec4<f32>(_e187.x, _e187.y, _e187.z, 0.0));
    let _e193 = VNormal;
    SphereUV = ((_e193.xy * 0.5) + vec2<f32>(0.5));
    let _e199 = ubo.proj;
    let _e201 = ubo.view;
    let _e203 = WorldPos;
    perVertexStruct.gl_Position = ((_e199 * _e201) * _e203);
    let _e206 = WorldNormal;
    f_WorldNormal = _e206;
    let _e207 = inTexcoord_1;
    f_Texcoord = _e207;
    let _e208 = WorldPos;
    f_WorldPos = _e208;
    let _e209 = WorldTangent;
    f_WorldTangent = _e209;
    let _e210 = WorldBioTangent;
    f_WorldBioTangent = _e210;
    let _e212 = ubo.lightVPMat;
    let _e213 = WorldPos;
    f_LightSpacePos = (_e212 * _e213);
    let _e215 = SphereUV;
    f_SphereUV = _e215;
    return;
}

@vertex 
fn main(@location(1) inNormal: vec3<f32>, @location(3) inTangent: vec4<f32>, @location(0) inPosition: vec3<f32>, @location(5) inWeights0_: vec4<f32>, @location(4) inBone0_: vec4<u32>, @location(2) inTexcoord: vec2<f32>) -> VertexOutput {
    inNormal_1 = inNormal;
    inTangent_1 = inTangent;
    inPosition_1 = inPosition;
    inWeights0_1 = inWeights0_;
    inBone0_1 = inBone0_;
    inTexcoord_1 = inTexcoord;
    main_1();
    let _e22 = perVertexStruct.gl_Position.y;
    perVertexStruct.gl_Position.y = -(_e22);
    let _e24 = perVertexStruct.gl_Position;
    let _e25 = f_WorldNormal;
    let _e26 = f_Texcoord;
    let _e27 = f_WorldPos;
    let _e28 = f_WorldTangent;
    let _e29 = f_WorldBioTangent;
    let _e30 = f_LightSpacePos;
    let _e31 = f_SphereUV;
    return VertexOutput(_e24, _e25, _e26, _e27, _e28, _e29, _e30, _e31);
}
