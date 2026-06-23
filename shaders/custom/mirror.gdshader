shader_type spatial;
render_mode unshaded;

uniform sampler2D tex: source_color, filter_linear_mipmap;

void vertex() {
	UV.x = 1.0 - UV.x;
}

void fragment() {
	vec4 mirror_sample = texture(tex, UV);
	ALBEDO = mirror_sample.rgb;
	ALPHA = mirror_sample.a;

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
