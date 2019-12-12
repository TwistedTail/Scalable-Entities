include("shared.lua")

local Queued = {}
local NWVars = {
	Size = function(Entity, Value)
		-- Updating the clientside size one tick later to prevent problems on spawn
		timer.Simple(engine.TickInterval(), function()
			Entity:SetSize(Value)
		end)
	end,
	OriginalSize = function(Entity, Value)
		Entity.OriginalSize = Value
		Entity.Size	= Value

		if Queued[Entity] then
			Queued[Entity] = nil
			Entity:SetSize(Value)
		end
	end
}

function ENT:SetSize(NewSize)
	if not self.OriginalSize then
		Queued[self] = true
		return
	end

	local Size  = self.OriginalSize
	local Scale = Vector(1 / Size.x, 1 / Size.y, 1 / Size.z) * NewSize

	self:PhysicsInit(SOLID_VPHYSICS) -- Physics must be set to VPhysics before re-scaling

	local Phys = self:GetPhysicsObject()
	local Mesh = Phys:GetMeshConvexes()
	local Mat  = Matrix()

	for I, Hull in pairs(Mesh) do
		for J, Vertex in pairs(Hull) do
			Mesh[I][J] = Vertex.pos * Scale
		end
	end

	Mat:Scale(Scale)

	self:EnableMatrix("RenderMultiply", Mat)
	self:PhysicsInitMultiConvex(Mesh)
	self:EnableCustomCollisions(true)
	self:SetRenderBounds(self:GetCollisionBounds())
	self:DrawShadow(false)

	local Obj = self:GetPhysicsObject()

	if IsValid(Obj) then
		Obj:EnableMotion(false)
		Obj:Sleep()
	end
end

function ENT:Think()
	local Obj = self:GetPhysicsObject()

	if IsValid(Obj) then
		Obj:SetPos(self:GetPos())
		Obj:SetAngles(self:GetAngles())
		Obj:EnableMotion(false)
		Obj:Sleep()
	end
end

hook.Add("EntityNetworkedVarChanged", "Scalable Box NWChange", function(Entity, Name, _, New)
	if NWVars[Name] then
		NWVars[Name](Entity, New)
	end
end)
