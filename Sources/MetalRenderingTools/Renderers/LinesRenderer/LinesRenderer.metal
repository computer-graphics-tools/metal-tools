#include "../../../MetalRenderingToolsSharedTypes/MetalRenderingToolsSharedTypes.h"
#include "../Common/Common.metal"

struct LinesVertexOut {
    float4 position [[ position ]];
};

vertex LinesVertexOut linesVertex(constant Line *lines [[ buffer(0) ]],
                             uint vertexId [[vertex_id]],
                             uint instanceId [[instance_id]]) {
    Line line = lines[instanceId];

    float2 startPoint = line.startPoint;
    float2 endPoint = line.endPoint;

    float2 vector = startPoint - endPoint;
    float2 perpendicularVector = perpendicular(normalize(vector));
    float halfWidth = line.width / 2;

    struct PositionAndOffsetFactor {
        float2 vertexPosition;
        float offsetFactor;
    };

    const PositionAndOffsetFactor positionsAndOffsetFactors[] = {
        { startPoint, -1.0 },
        { endPoint, -1.0 },
        { startPoint, 1.0 },
        { endPoint, 1.0 }
    };

    LinesVertexOut out;
    const float2 vertexPosition = positionsAndOffsetFactors[vertexId].vertexPosition;
    const float offsetFactor = positionsAndOffsetFactors[vertexId].offsetFactor;
    float2 position = convertToScreenSpace(vertexPosition + offsetFactor * perpendicularVector * halfWidth);
    out.position = float4(position, 0.0, 1.0);

    return out;
}

fragment float4 linesFragment(LinesVertexOut in [[ stage_in ]],
                              constant float4& color [[ buffer(0) ]]) {
    return color;
}
