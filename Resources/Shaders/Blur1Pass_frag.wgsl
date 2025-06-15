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
var<private> v2f_ProjPos_1: vec4<f32>;

fn GetTexColorvf2_(texcoord: ptr<function, vec2<f32>>) -> vec3<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e26 = (*texcoord);
    let _e27 = textureSample(texImage, texSampler, _e26);
    let _e28 = _e27.xyz;
    col[0u] = _e28.x;
    col[1u] = _e28.y;
    col[2u] = _e28.z;
    let _e35 = col;
    return _e35.xyz;
}

fn main_1() {
    var col_1: vec3<f32>;
    var st: vec2<f32>;
    var texelSize: vec2<f32>;
    var weights: array<f32, 5>;
    var BlurDir: vec2<f32>;
    var i: i32;
    var param: vec2<f32>;

    col_1 = vec3<f32>(0f, 0f, 0f);
    let _e31 = fUV_1;
    st = _e31;
    let _e32 = textureDimensions(texImage, 0i);
    texelSize = (vec2(1f) / vec2<f32>(vec2<i32>(_e32)));
    weights = array<f32, 5>(0.227027f, 0.316216f, 0.07027f, 0.002216f, 0.000167f);
    let _e38 = frag_ubo.IsXBlur;
    let _e42 = frag_ubo.IsXBlur;
    BlurDir = vec2<f32>(select(0f, 1f, (_e38 == 1i)), select(1f, 0f, (_e42 == 1i)));
    i = -4i;
    loop {
        let _e46 = i;
        if (_e46 <= 4i) {
            let _e48 = st;
            let _e49 = texelSize;
            let _e50 = i;
            let _e53 = BlurDir;
            param = (_e48 + ((_e49 * f32(_e50)) * _e53));
            let _e56 = GetTexColorvf2_((&param));
            let _e57 = i;
            let _e60 = weights[abs(_e57)];
            let _e62 = col_1;
            col_1 = (_e62 + (_e56 * _e60));
            continue;
        } else {
            break;
        }
        continuing {
            let _e64 = i;
            i = (_e64 + 1i);
        }
    }
    let _e66 = col_1;
    outColor = vec4<f32>(_e66.x, _e66.y, _e66.z, 1f);
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>, @location(1) v2f_ProjPos: vec4<f32>) -> @location(0) vec4<f32> {
    fUV_1 = fUV;
    v2f_ProjPos_1 = v2f_ProjPos;
    main_1();
    let _e5 = outColor;
    return _e5;
}
