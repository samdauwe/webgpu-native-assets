#version 450

layout(location=0) in vec3 inPosition;
layout(location=1) in vec3 inNormal;
layout(location=2) in vec2 inUV;

layout(set=0, binding=0) uniform Uniforms {
    mat4 modelMatrix;
    mat4 normalModelMatrix;
} uniforms;

layout(set=0, binding=1) uniform Camera {
    mat4 viewProjectionMatrix;
} camera;

layout(location=0) out vec3 outPosition; // position in world space
layout(location=1) out vec3 outNormal;   // normal in world space
layout(location=2) out vec2 outUV;

void main() {
    outPosition = (uniforms.modelMatrix * vec4(inPosition, 1.0)).xyz;
    gl_Position = camera.viewProjectionMatrix * vec4(outPosition, 1.0);
    outNormal = normalize((uniforms.normalModelMatrix * vec4(inNormal, 1.0)).xyz);
    outUV = inUV;
}
