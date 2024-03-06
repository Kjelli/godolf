shader_type canvas_item;
 
uniform vec4 custom_color: source_color = vec4(0.1);
uniform vec2 direction = vec2(1.0, 0.0);
uniform float speed_scale = 0.01;
 
void fragment(){
    vec2 move = direction * TIME * speed_scale;
    COLOR = texture(TEXTURE, UV + move) * custom_color;
}