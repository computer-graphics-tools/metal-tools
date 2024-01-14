#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void textureMaskedMix(texture2d<float, access::read> sourceOne [[ texture(0) ]],
                             texture2d<float, access::read> sourceTwo [[ texture(1) ]],
                             texture2d<float, access::sample> mask [[ texture(2) ]],
                             texture2d<float, access::write> destination [[ texture(3) ]],
                             const ushort2 position [[ thread_position_in_grid ]]) {
    const ushort2 textureSize = ushort2(destination.get_width(),
                                        destination.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    constexpr sampler s(coord::normalized,
                        address::clamp_to_edge,
                        filter::linear);
    const auto positionF = float2(position);
    const auto textureSizeF = float2(textureSize);
    const auto normalizedPosition = (positionF + 0.5f) / textureSizeF;

    const auto sourceOneValue = sourceOne.read(position);
    const auto sourceTwoValue = sourceTwo.read(position);
    const auto maskValue = mask.sample(s, normalizedPosition).r;
    const auto resultValue = mix(sourceOneValue,
                                 sourceTwoValue,
                                 maskValue);
    destination.write(resultValue, position);
}
