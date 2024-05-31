--#region constant variables
local CURSOR_WIDTH = love.graphics.newImage("cursor/Colour2/Outline/cursor.png"):getWidth()
--#endregion

MainMenu = {}

function MainMenu:enter()
    love.mouse.setPosition(WIDTH / 2 - CURSOR_WIDTH / 2, HEIGHT / 3)

    local Button = require('ui.button')

    start = Button {
        x = WIDTH / 2, y = HEIGHT / 2,
        text = 'Start',
        onPress = function()
            GS.switch(Level, 'forest')
        end
    }
end

function MainMenu:update(dt)
    love.keyboard.update()

    timer.update(dt)

    start:update()
end

function MainMenu:draw()
    love.graphics.push('all')

    start:draw()

    love.graphics.pop()
end

function MainMenu:leave()
    start = nil
end

return MainMenu