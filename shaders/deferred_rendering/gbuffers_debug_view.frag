#version 450
#extension GL_EXT_samplerless_texture_functions : require

layout(set=0, binding=0) uniform texture2D gBufferPosition;
layout(set=0, binding=1) uniform texture2D gBufferNormal;
layout(set=0, binding=2) uniform texture2D gBufferAlbedo;

layout(set=1, binding=0) uniform SurfaceConstants {
  vec2 size;
} surface;

layout(location = 0) out vec4 outColor;

void main() {
    vec2 c = gl_FragCoord.xy / surface.size;
    if (c.x < 0.33333) {
        outColor = texelFetch(gBufferPosition, ivec2(gl_FragCoord.xy), 0);
    } else if (c.x < 0.66667) {
        outColor = texelFetch(gBufferNormal, ivec2(gl_FragCoord.xy), 0);
        outColor.x = (outColor.x + 1.0) * 0.5;
        outColor.y = (outColor.y + 1.0) * 0.5;
        outColor.z = (outColor.z + 1.0) * 0.5;
    } else {
        outColor = texelFetch(gBufferAlbedo, ivec2(gl_FragCoord.xy), 0);
    }
}
