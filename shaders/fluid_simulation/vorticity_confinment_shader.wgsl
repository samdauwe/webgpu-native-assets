struct GridSize {
  w : f32,
  h : f32,
  dyeW: f32,
  dyeH: f32,
  dx : f32,
  rdx : f32,
  dyeRdx : f32
}

@group(0) @binding(0) var<storage, read_write> x_vel_in : array<f32>;
@group(0) @binding(1) var<storage, read_write> y_vel_in : array<f32>;
@group(0) @binding(2) var<storage, read_write> vorticity : array<f32>;
@group(0) @binding(3) var<storage, read_write> x_vel_out : array<f32>;
@group(0) @binding(4) var<storage, read_write> y_vel_out : array<f32>;
@group(0) @binding(5) var<uniform> uGrid : GridSize;
@group(0) @binding(6) var<uniform> uDt : f32;
@group(0) @binding(7) var<uniform> uVorticity : f32;

fn ID(x : f32, y : f32) -> u32 { return u32(x + y * uGrid.w); }
fn vort(x : f32, y : f32) -> f32 { let id = ID(x, y); return vorticity[id]; }

@compute @workgroup_size(8, 8)
fn main(@builtin(global_invocation_id) global_id : vec3<u32>) {

  var pos = vec2<f32>(global_id.xy);

  if (pos.x == 0 || pos.y == 0 || pos.x >= uGrid.w - 1 || pos.y >= uGrid.h - 1) {
    return;
  }

  let index = ID(pos.x, pos.y);

  let L = vort(pos.x - 1, pos.y);
  let R = vort(pos.x + 1, pos.y);
  let B = vort(pos.x, pos.y - 1);
  let T = vort(pos.x, pos.y + 1);
  let C = vorticity[index];

  var force = 0.5 * uGrid.rdx * vec2(abs(T) - abs(B), abs(R) - abs(L));

  let epsilon = 2.4414e-4;
  let magSqr = max(epsilon, dot(force, force));

  force = force / sqrt(magSqr);
  force *= uGrid.dx * uVorticity * uDt * C * vec2(1, -1);

  x_vel_out[index] = x_vel_in[index] + force.x;
  y_vel_out[index] = y_vel_in[index] + force.y;
}
