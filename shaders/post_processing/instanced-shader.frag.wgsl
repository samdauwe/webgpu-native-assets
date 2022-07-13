struct Lighting {
  position: vec3<f32>
}

@group(1) @binding(0)
var <uniform> lighting: Lighting;

struct Material {
  baseColor: vec3<f32>
}

@group(2) @binding(0)
var <uniform> material: Material;

struct Input {
  @location(0) normal: vec4<f32>,
  @location(1) pos: vec4<f32>
}

@fragment
fn main (input: Input) -> @location(0) vec4<f32> {
  var normal: vec3<f32> = normalize(input.normal.rgb);
  var lightColor: vec3<f32> = vec3<f32>(1.0);

  // ambient light
  var ambientFactor: f32 = 0.1;
  var ambientLight: vec3<f32> = lightColor * ambientFactor;

  // diffuse light
  var lightDirection: vec3<f32> = normalize(lighting.position - input.pos.rgb);
  var diffuseStrength: f32 = max(dot(normal, lightDirection), 0.0);
  var diffuseLight: vec3<f32> = lightColor * diffuseStrength;

  // combine lighting
  var finalLight: vec3<f32> = diffuseLight + ambientLight;

  return vec4<f32>(material.baseColor * finalLight, 1.0);
}
