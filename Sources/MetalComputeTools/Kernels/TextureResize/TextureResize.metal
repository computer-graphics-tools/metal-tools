#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void textureResize(texture2d<float, access::sample> source [[ texture(0) ]],
                          texture2d<float, access::write> destination [[ texture(1) ]],
                          sampler s [[ sampler(0) ]],
                          const ushort2 position [[ thread_position_in_grid ]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    const auto positionF = float2(position);
    const auto textureSizeF = float2(textureSize);
    const auto normalizedPosition = (positionF + 0.5f) / textureSizeF;

    auto sampledValue = source.sample(s, normalizedPosition);
    destination.write(sampledValue, position);
}
