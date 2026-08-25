struct UniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    prevMVP: mat4x4<f32>,
    useSkinMeshAnimation: i32,
    useSpatialCulling: i32,
    receiveSSR: i32,
    pad2_: i32,
    baseColorFactor: vec4<f32>,
    spatialCullPos: vec4<f32>,
    emissiveFactor: vec4<f32>,
    metallicFactor: f32,
    roughnessFactor: f32,
    emissiveStrength: f32,
    materialType: f32,
    useBaseColorTexture: i32,
    useMetallicRoughnessTexture: i32,
    useNormalTexture: i32,
    useEmissiveTexture: i32,
    baseColorTexture_ST: vec4<f32>,
}

struct FragmentOutput {
    @location(0) member: vec4<f32>,
    @location(1) member_1: vec4<f32>,
    @location(2) member_2: vec4<f32>,
    @location(3) member_3: vec4<f32>,
    @location(4) member_4: vec4<f32>,
    @location(5) member_5: vec4<f32>,
    @location(6) member_6: vec4<f32>,
}

@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> f_Texcoord_1: vec2<f32>;
@group(0) @binding(3) 
var baseColorTexture: texture_2d<f32>;
@group(0) @binding(4) 
var baseColorTextureSampler: sampler;
var<private> f_WorldTangent_1: vec3<f32>;
var<private> f_WorldBioTangent_1: vec3<f32>;
var<private> f_WorldNormal_1: vec3<f32>;
@group(0) @binding(7) 
var normalTexture: texture_2d<f32>;
@group(0) @binding(8) 
var normalTextureSampler: sampler;
@group(0) @binding(5) 
var metallicRoughnessTexture: texture_2d<f32>;
@group(0) @binding(6) 
var metallicRoughnessTextureSampler: sampler;
@group(0) @binding(9) 
var emissiveTexture: texture_2d<f32>;
@group(0) @binding(10) 
var emissiveTextureSampler: sampler;
var<private> f_WorldPos_1: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_PrevProjPos_1: vec4<f32>;
var<private> gPosition: vec4<f32>;
var<private> gNormal: vec4<f32>;
var<private> gAlbedo: vec4<f32>;
var<private> gDepth: vec4<f32>;
var<private> gCustomParam0_: vec4<f32>;
var<private> gEmission: vec4<f32>;
var<private> gVelocity: vec4<f32>;

fn GetEmissive_u0028_() -> vec3<f32> {
    var emissive: vec3<f32>;

    let _e52 = ubo.emissiveFactor;
    let _e55 = ubo.emissiveStrength;
    emissive = (_e52.xyz * _e55);
    let _e58 = ubo.useEmissiveTexture;
    if (_e58 != 0i) {
        let _e60 = f_Texcoord_1;
        let _e61 = textureSample(emissiveTexture, emissiveTextureSampler, _e60);
        let _e63 = emissive;
        emissive = (_e63 * _e61.xyz);
    }
    let _e65 = emissive;
    return _e65;
}

fn GetMetallicRoughness_u0028_() -> vec2<f32> {
    var perceptualRoughness: f32;
    var metallic: f32;
    var metallicRoughnessColor: vec4<f32>;

    let _e54 = ubo.roughnessFactor;
    perceptualRoughness = _e54;
    let _e56 = ubo.metallicFactor;
    metallic = _e56;
    let _e58 = ubo.useMetallicRoughnessTexture;
    if (_e58 != 0i) {
        let _e60 = f_Texcoord_1;
        let _e61 = textureSample(metallicRoughnessTexture, metallicRoughnessTextureSampler, _e60);
        metallicRoughnessColor = _e61;
        let _e63 = metallicRoughnessColor[1u];
        perceptualRoughness = _e63;
        let _e65 = metallicRoughnessColor[2u];
        metallic = _e65;
    }
    let _e66 = metallic;
    let _e67 = perceptualRoughness;
    return vec2<f32>(_e66, _e67);
}

fn getNormal_u0028_() -> vec3<f32> {
    var nomral: vec3<f32>;
    var t: vec3<f32>;
    var b: vec3<f32>;
    var n: vec3<f32>;
    var tbn: mat3x3<f32>;

    nomral = vec3<f32>(0f, 0f, 0f);
    let _e56 = ubo.useNormalTexture;
    if (_e56 != 0i) {
        let _e58 = f_WorldTangent_1;
        t = normalize(_e58);
        let _e60 = f_WorldBioTangent_1;
        b = normalize(_e60);
        let _e62 = f_WorldNormal_1;
        n = normalize(_e62);
        let _e64 = t;
        let _e65 = b;
        let _e66 = n;
        tbn = mat3x3<f32>(vec3<f32>(_e64.x, _e64.y, _e64.z), vec3<f32>(_e65.x, _e65.y, _e65.z), vec3<f32>(_e66.x, _e66.y, _e66.z));
        let _e80 = f_Texcoord_1;
        let _e81 = textureSample(normalTexture, normalTextureSampler, _e80);
        nomral = _e81.xyz;
        let _e83 = tbn;
        let _e84 = nomral;
        nomral = normalize((_e83 * ((_e84 * 2f) - vec3(1f))));
    } else {
        let _e90 = f_WorldNormal_1;
        nomral = _e90;
    }
    let _e91 = nomral;
    return _e91;
}

fn SRGBtoLINEAR_u0028_vf4_u003b(srgbIn: ptr<function, vec4<f32>>) -> vec4<f32> {
    let _e51 = (*srgbIn);
    let _e53 = pow(_e51.xyz, vec3<f32>(2.2f, 2.2f, 2.2f));
    let _e55 = (*srgbIn)[3u];
    return vec4<f32>(_e53.x, _e53.y, _e53.z, _e55);
}

fn GetBaseColor_u0028_() -> vec4<f32> {
    var st: vec2<f32>;
    var baseColor: vec4<f32>;
    var param: vec4<f32>;

    let _e54 = ubo.useBaseColorTexture;
    if (_e54 != 0i) {
        let _e56 = f_Texcoord_1;
        let _e58 = ubo.baseColorTexture_ST;
        let _e62 = ubo.baseColorTexture_ST;
        st = ((_e56 * _e58.xy) + _e62.zw);
        let _e65 = st;
        let _e66 = textureSample(baseColorTexture, baseColorTextureSampler, _e65);
        baseColor = _e66;
    } else {
        let _e68 = ubo.baseColorFactor;
        baseColor = _e68;
    }
    let _e69 = baseColor;
    param = _e69;
    let _e70 = SRGBtoLINEAR_u0028_vf4_u003b((&param));
    return _e70;
}

fn main_1() {
    var baseColor_1: vec4<f32>;
    var normal: vec3<f32>;
    var depth: f32;
    var metallicRoughness: vec2<f32>;
    var emissive_1: vec3<f32>;
    var ndcUV: vec2<f32>;
    var prevNDCUV: vec2<f32>;
    var velocity: vec2<f32>;

    let _e59 = ubo.useSpatialCulling;
    if (_e59 == 1i) {
        let _e62 = f_WorldPos_1[1u];
        let _e65 = ubo.spatialCullPos[1u];
        if (_e62 < _e65) {
            discard;
        }
    }
    let _e67 = GetBaseColor_u0028_();
    baseColor_1 = _e67;
    let _e68 = getNormal_u0028_();
    normal = _e68;
    let _e70 = v2f_ProjPos_1[2u];
    let _e72 = v2f_ProjPos_1[3u];
    depth = (_e70 / _e72);
    let _e74 = depth;
    depth = ((_e74 * 0.5f) + 0.5f);
    let _e77 = GetMetallicRoughness_u0028_();
    metallicRoughness = _e77;
    let _e78 = GetEmissive_u0028_();
    emissive_1 = _e78;
    let _e79 = v2f_ProjPos_1;
    let _e82 = v2f_ProjPos_1[3u];
    ndcUV = (_e79.xy / vec2(_e82));
    let _e85 = ndcUV;
    ndcUV = ((_e85 * 0.5f) + vec2(0.5f));
    let _e89 = v2f_PrevProjPos_1;
    let _e92 = v2f_PrevProjPos_1[3u];
    prevNDCUV = (_e89.xy / vec2(_e92));
    let _e95 = prevNDCUV;
    prevNDCUV = ((_e95 * 0.5f) + vec2(0.5f));
    let _e99 = ndcUV;
    let _e100 = prevNDCUV;
    velocity = (_e99 - _e100);
    let _e102 = f_WorldPos_1;
    gPosition = _e102;
    let _e103 = normal;
    gNormal = vec4<f32>(_e103.x, _e103.y, _e103.z, 0f);
    let _e108 = baseColor_1;
    gAlbedo = _e108;
    let _e109 = depth;
    let _e110 = depth;
    let _e111 = depth;
    gDepth = vec4<f32>(_e109, _e110, _e111, 1f);
    let _e114 = ubo.materialType;
    let _e116 = metallicRoughness[0u];
    let _e118 = metallicRoughness[1u];
    let _e120 = ubo.receiveSSR;
    gCustomParam0_ = vec4<f32>(_e114, _e116, _e118, f32(_e120));
    let _e123 = emissive_1;
    gEmission = vec4<f32>(_e123.x, _e123.y, _e123.z, 1f);
    let _e128 = velocity;
    gVelocity = vec4<f32>(_e128.x, _e128.y, 0f, 1f);
    return;
}

@fragment 
fn main(@location(1) f_Texcoord: vec2<f32>, @location(3) f_WorldTangent: vec3<f32>, @location(4) f_WorldBioTangent: vec3<f32>, @location(0) f_WorldNormal: vec3<f32>, @location(2) f_WorldPos: vec4<f32>, @location(5) v2f_ProjPos: vec4<f32>, @location(6) v2f_PrevProjPos: vec4<f32>) -> FragmentOutput {
    f_Texcoord_1 = f_Texcoord;
    f_WorldTangent_1 = f_WorldTangent;
    f_WorldBioTangent_1 = f_WorldBioTangent;
    f_WorldNormal_1 = f_WorldNormal;
    f_WorldPos_1 = f_WorldPos;
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_PrevProjPos_1 = v2f_PrevProjPos;
    main_1();
    let _e21 = gPosition;
    let _e22 = gNormal;
    let _e23 = gAlbedo;
    let _e24 = gDepth;
    let _e25 = gCustomParam0_;
    let _e26 = gEmission;
    let _e27 = gVelocity;
    return FragmentOutput(_e21, _e22, _e23, _e24, _e25, _e26, _e27);
}
