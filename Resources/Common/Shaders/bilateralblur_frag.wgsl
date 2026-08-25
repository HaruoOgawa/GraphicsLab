struct FragUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    g_InvResolutionDirection: vec2<f32>,
    v2Pad: vec2<f32>,
    g_Sharpness: f32,
    near: f32,
    far: f32,
    nExponent: f32,
    kernelRadius: i32,
    iPad0_: i32,
    iPad1_: i32,
    iPad2_: i32,
}

@group(0) @binding(3) 
var texSource: texture_2d<f32>;
@group(0) @binding(4) 
var texSourceSampler: sampler;
@group(0) @binding(5) 
var texDepth: texture_2d<f32>;
@group(0) @binding(6) 
var texDepthSampler: sampler;
@group(0) @binding(2) 
var<uniform> frag_ubo: FragUniformBuffer;
@group(0) @binding(7) 
var texNormal: texture_2d<f32>;
@group(0) @binding(8) 
var texNormalSampler: sampler;
var<private> v2f_UV_1: vec2<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;

fn GetWorldNormal_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> vec3<f32> {
    var worldNormal: vec3<f32>;

    let _e27 = (*uv);
    let _e28 = textureSample(texNormal, texNormalSampler, _e27);
    worldNormal = normalize(_e28.xyz);
    let _e31 = worldNormal;
    return _e31;
}

fn GetTexLinearDepth_u0028_vf2_u003b(uv_1: ptr<function, vec2<f32>>) -> f32 {
    var depth: f32;
    var z: f32;

    let _e28 = (*uv_1);
    let _e29 = textureSample(texDepth, texDepthSampler, _e28);
    depth = _e29.x;
    let _e31 = depth;
    z = ((_e31 * 2f) - 1f);
    let _e35 = frag_ubo.near;
    let _e38 = frag_ubo.far;
    let _e41 = frag_ubo.far;
    let _e43 = frag_ubo.near;
    let _e45 = z;
    let _e47 = frag_ubo.far;
    let _e49 = frag_ubo.near;
    return (((2f * _e35) * _e38) / ((_e41 + _e43) - (_e45 * (_e47 - _e49))));
}

fn GetTexSource_u0028_vf2_u003b(uv_2: ptr<function, vec2<f32>>) -> vec4<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e27 = (*uv_2);
    let _e28 = textureSample(texSource, texSourceSampler, _e27);
    col = _e28;
    let _e29 = col;
    return _e29;
}

fn BlurFunction_u0028_vf2_u003b_f1_u003b_vf4_u003b_f1_u003b_vf3_u003b_f1_u003b(uv_3: ptr<function, vec2<f32>>, r: ptr<function, f32>, center_c: ptr<function, vec4<f32>>, center_d: ptr<function, f32>, center_n: ptr<function, vec3<f32>>, w_total: ptr<function, f32>) -> vec4<f32> {
    var c: vec4<f32>;
    var param: vec2<f32>;
    var d: f32;
    var param_1: vec2<f32>;
    var n: vec3<f32>;
    var param_2: vec2<f32>;
    var BlurSigma: f32;
    var BlurFalloff: f32;
    var ddiff: f32;
    var normalDot: f32;
    var normalWeight: f32;
    var w: f32;

    let _e43 = (*uv_3);
    param = _e43;
    let _e44 = GetTexSource_u0028_vf2_u003b((&param));
    c = _e44;
    let _e45 = (*uv_3);
    param_1 = _e45;
    let _e46 = GetTexLinearDepth_u0028_vf2_u003b((&param_1));
    d = _e46;
    let _e47 = (*uv_3);
    param_2 = _e47;
    let _e48 = GetWorldNormal_u0028_vf2_u003b((&param_2));
    n = _e48;
    let _e50 = frag_ubo.kernelRadius;
    BlurSigma = (f32(_e50) * 0.5f);
    let _e53 = BlurSigma;
    let _e55 = BlurSigma;
    BlurFalloff = (1f / ((2f * _e53) * _e55));
    let _e58 = d;
    let _e59 = (*center_d);
    let _e62 = frag_ubo.g_Sharpness;
    ddiff = ((_e58 - _e59) * _e62);
    let _e64 = (*center_n);
    let _e65 = n;
    normalDot = dot(_e64, _e65);
    let _e67 = normalDot;
    let _e70 = frag_ubo.nExponent;
    normalWeight = pow(max(_e67, 0f), _e70);
    let _e72 = (*r);
    let _e74 = (*r);
    let _e76 = BlurFalloff;
    let _e78 = ddiff;
    let _e79 = ddiff;
    let _e83 = normalWeight;
    w = (exp2((((-(_e72) * _e74) * _e76) - (_e78 * _e79))) * _e83);
    let _e85 = w;
    let _e86 = (*w_total);
    (*w_total) = (_e86 + _e85);
    let _e88 = c;
    let _e89 = w;
    return (_e88 * _e89);
}

fn GetTextureSize_u0028_() -> vec2<f32> {
    var texSize: vec2<f32>;

    let _e26 = textureDimensions(texSource, 0i);
    texSize = vec2<f32>(vec2<i32>(_e26));
    let _e29 = texSize;
    return _e29;
}

fn main_1() {
    var center_c_1: vec4<f32>;
    var param_3: vec2<f32>;
    var center_d_1: f32;
    var param_4: vec2<f32>;
    var center_n_1: vec3<f32>;
    var param_5: vec2<f32>;
    var c_total: vec4<f32>;
    var w_total_1: f32;
    var texSize_1: vec2<f32>;
    var dir: vec2<f32>;
    var r_1: f32;
    var uv_4: vec2<f32>;
    var param_6: vec2<f32>;
    var param_7: f32;
    var param_8: vec4<f32>;
    var param_9: f32;
    var param_10: vec3<f32>;
    var param_11: f32;
    var r_2: f32;
    var uv_5: vec2<f32>;
    var param_12: vec2<f32>;
    var param_13: f32;
    var param_14: vec4<f32>;
    var param_15: f32;
    var param_16: vec3<f32>;
    var param_17: f32;

    let _e51 = v2f_UV_1;
    param_3 = _e51;
    let _e52 = GetTexSource_u0028_vf2_u003b((&param_3));
    center_c_1 = _e52;
    let _e53 = v2f_UV_1;
    param_4 = _e53;
    let _e54 = GetTexLinearDepth_u0028_vf2_u003b((&param_4));
    center_d_1 = _e54;
    let _e55 = v2f_UV_1;
    param_5 = _e55;
    let _e56 = GetWorldNormal_u0028_vf2_u003b((&param_5));
    center_n_1 = _e56;
    let _e57 = center_c_1;
    c_total = _e57;
    w_total_1 = 1f;
    let _e58 = GetTextureSize_u0028_();
    texSize_1 = _e58;
    let _e60 = frag_ubo.g_InvResolutionDirection;
    dir = _e60;
    let _e62 = dir[0u];
    let _e64 = texSize_1[0u];
    dir[0u] = (_e62 / _e64);
    let _e68 = dir[1u];
    let _e70 = texSize_1[1u];
    dir[1u] = (_e68 / _e70);
    r_1 = 1f;
    loop {
        let _e73 = r_1;
        let _e75 = frag_ubo.kernelRadius;
        if (_e73 <= f32(_e75)) {
            let _e78 = v2f_UV_1;
            let _e79 = dir;
            let _e80 = r_1;
            uv_4 = (_e78 + (_e79 * _e80));
            let _e83 = uv_4;
            param_6 = _e83;
            let _e84 = r_1;
            param_7 = _e84;
            let _e85 = center_c_1;
            param_8 = _e85;
            let _e86 = center_d_1;
            param_9 = _e86;
            let _e87 = center_n_1;
            param_10 = _e87;
            let _e88 = w_total_1;
            param_11 = _e88;
            let _e89 = BlurFunction_u0028_vf2_u003b_f1_u003b_vf4_u003b_f1_u003b_vf3_u003b_f1_u003b((&param_6), (&param_7), (&param_8), (&param_9), (&param_10), (&param_11));
            let _e90 = param_11;
            w_total_1 = _e90;
            let _e91 = c_total;
            c_total = (_e91 + _e89);
            continue;
        } else {
            break;
        }
        continuing {
            let _e93 = r_1;
            r_1 = (_e93 + 1f);
        }
    }
    r_2 = 1f;
    loop {
        let _e95 = r_2;
        let _e97 = frag_ubo.kernelRadius;
        if (_e95 <= f32(_e97)) {
            let _e100 = v2f_UV_1;
            let _e101 = dir;
            let _e102 = r_2;
            uv_5 = (_e100 - (_e101 * _e102));
            let _e105 = uv_5;
            param_12 = _e105;
            let _e106 = r_2;
            param_13 = _e106;
            let _e107 = center_c_1;
            param_14 = _e107;
            let _e108 = center_d_1;
            param_15 = _e108;
            let _e109 = center_n_1;
            param_16 = _e109;
            let _e110 = w_total_1;
            param_17 = _e110;
            let _e111 = BlurFunction_u0028_vf2_u003b_f1_u003b_vf4_u003b_f1_u003b_vf3_u003b_f1_u003b((&param_12), (&param_13), (&param_14), (&param_15), (&param_16), (&param_17));
            let _e112 = param_17;
            w_total_1 = _e112;
            let _e113 = c_total;
            c_total = (_e113 + _e111);
            continue;
        } else {
            break;
        }
        continuing {
            let _e115 = r_2;
            r_2 = (_e115 + 1f);
        }
    }
    let _e117 = c_total;
    let _e118 = w_total_1;
    outColor = (_e117 / vec4(_e118));
    return;
}

@fragment 
fn main(@location(0) v2f_UV: vec2<f32>, @location(1) v2f_ProjPos: vec4<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    v2f_UV_1 = v2f_UV;
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e7 = outColor;
    return _e7;
}
