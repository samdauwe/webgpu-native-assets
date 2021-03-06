#version 450
layout(location = 0) in vec4 v_position;
layout(location = 1) in vec2 v_uv;
layout(location = 2) in vec4 v_color;

layout(set = 0, binding = 1) uniform sampler samplerTex2D;
layout(set = 0, binding = 2) uniform texture2D tex;

layout(location = 0) out vec4 diffuseColor;

void main()
{
    diffuseColor = v_color * texture(sampler2D(tex, samplerTex2D), v_uv.st);
}
