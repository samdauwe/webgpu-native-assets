#version 450

#define DEFAULT_CANVAS_WIDTH 600
#define DEFAULT_CANVAS_HEIGHT 600

layout(location = 0) in vec4 clipPos;
layout(location = 0) out vec4 outColor;

layout(set = 1, binding = 0) uniform texture2D depthMap;
layout(set = 1, binding = 1) uniform sampler depthSampler;

void main() {
  vec2 fragUV = gl_FragCoord.xy / vec2(DEFAULT_CANVAS_WIDTH, DEFAULT_CANVAS_HEIGHT);
  float depthValue = texture(sampler2D(depthMap, depthSampler), fragUV).r;
  float error = abs(clipPos.z / clipPos.w - depthValue);
  outColor = vec4(vec3(error * 2000000.0), 1.0);
}
