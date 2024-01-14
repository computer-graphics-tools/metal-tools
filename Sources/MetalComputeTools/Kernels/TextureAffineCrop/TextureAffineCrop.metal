#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void textureAffineCrop(texture2d<half, access::sample> source [[ texture(0) ]],
                              texture2d<half, access::write> destination [[ texture(1) ]],
                              constant float3x3& transform [[ buffer(0) ]],
                              ushort2 position [[thread_position_in_grid]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    constexpr sampler s(coord::normalized,
                        address::clamp_to_edge,
                        filter::linear);
    const auto positionF = float2(position);
    const auto textureSizeF = float2(textureSize);
    const auto normalizedPosition = (positionF + 0.5f) / textureSizeF;

    const auto targetPosition = transform * float3(normalizedPosition, 1.0f);
    const auto sourceValue = source.sample(s, targetPosition.xy);

    destination.write(sourceValue, position);
}
