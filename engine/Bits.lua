-- Bits module
local Bits = {}

-- Converts number to array of bits
function Bits.fromNumber(number, size)
    local bits = { 0 }
    local position = 1
    for i = 1, size do
        bits[i] = (math.floor(number) % 2) == 1
        number = number / 2
    end
    return bits
end

-- Converts array of bits to number
function Bits.toNumber(bits)
    local number = 0
    local weight = 1
    for i = 1, #bits do
        if bits[i] then
            number = number + weight
        end
        weight = 2 * weight
    end
    return number
end

return Bits
