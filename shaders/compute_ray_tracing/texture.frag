#version 450

layout (binding = 0) uniform texture2D colorTexture;
layout (binding = 1) uniform sampler colorSampler;

layout (location = 0) in vec2 inUV;

layout (location = 0) out vec4 outFragColor;

void main() 
{
  outFragColor = texture(sampler2D(colorTexture, colorSampler), vec2(inUV.s, 1.0 - inUV.t));
}