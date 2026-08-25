struct GBufferResult {
    worldPos: vec3<f32>,
    worldNormal: vec3<f32>,
    albedo: vec4<f32>,
    depth: f32,
    materialType: f32,
    metallicRoughness: vec2<f32>,
    emissive: vec3<f32>,
}

struct LightUniformBuffer {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    frame: i32,
    iPad0_: i32,
    iPad1_: i32,
    iPad2_: i32,
    maxDistance: f32,
    near: f32,
    far: f32,
    fPad2_: f32,
    cameraPos: vec4<f32>,
}

struct FragmentOutput {
    @location(0) member: vec4<f32>,
    @location(1) member_1: vec4<f32>,
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
@group(0) @binding(1) 
var<uniform> l_ubo: LightUniformBuffer;
@group(0) @binding(10) 
var gCustomParam0Texture: texture_2d<f32>;
@group(0) @binding(11) 
var gCustomParam0TextureSampler: sampler;
@group(0) @binding(12) 
var gEmissionTexture: texture_2d<f32>;
@group(0) @binding(13) 
var gEmissionTextureSampler: sampler;
@group(0) @binding(16) 
var gSrcTexture: texture_2d<f32>;
@group(0) @binding(17) 
var gSrcTextureSampler: sampler;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> outColor: vec4<f32>;
var<private> outBackupMain: vec4<f32>;
var<private> v2f_UV_1: vec2<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;
@group(0) @binding(14) 
var gVelocityTexture: texture_2d<f32>;
@group(0) @binding(15) 
var gVelocityTextureSampler: sampler;

fn GetSource_u0028_vf2_u003b(ScreenUV: ptr<function, vec2<f32>>) -> vec3<f32> {
    var src: vec3<f32>;

    let _e49 = (*ScreenUV);
    let _e50 = textureSample(gSrcTexture, gSrcTextureSampler, _e49);
    src = _e50.xyz;
    let _e52 = src;
    return _e52;
}

fn GetWorldNormal_u0028_vf2_u003b(ScreenUV_1: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldNormal: vec3<f32>;

    let _e49 = (*ScreenUV_1);
    let _e50 = textureSample(gNormalTexture, gNormalTextureSampler, _e49);
    WorldNormal = _e50.xyz;
    let _e52 = WorldNormal;
    return _e52;
}

fn GetTexLinearDepth_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> f32 {
    var depth: f32;
    var z: f32;

    let _e50 = (*uv);
    let _e51 = textureSample(gDepthTexture, gDepthTextureSampler, _e50);
    depth = _e51.x;
    let _e53 = depth;
    z = ((_e53 * 2f) - 1f);
    let _e57 = l_ubo.near;
    let _e60 = l_ubo.far;
    let _e63 = l_ubo.far;
    let _e65 = l_ubo.near;
    let _e67 = z;
    let _e69 = l_ubo.far;
    let _e71 = l_ubo.near;
    return (((2f * _e57) * _e60) / ((_e63 + _e65) - (_e67 * (_e69 - _e71))));
}

fn Raymarch_u0028_vf2_u003b_vf3_u003b_vf3_u003b_vf2_u003b(ScreenUV_2: ptr<function, vec2<f32>>, refVec: ptr<function, vec3<f32>>, worldPos: ptr<function, vec3<f32>>, texSize: ptr<function, vec2<f32>>) -> vec3<f32> {
    var VMat: mat4x4<f32>;
    var PMat: mat4x4<f32>;
    var viewPos: vec4<f32>;
    var viewDir: vec4<f32>;
    var ro: vec3<f32>;
    var rd: vec3<f32>;
    var stepCount: f32;
    var stepSize: f32;
    var stepSum: f32;
    var jitter: f32;
    var resultUV: vec2<f32>;
    var collided: f32;
    var tickness: f32;
    var i: f32;
    var p: vec3<f32>;
    var projPos: vec4<f32>;
    var currentUV: vec2<f32>;
    var currentDepth_View: f32;
    var realDepth_View: f32;
    var param: vec2<f32>;
    var diff: f32;
    var hitWorldNormal: vec3<f32>;
    var param_1: vec2<f32>;
    var phi_352_: bool;
    var phi_360_: bool;
    var phi_367_: bool;

    let _e75 = l_ubo.view;
    VMat = _e75;
    let _e77 = l_ubo.proj;
    PMat = _e77;
    let _e78 = VMat;
    let _e79 = (*worldPos);
    viewPos = (_e78 * vec4<f32>(_e79.x, _e79.y, _e79.z, 1f));
    let _e85 = VMat;
    let _e86 = (*refVec);
    viewDir = (_e85 * vec4<f32>(_e86.x, _e86.y, _e86.z, 0f));
    let _e92 = viewPos;
    ro = _e92.xyz;
    let _e94 = viewDir;
    rd = normalize(_e94.xyz);
    stepCount = 32f;
    let _e98 = l_ubo.maxDistance;
    let _e100 = stepCount;
    stepSize = ((_e98 * 1f) / _e100);
    stepSum = 0f;
    jitter = 0.01f;
    let _e102 = stepSize;
    let _e103 = jitter;
    stepSum = (_e102 * _e103);
    resultUV = vec2<f32>(0f, 0f);
    collided = 0f;
    tickness = 0.1f;
    i = 0f;
    loop {
        let _e105 = i;
        let _e106 = stepCount;
        if (_e105 < _e106) {
            let _e108 = ro;
            let _e109 = rd;
            let _e110 = stepSum;
            p = (_e108 + (_e109 * _e110));
            let _e113 = PMat;
            let _e114 = p;
            projPos = (_e113 * vec4<f32>(_e114.x, _e114.y, _e114.z, 1f));
            let _e120 = projPos;
            let _e123 = projPos[3u];
            currentUV = (((_e120.xy / vec2(_e123)) * 0.5f) + vec2(0.5f));
            let _e130 = p[2u];
            currentDepth_View = -(_e130);
            let _e132 = currentUV;
            param = _e132;
            let _e133 = GetTexLinearDepth_u0028_vf2_u003b((&param));
            realDepth_View = _e133;
            let _e135 = currentUV[0u];
            let _e136 = (_e135 < 0f);
            phi_352_ = _e136;
            if !(_e136) {
                let _e139 = currentUV[0u];
                phi_352_ = (_e139 > 1f);
            }
            let _e142 = phi_352_;
            phi_360_ = _e142;
            if !(_e142) {
                let _e145 = currentUV[1u];
                phi_360_ = (_e145 < 0f);
            }
            let _e148 = phi_360_;
            phi_367_ = _e148;
            if !(_e148) {
                let _e151 = currentUV[1u];
                phi_367_ = (_e151 > 1f);
            }
            let _e154 = phi_367_;
            if _e154 {
                break;
            }
            let _e155 = currentDepth_View;
            let _e156 = realDepth_View;
            diff = (_e155 - _e156);
            let _e158 = diff;
            let _e160 = diff;
            let _e161 = tickness;
            if ((_e158 > 0f) && (_e160 < _e161)) {
                let _e164 = currentUV;
                param_1 = _e164;
                let _e165 = GetWorldNormal_u0028_vf2_u003b((&param_1));
                hitWorldNormal = _e165;
                let _e166 = rd;
                let _e167 = hitWorldNormal;
                if (dot(_e166, _e167) < 0f) {
                    let _e170 = currentUV;
                    resultUV = _e170;
                    collided = 1f;
                }
                break;
            }
            let _e171 = stepSize;
            let _e172 = stepSum;
            stepSum = (_e172 + _e171);
            continue;
        } else {
            break;
        }
        continuing {
            let _e174 = i;
            i = (_e174 + 1f);
        }
    }
    let _e176 = resultUV;
    let _e177 = collided;
    return vec3<f32>(_e176.x, _e176.y, _e177);
}

fn GetTextureSize_u0028_() -> vec2<f32> {
    var texSize_1: vec2<f32>;

    let _e48 = textureDimensions(gPositionTexture, 0i);
    texSize_1 = vec2<f32>(vec2<i32>(_e48));
    let _e51 = texSize_1;
    return _e51;
}

fn ComputeSSR_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b(gResult: ptr<function, GBufferResult>, ScreenUV_3: ptr<function, vec2<f32>>) -> vec3<f32> {
    var worldPos_1: vec3<f32>;
    var worldNormal: vec3<f32>;
    var texSize_2: vec2<f32>;
    var resultSSR: vec3<f32>;
    var viewDir_1: vec3<f32>;
    var refVec_1: vec3<f32>;
    var rayResult: vec3<f32>;
    var param_2: vec2<f32>;
    var param_3: vec3<f32>;
    var param_4: vec3<f32>;
    var param_5: vec2<f32>;
    var param_6: vec2<f32>;

    let _e62 = (*gResult).worldPos;
    worldPos_1 = _e62;
    let _e64 = (*gResult).worldNormal;
    worldNormal = _e64;
    let _e65 = GetTextureSize_u0028_();
    texSize_2 = _e65;
    resultSSR = vec3<f32>(0f, 0f, 0f);
    let _e66 = worldPos_1;
    let _e68 = l_ubo.cameraPos;
    viewDir_1 = normalize((_e66 - _e68.xyz));
    let _e72 = viewDir_1;
    let _e73 = worldNormal;
    refVec_1 = reflect(_e72, _e73);
    let _e75 = (*ScreenUV_3);
    param_2 = _e75;
    let _e76 = refVec_1;
    param_3 = _e76;
    let _e77 = worldPos_1;
    param_4 = _e77;
    let _e78 = texSize_2;
    param_5 = _e78;
    let _e79 = Raymarch_u0028_vf2_u003b_vf3_u003b_vf3_u003b_vf2_u003b((&param_2), (&param_3), (&param_4), (&param_5));
    rayResult = _e79;
    let _e81 = rayResult[2u];
    if (_e81 == 1f) {
        let _e83 = rayResult;
        param_6 = _e83.xy;
        let _e85 = GetSource_u0028_vf2_u003b((&param_6));
        resultSSR = _e85;
    }
    let _e86 = resultSSR;
    return _e86;
}

fn GetEmission_u0028_vf2_u003b(ScreenUV_4: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Emission: vec4<f32>;

    let _e49 = (*ScreenUV_4);
    let _e50 = textureSample(gEmissionTexture, gEmissionTextureSampler, _e49);
    Emission = _e50;
    let _e51 = Emission;
    return _e51;
}

fn GetCustomParam0_u0028_vf2_u003b(ScreenUV_5: ptr<function, vec2<f32>>) -> vec4<f32> {
    var CustomParam0_: vec4<f32>;

    let _e49 = (*ScreenUV_5);
    let _e50 = textureSample(gCustomParam0Texture, gCustomParam0TextureSampler, _e49);
    CustomParam0_ = _e50;
    let _e51 = CustomParam0_;
    return _e51;
}

fn GetDepth_u0028_vf2_u003b(ScreenUV_6: ptr<function, vec2<f32>>) -> f32 {
    var Depth: f32;

    let _e49 = (*ScreenUV_6);
    let _e50 = textureSample(gDepthTexture, gDepthTextureSampler, _e49);
    Depth = _e50.x;
    let _e52 = Depth;
    return _e52;
}

fn GetAlbedo_u0028_vf2_u003b(ScreenUV_7: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Albedo: vec4<f32>;

    let _e49 = (*ScreenUV_7);
    let _e50 = textureSample(gAlbedoTexture, gAlbedoTextureSampler, _e49);
    Albedo = _e50;
    let _e51 = Albedo;
    return _e51;
}

fn GetWorldPos_u0028_vf2_u003b(ScreenUV_8: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldPos: vec3<f32>;

    let _e49 = (*ScreenUV_8);
    let _e50 = textureSample(gPositionTexture, gPositionTextureSampler, _e49);
    WorldPos = _e50.xyz;
    let _e52 = WorldPos;
    return _e52;
}

fn GetGBuffer_u0028_vf2_u003b(ScreenUV_9: ptr<function, vec2<f32>>) -> GBufferResult {
    var gResult_1: GBufferResult;
    var param_7: vec2<f32>;
    var param_8: vec2<f32>;
    var param_9: vec2<f32>;
    var param_10: vec2<f32>;
    var CustomParam0_1: vec4<f32>;
    var param_11: vec2<f32>;
    var param_12: vec2<f32>;

    let _e56 = (*ScreenUV_9);
    param_7 = _e56;
    let _e57 = GetWorldPos_u0028_vf2_u003b((&param_7));
    gResult_1.worldPos = _e57;
    let _e59 = (*ScreenUV_9);
    param_8 = _e59;
    let _e60 = GetWorldNormal_u0028_vf2_u003b((&param_8));
    gResult_1.worldNormal = _e60;
    let _e62 = (*ScreenUV_9);
    param_9 = _e62;
    let _e63 = GetAlbedo_u0028_vf2_u003b((&param_9));
    gResult_1.albedo = _e63;
    let _e65 = (*ScreenUV_9);
    param_10 = _e65;
    let _e66 = GetDepth_u0028_vf2_u003b((&param_10));
    gResult_1.depth = _e66;
    let _e68 = (*ScreenUV_9);
    param_11 = _e68;
    let _e69 = GetCustomParam0_u0028_vf2_u003b((&param_11));
    CustomParam0_1 = _e69;
    let _e71 = CustomParam0_1[0u];
    gResult_1.materialType = _e71;
    let _e73 = CustomParam0_1;
    gResult_1.metallicRoughness = _e73.yz;
    let _e76 = (*ScreenUV_9);
    param_12 = _e76;
    let _e77 = GetEmission_u0028_vf2_u003b((&param_12));
    gResult_1.emissive = _e77.xyz;
    let _e80 = gResult_1;
    return _e80;
}

fn main_1() {
    var ScreenUV_10: vec2<f32>;
    var gResult_2: GBufferResult;
    var param_13: vec2<f32>;
    var col: vec4<f32>;
    var param_14: GBufferResult;
    var param_15: vec2<f32>;
    var param_16: vec2<f32>;

    let _e54 = v2f_ProjPos_1;
    let _e57 = v2f_ProjPos_1[3u];
    ScreenUV_10 = (_e54.xy / vec2(_e57));
    let _e60 = ScreenUV_10;
    ScreenUV_10 = ((_e60 * 0.5f) + vec2(0.5f));
    let _e64 = ScreenUV_10;
    param_13 = _e64;
    let _e65 = GetGBuffer_u0028_vf2_u003b((&param_13));
    gResult_2 = _e65;
    col = vec4<f32>(0f, 0f, 0f, 1f);
    let _e67 = gResult_2.materialType;
    if (_e67 == 1f) {
        let _e69 = gResult_2;
        param_14 = _e69;
        let _e70 = ScreenUV_10;
        param_15 = _e70;
        let _e71 = ComputeSSR_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b((&param_14), (&param_15));
        col[0u] = _e71.x;
        col[1u] = _e71.y;
        col[2u] = _e71.z;
    }
    let _e78 = col;
    let _e79 = _e78.xyz;
    outColor = vec4<f32>(_e79.x, _e79.y, _e79.z, 1f);
    let _e84 = ScreenUV_10;
    param_16 = _e84;
    let _e85 = GetSource_u0028_vf2_u003b((&param_16));
    outBackupMain = vec4<f32>(_e85.x, _e85.y, _e85.z, 1f);
    return;
}

@fragment 
fn main(@location(1) v2f_ProjPos: vec4<f32>, @location(0) v2f_UV: vec2<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> FragmentOutput {
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_UV_1 = v2f_UV;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e8 = outColor;
    let _e9 = outBackupMain;
    return FragmentOutput(_e8, _e9);
}
