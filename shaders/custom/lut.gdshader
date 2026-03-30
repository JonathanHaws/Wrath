shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled, depth_draw_never;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform sampler3D lut_tex; // 16x16x16 or 32x32x32

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment(){
	vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;   // already linear
	vec3 lut_color = pow(texture(lut_tex, color).rgb, vec3(2.2)); // linearize LUT
	ALBEDO = color;
}