#version 450
layout(location = 0) in vec2 Position;
layout(location = 1) in vec2 UV;
layout(location = 2) in vec4 Color;

layout(location = 0) out vec4 v_position;
layout(location = 1) out vec2 v_uv;
layout(location = 2) out vec4 v_color;

layout(std140, set = 0, binding = 0) uniform ProjUniform {
    mat4 ProjMtx;
} projUniform;

void main()
{
    v_uv = UV;
    v_color = Color;
    v_position = projUniform.ProjMtx * vec4(Position.xy,0.f,1.f);
    gl_Position = v_position;
}
