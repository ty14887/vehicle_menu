-- config.lua

Config = {}

-- 叫出選單的指令
Config.Command = 'vmenu'

-- ── Addon 車輛清單（手動填入你伺服器安裝的車輛 spawn name）─────
-- label = 顯示名稱, model = spawn name
Config.AddonVehicles = {
    { label = '範例 Addon 車 1', model = 'addoncar1' },
    { label = '範例 Addon 車 2', model = 'addoncar2' },
    { label = '範例 Addon 跑車', model = 'addonsport1' },
    -- 繼續新增...
}

-- ── 原生車輛分類清單 ────────────────────────────────────────────
Config.NativeVehicles = {
    {
        label = '🚗 轎車',
        icon = 'car',
        vehicles = {
            { label = 'Asea',           model = 'asea' },
            { label = 'Asterope',       model = 'asterope' },
            { label = 'Fugitive',       model = 'fugitive' },
            { label = 'Glendale',       model = 'glendale' },
            { label = 'Greenwood',      model = 'greenwood' },
            { label = 'Ingot',          model = 'ingot' },
            { label = 'Intruder',       model = 'intruder' },
            { label = 'Merit',          model = 'merit' },
            { label = 'Premier',        model = 'premier' },
            { label = 'Primo',          model = 'primo' },
            { label = 'Rhapsody',       model = 'rhapsody' },
            { label = 'Stanier',        model = 'stanier' },
            { label = 'Stratum',        model = 'stratum' },
            { label = 'Surge',          model = 'surge' },
            { label = 'Tailgater',      model = 'tailgater' },
            { label = 'Washington',     model = 'washington' },
        }
    },
    {
        label = '🏎️ 超級跑車',
        icon = 'gauge-high',
        vehicles = {
            { label = 'Adder',          model = 'adder' },
            { label = 'Autarch',        model = 'autarch' },
            { label = 'Banshee 900R',   model = 'banshee2' },
            { label = 'Cheetah',        model = 'cheetah' },
            { label = 'Entity XF',      model = 'entityxf' },
            { label = 'Entity XXR',     model = 'entity2' },
            { label = 'FMJ',            model = 'fmj' },
            { label = 'Infernus',       model = 'infernus' },
            { label = 'Itali GTB',      model = 'italigto' },
            { label = 'Krieger',        model = 'krieger' },
            { label = 'Nero',           model = 'nero' },
            { label = 'Osiris',         model = 'osiris' },
            { label = 'Reaper',         model = 'reaper' },
            { label = 'T20',            model = 't20' },
            { label = 'Tempesta',       model = 'tempesta' },
            { label = 'Turismo R',      model = 'turismor' },
            { label = 'Vagner',         model = 'vagner' },
            { label = 'Visione',        model = 'visione' },
            { label = 'Zentorno',       model = 'zentorno' },
        }
    },
    {
        label = '🏁 跑車',
        icon = 'flag-checkered',
        vehicles = {
            { label = 'Banshee',        model = 'banshee' },
            { label = 'Buffalo S',      model = 'buffalo2' },
            { label = 'Carbonizzare',   model = 'carbonizzare' },
            { label = 'Comet S2',       model = 'comet2' },
            { label = 'Coquette',       model = 'coquette' },
            { label = 'Elegy RH8',      model = 'elegy' },
            { label = 'Feltzer',        model = 'feltzer2' },
            { label = 'Furore GT',      model = 'furoregt' },
            { label = 'Jester',         model = 'jester' },
            { label = 'Massacro',       model = 'massacro' },
            { label = 'Rapid GT',       model = 'rapidgt' },
            { label = 'Sultan',         model = 'sultan' },
            { label = 'Surano',         model = 'surano' },
            { label = 'Zion',           model = 'zion' },
        }
    },
    {
        label = '🚙 SUV / 越野',
        icon = 'truck-monster',
        vehicles = {
            { label = 'Baller',         model = 'baller' },
            { label = 'Cavalcade',      model = 'cavalcade' },
            { label = 'Dubsta',         model = 'dubsta' },
            { label = 'FQ 2',           model = 'fq2' },
            { label = 'Granger',        model = 'granger' },
            { label = 'Huntley S',      model = 'huntley' },
            { label = 'Radius',         model = 'radius' },
            { label = 'Rebla GTS',      model = 'rebla' },
            { label = 'Seminole',       model = 'seminole' },
            { label = 'Toros',          model = 'toros' },
        }
    },
    {
        label = '🚐 廂型車 / 貨車',
        icon = 'van-shuttle',
        vehicles = {
            { label = 'Bison',          model = 'bison' },
            { label = 'Bobcat XL',      model = 'bobcatxl' },
            { label = 'Burrito',        model = 'burrito' },
            { label = 'Minivan',        model = 'minivan' },
            { label = 'Pony',           model = 'pony' },
            { label = 'Speedo',         model = 'speedo' },
            { label = 'Youga',          model = 'youga' },
        }
    },
    {
        label = '🚛 大型車輛',
        icon = 'truck',
        vehicles = {
            { label = 'Hauler',         model = 'hauler' },
            { label = 'Mule',           model = 'mule' },
            { label = 'Phantom',        model = 'phantom' },
            { label = 'Pounder',        model = 'pounder' },
            { label = 'Stockade',       model = 'stockade' },
        }
    },
    {
        label = '🏍️ 摩托車',
        icon = 'motorcycle',
        vehicles = {
            { label = 'Akuma',          model = 'akuma' },
            { label = 'Bati 801',       model = 'bati' },
            { label = 'Carbon RS',      model = 'carbonrs' },
            { label = 'Daemon',         model = 'daemon' },
            { label = 'Deathbike',      model = 'deathbike' },
            { label = 'Defiler',        model = 'defiler' },
            { label = 'Faggio',         model = 'faggio2' },
            { label = 'Hakuchou',       model = 'hakuchou' },
            { label = 'Lectro',         model = 'lectro' },
            { label = 'Nemesis',        model = 'nemesis' },
            { label = 'Nightblade',     model = 'nightblade' },
            { label = 'PCJ-600',        model = 'pcj' },
            { label = 'Ruffian',        model = 'ruffian' },
            { label = 'Sanchez',        model = 'sanchez' },
            { label = 'Shotaro',        model = 'shotaro' },
            { label = 'Thrust',         model = 'thrust' },
            { label = 'Vader',          model = 'vader' },
            { label = 'Vortex',         model = 'vortex' },
            { label = 'Wayfarer',       model = 'wayfarer' },
        }
    },
    {
        label = '✈️ 飛機',
        icon = 'plane',
        vehicles = {
            { label = 'Besra',          model = 'besra' },
            { label = 'Cargo Plane',    model = 'cargoplane' },
            { label = 'Cuban 800',      model = 'cuban800' },
            { label = 'Hydra',          model = 'hydra' },
            { label = 'Jet',            model = 'jet' },
            { label = 'Lazer',          model = 'lazer' },
            { label = 'Luxor',          model = 'luxor' },
            { label = 'Mallard',        model = 'mallard' },
            { label = 'Nimbus',         model = 'nimbus' },
            { label = 'Shamal',         model = 'shamal' },
            { label = 'Titan',          model = 'titan' },
            { label = 'Velum',          model = 'velum' },
        }
    },
    {
        label = '🚁 直升機',
        icon = 'helicopter',
        vehicles = {
            { label = 'Akula',          model = 'akula' },
            { label = 'Annihilator',    model = 'annihilator' },
            { label = 'Buzzard',        model = 'buzzard' },
            { label = 'Cargobob',       model = 'cargobob' },
            { label = 'Frogger',        model = 'frogger' },
            { label = 'Hunter',         model = 'hunter' },
            { label = 'Maverick',       model = 'maverick' },
            { label = 'Savage',         model = 'savage' },
            { label = 'Supervolito',    model = 'supervolito' },
            { label = 'Volatus',        model = 'volatus' },
        }
    },
    {
        label = '🚤 船隻',
        icon = 'ship',
        vehicles = {
            { label = 'Dinghy',         model = 'dinghy' },
            { label = 'Jetmax',         model = 'jetmax' },
            { label = 'Marquis',        model = 'marquis' },
            { label = 'Speeder',        model = 'speeder' },
            { label = 'Squalo',         model = 'squalo' },
            { label = 'Tug',            model = 'tug' },
            { label = 'Yacht',          model = 'yacht' },
        }
    },
}

-- ── 改裝選項設定 ────────────────────────────────────────────────
Config.Mods = {
    -- 性能改裝
    performance = {
        { label = '引擎',        modIndex = 11, maxLevel = 4 },
        { label = '變速箱',      modIndex = 13, maxLevel = 4 },
        { label = '煞車',        modIndex = 12, maxLevel = 4 },
        { label = '懸吊',        modIndex = 15, maxLevel = 4 },
        { label = '防彈輪胎',    modIndex = 69, toggle = true },  -- toggle mod
        { label = '氮氣加速',    modIndex = 63, toggle = true },
        { label = '渦輪增壓',    modIndex = 18, toggle = true },
    },
    -- 外觀改裝（tuning parts，數量依車型不同）
    tuning = {
        { label = '前保險桿',    modIndex = 0 },
        { label = '後保險桿',    modIndex = 1 },
        { label = '側裙',        modIndex = 2 },
        { label = '排氣管',      modIndex = 3 },
        { label = '車架',        modIndex = 4 },
        { label = '格柵',        modIndex = 5 },
        { label = '引擎蓋',      modIndex = 6 },
        { label = '左翼子板',    modIndex = 7 },
        { label = '右翼子板',    modIndex = 8 },
        { label = '車頂',        modIndex = 10 },
        { label = '車窗',        modIndex = 17 },
        { label = '車燈',        modIndex = 22 },
        { label = '後視鏡',      modIndex = 23 },
        { label = '輪圈',        modIndex = 23 },
        { label = '後擾流板',    modIndex = 9 },
    },
}
