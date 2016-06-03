local Game = {
	["Memory"] = {
		-- Version order: Europe, Japan, US 1.1, US 1.0
		["slope_timer"] = {0x37CCB4, 0x37CDE4, 0x37B4E4, 0x37C2E4},
		["player_grounded"] = {0x37C930, 0x37CA60, 0x37B160, 0x37BF60},
		["x_velocity"] = {0x37CE88, 0x37CFB8, 0x37B6B8, 0x37C4B8},
		["y_velocity"] = {0x37CE8C, 0x37CFBC, 0x37B6BC, 0x37C4BC},
		["z_velocity"] = {0x37CE90, 0x37CFC0, 0x37B6C0, 0x37C4C0},
		["x_position"] = {0x37CF70, 0x37D0A0, 0x37B7A0, 0x37C5A0},
		["y_position"] = {0x37CF74, 0x37D0A4, 0x37B7A4, 0x37C5A4},
		["z_position"] = {0x37CF78, 0x37D0A8, 0x37B7A8, 0x37C5A8},
		["x_rotation"] = {0x37CF10, 0x37D040, 0x37B740, 0x37C540},
		["y_rotation"] = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
		["facing_angle"] = {0x37D060, 0x37D190, 0x37B890, 0x37C690},
		["moving_angle"] = {0x37D064, 0x37D194, 0x37B894, 0x37C694},
		["z_rotation"] = {0x37D050, 0x37D180, 0x37B880, 0x37C680},
		["current_movement_state"] = {0x37DB34, 0x37DC64, 0x37C364, 0x37D164},
	},
};

local ROMHash = gameinfo.getromhash();
if ROMHash == "BB359A75941DF74BF7290212C89FBC6E2C5601FE" then -- Europe
	Game.version = 1;
elseif ROMHash == "90726D7E7CD5BF6CDFD38F45C9ACBF4D45BD9FD8" then -- Japan
	Game.version = 2;
elseif ROMHash == "DED6EE166E740AD1BC810FD678A84B48E245AB80" then -- US 1.1
	Game.version = 3;
elseif ROMHash == "1FE1632098865F639E22C11B9A81EE8F29C75D7A" then -- US 1.0
	Game.version = 4;
else
	print("This game is not supported.");
	return false;
end

local precision = 3;
function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

function Game.getXPosition()
	return mainmemory.readfloat(Game.Memory.x_position[Game.version], true);
end

function Game.getYPosition()
	return mainmemory.readfloat(Game.Memory.y_position[Game.version], true);
end

function Game.getZPosition()
	return mainmemory.readfloat(Game.Memory.z_position[Game.version], true);
end

function Game.getVelocity()
	local vX = mainmemory.readfloat(Game.Memory.x_velocity[Game.version], true);
	local vZ = mainmemory.readfloat(Game.Memory.z_velocity[Game.version], true);
	return math.sqrt(vX*vX + vZ*vZ);
end

function Game.getYVelocity()
	return mainmemory.readfloat(Game.Memory.y_velocity[Game.version], true);
end

function Game.getXRotation()
	return mainmemory.readfloat(Game.Memory.x_rotation[Game.version], true);
end

function Game.getMovingAngle()
	return mainmemory.readfloat(Game.Memory.moving_angle[Game.version], true);
end

function Game.getGroundState()
	return tostring(mainmemory.read_u32_be(Game.Memory.player_grounded[Game.version]) > 0);
end

function Game.getSlopeTimer()
	return mainmemory.readfloat(Game.Memory.slope_timer[Game.version], true);
end

local movementStates = {
	[0] = "Null",
	[1] = "Idle",
	[2] = "Walking", -- Slow
	[3] = "Walking",
	[4] = "Walking", -- Fast
	[5] = "Jumping",
	[6] = "Bear punch",
	[7] = "Crouching",
	[8] = "Jumping", -- Talon Trot
	[9] = "Shooting Egg",
	[10] = "Pooping Egg",

	[12] = "Skidding",
	[14] = "Damaged",
	[15] = "Beak Buster",
	[16] = "Feathery Flap",
	[17] = "Rat-a-tat rap",
	[18] = "Backflip", -- Flap Flip
	[19] = "Beak Barge",

	[20] = "Entering Talon Trot",
	[21] = "Idle", -- Talon Trot
	[22] = "Walking", -- Talon Trot
	[23] = "Leaving Talon Trot",
	[24] = "Knockback", -- Flying

	[26] = "Entering Wonderwing",
	[27] = "Idle", -- Wonderwing
	[28] = "Walking", -- Wonderwing
	[29] = "Jumping", -- Wonderwing
	[30] = "Leaving Wonderwing",

	[31] = "Creeping",
	[32] = "Landing", -- After Jump
	[33] = "Charging Shock Spring Jump",
	[34] = "Shock Spring Jump",
	[35] = "Taking Flight",
	[36] = "Flying",
	[37] = "Entering Wading Boots",
	[38] = "Idle", -- Wading Boots
	[39] = "Walking", -- Wading Boots

	[40] = "Jumping", -- Wading Boots
	[41] = "Leaving Wading Boots",
	[42] = "Beak Bomb",
	[43] = "Idle", -- Underwater
	[44] = "Swimming (B)",
	[45] = "Idle", -- Treading water
	[46] = "Paddling",

	[47] = "Falling", -- After pecking
	[48] = "Diving",

	[49] = "Rolling",
	[50] = "Slipping",

	[52] = "Jig", -- Note door
	[53] = "Idle", -- Termite
	[54] = "Walking", -- Termite
	[55] = "Jumping", -- Termite
	[56] = "Falling", -- Termite
	[57] = "Swimming (A)",
	[58] = "Idle", -- Carrying object (eg. Orange)
	[59] = "Walking", -- Carrying object (eg. Orange)

	[61] = "Falling", -- Tumbling, will take damage
	[62] = "Damaged", -- Termite

	[64] = "Locked", -- Pumpkin: Pipe
	[65] = "Death",
	[68] = "Jig", -- Jiggy
	[69] = "Slipping", -- Talon Trot

	[72] = "Idle", -- Pumpkin
	[73] = "Walking", -- Pumpkin
	[74] = "Jumping", -- Pumpkin
	[75] = "Falling", -- Pumpkin
	[76] = "Landing", -- In water
	[77] = "Damaged", -- Pumpkin
	[78] = "Death", -- Pumpkin
	[79] = "Idle", -- Holding tree, pole, etc.

	[80] = "Climbing", -- Tree, pole, etc.
	[81] = "Leaving Climb",
	[82] = "Tumblar", -- Standing on Tumblar
	[83] = "Tumblar", -- Standing on Tumblar

	[84] = "Death", -- Drowning
	[85] = "Slipping", -- Wading Boots
	[86] = "Knockback", -- Successful enemy damage
	[87] = "Beak Bomb", -- Ending
	[88] = "Damaged", -- Beak Bomb
	[89] = "Damaged", -- Beak Bomb

	[90] = "Loading Zone",
	[91] = "Throwing", -- Throwing object (eg. Orange)

	[94] = "Idle", -- Croc
	[95] = "Walking", -- Croc
	[96] = "Jumping", -- Croc
	[97] = "Falling", -- Croc
	[99] = "Damaged", -- Croc
	[100] = "Death", -- Croc

	[103] = "Idle", -- Walrus
	[104] = "Walking", -- Walrus
	[105] = "Jumping", -- Walrus
	[106] = "Falling", -- Walrus
	[107] = "Locked", -- Bee, Mumbo Transform Cutscene
	[108] = "Knockback", -- Walrus
	[109] = "Death", -- Walrus
	[110] = "Biting", -- Croc

	[113] = "Falling", -- Talon Trot
	[114] = "Recovering", -- Getting up after taking damage, eg. fall famage
	[115] = "Locked", -- Cutscene
	[116] = "Locked", -- Jiggy pad, Mumbo transformation, Bottles
	[117] = "Locked", -- Bottles

	[121] = "Locked", -- Holding Jiggy, Talon Trot
	[122] = "Creeping", -- In damaging water etc
	[123] = "Damaged", -- Talon Trot
	[124] = "Locked", -- Sled in FP sliding down scarf
	[127] = "Damaged", -- Swimming

	[133] = "Idle", -- Bee
	[134] = "Walking", -- Bee
	[135] = "Jumping", -- Bee
	[136] = "Falling", -- Bee
	[137] = "Damaged", -- Bee
	[138] = "Death", -- Bee

	[140] = "Flying", -- Bee
	[141] = "Locked", -- Mumbo transformation, Mr. Vile
	[142] = "Locked", -- Jiggy podium, Bottles' text outside Mumbo's
	[143] = "Locked", -- Pumpkin
	[145] = "Damaged", -- Flying
	[147] = "Locked", -- Pumpkin?
	[148] = "Locked", -- Mumbo transformation
	[149] = "Locked", -- Walrus?

	[150] = "Locked", -- Paddling
	[151] = "Locked", -- Swimming
	[152] = "Locked", -- Loading zone, Mumbo transformation
	[153] = "Locked", -- Flying
	[154] = "Locked", -- Talon Trot
	[157] = "Locked", -- Bee?
	[159] = "Knockback", -- Termite, not damaged
	[160] = "Knockback", -- Pumpkin, not damaged
	[161] = "Knockback", -- Croc, not damaged
	[162] = "Knockback", -- Walrus, not damaged
	[163] = "Knockback", -- Bee, not damaged
	[165] = "Locked", -- Wonderwing
};

function Game.getCurrentMovementState()
	local currentMovementState = mainmemory.read_u32_be(Game.Memory.current_movement_state[Game.version]);
	if type(movementStates[currentMovementState]) ~= "nil" then
		return movementStates[currentMovementState];
	end
	return "Unknown ("..currentMovementState..")";
end

local OSD = {
	{"X", Game.getXPosition},
	{"Y", Game.getYPosition},
	{"Z", Game.getZPosition},
	{"Separator", 1},
	{"Velocity", Game.getVelocity};
	{"Y Velocity", Game.getYVelocity},
	{"Separator", 1},
	{"X Rotation", Game.getXRotation},
	{"Angle", Game.getMovingAngle},
	{"Separator", 1},
	{"Movement", Game.getCurrentMovementState},
	{"On Ground", Game.getGroundState},
	{"Slope Timer", Game.getSlopeTimer},
};

local function drawOSD()
	local row = 0;
	local OSDX = 2;
	local OSDY = 70;

	for i = 1, #OSD do
		local label = OSD[i][1];
		local value = OSD[i][2];

		if label ~= "Separator" then
			-- Get the value
			if type(value) == "function" then
				value = value();
			end

			-- Round the value
			if type(value) == "number" then
				value = round(value, precision);
			end

			gui.text(OSDX, OSDY + 16 * row, label..": "..value);
		else
			if type(value) == "number" and value > 1 then
				row = row + value - 1;
			end
		end
		row = row + 1;
	end
end

while true do
	drawOSD();
	emu.yield();
end