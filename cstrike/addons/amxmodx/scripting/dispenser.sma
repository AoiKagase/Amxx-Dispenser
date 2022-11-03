#pragma compress 1

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <fun>

//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 190
	#assert "AMX Mod X v1.9.0 or Higher library required!"
#endif
#pragma semicolon 1
#pragma tabsize 4

#define PLUGIN  			"Dispenser"
#define VERSION 			"0.1"
#define AUTHOR  			"Aoi.Kagase"

#define PREFIX_CHAT 		"[DISPENSER]"

#define ENT_DISPENSER 		"dispenser"
#define ENT_DISPENSER_MOVE	"dispenser_move"
#define ENT_BREAKABLE 		"func_breakable"

#define is_valid_player(%1) (1 <= %1 <= MaxClients)

#define TASK_ANIM 			4875154
#define TASK_IDLE_SOUND 	154879321
#define TASK_LIGHT 			114879321
#define ID_ANIM 			(iTaskID - TASK_ANIM)
#define ADMIN_ACCESSLEVEL	ADMIN_LEVEL_H

new const Float:xStuckSize[][3] =
{
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
};

enum E_CVARS
{
	// Price.
	CV_LVL1_PRICE,
	CV_LVL2_PRICE,
	CV_LVL3_PRICE,
	CV_LVL4_PRICE,

	// Max recovcery health.
	CV_LVL1_MAX_HP,
	CV_LVL2_MAX_HP,
	CV_LVL3_MAX_HP,
	CV_LVL4_MAX_HP,

	// Amount of recovery health.
	Float:CV_LVL1_AMOUNT_HP,
	Float:CV_LVL2_AMOUNT_HP,
	Float:CV_LVL3_AMOUNT_HP,
	Float:CV_LVL4_AMOUNT_HP,

	// Max recovery armor.
	CV_LVL1_MAX_ARMOR,
	CV_LVL2_MAX_ARMOR,
	CV_LVL3_MAX_ARMOR,
	CV_LVL4_MAX_ARMOR,

	// Amount of recovery aromr.
	Float:CV_LVL1_AMOUNT_ARMOR,
	Float:CV_LVL2_AMOUNT_ARMOR,
	Float:CV_LVL3_AMOUNT_ARMOR,
	Float:CV_LVL4_AMOUNT_ARMOR,

	// Dispenser health.
	CV_LVL1_DISPENSER_HEALTH,
	CV_LVL2_DISPENSER_HEALTH,
	CV_LVL3_DISPENSER_HEALTH,
	CV_LVL4_DISPENSER_HEALTH,

	CV_RECOVERY_TIME,
	Float:CV_RECOVERY_RADIUS,
	CV_DESTRUCTION_BONUS,

	CV_GIVE_MONEY_TIME,
	Float:CV_GIVE_MONEY_DISTANCE,
	CV_GIVE_MONEY_MIN,
	CV_GIVE_MONEY_MAX,

	CV_GIVE_AMMO_TIME,
	Float:CV_GIVE_AMMO_DISTANCE,
	CV_GIVE_AMMO_MIN,
	CV_GIVE_AMMO_MAX,

	CV_LIMIT_PER_PLAYER,
	CV_LIMIT_PER_TEAM,

	CV_GLOW,
	CV_LIGHT,
	CV_SHOW_LINE,
	CV_SHOW_LIFE_SPRITE,
	CV_EFFECT_LVL_4,
	CV_IDLE_SOUND,

	CV_AUTOMATIC_STUCK,
	CV_REMOVE_ROUND_RESTART,
	CV_DROP_TO_BUY,
	CV_GIVE_AMMO_ALL_LVL,
	CV_INSTANT_PLANT
};

enum E_CVARS_KEY
{
	// Price.
	CL_LVL1_PRICE,
	CL_LVL2_PRICE,
	CL_LVL3_PRICE,
	CL_LVL4_PRICE,

	// Max recovcery health.
	CL_LVL1_MAX_HP,
	CL_LVL2_MAX_HP,
	CL_LVL3_MAX_HP,
	CL_LVL4_MAX_HP,

	// Amount of recovery health.
	CL_LVL1_AMOUNT_HP,
	CL_LVL2_AMOUNT_HP,
	CL_LVL3_AMOUNT_HP,
	CL_LVL4_AMOUNT_HP,

	// Max recovery armor.
	CL_LVL1_MAX_ARMOR,
	CL_LVL2_MAX_ARMOR,
	CL_LVL3_MAX_ARMOR,
	CL_LVL4_MAX_ARMOR,

	// Amount of recovery aromr.
	CL_LVL1_AMOUNT_ARMOR,
	CL_LVL2_AMOUNT_ARMOR,
	CL_LVL3_AMOUNT_ARMOR,
	CL_LVL4_AMOUNT_ARMOR,

	// Dispenser health.
	CL_LVL1_DISPENSER_HEALTH,
	CL_LVL2_DISPENSER_HEALTH,
	CL_LVL3_DISPENSER_HEALTH,
	CL_LVL4_DISPENSER_HEALTH,

	CL_RECOVERY_TIME,
	CL_RECOVERY_RADIUS,
	CL_DESTRUCTION_BONUS,

	CL_GIVE_MONEY_TIME,
	CL_GIVE_MONEY_DISTANCE,
	CL_GIVE_MONEY_MIN,
	CL_GIVE_MONEY_MAX,

	CL_GIVE_AMMO_TIME,
	CL_GIVE_AMMO_DISTANCE,
	CL_GIVE_AMMO_MIN,
	CL_GIVE_AMMO_MAX,

	CL_LIMIT_PER_PLAYER,
	CL_LIMIT_PER_TEAM,

	CL_GLOW,
	CL_LIGHT,
	CL_SHOW_LINE,
	CL_SHOW_LIFE_SPRITE,
	CL_EFFECT_LVL_4,
	CL_IDLE_SOUND,

	CL_AUTOMATIC_STUCK,
	CL_REMOVE_ROUND_RESTART,
	CL_DROP_TO_BUY,
	CL_GIVE_AMMO_ALL_LVL,
	CL_INSTANT_PLANT
};

new const g_CVarString	[E_CVARS_KEY][][] =
{
	// Price.
	{"dispenser_level1_price",			"1000",	"num"},	
	{"dispenser_level2_price",			"2000",	"num"},	
	{"dispenser_level3_price",			"3000",	"num"},	
	{"dispenser_level4_price",			"4000",	"num"},	

	// Max recovcery health.
	{"dispenser_level1_max_hp",			"110",	"num"},
	{"dispenser_level2_max_hp",			"120",	"num"},
	{"dispenser_level3_max_hp",			"130",	"num"},
	{"dispenser_level4_max_hp",			"150",	"num"},

	// Amount of recovery health.
	{"dispenser_level1_amount_hp",		"1.0",	"float"},
	{"dispenser_level2_amount_hp",		"1.5",	"float"},
	{"dispenser_level3_amount_hp",		"2.0",	"float"},
	{"dispenser_level4_amount_hp",		"2.5",	"float"},

	// Max recovery armor.
	{"dispenser_level1_max_armor",		"0",	"num"},
	{"dispenser_level2_max_armor",		"20",	"num"},
	{"dispenser_level3_max_armor",		"30",	"num"},
	{"dispenser_level4_max_armor",		"80",	"num"},

	// Amount of recovery aromr.
	{"dispenser_level1_amount_armor",	"1.0",	"float"},
	{"dispenser_level2_amount_armor",	"1.5",	"float"},
	{"dispenser_level3_amount_armor",	"2.0",	"float"},
	{"dispenser_level4_amount_armor",	"2.5",	"float"},

	// Amount of recovery aromr.
	{"dispenser_level1_health",			"800",	"num"},
	{"dispenser_level2_health",			"1400",	"num"},
	{"dispenser_level3_health",			"2100",	"num"},
	{"dispenser_level4_health",			"3200",	"num"},

	{"dispenser_recovery_time",			"1",	"num"},
	{"dispenser_recovery_radius",		"500.0","float"},
	{"dispenser_destruction_bonus",		"1000",	"num"},

	// Give Money Settings.
	{"dispenser_give_money_time",		"5",	"num"},
	{"dispenser_give_money_distance",	"200.0","float"},
	{"dispenser_give_money_min",		"10",	"num"},
	{"dispenser_give_money_max",		"50",	"num"},

	// Give Ammo Settings.
	{"dispenser_give_ammo_time",		"1",	"num"},
	{"dispenser_give_ammo_distance",	"400.0","float"},
	{"dispenser_give_ammo_min",			"1",	"num"},
	{"dispenser_give_ammo_max",			"1",	"num"},

	{"dispenser_limit_per_player",		"1",	"num"},
	{"dispenser_limit_per_team",		"5",	"num"},

	{"dispenser_glow",					"1",	"num"},
	{"dispenser_light",					"1",	"num"},
	{"dispenser_show_line",				"1",	"num"},
	{"dispenser_show_life_sprite",		"0",	"num"},
	{"dispenser_level4_effect",			"0",	"num"},
	{"dispenser_idle_sound",			"1",	"num"},

	{"dispenser_automatic_stuck",		"1",	"num"},

	{"dispenser_restart_remove",		"1",	"num"},
	{"dispenser_drop_to_buy",			"1",	"num"},

	// Give Ammo Dispenser Level. 1 = All Level. 0 = Level 4 only.
	{"dispenser_give_ammo_all_level",	"1",	"num"},
	{"dispenser_instant_plant",			"0",	"num"},
};

new g_CvarPointer	[E_CVARS_KEY];
new g_Cvars			[E_CVARS];

new const g_WeaponsAmmo[CSW_LAST_WEAPON + 1][2] =
{
	{0,  0},	// #define CSW_NONE            0
	{13, 52},	// #define CSW_P228            1
	{0,  0},	// #define CSW_GLOCK           2  // Unused by game, See CSW_GLOCK18.
	{10, 90},	// #define CSW_SCOUT           3
	{0,	 0},	// #define CSW_HEGRENADE       4
	{7,	 32},	// #define CSW_XM1014          5
	{0,	 0},	// #define CSW_C4              6
	{30, 100},	// #define CSW_MAC10           7
	{30, 90},	// #define CSW_AUG             8
	{0,	 0},	// #define CSW_SMOKEGRENADE    9
	{30, 120},	// #define CSW_ELITE           10
	{20, 100},	// #define CSW_FIVESEVEN       11
	{25, 100},	// #define CSW_UMP45           12
	{30, 90},	// #define CSW_SG550           13
	{35, 90},	// #define CSW_GALIL           14
	{25, 90},	// #define CSW_FAMAS           15
	{12, 100},	// #define CSW_USP             16
	{20, 120},	// #define CSW_GLOCK18         17
	{10, 30},	// #define CSW_AWP             18
	{30, 120},	// #define CSW_MP5NAVY         19
	{100,200},	// #define CSW_M249            20
	{8,	 32},	// #define CSW_M3              21
	{30, 90},	// #define CSW_M4A1            22
	{30, 120},	// #define CSW_TMP             23
	{20, 90},	// #define CSW_G3SG1           24
	{0,	 0},	// #define CSW_FLASHBANG       25
	{7,	 35},	// #define CSW_DEAGLE          26
	{30, 90},	// #define CSW_SG552           27
	{30, 90},	// #define CSW_AK47            28
	{0,	 0},	// #define CSW_KNIFE           29
	{50, 100},	// #define CSW_P90             30
};

new const g_DamageSounds[][] =
{
	"debris/metal1.wav",
	"debris/metal2.wav",
	"debris/metal3.wav"
};

new const g_BulletsSounds[][] =
{
	"dispenser/dispenser_bullet_chain.wav",
	"dispenser/dispenser_bullet_chain2.wav"
};

enum E_DISPENSER_SOUND
{
	SND_ACTIVE,
	SND_FAIL,
	SND_EXPLODE,
	SND_IDLE,
};

enum
{
	ANIM_LVL1_IDLE,
	ANIM_LVL1_BUILD,
	ANIM_LVL2_IDLE,
	ANIM_LVL2_BUILD,
	ANIM_LVL3_IDLE,
	ANIM_LVL3_BUILD
};

new const g_DispenserSound[E_DISPENSER_SOUND][] = 
{
	"dispenser/dispenser_generate_metal.wav",
	"dispenser/dispenser_fail.wav",
	"dispenser/dispenser_explode.wav",
	"dispenser/dispenser_idle.wav",
};

enum
{
	BUILD_DISPENSER_YES,
	BUILD_DISPENSER_NO,
};

enum _:E_MODELS
{
	MDL_BLUEPRINT,
	MDL_DISPENSER,
	MDL_GIBS_R,
	MDL_GIBS_B,
};

enum E_SPRITES
{
	SPR_SMOKE,
	SPR_HEAL_LIFE_R,
	SPR_HEAL_LIFE_B,
	SPR_FLARE,
	SPR_LASER,
};

new const g_DispenserModels[E_MODELS][] = 
{
	"models/dispenser/dispenser_blueprint.mdl",
	"models/dispenser/dispenser.mdl",
	"models/dispenser/dispenser_gibs_r.mdl",
	"models/dispenser/dispenser_gibs_b.mdl",
};

new const g_DispenserSprites[E_SPRITES][] =
{
	"sprites/dispenser/dispenser_smoke.spr",
	"sprites/dispenser/healbeam_blue.spr",
	"sprites/dispenser/healbeam_red.spr",
	"sprites/flare3.spr",
	"sprites/laserbeam.spr",
};

enum _:E_TIMERS
{
	TIME_RECOVERY,
	TIME_GIVE_MONEY,
	TIME_GIVE_AMMO,
	TIME_POST_THINK,
	TIME_PLANT_HUD,
	TIME_FLOOD_TOUCH,
}

new const Float:g_Color[CsTeams][] =
{
	{0.0,0.0,0.0},		// Unknown.
	{255.0,0.0,0.0},	// Terrists RED
	{0.0,0.0,255.0},	// Counter-Terrists BLUE
	{0.0,0.0,0.0},		// Spectator
};

new Array:g_Dispensers	[MAX_PLAYERS + 1];
new g_PlayerMoving		[MAX_PLAYERS + 1];
new Float:g_Timers		[MAX_PLAYERS + 1][E_TIMERS];

new g_PrecacheModels	[E_MODELS], 
	g_PrecacheSprites	[E_SPRITES];

new g_iPlantOk[33];
new g_MenuCallback;
new xStuck[33];

#define DISPENSER_OWNER pev_iuser2
#define DISPENSER_LEVEL pev_iuser3
#define DISPENSER_TEAM 	pev_iuser4

stock E_CVARS:get_cvar_key(E_CVARS_KEY:key)
{
	switch (key)
	{
		// Price.
		case CL_LVL1_PRICE:				return CV_LVL1_PRICE;
		case CL_LVL2_PRICE:				return CV_LVL2_PRICE;
		case CL_LVL3_PRICE:				return CV_LVL3_PRICE;
		case CL_LVL4_PRICE:				return CV_LVL4_PRICE;

		// Max recovcery health.
		case CL_LVL1_MAX_HP:			return CV_LVL1_MAX_HP;
		case CL_LVL2_MAX_HP:			return CV_LVL2_MAX_HP;
		case CL_LVL3_MAX_HP:			return CV_LVL3_MAX_HP;
		case CL_LVL4_MAX_HP:			return CV_LVL4_MAX_HP;

		// Amount of recovery health.
		case CL_LVL1_AMOUNT_HP:			return CV_LVL1_AMOUNT_HP;
		case CL_LVL2_AMOUNT_HP:			return CV_LVL2_AMOUNT_HP;
		case CL_LVL3_AMOUNT_HP:			return CV_LVL3_AMOUNT_HP;
		case CL_LVL4_AMOUNT_HP:			return CV_LVL4_AMOUNT_HP;

		// Max recovery armor.
		case CL_LVL1_MAX_ARMOR:			return CV_LVL1_MAX_ARMOR;
		case CL_LVL2_MAX_ARMOR:			return CV_LVL2_MAX_ARMOR;
		case CL_LVL3_MAX_ARMOR:			return CV_LVL3_MAX_ARMOR;
		case CL_LVL4_MAX_ARMOR:			return CV_LVL4_MAX_ARMOR;

		// Amount of recovery aromr.
		case CL_LVL1_AMOUNT_ARMOR:		return CV_LVL1_AMOUNT_ARMOR;
		case CL_LVL2_AMOUNT_ARMOR:		return CV_LVL2_AMOUNT_ARMOR;
		case CL_LVL3_AMOUNT_ARMOR:		return CV_LVL3_AMOUNT_ARMOR;
		case CL_LVL4_AMOUNT_ARMOR:		return CV_LVL4_AMOUNT_ARMOR;

		// Dispenser health.
		case CL_LVL1_DISPENSER_HEALTH:	return CV_LVL1_DISPENSER_HEALTH;
		case CL_LVL2_DISPENSER_HEALTH:	return CV_LVL2_DISPENSER_HEALTH;
		case CL_LVL3_DISPENSER_HEALTH:	return CV_LVL3_DISPENSER_HEALTH;
		case CL_LVL4_DISPENSER_HEALTH:	return CV_LVL4_DISPENSER_HEALTH;

		case CL_RECOVERY_TIME:			return CV_RECOVERY_TIME;
		case CL_RECOVERY_RADIUS:		return CV_RECOVERY_RADIUS;
		case CL_DESTRUCTION_BONUS:		return CV_DESTRUCTION_BONUS;

		case CL_GIVE_MONEY_TIME:		return CV_GIVE_MONEY_TIME;
		case CL_GIVE_MONEY_DISTANCE:	return CV_GIVE_MONEY_DISTANCE;
		case CL_GIVE_MONEY_MIN:			return CV_GIVE_MONEY_MIN;
		case CL_GIVE_MONEY_MAX:			return CV_GIVE_MONEY_MAX;

		case CL_GIVE_AMMO_TIME:			return CV_GIVE_AMMO_TIME;
		case CL_GIVE_AMMO_DISTANCE:		return CV_GIVE_AMMO_DISTANCE;
		case CL_GIVE_AMMO_MIN:			return CV_GIVE_AMMO_MIN;
		case CL_GIVE_AMMO_MAX:			return CV_GIVE_AMMO_MAX;

		case CL_LIMIT_PER_PLAYER:		return CV_LIMIT_PER_PLAYER;
		case CL_LIMIT_PER_TEAM:			return CV_LIMIT_PER_TEAM;

		case CL_GLOW:					return CV_GLOW;
		case CL_LIGHT:					return CV_LIGHT;
		case CL_SHOW_LINE:				return CV_SHOW_LINE;
		case CL_SHOW_LIFE_SPRITE:		return CV_SHOW_LIFE_SPRITE;
		case CL_EFFECT_LVL_4:			return CV_EFFECT_LVL_4;
		case CL_IDLE_SOUND:				return CV_IDLE_SOUND;

		case CL_AUTOMATIC_STUCK:		return CV_AUTOMATIC_STUCK;
		case CL_REMOVE_ROUND_RESTART:	return CV_REMOVE_ROUND_RESTART;
		case CL_DROP_TO_BUY:			return CV_DROP_TO_BUY;
		case CL_GIVE_AMMO_ALL_LVL:		return CV_GIVE_AMMO_ALL_LVL;
		case CL_INSTANT_PLANT:			return CV_INSTANT_PLANT;
	}
	return CV_LVL1_PRICE;
}

// ====================================================
//  Register Cvars.
// ====================================================
stock register_cvars()
{
	new E_CVARS:key;
	for(new E_CVARS_KEY:i = CL_LVL1_PRICE; i < E_CVARS_KEY; i++)
	{
		key = get_cvar_key(i);
		g_CvarPointer[i] = create_cvar(g_CVarString[i][0], g_CVarString[i][1]);
		if (equali(g_CVarString[i][2], "num"))
			bind_pcvar_num(g_CvarPointer[i], g_Cvars[key]);
		else if (equali(g_CVarString[i][2], "float"))
			bind_pcvar_float(g_CvarPointer[i], Float:g_Cvars[key]);
		
		hook_cvar_change(g_CvarPointer[i], "cvar_change_callback");
	}
}

// ====================================================
//  Callback cvar change.
// ====================================================
public cvar_change_callback(pcvar, const old_value[], const new_value[])
{
	new E_CVARS:key;
	for(new E_CVARS_KEY:i = CL_LVL1_PRICE; i < E_CVARS_KEY; i++)
	{
		key = get_cvar_key(i);
		if (g_CvarPointer[i] == pcvar)
		{
			if (equali(g_CVarString[i][2], "num"))
				g_Cvars[key] = str_to_num(new_value);
			else if (equali(g_CVarString[i][2], "float"))
				g_Cvars[key] = _:str_to_float(new_value);

			console_print(0,"[Cvar Debug]: Changed Cvar '%s' => '%s' to '%s'", g_CVarString[i][0], old_value, new_value);
		}
	}
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("say",  		"say_cmd");
	register_clcmd("say_team",  "say_cmd");
	register_clcmd("drop", 		"HookDrop");
	
	register_cvars();
	register_event("HLTV", 		"EventNewRound", "a", "1=0", "2=0");
	register_forward(FM_TraceLine,		"PlayerTraceLinePost", true);
	register_forward(FM_CmdStart,		"PlayerCmdStart");
	register_forward(FM_PlayerPreThink,	"PlayerPreThink");

	RegisterHam(Ham_Touch, 		 		ENT_BREAKABLE, "DispenserTouch");
	RegisterHam(Ham_Think, 		 		ENT_BREAKABLE, "DispenserThink");
	RegisterHam(Ham_TakeDamage,  		ENT_BREAKABLE, "ham_TakeDamagePost", true);
	RegisterHam(Ham_TakeDamage,  		ENT_BREAKABLE, "ham_TakeDamagePre", false);
	RegisterHam(Ham_TraceAttack, 		ENT_BREAKABLE, "ham_TraceAttackPre", false);

	Initialize();
	g_MenuCallback = menu_makecallback("DispenserMenuCallback");
	set_task(0.1, "xCheckStuck", _, _, _, "b");
	//set_task(500.0, "xSitePub", _, _, _, "b")
}

Initialize()
{
	for(new i = 0; i < sizeof(g_Dispensers); i++)
		g_Dispensers[i] = ArrayCreate();
}

public say_cmd(id)
{
	new said[32];
	read_argv(1, said, charsmax(said));

	if (equali(said, "/buy dispenser"))
	{
		BuyDispenser(id);
	} else
	if (equali(said, "/destroy dispenser"))
	{
		DestroyDispenser(id);
	}
}

public HookDrop(id)
{
	static weapon;

	weapon = get_user_weapon(id);

	if (weapon == CSW_KNIFE && g_Cvars[CV_DROP_TO_BUY])
	{
		BuyDispenser(id);
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

stock bool:is_hull_vacant(const Float:origin[3], hull, id)
{
	static tr;
	tr = create_tr2();
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr);
	
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
	{
		free_tr2(tr);
		return true;
	}
	free_tr2(tr);
	return false;
}

public xCheckStuck()
{
	if (g_Cvars[CV_AUTOMATIC_STUCK])
	{
		static players[32], pnum, player;
		get_players(players, pnum);
		static  Float:origin[3], Float:mins[3], hull, Float:vec[3], o, i;

		for(i=0; i<pnum; i++)
		{
			player = players[i];

			if (is_user_connected(player) && is_user_alive(player))
			{
				pev(player, pev_origin, origin);
				hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN;

				if (!is_hull_vacant(origin, hull, player) && !get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT))
				{
					xStuck[player] ++;

					if (xStuck[player] >= 7)
					{
						pev(player, pev_mins, mins);
						vec[2] = origin[2];

						for(o=0; o < sizeof(xStuckSize); ++o)
						{
							vec[0] = origin[0] - mins[0] * xStuckSize[o][0];
							vec[1] = origin[1] - mins[1] * xStuckSize[o][1];
							vec[2] = origin[2] - mins[2] * xStuckSize[o][2];

							if (is_hull_vacant(vec, hull,player))
							{
								engfunc(EngFunc_SetOrigin, player, vec);
								set_pev(player,pev_velocity,{0.0,0.0,0.0});
								o = sizeof(xStuckSize);
							}
						}
					}
				}
				else
				{
					xStuck[player] = 0;
				}
			}
		}
	}
}

public client_putinserver(id)
{
	for (new i = 0; i < E_TIMERS; i++)
		g_Timers[id][i] = get_gametime();

	g_PlayerMoving[id] = -1;
	g_iPlantOk[id] = false;
	xStuck[id] = false;
}

public client_disconnected(id)
{
	DestroyPlayerMoveEntity(id);
	DestroyPlayerDispensers(id);

	g_PlayerMoving[id] = -1;

	for (new i = 0; i < E_TIMERS; i++)
		g_Timers[id][i] = 0.0;

	g_iPlantOk[id] = false;
	xStuck[id] = false;
}

public plugin_cfg()
{
	static cfgdir[32];
	get_configsdir(cfgdir, charsmax(cfgdir));
	
	server_cmd("exec %s/dispenser.cfg", cfgdir);
}

public plugin_precache()
{
	for(new E_SPRITES:i = SPR_SMOKE; i < E_SPRITES; i++)
		g_PrecacheSprites[i] = precache_model(g_DispenserSprites[i]);

	for(new i = MDL_BLUEPRINT; i < E_MODELS; i++)
		g_PrecacheModels[i]   = precache_model(g_DispenserModels[i]);

	for(new E_DISPENSER_SOUND:i = SND_ACTIVE; i < E_DISPENSER_SOUND; i++)
		precache_sound(g_DispenserSound[i]);

	for(new i = 0; i < sizeof(g_BulletsSounds); i++)
		engfunc(EngFunc_PrecacheSound, g_BulletsSounds[i]);

	for(new i = 0; i < sizeof(g_DamageSounds); i++) 
		engfunc(EngFunc_PrecacheSound, g_DamageSounds[i]);
}

public EventNewRound()
{
	if (g_Cvars[CV_REMOVE_ROUND_RESTART])
		ForceDestroyDispensers();
}

public PlayerPreThink(id)
{
	if (is_user_alive(id))
	{
		if (pev_valid(g_PlayerMoving[id]))
		{
			static Float:ftime;
			ftime = get_gametime();

			if (floatcmp(ftime, Float:g_Timers[id][TIME_POST_THINK]) > 0) // no spamming the think
			{
				static Float:fOrigin[3];
				GetOriginFromDistPlayer(id, 125.0, fOrigin);
				set_pev(g_PlayerMoving[id], pev_origin, fOrigin);

				engfunc(EngFunc_DropToFloor, g_PlayerMoving[id]);

				static entlist[3];
				if (find_sphere_class(g_PlayerMoving[id], ENT_DISPENSER, 100.0, entlist, 2)
				 || find_sphere_class(g_PlayerMoving[id], "player", 20.0, entlist, 2)
				 || find_sphere_class(g_PlayerMoving[id], ENT_BREAKABLE, 20.0, entlist, 2)
				 || check_entity_in_sphere(g_PlayerMoving[id], 100.0)
				 || TraceCheckCollides(fOrigin, 35.0))
				{
					set_pev(g_PlayerMoving[id], pev_sequence, BUILD_DISPENSER_NO);
					g_iPlantOk[id] = false;
				} else 
				{
					set_pev(g_PlayerMoving[id], pev_sequence, BUILD_DISPENSER_YES);
					g_iPlantOk[id] = true;
				}
				g_Timers[id][TIME_POST_THINK] = ftime + 0.05;
			}

			if (floatcmp(ftime, Float:g_Timers[id][TIME_PLANT_HUD]) > 0)
			{
				// set_hudmessage(red = 200, green = 100, blue = 0, Float:x = -1.0, Float:y = 0.35, effects = 0, Float:fxtime = 6.0, Float:holdtime = 12.0, Float:fadeintime = 0.1, Float:fadeouttime = 0.2, channel = -1)
				set_hudmessage(.red = 0,.green = 150, .blue = 255, .x =	0.04, .y = 0.60, .effects = 0, .fxtime = 6.0, .holdtime = 1.1, .fadeintime = 0.04, .fadeouttime = 0.04, 	.channel = -1);
				show_hudmessage(id, "Press [E] to set the dispenser.");

				g_Timers[id][TIME_PLANT_HUD] = ftime + 1.2;
			}
		}
	}
	return FMRES_IGNORED;
}

stock check_entity_in_sphere(iEnt, Float:fRadius)
{
	new Float:fOrigin[3];
	new id = -1;
	new classname[33];
	new solid;
	pev(iEnt, pev_origin, fOrigin);

	while((id = engfunc(EngFunc_FindEntityInSphere, id, fOrigin, fRadius)) > 0)
	{
		pev(id, pev_classname, classname, charsmax(classname));
		if (!equali(classname, ENT_DISPENSER_MOVE)
		&&  !equali(classname, ENT_DISPENSER)
		&&  !equali(classname, "player"))
		{
			solid = pev(id, pev_solid);
			if (solid != SOLID_NOT && solid != SOLID_TRIGGER)
				return true;
		}
	}
	return false;
}

public BuyDispenser(id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE;

	// Check On Ground.
	if (!(pev(id, pev_flags) & FL_ONGROUND))
	{
		CheckFailure(id, fmt("%s ^3Make sure to stand on a ^1flat ^3floor to buy ^4Dispenser^3.", PREFIX_CHAT));
		return PLUGIN_HANDLED;
	}

	// Check Limit per Player.
	if (ArraySize(g_Dispensers[id]) >= g_Cvars[CV_LIMIT_PER_PLAYER])
	{
		CheckFailure(id, fmt("%s ^3You have already reached the ^4Dispenser ^3limit.", PREFIX_CHAT));
		return PLUGIN_HANDLED;
	}

	// Check Limit per Team.
	new globalT;
	new globalCT;
	GetGlobalCountDispenser(globalT, globalCT);
	switch(cs_get_user_team(id))
	{
		case CS_TEAM_T:
		{
			if (globalT >= g_Cvars[CV_LIMIT_PER_TEAM])
			{
				CheckFailure(id, fmt("%s ^3Your team has reached its ^4Dispenser ^3limit.", PREFIX_CHAT));
				return PLUGIN_HANDLED;
			}
		}
		case CS_TEAM_CT:
		{
			if (globalCT >= g_Cvars[CV_LIMIT_PER_TEAM])
			{
				CheckFailure(id, fmt("%s ^3Your team has reached its ^4Dispenser ^3limit.", PREFIX_CHAT));
				return PLUGIN_HANDLED;
			}
		}
	}

	// Check have money.
	new iMoney = cs_get_user_money(id);
	if (iMoney < g_Cvars[CV_LVL1_PRICE])
	{
		CheckFailure(id, fmt("%s ^3Not enough money. ^4$: %s^3.", PREFIX_CHAT, AddPoint(g_Cvars[CV_LVL1_PRICE])));
		return PLUGIN_HANDLED;
	}

	if (g_PlayerMoving[id] > 0)
	{
		CheckFailure(id, fmt("%s ^4Dispenser ^3is being deployed. Please purchase after deploying.", PREFIX_CHAT));
		return PLUGIN_HANDLED;
	}

	if (g_Cvars[CV_INSTANT_PLANT])
	{
		static Float:fOrigin[3];
		GetOriginFromDistPlayer(id, 100.0, fOrigin);

		if (CreateDispenser(fOrigin, id))
		{
			client_print_color(id, print_team_default, "%s ^4Dispenser ^3planted!", PREFIX_CHAT);
			cs_set_user_money(id, iMoney - g_Cvars[CV_LVL1_PRICE]);
		}
		else
		{
			client_cmd(id, "spk %s", g_DispenserSound[SND_FAIL]);
		}
	}
	else
	{
		CreateMoveEffect(id);
		cs_set_user_money(id, iMoney - g_Cvars[CV_LVL1_PRICE]);
	}

	return PLUGIN_HANDLED;
}

stock CheckFailure(id, chat[])
{
	client_print_color(id, print_team_default, chat);
	client_cmd(id, "spk %s", g_DispenserSound[SND_FAIL]);
}

stock GetGlobalCountDispenser(&TCount, &CTCount)
{
	TCount = 0;
	CTCount = 0;

	new iPlayers[MAX_PLAYERS], iNum;
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeDead | GetPlayers_ExcludeHLTV);

	for (new i = 0; i < iNum; i++)
	{
		switch(cs_get_user_team(iPlayers[i]))
		{
			case CS_TEAM_T:
				TCount += ArraySize(g_Dispensers[iPlayers[i]]);

			case CS_TEAM_CT:
				CTCount += ArraySize(g_Dispensers[iPlayers[i]]);
		}
	}
}

public DestroyDispenser(id)
{
	if (ArraySize(g_Dispensers[id]) <= 0)
	{
		client_print_color(id, print_team_default, "%s ^3There is no ^4Dispenser ^3to destroy.", PREFIX_CHAT);
		client_cmd(id, "spk %s", g_DispenserSound[SND_FAIL]);

		return PLUGIN_HANDLED;
	}

	new iLevel, iMoney, iEnt;
	for(new i = 0; i < ArraySize(g_Dispensers[id]); i++)
	{
		iEnt = ArrayGetCell(g_Dispensers[id], i);
		if (!pev_valid(iEnt))
			continue;
		
		if (pev(iEnt, DISPENSER_OWNER) != id)
			continue;
		
		iLevel = pev(iEnt, DISPENSER_LEVEL);
		iMoney = g_Cvars[E_CVARS:(_:CV_LVL1_PRICE + (iLevel - 1))] / 2;

		cs_set_user_money(id, cs_get_user_money(id) + iMoney);
		client_print_color(id, print_team_default, "%s ^3Destroyed ^4Dispenser ^3at Level: ^4%d ^3and got ^4$: %s ^3money.", PREFIX_CHAT, iLevel, AddPoint(iMoney));

		RemoveEntity(iEnt);
	}

	ArrayClear(g_Dispensers[id]);

	return PLUGIN_HANDLED;
}

stock RemoveEntity(ent)
{
	set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME);
	set_pev(ent, pev_nextthink, get_gametime() + 0.5);
}

public CreateMoveEffect(id)
{
	static Float:fOrigin[3];
	pev(id, pev_origin, fOrigin);
	GetOriginFromDistPlayer(id, 128.0, fOrigin);

	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	if (!pev_valid(iEnt))
		return false;
	
	set_pev(iEnt, pev_classname, ENT_DISPENSER_MOVE);
	engfunc(EngFunc_SetModel, iEnt, g_DispenserModels[MDL_BLUEPRINT]);
	set_pev(iEnt, pev_origin, fOrigin);
	set_pev(iEnt, pev_solid, SOLID_NOT);
	set_pev(iEnt, DISPENSER_OWNER, id);
	set_pev(iEnt, pev_framerate, 0.0);
	set_pev(iEnt, pev_animtime, get_gametime());
	set_pev(iEnt, pev_sequence, BUILD_DISPENSER_NO);

	SetRendering(iEnt, kRenderFxNone, Float:{0.0, 0.0, 0.0}, kRenderTransAdd, 255);
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.1);

	g_PlayerMoving[id] = iEnt;

	return true;
}

stock SetRendering(entity, fx = kRenderFxNone, Float:RenderColor[3], render = kRenderNormal, amount = 16) 
{
	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}

public PlayerCmdStart(id, uc_handle, randseed)
{
	if (!is_user_connected(id) || !is_user_alive(id))
		return FMRES_IGNORED;

	static button; button = get_uc(uc_handle , UC_Buttons);
	static oldbutton; oldbutton = pev(id, pev_oldbuttons);

	if (button & IN_USE && !(oldbutton & IN_USE))
	{
		if (g_PlayerMoving[id] && g_iPlantOk[id])
		{
			DispenserFinalCheck(id);
		} else 
		{
			new target;
			new body;
			get_user_aiming(id, target, body);

			if (!pev_valid(target))
				return FMRES_IGNORED;

			new Float:vOrigin[3];
			new Float:tOrigin[3];
			// get potision. player and target.
			pev(id, pev_origin, vOrigin);
			pev(target, pev_origin, tOrigin);

			// Distance Check. far 128.0 (cm?)
			if (get_distance_f(vOrigin, tOrigin) > 128.0)
				return FMRES_IGNORED;
	
			new entityName[MAX_NAME_LENGTH];
			pev(target, pev_classname, entityName, charsmax(entityName));

			// is target dipenser?
			if (!equali(entityName, ENT_DISPENSER))
				return FMRES_IGNORED;
			
			DispenserMenu(id, target);
		}
	}

	return FMRES_IGNORED;
}

//====================================================
// Check Logic.
//====================================================
bool:CheckAdmin(id)
{
	return bool:(get_user_flags(id) & ADMIN_ACCESSLEVEL);
}

public DispenserDestruct(id, iEnt)
{
	new idx = ArrayFindValue(g_Dispensers[id], iEnt);

	if (!pev_valid(iEnt))
		return PLUGIN_CONTINUE;

	new iOwner = pev(iEnt, DISPENSER_OWNER);
	new iTeam  = pev(iEnt, DISPENSER_TEAM);
	new iLevel;
	new iMoney;
	if (iOwner != id)
	{
		if (CheckAdmin(id))
		{
			new Float:fOrigin[3];
			pev(iEnt, pev_origin, fOrigin);
			// Target, iEnt, Attacker, dmg, DMG_
			EffectBreakModels(fOrigin, g_PrecacheModels[_:iTeam + MDL_DISPENSER], 2);
			EffectExplode(fOrigin, 10, 50, 50, 2, 35, 50);
			DestroyEntityDispenser(iEnt);

			client_print_color(id, print_team_default, "%s ^4Dispenser ^3at ^1%n ^3has been destroyed by Admin", PREFIX_CHAT, iOwner);
		}
	} else
	{
		iLevel = pev(iEnt, DISPENSER_LEVEL);
		iMoney = g_Cvars[E_CVARS:(_:CV_LVL1_PRICE + (iLevel - 1))] / 2;
		cs_set_user_money(id, cs_get_user_money(id) + iMoney);
		client_print_color(id, print_team_default, "%s ^3Destroyed ^4Dispenser ^3at Level: ^4%d ^3and got ^4$: %s ^3money.", PREFIX_CHAT, iLevel, AddPoint(iMoney));
		ArrayDeleteItem(g_Dispensers[id], idx);
		RemoveEntity(iEnt);
	}
	return PLUGIN_CONTINUE;
}

public DispenserMenu(id, iEnt)
{
	new menu = menu_create("Dispenser: ", "DispenserMenuHandler");

	new iLevel = pev(iEnt, DISPENSER_LEVEL);
	new param[6];
	num_to_str(iEnt, param, charsmax(param));
	menu_additem(menu, fmt("Upgrade: Next Level %d [$ %s]", iLevel + 1, AddPoint(g_Cvars[E_CVARS:(_:CV_LVL1_PRICE + (iLevel))])), param, 0, g_MenuCallback);
	menu_additem(menu, "Destruction", param, 0, g_MenuCallback);
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r");
	menu_display(id, menu, 0);
}

public DispenserMenuHandler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	// now lets create some variables that will give us information about the menu and the item that was pressed/chosen
	new szData[64 + 6], szName[32];
	new _access, item_callback;
	// heres the function that will give us that information ( since it doesnt magicaly appear )
	menu_item_getinfo(menu, item, _access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
	new iEnt 	= str_to_num(szData);

	switch(item)
	{
		case 0:
			DispenserUpgrade(id, iEnt);
		case 1:
			DispenserDestruct(id, iEnt);
	}
	return PLUGIN_HANDLED;
}

public DispenserMenuCallback(id, menu, item)
{
	new szData[6], szName[64], access, callback;
	//Get information about the menu item
	menu_item_getinfo(menu, item, access, szData, charsmax(szData), szName, charsmax(szName), callback);
	new iEnt 	= str_to_num(szData);
	new iLevel 	= pev(iEnt, DISPENSER_LEVEL);
	new iOwner        = pev(iEnt, DISPENSER_OWNER);
	new CsTeams:iTeam = CsTeams:pev(iEnt, DISPENSER_TEAM);

	switch(item)
	{
		// Upgrade.
		case 0:
			// MAX LEVEL.
			if (iLevel == 4)
				return ITEM_DISABLED;
			else
			{
				if (CheckAdmin(id))
					return ITEM_ENABLED;

				if (iOwner == id)
					return ITEM_DISABLED;
				else
				{
					if (iTeam == cs_get_user_team(id))
						return ITEM_ENABLED;
					else
						return ITEM_DISABLED;
				}
			}
		// Destruction.
		case 1:
			if (iOwner == id)
				return ITEM_ENABLED;
			else
			{
				if (CheckAdmin(id))
					return ITEM_ENABLED;
				else
					return ITEM_DISABLED;
			}
	}
	return ITEM_IGNORE;
}

public DispenserFinalCheck(id)
{
	static Float:fOrigin[3];
	GetOriginFromDistPlayer(id, 128.0, fOrigin);

	if (CreateDispenser(fOrigin, id))
	{
		client_print_color(id, print_team_default, "%s ^4Dispenser ^3Planted!", PREFIX_CHAT);
		DestroyPlayerMoveEntity(id);
		g_iPlantOk[id] = false;
		g_PlayerMoving[id] = -1;
	}
}

public AllowPlant(id)
{
	static Float:vTraceDirection[3], Float:vTraceEnd[3],Float:vOrigin[3];
	
	pev(id, pev_origin, vOrigin);
	vOrigin[2] += 15;
	velocity_by_aim(id, 128, vTraceDirection);
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd);
	static trace;
	static Float:fFraction;
	trace = create_tr2();
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, trace);
	{
		get_tr2(trace, TR_flFraction, fFraction);
	}
	free_tr2(trace);
	
	// -- We hit something!
	if (fFraction < 1.0)
		return true;

	return false;
}

public DestroyPlayerMoveEntity(id)
{
	static iEnt; iEnt = -1;
	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", ENT_DISPENSER_MOVE)))
	{
		if (pev(iEnt, DISPENSER_OWNER) != id)
			continue;

		if (pev_valid(iEnt))
			RemoveEntity(iEnt);
	}
	g_PlayerMoving[id] = -1;
}

public DispenserTouch(iEnt, id)
{
	static Float:time;
	time = get_gametime();

	if (is_valid_player(id))
	if (floatcmp(time, Float:g_Timers[id][TIME_FLOOD_TOUCH]) > 0)
	{
		g_Timers[id][TIME_FLOOD_TOUCH] = time + 2.5;

		DispenserUpgrade(id, iEnt);
	}
	return PLUGIN_CONTINUE;
}

public DispenserUpgrade(id, iEnt)
{
	// Skip. Invalid Player.
	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;

	// Skip. Dead Player.
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE;

	// Skip. Invalid Dispenser.
	if (!pev_valid(iEnt))
		return PLUGIN_CONTINUE;

	static CsTeams:iTeam;
	static iLevel;
	static iOwner;
	static iMoney;

	iMoney = cs_get_user_money(id);
	iTeam  = CsTeams:pev(iEnt, DISPENSER_TEAM);
	iOwner = pev(iEnt, DISPENSER_OWNER);
	iLevel = pev(iEnt, DISPENSER_LEVEL);

	// Max Level.
	if (iLevel == 4)
		return PLUGIN_CONTINUE;

	// Skip. Not team.
	if (iTeam != cs_get_user_team(id))
		return PLUGIN_CONTINUE;

	// Skip. Owner (Admin is OK.)
	if (!CheckAdmin(id))
	if (iOwner == id)
	{
		client_cmd(id, "spk %s", g_DispenserSound[SND_FAIL]);
		return PLUGIN_CONTINUE;
	}

	// Skip. No funds.
	if (iMoney < g_Cvars[E_CVARS:(_:CV_LVL1_PRICE + (iLevel - 1))])
	{
		CheckFailure(id, 
			fmt("%s ^4No funds ^3to level up the dispenser. ^1Price: ^4$: %s^3.", 
				PREFIX_CHAT, 
				AddPoint(g_Cvars[E_CVARS:(_:CV_LVL1_PRICE + (iLevel - 1))])
			)
		);
		return PLUGIN_CONTINUE;
	}

	// 
	// Dispenser Level Up
	// 
	iLevel++;
	// Price.
	cs_set_user_money(id, iMoney - g_Cvars[E_CVARS:(_:CV_LVL1_PRICE + (iLevel - 1))]);

	// Reset Animation.
	if (task_exists(iEnt+TASK_ANIM))
		remove_task(iEnt+TASK_ANIM);

	// Set Level.
	set_pev(iEnt, DISPENSER_LEVEL, iLevel);
	// Set New Dispenser Health.
	set_pev(iEnt, pev_health, float(g_Cvars[E_CVARS:(_:CV_LVL1_DISPENSER_HEALTH + (iLevel - 1))]));
	// Set Model / Hitbox. (Already set.)
	// engfunc(EngFunc_SetModel, iEnt, g_DispenserModels[MDL_DISPENSER]);
	// set_pev(iEnt, pev_modelindex, g_PrecacheModels[MDL_DISPENSER]);
	// engfunc(EngFunc_SetSize, iEnt, Float:{ -20.0, -20.0, 0.0 }, Float:{ 20.0, 20.0, 80.0 });
	// Active Sound.
	emit_sound(iEnt, CHAN_STATIC, g_DispenserSound[SND_ACTIVE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	// Level up Animation.
	if (iLevel > 1)
	{
		PlayAnimation(iEnt, min(ANIM_LVL1_BUILD + ((iLevel - 1) * 2), ANIM_LVL3_BUILD), 1.0);
		set_task(iLevel > 2 ? 0.9 : 1.4, "AnimIdle", iEnt + TASK_ANIM);
		set_pev(iEnt, pev_skin, iTeam);
	}

	// Skip. Owner is dropped.
	if (!is_user_connected(iOwner))
		return PLUGIN_CONTINUE;

	// Chat log.
	if (iOwner == id)
		client_print_color(id, print_team_default, "%s ^3Your ^4Dispenser ^3has been upgraded. level: ^4%d^3.", PREFIX_CHAT, iLevel);
	else
		client_print_color(iOwner, print_team_default, "%s ^3The level of ^4Dispenser ^3in ^1%n ^3has been increased. level: ^4%d^3.", PREFIX_CHAT, id, iLevel);	

	return PLUGIN_CONTINUE;
}

public DispenserThink(iEnt)
{
	// Skip. Invalid Entity.
	if (!pev_valid(iEnt))
		return PLUGIN_CONTINUE;

	static classname[32];
	pev(iEnt, pev_classname, classname, charsmax(classname));
	
	// Skip. Not Dispenser.
	if (!equali(classname, ENT_DISPENSER))
		return PLUGIN_CONTINUE;

	static iOwner;
	iOwner = pev(iEnt, DISPENSER_OWNER);

	// Skip. Disconnected Owner.
	if (!is_user_connected(iOwner))
	{
		RemoveEntity(iEnt);
		return PLUGIN_CONTINUE;
	}

	// Effect Level4
	if (g_Cvars[CV_EFFECT_LVL_4])
	{
		if (!(pev(iEnt, pev_effects) & EF_BRIGHTFIELD))
			set_pev(iEnt, pev_effects, pev(iEnt, pev_effects) | EF_BRIGHTFIELD);
	}

	static iLevel;
	static CsTeams:iTeam;
	static Float:fOrigin[3];
	static Float:fOriginTarget[3];
	static Float:time;
	static id;
	static Float:fRadius;

	// Get Max Radius.
	fRadius = floatmax(g_Cvars[CV_RECOVERY_RADIUS], g_Cvars[CV_GIVE_MONEY_DISTANCE]);
	fRadius = floatmax(fRadius, g_Cvars[CV_GIVE_AMMO_DISTANCE]);

	time = get_gametime();

	iLevel 	= pev(iEnt, DISPENSER_LEVEL);
	iTeam	= CsTeams:pev(iEnt, DISPENSER_TEAM);
	pev(iEnt, pev_origin, fOrigin);

	id = -1;
	// Find Entity in Sphere of Dispenser.
	while((id = engfunc(EngFunc_FindEntityInSphere, id, fOrigin, fRadius)) != 0)
	{
		// Is Players.
		if (is_valid_player(id))
		{
			// Skip. Dead Player.
			if (!is_user_alive(id))
				continue;

			// Skip. Enemies.
			if (cs_get_user_team(id) != iTeam)
				continue;
			
			// Skip. Can't Look Dispenser.
			if (!UTIL_IsVisible(id, iEnt, 1))
				continue;

			// Get Target origin.
			pev(id, pev_origin, fOriginTarget);

			// Get distance dispencer to target.
			static Float:distance;
			distance = get_distance_f(fOrigin, fOriginTarget);

			static bool:recovery;
			recovery = false;

			if (floatcmp(time, Float:g_Timers[id][TIME_RECOVERY]) > 0)
			{
				// If inside recovery radius.
				if (distance <= g_Cvars[CV_RECOVERY_RADIUS])
				{
					// Recovery Health.
					if (pev(id, pev_health) < g_Cvars[E_CVARS:(_:CV_LVL1_MAX_HP + (iLevel - 1))])
					{
						recovery = true;
						static Float:health;
						pev(id, pev_health, health); 

						set_pev(id, pev_health, 
							floatmin(
								floatadd(health, Float:g_Cvars[E_CVARS:(_:CV_LVL1_AMOUNT_HP + (iLevel - 1))]), 
								float(g_Cvars[E_CVARS:(_:CV_LVL1_MAX_HP + (iLevel - 1))])
							)
						);
						if (g_Cvars[CV_SHOW_LIFE_SPRITE])
						{
							static iOrigin[3];
							get_user_origin(id, iOrigin);
							message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
							write_byte(TE_PROJECTILE);
							write_coord(iOrigin[0] + random_num(-10, 15));
							write_coord(iOrigin[1] + random_num(-10, 15));
							write_coord(iOrigin[2] + random_num(5, 30));
							write_coord(10);
							write_coord(15);
							write_coord(20);
							write_short(iTeam == CS_TEAM_T ? g_PrecacheSprites[SPR_HEAL_LIFE_R] : g_PrecacheSprites[SPR_HEAL_LIFE_B]);
							write_byte(1);
							write_byte(id);
							message_end();
						}
					}
					// Recovery Armor.
					static CsArmorType:armortype;
					static armor; armor = cs_get_user_armor(id, armortype);
					if (armor < g_Cvars[E_CVARS:(_:CV_LVL1_MAX_ARMOR + (iLevel - 1))])
					{
						recovery = true;
						cs_set_user_armor(id, min(armor + g_Cvars[E_CVARS:(_:CV_LVL1_AMOUNT_ARMOR + (iLevel - 1))], g_Cvars[E_CVARS:(_:CV_LVL1_MAX_ARMOR + (iLevel - 1))]), CS_ARMOR_VESTHELM);
					}
				}
				g_Timers[id][TIME_RECOVERY] = time + g_Cvars[CV_RECOVERY_TIME];
			}
			// Check give money time think time.
			if (floatcmp(time, Float:g_Timers[id][TIME_GIVE_MONEY]) > 0)
			{
				// If inside give money radius.
				if (distance <= g_Cvars[CV_GIVE_MONEY_DISTANCE])
					cs_set_user_money(id, cs_get_user_money(id) + random_num(g_Cvars[CV_GIVE_MONEY_MIN], g_Cvars[CV_GIVE_MONEY_MAX]));

				g_Timers[id][TIME_GIVE_MONEY] = time + g_Cvars[CV_GIVE_MONEY_TIME];
			}

			if (pev_valid(id) == 2)
			{
				if (iLevel == 4 || g_Cvars[CV_GIVE_AMMO_ALL_LVL])
				{
					// Check give money ammo think time.
					if (floatcmp(time, Float:g_Timers[id][TIME_GIVE_AMMO]) > 0)
					{
						// If inside give money radius.
						if (distance <= g_Cvars[CV_GIVE_AMMO_DISTANCE])
						{
							static currentWpnEntId;
							static currentWpn;
							static currentAmmo;
							static currentBPAmmo;
							static newAmmo;
							static newBPAmmo;

							currentWpnEntId = get_pdata_cbase(id, 373);	// Global Weapon Entity ID.
							currentWpn		= get_user_weapon(id);		// Current Weapon Class.
							if (currentWpn != CSW_KNIFE )
							{
								currentAmmo 	= cs_get_weapon_ammo(currentWpnEntId);
								currentBPAmmo 	= cs_get_user_bpammo(id, currentWpn);
								newAmmo 		= currentAmmo   + random_num(g_Cvars[CV_GIVE_AMMO_MIN], g_Cvars[CV_GIVE_AMMO_MAX]);
								newBPAmmo 		= currentBPAmmo + random_num(g_Cvars[CV_GIVE_AMMO_MIN], g_Cvars[CV_GIVE_AMMO_MAX]);
								cs_set_weapon_ammo(currentWpnEntId, min(newAmmo, g_WeaponsAmmo[currentWpn][0]));
								cs_set_user_bpammo(id, currentWpn, min(newBPAmmo, g_WeaponsAmmo[currentWpn][1]));
								emit_sound(id, CHAN_ITEM, g_BulletsSounds[random_num(0, charsmax(g_BulletsSounds))], 0.3, ATTN_NORM, 0, PITCH_NORM);
							}
						}
						g_Timers[id][TIME_GIVE_AMMO] = time + g_Cvars[CV_GIVE_AMMO_TIME];
					}
				}
			}

			// Show line.
			if (recovery && g_Cvars[CV_SHOW_LINE])
			{
				fOrigin[1] += 1.0;
				EffectBeams(fOriginTarget, fOrigin, g_Color[iTeam], g_PrecacheSprites[SPR_LASER], 40, 0, 1);
			}
			continue;
		} else
		{
			static targetClassName[32];
			pev(iEnt, pev_classname, targetClassName, charsmax(targetClassName));
			// Skip. Not Dispenser.
			if (!equali(targetClassName, ENT_DISPENSER))
				continue;

			// static targetOwner;
			static CsTeams:targetTeam;
			// targetOwner = pev(iEnt, DISPENSER_OWNER);
			targetTeam = CsTeams:pev(id, DISPENSER_TEAM);
			// Skip. Enemies.
			if (targetTeam != iTeam)
				continue;

			// Skip. same one.
			if (id == iEnt)
				continue;
			
			// Skip. Can't Look Dispenser.
			if (!UTIL_IsVisible(id, iEnt, 1))
				continue;

			// Get Target origin.
			pev(id, pev_origin, fOriginTarget);

			// Get distance dispencer to target.
			static Float:distance;
			distance = get_distance_f(fOrigin, fOriginTarget);

			// If inside recovery radius.
			if (distance <= g_Cvars[CV_RECOVERY_RADIUS])
			{
				// Recovery Dispensers.
				static Float:AmountHP;
				AmountHP = floatmin(
						float(g_Cvars[E_CVARS:(_:CV_LVL1_AMOUNT_HP + (pev(id, DISPENSER_LEVEL) - 1))]),
						float(g_Cvars[E_CVARS:(_:CV_LVL1_DISPENSER_HEALTH + (pev(id, DISPENSER_LEVEL) - 1))]));
				set_pev(iEnt, pev_health, AmountHP);
				fOrigin[1] += 1.0;
				EffectBeams(fOriginTarget, fOrigin, g_Color[iTeam], g_PrecacheSprites[SPR_LASER], 40, 0, 1);
			}
		}
	}

	// Breaking....
	static Float:CurrentHealth;
	pev(iEnt, pev_health, CurrentHealth);

	// TODO: NOT USE MAGIC NUMBER 350.0.
	if (CurrentHealth <= 350.0)
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(TE_SMOKE);
		engfunc(EngFunc_WriteCoord, fOrigin[0] + random_float(-8.0, 8.0));
		engfunc(EngFunc_WriteCoord, fOrigin[1] + random_float(-8.0, 8.0));
		engfunc(EngFunc_WriteCoord, fOrigin[2] + random_float(25.0, 50.0));
		write_short(g_PrecacheSprites[SPR_SMOKE]);
		write_byte(random_num(3,10));
		write_byte(30); //def: 30
		message_end();
	}

	// Destroy Dispenser when changing teams.
	if (cs_get_user_team(iOwner) != iTeam)
	{
		DestroyPlayerDispensers(iOwner); // remove todos dispensers da PESSOA
		return PLUGIN_CONTINUE;
	}

	set_pev(iEnt, pev_nextthink, get_gametime() + 1.0);	
	return PLUGIN_CONTINUE;
}

stock ForceDestroyDispensers()
{
	new iEnt = -1;
	for(new i = 0; i <= MAX_PLAYERS; i++)
	{
		for (new n = 0; n < ArraySize(g_Dispensers[i]); n++)
		{
			iEnt = ArrayGetCell(g_Dispensers[i], n);
			if (pev_valid(iEnt))
				RemoveEntity(iEnt);
		}
		ArrayClear(g_Dispensers[i]);
	}

	iEnt = -1;
	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", ENT_DISPENSER)))
	{
		if (pev_valid(iEnt))
			RemoveEntity(iEnt);
	}
}

public DestroyPlayerDispensers(id)
{
	new iEnt;
	for(new i = 0; i < ArraySize(g_Dispensers[id]); i++)
	{
		iEnt = ArrayGetCell(g_Dispensers[id], i);
		if (pev_valid(iEnt))
			RemoveEntity(iEnt);
	}
	ArrayClear(g_Dispensers[id]);
}

public DestroyEntityDispenser(iEnt)
{
	new idx = -1;
	for (new i = 0; i <= MAX_PLAYERS; i++)
	{
		if ((idx = ArrayFindValue(g_Dispensers[i], iEnt)) > 0)
		{
			ArrayDeleteItem(g_Dispensers[i], idx);
			break;
		}
	}
	emit_sound(iEnt, CHAN_ITEM, g_DispenserSound[SND_EXPLODE], VOL_NORM, ATTN_NORM, 0, PITCH_HIGH);
	RemoveEntity(iEnt);
}

public PlayerTraceLinePost(Float:v1[3], Float:v2[3], noMonsters, id)
{
	if (!is_valid_player(id) || is_user_bot(id) || !is_user_alive(id))
		return FMRES_IGNORED;

	new iHitEnt;
	iHitEnt = get_tr(TR_pHit);

	if (iHitEnt <= MaxClients || !pev_valid(iHitEnt))
		return FMRES_IGNORED;

	new szClassname[32];
	pev(iHitEnt, pev_classname, szClassname, charsmax(szClassname));

	if (!equal(szClassname, ENT_DISPENSER))
		return FMRES_IGNORED;

	new CsTeams:iTeam = CsTeams:pev(iHitEnt, DISPENSER_TEAM);

	if (cs_get_user_team(id) != iTeam)
		return FMRES_IGNORED;

	new iHealth = pev(iHitEnt, pev_health);

	if (iHealth <= 0)
		return FMRES_IGNORED;

	new iOwner = pev(iHitEnt, DISPENSER_OWNER);

	if (!is_user_connected(iOwner))
		return FMRES_IGNORED;

	new iLevel = pev(iHitEnt, DISPENSER_LEVEL);

	set_dhudmessage(255, 255, 255, -1.0, 0.65, 0, 0.1, 0.5, 0.0, 0.0);
	show_dhudmessage(id, "Owner: %n^nHealth: %s^nLevel: %d", iOwner, AddPoint(iHealth), iLevel);
	
	return FMRES_IGNORED;
}

public ham_TraceAttackPre(ent, iAttacker, Float:flDamage, Float:flDirection[3], iTr, iDamageBits)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;
		
	new szClassname[32];
	pev(ent, pev_classname, szClassname, charsmax(szClassname));
	
	if (equal(szClassname, ENT_DISPENSER))
	{
		new iOwner; iOwner = pev(ent, DISPENSER_OWNER);

		if (!is_user_connected(iOwner) || !is_user_connected(iAttacker) || !is_valid_player(iOwner) || !is_valid_player(iAttacker))
			return HAM_SUPERCEDE;

		new Float:flEndOrigin[3];
		get_tr2(iTr, TR_vecEndPos, flEndOrigin);
	
		EffectSparks(flEndOrigin);
	}

	return HAM_IGNORED;
}

public ham_TakeDamagePre(ent, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	new szClassname[32];
	pev(ent, pev_classname, szClassname, charsmax(szClassname));
                                        
	if (equal(szClassname, ENT_DISPENSER))
	{
		new iOwner; iOwner = pev(ent, DISPENSER_OWNER);

		if (!is_user_connected(iOwner))
			return HAM_SUPERCEDE;

		if (!is_user_connected(idattacker))
			return HAM_SUPERCEDE;

		if (!is_valid_player(iOwner))
			return HAM_SUPERCEDE;
		
		if (!is_valid_player(idattacker))
			return HAM_SUPERCEDE;

		if (CheckAdmin(idattacker))
			return HAM_IGNORED;

		if (get_user_team(iOwner) == get_user_team(idattacker) && idattacker != iOwner)
			return HAM_SUPERCEDE;
	}

	return HAM_IGNORED ;
}

public ham_TakeDamagePost(ent, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	new szClassname[32];
	pev(ent, pev_classname, szClassname, charsmax(szClassname));

	if (equal(szClassname, ENT_DISPENSER))
	{
		if (!pev_valid(ent))
			return HAM_IGNORED;

		new iOwner; iOwner = pev(ent, DISPENSER_OWNER);

		if (!is_user_connected(iOwner) 
		||  !is_user_connected(idattacker) 
		||  !is_valid_player(iOwner) 
		||  !is_valid_player(idattacker))
			return HAM_SUPERCEDE;

		if (get_user_team(iOwner) == get_user_team(idattacker) && idattacker != iOwner)
			return HAM_SUPERCEDE;

		if (pev(ent, pev_health) <= 0.0)
		{
			new CsTeam:iTeam = CsTeam:pev(ent, DISPENSER_TEAM);

			new Float:originF[3];
			pev(ent, pev_origin, originF);

			EffectBreakModels(originF, g_PrecacheModels[_:iTeam + MDL_DISPENSER], 2);
			EffectExplode(originF, 10, 50, 50, 2, 35, 50);

			if (idattacker == iOwner)
				client_print_color(iOwner, print_team_default, "%s ^3You have destroyed your own ^4Dispenser^3.", PREFIX_CHAT);
			else
			{
				client_print_color(0, print_team_default, "%s ^1%n ^3destroyed the ^4Dispenser of ^1%n ^3and won $: ^4%s ^3of money.", 
						PREFIX_CHAT, idattacker, iOwner, AddPoint(g_Cvars[CV_DESTRUCTION_BONUS]));
				cs_set_user_money(idattacker, cs_get_user_money(idattacker) + g_Cvars[CV_DESTRUCTION_BONUS]);
			}

			DestroyEntityDispenser(ent);
		}

		if (pev_valid(ent))
			emit_sound(ent, CHAN_STATIC, g_DamageSounds[random_num(0, charsmax(g_DamageSounds))], 0.3, ATTN_NORM, 0, PITCH_NORM);
	}

	return HAM_IGNORED;
}

stock bool:CreateDispenser(Float:origin[3], creator)
{
	if (g_Cvars[CV_INSTANT_PLANT])
	{
		static xEntList[3];
		if (find_sphere_class(creator, ENT_DISPENSER, 130.0, xEntList, charsmax(xEntList))
		 || TraceCheckCollides(origin, 35.0)
		 || !(pev(creator, pev_flags) & FL_ONGROUND))
		{
			client_print_color(creator, print_team_default, "%s ^3Add the ^4Dispenser ^3away from others and do not lean it against walls.", PREFIX_CHAT);
			return false;
		}
	} else
	{
		if (!AllowPlant(creator))
		{
			client_print_color(creator, print_team_default, "%s ^3Aim for the ^1plane ground ^3and close so you can add the ^4Dispenser^3.", PREFIX_CHAT);
			return false;
		}
	}

	if (engfunc(EngFunc_PointContents, origin) != CONTENTS_EMPTY)
		return false;

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, ENT_BREAKABLE));

	if (!pev_valid(ent))
		return false;

	new iLevel = 1;
	new CsTeams:iTeam  = cs_get_user_team(creator);
	set_pev(ent, pev_classname, ENT_DISPENSER);

	engfunc(EngFunc_SetModel, ent, g_DispenserModels[MDL_DISPENSER]);
	set_pev(ent, pev_modelindex, g_PrecacheModels[MDL_DISPENSER]);
	set_pev(ent, pev_skin, iTeam);
	PlayAnimation(ent, ANIM_LVL1_BUILD, 1.0);
	set_task(10.0, "AnimIdle", ent + TASK_ANIM);

	engfunc(EngFunc_SetSize, ent, Float:{ -20.0, -20.0, 0.0 }, Float:{ 20.0, 20.0, 80.0 });
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_solid, SOLID_BBOX);
	set_pev(ent, pev_movetype, MOVETYPE_TOSS);
	set_pev(ent, pev_health, float(g_Cvars[CV_LVL1_DISPENSER_HEALTH]));
	set_pev(ent, pev_takedamage, 1.0);
	set_pev(ent, DISPENSER_OWNER, creator);
	set_pev(ent, DISPENSER_LEVEL, iLevel);
	set_pev(ent, DISPENSER_TEAM, iTeam);

	if (g_Cvars[CV_IDLE_SOUND])
	{
		DispenserIdleSound(ent);
		set_task(1.9, "DispenserIdleSound", ent + TASK_IDLE_SOUND, _, _, "b");
	}

	if (g_Cvars[CV_LIGHT])
		set_task(0.1, "DispenserLight", ent + TASK_LIGHT, _, _, "b");

	switch (iTeam)
	{
		case CS_TEAM_T:
			set_pev(ent, pev_body, 4);
		case CS_TEAM_CT:
			set_pev(ent, pev_body, 0);
	}
	if (g_Cvars[CV_GLOW])
		SetRendering(ent, kRenderFxGlowShell, g_Color[iTeam], kRenderNormal, 10);

	emit_sound(ent, CHAN_STATIC, g_DispenserSound[SND_ACTIVE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	set_pev(ent, pev_nextthink, get_gametime() + 0.1);

	ArrayPushCell(g_Dispensers[creator], ent);
	return true;
}

public DispenserIdleSound(ent)
{
	if (!pev_valid(ent))
	{
		if (task_exists(ent))
			remove_task(ent);

		return;
	}

	emit_sound(ent, CHAN_ITEM, g_DispenserSound[SND_IDLE], 0.35, ATTN_IDLE, 0, PITCH_NORM);
}

public DispenserLight(ent)
{
	if (!pev_valid(ent))
	{
		if (task_exists(ent))
			remove_task(ent);

		return;
	}

	static Float:origin[3];
	pev(ent, pev_origin, origin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0);
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, origin[0]);
	engfunc(EngFunc_WriteCoord, origin[1]);
	engfunc(EngFunc_WriteCoord, origin[2]);
	write_byte(3) ;// radius
	write_byte(100) ;// r
	write_byte(100) ;// g
	write_byte(100) ;// b
	write_byte(20) ;// life 10 = 1seg
	write_byte(0) ;// decay
	message_end();
}

stock EffectBreakModels(Float:flOrigin[3], model, flags)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0);
	write_byte(TE_BREAKMODEL);
	engfunc(EngFunc_WriteCoord, flOrigin[0]);
	engfunc(EngFunc_WriteCoord, flOrigin[1]);
	engfunc(EngFunc_WriteCoord, flOrigin[2]);
	write_coord(16);
	write_coord(16);
	write_coord(16);
	write_coord(random_num(-20, 20));
	write_coord(random_num(-20, 20));
	write_coord(10);
	write_byte(10);
	write_short(model);
	write_byte(10);
	write_byte(50); // time = 10 = 1 segundo
	write_byte(flags);
	message_end();
}

stock PlayAnimation(ent, anim, Float:framerate)
{
	if (!pev_valid(ent))
		return;
	
	set_pev(ent, pev_animtime, get_gametime());
	set_pev(ent, pev_framerate, framerate);
	set_pev(ent, pev_sequence, anim);
	
}

stock bool:UTIL_IsVisible(index, entity, ignoremonsters = 0)
{
	new Float:flStart[3], Float:flDest[3];

	pev(index, pev_origin, flStart);
	pev(index, pev_view_ofs, flDest);

	xs_vec_add(flStart, flDest, flStart);

	pev(entity, pev_origin, flDest);
	new trace = create_tr2();
	engfunc(EngFunc_TraceLine, flStart, flDest, ignoremonsters, index, trace);

	new Float:flFraction;
	get_tr2(trace, TR_flFraction, flFraction);

	if (flFraction == 1.0 || get_tr2(trace, TR_pHit) == entity)
	{
		free_tr2(trace);
		return true;
	}
	free_tr2(trace);

	return false;
}

stock EffectBeams(Float:flStart[3], Float:flEnd[3], Float:rgb[3], sprite, width, ampl, speed)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flStart);
	write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord, flStart[0]);
	engfunc(EngFunc_WriteCoord, flStart[1]);
	engfunc(EngFunc_WriteCoord, flStart[2]);
	engfunc(EngFunc_WriteCoord, flEnd[0]);
	engfunc(EngFunc_WriteCoord, flEnd[1]);
	engfunc(EngFunc_WriteCoord, flEnd[2]);
	write_short(sprite);
	write_byte(1);		// start frame
	write_byte(1);		// frame rate
	write_byte(1);		// life
	write_byte(width);	// widh
	write_byte(ampl);	// noise
	write_byte(floatround(rgb[0]));	//R
	write_byte(floatround(rgb[1]));	//G
	write_byte(floatround(rgb[2]));	//B
	write_byte(255);	// def: 130
	write_byte(speed);	// def: 30
	message_end();
}

stock bool:TraceCheckCollides(Float:origin[3], const Float:BOUNDS)
{
	static Float:traceEnds[8][3], Float:traceHit[3], hitEnt;
	traceEnds[0][0] = origin[0] - BOUNDS;
	traceEnds[0][1] = origin[1] - BOUNDS;
	traceEnds[0][2] = origin[2] - BOUNDS;
	traceEnds[1][0] = origin[0] - BOUNDS;
	traceEnds[1][1] = origin[1] - BOUNDS;
	traceEnds[1][2] = origin[2] + BOUNDS;
	traceEnds[2][0] = origin[0] + BOUNDS;
	traceEnds[2][1] = origin[1] - BOUNDS;
	traceEnds[2][2] = origin[2] + BOUNDS;
	traceEnds[3][0] = origin[0] + BOUNDS;
	traceEnds[3][1] = origin[1] - BOUNDS;
	traceEnds[3][2] = origin[2] - BOUNDS;
	traceEnds[4][0] = origin[0] - BOUNDS;
	traceEnds[4][1] = origin[1] + BOUNDS;
	traceEnds[4][2] = origin[2] - BOUNDS;
	traceEnds[5][0] = origin[0] - BOUNDS;
	traceEnds[5][1] = origin[1] + BOUNDS;
	traceEnds[5][2] = origin[2] + BOUNDS;
	traceEnds[6][0] = origin[0] + BOUNDS;
	traceEnds[6][1] = origin[1] + BOUNDS;
	traceEnds[6][2] = origin[2] + BOUNDS;
	traceEnds[7][0] = origin[0] + BOUNDS;
	traceEnds[7][1] = origin[1] + BOUNDS;
	traceEnds[7][2] = origin[2] - BOUNDS;

	static i, j;
	for(i = 0; i < 8; i++)
	{
		if (engfunc(EngFunc_PointContents, origin) != CONTENTS_EMPTY)
			return true;
		
		hitEnt = trace_line(0, origin, traceEnds[i], traceHit);

		if (hitEnt != 0)
			return true;


		for(j = 0; j < 3; j++)
		{
			if (traceEnds[i][j] != traceHit[j])
				return true;
		}
	}

	return false;
}

stock EffectExplode(const Float:originF[3], head, sprites, life, tamanho, velo, decals)
{	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0);
	write_byte(TE_SPRITETRAIL);
	engfunc(EngFunc_WriteCoord, originF[0]); // X
	engfunc(EngFunc_WriteCoord, originF[1]); // Y
	engfunc(EngFunc_WriteCoord, originF[2]+head); // Z
	engfunc(EngFunc_WriteCoord, originF[0]); // X
	engfunc(EngFunc_WriteCoord, originF[1]); // Y
	engfunc(EngFunc_WriteCoord, originF[2]+head); // Z
	write_short(g_PrecacheSprites[SPR_FLARE]);
	write_byte(sprites); // quantas sprites vai sair...
	write_byte(life); // life
	write_byte(tamanho); // tamanho
	write_byte(velo); // velo
	write_byte(decals); // decals
	message_end();
}

stock EffectSparks(Float:flOrigin[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0);
	write_byte(TE_SPARKS);
	engfunc(EngFunc_WriteCoord, flOrigin[0]);
	engfunc(EngFunc_WriteCoord, flOrigin[1]);
	engfunc(EngFunc_WriteCoord, flOrigin[2]);
	message_end();
}

// PEGA ORIGIN DA FRENTE
stock GetOriginFromDistPlayer(id, Float:dist, Float:origin[3], s3d = 1) 
{
	static Float:idorigin[3];
	pev(id, pev_origin, idorigin);
	
	if (dist == 0)
	{
		origin = idorigin;
		return;
	}
	
	static Float:idvangle[3];
	pev(id, pev_v_angle, idvangle);
	idvangle[0] *= -1;
	
	origin[0] = idorigin[0] + dist * floatcos(idvangle[1], degrees) * ((s3d) ? floatabs(floatcos(idvangle[0], degrees)) : 1.0);
	origin[1] = idorigin[1] + dist * floatsin(idvangle[1], degrees) * ((s3d) ? floatabs(floatcos(idvangle[0], degrees)) : 1.0);
	origin[2] = idorigin[2];
}

stock AddPoint(number)
{
	new count, i, str[29], str2[35], len;
	num_to_str(number, str, charsmax(str));
	len = strlen(str);

	for (i = 0; i < len; i++)
	{
		if (i != 0 && ((len - i) %3 == 0))
		{
			add(str2, charsmax(str2), ",", 1);
			count++;
			add(str2[i+count], 1, str[i], 1);
		}
		else add(str2[i+count], 1, str[i], 1);
	}

	return str2;
}

public AnimIdle(iTaskID)
{
	new iEnt = ID_ANIM;
	if (!pev_valid(ID_ANIM))
	{
		if (task_exists(iTaskID))
			remove_task(iTaskID);
		return;
	}
	new level = pev(iEnt, DISPENSER_LEVEL);
	PlayAnimation(ID_ANIM, min(ANIM_LVL1_IDLE + ((level - 1) * 2), ANIM_LVL3_IDLE), 1.0);
}
