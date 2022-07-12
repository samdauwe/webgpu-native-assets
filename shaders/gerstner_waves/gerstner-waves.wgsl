struct Uniforms {
    elapsedTime: f32,
    @align(16) modelMatrix: mat4x4<f32>,  // Explicitly set alignment
    viewProjectionMatrix: mat4x4<f32>,
    cameraPosition: vec3<f32>
}

struct GerstnerWaveParameters {
    length: f32,  // 0 < L
    amplitude: f32, // 0 < A
    steepness: f32,  // Steepness of the peak of the wave. 0 <= S <= 1
    @size(16) @align(8) direction: vec2<f32>  // Normalized direction of the wave
}

struct GerstnerWavesUniforms {
    waves: array<GerstnerWaveParameters, 5>,
    amplitudeSum: f32  // Sum of waves amplitudes
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) normal: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) worldPosition: vec4<f32>
}

@group(0) @binding(0) var<uniform> uniforms: Uniforms;
@group(0) @binding(1) var<uniform> wavesUniforms: GerstnerWavesUniforms;

@group(1) @binding(0) var seaSampler: sampler;
@group(1) @binding(1) var seaColor: texture_2d<f32>;


const pi = 3.14159;
const gravity = 9.8; // m/sec^2
const waveNumbers = 5;

@vertex
fn vertex_main(
    @location(0) position: vec3<f32>,
    // @location(1) normal: vec3<f32>,  // TODO: delete normals from plane geo
    @location(2) uv: vec2<f32>,
) -> VertexOutput {
    var output: VertexOutput;
    var worldPosition: vec4<f32> = uniforms.modelMatrix * vec4<f32>(position, 1.0);

    var wavesSum: vec3<f32> = vec3<f32>(0.0);
    var wavesSumNormal: vec3<f32>;
    for(var i: i32 = 0; i < waveNumbers; i = i + 1) {
        var wave = wavesUniforms.waves[i];
        var wavevectorMagnitude = 2.0 * pi / wave.length;
        var wavevector = wave.direction * wavevectorMagnitude;
        var temporalFrequency = sqrt(gravity * wavevectorMagnitude);
        var steepnessFactor = wave.steepness / (wave.amplitude * wavevectorMagnitude * f32(waveNumbers));

        var pos = dot(wavevector, worldPosition.xz) - temporalFrequency * uniforms.elapsedTime;
        var sinPosAmplitudeDirection = sin(pos) * wave.amplitude * wave.direction;

        var offset: vec3<f32>;
        offset.x = sinPosAmplitudeDirection.x * steepnessFactor;
        offset.z = sinPosAmplitudeDirection.y * steepnessFactor;
        offset.y = cos(pos) * wave.amplitude;

        var normal: vec3<f32>;
        normal.x = sinPosAmplitudeDirection.x * wavevectorMagnitude;
        normal.z = sinPosAmplitudeDirection.y * wavevectorMagnitude;
        normal.y = cos(pos) * wave.amplitude * wavevectorMagnitude * steepnessFactor;

        wavesSum = wavesSum + offset;
        wavesSumNormal = wavesSumNormal + normal;
    }
    wavesSumNormal.y = 1.0 - wavesSumNormal.y;
    wavesSumNormal = normalize(wavesSumNormal);

    worldPosition.x = worldPosition.x - wavesSum.x;
    worldPosition.z = worldPosition.z - wavesSum.z;
    worldPosition.y = wavesSum.y;

    output.worldPosition = worldPosition;
    output.position = uniforms.viewProjectionMatrix * worldPosition;
    output.normal = vec4<f32>(wavesSumNormal, 0.0);
    output.uv = uv;
    return output;
}

@fragment
fn fragment_main(
    data: VertexOutput,
) -> @location(0) vec4<f32> {
    const lightColor = vec3<f32>(1.0, 0.8, 0.65);
    const skyColor = vec3<f32>(0.69, 0.84, 1.0);

    const lightPosition = vec3<f32>(-10.0, 1.0, -10.0);
    var light = normalize(lightPosition - data.worldPosition.xyz);  // Vector from surface to light
    var eye = normalize(uniforms.cameraPosition - data.worldPosition.xyz);  // Vector from surface to camera
    var reflection = reflect(data.normal.xyz, -eye);  // I - 2.0 * dot(N, I) * N

    var halfway = normalize(eye + light);  // Vector between View and Light
    const shininess = 30.0;
    var specular = clamp(pow(dot(data.normal.xyz, halfway), shininess), 0.0, 1.0) * lightColor;  // Blinn-Phong specular component

    var fresnel = clamp(pow(1.0 + dot(-eye, data.normal.xyz), 4.0), 0.0, 1.0);  // Cheap fresnel approximation

    // Normalize height to [0, 1]
    var normalizedHeight = (data.worldPosition.y + wavesUniforms.amplitudeSum) / (2.0 * wavesUniforms.amplitudeSum);
    var underwater = textureSample(seaColor, seaSampler, vec2<f32>(normalizedHeight, 0.0)).rgb;

    // Approximating Translucency (GPU Pro 2 article)
    const distortion = 0.1;
    const power = 4.0;
    const scale = 1.0;
    const ambient = 0.2;
    var thickness = smoothstep(0.0, 1.0, normalizedHeight);
    var distortedLight = light + data.normal.xyz * distortion;
    var translucencyDot = pow(clamp(dot(eye, -distortedLight), 0.0, 1.0), power);
    var translucency = (translucencyDot * scale + ambient) * thickness;
    var underwaterTranslucency = mix(underwater, lightColor, translucency) * translucency;

    var color = mix(underwater + underwaterTranslucency, skyColor, fresnel) + specular;

    return vec4<f32>(color, 1.0);
}
