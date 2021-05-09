#version 450

layout (binding = 0) uniform texture2D textureColor;
layout (binding = 1) uniform sampler samplerColor;

layout (location = 0) in vec2 inUV;
layout (location = 0) out vec4 outColor;

void main() 
{
	outColor = texture(sampler2D(textureColor, samplerColor), inUV);
}