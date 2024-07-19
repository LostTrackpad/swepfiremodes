local Weapon = nil

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

local FiremodeNormalCase = {
	["FULL-AUTO"] = "Full-Auto",
	["SEMI-AUTO"] = "Semi-Auto",
	["3-BURST"] = "3-Burst",
	["SAFETY"] = "Safety"
}

function IsInputBound(bind) -- Renamed ARC9 function. Don't wanna cause conflicts.
    local key = input.LookupBinding(bind)

    if !key then
        return false
    else
        return true
    end
end


function GetCWFiremodeName()
	if Weapon:GetInUBGL() then return end
	--AltFiremodeText = Weapon:GetBuff_Override("UBGL_PrintName") and Weapon:GetBuff_Override("UBGL_PrintName") or ArcCW.GetTranslation("fcg.ubgl" .. abbrev)

	if Weapon:GetBuff_Hook("Hook_FiremodeName") then return Weapon:GetBuff_Hook("Hook_FiremodeName") end

	--local abbrev = GetConVar("arccw_hud_fcgabbrev"):GetBool() and ".abbrev" or ""

	--if Weapon:GetInUBGL() then
	--	ActivePrimaryFire = false
	--end

	local fm = Weapon:GetCurrentFiremode()

	if fm.PrintName then
		local phrase = ArcCW.GetPhraseFromString(fm.PrintName)
		return phrase and ArcCW.GetTranslation(phrase) or ArcCW.TryTranslation(fm.PrintName)
	end

	local mode = fm.Mode
	if mode == 0 then return "Safety" end
	if mode == 1 then return "Semi-Auto" end
	if mode >= 2 then return "Full-Auto" end
	if mode < 0 then return tostring(-mode) .. "-Burst" end
end

function GetA9FiremodeName()
	AltFiremodeText = Weapon:GetProcessedValue("UBGLFiremodeName")

	if Weapon:GetUBGL() then
		ActivePrimaryFire = false
	else
	end

	local arc9_mode = Weapon:GetCurrentFiremodeTable()
	local FiremodeText = "UNKNOWN"

	if arc9_mode.PrintName then
		FiremodeText = arc9_mode.PrintName
	else
		if arc9_mode.Mode == 1 then
			FiremodeText = "Semi-Auto"
		elseif arc9_mode.Mode == 0 then
			FiremodeText = "Safety"
		elseif arc9_mode.Mode < 0 then
			FiremodeText = "Full-Auto"
		elseif arc9_mode.Mode > 1 then
			FiremodeText = tostring(arc9_mode.Mode) .. "-Burst"
		end
	end

	if Weapon:GetSafe() then
		FiremodeText = "Safety"
	end

	return FiremodeText
end

function GetCurrentFiremode()
	Weapon = LocalPlayer():GetActiveWeapon()

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

		FiremodeString = GetA9FiremodeName()

		if Weapon:GetUBGL() then
			--arc9_mode = {
			--	Mode = Weapon:GetCurrentFiremode(),
			--	PrintName = Weapon:GetProcessedValue("UBGLFiremodeName")
			--}
			--FiremodeString = arc9_mode.PrintName
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

		AltFiremodeString = Weapon:GetBuff_Override("UBGL_PrintName") and Weapon:GetBuff_Override("UBGL_PrintName") or ArcCW.GetTranslation("fcg.ubgl")

		if Weapon:GetInUBGL() then
			ActivePrimaryFire = false
		else
			FiremodeString = GetCWFiremodeName()
		end

		if string.match(FiremodeString, "-round burst") then
			string.Replace(FiremodeString, "-round burst", "-BURST")
		elseif string.match(FiremodeString, "-ROUND BURST") then -- bruh case sensitivity is a thing
			string.Replace(FiremodeString, "-ROUND BURST", "-BURST")
		end

		FiremodeString = string.upper(FiremodeString)

		if Weapon:GetMalfunctionJam() then
			WeaponJammed = true
		end
	elseif ismgbase then
		-- FIXME: Fix Safety detection for the dev build of MWBase and make it also work for the public build.
		FiremodeString = string.upper(Weapon.Firemodes[Weapon:GetFiremode()].Name) -- Do we need two complicated tables for this?
		for k,v in pairs(MWBaseFiremodes) do
			if k == FiremodeString then
				FiremodeString = v
			end
		end
	elseif istfabase then
		FiremodeString = Weapon:GetFireModeName() -- Do we need two complicated tables for this?
		for k,v in pairs(TFAFiremodes) do
			if k == FiremodeString then
				FiremodeString = v
			end
		end
		-- It's a miracle how all of these bases don't conflict regarding their GetFiremode() or equivalent function.
	elseif Weapon:IsScripted() then
		if !Weapon.Primary.Automatic then
			FiremodeString = "Semi-Auto"
		end

		if Weapon.ThreeRoundBurst then
			FiremodeString = "3-Burst"
		end

		if Weapon.TwoRoundBurst then
			FiremodeString = "2-Burst"
		end

		if Weapon.GetSafe then
			if Weapon:GetSafe() then
				FiremodeString = "Safety"
			end
		end

		if isfunction(Weapon.Safe) then
			if Weapon:Safe() then
				FiremodeString = "Safety"
			end
		end

		if isfunction(Weapon.Safety) then
			if Weapon:Safety() then
				FiremodeString = "Safety"
			end
		end
	elseif !VanillaAutomatics[Weapon:GetClass()] then
		FiremodeString = "Semi-Auto"
	end

	if !isarc9 and !Weapon.ArcCW then AltFiremodeString = "Altfire" end

	if isarc9 and !IsInputBound("+arc9_ubgl") then
		ubglkey = "[" .. usekey .."]+" .. "[" .. attack2 .. "]"
	elseif isarc9 and IsInputBound("+arc9_ubgl") then
		ubglkey = "[" .. string.upper(input.LookupBinding("+arc9_ubgl", 1)) .. "]"
	elseif isweparccw and IsInputBound("arccw_toggle_ubgl") then
		ubglkey = "[" .. string.upper(input.LookupBinding("arccw_toggle_ubgl", 1)) .. "]"
	elseif isweparccw then
		ubglkey = "[" .. usekey .."]+" .. "[" .. reloadkey .. "]"
	end

	for k,v in pairs(FiremodeNormalCase) do
		if k == FiremodeString then
			FiremodeString = v
		end
	end
end