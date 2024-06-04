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
            GS.switch(LevelTransition, 'forest')
        end
    }

    love.mouse.setVisible(true)
end

function MainMenu:update(dt)
    love.keyboard.update()

    timer.update(dt)

    start:update()

    love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
end

function MainMenu:draw()
    love.graphics.push('all')

    start:draw()

    love.graphics.pop()
end

function MainMenu:leave()
    start = nil

    love.mouse.setVisible(false)
end

return MainMenu