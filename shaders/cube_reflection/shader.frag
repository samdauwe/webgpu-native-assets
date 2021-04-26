#version 450
layout(location = 2) in vec3 f_col;
layout(location = 0) out vec4 fragColor;

void main() {
    fragColor = vec4(f_col, 1.0);
}
