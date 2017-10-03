-- Dependencies
local Assets = require("engine.Assets")
local Table  = require("engine.Table")

-- Mapping module
local Mapping = {}

-- Variables
local descriptors = {}                              -- List of descriptors
local mapping = {}                                  -- Mapping of characters to descriptors
local noneCharacter = " "                           -- Character for empty floor
local wallCharacter = "#"                           -- Character for a wall
local backgroundSprites = Assets.sprites.background -- Background sprites
local objectsSprites = Assets.sprites.objects       -- Objects sprites
local enemiesSprites = Assets.sprites.enemies       -- Enemies sprites
local playerSprites = Assets.sprites.player         -- Player sprites

-- Adds descriptor of a new object
local function addMapping(descriptor)
    table.insert(descriptors, descriptor)
    mapping[descriptor.character] = descriptor
end

-- Returns object class
function Mapping.getClass(character)
    local descriptor = mapping[character]
    if descriptor then
        local className = descriptor.class
        local parameters = descriptor.parameters
        return require("game.objects." .. className), parameters
    end
end

-- Creates object instance
function Mapping.createObject(character, x, y)
    if character ~= noneCharacter and character ~= wallCharacter then
        local class, parameters = Mapping.getClass(character)
        return class and class(x, y, unpack(parameters or {}))
    end
end

-- Returns object image (in case it is a foreground object)
function Mapping.getImage(character)
    local descriptor = mapping[character]
    if descriptor and not descriptor.background then
        return descriptor.image
    end
end

-- Returns iterator for all descriptors
function Mapping.getIterator()
    return Table.iterator(descriptors)
end

-- Returns character representing nothing
function Mapping.getNone()
    return noneCharacter
end

-- Returns character representing wall
function Mapping.getWall()
    return wallCharacter
end

-- Core objects
addMapping {
    character   = wallCharacter,
    class       = "Wall",
    description = "Wall - Impassable, indestructible object.",
    image       = backgroundSprites[1],
    background  = true
}
addMapping {
    character   = noneCharacter,
    class       = "Object",
    description = "Floor - Empty space.",
    image       = backgroundSprites[5],
    background  = true
}
addMapping {
    character   = "@",
    class       = "Player",
    description = "Player - The unnamed hero.",
    image       = playerSprites[12]:clone():move(0, -2)
}
addMapping {
    character   = "$",
    class       = "Chest",
    description = "Chest - Contains key to unlock level exit. It opens after all diamonds are collected.",
    image       = objectsSprites[3]
}
addMapping {
    character   = "+",
    class       = "Door",
    description = "Door - Level exit. It opens after a key is obtained.",
    image       = objectsSprites[1]
}
addMapping {
    character   = "H",
    class       = "Ladder",
    description = "Ladder - Level exit. It emerges after a key is obtained.",
    image       = objectsSprites[15]
}

-- Diamonds
addMapping {
    character   = "g",
    class       = "Diamond",
    parameters  = { 6, "none" },
    description = "Green diamond - Basic diamond with no power-up.",
    image       = objectsSprites[6]
}
addMapping {
    character   = "r",
    class       = "Diamond",
    parameters  = { 7, "shot" },
    description = "Red diamond - Gives the player temporary ability (10 s) to shot a single projectile. Projectile petrifies enemies and can also destroy any explosive object.",
    image       = objectsSprites[7]
}
addMapping {
    character   = "k",
    class       = "Diamond",
    parameters  = { 8, "power" },
    description = "Black Diamond - Makes the player temporarily (10 s) 2x stronger. This means the player can push 4 boxes, 2 stones or 1 rock at once.",
    image       = objectsSprites[8]
}
addMapping {
    character   = "b",
    class       = "Diamond",
    parameters  = { 9, "immortality" },
    description = "Blue diamond - Makes the player temporarily (10 s) immortal.",
    image       = objectsSprites[9]
}
addMapping {
    character   = "y",
    class       = "Diamond",
    parameters  = { 10, "speed" },
    description = "Yellow diamond - Makes the player temporarily (10 s) 1.5x faster.",
    image       = objectsSprites[10]
}

-- Background objects
addMapping {
    character   = ".",
    class       = "Gravel",
    description = "Gravel - Enemies cannot enter this surface.",
    image       = backgroundSprites[9],
    background  = true
}
addMapping {
    character   = "_",
    class       = "Abyss",
    description = "Abyss - Blocks movement. Objects can be thrown into it.",
    image       = backgroundSprites[27],
    background  = true
}
addMapping {
    character   = "-",
    class       = "Trap",
    description = "Trap - Collapses into abyss after the player walks over it.",
    image       = backgroundSprites[13]
}
addMapping {
    character   = "~",
    class       = "Water",
    description = "Water - Blocks movement. Objects can be thrown into it. Things made of wood will float and make movement over the water possible. Other objects will sink.",
    image       = backgroundSprites[25],
    background  = true
}
addMapping {
    character   = "<",
    class       = "Arrow",
    parameters  = { "left" },
    description = "Left arrow - Blocks movement in right direction.",
    image       = backgroundSprites[21],
    background  = true
}
addMapping {
    character   = ">",
    class       = "Arrow",
    parameters  = { "right" },
    description = "Right arrow - Blocks movement in left direction.",
    image       = backgroundSprites[22],
    background  = true
}
addMapping {
    character   = "^",
    class       = "Arrow",
    parameters  = { "up" },
    description = "Up arrow - Blocks movement in down direction.",
    image       = backgroundSprites[23],
    background  = true
}
addMapping {
    character   = "v",
    class       = "Arrow",
    parameters  = { "down" },
    description = "Down arrow - Blocks movement in up direction.",
    image       = backgroundSprites[24],
    background  = true
}

-- Moveable objects
addMapping {
    character   = "x",
    class       = "Box",
    description = "Box - Movable object. Two can be pushed at once. It floats when it's thrown into water.",
    image       = objectsSprites[11]
}
addMapping {
    character   = "u",
    class       = "Barrel",
    description = "Barrel - Movable object. Two can be pushed at once. It floats when it's thrown into water.",
    image       = objectsSprites[12]
}
addMapping {
    character   = "o",
    class       = "Stone",
    description = "Stone - Movable object. Only one can be pushed at once.",
    image       = objectsSprites[13]
}
addMapping {
    character   = "O",
    class       = "Rock",
    description = "Rock - Movable object. It's too heavy to be pushed unless the player obtains a black diamond.",
    image       = objectsSprites[25]
}
addMapping {
    character   = "t",
    class       = "Dynamite",
    parameters  = { "small" },
    description = "Small dynamite - Explodes after collision with another object. The explosion can destroy nearby objects. Area of explosion is 1x1.",
    image       = objectsSprites[19]
}
addMapping {
    character   = "T",
    class       = "Dynamite",
    parameters  = { "big" },
    description = "Big dynamite - Same as the small one, but its area of explosion is 3x3. This means explosion can kill the player if they stand nearby.",
    image       = objectsSprites[20]
}

-- Static objects
addMapping {
    character   = "1",
    class       = "Switch",
    parameters  = { "white" },
    description = "White Switch - When something is placed on it, all white gates will open.",
    image       = objectsSprites[23]
}
addMapping {
    character   = "2",
    class       = "Switch",
    parameters  = { "red" },
    description = "Red Switch - When something is placed on it, all red gates will open.",
    image       = objectsSprites[23]:clone():blend(188, 96, 96)
}
addMapping {
    character   = "3",
    class       = "Switch",
    parameters  = { "blue" },
    description = "Blue Switch - When something is placed on it, all blue gates will open.",
    image       = objectsSprites[23]:clone():blend(122, 155, 200)
}
addMapping {
    character   = "A",
    class       = "Gate",
    parameters  = { "white" },
    description = "White Gate - Blocks movement until it's opened by a white switch. After releasing the switch, gate closes unless there is an object on it. Explosive objects will be destroyed by closed gate.",
    image       = objectsSprites[21]
}
addMapping {
    character   = "B",
    class       = "Gate",
    parameters  = { "red" },
    description = "Red Gate - Blocks movement until it's opened by a red switch. After releasing the switch, gate closes unless there is an object on it. Explosive objects will be destroyed by closed gate.",
    image       = objectsSprites[21]:clone():blend(188, 96, 96)
}
addMapping {
    character   = "C",
    class       = "Gate",
    parameters  = { "blue" },
    description = "Blue Gate - Blocks movement until it's opened by a blue switch. After releasing the switch, gate closes unless there is an object on it. Explosive objects will be destroyed by closed gate.",
    image       = objectsSprites[21]:clone():blend(122, 155, 200)
}

-- Enemies
addMapping {
    character   = "*",
    class       = "RedSlime",
    description = "Red slime - Static enemy. It does not harm the player, only blocks their way.",
    image       = enemiesSprites[2]:clone():move(0, -3)
}
addMapping {
    character   = "%",
    class       = "BlueSlime",
    description = "Blue slime - Same as the red one, but it can move and will follow the player.",
    image       = enemiesSprites[5]:clone():move(0, -3)
}
addMapping {
    character   = "!",
    class       = "Skull",
    description = "Skull - Sleeps until all diamonds are collected, then starts moving. When sleeping, it is harmless and only blocks the way. After awakening, it can kill the player on touch. It disappears after the player obtains a key.",
    image       = enemiesSprites[6]:clone():move(0, -2)
}
addMapping {
    character   = "&",
    class       = "Armor",
    description = "Living Armor - Static enemy. It will shoot a sword towards the player when they are in the same row or column. Swords cannot pass through solid objects. Armor disappears after the player obtains a key.",
    image       = enemiesSprites[9]:clone():move(0, -2)
}

return Mapping
