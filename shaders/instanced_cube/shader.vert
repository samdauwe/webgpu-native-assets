#version 450

#define MAX_NUM_INSTANCES 16

layout(set = 0, binding = 0) uniform Uniforms {
  mat4 modelViewProjectionMatrix[MAX_NUM_INSTANCES];
} uniforms;

layout(location = 0) in vec4 position;
layout(location = 1) in vec4 color;

layout(location = 0) out vec4 fragColor;

void main() {
  gl_Position = uniforms.modelViewProjectionMatrix[gl_InstanceIndex] * position;
  fragColor = color;
}
