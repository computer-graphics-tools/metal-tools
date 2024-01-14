#ifndef Common_metal
#define Common_metal

#include "../../../MetalRenderingToolsSharedTypes/MetalRenderingToolsSharedTypes.h"

template <typename T>
enable_if_t<is_floating_point_v<T>, vec<T, 2>>
METAL_FUNC perpendicular(vec<T, 2> vector) {
    return {
        -vector.y,
        vector.x
    };
}

template <typename T>
enable_if_t<is_floating_point_v<T>, vec<T, 2>>
METAL_FUNC convertToScreenSpace(vec<T, 2> vector) {
    return {
        -T(1) + (vector.x * T(2)),
        -T(1) + ((T(1) - vector.y) * T(2))
    };
}

#endif // Common_metal
