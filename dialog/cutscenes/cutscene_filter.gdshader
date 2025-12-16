shader_type canvas_item;

uniform float grayscale_amount : hint_range(0.0, 1.0) = 0.0;
uniform float sepia_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Tính toán Trắng đen (Grayscale)
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grayscale_col = vec3(gray);
    
    // Tính toán Sepia
    vec3 sepia_col;
    sepia_col.r = dot(color.rgb, vec3(0.393, 0.769, 0.189));
    sepia_col.g = dot(color.rgb, vec3(0.349, 0.686, 0.168));
    sepia_col.b = dot(color.rgb, vec3(0.272, 0.534, 0.131));
    
    // Trộn màu: Gốc -> Grayscale -> Sepia
    vec3 final_col = mix(color.rgb, grayscale_col, grayscale_amount);
    final_col = mix(final_col, sepia_col, sepia_amount);
    
    COLOR = vec4(final_col, color.a);
}