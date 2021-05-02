#version 450

layout(set=0, binding=0) uniform sampler mySampler;
layout(set=0, binding=1) uniform texture2D gBufferPosition;
layout(set=0, binding=2) uniform texture2D gBufferNormal;
layout(set=0, binding=3) uniform texture2D gBufferAlbedo;

layout(set=1, binding=0) uniform SurfaceConstants {
  vec2 size;
} surface;

layout(location = 0) out vec4 outColor;

void main() {
    vec2 c = gl_FragCoord.xy / surface.size;
    if (c.x < 0.33333) {
        outColor = texture(sampler2D(gBufferPosition, mySampler), c);
    } else if (c.x < 0.66667) {
        outColor = texture(sampler2D(gBufferNormal, mySampler), c);
        outColor.x = (outColor.x + 1.0) * 0.5;
        outColor.y = (outColor.y + 1.0) * 0.5;
        outColor.z = (outColor.z + 1.0) * 0.5;
    } else {
        outColor = texture(sampler2D(gBufferAlbedo, mySampler), c);
    }
}
