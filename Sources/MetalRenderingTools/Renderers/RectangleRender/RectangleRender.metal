#include "../../../MetalRenderingToolsSharedTypes/MetalRenderingToolsSharedTypes.h"
#include "../Common/Common.metal"

struct RectVertexOut {
    float4 position [[ position ]];
};

vertex RectVertexOut rectVertex(constant Rectangle& rectangle [[ buffer(0) ]],
                                uint vid [[vertex_id]]) {
    const float2 positions[] = {
        rectangle.topLeft, rectangle.bottomLeft,
        rectangle.topRight, rectangle.bottomRight
    };
    
    RectVertexOut out;
    float2 position = convertToScreenSpace(positions[vid]);
    out.position = float4(position, 0.0, 1.0);
    
    return out;
}

fragment float4 rectFragment(RectVertexOut in [[ stage_in ]],
                             constant float4& color [[ buffer(0) ]]) {
    return color;
}
