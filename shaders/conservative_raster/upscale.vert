#version 450

layout (location = 0) out vec2 tex_coords;

void main() 
{
    float x = float(int(gl_VertexIndex & 1u) << 2u) - 1.0;
    float y = float(int(gl_VertexIndex & 2u) << 1u) - 1.0;
    gl_Position = vec4(x, -y, 0.0, 1.0);
    tex_coords = vec2(x + 1.0, y + 1.0) * 0.5;
}
