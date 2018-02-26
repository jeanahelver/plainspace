space = require("plainspace")
function love.load()
	grid = love.graphics.newImage("grid.png")
	room = space:new()
	room:addTile(grid, 0,0,0)

	rotation = 0
end
function love.update(dt)
	rotation = rotation +dt
end
function love.draw()
	room:start()

	room:rotateY(rotation)
	room:rotateX(rotation)
	room:translate(0,0,-3)

	room:draw()

	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end
