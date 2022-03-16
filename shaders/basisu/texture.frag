#version 450

layout (binding = 1) uniform texture2D textureColor;
layout (binding = 2) uniform sampler samplerColor;

layout (location = 0) in vec2 inUV;

layout (location = 0) out vec4 outFragColor;

void main()
{
  outFragColor = texture(sampler2D(textureColor, samplerColor), inUV);
}
