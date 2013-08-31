if myHero.charName ~= "Karthus" then return end
require "ChampionLib"
--require "Collision" uncomment if it is needed
function OnLoad()
	rangeQ = 950              
	rangeW = 1000
	rangeE = 550  
	rangeR = 1000 
	killRange = 1000
	target = Enemy(killRange, rangeQ, rangeW, rangeE, rangeR, true, false, false, false)
	Orbwalking = OrbWalker(myHero.range)
	Orbwalking:addAA()
	skillQ = Skill(_Q, rangeQ, SPELL_CIRCLE, 900, 0.25) 
	skillW = Skill(_W, rangeW, SPELL_CIRCLE, 1000, 0.25) 
	skillE = Skill(_E, rangeE, SPELL_SELF)
	skillR = Skill(_R, rangeR, SPELL_SELF)
	defile = false
	ultCount = 0
	ultText = {"Use Ult: Kill", "Use Ult: Double Kill", "Use Ult: Triple Kill", "Use Ult: Quadra Kill", "Use Ult: Penta Kill"}
	enemyMinion = minionManager(MINION_ENEMY, 1000, player, MINION_SORT_HEALTH_ASC)
	Config = scriptConfig("Karthus WomboCombo 1.4.1", "Karthus WomboCombo")
	Config:addParam("harass", "Harass(X)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	Config:addParam("teamFight", "TeamFight(SpaceBar)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("farm", "Farm(Z)", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
	Config:addParam("DrawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("DrawArrow", "Draw Arrow", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("MinionMarker", "Minion Marker", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("moveToMouse", "Move To Mouse", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("AutoTurnOffE", "Auto E OFF (M)", SCRIPT_PARAM_ONKEYTOGGLE, true, 77)
	Config:addParam("nearestTarget", "Nearest Target(T)", SCRIPT_PARAM_ONKEYTOGGLE, false, 84)
	Config:addParam("setUltEnemies", "No. of 'ult him' Enemimes ", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
	Config:permaShow("setUltEnemies")
	Config:permaShow("nearestTarget")
	Config:permaShow("AutoTurnOffE")
	Config:permaShow("harass")
	Config:permaShow("teamFight")
	Config:permaShow("farm")
	PrintChat("Karthus WomboCombo v1.4.1 Loaded!")
end

function OnTick()
	if Config.moveToMouse and Config.teamFight then myHero:MoveTo(mousePos.x, mousePos.z) end
	if skillR:Ready() then
		ultCount = 0
		for _, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				local ultDmg = getDmg("R",enemy,myHero, 3)
				if ultDmg >= enemy.health then
					ultCount = ultCount + 1
				end
			end
			if ultCount >= Config.setUltEnemies then
				if CountEnemyHeroInRange(1500) == 0 and target:AlliesNearTarget(enemy, 800) ==0  then
					--Add dead skill here
					skillR:Cast()
				end
			end
		end
	end
	if CountEnemyHeroInRange(killRange) == 0 and Config.AutoTurnOffE then
		if defile then
			skillE:Cast()
		end
	end
	if Config.nearestTarget then
		target:update(true)
		if ValidTarget(target.focusTarget) and Config.teamFight then
			Orbwalking:Orbwalk(mousePos, target.focusTarget)
			target:CastItems(target.focusTarget, true)
			skillQ:Cast(target.focusTarget)
			skillW:Cast(target.focusTarget)
			if not defile then
				skillE:Cast(target.focusTarget)
			end
		end
	else
		target:update()
		if ValidTarget(target.ks) then
			target:CastItems(target.ks, true)
			if Config.teamFight then Orbwalking:Orbwalk(mousePos, target.ks) end
			skillQ:Cast(target.ks)
		elseif ValidTarget(target.kill) then
			if Config.teamFight then
				target:CastItems(target.kill, true)
				Orbwalking:Orbwalk(mousePos, target.kill)
				skillQ:Cast(target.kill)
				skillW:Cast(target.kill)
				if not defile and GetDistance(target.kill)<=rangeE then
					skillE:Cast(target.kill)
				end
			end
		elseif ValidTarget(target.combo) then
			if Config.teamFight then
				target:CastItems(target.combo, true)
				Orbwalking:Orbwalk(mousePos, target.combo)
				skillQ:Cast(target.combo)
				skillW:Cast(target.combo)
				if not defile and GetDistance(target.combo)<=rangeE then
					skillE:Cast(target.combo)
				end
			end
		elseif ValidTarget(target.harass) then
			if Config.teamFight then
				target:CastItems(target.harass)
				Orbwalking:Orbwalk(mousePos, target.harass)
				skillQ:Cast(target.harass)
				skillW:Cast(target.harass)
				if not defile and GetDistance(target.harass)<=rangeE then
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
		enemyMinion:update()
		for i, minion in pairs(enemyMinion.objects) do
			if skillQ:Ready() and GetDistance(minion)<=rangeQ and ValidTarget(minion) then
				dmg = getDmg("Q",minion,myHero, 2)
				if dmg/1.6>=minion.health then
					skillQ:Cast(minion)
				end
			end
		end
	end
end
function OnCreateObj(obj)	
	if obj.name:find("Defile_green_cas.troy") then
		if GetDistance(obj, myHero)<=80 then 
			defile = true
		end	
	end
end

function OnDeleteObj(obj)
	if obj.name:find("Defile_green_cas.troy") then
		if GetDistance(obj, myHero)<=80 then 
				defile = false
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
		if Config.MinionMarker then 
			enemyMinion:update()
			for i, minion in pairs(enemyMinion.objects) do
				if skillQ:Ready() and GetDistance(minion)<=rangeQ and ValidTarget(minion) then
					dmg = getDmg("Q",minion,myHero, 2)
					if dmg>=minion.health then
						DrawCircle(minion.x, minion.y, minion.z, 100, ARGB(87,183,60,244)) 
					end
				end
			end
		end
		if skillR:Ready() then
			if ultCount >=1 then
				DrawText(ultText[ultCount],25,400,50,0xFFFF66FF)
			else
				DrawText("",25,400,50,0xFFFF66FF)
			end
		else
			DrawText("",25,400,50,0xFFFF66FF)
		end
	end	
end