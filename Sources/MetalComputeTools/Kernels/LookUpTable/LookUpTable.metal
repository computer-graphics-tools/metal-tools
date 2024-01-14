#include "../../../MetalComputeToolsSharedTypes/Definitions.h"

kernel void lookUpTable(texture2d<float, access::read> source [[ texture(0) ]],
                        texture2d<float, access::write> destination [[ texture(1) ]],
                        texture3d<float, access::sample> lut [[ texture(2) ]],
                        constant float& intensity [[ buffer(0) ]],
                        uint2 position [[thread_position_in_grid]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    checkPosition(position, textureSize, deviceSupportsNonuniformThreadgroups);

    constexpr sampler s(coord::normalized,
                        address::clamp_to_edge,
                        filter::linear);

    // read original color
    auto sourceValue = source.read(position);

    // use it to sample target color
    sourceValue.rgb = mix(sourceValue.rgb,
                          lut.sample(s, sourceValue.rgb).rgb,
                          intensity);

    // write it to destination texture
    destination.write(sourceValue, position);
}
