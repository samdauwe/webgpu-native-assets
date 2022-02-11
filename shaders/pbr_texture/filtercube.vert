#version 450

layout (location = 0) in vec3 inPos;

layout (binding = 0) uniform Consts {
	mat4 mvp;
} consts;

layout (location = 0) out vec3 outUVW;

out gl_PerVertex {
	vec4 gl_Position;
};

void main()
{
	outUVW = inPos;
	gl_Position = consts.mvp * vec4(inPos.xyz, 1.0);
}
