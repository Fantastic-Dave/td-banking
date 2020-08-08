--================================================================================================--
--==                                VARIABLES - DO NOT EDIT                                     ==--
--================================================================================================--
ESX                         = nil
inMenu                      = true
local atbank = false
local bankMenu = true
local isbuy = false

function playAnim(animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
	TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

--================================================================================================
--==                                THREADING - DO NOT EDIT                                     ==
--================================================================================================

--===============================================
--==           Base ESX Threading              ==
--===============================================
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--[[Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(5)
        local coords, letSleep  = GetEntityCoords(PlayerPedId()), true
        for k,v in pairs(Config.Bank) do
            if Vdist2(GetEntityCoords(PlayerPedId(), false), v.x, v.y, v.z) < 1 then
                letSleep = false
                DrawText3Ds(v.x, v.y, v.z+0.50, "[E]-Banka")
                if IsControlJustReleased(0,119) then
					openUI()
					exports["aex-bar"]:taskBar(2500, "Kart Veriliyor! ")
		        local ped = GetPlayerPed(-1)
		      TriggerServerEvent('bank:balance')
                end               
            end
        end
        if letSleep then
            Citizen.Wait(1000)
        end
    end
end)]] 


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(data)
    ESX.TriggerServerCallback('td-banking:isbuycreditcard', function(dead)
        isbuy = buy
    end)
end)


function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 425
    DrawRect(_x,_y+0.0125, 0.0002+ factor, 0.025, 0, 0, 0, 50)
end


--===============================================
--==             Core Threading                ==
--===============================================
if bankMenu then
	Citizen.CreateThread(function()
		while true do
			Wait(0)
			--[[if nearBank() or nearATM() then
					DisplayHelpText(_U('atm_open'))

				if IsControlJustPressed(1, 38) then
					openUI()
					TriggerServerEvent('bank:balance')
					local ped = GetPlayerPed(-1)
				end
			end]]--

			--[[if IsControlJustPressed(1, 322) then
				closeUI()
			end--]]
		end
	end)
end

RegisterCommand("atm", function()
	print("komut")
	if nearBank() or nearATM() then
		ESX.TriggerServerCallback("td-banking:creditcontrol", function(var)
			if var then
        print("yakinda")
        ESX.UI.Menu.CloseAll()
        print("closeall")
		 ESX.TriggerServerCallback('td-banking:fetchPassword', function(pass)
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Şifreniz',
        {
          title = "Şifrenizi Girin"
        },
    function(data, menu)
	  menu.close()
	  if data.value == pass then
		openUI()
	else
		print("şifre yanlış")
		exports['mythic_notify']:SendAlert('inform', 'Şifre Yanlış.')
	end
	end)
        
			end)
		elseif not var then
			exports['mythic_notify']:SendAlert('inform', 'Kredi Kartınız Yok.')
		end
		end,"creditcard")
    end
end)

--===============================================
--==             Map Blips	                   ==
--===============================================

--BANK
Citizen.CreateThread(function()
	if Config.ShowBlips then
	  for k,v in ipairs(Config.Bank)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite (blip, v.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.5)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U("bank_blip"))
		EndTextCommandSetBlipName(blip)
	  end
	end
end)

--ATM
Citizen.CreateThread(function()
	if Config.ShowBlips and Config.OnlyBank == false then
	  for k,v in ipairs(Config.ATM)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite (blip, v.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.9)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U("atm_blip"))
		EndTextCommandSetBlipName(blip)
	  end
	end
end)


--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNetEvent('currentbalance1')
AddEventHandler('currentbalance1', function(balance)
	ESX.TriggerServerCallback('new_banking:getCharacterName', function(data)
		local name = data.firstname.. ' ' ..data.lastname
		SendNUIMessage({
			type = "balanceHUD",
			balance = balance,
			player = name
			})
	end)
end)
--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNUICallback('deposit', function(data)
	TriggerServerEvent('bank:deposit', tonumber(data.amount))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==          Withdraw Event                   ==
--===============================================
RegisterNUICallback('withdrawl', function(data)
	TriggerServerEvent('bank:withdraw', tonumber(data.amountw))
	TriggerServerEvent('bank:balance')
end)

RegisterNUICallback('withdrawK', function(data)
	TriggerServerEvent('bank:withdrawK', tonumber(amount))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Balance Event                     ==
--===============================================
RegisterNUICallback('balance', function()
	TriggerServerEvent('bank:balance')
end)

RegisterNetEvent('balance:back')
AddEventHandler('balance:back', function(balance)
	SendNUIMessage({type = 'balanceReturn', bal = balance})
end)


--===============================================
--==         Transfer Event                    ==
--===============================================
RegisterNUICallback('transfer', function(data)
	TriggerServerEvent('bank:transfer', data.to, data.amountt)
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Result   Event                    ==
--===============================================
RegisterNetEvent('bank:result')
AddEventHandler('bank:result', function(type, message)
	SendNUIMessage({type = 'result', m = message, t = type})
end)

--===============================================
--==               NUIFocusoff                 ==
--===============================================
RegisterNUICallback('NUIFocusOff', function()
	closeUI()
end)

AddEventHandler('onResourceStop', function (resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	closeUI()
end)

AddEventHandler('onResourceStart', function (resourceName)
	if(GetCurrentResourceName() ~= resourceName) then
		return
	end
	closeUI()
end)


--===============================================
--==            Capture Bank Distance          ==
--===============================================
function nearBank()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)

	for _, search in pairs(Config.Bank) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)

		if distance <= 3 then
			return true
		end
	end
end

function nearATM()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)

	for _, search in pairs(Config.ATM) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)

		if distance <= 2 then
			return true
		end
	end
end

function closeUI()
	inMenu = false
	SetNuiFocus(false, false)
	if Config.Animation then 
		playAnim('mp_common', 'givetake1_a', Config.AnimationTime)
		exports['progressBars']:startUI(5000, "Kartını alıyorsun")
	end
	SendNUIMessage({type = 'closeAll'})
end

function openUI()
	if (GetCurrentResourceName() == "td-banking") then
		ESX.TriggerServerCallback('new_banking:getCharacterName', function(data)
			if Config.Animation then 
				playAnim('mp_common', 'givetake1_a', Config.AnimationTime)
				Citizen.Wait(Config.AnimationTime)
			end
			inMenu = true
			local name = data.firstname.. ' ' ..data.lastname
			SetNuiFocus(true, true)
			SendNUIMessage({type = 'openGeneral', name = name})
		end)
	else
		exports['mythic_notify']:SendAlert('inform', 'Scriptin ismin td-banking olmalı.')
		print("")
        print("--------------------------------")
        print("Scriptin ismi td-banking olmali.")
        print("--------------------------------")
        print("")
    end
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end




Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(5)
        local coords, letSleep  = GetEntityCoords(PlayerPedId()), true
        for k,v in pairs(Config.BuyCredit) do
            if Vdist2(GetEntityCoords(PlayerPedId(), false), v.x, v.y, v.z) < 1 then
                letSleep = false
                DrawText3Ds(v.x, v.y, v.z+0.50, "[E]-Kredi Kartı")
				if IsControlJustReleased(0,119) then
					ESX.TriggerServerCallback('td-banking:creditcontrol', function(isbuy)
						if  isbuy then
							exports['mythic_notify']:SendAlert('inform', 'Zaten bir kredi kartına sahipsin.')
						else
							TriggerEvent("mythic_progbar:client:progress", {
								name = "creditcard",
								duration = 2000,
								label = "Kredi Kartı Alınıyor",
								useWhileDead = false,
								canCancel = true,
								controlDisables = {
										disableMovement = true,
										disableCarMovement = false,
										disableMouse = false,
										disableCombat = true,
								},
								animation = {
									animDict = "missheistdockssetup1clipboard@idle_a",
						anim = "idle_a",
								},
								prop = {
									model = "prop_notepad_01"	
								}
						}, function(status)
								if not status then
						
								end
						end)
				            local ped = GetPlayerPed(-1)
							isbuy = true
							Citizen.Wait(3500)
							TriggerServerEvent('td-banking:setbuycredit')	
							TriggerServerEvent('td-banking:giveplayerItem')	
							TriggerServerEvent('td-banking:addcreditcardnumber',creditcardnumber)					
						end
					end, "creditcard")
                end               
            end
        end
        if letSleep then
            Citizen.Wait(1000)
        end
    end
end) 





RegisterNetEvent('td-banking:client:start')
AddEventHandler('td-banking:client:start', function(data)

		local ped = PlayerPedId()
	  
		ESX.UI.Menu.CloseAll()
	  
		  local elements      = {}
	  
		table.insert(elements, {label = 'Kredi Kartı', value = "ekle"})	
		table.insert(elements, {label = 'Kapat', value = "kapat"})	
	  
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'td-banking',
			{
			  title    = 'Kredi Kartı İşlemleri',
			  align    = 'top-right',
			  elements = elements,
	  
			}, function(data, menu)
			  menu.close()
	  
				
		 if data.current.value == "kapat" then
	  
			menu.close()
			ClearPedTasks(ped)
			DeleteObject(tab)
	  
		  elseif data.current.value == "ekle" then
			--ESX.TriggerServerCallback('td-banking:fetchCount', function(count)
	  
				menu.close()
	  
		  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'aciklama',
				{
					title = "Kredi Kartı Şifresi"
			},
		   function(data4, menu4)
			
			menu4.close()
			
			local creditpassword = data4.value
	  
				  Citizen.Wait(300)
			TriggerServerEvent("td-banking:addpasword", creditpassword)
			exports['mythic_notify']:SendAlert('inform', 'Kredi Kartı Şifresi Değiştirildi.')
			Wait(1000)
			ClearPedTasks(ped)
	  
			end, function(data4, menu4)
			end)
			menu.close()
			end
		--end)
	end)
end)	  

RegisterCommand('şifrem',function(data,source)
	local sifre = data
	ESX.TriggerServerCallback('td-banking:fetchPassword', function(data)
		exports['mythic_notify']:SendAlert('inform', 'Kredi Kartı Şifren: '..data..'')
		--TriggerEvent('notification', 'Kredi Kartı Şifren: '..data..'')
	end)
end)
		
RegisterCommand('krediknum',function(data,source)
	local sifre = data
	ESX.TriggerServerCallback('td-banking:checknumber', function(data)
		exports['mythic_notify']:SendAlert('inform', 'Kredi Kartı Numaran: '..data..'')
	end)
end)
