shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float line_count : hint_range(0.0, 2.0) = 0.5;

uniform float line_density : hint_range(0.0, 1.0) = 0.5;

uniform float animation_speed : hint_range(1.0, 20.0) = 10.0;

uniform float mask_size : hint_range(0.0, 1.0) = 0.3; 

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float angle = atan(uv.y, uv.x) / (3.14159 * 2.0) + 0.5;
    float radius = length(uv);
    
    float noise = fract(sin(dot(vec2(angle, floor(TIME * animation_speed)), vec2(12.9898, 78.233))) * 43758.5453);
    
    float mask = step(line_density, noise);
    
    float center_mask = smoothstep(mask_size - 0.1, mask_size, radius);
    
    COLOR = line_color;
    COLOR.a = mask * center_mask * 0.3;
}