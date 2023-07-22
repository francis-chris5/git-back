shader_type sky;

uniform vec3 base_color : source_color;
uniform sampler2D clouds;
uniform vec2 direction = vec2(0.2, 2.3);

void sky() {
	vec2 wind = (TIME * direction) * 0.002;
	vec3 final_sky = mix(base_color, texture(clouds, SKY_COORDS + wind).rgb, 0.4);
	COLOR = final_sky;
}
