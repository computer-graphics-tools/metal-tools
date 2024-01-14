#include "../../../MetalRenderingToolsSharedTypes/MetalRenderingToolsSharedTypes.h"
#include "../Common/Common.metal"

struct PointVertexOut {
    float4 position [[ position ]];
    float size [[ point_size ]];
};

vertex PointVertexOut pointVertex(constant float2* pointsPositions [[ buffer(0) ]],
                                  constant float& pointSize [[ buffer(1) ]],
                                  uint instanceId [[instance_id]]) {
    const float2 pointPosition = pointsPositions[instanceId];

    PointVertexOut out;
    float2 position = convertToScreenSpace(pointPosition);
    out.position = float4(position, 0, 1);
    out.size = pointSize;

    return out;
}

fragment float4 pointFragment(PointVertexOut in [[stage_in]],
                              const float2 pointCenter [[ point_coord ]],
                              constant float4& pointColor [[ buffer(0) ]]) {
    const float distanceFromCenter = length(2 * (pointCenter - 0.5));
    float4 color = pointColor;
    color.a = 1.0 - smoothstep(0.9, 1.0, distanceFromCenter);

    return color;
}
