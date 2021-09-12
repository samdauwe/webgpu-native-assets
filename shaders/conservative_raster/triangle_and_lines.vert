#version 450

void main() 
{
    int i = int(gl_VertexIndex % 3u);
    float x = float(i - 1) * 0.75;
    float y = float((i & 1) * 2 - 1) * 0.75 + x * 0.2 + 0.1;
    gl_Position = vec4(x, y, 0.0, 1.0);
}