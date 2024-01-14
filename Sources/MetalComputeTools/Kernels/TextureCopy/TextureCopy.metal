#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

template <typename T>
void textureCopy(texture2d<T, access::read> source,
                 texture2d<T, access::write> destination,
                 constant short2& readOffset,
                 constant short2& writeOffset,
                 constant ushort2& gridSize,
                 const ushort2 position) {
    checkPosition(position, gridSize, deviceSupportsNonuniformThreadgroups);

    const auto readPosition = ushort2(short2(position) + readOffset);
    const auto writePosition = ushort2(short2(position) + writeOffset);

    const auto resultValue = source.read(readPosition);
    destination.write(resultValue, writePosition);
}

#define outerArguments(T)                                        \
(texture2d<T, access::read> source [[ texture(0) ]],             \
texture2d<T, access::write> destination [[ texture(1) ]],        \
constant short2& readOffset [[ buffer(0) ]],                     \
constant short2& writeOffset [[ buffer(1) ]],                    \
constant ushort2& gridSize [[ buffer(2),                         \
function_constant(deviceDoesntSupportNonuniformThreadgroups) ]], \
const ushort2 position [[ thread_position_in_grid ]])            \

#define innerArguments \
(source,               \
destination,           \
readOffset,            \
writeOffset,           \
gridSize,              \
position)              \

generateKernels(textureCopy)

#undef outerArguments
#undef innerArguments
