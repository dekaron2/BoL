if myHero.charName ~= "Cassiopeia" then return end
--require "Collision"
function OnLoad()
	LoadMenu()
	LoadVariables()
	LoadSkillRanges()
	LoadVIPPrediction()
	LoadMinions()
	LoadSummonerSpells()
	LoadEnemies()
end
function OnUnload()
	PrintFloatText(myHero,2,"Cassiopeia WomboCombo v1.2.8 UnLoaded!")
	newTarget = nil

end
function LoadMenu()
	Config = scriptConfig("Cassiopeia WomboCombo 1.2.8", "Cassiopeia WomboCombo")
	Config:addParam("harass", "Harass (X)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	Config:addParam("teamFight", "TeamFight (SpaceBar)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("farm", "Farm (Z)", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
	Config:addParam("DrawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("DrawArrow", "Draw Arrow", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("MinionMarker", "Minion Marker", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("moveToMouse", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("autoE", "Auto E (M)", SCRIPT_PARAM_ONKEYTOGGLE, true, 77)
	Config:addParam("useUltKillable", "Use Ult 'killHim' (U)", SCRIPT_PARAM_ONKEYTOGGLE, true, 85)
	--Config:addParam("nearestTarget", "Nearest Target (T)", SCRIPT_PARAM_ONKEYTOGGLE, false, 84)
	Config:addParam("setUltEnemies", "No. Enemies facing", SCRIPT_PARAM_SLICE, 1, 1, 6, 0)
	Config:permaShow("setUltEnemies")
	--Config:permaShow("nearestTarget")
	Config:permaShow("useUltKillable")
	Config:permaShow("autoE")
	Config:permaShow("harass")
	Config:permaShow("teamFight")
	Config:permaShow("farm")
	PrintFloatText(myHero,2,"Cassiopeia WomboCombo v1.2.8 Loaded!")
end
function LoadVariables()
	ignite = nil
	floattext = {"Harass Him!","Combo Killer!","Kill Him!","Ult him!"}
	enemyHeros = {}
	enemyHerosCount = 0
	NextShot = 0
	aaTime = 0
	minionRange = false
	wTick = 0
	tick = 0
	igniteActive = false
	igniteTick = 0
end
function LoadSkillRanges()
	rangeQ = 900
	rangeW = 950
	rangeE = 700
	rangeR = 750
	killRange = 950
end
function LoadVIPPrediction()
	tpQ = TargetPredictionVIP(rangeQ, 1650, 0.25)
	tpW = TargetPredictionVIP(rangeW, 2000, 0.25)
	tpR = TargetPredictionVIP(rangeR, 1850, 0.25)
end
function LoadMinions()
	enemyMinion = minionManager(MINION_ENEMY, rangeQ, player, MINION_SORT_HEALTH_ASC)
	jungleMinion = minionManager(MINION_JUNGLE, rangeQ, player, MINION_SORT_HEALTH_DES)
end
function LoadSummonerSpells()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then 
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2
	else 
		ignite = nil
  	end
end
function LoadEnemies()
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team ~= player.team then
			local enemyCount = enemyHerosCount + 1
			enemyHeros[enemyCount] = {object = hero, waittxt = 0, killable = 0 }
			enemyHerosCount = enemyCount
		end
	end
end
function OnTick()
	if not myHero.dead then

		QREADY = (myHero:CanUseSpell(_Q) == READY)
		WREADY = (myHero:CanUseSpell(_W) == READY)
		EREADY = (myHero:CanUseSpell(_E) == READY)
		RREADY = (myHero:CanUseSpell(_R) == READY)
		IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
		execute()
		orbWalk()
		jungleFarm()
		if Config.farm and not Config.teamFight and not Config.harass then
			farmCheck()
		end
		if Config.harass then
			harassCheck()
		end
	end
end

function Target()
	local currentTarget = nil
	local facing = 0
	local killMana = 0
	local ksMana = 0
	if ValidTarget(newTarget) then
		igniteCheck(newTarget)
		if GetDistance(newTarget)>killRange then
			newTarget = nil
		end
	else
		newTarget = nil
	end
	for i = 1, enemyHerosCount do
		local Enemy = enemyHeros[i].object
		if ValidTarget(Enemy) then
			local pdmg = getDmg("P", Enemy, myHero, 3)
			local qdmg = getDmg("Q", Enemy, myHero, 3)
			local wdmg = getDmg("W", Enemy, myHero, 3)
			local edmg = getDmg("E", Enemy, myHero, 3)
			local rdmg = getDmg("R", Enemy, myHero, 3)
			local ADdmg = getDmg("AD", Enemy, myHero, 3)
			local dfgdamage = (GetInventoryItemIsCastable(3128) and getDmg("DFG",Enemy,myHero) or 0) -- Deathfire Grasp
			local hxgdamage = (GetInventoryItemIsCastable(3146) and getDmg("HXG",Enemy,myHero) or 0) -- Hextech Gunblade
			local bwcdamage = (GetInventoryItemIsCastable(3144) and getDmg("BWC",Enemy,myHero) or 0) -- Bilgewater Cutlass
			local botrkdamage = (GetInventoryItemIsCastable(3153) and getDmg("RUINEDKING", Enemy, myHero) or 0) --Blade of the Ruined King
			if IREADY then
				idmg = getDmg("IGNITE",Enemy,myHero, 3)
			else
				idmg = 0
			end
			local onhitdmg = (GetInventoryHaveItem(3057) and getDmg("SHEEN",Enemy,myHero) or 0) + (GetInventoryHaveItem(3078) and getDmg("TRINITY",Enemy,myHero) or 0) + (GetInventoryHaveItem(3100) and getDmg("LICHBANE",Enemy,myHero) or 0) + (GetInventoryHaveItem(3025) and getDmg("ICEBORN",Enemy,myHero) or 0) + (GetInventoryHaveItem(3087) and getDmg("STATIKK",Enemy,myHero) or 0) + (GetInventoryHaveItem(3209) and getDmg("SPIRITLIZARD",Enemy,myHero) or 0)
			local onspelldamage = (GetInventoryHaveItem(3151) and getDmg("LIANDRYS",Enemy,myHero) or 0) + (GetInventoryHaveItem(3188) and getDmg("BLACKFIRE",Enemy,myHero) or 0)
			local sunfiredamage = (GetInventoryHaveItem(3068) and getDmg("SUNFIRE",Enemy,myHero) or 0)
			local comboKiller = pdmg + qdmg + wdmg + edmg + rdmg + onhitdmg + onspelldamage + sunfiredamage + idmg + hxgdamage + bwcdamage + botrkdamage
			local killHim = pdmg + onhitdmg + onspelldamage + sunfiredamage + idmg + hxgdamage + bwcdamage + botrkdamage
			local ksKiller = 0
			if QREADY then
				killMana = killMana + myHero:GetSpellData(_Q).mana
				ksMana = ksMana	+ myHero:GetSpellData(_Q).mana
				if GetDistance(Enemy)<=rangeQ then
					killHim = killHim + qdmg
					ksKiller = ksKiller + qdmg
				end
			end
			if WREADY then
				killMana = killMana + myHero:GetSpellData(_W).mana
				ksMana = ksMana	+ myHero:GetSpellData(_W).mana	
				if GetDistance(Enemy)<=rangeW then
					killHim = killHim + wdmg
					ksKiller = ksKiller + wdmg
				end
			end
			if EREADY then
				killMana = killMana + myHero:GetSpellData(_E).mana
				ksMana = ksMana	+ myHero:GetSpellData(_E).mana	
				if GetDistance(Enemy)<=rangeE then
					killHim = killHim + edmg
					ksKiller = ksKiller + edmg
				end
			end
			if RREADY then
				killMana = killMana + myHero:GetSpellData(_R).mana	
				if GetDistance(Enemy)<=rangeR then
					killHim = killHim + rdmg
				end
			end
			if GetInventoryItemIsCastable(3128) then  -- DFG      
				comboKiller = comboKiller + dfgdamage + (comboKiller*0.2)
				killHim = killHim + dfgdamage + (killHim*0.2) 
				if GetInventoryItemIsCastable(3146) then -- Hxg
					comboKiller = comboKiller + (hxgdamage*0.2)
					killHim = killHim + (hxgdamage*0.2)
				end
				if GetInventoryItemIsCastable(3144) then -- bwc
					comboKiller = comboKiller + (bwcdamage*0.2)
					killHim = killHim + (bwcdamage*0.2)
				end
				if GetInventoryItemIsCastable(3153) then -- botrk
					comboKiller = comboKiller + (botrkdamage*0.2)
					killHim = killHim + (botrkdamage*0.2)
				end
			end
			currentTarget = Enemy
			if ksKiller >= currentTarget.health and ksMana <= myHero.mana then
				enemyHeros[i].killable = 4
				if GetDistance(currentTarget) <= killRange then
					if newTarget == nil then
						newTarget = currentTarget
					elseif currentTarget.health < newTarget.health then
						newTarget = currentTarget
					end
					if ValidTarget(newTarget) then
						ksTarget(newTarget)
					end
				end
			elseif killHim >= currentTarget.health and killMana <= myHero.mana then
				enemyHeros[i].killable = 3
				if GetDistance(currentTarget) <= killRange then
					if newTarget == nil then
						newTarget = currentTarget
					elseif currentTarget.health < newTarget.health then
						newTarget = currentTarget
					end
					if ValidTarget(newTarget) then
						killTarget(newTarget)
					end
				end
			elseif comboKiller >= currentTarget.health then
				enemyHeros[i].killable = 2
				if GetDistance(currentTarget) <= killRange then
					if newTarget == nil then
						newTarget = currentTarget
					elseif currentTarget.health < newTarget.health then
						newTarget = currentTarget
					end
					if ValidTarget(newTarget) then
						comboTarget(newTarget)
					end
				end
			else
				enemyHeros[i].killable = 1
				if GetDistance(currentTarget) <= killRange then
					if newTarget == nil then
						newTarget = currentTarget
					elseif currentTarget.health < newTarget.health then
						newTarget = currentTarget
					end
					if ValidTarget(newTarget) then
						harassTarget(newTarget)
					end
				end	
			end
			local rCount = CountEnemyHeroInRange(killRange)
			if rCount >= 1 then
				if GetDistance(Enemy)<=killRange then
					RPos = tpR:GetPrediction(Enemy)
					if RPos then
						if GetDistance(RPos)<GetDistance(Enemy) then
							facing = facing + 1
							if facing>= Config.setUltEnemies then
								if GetDistance(Enemy)<=rangeR then
									CastSpell(_R, Enemy.x, Enemy.z)
								end
							end
						end
						
					end
				end		
			end
		else
			killable = 0
		end
	end
end

function execute()
	if tick == 0 or GetTickCount()-tick>100 then
		Target()
		tick = GetTickCount()
	end
end
function igniteCheck(target)
	if IREADY then
		if ValidTarget(target) then
			if idmg>= target.health and GetDistance(target)< 600 then
				CastSpell(ignite, target)
			end
		end
	else
		return
	end
end
function farmCheck()
	enemyMinion:update()
	if next(enemyMinion.objects)~=nil then
		for j, minion in pairs(enemyMinion.objects) do
			if minion.valid then
				local edamage = getDmg("E", minion, myHero, 3)
				if edamage>=minion.health then
					if Config.autoE then 
						CastE(minion)
					else
						if Config.teamFight then
							CastE(minion)
						end
					end
				end
			else
				table.remove(enemyMinion.objects, j)
			end
		end
	end
end
function harassCheck()
	if ValidTarget(newTarget) then
		if Config.autoE then 
			CastE(newTarget)
		else
			if Config.harass then
				CastE(newTarget)
			end
		end
		if Config.harass then
			CastQ(newTarget)
		end
	end
end
function ksTarget(target)
	if TargetHaveBuff("SummonerDot", target) then
		igniteActive = true
		igniteTick = GetTickCount()
	elseif igniteTick == nil or GetTickCount()-igniteTick>500 then
		igniteActive = false
	end
	if ValidTarget(target) and not igniteActive then
		CastItems(target, true)
		local qdamage = getDmg("Q", target, myHero, 3)
		local wdamage = getDmg("W", target, myHero, 3)
		local edamage = getDmg("E", target, myHero, 3)
		if edamage>=target.health then
			if EREADY and GetDistance(target)<=rangeE then 
				CastSpell(_E, target)
			end
		elseif qdamage>= target.health then
			CastQ(target)	
		elseif wdamage>= target.health then
			if WREADY then
				WPos = tpW:GetPrediction(target)
				if WPos and GetDistance(WPos)<=rangeW then
					CastSpell(_W, WPos.x, WPos.z)
					wTick = GetTickCount()
				end
			end
		else
			if EREADY and GetDistance(target)<=rangeE then 
				CastSpell(_E, target)
			end
			if WREADY then
				WPos = tpW:GetPrediction(target)
				if WPos and GetDistance(WPos)<=rangeW then
					CastSpell(_W, WPos.x, WPos.z)
					wTick = GetTickCount()
				end
			end
			CastQ(target)
		end
	end
end
function killTarget(target)
	if TargetHaveBuff("SummonerDot", target) then
		igniteActive = true
		igniteTick = GetTickCount()
	elseif igniteTick == nil or GetTickCount()-igniteTick>500 then
		igniteActive = false
	end
	if ValidTarget(target) and not igniteActive then
		if Config.autoE then 
			CastE(target)
		else
			if Config.teamFight then
				CastE(target)
			end
		end
		if Config.teamFight then
			CastItems(target, true)
			CastQ(target)
			WPos = tpQ:GetPrediction(target)
			if WPos and GetDistance(WPos)<=rangeW then
				CastSpell(_W, WPos.x, WPos.z)
				wTick = GetTickCount()
			end
			if Config.useUltKillable then
				RPos = tpR:GetPrediction(target)
				if RPos and GetDistance(RPos)<=rangeR then
					CastSpell(_R, RPos.x, RPos.z)
				end
			end
		end
	end
end
function comboTarget(target)
	if ValidTarget(target) then
		if Config.autoE then 
			CastE(target)
		else
			if Config.teamFight then
				CastE(target)
			end
		end
		if Config.teamFight then
			CastItems(target, true)
			CastQ(target)
			WPos = tpQ:GetPrediction(target)
			if WPos and GetDistance(WPos)<=rangeW then
				CastSpell(_W, WPos.x, WPos.z)
				wTick = GetTickCount()
			end
		end
	end
end
function harassTarget(target)
	if ValidTarget(target) then
		if Config.autoE then 
			CastE(target)
		else
			if Config.teamFight then
				CastE(target)
			end
		end
		if Config.teamFight then
			CastItems(target)
			CastQ(target)
			CastW(target)
		end
	end
end
function CastQ(target)
	if not QREADY then return end
	if ValidTarget(target) then
		if GetDistance(target) <= rangeQ and QREADY then
			QPos = tpQ:GetPrediction(target)
			if QPos and GetDistance(QPos)<=rangeQ then
				CastSpell(_Q, QPos.x, QPos.z)
			end
		end
	else
		return
	end
end
function CastW(target)
	if not WREADY then return end
	if ValidTarget(target) then
		if not TargetHaveBuff("cassiopeianoxiousblasthaste", myHero) and not QREADY and GetTickCount()-wTick>=200 then
			if GetDistance(target) <= rangeW and WREADY then
				WPos = tpQ:GetPrediction(target)
				if WPos and GetDistance(WPos)<=rangeW then
					CastSpell(_W, WPos.x, WPos.z)
					wTick = GetTickCount()
				end
			end
		end
	else
		return
	end
end
function CastE(target)
	if not EREADY then return end
	if ValidTarget(target) then
		if GetDistance(target) <= rangeE and EREADY then
			if TargetHaveBuff("cassiopeianoxiousblastpoison", target) or TargetHaveBuff("cassiopeiamiasmapoison", target) then
				CastSpell(_E, target)
			end
		end
	else
		return
	end
end
function CastR(target)
	if not RREADY then return end
	if ValidTarget(target) then
		if GetDistance(target) <= rangeR and RREADY then

		end
	else
		return
	end
end
function CastItems(target, allItems)
	if not ValidTarget(target) then 
		return
	else
		if GetDistance(target) <=800 and allItems == true then
			CastItem(3144, target) --Bilgewater Cutlass
			CastItem(3153, target) --Blade Of The Ruin King
			CastItem(3128, target) --Deathfire Grasp
			CastItem(3146, target) --Hextech Gunblade
			CastItem(3188, target) --Blackfire Torch  
		end
		if GetDistance(target) <= 275 then
			CastItem(3184, target) --Entropy
			CastItem(3143, target) --Randuin's Omen
			CastItem(3074, target) --Ravenous Hydra
			CastItem(3131, target) --Sword of the Devine
			CastItem(3077, target) --Tiamat
			CastItem(3142, target) --Youmuu's Ghostblade
		end
		if GetDistance(target) <= 1000 then
			CastItem(3023, target) --Twin Shadows
		end
	end
end
function orbWalk()
		
	if GetTickCount() > NextShot then
		if ValidTarget(newTarget) then
			if GetDistance(newTarget)<=myHero.range +70 then
				myHero:Attack(newTarget)
			else
				if Config.teamFight and Config.moveToMouse then
					myHero:MoveTo(mousePos.x, mousePos.z)
				end
			end
		elseif not ValidTarget(newTarget) then
			minionRange = false
			enemyMinion:update()
			jungleMinion:update()
			for i, minion in pairs(enemyMinion.objects) do
				if minion.valid then
					if GetDistance(minion)<=myHero.range+70 and Config.teamFight then
						myHero:Attack(minion)
						minionRange = true
					else
						minionRange = false
					end
				end
			end
			for j, minion in pairs(jungleMinion.objects) do
				if minion.valid then
					if GetDistance(minion)<=myHero.range+70 and Config.teamFight then
						myHero:Attack(minion)
						minionRange = true
					else
						minionRange = false
					end
				end
			end
		end
		if not minionRange and not ValidTarget(newTarget) and Config.moveToMouse then
			if Config.teamFight then
				myHero:MoveTo(mousePos.x, mousePos.z)
			end
		end
	elseif GetTickCount() > aaTime then
		if Config.teamFight and Config.moveToMouse then
			myHero:MoveTo(mousePos.x, mousePos.z)
		end
	end
end
function jungleFarm()
	jungleMinion:update()
	if not ValidTarget(newTarget) then
		for j, minion in pairs(jungleMinion.objects) do
			if minion.valid then
				if Config.autoE then 
					CastE(minion)
				else
					if Config.teamFight then
						CastE(minion)
					end
				end
				if Config.teamFight then
					CastQ(minion)
					CastW(minion)
				end
			end
		end
	else
		return
	end
end
function OnDraw()
	if not myHero.dead then
		if ValidTarget(newTarget) and Config.DrawArrow then
			DrawArrows(myHero, newTarget, 30, 0x099B2299, 50)
		end
		if Config.DrawCircles then
			DrawCircle(myHero.x, myHero.y, myHero.z, killRange, ARGB(87,183,60,244))
			if RREADY then
				DrawCircle(myHero.x, myHero.y, myHero.z, rangeR, ARGB(255,255,143,20))
			end
		end
		for i = 1, enemyHerosCount do
			local Enemy = enemyHeros[i].object
			local killable = enemyHeros[i].killable
			if ValidTarget(Enemy) then
				if killable == 4 then
					DrawText3D(tostring("Ks him"),Enemy.x,Enemy.y, Enemy.z,16,ARGB(255,255,10,20), true)
				elseif killable == 3 then
					DrawText3D(tostring("killable"),Enemy.x,Enemy.y, Enemy.z,16,ARGB(255,255,143,20), true)
				elseif killable == 2 then
					DrawText3D(tostring("Combo killer"),Enemy.x,Enemy.y, Enemy.z,16,ARGB(255,248,255,20), true) 
				elseif killable == 1 then
					DrawText3D(tostring("Harass Him"),Enemy.x,Enemy.y, Enemy.z,16,ARGB(255,10,255,20), true)
				else
					DrawText3D(tostring("Not killable"),Enemy.x,Enemy.y, Enemy.z,16,ARGB(244,66,155,255), true)
				end
			end
		end 
	end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") and spell.animationTime then
		aaTime = GetTickCount() + spell.windUpTime * 1000 - GetLatency() / 2 + 10 + 50
		NextShot = GetTickCount() + spell.animationTime * 1000
	end
end

	
	
