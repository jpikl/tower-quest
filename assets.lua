-- Fonts
fonts = {}
fonts.tiny = Font("tiny-font.png", "1234567890")
fonts.big = Font("big-font.png", " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
fonts.normal = Font("font.png", " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
fonts.normal:setLineHeight(1.5)
love.graphics.setFont(fonts.normal)

-- Images
images = {}
images.controls1 = Image("controls-01.png")
images.controls2 = Image("controls-02.png")
images.creditsFg = Image("credits-fg.png")
images.intro1 = Image("intro-01.png")
images.intro2 = Image("intro-02.png")
images.intro3 = Image("intro-03.png")
images.lovePowered = Image("love-powered.png")
images.particle = Image("particle.png")
images.title = Image("title.png")

-- Sprite sheets
sprites = {}
sprites.background = SpriteSheet("background.png", 16, 16)
sprites.clouds = SpriteSheet("clouds.png", 200, 96)
sprites.editor = SpriteSheet("editor.png", 16, 16)
sprites.enemies = SpriteSheet("enemies.png", 16, 18)
sprites.objects = SpriteSheet("objects.png", 16, 16)
sprites.player = SpriteSheet("player.png", 16, 18)
sprites.selection = SpriteSheet("selection.png",  56, 46)
sprites.smoke = SpriteSheet("smoke.png", 20, 28)
sprites.ui = SpriteSheet("ui.png", 8, 8)

-- Animations
animations = {}
animations.redSlime = Animation(sprites.enemies, "1-2"):setSpeed(1.5):setLooping()
animations.blueSlime = Animation(sprites.enemies, "3-5"):setSpeed(2):setLooping()
animations.smoke = Animation(sprites.smoke, "1-3"):setSpeed(10)
animations.trap = Animation(sprites.background, "17-20"):setSpeed(10)
animations.skull = Animation(sprites.enemies):setSpeed(3)
animations.skull:addSequence("movement", "7-8"):setLooping()
animations.skull:addSequence("stop", "6")
animations.player = Animation(sprites.player):setSpeed(4)
animations.player:addSequence("up", "2 1 2 3"):setLooping()
animations.player:addSequence("right", "5 4 5 6"):setLooping()
animations.player:addSequence("down", "8 7 8 9"):setLooping()
animations.player:addSequence("left", "11 10 11 12"):setLooping()

-- Sounds
sounds = {}
sounds.chest = Sound("chest.ogg")
sounds.completion = Sound("completion.ogg", 0.4)
sounds.death = Sound("death.ogg")
sounds.diamond = Sound("diamond.ogg", 0.4)
sounds.editor = Sound("editor.ogg")
sounds.exit = Sound("exit.ogg", 0.6)
sounds.fall = Sound("fall.ogg")
sounds.shot = Sound("shot.ogg")
sounds.smoke = Sound("smoke.ogg")
sounds.switch = Sound("switch.ogg", 0.5)
sounds.gate = sounds.switch
sounds.trap = Sound("trap.ogg")
sounds.ui = Sound("ui.ogg")
sounds.walk = Sound("walk.ogg")
sounds.water = Sound("water.ogg")

-- Music
music = {}
music.title = Music("title.ogg")
music.levels = Music("levels.ogg")
music.credits = Music("credits.ogg")
music.game1 = Music("game-01.ogg")
music.game2 = Music("game-02.ogg")
