if myHero.charName ~= "Leblanc" then return end
require "ChampionLib"
require "Collision"
function OnLoad()
	rangeQ = 700
	rangeW = 1450
	rangeE = 1000  
	rangeR = 700 
	killRange = 1450
	target = Enemy(killRange, rangeQ, rangeW, rangeE, rangeR, false, false, false, false)
	Orbwalking = OrbWalker(myHero.range)
	Orbwalking:addAA()
	skillQ = Skill(_Q, rangeQ, SPELL_TARGETED)
	skillW = Skill(_W, rangeW, SPELL_CIRCLE, 2000, 0.25)
	skillE = Skill(_E, rangeE, SPELL_LINEAR_COL, 1600, 0.25, 95, true)
	skillR = Skill(_R, rangeR, SPELL_TARGETED)
	Config = scriptConfig("Leblanc WomboCombo 1.3.4", "LeblancWomboCombo")
	Config:addParam("harass", "Harass(X) - (W>Q>W)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	Config:addParam("teamFight", "TeamFight(SpaceBar)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("farm", "Farm(Z)", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
	Config:addParam("DrawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("DrawArrow", "Draw Arrow", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("MinionMarker", "Minion Marker", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("moveToMouse", "Move To Mouse", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("nearestTarget", "Nearest Target(T)", SCRIPT_PARAM_ONKEYTOGGLE, false, 84)
	Config:permaShow("nearestTarget")
	Config:permaShow("harass")
	Config:permaShow("teamFight")
	Config:permaShow("farm")
	PrintChat("Leblanc WomboCombo v1..3.4 Loaded!")
end

function OnTick()
	if Config.moveToMouse and Config.teamFight then myHero:MoveTo(mousePos.x, mousePos.z) end
	if Config.nearestTarget then
		target:update(true)
		if ValidTarget(target.focusTarget) and Config.teamFight then
			Orbwalking:Orbwalk(mousePos, target.focusTarget)
			target:CastItems(target.focusTarget, true)
			skillQ:Cast(target.focusTarget)
			if rMimic() then
				skillR:Cast(target.focusTarget)
			end
			if not wUsed() then
				skillW:Cast(target.focusTarget)
			end
			if not skillQ:Ready() and not skillR:Ready() then
				skillE:Cast(target.focusTarget)
			end
		end
	else
		target:update()
		if ValidTarget(target.harass) then
			if Config.teamFight then
				target:CastItems(target.harass)
				Orbwalking:Orbwalk(mousePos, target.harass)
				skillQ:Cast(target.harass)
				if rMimic() then
					skillR:Cast(target.harass)
				end
				if not wUsed() then
					skillW:Cast(target.harass)
				end
				if not skillQ:Ready() and not skillR:Ready() then
					skillE:Cast(target.harass)
				end
			end
		elseif ValidTarget(target.focusTarget) then
			if Config.teamFight then
				target:CastItems(target.focusTarget, true)
				Orbwalking:Orbwalk(mousePos, target.focusTarget)
				skillQ:Cast(target.focusTarget)
				if rMimic() then
					skillR:Cast(target.focusTarget)
				end
				if not wUsed() then
					skillW:Cast(target.focusTarget)
				end
				if not skillQ:Ready() and not skillR:Ready() then
					skillE:Cast(target.focusTarget)
				end
			end
		end
	end
	if Config.harass and ValidTarget(target.focusTarget) then
		Orbwalking:Orbwalk(mousePos, target.focusTarget)
		if not wUsed() and skillQ:Ready() then 
			skillW:Cast(target.focusTarget)
		end
		skillQ:Cast(target.focusTarget)
		if wUsed() and not skillQ:Ready() then
			skillW:Cast(target.focusTarget)
		end
	end
	if Config.farm and not Config.teamFight and not Config.harass then		
		target:GetMinion(_Q, rangeQ) --set skill and range for minion
		if ValidTarget(target.minion) then --target.minion is the selected minion
			CastSpell(_Q, target.minion)
			--Orbwalking:Orbwalk(mousePos, target.minionLL)
		end
	end
end
function rMimic()
	rData = myHero:GetSpellData(_R)
	if rData.name == "LeblancChaosOrbM" then
		return true
	else
		return false
	end
end
function wUsed() 
	wData = myHero:GetSpellData(_W)
	if wData.name == "leblancslidereturn" then 
		return true 
	else 
		return false
	end
end
function OnDraw()
	if not myHero.dead then
		if Config.DrawCircles then 
			DrawCircle(myHero.x, myHero.y, myHero.z, killRange, ARGB(87,183,60,244))
		end
		if ValidTarget(target.focusTarget) and Config.DrawArrow then
			DrawArrows(myHero, target.focusTarget, 30, 0x099B2299, 50) 
		end
		if ValidTarget(target.minion) and Config.MinionMarker then 
			DrawCircle(target.minion.x, target.minion.y, target.minion.z, 100, ARGB(87,183,60,244)) 
		end
	end	
end