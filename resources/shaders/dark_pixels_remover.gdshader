shader_type canvas_item;

uniform float maximum_darkness: hint_range(0.0, 1.0, 0.01) = 0.1;


void fragment() {
	float darkness = COLOR.r + COLOR.g + COLOR.b;
	if (darkness < maximum_darkness) {
		COLOR.a = 0.0;
	}
}
