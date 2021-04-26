#version 450
layout(set = 0, binding = 0) uniform cameraData {
    mat4 view;
    mat4 proj;
} camera;

layout(set = 0, binding = 1) uniform modelData {
    mat4 modelMatrix;
};

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 col;
layout(location = 2) out vec3 f_col;

void main() {
    f_col = col;
    gl_Position = camera.proj * camera.view * modelMatrix * vec4(pos, 1.0);
}
