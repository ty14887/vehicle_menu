-- client.lua
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
--  動態讀取 mod 部位名稱
--  直接從遊戲 label 讀，確保和實際改裝部位一致
-- ══════════════════════════════════════════════════════════════

-- 每個 modIndex 的英文備用名（遊戲 label 讀不到時用）
local MOD_FALLBACK = {
    [0]='前保險桿',[1]='後保險桿',[2]='側裙',[3]='排氣管',
    [4]='車架',[5]='格柵',[6]='引擎蓋',[7]='左翼子板',
    [8]='右翼子板',[9]='後擾流板',[10]='車頂',[11]='引擎',
    [12]='煞車',[13]='變速箱',[14]='喇叭',[15]='懸吊',
    [16]='裝甲',[17]='車窗',[18]='渦輪增壓',[22]='車燈',
    [23]='後視鏡',[24]='輪圈',[25]='後輪圈',[27]='輪胎',
    [48]='引擎聲音',
}

local function getModSlotName(veh, modIndex)
    -- GetModTextLabel 回傳這個 slot 對應的 label key
    local key = GetModTextLabel(veh, modIndex)
    if key and key ~= '' and key ~= 'NULL' then
        local text = GetLabelText(key)
        if text and text ~= '' and text ~= 'NULL' then
            return text
        end
    end
    return MOD_FALLBACK[modIndex] or ('Mod ' .. modIndex)
end

-- ══════════════════════════════════════════════════════════════
--  外觀改裝選單（動態掃描，名稱直接從遊戲讀）
-- ══════════════════════════════════════════════════════════════

local function openTuningMenu()
    local veh = getVeh()
    if not veh then
        lib.notify({ title = '改裝', description = '需坐在車上', type = 'error' }) return
    end
    SetVehicleModKit(veh, 0)

    -- 跳過性能/toggle 槽，只掃外觀槽 0~23
    local skipSlots = { [11]=true,[12]=true,[13]=true,[15]=true,[18]=true }

    local options  = {}
    local slotList = {}  -- 對應 options 順序的 modIndex

    for modIndex = 0, 23 do
        if not skipSlots[modIndex] then
            local count = GetNumVehicleMods(veh, modIndex)
            if count > 0 then
                local slotName = getModSlotName(veh, modIndex)
                local current  = GetVehicleMod(veh, modIndex)

                local values = { '無' }
                for i = 0, count - 1 do
                    values[#values + 1] = '套件 ' .. (i + 1)
                end

                options[#options + 1] = {
                    label        = slotName,
                    description  = ('共 %d 個套件 | 目前: %s'):format(
                        count,
                        current >= 0 and ('套件 ' .. (current + 1)) or '無'
                    ),
                    values       = values,
                    defaultIndex = current + 2,  -- -1→idx1, 0→idx2, 1→idx3...
                    close        = false,
                }
                slotList[#slotList] = modIndex  -- 注意：這裡用 #slotList 已是 #options-1，修正如下
                slotList[#options]  = modIndex
            end
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
    }, function(selected, scrollIndex)
        local modIndex = slotList[selected]
        if not modIndex then return end
        -- scrollIndex 1 = '無' → SetVehicleMod(..., -1)
        -- scrollIndex 2 = '套件1' → SetVehicleMod(..., 0)
        local realValue = scrollIndex - 2
        SetVehicleMod(veh, modIndex, realValue, false)
    end)
    lib.showMenu('vmenu_tuning')
end

-- ══════════════════════════════════════════════════════════════
--  性能改裝選單
-- ══════════════════════════════════════════════════════════════

local function openPerformanceMenu()
    local veh = getVeh()
    if not veh then
        lib.notify({ title = '改裝', description = '需坐在車上', type = 'error' }) return
    end
    SetVehicleModKit(veh, 0)

    local levelMods = {
        { label = '引擎',     modIndex = 11 },
        { label = '變速箱',   modIndex = 13 },
        { label = '煞車',     modIndex = 12 },
        { label = '懸吊',     modIndex = 15 },
    }
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
            local values  = { '無' }
            for i = 0, count - 1 do values[#values + 1] = '等級 ' .. (i + 1) end
            options[#options + 1] = {
                label        = mod.label,
                description  = ('共 %d 等級 | 目前: %s'):format(
                    count,
                    current >= 0 and ('等級 ' .. (current + 1)) or '無'
                ),
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
            description  = isOn and '目前：開啟' or '目前：關閉',
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
    }, function(selected, scrollIndex)
        local info = modInfos[selected]
        if not info then return end
        SetVehicleModKit(veh, 0)
        if info.kind == 'level' then
            SetVehicleMod(veh, info.modIndex, scrollIndex - 2, false)
        elseif info.kind == 'toggle' then
            ToggleVehicleMod(veh, info.modIndex, scrollIndex == 2)
        end
    end)
    lib.showMenu('vmenu_performance')
end

-- ══════════════════════════════════════════════════════════════
--  改裝主選單
-- ══════════════════════════════════════════════════════════════

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
            { label = '🎨 外觀改裝', description = '自動掃描此車所有可用套件部位' },
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

local function openVehicleList(title, vehicleList)
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
            openVehicleList('⭐ Addon 模組車', Config.AddonVehicles)
        else
            local cat = Config.NativeVehicles[selected - 1]
            openVehicleList(cat.label, cat.vehicles)
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
            { label = '🚗 生成車輛',      description = '依分類瀏覽並生成車輛'          },
            { label = '🔧 改裝車輛',      description = '性能 & 外觀改裝（需坐在車上）'  },
            { label = '🩹 修車',          description = '修復車輛至全滿（需坐在車上）'   },
            { label = '🚿 洗車',          description = '清潔車輛外觀（需坐在車上）'     },
            { label = '🗑️ 刪除當前車輛', description = '移除你生成的車輛'               },
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
