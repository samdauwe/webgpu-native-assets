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

@group(0) @binding(1) var<uniform> projection: ProjectionUniformsStruct;
@group(0) @binding(2) var<uniform> view: ViewUniformsStruct;

struct Inputs {
  @location(0) position: vec3<f32>,
}

struct Output {
  @builtin(position) position: vec4<f32>,
}

@vertex
fn main(input: Inputs) -> Output {
  var output: Output;
  output.position = projection.matrix *
                    view.matrix *
                    vec4(input.position, 1.0);

  return output;
}
