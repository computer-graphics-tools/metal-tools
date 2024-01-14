#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

template <typename T>
void textureMask(texture2d<T, access::read> source,
                 texture2d<float, access::sample> mask,
                 texture2d<T, access::write> destination,
                 constant bool& isInversed,
                 const ushort2 position) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    const auto sourceValue = float4(source.read(position));

    constexpr sampler s(coord::normalized,
                        address::clamp_to_edge,
                        filter::linear);
    const auto positionF = float2(position);
    const auto textureSizeF = float2(textureSize);
    const auto normalizedPosition = (positionF + 0.5f) / textureSizeF;

    auto maskValue = mask.sample(s, normalizedPosition);
    if (isInversed) {
        maskValue = 1.0f - maskValue;
    }
    const auto resultValue = vec<T, 4>(sourceValue * maskValue.r);

    destination.write(resultValue, position);
}

#define outerArguments(T)                                 \
(texture2d<T, access::read> source [[ texture(0) ]],      \
texture2d<float, access::sample> mask [[ texture(1) ]],   \
texture2d<T, access::write> destination [[ texture(2) ]], \
constant bool& isInversed [[ buffer(0) ]],                \
const ushort2 position [[thread_position_in_grid]])       \

#define innerArguments \
(source,               \
mask,                  \
destination,           \
isInversed,            \
position)              \

generateKernels(textureMask)

#undef outerArguments
#undef innerArguments
