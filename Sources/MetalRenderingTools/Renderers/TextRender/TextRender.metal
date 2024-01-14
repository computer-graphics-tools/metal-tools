#include "../../../MetalRenderingToolsSharedTypes/MetalRenderingToolsSharedTypes.h"

// MARK: Text Rendering

struct TransformedTextVertex {
    float4 position [[ position ]];
    float2 texCoords;
};

vertex TransformedTextVertex textVertex(constant TextMeshVertex* vertices [[ buffer(0) ]],
                                        constant float4x4& viewProjectionMatrix [[ buffer(1) ]],
                                        uint vertexID [[ vertex_id ]]) {
    TransformedTextVertex outVert;
    outVert.position = viewProjectionMatrix * float4(vertices[vertexID].position);
    outVert.texCoords = vertices[vertexID].texCoords;
    return outVert;
}

fragment half4 textFragment(TransformedTextVertex vert [[ stage_in ]],
                            constant float4& color [[ buffer(0) ]],
                            sampler sampler [[ sampler(0) ]],
                            texture2d<float, access::sample> texture [[ texture(0) ]]) {
    // Outline of glyph is the isocontour with value 50%.
    float edgeDistance = 0.5;
    // Sample the signed-distance field to find distance from this fragment to the glyph outline.
    float sampleDistance = texture.sample(sampler, vert.texCoords).r;
    // Use local automatic gradients to find anti-aliased anisotropic edge width, cf. Gustavson 2012.
    float edgeWidth = 0.75 * length(float2(dfdx(sampleDistance), dfdy(sampleDistance)));
    // Smooth the glyph edge by interpolating across the boundary in a band with the width determined above.
    float insideness = smoothstep(edgeDistance - edgeWidth, edgeDistance + edgeWidth, sampleDistance);
    return half4(color.r, color.g, color.b, insideness);
}
