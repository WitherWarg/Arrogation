local TWEEN_DURATION = 0.5
local DELAY = 0.15

local LevelTransition = {}

function LevelTransition:enter(_, level_name)
    self.light = 1
    timer.tween(TWEEN_DURATION, self, { light = 0 }, 'linear', function ()
        timer.after(DELAY, function ()
            GS.switch(Level, level_name)
        end)
    end)
end

function LevelTransition:update(dt)
    timer.update(dt)

    love.graphics.setBackgroundColor(self.light, self.light, self.light)
end

return LevelTransition