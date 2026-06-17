//
//  nebula.metal
//  Gito
//
//  Created by Vivek Chahal on 6/17/26.
//
#include <metal_stdlib>
using namespace metal;

// Simple fractional noise generator for cosmic dust texture
float noise(float2 uv) {
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
}

// Layered noise for a smooth nebula effect
float nebula(float2 uv) {
    float val = 0.0;
    float scale = 1.0;
    for (int i = 0; i < 4; i++) {
        val += noise(uv * scale) * (1.0 / scale);
        scale *= 2.0;
    }
    return val;
}

[[ stitchable ]] half4 cosmicBackground(float2 position, float4 bounds, float time) {
    // Normalize coordinates
    float2 uv = position / bounds.zw;

    // Rotate and distort slightly to mimic the diagonal Milky Way band
    float diagonal = uv.x + uv.y * 1.5;

    // Base nebula density
    float density = nebula(uv * 3.0 + float2(time * 0.01, 0.0));

    // Concentrate the dust along a diagonal band like the image
    float band = smoothstep(0.4, 0.0, abs(diagonal - 1.0));
    density *= (band * 0.7 + 0.3);

    // Sepia/Amber color grading matching your image
    half3 baseColor = half3(0.12, 0.04, 0.01);      // Deep dark amber
    half3 nebulaColor = half3(0.85, 0.45, 0.15);    // Bright golden copper

    half3 finalColor = mix(baseColor, nebulaColor, half(density * 0.25));

    // Add subtle micro-grain to match the star-field texture
    finalColor += half(noise(position) * 0.04);

    return half4(finalColor, 1.0);
}
