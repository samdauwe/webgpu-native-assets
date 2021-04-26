#version 450

layout (set = 0, binding = 0) uniform texture2D textureColorMap;
layout (set = 0, binding = 1) uniform sampler samplerColorMap;
layout (set = 0, binding = 2) uniform texture2D textureGradientRamp;
layout (set = 0, binding = 3) uniform sampler samplerGradientRamp;

layout (location = 0) in float inGradientPos;

layout (location = 0) out vec4 outFragColor;

void main () 
{
	vec3 color = texture(sampler2D(textureGradientRamp, samplerGradientRamp), vec2(inGradientPos, 0.0)).rgb;
	outFragColor.rgb = texture(sampler2D(textureColorMap, samplerColorMap), gl_PointCoord).rgb * color;
}
