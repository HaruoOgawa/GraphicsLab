@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
var<private> fUV_1: vec2<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;

fn LINEARtoSRGB_u0028_vf3_u003b(srgbIn: ptr<function, vec3<f32>>) -> vec3<f32> {
    let _e12 = (*srgbIn);
    return pow(_e12, vec3<f32>(0.45454547f, 0.45454547f, 0.45454547f));
}

fn GetTexCol_u0028_vf2_u003b(st: ptr<function, vec2<f32>>) -> vec4<f32> {
    var col: vec4<f32>;

    let _e13 = (*st);
    let _e14 = textureSample(texImage, texSampler, _e13);
    col = _e14;
    let _e15 = col;
    return _e15;
}

fn main_1() {
    var st_1: vec2<f32>;
    var col_1: vec4<f32>;
    var param: vec2<f32>;
    var param_1: vec3<f32>;

    let _e15 = fUV_1;
    st_1 = _e15;
    let _e16 = st_1;
    param = _e16;
    let _e17 = GetTexCol_u0028_vf2_u003b((&param));
    col_1 = _e17;
    let _e18 = col_1;
    param_1 = _e18.xyz;
    let _e20 = LINEARtoSRGB_u0028_vf3_u003b((&param_1));
    col_1[0u] = _e20.x;
    col_1[1u] = _e20.y;
    col_1[2u] = _e20.z;
    let _e27 = col_1;
    outColor = _e27;
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>, @location(1) v2f_ProjPos: vec4<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    fUV_1 = fUV;
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e7 = outColor;
    return _e7;
}
