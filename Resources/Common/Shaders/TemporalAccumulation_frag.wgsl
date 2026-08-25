struct FragUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
}

@group(0) @binding(3) 
var newTexture: texture_2d<f32>;
@group(0) @binding(4) 
var newTextureSampler: sampler;
@group(0) @binding(5) 
var temporalTexture: texture_2d<f32>;
@group(0) @binding(6) 
var temporalTextureSampler: sampler;
@group(0) @binding(7) 
var velocityTexture: texture_2d<f32>;
@group(0) @binding(8) 
var velocityTextureSampler: sampler;
var<private> v2f_UV_1: vec2<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;
@group(0) @binding(2) 
var<uniform> frag_ubo: FragUniformBuffer;

fn GetNewTexture_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> vec4<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e25 = (*uv);
    let _e26 = textureSample(newTexture, newTextureSampler, _e25);
    col = _e26;
    let _e27 = col;
    return _e27;
}

fn GetTextureSize_u0028_() -> vec2<f32> {
    var texSize: vec2<f32>;

    let _e24 = textureDimensions(newTexture, 0i);
    texSize = vec2<f32>(vec2<i32>(_e24));
    let _e27 = texSize;
    return _e27;
}

fn GetTemporalTexture_u0028_vf2_u003b(uv_1: ptr<function, vec2<f32>>) -> vec4<f32> {
    var col_1: vec4<f32>;

    col_1 = vec4<f32>(0f, 0f, 0f, 0f);
    let _e25 = (*uv_1);
    let _e26 = textureSample(temporalTexture, temporalTextureSampler, _e25);
    col_1 = _e26;
    let _e27 = col_1;
    return _e27;
}

fn GetVelocityTexture_u0028_vf2_u003b(uv_2: ptr<function, vec2<f32>>) -> vec2<f32> {
    var velocity: vec2<f32>;

    let _e25 = (*uv_2);
    let _e26 = textureSample(velocityTexture, velocityTextureSampler, _e25);
    velocity = _e26.xy;
    let _e28 = velocity;
    return _e28;
}

fn SampleHistory_u0028_vf2_u003b(st: ptr<function, vec2<f32>>) -> vec4<f32> {
    var velocity_1: vec2<f32>;
    var param: vec2<f32>;
    var prevUV: vec2<f32>;
    var col_2: vec4<f32>;
    var param_1: vec2<f32>;
    var minColor: vec3<f32>;
    var maxColor: vec3<f32>;
    var texSize_1: vec2<f32>;
    var y: i32;
    var x: i32;
    var current: vec3<f32>;
    var param_2: vec2<f32>;
    var result: vec3<f32>;

    let _e37 = (*st);
    param = _e37;
    let _e38 = GetVelocityTexture_u0028_vf2_u003b((&param));
    velocity_1 = _e38;
    let _e39 = (*st);
    let _e40 = velocity_1;
    prevUV = (_e39 - _e40);
    let _e42 = prevUV;
    param_1 = _e42;
    let _e43 = GetTemporalTexture_u0028_vf2_u003b((&param_1));
    col_2 = _e43;
    minColor = vec3<f32>(9999f, 9999f, 9999f);
    maxColor = vec3<f32>(-9999f, -9999f, -9999f);
    let _e44 = GetTextureSize_u0028_();
    texSize_1 = _e44;
    y = -1i;
    loop {
        let _e45 = y;
        if (_e45 <= 1i) {
            x = -1i;
            loop {
                let _e47 = x;
                if (_e47 <= 1i) {
                    let _e49 = (*st);
                    let _e50 = x;
                    let _e52 = y;
                    let _e55 = texSize_1;
                    param_2 = (_e49 + (vec2<f32>(f32(_e50), f32(_e52)) / _e55));
                    let _e58 = GetNewTexture_u0028_vf2_u003b((&param_2));
                    current = _e58.xyz;
                    let _e60 = minColor;
                    let _e61 = current;
                    minColor = min(_e60, _e61);
                    let _e63 = maxColor;
                    let _e64 = current;
                    maxColor = max(_e63, _e64);
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e66 = x;
                    x = (_e66 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e68 = y;
            y = (_e68 + 1i);
        }
    }
    let _e70 = col_2;
    let _e72 = minColor;
    let _e73 = maxColor;
    result = clamp(_e70.xyz, _e72, _e73);
    let _e75 = result;
    return vec4<f32>(_e75.x, _e75.y, _e75.z, 1f);
}

fn main_1() {
    var new_: vec4<f32>;
    var param_3: vec2<f32>;
    var old: vec4<f32>;
    var param_4: vec2<f32>;

    let _e27 = v2f_UV_1;
    param_3 = _e27;
    let _e28 = GetNewTexture_u0028_vf2_u003b((&param_3));
    new_ = _e28;
    let _e29 = v2f_UV_1;
    param_4 = _e29;
    let _e30 = SampleHistory_u0028_vf2_u003b((&param_4));
    old = _e30;
    let _e31 = new_;
    let _e32 = old;
    outColor = mix(_e31, _e32, vec4(0.9f));
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
