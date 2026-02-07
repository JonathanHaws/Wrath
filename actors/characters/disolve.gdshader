shader_type spatial;
//credit DisplacedFikaDev
// potentially make script for auto animating material as animation player keyframes can be finicky

render_mode cull_disabled; // Cant change this dynamicalyy. Must just make meshes with no visible backface...
// but honestly seeing interior of the mesh looks better then seeing disparate parts so might keep for simplicity
// having smooth transparency AND depth testing seems to be very difficult so will revisit only if feeling masochistic. 
//uniform float fade_near = 0.02;
//uniform float fade_far  = 0.005;
//uniform sampler2D depth_tex : hint_depth_texture;

group_uniforms Dissolve;
uniform float dissolve_amount: hint_range(0.0, 1.0) = 0.0;
uniform float dissolve_frequency: hint_range(0.2, 12.0) = 6.0; // How granular the disove is 
uniform vec3 dissolve_vector = vec3(2.0, -2.0, 1.0); // Specifies a direction for particles to drift towards

group_uniforms Albedo;
uniform sampler2D albedo_texture : source_color;
uniform vec3 albedo_color : source_color = vec3(1.0);

group_uniforms Emisson;
uniform bool enabled_emisson = true;
uniform sampler2D emission_texture : source_color;
uniform float emission_texture_intensity : hint_range(0.0, 50.0) = 1.0;

uniform vec3 glow_color: source_color = vec3(0.533, 0.533, 0.533);
uniform float glow_intensitiy = 1.3;
uniform float glow_border_width: hint_range(0.0, 0.25) = 0.018;
uniform float glow_border_smoothness: hint_range(0.0, 0.1) = 0.003;

group_uniforms Normal;
uniform sampler2D normal_texture;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
uniform bool enabled_normal = false;

float noise3d(vec3 p) {
	p *= dissolve_frequency;

	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float n000 = fract(sin(dot(i + vec3(0,0,0), vec3(127.1,311.7, 74.7))) * 43758.5453);
	float n100 = fract(sin(dot(i + vec3(1,0,0), vec3(127.1,311.7, 74.7))) * 43758.5453);
	float n010 = fract(sin(dot(i + vec3(0,1,0), vec3(127.1,311.7, 74.7))) * 43758.5453);
	float n110 = fract(sin(dot(i + vec3(1,1,0), vec3(127.1,311.7, 74.7))) * 43758.5453);
	float n001 = fract(sin(dot(i + vec3(0,0,1), vec3(127.1,311.7, 74.7))) * 43758.5453);
	float n101 = fract(sin(dot(i + vec3(1,0,1), vec3(127.1,311.7, 74.7))) * 43758.5453);
	float n011 = fract(sin(dot(i + vec3(0,1,1), vec3(127.1,311.7, 74.7))) * 43758.5453);
	float n111 = fract(sin(dot(i + vec3(1,1,1), vec3(127.1,311.7, 74.7))) * 43758.5453);

	return mix(
		mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
		mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y),
		f.z
	);
}

void fragment() {

	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz
               + dissolve_vector * dissolve_amount;
	float dissolve_noise = noise3d(world_pos );

	//float dissolve_noise = texture(noise_texture, (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xy * 0.1).r;
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
	if (enabled_emisson) { surface_emisson += texture(emission_texture, UV).rgb * emission_texture_intensity; }
	EMISSION = surface_emisson * glow_intensitiy;

	if (enabled_normal) { NORMAL_MAP = texture(normal_texture, UV).xyz; }

	//float depth = texture(depth_tex, SCREEN_UV).r * 15.0;
	//if (depth > .01){
		//ALBEDO = vec3(0.0, 0.0, 1.0); // hard cutoff blue 
		//ALBEDO = mix(ALBEDO, vec3(0.0,0.0,1.0), smoothstep(0.01, 1.0, depth)); // smooth cuttoff blue
	//}

}
