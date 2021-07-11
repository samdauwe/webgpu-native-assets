#version 450

layout(set = 0, binding = 0) uniform sampler linearSampler;
layout(set = 0, binding = 1) uniform texture2D colorTexture;

layout(location = 0) in vec4 eyePosition;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 texCoords;

layout(location = 0) out vec4 outFragColor;

void main()
{
    // Lighting constants
    vec3 lightColor = 2.0 * vec3(0.812, 0.914, 1.0);
    vec3 L = normalize(vec3(1.0, 1.0, 1.0));

    // Determine diffuse lighting contribution
    vec3 N = normalize(normal.xyz);
    float diffuseFactor = clamp(dot(N, L), 0.0, 1.0);

    float texCoordScale = 4.0;
    vec3 baseColor = texture(sampler2D(colorTexture, linearSampler), texCoords * texCoordScale).rgb;

    vec3 litColor = diffuseFactor * lightColor * baseColor;

    // Fog constants
    vec3 fogColor = vec3(0.812, 0.914, 1.0);
    float fogStart = 3.0;
    float fogEnd = 50.0;

    // Calculate fog factor from eye space distance
    float fogDist = length(eyePosition.xyz);
    float fogFactor = clamp((fogEnd - fogDist) / (fogEnd - fogStart), 0.0, 1.0);

    // Blend lit color and fog color to get fragment color
    vec3 finalColor = (fogColor * (1.0 - fogFactor)) + (litColor * fogFactor);
    outFragColor = vec4(finalColor, 1.0);
}
