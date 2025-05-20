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

fn main_1() {
    var col: vec3<f32>;
    var st: vec2<f32>;
    var mainCol: vec3<f32>;
    var bloomCol: vec3<f32>;

    col = vec3<f32>(0.0, 0.0, 0.0);
    let _e17 = fUV_1;
    st = _e17;
    let _e18 = st;
    let _e19 = textureSample(texImage, texSampler, _e18);
    mainCol = _e19.xyz;
    let _e21 = st;
    let _e22 = textureSample(bloomImage, bloomSampler, _e21);
    bloomCol = _e22.xyz;
    let _e24 = mainCol;
    let _e25 = bloomCol;
    col = (_e24 + _e25);
    let _e27 = col;
    outColor = vec4<f32>(_e27.x, _e27.y, _e27.z, 1.0);
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>) -> @location(0) vec4<f32> {
    fUV_1 = fUV;
    main_1();
    let _e3 = outColor;
    return _e3;
}
