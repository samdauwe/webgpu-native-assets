struct Input {
  @location(0) uv: vec2<f32>
}

@group(2) @binding(0) var mySampler: sampler;
@group(2) @binding(1) var postFX0Texture: texture_2d<f32>;
@group(2) @binding(2) var postFX1Texture: texture_2d<f32>;
@group(2) @binding(3) var cutOffTexture: texture_2d<f32>;

struct Tween {
  factor: f32
}

@group(3) @binding(0)
var <uniform> tween: Tween;

@fragment
fn main (input: Input) -> @location(0) vec4<f32> {
  var result0: vec4<f32> = textureSample(postFX0Texture, mySampler, input.uv);
  var result1: vec4<f32> = textureSample(postFX1Texture, mySampler, input.uv);

  var cutoffResult: vec4<f32> = textureSample(cutOffTexture, mySampler, input.uv);

  var mixFactor: f32 = step(tween.factor * 1.05, cutoffResult.r);

  return mix(result0, result1, mixFactor);
}
