@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
var<private> fUV_1: vec2<f32>;
var<private> outColor: vec4<f32>;

fn GetTexColorvf2_(texcoord: ptr<function, vec2<f32>>) -> vec3<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0.0, 0.0, 0.0, 0.0);
    let _e25 = (*texcoord);
    let _e26 = textureSample(texImage, texSampler, _e25);
    let _e27 = _e26.xyz;
    col[0u] = _e27.x;
    col[1u] = _e27.y;
    col[2u] = _e27.z;
    let _e34 = col;
    return _e34.xyz;
}

fn main_1() {
    var col_1: vec3<f32>;
    var st: vec2<f32>;
    var texelSize: vec2<f32>;
    var param: vec2<f32>;
    var param_1: vec2<f32>;
    var param_2: vec2<f32>;
    var param_3: vec2<f32>;
    var param_4: vec2<f32>;

    col_1 = vec3<f32>(0.0, 0.0, 0.0);
    let _e31 = fUV_1;
    st = _e31;
    let _e32 = textureDimensions(texImage, 0);
    texelSize = (vec2<f32>(1.0) / vec2<f32>(vec2<i32>(_e32)));
    let _e37 = st;
    param = _e37;
    let _e38 = GetTexColorvf2_((&param));
    let _e39 = col_1;
    col_1 = (_e39 + _e38);
    let _e41 = st;
    let _e42 = texelSize;
    param_1 = (_e41 + (_e42 * vec2<f32>(-0.5, -0.5)));
    let _e45 = GetTexColorvf2_((&param_1));
    let _e46 = col_1;
    col_1 = (_e46 + _e45);
    let _e48 = st;
    let _e49 = texelSize;
    param_2 = (_e48 + (_e49 * vec2<f32>(-0.5, 0.5)));
    let _e52 = GetTexColorvf2_((&param_2));
    let _e53 = col_1;
    col_1 = (_e53 + _e52);
    let _e55 = st;
    let _e56 = texelSize;
    param_3 = (_e55 + (_e56 * vec2<f32>(0.5, -0.5)));
    let _e59 = GetTexColorvf2_((&param_3));
    let _e60 = col_1;
    col_1 = (_e60 + _e59);
    let _e62 = st;
    let _e63 = texelSize;
    param_4 = (_e62 + (_e63 * vec2<f32>(0.5, 0.5)));
    let _e66 = GetTexColorvf2_((&param_4));
    let _e67 = col_1;
    col_1 = (_e67 + _e66);
    let _e69 = col_1;
    col_1 = (_e69 * 0.20000000298023224);
    let _e71 = col_1;
    outColor = vec4<f32>(_e71.x, _e71.y, _e71.z, 1.0);
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>) -> @location(0) vec4<f32> {
    fUV_1 = fUV;
    main_1();
    let _e3 = outColor;
    return _e3;
}
