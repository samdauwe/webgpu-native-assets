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
  @location(1) instanceMat0: vec4<f32>,
  @location(2) instanceMat1: vec4<f32>,
  @location(3) instanceMat2: vec4<f32>,
  @location(4) instanceMat3: vec4<f32>,
}

struct Output {
  @builtin(position) position: vec4<f32>,
  @location(0) localPosition: vec3<f32>,
}

@vertex
fn main(input: Inputs) -> Output {
  var output: Output;

  var instanceMatrix = mat4x4(
    input.instanceMat0,
    input.instanceMat1,
    input.instanceMat2,
    input.instanceMat3,
  );

  var worldPosition = vec4<f32>(input.position, 1.0);
  output.position = projection.matrix *
                    view.matrix *
                    instanceMatrix *
                    worldPosition;

  output.localPosition = input.position;
  return output;
}