struct FragUniformBufferObject {
    lightDir: vec4<f32>,
    lightColor: vec4<f32>,
    cameraPos: vec4<f32>,
    diffuseFactor: vec4<f32>,
    ambientFactor: vec4<f32>,
    specularFactor: vec4<f32>,
    edgeColor: vec4<f32>,
    specularIntensity: f32,
    f_pad0_: f32,
    f_pad1_: f32,
    f_pad2_: f32,
    UseMainTexture: i32,
    UseToonTexture: i32,
    UseSphereTexture: i32,
    SphereMode: i32,
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
}

var<private> f_WorldNormal_1: vec3<f32>;
@group(0) @binding(2) 
var<uniform> fragUbo: FragUniformBufferObject;
var<private> f_WorldPos_1: vec4<f32>;
@group(0) @binding(3) 
var MainTexture: texture_2d<f32>;
@group(0) @binding(4) 
var MainTextureSampler: sampler;
var<private> f_Texcoord_1: vec2<f32>;
@group(0) @binding(7) 
var SphereTexture: texture_2d<f32>;
@group(0) @binding(8) 
var SphereTextureSampler: sampler;
var<private> f_SphereUV_1: vec2<f32>;
@group(0) @binding(5) 
var ToonTexture: texture_2d<f32>;
@group(0) @binding(6) 
var ToonTextureSampler: sampler;
var<private> outColor: vec4<f32>;
var<private> f_WorldTangent_1: vec3<f32>;
var<private> f_WorldBioTangent_1: vec3<f32>;
var<private> f_LightSpacePos_1: vec4<f32>;

fn main_1() {
    var col: vec3<f32>;
    var alpha: f32;
    var NdotL: f32;
    var v: vec3<f32>;
    var l: vec3<f32>;
    var HalfVector: vec3<f32>;
    var diffuseColor: vec4<f32>;
    var MainColor: vec4<f32>;
    var SphereColor: vec3<f32>;
    var ToonColor: vec3<f32>;
    var specularColor: vec3<f32>;

    col = vec3<f32>(1f, 1f, 1f);
    alpha = 1f;
    let _e43 = f_WorldNormal_1;
    let _e45 = fragUbo.lightDir;
    NdotL = max(0f, dot(_e43, -(_e45.xyz)));
    let _e51 = fragUbo.cameraPos;
    let _e53 = f_WorldPos_1;
    v = normalize((_e51.xyz - _e53.xyz));
    let _e58 = fragUbo.lightDir;
    l = (_e58.xyz * -1f);
    let _e61 = v;
    let _e62 = l;
    HalfVector = normalize((_e61 + _e62));
    let _e66 = fragUbo.diffuseFactor;
    diffuseColor = _e66;
    let _e68 = fragUbo.UseToonTexture;
    if (_e68 == 0i) {
    }
    let _e71 = fragUbo.UseMainTexture;
    if (_e71 != 0i) {
        let _e73 = f_Texcoord_1;
        let _e74 = textureSample(MainTexture, MainTextureSampler, _e73);
        MainColor = _e74;
        let _e75 = MainColor;
        let _e76 = diffuseColor;
        diffuseColor = (_e76 * _e75);
    }
    let _e78 = diffuseColor;
    col = _e78.xyz;
    let _e81 = diffuseColor[3u];
    alpha = _e81;
    let _e83 = fragUbo.UseSphereTexture;
    if (_e83 != 0i) {
        let _e85 = f_SphereUV_1;
        let _e86 = textureSample(SphereTexture, SphereTextureSampler, _e85);
        SphereColor = _e86.xyz;
        let _e89 = fragUbo.SphereMode;
        if (_e89 == 1i) {
            let _e91 = SphereColor;
            let _e92 = col;
            col = (_e92 * _e91);
        } else {
            let _e95 = fragUbo.SphereMode;
            if (_e95 == 2i) {
                let _e97 = SphereColor;
                let _e98 = col;
                col = (_e98 + _e97);
            }
        }
    }
    let _e101 = fragUbo.UseToonTexture;
    if (_e101 != 0i) {
        let _e103 = NdotL;
        let _e105 = textureSample(ToonTexture, ToonTextureSampler, vec2<f32>(0f, _e103));
        ToonColor = _e105.xyz;
        let _e107 = ToonColor;
        let _e108 = NdotL;
        let _e114 = col;
        col = (_e114 * mix(_e107, vec3<f32>(1f, 1f, 1f), vec3(clamp(((_e108 * 16f) + 0.5f), 0f, 1f))));
    }
    let _e117 = fragUbo.specularIntensity;
    if (_e117 > 0f) {
        let _e120 = fragUbo.specularFactor;
        let _e122 = HalfVector;
        let _e123 = f_WorldNormal_1;
        let _e127 = fragUbo.specularIntensity;
        specularColor = (_e120.xyz * pow(max(0f, dot(_e122, _e123)), _e127));
        let _e130 = specularColor;
        let _e131 = col;
        col = (_e131 + _e130);
    }
    let _e133 = col;
    let _e134 = alpha;
    outColor = vec4<f32>(_e133.x, _e133.y, _e133.z, _e134);
    return;
}

@fragment 
fn main(@location(0) f_WorldNormal: vec3<f32>, @location(2) f_WorldPos: vec4<f32>, @location(1) f_Texcoord: vec2<f32>, @location(6) f_SphereUV: vec2<f32>, @location(3) f_WorldTangent: vec3<f32>, @location(4) f_WorldBioTangent: vec3<f32>, @location(5) f_LightSpacePos: vec4<f32>) -> @location(0) vec4<f32> {
    f_WorldNormal_1 = f_WorldNormal;
    f_WorldPos_1 = f_WorldPos;
    f_Texcoord_1 = f_Texcoord;
    f_SphereUV_1 = f_SphereUV;
    f_WorldTangent_1 = f_WorldTangent;
    f_WorldBioTangent_1 = f_WorldBioTangent;
    f_LightSpacePos_1 = f_LightSpacePos;
    main_1();
    let _e15 = outColor;
    return _e15;
}
