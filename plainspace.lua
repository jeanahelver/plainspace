local perspective = require("lib/perspective")
local space = {scene={}}

function space:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
function space:add(texture, x,y,z)
	self.scene[#self.scene+1] = {
		img = texture,
		x = x,
		y = y,
		z = z
	}
	return #self.scene
end
function space:addTile(texture, x,y,z,roll,yaw,pitch)
	local w = texture:getWidth()/2
	local h = texture:getHeight()/2
	w = w/400
	h = h/400
	local roll = roll or 0
	local yaw = yaw or 0
	local pitch = pitch or 0
	self.scene[#self.scene+1] = {
		img = texture,
		x = x,
		y = y,
		z = z,
		vertex ={
			{x=-w,y=0,z=-h},
			{x= w,y=0,z=-h},
			{x=-w,y=0,z= h},
			{x= w,y=0,z= h},
		}
	}
	for _, vertex in pairs(self.scene[#self.scene].vertex) do
		vertex.y = vertex.y*math.cos(roll) + vertex.z*-math.sin(roll)
    	vertex.z = vertex.y*math.sin(roll) + vertex.z*math.cos(roll)

    	vertex.x = vertex.x*math.cos(yaw) + vertex.z*-math.sin(yaw)
      	vertex.z = vertex.x*math.sin(yaw) + vertex.z*math.cos(yaw)

      	vertex.x = vertex.x*math.cos(pitch) + vertex.y*-math.sin(pitch)
    	vertex.y = vertex.x*math.sin(pitch) + vertex.y*math.cos(pitch)

    	vertex.x = vertex.x+x
    	vertex.y = vertex.y+y
    	vertex.z = vertex.z+z
	end
	return #self.scene
end
function space:start()
	self.backupscene = DeepCopy(self.scene)
end
function space:draw()
 
	local screen = {w = love.graphics.getWidth(),h= love.graphics.getHeight()}
	table.sort(self.scene,function(a,b) return a.z < b.z end)
	for i, plane in pairs(self.scene) do
		if plane.z < -0.9 then --odd value but seems to fix glitches
			if plane.vertex ~= nil then
				local points = {}
				for _, vertex in pairs(plane.vertex) do
          local x = vertex.x / -vertex.z
          local y = vertex.y / -vertex.z * -1
          points[#points+1] = (screen.w/2) + x*(screen.w/2)
          points[#points+1] = (screen.h/2) + y*(screen.w/2)
				end
          perspective.on()
          perspective.quad(plane.img,{points[1],points[2]},{points[3],points[4]},{points[7],points[8]},{points[5],points[6]})
          perspective.off()
      else
				    local x = plane.x / -plane.z
      			local y = plane.y / -plane.z * -1
      			x = (screen.w/2) + x*(screen.w/2)
      			y = (screen.h/2) + y*(screen.w/2)
      			love.graphics.draw(plane.img, x, y, 0, 1/-plane.z,1/-plane.z,plane.img:getWidth()/2,plane.img:getHeight()/2)
      			
      		end
		end
	end
	self.scene = self.backupscene
  
end
function space:translate(x, y, z)
  for _, plane in pairs(self.scene) do
    plane.x = plane.x + x
    plane.y = plane.y + y
    plane.z = plane.z + z
    if plane.vertex ~= nil then 
    	for _, vertex in pairs(plane.vertex) do
      		vertex.x = vertex.x + x
      		vertex.y = vertex.y + y
      		vertex.z = vertex.z + z
      	end
    end
  end
end
function space:rotateY(r)
  local cosR = math.cos(r)
  local sinR = math.sin(r)
  for _, plane in pairs(self.scene) do
    local x = plane.x
    local z = plane.z
    plane.x = x*cosR + z*-sinR
    plane.z = x*sinR + z*cosR
    if plane.vertex ~= nil then 
    	for _, vertex in pairs(plane.vertex) do
      		local x = vertex.x
      		local z = vertex.z
      		vertex.x = x*cosR + z*-sinR
      		vertex.z = x*sinR + z*cosR
    	end
    end
  end
end
function space:rotateX(r)
  local cosR = math.cos(r)
  local sinR = math.sin(r)
  for _, plane in pairs(self.scene) do
    local y = plane.y
    local z = plane.z
    plane.y = y*cosR + z*-sinR
    plane.z = y*sinR + z*cosR
    if plane.vertex ~= nil then 
    	for _, vertex in pairs(plane.vertex) do
    		local y = vertex.y
      		local z = vertex.z
      		vertex.y = y*cosR + z*-sinR
      		vertex.z = y*sinR + z*cosR
    	end
    end
  end
end
function space:rotateZ(r)
  local cosR = math.cos(r)
  local sinR = math.sin(r)
  for _, plane in pairs(self.scene) do
    local x = plane.x
    local y = plane.y
    plane.x = x*cosR + y*-sinR
    plane.y = x*sinR + y*cosR
    if plane.vertex ~= nil then 
    	for _, vertex in pairs(plane.vertex) do
    		local x = vertex.x
    		local y = vertex.y
    		vertex.x = x*cosR + y*-sinR
    		vertex.y = x*sinR + y*cosR
    	end
    end
  end
end
function DeepCopy( Table, Cache ) -- Makes a deep copy of a table. 
    if type( Table ) ~= 'table' then
        return Table
    end

    Cache = Cache or {}
    if Cache[Table] then
        return Cache[Table]
    end

    local New = {}
    Cache[Table] = New
    for Key, Value in pairs( Table ) do
        New[DeepCopy( Key, Cache)] = DeepCopy( Value, Cache )
    end

    return New
end
return space
