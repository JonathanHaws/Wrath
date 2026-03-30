shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never; // fog disabled stops clipping issue but now not including transparent things in post process
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform sampler3D lut_tex; // 16x16x16 orf 32x32x32
uniform float lut_size = 16.0; 

void vertex(){
	 POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb; 

	vec3 coord = clamp(color * (lut_size - 1.0) + 0.5, 0.0, lut_size - 1.0) / lut_size;

	vec3 lut_color = texture(lut_tex, coord).rgb;

	ALBEDO = lut_color;
}