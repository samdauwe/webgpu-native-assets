#version 450
layout(set = 0, binding = 0) uniform sampler mySampler;
layout(set = 0, binding = 1) uniform texture2D myTexture;

layout(location = 0) in vec2 fragUV;
layout(location = 0) out vec4 outColor;

void main() {
  outColor = texture(sampler2D(myTexture, mySampler), fragUV);
}
