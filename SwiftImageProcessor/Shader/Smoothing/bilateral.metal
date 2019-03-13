#include <metal_stdlib>
#include "utilities.h"
using namespace metal;

half kernel_factor(half center_luminance,
                   half surrounding_luminance,
                   half sigma,
                   half luminance_sigma,
                   int2 normalized_position) {
    half luminance_gauss = gauss(center_luminance - surrounding_luminance, luminance_sigma);
    half space_gauss = gauss(normalized_position.x, sigma) * gauss(normalized_position.y, sigma);
    
    return space_gauss * luminance_gauss;
}

kernel void bilateral(texture2d<half, access::read> inTexture [[ texture(0) ]],
                      texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                      constant float &sigma [[ buffer(0) ]],
                      constant float &luminance_sigma [[ buffer(1) ]],
                      uint2 gid [[ thread_position_in_grid ]]) {
    constexpr int kernel_size = 7;
    constexpr int radius = kernel_size / 2;
    
    half kernel_weight = 0;
    half center_luminance = dot(inTexture.read(gid).rgb, luminance_vector);
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            uint2 texture_index(gid.x + (i - radius), gid.y + (j - radius));
            half surrounding_luminance = dot(inTexture.read(texture_index).rgb, luminance_vector);
            int2 normalized_position(i - radius, j - radius);
            
            kernel_weight += kernel_factor(center_luminance, surrounding_luminance, sigma, luminance_sigma, normalized_position);
        }
    }
    
    half4 acc_color(0, 0, 0, 0);
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            uint2 texture_index(gid.x + (i - radius), gid.y + (j - radius));
            half4 texture = inTexture.read(texture_index);
            half surrounding_luminance = dot(texture.rgb, luminance_vector);
            int2 normalized_position(i - radius, j - radius);
            
            half factor = kernel_factor(center_luminance, surrounding_luminance, sigma, luminance_sigma, normalized_position) / kernel_weight;
            acc_color += factor * texture.rgba;
        }
    }
    
    outTexture.write(acc_color, gid);
}
