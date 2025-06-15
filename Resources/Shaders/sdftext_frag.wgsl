struct FragUniformBufferObject {
    pad0_: mat4x4<f32>,
    pad1_: mat4x4<f32>,
    pad2_: mat4x4<f32>,
    pad3_: mat4x4<f32>,
    maxWidth: f32,
    charWidth: f32,
    numOfChar: f32,
    textID: f32,
}

var<private> fUV_1: vec2<f32>;
@group(0) @binding(1) 
var<uniform> f_ubo: FragUniformBufferObject;
@group(0) @binding(2) 
var MainTexture: texture_2d<f32>;
@group(0) @binding(3) 
var MainTextureSampler: sampler;
var<private> outCol: vec4<f32>;
var<private> fWolrdNormal_1: vec3<f32>;
var<private> fViewDir_1: vec3<f32>;

fn main_1() {
    var col: vec4<f32>;
    var st: vec2<f32>;
    var uvCharW: f32;
    var dist: f32;
    var t: f32;
    var alpha: f32;

    col = vec4<f32>(0f, 0f, 0f, 1f);
    let _e25 = fUV_1;
    st = _e25;
    let _e27 = f_ubo.maxWidth;
    let _e30 = f_ubo.charWidth;
    uvCharW = ((1f / _e27) * _e30);
    let _e32 = uvCharW;
    let _e34 = st[0u];
    st[0u] = (_e34 * _e32);
    let _e37 = uvCharW;
    let _e39 = f_ubo.textID;
    let _e43 = st[0u];
    st[0u] = (_e43 + (_e37 * floor(_e39)));
    let _e47 = st[0u];
    let _e49 = st[1u];
    let _e52 = textureSample(MainTexture, MainTextureSampler, vec2<f32>(_e47, (1f - _e49)));
    dist = _e52.x;
    t = 0.5f;
    let _e54 = t;
    let _e56 = t;
    let _e58 = dist;
    alpha = smoothstep((_e54 - 0.01f), (_e56 + 0.01f), _e58);
    let _e60 = alpha;
    if (_e60 > 0.5f) {
        col[0u] = vec3<f32>(1f, 1f, 1f).x;
        col[1u] = vec3<f32>(1f, 1f, 1f).y;
        col[2u] = vec3<f32>(1f, 1f, 1f).z;
    } else {
        discard;
    }
    let _e68 = col;
    outCol = _e68;
    return;
}

@fragment 
fn main(@location(1) fUV: vec2<f32>, @location(0) fWolrdNormal: vec3<f32>, @location(2) fViewDir: vec3<f32>) -> @location(0) vec4<f32> {
    fUV_1 = fUV;
    fWolrdNormal_1 = fWolrdNormal;
    fViewDir_1 = fViewDir;
    main_1();
    let _e7 = outCol;
    return _e7;
}
