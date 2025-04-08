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
const vec4 p_o354787792922_albedo_color = vec4(1.000000000, 0.937500000, 0.000000000, 1.000000000);
const float p_o354787792922_metallic = 0.000000000;
const float p_o354787792922_roughness = 1.000000000;
const float p_o354787792922_emission_energy = 1.000000000;
const float p_o354787792922_normal = 1.000000000;
const float p_o354787792922_ao = 1.000000000;
const float p_o354787792922_depth_scale = 0.500000000;
const float p_o14041825154670_translate_y = 0.000000000;
const float p_o6694948048012_cx = 0.000000000;
const float p_o6694948048012_cy = 0.000000000;
const float p_o6694948048012_scale_x = 0.200000000;
const float p_o6694948048012_scale_y = 0.200000000;
const float p_o3412871617786_gradient_pos[2] = float[]( 0.000000000, 0.027671756 );
const vec4 p_o3412871617786_gradient_col[2] = vec4[]( vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000), vec4(0.894531250, 0.894531250, 0.894531250, 1.000000000) );
const float p_o900416408580_steps = 32.000000000;
const float p_o440754248939_x_scale = 4.000000000;
const float p_o440754248939_y_scale = 4.000000000;
// #globals: translate (o14041825154670)
// #globals: scale (o6694948048012)
vec2 scale(vec2 uv, vec2 center, vec2 scale) {
	uv -= center;
	uv /= scale;
	uv += center;
	return uv;
}
// #globals: pattern (o440754248939)
float wave_constant(float x) {
	return 1.0;
}
float wave_sine(float x) {
	return 0.5-0.5*cos(3.14159265359*2.0*x);
}
float wave_triangle(float x) {
	x = fract(x);
	return min(2.0*x, 2.0-2.0*x);
}
float wave_sawtooth(float x) {
	return fract(x);
}
float wave_square(float x) {
	return (fract(x) < 0.5) ? 0.0 : 1.0;
}
float wave_bounce(float x) {
	x = 2.0*(fract(x)-0.5);
	return sqrt(1.0-x*x);
}
float mix_mul(float x, float y) {
	return x*y;
}
float mix_add(float x, float y) {
	return min(x+y, 1.0);
}
float mix_max(float x, float y) {
	return max(x, y);
}
float mix_min(float x, float y) {
	return min(x, y);
}
float mix_xor(float x, float y) {
	return min(x+y, 2.0-x-y);
}
float mix_pow(float x, float y) {
	return pow(x, y);
}
vec4 o3412871617786_gradient_gradient_fct(float x) {
  if (x < p_o3412871617786_gradient_pos[1]) {
    return p_o3412871617786_gradient_col[0];
  }
  return p_o3412871617786_gradient_col[1];
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);

// #output0: pattern (o440754248939)
float o440754248939_0_1_f = mix_mul(wave_sine(p_o440754248939_x_scale*(scale(((uv)-vec2((elapsed_time*0.01), p_o14041825154670_translate_y)), vec2(0.5+p_o6694948048012_cx, 0.5+p_o6694948048012_cy), vec2(p_o6694948048012_scale_x, p_o6694948048012_scale_y))).x), wave_sine(p_o440754248939_y_scale*(scale(((uv)-vec2((elapsed_time*0.01), p_o14041825154670_translate_y)), vec2(0.5+p_o6694948048012_cx, 0.5+p_o6694948048012_cy), vec2(p_o6694948048012_scale_x, p_o6694948048012_scale_y))).y));

// #output0: quantize (o900416408580)
vec4 o900416408580_0_1_rgba = vec4(floor(vec4(vec3(o440754248939_0_1_f), 1.0).rgb*p_o900416408580_steps)/p_o900416408580_steps, vec4(vec3(o440754248939_0_1_f), 1.0).a);

// #output0: colorize (o3412871617786)
vec4 o3412871617786_0_1_rgba = o3412871617786_gradient_gradient_fct((dot((o900416408580_0_1_rgba).rgb, vec3(1.0))/3.0));

// #output0: scale (o6694948048012)
vec4 o6694948048012_0_1_rgba = o3412871617786_0_1_rgba;

// #output0: translate (o14041825154670)
vec4 o14041825154670_0_1_rgba = o6694948048012_0_1_rgba;

	vec3 albedo_tex = ((o14041825154670_0_1_rgba).rgb).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o354787792922_albedo_color.rgb;
	METALLIC = 1.0*p_o354787792922_metallic;
	ROUGHNESS = 1.0*p_o354787792922_roughness;
	NORMAL = vec3(0.5);
	EMISSION = vec3(0.0)*p_o354787792922_emission_energy;
}
