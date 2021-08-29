#version 450

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 scale;
layout(location = 2) in float alpha;
layout(location = 3) in vec4 a_pos;
layout(location = 4) in vec2 a_uv;

layout(location = 0) out vec2 tUV;
layout(location = 1) out float vAlpha;

void main() {
    float ratio = 976.0/1920.0; 
    mat4 scaleMTX = mat4(
        scale.x, 0, 0, 0,
        0, scale.y , 0, 0,
        0, 0, scale.z, 0,
        position, 1
    );
    gl_Position = scaleMTX * vec4(a_pos.x, a_pos.y/ratio, a_pos.z , 1);
    tUV = a_uv;
    vAlpha = alpha;
}
