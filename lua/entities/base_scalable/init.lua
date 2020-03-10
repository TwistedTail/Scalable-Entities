AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local function GetOriginalSize(Entity)
	if not Entity.OriginalSize then
		local Min, Max = Entity:GetCollisionBounds()

		Entity.OriginalSize = -Min + Max
		Entity:SetNW2Vector("OriginalSize", -Min + Max)
	end

	return Entity.OriginalSize
end

function CreateScalable(Player, Pos, Angle, Size)
	local Ent = ents.Create("base_scalable")

	if not IsValid(Ent) then return end

	Ent:SetModel("models/hunter/blocks/cube1x1x1.mdl")
	Ent:SetAngles(Angle)
	Ent:SetPos(Pos)
	Ent:Spawn()

	Ent:SetSize(Size)

	Ent.Owner = Player

	return Ent
end
duplicator.RegisterEntityClass("base_scalable", CreateScalable, "Pos", "Angle", "Size")

function ENT:SetSize(NewSize)
	if NewSize == self.Size then return end

	local Size  = GetOriginalSize(self)
	local Scale = Vector(1 / Size.x, 1 / Size.y, 1 / Size.z) * NewSize

	self:PhysicsInit(SOLID_VPHYSICS) -- Physics must be set to VPhysics before re-scaling
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	local Phys = self:GetPhysicsObject()
	local Mesh = Phys:GetMeshConvexes()

	for I, Hull in pairs(Mesh) do -- Scale the mesh
		for J, Vertex in pairs(Hull) do
			Mesh[I][J] = Vertex.pos * Scale
		end
	end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInitMultiConvex(Mesh) -- Apply new mesh
	self:EnableCustomCollisions(true)

	self:SetNW2Vector("Size", NewSize)
	self.Size = NewSize

	local Obj = self:GetPhysicsObject()

	if IsValid(Obj) then
		Obj:SetMass(Obj:GetVolume() / 1000)

		if self.OnResized then self:OnResized() end

		hook.Run("OnScaledBoxSizeChange", self, Obj, NewSize)
	end
end