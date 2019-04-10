#include <metal_stdlib>
#include "utilities.h"
using namespace metal;

kernel void sobel(texture2d<half, access::read> inTexture [[ texture(0) ]],
                  texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                  uint2 gid [[ thread_position_in_grid ]]) {
    constexpr int kernel_size = 3;
    constexpr int radius = kernel_size / 2;
    
    half3x3 sobel_horizontal_kernel = half3x3(-1, -2, -1,
                                              0,  0,  0,
                                              1, 2, 1);
    half3x3 sobel_vertical_kernel = half3x3(1, 0, -1,
                                            2, 0, -2,
                                            1, 0, -1);
    
    half3 result_horizontal(0, 0, 0);
    half3 result_vertical(0, 0, 0);
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            uint2 texture_index(gid.x + (i - radius), gid.y + (j - radius));
            result_horizontal += sobel_horizontal_kernel[i][j] * inTexture.read(texture_index).rgb;
            result_vertical += sobel_vertical_kernel[i][j] * inTexture.read(texture_index).rgb;
        }
    }
    
    half gray_horizontal = dot(result_horizontal.rgb, bt601);
    half gray_vertical = dot(result_vertical.rgb, bt601);
    
    half magnitude = length(half2(gray_horizontal, gray_vertical));
    magnitude = abs(1 - magnitude);
    
    outTexture.write(half4(half3(magnitude), 1), gid);
}
