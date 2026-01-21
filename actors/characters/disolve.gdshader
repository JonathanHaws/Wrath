shader_type spatial;
//credit DisplacedFikaDev

render_mode cull_disabled; // Cant change this dynamicalyy. Must just make meshes with no visible backface...
// but honestly seeing interior of the mesh looks better then seeing disparate parts so might keep for simplicity
// having smooth transparency AND depth testing seems to be very difficult so will revisit only if feeling masochistic. 

//uniform float fade_near = 0.02;
//uniform float fade_far  = 0.005;
//uniform sampler2D depth_tex : hint_depth_texture;

uniform sampler2D albedo_texture : source_color;
uniform vec3 albedo_color : source_color = vec3(1.0);
uniform sampler2D emission_texture : source_color;
uniform float emission_texture_intensity : hint_range(0.0, 50.0) = 1.0;
uniform bool emission_texture_enabled = true;
uniform vec3 inside_color: source_color;
uniform float dissolve_amount: hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture;

uniform vec3 glow_color: source_color = vec3(0.533, 0.533, 0.533);
uniform float glow_intensitiy = 1.3;
uniform float glow_border_width: hint_range(0.0, 0.25) = 0.018;
uniform float glow_border_smoothness: hint_range(0.0, 0.1) = 0.003;

uniform sampler2D normal_texture;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
uniform bool use_normal_map = false;

void fragment() {

	float dissolve_noise = texture(noise_texture, (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xy * 0.1).r;
	// planar mapping so dont have to worry about messed up uv as it uses world space

	float border_mask = 0.0;
	if (dissolve_amount > 0.0) {
		float border_size = dissolve_amount + glow_border_width;
		border_mask = 1.0 - smoothstep(
			border_size - glow_border_smoothness,
			border_size + glow_border_smoothness,
			dissolve_noise
		);
	}

	vec4 albedo_tex = texture(albedo_texture, UV).rgba;
	if (albedo_tex.a < 0.5) {  discard; } // force hard transparency
	ALBEDO = albedo_tex.rgb * albedo_color;

	ALPHA = dissolve_noise;
	ALPHA_SCISSOR_THRESHOLD = dissolve_amount;

	vec3 surface_emisson = mix(vec3(0.0), glow_color, border_mask);
	if (emission_texture_enabled) { surface_emisson += texture(emission_texture, UV).rgb * emission_texture_intensity; }
	EMISSION = surface_emisson * glow_intensitiy;

	if (use_normal_map) { NORMAL_MAP = texture(normal_texture, UV).xyz; }

	//float depth = texture(depth_tex, SCREEN_UV).r * 15.0;
	//if (depth > .01){
		//ALBEDO = vec3(0.0, 0.0, 1.0); // hard cutoff blue 
		//ALBEDO = mix(ALBEDO, vec3(0.0,0.0,1.0), smoothstep(0.01, 1.0, depth)); // smooth cuttoff blue
	//}

}
