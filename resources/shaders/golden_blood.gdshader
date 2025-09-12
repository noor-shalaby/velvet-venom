shader_type canvas_item;


void fragment() {
	COLOR.r += 0.05;
	COLOR.g = COLOR.r;
}