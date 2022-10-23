#version 450

layout (set = 0, binding = 1) uniform texture2D textureColor;
layout (set = 0, binding = 2) uniform sampler sampler_1;
layout (set = 0, binding = 3) uniform sampler sampler_2;
layout (set = 0, binding = 4) uniform sampler sampler_3;

layout (location = 0) in vec2 inUV;
layout (location = 1) in float inLodBias;
layout (location = 2) flat in int inSamplerIndex;
layout (location = 3) in vec3 inNormal;
layout (location = 4) in vec3 inViewVec;
layout (location = 5) in vec3 inLightVec;

layout (location = 0) out vec4 outFragColor;

void main() 
{
    vec4 color = vec4(0);

    vec4 color_1 = texture(sampler2D(textureColor, sampler_1), inUV, inLodBias);
    vec4 color_2 = texture(sampler2D(textureColor, sampler_2), inUV, inLodBias);
    vec4 color_3 = texture(sampler2D(textureColor, sampler_3), inUV, inLodBias);

    switch (inSamplerIndex) {
        case 0:
            color = color_1;
            break;
        case 1:
            color = color_2;
            break;
        case 2:
            color = color_3;
            break;
        default:
            break;
    }

    vec3 N = normalize(inNormal);
    vec3 L = normalize(inLightVec);
    vec3 V = normalize(inViewVec);
    vec3 R = reflect(L, N);
    vec3 diffuse = max(dot(N, L), 0.65) * vec3(1.0);
    float specular = pow(max(dot(R, V), 0.0), 16.0) * color.a;
    outFragColor = vec4(diffuse * color.rgb + specular, 1.0);    
}