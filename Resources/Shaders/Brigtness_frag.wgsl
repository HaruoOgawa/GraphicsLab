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

fn main_1() {
    var col: vec4<f32>;
    var st: vec2<f32>;
    var BrigtnessCol: vec4<f32>;

    col = vec4<f32>(1.0, 1.0, 1.0, 1.0);
    let _e22 = fUV_1;
    st = _e22;
    let _e23 = st;
    let _e24 = textureSample(texImage, texSampler, _e23);
    let _e25 = _e24.xyz;
    col[0u] = _e25.x;
    col[1u] = _e25.y;
    col[2u] = _e25.z;
    let _e32 = col;
    BrigtnessCol = _e32;
    let _e33 = BrigtnessCol;
    let _e36 = frag_ubo.Threshold;
    let _e41 = frag_ubo.Intencity;
    let _e42 = (max(vec3<f32>(0.0, 0.0, 0.0), (_e33.xyz - vec3<f32>(_e36))) * _e41);
    BrigtnessCol[0u] = _e42.x;
    BrigtnessCol[1u] = _e42.y;
    BrigtnessCol[2u] = _e42.z;
    let _e49 = col;
    outColor = _e49;
    let _e50 = BrigtnessCol;
    outBrigtnessColor = _e50;
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>) -> FragmentOutput {
    fUV_1 = fUV;
    main_1();
    let _e4 = outColor;
    let _e5 = outBrigtnessColor;
    return FragmentOutput(_e4, _e5);
}
