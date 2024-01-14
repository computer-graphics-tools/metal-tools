#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

#define SORT(F,L,R) {           \
    const auto v = sort(F,L,R); \
    (L) = v.x;                  \
    (R) = v.y;                  \
}                               \

METAL_FUNC static constexpr int genLeftIndex(const uint position,
                                             const uint blockSize) {
    const uint32_t blockMask = blockSize - 1;
    const auto no = position & blockMask; // comparator No. in block
    return ((position & ~blockMask) << 1) | no;
}

template <typename T>
METAL_FUNC static vec<T, 2> sort(const bool reverse,
                                 T left,
                                 T right) {
    const bool lt = left < right;
    const bool swap = !lt ^ reverse;
    const bool2 dir = bool2(swap, !swap); // (lt, gte) or (gte, lt)
    const vec<T, 2> v = select(vec<T, 2>(left),
                               vec<T, 2>(right),
                               dir);
    return v;
}

template <typename T>
METAL_FUNC static void loadShared(const uint threadGroupSize,
                                  const uint indexInThreadgroup,
                                  const uint position,
                                  device T* data,
                                  threadgroup T* shared) {
    const auto index = genLeftIndex(position, threadGroupSize);
    shared[indexInThreadgroup] = data[index];
    shared[indexInThreadgroup | threadGroupSize] = data[index | threadGroupSize];
}

template <typename T>
METAL_FUNC static void storeShared(const uint threadGroupSize,
                               const uint indexInThreadgroup,
                               const uint position,
                               device T* data,
                               threadgroup T* shared) {
    const auto index = genLeftIndex(position, threadGroupSize);
    data[index] = shared[indexInThreadgroup];
    data[index | threadGroupSize] = shared[indexInThreadgroup | threadGroupSize];
}

template <typename T>
void bitonicSortFirstPass(device T* data,
                          constant uint& gridSize,
                          threadgroup T* shared, // element num must be 2x (threads per threadgroup)
                          const uint threadgroupSize,
                          const uint indexInThreadgroup,
                          const uint position) {
    if (!deviceSupportsNonuniformThreadgroups && position >= gridSize) { return; }
    loadShared(threadgroupSize, indexInThreadgroup, position, data, shared);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    for (uint unitSize = 1; unitSize <= threadgroupSize; unitSize <<= 1) {
        const bool reverse = (position & (unitSize)) != 0;    // to toggle direction
        for (uint blockSize = unitSize; 0 < blockSize; blockSize >>= 1) {
            const auto left = genLeftIndex(indexInThreadgroup, blockSize);
            SORT(reverse, shared[left], shared[left | blockSize]);
            threadgroup_barrier(mem_flags::mem_threadgroup);
        }
    }
    storeShared(threadgroupSize, indexInThreadgroup, position, data, shared);
}

#define outerArguments(T)                                         \
(device T* data [[ buffer(0) ]],                                  \
 constant uint& gridSize [[ buffer(1) ]],                         \
 threadgroup T* shared [[ threadgroup(0) ]],                      \
 const uint threadgroupSize [[ threads_per_threadgroup ]],        \
 const uint indexInThreadgroup [[ thread_index_in_threadgroup ]], \
 const uint position [[ thread_position_in_grid ]])

#define innerArguments \
(data,                 \
 gridSize,             \
 shared,               \
 threadgroupSize,      \
 indexInThreadgroup,   \
 position)

generateKernels(bitonicSortFirstPass)

#undef outerArguments
#undef innerArguments

template <typename T>
void bitonicSortGeneralPass(device T* data,         // should be multiple of params.x
                            constant uint& gridSize,
                            constant uint2& params, // x: monotonic width, y: comparative width
                            const uint position) {  // total threads should be half of data length
    if (!deviceSupportsNonuniformThreadgroups && position >= gridSize) { return; }
    const bool reverse = (position & (params.x >> 1)) != 0; // to toggle direction
    const uint blockSize = params.y; // size of comparison sets
    const auto left = genLeftIndex(position, blockSize);
    SORT(reverse, data[left], data[left | blockSize]);
}

#define outerArguments(T)                           \
(device T* data [[ buffer(0) ]],                    \
 constant uint& gridSize  [[ buffer(1) ]],          \
 constant uint2& params [[ buffer(2) ]],            \
 const uint position [[ thread_position_in_grid ]])

#define innerArguments \
(data,                 \
 gridSize,             \
 params,               \
 position)

generateKernels(bitonicSortGeneralPass)

#undef outerArguments
#undef innerArguments

template <typename T>
void bitonicSortFinalPass(device T* data,
                          constant uint& gridSize,
                          constant uint2& params,
                          threadgroup T* shared, // element num must be 2x (threads per threadgroup)
                          const uint threadgroupSize,
                          const uint indexInThreadgroup,
                          const uint position) {
    if (!deviceSupportsNonuniformThreadgroups && position >= gridSize) { return; }
    loadShared(threadgroupSize, indexInThreadgroup, position, data, shared);
    const auto unitSize = params.x;
    const auto blockSize = params.y;
    const auto num = 10 + 1;
    // Toggle direction.
    const bool reverse = (position & (unitSize >> 1)) != 0;
    for (uint i = 0; i < num; ++i) {
        const auto width = blockSize >> i;
        const auto left = genLeftIndex(indexInThreadgroup, width);
        SORT(reverse, shared[left], shared[left | width]);
        threadgroup_barrier(mem_flags::mem_threadgroup);
    }
    storeShared(threadgroupSize, indexInThreadgroup, position, data, shared);
}

#define outerArguments(T)                                         \
(device T* data [[ buffer(0) ]],                                  \
 constant uint& gridSize [[ buffer(1) ]],                         \
 constant uint2& params [[ buffer(2) ]],                          \
 threadgroup T* shared [[ threadgroup(0) ]],                      \
 const uint threadgroupSize [[ threads_per_threadgroup ]],        \
 const uint indexInThreadgroup [[ thread_index_in_threadgroup ]], \
 const uint position [[ thread_position_in_grid ]])

#define innerArguments \
(data,                 \
 gridSize,             \
 params,               \
 shared,               \
 threadgroupSize,      \
 indexInThreadgroup,   \
 position)

generateKernels(bitonicSortFinalPass)

#undef outerArguments
#undef innerArguments
#undef SORT
