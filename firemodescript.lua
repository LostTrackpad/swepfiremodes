local MWBaseFiremodes = {
    ["AUTOMATIC"] = "Full-Auto",
	["FULL AUTO"] = "Full-Auto",
	["SEMI AUTO"] = "Semi-Auto",
	["SEMI AUTOMATIC"] = "Semi-Auto",
	["3RND BURST"] = "3-Burst"
}

local TFAFiremodes = {
    ["Full-Auto"] = "Full-Auto",
	["Semi-Auto"] = "Semi-Auto",
	["3 Round Burst"] = "3-Burst"
}

local VanillaAutomatics = {
	["weapon_smg1"] = true,
	["weapon_ar2"] = true,
	["weapon_mp5_hl1"] = true,
	["weapon_gauss"] = true,
	["weapon_egon"] = true
}

function GetCurrentWeaponFiremode()
	local Weapon = LocalPlayer():GetActiveWeapon()

	if !IsValid(Weapon) then return end

	local ismgbase = false
	local isarc9 = Weapon.ARC9
	local inarc9cust = isarc9 and Weapon:GetCustomize()
	local isweparccw = Weapon.ArcCW
	local istfabase = Weapon.IsTFAWeapon
	ActivePrimaryFire = true

	usekey = string.Replace(input.LookupBinding("+use"), "MOUSE", "M")
	attack2 = string.Replace(input.LookupBinding("+attack2"), "MOUSE", "M")
	reloadkey = string.Replace(input.LookupBinding("+reload"), "MOUSE", "M")

	if Weapon:IsScripted() and WepMag2 == -1 then
		InstantAltfire = true
	elseif !Weapon:IsScripted() then
		InstantAltfire = true
	else
		InstantAltfire = false
	end

	if weapons.IsBasedOn(Weapon:GetClass(), "mg_base") then -- I have ZERO other fucking clue as to how to detect MW Base as it's barely documented.
		ismgbase = true
	else
		ismgbase = false
	end

	if isarc9 then -- Biggest blunder ever: forgor to change a9 to isarc9. bruh.
		local arc9_mode = Weapon:GetCurrentFiremodeTable()

		FiremodeText = GetA9FiremodeName()

		if Weapon:GetUBGL() then
			--arc9_mode = {
			--	Mode = Weapon:GetCurrentFiremode(),
			--	PrintName = Weapon:GetProcessedValue("UBGLFiremodeName")
			--}
			--FiremodeText = arc9_mode.PrintName
			wepmultifire = false
			ActivePrimaryFire = false
		end

		if Weapon:GetJammed() then
			WeaponJammed = true
		end

		if Weapon:GetProcessedValue("Overheat", true) then
			arc9showheat = true
			heat = Weapon:GetHeatAmount()
			heatcap = Weapon:GetProcessedValue("HeatCapacity")
			heatlocked = Weapon:GetHeatLockout()
		end
	elseif Weapon.ArcCW then
		local arccw_mode = Weapon:GetCurrentFiremode()

		AltFiremodeText = Weapon:GetBuff_Override("UBGL_PrintName") and Weapon:GetBuff_Override("UBGL_PrintName") or ArcCW.GetTranslation("fcg.ubgl")

		if Weapon:GetInUBGL() then
			ActivePrimaryFire = false
		else
			FiremodeText = GetCWFiremodeName()
		end

		if string.match(FiremodeText, "-round burst") then
			string.Replace(FiremodeText, "-round burst", "-BURST")
		elseif string.match(FiremodeText, "-ROUND BURST") then -- bruh case sensitivity is a thing
			string.Replace(FiremodeText, "-ROUND BURST", "-BURST")
		end

		FiremodeText = string.upper(FiremodeText)

		if Weapon:GetMalfunctionJam() then
			WeaponJammed = true
		end
	elseif ismgbase then
		-- FIXME: Fix Safety detection for the dev build of MWBase and make it also work for the public build.
		FiremodeText = string.upper(Weapon.Firemodes[Weapon:GetFiremode()].Name) -- Do we need two complicated tables for this?
		for k,v in pairs(MWBaseFiremodes) do
			if k == FiremodeText then
				FiremodeText = v
			end
		end
	elseif istfabase then
		FiremodeText = Weapon:GetFireModeName() -- Do we need two complicated tables for this?
		for k,v in pairs(TFAFiremodes) do
			if k == FiremodeText then
				FiremodeText = v
			end
		end
		-- It's a miracle how all of these bases don't conflict regarding their GetFiremode() or equivalent function.
	elseif Weapon:IsScripted() then
		if !Weapon.Primary.Automatic then
			FiremodeText = "Semi-Auto"
		end

		if Weapon.ThreeRoundBurst then
			FiremodeText = "3-Burst"
		end

		if Weapon.TwoRoundBurst then
			FiremodeText = "2-Burst"
		end

		if Weapon.GetSafe then
			if Weapon:GetSafe() then
				FiremodeText = "Safety"
			end
		end

		if isfunction(Weapon.Safe) then
			if Weapon:Safe() then
				FiremodeText = "Safety"
			end
		end

		if isfunction(Weapon.Safety) then
			if Weapon:Safety() then
				FiremodeText = "Safety"
			end
		end
	elseif !VanillaAutomatics[Weapon:GetClass()] then
		FiremodeText = "Semi-Auto"
	end

	if !isarc9 and !Weapon.ArcCW then AltFiremodeText = "Altfire" end

	if isarc9 and !IsInputBound("+arc9_ubgl") then
		ubglkey = "[" .. usekey .."]+" .. "[" .. attack2 .. "]"
	elseif isarc9 and IsInputBound("+arc9_ubgl") then
		ubglkey = "[" .. string.upper(input.LookupBinding("+arc9_ubgl", 1)) .. "]"
	elseif isweparccw and IsInputBound("arccw_toggle_ubgl") then
		ubglkey = "[" .. string.upper(input.LookupBinding("arccw_toggle_ubgl", 1)) .. "]"
	elseif isweparccw then
		ubglkey = "[" .. usekey .."]+" .. "[" .. reloadkey .. "]"
	end
end