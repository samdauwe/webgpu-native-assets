#version 450

#define NUM_INSTANCES 9

layout(location = 0) in vec4 position;
layout(location = 1) in vec2 inTexCoords;

layout(set = 0, binding = 0) uniform sampler linearSampler;
layout(set = 0, binding = 1) uniform texture2D colorTexture;
layout(set = 0, binding = 2) uniform texture2D heightmap;

struct Instance {
    mat4 modelViewMatrix;
    mat4 modelViewProjectionMatrix;
};

layout(std140, set = 1, binding = 0) uniform Uniforms {
    Instance instances[NUM_INSTANCES];
} uniforms;

layout(location = 0) out vec4 eyePosition;
layout(location = 1) out vec3 normal;
layout(location = 2) out vec2 outTexCoords;

void main() {
    // Displacement mapping constants
    float patchSize = 50.0;
    float heightScale = 8.0;
    vec3 d = vec3(1.0 / 256.0, 1.0 / 256.0, 0.0);
    float dydy = heightScale / patchSize;

    // Calculate displacement and differentials (for normal calculation)
    float height  = texture(sampler2D(heightmap, linearSampler), inTexCoords).r;
    float dydx  = height - texture(sampler2D(heightmap, linearSampler), inTexCoords + d.xz).r;
    float dydz  = height - texture(sampler2D(heightmap, linearSampler), inTexCoords + d.zy).r;

    // Calculate model-space vertex position and normal
    vec4 modelPosition = vec4(position.x, position.y + height * heightScale, position.z, 1.0);
    vec4 modelNormal = vec4(normalize(vec3(dydx, dydy, dydz)), 0.0);

    // Retrieve MV and MVP matrices from instance data
    mat4 modelViewMatrix = uniforms.instances[gl_InstanceIndex].modelViewMatrix;
    mat4 modelViewProjectionMatrix = uniforms.instances[gl_InstanceIndex].modelViewProjectionMatrix;

    gl_Position = modelViewProjectionMatrix * modelPosition; // clip space position
    eyePosition = modelViewMatrix * modelPosition; // eye space position
    normal = (modelViewMatrix * modelNormal).xyz; // eye space normal
    outTexCoords = inTexCoords;
}
