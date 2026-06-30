shader_type canvas_item; // LOOK UP TABLE (LUT) Shader
uniform sampler2D screen_tex : hint_screen_texture;
uniform sampler3D default_texture; 
uniform sampler3D destination_texture; 
uniform float blend = 0.0;

uniform bool flip_x = false; // Adds the ability to render the camera x scale negative

void fragment() {
    vec2 uv = SCREEN_UV;
    if (flip_x) { uv.x = 1.0 - uv.x;}
	
	vec3 col = texture(screen_tex, uv).rgb;
	vec3 col_default = texture(default_texture, col).rgb;
	vec3 col_dest    = texture(destination_texture, col).rgb;
	col = mix(col_default, col_dest, blend);
	COLOR = vec4(col, 1.0);
}
