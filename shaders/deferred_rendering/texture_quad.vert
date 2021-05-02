#version 450

const vec2 pos[6] = vec2[6](
    vec2(-1.0, -1.0), vec2(1.0, -1.0), vec2(-1.0, 1.0),
    vec2(-1.0, 1.0), vec2(1.0, -1.0), vec2(1.0, 1.0)
);

void main() {
    gl_Position = vec4(pos[gl_VertexIndex], 0.0, 1.0);
}
