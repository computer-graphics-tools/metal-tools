#include "../../../MetalRenderingToolsSharedTypes/MetalRenderingToolsSharedTypes.h"

vertex float4 simpleVertex(constant float4* vertices [[ buffer(0) ]],
                           constant float4x4& matrix [[ buffer(1) ]],
                           uint vid [[vertex_id]]) {
    const float4 v = vertices[vid];

    return matrix * v;
}

fragment float4 simpleFragment(constant float4& pointColor [[ buffer(0) ]]) {
    return pointColor;
}
