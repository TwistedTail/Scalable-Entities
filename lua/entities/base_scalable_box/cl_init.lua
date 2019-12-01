include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)

	local Size  = self:GetNW2Vector("Size")
	local Scale = Vector(0.02107, 0.02107, 0.02107) * Size
	local Phys  = self:GetPhysicsObject()
	local Mesh  = Phys:GetMeshConvexes()
	local Mat   = Matrix()

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
