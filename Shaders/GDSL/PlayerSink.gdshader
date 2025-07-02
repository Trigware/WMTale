shader_type canvas_item;

const float image_scale = 3.0;
const float image_pixel_height = 36.0;

uniform float sink_progression = 0;

void fragment() {
	float inverted_obstruct = 1.0 - sink_progression;
	float rescaled_obstruct = inverted_obstruct / image_scale;
	float pixel_step = 1.0 / (image_pixel_height * image_scale);
	float floored_pixel_y = floor(UV.y / pixel_step) * pixel_step;
	
	if (floored_pixel_y > rescaled_obstruct) {
		COLOR.a = 0.0;
	}
}

void vertex()
{
	if (sink_progression > 0.0)
	{
		float pixel_step = 1.0 / image_pixel_height;
		float floored_y_pos = floor(sink_progression / pixel_step) * pixel_step;
		VERTEX.y += floored_y_pos * image_pixel_height;
	}
}