@group(0) @binding(1) 
var depthMap: texture_2d<f32>;
@group(0) @binding(2) 
var depthSampler: sampler;
var<private> fragTexCoord_1: vec2<f32>;
var<private> outColor: vec4<f32>;

fn main_1() {
    var depth: f32;

    let _e9 = fragTexCoord_1[0u];
    let _e11 = fragTexCoord_1[1u];
    let _e14 = textureSample(depthMap, depthSampler, vec2<f32>(_e9, (1f - _e11)));
    depth = _e14.x;
    let _e16 = depth;
    let _e17 = vec3(_e16);
    outColor = vec4<f32>(_e17.x, _e17.y, _e17.z, 1f);
    return;
}

@fragment 
fn main(@location(0) fragTexCoord: vec2<f32>) -> @location(0) vec4<f32> {
    fragTexCoord_1 = fragTexCoord;
    main_1();
    let _e3 = outColor;
    return _e3;
}
