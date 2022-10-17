struct GridSize {
  w : f32,
  h : f32,
  dyeW: f32,
  dyeH: f32,
  dx : f32,
  rdx : f32,
  dyeRdx : f32
}

@group(0) @binding(0) var<storage, read_write> x_in : array<f32>;
@group(0) @binding(1) var<storage, read_write> y_in : array<f32>;
@group(0) @binding(2) var<storage, read_write> z_in : array<f32>;
@group(0) @binding(3) var<storage, read_write> x_vel : array<f32>;
@group(0) @binding(4) var<storage, read_write> y_vel : array<f32>;
@group(0) @binding(5) var<storage, read_write> x_out : array<f32>;
@group(0) @binding(6) var<storage, read_write> y_out : array<f32>;
@group(0) @binding(7) var<storage, read_write> z_out : array<f32>;
@group(0) @binding(8) var<uniform> uGrid : GridSize;
@group(0) @binding(9) var<uniform> uDt : f32;

fn ID(x : f32, y : f32) -> u32 { return u32(x + y * uGrid.dyeW); }
fn in(x : f32, y : f32) -> vec3<f32> { let id = ID(x, y); return vec3(x_in[id], y_in[id], z_in[id]); }
fn vel(x : f32, y : f32) -> vec2<f32> {
  let id = u32(i32(x) + i32(y) * i32(uGrid.w));
  return vec2(x_vel[id], y_vel[id]);
}

fn vel_bilerp(x0 : f32, y0 : f32) -> vec2<f32> {
    var x = x0 * uGrid.w / uGrid.dyeW;
    var y = y0 * uGrid.h / uGrid.dyeH;

    if (x < 0) { x = 0; }
    else if (x >= uGrid.w - 1) { x = uGrid.w - 1; }
    if (y < 0) { y = 0; }
    else if (y >= uGrid.h - 1) { y = uGrid.h - 1; }

    let x1 = floor(x);
    let y1 = floor(y);
    let x2 = x1 + 1;
    let y2 = y1 + 1;

    let TL = vel(x1, y2);
    let TR = vel(x2, y2);
    let BL = vel(x1, y1);
    let BR = vel(x2, y1);

    let xMod = fract(x);
    let yMod = fract(y);

    return mix( mix(BL, BR, xMod), mix(TL, TR, xMod), yMod );
}

@compute @workgroup_size(8, 8)
fn main(@builtin(global_invocation_id) global_id : vec3<u32>) {

    // This code initialize the pos and index variables and target only interior cells
    var pos = vec2<f32>(global_id.xy);

    if (pos.x == 0 || pos.y == 0 || pos.x >= uGrid.dyeW - 1 || pos.y >= uGrid.dyeH - 1) {
        return;
    }

    let index = ID(pos.x, pos.y);

    let V = vel_bilerp(pos.x, pos.y);

    var x = pos.x - uDt * uGrid.dyeRdx * V.x;
    var y = pos.y - uDt * uGrid.dyeRdx * V.y;

    if (x < 0) { x = 0; }
    else if (x >= uGrid.dyeW - 1) { x = uGrid.dyeW - 1; }
    if (y < 0) { y = 0; }
    else if (y >= uGrid.dyeH - 1) { y = uGrid.dyeH - 1; }

    let x1 = floor(x);
    let y1 = floor(y);
    let x2 = x1 + 1;
    let y2 = y1 + 1;

    let TL = in(x1, y2);
    let TR = in(x2, y2);
    let BL = in(x1, y1);
    let BR = in(x2, y1);

    let xMod = fract(x);
    let yMod = fract(y);

    let bilerp = mix( mix(BL, BR, xMod), mix(TL, TR, xMod), yMod );

    x_out[index] = bilerp.x;
    y_out[index] = bilerp.y;
    z_out[index] = bilerp.z;
}
