#ifndef utilities_h
#define utilities_h
#include <metal_stdlib>

constant half3 gray_common_factor(0.3, 0.59, 0.11);
constant half3 bt709(0.2126, 0.7152, 0.0722);
constant half3 bt601(0.299, 0.587, 0.114);
constant half3 luminance_vector(0.2125, 0.7154, 0.0721);

half gauss(half x, half sigma);
#endif
