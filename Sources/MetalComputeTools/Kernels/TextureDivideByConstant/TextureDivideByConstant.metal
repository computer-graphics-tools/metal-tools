#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

template <typename T>
void divideByConstant(texture2d<T, access::read> source,
                      texture2d<T, access::write> destination,
                      constant float4& constantValue,
                      const ushort2 position) {
    const auto textureSize = ushort2(source.get_width(),
                                     source.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    auto sourceValue = source.read(position);
    auto destinationValue = sourceValue / vec<T, 4>(constantValue);
    destination.write(destinationValue, position);
}

#define outerArguments(T)                                 \
(texture2d<T, access::read> source [[ texture(0) ]],      \
texture2d<T, access::write> destination [[ texture(1) ]], \
constant float4& constantValue [[ buffer(0) ]],           \
const ushort2 position [[ thread_position_in_grid ]])

#define innerArguments \
(source,               \
destination,           \
constantValue,         \
position)

generateKernels(divideByConstant)

#undef outerArguments
#undef innerArguments
