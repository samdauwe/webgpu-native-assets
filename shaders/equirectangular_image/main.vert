#version 450

#extension GL_ARB_separate_shader_objects: enable
#extension GL_ARB_shading_language_420pack: enable

layout (location = 0) out vec2 frag_pos;

void main()
{
    frag_pos = vec2((gl_VertexIndex << 1) & 2, gl_VertexIndex & 2);
    gl_Position = vec4(frag_pos * 2.0f + -1.0f, 0.0f, 1.0f);
}
