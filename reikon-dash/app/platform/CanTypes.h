#pragma once

#include <cstdint>
#include <array>

struct CanFrame
{
    uint32_t id;
    uint8_t dlc;
    std::array<uint8_t, 8> data;
    uint64_t timestamp;
};
