shader_type canvas_item;
// Each enemy passes a colour and how strongly to blend towards it (in alpha), for hit flashes and elite gold.
varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	COLOR = vec4(mix(t.rgb, tint.rgb, tint.a), t.a);
}
