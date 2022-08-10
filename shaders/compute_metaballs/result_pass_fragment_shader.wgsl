// see http://chilliant.blogspot.com/2012/08/srgb-approximations-for-hlsl.html
const GAMMA = 2.2;
fn linearTosRGB(linear: vec3<f32>) -> vec3<f32> {
  var INV_GAMMA = 1.0 / GAMMA;
  return pow(linear, vec3<f32>(INV_GAMMA, INV_GAMMA, INV_GAMMA));
}

@group(0) @binding(0) var copyTexture: texture_2d<f32>;
@group(0) @binding(1) var bloomTexture: texture_2d<f32>;

struct Inputs {
  @builtin(position) coords: vec4<f32>,
}
struct Output {
  @location(0) color: vec4<f32>,
}

@fragment
fn main(input: Inputs) -> Output {
  var output: Output;
  var hdrColor = textureLoad(
    copyTexture,
    vec2<i32>(floor(input.coords.xy)),
    0
  );
  var bloomColor = textureLoad(
    bloomTexture,
    vec2<i32>(floor(input.coords.xy)),
    0
  );

  hdrColor += bloomColor;

  var result = vec3(1.0) - exp(-hdrColor.rgb * 1.0);
  // result = linearTosRGB(result);

  output.color = vec4(result, 1.0);
  // output.color = vec4(bloomColor.rgba);
  return output;
}
