shader_type canvas_item;

uniform float darken_amount: hint_range(0.0, 1.0) = 0.5;
uniform float desaturate_amount: hint_range(0.0, 1.0) = 1.0;

uniform vec4 blink_color: source_color = vec4(1, 1, 1, 1);
uniform float blink_intensity = 0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));

	// Create a grayscale color using the calculated luminance.
	vec3 grayscale_color = vec3(luma);

	// Mix the original color with the grayscale color based on `desaturate_amount`.
	// `mix()` linearly interpolates between the two colors.
	color.rgb = mix(color.rgb, grayscale_color, desaturate_amount);

	// Darken the color by mixing it with black.
	// The `darken_amount` controls the blend.
	color.rgb = mix(color.rgb, vec3(0.0), darken_amount);

	color = mix(color, blink_color, blink_intensity * color.a);

	COLOR = color;
}