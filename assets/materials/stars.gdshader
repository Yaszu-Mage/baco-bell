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
const vec4 p_o357958686749_albedo_color = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o357958686749_metallic = 0.000000000;
const float p_o357958686749_roughness = 1.000000000;
const float p_o357958686749_emission_energy = 1.000000000;
const float p_o357958686749_normal = 1.000000000;
const float p_o357958686749_ao = 1.000000000;
const float p_o357958686749_depth_scale = 0.500000000;
const float p_o23615978345791_translate_y = 0.000000000;
const float p_o12176718828260_amount1 = 0.740000000;
const float p_o9955885190280_gradient_pos[4] = float[]( 0.000000000, 0.509816110, 0.695706904, 0.863645852 );
const vec4 p_o9955885190280_gradient_col[4] = vec4[]( vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000), vec4(0.789062500, 0.000000000, 0.224165559, 1.000000000), vec4(1.000000000, 0.843750000, 0.000000000, 1.000000000), vec4(1.000000000, 0.539062500, 0.000000000, 1.000000000) );
const float p_o10980486551888_cx = 0.000000000;
const float p_o10980486551888_cy = 0.000000000;
const float p_o10980486551888_scale_x = 0.500000000;
const float p_o10980486551888_scale_y = 0.500000000;
const float seed_o3170071745525 = 0.000000000;
const float p_o3170071745525_count = 25.000000000;
const float p_o3170071745525_scale_x = 1.000000000;
const float p_o3170071745525_scale_y = 1.000000000;
const float p_o3170071745525_rotate = 71.900000000;
const float p_o3170071745525_scale = 0.320000000;
const float p_o3170071745525_value = 0.820000000;
const float p_o76734472920833_cx = 0.000000000;
const float p_o76734472920833_cy = 0.000000000;
const float p_o698401950817_sides = 5.000000000;
const float p_o698401950817_radius = 0.100000000;
const float p_o698401950817_edge = 0.260000000;
const float p_o34928318226102_amplitude = 0.150000000;
const float p_o34928318226102_frequency = 16.000000000;
const float p_o40343332459482_gradient_pos[2] = float[]( 0.000000000, 1.000000000 );
const vec4 p_o40343332459482_gradient_col[2] = vec4[]( vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000), vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000) );
const float p_o70221339565732_sides = 5.000000000;
const float p_o70221339565732_radius = 0.100000000;
const float p_o70221339565732_edge = 0.260000000;
// #globals: translate (o23615978345791)
// #globals: blend
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
// #globals: adjust_hsv
vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
// #globals: blend2 (o12176718828260)
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hue(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	vec3 outcol = c2;
	vec3 hsv, hsv2, tmp;
	hsv2 = rgb_to_hsv(c1);
	if (hsv2.y != 0.0) {
		hsv = rgb_to_hsv(outcol);
		hsv.x = hsv2.x;
		tmp = hsv_to_rgb(hsv);
		outcol = mix(outcol, tmp, opacity);
	}
	return outcol;
}
vec3 blend_saturation(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	float facm = 1.0 - opacity;
	vec3 outcol = c2;
	vec3 hsv, hsv2;
	hsv = rgb_to_hsv(outcol);
	if (hsv.y != 0.0) {
		hsv2 = rgb_to_hsv(c1);
		hsv.y = facm * hsv.y + opacity * hsv2.y;
		outcol = hsv_to_rgb(hsv);
	}
	return outcol;
}
vec3 blend_color(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	float facm = 1.0 - opacity;
	vec3 outcol = c2;
	vec3 hsv, hsv2, tmp;
	hsv2 = rgb_to_hsv(c1);
	if (hsv2.y != 0.0) {
		hsv = rgb_to_hsv(outcol);
		hsv.x = hsv2.x;
		hsv.y = hsv2.y;
		tmp = hsv_to_rgb(hsv);
		outcol = mix(outcol, tmp, opacity);
	}
	return outcol;
}
vec3 blend_value(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	float facm = 1.0 - opacity;
	vec3 hsv, hsv2;
	hsv = rgb_to_hsv(c2);
	hsv2 = rgb_to_hsv(c1);
	hsv.z = facm * hsv.z + opacity * hsv2.z;
	return hsv_to_rgb(hsv);
}
// #globals: scale (o10980486551888)
vec2 scale(vec2 uv, vec2 center, vec2 scale) {
	uv -= center;
	uv /= scale;
	uv += center;
	return uv;
}
// #globals: shape (o698401950817)
float shape_circle(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
// #globals: custom_uv
vec2 get_from_tileset(float count, float seed, vec2 uv) {
	return clamp((uv+floor(rand2(vec2(seed))*count))/count, vec2(0.0), vec2(1.0));
}
vec2 custom_uv_transform(vec2 uv, vec2 cst_scale, float rnd_rotate, float rnd_scale, vec2 seed) {
	seed = rand2(seed);
	uv -= vec2(0.5);
	float angle = (seed.x * 2.0 - 1.0) * rnd_rotate;
	float ca = cos(angle);
	float sa = sin(angle);
	uv = vec2(ca*uv.x+sa*uv.y, -sa*uv.x+ca*uv.y);
	uv *= (seed.y-0.5)*2.0*rnd_scale+1.0;
	uv /= cst_scale;
	uv += vec2(0.5);
	return uv;
}
vec4 o9955885190280_gradient_gradient_fct(float x) {
  if (x < p_o9955885190280_gradient_pos[1]) {
    return p_o9955885190280_gradient_col[0];
  } else if (x < p_o9955885190280_gradient_pos[2]) {
    return p_o9955885190280_gradient_col[1];
  } else if (x < p_o9955885190280_gradient_pos[3]) {
    return p_o9955885190280_gradient_col[2];
  }
  return p_o9955885190280_gradient_col[3];
}
vec4 o40343332459482_gradient_gradient_fct(float x) {
  if (x < p_o40343332459482_gradient_pos[1]) {
    return p_o40343332459482_gradient_col[0];
  }
  return p_o40343332459482_gradient_col[1];
}
float o3170071745525_input_in(vec2 uv, float _seed_variation_) {
// #output0: sine_wave (o34928318226102)
float o34928318226102_0_1_f = 1.0-abs(2.0*((scale(uv, vec2(0.5+p_o76734472920833_cx, 0.5+p_o76734472920833_cy), vec2((sin(elapsed_time)*0.9), (sin(elapsed_time)*0.9)))).y-0.5)-p_o34928318226102_amplitude*sin((p_o34928318226102_frequency*(scale(uv, vec2(0.5+p_o76734472920833_cx, 0.5+p_o76734472920833_cy), vec2((sin(elapsed_time)*0.9), (sin(elapsed_time)*0.9)))).x+(elapsed_time))*6.28318530718));
// #output0: shape_3 (o70221339565732)
float o70221339565732_0_1_f = shape_star((scale(uv, vec2(0.5+p_o76734472920833_cx, 0.5+p_o76734472920833_cy), vec2((sin(elapsed_time)*0.9), (sin(elapsed_time)*0.9)))), p_o70221339565732_sides, p_o70221339565732_radius*o34928318226102_0_1_f, p_o70221339565732_edge*o34928318226102_0_1_f);
// #output0: colorize_3 (o40343332459482)
vec4 o40343332459482_0_1_rgba = o40343332459482_gradient_gradient_fct(o70221339565732_0_1_f);
// #output0: shape (o698401950817)
float o698401950817_0_1_f = shape_star((scale(uv, vec2(0.5+p_o76734472920833_cx, 0.5+p_o76734472920833_cy), vec2((sin(elapsed_time)*0.9), (sin(elapsed_time)*0.9)))), p_o698401950817_sides, p_o698401950817_radius*(dot((o40343332459482_0_1_rgba).rgb, vec3(1.0))/3.0), p_o698401950817_edge*o34928318226102_0_1_f);
// #output0: scale_2 (o76734472920833)
vec4 o76734472920833_0_1_rgba = vec4(vec3(o698401950817_0_1_f), 1.0);
return (dot((o76734472920833_0_1_rgba).rgb, vec3(1.0))/3.0);
}
// #instance: splatter (o3170071745525)
vec4 splatter_o3170071745525(vec2 uv, int count, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	for (int i = 0; i < count; ++i) {
		seed = rand2(seed);
		rc1 = rand3(seed);
		float mask = 1.0;
		if (mask > 0.01) {
			vec2 pv = fract(uv - seed)-vec2(0.5);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o3170071745525_rotate * 0.01745329251;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv *= (seed.y-0.5)*2.0*p_o3170071745525_scale+1.0;
			pv /= vec2(p_o3170071745525_scale_x, p_o3170071745525_scale_y);
			pv += vec2(0.5);
			seed = rand2(seed);
			vec2 clamped_pv = clamp(pv, vec2(0.0), vec2(1.0));
			if (pv.x != clamped_pv.x || pv.y != clamped_pv.y) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o3170071745525_input_in(pv, false ? seed.x : 0.0)*mask*(1.0-p_o3170071745525_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);

// #code: splatter (o3170071745525)
vec3 o3170071745525_0_instance_uv = vec3(0.0);
vec4 o3170071745525_0_rch = splatter_o3170071745525((scale(((uv)-vec2((elapsed_time*0.02), p_o23615978345791_translate_y)), vec2(0.5+p_o10980486551888_cx, 0.5+p_o10980486551888_cy), vec2(p_o10980486551888_scale_x, p_o10980486551888_scale_y))), int(p_o3170071745525_count), o3170071745525_0_instance_uv, vec2(float((seed_o3170071745525+fract(_seed_variation_)))), _seed_variation_);
// #output0: splatter (o3170071745525)
float o3170071745525_0_1_f = o3170071745525_0_rch.a;

// #output0: scale (o10980486551888)
vec4 o10980486551888_0_1_rgba = vec4(vec3(o3170071745525_0_1_f), 1.0);

// #output0: colorize (o9955885190280)
vec4 o9955885190280_0_1_rgba = o9955885190280_gradient_gradient_fct((dot((o10980486551888_0_1_rgba).rgb, vec3(1.0))/3.0));

// #code: splatter (o3170071745525)
vec3 o3170071745525_2_instance_uv = vec3(0.0);
vec4 o3170071745525_2_rch = splatter_o3170071745525(((uv)-vec2((elapsed_time*0.02), p_o23615978345791_translate_y)), int(p_o3170071745525_count), o3170071745525_2_instance_uv, vec2(float((seed_o3170071745525+fract(_seed_variation_)))), _seed_variation_);
// #output0: splatter (o3170071745525)
float o3170071745525_0_3_f = o3170071745525_2_rch.a;

// #code: blend2 (o12176718828260)
vec4 o12176718828260_0_b = vec4(vec3(o3170071745525_0_3_f), 1.0);
vec4 o12176718828260_0_l;
float o12176718828260_0_a;

o12176718828260_0_l = o9955885190280_0_1_rgba;
o12176718828260_0_a = p_o12176718828260_amount1*1.0;
o12176718828260_0_b = vec4(blend_overlay(((uv)-vec2((elapsed_time*0.02), p_o23615978345791_translate_y)), o12176718828260_0_l.rgb, o12176718828260_0_b.rgb, o12176718828260_0_a*o12176718828260_0_l.a), min(1.0, o12176718828260_0_b.a+o12176718828260_0_a*o12176718828260_0_l.a));
// #output0: blend2 (o12176718828260)
vec4 o12176718828260_0_1_rgba = o12176718828260_0_b;

// #output0: translate (o23615978345791)
vec4 o23615978345791_0_1_rgba = o12176718828260_0_1_rgba;

	vec3 albedo_tex = ((o23615978345791_0_1_rgba).rgb).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o357958686749_albedo_color.rgb;
	METALLIC = 1.0*p_o357958686749_metallic;
	ROUGHNESS = 1.0*p_o357958686749_roughness;
	NORMAL = vec3(0.5);
	EMISSION = ((o23615978345791_0_1_rgba).rgb)*p_o357958686749_emission_energy;
}



