var<private> fragColor_1: vec4<f32>;
var<private> outColor: vec4<f32>;
var<private> fragTexCoord_1: vec2<f32>;

fn main_1() {
    var col: vec3<f32>;

    col = vec3<f32>(0f, 0f, 0f);
    let _e7 = fragColor_1;
    col = _e7.xyz;
    let _e9 = col;
    outColor = vec4<f32>(_e9.x, _e9.y, _e9.z, 0.5f);
    return;
}

@fragment 
fn main(@location(1) fragColor: vec4<f32>, @location(0) fragTexCoord: vec2<f32>) -> @location(0) vec4<f32> {
    fragColor_1 = fragColor;
    fragTexCoord_1 = fragTexCoord;
    main_1();
    let _e5 = outColor;
    return _e5;
}
