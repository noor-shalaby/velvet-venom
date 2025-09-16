shader_type canvas_item;


void fragment() {
	float darkness = COLOR.r + COLOR.g + COLOR.b;
	if (darkness < 0.1) {
		COLOR.a = 0.0;
	}
}
