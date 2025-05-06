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

    col = vec3<f32>(1.0, 1.0, 1.0);
    alpha = 1.0;
    let _e47 = f_WorldNormal_1;
    let _e49 = fragUbo.lightDir;
    NdotL = max(0.0, dot(_e47, -(_e49.xyz)));
    let _e55 = fragUbo.cameraPos;
    let _e57 = f_WorldPos_1;
    v = normalize((_e55.xyz - _e57.xyz));
    let _e62 = fragUbo.lightDir;
    l = (_e62.xyz * -1.0);
    let _e65 = v;
    let _e66 = l;
    HalfVector = normalize((_e65 + _e66));
    let _e70 = fragUbo.diffuseFactor;
    diffuseColor = _e70;
    let _e72 = fragUbo.UseToonTexture;
    if (_e72 == 0) {
    }
    let _e75 = fragUbo.UseMainTexture;
    if (_e75 != 0) {
        let _e77 = f_Texcoord_1;
        let _e78 = textureSample(MainTexture, MainTextureSampler, _e77);
        MainColor = _e78;
        let _e79 = MainColor;
        let _e80 = diffuseColor;
        diffuseColor = (_e80 * _e79);
    }
    let _e82 = diffuseColor;
    col = _e82.xyz;
    let _e85 = diffuseColor[3u];
    alpha = _e85;
    let _e87 = fragUbo.UseSphereTexture;
    if (_e87 != 0) {
        let _e89 = f_SphereUV_1;
        let _e90 = textureSample(SphereTexture, SphereTextureSampler, _e89);
        SphereColor = _e90.xyz;
        let _e93 = fragUbo.SphereMode;
        if (_e93 == 1) {
            let _e95 = SphereColor;
            let _e96 = col;
            col = (_e96 * _e95);
        } else {
            let _e99 = fragUbo.SphereMode;
            if (_e99 == 2) {
                let _e101 = SphereColor;
                let _e102 = col;
                col = (_e102 + _e101);
            }
        }
    }
    let _e105 = fragUbo.UseToonTexture;
    if (_e105 != 0) {
        let _e107 = NdotL;
        let _e109 = textureSample(ToonTexture, ToonTextureSampler, vec2<f32>(0.0, _e107));
        ToonColor = _e109.xyz;
        let _e111 = ToonColor;
        let _e112 = NdotL;
        let _e118 = col;
        col = (_e118 * mix(_e111, vec3<f32>(1.0, 1.0, 1.0), vec3<f32>(clamp(((_e112 * 16.0) + 0.5), 0.0, 1.0))));
    }
    let _e121 = fragUbo.specularIntensity;
    if (_e121 > 0.0) {
        let _e124 = fragUbo.specularFactor;
        let _e126 = HalfVector;
        let _e127 = f_WorldNormal_1;
        let _e131 = fragUbo.specularIntensity;
        specularColor = (_e124.xyz * pow(max(0.0, dot(_e126, _e127)), _e131));
        let _e134 = specularColor;
        let _e135 = col;
        col = (_e135 + _e134);
    }
    let _e137 = col;
    let _e138 = alpha;
    outColor = vec4<f32>(_e137.x, _e137.y, _e137.z, _e138);
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
