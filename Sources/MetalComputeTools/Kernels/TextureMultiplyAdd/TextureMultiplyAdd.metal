#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void textureMultiplyAdd(texture2d<float, access::read> sourceOne [[ texture(0) ]],
                               texture2d<float, access::read> sourceTwo [[ texture(1) ]],
                               texture2d<float, access::write> destination [[ texture(2) ]],
                               const ushort2 position [[ thread_position_in_grid ]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    const auto sourceOneValue = sourceOne.read(position);
    const auto sourceTwoValue = sourceTwo.read(position);
    const auto destinationValue = fma(sourceTwoValue,
                                      multiplierFC,
                                      sourceOneValue);
    destination.write(destinationValue,
                      position);
}
