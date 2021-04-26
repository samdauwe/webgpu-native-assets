#version 450
layout(set = 0, binding = 1) uniform texture2D t_Color;
layout(set = 0, binding = 2) uniform sampler s_Color;

layout (location = 0) in vec2 inUV;
layout (location = 1) in float inLodBias;
layout (location = 2) in vec3 inNormal;
layout (location = 3) in vec3 inViewVec;
layout (location = 4) in vec3 inLightVec;

layout (location = 0) out vec4 outFragColor;

void main()
{
  vec4 color = texture(sampler2D(t_Color, s_Color), inUV, inLodBias);

  vec3 N = normalize(inNormal);
  vec3 L = normalize(inLightVec);
  vec3 V = normalize(inViewVec);
  vec3 R = reflect(-L, N);
  vec3 diffuse = max(dot(N, L), 0.0) * vec3(1.0);
  float specular = pow(max(dot(R, V), 0.0), 16.0) * color.a;

  outFragColor = vec4(diffuse * color.rgb + specular, 1.0);
}
