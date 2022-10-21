// Modification of
//
// Equirectangular image viewer
// By rosme
// https://www.shadertoy.com/view/4lK3DK

#define PI 3.14159265
#define DEG2RAD 0.01745329251994329576923690768489

// tools
vec3 rotateXY(vec3 p, vec2 angle) {
    vec2 c = cos(angle), s = sin(angle);
    p = vec3(p.x, c.x*p.y + s.x*p.z, -s.x*p.y + c.x*p.z);
    return vec3(c.y*p.x + s.y*p.z, p.y, -s.y*p.x + c.y*p.z);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // place 0,0 in center from -1 to 1 ndc
    vec2 uv = fragCoord.xy * 2./iResolution.xy - 1.;

    // Flip x and y
    uv *= vec2(-1.0, -1.0);

    // Compensate for flipped axises
    iMouse.y = iResolution.y - iMouse.y;

    // to spherical
    vec3 camDir = normalize(vec3(uv.xy * vec2(tan(0.5 * iHFovDegrees * DEG2RAD), tan(0.5 * iVFovDegrees * DEG2RAD)), 1.0));

    // camRot is angle vec in rad
    vec3 camRot = vec3( ((iMouse.xy / iResolution.xy) - 0.5) * vec2(2.0 * PI,  PI), 0.);

    // rotate
    vec3 rd = normalize(rotateXY(camDir, camRot.yx));

    // radial azmuth polar
    vec2 texCoord = vec2(atan(rd.z, rd.x) + PI, acos(-rd.y)) / vec2(2.0 * PI, PI);

    // Input visualization
    fragCoord.y = iVisualizeInput ? iResolution.y - fragCoord.y : fragCoord.y;
    texCoord = iVisualizeInput ? (fragCoord.xy/iResolution.xy) : texCoord;

    fragColor = texture(sampler2D(iChannel0Texture, iChannel0TextureSampler), texCoord);
}
