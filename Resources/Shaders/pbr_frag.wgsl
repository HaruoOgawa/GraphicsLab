struct PBRParam {
    NdotL: f32,
    NdotV: f32,
    NdotH: f32,
    LdotH: f32,
    VdotH: f32,
    perceptualRoughness: f32,
    metallic: f32,
    reflectance0_: vec3<f32>,
    reflectance90_: vec3<f32>,
    alphaRoughness: f32,
    diffuseColor: vec3<f32>,
    specularColor: vec3<f32>,
}

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

@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> f_WorldTangent_1: vec3<f32>;
var<private> f_WorldBioTangent_1: vec3<f32>;
var<private> f_WorldNormal_1: vec3<f32>;
@group(0) @binding(8) 
var normalTexture: texture_2d<f32>;
@group(0) @binding(9) 
var normalTextureSampler: sampler;
var<private> f_Texcoord_1: vec2<f32>;
@group(0) @binding(14) 
var shadowmapTexture: texture_2d<f32>;
@group(0) @binding(15) 
var shadowmapTextureSampler: sampler;
@group(0) @binding(12) 
var cubemapTexture: texture_cube<f32>;
@group(0) @binding(13) 
var cubemapTextureSampler: sampler;
@group(0) @binding(22) 
var cubeMap2DTexture: texture_2d<f32>;
@group(0) @binding(23) 
var cubeMap2DTextureSampler: sampler;
@group(0) @binding(20) 
var IBL_GGXLUT_Texture: texture_2d<f32>;
@group(0) @binding(21) 
var IBL_GGXLUT_TextureSampler: sampler;
@group(0) @binding(16) 
var IBL_Diffuse_Texture: texture_2d<f32>;
@group(0) @binding(17) 
var IBL_Diffuse_TextureSampler: sampler;
@group(0) @binding(18) 
var IBL_Specular_Texture: texture_2d<f32>;
@group(0) @binding(19) 
var IBL_Specular_TextureSampler: sampler;
@group(0) @binding(4) 
var metallicRoughnessTexture: texture_2d<f32>;
@group(0) @binding(5) 
var metallicRoughnessTextureSampler: sampler;
@group(0) @binding(2) 
var baseColorTexture: texture_2d<f32>;
@group(0) @binding(3) 
var baseColorTextureSampler: sampler;
var<private> f_WorldPos_1: vec4<f32>;
@group(0) @binding(10) 
var occlusionTexture: texture_2d<f32>;
@group(0) @binding(11) 
var occlusionTextureSampler: sampler;
@group(0) @binding(6) 
var emissiveTexture: texture_2d<f32>;
@group(0) @binding(7) 
var emissiveTextureSampler: sampler;
var<private> f_LightSpacePos_1: vec4<f32>;
var<private> outColor: vec4<f32>;

fn ComputePCFvf2_(uv: ptr<function, vec2<f32>>) -> vec2<f32> {
    var moments: vec2<f32>;
    var texelSize: vec2<f32>;

    moments = vec2<f32>(0.0, 0.0);
    let _e102 = ubo.ShadowMapX;
    let _e105 = ubo.ShadowMapY;
    texelSize = vec2<f32>((1.0 / _e102), (1.0 / _e105));
    let _e108 = (*uv);
    let _e109 = texelSize;
    let _e112 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e108 + (vec2<f32>(-1.0, -1.0) * _e109)));
    let _e114 = moments;
    moments = (_e114 + _e112.xy);
    let _e116 = (*uv);
    let _e117 = texelSize;
    let _e120 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e116 + (vec2<f32>(-1.0, 0.0) * _e117)));
    let _e122 = moments;
    moments = (_e122 + _e120.xy);
    let _e124 = (*uv);
    let _e125 = texelSize;
    let _e128 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e124 + (vec2<f32>(-1.0, 1.0) * _e125)));
    let _e130 = moments;
    moments = (_e130 + _e128.xy);
    let _e132 = (*uv);
    let _e133 = texelSize;
    let _e136 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e132 + (vec2<f32>(0.0, -1.0) * _e133)));
    let _e138 = moments;
    moments = (_e138 + _e136.xy);
    let _e140 = (*uv);
    let _e141 = texelSize;
    let _e144 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e140 + (vec2<f32>(0.0, 0.0) * _e141)));
    let _e146 = moments;
    moments = (_e146 + _e144.xy);
    let _e148 = (*uv);
    let _e149 = texelSize;
    let _e152 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e148 + (vec2<f32>(0.0, 1.0) * _e149)));
    let _e154 = moments;
    moments = (_e154 + _e152.xy);
    let _e156 = (*uv);
    let _e157 = texelSize;
    let _e160 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e156 + (vec2<f32>(1.0, -1.0) * _e157)));
    let _e162 = moments;
    moments = (_e162 + _e160.xy);
    let _e164 = (*uv);
    let _e165 = texelSize;
    let _e168 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e164 + (vec2<f32>(1.0, 0.0) * _e165)));
    let _e170 = moments;
    moments = (_e170 + _e168.xy);
    let _e172 = (*uv);
    let _e173 = texelSize;
    let _e176 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e172 + (vec2<f32>(1.0, 1.0) * _e173)));
    let _e178 = moments;
    moments = (_e178 + _e176.xy);
    let _e180 = moments;
    moments = (_e180 / vec2<f32>(9.0));
    let _e183 = moments;
    return _e183;
}

fn CalcShadowvf3vf3vf3_(lsp: ptr<function, vec3<f32>>, nomral: ptr<function, vec3<f32>>, lightDir: ptr<function, vec3<f32>>) -> f32 {
    var moments_1: vec2<f32>;
    var param: vec2<f32>;
    var ShadowBias: f32;
    var distance: f32;

    let _e105 = (*lsp);
    param = _e105.xy;
    let _e107 = ComputePCFvf2_((&param));
    moments_1 = _e107;
    let _e108 = moments_1;
    moments_1 = ((_e108 * 0.5) + vec2<f32>(0.5));
    let _e112 = (*nomral);
    let _e113 = (*lightDir);
    ShadowBias = max(0.0, (0.0010000000474974513 * (1.0 - dot(_e112, _e113))));
    let _e119 = (*lsp)[2u];
    let _e120 = ShadowBias;
    distance = (_e119 - _e120);
    let _e122 = distance;
    let _e124 = moments_1[0u];
    if (_e122 <= _e124) {
        return 1.0;
    }
    return 0.10000000149011612;
}

fn SRGBtoLINEARvf4_(srgbIn: ptr<function, vec4<f32>>) -> vec4<f32> {
    let _e99 = (*srgbIn);
    let _e101 = pow(_e99.xyz, vec3<f32>(2.200000047683716, 2.200000047683716, 2.200000047683716));
    let _e103 = (*srgbIn)[3u];
    return vec4<f32>(_e101.x, _e101.y, _e101.z, _e103);
}

fn CastDirToStvf3_(Dir: ptr<function, vec3<f32>>) -> vec2<f32> {
    var pi: f32;
    var theta: f32;
    var phi: f32;
    var st: vec2<f32>;

    pi = 3.1414999961853027;
    let _e104 = (*Dir)[1u];
    theta = acos(_e104);
    let _e107 = (*Dir)[2u];
    let _e109 = (*Dir)[0u];
    phi = atan2(_e107, _e109);
    let _e111 = phi;
    let _e112 = pi;
    let _e115 = theta;
    let _e116 = pi;
    st = vec2<f32>((_e111 / (2.0 * _e112)), (_e115 / _e116));
    let _e119 = st;
    return _e119;
}

fn ComputeReflectionColorstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31vf3vf3_(pbrParam: ptr<function, PBRParam>, v: ptr<function, vec3<f32>>, n: ptr<function, vec3<f32>>) -> vec3<f32> {
    var reflectColor: vec3<f32>;
    var mipCount: f32;
    var lod: f32;
    var param_1: vec4<f32>;
    var st_1: vec2<f32>;
    var param_2: vec3<f32>;
    var mipCount_1: f32;
    var lod_1: f32;
    var param_3: vec4<f32>;

    reflectColor = vec3<f32>(0.0, 0.0, 0.0);
    let _e111 = ubo.useCubeMap;
    if (_e111 != 0) {
        let _e114 = ubo.mipCount;
        mipCount = _e114;
        let _e115 = mipCount;
        let _e117 = (*pbrParam).perceptualRoughness;
        lod = (_e115 * _e117);
        let _e119 = (*v);
        let _e120 = (*n);
        let _e122 = lod;
        let _e123 = textureSampleLevel(cubemapTexture, cubemapTextureSampler, reflect(_e119, _e120), _e122);
        param_1 = _e123;
        let _e124 = SRGBtoLINEARvf4_((&param_1));
        reflectColor = _e124.xyz;
    } else {
        let _e127 = ubo.useDirCubemap;
        if (_e127 != 0) {
            let _e129 = (*v);
            let _e130 = (*n);
            param_2 = reflect(_e129, _e130);
            let _e132 = CastDirToStvf3_((&param_2));
            st_1 = _e132;
            let _e134 = ubo.mipCount;
            mipCount_1 = _e134;
            let _e135 = mipCount_1;
            let _e137 = (*pbrParam).perceptualRoughness;
            lod_1 = (_e135 * _e137);
            let _e139 = st_1;
            let _e140 = lod_1;
            let _e141 = textureSampleLevel(cubeMap2DTexture, cubeMap2DTextureSampler, _e139, _e140);
            param_3 = _e141;
            let _e142 = SRGBtoLINEARvf4_((&param_3));
            reflectColor = _e142.xyz;
        }
    }
    let _e144 = reflectColor;
    return _e144;
}

fn GetSphericalTexcoordvf3_(Dir_1: ptr<function, vec3<f32>>) -> vec2<f32> {
    var pi_1: f32;
    var theta_1: f32;
    var phi_1: f32;
    var st_2: vec2<f32>;

    pi_1 = 3.1414999961853027;
    let _e104 = (*Dir_1)[1u];
    theta_1 = acos(_e104);
    let _e107 = (*Dir_1)[2u];
    let _e109 = (*Dir_1)[0u];
    phi_1 = atan2(_e107, _e109);
    let _e111 = phi_1;
    let _e112 = pi_1;
    let _e115 = theta_1;
    let _e116 = pi_1;
    st_2 = vec2<f32>((_e111 / (2.0 * _e112)), (_e115 / _e116));
    let _e119 = st_2;
    return _e119;
}

fn ComputeIBLstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31vf3vf3_(pbrParam_1: ptr<function, PBRParam>, v_1: ptr<function, vec3<f32>>, n_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var mipCount_2: f32;
    var lod_2: f32;
    var brdf: vec3<f32>;
    var param_4: vec4<f32>;
    var diffuseLight: vec3<f32>;
    var param_5: vec3<f32>;
    var param_6: vec4<f32>;
    var specularLight: vec3<f32>;
    var param_7: vec3<f32>;
    var param_8: vec4<f32>;
    var diffuse: vec3<f32>;
    var specular: vec3<f32>;

    let _e114 = ubo.mipCount;
    mipCount_2 = _e114;
    let _e115 = mipCount_2;
    let _e117 = (*pbrParam_1).perceptualRoughness;
    lod_2 = (_e115 * _e117);
    let _e120 = (*pbrParam_1).NdotV;
    let _e122 = (*pbrParam_1).perceptualRoughness;
    let _e125 = textureSample(IBL_GGXLUT_Texture, IBL_GGXLUT_TextureSampler, vec2<f32>(_e120, (1.0 - _e122)));
    param_4 = _e125;
    let _e126 = SRGBtoLINEARvf4_((&param_4));
    brdf = _e126.xyz;
    let _e128 = (*n_1);
    param_5 = _e128;
    let _e129 = GetSphericalTexcoordvf3_((&param_5));
    let _e130 = textureSample(IBL_Diffuse_Texture, IBL_Diffuse_TextureSampler, _e129);
    param_6 = _e130;
    let _e131 = SRGBtoLINEARvf4_((&param_6));
    diffuseLight = _e131.xyz;
    let _e133 = (*v_1);
    let _e134 = (*n_1);
    param_7 = reflect(_e133, _e134);
    let _e136 = GetSphericalTexcoordvf3_((&param_7));
    let _e137 = lod_2;
    let _e138 = textureSampleLevel(IBL_Specular_Texture, IBL_Specular_TextureSampler, _e136, _e137);
    param_8 = _e138;
    let _e139 = SRGBtoLINEARvf4_((&param_8));
    specularLight = _e139.xyz;
    let _e141 = diffuseLight;
    let _e143 = (*pbrParam_1).diffuseColor;
    diffuse = (_e141 * _e143);
    let _e145 = specularLight;
    let _e147 = (*pbrParam_1).specularColor;
    let _e149 = brdf[0u];
    let _e152 = brdf[1u];
    specular = (_e145 * ((_e147 * _e149) + vec3<f32>(_e152)));
    let _e156 = specular;
    return _e156;
}

fn CalcDiffuseBRDFstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_(param_9: ptr<function, PBRParam>) -> vec3<f32> {
    var oneminus: f32;

    let _e101 = (*param_9).metallic;
    oneminus = (0.9599999785423279 - (_e101 * 0.9599999785423279));
    let _e105 = (*param_9).diffuseColor;
    let _e106 = oneminus;
    return (_e105 * _e106);
}

fn CalcFrenelReflectionstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_(param_10: ptr<function, PBRParam>) -> vec3<f32> {
    let _e100 = (*param_10).reflectance0_;
    let _e102 = (*param_10).reflectance90_;
    let _e104 = (*param_10).reflectance0_;
    let _e107 = (*param_10).VdotH;
    return (_e100 + ((_e102 - _e104) * pow(clamp((1.0 - _e107), 0.0, 1.0), 5.0)));
}

fn CalcGeometricOcculusionstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_(param_11: ptr<function, PBRParam>) -> f32 {
    var NdotL: f32;
    var NdotV: f32;
    var r: f32;
    var attenuationL: f32;
    var attenuationV: f32;

    let _e105 = (*param_11).NdotL;
    NdotL = _e105;
    let _e107 = (*param_11).NdotV;
    NdotV = _e107;
    let _e109 = (*param_11).alphaRoughness;
    r = _e109;
    let _e110 = NdotL;
    let _e112 = NdotL;
    let _e113 = r;
    let _e114 = r;
    let _e116 = r;
    let _e117 = r;
    let _e120 = NdotL;
    let _e121 = NdotL;
    attenuationL = ((2.0 * _e110) / (_e112 + sqrt(((_e113 * _e114) + ((1.0 - (_e116 * _e117)) * (_e120 * _e121))))));
    let _e128 = NdotV;
    let _e130 = NdotV;
    let _e131 = r;
    let _e132 = r;
    let _e134 = r;
    let _e135 = r;
    let _e138 = NdotV;
    let _e139 = NdotV;
    attenuationV = ((2.0 * _e128) / (_e130 + sqrt(((_e131 * _e132) + ((1.0 - (_e134 * _e135)) * (_e138 * _e139))))));
    let _e146 = attenuationL;
    let _e147 = attenuationV;
    return (_e146 * _e147);
}

fn CalcMicrofacetstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_(param_12: ptr<function, PBRParam>) -> f32 {
    var roughness2_: f32;
    var f: f32;

    let _e102 = (*param_12).alphaRoughness;
    let _e104 = (*param_12).alphaRoughness;
    roughness2_ = (_e102 * _e104);
    let _e107 = (*param_12).NdotH;
    let _e108 = roughness2_;
    let _e111 = (*param_12).NdotH;
    let _e114 = (*param_12).NdotH;
    f = ((((_e107 * _e108) - _e111) * _e114) + 1.0);
    let _e117 = roughness2_;
    let _e118 = f;
    let _e120 = f;
    return (_e117 / ((3.1415927410125732 * _e118) * _e120));
}

fn getNormal() -> vec3<f32> {
    var nomral_1: vec3<f32>;
    var t: vec3<f32>;
    var b: vec3<f32>;
    var n_2: vec3<f32>;
    var tbn: mat3x3<f32>;

    nomral_1 = vec3<f32>(0.0, 0.0, 0.0);
    let _e104 = ubo.useNormalTexture;
    if (_e104 != 0) {
        let _e106 = f_WorldTangent_1;
        t = normalize(_e106);
        let _e108 = f_WorldBioTangent_1;
        b = normalize(_e108);
        let _e110 = f_WorldNormal_1;
        n_2 = normalize(_e110);
        let _e112 = t;
        let _e113 = b;
        let _e114 = n_2;
        tbn = mat3x3<f32>(vec3<f32>(_e112.x, _e112.y, _e112.z), vec3<f32>(_e113.x, _e113.y, _e113.z), vec3<f32>(_e114.x, _e114.y, _e114.z));
        let _e128 = f_Texcoord_1;
        let _e129 = textureSample(normalTexture, normalTextureSampler, _e128);
        nomral_1 = _e129.xyz;
        let _e131 = tbn;
        let _e132 = nomral_1;
        let _e137 = ubo.normalMapScale;
        let _e139 = ubo.normalMapScale;
        nomral_1 = normalize((_e131 * (((_e132 * 2.0) - vec3<f32>(1.0)) * vec3<f32>(_e137, _e139, 1.0))));
    } else {
        let _e144 = f_WorldNormal_1;
        nomral_1 = _e144;
    }
    let _e145 = nomral_1;
    return _e145;
}

fn CalcSurface() -> vec4<f32> {
    var col: vec3<f32>;
    var perceptualRoughness: f32;
    var metallic: f32;
    var metallicRoughnessColor: vec4<f32>;
    var alphaRoughness: f32;
    var baseColor: vec4<f32>;
    var f0_: vec3<f32>;
    var diffuseColor: vec3<f32>;
    var specularColor: vec3<f32>;
    var reflectance: f32;
    var reflectance90_: f32;
    var specularEnvironmentR0_: vec3<f32>;
    var specularEnvironmentR90_: vec3<f32>;
    var n_3: vec3<f32>;
    var v_2: vec3<f32>;
    var l: vec3<f32>;
    var h: vec3<f32>;
    var reflection: vec3<f32>;
    var NdotL_1: f32;
    var NdotV_1: f32;
    var NdotH: f32;
    var LdotH: f32;
    var VdotH: f32;
    var pbrParam_2: PBRParam;
    var specular_1: vec3<f32>;
    var diffuse_1: vec3<f32>;
    var D: f32;
    var param_13: PBRParam;
    var G: f32;
    var param_14: PBRParam;
    var F: vec3<f32>;
    var param_15: PBRParam;
    var param_16: PBRParam;
    var param_17: PBRParam;
    var param_18: vec3<f32>;
    var param_19: vec3<f32>;
    var param_20: PBRParam;
    var param_21: vec3<f32>;
    var param_22: vec3<f32>;
    var gi_diffuse: vec3<f32>;
    var ao: f32;
    var emissive: vec3<f32>;
    var param_23: vec4<f32>;
    var lsp_1: vec3<f32>;
    var shadowCol: f32;
    var outSide: bool;
    var param_24: vec3<f32>;
    var param_25: vec3<f32>;
    var param_26: vec3<f32>;
    var alpha: f32;
    var result: vec4<f32>;
    var phi_877_: bool;
    var phi_983_: bool;
    var phi_990_: bool;
    var phi_1003_: bool;
    var phi_1010_: bool;
    var phi_1011_: bool;

    col = vec3<f32>(0.0, 0.0, 0.0);
    let _e150 = ubo.roughnessFactor;
    perceptualRoughness = _e150;
    let _e152 = ubo.metallicFactor;
    metallic = _e152;
    let _e154 = ubo.useMetallicRoughnessTexture;
    if (_e154 != 0) {
        let _e156 = f_Texcoord_1;
        let _e157 = textureSample(metallicRoughnessTexture, metallicRoughnessTextureSampler, _e156);
        metallicRoughnessColor = _e157;
        let _e158 = perceptualRoughness;
        let _e160 = metallicRoughnessColor[1u];
        perceptualRoughness = (_e158 * _e160);
        let _e162 = metallic;
        let _e164 = metallicRoughnessColor[2u];
        metallic = (_e162 * _e164);
    }
    let _e166 = perceptualRoughness;
    perceptualRoughness = clamp(_e166, 0.03999999910593033, 1.0);
    let _e168 = metallic;
    metallic = clamp(_e168, 0.0, 1.0);
    let _e170 = perceptualRoughness;
    let _e171 = perceptualRoughness;
    alphaRoughness = (_e170 * _e171);
    let _e174 = ubo.useBaseColorTexture;
    if (_e174 != 0) {
        let _e176 = f_Texcoord_1;
        let _e177 = textureSample(baseColorTexture, baseColorTextureSampler, _e176);
        baseColor = _e177;
    } else {
        let _e179 = ubo.baseColorFactor;
        baseColor = _e179;
    }
    f0_ = vec3<f32>(0.03999999910593033, 0.03999999910593033, 0.03999999910593033);
    let _e180 = baseColor;
    let _e182 = f0_;
    diffuseColor = (_e180.xyz * (vec3<f32>(1.0, 1.0, 1.0) - _e182));
    let _e185 = f0_;
    let _e186 = baseColor;
    let _e188 = metallic;
    specularColor = mix(_e185, _e186.xyz, vec3<f32>(_e188));
    let _e192 = specularColor[0u];
    let _e194 = specularColor[1u];
    let _e197 = specularColor[2u];
    reflectance = max(max(_e192, _e194), _e197);
    let _e199 = reflectance;
    reflectance90_ = clamp((_e199 * 25.0), 0.0, 1.0);
    let _e202 = specularColor;
    specularEnvironmentR0_ = _e202;
    let _e203 = reflectance90_;
    specularEnvironmentR90_ = (vec3<f32>(1.0, 1.0, 1.0) * _e203);
    let _e205 = getNormal();
    n_3 = _e205;
    let _e206 = f_WorldPos_1;
    let _e209 = ubo.cameraPos;
    v_2 = (normalize((_e206.xyz - _e209.xyz)) * -1.0);
    let _e215 = ubo.lightDir;
    l = (normalize(_e215.xyz) * -1.0);
    let _e219 = v_2;
    let _e220 = l;
    h = normalize((_e219 + _e220));
    let _e223 = v_2;
    let _e224 = n_3;
    reflection = normalize(reflect(_e223, _e224));
    let _e227 = n_3;
    let _e228 = l;
    NdotL_1 = clamp(dot(_e227, _e228), 0.0, 1.0);
    let _e231 = n_3;
    let _e232 = v_2;
    NdotV_1 = clamp(abs(dot(_e231, _e232)), 0.0, 1.0);
    let _e236 = n_3;
    let _e237 = h;
    NdotH = clamp(dot(_e236, _e237), 0.0, 1.0);
    let _e240 = l;
    let _e241 = h;
    LdotH = clamp(dot(_e240, _e241), 0.0, 1.0);
    let _e244 = v_2;
    let _e245 = h;
    VdotH = clamp(dot(_e244, _e245), 0.0, 1.0);
    let _e248 = NdotL_1;
    let _e249 = NdotV_1;
    let _e250 = NdotH;
    let _e251 = LdotH;
    let _e252 = VdotH;
    let _e253 = perceptualRoughness;
    let _e254 = metallic;
    let _e255 = specularEnvironmentR0_;
    let _e256 = specularEnvironmentR90_;
    let _e257 = alphaRoughness;
    let _e258 = diffuseColor;
    let _e259 = specularColor;
    pbrParam_2 = PBRParam(_e248, _e249, _e250, _e251, _e252, _e253, _e254, _e255, _e256, _e257, _e258, _e259);
    specular_1 = vec3<f32>(0.0, 0.0, 0.0);
    diffuse_1 = vec3<f32>(0.0, 0.0, 0.0);
    let _e261 = pbrParam_2;
    param_13 = _e261;
    let _e262 = CalcMicrofacetstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_((&param_13));
    D = _e262;
    let _e263 = pbrParam_2;
    param_14 = _e263;
    let _e264 = CalcGeometricOcculusionstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_((&param_14));
    G = _e264;
    let _e265 = pbrParam_2;
    param_15 = _e265;
    let _e266 = CalcFrenelReflectionstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_((&param_15));
    F = _e266;
    let _e267 = NdotL_1;
    let _e269 = NdotV_1;
    if ((_e267 > 0.0) || (_e269 > 0.0)) {
        let _e272 = D;
        let _e273 = G;
        let _e275 = F;
        let _e277 = NdotL_1;
        let _e279 = NdotV_1;
        let _e283 = specular_1;
        specular_1 = (_e283 + ((_e275 * (_e272 * _e273)) / vec3<f32>(((4.0 * _e277) * _e279))));
        let _e285 = specular_1;
        specular_1 = max(_e285, vec3<f32>(0.0, 0.0, 0.0));
        let _e287 = F;
        let _e290 = pbrParam_2;
        param_16 = _e290;
        let _e291 = CalcDiffuseBRDFstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_((&param_16));
        let _e293 = diffuse_1;
        diffuse_1 = (_e293 + ((vec3<f32>(1.0) - _e287) * _e291));
        let _e295 = NdotL_1;
        let _e296 = specular_1;
        let _e297 = diffuse_1;
        col = ((_e296 + _e297) * _e295);
    }
    let _e301 = ubo.useIBL;
    if (_e301 != 0) {
        let _e303 = pbrParam_2;
        param_17 = _e303;
        let _e304 = v_2;
        param_18 = _e304;
        let _e305 = n_3;
        param_19 = _e305;
        let _e306 = ComputeIBLstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31vf3vf3_((&param_17), (&param_18), (&param_19));
        let _e307 = col;
        col = (_e307 + _e306);
    } else {
        let _e310 = ubo.useCubeMap;
        let _e311 = (_e310 != 0);
        phi_877_ = _e311;
        if !(_e311) {
            let _e314 = ubo.useDirCubemap;
            phi_877_ = (_e314 != 0);
        }
        let _e317 = phi_877_;
        if _e317 {
            let _e318 = pbrParam_2;
            param_20 = _e318;
            let _e319 = v_2;
            param_21 = _e319;
            let _e320 = n_3;
            param_22 = _e320;
            let _e321 = ComputeReflectionColorstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31vf3vf3_((&param_20), (&param_21), (&param_22));
            let _e322 = F;
            let _e324 = col;
            col = (_e324 + (_e321 * _e322));
        } else {
            let _e327 = ubo.ambientColor;
            gi_diffuse = _e327.xyz;
            let _e329 = gi_diffuse;
            let _e330 = col;
            col = (_e330 + _e329);
        }
    }
    let _e333 = ubo.useOcclusionTexture;
    if (_e333 != 0) {
        let _e335 = f_Texcoord_1;
        let _e336 = textureSample(occlusionTexture, occlusionTextureSampler, _e335);
        ao = _e336.x;
        let _e338 = col;
        let _e339 = col;
        let _e340 = ao;
        let _e343 = ubo.occlusionStrength;
        col = mix(_e338, (_e339 * _e340), vec3<f32>(_e343));
    }
    let _e347 = ubo.emissiveFactor;
    let _e350 = ubo.emissiveStrength;
    emissive = (_e347.xyz * _e350);
    let _e353 = ubo.useEmissiveTexture;
    if (_e353 != 0) {
        let _e355 = f_Texcoord_1;
        let _e356 = textureSample(emissiveTexture, emissiveTextureSampler, _e355);
        param_23 = _e356;
        let _e357 = SRGBtoLINEARvf4_((&param_23));
        let _e359 = emissive;
        emissive = (_e359 * _e357.xyz);
    }
    let _e361 = emissive;
    let _e362 = col;
    col = (_e362 + _e361);
    let _e365 = ubo.useShadowMap;
    if (_e365 != 0) {
        let _e367 = f_LightSpacePos_1;
        let _e370 = f_LightSpacePos_1[3u];
        lsp_1 = (_e367.xyz / vec3<f32>(_e370));
        let _e373 = lsp_1;
        lsp_1 = ((_e373 * 0.5) + vec3<f32>(0.5));
        shadowCol = 1.0;
        let _e378 = lsp_1[0u];
        let _e379 = (_e378 < 0.0);
        phi_983_ = _e379;
        if !(_e379) {
            let _e382 = lsp_1[1u];
            phi_983_ = (_e382 < 0.0);
        }
        let _e385 = phi_983_;
        phi_990_ = _e385;
        if !(_e385) {
            let _e388 = lsp_1[2u];
            phi_990_ = (_e388 < 0.0);
        }
        let _e391 = phi_990_;
        phi_1011_ = _e391;
        if !(_e391) {
            let _e394 = lsp_1[0u];
            let _e395 = (_e394 > 1.0);
            phi_1003_ = _e395;
            if !(_e395) {
                let _e398 = lsp_1[1u];
                phi_1003_ = (_e398 > 1.0);
            }
            let _e401 = phi_1003_;
            phi_1010_ = _e401;
            if !(_e401) {
                let _e404 = lsp_1[2u];
                phi_1010_ = (_e404 > 1.0);
            }
            let _e407 = phi_1010_;
            phi_1011_ = _e407;
        }
        let _e409 = phi_1011_;
        outSide = _e409;
        let _e410 = outSide;
        if !(_e410) {
            let _e412 = lsp_1;
            param_24 = _e412;
            let _e413 = n_3;
            param_25 = _e413;
            let _e414 = l;
            param_26 = _e414;
            let _e415 = CalcShadowvf3vf3vf3_((&param_24), (&param_25), (&param_26));
            shadowCol = _e415;
        }
        let _e416 = shadowCol;
        let _e417 = col;
        col = (_e417 * _e416);
    }
    let _e419 = col;
    col = pow(_e419, vec3<f32>(0.4545454680919647, 0.4545454680919647, 0.4545454680919647));
    let _e422 = baseColor[3u];
    alpha = _e422;
    let _e423 = col;
    let _e424 = alpha;
    result = vec4<f32>(_e423.x, _e423.y, _e423.z, _e424);
    let _e429 = result;
    return _e429;
}

fn main_1() {
    var result_1: vec4<f32>;

    result_1 = vec4<f32>(0.0, 0.0, 0.0, 0.0);
    let _e99 = CalcSurface();
    result_1 = _e99;
    let _e100 = result_1;
    outColor = _e100;
    return;
}

@fragment 
fn main(@location(3) f_WorldTangent: vec3<f32>, @location(4) f_WorldBioTangent: vec3<f32>, @location(0) f_WorldNormal: vec3<f32>, @location(1) f_Texcoord: vec2<f32>, @location(2) f_WorldPos: vec4<f32>, @location(5) f_LightSpacePos: vec4<f32>) -> @location(0) vec4<f32> {
    f_WorldTangent_1 = f_WorldTangent;
    f_WorldBioTangent_1 = f_WorldBioTangent;
    f_WorldNormal_1 = f_WorldNormal;
    f_Texcoord_1 = f_Texcoord;
    f_WorldPos_1 = f_WorldPos;
    f_LightSpacePos_1 = f_LightSpacePos;
    main_1();
    let _e13 = outColor;
    return _e13;
}
