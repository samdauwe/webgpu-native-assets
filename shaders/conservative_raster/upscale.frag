#version 450

layout (set = 0, binding = 0) uniform texture2D r_color;
layout (set = 0, binding = 1) uniform sampler r_sampler;

layout (location = 0) in vec2 tex_coords;

layout (location = 0) out vec4 outFragColor;

void main() 
{
    outFragColor = texture(sampler2D(r_color, r_sampler), tex_coords);
}
