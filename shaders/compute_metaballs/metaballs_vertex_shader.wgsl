struct ProjectionUniformsStruct {
  matrix : mat4x4<f32>,
  inverseMatrix: mat4x4<f32>,
  outputSize : vec2<f32>,
  zNear : f32,
  zFar : f32,
}

struct ViewUniformsStruct {
  matrix: mat4x4<f32>,
  inverseMatrix: mat4x4<f32>,
  position: vec3<f32>,
  time: f32,
  deltaTime: f32,
}

@group(0) @binding(0) var<uniform> projection : ProjectionUniformsStruct;
@group(0) @binding(1) var<uniform> view : ViewUniformsStruct;

struct Inputs {
  @location(0) position: vec3<f32>,
  @location(1) normal: vec3<f32>,
}

struct Output {
  @location(0) normal: vec3<f32>,
  @builtin(position) position: vec4<f32>,
}

@vertex
fn main(input: Inputs) -> Output {
  var output: Output;
  output.position = projection.matrix *
                  view.matrix *
                  vec4(input.position, 1.0);

  output.normal = input.normal;
  return output;
}
