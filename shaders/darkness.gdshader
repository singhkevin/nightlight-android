shader_type canvas_item;
// The night itself: opaque far away, with a soft hole around the flame.
uniform float radius = 300.0;
uniform float sheet = 4000.0;
uniform vec3 tint = vec3(0.012, 0.012, 0.055);
uniform float strength = 0.965;

void fragment() {
	float d = length(UV - vec2(0.5)) * sheet / radius;
	float a = smoothstep(0.52, 1.32, d);
	// A touch of noise stops the gradient from showing visible bands on a dark screen.
	float n = fract(52.9829189 * fract(dot(FRAGCOORD.xy, vec2(0.06711056, 0.00583715)))) - 0.5;
	COLOR = vec4(tint, clamp(a * strength + n * 0.008 * step(0.001, a), 0.0, 1.0));
}
