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

@group(0) @binding(0) var<storage, read> x_in : array<f32>;
@group(0) @binding(1) var<storage, read_write> x_out : array<f32>;
@group(0) @binding(2) var<uniform> uGrid : GridSize;

fn ID(x : f32, y : f32) -> u32 { return u32(x + y * uGrid.w); }

@compute @workgroup_size(8, 8)
fn main(@builtin(global_invocation_id) global_id : vec3<u32>) {

  // -- COMPUTE_START_ALL -- //
  // This code initialize the pos and index variables and target all cells
  var pos = vec2<f32>(global_id.xy);

  if (pos.x >= uGrid.w || pos.y >= uGrid.h) {
    return;
  }

  let index = ID(pos.x, pos.y);
  // -- COMPUTE_START_ALL -- //

  if (pos.x == 0) { pos.x += 1; }
  else if (pos.x == uGrid.w - 1) { pos.x -= 1; }
  if (pos.y == 0) { pos.y += 1; }
  else if (pos.y == uGrid.h - 1) { pos.y -= 1; }

  x_out[index] = x_in[ID(pos.x, pos.y)];
}
