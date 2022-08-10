struct Metaball {
  position: vec3<f32>,
  radius: f32,
  strength: f32,
  subtract: f32,
}

struct MetaballList {
  ballCount: u32,
  balls: array<Metaball>,
}
@group(0) @binding(0) var<storage> metaballs : MetaballList;

struct IsosurfaceVolume {
  min: vec3<f32>,
  max: vec3<f32>,
  step: vec3<f32>,
  size: vec3<u32>,
  threshold: f32,
  values: array<f32>,
}
@group(0) @binding(1) var<storage, read_write> volume : IsosurfaceVolume;

fn positionAt(index : vec3<u32>) -> vec3<f32> {
  return volume.min + (volume.step * vec3<f32>(index.xyz));
}

fn surfaceFunc(position : vec3<f32>) -> f32 {
  var result = 0.0;
  for (var i = 0u; i < metaballs.ballCount; i = i + 1u) {
    var ball = metaballs.balls[i];
    var dist = distance(position, ball.position);
    var val = ball.strength / (0.000001 + (dist * dist)) - ball.subtract;
    if (val > 0.0) {
      result = result + val;
    }
  }
  return result;
}

@compute @workgroup_size(4, 4, 4)
fn main(@builtin(global_invocation_id) global_id : vec3<u32>) {
  var position = positionAt(global_id);
  var valueIndex = global_id.x +
                  (global_id.y * volume.size.x) +
                  (global_id.z * volume.size.x * volume.size.y);

  volume.values[valueIndex] = surfaceFunc(position);
}
