#version 450

// This should match the constants defined in shadow_mapping.c
#define SHADOW_DEPTH_TEXTURE_SIZE 1024

layout(set = 0, binding = 0) uniform Scene {
  mat4 lightViewProjMatrix;
  mat4 cameraViewProjMatrix;
  vec3 lightPos;
} scene;

layout(set = 0, binding = 1) uniform texture2D shadowMap;
layout(set = 0, binding = 2) uniform samplerShadow shadowSampler;

layout(location = 0) in vec3 shadowPos;
layout(location = 1) in vec3 fragPos;
layout(location = 2) in vec3 fragNorm;

layout(location = 0) out vec4 outColor;

const vec3 albedo = vec3(0.9);
const float ambientFactor = 0.2;

void main() {
  // Percentage-closer filtering. Sample texels in the region
  // to smooth the result.
  float shadowFactor = 0.0;
  for (int y = -1 ; y <= 1 ; y++) {
      for (int x = -1 ; x <= 1 ; x++) {
        vec2 offset = vec2(
          x * (1.0 / SHADOW_DEPTH_TEXTURE_SIZE),
          y * (1.0 / SHADOW_DEPTH_TEXTURE_SIZE));

        shadowFactor += texture(
          sampler2DShadow(shadowMap, shadowSampler),
          vec3(shadowPos.xy + offset, shadowPos.z - 0.007));
      }
  }

  shadowFactor = ambientFactor + shadowFactor / 9.0;

  float lambertFactor = abs(dot(normalize(scene.lightPos - fragPos), fragNorm));

  float lightingFactor = min(shadowFactor * lambertFactor, 1.0);
  outColor = vec4(lightingFactor * albedo, 1.0);
}
