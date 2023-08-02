#version 450

layout (location = 0) in vec3 inPos;

layout (binding = 0) uniform UBO 
{
	mat4 projection;
	mat4 model;
} ubo;

layout (location = 0) out vec3 outUVW;

void main() 
{
	outUVW = inPos;
	// Convert cubemap coordinates into WebGPU coordinate space
	outUVW.x *= -1.0;
	gl_Position = ubo.projection * ubo.model * vec4(inPos.xyz, 1.0);
}
