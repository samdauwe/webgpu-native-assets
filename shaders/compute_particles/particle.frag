#version 450

layout (binding = 0) uniform texture2D textureColorMap;
layout (binding = 1) uniform sampler samplerColorMap;
layout (binding = 2) uniform texture2D textureGradientRamp;
layout (binding = 3) uniform sampler samplerGradientRamp;

layout (location = 0) in vec4 inColor;
layout (location = 1) in float inGradientPos;

layout (location = 0) out vec4 outFragColor;

void main () 
{
	vec3 color = texture(sampler2D(textureGradientRamp, samplerGradientRamp), vec2(inGradientPos, 0.0)).rgb;
	// outFragColor.rgb = texture(sampler2D(textureColorMap, samplerColorMap), gl_PointCoord).rgb * color;
	outFragColor.rgb = color.rgb; // gl_PointCoord does not exist in WebGPU
}
