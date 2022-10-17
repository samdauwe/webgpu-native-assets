struct GridSize {
  w : f32,
  h : f32,
  dyeW: f32,
  dyeH: f32,
  dx : f32,
  rdx : f32,
  dyeRdx : f32
}

@group(0) @binding(0) var<storage, read_write> x_out : array<f32>;
@group(0) @binding(1) var<storage, read_write> y_out : array<f32>;
@group(0) @binding(2) var<storage, read_write> z_out : array<f32>;
@group(0) @binding(3) var<uniform> uGrid : GridSize;

fn ID(x : f32, y : f32) -> u32 { return u32(x + y * uGrid.dyeW); }

@compute @workgroup_size(8, 8)
fn main(@builtin(global_invocation_id) global_id : vec3<u32>) {

  // This code initialize the pos and index variables and target only interior cells
  var pos = vec2<f32>(global_id.xy);

  if (pos.x == 0 || pos.y == 0 || pos.x >= uGrid.dyeW - 1 || pos.y >= uGrid.dyeH - 1) {
    return;
  }

  let index = ID(pos.x, pos.y);

  let size = 128.;
  if ((pos.x%size < size/2. && pos.y%size < size/2.) || (pos.x%size > size/2. && pos.y%size > size/2.)) {
    x_out[index] = 2.;
    y_out[index] = 2.;
    z_out[index] = 2.;
  } else {
    x_out[index] = 0.;
    y_out[index] = 0.;
    z_out[index] = 0.;
  }
}
