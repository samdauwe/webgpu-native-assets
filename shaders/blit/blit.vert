#version 450

const vec2 pos[4] = vec2[4](
    vec2(-1.0, 1.0), vec2(1.0, 1.0), vec2(-1.0, -1.0), vec2(1.0, -1.0)
);
const vec2 tex[4] = vec2[4](
    vec2(0.0, 0.0), vec2(1.0, 0.0), vec2(0.0, 1.0), vec2(1.0, 1.0)
);

layout(location=0) out vec2 texCoord;

void main() {
    texCoord = tex[gl_VertexIndex];
    gl_Position = vec4(pos[gl_VertexIndex], 0.0, 1.0);
}
