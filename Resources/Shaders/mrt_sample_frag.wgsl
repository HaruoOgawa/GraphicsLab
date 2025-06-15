struct Light {
    Posision: vec3<f32>,
    Color: vec3<f32>,
}

struct FragmentOutput {
    @location(0) member: vec4<f32>,
    @builtin(frag_depth) member_1: f32,
}

var<private> fUV_1: vec2<f32>;
@group(0) @binding(1) 
var texGPosition: texture_2d<f32>;
@group(0) @binding(2) 
var texGPositionSampler: sampler;
@group(0) @binding(3) 
var texGNormal: texture_2d<f32>;
@group(0) @binding(4) 
var texGNormalSampler: sampler;
@group(0) @binding(5) 
var texGAlbedo: texture_2d<f32>;
@group(0) @binding(6) 
var texGAlbedoSampler: sampler;
@group(0) @binding(7) 
var texDepth: texture_2d<f32>;
@group(0) @binding(8) 
var texDepthSampler: sampler;
var<private> outColor: vec4<f32>;
var<private> gl_FragDepth: f32 = 0f;
var<private> v2f_ProjPos_1: vec4<f32>;

fn main_1() {
    var col: vec4<f32>;
    var st: vec2<f32>;
    var id: vec2<f32>;
    var GPositionCol: vec4<f32>;
    var GNormalCol: vec4<f32>;
    var GAlbedoCol: vec4<f32>;
    var GDepthCol: vec4<f32>;
    var width: f32;
    var lightList: array<Light, 5>;
    var i: i32;
    var lightDir: vec3<f32>;
    var diffuse: vec3<f32>;

    col = vec4<f32>(0f, 0f, 0f, 1f);
    let _e46 = fUV_1;
    st = _e46;
    let _e47 = fUV_1;
    id = floor((_e47 * 2f));
    let _e50 = st;
    let _e51 = textureSample(texGPosition, texGPositionSampler, _e50);
    GPositionCol = _e51;
    let _e52 = st;
    let _e53 = textureSample(texGNormal, texGNormalSampler, _e52);
    GNormalCol = _e53;
    let _e54 = st;
    let _e55 = textureSample(texGAlbedo, texGAlbedoSampler, _e54);
    GAlbedoCol = _e55;
    let _e56 = st;
    let _e57 = textureSample(texDepth, texDepthSampler, _e56);
    GDepthCol = _e57;
    width = 3f;
    lightList[0i].Posision = vec3<f32>(0f, 1f, 0f);
    lightList[0i].Color = vec3<f32>(1f, 1f, 1f);
    let _e62 = width;
    lightList[1i].Posision = vec3<f32>((1f * _e62), 1f, 0f);
    lightList[1i].Color = vec3<f32>(1f, 0f, 0f);
    let _e69 = width;
    lightList[2i].Posision = vec3<f32>((-1f * _e69), 1f, 0f);
    lightList[2i].Color = vec3<f32>(0f, 1f, 0f);
    let _e76 = width;
    lightList[3i].Posision = vec3<f32>((-2f * _e76), 1f, 0f);
    lightList[3i].Color = vec3<f32>(0f, 0f, 1f);
    let _e83 = width;
    lightList[4i].Posision = vec3<f32>((-2f * _e83), 1f, 0f);
    lightList[4i].Color = vec3<f32>(1f, 0f, 1f);
    i = 0i;
    loop {
        let _e90 = i;
        if (_e90 < 5i) {
            let _e92 = i;
            let _e95 = lightList[_e92].Posision;
            let _e96 = GPositionCol;
            lightDir = normalize((_e95 - _e96.xyz));
            let _e100 = GNormalCol;
            let _e102 = lightDir;
            let _e105 = GAlbedoCol;
            let _e108 = i;
            let _e111 = lightList[_e108].Color;
            diffuse = ((_e105.xyz * max(0f, dot(_e100.xyz, _e102))) * _e111);
            let _e113 = diffuse;
            let _e114 = col;
            let _e116 = (_e114.xyz + _e113);
            col[0u] = _e116.x;
            col[1u] = _e116.y;
            col[2u] = _e116.z;
            continue;
        } else {
            break;
        }
        continuing {
            let _e123 = i;
            i = (_e123 + 1i);
        }
    }
    let _e125 = col;
    outColor = _e125;
    let _e127 = GDepthCol[0u];
    gl_FragDepth = _e127;
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>, @location(1) v2f_ProjPos: vec4<f32>) -> FragmentOutput {
    fUV_1 = fUV;
    v2f_ProjPos_1 = v2f_ProjPos;
    main_1();
    let _e6 = outColor;
    let _e7 = gl_FragDepth;
    return FragmentOutput(_e6, _e7);
}
