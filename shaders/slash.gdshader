shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D slash;
uniform sampler2D noise_texure;
uniform float slash_alpha = 0.2;
uniform float offset_speed = .2;
varying vec2 noise_uv;

void vertex() {
	noise_uv = UV + vec2(TIME * offset_speed, 0.0);
}

void fragment() {
	vec4 tex_color = texture(slash, UV);
	float noise = texture(noise_texure, noise_uv).r;
	ALBEDO = tex_color.rgb;
	ALPHA = tex_color.a * slash_alpha * noise;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
