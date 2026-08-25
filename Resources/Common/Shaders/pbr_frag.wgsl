struct PBRData {
    Albedo: vec3<f32>,
    Metallic: f32,
    Roughness: f32,
    WorldNormal: vec3<f32>,
    WorldPos: vec3<f32>,
    ViewDir: vec3<f32>,
}

struct LightData {
    dir: vec3<f32>,
    color: vec3<f32>,
    attenuation: f32,
}

struct PBRParam {
    Albedo: vec3<f32>,
    Metallic: f32,
    Roughness: f32,
    NdH: f32,
    LdH: f32,
    NdL: f32,
    NdV: f32,
    VdH: f32,
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
@group(0) @binding(12) 
var cubemapTexture: texture_cube<f32>;
@group(0) @binding(13) 
var cubemapTextureSampler: sampler;
@group(0) @binding(22) 
var cubeMap2DTexture: texture_2d<f32>;
@group(0) @binding(23) 
var cubeMap2DTextureSampler: sampler;
@group(0) @binding(16) 
var IBL_Diffuse_Texture: texture_2d<f32>;
@group(0) @binding(17) 
var IBL_Diffuse_TextureSampler: sampler;
@group(0) @binding(18) 
var IBL_Specular_Texture: texture_2d<f32>;
@group(0) @binding(19) 
var IBL_Specular_TextureSampler: sampler;
@group(0) @binding(20) 
var IBL_GGXLUT_Texture: texture_2d<f32>;
@group(0) @binding(21) 
var IBL_GGXLUT_TextureSampler: sampler;
@group(0) @binding(2) 
var baseColorTexture: texture_2d<f32>;
@group(0) @binding(3) 
var baseColorTextureSampler: sampler;
var<private> f_Texcoord_1: vec2<f32>;
@group(0) @binding(4) 
var metallicRoughnessTexture: texture_2d<f32>;
@group(0) @binding(5) 
var metallicRoughnessTextureSampler: sampler;
var<private> f_WorldTangent_1: vec3<f32>;
var<private> f_WorldBioTangent_1: vec3<f32>;
var<private> f_WorldNormal_1: vec3<f32>;
@group(0) @binding(8) 
var normalTexture: texture_2d<f32>;
@group(0) @binding(9) 
var normalTextureSampler: sampler;
@group(0) @binding(6) 
var emissiveTexture: texture_2d<f32>;
@group(0) @binding(7) 
var emissiveTextureSampler: sampler;
var<private> f_WorldPos_1: vec4<f32>;
var<private> outColor: vec4<f32>;
var<private> f_LightSpacePos_1: vec4<f32>;
@group(0) @binding(10) 
var occlusionTexture: texture_2d<f32>;
@group(0) @binding(11) 
var occlusionTextureSampler: sampler;
@group(0) @binding(14) 
var shadowmapTexture: texture_2d<f32>;
@group(0) @binding(15) 
var shadowmapTextureSampler: sampler;

fn SRGBtoLINEAR_u0028_vf3_u003b(srgbIn: ptr<function, vec3<f32>>) -> vec3<f32> {
    let _e74 = (*srgbIn);
    return pow(_e74, vec3<f32>(2.2f, 2.2f, 2.2f));
}

fn CalcEmissive_u0028_() -> vec3<f32> {
    var emissive: vec3<f32>;
    var param: vec3<f32>;

    let _e76 = ubo.emissiveFactor;
    let _e79 = ubo.emissiveStrength;
    emissive = (_e76.xyz * _e79);
    let _e82 = ubo.useEmissiveTexture;
    if (_e82 != 0i) {
        let _e84 = f_Texcoord_1;
        let _e85 = textureSample(emissiveTexture, emissiveTextureSampler, _e84);
        param = _e85.xyz;
        let _e87 = SRGBtoLINEAR_u0028_vf3_u003b((&param));
        let _e88 = emissive;
        emissive = (_e88 * _e87);
    }
    let _e90 = emissive;
    return _e90;
}

fn CastDirToSt_u0028_vf3_u003b(Dir: ptr<function, vec3<f32>>) -> vec2<f32> {
    var theta: f32;
    var phi: f32;
    var st: vec2<f32>;

    let _e78 = (*Dir)[1u];
    theta = acos(_e78);
    let _e81 = (*Dir)[2u];
    let _e83 = (*Dir)[0u];
    phi = atan2(_e81, _e83);
    let _e85 = phi;
    let _e87 = theta;
    st = vec2<f32>((_e85 / 6.2831855f), (_e87 / 3.1415927f));
    let _e90 = st;
    return _e90;
}

fn CalcReflectionProbe_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b(pbr: ptr<function, PBRData>) -> vec3<f32> {
    var v: vec3<f32>;
    var reflectV: vec3<f32>;
    var reflectColor: vec3<f32>;
    var mipCount: f32;
    var lod: f32;
    var param_1: vec3<f32>;
    var st_1: vec2<f32>;
    var param_2: vec3<f32>;
    var mipCount_1: f32;
    var lod_1: f32;
    var param_3: vec3<f32>;

    let _e86 = (*pbr).ViewDir;
    v = normalize(_e86);
    let _e88 = v;
    let _e90 = (*pbr).WorldNormal;
    reflectV = reflect(_e88, _e90);
    reflectColor = vec3<f32>(0f, 0f, 0f);
    let _e93 = ubo.useCubeMap;
    if (_e93 != 0i) {
        let _e96 = ubo.mipCount;
        mipCount = _e96;
        let _e97 = mipCount;
        let _e99 = (*pbr).Roughness;
        lod = (_e97 * _e99);
        let _e101 = reflectV;
        let _e102 = lod;
        let _e103 = textureSampleLevel(cubemapTexture, cubemapTextureSampler, _e101, _e102);
        param_1 = _e103.xyz;
        let _e105 = SRGBtoLINEAR_u0028_vf3_u003b((&param_1));
        reflectColor = _e105;
    } else {
        let _e107 = ubo.useDirCubemap;
        if (_e107 != 0i) {
            let _e109 = reflectV;
            param_2 = _e109;
            let _e110 = CastDirToSt_u0028_vf3_u003b((&param_2));
            st_1 = _e110;
            let _e112 = ubo.mipCount;
            mipCount_1 = _e112;
            let _e113 = mipCount_1;
            let _e115 = (*pbr).Roughness;
            lod_1 = (_e113 * _e115);
            let _e117 = st_1;
            let _e118 = lod_1;
            let _e119 = textureSampleLevel(cubeMap2DTexture, cubeMap2DTextureSampler, _e117, _e118);
            param_3 = _e119.xyz;
            let _e121 = SRGBtoLINEAR_u0028_vf3_u003b((&param_3));
            reflectColor = _e121;
        }
    }
    let _e122 = reflectColor;
    return _e122;
}

fn GetSphericalTexcoord_u0028_vf3_u003b(Dir_1: ptr<function, vec3<f32>>) -> vec2<f32> {
    var theta_1: f32;
    var phi_1: f32;
    var st_2: vec2<f32>;

    let _e78 = (*Dir_1)[1u];
    theta_1 = acos(_e78);
    let _e81 = (*Dir_1)[2u];
    let _e83 = (*Dir_1)[0u];
    phi_1 = atan2(_e81, _e83);
    let _e85 = phi_1;
    let _e87 = theta_1;
    st_2 = vec2<f32>((_e85 / 6.2831855f), (_e87 / 3.1415927f));
    let _e90 = st_2;
    return _e90;
}

fn GetIndirectDiffuse_u0028_vf3_u003b(n: ptr<function, vec3<f32>>) -> vec3<f32> {
    var diffuseLight: vec3<f32>;
    var param_4: vec3<f32>;

    let _e76 = (*n);
    param_4 = _e76;
    let _e77 = GetSphericalTexcoord_u0028_vf3_u003b((&param_4));
    let _e78 = textureSample(IBL_Diffuse_Texture, IBL_Diffuse_TextureSampler, _e77);
    diffuseLight = _e78.xyz;
    let _e80 = diffuseLight;
    return _e80;
}

fn GetGGXRadiance_u0028_vf3_u003b_vf3_u003b_f1_u003b_f1_u003b(n_1: ptr<function, vec3<f32>>, v_1: ptr<function, vec3<f32>>, roughenss: ptr<function, f32>, mipCount_2: ptr<function, f32>) -> vec3<f32> {
    var lod_2: f32;
    var specularLight: vec3<f32>;
    var param_5: vec3<f32>;

    let _e80 = (*mipCount_2);
    let _e81 = (*roughenss);
    lod_2 = (_e80 * _e81);
    let _e83 = (*v_1);
    let _e84 = (*n_1);
    param_5 = reflect(_e83, _e84);
    let _e86 = GetSphericalTexcoord_u0028_vf3_u003b((&param_5));
    let _e87 = lod_2;
    let _e88 = textureSampleLevel(IBL_Specular_Texture, IBL_Specular_TextureSampler, _e86, _e87);
    specularLight = _e88.xyz;
    let _e90 = specularLight;
    return _e90;
}

fn GetSpecularBRDF_u0028_f1_u003b_f1_u003b_vf3_u003b(NdV: ptr<function, f32>, roughenss_1: ptr<function, f32>, F0_: ptr<function, vec3<f32>>) -> vec3<f32> {
    var uv: vec2<f32>;
    var brdf: vec3<f32>;
    var F: vec3<f32>;

    let _e79 = (*NdV);
    let _e80 = (*roughenss_1);
    uv = vec2<f32>(_e79, _e80);
    let _e82 = uv;
    let _e83 = textureSample(IBL_GGXLUT_Texture, IBL_GGXLUT_TextureSampler, _e82);
    brdf = _e83.xyz;
    let _e85 = (*F0_);
    let _e86 = (*F0_);
    let _e89 = (*NdV);
    F = (_e85 + ((vec3(1f) - _e86) * pow((1f - _e89), 5f)));
    let _e94 = F;
    let _e96 = brdf[0u];
    let _e99 = brdf[1u];
    return ((_e94 * _e96) + vec3(_e99));
}

fn ComputeIBL_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b(pbr_1: ptr<function, PBRData>) -> vec3<f32> {
    var n_2: vec3<f32>;
    var v_2: vec3<f32>;
    var NdV_1: f32;
    var metal_fresnel: vec3<f32>;
    var param_6: f32;
    var param_7: f32;
    var param_8: vec3<f32>;
    var metal_specularBRDF: vec3<f32>;
    var param_9: vec3<f32>;
    var param_10: vec3<f32>;
    var param_11: f32;
    var param_12: f32;
    var metal_specular_color: vec3<f32>;
    var dielectric_fresnel: vec3<f32>;
    var param_13: f32;
    var param_14: f32;
    var param_15: vec3<f32>;
    var dielectric_diffuse: vec3<f32>;
    var param_16: vec3<f32>;
    var dielectric_specularBRDF: vec3<f32>;
    var param_17: vec3<f32>;
    var param_18: vec3<f32>;
    var param_19: f32;
    var param_20: f32;
    var dielectric_color: vec3<f32>;
    var finalColor: vec3<f32>;

    let _e101 = (*pbr_1).WorldNormal;
    n_2 = normalize(_e101);
    let _e104 = (*pbr_1).ViewDir;
    v_2 = normalize(-(_e104));
    let _e107 = n_2;
    let _e108 = v_2;
    NdV_1 = clamp(dot(_e107, _e108), 0f, 1f);
    let _e111 = NdV_1;
    param_6 = _e111;
    let _e113 = (*pbr_1).Roughness;
    param_7 = _e113;
    let _e115 = (*pbr_1).Albedo;
    param_8 = _e115;
    let _e116 = GetSpecularBRDF_u0028_f1_u003b_f1_u003b_vf3_u003b((&param_6), (&param_7), (&param_8));
    metal_fresnel = _e116;
    let _e117 = n_2;
    param_9 = _e117;
    let _e118 = v_2;
    param_10 = _e118;
    let _e120 = (*pbr_1).Roughness;
    param_11 = _e120;
    let _e122 = ubo.mipCount;
    param_12 = _e122;
    let _e123 = GetGGXRadiance_u0028_vf3_u003b_vf3_u003b_f1_u003b_f1_u003b((&param_9), (&param_10), (&param_11), (&param_12));
    metal_specularBRDF = _e123;
    let _e124 = metal_fresnel;
    let _e125 = metal_specularBRDF;
    metal_specular_color = (_e124 * _e125);
    let _e127 = NdV_1;
    param_13 = _e127;
    let _e129 = (*pbr_1).Roughness;
    param_14 = _e129;
    param_15 = vec3<f32>(0.04f, 0.04f, 0.04f);
    let _e130 = GetSpecularBRDF_u0028_f1_u003b_f1_u003b_vf3_u003b((&param_13), (&param_14), (&param_15));
    dielectric_fresnel = _e130;
    let _e131 = n_2;
    param_16 = _e131;
    let _e132 = GetIndirectDiffuse_u0028_vf3_u003b((&param_16));
    let _e134 = (*pbr_1).Albedo;
    dielectric_diffuse = (_e132 * _e134);
    let _e136 = n_2;
    param_17 = _e136;
    let _e137 = v_2;
    param_18 = _e137;
    let _e139 = (*pbr_1).Roughness;
    param_19 = _e139;
    let _e141 = ubo.mipCount;
    param_20 = _e141;
    let _e142 = GetGGXRadiance_u0028_vf3_u003b_vf3_u003b_f1_u003b_f1_u003b((&param_17), (&param_18), (&param_19), (&param_20));
    dielectric_specularBRDF = _e142;
    let _e143 = dielectric_diffuse;
    let _e144 = dielectric_specularBRDF;
    let _e145 = dielectric_fresnel;
    dielectric_color = mix(_e143, _e144, _e145);
    let _e147 = dielectric_color;
    let _e148 = metal_specular_color;
    let _e150 = (*pbr_1).Metallic;
    finalColor = mix(_e147, _e148, vec3(_e150));
    let _e153 = finalColor;
    finalColor = clamp(_e153, vec3<f32>(0f, 0f, 0f), vec3<f32>(3f, 3f, 3f));
    let _e155 = finalColor;
    return _e155;
}

fn ComputeIndirectLight_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b(pbr_2: ptr<function, PBRData>) -> vec3<f32> {
    var ResultCol: vec3<f32>;
    var param_21: PBRData;
    var param_22: PBRData;
    var gi_diffuse: vec3<f32>;
    var n_3: vec3<f32>;
    var v_3: vec3<f32>;
    var NdV_2: f32;
    var phi_669_: bool;

    ResultCol = vec3<f32>(0f, 0f, 0f);
    let _e82 = ubo.useIBL;
    if (_e82 != 0i) {
        let _e84 = (*pbr_2);
        param_21 = _e84;
        let _e85 = ComputeIBL_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b((&param_21));
        let _e86 = ResultCol;
        ResultCol = (_e86 + _e85);
    } else {
        let _e89 = ubo.useCubeMap;
        let _e90 = (_e89 != 0i);
        phi_669_ = _e90;
        if !(_e90) {
            let _e93 = ubo.useDirCubemap;
            phi_669_ = (_e93 != 0i);
        }
        let _e96 = phi_669_;
        if _e96 {
            let _e97 = (*pbr_2);
            param_22 = _e97;
            let _e98 = CalcReflectionProbe_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b((&param_22));
            let _e99 = ResultCol;
            ResultCol = (_e99 + _e98);
        } else {
            let _e102 = ubo.ambientColor;
            gi_diffuse = _e102.xyz;
            let _e104 = gi_diffuse;
            let _e105 = ResultCol;
            ResultCol = (_e105 + _e104);
        }
    }
    let _e108 = (*pbr_2).WorldNormal;
    n_3 = normalize(_e108);
    let _e111 = (*pbr_2).ViewDir;
    v_3 = normalize(-(_e111));
    let _e114 = n_3;
    let _e115 = v_3;
    NdV_2 = clamp(dot(_e114, _e115), 0f, 1f);
    let _e118 = ResultCol;
    return _e118;
}

fn CalcFrenelReflection_u0028_vf3_u003b_f1_u003b_f1_u003b(Albedo: ptr<function, vec3<f32>>, Metallic: ptr<function, f32>, NdV_3: ptr<function, f32>) -> vec3<f32> {
    var F0_1: vec3<f32>;

    let _e77 = (*Albedo);
    let _e78 = (*Metallic);
    F0_1 = mix(vec3<f32>(0.04f, 0.04f, 0.04f), _e77, vec3(_e78));
    let _e81 = F0_1;
    let _e82 = F0_1;
    let _e85 = (*NdV_3);
    return (_e81 + ((vec3(1f) - _e82) * pow((1f - _e85), 5f)));
}

fn CalcGeometricOcculusion_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b(param_23: ptr<function, PBRParam>) -> f32 {
    var k: f32;
    var attenuationL: f32;
    var attenuationV: f32;

    let _e78 = (*param_23).Roughness;
    k = _e78;
    let _e80 = (*param_23).NdV;
    let _e82 = (*param_23).NdV;
    let _e83 = k;
    let _e86 = k;
    attenuationL = (_e80 / ((_e82 * (1f - _e83)) + _e86));
    let _e90 = (*param_23).NdL;
    let _e92 = (*param_23).NdL;
    let _e93 = k;
    let _e96 = k;
    attenuationV = (_e90 / ((_e92 * (1f - _e93)) + _e96));
    let _e99 = attenuationL;
    let _e100 = attenuationV;
    return (_e99 * _e100);
}

fn CalcMicrofacet_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b(param_24: ptr<function, PBRParam>) -> f32 {
    var r: f32;
    var a: f32;
    var a2_: f32;
    var f: f32;

    let _e79 = (*param_24).Roughness;
    r = _e79;
    let _e80 = r;
    a = _e80;
    let _e81 = a;
    let _e82 = a;
    a2_ = max(0.001f, (_e81 * _e82));
    let _e86 = (*param_24).NdH;
    let _e88 = a2_;
    f = ((pow(_e86, 2f) * (_e88 - 1f)) + 1f);
    let _e92 = a2_;
    let _e93 = f;
    let _e95 = f;
    return (_e92 / ((3.1415927f * _e93) * _e95));
}

fn CalcSpecularBRDF_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b(param_25: ptr<function, PBRParam>) -> vec3<f32> {
    var D: f32;
    var param_26: PBRParam;
    var G: f32;
    var param_27: PBRParam;
    var F_1: vec3<f32>;
    var param_28: vec3<f32>;
    var param_29: f32;
    var param_30: f32;
    var spec: vec3<f32>;

    let _e83 = (*param_25);
    param_26 = _e83;
    let _e84 = CalcMicrofacet_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b((&param_26));
    D = _e84;
    let _e85 = (*param_25);
    param_27 = _e85;
    let _e86 = CalcGeometricOcculusion_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b((&param_27));
    G = _e86;
    let _e88 = (*param_25).Albedo;
    param_28 = _e88;
    let _e90 = (*param_25).Metallic;
    param_29 = _e90;
    let _e92 = (*param_25).NdV;
    param_30 = _e92;
    let _e93 = CalcFrenelReflection_u0028_vf3_u003b_f1_u003b_f1_u003b((&param_28), (&param_29), (&param_30));
    F_1 = _e93;
    let _e94 = D;
    let _e95 = G;
    let _e97 = F_1;
    let _e100 = (*param_25).NdV;
    let _e103 = (*param_25).NdL;
    spec = ((_e97 * (_e94 * _e95)) / vec3(((4f * _e100) * _e103)));
    let _e108 = spec[0u];
    spec[0u] = max(0f, _e108);
    let _e112 = spec[1u];
    spec[1u] = max(0f, _e112);
    let _e116 = spec[2u];
    spec[2u] = max(0f, _e116);
    let _e119 = spec;
    return _e119;
}

fn CalcDiffuseBRDF_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b(pbr_3: ptr<function, PBRData>) -> vec3<f32> {
    var OneMinusReflectivity: f32;
    var col: vec3<f32>;

    let _e77 = (*pbr_3).Metallic;
    OneMinusReflectivity = (0.96f - (_e77 * 0.96f));
    let _e81 = (*pbr_3).Albedo;
    let _e82 = OneMinusReflectivity;
    col = (_e81 * _e82);
    let _e85 = col[0u];
    col[0u] = max(0f, _e85);
    let _e89 = col[1u];
    col[1u] = max(0f, _e89);
    let _e93 = col[2u];
    col[2u] = max(0f, _e93);
    let _e96 = col;
    return _e96;
}

fn CreatePBRParam_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b_struct_u002d_LightData_u002d_vf3_u002d_vf3_u002d_f11_u003b(pbr_4: ptr<function, PBRData>, light: ptr<function, LightData>) -> PBRParam {
    var l: vec3<f32>;
    var v_4: vec3<f32>;
    var n_4: vec3<f32>;
    var h: vec3<f32>;
    var NdH: f32;
    var LdH: f32;
    var NdL: f32;
    var NdV_4: f32;
    var VdH: f32;
    var param_31: PBRParam;

    let _e86 = (*light).dir;
    l = normalize(-(_e86));
    let _e90 = (*pbr_4).ViewDir;
    v_4 = normalize(-(_e90));
    let _e94 = (*pbr_4).WorldNormal;
    n_4 = normalize(_e94);
    let _e96 = l;
    let _e97 = v_4;
    h = normalize((_e96 + _e97));
    let _e100 = n_4;
    let _e101 = h;
    NdH = clamp(dot(_e100, _e101), 0f, 1f);
    let _e104 = l;
    let _e105 = h;
    LdH = clamp(dot(_e104, _e105), 0f, 1f);
    let _e108 = n_4;
    let _e109 = l;
    NdL = clamp(dot(_e108, _e109), 0f, 1f);
    let _e112 = n_4;
    let _e113 = v_4;
    NdV_4 = clamp(dot(_e112, _e113), 0f, 1f);
    let _e116 = v_4;
    let _e117 = h;
    VdH = clamp(dot(_e116, _e117), 0f, 1f);
    let _e121 = (*pbr_4).Albedo;
    param_31.Albedo = _e121;
    let _e124 = (*pbr_4).Metallic;
    param_31.Metallic = _e124;
    let _e127 = (*pbr_4).Roughness;
    param_31.Roughness = max(0.04f, _e127);
    let _e130 = NdH;
    param_31.NdH = _e130;
    let _e132 = LdH;
    param_31.LdH = _e132;
    let _e134 = NdL;
    param_31.NdL = _e134;
    let _e136 = NdV_4;
    param_31.NdV = _e136;
    let _e138 = VdH;
    param_31.VdH = _e138;
    let _e140 = param_31;
    return _e140;
}

fn ComputeDirectLight_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b_struct_u002d_LightData_u002d_vf3_u002d_vf3_u002d_f11_u003b(pbr_5: ptr<function, PBRData>, light_1: ptr<function, LightData>) -> vec3<f32> {
    var param_32: PBRParam;
    var param_33: PBRData;
    var param_34: LightData;
    var DiffuseCol: vec3<f32>;
    var param_35: PBRData;
    var SpecularCol: vec3<f32>;
    var param_36: PBRParam;
    var ResultCol_1: vec3<f32>;

    let _e83 = (*pbr_5);
    param_33 = _e83;
    let _e84 = (*light_1);
    param_34 = _e84;
    let _e85 = CreatePBRParam_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b_struct_u002d_LightData_u002d_vf3_u002d_vf3_u002d_f11_u003b((&param_33), (&param_34));
    param_32 = _e85;
    let _e86 = (*pbr_5);
    param_35 = _e86;
    let _e87 = CalcDiffuseBRDF_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b((&param_35));
    DiffuseCol = _e87;
    let _e88 = param_32;
    param_36 = _e88;
    let _e89 = CalcSpecularBRDF_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b((&param_36));
    SpecularCol = _e89;
    let _e91 = param_32.NdL;
    let _e92 = DiffuseCol;
    let _e93 = SpecularCol;
    let _e97 = (*light_1).color;
    let _e100 = (*light_1).attenuation;
    ResultCol_1 = ((((_e92 + _e93) * _e91) * _e97) * _e100);
    let _e102 = ResultCol_1;
    return _e102;
}

fn CalcNormal_u0028_() -> vec3<f32> {
    var nomral: vec3<f32>;
    var t: vec3<f32>;
    var b: vec3<f32>;
    var n_5: vec3<f32>;
    var tbn: mat3x3<f32>;

    nomral = vec3<f32>(0f, 0f, 0f);
    let _e79 = ubo.useNormalTexture;
    if (_e79 != 0i) {
        let _e81 = f_WorldTangent_1;
        t = normalize(_e81);
        let _e83 = f_WorldBioTangent_1;
        b = normalize(_e83);
        let _e85 = f_WorldNormal_1;
        n_5 = normalize(_e85);
        let _e87 = t;
        let _e88 = b;
        let _e89 = n_5;
        tbn = mat3x3<f32>(vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e89.x, _e89.y, _e89.z));
        let _e103 = f_Texcoord_1;
        let _e104 = textureSample(normalTexture, normalTextureSampler, _e103);
        nomral = _e104.xyz;
        let _e106 = tbn;
        let _e107 = nomral;
        let _e112 = ubo.normalMapScale;
        let _e114 = ubo.normalMapScale;
        nomral = normalize((_e106 * (((_e107 * 2f) - vec3(1f)) * vec3<f32>(_e112, _e114, 1f))));
    } else {
        let _e119 = f_WorldNormal_1;
        nomral = _e119;
    }
    let _e120 = nomral;
    return _e120;
}

fn CalcMetallicRoughness_u0028_() -> vec2<f32> {
    var metallic: f32;
    var roughness: f32;
    var metallicRoughnessColor: vec4<f32>;

    let _e77 = ubo.metallicFactor;
    metallic = _e77;
    let _e79 = ubo.roughnessFactor;
    roughness = _e79;
    let _e81 = ubo.useMetallicRoughnessTexture;
    if (_e81 != 0i) {
        let _e83 = f_Texcoord_1;
        let _e84 = textureSample(metallicRoughnessTexture, metallicRoughnessTextureSampler, _e83);
        metallicRoughnessColor = _e84;
        let _e85 = roughness;
        let _e87 = metallicRoughnessColor[1u];
        roughness = (_e85 * _e87);
        let _e89 = metallic;
        let _e91 = metallicRoughnessColor[2u];
        metallic = (_e89 * _e91);
    }
    let _e93 = metallic;
    let _e94 = roughness;
    return vec2<f32>(_e93, _e94);
}

fn CalcBaseColor_u0028_() -> vec4<f32> {
    var baseColor: vec4<f32>;
    var param_37: vec3<f32>;

    let _e76 = ubo.useBaseColorTexture;
    if (_e76 != 0i) {
        let _e78 = f_Texcoord_1;
        let _e79 = textureSample(baseColorTexture, baseColorTextureSampler, _e78);
        baseColor = _e79;
        let _e80 = baseColor;
        param_37 = _e80.xyz;
        let _e82 = SRGBtoLINEAR_u0028_vf3_u003b((&param_37));
        baseColor[0u] = _e82.x;
        baseColor[1u] = _e82.y;
        baseColor[2u] = _e82.z;
    } else {
        let _e90 = ubo.baseColorFactor;
        baseColor = _e90;
    }
    let _e91 = baseColor;
    return _e91;
}

fn main_1() {
    var col_1: vec4<f32>;
    var baseColor_1: vec4<f32>;
    var MetallicRoughness: vec2<f32>;
    var Normal: vec3<f32>;
    var pbr_6: PBRData;
    var light_2: LightData;
    var param_38: PBRData;
    var param_39: LightData;
    var param_40: PBRData;

    col_1 = vec4<f32>(0f, 0f, 0f, 1f);
    let _e82 = CalcBaseColor_u0028_();
    baseColor_1 = _e82;
    let _e83 = CalcMetallicRoughness_u0028_();
    MetallicRoughness = _e83;
    let _e84 = CalcNormal_u0028_();
    Normal = _e84;
    let _e85 = baseColor_1;
    pbr_6.Albedo = _e85.xyz;
    let _e89 = MetallicRoughness[0u];
    pbr_6.Metallic = _e89;
    let _e92 = MetallicRoughness[1u];
    pbr_6.Roughness = _e92;
    let _e94 = Normal;
    pbr_6.WorldNormal = _e94;
    let _e96 = f_WorldPos_1;
    let _e99 = ubo.cameraPos;
    pbr_6.ViewDir = normalize((_e96.xyz - _e99.xyz));
    let _e105 = ubo.lightDir;
    light_2.dir = _e105.xyz;
    let _e109 = ubo.lightColor;
    light_2.color = _e109.xyz;
    light_2.attenuation = 1f;
    let _e113 = pbr_6;
    param_38 = _e113;
    let _e114 = light_2;
    param_39 = _e114;
    let _e115 = ComputeDirectLight_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b_struct_u002d_LightData_u002d_vf3_u002d_vf3_u002d_f11_u003b((&param_38), (&param_39));
    let _e116 = col_1;
    let _e118 = (_e116.xyz + _e115);
    col_1[0u] = _e118.x;
    col_1[1u] = _e118.y;
    col_1[2u] = _e118.z;
    let _e125 = pbr_6;
    param_40 = _e125;
    let _e126 = ComputeIndirectLight_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b((&param_40));
    let _e127 = col_1;
    let _e129 = (_e127.xyz + _e126);
    col_1[0u] = _e129.x;
    col_1[1u] = _e129.y;
    col_1[2u] = _e129.z;
    let _e136 = CalcEmissive_u0028_();
    let _e137 = col_1;
    let _e139 = (_e137.xyz + _e136);
    col_1[0u] = _e139.x;
    col_1[1u] = _e139.y;
    col_1[2u] = _e139.z;
    let _e146 = col_1;
    outColor = _e146;
    return;
}

@fragment 
fn main(@location(1) f_Texcoord: vec2<f32>, @location(3) f_WorldTangent: vec3<f32>, @location(4) f_WorldBioTangent: vec3<f32>, @location(0) f_WorldNormal: vec3<f32>, @location(2) f_WorldPos: vec4<f32>, @location(5) f_LightSpacePos: vec4<f32>) -> @location(0) vec4<f32> {
    f_Texcoord_1 = f_Texcoord;
    f_WorldTangent_1 = f_WorldTangent;
    f_WorldBioTangent_1 = f_WorldBioTangent;
    f_WorldNormal_1 = f_WorldNormal;
    f_WorldPos_1 = f_WorldPos;
    f_LightSpacePos_1 = f_LightSpacePos;
    main_1();
    let _e13 = outColor;
    return _e13;
}
