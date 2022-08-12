struct Inputs {
  @location(0) position: vec2<f32>,
}

struct Output {
  @builtin(position) position: vec4<f32>,
}

@vertex
fn main(input: Inputs) -> Output {
  var output: Output;
  output.position = vec4(input.position, 0.0, 1.0);

  return output;
}
