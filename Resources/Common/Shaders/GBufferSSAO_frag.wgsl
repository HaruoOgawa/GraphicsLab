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
    near: f32,
    far: f32,
    aoRadius: f32,
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

fn GetSourceTexture_u0028_vf2_u003b(ScreenUV: ptr<function, vec2<f32>>) -> vec3<f32> {
    var src: vec3<f32>;

    let _e56 = (*ScreenUV);
    let _e57 = textureSample(gSourceTexture, gSourceTextureSampler, _e56);
    src = _e57.xyz;
    let _e59 = src;
    return _e59;
}

fn GetTexLinearDepth_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> f32 {
    var depth: f32;
    var z: f32;

    let _e57 = (*uv);
    let _e58 = textureSample(gDepthTexture, gDepthTextureSampler, _e57);
    depth = _e58.x;
    let _e60 = depth;
    z = ((_e60 * 2f) - 1f);
    let _e64 = l_ubo.near;
    let _e67 = l_ubo.far;
    let _e70 = l_ubo.far;
    let _e72 = l_ubo.near;
    let _e74 = z;
    let _e76 = l_ubo.far;
    let _e78 = l_ubo.near;
    return (((2f * _e64) * _e67) / ((_e70 + _e72) - (_e74 * (_e76 - _e78))));
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
    let _e66 = (*normal);
    let _e67 = up;
    let _e71 = up;
    let _e72 = side;
    dir = select(_e72, _e71, vec3((abs(dot(_e66, _e67)) < 0.9f)));
    let _e75 = dir;
    let _e76 = (*normal);
    tmpT = normalize(cross(_e75, _e76));
    let _e79 = (*normal);
    let _e80 = tmpT;
    bioTangent = normalize(cross(_e79, _e80));
    let _e83 = bioTangent;
    let _e84 = (*normal);
    tangent = normalize(cross(_e83, _e84));
    let _e87 = (*rand1_);
    let _e88 = (*rand2_);
    randVal = vec2<f32>(_e87, _e88);
    let _e91 = randVal[0u];
    r = sqrt(_e91);
    let _e94 = randVal[1u];
    phi = (6.2831855f * _e94);
    let _e96 = tangent;
    let _e97 = r;
    let _e98 = phi;
    let _e102 = bioTangent;
    let _e103 = r;
    let _e104 = phi;
    let _e109 = (*normal);
    let _e111 = randVal[0u];
    return (((_e96 * (_e97 * cos(_e98))) + (_e102 * (_e103 * sin(_e104)))) + (_e109 * sqrt(max(0f, (1f - _e111)))));
}

fn ConstructFloat_u0028_u1_u003b(m: ptr<function, u32>) -> f32 {
    let _e55 = (*m);
    (*m) = (_e55 & 8388607u);
    let _e57 = (*m);
    (*m) = (_e57 | 1065353216u);
    let _e59 = (*m);
    return (bitcast<f32>(_e59) - 1f);
}

fn JenkinsHash_u0028_u1_u003b(x: ptr<function, u32>) -> u32 {
    let _e55 = (*x);
    let _e58 = (*x);
    (*x) = (_e58 + (_e55 << bitcast<u32>(10u)));
    let _e60 = (*x);
    let _e63 = (*x);
    (*x) = (_e63 ^ (_e60 >> bitcast<u32>(6u)));
    let _e65 = (*x);
    let _e68 = (*x);
    (*x) = (_e68 + (_e65 << bitcast<u32>(3u)));
    let _e70 = (*x);
    let _e73 = (*x);
    (*x) = (_e73 ^ (_e70 >> bitcast<u32>(11u)));
    let _e75 = (*x);
    let _e78 = (*x);
    (*x) = (_e78 + (_e75 << bitcast<u32>(15u)));
    let _e80 = (*x);
    return _e80;
}

fn JenkinsHash_u0028_vu2_u003b(v: ptr<function, vec2<u32>>) -> u32 {
    var param: u32;
    var param_1: u32;

    let _e58 = (*v)[0u];
    let _e60 = (*v)[1u];
    param = _e60;
    let _e61 = JenkinsHash_u0028_u1_u003b((&param));
    param_1 = (_e58 ^ _e61);
    let _e63 = JenkinsHash_u0028_u1_u003b((&param_1));
    return _e63;
}

fn JenkinsHash_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param_2: vec2<u32>;
    var param_3: u32;

    let _e58 = (*v_1)[0u];
    let _e59 = (*v_1);
    param_2 = _e59.yz;
    let _e61 = JenkinsHash_u0028_vu2_u003b((&param_2));
    param_3 = (_e58 ^ _e61);
    let _e63 = JenkinsHash_u0028_u1_u003b((&param_3));
    return _e63;
}

fn GenerateHashedRandomFloat_u0028_vu3_u003b(v_2: ptr<function, vec3<u32>>) -> f32 {
    var param_4: vec3<u32>;
    var param_5: u32;

    let _e57 = (*v_2);
    param_4 = _e57;
    let _e58 = JenkinsHash_u0028_vu3_u003b((&param_4));
    param_5 = _e58;
    let _e59 = ConstructFloat_u0028_u1_u003b((&param_5));
    return _e59;
}

fn GenerateRandomValue_u0028_vf2_u003b_vf2_u003b_i1_u003b(screenUV: ptr<function, vec2<f32>>, texSize: ptr<function, vec2<f32>>, frame: ptr<function, i32>) -> f32 {
    var seed: vec3<u32>;
    var param_6: vec3<u32>;

    let _e59 = g_HashSeed;
    g_HashSeed = (_e59 + 1f);
    let _e61 = (*screenUV);
    let _e62 = (*texSize);
    let _e64 = vec2<u32>((_e61 * _e62));
    let _e65 = (*frame);
    let _e67 = g_HashSeed;
    seed = vec3<u32>(_e64.x, _e64.y, u32((f32(_e65) + _e67)));
    let _e73 = seed;
    param_6 = _e73;
    let _e74 = GenerateHashedRandomFloat_u0028_vu3_u003b((&param_6));
    return _e74;
}

fn GetRandomVector_u0028_vf2_u003b_vf3_u003b_vf2_u003b_i1_u003b(ScreenUV_1: ptr<function, vec2<f32>>, worldNormal: ptr<function, vec3<f32>>, texSize_1: ptr<function, vec2<f32>>, index: ptr<function, i32>) -> vec3<f32> {
    var noise1_: f32;
    var param_7: vec2<f32>;
    var param_8: vec2<f32>;
    var param_9: i32;
    var noise2_: f32;
    var param_10: vec2<f32>;
    var param_11: vec2<f32>;
    var param_12: i32;
    var randNormal: vec3<f32>;
    var param_13: f32;
    var param_14: f32;
    var param_15: vec3<f32>;

    let _e70 = (*ScreenUV_1);
    param_7 = _e70;
    let _e71 = (*texSize_1);
    param_8 = _e71;
    let _e73 = l_ubo.frame;
    param_9 = _e73;
    let _e74 = GenerateRandomValue_u0028_vf2_u003b_vf2_u003b_i1_u003b((&param_7), (&param_8), (&param_9));
    noise1_ = _e74;
    let _e75 = (*ScreenUV_1);
    param_10 = _e75;
    let _e76 = (*texSize_1);
    param_11 = _e76;
    let _e78 = l_ubo.frame;
    param_12 = _e78;
    let _e79 = GenerateRandomValue_u0028_vf2_u003b_vf2_u003b_i1_u003b((&param_10), (&param_11), (&param_12));
    noise2_ = _e79;
    let _e80 = noise1_;
    param_13 = _e80;
    let _e81 = noise2_;
    param_14 = _e81;
    let _e82 = (*worldNormal);
    param_15 = _e82;
    let _e83 = GetCosGemisphereSample_u0028_f1_u003b_f1_u003b_vf3_u003b((&param_13), (&param_14), (&param_15));
    randNormal = _e83;
    let _e84 = randNormal;
    return normalize(_e84);
}

fn GetTextureSize_u0028_() -> vec2<f32> {
    var texSize_2: vec2<f32>;

    let _e55 = textureDimensions(gPositionTexture, 0i);
    texSize_2 = vec2<f32>(vec2<i32>(_e55));
    let _e58 = texSize_2;
    return _e58;
}

fn ComputeSSAO_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b(gResult: ptr<function, GBufferResult>, ScreenUV_2: ptr<function, vec2<f32>>) -> f32 {
    var VMat: mat4x4<f32>;
    var PMat: mat4x4<f32>;
    var worldPos: vec3<f32>;
    var worldNormal_1: vec3<f32>;
    var texSize_3: vec2<f32>;
    var viewPos: vec4<f32>;
    var ro: vec3<f32>;
    var resultAO: f32;
    var loop_: f32;
    var aoRadius: f32;
    var rayDist: f32;
    var param_16: vec2<f32>;
    var param_17: vec2<f32>;
    var param_18: i32;
    var i: i32;
    var randVec: vec3<f32>;
    var param_19: vec2<f32>;
    var param_20: vec3<f32>;
    var param_21: vec2<f32>;
    var param_22: i32;
    var viewDir: vec4<f32>;
    var rd: vec3<f32>;
    var p: vec3<f32>;
    var projPos: vec4<f32>;
    var currentUV: vec2<f32>;
    var currentDepth_View: f32;
    var realDepth_View: f32;
    var param_23: vec2<f32>;
    var occluded: f32;
    var rangeCheck: f32;
    var phi_595_: bool;
    var phi_602_: bool;
    var phi_609_: bool;

    let _e87 = l_ubo.view;
    VMat = _e87;
    let _e89 = l_ubo.proj;
    PMat = _e89;
    let _e91 = (*gResult).worldPos;
    worldPos = _e91;
    let _e93 = (*gResult).worldNormal;
    worldNormal_1 = _e93;
    let _e94 = GetTextureSize_u0028_();
    texSize_3 = _e94;
    let _e95 = VMat;
    let _e96 = worldPos;
    viewPos = (_e95 * vec4<f32>(_e96.x, _e96.y, _e96.z, 1f));
    let _e102 = viewPos;
    ro = _e102.xyz;
    resultAO = 0f;
    loop_ = 32f;
    let _e105 = l_ubo.aoRadius;
    aoRadius = _e105;
    let _e106 = aoRadius;
    let _e107 = (*ScreenUV_2);
    param_16 = _e107;
    let _e108 = texSize_3;
    param_17 = _e108;
    let _e110 = l_ubo.frame;
    param_18 = _e110;
    let _e111 = GenerateRandomValue_u0028_vf2_u003b_vf2_u003b_i1_u003b((&param_16), (&param_17), (&param_18));
    rayDist = (_e106 * _e111);
    i = 0i;
    loop {
        let _e113 = i;
        let _e114 = loop_;
        if (_e113 < i32(_e114)) {
            let _e117 = (*ScreenUV_2);
            param_19 = _e117;
            let _e118 = worldNormal_1;
            param_20 = _e118;
            let _e119 = texSize_3;
            param_21 = _e119;
            let _e120 = i;
            param_22 = _e120;
            let _e121 = GetRandomVector_u0028_vf2_u003b_vf3_u003b_vf2_u003b_i1_u003b((&param_19), (&param_20), (&param_21), (&param_22));
            randVec = _e121;
            let _e122 = VMat;
            let _e123 = randVec;
            viewDir = (_e122 * vec4<f32>(_e123.x, _e123.y, _e123.z, 0f));
            let _e129 = viewDir;
            rd = normalize(_e129.xyz);
            let _e132 = ro;
            let _e133 = rd;
            let _e134 = rayDist;
            p = (_e132 + (_e133 * _e134));
            let _e137 = PMat;
            let _e138 = p;
            projPos = (_e137 * vec4<f32>(_e138.x, _e138.y, _e138.z, 1f));
            let _e144 = projPos;
            let _e147 = projPos[3u];
            currentUV = (((_e144.xy / vec2(_e147)) * 0.5f) + vec2(0.5f));
            let _e154 = p[2u];
            currentDepth_View = -(_e154);
            let _e156 = currentUV;
            param_23 = _e156;
            let _e157 = GetTexLinearDepth_u0028_vf2_u003b((&param_23));
            realDepth_View = _e157;
            let _e159 = currentUV[0u];
            let _e160 = (_e159 < 0f);
            phi_595_ = _e160;
            if !(_e160) {
                let _e163 = currentUV[0u];
                phi_595_ = (_e163 > 1f);
            }
            let _e166 = phi_595_;
            phi_602_ = _e166;
            if !(_e166) {
                let _e169 = currentUV[1u];
                phi_602_ = (_e169 < 0f);
            }
            let _e172 = phi_602_;
            phi_609_ = _e172;
            if !(_e172) {
                let _e175 = currentUV[1u];
                phi_609_ = (_e175 > 1f);
            }
            let _e178 = phi_609_;
            if _e178 {
                continue;
            }
            let _e179 = realDepth_View;
            let _e180 = currentDepth_View;
            occluded = select(1f, 0f, (_e179 < _e180));
            let _e183 = aoRadius;
            let _e184 = currentDepth_View;
            let _e185 = realDepth_View;
            rangeCheck = smoothstep(0f, 1f, (_e183 / max(abs((_e184 - _e185)), 0.0001f)));
            let _e191 = occluded;
            let _e192 = rangeCheck;
            let _e194 = resultAO;
            resultAO = (_e194 + mix(1f, _e191, _e192));
            continue;
        } else {
            break;
        }
        continuing {
            let _e196 = i;
            i = (_e196 + 1i);
        }
    }
    let _e198 = loop_;
    let _e199 = resultAO;
    resultAO = (_e199 / _e198);
    let _e201 = resultAO;
    resultAO = pow(_e201, 2f);
    let _e203 = resultAO;
    return _e203;
}

fn GetEmission_u0028_vf2_u003b(ScreenUV_3: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Emission: vec4<f32>;

    let _e56 = (*ScreenUV_3);
    let _e57 = textureSample(gEmissionTexture, gEmissionTextureSampler, _e56);
    Emission = _e57;
    let _e58 = Emission;
    return _e58;
}

fn GetCustomParam0_u0028_vf2_u003b(ScreenUV_4: ptr<function, vec2<f32>>) -> vec4<f32> {
    var CustomParam0_: vec4<f32>;

    let _e56 = (*ScreenUV_4);
    let _e57 = textureSample(gCustomParam0Texture, gCustomParam0TextureSampler, _e56);
    CustomParam0_ = _e57;
    let _e58 = CustomParam0_;
    return _e58;
}

fn GetDepth_u0028_vf2_u003b(ScreenUV_5: ptr<function, vec2<f32>>) -> f32 {
    var Depth: f32;

    let _e56 = (*ScreenUV_5);
    let _e57 = textureSample(gDepthTexture, gDepthTextureSampler, _e56);
    Depth = _e57.x;
    let _e59 = Depth;
    return _e59;
}

fn GetAlbedo_u0028_vf2_u003b(ScreenUV_6: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Albedo: vec4<f32>;

    let _e56 = (*ScreenUV_6);
    let _e57 = textureSample(gAlbedoTexture, gAlbedoTextureSampler, _e56);
    Albedo = _e57;
    let _e58 = Albedo;
    return _e58;
}

fn GetWorldNormal_u0028_vf2_u003b(ScreenUV_7: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldNormal: vec3<f32>;

    let _e56 = (*ScreenUV_7);
    let _e57 = textureSample(gNormalTexture, gNormalTextureSampler, _e56);
    WorldNormal = _e57.xyz;
    let _e59 = WorldNormal;
    return _e59;
}

fn GetWorldPos_u0028_vf2_u003b(ScreenUV_8: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldPos: vec3<f32>;

    let _e56 = (*ScreenUV_8);
    let _e57 = textureSample(gPositionTexture, gPositionTextureSampler, _e56);
    WorldPos = _e57.xyz;
    let _e59 = WorldPos;
    return _e59;
}

fn GetGBuffer_u0028_vf2_u003b(ScreenUV_9: ptr<function, vec2<f32>>) -> GBufferResult {
    var gResult_1: GBufferResult;
    var param_24: vec2<f32>;
    var param_25: vec2<f32>;
    var param_26: vec2<f32>;
    var param_27: vec2<f32>;
    var CustomParam0_1: vec4<f32>;
    var param_28: vec2<f32>;
    var param_29: vec2<f32>;

    let _e63 = (*ScreenUV_9);
    param_24 = _e63;
    let _e64 = GetWorldPos_u0028_vf2_u003b((&param_24));
    gResult_1.worldPos = _e64;
    let _e66 = (*ScreenUV_9);
    param_25 = _e66;
    let _e67 = GetWorldNormal_u0028_vf2_u003b((&param_25));
    gResult_1.worldNormal = _e67;
    let _e69 = (*ScreenUV_9);
    param_26 = _e69;
    let _e70 = GetAlbedo_u0028_vf2_u003b((&param_26));
    gResult_1.albedo = _e70;
    let _e72 = (*ScreenUV_9);
    param_27 = _e72;
    let _e73 = GetDepth_u0028_vf2_u003b((&param_27));
    gResult_1.depth = _e73;
    let _e75 = (*ScreenUV_9);
    param_28 = _e75;
    let _e76 = GetCustomParam0_u0028_vf2_u003b((&param_28));
    CustomParam0_1 = _e76;
    let _e78 = CustomParam0_1[0u];
    gResult_1.materialType = _e78;
    let _e80 = CustomParam0_1;
    gResult_1.metallicRoughness = _e80.yz;
    let _e83 = (*ScreenUV_9);
    param_29 = _e83;
    let _e84 = GetEmission_u0028_vf2_u003b((&param_29));
    gResult_1.emissive = _e84.xyz;
    let _e87 = gResult_1;
    return _e87;
}

fn main_1() {
    var ScreenUV_10: vec2<f32>;
    var gResult_2: GBufferResult;
    var param_30: vec2<f32>;
    var col: vec3<f32>;
    var param_31: GBufferResult;
    var param_32: vec2<f32>;
    var param_33: vec2<f32>;

    g_HashSeed = 0f;
    let _e61 = v2f_ProjPos_1;
    let _e64 = v2f_ProjPos_1[3u];
    ScreenUV_10 = (_e61.xy / vec2(_e64));
    let _e67 = ScreenUV_10;
    ScreenUV_10 = ((_e67 * 0.5f) + vec2(0.5f));
    let _e71 = ScreenUV_10;
    param_30 = _e71;
    let _e72 = GetGBuffer_u0028_vf2_u003b((&param_30));
    gResult_2 = _e72;
    col = vec3<f32>(1f, 1f, 1f);
    let _e74 = gResult_2.materialType;
    if (_e74 == 1f) {
        let _e76 = gResult_2;
        param_31 = _e76;
        let _e77 = ScreenUV_10;
        param_32 = _e77;
        let _e78 = ComputeSSAO_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b((&param_31), (&param_32));
        col = vec3(_e78);
    }
    let _e80 = col;
    outColor = vec4<f32>(_e80.x, _e80.y, _e80.z, 1f);
    let _e85 = ScreenUV_10;
    param_33 = _e85;
    let _e86 = GetSourceTexture_u0028_vf2_u003b((&param_33));
    outBackupMain = vec4<f32>(_e86.x, _e86.y, _e86.z, 1f);
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
