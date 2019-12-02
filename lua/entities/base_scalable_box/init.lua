AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-- util.PrecacheModel("models/hunter/blocks/cube1x1x1.mdl")

function CreateScalableBox(Player, Pos, Angle, Size)
	local Ent = ents.Create("base_scalable_box")

	if not IsValid(Ent) then return end

	Size = Vector(Size)

	Ent:SetModel("models/hunter/blocks/cube1x1x1.mdl")
	Ent:SetAngles(Angle)
	Ent:SetPos(Pos)
	Ent:Spawn()

	local Scale = Vector(0.02107, 0.02107, 0.02107) * Size
	local Phys  = Ent:GetPhysicsObject()
	local Mesh  = Phys:GetMeshConvexes()

	for I, Hull in pairs(Mesh) do
		for J, Vertex in pairs(Hull) do
			Mesh[I][J] = Vertex.pos * Scale
		end
	end

	Ent:SetNW2Vector("Size", Size)

	Ent:PhysicsInitMultiConvex(Mesh)
	Ent:EnableCustomCollisions(true)
	Ent:SetMoveType(MOVETYPE_VPHYSICS)
	Ent:SetSolid(SOLID_VPHYSICS)

	Ent.Owner = Player
	Ent.Size  = Size

	local Obj = Ent:GetPhysicsObject()

	if IsValid(Obj) then
		Obj:SetMass(50)
	end

	return Ent
end

if PSA then
	PSA.RegisterEntityClass("base_scalable_box", CreateScalableBox, "Size")
else
	duplicator.RegisterEntityClass("base_scalable_box", CreateScalableBox, "Pos", "Angle", "Size")
end
