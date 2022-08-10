struct ViewUniformsStruct {
  matrix: mat4x4<f32>,
  inverseMatrix: mat4x4<f32>,
  position: vec3<f32>,
  time: f32,
  deltaTime: f32,
}

struct InputPointLight {
  position: vec4<f32>,
  velocity: vec4<f32>,
  color: vec3<f32>,
  range: f32,
  intensity: f32,
}

struct LightsBuffer {
  lights: array<InputPointLight>,
}

struct LightsConfig {
  numLights: u32,
}

@group(0) @binding(0) var<storage, read_write> lightsBuffer: LightsBuffer;
@group(0) @binding(1) var<uniform> config: LightsConfig;

@group(1) @binding(1) var<uniform> view: ViewUniformsStruct;

const PI = 3.141592653589793;

@compute @workgroup_size(64, 1, 1)
fn main(@builtin(global_invocation_id) GlobalInvocationID : vec3<u32>) {
  var index = GlobalInvocationID.x;
  if (index >= config.numLights) {
    return;
  }

  lightsBuffer.lights[index].position.x += lightsBuffer.lights[index].velocity.x * view.deltaTime;
  lightsBuffer.lights[index].position.z += lightsBuffer.lights[index].velocity.z * view.deltaTime;
  
  const size = 42.0;
  var halfSize = size / 2.0;
  
  if (lightsBuffer.lights[index].position.x < -halfSize) {
    lightsBuffer.lights[index].position.x = -halfSize;
    lightsBuffer.lights[index].velocity.x *= -1.0;
  } else if (lightsBuffer.lights[index].position.x > halfSize) {
    lightsBuffer.lights[index].position.x = halfSize;
    lightsBuffer.lights[index].velocity.x *= -1.0;
  }

  if (lightsBuffer.lights[index].position.z < -halfSize) {
    lightsBuffer.lights[index].position.z = -halfSize;
    lightsBuffer.lights[index].velocity.z *= -1.0;
  } else if (lightsBuffer.lights[index].position.z > halfSize) {
    lightsBuffer.lights[index].position.z = halfSize;
    lightsBuffer.lights[index].velocity.z *= -1.0;
  }
}
