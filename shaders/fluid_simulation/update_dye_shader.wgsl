struct GridSize {
  w : f32,
  h : f32,
  dyeW: f32,
  dyeH: f32,
  dx : f32,
  rdx : f32,
  dyeRdx : f32
}

struct Mouse {
  pos: vec2<f32>,
  vel: vec2<f32>,
}
@group(0) @binding(0) var<storage, read_write> x_in : array<f32>;
@group(0) @binding(1) var<storage, read_write> y_in : array<f32>;
@group(0) @binding(2) var<storage, read_write> z_in : array<f32>;
@group(0) @binding(3) var<storage, read_write> x_out : array<f32>;
@group(0) @binding(4) var<storage, read_write> y_out : array<f32>;
@group(0) @binding(5) var<storage, read_write> z_out : array<f32>;
@group(0) @binding(6) var<uniform> uGrid: GridSize;
@group(0) @binding(7) var<uniform> uMouse: Mouse;
@group(0) @binding(8) var<uniform> uForce : f32;
@group(0) @binding(9) var<uniform> uRadius : f32;
@group(0) @binding(10) var<uniform> uDiffusion : f32;
@group(0) @binding(11) var<uniform> uTime : f32;
@group(0) @binding(12) var<uniform> uDt : f32;
@group(0) @binding(13) var<uniform> uSymmetry : f32;

fn ID(x : f32, y : f32) -> u32 { return u32(x + y * uGrid.dyeW); }
fn inBetween(x : f32, lower : f32, upper : f32) -> bool {
  return x > lower && x < upper;
}
fn inBounds(pos : vec2<f32>, xMin : f32, xMax : f32, yMin: f32, yMax : f32) -> bool {
  return inBetween(pos.x, xMin * uGrid.dyeW, xMax * uGrid.dyeW) && inBetween(pos.y, yMin * uGrid.dyeH, yMax * uGrid.dyeH);
}
// cosine based palette, 4 vec3 params
fn palette(t : f32, a : vec3<f32>, b : vec3<f32>, c : vec3<f32>, d : vec3<f32> ) -> vec3<f32> {
    return a + b*cos( 6.28318*(c*t+d) );
}

fn createSplat(pos : vec2<f32>, splatPos : vec2<f32>, vel : vec2<f32>, radius : f32) -> vec3<f32> {
  var p = pos - splatPos;
  p.x *= uGrid.w / uGrid.h;
  var v = vel;
  v.x *= uGrid.w / uGrid.h;
  var splat = exp(-dot(p, p) / radius) * length(v);
  return vec3(splat);
}

@compute @workgroup_size(8, 8)
fn main(@builtin(global_invocation_id) global_id : vec3<u32>) {

    var pos = vec2<f32>(global_id.xy);

    if (pos.x == 0 || pos.y == 0 || pos.x >= uGrid.dyeW - 1 || pos.y >= uGrid.dyeH - 1) {
        return;
    }

    let index = ID(pos.x, pos.y);

    // var col_start = palette(uTime/8., vec3(0.875, 0.516, 0.909), vec3(0.731, 0.232, 0.309), vec3(1.566, 0.088, 1.466), vec3(0.825, 5.786, 3.131));
    // var col_start = palette(uTime/8., vec3(0.383, 0.659, 0.770), vec3(0.322, 0.366, 0.089), vec3(1.132, 1.321, 0.726), vec3(6.241, 4.902, 1.295));
    let col_start = palette(uTime/8., vec3(0.5), vec3(0.5), vec3(1), vec3(0.333, 0.667, 0.999));

    var p = pos/vec2(uGrid.dyeW, uGrid.dyeH);

    var m = uMouse.pos;
    var v = uMouse.vel*2.;

    var splat = createSplat(p, m, v, uRadius);
    if (uSymmetry == 1. || uSymmetry == 3.) {splat += createSplat(p, vec2(1. - m.x, m.y), v * vec2(-1., 1.), uRadius);}
    if (uSymmetry == 2. || uSymmetry == 3.) {splat += createSplat(p, vec2(m.x, 1. - m.y), v * vec2(1., -1.), uRadius);}
    if (uSymmetry == 3. || uSymmetry == 4.) {splat += createSplat(p, vec2(1. - m.x, 1. - m.y), v * vec2(-1., -1.), uRadius);}

    splat *= col_start * uForce * uDt * 100.;

    x_out[index] = x_in[index]*uDiffusion + splat.x;
    y_out[index] = y_in[index]*uDiffusion + splat.y;
    z_out[index] = z_in[index]*uDiffusion + splat.z;
}
