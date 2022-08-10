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

struct Uniforms {
  color: vec3<f32>,
  roughness: f32,
  metallic: f32,
}

@group(1) @binding(0) var<uniform> ubo: Uniforms;

struct Inputs {
  @location(0) normal: vec3<f32>,
}

@fragment
fn main(input: Inputs) -> Output {
  var normal = normalize(input.normal);
  var albedo = ubo.color;
  var metallic = ubo.metallic;
  var roughness = ubo.roughness;
  var ID = 0.0;
  return encodeGBufferOutput(
    normal,
    albedo,
    metallic,
    roughness,
    ID
  );
}
