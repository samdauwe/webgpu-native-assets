#version 450

layout (binding = 0) uniform texture2D textureColor0;
layout (binding = 1) uniform sampler samplerColor0;
layout (binding = 2) uniform texture2D textureColor1;
layout (binding = 3) uniform sampler samplerColor1;

layout (location = 0) in vec2 inUV;

layout (location = 0) out vec4 outColor;

void main() 
{
	outColor = texture(sampler2D(textureColor0, samplerColor0), inUV);
}