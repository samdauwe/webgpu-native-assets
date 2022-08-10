struct Input {
  @location(0) color: vec3<f32>,
  @location(1) uv: vec2<f32>,
}

struct Output {
  @location(0) normal: vec4<f32>,	
  @location(1) albedo: vec4<f32>,	
}

@fragment
fn main(input: Input) -> Output {
  var dist = distance(input.uv, vec2(0.5), );
  if (dist > 0.5) {
    discard;
  }
  var output: Output;
  output.normal = vec4(0.0, 0.0, 0.0, 0.1);
  output.albedo = vec4(input.color, 1.0);
  return output;
}
