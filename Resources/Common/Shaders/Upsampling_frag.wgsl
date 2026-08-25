struct FragUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    filterRadius: f32,
    fPad0_: f32,
    fPad1_: f32,
    fPad2_: f32,
}

@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
@group(0) @binding(2) 
var<uniform> frag_ubo: FragUniformBuffer;
var<private> v2f_UV_1: vec2<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;

fn GetTexColor_u0028_vf2_u003b(texcoord: ptr<function, vec2<f32>>) -> vec4<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e17 = (*texcoord);
    let _e18 = textureSample(texImage, texSampler, _e17);
    col = _e18;
    let _e19 = col;
    return _e19;
}

fn main_1() {
    var x: f32;
    var y: f32;
    var a: vec4<f32>;
    var param: vec2<f32>;
    var b: vec4<f32>;
    var param_1: vec2<f32>;
    var c: vec4<f32>;
    var param_2: vec2<f32>;
    var d: vec4<f32>;
    var param_3: vec2<f32>;
    var e: vec4<f32>;
    var param_4: vec2<f32>;
    var f: vec4<f32>;
    var param_5: vec2<f32>;
    var g: vec4<f32>;
    var param_6: vec2<f32>;
    var h: vec4<f32>;
    var param_7: vec2<f32>;
    var i: vec4<f32>;
    var param_8: vec2<f32>;
    var upsample: vec4<f32>;

    let _e37 = frag_ubo.filterRadius;
    x = _e37;
    let _e39 = frag_ubo.filterRadius;
    y = _e39;
    let _e41 = v2f_UV_1[0u];
    let _e42 = x;
    let _e45 = v2f_UV_1[1u];
    let _e46 = y;
    param = vec2<f32>((_e41 - _e42), (_e45 + _e46));
    let _e49 = GetTexColor_u0028_vf2_u003b((&param));
    a = _e49;
    let _e51 = v2f_UV_1[0u];
    let _e53 = v2f_UV_1[1u];
    let _e54 = y;
    param_1 = vec2<f32>(_e51, (_e53 + _e54));
    let _e57 = GetTexColor_u0028_vf2_u003b((&param_1));
    b = _e57;
    let _e59 = v2f_UV_1[0u];
    let _e60 = x;
    let _e63 = v2f_UV_1[1u];
    let _e64 = y;
    param_2 = vec2<f32>((_e59 + _e60), (_e63 + _e64));
    let _e67 = GetTexColor_u0028_vf2_u003b((&param_2));
    c = _e67;
    let _e69 = v2f_UV_1[0u];
    let _e70 = x;
    let _e73 = v2f_UV_1[1u];
    param_3 = vec2<f32>((_e69 - _e70), _e73);
    let _e75 = GetTexColor_u0028_vf2_u003b((&param_3));
    d = _e75;
    let _e77 = v2f_UV_1[0u];
    let _e79 = v2f_UV_1[1u];
    param_4 = vec2<f32>(_e77, _e79);
    let _e81 = GetTexColor_u0028_vf2_u003b((&param_4));
    e = _e81;
    let _e83 = v2f_UV_1[0u];
    let _e84 = x;
    let _e87 = v2f_UV_1[1u];
    param_5 = vec2<f32>((_e83 + _e84), _e87);
    let _e89 = GetTexColor_u0028_vf2_u003b((&param_5));
    f = _e89;
    let _e91 = v2f_UV_1[0u];
    let _e92 = x;
    let _e95 = v2f_UV_1[1u];
    let _e96 = y;
    param_6 = vec2<f32>((_e91 - _e92), (_e95 - _e96));
    let _e99 = GetTexColor_u0028_vf2_u003b((&param_6));
    g = _e99;
    let _e101 = v2f_UV_1[0u];
    let _e103 = v2f_UV_1[1u];
    let _e104 = y;
    param_7 = vec2<f32>(_e101, (_e103 - _e104));
    let _e107 = GetTexColor_u0028_vf2_u003b((&param_7));
    h = _e107;
    let _e109 = v2f_UV_1[0u];
    let _e110 = x;
    let _e113 = v2f_UV_1[1u];
    let _e114 = y;
    param_8 = vec2<f32>((_e109 + _e110), (_e113 - _e114));
    let _e117 = GetTexColor_u0028_vf2_u003b((&param_8));
    i = _e117;
    upsample = vec4<f32>(0f, 0f, 0f, 0f);
    let _e118 = e;
    upsample = (_e118 * 4f);
    let _e120 = b;
    let _e121 = d;
    let _e123 = f;
    let _e125 = h;
    let _e128 = upsample;
    upsample = (_e128 + ((((_e120 + _e121) + _e123) + _e125) * 2f));
    let _e130 = a;
    let _e131 = c;
    let _e133 = g;
    let _e135 = i;
    let _e137 = upsample;
    upsample = (_e137 + (((_e130 + _e131) + _e133) + _e135));
    let _e139 = upsample;
    upsample = (_e139 * 0.0625f);
    let _e141 = upsample;
    outColor = _e141;
    return;
}

@fragment 
fn main(@location(0) v2f_UV: vec2<f32>, @location(1) v2f_ProjPos: vec4<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    v2f_UV_1 = v2f_UV;
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e7 = outColor;
    return _e7;
}
