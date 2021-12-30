#version 450

layout (binding = 1) uniform texture2D textureColor;
layout (binding = 2) uniform sampler samplerColor;

layout (binding = 0) uniform UBO 
{
	float blurScale;
	float blurStrength;
} ubo;

layout (location = 0) in vec2 inUV;

layout (location = 0) out vec4 outFragColor;

void main() 
{
	float weight[5];
	weight[0] = 0.227027;
	weight[1] = 0.1945946;
	weight[2] = 0.1216216;
	weight[3] = 0.054054;
	weight[4] = 0.016216;

	vec2 tex_offset = 1.0 / textureSize(sampler2D(textureColor, samplerColor), 0) * ubo.blurScale; // gets size of single texel
	vec3 result = texture(sampler2D(textureColor, samplerColor), inUV).rgb * weight[0]; // current fragment's contribution
	for(int i = 1; i < 5; ++i)
	{
		// H
		result += texture(sampler2D(textureColor, samplerColor), inUV + vec2(tex_offset.x * i, 0.0)).rgb * weight[i] * ubo.blurStrength;
		result += texture(sampler2D(textureColor, samplerColor), inUV - vec2(tex_offset.x * i, 0.0)).rgb * weight[i] * ubo.blurStrength;
	}
	outFragColor = vec4(result, 1.0);
}