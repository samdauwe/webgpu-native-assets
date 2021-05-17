#version 450

layout(set = 0, binding = 0) uniform texture2D img;
layout(set = 0, binding = 1) uniform sampler imgSampler;

layout (location = 0) in vec2 texCoord;

layout (location = 0) out vec4 outFragColor;

void main() {
    outFragColor = texture(sampler2D(img, imgSampler), texCoord);
}
