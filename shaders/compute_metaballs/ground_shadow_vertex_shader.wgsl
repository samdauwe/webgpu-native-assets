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

struct ModelUniforms {
  matrix: mat4x4<f32>,
}

@group(0) @binding(1) var<uniform> projection: ProjectionUniformsStruct;
@group(0) @binding(2) var<uniform> view: ViewUniformsStruct;
@group(1) @binding(0) var<uniform> model: ModelUniforms;

struct Inputs {
  @location(0) position: vec3<f32>,
  @location(1) instanceOffset: vec3<f32>,
}

struct Output {
  @builtin(position) position: vec4<f32>,
}

@vertex
fn main(input: Inputs) -> Output {
  var output: Output;
  var dist = distance(input.instanceOffset.xy, vec2(0.0));
  var offsetX = input.instanceOffset.x;
  var offsetZ = input.instanceOffset.y;
  var scaleY = input.instanceOffset.z;
  var offsetPos = vec3(offsetX, abs(dist) * 0.06 + scaleY * 0.01, offsetZ);
  var scaleMatrix = mat4x4(
    1.0, 0.0, 0.0, 0.0,
    0.0, scaleY, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
  );
  var worldPosition = model.matrix * scaleMatrix * vec4(input.position + offsetPos, 1.0);
  output.position = projection.matrix *
                    view.matrix *
                    worldPosition;

  return output;
}
