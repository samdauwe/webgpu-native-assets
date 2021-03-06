#version 450 core

layout (location = 0) in vec2 inUV;

layout (binding = 0) uniform texture2D textureFont;
layout (binding = 1) uniform sampler samplerFont;

layout (location = 0) out vec4 outFragColor;

void main(void)
{
	float color = texture(sampler2D(textureFont, samplerFont), inUV).r;
	outFragColor = vec4(color);
}
