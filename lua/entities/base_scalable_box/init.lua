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

function CreateScalableBox(Player, Pos, Angle, Size)
	local Ent = ents.Create("base_scalable_box")

	if not IsValid(Ent) then return end

	Size = Vector(Size)

	Ent:SetModel("models/hunter/blocks/cube1x1x1.mdl")
	Ent:SetAngles(Angle)
	Ent:SetPos(Pos)
	Ent:Spawn()

	Ent:SetSize(Size)

	Ent.Owner = Player

	return Ent
end

if PSA then
	PSA.RegisterEntityClass("base_scalable_box", CreateScalableBox, "Size")
else
	duplicator.RegisterEntityClass("base_scalable_box", CreateScalableBox, "Pos", "Angle", "Size")
end

function ENT:SetSize(NewSize)
	if NewSize == self.Size then return end

	local Size  = GetOriginalSize(self)
	local Scale = Vector(1 / Size.x, 1 / Size.y, 1 / Size.z) * NewSize

	self:PhysicsInit(SOLID_VPHYSICS) -- Physics must be set to VPhysics before re-scaling

	local Phys = self:GetPhysicsObject()
	local Mesh = Phys:GetMeshConvexes()

	for I, Hull in pairs(Mesh) do
		for J, Vertex in pairs(Hull) do
			Mesh[I][J] = Vertex.pos * Scale
		end
	end

	self:PhysicsInitMultiConvex(Mesh)
	self:EnableCustomCollisions(true)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetNW2Vector("Size", NewSize)
	self.Size = NewSize

	local Obj = self:GetPhysicsObject()

	if IsValid(Obj) then
		Obj:SetMass(50)

		hook.Run("OnScaledBoxSizeChange", self, Obj, NewSize)
	end
end
