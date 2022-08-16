math.randomseed(os.time())

STATUS = {}
STATUS.START_CLOCK = os.clock()
STATUS.START_DATE = os.date("*t")
STATUS.TRACKER_READY = false
STATUS.ACCESS_COUNTER = 0

CONFIG.LAYOUT_SHOW_MAP_GRIDLINES = false

CACHE = {}
CACHE.MODULE = 0
CACHE.OWAREA = -1
CACHE.DUNGEON = -1
CACHE.ROOM = -1
CACHE.WORLD = 0
CACHE.CollectionRate = 0

INSTANCE = {}
INSTANCE.NEW_KEY_SYSTEM = false
INSTANCE.NEW_DUNGEONCOUNT_SYSTEM = false
INSTANCE.NEW_POTDROP_SYSTEM = false
INSTANCE.NEW_SRAM_SYSTEM = false
INSTANCE.VERSION_MAJOR = 0
INSTANCE.VERSION_MINOR = 0

INSTANCE.DUNGEON_PRIZE_DATA = 0x0000

INSTANCE.ROOMCURSORPOSITION = 1
INSTANCE.ROOMSLOTS = { {0, 0}, {0, 0}, {0, 0}, {0, 0} }

INSTANCE.DOORSLOTS = {--1 2  3   4  5  6   7  8  9   10 11 12  13 14 15 16
    [0x01] = {0, 1, 0,  1, 0, 0,  1, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    --[0x07] = {0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0, 1, 0, 0, 1},--Moldorm Boss Arena
    [0x09] = {0, 1, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0,  1, 0, 0, 0},
    --[0x0a] = {0, 1, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0, 1, 0, 0},--PoD Stalfos Basement
    [0x0c] = {1, 1, 1,  0, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x11] = {0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 1,  0, 0, 0, 0},
    [0x14] = {0, 0, 0,  1, 0, 0,  1, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0x15] = {1, 0, 0,  1, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x17] = {1, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 1, 0},
    [0x1a] = {0, 1, 1,  1, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0, 0},
    [0x1e] = {0, 0, 0,  0, 0, 0,  0, 0, 1,  0, 0, 1,  0, 1, 1, 0},
    [0x24] = {1, 0, 6,  0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x26] = {0, 1, 1,  0, 0, 0,  0, 1, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x27] = {1, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0,  1, 0, 1, 0},
    [0x2a] = {1, 0, 0,  0, 0, 0,  0, 1, 0,  1, 0, 1,  0, 0, 0, 0},
    [0x2b] = {1, 0, 0,  0, 1, 1,  0, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0x31] = {0, 0, 1,  0, 0, 0,  0, 0, 1,  0, 0, 0,  0, 0, 1, 0},
    [0x34] = {0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0,  0, 0, 1, 0},
    [0x35] = {0, 0, 0,  0, 0, 1,  1, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x36] = {0, 1, 0,  1, 0, 1,  0, 0, 1,  0, 1, 0,  0, 0, 0, 0},
    [0x37] = {0, 0, 0,  1, 0, 1,  0, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x38] = {1, 0, 0,  1, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x3a] = {1, 0, 1,  0, 0, 0,  0, 0, 0,  0, 1, 0,  1, 1, 0, 0},
    [0x3d] = {0, 0, 0,  0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0, 1},
    [0x45] = {1, 0, 0,  1, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x4a] = {1, 1, 1,  0, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x4d] = {1, 0, 1,  0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0, 1},
    [0x52] = {0, 0, 0,  1, 0, 0,  0, 0, 0,  1, 1, 0,  0, 0, 0, 0},
    [0x56] = {0, 0, 0,  0, 0, 0,  0, 0, 1,  1, 0, 0,  0, 0, 0, 0},
    [0x58] = {0, 0, 0,  0, 0, 1,  0, 0, 0,  1, 0, 1,  0, 0, 0, 0},
    [0x5e] = {0, 0, 0,  0, 0, 1,  0, 0, 1,  0, 0, 1,  0, 1, 0, 0},
    [0x5f] = {1, 0, 1,  0, 1, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x60] = {0, 0, 1,  0, 0, 0,  1, 1, 0,  0, 0, 1,  0, 0, 0, 0},
    [0x61] = {0, 1, 0,  1, 1, 0,  0, 1, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x62] = {1, 1, 0,  0, 1, 0,  0, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0x67] = {0, 0, 1,  0, 0, 0,  0, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x68] = {0, 0, 1,  0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x72] = {0, 1, 0,  0, 0, 0,  0, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0x74] = {0, 0, 0,  0, 0, 1,  0, 0, 1,  1, 0, 1,  0, 0, 0, 0},
    [0x76] = {1, 1, 0,  0, 0, 0,  0, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x77] = {1, 0, 0,  0, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 1, 1},
    [0x7d] = {0, 0, 0,  0, 0, 1,  0, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x7e] = {0, 0, 0,  0, 0, 1,  1, 0, 0,  0, 0, 1,  0, 0, 1, 0},
    [0x81] = {1, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x84] = {1, 1, 1,  0, 0, 0,  1, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x85] = {1, 0, 1,  1, 0, 0,  0, 0, 0,  0, 0, 1,  0, 0, 0, 0},
    [0x8b] = {1, 0, 0,  0, 0, 0,  1, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0x8c] = {1, 0, 1,  1, 0, 0,  1, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0x8d] = {0, 0, 1,  1, 0, 0,  0, 0, 0,  0, 0, 1,  0, 0, 0, 0},
    [0x96] = {0, 0, 0,  1, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 1},
    [0x97] = {0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0,  1, 0, 1, 0},
    [0x9c] = {1, 0, 1,  0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x9e] = {0, 0, 1,  0, 0, 0,  0, 0, 1,  0, 0, 0,  0, 0, 0, 1},
    [0xa2] = {0, 1, 0,  0, 0, 0,  0, 0, 0,  0, 1, 1,  0, 0, 0, 0},
    [0xa8] = {0, 0, 0,  0, 0, 0,  1, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0xa9] = {0, 6, 0,  1, 1, 0,  1, 1, 0,  0, 1, 0,  0, 0, 0, 0},
    [0xb1] = {0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 1,  6, 0, 0, 0},
    [0xb2] = {0, 6, 1,  0, 0, 0,  1, 0, 1,  1, 0, 1,  0, 0, 0, 0},
    [0xb3] = {1, 0, 0,  1, 0, 1,  0, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0xbb] = {1, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0xbc] = {1, 0, 1,  1, 0, 1,  0, 0, 0,  0, 0, 1,  0, 0, 0, 0},
    [0xbe] = {0, 0, 1,  0, 0, 0,  0, 0, 1,  0, 0, 1,  0, 0, 0, 0},
    [0xc1] = {0, 0, 1,  0, 0, 0,  1, 0, 1,  1, 0, 1,  0, 0, 0, 0},
    [0xc2] = {1, 0, 1,  1, 0, 1,  1, 1, 1,  0, 0, 1,  0, 0, 0, 0},
    [0xc3] = {1, 0, 0,  1, 1, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0xc5] = {1, 0, 0,  0, 0, 1,  0, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0xc6] = {1, 0, 1,  0, 0, 0,  1, 0, 1,  1, 0, 1,  0, 0, 0, 0},
    [0xcb] = {0, 0, 0,  0, 0, 0,  1, 1, 1,  0, 1, 1,  0, 0, 0, 0},
    [0xcc] = {1, 0, 6,  1, 1, 1,  0, 0, 0,  1, 1, 0,  0, 0, 0, 0},
    [0xd1] = {0, 1, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0xdb] = {0, 1, 1,  0, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0xdc] = {1, 1, 0,  0, 1, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},

    [0x1000] = {1, 0, 0,  0, 0, 0,  1, 0, 0,  1, 1, 1,  0, 0, 0, 0},
    [0x1002] = {0, 0, 0,  1, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x1003] = {0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0,  0, 1, 0, 0},
    [0x1005] = {0, 0, 0,  1, 0, 1,  1, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1007] = {0, 0, 0,  1, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 1, 0},
    [0x100a] = {0, 1, 0,  0, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x100f] = {0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 1,  0, 0, 1, 0},
    [0x1010] = {1, 0, 1,  0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0, 1},
    [0x1011] = {0, 0, 1,  0, 0, 0,  1, 0, 1,  0, 1, 0,  0, 0, 0, 0},
    [0x1012] = {0, 1, 0,  1, 0, 1,  0, 1, 1,  1, 1, 0,  1, 0, 0, 0},
    [0x1013] = {0, 0, 0,  0, 1, 1,  0, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1014] = {0, 0, 0,  0, 1, 0,  0, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1015] = {0, 0, 0,  0, 1, 0,  1, 1, 1,  1, 1, 1,  0, 1, 0, 0},
    [0x1016] = {0, 0, 0,  1, 1, 1,  1, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1017] = {0, 0, 1,  1, 1, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1018] = {1, 1, 1,  0, 0, 0,  0, 0, 1,  0, 0, 1,  0, 0, 0, 0},
    [0x101a] = {1, 1, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x101b] = {0, 0, 0,  1, 0, 0,  0, 0, 1,  1, 0, 1,  0, 0, 0, 1},
    [0x101d] = {1, 1, 1,  0, 0, 0,  0, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0x101e] = {0, 0, 0,  0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0, 0},
    [0x1022] = {0, 0, 0,  0, 1, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1025] = {0, 1, 0,  1, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x1028] = {0, 0, 0,  0, 0, 0,  0, 0, 1,  0, 0, 0,  0, 0, 0, 0}, --Race Game
    [0x1029] = {0, 0, 1,  0, 0, 1,  0, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    --[0x102a] = {0, 0, 0,  0, 0, 1,  0, 0, 0,  1, 0, 0,  0, 0, 0, 0}, --Flute Boy
    [0x102b] = {1, 0, 0,  0, 0, 0,  1, 1, 1,  1, 0, 0,  0, 0, 0, 0},
    [0x102c] = {0, 1, 0,  1, 1, 1,  0, 0, 1,  0, 1, 0,  0, 0, 0, 0},
    [0x102d] = {0, 1, 0,  0, 0, 1,  1, 0, 1,  0, 1, 0,  0, 0, 0, 1},
    [0x102e] = {1, 0, 0,  1, 1, 0,  0, 0, 0,  0, 1, 1,  0, 0, 0, 0},
    [0x102f] = {0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 1},
    [0x1030] = {0, 0, 0,  0, 0, 0,  0, 1, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x1032] = {1, 1, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1033] = {1, 0, 0,  0, 1, 0,  1, 1, 1,  0, 1, 0,  0, 1, 0, 1},
    [0x1034] = {0, 1, 0,  1, 1, 1,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x1035] = {1, 1, 1,  0, 0, 1,  0, 1, 1,  0, 0, 0,  0, 0, 0, 1},
    [0x1037] = {0, 0, 0,  0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0, 0},
    [0x103a] = {0, 0, 0,  0, 1, 1,  0, 1, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x103b] = {0, 1, 0,  0, 1, 1,  0, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x103c] = {0, 1, 0,  0, 1, 0,  0, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x103f] = {0, 0, 1,  0, 1, 1,  0, 0, 0,  0, 0, 0,  1, 0, 0, 0},
    [0x1040] = {0, 0, 0,  0, 0, 0,  1, 0, 0,  1, 1, 1,  0, 0, 0, 0},
    [0x1042] = {0, 0, 0,  1, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x1043] = {0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x1045] = {0, 0, 0,  1, 0, 1,  1, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1047] = {0, 0, 0,  1, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x104a] = {0, 1, 0,  0, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    --[0x104f] = {0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 1,  0, 0, 0, 0}, --Catfish
    [0x1050] = {1, 0, 1,  0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0, 0},
    [0x1051] = {0, 0, 1,  0, 0, 0,  1, 0, 1,  0, 1, 0,  0, 0, 0, 0},
    [0x1052] = {0, 1, 0,  1, 0, 1,  0, 1, 1,  1, 1, 0,  0, 0, 0, 0},
    [0x1053] = {0, 0, 0,  0, 1, 1,  0, 1, 0,  0, 0, 0,  1, 0, 0, 0},
    [0x1054] = {0, 0, 0,  0, 1, 0,  0, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1055] = {0, 0, 0,  0, 1, 0,  1, 1, 1,  1, 1, 1,  0, 1, 0, 0},
    [0x1056] = {0, 0, 0,  0, 1, 1,  1, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1057] = {0, 0, 1,  1, 1, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1058] = {1, 1, 1,  0, 0, 0,  0, 0, 1,  0, 0, 1,  0, 0, 0, 0},
    [0x105a] = {1, 1, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x105b] = {0, 0, 0,  0, 0, 0,  0, 1, 0,  1, 0, 1,  0, 0, 0, 0},
    [0x105d] = {1, 1, 1,  0, 0, 0,  0, 0, 0,  1, 0, 0,  0, 0, 0, 0},
    [0x105e] = {0, 0, 0,  0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0, 0},
    [0x1062] = {0, 0, 0,  0, 1, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x1065] = {0, 1, 0,  1, 0, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x1068] = {0, 0, 0,  0, 0, 0,  0, 1, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x1069] = {0, 0, 1,  0, 1, 1,  0, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    --[0x106a] = {0, 0, 0,  0, 0, 1,  0, 0, 0,  1, 0, 0,  0, 0, 0, 0}, --Stumpy
    [0x106b] = {1, 0, 0,  0, 0, 0,  1, 1, 1,  1, 0, 0,  0, 0, 0, 0},
    [0x106c] = {0, 1, 0,  1, 1, 1,  0, 0, 1,  0, 1, 0,  0, 0, 0, 0},
    [0x106d] = {0, 1, 0,  0, 0, 1,  1, 1, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x106e] = {1, 0, 0,  1, 1, 0,  0, 0, 0,  0, 1, 1,  0, 0, 0, 0},
    [0x106f] = {0, 0, 1,  0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0},
    --[0x1070] = {0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0, 0}, --Mire
    [0x1072] = {1, 1, 0,  0, 0, 0,  0, 1, 0,  0, 0, 0,  0, 0, 1, 0},
    [0x1073] = {1, 0, 0,  0, 1, 0,  1, 1, 1,  0, 1, 0,  0, 0, 0, 0},
    [0x1074] = {0, 1, 0,  1, 1, 1,  0, 0, 0,  0, 1, 0,  0, 0, 0, 0},
    [0x1075] = {1, 1, 1,  0, 0, 1,  0, 1, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x1077] = {0, 0, 0,  0, 0, 0,  0, 0, 0,  1, 0, 1,  0, 0, 0, 0},
    [0x107a] = {0, 0, 0,  0, 0, 0,  0, 1, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x107b] = {0, 1, 0,  0, 1, 1,  0, 1, 0,  0, 0, 0,  0, 0, 0, 0},
    [0x107c] = {0, 1, 0,  0, 1, 0,  0, 0, 1,  0, 0, 0,  0, 0, 0, 0},
    [0x107f] = {0, 0, 1,  0, 1, 1,  0, 0, 0,  0, 0, 0,  1, 0, 0, 0}
}

function loadSettings()
    for i, file in ipairs(DATA.SettingsHeader) do
        for j, setting in ipairs(file[2]) do
            name = DATA.SettingsData[file[1]][setting][1]
            code = DATA.SettingsData[file[1]][setting][2]
            count = DATA.SettingsData[file[1]][setting][3]
            default = DATA.SettingsData[file[1]][setting][4]
            current = DATA.SettingsData[file[1]][setting][5]
            Setting(name, code, file[1], setting, count, default, current)
        end
    end
end

function loadMCBK()
    MapCompassBK("Hyrule Castle Map/Compass/Big Key",      "hc")
    MapCompassBK("Eastern Palace Map/Compass/Big Key",     "ep")
    MapCompassBK("Desert Palace Map/Compass/Big Key",      "dp")
    MapCompassBK("Tower of Hera Map/Compass/Big Key",      "toh")
    MapCompassBK("Aganihm's Tower Map/Compass/Big Key",    "at")
    MapCompassBK("Palace of Darkness Map/Compass/Big Key", "pod")
    MapCompassBK("Swamp Palace Map/Compass/Big Key",       "sp")
    MapCompassBK("Skull Woods Map/Compass/Big Key",        "sw")
    MapCompassBK("Thieves Town Map/Compass/Big Key",       "tt")
    MapCompassBK("Ice Palace Map/Compass/Big Key",         "ip")
    MapCompassBK("Misery Mire Map/Compass/Big Key",        "mm")
    MapCompassBK("Turtle Rock Map/Compass/Big Key",        "tr")
    MapCompassBK("Ganon's Tower Map/Compass/Big Key",      "gt")
end

function loadModes()
    OBJ_WORLDSTATE = WorldStateMode(false):linkSurrogate(WorldStateMode(true))
    OBJ_KEYMAP = KeysanityMode(false, "Map"):linkSurrogate(KeysanityMode(true, "Map"))
    OBJ_KEYCOMPASS = KeysanityMode(false, "Compass"):linkSurrogate(KeysanityMode(true, "Compass"))
    OBJ_KEYSMALL = KeysanityMode(false, "Small Key"):linkSurrogate(KeysanityMode(true, "Small Key"))
    OBJ_KEYBIG = KeysanityMode(false, "Big Key"):linkSurrogate(KeysanityMode(true, "Big Key"))
    OBJ_ENTRANCE = EntranceShuffleMode(false):linkSurrogate(EntranceShuffleMode(true))
    OBJ_DOORSHUFFLE = DoorShuffleMode(false):linkSurrogate(DoorShuffleMode(true))
    OBJ_MIXED = OverworldMixedMode(false):linkSurrogate(OverworldMixedMode(true))
    OBJ_OWSHUFFLE = OverworldLayoutMode(false):linkSurrogate(OverworldLayoutMode(true))
    OBJ_RETRO = RetroMode(false):linkSurrogate(RetroMode(true))
    OBJ_DISTRICT = PoolMode(0, "District")
    PoolMode(0, "Shopsanity"):linkSurrogate(PoolMode(1, "Shopsanity"))
    PoolMode(0, "Bonk Drop"):linkSurrogate(PoolMode(1, "Bonk Drop"))
    OBJ_POOL_ENEMYDROP = PoolMode(0, "Enemy Drop")
    OBJ_POOL_ENEMYDROP:linkSurrogate(PoolMode(1, "Enemy Drop"):linkSurrogate(PoolMode(2, "Enemy Drop"):linkSurrogate(OBJ_POOL_ENEMYDROP, true), true), true)
    OBJ_POOL_DUNGEONPOT = PoolPotMode(0, "Dungeon Pot")
    OBJ_POOL_DUNGEONPOT:linkSurrogate(PoolPotMode(1, "Dungeon Pot"):linkSurrogate(PoolPotMode(2, "Dungeon Pot"):linkSurrogate(OBJ_POOL_DUNGEONPOT, true), true), true)
    OBJ_POOL_CAVEPOT = PoolPotMode(0, "Cave Pot")
    OBJ_POOL_CAVEPOT:linkSurrogate(PoolPotMode(2, "Cave Pot"):linkSurrogate(OBJ_POOL_CAVEPOT, true), true)
    OBJ_GLITCHMODE = GlitchMode(false):linkSurrogate(GlitchMode(true))
    OBJ_RACEMODE = RaceMode(false):linkSurrogate(RaceMode(true))

    GTCrystalReq()
end

function loadSwaps()
    if Tracker.ActiveVariantUID == "full_tracker" then
        for i = 1, #DATA.OverworldIds do
            OWSwap(DATA.OverworldIds[i]):linkSurrogate(OWSwap(DATA.OverworldIds[i] + 0x40))
        end
    end
end

function loadDungeonChests()
    ExtendedChestCounter("Hyrule Castle Items",      "hc",  "@Hyrule Castle & Escape", 8,  2)
    ExtendedChestCounter("Eastern Palace Items",     "ep",  "@Eastern Palace",         6,  3)
    ExtendedChestCounter("Desert Palace Items",      "dp",  "@Desert Palace",          6,  4)
    ExtendedChestCounter("Tower of Hera Items",      "toh", "@Tower of Hera",          6,  4)
    ExtendedChestCounter("Aganihm's Tower Items",    "at",  "@Agahnim's Tower",        2,  2)
    ExtendedChestCounter("Palace of Darkness Items", "pod", "@Palace of Darkness",     14, 9)
    ExtendedChestCounter("Swamp Palace Items",       "sp",  "@Swamp Palace",           10, 4)
    ExtendedChestCounter("Skull Woods Items",        "sw",  "@Skull Woods",            8,  6)
    ExtendedChestCounter("Thieves Town Items",       "tt",  "@Thieves Town",           8,  4)
    ExtendedChestCounter("Ice Palace Items",         "ip",  "@Ice Palace",             8,  5)
    ExtendedChestCounter("Misery Mire Items",        "mm",  "@Misery Mire",            8,  6)
    ExtendedChestCounter("Turtle Rock Items",        "tr",  "@Turtle Rock",            12, 7)
    ExtendedChestCounter("Ganon's Tower Items",      "gt",  "@Ganon's Tower",          27, 7)
end

function loadDoorObjects()
    if Tracker.ActiveVariantUID == "full_tracker" then
        for g = 1, #RoomGroupSelection.Groups do
            RoomGroupSelection(g)
        end
        for r = 1, 9 do
            RoomSelectSlot(r)
        end
        for r = 1, #INSTANCE.ROOMSLOTS do
            for d = 1, 16 do
                DoorSlot(r, d)
            end
        end
        for t = 1, #DoorSlot.Icons do
            if DoorSlotSelection.Types[t] then
                DoorSlotSelection(t)
            end
        end
    end

    if Tracker.ActiveVariantUID ~= "vanilla" then
        OBJ_DOORDUNGEON = DoorDungeonSelect()
        OBJ_DOORCHEST = DoorTotalChest("Chests", "chest", "item", "images/items/chest.png")
        OBJ_DOORKEY = DoorTotalChest("Keys", "key", "smallkey", "images/items/smallkey.png")
    end
end

function loadMisc()
    if Tracker.ActiveVariantUID ~= "vanilla" then
        DykCloseItem(1)
        DykCloseItem(2)
        DykCloseItem(3)
        TrackerSync()
        SaveStorage()
    end
end

function initialize()
    if Tracker.ActiveVariantUID ~= "vanilla" then
        updateDyk()

        if Tracker.ActiveVariantUID == "full_tracker" then
            CaptureBadgeCache = {}
        
            --Link Dungeon Locations to Chest Items
            for i = 1, #DATA.DungeonList do
                local item = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_item").ItemState
                if item then
                    if item:getProperty("section") == nil then
                        item:setProperty("section", Tracker:FindObjectForCode(item:getProperty("sectionName")))
                    end
                end
            end

            updateChests()
        
            --Disable Retro Mode Icon
            OBJ_RETRO:updateItem()
        end

        --Auto-Toggle Race Mode
        if CONFIG.PREFERENCE_DEFAULT_RACE_MODE_ON then
            OBJ_RACEMODE:setState(1)
        end
    end

    updateLayout()
end

function updateChests()
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Before chest change: " .. os.clock() - STATUS.START_CLOCK)
    end

    for i = 1, #DATA.DungeonList do
        local key = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_smallkey")
        local newMax = 0
        if OBJ_DOORSHUFFLE:getState() == 2 then
            key.MaxCount = 999
            key.Icon = ImageReference:FromPackRelativePath("images/items/smallkey.png", key.AcquiredCount > 0 and "" or "@disabled")
            
            if (OBJ_POOL_ENEMYDROP:getState() == 0 and DATA.DungeonList[i] == "hc") or DATA.DungeonList[i] == "at" then
                local bk = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_bigkey")
                bk.Icon = ImageReference:FromPackRelativePath("images/items/bigkey.png", bk.Active and "" or "@disabled")
            end
        else
            newMax = DATA.DungeonData[DATA.DungeonList[i]][6]
            if OBJ_POOL_ENEMYDROP:getState() > 0 then
                newMax = newMax + DATA.DungeonData[DATA.DungeonList[i]][7]
            end
            if OBJ_POOL_DUNGEONPOT:getState() > 0 then
                newMax = newMax + DATA.DungeonData[DATA.DungeonList[i]][8]
            end
            key.MaxCount = newMax

            if OBJ_POOL_ENEMYDROP:getState() > 0 and DATA.DungeonList[i] == "hc" then
                local bk = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_bigkey")
                bk.Icon = ImageReference:FromPackRelativePath("images/items/bigkey.png", bk.Active and "" or "@disabled")
            elseif (OBJ_POOL_ENEMYDROP:getState() == 0 and DATA.DungeonList[i] == "hc") or DATA.DungeonList[i] == "at" then
                Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_bigkey").Icon = ""
            end
        end

        if key.MaxCount == 0 or OBJ_KEYSMALL:getState() == 2 then
            key.Icon = ""
            key.BadgeText = nil
            key.IgnoreUserInput = true
        else
            if key.MaxCount > 0 then
                key.DisplayAsFractionOfMax = true
                key.DisplayAsFractionOfMax = false
            end
            key.IgnoreUserInput = false
        end

        local item = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_item").ItemState
        local seenFlags = AutoTracker:ReadU16(0x7ef403, 0)
        if shouldChestCountUp() then
            if item.MaxCount ~= 999 then
                item.MaxCount = 999
                updateDungeonTotal(DATA.DungeonList[i], seenFlags)
            end
        else
            newMax = DATA.DungeonData[DATA.DungeonList[i]][5]
            if OBJ_POOL_ENEMYDROP:getState() > 0 then
                newMax = newMax + DATA.DungeonData[DATA.DungeonList[i]][7] + (DATA.DungeonList[i] == "hc" and 1 or 0)
            end
            if OBJ_POOL_DUNGEONPOT:getState() > 0 then
                newMax = newMax + DATA.DungeonData[DATA.DungeonList[i]][8]
            end
            item.MaxCount = newMax
        end

        newMax = 0
        local newDeducted = 0
        if not shouldChestCountUp() or OBJ_DOORSHUFFLE:getState() < 2 then
            if OBJ_KEYMAP:getState() == 0 and DATA.DungeonList[i] ~= "at" then
                newMax = newMax + 1
                if Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_map").Active then
                    newDeducted = newDeducted + 1
                end
            end
            if OBJ_KEYCOMPASS:getState() == 0 and DATA.DungeonList[i] ~= "hc" and DATA.DungeonList[i] ~= "at" then
                newMax = newMax + 1
                if Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_compass").Active then
                    newDeducted = newDeducted + 1
                end
            end
            if OBJ_KEYSMALL:getState() == 0 and key then
                newMax = newMax + key.MaxCount
                newDeducted = newDeducted + key.AcquiredCount
            end
            if OBJ_KEYBIG:getState() == 0 and DATA.DungeonList[i] ~= "at" and (DATA.DungeonList[i] ~= "hc" or OBJ_POOL_ENEMYDROP:getState() > 0) then
                newMax = newMax + 1
                if Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_bigkey").Active then
                    newDeducted = newDeducted + 1
                end
            end
        end
        item.ExemptedCount = newMax
        item.DeductedCount = newDeducted

        OBJ_DOORDUNGEON:updateIcon()
        OBJ_DOORCHEST:updateIcon()
        OBJ_DOORKEY:updateIcon()
    end

    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("After chest change: " .. os.clock() - STATUS.START_CLOCK)
    end
end

function updateMaps()
    local e = Layout:FindLayout("map").Root.Maps:GetEnumerator()
    e:MoveNext()
    if OBJ_DISTRICT:getState() > 0 then
        e.Current.Image = ImageReference:FromPackRelativePath("images/maps/overworld/ow-district-" .. (OBJ_WORLDSTATE:getState() == 0 and "lw" or "dw") .. ".png")
        e:MoveNext()
        e.Current.Image = ImageReference:FromPackRelativePath("images/maps/overworld/ow-district-" .. (OBJ_WORLDSTATE:getState() == 0 and "dw" or "lw") .. ".png")
    else
        e.Current.Image = ImageReference:FromPackRelativePath("images/maps/overworld/ow_transparent.png")
        e:MoveNext()
        e.Current.Image = ImageReference:FromPackRelativePath("images/maps/overworld/ow_transparent.png")
    end
end

function updateLayout(setting)
    if Tracker.ActiveVariantUID ~= "vanilla" then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Updating layout")
        end

        if setting == nil or setting.file == "defaults.lua" then
            if setting == nil or setting.textcode == "CONFIG.PREFERENCE_DISPLAY_ALL_LOCATIONS" then
                Tracker.DisplayAllLocations = CONFIG.PREFERENCE_DISPLAY_ALL_LOCATIONS
            end
            if setting == nil or setting.textcode == "CONFIG.PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS" then
                Tracker.AlwaysAllowClearing = CONFIG.PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS
            end
            if setting == nil or setting.textcode == "CONFIG.PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE" then
                Tracker.PinLocationsOnItemCapture = CONFIG.PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE
            end
            if setting == nil or setting.textcode == "CONFIG.PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR" then
                Tracker.AutoUnpinLocationsOnClear = CONFIG.PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR
            end
        end
        if setting == nil or setting.file == "layout.lua" then
            if setting == nil or setting.textcode == "CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW" then
                --Change horizontal layout
                local e = Layout:FindLayout("shared_dungeon_grid").Root.Children:GetEnumerator()
                e:MoveNext()
                if CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW then
                    e.Current.Layout = Layout:FindLayout("shared_lw_keys_alt_grid")
                else
                    e.Current.Layout = Layout:FindLayout("shared_lw_keys_grid")
                end
                e:MoveNext()
                e:MoveNext()
                if CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW then
                    e.Current.Layout = Layout:FindLayout("shared_dw_keys_alt_grid")
                else
                    e.Current.Layout = Layout:FindLayout("shared_dw_keys_grid")
                end
                e:MoveNext()
                if CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW then
                e.Current.Layout = Layout:FindLayout("shared_doortotal_v_grid")
                else
                e.Current.Layout = nil
                end

                --Change vertical layout
                e = Layout:FindLayout("shared_dungeon_v_grid").Root.Children:GetEnumerator()
                e:MoveNext()
                local e2 = e.Current.Items:GetEnumerator()
                e2:MoveNext()
                if CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW then
                    e2.Current.Layout = Layout:FindLayout("shared_lw_keys_alt_grid")
                    e2:MoveNext()
                    e2.Current.Layout = Layout:FindLayout("shared_doortotal_v_grid")
                else
                    e2.Current.Layout = Layout:FindLayout("shared_lw_keys_grid")
                    e2:MoveNext()
                    e2.Current.Layout = nil
                end
                e:MoveNext()
                e:MoveNext()
                if CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW then
                    e.Current.Layout = Layout:FindLayout("shared_dw_keys_alt_grid")
                else
                    e.Current.Layout = Layout:FindLayout("shared_dw_keys_grid")
                end
            end
            if setting == nil or setting.textcode == "CONFIG.LAYOUT_USE_THIN_HORIZONTAL_PANE" then
                if CONFIG.LAYOUT_USE_THIN_HORIZONTAL_PANE then
                    Layout:FindLayout("shared_dock_grid").Root.Layout = Layout:FindLayout("dock_thin_grid")
                    Layout:FindLayout("shared_pins").Root.MaxHeight = 230
                else
                    Layout:FindLayout("shared_dock_grid").Root.Layout = Layout:FindLayout("dock_grid")
                    Layout:FindLayout("shared_pins").Root.MaxHeight = 306
                end
            end
            if Tracker.ActiveVariantUID == "full_tracker" and (setting == nil or setting.textcode == "CONFIG.LAYOUT_SHOW_MAP_GRIDLINES") then
                for i = 1, #DATA.OverworldIds do
                    Tracker:FindObjectForCode("ow_swapped_" .. string.format("%02x", DATA.OverworldIds[i])).ItemState:updateIcon()
                    Tracker:FindObjectForCode("ow_swapped_" .. string.format("%02x", DATA.OverworldIds[i] + 0x40)).ItemState:updateIcon()
                end
            end
        end
        if Tracker.ActiveVariantUID == "full_tracker" and setting == nil then
            updateMaps()
            OBJ_DOORSHUFFLE:postUpdate()
            OBJ_ENTRANCE:postUpdate()
            OBJ_MIXED:postUpdate()
        end
    end
    if setting == nil or setting.file == "broadcast.lua" then
        if Tracker.ActiveVariantUID == "vanilla" then
            if CONFIG.BROADCAST_ALTERNATE_LAYOUT == 2 then
                Layout:FindLayout("tracker_broadcast").Root.Layout = Layout:FindLayout("broadcast_vanilla_full")
            else
                Layout:FindLayout("tracker_broadcast").Root.Layout = Layout:FindLayout("broadcast_vanilla")
            end
        elseif CONFIG.BROADCAST_ALTERNATE_LAYOUT == 2 and Tracker.ActiveVariantUID == "full_tracker" then
            Layout:FindLayout("tracker_broadcast").Root.Layout = Layout:FindLayout("broadcast_full")
        elseif CONFIG.BROADCAST_ALTERNATE_LAYOUT == 3 then
            Layout:FindLayout("tracker_broadcast").Root.Layout = Layout:FindLayout("broadcast_custom")
        else
            Layout:FindLayout("tracker_broadcast").Root.Layout = Layout:FindLayout("broadcast_standard")

            if Tracker.ActiveVariantUID == "full_tracker" then
                if CONFIG.BROADCAST_MAP_DIRECTION ~= 5 then
                    Layout:FindLayout("broadcast_v_map").Root.Layout = CONFIG.BROADCAST_MAP_DIRECTION == 1 and Layout:FindLayout("shared_v_map") or nil
                    Layout:FindLayout("broadcast_map").Root.Layout = CONFIG.BROADCAST_MAP_DIRECTION == 2 and Layout:FindLayout("shared_map") or nil
                    Layout:FindLayout("broadcast_v_right_map").Root.Layout = CONFIG.BROADCAST_MAP_DIRECTION == 3 and Layout:FindLayout("shared_v_map") or nil
                    Layout:FindLayout("broadcast_bottom_map").Root.Layout = CONFIG.BROADCAST_MAP_DIRECTION == 4 and Layout:FindLayout("shared_map") or nil
                else
                    Layout:FindLayout("broadcast_map").Root.Layout = nil
                    Layout:FindLayout("broadcast_bottom_map").Root.Layout = nil
                    Layout:FindLayout("broadcast_v_map").Root.Layout = nil
                    Layout:FindLayout("broadcast_v_right_map").Root.Layout = nil
                end
            end
        end
    end
end

function updateDyk()
    local e = Layout:FindLayout("dyk_lines_grid").Root.Children:GetEnumerator()
    e:MoveNext()
    
    if Tracker.ActiveVariantUID == "full_tracker" or Tracker.ActiveVariantUID == "items_only" or Tracker.ActiveVariantUID == "vanilla" then
        local text = DATA.DykTexts[math.random(1, #DATA.DykTexts)]
        e.Current.Text = text[1]
        e:MoveNext()
        e.Current.Text = table.concat({table.unpack(text, 2, #text - 1)}, "\n")
        e:MoveNext()
        e.Current.Text = text[#text]
    else
        e:MoveNext()
        e.Current.Background = "#80aa0000"
        e.Current.Text = "The package variants have changed, please select a new variant"
        e:MoveNext()
    end
    
    e = Layout:FindLayout("dyk_close_troll").Root.Items:GetEnumerator()
    e:MoveNext()
    e.Current.Margin = string.format("%i,%i,0,0", math.random(10, 550), math.random(10, 132))
    e:MoveNext()
    e.Current.Margin = string.format("%i,%i,0,0", math.random(10, 550), math.random(10, 132))
end

function updateAllGhosts()
    if Tracker.ActiveVariantUID == "full_tracker" then
        --Update Ghost Badges
        -- if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        --     print("Before ghost update: " .. os.clock() - STATUS.START_CLOCK)
        -- end
        updateGhosts(DATA.CaptureBadgeOverworld, false, false)
        if OBJ_ENTRANCE:getState() < 2 then
            updateGhosts(DATA.CaptureBadgeUnderworld, false, true)
        end
        if OBJ_ENTRANCE:getState() > 0 then
            updateGhosts(DATA.CaptureBadgeDungeons, true, true)
            
            if OBJ_ENTRANCE:getState() > 1 then
                updateGhosts(DATA.CaptureBadgeEntrances, true, true)
                updateGhosts(DATA.CaptureBadgeConnectors, true, true)
                updateGhosts(DATA.CaptureBadgeDropdowns, true, true)
                updateGhosts(DATA.CaptureBadgeSWDungeons, true, true)
                updateGhosts(DATA.CaptureBadgeSWDropdowns, true, true)

                if OBJ_ENTRANCE:getState() == 4 then
                    updateGhosts(DATA.CaptureBadgeInsanity, true, true)
                end
            end
        end
        -- if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        --     print("After ghost update: " .. os.clock() - STATUS.START_CLOCK)
        -- end
    end
end

function updateGhosts(list, clearSection, markHostedItem)
    for i,section in pairs(list) do
        updateGhost(section, clearSection, markHostedItem)
    end
end

function updateGhost(section, clearSection, markHostedItem)
    local target, hiddenTarget
    if not CaptureBadgeCache[section] then
        local tempSection = section:gsub("/", " Ghost/")
        target = Tracker:FindObjectForCode(section)
        hiddenTarget = Tracker:FindObjectForCode(tempSection)
        CaptureBadgeCache[section] = {target, hiddenTarget, nil, nil}
    else
        target = CaptureBadgeCache[section][1]
        hiddenTarget = CaptureBadgeCache[section][2]
    end

    if target == nil or hiddenTarget == nil then
        print("Failed to resolve " .. section .. " please check for typos.")
        return false
    elseif target.CapturedItem and hiddenTarget and not hiddenTarget.Visible then
        removeGhost(section)
    end
    if target.CapturedItem ~= CaptureBadgeCache[section][4] and hiddenTarget.Visible then
        if CaptureBadgeCache[section][3] then
            hiddenTarget.Owner:RemoveBadge(CaptureBadgeCache[section][3])
            CaptureBadgeCache[section][3] = nil
            CaptureBadgeCache[section][4] = nil
        end
        if target.CapturedItem and hiddenTarget.Visible then
            CaptureBadgeCache[section][3] = hiddenTarget.Owner:AddBadge(target.CapturedItem.PotentialIcon)
            CaptureBadgeCache[section][4] = target.CapturedItem
            if clearSection then
                target.AvailableChestCount = 0
                target.CapturedItem = CaptureBadgeCache[section][4]
            end
            if markHostedItem then
                if target.HostedItem then
                    target.HostedItem.Active = true
                end
            end

            if OBJ_DOORSHUFFLE:getState() == 2 and not target.Owner.Pinned and (string.match(tostring(target.CapturedItem.Icon.URI), "capture/dungeons") or target.CapturedItem.Name == "Sanctuary Dropdown" or string.match(target.CapturedItem.Name, "^SW .* Dropdown")) then
                target.Owner.Pinned = true
            elseif CONFIG.PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE and not target.Owner.Pinned and (string.match(tostring(target.CapturedItem.Icon.URI), "capture/items") or string.match(tostring(target.CapturedItem.Icon.URI), "capture/misc")) then
                target.Owner.Pinned = true
            end

            if target.Owner.Pinned and target.CapturedItem.Name == "Dead Entrance" then
                target.Owner.Pinned = false
            end
        end
    end
end

function removeGhost(section)
    local target, hiddenTarget
    if not CaptureBadgeCache[section] then
        local tempSection = section:gsub("/", " Ghost/")
        target = Tracker:FindObjectForCode(section)
        hiddenTarget = Tracker:FindObjectForCode(tempSection)
        CaptureBadgeCache[section] = {target, hiddenTarget, nil, nil}
    else
        target = CaptureBadgeCache[section][1]
        hiddenTarget = CaptureBadgeCache[section][2]
    end

    if target == nil or hiddenTarget == nil then
        print("Failed to resolve " .. section .. " please check for typos.")
    elseif CaptureBadgeCache[section][4] then
        hiddenTarget.Owner:RemoveBadge(CaptureBadgeCache[section][3])
        CaptureBadgeCache[section][3] = nil
        CaptureBadgeCache[section][4] = nil
    end
end

function updateRoomSlots(roomId, forceUpdate)
    if Tracker.ActiveVariantUID == "full_tracker" then
        local roomToLoad = roomId
        if DATA.LinkedRoomSurrogates[roomId] then
            roomToLoad = DATA.LinkedRoomSurrogates[roomId]
        end
        local shouldUpdate = false
        if roomToLoad > 0 and INSTANCE.DOORSLOTS[roomToLoad] and INSTANCE.ROOMSLOTS[INSTANCE.ROOMCURSORPOSITION][1] ~= roomToLoad and shouldShowRoom(roomToLoad, AutoTracker:ReadU16(0x7e0022, 0), AutoTracker:ReadU16(0x7e0020, 0)) then
            if CONFIG.LAYOUT_ROOM_SLOT_METHOD == 2 then --always have the current room in slot 1
                local carried = INSTANCE.ROOMSLOTS[1][1]
                INSTANCE.ROOMSLOTS[1][1] = roomToLoad
                for r = 2, #INSTANCE.ROOMSLOTS do
                    if INSTANCE.ROOMSLOTS[r][1] == roomToLoad then
                        INSTANCE.ROOMSLOTS[r][1] = carried
                        break
                    end
                    local temp = INSTANCE.ROOMSLOTS[r][1]
                    INSTANCE.ROOMSLOTS[r][1] = carried
                    carried = temp
                end
                INSTANCE.ROOMCURSORPOSITION = 1
            elseif CONFIG.LAYOUT_ROOM_SLOT_METHOD == 3 then --always place the next room after the last
                INSTANCE.ROOMCURSORPOSITION = (INSTANCE.ROOMCURSORPOSITION % 4) + 1
                INSTANCE.ROOMSLOTS[INSTANCE.ROOMCURSORPOSITION][1] = roomToLoad
            else --method 1, default, prioritize replacing the oldest room
                local found = false
                for r = 1, #INSTANCE.ROOMSLOTS do
                    if INSTANCE.ROOMSLOTS[r][1] == roomToLoad then
                        INSTANCE.ROOMCURSORPOSITION = r
                        found = true
                        break
                    end
                end

                local age = INSTANCE.ROOMSLOTS[INSTANCE.ROOMCURSORPOSITION][2]
                for r = 1, #INSTANCE.ROOMSLOTS do
                    if found then
                        if INSTANCE.ROOMSLOTS[r][2] <= age and INSTANCE.ROOMSLOTS[r][2] ~= 0 then
                            INSTANCE.ROOMSLOTS[r][2] = (INSTANCE.ROOMSLOTS[r][2] % age) + 1
                        end
                    else
                        if INSTANCE.ROOMSLOTS[r][2] == 0 or INSTANCE.ROOMSLOTS[r][2] == 4 then
                            INSTANCE.ROOMCURSORPOSITION = r
                            if INSTANCE.ROOMSLOTS[r][2] == 0 then
                                INSTANCE.ROOMSLOTS[r][2] = 1
                                break
                            end
                            INSTANCE.ROOMSLOTS[r][2] = 1
                        else
                            INSTANCE.ROOMSLOTS[r][2] = INSTANCE.ROOMSLOTS[r][2] + 1
                        end
                    end
                end

                if not found then
                    INSTANCE.ROOMSLOTS[INSTANCE.ROOMCURSORPOSITION][1] = roomToLoad
                end
            end
            shouldUpdate = true
        end
        if shouldUpdate or forceUpdate then
            refreshDoorSlots()
        end
    end
end

function refreshDoorSlots()
    for r = 1, #INSTANCE.ROOMSLOTS do
        if INSTANCE.ROOMSLOTS[r][1] > 0 then
            local item = Tracker:FindObjectForCode("roomSlot" .. math.floor(r))
            local type = "rooms"
            local id = INSTANCE.ROOMSLOTS[r][1]
            if INSTANCE.ROOMSLOTS[r][1] >= 0x1000 then
                type = "overworld"
                id = INSTANCE.ROOMSLOTS[r][1] - 0x1000
            end
            if INSTANCE.ROOMCURSORPOSITION == r then
                item.Icon = ImageReference:FromPackRelativePath("images/maps/" .. type .. "/" .. string.format("%02x", id) .. ".png", "overlay|images/doortracker/overlays/highlighted.png")
            else
                item.Icon = ImageReference:FromPackRelativePath("images/maps/" .. type .. "/" .. string.format("%02x", id) .. ".png")
            end

            for d = 1, #INSTANCE.DOORSLOTS[INSTANCE.ROOMSLOTS[r][1]] do
                item = Tracker:FindObjectForCode("doorSlot" .. math.floor(r) .. "_" .. math.floor(d)).ItemState
                item:setState(INSTANCE.DOORSLOTS[INSTANCE.ROOMSLOTS[r][1]][d])
            end
        end
    end
end

function shouldChestCountUp()
    return OBJ_DOORSHUFFLE:getState() == 2 or OBJ_POOL_DUNGEONPOT:getState() > 1
end

function shouldShowRoom(roomId, xCoord, yCoord)
    if DATA.RoomNonLinearExclusions[roomId] then
        for i, rect in ipairs(DATA.RoomNonLinearExclusions[roomId]) do
            if xCoord >= rect[1] and xCoord <= rect[2] and yCoord >= rect[3] and yCoord <= rect[4] then
                return false
            end
        end
    end
    return true
end

function JObjectToLuaTable(obj)
    local ret = {}
    if obj:GetType():ToString() == "Newtonsoft.Json.Linq.JObject" then
        local vals = obj:GetValue("Values")
        local curKey = obj:GetValue("Keys").First
        local curVal = vals.First
        while (true)
        do
            if curVal:GetType():ToString() == "Newtonsoft.Json.Linq.JValue" then
                ret[tonumber(curKey:ToString())] = tonumber(curVal:ToString())
            else
                ret[tonumber(curKey:ToString())] = JObjectToLuaTable(curVal)
            end
            if curVal == vals.Last then
                break
            else
                curKey = curKey.Next
                curVal = curVal.Next
            end
        end
    end
    return ret
end
