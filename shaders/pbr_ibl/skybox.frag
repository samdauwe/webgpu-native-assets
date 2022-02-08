#version 450

layout (binding = 2) uniform textureCube textureEnv;
layout (binding = 3) uniform sampler samplerEnv;

layout (location = 0) in vec3 inUVW;

layout (location = 0) out vec4 outColor;

layout (binding = 1) uniform UBOParams {
	vec4 lights[4];
	float exposure;
	float gamma;
} uboParams;

// From http://filmicworlds.com/blog/filmic-tonemapping-operators/
vec3 Uncharted2Tonemap(vec3 color)
{
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	return ((color*(A*color+C*B)+D*E)/(color*(A*color+B)+D*F))-E/F;
}

void main()
{
	vec3 color = texture(samplerCube(textureEnv, samplerEnv), inUVW * vec3(1.0, -1.0, 1.0)).rgb;

	// Tone mapping
	color = Uncharted2Tonemap(color * uboParams.exposure);
	color = color * (1.0f / Uncharted2Tonemap(vec3(11.2f)));
	// Gamma correction
	color = pow(color, vec3(1.0f / uboParams.gamma));

	outColor = vec4(color, 1.0);
}
