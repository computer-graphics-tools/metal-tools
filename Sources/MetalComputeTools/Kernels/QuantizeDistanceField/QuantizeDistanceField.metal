#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void quantizeDistanceField(texture2d<float, access::sample> source [[ texture(0) ]],
                                  texture2d<float, access::write> destination [[ texture(1) ]],
                                  constant float& normalizationFactor [[buffer(0)]],
                                  uint2 position [[thread_position_in_grid]]) {
    const uint2 textureSize = {
        destination.get_width(),
        destination.get_height()
    };
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);
    
    constexpr sampler s(coord::normalized,
                        address::clamp_to_edge,
                        filter::linear);
    
    const float2 positionF = float2(position);
    const float2 textureSizeF = float2(textureSize);
    const float2 normalizedPosition = (positionF + 0.5f) / textureSizeF;

    const float distance = source.sample(s, normalizedPosition).r;
    const float clampDist = fmax(-normalizationFactor, fmin(distance, normalizationFactor));
    const float scaledDist = clampDist / normalizationFactor;
    const float resultValue = ((scaledDist + 1.0f) / 2.0f);
    destination.write(resultValue, position);
}
