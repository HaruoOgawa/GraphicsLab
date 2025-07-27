struct GBufferResult {
    worldPos: vec3<f32>,
    worldNormal: vec3<f32>,
    albedo: vec4<f32>,
    depth: f32,
    materialType: f32,
    metallicRoughness: vec2<f32>,
}

struct LightParam {
    dir: vec3<f32>,
    color: vec3<f32>,
    attenuation: f32,
    enabled: bool,
}

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

struct LightUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    type_: f32,
    radius: f32,
    intensity: f32,
    fPad0_: f32,
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
@group(0) @binding(1) 
var<uniform> l_ubo: LightUniformBuffer;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_UV_1: vec2<f32>;

fn CalcDiffuseBRDFstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_(param: ptr<function, PBRParam>) -> vec3<f32> {
    var oneminus: f32;

    let _e50 = (*param).metallic;
    oneminus = (0.96f - (_e50 * 0.96f));
    let _e54 = (*param).diffuseColor;
    let _e55 = oneminus;
    return (_e54 * _e55);
}

fn CalcFrenelReflectionstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_(param_1: ptr<function, PBRParam>) -> vec3<f32> {
    let _e49 = (*param_1).reflectance0_;
    let _e51 = (*param_1).reflectance90_;
    let _e53 = (*param_1).reflectance0_;
    let _e56 = (*param_1).VdotH;
    return (_e49 + ((_e51 - _e53) * pow(clamp((1f - _e56), 0f, 1f), 5f)));
}

fn CalcGeometricOcculusionstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_(param_2: ptr<function, PBRParam>) -> f32 {
    var NdotL: f32;
    var NdotV: f32;
    var r: f32;
    var attenuationL: f32;
    var attenuationV: f32;

    let _e54 = (*param_2).NdotL;
    NdotL = _e54;
    let _e56 = (*param_2).NdotV;
    NdotV = _e56;
    let _e58 = (*param_2).alphaRoughness;
    r = _e58;
    let _e59 = NdotL;
    let _e61 = NdotL;
    let _e62 = r;
    let _e63 = r;
    let _e65 = r;
    let _e66 = r;
    let _e69 = NdotL;
    let _e70 = NdotL;
    attenuationL = ((2f * _e59) / (_e61 + sqrt(((_e62 * _e63) + ((1f - (_e65 * _e66)) * (_e69 * _e70))))));
    let _e77 = NdotV;
    let _e79 = NdotV;
    let _e80 = r;
    let _e81 = r;
    let _e83 = r;
    let _e84 = r;
    let _e87 = NdotV;
    let _e88 = NdotV;
    attenuationV = ((2f * _e77) / (_e79 + sqrt(((_e80 * _e81) + ((1f - (_e83 * _e84)) * (_e87 * _e88))))));
    let _e95 = attenuationL;
    let _e96 = attenuationV;
    return (_e95 * _e96);
}

fn CalcMicrofacetstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_(param_3: ptr<function, PBRParam>) -> f32 {
    var roughness2_: f32;
    var f: f32;

    let _e51 = (*param_3).alphaRoughness;
    let _e53 = (*param_3).alphaRoughness;
    roughness2_ = (_e51 * _e53);
    let _e56 = (*param_3).NdotH;
    let _e57 = roughness2_;
    let _e60 = (*param_3).NdotH;
    let _e63 = (*param_3).NdotH;
    f = ((((_e56 * _e57) - _e60) * _e63) + 1f);
    let _e66 = roughness2_;
    let _e67 = f;
    let _e69 = f;
    return (_e66 / ((3.1415927f * _e67) * _e69));
}

fn ComputeLightstructGBufferResultvf3vf3vf4f1f1vf21structLightParamvf3vf3f1b11_(gResult: ptr<function, GBufferResult>, light: ptr<function, LightParam>) -> vec3<f32> {
    var col: vec3<f32>;
    var perceptualRoughness: f32;
    var metallic: f32;
    var alphaRoughness: f32;
    var baseColor: vec4<f32>;
    var f0_: vec3<f32>;
    var diffuseColor: vec3<f32>;
    var specularColor: vec3<f32>;
    var reflectance: f32;
    var reflectance90_: f32;
    var specularEnvironmentR0_: vec3<f32>;
    var specularEnvironmentR90_: vec3<f32>;
    var n: vec3<f32>;
    var v: vec3<f32>;
    var l: vec3<f32>;
    var h: vec3<f32>;
    var reflection: vec3<f32>;
    var NdotL_1: f32;
    var NdotV_1: f32;
    var NdotH: f32;
    var LdotH: f32;
    var VdotH: f32;
    var pbrParam: PBRParam;
    var specular: vec3<f32>;
    var diffuse: vec3<f32>;
    var D: f32;
    var param_4: PBRParam;
    var G: f32;
    var param_5: PBRParam;
    var F: vec3<f32>;
    var param_6: PBRParam;
    var param_7: PBRParam;

    col = vec3<f32>(0f, 0f, 0f);
    let _e83 = (*gResult).metallicRoughness[1u];
    perceptualRoughness = _e83;
    let _e86 = (*gResult).metallicRoughness[0u];
    metallic = _e86;
    let _e87 = perceptualRoughness;
    perceptualRoughness = clamp(_e87, 0.04f, 1f);
    let _e89 = metallic;
    metallic = clamp(_e89, 0f, 1f);
    let _e91 = perceptualRoughness;
    let _e92 = perceptualRoughness;
    alphaRoughness = (_e91 * _e92);
    let _e95 = (*gResult).albedo;
    baseColor = _e95;
    f0_ = vec3<f32>(0.04f, 0.04f, 0.04f);
    let _e96 = baseColor;
    let _e98 = f0_;
    diffuseColor = (_e96.xyz * (vec3<f32>(1f, 1f, 1f) - _e98));
    let _e101 = f0_;
    let _e102 = baseColor;
    let _e104 = metallic;
    specularColor = mix(_e101, _e102.xyz, vec3(_e104));
    let _e108 = specularColor[0u];
    let _e110 = specularColor[1u];
    let _e113 = specularColor[2u];
    reflectance = max(max(_e108, _e110), _e113);
    let _e115 = reflectance;
    reflectance90_ = clamp((_e115 * 25f), 0f, 1f);
    let _e118 = specularColor;
    specularEnvironmentR0_ = _e118;
    let _e119 = reflectance90_;
    specularEnvironmentR90_ = (vec3<f32>(1f, 1f, 1f) * _e119);
    let _e122 = (*gResult).worldNormal;
    n = _e122;
    let _e124 = (*gResult).worldPos;
    let _e126 = l_ubo.cameraPos;
    v = (normalize((_e124 - _e126.xyz)) * -1f);
    let _e132 = (*light).dir;
    l = (_e132 * -1f);
    let _e134 = v;
    let _e135 = l;
    h = normalize((_e134 + _e135));
    let _e138 = v;
    let _e139 = n;
    reflection = normalize(reflect(_e138, _e139));
    let _e142 = n;
    let _e143 = l;
    NdotL_1 = clamp(dot(_e142, _e143), 0f, 1f);
    let _e146 = n;
    let _e147 = v;
    NdotV_1 = clamp(abs(dot(_e146, _e147)), 0f, 1f);
    let _e151 = n;
    let _e152 = h;
    NdotH = clamp(dot(_e151, _e152), 0f, 1f);
    let _e155 = l;
    let _e156 = h;
    LdotH = clamp(dot(_e155, _e156), 0f, 1f);
    let _e159 = v;
    let _e160 = h;
    VdotH = clamp(dot(_e159, _e160), 0f, 1f);
    let _e163 = NdotL_1;
    let _e164 = NdotV_1;
    let _e165 = NdotH;
    let _e166 = LdotH;
    let _e167 = VdotH;
    let _e168 = perceptualRoughness;
    let _e169 = metallic;
    let _e170 = specularEnvironmentR0_;
    let _e171 = specularEnvironmentR90_;
    let _e172 = alphaRoughness;
    let _e173 = diffuseColor;
    let _e174 = specularColor;
    pbrParam = PBRParam(_e163, _e164, _e165, _e166, _e167, _e168, _e169, _e170, _e171, _e172, _e173, _e174);
    specular = vec3<f32>(0f, 0f, 0f);
    diffuse = vec3<f32>(0f, 0f, 0f);
    let _e176 = pbrParam;
    param_4 = _e176;
    let _e177 = CalcMicrofacetstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_((&param_4));
    D = _e177;
    let _e178 = pbrParam;
    param_5 = _e178;
    let _e179 = CalcGeometricOcculusionstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_((&param_5));
    G = _e179;
    let _e180 = pbrParam;
    param_6 = _e180;
    let _e181 = CalcFrenelReflectionstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_((&param_6));
    F = _e181;
    let _e182 = NdotL_1;
    let _e184 = NdotV_1;
    if ((_e182 > 0f) || (_e184 > 0f)) {
        let _e187 = D;
        let _e188 = G;
        let _e190 = F;
        let _e192 = NdotL_1;
        let _e194 = NdotV_1;
        let _e198 = specular;
        specular = (_e198 + ((_e190 * (_e187 * _e188)) / vec3(((4f * _e192) * _e194))));
        let _e200 = specular;
        specular = max(_e200, vec3<f32>(0f, 0f, 0f));
        let _e202 = F;
        let _e205 = pbrParam;
        param_7 = _e205;
        let _e206 = CalcDiffuseBRDFstructPBRParamf1f1f1f1f1f1f1vf3vf3f1vf3vf31_((&param_7));
        let _e208 = diffuse;
        diffuse = (_e208 + ((vec3(1f) - _e202) * _e206));
        let _e210 = NdotL_1;
        let _e211 = specular;
        let _e212 = diffuse;
        let _e216 = (*light).color;
        col = (((_e211 + _e212) * _e210) * _e216);
    }
    let _e219 = (*light).attenuation;
    let _e220 = col;
    col = (_e220 * _e219);
    let _e222 = col;
    col = pow(_e222, vec3<f32>(0.45454547f, 0.45454547f, 0.45454547f));
    let _e224 = col;
    return _e224;
}

fn GetLightParamstructGBufferResultvf3vf3vf4f1f1vf21_(gResult_1: ptr<function, GBufferResult>) -> LightParam {
    var light_1: LightParam;
    var l2v: vec3<f32>;
    var len: f32;

    let _e52 = l_ubo.type_;
    if (_e52 == 1f) {
        let _e55 = l_ubo.dir;
        light_1.dir = normalize(_e55.xyz);
        let _e60 = l_ubo.color;
        light_1.color = _e60.xyz;
        let _e64 = l_ubo.intensity;
        light_1.attenuation = _e64;
        light_1.enabled = true;
    } else {
        let _e68 = l_ubo.type_;
        if (_e68 == 2f) {
            let _e71 = (*gResult_1).worldPos;
            let _e73 = l_ubo.pos;
            l2v = (_e71 - _e73.xyz);
            let _e76 = l2v;
            light_1.dir = normalize(_e76);
            let _e80 = l_ubo.color;
            light_1.color = _e80.xyz;
            let _e83 = l2v;
            len = length(_e83);
            let _e86 = l_ubo.intensity;
            let _e87 = len;
            let _e89 = l_ubo.radius;
            let _e96 = len;
            light_1.attenuation = ((_e86 * max(min((1f - pow((_e87 / _e89), 4f)), 1f), 0f)) / pow(_e96, 2f));
            let _e100 = len;
            let _e102 = l_ubo.radius;
            light_1.enabled = (_e100 <= _e102);
        }
    }
    let _e105 = light_1;
    return _e105;
}

fn GetCustomParam0vf2_(ScreenUV: ptr<function, vec2<f32>>) -> vec4<f32> {
    var CustomParam0_: vec4<f32>;

    let _e49 = (*ScreenUV);
    let _e50 = textureSample(gCustomParam0Texture, gCustomParam0TextureSampler, _e49);
    CustomParam0_ = _e50;
    let _e51 = CustomParam0_;
    return _e51;
}

fn GetDepthvf2_(ScreenUV_1: ptr<function, vec2<f32>>) -> f32 {
    var Depth: f32;

    let _e49 = (*ScreenUV_1);
    let _e50 = textureSample(gDepthTexture, gDepthTextureSampler, _e49);
    Depth = _e50.x;
    let _e52 = Depth;
    return _e52;
}

fn GetAlbedovf2_(ScreenUV_2: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Albedo: vec4<f32>;

    let _e49 = (*ScreenUV_2);
    let _e50 = textureSample(gAlbedoTexture, gAlbedoTextureSampler, _e49);
    Albedo = _e50;
    let _e51 = Albedo;
    return _e51;
}

fn GetWorldNormalvf2_(ScreenUV_3: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldNormal: vec3<f32>;

    let _e49 = (*ScreenUV_3);
    let _e50 = textureSample(gNormalTexture, gNormalTextureSampler, _e49);
    WorldNormal = _e50.xyz;
    let _e52 = WorldNormal;
    return _e52;
}

fn GetWorldPosvf2_(ScreenUV_4: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldPos: vec3<f32>;

    let _e49 = (*ScreenUV_4);
    let _e50 = textureSample(gPositionTexture, gPositionTextureSampler, _e49);
    WorldPos = _e50.xyz;
    let _e52 = WorldPos;
    return _e52;
}

fn GetGBuffervf2_(ScreenUV_5: ptr<function, vec2<f32>>) -> GBufferResult {
    var gResult_2: GBufferResult;
    var param_8: vec2<f32>;
    var param_9: vec2<f32>;
    var param_10: vec2<f32>;
    var param_11: vec2<f32>;
    var CustomParam0_1: vec4<f32>;
    var param_12: vec2<f32>;

    let _e55 = (*ScreenUV_5);
    param_8 = _e55;
    let _e56 = GetWorldPosvf2_((&param_8));
    gResult_2.worldPos = _e56;
    let _e58 = (*ScreenUV_5);
    param_9 = _e58;
    let _e59 = GetWorldNormalvf2_((&param_9));
    gResult_2.worldNormal = _e59;
    let _e61 = (*ScreenUV_5);
    param_10 = _e61;
    let _e62 = GetAlbedovf2_((&param_10));
    gResult_2.albedo = _e62;
    let _e64 = (*ScreenUV_5);
    param_11 = _e64;
    let _e65 = GetDepthvf2_((&param_11));
    gResult_2.depth = _e65;
    let _e67 = (*ScreenUV_5);
    param_12 = _e67;
    let _e68 = GetCustomParam0vf2_((&param_12));
    CustomParam0_1 = _e68;
    let _e70 = CustomParam0_1[0u];
    gResult_2.materialType = _e70;
    let _e72 = CustomParam0_1;
    gResult_2.metallicRoughness = _e72.yz;
    let _e75 = gResult_2;
    return _e75;
}

fn main_1() {
    var ScreenUV_6: vec2<f32>;
    var gResult_3: GBufferResult;
    var param_13: vec2<f32>;
    var light_2: LightParam;
    var param_14: GBufferResult;
    var col_1: vec3<f32>;
    var param_15: GBufferResult;
    var param_16: LightParam;

    let _e55 = v2f_ProjPos_1;
    let _e58 = v2f_ProjPos_1[3u];
    ScreenUV_6 = (_e55.xy / vec2(_e58));
    let _e61 = ScreenUV_6;
    ScreenUV_6 = ((_e61 * 0.5f) + vec2(0.5f));
    let _e65 = ScreenUV_6;
    param_13 = _e65;
    let _e66 = GetGBuffervf2_((&param_13));
    gResult_3 = _e66;
    let _e67 = gResult_3;
    param_14 = _e67;
    let _e68 = GetLightParamstructGBufferResultvf3vf3vf4f1f1vf21_((&param_14));
    light_2 = _e68;
    col_1 = vec3<f32>(0f, 0f, 0f);
    let _e70 = gResult_3.materialType;
    let _e73 = light_2.enabled;
    if ((_e70 == 1f) && _e73) {
        let _e75 = gResult_3;
        param_15 = _e75;
        let _e76 = light_2;
        param_16 = _e76;
        let _e77 = ComputeLightstructGBufferResultvf3vf3vf4f1f1vf21structLightParamvf3vf3f1b11_((&param_15), (&param_16));
        col_1 = _e77;
    } else {
        col_1 = vec3<f32>(0f, 0f, 0f);
    }
    let _e78 = col_1;
    outColor = vec4<f32>(_e78.x, _e78.y, _e78.z, 1f);
    return;
}

@fragment 
fn main(@location(1) v2f_ProjPos: vec4<f32>, @location(0) v2f_UV: vec2<f32>) -> @location(0) vec4<f32> {
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_UV_1 = v2f_UV;
    main_1();
    let _e5 = outColor;
    return _e5;
}
