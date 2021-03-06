struct Camera {
  projectionMatrix: mat4x4<f32>,
  viewMatrix: mat4x4<f32>
}

@group(0) @binding(0)
var<uniform> camera: Camera;

struct Transform {
  modelMatrix: mat4x4<f32>
}

@group(1) @binding(0)
var<uniform> transform: Transform;

struct Input {
  @location(0) position: vec4<f32>,
  @location(1) uv: vec2<f32>
}

struct Output {
  @builtin(position) Position: vec4<f32>,
  @location(0) uv: vec2<f32>
}

@vertex
fn main (input: Input) -> Output {
  var output: Output;

  output.Position = camera.projectionMatrix *
                    camera.viewMatrix *
                    transform.modelMatrix *
                    input.position;

  output.uv = input.uv;

  return output;
}
