-- ================================================================================================--
-- ==                                VARIABLES - DO NOT EDIT                                     ==--
-- ================================================================================================--
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('bank:deposit')
AddEventHandler('bank:deposit', function(amount)
    local _source = source

    local xPlayer = ESX.GetPlayerFromId(_source)
    if amount == nil or amount <= 0 then
        TriggerClientEvent('chatMessage', _source, _U('invalid_amount'))
    else
        if amount > xPlayer.getMoney() then
            amount = xPlayer.getMoney()
        end
        xPlayer.removeMoney(amount)
        xPlayer.addAccountMoney('bank', tonumber(amount))
    end
end)

RegisterServerEvent('bank:withdraw')
AddEventHandler('bank:withdraw', function(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local base = 0
    amount = tonumber(amount)
    base = xPlayer.getAccount('bank').money
    if amount == nil or amount <= 0 then
        TriggerClientEvent('chatMessage', _source, _U('invalid_amount'))
    else
        if amount > base then
            amount = base
        end
        xPlayer.removeAccountMoney('bank', amount)
        xPlayer.addMoney(amount)
    end
end)

RegisterServerEvent('bank:withdrawK')
AddEventHandler('bank:withdrawK', function(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local base = 0

    amount = tonumber(200)
    base = xPlayer.getAccount('bank').money
        if amount > base then
            amount = base
        end
        xPlayer.removeAccountMoney('bank', 200)
        xPlayer.addMoney(200)
end)

RegisterServerEvent('bank:balance')
AddEventHandler('bank:balance', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    balance = xPlayer.getAccount('bank').money
    TriggerClientEvent('currentbalance1', _source, balance)

end)

RegisterServerEvent('bank:transfer')
AddEventHandler('bank:transfer', function(to, amountt)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local zPlayer = ESX.GetPlayerFromId(to)
    local balance = 0
    if zPlayer ~= nil then
        balance = xPlayer.getAccount('bank').money
        zbalance = zPlayer.getAccount('bank').money
        if tonumber(_source) == tonumber(to) then
            -- advanced notification with bank icon
            TriggerClientEvent('esx:showAdvancedNotification', _source, 'Bank',
                               'Transfer Money',
                               'You cannot transfer to your self!',
                               'CHAR_BANK_MAZE', 9)
        else
            if balance <= 0 or balance < tonumber(amountt) or tonumber(amountt) <=
                0 then
                -- advanced notification with bank icon
                TriggerClientEvent('esx:showAdvancedNotification', _source,
                                   'Bank', 'Transfer Money',
                                   'Not enough money to transfer!',
                                   'CHAR_BANK_MAZE', 9)
            else
                xPlayer.removeAccountMoney('bank', tonumber(amountt))
                zPlayer.addAccountMoney('bank', tonumber(amountt))
                -- advanced notification with bank icon
                TriggerClientEvent('esx:showAdvancedNotification', _source,
                                   'Bank', 'Transfer Money',
                                   'You transfered ~r~$' .. amountt ..
                                       '~s~ to ~r~' .. to .. ' .',
                                   'CHAR_BANK_MAZE', 9)
                TriggerClientEvent('esx:showAdvancedNotification', to, 'Bank',
                                   'Transfer Money', 'You received ~r~$' ..
                                       amountt .. '~s~ from ~r~' .. _source ..
                                       ' .', 'CHAR_BANK_MAZE', 9)
            end

        end
    end

end)


ESX.RegisterUsableItem('creditcard', function(source)

	local _source = source
  TriggerClientEvent("td-banking:client:start", _source)

end)




ESX.RegisterServerCallback('new_banking:getCharacterName', function(source, cb)
    local identifier = GetPlayerIdentifiers(source)[1]
    print(identifier)
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier=@identifier', {
        ['@identifier'] = identifier
    }, function(result)
        cb({firstname = result[1].firstname, lastname = result[1].lastname})
    end)
end)


  
ESX.RegisterServerCallback('td-banking:isbuycreditcard', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT buycredit FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        local buycredit = result[1].buycredit
         cb(buycredit)
    end)
end)


RegisterServerEvent('td-banking:setbuycredit')
AddEventHandler('td-banking:setbuycredit', function(isbuy)
    local player = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('UPDATE users SET buycredit = @buycredit WHERE identifier = @identifier', {
        ['@buycredit'] = isbuy,
        ['@identifier'] = player.identifier
    })
end)

  RegisterServerEvent('td-banking:addcreditcardnumber')
  AddEventHandler('td-banking:addcreditcardnumber', function(creditcardnumber)
	local xPlayer = ESX.GetPlayerFromId(source)
        local numBase0 = math.random(100,999)
        local numBase1 = math.random(0,9999)
        local num = string.format("%03d%04d", numBase0, numBase1 )
    

		MySQL.Async.execute('UPDATE users SET creditcardnumber = @creditcardnumber WHERE identifier = @identifier', {
            ['@creditcardnumber'] = num,
            ['@identifier'] = xPlayer.identifier
		})
end)

RegisterNetEvent('td-banking:giveplayerItem')
AddEventHandler('td-banking:giveplayerItem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.canCarryItem("creditcard", 1) then
    xPlayer.addInventoryItem('creditcard', 1)
    else
        xPlayer.showNotification("Envanterinde yeterince yer yok.")
    end
end)


ESX.RegisterServerCallback("td-banking:creditcontrol", function(source, cb, itemname)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(itemname)["count"]

    if item >= 1 then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('td-banking:addpasword')
AddEventHandler('td-banking:addpasword', function(creditpassword)
  local xPlayer = ESX.GetPlayerFromId(source)
      MySQL.Async.execute('UPDATE users SET creditpassword = @creditpassword WHERE identifier = @identifier', {
          ['@creditpassword'] = creditpassword,
          ['@identifier'] = xPlayer.identifier
      })
end)

ESX.RegisterServerCallback('td-banking:fetchPassword', function(source, cb)
    local player = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT creditpassword FROM users WHERE identifier = @identifier',  {
        ['@identifier'] = player.identifier
    }, function(result)
        local password = result[1].creditpassword
        cb(password)
    end)
end)

ESX.RegisterServerCallback('td-banking:checknumber', function(source, cb)
    local player = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT creditcardnumber FROM users WHERE identifier = @identifier',  {
        ['@identifier'] = player.identifier
    }, function(result)
        local creditcardnumber = result[1].creditcardnumber
        cb(creditcardnumber)
    end)
end)

-- ESX.RegisterServerCallback('td-banking:fetchCount', function(source, cb)
--     local player = ESX.GetPlayerFromId(source)

--     MySQL.Async.fetchAll('SELECT changecount FROM users WHERE identifier = @identifier',  {
--         ['@identifier'] = player.identifier
--     }, function(result)
--         local changecount = result[1].changecount
--         cb(changecount)
--     end)
-- end)

