struct FragmentUniformBuffer {
    invModel: mat4x4<f32>,
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    cameraPos: vec4<f32>,
    mainColor: vec4<f32>,
    v4Pad1_: vec4<f32>,
    v4Pad2_: vec4<f32>,
    time: f32,
    fPad0_: f32,
    fPad1_: f32,
    fPad2_: f32,
}

struct FragmentOutput {
    @location(0) member: vec4<f32>,
    @location(1) member_1: vec4<f32>,
    @location(2) member_2: vec4<f32>,
    @location(3) member_3: vec4<f32>,
    @builtin(frag_depth) member_4: f32,
}

@group(0) @binding(1) 
var<uniform> f_ubo: FragmentUniformBuffer;
var<private> v2f_ObjectPos_1: vec4<f32>;
var<private> gl_FragCoord_1: vec4<f32>;
var<private> gPosition: vec4<f32>;
var<private> gNormal: vec4<f32>;
var<private> gAlbedo: vec4<f32>;
var<private> gDepth: vec4<f32>;
var<private> gl_FragDepth: f32 = 0f;

fn mapvf3_(p: ptr<function, vec3<f32>>) -> f32 {
    let _e21 = (*p);
    return (length(_e21) - 0.5f);
}

fn gnvf3_(p_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var e: vec2<f32>;
    var param: vec3<f32>;
    var param_1: vec3<f32>;
    var param_2: vec3<f32>;
    var param_3: vec3<f32>;
    var param_4: vec3<f32>;
    var param_5: vec3<f32>;

    e = vec2<f32>(0.0001f, 0f);
    let _e28 = (*p_1);
    let _e29 = e;
    param = (_e28 + _e29.xyy);
    let _e32 = mapvf3_((&param));
    let _e33 = (*p_1);
    let _e34 = e;
    param_1 = (_e33 - _e34.xyy);
    let _e37 = mapvf3_((&param_1));
    let _e39 = (*p_1);
    let _e40 = e;
    param_2 = (_e39 + _e40.yxy);
    let _e43 = mapvf3_((&param_2));
    let _e44 = (*p_1);
    let _e45 = e;
    param_3 = (_e44 - _e45.yxy);
    let _e48 = mapvf3_((&param_3));
    let _e50 = (*p_1);
    let _e51 = e;
    param_4 = (_e50 + _e51.yyx);
    let _e54 = mapvf3_((&param_4));
    let _e55 = (*p_1);
    let _e56 = e;
    param_5 = (_e55 - _e56.yyx);
    let _e59 = mapvf3_((&param_5));
    return normalize(vec3<f32>((_e32 - _e37), (_e43 - _e48), (_e54 - _e59)));
}

fn main_1() {
    var ro: vec3<f32>;
    var rd: vec3<f32>;
    var d: f32;
    var t: f32;
    var i: i32;
    var param_6: vec3<f32>;
    var p_2: vec3<f32>;
    var n: vec3<f32>;
    var param_7: vec3<f32>;
    var depth: f32;

    let _e31 = f_ubo.invModel;
    let _e33 = f_ubo.cameraPos;
    ro = (_e31 * _e33).xyz;
    let _e36 = v2f_ObjectPos_1;
    let _e38 = ro;
    rd = normalize((_e36.xyz - _e38));
    d = 1f;
    t = 0f;
    i = 0i;
    loop {
        let _e41 = i;
        if (_e41 < 64i) {
            let _e43 = ro;
            let _e44 = rd;
            let _e45 = t;
            param_6 = (_e43 + (_e44 * _e45));
            let _e48 = mapvf3_((&param_6));
            d = _e48;
            let _e49 = d;
            if (_e49 < 0.0001f) {
                break;
            }
            let _e51 = d;
            let _e52 = t;
            t = (_e52 + _e51);
            continue;
        } else {
            break;
        }
        continuing {
            let _e54 = i;
            i = (_e54 + 1i);
        }
    }
    let _e56 = d;
    let _e58 = t;
    if ((_e56 < 0.0001f) && (_e58 < 100f)) {
        let _e61 = ro;
        let _e62 = rd;
        let _e63 = t;
        p_2 = (_e61 + (_e62 * _e63));
        let _e66 = p_2;
        param_7 = _e66;
        let _e67 = gnvf3_((&param_7));
        n = _e67;
        let _e69 = gl_FragCoord_1[2u];
        depth = _e69;
        let _e70 = p_2;
        gPosition = vec4<f32>(_e70.x, _e70.y, _e70.z, 1f);
        let _e75 = n;
        gNormal = vec4<f32>(_e75.x, _e75.y, _e75.z, 1f);
        let _e81 = f_ubo.mainColor;
        gAlbedo = _e81;
        let _e82 = depth;
        gDepth = vec4(_e82);
        let _e84 = depth;
        gl_FragDepth = _e84;
    } else {
        discard;
    }
    return;
}

@fragment 
fn main(@location(0) v2f_ObjectPos: vec4<f32>, @builtin(position) gl_FragCoord: vec4<f32>) -> FragmentOutput {
    v2f_ObjectPos_1 = v2f_ObjectPos;
    gl_FragCoord_1 = gl_FragCoord;
    main_1();
    let _e9 = gPosition;
    let _e10 = gNormal;
    let _e11 = gAlbedo;
    let _e12 = gDepth;
    let _e13 = gl_FragDepth;
    return FragmentOutput(_e9, _e10, _e11, _e12, _e13);
}
