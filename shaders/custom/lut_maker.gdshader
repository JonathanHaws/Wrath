shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture;
uniform vec3 shadows;
uniform vec3 midtones;
uniform vec3 highlights;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 color = texture(screen_tex, uv).rgb;
	float lum = dot(color, vec3(0.2126, 0.7152, 0.0722));
	vec3 shadow_factor = vec3(clamp((0.5 - lum) * 2.0, 0.0, 1.0));
	vec3 highlight_factor = vec3(clamp((lum - 0.5) * 2.0, 0.0, 1.0));
	vec3 midtone_factor = vec3(1.0) - shadow_factor - highlight_factor;
	color += shadows * shadow_factor;
	color += midtones * midtone_factor;
	color += highlights * highlight_factor;
	COLOR = vec4(color, 1.0);
}