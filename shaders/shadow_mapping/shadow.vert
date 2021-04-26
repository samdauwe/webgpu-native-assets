#version 450
layout(set = 0, binding = 0) uniform Scene {
  mat4 lightViewProjMatrix;
  mat4 cameraViewProjMatrix;
  vec3 lightPos;
} scene;

layout(set = 1, binding = 0) uniform Model {
  mat4 modelMatrix;
} model;

layout(location = 0) in vec3 position;

void main() {
  gl_Position =
    scene.lightViewProjMatrix * model.modelMatrix * vec4(position, 1.0);
}