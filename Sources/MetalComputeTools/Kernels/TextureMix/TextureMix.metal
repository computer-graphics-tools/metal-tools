#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void textureMix(texture2d<float, access::read> sourceOne [[ texture(0) ]],
                       texture2d<float, access::sample> sourceTwo [[ texture(1) ]],
                       texture2d<float, access::write> destination [[ texture(2) ]],
                       constant float3x3& transform [[ buffer(0) ]],
                       constant float& opacity [[ buffer(1) ]],
                       const uint2 position [[ thread_position_in_grid ]]) {
    const uint2 destinationTextureSize = {
        destination.get_width(),
        destination.get_height()
    };
    
    checkPosition(position, destinationTextureSize, deviceSupportsNonuniformThreadgroups);
    
    const uint2 sourceTwoTextureSize = {
        sourceTwo.get_width(),
        sourceTwo.get_height()
    };

    constexpr sampler s(coord::normalized,
                        address::clamp_to_zero,
                        filter::linear);

    const float2 sourceTwoPosition = (transform * float3(float2(position), 1.0f)).xy;
    const float2 sourceTwoNormalizedPosition = sourceTwoPosition / float2(sourceTwoTextureSize);
    const bool sourceTwoPositionIsOutOfBounds = sourceTwoPosition.x < 0
                                             || sourceTwoPosition.x >= sourceTwoTextureSize.x
                                             || sourceTwoPosition.y < 0
                                             || sourceTwoPosition.y >= sourceTwoTextureSize.y;

    const float4 sourceOneValue = sourceOne.read(position);
    const float4 sourceTwoValue = sourceTwoPositionIsOutOfBounds
                                ? sourceOneValue
                                : sourceTwo.sample(s, sourceTwoNormalizedPosition);

    const float4 destinationValue = mix(sourceOneValue,
                                        sourceTwoValue,
                                        opacity);
    
    destination.write(destinationValue, position);
}
