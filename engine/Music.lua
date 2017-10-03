-- Music module
local Music = {}

-- Variables
local previousMusic = nil
local currentMusic = nil
local selectedMusic = nil
local defaultFadeDuration = 0
local currentFadeDuration = 0
local selectedFadeDuration = 0
local musicPaused = false
local timeLeft = 0

-- Initializes music
function Music.init(config)
    Music.setFadeDuration(config.audioFadeDuration)
end

-- Pauses or resumes music
local function pauseMusic(paused)
    if currentMusic and musicPaused ~= paused then
        musicPaused = paused
        if paused then
            currentMusic:pause()
        else
            currentMusic:resume()
        end
    end
end

-- Schedules change of music
local function resetMusic(music, duration)
    if selectedMusic == music then
        return
    end

    -- With transition
    if duration then
        selectedFadeDuration = math.max(0.001, duration)
        selectedMusic = music
    -- Without transition
    else
        if currentMusic then
            currentMusic:stop()
        end

        timeLeft = 0
        selectedMusic = music
        currentMusic = music

        if currentMusic then
            currentMusic:setVolume(1);
            currentMusic:play()
        end
    end
end

-- Updates music
function Music.update(delta)
    -- Skip update if paused
    if musicPaused then
        return
    end

    -- Perform volume change
    if timeLeft > 0 then
        local progress = timeLeft / currentFadeDuration
        local prevTimeLeft = timeLeft
        timeLeft = math.max(timeLeft - delta, 0)

        if currentMusic then
            currentMusic:setVolume(1 - progress);
            if prevTimeLeft == currentFadeDuration then
                currentMusic:play()
            end
        else
            previousMusic:setVolume(progress);
            if timeLeft == 0 then
                previousMusic:stop()
            end
        end
    -- Perform music change
    elseif currentMusic ~= selectedMusic then
        if currentMusic then
            previousMusic = currentMusic
            currentMusic = nil
        else
            currentMusic = selectedMusic
        end
        currentFadeDuration = selectedFadeDuration
        timeLeft = currentFadeDuration
    end
end

-- Sets fade duration
function Music.setFadeDuration(duration)
    defaultFadeDuration = duration or 1
end

-- Pauses music
function Music.pause()
    pauseMusic(true)
end

-- Resumes paused music
function Music.resume()
    pauseMusic(false)
end

-- Plays music immediately
function Music.play(music)
    resetMusic(music)
end

-- Stops music immediately
function Music.stop()
    resetMusic()
end

-- Plays music with transition
function Music.fadeIn(music, duration)
    resetMusic(music, duration or defaultFadeDuration)
end

-- Stops music with transition
function Music.fadeOut(duration)
    resetMusic(nil, duration or defaultFadeDuration)
end

return Music
