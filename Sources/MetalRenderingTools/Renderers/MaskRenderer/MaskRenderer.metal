#include "../../../MetalRenderingToolsSharedTypes/MetalRenderingToolsSharedTypes.h"
#include "../Common/Common.metal"

struct MaskVertexOut {
    float4 position [[ position ]];
    float2 uv;
};

vertex MaskVertexOut maskVertex(constant Rectangle& rectangle [[ buffer(0) ]],
                                uint vid [[vertex_id]]) {
    struct Vertex {
        float2 position;
        float2 uv;
    };

    const Vertex vertices[] = {
        Vertex { rectangle.topLeft, float2(0.0, 1.0) },
        Vertex { rectangle.bottomLeft, float2(0.0, 0.0) },
        Vertex { rectangle.topRight, float2(1.0, 1.0) },
        Vertex { rectangle.bottomRight, float2(1.0, 0.0) }
    };

    MaskVertexOut out;
    float2 position = convertToScreenSpace(vertices[vid].position);
    out.position = float4(position, 0.0, 1.0);
    out.uv = vertices[vid].uv;

    return out;
}

fragment float4 maskFragment(MaskVertexOut in [[ stage_in ]],
                              texture2d<half, access::sample> maskTexture [[ texture(0) ]],
                              constant float4& color [[ buffer(0) ]]) {
    constexpr sampler s(coord::normalized,
                        address::clamp_to_zero,
                        filter::linear);
    float4 maskValue = (float4)maskTexture.sample(s, in.uv).rrrr;
    float4 resultColor = maskValue * color;

    return resultColor;
}
