function love.load()
    GS = require('libraries/gamestate') -- State Manager for game
    Class = require('libraries/class')
    timer = require('libraries/timer')
    vector = require('libraries/vector')
    anim8 = require('libraries.anim8')
    hsl = require('libraries/hsl')

    love.graphics.setDefaultFilter("nearest", "nearest") -- Best for drawing pixel art

    math.randomseed(os.time())

    local new_image_data = love.image.newImageData("cursor/Colour2/Outline/cursor.png")
    local new_cursor_image = love.mouse.newCursor(new_image_data, 0, 0)
    love.mouse.setCursor(new_cursor_image)
    love.mouse.setVisible(false)

    WIDTH, HEIGHT = love.graphics.getDimensions()
    
    TIMER = timer.after(0, function() end)

    require('utilities.math')
    require('utilities.table')
    require('utilities.input')
    require('utilities.debug')
    require('utilities.printf')

    Level = require('gamestates.level')
    MainMenu = require('gamestates.main_menu')
    LevelTransition = require('gamestates.level_transition')
    
    GS.registerEvents{'enter', 'update', 'draw', 'leave'}
    return GS.switch(Level, 'forest')
end