#version 450

#define X_COUNT 1
#define Y_COUNT 5
#define NUM_INSTANCES (X_COUNT * Y_COUNT)

layout(set = 0, binding = 0) uniform Uniforms {
  mat4 modelMatrix[NUM_INSTANCES];
} uniforms;

layout(set = 0, binding = 1) uniform CameraMatrix {
  mat4 viewProjectionMatrix;
} camera;

layout(location = 0) in vec4 position;

layout(location = 0) out vec4 clipPos;

void main() {
  gl_Position = camera.viewProjectionMatrix * uniforms.modelMatrix[gl_InstanceIndex] * position;
  clipPos = gl_Position;
}