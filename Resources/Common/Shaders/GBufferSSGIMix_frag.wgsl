struct GBufferResult {
    worldPos: vec3<f32>,
    worldNormal: vec3<f32>,
    albedo: vec4<f32>,
    depth: f32,
    materialType: f32,
    metallicRoughness: vec2<f32>,
    emissive: vec3<f32>,
}

struct LightUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
}

@group(0) @binding(2) 
var gPositionTexture: texture_2d<f32>;
@group(0) @binding(3) 
var gPositionTextureSampler: sampler;
@group(0) @binding(4) 
var gNormalTexture: texture_2d<f32>;
@group(0) @binding(5) 
var gNormalTextureSampler: sampler;
@group(0) @binding(6) 
var gAlbedoTexture: texture_2d<f32>;
@group(0) @binding(7) 
var gAlbedoTextureSampler: sampler;
@group(0) @binding(8) 
var gDepthTexture: texture_2d<f32>;
@group(0) @binding(9) 
var gDepthTextureSampler: sampler;
@group(0) @binding(10) 
var gCustomParam0Texture: texture_2d<f32>;
@group(0) @binding(11) 
var gCustomParam0TextureSampler: sampler;
@group(0) @binding(12) 
var gEmissionTexture: texture_2d<f32>;
@group(0) @binding(13) 
var gEmissionTextureSampler: sampler;
@group(0) @binding(16) 
var temporalTexture: texture_2d<f32>;
@group(0) @binding(17) 
var temporalTextureSampler: sampler;
@group(0) @binding(18) 
var mainResultTex: texture_2d<f32>;
@group(0) @binding(19) 
var mainResultTexSampler: sampler;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_UV_1: vec2<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;
@group(0) @binding(1) 
var<uniform> l_ubo: LightUniformBuffer;
@group(0) @binding(14) 
var gVelocityTexture: texture_2d<f32>;
@group(0) @binding(15) 
var gVelocityTextureSampler: sampler;

fn GetTemporalTexture_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> vec4<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e41 = (*uv);
    let _e42 = textureSample(temporalTexture, temporalTextureSampler, _e41);
    col = _e42;
    let _e43 = col;
    return _e43;
}

fn MixSSGI_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b(gResult: ptr<function, GBufferResult>, ScreenUV: ptr<function, vec2<f32>>) -> vec4<f32> {
    var temporal: vec4<f32>;
    var param: vec2<f32>;
    var albedo: vec3<f32>;

    let _e44 = (*ScreenUV);
    param = _e44;
    let _e45 = GetTemporalTexture_u0028_vf2_u003b((&param));
    temporal = _e45;
    let _e47 = temporal[0u];
    temporal[0u] = max(0f, _e47);
    let _e51 = temporal[1u];
    temporal[1u] = max(0f, _e51);
    let _e55 = temporal[2u];
    temporal[2u] = max(0f, _e55);
    let _e59 = temporal[3u];
    temporal[3u] = max(0f, _e59);
    let _e63 = (*gResult).albedo;
    albedo = _e63.xyz;
    let _e65 = temporal;
    return _e65;
}

fn GetMainResultTex_u0028_vf2_u003b(uv_1: ptr<function, vec2<f32>>) -> vec4<f32> {
    var col_1: vec4<f32>;

    col_1 = vec4<f32>(0f, 0f, 0f, 0f);
    let _e41 = (*uv_1);
    let _e42 = textureSample(mainResultTex, mainResultTexSampler, _e41);
    col_1 = _e42;
    let _e43 = col_1;
    return _e43;
}

fn GetEmission_u0028_vf2_u003b(ScreenUV_1: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Emission: vec4<f32>;

    let _e41 = (*ScreenUV_1);
    let _e42 = textureSample(gEmissionTexture, gEmissionTextureSampler, _e41);
    Emission = _e42;
    let _e43 = Emission;
    return _e43;
}

fn GetCustomParam0_u0028_vf2_u003b(ScreenUV_2: ptr<function, vec2<f32>>) -> vec4<f32> {
    var CustomParam0_: vec4<f32>;

    let _e41 = (*ScreenUV_2);
    let _e42 = textureSample(gCustomParam0Texture, gCustomParam0TextureSampler, _e41);
    CustomParam0_ = _e42;
    let _e43 = CustomParam0_;
    return _e43;
}

fn GetDepth_u0028_vf2_u003b(ScreenUV_3: ptr<function, vec2<f32>>) -> f32 {
    var Depth: f32;

    let _e41 = (*ScreenUV_3);
    let _e42 = textureSample(gDepthTexture, gDepthTextureSampler, _e41);
    Depth = _e42.x;
    let _e44 = Depth;
    return _e44;
}

fn GetAlbedo_u0028_vf2_u003b(ScreenUV_4: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Albedo: vec4<f32>;

    let _e41 = (*ScreenUV_4);
    let _e42 = textureSample(gAlbedoTexture, gAlbedoTextureSampler, _e41);
    Albedo = _e42;
    let _e43 = Albedo;
    return _e43;
}

fn GetWorldNormal_u0028_vf2_u003b(ScreenUV_5: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldNormal: vec3<f32>;

    let _e41 = (*ScreenUV_5);
    let _e42 = textureSample(gNormalTexture, gNormalTextureSampler, _e41);
    WorldNormal = _e42.xyz;
    let _e44 = WorldNormal;
    return _e44;
}

fn GetWorldPos_u0028_vf2_u003b(ScreenUV_6: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldPos: vec3<f32>;

    let _e41 = (*ScreenUV_6);
    let _e42 = textureSample(gPositionTexture, gPositionTextureSampler, _e41);
    WorldPos = _e42.xyz;
    let _e44 = WorldPos;
    return _e44;
}

fn GetGBuffer_u0028_vf2_u003b(ScreenUV_7: ptr<function, vec2<f32>>) -> GBufferResult {
    var gResult_1: GBufferResult;
    var param_1: vec2<f32>;
    var param_2: vec2<f32>;
    var param_3: vec2<f32>;
    var param_4: vec2<f32>;
    var CustomParam0_1: vec4<f32>;
    var param_5: vec2<f32>;
    var param_6: vec2<f32>;

    let _e48 = (*ScreenUV_7);
    param_1 = _e48;
    let _e49 = GetWorldPos_u0028_vf2_u003b((&param_1));
    gResult_1.worldPos = _e49;
    let _e51 = (*ScreenUV_7);
    param_2 = _e51;
    let _e52 = GetWorldNormal_u0028_vf2_u003b((&param_2));
    gResult_1.worldNormal = _e52;
    let _e54 = (*ScreenUV_7);
    param_3 = _e54;
    let _e55 = GetAlbedo_u0028_vf2_u003b((&param_3));
    gResult_1.albedo = _e55;
    let _e57 = (*ScreenUV_7);
    param_4 = _e57;
    let _e58 = GetDepth_u0028_vf2_u003b((&param_4));
    gResult_1.depth = _e58;
    let _e60 = (*ScreenUV_7);
    param_5 = _e60;
    let _e61 = GetCustomParam0_u0028_vf2_u003b((&param_5));
    CustomParam0_1 = _e61;
    let _e63 = CustomParam0_1[0u];
    gResult_1.materialType = _e63;
    let _e65 = CustomParam0_1;
    gResult_1.metallicRoughness = _e65.yz;
    let _e68 = (*ScreenUV_7);
    param_6 = _e68;
    let _e69 = GetEmission_u0028_vf2_u003b((&param_6));
    gResult_1.emissive = _e69.xyz;
    let _e72 = gResult_1;
    return _e72;
}

fn main_1() {
    var ScreenUV_8: vec2<f32>;
    var gResult_2: GBufferResult;
    var param_7: vec2<f32>;
    var mainResult: vec3<f32>;
    var param_8: vec2<f32>;
    var col_2: vec3<f32>;
    var giPower: f32;
    var param_9: GBufferResult;
    var param_10: vec2<f32>;

    let _e48 = v2f_ProjPos_1;
    let _e51 = v2f_ProjPos_1[3u];
    ScreenUV_8 = (_e48.xy / vec2(_e51));
    let _e54 = ScreenUV_8;
    ScreenUV_8 = ((_e54 * 0.5f) + vec2(0.5f));
    let _e58 = ScreenUV_8;
    param_7 = _e58;
    let _e59 = GetGBuffer_u0028_vf2_u003b((&param_7));
    gResult_2 = _e59;
    let _e60 = ScreenUV_8;
    param_8 = _e60;
    let _e61 = GetMainResultTex_u0028_vf2_u003b((&param_8));
    mainResult = _e61.xyz;
    let _e63 = mainResult;
    col_2 = _e63;
    let _e65 = gResult_2.materialType;
    if (_e65 == 1f) {
        giPower = 2f;
        let _e67 = gResult_2;
        param_9 = _e67;
        let _e68 = ScreenUV_8;
        param_10 = _e68;
        let _e69 = MixSSGI_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_vf2_u003b((&param_9), (&param_10));
        let _e71 = giPower;
        let _e73 = col_2;
        col_2 = (_e73 + (_e69.xyz * _e71));
    }
    let _e75 = col_2;
    outColor = vec4<f32>(_e75.x, _e75.y, _e75.z, 1f);
    return;
}

@fragment 
fn main(@location(1) v2f_ProjPos: vec4<f32>, @location(0) v2f_UV: vec2<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_UV_1 = v2f_UV;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e7 = outColor;
    return _e7;
}
