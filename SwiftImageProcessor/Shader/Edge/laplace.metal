#include <metal_stdlib>
#include "utilities.h"
using namespace metal;

kernel void laplace(texture2d<half, access::read> inTexture [[ texture(0) ]],
                    texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                    uint2 gid [[ thread_position_in_grid ]]) {
    constexpr int kernel_size = 3;
    constexpr int radius = kernel_size / 2;
    
    half3x3 laplace_kernel = half3x3(0, 1, 0,
                                     1, -4, 1,
                                     0, 1, 0);
    
    half4 acc_color(0, 0, 0, 0);
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
            acc_color += laplace_kernel[i][j] * inTexture.read(textureIndex).rgba;
        }
    }
    
    half value = dot(acc_color.rgb, bt601);
    half4 gray_color(value, value, value, 1.0);
    
    outTexture.write(gray_color, gid);
}

kernel void laplace_eight_surrounding(texture2d<half, access::read> inTexture [[ texture(0) ]],
                                      texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                                      uint2 gid [[ thread_position_in_grid ]]) {
    constexpr int kernel_size = 3;
    constexpr int radius = kernel_size / 2;
    
    half3x3 laplace_kernel = half3x3(1, 1, 1,
                                     1, -8, 1,
                                     1, 1, 1);
    
    half4 acc_color(0, 0, 0, 0);
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
            acc_color += laplace_kernel[i][j] * inTexture.read(textureIndex).rgba;
        }
    }
    
    half value = dot(acc_color.rgb, bt601);
    half4 gray_color(value, value, value, 1.0);
    
    outTexture.write(gray_color, gid);
}
