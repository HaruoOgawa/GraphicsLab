struct UniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVMat: mat4x4<f32>,
    lightPMat: mat4x4<f32>,
    lightDir: vec4<f32>,
    lightColor: vec4<f32>,
    cameraPos: vec4<f32>,
    baseColorFactor: vec4<f32>,
    emissiveFactor: vec4<f32>,
    spatialCullPos: vec4<f32>,
    ambientColor: vec4<f32>,
    time: f32,
    metallicFactor: f32,
    roughnessFactor: f32,
    normalMapScale: f32,
    occlusionStrength: f32,
    mipCount: f32,
    ShadowMapX: f32,
    ShadowMapY: f32,
    emissiveStrength: f32,
    fPad0_: f32,
    fPad1_: f32,
    fPad2_: f32,
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
}

var<private> inNormal_1: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> inWeights0_1: vec4<f32>;
@group(0) @binding(1) 
var<uniform> r_SkinMatrixBuffer: SkinMatrixBuffer;
var<private> inJoint0_1: vec4<u32>;
var<private> inPosition_1: vec3<f32>;
var<private> perVertexStruct: gl_PerVertex = gl_PerVertex(vec4<f32>(0.0, 0.0, 0.0, 1.0), 1.0, array<f32,1u>(0.0), array<f32,1u>(0.0));
var<private> f_WorldNormal: vec3<f32>;
var<private> f_Texcoord: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> f_WorldPos: vec4<f32>;
var<private> f_WorldTangent: vec3<f32>;
var<private> f_WorldBioTangent: vec3<f32>;
var<private> f_LightSpacePos: vec4<f32>;

fn main_1() {
    var BioTangent: vec3<f32>;
    var SkinMat: mat4x4<f32>;
    var WorldPos: vec4<f32>;
    var WorldNormal: vec3<f32>;
    var WorldTangent: vec3<f32>;
    var WorldBioTangent: vec3<f32>;

    let _e38 = inNormal_1;
    let _e39 = inTangent_1;
    BioTangent = cross(_e38, _e39.xyz);
    let _e43 = ubo.useSkinMeshAnimation;
    if (_e43 != 0) {
        let _e46 = inWeights0_1[0u];
        let _e48 = inJoint0_1[0u];
        let _e51 = r_SkinMatrixBuffer.SkinMat[_e48];
        let _e52 = (_e51 * _e46);
        let _e54 = inWeights0_1[1u];
        let _e56 = inJoint0_1[1u];
        let _e59 = r_SkinMatrixBuffer.SkinMat[_e56];
        let _e60 = (_e59 * _e54);
        let _e73 = mat4x4<f32>((_e52[0] + _e60[0]), (_e52[1] + _e60[1]), (_e52[2] + _e60[2]), (_e52[3] + _e60[3]));
        let _e75 = inWeights0_1[2u];
        let _e77 = inJoint0_1[2u];
        let _e80 = r_SkinMatrixBuffer.SkinMat[_e77];
        let _e81 = (_e80 * _e75);
        let _e94 = mat4x4<f32>((_e73[0] + _e81[0]), (_e73[1] + _e81[1]), (_e73[2] + _e81[2]), (_e73[3] + _e81[3]));
        let _e96 = inWeights0_1[3u];
        let _e98 = inJoint0_1[3u];
        let _e101 = r_SkinMatrixBuffer.SkinMat[_e98];
        let _e102 = (_e101 * _e96);
        SkinMat = mat4x4<f32>((_e94[0] + _e102[0]), (_e94[1] + _e102[1]), (_e94[2] + _e102[2]), (_e94[3] + _e102[3]));
        let _e116 = SkinMat;
        let _e117 = inPosition_1;
        WorldPos = (_e116 * vec4<f32>(_e117.x, _e117.y, _e117.z, 1.0));
        let _e123 = SkinMat;
        let _e124 = inNormal_1;
        WorldNormal = normalize((_e123 * vec4<f32>(_e124.x, _e124.y, _e124.z, 0.0)).xyz);
        let _e132 = SkinMat;
        let _e133 = inTangent_1;
        WorldTangent = normalize((_e132 * _e133).xyz);
        let _e137 = SkinMat;
        let _e138 = BioTangent;
        WorldBioTangent = normalize((_e137 * vec4<f32>(_e138.x, _e138.y, _e138.z, 0.0)).xyz);
    } else {
        let _e147 = ubo.model;
        let _e148 = inPosition_1;
        WorldPos = (_e147 * vec4<f32>(_e148.x, _e148.y, _e148.z, 1.0));
        let _e155 = ubo.model;
        let _e156 = inNormal_1;
        WorldNormal = normalize((_e155 * vec4<f32>(_e156.x, _e156.y, _e156.z, 0.0)).xyz);
        let _e165 = ubo.model;
        let _e166 = inTangent_1;
        WorldTangent = normalize((_e165 * _e166).xyz);
        let _e171 = ubo.model;
        let _e172 = BioTangent;
        WorldBioTangent = normalize((_e171 * vec4<f32>(_e172.x, _e172.y, _e172.z, 0.0)).xyz);
    }
    let _e181 = ubo.proj;
    let _e183 = ubo.view;
    let _e185 = WorldPos;
    perVertexStruct.gl_Position = ((_e181 * _e183) * _e185);
    let _e188 = WorldNormal;
    f_WorldNormal = _e188;
    let _e189 = inTexcoord_1;
    f_Texcoord = _e189;
    let _e190 = WorldPos;
    f_WorldPos = _e190;
    let _e191 = WorldTangent;
    f_WorldTangent = _e191;
    let _e192 = WorldBioTangent;
    f_WorldBioTangent = _e192;
    let _e194 = ubo.lightPMat;
    let _e196 = ubo.lightVMat;
    let _e198 = WorldPos;
    f_LightSpacePos = ((_e194 * _e196) * _e198);
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
    let _e21 = perVertexStruct.gl_Position.y;
    perVertexStruct.gl_Position.y = -(_e21);
    let _e23 = perVertexStruct.gl_Position;
    let _e24 = f_WorldNormal;
    let _e25 = f_Texcoord;
    let _e26 = f_WorldPos;
    let _e27 = f_WorldTangent;
    let _e28 = f_WorldBioTangent;
    let _e29 = f_LightSpacePos;
    return VertexOutput(_e23, _e24, _e25, _e26, _e27, _e28, _e29);
}
