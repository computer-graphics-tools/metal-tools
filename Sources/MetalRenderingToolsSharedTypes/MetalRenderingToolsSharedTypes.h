#ifndef MetalRenderingToolsSharedTypes_h
#define MetalRenderingToolsSharedTypes_h

#if __METAL_MACOS__ || __METAL_IOS__

#include <metal_stdlib>

using namespace metal;

#else

#include <simd/simd.h>

#endif // __METAL_MACOS__ || __METAL_IOS__

typedef struct Rectangle {
    vector_float2 topLeft;
    vector_float2 bottomLeft;
    vector_float2 topRight;
    vector_float2 bottomRight;
} Rectangle;

typedef struct Line {
    vector_float2 startPoint;
    vector_float2 endPoint;
    float width;
} Line;

typedef struct {
    packed_float4 position;
    packed_float2 texCoords;
} TextMeshVertex;

#endif /* MetalRenderingToolsSharedTypes_h */
