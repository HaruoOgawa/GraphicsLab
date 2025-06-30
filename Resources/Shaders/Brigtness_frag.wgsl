struct FragUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    Threshold: f32,
    Intencity: f32,
    fPad0_: f32,
    fPad1_: f32,
}

struct FragmentOutput {
    @location(1) member: vec4<f32>,
    @location(0) member_1: vec4<f32>,
}

var<private> fUV_1: vec2<f32>;
@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
@group(0) @binding(2) 
var<uniform> frag_ubo: FragUniformBuffer;
var<private> outColor: vec4<f32>;
var<private> outBrigtnessColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;

fn main_1() {
    var col: vec4<f32>;
    var st: vec2<f32>;
    var BrigtnessCol: vec4<f32>;

    col = vec4<f32>(1f, 1f, 1f, 1f);
    let _e19 = fUV_1;
    st = _e19;
    let _e20 = st;
    let _e21 = textureSample(texImage, texSampler, _e20);
    let _e22 = _e21.xyz;
    col[0u] = _e22.x;
    col[1u] = _e22.y;
    col[2u] = _e22.z;
    let _e29 = col;
    BrigtnessCol = _e29;
    let _e30 = BrigtnessCol;
    let _e33 = frag_ubo.Threshold;
    let _e38 = frag_ubo.Intencity;
    let _e39 = (max(vec3<f32>(0f, 0f, 0f), (_e30.xyz - vec3(_e33))) * _e38);
    BrigtnessCol[0u] = _e39.x;
    BrigtnessCol[1u] = _e39.y;
    BrigtnessCol[2u] = _e39.z;
    let _e46 = col;
    outColor = _e46;
    let _e47 = BrigtnessCol;
    outBrigtnessColor = _e47;
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>, @location(1) v2f_ProjPos: vec4<f32>) -> FragmentOutput {
    fUV_1 = fUV;
    v2f_ProjPos_1 = v2f_ProjPos;
    main_1();
    let _e6 = outColor;
    let _e7 = outBrigtnessColor;
    return FragmentOutput(_e6, _e7);
}
