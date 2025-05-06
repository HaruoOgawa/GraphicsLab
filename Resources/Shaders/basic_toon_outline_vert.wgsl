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
    var ViewSpaceOutline: bool;
    var CameraPos: vec4<f32>;
    var CameraNormal: vec3<f32>;

    let _e48 = inNormal_1;
    let _e49 = inTangent_1;
    BioTangent = cross(_e48, _e49.xyz);
    let _e52 = inPosition_1;
    LocalPos = _e52;
    let _e54 = ubo.useSkinMeshAnimation;
    if (_e54 != 0) {
        let _e57 = inWeights0_1[0u];
        let _e59 = inBone0_1[0u];
        let _e62 = r_SkinMatrixBuffer.SkinMat[_e59];
        let _e63 = (_e62 * _e57);
        let _e65 = inWeights0_1[1u];
        let _e67 = inBone0_1[1u];
        let _e70 = r_SkinMatrixBuffer.SkinMat[_e67];
        let _e71 = (_e70 * _e65);
        let _e84 = mat4x4<f32>((_e63[0] + _e71[0]), (_e63[1] + _e71[1]), (_e63[2] + _e71[2]), (_e63[3] + _e71[3]));
        let _e86 = inWeights0_1[2u];
        let _e88 = inBone0_1[2u];
        let _e91 = r_SkinMatrixBuffer.SkinMat[_e88];
        let _e92 = (_e91 * _e86);
        let _e105 = mat4x4<f32>((_e84[0] + _e92[0]), (_e84[1] + _e92[1]), (_e84[2] + _e92[2]), (_e84[3] + _e92[3]));
        let _e107 = inWeights0_1[3u];
        let _e109 = inBone0_1[3u];
        let _e112 = r_SkinMatrixBuffer.SkinMat[_e109];
        let _e113 = (_e112 * _e107);
        SkinMat = mat4x4<f32>((_e105[0] + _e113[0]), (_e105[1] + _e113[1]), (_e105[2] + _e113[2]), (_e105[3] + _e113[3]));
        let _e127 = SkinMat;
        let _e128 = LocalPos;
        WorldPos = (_e127 * vec4<f32>(_e128.x, _e128.y, _e128.z, 1.0));
        let _e134 = SkinMat;
        let _e135 = inNormal_1;
        WorldNormal = normalize((_e134 * vec4<f32>(_e135.x, _e135.y, _e135.z, 0.0)).xyz);
        let _e143 = SkinMat;
        let _e144 = inTangent_1;
        WorldTangent = normalize((_e143 * _e144).xyz);
        let _e148 = SkinMat;
        let _e149 = BioTangent;
        WorldBioTangent = normalize((_e148 * vec4<f32>(_e149.x, _e149.y, _e149.z, 0.0)).xyz);
    } else {
        let _e158 = ubo.model;
        let _e159 = LocalPos;
        WorldPos = (_e158 * vec4<f32>(_e159.x, _e159.y, _e159.z, 1.0));
        let _e166 = ubo.model;
        let _e167 = inNormal_1;
        WorldNormal = normalize((_e166 * vec4<f32>(_e167.x, _e167.y, _e167.z, 0.0)).xyz);
        let _e176 = ubo.model;
        let _e177 = inTangent_1;
        WorldTangent = normalize((_e176 * _e177).xyz);
        let _e182 = ubo.model;
        let _e183 = BioTangent;
        WorldBioTangent = normalize((_e182 * vec4<f32>(_e183.x, _e183.y, _e183.z, 0.0)).xyz);
    }
    let _e192 = ubo.view;
    let _e193 = WorldNormal;
    VNormal = (_e192 * vec4<f32>(_e193.x, _e193.y, _e193.z, 0.0));
    let _e199 = VNormal;
    SphereUV = ((_e199.xy * 0.5) + vec2<f32>(0.5));
    ViewSpaceOutline = false;
    let _e204 = ViewSpaceOutline;
    if _e204 {
        let _e206 = ubo.view;
        let _e207 = WorldPos;
        CameraPos = (_e206 * _e207);
        let _e210 = ubo.view;
        let _e211 = WorldNormal;
        CameraNormal = (_e210 * vec4<f32>(_e211.x, _e211.y, _e211.z, 0.0)).xyz;
        let _e218 = CameraNormal;
        let _e222 = ubo.edgeSize;
        let _e225 = CameraPos;
        let _e227 = (_e225.xy + ((normalize(_e218).xy * _e222) * 0.0010000000474974513));
        CameraPos[0u] = _e227.x;
        CameraPos[1u] = _e227.y;
        let _e233 = ubo.proj;
        let _e234 = CameraPos;
        perVertexStruct.gl_Position = (_e233 * _e234);
    } else {
        let _e237 = WorldNormal;
        let _e240 = ubo.edgeSize;
        let _e243 = WorldPos;
        let _e245 = (_e243.xyz + ((normalize(_e237) * _e240) * 0.0010000000474974513));
        WorldPos[0u] = _e245.x;
        WorldPos[1u] = _e245.y;
        WorldPos[2u] = _e245.z;
        let _e253 = ubo.proj;
        let _e255 = ubo.view;
        let _e257 = WorldPos;
        perVertexStruct.gl_Position = ((_e253 * _e255) * _e257);
    }
    let _e260 = WorldNormal;
    f_WorldNormal = _e260;
    let _e261 = inTexcoord_1;
    f_Texcoord = _e261;
    let _e262 = WorldPos;
    f_WorldPos = _e262;
    let _e263 = WorldTangent;
    f_WorldTangent = _e263;
    let _e264 = WorldBioTangent;
    f_WorldBioTangent = _e264;
    let _e266 = ubo.lightVPMat;
    let _e267 = WorldPos;
    f_LightSpacePos = (_e266 * _e267);
    let _e269 = SphereUV;
    f_SphereUV = _e269;
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
