#include "../../../Sources/MetalComputeToolsSharedTypes/Definitions.h"

constant bool conversionTypeDenormalize [[ function_constant(3) ]];

kernel void switchDataFormat(texture2d<float, access::read_write> normalizedTexture [[ texture(0) ]],
                             texture2d<uint, access::read_write> unnormalizedTexture [[ texture(1) ]],
                             const ushort2 position [[thread_position_in_grid]]) {
    const ushort2 textureSize = ushort2(normalizedTexture.get_width(),
                                        normalizedTexture.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    if (conversionTypeDenormalize) {
        float4 floatValue = normalizedTexture.read(position);
        uint4 uintValue = uint4(floatValue * 255);
        unnormalizedTexture.write(uintValue, position);
    } else {
        uint4 uintValue = unnormalizedTexture.read(position);
        float4 floatValue = float4(uintValue) / 255;
        normalizedTexture.write(floatValue, position);
    }
}
