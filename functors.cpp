#include <cstdint>
#include <cfloat>
#include <cmath>

extern "C" {

double logn(double x) {
    return log(x);
}

double asDouble(int32_t x) {
    return (double)x;
}

}
