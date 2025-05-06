struct FragUniformBufferObject {
    edgeColor: vec4<f32>,
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
}

@group(0) @binding(2) 
var<uniform> fragUbo: FragUniformBufferObject;
var<private> outColor: vec4<f32>;
var<private> f_WorldNormal_1: vec3<f32>;
var<private> f_Texcoord_1: vec2<f32>;
var<private> f_WorldPos_1: vec4<f32>;
var<private> f_WorldTangent_1: vec3<f32>;
var<private> f_WorldBioTangent_1: vec3<f32>;
var<private> f_LightSpacePos_1: vec4<f32>;
var<private> f_SphereUV_1: vec2<f32>;

fn main_1() {
    var col: vec3<f32>;
    var alpha: f32;

    col = vec3<f32>(1.0, 1.0, 1.0);
    alpha = 1.0;
    let _e19 = fragUbo.edgeColor;
    col = _e19.xyz;
    let _e21 = col;
    let _e22 = alpha;
    outColor = vec4<f32>(_e21.x, _e21.y, _e21.z, _e22);
    return;
}

@fragment 
fn main(@location(0) f_WorldNormal: vec3<f32>, @location(1) f_Texcoord: vec2<f32>, @location(2) f_WorldPos: vec4<f32>, @location(3) f_WorldTangent: vec3<f32>, @location(4) f_WorldBioTangent: vec3<f32>, @location(5) f_LightSpacePos: vec4<f32>, @location(6) f_SphereUV: vec2<f32>) -> @location(0) vec4<f32> {
    f_WorldNormal_1 = f_WorldNormal;
    f_Texcoord_1 = f_Texcoord;
    f_WorldPos_1 = f_WorldPos;
    f_WorldTangent_1 = f_WorldTangent;
    f_WorldBioTangent_1 = f_WorldBioTangent;
    f_LightSpacePos_1 = f_LightSpacePos;
    f_SphereUV_1 = f_SphereUV;
    main_1();
    let _e15 = outColor;
    return _e15;
}
