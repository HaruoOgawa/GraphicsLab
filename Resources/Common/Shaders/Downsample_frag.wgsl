struct FragUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
}

@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
var<private> v2f_UV_1: vec2<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;
@group(0) @binding(2) 
var<uniform> frag_ubo: FragUniformBuffer;

fn GetTexColor_u0028_vf2_u003b(texcoord: ptr<function, vec2<f32>>) -> vec3<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e21 = (*texcoord);
    let _e22 = textureSample(texImage, texSampler, _e21);
    let _e23 = _e22.xyz;
    col[0u] = _e23.x;
    col[1u] = _e23.y;
    col[2u] = _e23.z;
    let _e30 = col;
    return _e30.xyz;
}

fn GetTextureSize_u0028_() -> vec2<f32> {
    var texSize: vec2<f32>;

    let _e20 = textureDimensions(texImage, 0i);
    texSize = vec2<f32>(vec2<i32>(_e20));
    let _e23 = texSize;
    return _e23;
}

fn main_1() {
    var texSize_1: vec2<f32>;
    var x: f32;
    var y: f32;
    var a: vec3<f32>;
    var param: vec2<f32>;
    var b: vec3<f32>;
    var param_1: vec2<f32>;
    var c: vec3<f32>;
    var param_2: vec2<f32>;
    var d: vec3<f32>;
    var param_3: vec2<f32>;
    var e: vec3<f32>;
    var param_4: vec2<f32>;
    var f: vec3<f32>;
    var param_5: vec2<f32>;
    var g: vec3<f32>;
    var param_6: vec2<f32>;
    var h: vec3<f32>;
    var param_7: vec2<f32>;
    var i: vec3<f32>;
    var param_8: vec2<f32>;
    var j: vec3<f32>;
    var param_9: vec2<f32>;
    var k: vec3<f32>;
    var param_10: vec2<f32>;
    var l: vec3<f32>;
    var param_11: vec2<f32>;
    var m: vec3<f32>;
    var param_12: vec2<f32>;
    var downsample: vec3<f32>;

    let _e49 = GetTextureSize_u0028_();
    texSize_1 = _e49;
    let _e51 = texSize_1[0u];
    x = (1f / _e51);
    let _e54 = texSize_1[1u];
    y = (1f / _e54);
    let _e57 = v2f_UV_1[0u];
    let _e58 = x;
    let _e62 = v2f_UV_1[1u];
    let _e63 = y;
    param = vec2<f32>((_e57 - (2f * _e58)), (_e62 + (2f * _e63)));
    let _e67 = GetTexColor_u0028_vf2_u003b((&param));
    a = _e67;
    let _e69 = v2f_UV_1[0u];
    let _e71 = v2f_UV_1[1u];
    let _e72 = y;
    param_1 = vec2<f32>(_e69, (_e71 + (2f * _e72)));
    let _e76 = GetTexColor_u0028_vf2_u003b((&param_1));
    b = _e76;
    let _e78 = v2f_UV_1[0u];
    let _e79 = x;
    let _e83 = v2f_UV_1[1u];
    let _e84 = y;
    param_2 = vec2<f32>((_e78 + (2f * _e79)), (_e83 + (2f * _e84)));
    let _e88 = GetTexColor_u0028_vf2_u003b((&param_2));
    c = _e88;
    let _e90 = v2f_UV_1[0u];
    let _e91 = x;
    let _e95 = v2f_UV_1[1u];
    param_3 = vec2<f32>((_e90 - (2f * _e91)), _e95);
    let _e97 = GetTexColor_u0028_vf2_u003b((&param_3));
    d = _e97;
    let _e99 = v2f_UV_1[0u];
    let _e101 = v2f_UV_1[1u];
    param_4 = vec2<f32>(_e99, _e101);
    let _e103 = GetTexColor_u0028_vf2_u003b((&param_4));
    e = _e103;
    let _e105 = v2f_UV_1[0u];
    let _e106 = x;
    let _e110 = v2f_UV_1[1u];
    param_5 = vec2<f32>((_e105 + (2f * _e106)), _e110);
    let _e112 = GetTexColor_u0028_vf2_u003b((&param_5));
    f = _e112;
    let _e114 = v2f_UV_1[0u];
    let _e115 = x;
    let _e119 = v2f_UV_1[1u];
    let _e120 = y;
    param_6 = vec2<f32>((_e114 - (2f * _e115)), (_e119 - (2f * _e120)));
    let _e124 = GetTexColor_u0028_vf2_u003b((&param_6));
    g = _e124;
    let _e126 = v2f_UV_1[0u];
    let _e128 = v2f_UV_1[1u];
    let _e129 = y;
    param_7 = vec2<f32>(_e126, (_e128 - (2f * _e129)));
    let _e133 = GetTexColor_u0028_vf2_u003b((&param_7));
    h = _e133;
    let _e135 = v2f_UV_1[0u];
    let _e136 = x;
    let _e140 = v2f_UV_1[1u];
    let _e141 = y;
    param_8 = vec2<f32>((_e135 + (2f * _e136)), (_e140 - (2f * _e141)));
    let _e145 = GetTexColor_u0028_vf2_u003b((&param_8));
    i = _e145;
    let _e147 = v2f_UV_1[0u];
    let _e148 = x;
    let _e151 = v2f_UV_1[1u];
    let _e152 = y;
    param_9 = vec2<f32>((_e147 - _e148), (_e151 + _e152));
    let _e155 = GetTexColor_u0028_vf2_u003b((&param_9));
    j = _e155;
    let _e157 = v2f_UV_1[0u];
    let _e158 = x;
    let _e161 = v2f_UV_1[1u];
    let _e162 = y;
    param_10 = vec2<f32>((_e157 + _e158), (_e161 + _e162));
    let _e165 = GetTexColor_u0028_vf2_u003b((&param_10));
    k = _e165;
    let _e167 = v2f_UV_1[0u];
    let _e168 = x;
    let _e171 = v2f_UV_1[1u];
    let _e172 = y;
    param_11 = vec2<f32>((_e167 - _e168), (_e171 - _e172));
    let _e175 = GetTexColor_u0028_vf2_u003b((&param_11));
    l = _e175;
    let _e177 = v2f_UV_1[0u];
    let _e178 = x;
    let _e181 = v2f_UV_1[1u];
    let _e182 = y;
    param_12 = vec2<f32>((_e177 + _e178), (_e181 - _e182));
    let _e185 = GetTexColor_u0028_vf2_u003b((&param_12));
    m = _e185;
    downsample = vec3<f32>(0f, 0f, 0f);
    let _e186 = e;
    downsample = (_e186 * 0.125f);
    let _e188 = j;
    let _e189 = k;
    let _e191 = l;
    let _e193 = m;
    let _e196 = downsample;
    downsample = (_e196 + ((((_e188 + _e189) + _e191) + _e193) * 0.125f));
    let _e198 = b;
    let _e199 = d;
    let _e201 = f;
    let _e203 = h;
    let _e206 = downsample;
    downsample = (_e206 + ((((_e198 + _e199) + _e201) + _e203) * 0.0625f));
    let _e208 = a;
    let _e209 = c;
    let _e211 = g;
    let _e213 = i;
    let _e216 = downsample;
    downsample = (_e216 + ((((_e208 + _e209) + _e211) + _e213) * 0.03125f));
    let _e218 = downsample;
    outColor = vec4<f32>(_e218.x, _e218.y, _e218.z, 1f);
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
