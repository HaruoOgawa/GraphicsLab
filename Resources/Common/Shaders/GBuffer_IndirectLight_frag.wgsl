struct GBufferResult {
    worldPos: vec3<f32>,
    worldNormal: vec3<f32>,
    albedo: vec4<f32>,
    depth: f32,
    materialType: f32,
    metallicRoughness: vec2<f32>,
    emissive: vec3<f32>,
}

struct PBRData {
    Albedo: vec3<f32>,
    Metallic: f32,
    Roughness: f32,
    WorldNormal: vec3<f32>,
    WorldPos: vec3<f32>,
    ViewDir: vec3<f32>,
}

struct LightUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    useIBL: i32,
    useCubeMap: i32,
    useDirCubemap: i32,
    iPad2_: i32,
    mipCount: f32,
    fPad0_: f32,
    fPad1_: f32,
    fPad2_: f32,
    ambientColor: vec4<f32>,
    cameraPos: vec4<f32>,
}

@group(0) @binding(2) 
var gPositionTexture: texture_2d<f32>;
@group(0) @binding(3) 
var gPositionTextureSampler: sampler;
@group(0) @binding(4) 
var gNormalTexture: texture_2d<f32>;
@group(0) @binding(5) 
var gNormalTextureSampler: sampler;
@group(0) @binding(6) 
var gAlbedoTexture: texture_2d<f32>;
@group(0) @binding(7) 
var gAlbedoTextureSampler: sampler;
@group(0) @binding(8) 
var gDepthTexture: texture_2d<f32>;
@group(0) @binding(9) 
var gDepthTextureSampler: sampler;
@group(0) @binding(10) 
var gCustomParam0Texture: texture_2d<f32>;
@group(0) @binding(11) 
var gCustomParam0TextureSampler: sampler;
@group(0) @binding(12) 
var gEmissionTexture: texture_2d<f32>;
@group(0) @binding(13) 
var gEmissionTextureSampler: sampler;
@group(0) @binding(22) 
var gDirectLightTexture: texture_2d<f32>;
@group(0) @binding(23) 
var gDirectLightTextureSampler: sampler;
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
@group(0) @binding(1) 
var<uniform> l_ubo: LightUniformBuffer;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_UV_1: vec2<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;
@group(0) @binding(14) 
var gVelocityTexture: texture_2d<f32>;
@group(0) @binding(15) 
var gVelocityTextureSampler: sampler;
@group(0) @binding(24) 
var gSSAOBlurTexture: texture_2d<f32>;
@group(0) @binding(25) 
var gSSAOBlurTextureSampler: sampler;

fn GetDirectLight_u0028_vf2_u003b(ScreenUV: ptr<function, vec2<f32>>) -> vec3<f32> {
    var DirectLight: vec3<f32>;

    let _e56 = (*ScreenUV);
    let _e57 = textureSample(gDirectLightTexture, gDirectLightTextureSampler, _e56);
    DirectLight = _e57.xyz;
    let _e59 = DirectLight;
    return _e59;
}

fn GetSphericalTexcoord_u0028_vf3_u003b(Dir: ptr<function, vec3<f32>>) -> vec2<f32> {
    var theta: f32;
    var phi: f32;
    var st: vec2<f32>;

    let _e59 = (*Dir)[1u];
    theta = acos(_e59);
    let _e62 = (*Dir)[2u];
    let _e64 = (*Dir)[0u];
    phi = atan2(_e62, _e64);
    let _e66 = phi;
    let _e68 = theta;
    st = vec2<f32>((_e66 / 6.2831855f), (_e68 / 3.1415927f));
    let _e71 = st;
    return _e71;
}

fn GetIndirectDiffuse_u0028_vf3_u003b(n: ptr<function, vec3<f32>>) -> vec3<f32> {
    var diffuseLight: vec3<f32>;
    var param: vec3<f32>;

    let _e57 = (*n);
    param = _e57;
    let _e58 = GetSphericalTexcoord_u0028_vf3_u003b((&param));
    let _e59 = textureSample(IBL_Diffuse_Texture, IBL_Diffuse_TextureSampler, _e58);
    diffuseLight = _e59.xyz;
    let _e61 = diffuseLight;
    return _e61;
}

fn GetGGXRadiance_u0028_vf3_u003b_vf3_u003b_f1_u003b_f1_u003b(n_1: ptr<function, vec3<f32>>, v: ptr<function, vec3<f32>>, roughenss: ptr<function, f32>, mipCount: ptr<function, f32>) -> vec3<f32> {
    var lod: f32;
    var specularLight: vec3<f32>;
    var param_1: vec3<f32>;

    let _e61 = (*mipCount);
    let _e62 = (*roughenss);
    lod = (_e61 * _e62);
    let _e64 = (*v);
    let _e65 = (*n_1);
    param_1 = reflect(_e64, _e65);
    let _e67 = GetSphericalTexcoord_u0028_vf3_u003b((&param_1));
    let _e68 = lod;
    let _e69 = textureSampleLevel(IBL_Specular_Texture, IBL_Specular_TextureSampler, _e67, _e68);
    specularLight = _e69.xyz;
    let _e71 = specularLight;
    return _e71;
}

fn GetSpecularBRDF_u0028_f1_u003b_f1_u003b_vf3_u003b(NdV: ptr<function, f32>, roughenss_1: ptr<function, f32>, F0_: ptr<function, vec3<f32>>) -> vec3<f32> {
    var uv: vec2<f32>;
    var brdf: vec3<f32>;
    var F: vec3<f32>;

    let _e60 = (*NdV);
    let _e61 = (*roughenss_1);
    uv = vec2<f32>(_e60, _e61);
    let _e63 = uv;
    let _e64 = textureSample(IBL_GGXLUT_Texture, IBL_GGXLUT_TextureSampler, _e63);
    brdf = _e64.xyz;
    let _e66 = (*F0_);
    let _e67 = (*F0_);
    let _e70 = (*NdV);
    F = (_e66 + ((vec3(1f) - _e67) * pow((1f - _e70), 5f)));
    let _e75 = F;
    let _e77 = brdf[0u];
    let _e80 = brdf[1u];
    return ((_e75 * _e77) + vec3(_e80));
}

fn ComputeIBL_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b(pbr: ptr<function, PBRData>) -> vec3<f32> {
    var n_2: vec3<f32>;
    var v_1: vec3<f32>;
    var NdV_1: f32;
    var metal_fresnel: vec3<f32>;
    var param_2: f32;
    var param_3: f32;
    var param_4: vec3<f32>;
    var metal_specularBRDF: vec3<f32>;
    var param_5: vec3<f32>;
    var param_6: vec3<f32>;
    var param_7: f32;
    var param_8: f32;
    var metal_specular_color: vec3<f32>;
    var dielectric_fresnel: vec3<f32>;
    var param_9: f32;
    var param_10: f32;
    var param_11: vec3<f32>;
    var dielectric_diffuse: vec3<f32>;
    var param_12: vec3<f32>;
    var dielectric_specularBRDF: vec3<f32>;
    var param_13: vec3<f32>;
    var param_14: vec3<f32>;
    var param_15: f32;
    var param_16: f32;
    var dielectric_color: vec3<f32>;
    var finalColor: vec3<f32>;

    let _e82 = (*pbr).WorldNormal;
    n_2 = normalize(_e82);
    let _e85 = (*pbr).ViewDir;
    v_1 = normalize(-(_e85));
    let _e88 = n_2;
    let _e89 = v_1;
    NdV_1 = clamp(dot(_e88, _e89), 0f, 1f);
    let _e92 = NdV_1;
    param_2 = _e92;
    let _e94 = (*pbr).Roughness;
    param_3 = _e94;
    let _e96 = (*pbr).Albedo;
    param_4 = _e96;
    let _e97 = GetSpecularBRDF_u0028_f1_u003b_f1_u003b_vf3_u003b((&param_2), (&param_3), (&param_4));
    metal_fresnel = _e97;
    let _e98 = n_2;
    param_5 = _e98;
    let _e99 = v_1;
    param_6 = _e99;
    let _e101 = (*pbr).Roughness;
    param_7 = _e101;
    let _e103 = l_ubo.mipCount;
    param_8 = _e103;
    let _e104 = GetGGXRadiance_u0028_vf3_u003b_vf3_u003b_f1_u003b_f1_u003b((&param_5), (&param_6), (&param_7), (&param_8));
    metal_specularBRDF = _e104;
    let _e105 = metal_fresnel;
    let _e106 = metal_specularBRDF;
    metal_specular_color = (_e105 * _e106);
    let _e108 = NdV_1;
    param_9 = _e108;
    let _e110 = (*pbr).Roughness;
    param_10 = _e110;
    param_11 = vec3<f32>(0.04f, 0.04f, 0.04f);
    let _e111 = GetSpecularBRDF_u0028_f1_u003b_f1_u003b_vf3_u003b((&param_9), (&param_10), (&param_11));
    dielectric_fresnel = _e111;
    let _e112 = n_2;
    param_12 = _e112;
    let _e113 = GetIndirectDiffuse_u0028_vf3_u003b((&param_12));
    let _e115 = (*pbr).Albedo;
    dielectric_diffuse = (_e113 * _e115);
    let _e117 = n_2;
    param_13 = _e117;
    let _e118 = v_1;
    param_14 = _e118;
    let _e120 = (*pbr).Roughness;
    param_15 = _e120;
    let _e122 = l_ubo.mipCount;
    param_16 = _e122;
    let _e123 = GetGGXRadiance_u0028_vf3_u003b_vf3_u003b_f1_u003b_f1_u003b((&param_13), (&param_14), (&param_15), (&param_16));
    dielectric_specularBRDF = _e123;
    let _e124 = dielectric_diffuse;
    let _e125 = dielectric_specularBRDF;
    let _e126 = dielectric_fresnel;
    dielectric_color = mix(_e124, _e125, _e126);
    let _e128 = dielectric_color;
    let _e129 = metal_specular_color;
    let _e131 = (*pbr).Metallic;
    finalColor = mix(_e128, _e129, vec3(_e131));
    let _e134 = finalColor;
    finalColor = clamp(_e134, vec3<f32>(0f, 0f, 0f), vec3<f32>(3f, 3f, 3f));
    let _e136 = finalColor;
    return _e136;
}

fn ComputeIndirectLight_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b(gResult: ptr<function, GBufferResult>, ScreenUV_1: ptr<function, vec2<f32>>) -> vec3<f32> {
    var pbr_1: PBRData;
    var ResultCol: vec3<f32>;
    var param_17: PBRData;
    var gi_diffuse: vec3<f32>;
    var n_3: vec3<f32>;
    var v_2: vec3<f32>;
    var NdV_2: f32;
    var phi_443_: bool;

    let _e64 = (*gResult).albedo;
    pbr_1.Albedo = _e64.xyz;
    let _e69 = (*gResult).metallicRoughness[0u];
    pbr_1.Metallic = _e69;
    let _e73 = (*gResult).metallicRoughness[1u];
    pbr_1.Roughness = _e73;
    let _e76 = (*gResult).worldNormal;
    pbr_1.WorldNormal = _e76;
    let _e79 = (*gResult).worldPos;
    let _e81 = l_ubo.cameraPos;
    pbr_1.ViewDir = normalize((_e79 - _e81.xyz));
    ResultCol = vec3<f32>(0f, 0f, 0f);
    let _e87 = l_ubo.useIBL;
    if (_e87 != 0i) {
        let _e89 = pbr_1;
        param_17 = _e89;
        let _e90 = ComputeIBL_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b((&param_17));
        let _e91 = ResultCol;
        ResultCol = (_e91 + _e90);
    } else {
        let _e94 = l_ubo.useCubeMap;
        let _e95 = (_e94 != 0i);
        phi_443_ = _e95;
        if !(_e95) {
            let _e98 = l_ubo.useDirCubemap;
            phi_443_ = (_e98 != 0i);
        }
        let _e101 = phi_443_;
        if _e101 {
        } else {
            let _e103 = l_ubo.ambientColor;
            gi_diffuse = _e103.xyz;
            let _e105 = gi_diffuse;
            let _e106 = ResultCol;
            ResultCol = (_e106 + _e105);
        }
    }
    let _e109 = pbr_1.WorldNormal;
    n_3 = normalize(_e109);
    let _e112 = pbr_1.ViewDir;
    v_2 = normalize(-(_e112));
    let _e115 = n_3;
    let _e116 = v_2;
    NdV_2 = clamp(dot(_e115, _e116), 0f, 1f);
    let _e119 = ResultCol;
    return _e119;
}

fn GetEmission_u0028_vf2_u003b(ScreenUV_2: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Emission: vec4<f32>;

    let _e56 = (*ScreenUV_2);
    let _e57 = textureSample(gEmissionTexture, gEmissionTextureSampler, _e56);
    Emission = _e57;
    let _e58 = Emission;
    return _e58;
}

fn GetCustomParam0_u0028_vf2_u003b(ScreenUV_3: ptr<function, vec2<f32>>) -> vec4<f32> {
    var CustomParam0_: vec4<f32>;

    let _e56 = (*ScreenUV_3);
    let _e57 = textureSample(gCustomParam0Texture, gCustomParam0TextureSampler, _e56);
    CustomParam0_ = _e57;
    let _e58 = CustomParam0_;
    return _e58;
}

fn GetDepth_u0028_vf2_u003b(ScreenUV_4: ptr<function, vec2<f32>>) -> f32 {
    var Depth: f32;

    let _e56 = (*ScreenUV_4);
    let _e57 = textureSample(gDepthTexture, gDepthTextureSampler, _e56);
    Depth = _e57.x;
    let _e59 = Depth;
    return _e59;
}

fn GetAlbedo_u0028_vf2_u003b(ScreenUV_5: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Albedo: vec4<f32>;

    let _e56 = (*ScreenUV_5);
    let _e57 = textureSample(gAlbedoTexture, gAlbedoTextureSampler, _e56);
    Albedo = _e57;
    let _e58 = Albedo;
    return _e58;
}

fn GetWorldNormal_u0028_vf2_u003b(ScreenUV_6: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldNormal: vec3<f32>;

    let _e56 = (*ScreenUV_6);
    let _e57 = textureSample(gNormalTexture, gNormalTextureSampler, _e56);
    WorldNormal = _e57.xyz;
    let _e59 = WorldNormal;
    return _e59;
}

fn GetWorldPos_u0028_vf2_u003b(ScreenUV_7: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldPos: vec3<f32>;

    let _e56 = (*ScreenUV_7);
    let _e57 = textureSample(gPositionTexture, gPositionTextureSampler, _e56);
    WorldPos = _e57.xyz;
    let _e59 = WorldPos;
    return _e59;
}

fn GetGBuffer_u0028_vf2_u003b(ScreenUV_8: ptr<function, vec2<f32>>) -> GBufferResult {
    var gResult_1: GBufferResult;
    var param_18: vec2<f32>;
    var param_19: vec2<f32>;
    var param_20: vec2<f32>;
    var param_21: vec2<f32>;
    var CustomParam0_1: vec4<f32>;
    var param_22: vec2<f32>;
    var param_23: vec2<f32>;

    let _e63 = (*ScreenUV_8);
    param_18 = _e63;
    let _e64 = GetWorldPos_u0028_vf2_u003b((&param_18));
    gResult_1.worldPos = _e64;
    let _e66 = (*ScreenUV_8);
    param_19 = _e66;
    let _e67 = GetWorldNormal_u0028_vf2_u003b((&param_19));
    gResult_1.worldNormal = _e67;
    let _e69 = (*ScreenUV_8);
    param_20 = _e69;
    let _e70 = GetAlbedo_u0028_vf2_u003b((&param_20));
    gResult_1.albedo = _e70;
    let _e72 = (*ScreenUV_8);
    param_21 = _e72;
    let _e73 = GetDepth_u0028_vf2_u003b((&param_21));
    gResult_1.depth = _e73;
    let _e75 = (*ScreenUV_8);
    param_22 = _e75;
    let _e76 = GetCustomParam0_u0028_vf2_u003b((&param_22));
    CustomParam0_1 = _e76;
    let _e78 = CustomParam0_1[0u];
    gResult_1.materialType = _e78;
    let _e80 = CustomParam0_1;
    gResult_1.metallicRoughness = _e80.yz;
    let _e83 = (*ScreenUV_8);
    param_23 = _e83;
    let _e84 = GetEmission_u0028_vf2_u003b((&param_23));
    gResult_1.emissive = _e84.xyz;
    let _e87 = gResult_1;
    return _e87;
}

fn main_1() {
    var ScreenUV_9: vec2<f32>;
    var gResult_2: GBufferResult;
    var param_24: vec2<f32>;
    var col: vec3<f32>;
    var param_25: GBufferResult;
    var param_26: vec2<f32>;
    var param_27: vec2<f32>;

    let _e61 = v2f_ProjPos_1;
    let _e64 = v2f_ProjPos_1[3u];
    ScreenUV_9 = (_e61.xy / vec2(_e64));
    let _e67 = ScreenUV_9;
    ScreenUV_9 = ((_e67 * 0.5f) + vec2(0.5f));
    let _e71 = ScreenUV_9;
    param_24 = _e71;
    let _e72 = GetGBuffer_u0028_vf2_u003b((&param_24));
    gResult_2 = _e72;
    col = vec3<f32>(0f, 0f, 0f);
    let _e74 = gResult_2.materialType;
    if (_e74 == 1f) {
        let _e76 = gResult_2;
        param_25 = _e76;
        let _e77 = ScreenUV_9;
        param_26 = _e77;
        let _e78 = ComputeIndirectLight_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b((&param_25), (&param_26));
        let _e79 = col;
        col = (_e79 + _e78);
        let _e81 = ScreenUV_9;
        param_27 = _e81;
        let _e82 = GetDirectLight_u0028_vf2_u003b((&param_27));
        let _e83 = col;
        col = (_e83 + _e82);
    } else {
        col = vec3<f32>(0f, 0f, 0f);
    }
    let _e85 = col;
    outColor = vec4<f32>(_e85.x, _e85.y, _e85.z, 1f);
    return;
}

@fragment 
fn main(@location(1) v2f_ProjPos: vec4<f32>, @location(0) v2f_UV: vec2<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_UV_1 = v2f_UV;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e7 = outColor;
    return _e7;
}
