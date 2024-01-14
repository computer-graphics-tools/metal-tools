#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

constant float4x4 rgbaToYCbCrTransform = {
    { +0.2990f, -0.1687f, +0.5000f, +0.0000f },
    { +0.5870f, -0.3313f, -0.4187f, +0.0000f },
    { +0.1140f, +0.5000f, -0.0813f, +0.0000f },
    { -0.0000f, +0.5000f, +0.5000f, +1.0000f }
};

kernel void rgbaToYCbCr(texture2d<float, access::sample> sourceRGBA [[ texture(0) ]],
                        texture2d<float, access::write> destinationY [[ texture(1) ]],
                        texture2d<float, access::write> destinationCbCr [[ texture(2) ]],
                        const ushort2 position [[ thread_position_in_grid ]]) {
    const auto textureSize = ushort2(destinationCbCr.get_width(),
                                     destinationCbCr.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    if (halfSizedCbCr) {
        constexpr sampler s(coord::pixel,
                            address::clamp_to_edge,
                            filter::nearest);
        const auto positionF = float2(position);
        const auto gatherPosition = positionF * 2.0f + 1.0f;

        const auto rValuesForQuad = sourceRGBA.gather(s, gatherPosition,
                                                      0, component::x);
        const auto gValuesForQuad = sourceRGBA.gather(s, gatherPosition,
                                                      0, component::y);
        const auto bValuesForQuad = sourceRGBA.gather(s, gatherPosition,
                                                      0, component::z);
        const auto rgbaValues = transpose(float4x4(rValuesForQuad,
                                                   gValuesForQuad,
                                                   bValuesForQuad,
                                                   float4(1.0f)));
        const auto ycbcrValues = rgbaToYCbCrTransform * rgbaValues;

        destinationY.write(ycbcrValues[0].r, position * 2 + ushort2(0, 1));
        destinationY.write(ycbcrValues[1].r, position * 2 + ushort2(1, 1));
        destinationY.write(ycbcrValues[2].r, position * 2 + ushort2(1, 0));
        destinationY.write(ycbcrValues[3].r, position * 2 + ushort2(0, 0));

        const auto cbcrValue = (ycbcrValues * float4(0.25f)).gb;
        destinationCbCr.write(float4(cbcrValue, 0.0f), position);
    } else {
        const auto rgbaValue = sourceRGBA.read(position);
        const auto ycbcrValue = rgbaToYCbCrTransform * rgbaValue;
        const auto yValue = ycbcrValue.r;
        const auto cbcrValue = float4(ycbcrValue.gb, 0.0f);
        destinationY.write(yValue, position);
        destinationCbCr.write(cbcrValue, position);
    }
}
