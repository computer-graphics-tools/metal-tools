#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

constant float4x4 ycbcrToRGBTransform = {
    { +1.0000f, +1.0000f, +1.0000f, +0.0000f },
    { +0.0000f, -0.3441f, +1.7720f, +0.0000f },
    { +1.4020f, -0.7141f, +0.0000f, +0.0000f },
    { -0.7010f, +0.5291f, -0.8860f, +1.0000f }
};

kernel void ycbcrToRGBA(texture2d<float, access::sample> sourceY [[ texture(0) ]],
                        texture2d<float, access::sample> sourceCbCr [[ texture(1) ]],
                        texture2d<float, access::write> destinationRGBA [[ texture(2) ]],
                        const ushort2 position [[ thread_position_in_grid ]],
                        const ushort2 totalThreads [[ threads_per_grid ]]) {
    const auto textureSize = ushort2(destinationRGBA.get_width(),
                                     destinationRGBA.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    constexpr sampler s(coord::normalized,
                        address::clamp_to_edge,
                        filter::linear);
    const auto positionF = float2(position);
    const auto textureSizeF = float2(textureSize);
    const auto normalizedPosition = (positionF + 0.5f) / textureSizeF;

    const auto ycbcr = float4(sourceY.sample(s, normalizedPosition).r,
                              sourceCbCr.sample(s, normalizedPosition).rg,
                              1.0f);
    const auto destinationValue = ycbcrToRGBTransform * ycbcr;

    destinationRGBA.write(destinationValue, position);
}
