// -- STRUCT_GRID_SIZE -- //
struct GridSize {
  w : f32,
  h : f32,
  dyeW: f32,
  dyeH: f32,
  dx : f32,
  rdx : f32,
  dyeRdx : f32
}
// -- STRUCT_GRID_SIZE -- //

@group(0) @binding(0) var<storage, read> x_vel : array<f32>;
@group(0) @binding(1) var<storage, read> y_vel : array<f32>;
@group(0) @binding(2) var<storage, read_write> div : array<f32>;
@group(0) @binding(3) var<uniform> uGrid : GridSize;

fn ID(x : f32, y : f32) -> u32 { return u32(x + y * uGrid.w); }
fn vel(x : f32, y : f32) -> vec2<f32> { let id = ID(x, y); return vec2(x_vel[id], y_vel[id]); }

@compute @workgroup_size(8, 8)
fn main(@builtin(global_invocation_id) global_id : vec3<u32>) {

  // -- COMPUTE_START -- //
  // This code initialize the pos and index variables and target only interior cells
  var pos = vec2<f32>(global_id.xy);

  if (pos.x == 0 || pos.y == 0 || pos.x >= uGrid.w - 1 || pos.y >= uGrid.h - 1) {
    return;
  }      

  let index = ID(pos.x, pos.y);
  // -- COMPUTE_START -- //

  let L = vel(pos.x - 1, pos.y).x;
  let R = vel(pos.x + 1, pos.y).x;
  let B = vel(pos.x, pos.y - 1).y;
  let T = vel(pos.x, pos.y + 1).y;

  div[index] = 0.5 * uGrid.rdx * ((R - L) + (T - B));
}
