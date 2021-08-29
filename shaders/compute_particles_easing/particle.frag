#version 450

layout(location = 0) in vec2 tUV;
layout(location = 1) in float vAlpha;

layout(set = 0, binding = 0) uniform sampler uSampler;
layout(set = 0, binding = 1) uniform texture2D uTexture;

layout(location = 0) out vec4 outColor;

void main() {
    outColor =  texture(sampler2D(uTexture, uSampler), tUV);
    outColor.rgb = mix(outColor.rgb,vec3(vAlpha,0,0),1-vAlpha);

    outColor.a *= vAlpha;
}
