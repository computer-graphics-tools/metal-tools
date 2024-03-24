#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

template <typename T>
void integralImage(
    texture2d<T, access::read> source,
    texture2d<T, access::write> destination,
    constant bool& isHorisontalPass,
    const uint position
) {
    const uint2 textureSize = {
        destination.get_width(),
        destination.get_height()
    };

    if (isHorisontalPass) {
        if (!deviceSupportsNonuniformThreadgroups) {
            if (position >= textureSize.y) {
                return;
            }
        }

        auto previousValue = vec<T, 4>(0);

        for (uint i = 0; i < textureSize.x; ++i) {
            const auto currentPosition = uint2(i, position);
            const auto currentValue = source.read(currentPosition);
            const auto resultValue = previousValue + currentValue;
            destination.write(resultValue, currentPosition);
            previousValue = resultValue;
        }
    } else {
        if (!deviceSupportsNonuniformThreadgroups) {
            if (position >= textureSize.x) {
                return;
            }
        }

        auto previousValue = vec<T, 4>(0);

        for (uint i = 0; i < textureSize.y; ++i) {
            const auto currentPosition = uint2(position, i);
            const auto currentValue = source.read(currentPosition);
            const auto resultValue = previousValue + currentValue;
            destination.write(resultValue, currentPosition);
            previousValue = resultValue;
        }
    }
}

#define outerArguments(T) (                                   \
    texture2d<T, access::read> source [[ texture(0) ]],       \
    texture2d<T, access::write> destination [[ texture(1) ]], \
    constant bool& isHorisontalPass [[ buffer(0) ]],          \
    const ushort position [[ thread_position_in_grid ]]       \
)                                                             \

#define innerArguments ( \
    source,              \
    destination,         \
    isHorisontalPass,    \
    position             \
)                        \

generateKernels(integralImage)

#undef outerArguments
#undef innerArguments
