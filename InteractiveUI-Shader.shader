shader_type canvas_item;

uniform vec4 color : hint_color = vec4(1.0);
uniform float width : hint_range(0, 100) = 10.0;
uniform float margin : hint_range(0, 100) = 10.0;
uniform int pattern = 2; // diamond, circle, square
const bool inside = true;

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		
		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a == 0.0) == inside) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	vec2 uv = UV;
	
	vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(margin * 2.0));
	
	uv = (uv - texture_pixel_size * margin) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
	
	if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
		COLOR.a = 0.0;
	} else {
		COLOR = texture(TEXTURE, uv);
	}
	
	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
		COLOR.a += (1.0 - COLOR.a) * color.a;
	}
	
	COLOR.rgb = mix(COLOR.rgb, color.rgb, color.a / 5.0);
}