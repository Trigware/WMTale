shader_type canvas_item;

const float image_pixel_height = 36.0;
uniform float sink_progression = 0.0;
uniform bool shader_disabled = false;
varying float local_y;

void vertex()
{
	if (!shader_disabled) {
		float pixel_step = 1.0 / image_pixel_height;
		float floored_progress = floor(sink_progression / pixel_step) * pixel_step;
		VERTEX.y += image_pixel_height * floored_progress;
		local_y = VERTEX.y;
	}
}

void fragment()
{
	if (!shader_disabled && local_y > image_pixel_height / 2.0) {
        COLOR.a = 0.0;
    }
}