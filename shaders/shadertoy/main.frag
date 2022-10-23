#version 450

#extension GL_ARB_separate_shader_objects: enable
#extension GL_ARB_shading_language_420pack: enable
#extension GL_GOOGLE_include_directive : enable

layout (location = 0) in vec2 frag_pos;

layout (binding = 0) uniform shader_inputs_ubo
{
	vec2 u_Resolution;
	float u_Time;
	float u_TimeDelta;
	int u_Frame;
	vec4 u_Mouse;
	vec4 u_Date;
	float u_SampleRate;
} shader_inputs;

vec3 iResolution = vec3(shader_inputs.u_Resolution,1.);
float iTime = shader_inputs.u_Time;
float iTimeDelta = shader_inputs.u_TimeDelta;
int iFrame = shader_inputs.u_Frame;
vec4 iMouse = shader_inputs.u_Mouse;
vec4 iDate = shader_inputs.u_Date;
float iSampleRate = shader_inputs.u_SampleRate;

layout (location = 0) out vec4 out_color;

#include "seascape.glsl"

void main()
{
    vec4 uFragColor = vec4(0.);
    vec2 fragCoord = frag_pos.xy;
    fragCoord = floor(iResolution.xy*fragCoord);
    mainImage(uFragColor,fragCoord);
    out_color = uFragColor;
}
