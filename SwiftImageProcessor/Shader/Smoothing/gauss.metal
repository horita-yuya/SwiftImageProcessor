#include <metal_stdlib>
#include "utilities.h"
using namespace metal;

kernel void gaussian(texture2d<half, access::read> inTexture [[ texture(0) ]],
                     texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                     constant float &sigma [[ buffer(0) ]],
                     uint2 gid [[ thread_position_in_grid ]]) {
    constexpr int kernel_size = 7;
    constexpr int radius = kernel_size / 2;
    
    half kernel_weight = 0;
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            int2 normalized_position(i - radius, j - radius);
            kernel_weight += gauss(normalized_position.x, sigma) * gauss(normalized_position.y, sigma);
        }
    }
    
    half4 acc_color(0, 0, 0, 0);
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            int2 normalized_position(i - radius, j - radius);
            uint2 texture_index(gid.x + (i - radius), gid.y + (j - radius));
            half factor = gauss(normalized_position.x, sigma) * gauss(normalized_position.y, sigma) / kernel_weight;
            acc_color += factor * inTexture.read(texture_index).rgba;
        }
    }
    
    outTexture.write(acc_color, gid);
}

kernel void gaussian_three_dim(texture2d<half, access::read> inTexture [[ texture(0) ]],
                               texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                               uint2 gid [[ thread_position_in_grid ]]) {
    constexpr int kernel_size = 3;
    constexpr int radius = kernel_size / 2;
    
    constexpr half kernel_weight = 16;
    half3x3 gauss_kernel = half3x3(1, 2, 1,
                                   2, 4, 2,
                                   1, 2, 1);
    
    half4 acc_color(0, 0, 0, 0);
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            uint2 texture_index(gid.x + (i - radius), gid.y + (j - radius));
            acc_color += gauss_kernel[i][j] * inTexture.read(texture_index).rgba / kernel_weight;
        }
    }
    
    outTexture.write(acc_color, gid);
}

kernel void gaussian_five_dim(texture2d<half, access::read> inTexture [[ texture(0) ]],
                              texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                              uint2 gid [[ thread_position_in_grid ]]) {
    constexpr int kernel_size = 5;
    constexpr int radius = kernel_size / 2;
    
    constexpr half kernel_weight = 256;
    // 5x5 Gauss Kernel
    matrix<half, kernel_size, kernel_size> m;
    m[0][0] = 1; m[0][1] =  4; m[0][2] =  6; m[0][3] =  4; m[0][4] = 1;
    m[1][0] = 4; m[1][1] = 16; m[1][2] = 24; m[1][3] = 16; m[1][4] = 4;
    m[2][0] = 6; m[2][1] = 24; m[2][2] = 36; m[2][3] = 24; m[2][4] = 6;
    m[3][0] = 4; m[3][1] = 16; m[3][2] = 24; m[3][3] = 16; m[3][4] = 4;
    m[4][0] = 1; m[4][1] =  4; m[4][2] =  6; m[4][3] =  4; m[4][4] = 1;
    
    half4 acc_color(0, 0, 0, 0);
    for (int j = 0; j <= kernel_size - 1; j++) {
        for (int i = 0; i <= kernel_size - 1; i++) {
            uint2 texture_index(gid.x + (i - radius), gid.y + (j - radius));
            acc_color += m[i][j] * inTexture.read(texture_index).rgba / kernel_weight;
        }
    }
    
    outTexture.write(acc_color, gid);
}
