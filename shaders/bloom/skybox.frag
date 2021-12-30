#version 450

layout( binding = 1 ) uniform textureCube textureCubemap;
layout( binding = 2 ) uniform sampler samplerCubemap;

layout (location = 0) in vec3 inUVW;

layout (location = 0) out vec4 outFragColor;

void main() 
{
	outFragColor = texture(samplerCube(textureCubemap, samplerCubemap), inUVW);
}