#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

template <typename T>
void euclideanDistance(texture2d<T, access::sample> textureOne,
                       texture2d<T, access::sample> textureTwo,
                       constant ushort2& inputBlockSize,
                       device float& result,
                       threadgroup float* sharedMemory,
                       const ushort index,
                       const ushort2 position,
                       const ushort2 threadsPerThreadgroup) {
    const auto textureSize = ushort2(textureOne.get_width(),
                                     textureOne.get_height());

    const auto blockStartPosition = position * inputBlockSize;

    auto blockSize = inputBlockSize;
    if (position.x == threadsPerThreadgroup.x || position.y == threadsPerThreadgroup.y) {
        const auto readTerritory = blockStartPosition + inputBlockSize;
        blockSize = inputBlockSize - (readTerritory - textureSize);
    }

    float euclideanDistanceSumInBlock = 0.0f;

    for (ushort x = 0; x < blockSize.x; x++) {
        for (ushort y = 0; y < blockSize.y; y++) {
            const auto readPosition = blockStartPosition + ushort2(x, y);
            const auto textureOneValue = float4(textureOne.read(readPosition));
            const auto textureTwoValue = float4(textureTwo.read(readPosition));
            euclideanDistanceSumInBlock += sqrt(dot(pow(textureOneValue - textureTwoValue, 2), 1));
        }
    }

    sharedMemory[index] = euclideanDistanceSumInBlock;

    threadgroup_barrier(mem_flags::mem_threadgroup);

    if (index == 0) {
        auto totalEuclideanDistanceSum = sharedMemory[0];
        const auto threadsInThreadgroup = threadsPerThreadgroup.x * threadsPerThreadgroup.y;
        for (ushort i = 1; i < threadsInThreadgroup; i++) {
            totalEuclideanDistanceSum += sharedMemory[i];
        }

        result = totalEuclideanDistanceSum;
    }

}

#define outerArguments(T)                                          \
(texture2d<T, access::sample> textureOne [[ texture(0) ]],         \
texture2d<T, access::sample> textureTwo [[ texture(1) ]],          \
constant ushort2& inputBlockSize [[ buffer(0) ]],                  \
device float& result [[ buffer(1) ]],                              \
threadgroup float* sharedMemory [[ threadgroup(0) ]],              \
const ushort index [[ thread_index_in_threadgroup ]],              \
const ushort2 position [[ thread_position_in_grid ]],              \
const ushort2 threadsPerThreadgroup [[ threads_per_threadgroup ]])

#define innerArguments \
(textureOne,           \
textureTwo,            \
inputBlockSize,        \
result,                \
sharedMemory,          \
index,                 \
position,              \
threadsPerThreadgroup)

generateKernels(euclideanDistance)

#undef outerArguments
#undef innerArguments
#undef euclidean
