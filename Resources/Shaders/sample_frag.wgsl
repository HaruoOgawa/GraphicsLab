var<private> outColor: vec4<f32>;
var<private> f_Color_1: vec4<f32>;
var<private> f_WorldNormal_1: vec3<f32>;
var<private> f_Texcoord_1: vec2<f32>;
var<private> f_WorldPos_1: vec4<f32>;

fn main_1() {
    let _e9 = f_Color_1;
    outColor = _e9;
    return;
}

@fragment 
fn main(@location(3) f_Color: vec4<f32>, @location(0) f_WorldNormal: vec3<f32>, @location(1) f_Texcoord: vec2<f32>, @location(2) f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    f_Color_1 = f_Color;
    f_WorldNormal_1 = f_WorldNormal;
    f_Texcoord_1 = f_Texcoord;
    f_WorldPos_1 = f_WorldPos;
    main_1();
    let _e9 = outColor;
    return _e9;
}
