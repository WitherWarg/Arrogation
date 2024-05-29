function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest") -- Best for drawing pixel art
    
    -- local new_image_data = love.image.newImageData("cursor/Colour2/Outline/cursor.png")
    -- local new_cursor_image = love.mouse.newCursor(new_image_data, 0, 0)
    -- love.mouse.setCursor(new_cursor_image)
    -- love.mouse.setVisible(false)

    GS = require('libraries/gamestate') -- State Manager for game
    Class = require('libraries/class')
    timer = require('libraries/timer')
    vector = require('libraries/vector')
    anim8 = require('libraries.anim8')
    hsl = require('libraries/hsl')

    require('utilities.math')
    require('utilities.table')
    require('utilities.input')
    require('utilities.debug')
    require('utilities.world')

    Level = require('gamestates.level')
    
    GS.registerEvents{'enter', 'update', 'draw', 'leave'}
    return GS.switch(Level, 'forest')
end