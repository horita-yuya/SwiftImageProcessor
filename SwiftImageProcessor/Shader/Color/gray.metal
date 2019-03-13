#include <metal_stdlib>
#include "utilities.h"
using namespace metal;

kernel void gray_average(texture2d<half, access::read> inTexture [[ texture(0) ]],
                       texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                       uint2 gid [[ thread_position_in_grid ]]) {
    half3 color = inTexture.read(gid).rgb;
    half gray = (color.r + color.g + color.b) / 3;
    outTexture.write(half4(gray, gray, gray, 1), gid);
}

kernel void gray_common(texture2d<half, access::read> inTexture [[ texture(0) ]],
                         texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                         uint2 gid [[ thread_position_in_grid ]]) {
    half gray = dot(inTexture.read(gid).rgb, gray_common_factor);
    outTexture.write(half4(gray, gray, gray, 1), gid);
}

kernel void gray_bt709(texture2d<half, access::read> inTexture [[ texture(0) ]],
                       texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                       uint2 gid [[ thread_position_in_grid ]]) {
    half gray = dot(inTexture.read(gid).rgb, bt709);
    outTexture.write(half4(gray, gray, gray, 1), gid);
}

kernel void gray_bt601(texture2d<half, access::read> inTexture [[ texture(0) ]],
                       texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                       uint2 gid [[ thread_position_in_grid ]]) {
    half gray = dot(inTexture.read(gid).rgb, bt601);
    outTexture.write(half4(gray, gray, gray, 1), gid);
}
