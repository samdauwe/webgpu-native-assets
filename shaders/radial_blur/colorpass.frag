#version 450

layout (binding = 1) uniform texture2D textureGradientRamp;
layout (binding = 2) uniform sampler samplerGradientRamp;

layout (location = 0) in vec3 inColor;
layout (location = 1) in vec2 inUV;

layout (location = 0) out vec4 outFragColor;

void main() 
{
	// Use max. color channel value to detect bright glow emitters
	if ((inColor.r >= 0.9) || (inColor.g >= 0.9) || (inColor.b >= 0.9)) 
	{
		outFragColor.rgb = texture(sampler2D(textureGradientRamp, samplerGradientRamp), inUV).rgb;
	}
	else
	{
		outFragColor.rgb = inColor;
	}
}