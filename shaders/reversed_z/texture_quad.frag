#version 450

#define DEFAULT_CANVAS_WIDTH 600
#define DEFAULT_CANVAS_HEIGHT 600

layout(set = 0, binding = 0) uniform texture2D map;
layout(set = 0, binding = 1) uniform sampler mapSampler;

layout(location = 0) out vec4 outColor;

void main() {
  vec2 fragUV = gl_FragCoord.xy / vec2(DEFAULT_CANVAS_WIDTH, DEFAULT_CANVAS_HEIGHT);
  float value = texture(sampler2D(map, mapSampler), fragUV).r;
  outColor = vec4(vec3(value), 1.0);
}
