ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('almez-houses:satin-al')
AddEventHandler('almez-houses:satin-al', function(id, fiyat)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    exports.ghmattimysql:execute("SELECT * FROM almez_houses WHERE (identifier = @identifier OR anahtar1 = @identifier OR anahtar2 = @identifier OR anahtar3 = @identifier OR anahtar4 = @identifier)", {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            TriggerEvent('Notification', 'Zaten Bir Depo Evin Var.')
        else
            exports.ghmattimysql:execute("SELECT * FROM almez_houses WHERE id = @id", {
                ['@identifier'] = identifier
            }, function(result2)
                if not result2[1] then
                    if xPlayer.getAccount('bank').money >= fiyat then
                        xPlayer.removeAccountMoney('bank', fiyat)
                        exports.ghmattimysql:scalarSync("INSERT INTO almez_houses (id, identifier, anahtar1) VALUES (@id, @identifier, @anahtar1)", {
                            ['id'] = id, 
                            ['anahtar1'] = xPlayer.identifier,
                            ['identifier'] = xPlayer.identifier
                         })
                        TriggerEvent('Notification',  'Depo Ev Satın Alındı.')
                    else
                        TriggerEvent('Notification', 'Bankanda Yeterli Para Yok.')
                    end
                else
                    TriggerEvent('Notification', 'Bu Ev Başka Birine Ait')
                end
            end)  
        end
    end)

    Citizen.Wait(1500)
    TriggerClientEvent('almez-houses:ev-ayarla', xPlayer.source)
end)

RegisterServerEvent("almez-houses:anahtar-ver")
AddEventHandler("almez-houses:anahtar-ver", function(player, id)
    local src = source
    local xpl = ESX.GetPlayerFromId(source)
    local zpl = ESX.GetPlayerFromId(player)

    if xpl then
        exports.ghmattimysql:execute("SELECT * FROM almez_houses WHERE (identifier = @identifier OR anahtar1 = @identifier OR anahtar2 = @identifier OR anahtar3 = @identifier OR anahtar4 = @identifier)", {
            ['@identifier'] = zpl.identifier
        }, function(result)
            if result[1] then
              TriggerEvent('Notification','Kişinin Bir Evi Var Zaten.')
            else
                exports.ghmattimysql:execute("SELECT * FROM almez_houses WHERE id= @id", {
                    ['@id'] = id
                }, function(result)
                    if result[1] then
                        if result[1].anahtar1 == nil and result[1].anahtar1 ~= zpl.identifier then
                            givekeys(id, "UPDATE almez_houses SET anahtar1 = @anahtar WHERE id = @id", zpl.identifier)
                            TriggerEvent('Notification','Anahtar Yakındaki Kişiye Verildi.')
                            TriggerClientEvent("almez-houses:ev-ayarla", zpl.source)
                        elseif result[1].anahtar2 == nil and result[1].anahtar1 ~= zpl.identifier then
                            givekeys(id, "UPDATE almez_houses SET anahtar2 = @anahtar WHERE id = @id", zpl.identifier)
                            TriggerEvent('Notification','Anahtar Yakındaki Kişiye Verildi.') 
                            TriggerClientEvent("almez-houses:ev-ayarla", zpl.source)      
                        elseif result[1].anahtar3 == nil and result[1].anahtar1 ~= zpl.identifier then
                            givekeys(id, "UPDATE almez_houses SET anahtar3 = @anahtar WHERE id = @id", zpl.identifier)
                            TriggerEvent('Notification','Anahtar Yakındaki Kişiye Verildi.')
                            TriggerClientEvent("almez-houses:ev-ayarla", zpl.source)
                        elseif result[1].anahtar4 == nil and result[1].anahtar1 ~= zpl.identifier then
                            givekeys(id, "UPDATE almez_houses SET anahtar4 = @anahtar WHERE id = @id", zpl.identifier)
                            TriggerEvent('Notification','Anahtar Yakındaki Kişiye Verildi.')
                            TriggerClientEvent("almez-houses:ev-ayarla", zpl.source)
                        else
                            TriggerEvent('Notification','Verebilecek Başka Anahtarın Yok veya Kişinin Zaten Anahtarı Var!')
                        end                  
                    end
                end)
            end
        end)
    end
end)

RegisterServerEvent("almez-houses:anahtar-degis")
AddEventHandler("almez-houses:anahtar-degis", function(evim)


end)

RegisterServerEvent('almez-houses:sat')
AddEventHandler('almez-houses:sat', function(fiyat, id)
    local src = source
    local xpl = ESX.GetPlayerFromId(src)
    if xpl then
        xpl.addAccountMoney('bank', fiyat)
        TriggerEvent('Notification','Depo Ev satıldı', "success", 5000)
        exports.ghmattimysql:scalar("DELETE FROM almez_houses WHERE id = @id", {
            ['@id'] = id
            }) 
        TriggerClientEvent("almez-houses:ev-ayarla", xpl.source)
    end 
end)

RegisterServerEvent("almez-houses:anahtar-birak")
AddEventHandler("almez-houses:anahtar-birak", function(id, tip)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if tip == "anahtar" then
    if xPlayer then
         exports.ghmattimysql:execute("SELECT * FROM almez_houses WHERE id = @id", {
             ['@id'] = id
        }, function(result)
            if result[1] then
                if result[1].anahtar1 == xPlayer.identifier then
                    givekeys(id, "UPDATE almez_houses SET anahtar1 = @anahtar WHERE id = @id", nil)
                    TriggerEvent('Notification', 'Anahtarı Geri Verdin.')
                    TriggerClientEvent("almez-houses:ev-ayarla", xPlayer.source)
                elseif result[1].anahtar2 == xPlayer.identifier then
                    givekeys(id, "UPDATE almez_houses SET anahtar2 = @anahtar WHERE id = @id", nil)
                    TriggerEvent('Notification', 'Anahtarı Geri Verdin.')
                    TriggerClientEvent("almez-houses:ev-ayarla", xPlayer.source)
                elseif result[1].anahtar3 == xPlayer.identifier then
                    givekeys(id, "UPDATE almez_houses SET anahtar3 = @anahtar WHERE id = @id", nil)
                    TriggerEvent('Notification', 'Anahtarı Geri Verdin.')
                    TriggerClientEvent("almez-houses:ev-ayarla", xPlayer.source)
                elseif result[1].anahtar4 == xPlayer.identifier then
                    givekeys(id, "UPDATE almez_houses SET anahtar4 = @anahtar WHERE id = @id", nil)
                    TriggerEvent('Notification', 'Anahtarı Geri Verdin.')
                    TriggerClientEvent("almez-houses:ev-ayarla", xPlayer.source)
                end
            end
        end)
    end 
end
if tip == "sahip" then
    exports.ghmattimysql:scalar("UPDATE almez_houses SET anahtar1 = @anahtar, anahtar2 = @anahtar, anahtar3 = @anahtar, anahtar4 = @anahtar WHERE id = @id",{
        ["@id"] = id,
        ["@anahtar"] = nil
    })
    TriggerClientEvent("almez-houses:ev-ayarla", xPlayer.source)
    TriggerEvent('Notification', 'Anahtar bilgileri silindi!')
end
end)

function givekeys(id, sorgu, identifier)
    exports.ghmattimysql:scalar(sorgu, {
        ['@id'] = id, 
        ['@anahtar'] = identifier
    })
end


evData = {}

ESX.RegisterServerCallback('almez-houses:ilg-giris', function(source, cb, evData)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    evData = nil
    exports.ghmattimysql:execute("SELECT * FROM almez_houses WHERE (identifier = @identifier OR anahtar1 = @identifier OR anahtar2 = @identifier OR anahtar3 = @identifier OR anahtar4 = @identifier)", {
        ['@identifier'] = xPlayer.identifier
    }, function(evData)
        if json.encode(evData) ~= "[]" then
            cb(evData[1])
            TriggerEvent('Notification', 'Ev bilgisi başarılı bir şekilde çekildi.')
        else
            cb(false)
            TriggerEvent('Notification', 'Çadır bilgisi başarılı bir şekilde çekildi.')
        end
    end)
end)