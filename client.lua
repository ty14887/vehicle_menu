-- client.lua (使用 lib.registerMenu，完全支援 function callback)

local currentVehicle = nil

-- ══════════════════════════════════════════════════════════════
--  工具函式
-- ══════════════════════════════════════════════════════════════

local function loadModel(model)
    local hash = type(model) == 'number' and model or GetHashKey(model)
    if not IsModelValid(hash) then
        lib.notify({ title = '錯誤', description = '無效模型: ' .. tostring(model), type = 'error' })
        return nil
    end
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) do
        Citizen.Wait(100)
        timeout += 100
        if timeout > 10000 then
            lib.notify({ title = '錯誤', description = '模型載入逾時', type = 'error' })
            return nil
        end
    end
    return hash
end

local function deleteCurrentVehicle()
    if currentVehicle and DoesEntityExist(currentVehicle) then
        TriggerServerEvent('vmenu:deleteVehicle', NetworkGetNetworkIdFromEntity(currentVehicle))
        currentVehicle = nil
    end
end

local function spawnVehicle(model)
    local hash = loadModel(model)
    if not hash then return end
    deleteCurrentVehicle()
    local ped     = PlayerPedId()
    local coords  = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local veh     = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleNumberPlateText(veh, 'SERVER')
    SetEntityAsMissionEntity(veh, true, true)
    NetworkRegisterEntityAsNetworked(veh)
    TaskWarpPedIntoVehicle(ped, veh, -1)
    currentVehicle = veh
    lib.notify({ title = '車輛生成', description = model .. ' 已生成', type = 'success', duration = 3000 })
end

local function getVeh()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    return (DoesEntityExist(veh) and veh ~= 0) and veh or nil
end

-- ══════════════════════════════════════════════════════════════
--  改裝選單
-- ══════════════════════════════════════════════════════════════

local function openTuningMenu()
    local veh = getVeh()
    if not veh then
        lib.notify({ title = '改裝', description = '需坐在車上', type = 'error' }) return
    end
    SetVehicleModKit(veh, 0)

    local tuningMods = {
        { label = '前保險桿', modIndex = 0  },
        { label = '後保險桿', modIndex = 1  },
        { label = '側裙',     modIndex = 2  },
        { label = '排氣管',   modIndex = 3  },
        { label = '車架',     modIndex = 4  },
        { label = '格柵',     modIndex = 5  },
        { label = '引擎蓋',   modIndex = 6  },
        { label = '左翼子板', modIndex = 7  },
        { label = '右翼子板', modIndex = 8  },
        { label = '後擾流板', modIndex = 9  },
        { label = '車頂',     modIndex = 10 },
        { label = '車窗',     modIndex = 17 },
        { label = '車燈',     modIndex = 22 },
        { label = '後視鏡',   modIndex = 23 },
    }

    local options = {}
    local indexMap = {}   -- options 的位置 → modIndex

    for _, mod in ipairs(tuningMods) do
        local count = GetNumVehicleMods(veh, mod.modIndex)
        if count > 0 then
            local current = GetVehicleMod(veh, mod.modIndex)
            local values = {}
            for i = -1, count - 1 do
                values[#values + 1] = i == -1 and '無' or ('套件 ' .. (i + 1))
            end
            options[#options + 1] = {
                label        = mod.label,
                description  = ('共 %d 個套件'):format(count),
                values       = values,
                defaultIndex = current + 2,  -- -1 → index 1, 0 → index 2 ...
                close        = false,
            }
            indexMap[#options] = { modIndex = mod.modIndex, offset = -1 }
        end
    end

    if #options == 0 then
        lib.notify({ title = '外觀改裝', description = '此車無可用套件', type = 'inform' }) return
    end

    lib.registerMenu({
        id       = 'vmenu_tuning',
        title    = '🎨 外觀改裝',
        position = 'top-left',
        options  = options,
    }, function(selected, scrollIndex, args)
        local info = indexMap[selected]
        if not info then return end
        local modValue = scrollIndex - 2 + info.offset + 1
        -- scrollIndex 1 = '無'(-1), 2 = 套件0, 3 = 套件1 ...
        local realValue = scrollIndex - 2  -- -1=無, 0=套件1...
        SetVehicleMod(veh, info.modIndex, realValue, false)
    end)
    lib.showMenu('vmenu_tuning')
end

local function openPerformanceMenu()
    local veh = getVeh()
    if not veh then
        lib.notify({ title = '改裝', description = '需坐在車上', type = 'error' }) return
    end
    SetVehicleModKit(veh, 0)

    -- Level mods
    local levelMods = {
        { label = '引擎',   modIndex = 11 },
        { label = '變速箱', modIndex = 13 },
        { label = '煞車',   modIndex = 12 },
        { label = '懸吊',   modIndex = 15 },
    }
    -- Toggle mods
    local toggleMods = {
        { label = '渦輪增壓', modIndex = 18 },
        { label = '氮氣加速', modIndex = 63 },
        { label = '防彈輪胎', modIndex = 69 },
    }

    local options  = {}
    local modInfos = {}

    for _, mod in ipairs(levelMods) do
        local count = GetNumVehicleMods(veh, mod.modIndex)
        if count > 0 then
            local current = GetVehicleMod(veh, mod.modIndex)
            local values = { '無' }
            for i = 0, count - 1 do values[#values + 1] = '等級 ' .. (i + 1) end
            options[#options + 1] = {
                label        = mod.label,
                values       = values,
                defaultIndex = current + 2,
                close        = false,
            }
            modInfos[#options] = { kind = 'level', modIndex = mod.modIndex }
        end
    end

    for _, mod in ipairs(toggleMods) do
        local isOn = IsToggleModOn(veh, mod.modIndex)
        options[#options + 1] = {
            label        = mod.label,
            values       = { '關閉', '開啟' },
            defaultIndex = isOn and 2 or 1,
            close        = false,
        }
        modInfos[#options] = { kind = 'toggle', modIndex = mod.modIndex }
    end

    if #options == 0 then
        lib.notify({ title = '性能改裝', description = '此車無可用改裝', type = 'inform' }) return
    end

    lib.registerMenu({
        id       = 'vmenu_performance',
        title    = '⚙️ 性能改裝',
        position = 'top-left',
        options  = options,
    }, function(selected, scrollIndex, args)
        local info = modInfos[selected]
        if not info then return end
        SetVehicleModKit(veh, 0)
        if info.kind == 'level' then
            local realValue = scrollIndex - 2  -- 1='無'→-1, 2='等級1'→0
            SetVehicleMod(veh, info.modIndex, realValue, false)
        elseif info.kind == 'toggle' then
            ToggleVehicleMod(veh, info.modIndex, scrollIndex == 2)
        end
    end)
    lib.showMenu('vmenu_performance')
end

local function openModMenu()
    local veh = getVeh()
    if not veh then
        lib.notify({ title = '改裝', description = '需坐在車上', type = 'error' }) return
    end
    lib.registerMenu({
        id       = 'vmenu_mod',
        title    = '🔧 車輛改裝',
        position = 'top-left',
        options  = {
            { label = '⚙️ 性能改裝', description = '引擎 / 煞車 / 懸吊 / 渦輪 / 氮氣 / 防彈輪胎' },
            { label = '🎨 外觀改裝', description = '保險桿 / 側裙 / 擾流板 / 引擎蓋 ...' },
        },
    }, function(selected)
        if selected == 1 then openPerformanceMenu()
        elseif selected == 2 then openTuningMenu()
        end
    end)
    lib.showMenu('vmenu_mod')
end

-- ══════════════════════════════════════════════════════════════
--  車輛生成選單
-- ══════════════════════════════════════════════════════════════

local function openVehicleList(title, vehicleList, backId)
    local options = {}
    for _, v in ipairs(vehicleList) do
        options[#options + 1] = { label = v.label, description = v.model }
    end
    lib.registerMenu({
        id       = 'vmenu_vehlist',
        title    = title,
        position = 'top-left',
        options  = options,
    }, function(selected)
        spawnVehicle(vehicleList[selected].model)
    end)
    lib.showMenu('vmenu_vehlist')
end

local function openCategoryMenu()
    local options = {
        { label = '⭐ Addon 模組車', description = '伺服器自訂安裝車輛' }
    }
    for _, cat in ipairs(Config.NativeVehicles) do
        options[#options + 1] = { label = cat.label }
    end
    lib.registerMenu({
        id       = 'vmenu_category',
        title    = '🚗 選擇車輛分類',
        position = 'top-left',
        options  = options,
    }, function(selected)
        if selected == 1 then
            openVehicleList('⭐ Addon 模組車', Config.AddonVehicles, 'vmenu_category')
        else
            local cat = Config.NativeVehicles[selected - 1]
            openVehicleList(cat.label, cat.vehicles, 'vmenu_category')
        end
    end)
    lib.showMenu('vmenu_category')
end

-- ══════════════════════════════════════════════════════════════
--  主選單
-- ══════════════════════════════════════════════════════════════

local function openMainMenu()
    lib.registerMenu({
        id       = 'vmenu_main',
        title    = '🚘 車輛選單',
        position = 'top-left',
        options  = {
            { label = '🚗 生成車輛',      description = '依分類瀏覽並生成車輛'         },
            { label = '🔧 改裝車輛',      description = '性能 & 外觀改裝（需坐在車上）' },
            { label = '🩹 修車',          description = '修復車輛至全滿（需坐在車上）'  },
            { label = '🚿 洗車',          description = '清潔車輛外觀（需坐在車上）'    },
            { label = '🗑️ 刪除當前車輛', description = '移除你生成的車輛'              },
        },
    }, function(selected)
        if selected == 1 then
            openCategoryMenu()

        elseif selected == 2 then
            openModMenu()

        elseif selected == 3 then
            local veh = getVeh()
            if not veh then lib.notify({ title = '修車', description = '需坐在車上', type = 'error' }) return end
            SetVehicleFixed(veh)
            SetVehicleDeformationFixed(veh)
            SetVehicleEngineHealth(veh, 1000.0)
            SetVehicleBodyHealth(veh, 1000.0)
            lib.notify({ title = '修車', description = '車輛已修復 🩹', type = 'success', duration = 3000 })

        elseif selected == 4 then
            local veh = getVeh()
            if not veh then lib.notify({ title = '洗車', description = '需坐在車上', type = 'error' }) return end
            SetVehicleDirtLevel(veh, 0.0)
            lib.notify({ title = '洗車', description = '車輛已洗乾淨 🚿', type = 'success', duration = 3000 })

        elseif selected == 5 then
            deleteCurrentVehicle()
            lib.notify({ title = '車輛', description = '車輛已刪除', type = 'inform', duration = 2000 })
        end
    end)
    lib.showMenu('vmenu_main')
end

-- ══════════════════════════════════════════════════════════════
--  指令 & 快捷鍵
-- ══════════════════════════════════════════════════════════════

RegisterCommand(Config.Command, function()
    openMainMenu()
end, false)

RegisterKeyMapping(Config.Command, '開啟車輛選單', 'keyboard', 'F5')
