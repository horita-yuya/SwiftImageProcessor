#include <metal_stdlib>
#include "utilities.h"
using namespace metal;

// Under constracting
//kernel void median(texture2d<half, access::read> inTexture [[ texture(0) ]],
//                   texture2d<half, access::read_write> outTexture [[ texture(1) ]],
//                   uint2 gid [[ thread_position_in_grid ]]) {
//
//    outTexture.write(half4(m, m, m, 1), gid);
//}
