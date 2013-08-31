if myHero.charName ~= "Malzahar" then return end
require "ChampionLib"
function OnLoad()
	rangeQ = 900 
	rangeW = 800
	rangeE = 650  
	rangeR = 700 
	killRange = 900

	target = Enemy(killRange, rangeQ, rangeW, rangeE, rangeR, false, false, true, false)
	
	Orbwalking = OrbWalker(myHero.range)
	Orbwalking:addAA()
	skillQ = Skill(_Q, rangeQ, SPELL_CIRCLE, 1400, 0.25) 
	skillW = Skill(_W, rangeW, SPELL_CIRCLE, 2000, 0.25) 
	skillE = Skill(_E, rangeE, SPELL_TARGETED)
	skillR = Skill(_R, rangeR, SPELL_TARGETED) 
	Config = scriptConfig("Malzahar WomboCombo 1.2", "Malzahar WomboCombo")
	Config:addParam("harass", "Harass (X)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	Config:addParam("teamFight", "TeamFight (SpaceBar)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("farm", "Farm (Z)", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
	Config:addParam("DrawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("DrawArrow", "Draw Arrow", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("MinionMarker", "Minion Marker", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("moveToMouse", "Move To Mouse", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("nearestTarget", "Nearest Target (T)", SCRIPT_PARAM_ONKEYTOGGLE, false, 84)
	Config:permaShow("nearestTarget")
	Config:permaShow("harass")
	Config:permaShow("teamFight")
	Config:permaShow("farm")
	PrintChat("Malzahar WomboCombo v1.2 Loaded!")
end

function OnTick()
	if Config.moveToMouse and Config.teamFight then myHero:MoveTo(mousePos.x, mousePos.z) end
	if Config.nearestTarget then
		target:update(true)
		if ValidTarget(target.focusTarget) and Config.teamFight then
			target:CastItems(target.focusTarget, true)
			if not TargetHaveBuff("alzaharnethergraspsound", myHero) then
				Orbwalking:Orbwalk(mousePos, target.focusTarget)
				skillQ:Cast(target.focusTarget)
				skillW:Cast(target.focusTarget)
				skillE:Cast(target.focusTarget)
				if not skillQ:Ready() and not skillW:Ready() and not skillE:Ready() then
					skillR:Cast(target.focusTarget)
				end
			end
		end
	else
		target:update()
		if ValidTarget(target.ks) then
			target:CastItems(target.ks, true)
			if not TargetHaveBuff("alzaharnethergraspsound", myHero) then
				if Config.teamFight then Orbwalking:Orbwalk(mousePos, target.ks) end
				skillE:Cast(target.ks)
			end
		elseif ValidTarget(target.kill) then
			if Config.teamFight then
				target:CastItems(target.kill, true)
				if not TargetHaveBuff("alzaharnethergraspsound", myHero) then
					Orbwalking:Orbwalk(mousePos, target.kill)
					skillQ:Cast(target.kill)
					skillW:Cast(target.kill)
					skillE:Cast(target.kill)
					if not skillQ:Ready() and not skillW:Ready() and not skillE:Ready() then
						skillR:Cast(target.kill)
					end
				end
			end
		elseif ValidTarget(target.combo) then
			if Config.teamFight then
				target:CastItems(target.combo, true)
				if not TargetHaveBuff("alzaharnethergraspsound", myHero) then
					Orbwalking:Orbwalk(mousePos, target.combo)
					skillQ:Cast(target.combo)
					skillW:Cast(target.combo)
					skillE:Cast(target.combo)
					if not skillQ:Ready() and not skillW:Ready() and not skillE:Ready() then
						skillR:Cast(target.combo)
					end
				end
			end
		elseif ValidTarget(target.harass) then
			if Config.teamFight then
				target:CastItems(target.harass)
				if not TargetHaveBuff("alzaharnethergraspsound", myHero) then
					Orbwalking:Orbwalk(mousePos, target.harass)
					skillQ:Cast(target.harass)
					skillW:Cast(target.harass)
					skillE:Cast(target.harass)
				end
			end
		end
	end
	if Config.harass and ValidTarget(target.focusTarget) then
		Orbwalking:Orbwalk(mousePos, target.focusTarget)
		skillQ:Cast(target.focusTarget)
	end
	if Config.farm and not Config.teamFight and not Config.harass then		
		target:GetMinion(_Q, rangeQ) --set skill and range for minion
		if ValidTarget(target.minion) then --target.minion is the selected minion
			skillQ:Cast(target.minion)
			--Orbwalking:Orbwalk(mousePos, target.minionLL)
		end
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