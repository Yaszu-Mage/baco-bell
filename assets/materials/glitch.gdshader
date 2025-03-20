shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
float param_rndi(float minimum, float maximum, float seed) {
	return floor(param_rnd(minimum, maximum + 1.0, seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
const vec4 p_o354284476442_albedo_color = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o354284476442_metallic = 0.000000000;
const float p_o354284476442_roughness = 1.000000000;
const float p_o354284476442_emission_energy = 1.000000000;
const float p_o354284476442_normal = 1.000000000;
const float p_o354284476442_ao = 1.000000000;
const float p_o354284476442_depth_scale = 0.500000000;
const float p_o1218730532106_x = 16.000000000;
const float p_o1218730532106_y = 16.000000000;
const float p_o1218730532106_c = 32.000000000;
const float p_o1218730532106_d = 1.000000000;
const float seed_o673487787702 = 0.039562000;
const float p_o673487787702_iterations = 5.000000000;
const float p_o673487787702_persistence = 0.500000000;
const float p_o673487787702_frequency = 2.000000000;
const float p_o673487787702_offset = 0.000000000;
// #globals: pixelize (o1218730532106)
// #globals: wavelet_noise (o673487787702)
float wavelet(vec2 uv, vec2 size, float s, float frequency, float offset) {
	uv = mod(uv, size);
	vec2 seed = fract(floor(uv)*0.1236754+vec2(s));
	uv = fract(uv);
	vec2 ruv = uv-0.5;
	float a = rand(seed)*6.28;
	float ca = cos(a);
	float sa = sin(a);
	ruv = vec2(ca*ruv.x + sa*ruv.y, -sa*ruv.x + ca*ruv.y);
	return (0.5*sin(ruv.x*6.28*frequency+offset)+0.5)*max(0.0, 1.0-2.0*length(uv-vec2(0.5)));
}
float wavelet_noise(vec2 uv, vec2 size, int iterations, float persistence, float seed, float frequency, float offset, float type) {
	float rv = 0.0;
	float acc = 0.0;
	vec2 seed2 = rand2(vec2(seed));
	vec2 local_uv = uv * size;
	float q = 1.0;
	for (int i = 0; i < iterations; ++i) {
		rv += q*wavelet(local_uv, size, seed, frequency, offset);
		rv += q*wavelet(local_uv+vec2(0.5), size, seed+0.1, frequency, offset);
		acc += q;
		if (type > 0.0) {
			local_uv += type*uv;
			size += vec2(type);
		} else {
			local_uv *= -type;
			size *= -type;
		}
		local_uv += seed2; 
		seed2 = rand2(seed2);
		q *= persistence;
		seed += 0.1;
	}
	return rv / acc;
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);

// #code: pixelize (o1218730532106)
vec2 o1218730532106_0_uv = floor(((uv)*vec2(p_o1218730532106_x, p_o1218730532106_y)))+vec2(0.5);
vec3 o1218730532106_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o1218730532106_0_uv))/vec3(103.0, 71.0, 97.0));

// #output0: wavelet_noise (o673487787702)
float o673487787702_0_1_f = wavelet_noise((o1218730532106_0_uv/vec2(p_o1218730532106_x, p_o1218730532106_y)), vec2((elapsed_time), (elapsed_time)), int(p_o673487787702_iterations), p_o673487787702_persistence, (seed_o673487787702+fract(_seed_variation_)), p_o673487787702_frequency, p_o673487787702_offset, 2);

// #output0: pixelize (o1218730532106)
vec3 o1218730532106_0_1_rgb = floor(vec3(o673487787702_0_1_f)*p_o1218730532106_c+p_o1218730532106_d*(o1218730532106_0_dither-vec3(0.5)))/p_o1218730532106_c;

	vec3 albedo_tex = o1218730532106_0_1_rgb.rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o354284476442_albedo_color.rgb;
	METALLIC = 1.0*p_o354284476442_metallic;
	ROUGHNESS = 1.0*p_o354284476442_roughness;
	NORMAL = vec3(0.5);
	EMISSION = vec3(0.0)*p_o354284476442_emission_energy;
}



