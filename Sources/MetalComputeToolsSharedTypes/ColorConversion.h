#ifndef ColorConversion_h
#define ColorConversion_h

#if __METAL_MACOS__ || __METAL_IOS__

#include <metal_stdlib>

using namespace metal;

namespace colors {

    template <typename T>
    enable_if_t<is_floating_point_v<T>, T>
    METAL_FUNC hue2rgb(T p, T q, T t){
        if(t < T(0.0)) {
            t += T(1.0);
        }
        if(t > T(1.0)) {
            t -= T(1.0);
        }
        if(t < T(1.0)/T(6.0)) {
            return p + (q - p) * T(6.0) * t;
        }
        if(t < T(1.0)/T(2.0)) {
            return q;
        }
        if(t < T(2.0)/T(3.0)) {
            return p + (q - p) * (T(2.0)/T(3.0) - t) * T(6.0);
        }
        return p;
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC rgb2hsl(vec<T, 3> inputColor) {
        vec<T, 3> color = saturate(inputColor);

        //Compute min and max component values
        auto MAX = max(color.r, max(color.g, color.b));
        const auto MIN = min(color.r, min(color.g, color.b));

        //Make sure MAX > MIN to avoid division by zero later
        MAX = max(MIN + T(1e-6), MAX);

        //Compute luminosity
        const auto l = (MIN + MAX) / T(2.0);

        //Compute saturation
        const auto s = (l < T(0.5)
                     ? (MAX - MIN) / (MIN + MAX)
                     : (MAX - MIN) / (T(2.0) - MAX - MIN));

        //Compute hue
        auto h = (MAX == color.r ? (color.g - color.b) / (MAX - MIN) : (MAX == color.g ? 2.0 + (color.b - color.r) / (MAX - MIN) : 4.0 + (color.r - color.g) / (MAX - MIN)));
        h /= T(6.0);
        h = (h < T(0.0) ? T(1.0) + h : h);

        return vec<T, 3>(h, s, l);
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC hsl2rgb(vec<T, 3> inputColor) {
        vec<T, 3> color = saturate(inputColor);

        const auto h = color.r;
        const auto s = color.g;
        const auto l = color.b;

        T r,g,b;
        if (s <= T(0.0)) {
            r = g = b = l;
        } else {
            const auto q = l < T(0.5) ? (l * (T(1.0) + s)) : (l + s - l * s);
            const auto p = T(2.0) * l - q;
            r = hue2rgb(p, q, h + T(1.0)/T(3.0));
            g = hue2rgb(p, q, h);
            b = hue2rgb(p, q, h - T(1.0)/T(3.0));
        }
        return vec<T, 3>(r,g,b);
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC rgb2hsv(vec<T, 3> c) {
        const auto K = vec<T, 4>(0.0f, -1.0f / 3.0f, 2.0f / 3.0f, -1.0f);
        const auto p = mix(vec<T, 4>(c.bg, K.wz),
                           vec<T, 4>(c.gb, K.xy),
                           step(c.b, c.g));
        const auto q = mix(vec<T, 4>(p.xyw, c.r),
                           vec<T, 4>(c.r, p.yzx),
                           step(p.x, c.r));
        const auto d = q.x - min(q.w, q.y);
        const auto e = T(1.0e-10f);
        return vec<T, 3>(abs(q.z + (q.w - q.y) / (6.0f * d + e)), d / (q.x + e), q.x);
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC hsv2rgb(vec<T, 3> c) {
        const auto K = vec<T, 4>(T(1.0f), T(2.0f) / T(3.0f), T(1.0f) / T(3.0f), T(3.0f));
        const auto p = abs(fract(c.xxx + K.xyz) * T(6.0f) - K.www);
        return c.z * mix(K.xxx, clamp(p - K.xxx, T(0.0f), T(1.0f)), c.y);
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC rgb2xyz(vec<T, 3> c) {
        float3 tmp;
        tmp.x = ( float(c.r) > 0.04045 ) ? pow( ( float(c.r) + 0.055 ) / 1.055, 2.4 ) : float(c.r) / 12.92;
        tmp.y = ( float(c.g) > 0.04045 ) ? pow( ( float(c.g) + 0.055 ) / 1.055, 2.4 ) : float(c.g) / 12.92,
        tmp.z = ( float(c.b) > 0.04045 ) ? pow( ( float(c.b) + 0.055 ) / 1.055, 2.4 ) : float(c.b) / 12.92;
        const float3x3 mat = float3x3(
                                      float3( 0.4124, 0.3576, 0.1805 ),
                                      float3( 0.2126, 0.7152, 0.0722 ),
                                      float3( 0.0193, 0.1192, 0.9505 )
                                      );
        return vec<T, 3>(100.0f * (tmp * mat));
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC xyz2lab(vec<T, 3> c) {
        float3 n = float3(c) / float3(95.047, 100, 108.883);
        float3 v;
        v.x = ( n.x > 0.008856f ) ? pow( n.x, 1.0f / 3.0f ) : ( 7.787f * n.x ) + ( 16.0f / 116.0f );
        v.y = ( n.y > 0.008856f ) ? pow( n.y, 1.0f / 3.0f ) : ( 7.787f * n.y ) + ( 16.0f / 116.0f );
        v.z = ( n.z > 0.008856f ) ? pow( n.z, 1.0f / 3.0f ) : ( 7.787f * n.z ) + ( 16.0f / 116.0f );
        return vec<T, 3>(( 116.0f * v.y ) - 16.0f, 500.0f * ( v.x - v.y ), 200.0f * ( v.y - v.z ));
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC rgb2lab( vec<T, 3> c ) {
        const float3 lab = xyz2lab( rgb2xyz( float3(c) ) );
        return vec<T, 3>( lab.x / 100.0f, 0.5f + 0.5f * ( lab.y / 127.0f ), 0.5f + 0.5f * ( lab.z / 127.0f ));
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC lab2xyz(vec<T, 3> c) {
        const auto fy = ( float(c.x) + 16.0f ) / 116.0f;
        const auto fx = float(c.y) / 500.0f + fy;
        const auto fz = fy - float(c.z) / 200.0f;
        return vec<T, 3>(95.047f * (( fx > 0.206897f ) ? fx * fx * fx : ( fx - 16.0f / 116.0f ) / 7.787f),
                         100.000f * (( fy > 0.206897f ) ? fy * fy * fy : ( fy - 16.0f / 116.0f ) / 7.787f),
                         108.883f * (( fz > 0.206897f ) ? fz * fz * fz : ( fz - 16.0f / 116.0f ) / 7.787f));
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC xyz2rgb(vec<T, 3> c) {
        const float3x3 mat = float3x3(
                                      float3( 3.2406f, -1.5372f, -0.4986f ),
                                      float3( -0.9689f, 1.8758f, 0.0415f ),
                                      float3( 0.0557f, -0.2040f, 1.0570f )
                                      );
        const auto v = (float3(c) / 100.0f) * mat;
        float3 r;
        r.x = ( v.r > 0.0031308f ) ? (( 1.055f * pow( v.r, ( 1.0f / 2.4f ))) - 0.055f ) : 12.92f * v.r;
        r.y = ( v.g > 0.0031308f ) ? (( 1.055f * pow( v.g, ( 1.0f / 2.4f ))) - 0.055f ) : 12.92f * v.g;
        r.z = ( v.b > 0.0031308f ) ? (( 1.055f * pow( v.b, ( 1.0f / 2.4f ))) - 0.055f ) : 12.92f * v.b;
        return vec<T, 3>(r);
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC lab2rgb( vec<T, 3> c ) {
        return vec<T, 3>(xyz2rgb( lab2xyz( float3(100.0f * float(c.x), 2.0f * 127.0f * (float(c.y) - 0.5f), 2.0f * 127.0f * (float(c.z) - 0.5f)) ) ));
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC denormalizeLab(vec<T, 3> labColor) {
        vec<T, 3> result = labColor;
        result.g = (result.g - T(0.5)) * T(255);
        result.b = (result.b - T(0.5)) * T(255);
        return result;
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC normalizeLab(vec<T, 3> labColor) {
        vec<T, 3> result = labColor;
        result.g = result.g / T(255) + T(0.5);
        result.b = result.b / T(255) + T(0.5);
        return result;
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC clipLab(vec<T, 3> color) {
        return vec<T, 3>(clamp(color.r, T(0), T(1)),
                         clamp(color.g, T(-127), T(127)),
                         clamp(color.b, T(-127), T(127)));
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC contrastLabColor(vec<T, 3> labColor, T value) {
        value *= (value > T(0)) ? T(1.0) : T(0.6);

        const auto newLuminance = ((tanh(labColor.r * T(M_PI_F) * T(2) - T(M_PI_F)) + T(1)) / T(2) + labColor.r)
                                / T(2);
        const auto luminanceDifference = newLuminance - labColor.r;

        labColor.r += luminanceDifference * value;

        const auto colorMultiplierPower = (value > T(0))
                                        ? T(2) * (T(0.25) - pow(labColor.r - T(0.5), T(2)))
                                        : T(0.35);
        const auto colorMultiplier = T(1) + value * colorMultiplierPower;

        labColor.g *= colorMultiplier;
        labColor.b *= colorMultiplier;

        labColor = clipLab(labColor);

        return labColor;
    }

    template <typename T>
    enable_if_t<is_floating_point_v<T>, vec<T, 3>>
    METAL_FUNC exposeLabColor(vec<T, 3> labColor, T value){
        const auto newLuminance = (value > T(0))
                                ? T(1) - pow(T(1) - labColor.r, T(2.8))
                                : pow(labColor.r, T(1.5)) * T(0.7);

        labColor.r += (newLuminance - labColor.r) * abs(value);

        const auto rate = (value > T(0)) ? (pow(labColor.r, T(3.0)) - T(0.5)) * T(2)
                                         : (labColor.r - T(0.8)) * T(0.1);
        const auto colorMultiplier = max(T(0.0), T(1) - rate * value);

        labColor.g *= colorMultiplier;
        labColor.b *= colorMultiplier;

        return clipLab(labColor);
    }

}

#endif /* __METAL_MACOS__ || __METAL_IOS__ */

#endif /* ColorConversion_h */
