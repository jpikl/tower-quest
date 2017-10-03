-- Dependencies
local Ground = require("game.objects.Ground")

-- Wall class
local Wall = Ground:derive("Wall")

-- Returns number of a sprite which is drawn as background
function Wall.getBackgroundSprite(classes)
    local tl = classes.tl:is("Wall")
    local tc = classes.tc:is("Wall")
    local tr = classes.tr:is("Wall")
    local cl = classes.cl:is("Wall")
    local cc = classes.cc:is("Wall")
    local cr = classes.cr:is("Wall")
    local bl = classes.bl:is("Wall")
    local bc = classes.bc:is("Wall")
    local br = classes.br:is("Wall")

    if tl and tc and tr and cl and cr and bl and bc and br then
        return nil
    elseif not tl and tc and not tr and cl and cr and bl and bc and br then
        return Wall.sprites[15]
    elseif tl and tc and not tr and cl and cr and bl and bc and br then
        return Wall.sprites[14]
    elseif not tl and tc and tr and cl and cr and bl and bc and br then
        return Wall.sprites[16]
    elseif not tl and tc and cl and bc and bl then
        return Wall.sprites[6]
    elseif tc and not tr and cr and bc and br then
        return Wall.sprites[8]
    elseif tl and tc and cl and bl and bc then
        return Wall.sprites[10]
    elseif tc and tr and cr and bc and br then
        return Wall.sprites[12]
    elseif tc and bc then
        return Wall.sprites[7]
    elseif not tc and cl and not (cr and br) and bl and bc then
        return Wall.sprites[2]
    elseif not tc and not (cl and bl) and cr and bc and br then
        return Wall.sprites[4]
    elseif not tc and not (cl and bl) and not (cr and br) and bc then
        return Wall.sprites[3]
    elseif bc then
        return Wall.sprites[11]
    else
        return Wall.sprites[1]
    end
end

return Wall
