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

struct InputPointLight {
  position: vec4<f32>,
  velocity: vec4<f32>,
  color: vec3<f32>,
  range: f32,
  intensity: f32,
}

struct LightsBuffer {
  lights: array<InputPointLight>,
}

struct LightsConfig {
  numLights: u32,
}

struct PointLight {
  pointToLight: vec3<f32>,
  color: vec3<f32>,
  range: f32,
  intensity: f32,
}

struct DirectionalLight {
  direction: vec3<f32>,
  color: vec3<f32>,
}

struct SpotLight {
  position: vec3<f32>,
  direction: vec3<f32>,
  color: vec3<f32>,
  cutOff: f32,
  outerCutOff: f32,
  intensity: f32,
}

struct Surface {
  albedo: vec4<f32>,
  metallic: f32,
  roughness: f32,
  worldPos: vec4<f32>,
  ID: f32,
  N: vec3<f32>,
  F0: vec3<f32>,
  V: vec3<f32>,
}

fn decodeNormals(enc: vec2<f32>) -> vec3<f32> {
  var fenc = enc * 4.0 - 2.0;
  var f = dot(fenc, fenc);
  var g = sqrt(1.0 - f / 4.0);
  return vec3(fenc*g, 1.0 - f / 2.0);
}

fn reconstructWorldPosFromZ(
  coords: vec2<f32>,
  size: vec2<f32>,
  depthTexture: texture_depth_2d,
  projInverse: mat4x4<f32>,
  viewInverse: mat4x4<f32>
) -> vec4<f32> {
  var uv = coords.xy / projection.outputSize;
  var depth = textureLoad(depthTexture, vec2<i32>(floor(coords)), 0);
  var x = uv.x * 2.0 - 1.0;
  var y = (1.0 - uv.y) * 2.0 - 1.0;
  var projectedPos = vec4(x, y, depth, 1.0);
  var worldPosition = projInverse * projectedPos;
  worldPosition = vec4(worldPosition.xyz / worldPosition.w, 1.0);
  worldPosition = viewInverse * worldPosition;
  return worldPosition;
}

@group(0) @binding(0) var<storage, read> lightsBuffer: LightsBuffer;
@group(0) @binding(1) var<uniform> lightsConfig: LightsConfig;
@group(0) @binding(2) var normalTexture: texture_2d<f32>;
@group(0) @binding(3) var diffuseTexture: texture_2d<f32>;
@group(0) @binding(4) var depthTexture: texture_depth_2d;

@group(1) @binding(0) var<uniform> projection: ProjectionUniformsStruct;
@group(1) @binding(1) var<uniform> view: ViewUniformsStruct;
@group(1) @binding(2) var depthSampler: sampler;

@group(2) @binding(0) var<uniform> spotLight: SpotLight;
@group(2) @binding(1) var<uniform> spotLightProjection: ProjectionUniformsStruct;
@group(2) @binding(2) var<uniform> spotLightView: ViewUniformsStruct;

@group(3) @binding(0) var spotLightDepthTexture: texture_depth_2d;

struct Inputs {
  @builtin(position) coords: vec4<f32>,
}
struct Output {
  @location(0) color: vec4<f32>,
}

const PI = 3.141592653589793;
const LOG2 = 1.4426950408889634;

fn DistributionGGX(N: vec3<f32>, H: vec3<f32>, roughness: f32) -> f32 {
  var a      = roughness*roughness;
  var a2     = a*a;
  var NdotH  = max(dot(N, H), 0.0);
  var NdotH2 = NdotH*NdotH;

  var num   = a2;
  var denom = (NdotH2 * (a2 - 1.0) + 1.0);
  denom = PI * denom * denom;
  return num / denom;
}

fn GeometrySchlickGGX(NdotV: f32, roughness: f32) -> f32 {
  var r = (roughness + 1.0);
  var k = (r*r) / 8.0;

  var num   = NdotV;
  var denom = NdotV * (1.0 - k) + k;

  return num / denom;
}

fn GeometrySmith(N: vec3<f32>, V: vec3<f32>, L: vec3<f32>, roughness: f32) -> f32 {
  var NdotV = max(dot(N, V), 0.0);
  var NdotL = max(dot(N, L), 0.0);
  var ggx2  = GeometrySchlickGGX(NdotV, roughness);
  var ggx1  = GeometrySchlickGGX(NdotL, roughness);

  return ggx1 * ggx2;
}

fn FresnelSchlick(cosTheta: f32, F0: vec3<f32>) -> vec3<f32> {
  return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

fn reinhard(x: vec3<f32>) -> vec3<f32> {
  return x / (1.0 + x);
}

fn rangeAttenuation(range : f32, distance : f32) -> f32 {
  if (range <= 0.0) {
      // Negative range means no cutoff
      return 1.0 / pow(distance, 2.0);
  }
  return clamp(1.0 - pow(distance / range, 4.0), 0.0, 1.0) / pow(distance, 2.0);
}

fn PointLightRadiance(light : PointLight, surface : Surface) -> vec3<f32> {
  var L = normalize(light.pointToLight);
  var H = normalize(surface.V + L);
  var distance = length(light.pointToLight);

  // cook-torrance brdf
  var NDF = DistributionGGX(surface.N, H, surface.roughness);
  var G = GeometrySmith(surface.N, surface.V, L, surface.roughness);
  var F = FresnelSchlick(max(dot(H, surface.V), 0.0), surface.F0);

  var kD = (vec3(1.0, 1.0, 1.0) - F) * (1.0 - surface.metallic);

  var NdotL = max(dot(surface.N, L), 0.0);

  var numerator = NDF * G * F;
  var denominator = max(4.0 * max(dot(surface.N, surface.V), 0.0) * NdotL, 0.001);
  var specular = numerator / vec3(denominator, denominator, denominator);

  // add to outgoing radiance Lo
  var attenuation = rangeAttenuation(light.range, distance);
  var radiance = light.color * light.intensity * attenuation;
  return (kD * surface.albedo.rgb / vec3(PI, PI, PI) + specular) * radiance * NdotL;
}

fn SpotLightRadiance(light: SpotLight, surface: Surface) -> vec3<f32> {
  var L = normalize(light.position - surface.worldPos.xyz);
  var H = normalize(surface.V + L);
  
  // spotlight (soft edges)
  var theta = dot(L, normalize(light.direction)); 
  var attenuation = smoothstep(light.outerCutOff, light.cutOff, theta);

  // cook-torrance brdf
  var NDF = DistributionGGX(surface.N, H, surface.roughness);
  var G = GeometrySmith(surface.N, surface.V, L, surface.roughness);
  var F = FresnelSchlick(max(dot(H, surface.V), 0.0), surface.F0);

  var kD = (vec3(1.0, 1.0, 1.0) - F) * (1.0 - surface.metallic);

  var NdotL = max(dot(surface.N, L), 0.0);

  var numerator = NDF * G * F;
  var denominator = max(4.0 * max(dot(surface.N, surface.V), 0.0) * NdotL, 0.001);
  var specular = numerator / denominator;

  // add to outgoing radiance Lo
  var radiance = light.color * light.intensity * attenuation;
  
  return (kD * surface.albedo.rgb / vec3(PI, PI, PI) + specular) * radiance * NdotL;
}

fn DirectionalLightRadiance(light: DirectionalLight, surface : Surface) -> vec3<f32> {
  var L = normalize(light.direction);
  var H = normalize(surface.V + L);

  // cook-torrance brdf
  var NDF = DistributionGGX(surface.N, H, surface.roughness);
  var G = GeometrySmith(surface.N, surface.V, L, surface.roughness);
  var F = FresnelSchlick(max(dot(H, surface.V), 0.0), surface.F0);

  var kD = (vec3(1.0, 1.0, 1.0) - F) * (1.0 - surface.metallic);

  var NdotL = max(dot(surface.N, L), 0.0);

  var numerator = NDF * G * F;
  var denominator = max(4.0 * max(dot(surface.N, surface.V), 0.0) * NdotL, 0.001);
  var specular = numerator / vec3(denominator, denominator, denominator);

  // add to outgoing radiance Lo
  var radiance = light.color;
  return (kD * surface.albedo.rgb / vec3(PI, PI, PI) + specular) * radiance * NdotL;
}

// see http://chilliant.blogspot.com/2012/08/srgb-approximations-for-hlsl.html
const GAMMA = 2.2;
fn linearTosRGB(linear: vec3<f32>) -> vec3<f32> {
  var INV_GAMMA = 1.0 / GAMMA;
  return pow(linear, vec3<f32>(INV_GAMMA, INV_GAMMA, INV_GAMMA));
}

fn LinearizeDepth(depth: f32) -> f32 {
  var z = depth * 2.0 - 1.0; // Back to NDC 
  var near_plane = 0.001;
  var far_plane = 0.4;
  return (2.0 * near_plane * far_plane) / (far_plane + near_plane - z * (far_plane - near_plane));
}

@fragment
fn main(input: Inputs) -> Output {
  // ## Reconstruct world position from depth buffer

  var worldPosition = reconstructWorldPosFromZ(
    input.coords.xy,
    projection.outputSize,
    depthTexture,
    projection.inverseMatrix,
    view.inverseMatrix
  );
  
  var normalRoughnessMatID = textureLoad(
    normalTexture,
    vec2<i32>(floor(input.coords.xy)),
    0
  );

  var albedo = textureLoad(
    diffuseTexture,
    vec2<i32>(floor(input.coords.xy)),
    0
  );

  var surface: Surface;
  surface.ID = normalRoughnessMatID.w;

  var output: Output;

  // ## Shadow map visibility

  var posFromLight = spotLightProjection.matrix * spotLightView.matrix * vec4(worldPosition.xyz, 1.0);
  posFromLight = vec4(posFromLight.xyz / posFromLight.w, 1.0);
  var shadowPos = vec3(
    posFromLight.xy * vec2(0.5,-0.5) + vec2(0.5, 0.5),
    posFromLight.z
  );

  var projectedDepth = textureSample(spotLightDepthTexture, depthSampler, shadowPos.xy);

  if (surface.ID == 0.0) {

    // ## Shadow mapping visibility

    var inRange =
      shadowPos.x >= 0.0 &&
      shadowPos.x <= 1.0 &&
      shadowPos.y >= 0.0 &&
      shadowPos.y <= 1.0;
    var visibility = 1.0;
    if (inRange && projectedDepth <= posFromLight.z - 0.000009) {
      visibility = 0.0;
    }

    // ## PBR

    surface.albedo = albedo;
    surface.metallic = normalRoughnessMatID.z;
    surface.roughness = albedo.a;
    surface.worldPos = worldPosition;
    surface.N = decodeNormals(normalRoughnessMatID.xy);
    surface.F0 = mix(vec3(0.04), surface.albedo.rgb, vec3(surface.metallic));
    surface.V = normalize(view.position - worldPosition.xyz);

    // output luminance to add to
    var Lo = vec3(0.0);

    // ## Point lighting

    for (var i : u32 = 0u; i < lightsConfig.numLights; i = i + 1u) {
        var light = lightsBuffer.lights[i];
      var pointLight: PointLight;
      
      // Don't calculate if too far away
      if (distance(light.position.xyz, worldPosition.xyz) > light.range) {
        continue;
      }
      
      pointLight.pointToLight = light.position.xyz - worldPosition.xyz;
      pointLight.color = light.color;
      pointLight.range = light.range;
      pointLight.intensity = light.intensity;
      Lo += PointLightRadiance(pointLight, surface);
    }

    // ## Directional lighting

    var dirLight: DirectionalLight;
    dirLight.direction = vec3(2.0, 20.0, 0.0);
    dirLight.color = vec3(0.1);
    Lo += DirectionalLightRadiance(dirLight, surface) * visibility;

    // ## Spot lighting

    Lo += SpotLightRadiance(spotLight, surface) * visibility;

    var ambient = vec3(0.09) * albedo.rgb;
    var color = ambient + Lo;
    output.color = vec4(color.rgb, 1.0);			

    // ## Fog

    var fogDensity = 0.085;
    var fogDistance = length(worldPosition.xyz);
    var fogAmount = 1.0 - exp2(-fogDensity * fogDensity * fogDistance * fogDistance * LOG2);
    fogAmount = clamp(fogAmount, 0.0, 1.0);
    var fogColor = vec4(vec3(0.005), 1.0);
    output.color = mix(output.color, fogColor, fogAmount);
    

  } else if (0.1 - surface.ID < 0.01 && surface.ID < 0.1) {
    output.color = vec4(albedo.rgb, 1.0);
  } else {
    output.color = vec4(vec3(0.005), 1.0);
  }
  return output;
}
