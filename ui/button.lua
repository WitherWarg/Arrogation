--#region constant variables
local font = love.graphics.newFont('fonts/angel_wish/Angel wish.otf', 70)
local margin = vector(40, 15)
local BORDER = 3
local HOVER_TWEEN_TIME = 0.1
local HOVER_TWEEN_METHOD = 'out-in-cubic'
--#endregion

local Button = Class {
    is_hovered = false,
    is_pressed = false,
    is_released = false,

    border = 0,

    is_tween_ongoing = false,
}

function Button:init(parameters)
    self.text = parameters.text

    self.width, self.height = font:getWidth(self.text) + margin.x, font:getHeight() + margin.y

    self.x, self.y = parameters.x - self.width/2, parameters.y - self.height/2

    self.onPress = parameters.onPress or function() end
end

function Button:update()
    local x, y = love.mouse.getPosition()

    self.is_hovered = self.x < x and x < self.x + self.width and self.y < y and y < self.y + self.height
    self.is_pressed = input('left_click') and self.is_hovered

    if self.is_pressed then
        self:onPress()
    end

    if self.is_hovered and not self.is_tween_ongoing then
        self.is_tween_ongoing = true
        timer.tween(HOVER_TWEEN_TIME, self, { border = BORDER * 2 }, HOVER_TWEEN_METHOD, function ()
            self.is_tween_ongoing = false
        end)
    end

    if not self.is_hovered then
        self.border = 0
        self.is_tween_ongoing = false
    end
end

function Button:draw()
    love.graphics.push('all')

    if self.is_tween_ongoing or self.is_hovered then
        love.graphics.setColor(hsl(0, 0, 100))
        love.graphics.rectangle(
            'fill',
            self.x - self.border/2 - 0.5, -- Border has a 0.5 offset for some reason
            self.y - self.border/2 - 0.5,
            self.width + self.border,
            self.height + self.border
        )
    end

    love.graphics.setColor(hsl(2, 80, 47))
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    love.graphics.setColor(hsl(51, 100, 45))
    love.graphics.setFont(font)
    love.graphics.print(
        self.text, self.x, self.y, nil, nil, nil,
        font:getWidth(self.text) / 2 - self.width / 2,
        font:getHeight() / 2 - self.height / 2
    )

    love.graphics.pop()
end

return Button