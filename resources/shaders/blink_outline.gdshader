shader_type canvas_item;

// blink
uniform vec4 blink_color: source_color = vec4(1, 1, 1, 1);
uniform float blink_intensity = 0;

// outline
uniform bool outline_on = false;
uniform vec4 line_color: source_color = vec4(1.0);
uniform float line_thickness: hint_range(0, 10) = 1.0;

// outline
const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), 
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
	// blink
	vec4 color_blink = texture(TEXTURE, UV);
	color_blink = mix(color_blink, blink_color, blink_intensity * color_blink.a);
	
	COLOR = color_blink;
	
	
	
	// outline
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	float outline = 0.0;
	
	for (int i = 0; i < OFFSETS.length(); i++) {
		outline += texture(TEXTURE, UV + size * OFFSETS[i]).a;
	}
	outline = min(outline, 1.0);
	
	vec4 color_outline = texture(TEXTURE, UV);
	if (outline_on) {
		COLOR = mix(color_outline, line_color, outline - color_outline.a);
	}
}