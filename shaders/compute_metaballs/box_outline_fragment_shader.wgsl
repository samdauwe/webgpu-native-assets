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

struct Output {
  @location(0) GBuffer_OUT0: vec4<f32>,	// RG: Normal, B: Metallic, A: Mesh ID
  @location(1) GBuffer_OUT1: vec4<f32>,	// RGB: Albedo, A: Roughness
}

// Normal gbuffer encoding / decoding. Packs normals as xyz to 2 values only
// Shamelessly stolen from https://aras-p.info/texts/CompactNormalStorage.html
fn encodeNormals(n: vec3<f32>) -> vec2<f32> {
  var p = sqrt(n.z * 8.0 + 8.0);
  return vec2(n.xy / p + 0.5);
}

fn encodeGBufferOutput(
  normal: vec3<f32>,
  albedo: vec3<f32>,
  metallic: f32,
  roughness: f32,
  ID: f32
) -> Output {
  var output: Output;
  output.GBuffer_OUT0 = vec4(encodeNormals(normal), metallic, ID);
  output.GBuffer_OUT1 = vec4(albedo, roughness);
  return output;
}

struct Input {
  @location(0) localPosition: vec3<f32>,
}
@group(0) @binding(0) var<uniform> projection : ProjectionUniformsStruct;
@group(0) @binding(1) var<uniform> view : ViewUniformsStruct;

@fragment
fn main(input: Input) -> Output {
  var output: Output;
  var spacing = step(sin(input.localPosition.x * 10.0 + view.time * 2.0), 0.1);
  if (spacing < 0.5) {
    discard;
  }
  var normal = vec3(0.0);
  var albedo = vec3(1.0);
  var metallic = 0.0;
  var roughness = 0.0;
  var ID = 0.1;
  return encodeGBufferOutput(
    normal,
    albedo,
    metallic,
    roughness,
    ID
  );
}
