struct FragUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    IsXBlur: i32,
    iPad0_: i32,
    iPad1_: i32,
    iPad2_: i32,
}

@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
var<private> fUV_1: vec2<f32>;
@group(0) @binding(2) 
var<uniform> frag_ubo: FragUniformBuffer;
var<private> outColor: vec4<f32>;

fn GetTexColorvf2_(texcoord: ptr<function, vec2<f32>>) -> vec3<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0.0, 0.0, 0.0, 0.0);
    let _e29 = (*texcoord);
    let _e30 = textureSample(texImage, texSampler, _e29);
    let _e31 = _e30.xyz;
    col[0u] = _e31.x;
    col[1u] = _e31.y;
    col[2u] = _e31.z;
    let _e38 = col;
    return _e38.xyz;
}

fn main_1() {
    var col_1: vec3<f32>;
    var st: vec2<f32>;
    var texelSize: vec2<f32>;
    var weights: array<f32,5u>;
    var BlurDir: vec2<f32>;
    var i: i32;
    var param: vec2<f32>;

    col_1 = vec3<f32>(0.0, 0.0, 0.0);
    let _e34 = fUV_1;
    st = _e34;
    let _e35 = textureDimensions(texImage, 0);
    texelSize = (vec2<f32>(1.0) / vec2<f32>(vec2<i32>(_e35)));
    weights = array<f32,5u>(0.22702699899673462, 0.31621599197387695, 0.07027000188827515, 0.002216000109910965, 0.00016700000560376793);
    let _e41 = frag_ubo.IsXBlur;
    let _e45 = frag_ubo.IsXBlur;
    BlurDir = vec2<f32>(select(0.0, 1.0, (_e41 == 1)), select(1.0, 0.0, (_e45 == 1)));
    i = -4;
    loop {
        let _e49 = i;
        if (_e49 <= 4) {
            let _e51 = st;
            let _e52 = texelSize;
            let _e53 = i;
            let _e56 = BlurDir;
            param = (_e51 + ((_e52 * f32(_e53)) * _e56));
            let _e59 = GetTexColorvf2_((&param));
            let _e60 = i;
            let _e63 = weights[abs(_e60)];
            let _e65 = col_1;
            col_1 = (_e65 + (_e59 * _e63));
            continue;
        } else {
            break;
        }
        continuing {
            let _e67 = i;
            i = (_e67 + 1);
        }
    }
    let _e69 = col_1;
    outColor = vec4<f32>(_e69.x, _e69.y, _e69.z, 1.0);
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>) -> @location(0) vec4<f32> {
    fUV_1 = fUV;
    main_1();
    let _e3 = outColor;
    return _e3;
}
