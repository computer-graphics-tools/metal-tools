#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void textureWeightedMix(texture2d<float, access::read> sourceOne [[ texture(0) ]],
                               texture2d<float, access::read> sourceTwo [[ texture(1) ]],
                               texture2d<float, access::write> destination [[ texture(2) ]],
                               constant float& weight [[ buffer(0) ]],
                               const ushort2 position [[ thread_position_in_grid ]]) {
    const ushort2 textureSize = ushort2(destination.get_width(),
                                        destination.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    const auto sourceOneValue = sourceOne.read(position);
    const auto sourceTwoValue = sourceTwo.read(position);
    const auto resultValue = mix(sourceOneValue,
                                 sourceTwoValue,
                                 weight);

    destination.write(resultValue, position);
}
