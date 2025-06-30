struct MorphUniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVPMat: mat4x4<f32>,
    lightDir: vec4<f32>,
    lightColor: vec4<f32>,
    cameraPos: vec4<f32>,
    baseColorFactor: vec4<f32>,
    emissiveFactor: vec4<f32>,
    time: f32,
    metallicFactor: f32,
    roughnessFactor: f32,
    normalMapScale: f32,
    occlusionStrength: f32,
    mipCount: f32,
    ShadowMapX: f32,
    ShadowMapY: f32,
    MorphWeight_0_: f32,
    MorphWeight_1_: f32,
    fPad0_: f32,
    fPad1_: f32,
    useBaseColorTexture: i32,
    useMetallicRoughnessTexture: i32,
    useEmissiveTexture: i32,
    useNormalTexture: i32,
    useOcclusionTexture: i32,
    useCubeMap: i32,
    useShadowMap: i32,
    useIBL: i32,
    useSkinMeshAnimation: i32,
    useDirCubemap: i32,
    useMorph: i32,
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
    @location(5) member_5: vec4<f32>,
}

var<private> inNormal_1: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
var<private> inPosition_1: vec3<f32>;
@group(0) @binding(0) 
var<uniform> ubo: MorphUniformBufferObject;
var<private> inMorphVec0_1: vec3<f32>;
var<private> inMorphVec1_1: vec3<f32>;
var<private> inWeights0_1: vec4<f32>;
@group(0) @binding(1) 
var<uniform> r_SkinMatrixBuffer: SkinMatrixBuffer;
var<private> inJoint0_1: vec4<u32>;
var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
var<private> f_WorldNormal: vec3<f32>;
var<private> f_Texcoord: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> f_WorldPos: vec4<f32>;
var<private> f_WorldTangent: vec3<f32>;
var<private> f_WorldBioTangent: vec3<f32>;
var<private> f_LightSpacePos: vec4<f32>;

fn main_1() {
    var BioTangent: vec3<f32>;
    var LocalPos: vec3<f32>;
    var SkinMat: mat4x4<f32>;
    var WorldPos: vec4<f32>;
    var WorldNormal: vec3<f32>;
    var WorldTangent: vec3<f32>;
    var WorldBioTangent: vec3<f32>;

    let _e39 = inNormal_1;
    let _e40 = inTangent_1;
    BioTangent = cross(_e39, _e40.xyz);
    let _e43 = inPosition_1;
    LocalPos = _e43;
    let _e45 = ubo.useMorph;
    if (_e45 != 0i) {
        let _e47 = inMorphVec0_1;
        let _e49 = ubo.MorphWeight_0_;
        let _e51 = inMorphVec1_1;
        let _e53 = ubo.MorphWeight_1_;
        let _e56 = LocalPos;
        LocalPos = (_e56 + ((_e47 * _e49) + (_e51 * _e53)));
    }
    let _e59 = ubo.useSkinMeshAnimation;
    if (_e59 != 0i) {
        let _e62 = inWeights0_1[0u];
        let _e64 = inJoint0_1[0u];
        let _e67 = r_SkinMatrixBuffer.SkinMat[_e64];
        let _e68 = (_e67 * _e62);
        let _e70 = inWeights0_1[1u];
        let _e72 = inJoint0_1[1u];
        let _e75 = r_SkinMatrixBuffer.SkinMat[_e72];
        let _e76 = (_e75 * _e70);
        let _e89 = mat4x4<f32>((_e68[0] + _e76[0]), (_e68[1] + _e76[1]), (_e68[2] + _e76[2]), (_e68[3] + _e76[3]));
        let _e91 = inWeights0_1[2u];
        let _e93 = inJoint0_1[2u];
        let _e96 = r_SkinMatrixBuffer.SkinMat[_e93];
        let _e97 = (_e96 * _e91);
        let _e110 = mat4x4<f32>((_e89[0] + _e97[0]), (_e89[1] + _e97[1]), (_e89[2] + _e97[2]), (_e89[3] + _e97[3]));
        let _e112 = inWeights0_1[3u];
        let _e114 = inJoint0_1[3u];
        let _e117 = r_SkinMatrixBuffer.SkinMat[_e114];
        let _e118 = (_e117 * _e112);
        SkinMat = mat4x4<f32>((_e110[0] + _e118[0]), (_e110[1] + _e118[1]), (_e110[2] + _e118[2]), (_e110[3] + _e118[3]));
        let _e132 = SkinMat;
        let _e133 = LocalPos;
        WorldPos = (_e132 * vec4<f32>(_e133.x, _e133.y, _e133.z, 1f));
        let _e139 = SkinMat;
        let _e140 = inNormal_1;
        WorldNormal = normalize((_e139 * vec4<f32>(_e140.x, _e140.y, _e140.z, 0f)).xyz);
        let _e148 = SkinMat;
        let _e149 = inTangent_1;
        WorldTangent = normalize((_e148 * _e149).xyz);
        let _e153 = SkinMat;
        let _e154 = BioTangent;
        WorldBioTangent = normalize((_e153 * vec4<f32>(_e154.x, _e154.y, _e154.z, 0f)).xyz);
    } else {
        let _e163 = ubo.model;
        let _e164 = LocalPos;
        WorldPos = (_e163 * vec4<f32>(_e164.x, _e164.y, _e164.z, 1f));
        let _e171 = ubo.model;
        let _e172 = inNormal_1;
        WorldNormal = normalize((_e171 * vec4<f32>(_e172.x, _e172.y, _e172.z, 0f)).xyz);
        let _e181 = ubo.model;
        let _e182 = inTangent_1;
        WorldTangent = normalize((_e181 * _e182).xyz);
        let _e187 = ubo.model;
        let _e188 = BioTangent;
        WorldBioTangent = normalize((_e187 * vec4<f32>(_e188.x, _e188.y, _e188.z, 0f)).xyz);
    }
    let _e197 = ubo.proj;
    let _e199 = ubo.view;
    let _e201 = WorldPos;
    unnamed.gl_Position = ((_e197 * _e199) * _e201);
    let _e204 = WorldNormal;
    f_WorldNormal = _e204;
    let _e205 = inTexcoord_1;
    f_Texcoord = _e205;
    let _e206 = WorldPos;
    f_WorldPos = _e206;
    let _e207 = WorldTangent;
    f_WorldTangent = _e207;
    let _e208 = WorldBioTangent;
    f_WorldBioTangent = _e208;
    let _e210 = ubo.lightVPMat;
    let _e211 = WorldPos;
    f_LightSpacePos = (_e210 * _e211);
    return;
}

@vertex 
fn main(@location(1) inNormal: vec3<f32>, @location(3) inTangent: vec4<f32>, @location(0) inPosition: vec3<f32>, @location(6) inMorphVec0_: vec3<f32>, @location(7) inMorphVec1_: vec3<f32>, @location(5) inWeights0_: vec4<f32>, @location(4) inJoint0_: vec4<u32>, @location(2) inTexcoord: vec2<f32>) -> VertexOutput {
    inNormal_1 = inNormal;
    inTangent_1 = inTangent;
    inPosition_1 = inPosition;
    inMorphVec0_1 = inMorphVec0_;
    inMorphVec1_1 = inMorphVec1_;
    inWeights0_1 = inWeights0_;
    inJoint0_1 = inJoint0_;
    inTexcoord_1 = inTexcoord;
    main_1();
    let _e25 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e25);
    let _e27 = unnamed.gl_Position;
    let _e28 = f_WorldNormal;
    let _e29 = f_Texcoord;
    let _e30 = f_WorldPos;
    let _e31 = f_WorldTangent;
    let _e32 = f_WorldBioTangent;
    let _e33 = f_LightSpacePos;
    return VertexOutput(_e27, _e28, _e29, _e30, _e31, _e32, _e33);
}
