local TWEEN_DURATION = 0.5
local DELAY = 0.15

local LevelTransition = {}

function LevelTransition:enter(_, level_name)
    assert(level_name ~= nil, "Please add a next_level property to the level's flag")

    self.light = 1

    timer.tween(TWEEN_DURATION, self, { light = 0 }, 'linear', function ()
        timer.after(DELAY, function ()
            if level_name == 'main_menu' then
                return GS.switch(MainMenu)
            end

            GS.switch(Level, level_name)
        end)
    end)
end

function LevelTransition:update(dt)
    timer.update(dt)
end

function LevelTransition:draw()
    love.graphics.push('all')

    love.graphics.setColor(self.light, self.light, self.light)
    love.graphics.rectangle('fill', 0, 0, WIDTH, HEIGHT)

    love.graphics.pop()
end

return LevelTransition