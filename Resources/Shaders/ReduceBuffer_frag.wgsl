@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
var<private> fUV_1: vec2<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;

fn GetTexColorvf2_(texcoord: ptr<function, vec2<f32>>) -> vec3<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e22 = (*texcoord);
    let _e23 = textureSample(texImage, texSampler, _e22);
    let _e24 = _e23.xyz;
    col[0u] = _e24.x;
    col[1u] = _e24.y;
    col[2u] = _e24.z;
    let _e31 = col;
    return _e31.xyz;
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

    col_1 = vec3<f32>(0f, 0f, 0f);
    let _e28 = fUV_1;
    st = _e28;
    let _e29 = textureDimensions(texImage, 0i);
    texelSize = (vec2(1f) / vec2<f32>(vec2<i32>(_e29)));
    let _e34 = st;
    param = _e34;
    let _e35 = GetTexColorvf2_((&param));
    let _e36 = col_1;
    col_1 = (_e36 + _e35);
    let _e38 = st;
    let _e39 = texelSize;
    param_1 = (_e38 + (_e39 * vec2<f32>(-0.5f, -0.5f)));
    let _e42 = GetTexColorvf2_((&param_1));
    let _e43 = col_1;
    col_1 = (_e43 + _e42);
    let _e45 = st;
    let _e46 = texelSize;
    param_2 = (_e45 + (_e46 * vec2<f32>(-0.5f, 0.5f)));
    let _e49 = GetTexColorvf2_((&param_2));
    let _e50 = col_1;
    col_1 = (_e50 + _e49);
    let _e52 = st;
    let _e53 = texelSize;
    param_3 = (_e52 + (_e53 * vec2<f32>(0.5f, -0.5f)));
    let _e56 = GetTexColorvf2_((&param_3));
    let _e57 = col_1;
    col_1 = (_e57 + _e56);
    let _e59 = st;
    let _e60 = texelSize;
    param_4 = (_e59 + (_e60 * vec2<f32>(0.5f, 0.5f)));
    let _e63 = GetTexColorvf2_((&param_4));
    let _e64 = col_1;
    col_1 = (_e64 + _e63);
    let _e66 = col_1;
    col_1 = (_e66 * 0.2f);
    let _e68 = col_1;
    outColor = vec4<f32>(_e68.x, _e68.y, _e68.z, 1f);
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
