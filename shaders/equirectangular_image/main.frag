#version 450

#extension GL_ARB_separate_shader_objects: enable
#extension GL_ARB_shading_language_420pack: enable
#extension GL_GOOGLE_include_directive : enable

layout (location = 0) in vec2 frag_pos;

layout (set = 0, binding = 0) uniform shader_inputs_ubo
{
	vec2 u_Resolution;
	vec4 u_Mouse;
	float u_HFovDegrees; // = 120.0
	float u_VFovDegrees; // = 60.0;
	bool u_VisualizeInput; // = 0
} shader_inputs;

layout (set = 0, binding = 1) uniform texture2D iChannel0Texture;
layout (set = 0, binding = 2) uniform sampler iChannel0TextureSampler;

vec3 iResolution = vec3(shader_inputs.u_Resolution,1.);
vec4 iMouse = shader_inputs.u_Mouse;
float iHFovDegrees = shader_inputs.u_HFovDegrees;
float iVFovDegrees = shader_inputs.u_VFovDegrees;
bool iVisualizeInput = shader_inputs.u_VisualizeInput;

layout (location = 0) out vec4 out_color;

#include "equirectangular_image_viewer.glsl"

void main()
{
    vec4 uFragColor = vec4(0.);
    vec2 fragCoord = frag_pos.xy;
    fragCoord = floor(iResolution.xy*fragCoord);
    mainImage(uFragColor,fragCoord);
    out_color = uFragColor;
}
