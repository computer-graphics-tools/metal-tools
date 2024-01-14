#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

template <typename T>
void textureInterpolation(texture2d<T, access::read> sourceOne,
                          texture2d<T, access::read> sourceTwo,
                          texture2d<T, access::write> destination,
                          constant float& weight,
                          const ushort2 position) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    const auto sourceValueOne = sourceOne.read(position);
    const auto sourceValueTwo = sourceTwo.read(position);
    const auto resultValue = sourceValueOne + vec<T, 4>(float4(sourceValueTwo - sourceValueOne) * weight);

    destination.write(resultValue, position);
}

#define outerArguments(T)                                 \
(texture2d<T, access::read> sourceOne [[ texture(0) ]],   \
texture2d<T, access::read> sourceTwo [[ texture(1) ]],    \
texture2d<T, access::write> destination [[ texture(2) ]], \
constant float& weight [[ buffer(0) ]],                   \
const ushort2 position [[ thread_position_in_grid ]])     \

#define innerArguments \
(sourceOne,            \
sourceTwo,             \
destination,           \
weight,                \
position)              \

generateKernels(textureInterpolation)

#undef outerArguments
#undef innerArguments
