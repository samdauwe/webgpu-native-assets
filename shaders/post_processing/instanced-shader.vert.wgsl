struct Camera {
  projectionMatrix: mat4x4<f32>,
  viewMatrix: mat4x4<f32>
}

@group(0) @binding(0) 
var<uniform> camera: Camera;

struct Input {
  @location(0) position: vec4<f32>,
  @location(1) normal: vec3<f32>,

  @location(2) instanceModelMatrix0: vec4<f32>,
  @location(3) instanceModelMatrix1: vec4<f32>,
  @location(4) instanceModelMatrix2: vec4<f32>,
  @location(5) instanceModelMatrix3: vec4<f32>,

  @location(6) instanceNormalMatrix0: vec4<f32>,
  @location(7) instanceNormalMatrix1: vec4<f32>,
  @location(8) instanceNormalMatrix2: vec4<f32>,
  @location(9) instanceNormalMatrix3: vec4<f32>
}

struct Output {
  @builtin(position) Position: vec4<f32>,
  @location(0) normal: vec4<f32>,
  @location(1) pos: vec4<f32>
}

@vertex
fn main (input: Input) -> Output {
  var output: Output;

  var instanceModelMatrix: mat4x4<f32> = mat4x4<f32>(
    input.instanceModelMatrix0,
    input.instanceModelMatrix1,
    input.instanceModelMatrix2,
    input.instanceModelMatrix3
  );

  var instanceModelInverseTransposeMatrix: mat4x4<f32> = mat4x4<f32>(
    input.instanceNormalMatrix0,
    input.instanceNormalMatrix1,
    input.instanceNormalMatrix2,
    input.instanceNormalMatrix3
  );

  var worldPosition: vec4<f32> = instanceModelMatrix * input.position;

  output.Position = camera.projectionMatrix *
                    camera.viewMatrix *
                    worldPosition;

  output.normal = instanceModelInverseTransposeMatrix * vec4<f32>(input.normal, 0.0);
  output.pos = worldPosition;

  return output;
}
