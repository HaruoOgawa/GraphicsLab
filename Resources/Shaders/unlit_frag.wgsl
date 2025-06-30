struct FragBufferObject_0_ {
    useDirSampling: i32,
    time: f32,
    useTexColor: i32,
    useColor: i32,
    baseColor: vec4<f32>,
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
}

var<private> fUV_1: vec2<f32>;
@group(0) @binding(1) 
var<uniform> fbo_0_: FragBufferObject_0_;
var<private> fViewDir_1: vec3<f32>;
@group(0) @binding(2) 
var texImage: texture_2d<f32>;
@group(0) @binding(3) 
var texSampler: sampler;
var<private> outColor: vec4<f32>;
var<private> fWolrdNormal_1: vec3<f32>;

fn main_1() {
    var col: vec4<f32>;
    var st: vec2<f32>;
    var pi: f32;
    var theta: f32;
    var phi: f32;

    col = vec4<f32>(1f, 1f, 1f, 1f);
    let _e22 = fUV_1;
    st = _e22;
    let _e24 = fbo_0_.useTexColor;
    if (_e24 != 0i) {
        let _e27 = fbo_0_.useDirSampling;
        if (_e27 != 0i) {
            pi = 3.1415f;
            let _e30 = fViewDir_1[1u];
            theta = acos(_e30);
            let _e33 = fViewDir_1[2u];
            let _e35 = fViewDir_1[0u];
            phi = atan2(_e33, _e35);
            let _e37 = phi;
            let _e38 = pi;
            let _e41 = theta;
            let _e42 = pi;
            st = vec2<f32>((_e37 / (2f * _e38)), (_e41 / _e42));
        }
        let _e45 = st;
        let _e46 = textureSample(texImage, texSampler, _e45);
        let _e48 = col;
        let _e50 = (_e48.xyz * _e46.xyz);
        col[0u] = _e50.x;
        col[1u] = _e50.y;
        col[2u] = _e50.z;
    }
    let _e58 = fbo_0_.baseColor;
    let _e60 = col;
    let _e62 = (_e60.xyz * _e58.xyz);
    col[0u] = _e62.x;
    col[1u] = _e62.y;
    col[2u] = _e62.z;
    let _e69 = col;
    outColor = _e69;
    return;
}

@fragment 
fn main(@location(1) fUV: vec2<f32>, @location(2) fViewDir: vec3<f32>, @location(0) fWolrdNormal: vec3<f32>) -> @location(0) vec4<f32> {
    fUV_1 = fUV;
    fViewDir_1 = fViewDir;
    fWolrdNormal_1 = fWolrdNormal;
    main_1();
    let _e7 = outColor;
    return _e7;
}
