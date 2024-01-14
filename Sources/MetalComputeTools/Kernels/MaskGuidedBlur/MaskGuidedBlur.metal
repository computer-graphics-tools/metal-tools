#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void maskGuidedBlurRowPass(texture2d<float, access::read> source [[ texture(0) ]],
                                  texture2d<float, access::sample> mask [[ texture(1) ]],
                                  texture2d<float, access::write> destination [[ texture(2) ]],
                                  constant float& sigma [[ buffer(0) ]],
                                  ushort2 position [[ thread_position_in_grid ]]) {
    const auto textureSize = ushort2(source.get_width(),
                                     source.get_height());

    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    constexpr sampler s(coord::normalized,
                        address::clamp_to_edge,
                        filter::linear);

    const auto positionF = float2(position);
    const auto textureSizeF = float2(textureSize);
    const auto normalizedPosition = (positionF + 0.5f) / textureSizeF;

    const auto maskValue = mask.sample(s, normalizedPosition).r;

    const auto sigmaValue = (1.0f - maskValue) * sigma;
    const auto kernelRadius = int(2.0f * sigmaValue);

    auto normalizingConstant = 0.0f;
    auto result = float3(0.0f);

    for (int row = -kernelRadius; row <= kernelRadius; row++) {
        const auto kernelValue = exp(float(-row * row) / (2.0f * sigmaValue * sigmaValue + 1e-5f));
        const auto readPosition = uint2(clamp(position.x + row, 0, position.y - 1), position.y);
        const auto readPositionF = float2(readPosition);
        const auto normalizedPosition = (readPositionF.x + 0.5f) / textureSizeF;
        const auto maskMultiplier = 1.0f - mask.sample(s, normalizedPosition).r + 1e-5f;
        const auto totalFactor = kernelValue * maskMultiplier;
        normalizingConstant += float(totalFactor);
        result += source.read(readPosition).rgb * totalFactor;
    }

    result /= normalizingConstant;

    destination.write(float4(result, 1.0f), position);
}

kernel void maskGuidedBlurColumnPass(texture2d<float, access::read> source [[ texture(0) ]],
                                     texture2d<float, access::sample> mask [[ texture(1) ]],
                                     texture2d<float, access::write> destination [[ texture(2) ]],
                                     constant float& sigma [[ buffer(0) ]],
                                     uint2 position [[ thread_position_in_grid ]]) {
    const auto textureSize = ushort2(source.get_width(),
                                     source.get_height());

    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    constexpr sampler s(coord::normalized,
                        address::clamp_to_edge,
                        filter::linear);

    const auto textureSizeF = float2(textureSize);
    const auto positionF = float2(position);
    const auto normalizedPosition = (positionF.x + 0.5f) / textureSizeF;

    const auto maskValue = mask.sample(s, normalizedPosition).r;

    const auto sigmaValue = (1.0f - maskValue) * sigma;
    const auto kernelRadius = uint(2.0f * sigmaValue);

    auto normalizingConstant = 0.0f;
    auto result = float3(0.0f);

    for (uint column = -kernelRadius; column <= kernelRadius; column++) {
        const auto kernelValue = exp(float(-column * column) / (2.0f * sigmaValue * sigmaValue + 1e-5f));
        const auto readPosition = uint2(position.x, clamp(position.y + column, 0u, position.y - 1));
        const auto readPositionF = float2(readPosition);
        const auto normalizedPosition = (readPositionF.x + 0.5f) / textureSizeF;
        const auto maskMultiplier = 1.0f - mask.sample(s, normalizedPosition).r + 1e-5f;
        const auto totalFactor = kernelValue * maskMultiplier;
        normalizingConstant += float(totalFactor);
        result += source.read(readPosition).rgb * totalFactor;
    }

    result /= normalizingConstant;

    destination.write(float4(result, 1.0f), position);
}
