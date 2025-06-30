var<private> fUV_1: vec2<f32>;
@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
@group(0) @binding(2) 
var bloomImage: texture_2d<f32>;
@group(0) @binding(3) 
var bloomSampler: sampler;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;

fn main_1() {
    var col: vec3<f32>;
    var st: vec2<f32>;
    var mainCol: vec3<f32>;
    var bloomCol: vec3<f32>;

    col = vec3<f32>(0f, 0f, 0f);
    let _e14 = fUV_1;
    st = _e14;
    let _e15 = st;
    let _e16 = textureSample(texImage, texSampler, _e15);
    mainCol = _e16.xyz;
    let _e18 = st;
    let _e19 = textureSample(bloomImage, bloomSampler, _e18);
    bloomCol = _e19.xyz;
    let _e21 = mainCol;
    let _e22 = bloomCol;
    col = (_e21 + _e22);
    let _e24 = col;
    outColor = vec4<f32>(_e24.x, _e24.y, _e24.z, 1f);
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
