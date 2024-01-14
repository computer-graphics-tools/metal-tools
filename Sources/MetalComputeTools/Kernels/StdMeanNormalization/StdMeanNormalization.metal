#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void normalization(texture2d<half, access::read> inputTexture [[ texture(0) ]],
                          texture2d<half, access::write> outputTexture [[ texture(1) ]],
                          constant float3& mean [[ buffer(0) ]],
                          constant float3& std [[ buffer(1) ]],
                          uint2 position [[thread_position_in_grid]]) {
    const auto textureSize = ushort2(inputTexture.get_width(),
                                     inputTexture.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    // Read mpsnngraph result value.
    const auto originalValue = inputTexture.read(position);
    const auto meanValue = (half3)mean;
    const auto stdValue = (half3)std;
    auto normalizedValue = originalValue;
    normalizedValue.rgb -= meanValue;
    normalizedValue.rgb /= stdValue;
    outputTexture.write(normalizedValue, position);
}
