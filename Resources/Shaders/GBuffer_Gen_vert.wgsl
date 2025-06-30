struct VertUniformBuffer {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVPMat: mat4x4<f32>,
    useSkinMeshAnimation: i32,
    pad0_: i32,
    pad1_: i32,
    pad2_: i32,
}

struct SkinMatrixBuffer {
    SkinMat: array<mat4x4<f32>, 1024>,
}

struct gl_PerVertex {
    @builtin(position) gl_Position: vec4<f32>,
    gl_PointSize: f32,
    gl_ClipDistance: array<f32, 1>,
    gl_CullDistance: array<f32, 1>,
}

struct VertexOutput {
    @builtin(position) gl_Position: vec4<f32>,
    @location(0) member: vec3<f32>,
    @location(1) member_1: vec2<f32>,
    @location(2) member_2: vec4<f32>,
    @location(3) member_3: vec3<f32>,
    @location(4) member_4: vec3<f32>,
}

var<private> inNormal_1: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
@group(0) @binding(0) 
var<uniform> v_ubo: VertUniformBuffer;
var<private> inWeights0_1: vec4<f32>;
@group(0) @binding(1) 
var<uniform> r_SkinMatrixBuffer: SkinMatrixBuffer;
var<private> inJoint0_1: vec4<u32>;
var<private> inPosition_1: vec3<f32>;
var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
var<private> f_WorldNormal: vec3<f32>;
var<private> f_Texcoord: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> f_WorldPos: vec4<f32>;
var<private> f_WorldTangent: vec3<f32>;
var<private> f_WorldBioTangent: vec3<f32>;

fn main_1() {
    var BioTangent: vec3<f32>;
    var SkinMat: mat4x4<f32>;
    var WorldPos: vec4<f32>;
    var WorldNormal: vec3<f32>;
    var WorldTangent: vec3<f32>;
    var WorldBioTangent: vec3<f32>;

    let _e31 = inNormal_1;
    let _e32 = inTangent_1;
    BioTangent = cross(_e31, _e32.xyz);
    let _e36 = v_ubo.useSkinMeshAnimation;
    if (_e36 != 0i) {
        let _e39 = inWeights0_1[0u];
        let _e41 = inJoint0_1[0u];
        let _e44 = r_SkinMatrixBuffer.SkinMat[_e41];
        let _e45 = (_e44 * _e39);
        let _e47 = inWeights0_1[1u];
        let _e49 = inJoint0_1[1u];
        let _e52 = r_SkinMatrixBuffer.SkinMat[_e49];
        let _e53 = (_e52 * _e47);
        let _e66 = mat4x4<f32>((_e45[0] + _e53[0]), (_e45[1] + _e53[1]), (_e45[2] + _e53[2]), (_e45[3] + _e53[3]));
        let _e68 = inWeights0_1[2u];
        let _e70 = inJoint0_1[2u];
        let _e73 = r_SkinMatrixBuffer.SkinMat[_e70];
        let _e74 = (_e73 * _e68);
        let _e87 = mat4x4<f32>((_e66[0] + _e74[0]), (_e66[1] + _e74[1]), (_e66[2] + _e74[2]), (_e66[3] + _e74[3]));
        let _e89 = inWeights0_1[3u];
        let _e91 = inJoint0_1[3u];
        let _e94 = r_SkinMatrixBuffer.SkinMat[_e91];
        let _e95 = (_e94 * _e89);
        SkinMat = mat4x4<f32>((_e87[0] + _e95[0]), (_e87[1] + _e95[1]), (_e87[2] + _e95[2]), (_e87[3] + _e95[3]));
        let _e109 = SkinMat;
        let _e110 = inPosition_1;
        WorldPos = (_e109 * vec4<f32>(_e110.x, _e110.y, _e110.z, 1f));
        let _e116 = SkinMat;
        let _e117 = inNormal_1;
        WorldNormal = normalize((_e116 * vec4<f32>(_e117.x, _e117.y, _e117.z, 0f)).xyz);
        let _e125 = SkinMat;
        let _e126 = inTangent_1;
        WorldTangent = normalize((_e125 * _e126).xyz);
        let _e130 = SkinMat;
        let _e131 = BioTangent;
        WorldBioTangent = normalize((_e130 * vec4<f32>(_e131.x, _e131.y, _e131.z, 0f)).xyz);
    } else {
        let _e140 = v_ubo.model;
        let _e141 = inPosition_1;
        WorldPos = (_e140 * vec4<f32>(_e141.x, _e141.y, _e141.z, 1f));
        let _e148 = v_ubo.model;
        let _e149 = inNormal_1;
        WorldNormal = normalize((_e148 * vec4<f32>(_e149.x, _e149.y, _e149.z, 0f)).xyz);
        let _e158 = v_ubo.model;
        let _e159 = inTangent_1;
        WorldTangent = normalize((_e158 * _e159).xyz);
        let _e164 = v_ubo.model;
        let _e165 = BioTangent;
        WorldBioTangent = normalize((_e164 * vec4<f32>(_e165.x, _e165.y, _e165.z, 0f)).xyz);
    }
    let _e174 = v_ubo.proj;
    let _e176 = v_ubo.view;
    let _e178 = WorldPos;
    unnamed.gl_Position = ((_e174 * _e176) * _e178);
    let _e181 = WorldNormal;
    f_WorldNormal = _e181;
    let _e182 = inTexcoord_1;
    f_Texcoord = _e182;
    let _e183 = WorldPos;
    f_WorldPos = _e183;
    let _e184 = WorldTangent;
    f_WorldTangent = _e184;
    let _e185 = WorldBioTangent;
    f_WorldBioTangent = _e185;
    return;
}

@vertex 
fn main(@location(1) inNormal: vec3<f32>, @location(3) inTangent: vec4<f32>, @location(5) inWeights0_: vec4<f32>, @location(4) inJoint0_: vec4<u32>, @location(0) inPosition: vec3<f32>, @location(2) inTexcoord: vec2<f32>) -> VertexOutput {
    inNormal_1 = inNormal;
    inTangent_1 = inTangent;
    inWeights0_1 = inWeights0_;
    inJoint0_1 = inJoint0_;
    inPosition_1 = inPosition;
    inTexcoord_1 = inTexcoord;
    main_1();
    let _e20 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e20);
    let _e22 = unnamed.gl_Position;
    let _e23 = f_WorldNormal;
    let _e24 = f_Texcoord;
    let _e25 = f_WorldPos;
    let _e26 = f_WorldTangent;
    let _e27 = f_WorldBioTangent;
    return VertexOutput(_e22, _e23, _e24, _e25, _e26, _e27);
}
