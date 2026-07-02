shader_type spatial;
render_mode unshaded;
uniform sampler2D mirror_texture : source_color, filter_linear_mipmap;
uniform sampler2D mask_texture;
uniform sampler2D overlay_texture : source_color;

void vertex() {
	UV.x = 1.0 - UV.x;
}

void fragment() {
	vec4 mirror = texture(mirror_texture, UV);
	vec4 mask = texture(mask_texture, UV);
	vec4 overlay = texture(overlay_texture, UV);

	ALBEDO = mix(mirror.rgb, overlay.rgb, overlay.a);
	ALPHA = max(mask.a, overlay.a );
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
