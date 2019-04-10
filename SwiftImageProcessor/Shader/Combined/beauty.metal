#include <metal_stdlib>
#include "utilities.h"
using namespace metal;

half kernel_f(half center_luminance,
                   half surrounding_luminance,
                   half sigma,
                   half luminance_sigma,
                   int2 normalized_position) {
    half luminance_gauss = gauss(center_luminance - surrounding_luminance, luminance_sigma);
    half space_gauss = gauss(normalized_position.x, sigma) * gauss(normalized_position.y, sigma);
    
    return space_gauss * luminance_gauss;
}

kernel void beauty(texture2d<half, access::read> inTexture [[ texture(0) ]],
                      texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                      constant float &sigma [[ buffer(0) ]],
                      constant float &luminance_sigma [[ buffer(1) ]],
                      uint2 gid [[ thread_position_in_grid ]]) {
    
    // Bilateral
    constexpr int kernel_size = 25;
    constexpr int radius = kernel_size / 2;
    
    half3 central_rgb = inTexture.read(gid).rgb;
    half3 central_hsv = rgb2hsv(central_rgb);
    half kernel_weight = 0;
    half center_luminance = central_hsv.z;
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            uint2 texture_index(gid.x + (i - radius), gid.y + (j - radius));
            half surrounding_luminance = rgb2hsv(inTexture.read(texture_index).rgb).z;
            int2 normalized_position(i - radius, j - radius);
            
            kernel_weight += kernel_f(center_luminance, surrounding_luminance, sigma, luminance_sigma, normalized_position);
        }
    }
    
    half bilateral_luminance = 0.0;
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            uint2 texture_index(gid.x + (i - radius), gid.y + (j - radius));
            half4 texture = inTexture.read(texture_index);
            half surrounding_luminance = rgb2hsv(texture.rgb).z;
            int2 normalized_position(i - radius, j - radius);
            
            half factor = kernel_f(center_luminance, surrounding_luminance, sigma, luminance_sigma, normalized_position) / kernel_weight;
            bilateral_luminance += factor * surrounding_luminance;
        }
    }
    // Bilateral End
    
    // Sobel
    half3x3 sobel_horizontal_kernel = half3x3(-1, -2, -1,
                                              0,  0,  0,
                                              1, 2, 1);
    half3x3 sobel_vertical_kernel = half3x3(1, 0, -1,
                                            2, 0, -2,
                                            1, 0, -1);
    
    half3 result_horizontal(0, 0, 0);
    half3 result_vertical(0, 0, 0);
    for (int j = 0; j <= 2; j++) {
        for (int i = 0; i <= 2; i++) {
            uint2 texture_index(gid.x + (i - 1), gid.y + (j - 1));
            result_horizontal += sobel_horizontal_kernel[i][j] * inTexture.read(texture_index).rgb;
            result_vertical += sobel_vertical_kernel[i][j] * inTexture.read(texture_index).rgb;
        }
    }
    
    half gray_horizontal = rgb2hsv(result_horizontal.rgb).z;
    half gray_vertical = rgb2hsv(result_vertical.rgb).z;
    
    half magnitude = length(half2(gray_horizontal, gray_vertical));
    magnitude = abs(1 - magnitude);
    if (magnitude > 0.8) {
        magnitude = 1;
    } else {
        magnitude = 0;
    }
    // Soben End
    
    // combine
    half smooth = bilateral_luminance;
    if (magnitude < 0.5) {
        half alpha = 0.1;
        half smooth_luminance = bilateral_luminance + (center_luminance - bilateral_luminance) * alpha;
        smooth = smooth_luminance;
    }
    
    half3 final_color = hsv2rgb(half3(central_hsv.x, central_hsv.y, smooth));
    
    // Wever-Fechner Law
    final_color = log(1.0 + 0.2 * final_color) / log(1.2);
    
    outTexture.write(half4(final_color, 1), gid);
}
