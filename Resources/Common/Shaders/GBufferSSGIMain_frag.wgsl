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
}

struct FragmentOutput {
    @location(0) member: vec4<f32>,
    @location(1) member_1: vec4<f32>,
}

var<private> g_HashSeed: f32;
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
var gSourceTexture: texture_2d<f32>;
@group(0) @binding(17) 
var gSourceTextureSampler: sampler;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> outColor: vec4<f32>;
var<private> outBackupMain: vec4<f32>;
var<private> v2f_UV_1: vec2<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;
@group(0) @binding(14) 
var gVelocityTexture: texture_2d<f32>;
@group(0) @binding(15) 
var gVelocityTextureSampler: sampler;
@group(0) @binding(18) 
var historyTexture: texture_2d<f32>;
@group(0) @binding(19) 
var historyTextureSampler: sampler;

fn GetSourceTexture_u0028_vf2_u003b(ScreenUV: ptr<function, vec2<f32>>) -> vec3<f32> {
    var src: vec3<f32>;

    let _e60 = (*ScreenUV);
    let _e61 = textureSample(gSourceTexture, gSourceTextureSampler, _e60);
    src = _e61.xyz;
    let _e63 = src;
    return _e63;
}

fn GetWorldNormal_u0028_vf2_u003b(ScreenUV_1: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldNormal: vec3<f32>;

    let _e60 = (*ScreenUV_1);
    let _e61 = textureSample(gNormalTexture, gNormalTextureSampler, _e60);
    WorldNormal = _e61.xyz;
    let _e63 = WorldNormal;
    return _e63;
}

fn GetTexLinearDepth_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> f32 {
    var depth: f32;
    var z: f32;

    let _e61 = (*uv);
    let _e62 = textureSample(gDepthTexture, gDepthTextureSampler, _e61);
    depth = _e62.x;
    let _e64 = depth;
    z = ((_e64 * 2f) - 1f);
    let _e68 = l_ubo.near;
    let _e71 = l_ubo.far;
    let _e74 = l_ubo.far;
    let _e76 = l_ubo.near;
    let _e78 = z;
    let _e80 = l_ubo.far;
    let _e82 = l_ubo.near;
    return (((2f * _e68) * _e71) / ((_e74 + _e76) - (_e78 * (_e80 - _e82))));
}

fn ConstructFloat_u0028_u1_u003b(m: ptr<function, u32>) -> f32 {
    let _e59 = (*m);
    (*m) = (_e59 & 8388607u);
    let _e61 = (*m);
    (*m) = (_e61 | 1065353216u);
    let _e63 = (*m);
    return (bitcast<f32>(_e63) - 1f);
}

fn JenkinsHash_u0028_u1_u003b(x: ptr<function, u32>) -> u32 {
    let _e59 = (*x);
    let _e62 = (*x);
    (*x) = (_e62 + (_e59 << bitcast<u32>(10u)));
    let _e64 = (*x);
    let _e67 = (*x);
    (*x) = (_e67 ^ (_e64 >> bitcast<u32>(6u)));
    let _e69 = (*x);
    let _e72 = (*x);
    (*x) = (_e72 + (_e69 << bitcast<u32>(3u)));
    let _e74 = (*x);
    let _e77 = (*x);
    (*x) = (_e77 ^ (_e74 >> bitcast<u32>(11u)));
    let _e79 = (*x);
    let _e82 = (*x);
    (*x) = (_e82 + (_e79 << bitcast<u32>(15u)));
    let _e84 = (*x);
    return _e84;
}

fn JenkinsHash_u0028_vu2_u003b(v: ptr<function, vec2<u32>>) -> u32 {
    var param: u32;
    var param_1: u32;

    let _e62 = (*v)[0u];
    let _e64 = (*v)[1u];
    param = _e64;
    let _e65 = JenkinsHash_u0028_u1_u003b((&param));
    param_1 = (_e62 ^ _e65);
    let _e67 = JenkinsHash_u0028_u1_u003b((&param_1));
    return _e67;
}

fn JenkinsHash_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param_2: vec2<u32>;
    var param_3: u32;

    let _e62 = (*v_1)[0u];
    let _e63 = (*v_1);
    param_2 = _e63.yz;
    let _e65 = JenkinsHash_u0028_vu2_u003b((&param_2));
    param_3 = (_e62 ^ _e65);
    let _e67 = JenkinsHash_u0028_u1_u003b((&param_3));
    return _e67;
}

fn GenerateHashedRandomFloat_u0028_vu3_u003b(v_2: ptr<function, vec3<u32>>) -> f32 {
    var param_4: vec3<u32>;
    var param_5: u32;

    let _e61 = (*v_2);
    param_4 = _e61;
    let _e62 = JenkinsHash_u0028_vu3_u003b((&param_4));
    param_5 = _e62;
    let _e63 = ConstructFloat_u0028_u1_u003b((&param_5));
    return _e63;
}

fn GenerateRandomValue_u0028_vf2_u003b_vf2_u003b_i1_u003b(screenUV: ptr<function, vec2<f32>>, texSize: ptr<function, vec2<f32>>, frame: ptr<function, i32>) -> f32 {
    var seed: vec3<u32>;
    var param_6: vec3<u32>;

    let _e63 = g_HashSeed;
    g_HashSeed = (_e63 + 1f);
    let _e65 = (*screenUV);
    let _e66 = (*texSize);
    let _e68 = vec2<u32>((_e65 * _e66));
    let _e69 = (*frame);
    let _e71 = g_HashSeed;
    seed = vec3<u32>(_e68.x, _e68.y, u32((f32(_e69) + _e71)));
    let _e77 = seed;
    param_6 = _e77;
    let _e78 = GenerateHashedRandomFloat_u0028_vu3_u003b((&param_6));
    return _e78;
}

fn Raymarch_u0028_vf2_u003b_vf3_u003b_vf3_u003b_vf2_u003b(ScreenUV_2: ptr<function, vec2<f32>>, randVec: ptr<function, vec3<f32>>, worldPos: ptr<function, vec3<f32>>, texSize_1: ptr<function, vec2<f32>>) -> vec3<f32> {
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
    var param_7: vec2<f32>;
    var param_8: vec2<f32>;
    var param_9: i32;
    var resultUV: vec2<f32>;
    var collided: f32;
    var tickness: f32;
    var i: f32;
    var p: vec3<f32>;
    var projPos: vec4<f32>;
    var currentUV: vec2<f32>;
    var currentDepth_View: f32;
    var realDepth_View: f32;
    var param_10: vec2<f32>;
    var diff: f32;
    var hitWorldNormal: vec3<f32>;
    var param_11: vec2<f32>;
    var phi_592_: bool;
    var phi_599_: bool;
    var phi_606_: bool;

    let _e89 = l_ubo.view;
    VMat = _e89;
    let _e91 = l_ubo.proj;
    PMat = _e91;
    let _e92 = VMat;
    let _e93 = (*worldPos);
    viewPos = (_e92 * vec4<f32>(_e93.x, _e93.y, _e93.z, 1f));
    let _e99 = VMat;
    let _e100 = (*randVec);
    viewDir = (_e99 * vec4<f32>(_e100.x, _e100.y, _e100.z, 0f));
    let _e106 = viewPos;
    ro = _e106.xyz;
    let _e108 = viewDir;
    rd = normalize(_e108.xyz);
    stepCount = 32f;
    let _e112 = l_ubo.maxDistance;
    let _e114 = stepCount;
    stepSize = ((_e112 * 1f) / _e114);
    stepSum = 0f;
    let _e116 = (*ScreenUV_2);
    param_7 = _e116;
    let _e117 = (*texSize_1);
    param_8 = _e117;
    let _e119 = l_ubo.frame;
    param_9 = _e119;
    let _e120 = GenerateRandomValue_u0028_vf2_u003b_vf2_u003b_i1_u003b((&param_7), (&param_8), (&param_9));
    jitter = _e120;
    let _e121 = stepSize;
    let _e122 = jitter;
    stepSum = (_e121 * _e122);
    resultUV = vec2<f32>(0f, 0f);
    collided = 0f;
    tickness = 0.1f;
    i = 0f;
    loop {
        let _e124 = i;
        let _e125 = stepCount;
        if (_e124 < _e125) {
            let _e127 = ro;
            let _e128 = rd;
            let _e129 = stepSum;
            p = (_e127 + (_e128 * _e129));
            let _e132 = PMat;
            let _e133 = p;
            projPos = (_e132 * vec4<f32>(_e133.x, _e133.y, _e133.z, 1f));
            let _e139 = projPos;
            let _e142 = projPos[3u];
            currentUV = (((_e139.xy / vec2(_e142)) * 0.5f) + vec2(0.5f));
            let _e149 = p[2u];
            currentDepth_View = -(_e149);
            let _e151 = currentUV;
            param_10 = _e151;
            let _e152 = GetTexLinearDepth_u0028_vf2_u003b((&param_10));
            realDepth_View = _e152;
            let _e154 = currentUV[0u];
            let _e155 = (_e154 < 0f);
            phi_592_ = _e155;
            if !(_e155) {
                let _e158 = currentUV[0u];
                phi_592_ = (_e158 > 1f);
            }
            let _e161 = phi_592_;
            phi_599_ = _e161;
            if !(_e161) {
                let _e164 = currentUV[1u];
                phi_599_ = (_e164 < 0f);
            }
            let _e167 = phi_599_;
            phi_606_ = _e167;
            if !(_e167) {
                let _e170 = currentUV[1u];
                phi_606_ = (_e170 > 1f);
            }
            let _e173 = phi_606_;
            if _e173 {
                break;
            }
            let _e174 = currentDepth_View;
            let _e175 = realDepth_View;
            diff = (_e174 - _e175);
            let _e177 = diff;
            let _e179 = diff;
            let _e180 = tickness;
            if ((_e177 > 0f) && (_e179 < _e180)) {
                let _e183 = currentUV;
                param_11 = _e183;
                let _e184 = GetWorldNormal_u0028_vf2_u003b((&param_11));
                hitWorldNormal = _e184;
                let _e185 = rd;
                let _e186 = hitWorldNormal;
                if (dot(_e185, _e186) < 0f) {
                    let _e189 = currentUV;
                    resultUV = _e189;
                    collided = 1f;
                }
                break;
            }
            let _e190 = stepSize;
            let _e191 = stepSum;
            stepSum = (_e191 + _e190);
            continue;
        } else {
            break;
        }
        continuing {
            let _e193 = i;
            i = (_e193 + 1f);
        }
    }
    let _e195 = resultUV;
    let _e196 = collided;
    return vec3<f32>(_e195.x, _e195.y, _e196);
}

fn GetCosGemisphereSample_u0028_f1_u003b_f1_u003b_vf3_u003b(rand1_: ptr<function, f32>, rand2_: ptr<function, f32>, normal: ptr<function, vec3<f32>>) -> vec3<f32> {
    var up: vec3<f32>;
    var side: vec3<f32>;
    var dir: vec3<f32>;
    var tmpT: vec3<f32>;
    var bioTangent: vec3<f32>;
    var tangent: vec3<f32>;
    var randVal: vec2<f32>;
    var r: f32;
    var phi: f32;

    up = vec3<f32>(0f, 1f, 0f);
    side = vec3<f32>(1f, 0f, 0f);
    let _e70 = (*normal);
    let _e71 = up;
    let _e75 = up;
    let _e76 = side;
    dir = select(_e76, _e75, vec3((abs(dot(_e70, _e71)) < 0.9f)));
    let _e79 = dir;
    let _e80 = (*normal);
    tmpT = normalize(cross(_e79, _e80));
    let _e83 = (*normal);
    let _e84 = tmpT;
    bioTangent = normalize(cross(_e83, _e84));
    let _e87 = bioTangent;
    let _e88 = (*normal);
    tangent = normalize(cross(_e87, _e88));
    let _e91 = (*rand1_);
    let _e92 = (*rand2_);
    randVal = vec2<f32>(_e91, _e92);
    let _e95 = randVal[0u];
    r = sqrt(_e95);
    let _e98 = randVal[1u];
    phi = (6.2831855f * _e98);
    let _e100 = tangent;
    let _e101 = r;
    let _e102 = phi;
    let _e106 = bioTangent;
    let _e107 = r;
    let _e108 = phi;
    let _e113 = (*normal);
    let _e115 = randVal[0u];
    return (((_e100 * (_e101 * cos(_e102))) + (_e106 * (_e107 * sin(_e108)))) + (_e113 * sqrt(max(0f, (1f - _e115)))));
}

fn GetRandomVector_u0028_vf2_u003b_vf3_u003b_vf2_u003b_i1_u003b(ScreenUV_3: ptr<function, vec2<f32>>, worldNormal: ptr<function, vec3<f32>>, texSize_2: ptr<function, vec2<f32>>, index: ptr<function, i32>) -> vec3<f32> {
    var noise1_: f32;
    var param_12: vec2<f32>;
    var param_13: vec2<f32>;
    var param_14: i32;
    var noise2_: f32;
    var param_15: vec2<f32>;
    var param_16: vec2<f32>;
    var param_17: i32;
    var randNormal: vec3<f32>;
    var param_18: f32;
    var param_19: f32;
    var param_20: vec3<f32>;

    let _e74 = (*ScreenUV_3);
    param_12 = _e74;
    let _e75 = (*texSize_2);
    param_13 = _e75;
    let _e77 = l_ubo.frame;
    param_14 = _e77;
    let _e78 = GenerateRandomValue_u0028_vf2_u003b_vf2_u003b_i1_u003b((&param_12), (&param_13), (&param_14));
    noise1_ = _e78;
    let _e79 = (*ScreenUV_3);
    param_15 = _e79;
    let _e80 = (*texSize_2);
    param_16 = _e80;
    let _e82 = l_ubo.frame;
    param_17 = _e82;
    let _e83 = GenerateRandomValue_u0028_vf2_u003b_vf2_u003b_i1_u003b((&param_15), (&param_16), (&param_17));
    noise2_ = _e83;
    let _e84 = noise1_;
    param_18 = _e84;
    let _e85 = noise2_;
    param_19 = _e85;
    let _e86 = (*worldNormal);
    param_20 = _e86;
    let _e87 = GetCosGemisphereSample_u0028_f1_u003b_f1_u003b_vf3_u003b((&param_18), (&param_19), (&param_20));
    randNormal = _e87;
    let _e88 = randNormal;
    return normalize(_e88);
}

fn GetTextureSize_u0028_() -> vec2<f32> {
    var texSize_3: vec2<f32>;

    let _e59 = textureDimensions(gPositionTexture, 0i);
    texSize_3 = vec2<f32>(vec2<i32>(_e59));
    let _e62 = texSize_3;
    return _e62;
}

fn ComputeSSGI_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b(gResult: ptr<function, GBufferResult>, ScreenUV_4: ptr<function, vec2<f32>>) -> vec3<f32> {
    var worldPos_1: vec3<f32>;
    var worldNormal_1: vec3<f32>;
    var texSize_4: vec2<f32>;
    var RAY_COUNT: i32;
    var sampleWeight: f32;
    var resultSSGI: vec3<f32>;
    var i_1: i32;
    var randVec_1: vec3<f32>;
    var param_21: vec2<f32>;
    var param_22: vec3<f32>;
    var param_23: vec2<f32>;
    var param_24: i32;
    var rayResult: vec3<f32>;
    var param_25: vec2<f32>;
    var param_26: vec3<f32>;
    var param_27: vec3<f32>;
    var param_28: vec2<f32>;
    var param_29: vec2<f32>;

    let _e79 = (*gResult).worldPos;
    worldPos_1 = _e79;
    let _e81 = (*gResult).worldNormal;
    worldNormal_1 = _e81;
    let _e82 = GetTextureSize_u0028_();
    texSize_4 = _e82;
    RAY_COUNT = 4i;
    let _e83 = RAY_COUNT;
    sampleWeight = (1f / f32(_e83));
    resultSSGI = vec3<f32>(0f, 0f, 0f);
    i_1 = 0i;
    loop {
        let _e86 = i_1;
        let _e87 = RAY_COUNT;
        if (_e86 < _e87) {
            let _e89 = (*ScreenUV_4);
            param_21 = _e89;
            let _e90 = worldNormal_1;
            param_22 = _e90;
            let _e91 = texSize_4;
            param_23 = _e91;
            let _e92 = i_1;
            param_24 = _e92;
            let _e93 = GetRandomVector_u0028_vf2_u003b_vf3_u003b_vf2_u003b_i1_u003b((&param_21), (&param_22), (&param_23), (&param_24));
            randVec_1 = _e93;
            let _e94 = (*ScreenUV_4);
            param_25 = _e94;
            let _e95 = randVec_1;
            param_26 = _e95;
            let _e96 = worldPos_1;
            param_27 = _e96;
            let _e97 = texSize_4;
            param_28 = _e97;
            let _e98 = Raymarch_u0028_vf2_u003b_vf3_u003b_vf3_u003b_vf2_u003b((&param_25), (&param_26), (&param_27), (&param_28));
            rayResult = _e98;
            let _e100 = rayResult[2u];
            if (_e100 == 1f) {
                let _e102 = rayResult;
                param_29 = _e102.xy;
                let _e104 = GetSourceTexture_u0028_vf2_u003b((&param_29));
                let _e105 = sampleWeight;
                let _e107 = resultSSGI;
                resultSSGI = (_e107 + (_e104 * _e105));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e109 = i_1;
            i_1 = (_e109 + 1i);
        }
    }
    let _e111 = resultSSGI;
    return _e111;
}

fn GetEmission_u0028_vf2_u003b(ScreenUV_5: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Emission: vec4<f32>;

    let _e60 = (*ScreenUV_5);
    let _e61 = textureSample(gEmissionTexture, gEmissionTextureSampler, _e60);
    Emission = _e61;
    let _e62 = Emission;
    return _e62;
}

fn GetCustomParam0_u0028_vf2_u003b(ScreenUV_6: ptr<function, vec2<f32>>) -> vec4<f32> {
    var CustomParam0_: vec4<f32>;

    let _e60 = (*ScreenUV_6);
    let _e61 = textureSample(gCustomParam0Texture, gCustomParam0TextureSampler, _e60);
    CustomParam0_ = _e61;
    let _e62 = CustomParam0_;
    return _e62;
}

fn GetDepth_u0028_vf2_u003b(ScreenUV_7: ptr<function, vec2<f32>>) -> f32 {
    var Depth: f32;

    let _e60 = (*ScreenUV_7);
    let _e61 = textureSample(gDepthTexture, gDepthTextureSampler, _e60);
    Depth = _e61.x;
    let _e63 = Depth;
    return _e63;
}

fn GetAlbedo_u0028_vf2_u003b(ScreenUV_8: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Albedo: vec4<f32>;

    let _e60 = (*ScreenUV_8);
    let _e61 = textureSample(gAlbedoTexture, gAlbedoTextureSampler, _e60);
    Albedo = _e61;
    let _e62 = Albedo;
    return _e62;
}

fn GetWorldPos_u0028_vf2_u003b(ScreenUV_9: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldPos: vec3<f32>;

    let _e60 = (*ScreenUV_9);
    let _e61 = textureSample(gPositionTexture, gPositionTextureSampler, _e60);
    WorldPos = _e61.xyz;
    let _e63 = WorldPos;
    return _e63;
}

fn GetGBuffer_u0028_vf2_u003b(ScreenUV_10: ptr<function, vec2<f32>>) -> GBufferResult {
    var gResult_1: GBufferResult;
    var param_30: vec2<f32>;
    var param_31: vec2<f32>;
    var param_32: vec2<f32>;
    var param_33: vec2<f32>;
    var CustomParam0_1: vec4<f32>;
    var param_34: vec2<f32>;
    var param_35: vec2<f32>;

    let _e67 = (*ScreenUV_10);
    param_30 = _e67;
    let _e68 = GetWorldPos_u0028_vf2_u003b((&param_30));
    gResult_1.worldPos = _e68;
    let _e70 = (*ScreenUV_10);
    param_31 = _e70;
    let _e71 = GetWorldNormal_u0028_vf2_u003b((&param_31));
    gResult_1.worldNormal = _e71;
    let _e73 = (*ScreenUV_10);
    param_32 = _e73;
    let _e74 = GetAlbedo_u0028_vf2_u003b((&param_32));
    gResult_1.albedo = _e74;
    let _e76 = (*ScreenUV_10);
    param_33 = _e76;
    let _e77 = GetDepth_u0028_vf2_u003b((&param_33));
    gResult_1.depth = _e77;
    let _e79 = (*ScreenUV_10);
    param_34 = _e79;
    let _e80 = GetCustomParam0_u0028_vf2_u003b((&param_34));
    CustomParam0_1 = _e80;
    let _e82 = CustomParam0_1[0u];
    gResult_1.materialType = _e82;
    let _e84 = CustomParam0_1;
    gResult_1.metallicRoughness = _e84.yz;
    let _e87 = (*ScreenUV_10);
    param_35 = _e87;
    let _e88 = GetEmission_u0028_vf2_u003b((&param_35));
    gResult_1.emissive = _e88.xyz;
    let _e91 = gResult_1;
    return _e91;
}

fn main_1() {
    var ScreenUV_11: vec2<f32>;
    var gResult_2: GBufferResult;
    var param_36: vec2<f32>;
    var col: vec4<f32>;
    var param_37: GBufferResult;
    var param_38: vec2<f32>;
    var param_39: vec2<f32>;

    g_HashSeed = 0f;
    let _e65 = v2f_ProjPos_1;
    let _e68 = v2f_ProjPos_1[3u];
    ScreenUV_11 = (_e65.xy / vec2(_e68));
    let _e71 = ScreenUV_11;
    ScreenUV_11 = ((_e71 * 0.5f) + vec2(0.5f));
    let _e75 = ScreenUV_11;
    param_36 = _e75;
    let _e76 = GetGBuffer_u0028_vf2_u003b((&param_36));
    gResult_2 = _e76;
    col = vec4<f32>(0f, 0f, 0f, 1f);
    let _e78 = gResult_2.materialType;
    if (_e78 == 1f) {
        let _e80 = gResult_2;
        param_37 = _e80;
        let _e81 = ScreenUV_11;
        param_38 = _e81;
        let _e82 = ComputeSSGI_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b((&param_37), (&param_38));
        col[0u] = _e82.x;
        col[1u] = _e82.y;
        col[2u] = _e82.z;
    }
    let _e89 = col;
    let _e90 = _e89.xyz;
    outColor = vec4<f32>(_e90.x, _e90.y, _e90.z, 1f);
    let _e95 = ScreenUV_11;
    param_39 = _e95;
    let _e96 = GetSourceTexture_u0028_vf2_u003b((&param_39));
    outBackupMain = vec4<f32>(_e96.x, _e96.y, _e96.z, 1f);
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
