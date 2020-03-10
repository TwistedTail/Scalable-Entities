-- Detour decals to scale properly on scaled entities

hook.Add("Initialize", "Scalable Ents Decals", function()
	local DecalEx = util.DecalEx

	util.DecalEx = function(Mat, Ent, Pos, Normal, Color, W, H)
		if Ent.OriginalSize then -- If entity is scaled offset decal pos
			local Offset = Pos - Ent:GetPos()

			-- Thank you, Garry. Very cool.
			local O 	 = Ent.OriginalSize
			local C 	 = Ent.CurrentSize
			local Scaler = Vector(O[1] / C[1], O[2] / C[2], O[3] / C[3])

			Pos = Ent:GetPos() + Offset * Scaler

			local Max = math.Max(Scaler[1], Scaler[2], Scaler[3])

			W = W * Max
			H = H * Max
		end

		DecalEx(Mat, Ent, Pos, Normal, Color, W, H)
	end

	hook.Remove("Initialize", "Scalable Ents Decals")
end)