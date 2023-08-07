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

@group(0) @binding(0) var<storage, read_write> x_out : array<f32>;
@group(0) @binding(1) var<storage, read_write> y_out : array<f32>;
@group(0) @binding(2) var<storage, read_write> z_out : array<f32>;
@group(0) @binding(3) var<uniform> uGrid : GridSize;
@group(0) @binding(4) var<uniform> uTime : f32;

fn ID(x : f32, y : f32) -> u32 { return u32(x + y * uGrid.dyeW); }

fn noise(p_ : vec3<f32>) -> f32 {
  var p = p_;
	var ip=floor(p);
  p-=ip; 
  var s=vec3(7.,157.,113.);
  var h=vec4(0.,s.y, s.z,s.y+s.z)+dot(ip,s);
  p=p*p*(3. - 2.*p); 
  h=mix(fract(sin(h)*43758.5),fract(sin(h+s.x)*43758.5),p.x);
  var r=mix(h.xz,h.yw,p.y);
  h.x = r.x;
  h.y = r.y;
  return mix(h.x,h.y,p.z); 
}

fn fbm(p_ : vec3<f32>, octaveNum : i32) -> vec2<f32> {
  var p=p_;
	var acc = vec2(0.);	
	var freq = 1.0;
	var amp = 0.5;
  var shift = vec3(100.);
	for (var i = 0; i < octaveNum; i++) {
		acc += vec2(noise(p), noise(p + vec3(0.,0.,10.))) * amp;
    p = p * 2.0 + shift;
    amp *= 0.5;
	}
	return acc;
}

@compute @workgroup_size(8, 8)
fn main(@builtin(global_invocation_id) global_id : vec3<u32>) {

  // -- COMPUTE_START_DYE -- //
  // This code initialize the pos and index variables and target only interior cells
  var pos = vec2<f32>(global_id.xy);

  if (pos.x == 0 || pos.y == 0 || pos.x >= uGrid.dyeW - 1 || pos.y >= uGrid.dyeH - 1) {
    return;
  }

  let index = ID(pos.x, pos.y);
  // -- COMPUTE_START_DYE -- //

  var uv = pos/vec2(uGrid.dyeW, uGrid.dyeH);
  var zoom = 4.;

  var smallNoise = fbm(vec3(uv.x*zoom*2., uv.y*zoom*2., uTime+2.145), 7) - .5;
  var bigNoise = fbm(vec3(uv.x*zoom, uv.y*zoom, uTime*.1+30.), 7) - .5;

  var noise = max(length(bigNoise) * 0.035, 0.);
  var noise2 = max(length(smallNoise) * 0.035, 0.);

  noise = noise + noise2 * .05;

  var czoom = 4.;
  var n = fbm(vec3(uv.x*czoom, uv.y*czoom, uTime*.1+63.1), 7)*.75+.25;
  var n2 = fbm(vec3(uv.x*czoom, uv.y*czoom, uTime*.1+23.4), 7)*.75+.25;
  // var col = 6.*vec3(n.x, n.y, n2.x);
  
  var col = vec3(1.);

  x_out[index] += noise * col.x;
  y_out[index] += noise * col.y;
  z_out[index] += noise * col.z;
}
