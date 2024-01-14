#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void textureDifferenceHighlight(texture2d<float, access::read> sourceOne [[texture(0)]],
                                       texture2d<float, access::read> sourceTwo [[texture(1)]],
                                       texture2d<float, access::write> destination [[texture(2)]],
                                       constant float4& color [[ buffer(0) ]],
                                       constant float& threshold [[ buffer(1) ]],
                                       ushort2 position [[ thread_position_in_grid ]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    const auto originalColor = sourceOne.read(position);
    const auto targetColor = sourceTwo.read(position);
    const auto difference = abs(targetColor - originalColor);
    const auto totalDifference = dot(difference, 1.f);
    const auto resultValue = mix(targetColor,
                                 color,
                                 step(threshold, totalDifference));
    destination.write(resultValue, position);
}
