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
layout(location = 1) in vec3 normal;

layout(location = 0) out vec3 shadowPos;
layout(location = 1) out vec3 fragPos;
layout(location = 2) out vec3 fragNorm;

void main() {
  // XY is in (-1, 1) space, Z is in (0, 1) space
  vec4 posFromLight = scene.lightViewProjMatrix * model.modelMatrix * vec4(position, 1.0);

  // Convert XY to (0, 1)
  // Y is flipped because texture coords are Y down.
  shadowPos = vec3(posFromLight.xy * vec2(0.5, -0.5) + 0.5, posFromLight.z);

  gl_Position =
    scene.cameraViewProjMatrix * model.modelMatrix * vec4(position, 1.0);
  fragPos = gl_Position.xyz;
  fragNorm = normal;
}
