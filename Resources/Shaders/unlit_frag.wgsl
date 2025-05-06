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

    col = vec4<f32>(1.0, 1.0, 1.0, 1.0);
    let _e26 = fUV_1;
    st = _e26;
    let _e28 = fbo_0_.useTexColor;
    if (_e28 != 0) {
        let _e31 = fbo_0_.useDirSampling;
        if (_e31 != 0) {
            pi = 3.1414999961853027;
            let _e34 = fViewDir_1[1u];
            theta = acos(_e34);
            let _e37 = fViewDir_1[2u];
            let _e39 = fViewDir_1[0u];
            phi = atan2(_e37, _e39);
            let _e41 = phi;
            let _e42 = pi;
            let _e45 = theta;
            let _e46 = pi;
            st = vec2<f32>((_e41 / (2.0 * _e42)), (_e45 / _e46));
        }
        let _e49 = st;
        let _e50 = textureSample(texImage, texSampler, _e49);
        let _e52 = col;
        let _e54 = (_e52.xyz * _e50.xyz);
        col[0u] = _e54.x;
        col[1u] = _e54.y;
        col[2u] = _e54.z;
    }
    let _e62 = fbo_0_.baseColor;
    let _e64 = col;
    let _e66 = (_e64.xyz * _e62.xyz);
    col[0u] = _e66.x;
    col[1u] = _e66.y;
    col[2u] = _e66.z;
    let _e73 = col;
    outColor = _e73;
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
