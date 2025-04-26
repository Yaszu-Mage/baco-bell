    shader_type canvas_item;

    // Adjust this value to control pixel size
    uniform float pixel_size : hint_range(1, 10000, 1) = 4.0;

    void fragment() {
        // Get the UV coordinates
        vec2 uv = UV;

        // Calculate the pixelated UV coordinates
        vec2 pixelated_uv = floor(uv * pixel_size) / pixel_size;

        // Sample the texture with the pixelated UV coordinates
        vec4 color = texture(TEXTURE, pixelated_uv);

        // Output the color
        COLOR = color;
    }