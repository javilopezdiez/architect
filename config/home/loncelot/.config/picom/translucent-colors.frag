#version 330

in vec2 texcoord;
uniform sampler2D tex;
uniform float opacity;

const vec3 translucent_colors[7] = vec3[7](

    vec3(0.101961, 0.101961, 0.101961), // #1A1A1A # thunar file bar
    vec3(0.149020, 0.149020, 0.149020), // #262626 # thunar background

    vec3(0.129412, 0.129412, 0.129412), // #212121 # chat background
    
    // VSCode
    vec3(0.000000, 0.000000, 0.000000), // #000000 # background
    vec3(0.250980, 0.250980, 0.250980), // #404040 # menu, selection background
    vec3(0.105882, 0.105882, 0.105882), // #1b1b1b # tab background
    vec3(0.066667, 0.066667, 0.066667)  // #111111 # scrollbar, tab, hover or inactive
);

/*
 * How much color variation to tolerate.
 *
 * 0.0 = exact RGB match
 *
 * A small value such as 0.01 helps with tiny rendering
 * differences caused by applications.
 */
const float color_tolerance = 0.005;

bool is_translucent_color(vec3 color) {
    for (int i = 0; i < 4; i++) {
        if (distance(color, translucent_colors[i]) <= color_tolerance) {
            return true;
        }
    }
    return false;
}

vec4 window_shader() {
    vec2 texsize = textureSize(tex, 0);
    vec4 c = texture2D(tex, texcoord / texsize, 0);
    /*
     * Only colors in translucent_colors receive the
     * window's Picom opacity.
     */
    if (is_translucent_color(c.rgb)) {
        c.rgb *= opacity;
        c.a   *= opacity;
    }

    return c;
}