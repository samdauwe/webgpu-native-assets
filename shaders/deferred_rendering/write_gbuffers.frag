#version 450

layout(location=0) in vec3 fragPosition;
layout(location=1) in vec3 fragNormal;
layout(location=2) in vec2 fragUV;

// GBufferOutput
layout(location=0) out vec4 outPosition;
layout(location=1) out vec4 outNormal;
// Textures: diffuse color, specular color, smoothness, emissive etc. could go here
layout(location=2) out vec4 outAlbedo;

void main() {
    outPosition = vec4(fragPosition, 1.0);
    outNormal = vec4(fragNormal, 1.0);
    // faking some kind of checkerboard texture
    vec2 uv = floor(30.0 * fragUV);
    float c = 0.2 + 0.5 * ((uv.x + uv.y) - 2.0 * floor((uv.x + uv.y) / 2.0));
    outAlbedo = vec4(c, c, c, 1.0);
}