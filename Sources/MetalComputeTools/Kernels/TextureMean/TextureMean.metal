#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

template <typename T>
void textureMean(texture2d<T, access::read> source,
                 constant ushort2& inputBlockSize,
                 device float4& result,
                 threadgroup float4* sharedMemory,
                 const ushort index,
                 const ushort2 position,
                 const ushort2 threadsPerThreadgroup) {
    const auto textureSize = ushort2(source.get_width(),
                                     source.get_height());

    const auto blockStartPosition = position * inputBlockSize;

    auto blockSize = inputBlockSize;
    if (position.x == threadsPerThreadgroup.x || position.y == threadsPerThreadgroup.y) {
        const auto readTerritory = blockStartPosition + inputBlockSize;
        blockSize = inputBlockSize - (readTerritory - textureSize);
    }

    auto totalSumInBlock = float4(0);

    for (ushort x = 0; x < blockSize.x; x++) {
        for (ushort y = 0; y < blockSize.y; y++) {
            const auto readPosition = blockStartPosition + ushort2(x, y);
            const auto currentValue = float4(source.read(readPosition));
            totalSumInBlock += currentValue;
        }
    }

    sharedMemory[index] = totalSumInBlock;

    threadgroup_barrier(mem_flags::mem_threadgroup);

    if (index == 0) {

        auto totalSum = sharedMemory[0];
        const auto threadsInThreadgroup = threadsPerThreadgroup.x * threadsPerThreadgroup.y;
        for (ushort i = 1; i < threadsInThreadgroup; i++) {
            totalSum += sharedMemory[i];
        }

        auto gridSize = textureSize.x * textureSize.y;
        auto meanValue = totalSum / gridSize;

        result = meanValue;
    }
}

#define outerArguments(T)                                          \
(texture2d<T, access::read> source [[ texture(0) ]],               \
constant ushort2& inputBlockSize [[ buffer(0) ]],                  \
device float4& result [[ buffer(1) ]],                             \
threadgroup float4* sharedMemory [[ threadgroup(0) ]],             \
const ushort index [[ thread_index_in_threadgroup ]],              \
const ushort2 position [[ thread_position_in_grid ]],              \
const ushort2 threadsPerThreadgroup [[ threads_per_threadgroup ]]) \

#define innerArguments \
(source,               \
inputBlockSize,        \
result,                \
sharedMemory,          \
index,                 \
position,              \
threadsPerThreadgroup) \

generateKernels(textureMean)

#undef outerArguments
#undef innerArguments
