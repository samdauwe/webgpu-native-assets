#version 450
layout(std140, set = 0, binding = 0) uniform Time {
    float time;
};
layout(std140, set = 1, binding = 0) uniform Uniforms {
    float scale;
    float offsetX;
    float offsetY;
    float scalar;
    float scalarOffset;
};

layout(location = 0) in vec4 position;
layout(location = 1) in vec4 color;

layout(location = 0) out vec4 v_color;

void main() {
    float fade = mod(scalarOffset + time * scalar / 10.0, 1.0);
    if (fade < 0.5) {
        fade = fade * 2.0;
    } else {
        fade = (1.0 - fade) * 2.0;
    }
    float xpos = position.x * scale;
    float ypos = position.y * scale;
    float angle = 3.14159 * 2.0 * fade;
    float xrot = xpos * cos(angle) - ypos * sin(angle);
    float yrot = xpos * sin(angle) + ypos * cos(angle);
    xpos = xrot + offsetX;
    ypos = yrot + offsetY;
    v_color = vec4(fade, 1.0 - fade, 0.0, 1.0) + color;
    gl_Position = vec4(xpos, ypos, 0.0, 1.0);
}
