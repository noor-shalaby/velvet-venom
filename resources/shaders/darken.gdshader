// This shader is for use with a CanvasItem, like a Sprite2D.
shader_type canvas_item;

// Uniforms are variables that can be changed from the Godot editor.
// `darken_amount` controls how much the image is darkened.
// A value of 0.0 means no darkening, 1.0 means completely black.
uniform float darken_amount: hint_range(0.0, 1.0) = 0.2;

// `desaturate_amount` controls how much the image is desaturated.
// A value of 0.0 means no desaturation, 1.0 means completely grayscale.
uniform float desaturate_amount: hint_range(0.0, 1.0) = 0.3;

// The fragment function is executed for every pixel of the `CanvasItem`.
void fragment() {
	// `texture()` reads the color of the current pixel from the source texture.
	// `TEXTURE` is the built-in texture for the `CanvasItem`.
	// `UV` is the built-in coordinate for the current pixel.
	vec4 color = texture(TEXTURE, UV);

	// Convert the RGB color to its grayscale equivalent.
	// This is done by calculating the luminance of the color.
	float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));

	// Create a grayscale color using the calculated luminance.
	vec3 grayscale_color = vec3(luma);

	// Mix the original color with the grayscale color based on `desaturate_amount`.
	// `mix()` linearly interpolates between the two colors.
	color.rgb = mix(color.rgb, grayscale_color, desaturate_amount);

	// Darken the color by mixing it with black.
	// The `darken_amount` controls the blend.
	color.rgb = mix(color.rgb, vec3(0.0), darken_amount);

	// Set the final `COLOR` to be displayed.
	// The `alpha` value from the original color is preserved.
	COLOR = color;
}