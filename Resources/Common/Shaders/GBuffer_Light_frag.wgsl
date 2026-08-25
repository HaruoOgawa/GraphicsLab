struct GBufferResult {
    worldPos: vec3<f32>,
    worldNormal: vec3<f32>,
    albedo: vec4<f32>,
    depth: f32,
    materialType: f32,
    metallicRoughness: vec2<f32>,
    emissive: vec3<f32>,
}

struct LightParam {
    dir: vec3<f32>,
    color: vec3<f32>,
    attenuation: f32,
    enabled: bool,
}

struct PBRData {
    Albedo: vec3<f32>,
    Metallic: f32,
    Roughness: f32,
    WorldNormal: vec3<f32>,
    WorldPos: vec3<f32>,
    ViewDir: vec3<f32>,
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

struct LightUniformBuffer {
    lightVPMat: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    type_: f32,
    radius: f32,
    intensity: f32,
    angle: f32,
    height: f32,
    mipCount: f32,
    ShadowMapX: f32,
    ShadowMapY: f32,
    useIBL: i32,
    useShadowMap: i32,
    ForceLighting: i32,
    iPad2_: i32,
    dir: vec4<f32>,
    pos: vec4<f32>,
    color: vec4<f32>,
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
@group(0) @binding(16) 
var shadowmapTexture: texture_2d<f32>;
@group(0) @binding(17) 
var shadowmapTextureSampler: sampler;

fn CalcFrenelReflection_u0028_vf3_u003b_f1_u003b_f1_u003b(Albedo: ptr<function, vec3<f32>>, Metallic: ptr<function, f32>, NdV: ptr<function, f32>) -> vec3<f32> {
    var F0_: vec3<f32>;

    let _e59 = (*Albedo);
    let _e60 = (*Metallic);
    F0_ = mix(vec3<f32>(0.04f, 0.04f, 0.04f), _e59, vec3(_e60));
    let _e63 = F0_;
    let _e64 = F0_;
    let _e67 = (*NdV);
    return (_e63 + ((vec3(1f) - _e64) * pow((1f - _e67), 5f)));
}

fn CalcGeometricOcculusion_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b(param: ptr<function, PBRParam>) -> f32 {
    var k: f32;
    var attenuationL: f32;
    var attenuationV: f32;

    let _e60 = (*param).Roughness;
    k = _e60;
    let _e62 = (*param).NdV;
    let _e64 = (*param).NdV;
    let _e65 = k;
    let _e68 = k;
    attenuationL = (_e62 / ((_e64 * (1f - _e65)) + _e68));
    let _e72 = (*param).NdL;
    let _e74 = (*param).NdL;
    let _e75 = k;
    let _e78 = k;
    attenuationV = (_e72 / ((_e74 * (1f - _e75)) + _e78));
    let _e81 = attenuationL;
    let _e82 = attenuationV;
    return (_e81 * _e82);
}

fn CalcMicrofacet_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b(param_1: ptr<function, PBRParam>) -> f32 {
    var r: f32;
    var a: f32;
    var a2_: f32;
    var f: f32;

    let _e61 = (*param_1).Roughness;
    r = _e61;
    let _e62 = r;
    a = _e62;
    let _e63 = a;
    let _e64 = a;
    a2_ = max(0.001f, (_e63 * _e64));
    let _e68 = (*param_1).NdH;
    let _e70 = a2_;
    f = ((pow(_e68, 2f) * (_e70 - 1f)) + 1f);
    let _e74 = a2_;
    let _e75 = f;
    let _e77 = f;
    return (_e74 / ((3.1415927f * _e75) * _e77));
}

fn CalcSpecularBRDF_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b(param_2: ptr<function, PBRParam>) -> vec3<f32> {
    var D: f32;
    var param_3: PBRParam;
    var G: f32;
    var param_4: PBRParam;
    var F: vec3<f32>;
    var param_5: vec3<f32>;
    var param_6: f32;
    var param_7: f32;
    var spec: vec3<f32>;

    let _e65 = (*param_2);
    param_3 = _e65;
    let _e66 = CalcMicrofacet_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b((&param_3));
    D = _e66;
    let _e67 = (*param_2);
    param_4 = _e67;
    let _e68 = CalcGeometricOcculusion_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b((&param_4));
    G = _e68;
    let _e70 = (*param_2).Albedo;
    param_5 = _e70;
    let _e72 = (*param_2).Metallic;
    param_6 = _e72;
    let _e74 = (*param_2).NdV;
    param_7 = _e74;
    let _e75 = CalcFrenelReflection_u0028_vf3_u003b_f1_u003b_f1_u003b((&param_5), (&param_6), (&param_7));
    F = _e75;
    let _e76 = D;
    let _e77 = G;
    let _e79 = F;
    let _e82 = (*param_2).NdV;
    let _e85 = (*param_2).NdL;
    spec = ((_e79 * (_e76 * _e77)) / vec3(((4f * _e82) * _e85)));
    let _e90 = spec[0u];
    spec[0u] = max(0f, _e90);
    let _e94 = spec[1u];
    spec[1u] = max(0f, _e94);
    let _e98 = spec[2u];
    spec[2u] = max(0f, _e98);
    let _e101 = spec;
    return _e101;
}

fn CalcDiffuseBRDF_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b(pbr: ptr<function, PBRData>) -> vec3<f32> {
    var OneMinusReflectivity: f32;
    var col: vec3<f32>;

    let _e59 = (*pbr).Metallic;
    OneMinusReflectivity = (0.96f - (_e59 * 0.96f));
    let _e63 = (*pbr).Albedo;
    let _e64 = OneMinusReflectivity;
    col = (_e63 * _e64);
    let _e67 = col[0u];
    col[0u] = max(0f, _e67);
    let _e71 = col[1u];
    col[1u] = max(0f, _e71);
    let _e75 = col[2u];
    col[2u] = max(0f, _e75);
    let _e78 = col;
    return _e78;
}

fn CreatePBRParam_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b_struct_u002d_LightParam_u002d_vf3_u002d_vf3_u002d_f1_u002d_b11_u003b(pbr_1: ptr<function, PBRData>, light: ptr<function, LightParam>) -> PBRParam {
    var l: vec3<f32>;
    var v: vec3<f32>;
    var n: vec3<f32>;
    var h: vec3<f32>;
    var NdH: f32;
    var LdH: f32;
    var NdL: f32;
    var NdV_1: f32;
    var VdH: f32;
    var param_8: PBRParam;

    let _e68 = (*light).dir;
    l = normalize(-(_e68));
    let _e72 = (*pbr_1).ViewDir;
    v = normalize(-(_e72));
    let _e76 = (*pbr_1).WorldNormal;
    n = normalize(_e76);
    let _e78 = l;
    let _e79 = v;
    h = normalize((_e78 + _e79));
    let _e82 = n;
    let _e83 = h;
    NdH = clamp(dot(_e82, _e83), 0f, 1f);
    let _e86 = l;
    let _e87 = h;
    LdH = clamp(dot(_e86, _e87), 0f, 1f);
    let _e90 = n;
    let _e91 = l;
    NdL = clamp(dot(_e90, _e91), 0f, 1f);
    let _e94 = n;
    let _e95 = v;
    NdV_1 = clamp(dot(_e94, _e95), 0f, 1f);
    let _e98 = v;
    let _e99 = h;
    VdH = clamp(dot(_e98, _e99), 0f, 1f);
    let _e103 = (*pbr_1).Albedo;
    param_8.Albedo = _e103;
    let _e106 = (*pbr_1).Metallic;
    param_8.Metallic = _e106;
    let _e109 = (*pbr_1).Roughness;
    param_8.Roughness = max(0.04f, _e109);
    let _e112 = NdH;
    param_8.NdH = _e112;
    let _e114 = LdH;
    param_8.LdH = _e114;
    let _e116 = NdL;
    param_8.NdL = _e116;
    let _e118 = NdV_1;
    param_8.NdV = _e118;
    let _e120 = VdH;
    param_8.VdH = _e120;
    let _e122 = param_8;
    return _e122;
}

fn ComputeDirectLight_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_struct_u002d_LightParam_u002d_vf3_u002d_vf3_u002d_f1_u002d_b11_u003b(gResult: ptr<function, GBufferResult>, light_1: ptr<function, LightParam>) -> vec3<f32> {
    var pbr_2: PBRData;
    var param_9: PBRParam;
    var param_10: PBRData;
    var param_11: LightParam;
    var DiffuseCol: vec3<f32>;
    var param_12: PBRData;
    var SpecularCol: vec3<f32>;
    var param_13: PBRParam;
    var ResultCol: vec3<f32>;

    let _e67 = (*gResult).albedo;
    pbr_2.Albedo = _e67.xyz;
    let _e72 = (*gResult).metallicRoughness[0u];
    pbr_2.Metallic = _e72;
    let _e76 = (*gResult).metallicRoughness[1u];
    pbr_2.Roughness = _e76;
    let _e79 = (*gResult).worldNormal;
    pbr_2.WorldNormal = _e79;
    let _e82 = (*gResult).worldPos;
    let _e84 = l_ubo.cameraPos;
    pbr_2.ViewDir = normalize((_e82 - _e84.xyz));
    let _e89 = pbr_2;
    param_10 = _e89;
    let _e90 = (*light_1);
    param_11 = _e90;
    let _e91 = CreatePBRParam_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b_struct_u002d_LightParam_u002d_vf3_u002d_vf3_u002d_f1_u002d_b11_u003b((&param_10), (&param_11));
    param_9 = _e91;
    let _e92 = pbr_2;
    param_12 = _e92;
    let _e93 = CalcDiffuseBRDF_u0028_struct_u002d_PBRData_u002d_vf3_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf31_u003b((&param_12));
    DiffuseCol = _e93;
    let _e94 = param_9;
    param_13 = _e94;
    let _e95 = CalcSpecularBRDF_u0028_struct_u002d_PBRParam_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f11_u003b((&param_13));
    SpecularCol = _e95;
    let _e97 = param_9.NdL;
    let _e98 = DiffuseCol;
    let _e99 = SpecularCol;
    let _e103 = (*light_1).color;
    let _e106 = (*light_1).attenuation;
    ResultCol = ((((_e98 + _e99) * _e97) * _e103) * _e106);
    let _e108 = ResultCol;
    return _e108;
}

fn GetLightParam_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b(gResult_1: ptr<function, GBufferResult>) -> LightParam {
    var light_2: LightParam;
    var l2v: vec3<f32>;
    var len: f32;
    var baseDir: vec3<f32>;
    var l2g: vec3<f32>;
    var l2g_norm: vec3<f32>;
    var coneAngle: f32;
    var l2g_angle: f32;
    var ValidAngle: bool;
    var height: f32;
    var prjlen: f32;
    var ValidHeight: bool;
    var sinFactor: f32;
    var spotR: f32;
    var l2g_perp: vec3<f32>;
    var l2gR: f32;
    var ValidRadius: bool;
    var attenuation: f32;

    let _e75 = l_ubo.type_;
    if (_e75 == 1f) {
        let _e78 = l_ubo.dir;
        light_2.dir = normalize(_e78.xyz);
        let _e83 = l_ubo.color;
        light_2.color = _e83.xyz;
        let _e87 = l_ubo.intensity;
        light_2.attenuation = _e87;
        light_2.enabled = true;
    } else {
        let _e91 = l_ubo.type_;
        if (_e91 == 2f) {
            let _e94 = (*gResult_1).worldPos;
            let _e96 = l_ubo.pos;
            l2v = (_e94 - _e96.xyz);
            let _e99 = l2v;
            light_2.dir = normalize(_e99);
            let _e103 = l_ubo.color;
            light_2.color = _e103.xyz;
            let _e106 = l2v;
            len = length(_e106);
            let _e109 = l_ubo.intensity;
            let _e110 = len;
            let _e112 = l_ubo.radius;
            let _e119 = len;
            light_2.attenuation = ((_e109 * max(min((1f - pow((_e110 / _e112), 4f)), 1f), 0f)) / pow(_e119, 2f));
            let _e123 = len;
            let _e125 = l_ubo.radius;
            light_2.enabled = (_e123 <= _e125);
        } else {
            let _e129 = l_ubo.type_;
            if (_e129 == 3f) {
                let _e132 = l_ubo.dir;
                baseDir = normalize(_e132.xyz);
                let _e136 = (*gResult_1).worldPos;
                let _e138 = l_ubo.pos;
                l2g = (_e136 - _e138.xyz);
                let _e141 = l2g;
                l2g_norm = normalize(_e141);
                let _e144 = l_ubo.angle;
                coneAngle = radians(_e144);
                let _e146 = baseDir;
                let _e147 = l2g_norm;
                l2g_angle = acos(dot(_e146, _e147));
                let _e150 = l2g_angle;
                let _e152 = l2g_angle;
                let _e153 = coneAngle;
                ValidAngle = ((_e150 >= 0f) && (_e152 <= _e153));
                let _e157 = l_ubo.height;
                height = _e157;
                let _e158 = l2g;
                let _e160 = l2g_angle;
                prjlen = (length(_e158) * cos(_e160));
                let _e163 = prjlen;
                let _e165 = prjlen;
                let _e166 = height;
                ValidHeight = ((_e163 >= 0f) && (_e165 < _e166));
                let _e169 = coneAngle;
                let _e171 = coneAngle;
                sinFactor = (sin(_e169) / sin((1.57075f - _e171)));
                let _e175 = sinFactor;
                let _e176 = prjlen;
                spotR = (_e175 * _e176);
                let _e178 = l2g;
                let _e179 = prjlen;
                let _e180 = baseDir;
                l2g_perp = (_e178 - (_e180 * _e179));
                let _e183 = l2g_perp;
                l2gR = length(_e183);
                let _e185 = l2gR;
                let _e186 = spotR;
                ValidRadius = (_e185 <= _e186);
                attenuation = 1f;
                let _e188 = l2g_norm;
                light_2.dir = _e188;
                let _e191 = l_ubo.color;
                light_2.color = _e191.xyz;
                let _e195 = l_ubo.intensity;
                let _e196 = attenuation;
                let _e200 = l_ubo.color[3u];
                light_2.attenuation = ((_e195 * _e196) * _e200);
                let _e203 = ValidAngle;
                let _e204 = ValidRadius;
                light_2.enabled = (_e203 && _e204);
            }
        }
    }
    let _e207 = light_2;
    return _e207;
}

fn GetEmission_u0028_vf2_u003b(ScreenUV: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Emission: vec4<f32>;

    let _e57 = (*ScreenUV);
    let _e58 = textureSample(gEmissionTexture, gEmissionTextureSampler, _e57);
    Emission = _e58;
    let _e59 = Emission;
    return _e59;
}

fn GetCustomParam0_u0028_vf2_u003b(ScreenUV_1: ptr<function, vec2<f32>>) -> vec4<f32> {
    var CustomParam0_: vec4<f32>;

    let _e57 = (*ScreenUV_1);
    let _e58 = textureSample(gCustomParam0Texture, gCustomParam0TextureSampler, _e57);
    CustomParam0_ = _e58;
    let _e59 = CustomParam0_;
    return _e59;
}

fn GetDepth_u0028_vf2_u003b(ScreenUV_2: ptr<function, vec2<f32>>) -> f32 {
    var Depth: f32;

    let _e57 = (*ScreenUV_2);
    let _e58 = textureSample(gDepthTexture, gDepthTextureSampler, _e57);
    Depth = _e58.x;
    let _e60 = Depth;
    return _e60;
}

fn GetAlbedo_u0028_vf2_u003b(ScreenUV_3: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Albedo_1: vec4<f32>;

    let _e57 = (*ScreenUV_3);
    let _e58 = textureSample(gAlbedoTexture, gAlbedoTextureSampler, _e57);
    Albedo_1 = _e58;
    let _e59 = Albedo_1;
    return _e59;
}

fn GetWorldNormal_u0028_vf2_u003b(ScreenUV_4: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldNormal: vec3<f32>;

    let _e57 = (*ScreenUV_4);
    let _e58 = textureSample(gNormalTexture, gNormalTextureSampler, _e57);
    WorldNormal = _e58.xyz;
    let _e60 = WorldNormal;
    return _e60;
}

fn GetWorldPos_u0028_vf2_u003b(ScreenUV_5: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldPos: vec3<f32>;

    let _e57 = (*ScreenUV_5);
    let _e58 = textureSample(gPositionTexture, gPositionTextureSampler, _e57);
    WorldPos = _e58.xyz;
    let _e60 = WorldPos;
    return _e60;
}

fn GetGBuffer_u0028_vf2_u003b(ScreenUV_6: ptr<function, vec2<f32>>) -> GBufferResult {
    var gResult_2: GBufferResult;
    var param_14: vec2<f32>;
    var param_15: vec2<f32>;
    var param_16: vec2<f32>;
    var param_17: vec2<f32>;
    var CustomParam0_1: vec4<f32>;
    var param_18: vec2<f32>;
    var param_19: vec2<f32>;

    let _e64 = (*ScreenUV_6);
    param_14 = _e64;
    let _e65 = GetWorldPos_u0028_vf2_u003b((&param_14));
    gResult_2.worldPos = _e65;
    let _e67 = (*ScreenUV_6);
    param_15 = _e67;
    let _e68 = GetWorldNormal_u0028_vf2_u003b((&param_15));
    gResult_2.worldNormal = _e68;
    let _e70 = (*ScreenUV_6);
    param_16 = _e70;
    let _e71 = GetAlbedo_u0028_vf2_u003b((&param_16));
    gResult_2.albedo = _e71;
    let _e73 = (*ScreenUV_6);
    param_17 = _e73;
    let _e74 = GetDepth_u0028_vf2_u003b((&param_17));
    gResult_2.depth = _e74;
    let _e76 = (*ScreenUV_6);
    param_18 = _e76;
    let _e77 = GetCustomParam0_u0028_vf2_u003b((&param_18));
    CustomParam0_1 = _e77;
    let _e79 = CustomParam0_1[0u];
    gResult_2.materialType = _e79;
    let _e81 = CustomParam0_1;
    gResult_2.metallicRoughness = _e81.yz;
    let _e84 = (*ScreenUV_6);
    param_19 = _e84;
    let _e85 = GetEmission_u0028_vf2_u003b((&param_19));
    gResult_2.emissive = _e85.xyz;
    let _e88 = gResult_2;
    return _e88;
}

fn main_1() {
    var ScreenUV_7: vec2<f32>;
    var gResult_3: GBufferResult;
    var param_20: vec2<f32>;
    var light_3: LightParam;
    var param_21: GBufferResult;
    var col_1: vec3<f32>;
    var param_22: GBufferResult;
    var param_23: LightParam;
    var phi_690_: bool;

    let _e63 = v2f_ProjPos_1;
    let _e66 = v2f_ProjPos_1[3u];
    ScreenUV_7 = (_e63.xy / vec2(_e66));
    let _e69 = ScreenUV_7;
    ScreenUV_7 = ((_e69 * 0.5f) + vec2(0.5f));
    let _e73 = ScreenUV_7;
    param_20 = _e73;
    let _e74 = GetGBuffer_u0028_vf2_u003b((&param_20));
    gResult_3 = _e74;
    let _e75 = gResult_3;
    param_21 = _e75;
    let _e76 = GetLightParam_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b((&param_21));
    light_3 = _e76;
    let _e78 = l_ubo.ForceLighting;
    let _e79 = (_e78 == 1i);
    phi_690_ = _e79;
    if _e79 {
        let _e81 = l_ubo.type_;
        phi_690_ = (_e81 == 3f);
    }
    let _e84 = phi_690_;
    if _e84 {
        gResult_3.albedo = vec4<f32>(1f, 1f, 1f, 1f);
    }
    col_1 = vec3<f32>(0f, 0f, 0f);
    let _e87 = gResult_3.materialType;
    let _e90 = light_3.enabled;
    if ((_e87 == 1f) && _e90) {
        let _e92 = gResult_3;
        param_22 = _e92;
        let _e93 = light_3;
        param_23 = _e93;
        let _e94 = ComputeDirectLight_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_struct_u002d_LightParam_u002d_vf3_u002d_vf3_u002d_f1_u002d_b11_u003b((&param_22), (&param_23));
        col_1 = _e94;
    } else {
        col_1 = vec3<f32>(0f, 0f, 0f);
    }
    let _e95 = col_1;
    outColor = vec4<f32>(_e95.x, _e95.y, _e95.z, 1f);
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
