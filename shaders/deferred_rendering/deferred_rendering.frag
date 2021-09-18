#version 450
#extension GL_EXT_samplerless_texture_functions : require

// These should match the constants defined in deferred_rendering.c
#define MAX_NUM_LIGHTS 1024

layout(set=0, binding=0) uniform texture2D gBufferPosition;
layout(set=0, binding=1) uniform texture2D gBufferNormal;
layout(set=0, binding=2) uniform texture2D gBufferAlbedo;

struct LightData {
  vec4 position;
  vec3 color;
  float radius;
};
layout(set=1, binding=0) buffer LightsBuffer {
    LightData lights[MAX_NUM_LIGHTS];
} lightsBuffer;

layout(set=1, binding=1) uniform Config {
    uint numLights;
} config;

layout(set=2, binding=0) uniform SurfaceConstants {
    vec2 size;
} surface;

layout(location = 0) out vec4 outColor;

void main() {
    vec3 result = vec3(0.0, 0.0, 0.0);
    ivec2 c = ivec2(gl_FragCoord.xy);

    vec3 position = texelFetch(gBufferPosition, c, 0).xyz;

    if (position.z > 10000.0) {
        discard;
    }

    vec3 normal = texelFetch(gBufferNormal, c, 0).xyz;
    vec3 albedo = texelFetch(gBufferAlbedo, c, 0).rgb;

    for (uint i = 0; i < config.numLights; i++) {
        vec3 L = lightsBuffer.lights[i].position.xyz - position;
        float distance = length(L);
        if (distance > lightsBuffer.lights[i].radius) {
            continue;
        }
        float lambert = max(dot(normal, normalize(L)), 0.0);
        result = result + vec3(lambert * pow(1.0 - distance / lightsBuffer.lights[i].radius, 2.0) * lightsBuffer.lights[i].color * albedo);
    }

    // some manual ambient
    result = result + vec3(0.2, 0.2, 0.2);

    outColor = vec4(result, 1.0);
}