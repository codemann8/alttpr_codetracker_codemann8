START_CLOCK = os.clock()
TRACKER_READY = false
NEW_KEY_SYSTEM = false

DUNGEON_PRIZE_DATA = 0x0000

ROOMCURSORPOSITION = 0
ROOMCURSORRECENT = 0
ROOMSLOTS = { 0, 0, 0, 0 }

DOORSLOTS = {--1 2  3   4  5  6   7  8  9   10 11 12  13 14 15 16
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

function loadDungeonChests()
    ExtendedConsumableItem("Hyrule Castle Items", "hc", "@Hyrule Castle & Escape")
    ExtendedConsumableItem("Eastern Palace Items", "ep", "@Eastern Palace")
    ExtendedConsumableItem("Desert Palace Items", "dp", "@Desert Palace")
    ExtendedConsumableItem("Tower of Hera Items", "toh", "@Tower of Hera")
    ExtendedConsumableItem("Aganihm's Tower Items", "at", "@Agahnim's Tower")
    ExtendedConsumableItem("Palace of Darkness Items", "pod", "@Palace of Darkness")
    ExtendedConsumableItem("Swamp Palace Items", "sp", "@Swamp Palace")
    ExtendedConsumableItem("Skull Woods Items", "sw", "@Skull Woods")
    ExtendedConsumableItem("Thieves Town Items", "tt", "@Thieves Town")
    ExtendedConsumableItem("Ice Palace Items", "ip", "@Ice Palace")
    ExtendedConsumableItem("Misery Mire Items", "mm", "@Misery Mire")
    ExtendedConsumableItem("Turtle Rock Items", "tr", "@Turtle Rock")
    ExtendedConsumableItem("Ganon's Tower Items", "gt", "@Ganon's Tower")
end

function loadMCBK()
    MapCompassBK("Hyrule Castle Map/Compass/Big Key", "hc")
    MapCompassBK("Eastern Palace Map/Compass/Big Key", "ep")
    MapCompassBK("Desert Palace Map/Compass/Big Key", "dp")
    MapCompassBK("Tower of Hera Map/Compass/Big Key", "toh")
    MapCompassBK("Aganihm's Tower Map/Compass/Big Key", "at")
    MapCompassBK("Palace of Darkness Map/Compass/Big Key", "pod")
    MapCompassBK("Swamp Palace Map/Compass/Big Key", "sp")
    MapCompassBK("Skull Woods Map/Compass/Big Key", "sw")
    MapCompassBK("Thieves Town Map/Compass/Big Key", "tt")
    MapCompassBK("Ice Palace Map/Compass/Big Key", "ip")
    MapCompassBK("Misery Mire Map/Compass/Big Key", "mm")
    MapCompassBK("Turtle Rock Map/Compass/Big Key", "tr")
    MapCompassBK("Ganon's Tower Map/Compass/Big Key", "gt")
end

function loadDynamicRequirement()
    DynamicRequirement("hc", "hc", 1, 923, 983)
    DynamicRequirement("hc", "hc", 2, 1008, 983)
    DynamicRequirement("ep", "eppod", 1, 1840, 862)
    DynamicRequirement("ep", "eppod", 2, 1925, 862)
    DynamicRequirement("dp", "dpmm", 1, 89, 1742)
    DynamicRequirement("dp", "dpmm", 2, 174, 1742)
    DynamicRequirement("toh", "tohgt", 1, 1056, 115)
    DynamicRequirement("toh", "tohgt", 2, 1141, 115)
    DynamicRequirement("at", "at", 1, 923, 627)
    DynamicRequirement("at", "at", 2, 1008, 862)
    DynamicRequirement("pod", "eppod", 1, 1840, 862)
    DynamicRequirement("pod", "eppod", 2, 1925, 862)
    DynamicRequirement("sp", "sp", 1, 860, 1910)
    DynamicRequirement("sp", "sp", 2, 945, 1910)
    DynamicRequirement("sw", "sw", 1, 2, 158)
    DynamicRequirement("sw", "sw", 2, 87, 158)
    DynamicRequirement("tt", "tt", 1, 174, 1018)
    DynamicRequirement("tt", "tt", 2, 259, 1018)
    DynamicRequirement("ip", "ip", 1, 1519, 1785)
    DynamicRequirement("ip", "ip", 2, 1604, 1785)
    DynamicRequirement("mm", "dpmm", 1, 89, 1742)
    DynamicRequirement("mm", "dpmm", 2, 174, 1742)
    DynamicRequirement("tr", "tr", 1, 1809, 196)
    DynamicRequirement("tr", "tr", 2, 1889, 196)
    DynamicRequirement("gt", "tohgt", 1, 1056, 115)
    DynamicRequirement("gt", "tohgt", 2, 1141, 115)
end

function loadDoorSlots()
    for g = 1, #RoomGroupSelection.Groups do
        RoomGroupSelection(g)
    end
    for r = 1, 9 do
        RoomSelectSlot(r)
    end
    for r = 1, #ROOMSLOTS do
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

function initGlobalVars()
    AUTOTRACKER_ON = false

    OBJ_MODULE = Tracker:FindObjectForCode("module")
    OBJ_OWAREA = Tracker:FindObjectForCode("owarea")
    OBJ_DUNGEON = Tracker:FindObjectForCode("dungeon")
    OBJ_ROOM = Tracker:FindObjectForCode("room")

    if Tracker.ActiveVariantUID ~= "items_only" then
        OBJ_WORLDSTATE = Tracker:FindObjectForCode("world_state_mode")
        OBJ_KEYSANITY_SMALL = Tracker:FindObjectForCode("keysanity_smallkey")
        OBJ_KEYSANITY_BIG = Tracker:FindObjectForCode("keysanity_bigkey")
        OBJ_ENTRANCE = Tracker:FindObjectForCode("entrance_shuffle")
        OBJ_DOORSHUFFLE = Tracker:FindObjectForCode("door_shuffle")
        OBJ_OWSHUFFLE = Tracker:FindObjectForCode("ow_shuffle")
        OBJ_RETRO = Tracker:FindObjectForCode("retro_mode")
        OBJ_POOL_KEYDROP = Tracker:FindObjectForCode("pool_keydrop")
        OBJ_GLITCH = Tracker:FindObjectForCode("glitch_mode")
        OBJ_RACEMODE = Tracker:FindObjectForCode("race_mode")

        OBJ_DOORDUNGEON = Tracker:FindObjectForCode("door_dungeonselect")
        OBJ_DOORCHEST = Tracker:FindObjectForCode("door_totalchest")
        OBJ_DOORKEY = Tracker:FindObjectForCode("door_totalkey")

        CaptureBadgeCache = {}

        --Auto-Toggle Race Mode
        if PREFERENCE_DEFAULT_RACE_MODE_ON then
            Tracker:FindObjectForCode("race_mode_surrogate").ItemState:setState(1)
        end

        --Default Selected Door Icon Selector
        Tracker:FindObjectForCode("doorslot_x").ItemState:setState(1)

        TRACKER_READY = true

        updateIcons()

        local message = "To get started: Select a Game Mode by clicking the Gear icon in the Items pane"
        ScriptHost:PushMarkdownNotification(NotificationType.Message, message)
    end

    TRACKER_READY = true
end

function updateIcons(updateDoorCounts)
    if not TRACKER_READY then
        for i = 1, #DungeonList do
            local item = Tracker:FindObjectForCode(DungeonList[i] .. "_item").ItemState
            item.SwapActions = (OBJ_DOORSHUFFLE and OBJ_DOORSHUFFLE.CurrentStage == 2 or false)
        end
    else
        for i = 1, #DungeonList do
            local item = Tracker:FindObjectForCode(DungeonList[i] .. "_item").ItemState
            local key = Tracker:FindObjectForCode(DungeonList[i] .. "_smallkey")
            if OBJ_DOORSHUFFLE.CurrentStage < 2 then
                local newMax = DungeonData[DungeonList[i]][2]
                if OBJ_POOL_KEYDROP.CurrentStage > 0 then
                    newMax = newMax + DungeonData[DungeonList[i]][3]
                end
                key.MaxCount = newMax

                if key.MaxCount == 0 then
                    key.Icon = ""
                end

                if OBJ_POOL_KEYDROP.CurrentStage > 0 and DungeonList[i] == "hc" then
                    local bk = Tracker:FindObjectForCode(DungeonList[i] .. "_bigkey")
                    bk.Icon = ImageReference:FromPackRelativePath("images/BigKey.png", (not bk.Active and "@disabled" or ""))
                elseif (OBJ_POOL_KEYDROP.CurrentStage == 0 and DungeonList[i] == "hc") or DungeonList[i] == "at" then
                    local bk = Tracker:FindObjectForCode(DungeonList[i] .. "_bigkey")
                    if bk.Icon ~= "" then
                        bk.Icon = ""
                    end
                end

                local found = 0
                if item.MaxCount ~= 99 then
                    found = item.MaxCount - item.AcquiredCount
                end

                local chest = Tracker:FindObjectForCode(DungeonList[i] .. "_chest")
                newMax = chest.MaxCount
                if OBJ_POOL_KEYDROP.CurrentStage > 0 then
                    newMax = newMax + DungeonData[DungeonList[i]][3] + (DungeonList[i] == "hc" and 1 or 0)
                end

                if Tracker:FindObjectForCode("keysanity_map").CurrentStage == 0 and DungeonList[i] ~= "at" then
                    newMax = newMax - 1
                end
                if Tracker:FindObjectForCode("keysanity_compass").CurrentStage == 0 and DungeonList[i] ~= "hc" and DungeonList[i] ~= "at" then
                    newMax = newMax - 1
                end
                if OBJ_KEYSANITY_SMALL.CurrentStage == 0 and key then
                    newMax = newMax - key.MaxCount
                end
                if OBJ_KEYSANITY_BIG.CurrentStage == 0 and DungeonList[i] ~= "at" and not (DungeonList[i] == "hc" and OBJ_POOL_KEYDROP.CurrentStage == 0) then
                    newMax = newMax - 1
                end
                item.MaxCount = newMax

                item.AcquiredCount = math.max(item.MaxCount - found, 0)

                --Link Dungeon Locations to Chest Items
                item:setProperty("section", Tracker:FindObjectForCode(item:getProperty("sectionName")))
                item:UpdateBadgeAndIcon()

                item.SwapActions = false
            end

            if EXPERIMENTAL_ENABLE_DYNAMIC_REQUIREMENTS then
                local dyn = Tracker:FindObjectForCode("dynreq_" .. DungeonList[i] .. "1_sur")
                if dyn then
                    dyn.ItemState:setState(OBJ_DOORSHUFFLE.CurrentStage == 2 and 1 or 0)
                end
                dyn = Tracker:FindObjectForCode("dynreq_" .. DungeonList[i] .. "2_sur")
                if dyn then
                    dyn.ItemState:setState(OBJ_DOORSHUFFLE.CurrentStage == 2 and 1 or 0)
                end
            end

            if OBJ_KEYSANITY_SMALL.CurrentStage == 2 then
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
        end

        local gtbk = Tracker:FindObjectForCode("gt_bkgame")
        if OBJ_DOORSHUFFLE.CurrentStage == 0 then
            if OBJ_POOL_KEYDROP.CurrentStage == 0 then
                gtbk.MaxCount = 22
            else
                gtbk.MaxCount = 25
            end
        elseif OBJ_DOORSHUFFLE.CurrentStage == 1 then
            if OBJ_POOL_KEYDROP.CurrentStage == 0 then
                gtbk.MaxCount = 27
            else
                gtbk.MaxCount = 31
            end
        else
            gtbk.MaxCount = 99
        end

        OBJ_DOORDUNGEON.ItemState:updateIcon()
        OBJ_DOORCHEST.ItemState:updateIcon()
        OBJ_DOORKEY.ItemState:updateIcon()
    end
end

function updateGhosts(list, clearSection, markHostedItem)
    for i,section in pairs(list) do
        updateGhost(section, clearSection, markHostedItem)
    end
end

function updateGhost(section, clearSection, markHostedItem)
    local tempSection = section:gsub("/", " Ghost/")
    local target = Tracker:FindObjectForCode(section)
    local hiddenTarget = Tracker:FindObjectForCode(tempSection)

    if target == nil or hiddenTarget == nil then
        print("Failed to resolve " .. section .. " please check for typos.")
        return false
    elseif target.CapturedItem and CaptureBadgeCache[target] and not hiddenTarget.Visible then
        removeGhost(section)
    end
    if target.CapturedItem ~= CaptureBadgeCache[target] and hiddenTarget.Visible then
        if CaptureBadgeCache[target.Owner] then
            hiddenTarget.Owner:RemoveBadge(CaptureBadgeCache[target.Owner])
            CaptureBadgeCache[target.Owner] = nil
            CaptureBadgeCache[target] = nil
        end
        if target.CapturedItem and hiddenTarget.Visible then
            CaptureBadgeCache[target.Owner] = hiddenTarget.Owner:AddBadge(target.CapturedItem.PotentialIcon)
            CaptureBadgeCache[target] = target.CapturedItem
            if clearSection then
                target.AvailableChestCount = 0
                target.CapturedItem = CaptureBadgeCache[target]
            end
            if markHostedItem then
                if target.HostedItem then
                    target.HostedItem.Active = true
                end
            end

            if OBJ_DOORSHUFFLE.CurrentStage == 2 and not target.Owner.Pinned and (string.match(tostring(target.CapturedItem.Icon.URI), "%-dungeon%-") or target.CapturedItem.Name == "Sanctuary Dropdown" or string.match(target.CapturedItem.Name, "^SW .* Dropdown")) then
                target.Owner.Pinned = true
            elseif PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE and not target.Owner.Pinned and (string.match(tostring(target.CapturedItem.Icon.URI), "%-item%-") or string.match(tostring(target.CapturedItem.Icon.URI), "%-misc%-")) then
                target.Owner.Pinned = true
            end

            if target.Owner.Pinned and target.CapturedItem.Name == "Dead Entrance" then
                target.Owner.Pinned = false
            end
        end
    end
end

function removeGhost(section)
    local tempSection = section:gsub("/", " Ghost/")
    local target = Tracker:FindObjectForCode(section)
    local hiddenTarget = Tracker:FindObjectForCode(tempSection)

    if target == nil or hiddenTarget == nil then
        print("Failed to resolve " .. section .. " please check for typos.")
    elseif CaptureBadgeCache[target] then
        hiddenTarget.Owner:RemoveBadge(CaptureBadgeCache[target.Owner])
        CaptureBadgeCache[target.Owner] = nil
        CaptureBadgeCache[target] = nil
    end
end

function updateDoorSlots(roomId, forceUpdate)
    local roomToLoad = roomId
    if LinkedRoomSurrogates[roomId] then
        roomToLoad = LinkedRoomSurrogates[roomId]
    end
    local shouldUpdate = false
    if roomToLoad > 0 and DOORSLOTS[roomToLoad] and ROOMSLOTS[ROOMCURSORPOSITION] ~= roomToLoad and shouldShowRoom(roomToLoad, AutoTracker:ReadU16(0x7e0022, 0), AutoTracker:ReadU16(0x7e0020, 0)) then
        if LAYOUT_ROOM_SLOT_METHOD == "top" then
            local carried = ROOMSLOTS[1]
            ROOMSLOTS[1] = roomToLoad
            for r = 2, #ROOMSLOTS do
                if ROOMSLOTS[r] == roomToLoad then
                    ROOMSLOTS[r] = carried
                    break
                end
                local temp = ROOMSLOTS[r]
                ROOMSLOTS[r] = carried
                carried = temp
            end
            ROOMCURSORPOSITION = 1
        elseif LAYOUT_ROOM_SLOT_METHOD == "next" then
            ROOMCURSORPOSITION = (ROOMCURSORPOSITION % 4) + 1
            ROOMSLOTS[ROOMCURSORPOSITION] = roomToLoad
        else
            local found = false
            for r = 1, #ROOMSLOTS do
                if ROOMSLOTS[r] == roomToLoad then
                    ROOMCURSORPOSITION = r
                    found = true
                    break
                end
            end
            if not found then
                ROOMCURSORPOSITION = (ROOMCURSORRECENT % 4) + 1
                ROOMCURSORRECENT = ROOMCURSORPOSITION
                ROOMSLOTS[ROOMCURSORPOSITION] = roomToLoad
            end
        end
        shouldUpdate = true
    end
    if shouldUpdate or forceUpdate then
        refreshDoorSlots()
    end
end

function refreshDoorSlots()
    for r = 1, #ROOMSLOTS do
        if ROOMSLOTS[r] > 0 then
            local item = Tracker:FindObjectForCode("roomSlot" .. math.floor(r))
            local type = "rooms"
            local id = ROOMSLOTS[r]
            if ROOMSLOTS[r] >= 0x1000 then
                type = "ow"
                id = ROOMSLOTS[r] - 0x1000
            end
            if ROOMCURSORPOSITION == r then
                item.Icon = ImageReference:FromPackRelativePath("images/" .. type .. "/" .. string.format("%02x", id) .. ".png", "overlay|images/overlay-highlighted.png")
            else
                item.Icon = ImageReference:FromPackRelativePath("images/" .. type .. "/" .. string.format("%02x", id) .. ".png")
            end

            for d = 1, #DOORSLOTS[ROOMSLOTS[r]] do
                item = Tracker:FindObjectForCode("doorSlot" .. math.floor(r) .. "_" .. math.floor(d)).ItemState
                item:setState(DOORSLOTS[ROOMSLOTS[r]][d])
            end
        end
    end
end

function shouldShowRoom(roomId, xCoord, yCoord)
    if RoomNonLinearExclusions[roomId] then
        for i, rect in ipairs(RoomNonLinearExclusions[roomId]) do
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
