ESX = nil
coreLoaded = false

local evim = nil
local evBlip = nil
local evBenim = false
local anahtarNo = ""

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(30)-- Saniye Bekletme
      end
    coreLoaded = true
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    firstLogin()
end)

function firstLogin()
    PlayerData = ESX.GetPlayerData()
    TriggerEvent("almez-houses:ev-ayarla")
end


RegisterNetEvent('almez-houses:ev-ayarla')
AddEventHandler('almez-houses:ev-ayarla', function()
    ESX.TriggerServerCallback("almez-houses:ilg-giris", function(evData)
        local PlayerData = ESX.GetPlayerData()
        evBenim = false
        evim = nil
        if evData == nil then return end
        if evData then
            evim = evData.id
            for x,y in pairs(evData) do
                if x ~= id then
                    if y == PlayerData.identifier then
                        anahtarNo = x
                        if anahtarNo == "anahtar1" then
                            evBenim = true
                        end
                        break
                    end
                end
            end
            evBlipYarat(evler[evim]["coord"]["depo"], "Evin", 40, 3)
        end
    end)
end)

function evBlipYarat(coord, yazi, sprite, renk)
    if evBlip then RemoveBlip(evBlip) end
    evBlip = AddBlipForCoord(coord)
    SetBlipSprite(evBlip, sprite)
    SetBlipColour(evBlip, renk)
    SetBlipAsShortRange(evBlip, true)
    SetBlipScale(evBlip, 0.7)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(yazi)
    EndTextCommandSetBlipName(evBlip)
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

local satinAlNokta = vector3(4.44000, -707.01, 32.4766)
local markerYazi = {
    ["kapi"] = "Kapı",
    ["depo"] = "Depo",
    ["kiyafet"] = "Kıyafet Değiştir",
}

Citizen.CreateThread(function()
    local DepoEv = AddBlipForCoord(vector3(satinAlNokta["x"], satinAlNokta["y"], satinAlNokta["z"]))
    SetBlipSprite(DepoEv, 375)
    SetBlipColour(DepoEv, 2)
    SetBlipAsShortRange(DepoEv, true)
    SetBlipScale(DepoEv, 0.5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Ev ve Market Satış")
    EndTextCommandSetBlipName(DepoEv)

    while true do
        local time = 1000
        local playerPed = PlayerPedId()
        local playerCoord = GetEntityCoords(playerPed)
        if coreLoaded then
            if evim then
                local evData = evler[evim]
                if #(playerCoord - evData.coord.depo) < 100 then
                    for tip, coord in pairs(evData.coord) do
                        local yaziMesafe = #(playerCoord - coord)
                        if yaziMesafe < 30 then
                            time = 1
                            DrawMarker(2, coord.x, coord.y, coord.z-0.65, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.3, 255, 00, 0, 200, false, true, false, false, false, false, false)
                            if yaziMesafe < 3 then
                                local yazi = ""
                                if yaziMesafe < 1 then
                                    yazi = "[E] "
                                    if IsControlJustReleased(0, 38) then
                                        TriggerEvent("almez-houses:e", tip)
                                    end
                                end
                                DrawText3D(coord.x, coord.y, coord.z-0.35, yazi..markerYazi[tip])
                            end
                        end
                    end

                    for kapiNo, coord in pairs(evData.kapilar) do
                        local yaziMesafe = #(playerCoord - coord)
                        if yaziMesafe < 3 then
                            time = 1
                            local kapiData = exports["almez-kapikilit"]:kapidurum(kapiNo)
                            if kapiData then
                                local yazi = ""
                                if yaziMesafe < 1 then
                                    yazi = "[E] "
                                    if IsControlJustReleased(0, 38) then
                                        TriggerEvent("esx_doorlock:ev-kapi", kapiNo)
                                    end
                                end
                            
                                DrawText3D(kapiData.coord.x, kapiData.coord.y, kapiData.coord.z, yazi..kapiData.durum)
                            else
                                print("[almez-houses] Kapi Data Yok!")
                            end
                        end
                    end
                end
            end

            local yaziMesafe = #(playerCoord - satinAlNokta)
            if yaziMesafe < 20 then
                time = 1
                DrawMarker(2, satinAlNokta.x, satinAlNokta.y, satinAlNokta.z-0.65, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.3, 255, 00, 0, 200, false, true, false, false, false, false, false)
                if yaziMesafe < 3 then
                    if yaziMesafe < 1 then
                        yazi = "[E] "
                        if IsControlJustReleased(0, 38) then
                            menuAc()
                        end
                    end
                    DrawText3D(4.44000, -707.01, 32.12, "[E] Ev Satın Al")
                end
            end

        end
        Citizen.Wait(time)
    end
end)

DrawText3D = function(x, y, z, text)
	SetTextScale(0.30, 0.30)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 250
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent('almez-houses:e')
AddEventHandler('almez-houses:e', function(tip)
    if tip == "depo" then
        TriggerEvent("inventory:client:SetCurrentStash", "TEv_"..tostring(evim))
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "TEv_"..tostring(evim), {
            maxweight = 4000000,
            slots = 500,
        })
    elseif tip == "kiyafet" then
        TriggerEvent("qb-clothing:client:openOutfitMenu")
    end
end)

function menuAc()
    if evim then
        evimMenu()
    else
        satilikEvler()
    end
end



function satilikEvler()
    local elements = {}
    for i=1, #evler do
        table.insert(elements, {label = evler[i].isim.."("..i..") $"..evler[i].fiyat, value = i, fiyat = evler[i].fiyat})
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'evSatinAlMenu', {
        title    = 'Satılık Evler',
        align    = 'left',
        elements = elements
    }, function(data2, menu2)
        if data2.current.value then
            -- Soru Menu
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'evSoruMenu', {
                title    = 'Satın Almak İstediğine Emin misin? <div style="font-size:18px; padding-bottom:5px">?</div>',
                align    = 'left',
                elements = {
                    {label = "Hayır", value = "no"},
                    {label = "Evet", value = "yes"},
                }
            }, function(data3, menu3)
                if data3.current.value == "yes" then
                    TriggerServerEvent("almez-houses:satin-al", data2.current.value, data2.current.fiyat)
                    ESX.UI.Menu.CloseAll()
                else
                    menu3.close()
                end
            end,function(data3, menu3)
                menu3.close()
            end)

        end
    end,function(data2, menu2)
        menu2.close()
    end)
end

function evimMenu()
    if evBenim then
        local evSatFiyat = evler[evim].fiyat * 0.5
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'evimMenu', {
            title    = 'Evim',
            align    = 'left',
            elements = {
                {label = "Anahtarı Değiştir", value = "anahtar"},
                {label = "Yakınındakine Anahtar Ver", value = "ver"},
                {label = "Evi Sat $"..evSatFiyat, value = "sat", fiyat = evSatFiyat},
            }
        }, function(data, menu)
            if data.current.value == "anahtar" then
                -- Anahtar Sıfırlama
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'evSatSoruMenu', {
                    title    = 'Evinin Anahtarını Değiştirmek İstediğine Emin misin?',
                    align    = 'left',
                    elements = {
                        {label = "Hayır", value = "no"},
                        {label = "Evet", value = "yes"},
                    }
                }, function(data2, menu2)
                    if data2.current.value == "yes" then
                        TriggerServerEvent("almez-houses:anahtar-degis", evim)
                    end
                    menu2.close()
                end,function(data2, menu2)
                    menu2.close()
                end)

            elseif data.current.value == "ver" then
                local player, distance = ESX.Game.GetClosestPlayer()
                if distance ~= -1 and distance <= 3.0 then
                    TriggerServerEvent("almez-houses:anahtar-ver", GetPlayerServerId(player), evim)
                else
                    TriggerEvent('Notification', "Yakınlarda Kimse Yok")
                end

            elseif data.current.value == "sat" then
                -- Ev Sat Soru Menu
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'evSatSoruMenu', {
                    title    = 'Evini Satmak İstediğine Emin misin?',
                    align    = 'left',
                    elements = {
                        {label = "Hayır", value = "no"},
                        {label = "Evet", value = "yes"},
                    }
                }, function(data2, menu2)
                    if data2.current.value == "yes" then
                        TriggerServerEvent("almez-houses:sat", data.current.fiyat, evim)
                        TriggerEvent("almez-houses:sifirla")
                        ESX.UI.Menu.CloseAll()
                    else
                        menu2.close()
                    end
                end,function(data2, menu2)
                    menu2.close()
                end)
            end
        end,function(data, menu)
            menu.close()
        end)
    else
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'evAnahtarBirak', {
            title    = 'Evim',
            align    = 'left',
            elements = {{label = "Evin Anahtarını Bırak", value = "abirak"}}
        }, function(data, menu)
            if data.current.value then
                -- Soru Menu
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'evSoruMenu', {
                    title    = 'Sahip Olduğun Evin Anaharını Bırakmak İstediğine Eminmisin',
                    align    = 'left',
                    elements = {
                        {label = "Hayır", value = "no"},
                        {label = "Evet", value = "yes"},
                    }
                }, function(data2, menu2)
                    if data2.current.value == "yes" then
                        TriggerServerEvent("almez-houses:anahtar-birak", evim, anahtarNo)
                        ESX.UI.Menu.CloseAll()
                    else
                        menu2.close()
                    end
                end,function(data2, menu2)
                    menu2.close()
                end)
    
            end
        end,function(data, menu)
            menu.close()
        end)
    end
end

local goster = false
local blips = {}
RegisterCommand("evler", function()
    satilanEvler()
end)

function satilanEvler()
    if not goster then
        for k, v in pairs(evler) do
            CreateBlip(v['coord']["depo"], 374, 0, 0.45, '')
        end
        TriggerEvent('Notification', 'Haritada Evler Açıldı')
    else
        for k, v in pairs(blips) do
            RemoveBlip(v)
        end
        blips = {}
        TriggerEvent('Notification', 'Haritada Evler Kapatıldı')
    end
    goster = not goster
end

function CreateBlip(coords, sprite, colour, scale, text)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    table.insert(blips, blip)
end

RegisterNetEvent('almez-houses:sifirla')
AddEventHandler('almez-houses:sifirla', function()
    evim = nil
end)