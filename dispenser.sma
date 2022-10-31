#pragma compress 1

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
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

#define PLUGIN  "Dispenser"
#define VERSION "0.1"
#define AUTHOR  "Aoi.Kagase"

#define PREFIX_CHAT ""

#define dispenser_classname "dispenser"
#define dispenser_classmove "dispenser_move"

#define is_valid_player(%1) (1 <= %1 <= MaxClients)

#define TASK_ANIM 4875154
#define ID_ANIM (iTaskID - TASK_ANIM)

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

new const g_CVarString	[E_CVARS][][] =
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
	{"dispenser_instant_plant",			"1",	"num"},
};

new g_CvarPointer	[E_CVARS];
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

new const g_DispenserSound[][] = 
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

enum E_MODELS
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

new const g_DispenserModels[][] = 
{
	"models/dispenser/dispenser_blueprint.mdl",
	"models/dispenser/dispenser.mdl",
	"models/dispenser/dispenser_gibs_r.mdl",
	"models/dispenser/dispenser_gibs_b.mdl",
};

new const g_DispenserSprites[][] =
{
	"sprites/dispenser/dispenser_smoke.spr",
	"sprites/dispenser/healbeam_blue.spr",
	"sprites/dispenser/healbeam_red.spr",
	"sprites/flare3.spr",
	"sprites/laserbeam.spr",
};

new Array:g_Dispensers[33];
new g_PlayerMoving[33];

new Float:g_DispOrigin[33][3], 
	Float:g_fTimeFloodDispTouch[33], 
	Float:g_fTimeGiveMoney[33], 
	g_BeamColor[33][3], 
	g_DispPlayerCount[33];

new g_PrecacheModels	[E_MODELS], 
	g_PrecacheSprites	[E_SPRITES];

new Float:g_fTimePostThink[33],
	g_iPlantOk[33], 
	Float:g_fTimePlantHud[33], 
	Float:g_fTimeGiveAmmo[33];

new xStuck[33], xModelIndex;

#define DISPENSER_OWNER pev_iuser2
#define DISPENSER_LEVEL pev_iuser3
#define DISPENSER_TEAM 	pev_iuser4

// ====================================================
//  Register Cvars.
// ====================================================
stock register_cvars()
{
	for(new E_CVARS:i = CV_LVL1_PRICE; i < E_CVARS; i++)
	{
		g_CvarPointer[i] = create_cvar(g_CVarString[i][0], g_CVarString[i][1]);
		if (equali(g_CVarString[i][2], "num"))
			bind_pcvar_num(g_CvarPointer[i], g_Cvars[i]);
		else if(equali(g_CVarString[i][2], "float"))
			bind_pcvar_float(g_CvarPointer[i], Float:g_Cvars[i]);
		
		hook_cvar_change(g_CvarPointer[i], "cvar_change_callback");
	}
}

// ====================================================
//  Callback cvar change.
// ====================================================
public cvar_change_callback(pcvar, const old_value[], const new_value[])
{
	for(new i = 0; i < sizeof(g_CVarString); i++)
	{
		if (g_CvarPointer[E_CVARS:i] == pcvar)
		{
			if (equali(g_CVarString[E_CVARS:i][2], "num"))
				g_Cvars[E_CVARS:i] = str_to_num(new_value);
			else if (equali(g_CVarString[E_CVARS:i][2], "float"))
				g_Cvars[E_CVARS:i] = _:str_to_float(new_value);

			console_print(0,"[Cvar Debug]: Changed Cvar '%s' => '%s' to '%s'", g_CVarString[E_CVARS:i][0], old_value, new_value);
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
	register_forward(FM_TraceLine, "fw_TraceLinePost", true);
	register_forward(FM_CmdStart, "fw_CmdStart");

	RegisterHam(Ham_Touch, 		 		"player",	"fw_DispenserTouch");
	RegisterHam(Ham_Player_PreThink,	"player",	"PlayerPreThink");
	RegisterHam(Ham_Think, 		 		"func_breakable", "DispenserThink");
	RegisterHam(Ham_TakeDamage,  		"func_breakable", "ham_TakeDamagePost", true);
	RegisterHam(Ham_TakeDamage,  		"func_breakable", "ham_TakeDamagePre", false);
	RegisterHam(Ham_TraceAttack, 		"func_breakable", "ham_TraceAttackPre", false);

	Initialize();

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

	if(weapon == CSW_KNIFE && g_Cvars[CV_DROP_TO_BUY])
	{
		BuyDispenser(id);
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

stock bool:is_hull_vacant(const Float:origin[3], hull, id)
{
	static tr;
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr);
	
	if(!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true;
	
	return false;
}

public xCheckStuck()
{
	if(g_Cvars[CV_AUTOMATIC_STUCK])
	{
		static players[32], pnum, player;
		get_players(players, pnum);
		static  Float:origin[3], Float:mins[3], hull, Float:vec[3], o, i;

		for(i=0; i<pnum; i++)
		{
			player = players[i];

			if(is_user_connected(player) && is_user_alive(player))
			{
				pev(player, pev_origin, origin);
				hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN;

				if(!is_hull_vacant(origin, hull, player) && !get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT))
				{
					xStuck[player] ++;

					if(xStuck[player] >= 7)
					{
						pev(player, pev_mins, mins);
						vec[2] = origin[2];

						for(o=0; o < sizeof(xStuckSize); ++o)
						{
							vec[0] = origin[0] - mins[0] * xStuckSize[o][0];
							vec[1] = origin[1] - mins[1] * xStuckSize[o][1];
							vec[2] = origin[2] - mins[2] * xStuckSize[o][2];

							if(is_hull_vacant(vec, hull,player))
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
}

public client_disconnected(id)
{
	DestroyPlayerMoveEntity(id);
	DestroyPlayerDispensers(id);

	g_DispOrigin[id][0] = 0.0;
	g_DispOrigin[id][1] = 0.0;
	g_DispOrigin[id][2] = 0.0;

	g_DispPlayerCount[id] = false;
	g_PlayerMoving[id] = 0;
	g_fTimeFloodDispTouch[id] = 0.0;
	g_fTimeGiveMoney[id] = 0.0;
	g_fTimePostThink[id] = 0.0;
	g_fTimePlantHud[id] = 0.0;
	g_fTimeGiveAmmo[id] = 0.0;
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
	new i;
	for(i = 0; i < sizeof(g_DispenserSprites); i++)
		g_PrecacheSprites[E_SPRITES:i] = precache_model(g_DispenserSprites[i]);

	for(i = 0; i < sizeof(g_DispenserModels); i++)
		g_PrecacheModels[E_MODELS:i]   = precache_model(g_DispenserModels[i]);

	for(i = 0; i < sizeof(g_DispenserSound); i++)
		precache_sound(g_DispenserSound[i]);

	for(i = 0; i < sizeof(g_BulletsSounds); i++)
		engfunc(EngFunc_PrecacheSound, g_BulletsSounds[i]);

	for(i = 0; i < sizeof(g_DamageSounds); i++) 
		engfunc(EngFunc_PrecacheSound, g_DamageSounds[i]);
}

public EventNewRound()
{
	if(g_Cvars[CV_REMOVE_ROUND_RESTART])
		ForceDestroyDispensers();
}

public PlayerPreThink(id)
{
	static Float:ftime;
	ftime = get_gametime();

	if(ftime - 0.05 > g_fTimePostThink[id]) // sem spamar o think
	{
		if(g_PlayerMoving[id] && is_user_alive(id))
		{
			static iEnt; iEnt = FM_NULLENT

			while((iEnt = find_ent_by_class(iEnt, dispenser_classmove)))
			{
				if(entity_get_int(iEnt, EV_INT_iuser2) != id)
					continue

				if(pev_valid(iEnt))
				{
					static Float:fOrigin[3]
					xGetOriginFromDistPlayer(id, 125.0, fOrigin)
					entity_set_origin(iEnt, fOrigin)
					drop_to_floor(iEnt)

					static entlist[3]
					if(find_sphere_class(iEnt, dispenser_classname, 100.0, entlist, 2) || find_sphere_class(iEnt, "player", 20.0, entlist, 2) || TraceCheckCollides(fOrigin, 35.0))
					{
						entity_set_int(iEnt, EV_INT_sequence, BUILD_DISPENSER_NO)
						g_iPlantOk[id] = false
					}
					else
					{
						entity_set_int(iEnt, EV_INT_sequence, BUILD_DISPENSER_YES)
						g_iPlantOk[id] = true
					}
				}
			}

			if(ftime - 1.2 > f_TimePlantHud[id])
			{
				set_shudmessage
				(
					0, // r
					150, // g
					255, // b
					100, // alpha
					0.04, 0.60,
					1.1, // holdtime (tempo exibido na tela)
					0.04, // fade in time
					0.04, // fade out time
					-1, // channel
					2, // effect
					255, // effect_R
					255, // effect_G
					255, // effect_B
					255, // effect_alpha
					0.07 // effect time
				)
				show_shudmessage(id, "Aperte [E] para plantar^n^t^t^t^t^tO dispenser!")

				f_TimePlantHud[id] = ftime
			}
		}

		f_TimePostThink[id] = ftime
	}
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
	if (ArrayCount(g_Dispensers[id]) >= g_Cvars[CV_LIMIT_PER_PLAYER])
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
	if(iMoney < g_Cvars[CV_LVL1_PRICE])
	{
		CheckFailure(id, fmt("%s ^3Not enough money. ^4$: %s^3.", PREFIX_CHAT, xAddPoint(g_Cvars[CV_LVL1_PRICE])));
		return PLUGIN_HANDLED;
	}

	if(g_PlayerMoving[id])
	{
		CheckFailure(id, fmt("%s ^4Dispenser ^3is being deployed. Please purchase after deploying.", PREFIX_CHAT));
		return PLUGIN_HANDLED;
	}

	if(g_Cvars[CV_INSTANT_PLANT])
	{
		static Float:fOrigin[3]
		get_origin_from_dist_player(id, 100.0, fOrigin);

		if(CreateDispanser(fOrigin, id))
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

	new iPlayers[MAX_PLAYERS];
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeDead | GetPlayers_ExcludeHLTV);

	for (new i = 0; i < iNum + 1; i++)
	{
		switch(cs_get_user_team(iPlayers[i]))
		{
			case CS_TEAM_T:
				TCount += ArrayCount(g_Dispensers[iPlayers[i]]);

			case CS_TEAM_CT:
				CTCount += ArrayCount(g_Dispensers[iPlayers[i]]);
		}
	}
}

public DestroyDispenser(id)
{
	if(ArraySize(g_Dispensers[id]) <= 0)
	{
		client_print_color(id, print_team_default, "%s ^3There is no ^4Dispenser ^3to destroy.", PREFIX_CHAT);
		client_cmd(id, "spk %s", g_DispenserSound[SND_FAIL]);

		return PLUGIN_HANDLED;
	}

	new iLevel, iMoney;
	while((ent = ArrayGetCell(g_Dispensers[id], i++)))
	{
		if (!pev_valid(ent))
			continue;
		
		if (pev(ent, DISPENSER_OWNER) != id)
			continue;
		
		iLevel = pev(ent, DISPENSER_LEVEL);
		iMoney = g_Cvars[CV_LVL1_PRICE + (iLevel - 1)] / 2;

		cs_set_user_money(id, cs_get_user_money(id) + iMoney);
		client_print_color(id, print_team_default, "%s ^3Destroyed ^4Dispenser ^3at Level: ^4%d ^3and got ^4$: %s ^3money.", iLevel, xAddPoint(iMoney));

		RemoveEntity(ent);
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
	get_origin_from_dist_player(id, 128.0, fOrigin);

	new iEnt;

	iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	if(!pev_valid(iEnt))
		return false;
	
	set_pev(iEnt, pev_classname, dispenser_classmove);
	engfunc(EngFunc_SetModel, iEnt, g_PrecacheModels[MDL_BLUEPRINT]);
	set_pev(iEnt, pev_origin, fOrigin);
	set_pev(iEnt, pev_solid, SOLID_NOT);
	set_pev(iEnt, DISPENSER_OWNER, id);
	set_pev(iEnt, pev_framerate, 0.0);
	set_pev(iEnt, pev_animtime, get_gametime());
	set_pev(iEnt, pev_sequence, BUILD_DISPENSER_NO);

	fm_set_rendering(iEnt, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 255);
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.1);

	g_PlayerMoving[id] = iEnt;

	return true;
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}

public fw_CmdStart(id, uc_handle, randseed)
{
	if(!is_user_connected(id) || !is_user_alive(id))
		return FMRES_IGNORED

	static button; button = get_uc(uc_handle , UC_Buttons)
	static oldbutton; oldbutton = pev(id, pev_oldbuttons)

	if(button & IN_USE && !(oldbutton & IN_USE) && g_PlayerMovingDisp[id] && g_iPlantOk[id])
		xDispFinalCheck(id)

	return FMRES_IGNORED
}

public xDispFinalCheck(id)
{
	static Float:fOrigin[3]
	get_origin_from_dist_player(id, 128.0, fOrigin)

	if(xCreateDispanser(fOrigin, id))
	{
		client_print_color(id, print_team_default, "%s ^4Dispenser ^3plantado!", PREFIX_CHAT)
		DestroyPlayerMoveEntity(id)

		g_PlayerMovingDisp[id] = false
	}
}

public xAllowPlant(id)
{
	static Float:vTraceDirection[3], Float:vTraceEnd[3],Float:vOrigin[3];
	
	pev(id, pev_origin, vOrigin)
	vOrigin[2] += 15
	velocity_by_aim(id, 128, vTraceDirection)
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd)
	
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0)
	
	static Float:fFraction
	get_tr2(0, TR_flFraction, fFraction)
	
	// -- We hit something!
	if(fFraction < 1.0)
		return true

	return false
}

public DestroyPlayerMoveEntity(id)
{
	static ent; ent = FM_NULLENT
	iEnt = -1;
	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", dispenser_classmove)))
	{
		if(pev(ent, DISPENSER_OWNER) != id)
			continue

		if(pev_valid(ent))
			RemoveEntity(ent)
	}
}

public fw_DispenserTouch(ent, id)
{
	static Float:time
	time = get_gametime()

	if(f_TimeFloodDispTouch[id] > time)
		return PLUGIN_CONTINUE

	f_TimeFloodDispTouch[id] = time + 2.5
    
	if(!pev_valid(ent))
		return PLUGIN_CONTINUE

	if(!is_user_connected(id) || !is_user_alive(id))
		return PLUGIN_CONTINUE

	static CsTeam:iTeam
	iTeam = CsTeam:pev(ent, DISPENSER_TEAM)

	static iLevel
	iLevel = pev(ent, DISPENSER_LEVEL)

	if(iLevel == 4)
		return PLUGIN_CONTINUE

	if(iTeam != get_user_team(id))
		return PLUGIN_CONTINUE

	static iOwner
	iOwner = pev(ent, DISPENSER_OWNER)

	{
		if(iOwner == id)
		{
			client_print_color(id, print_team_default, "%s ^3Você não pode upar o level do seu proprio ^4Dispenser ^3apenas ^1V.I.P^3.", PREFIX_CHAT)
			client_cmd(id, "spk %s", g_DispSndFail)

			return PLUGIN_CONTINUE
		}
	}
	
	static iMoney
	iMoney = cs_get_user_money(id)

	static iDispBuy, iDispHpUp

	switch(iLevel + 1)
	{
		case 1: iDispBuy = get_pcvar_num(g_Cvars[CVAR_LVL1_PRICE]), iDispHpUp = get_pcvar_num(g_Cvars[CVAR_DISP_HP_LVL1])
		case 2: iDispBuy = get_pcvar_num(g_Cvars[CVAR_LVL2_PRICE]), iDispHpUp = get_pcvar_num(g_Cvars[CVAR_DISP_HP_LVL2])
		case 3: iDispBuy = get_pcvar_num(g_Cvars[CVAR_LVL3_PRICE]), iDispHpUp = get_pcvar_num(g_Cvars[CVAR_DISP_HP_LVL3])
		case 4: iDispBuy = get_pcvar_num(g_Cvars[CVAR_LVL4_PRICE]), iDispHpUp = get_pcvar_num(g_Cvars[CVAR_DISP_HP_LVL4])
	}

	if(iMoney < iDispBuy)
	{
		client_print_color(id, print_team_default, "%s ^3Você não possui ^4dinheiro ^3para subir o ^4Dispenser ^3de level. ^1Preço: ^4$: %s^3.", PREFIX_CHAT, xAddPoint(iDispBuy))
		client_cmd(id, "spk %s", g_DispSndFail)

		return PLUGIN_CONTINUE
	}

	iLevel ++
	cs_set_user_money(id, iMoney - iDispBuy)

	if(task_exists(ent+TASK_ANIM))
		remove_task(ent+TASK_ANIM)

	set_pev(ent, DISPENSER_LEVEL, iLevel)
	set_pev(ent, pev_health, float(iDispHpUp))

	static iDispVip
	iDispVip = pev(ent, DISPENSER_VIP)

	engfunc(EngFunc_SetModel, ent, g_DispModel)
	set_pev(ent, pev_modelindex, xModelIndex[1])

	engfunc(EngFunc_SetSize, ent, Float:{ -20.0, -20.0, 0.0 }, Float:{ 20.0, 20.0, 80.0 })
	emit_sound(ent, CHAN_STATIC, g_DispActive, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
    
	switch(cs_get_user_team(id))
	{
		case CS_TEAM_T:
		{
			g_BeamColor[id][0] = 255
			g_BeamColor[id][1] = 0
			g_BeamColor[id][2] = 0

			switch(iLevel)
			{
				case 2:
				{
					if(iDispVip && !get_pcvar_num(g_Cvars[CVAR_ONEMODEL]))
					{
						UTIL_SetAnim(ent, ANIM_LVL2_BUILD, 1.0)
						set_task(1.4, "Model_IdleLvl2", ent+TASK_ANIM)
					}
					else
					{
						set_pev(ent, pev_body, 5)
					}
				}

				case 3:
				{
					if(iDispVip && !get_pcvar_num(g_Cvars[CVAR_ONEMODEL]))
					{
						UTIL_SetAnim(ent, ANIM_LVL3_BUILD, 1.0)
						set_task(0.9, "Model_IdleLvl3", ent+TASK_ANIM)
					}
					else
					{
						set_pev(ent, pev_body, 6)
					}
				}

				case 4:
				{
					if(iDispVip && !get_pcvar_num(g_Cvars[CVAR_ONEMODEL]))
					{
						UTIL_SetAnim(ent, ANIM_LVL3_BUILD, 1.0)
						set_task(0.9, "Model_IdleLvl3", ent+TASK_ANIM)
					}
					else
					{
						set_pev(ent, pev_body, 7)
					}
				}
			}

			set_pev(ent, pev_skin, get_user_team(id))
		}

		case CS_TEAM_CT:
		{
			g_BeamColor[id][0] = 0
			g_BeamColor[id][1] = 0
			g_BeamColor[id][2] = 255

			switch(iLevel)
			{
				case 2:
				{
					if(iDispVip && !get_pcvar_num(g_Cvars[CVAR_ONEMODEL]))
					{
						UTIL_SetAnim(ent, ANIM_LVL2_BUILD, 1.0)
						set_task(1.4, "Model_IdleLvl2", ent+TASK_ANIM)
					}
					else
					{
						set_pev(ent, pev_body, 1)
					}
				}

				case 3:
				{
					if(iDispVip && !get_pcvar_num(g_Cvars[CVAR_ONEMODEL]))
					{
						UTIL_SetAnim(ent, ANIM_LVL3_BUILD, 1.0)
						set_task(0.9, "Model_IdleLvl3", ent+TASK_ANIM)
					}
					else
					{
						set_pev(ent, pev_body, 2)
					}
				}

				case 4:
				{
					if(iDispVip && !get_pcvar_num(g_Cvars[CVAR_ONEMODEL]))
					{
						UTIL_SetAnim(ent, ANIM_LVL3_BUILD, 1.0)
						set_task(0.9, "Model_IdleLvl3", ent+TASK_ANIM)
					}
					else
					{
						set_pev(ent, pev_body, 3)
					}
				}
			}

			set_pev(ent, pev_skin, get_user_team(id))
		}
	}
    
	if(!is_user_connected(iOwner))
		return PLUGIN_CONTINUE
    
	static szName[32]
	get_user_name(id, szName, charsmax(szName))

	if(iOwner == id)
		client_print_color(id, print_team_default, "%s ^3Você subiu o level do seu ^4Dispenser ^3para o level: ^4%d^3.", PREFIX_CHAT, iLevel)
	else
		client_print_color(iOwner, print_team_default, "%s ^1%s ^3subiu o level do seu ^4Dispenser ^3para o level: ^4%d^3.", PREFIX_CHAT, szName, iLevel)

	return PLUGIN_CONTINUE
}

public DispenserThink(iEnt)
{
	// Skip. Invalid Entity.
	if (!pev_valid(iEnt))
		return PLUGIN_CONTINUE;

	static classname[32];
	pev(iEnt, pev_classname, classname);
	
	// Skip. Not Dispenser.
	if (!equali(classname, dispenser_classname))
		return PLUGIN_CONTINUE;

	static iOwner;
	iOwner = pev(iEnt, DISPENSER_OWNER);

	// Skip. Disconnected Owner.
	if(!is_user_connected(iOwner))
	{
		RemoveEntity(iEnt);
		return PLUGIN_CONTINUE;
	}

	// Effect Level4
	if (g_Cvars[CV_EFFECT_LVL_4])
	{
		if(!(pev(iEnt, pev_effects) & EF_BRIGHTFIELD))
			set_pev(iEnt, pev_effects, pev(iEnt, pev_effects) | EF_BRIGHTFIELD);
	}

	static iLevel;
	static CsTeam:iTeam;
	static Float:fOrigin[3];
	static Float:fOriginTarget[3];
	static Float:time;
	static id;
	static Float:fRadius;

	// Get Max Radius.
	fRadius = max(g_Cvars[CV_RECOVERY_RADIUS], g_Cvars[CV_GIVE_MONEY_DISTANCE]);
	fRadius = max(fRadius, g_Cvars[CV_GIVE_AMMO_DISTANCE]);

	time = get_gametime();

	iLevel 	= pev(iEnt, DISPENSER_LEVEL);
	iTeam	= CsTeam:pev(iEnt, DISPENSER_TEAM);
	pev(iEnt, pev_origin, fOrigin);

	id = -1;
	// Find Entity in Sphere of Dispenser.
	while((id = engfunc(EngFunc_FindEntityInSphere, id, flOrigin, fRadius)) != 0)
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
			static distance;
			distance = get_distance_f(fOrigin, fOriginTarget);

			static bool:recovery;
			recovery = false;

			// If inside recovery radius.
			if (distance <= g_Cvars[CV_RECOVERY_RADIUS])
			{
				// Recovery Health.
				if (pev(id, pev_health) < g_Cvars[CV_LVL1_MAX_HP + (iLevel - 1)])
				{
					recovcery = true;
					set_pev(id, pev_health, floatmin(pev(id, pev_health) + g_Cvars[CV_LVL1_AMOUNT_HP + (iLevel - 1)], float(g_Cvars[CV_LVL1_MAX_HP + (iLevel - 1)])));
					if (g_Cvars[CV_SHOW_LIFE_SPRITE])
					{
						message_begin(MSG_PVS, SVC_TEMPENTITY, fOriginTarget);
						write_byte(TE_PROJECTILE);
						write_coord(fOriginTarget[0] + random_num(-10, 15));
						write_coord(fOriginTarget[1] + random_num(-10, 15));
						write_coord(fOriginTarget[2] + random_num(5, 30));
						write_coord(10);
						write_coord(15);
						write_coord(20);
						write_short(iTeam == 1 ? g_PrecacheSprites[SPR_HEAL_LIFE_R] : g_PrecacheSprites[SPR_HEAL_LIFE_B]);
						write_byte(1);
						write_byte(id);
						message_end();
					}
				}
				// Recovery Armor.
				if(pev(id, pev_armorvalue) < g_Cvars[CV_LVL1_MAX_ARMOR + (iLevel - 1)])
				{
					recovcery = true;
					set_pev(id, pev_armorvalue, floatmin(pev(id, pev_armorvalue) + g_Cvars[CV_LVL1_AMOUNT_ARMOR + (iLevel - 1)], float(g_Cvars[CV_LVL1_MAX_ARMOR + (iLevel - 1)])))
				}
			}

			// Check give money time think time.
			if (time - g_Cvars[CV_GIVE_MONEY_TIME] > g_fTimeGiveMoney[id])
			{
				// If inside give money radius.
				if (distance <= g_Cvars[CV_GIVE_MONEY_DISTANCE])
					cs_set_user_money(id, cs_get_user_money(id) + random_num(g_Cvars[CV_GIVE_MONEY_MIN], g_Cvars[CV_GIVE_MONEY_MAX]))

				g_fTimeGiveMoney[id] = time;
			}

			if (pev_valid(id) == 2)
			{
				if (iLevel == 4 || g_Cvars[CV_GIVE_AMMO_ALL_LVL])
				{
					// Check give money ammo think time.
					if (time - g_Cvars[CV_GIVE_AMMO_TIME] > g_fTimeGiveAmmo[id])
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

							currentAmmo 	= cs_get_weapon_ammo(currentWpnEntId);
							currentBPAmmo 	= cs_get_user_bpammo(id, currentWpn);

							newAmmo 		= currentAmmo   + random_num(g_Cvars[CV_GIVE_AMMO_MIN], g_Cvars[CV_GIVE_AMMO_MAX]);
							newBPAmmo 		= currentBPAmmo + random_num(g_Cvars[CV_GIVE_AMMO_MIN], g_Cvars[CV_GIVE_AMMO_MAX]);
								
							if(currentAmmo == gWeaponAmmo[currentWpn][0] && currentBPAmmo == gWeaponAmmo[currentWpn][1])
								continue

							cs_set_weapon_ammo(currentWpnEntId, min(newAmmo, gWeaponAmmo[currentWpn][0]));
							cs_set_user_bpammo(id, currentWpn, min(newBPAmmo, gWeaponAmmo[currentWpn][1]));
							emit_sound(id, CHAN_ITEM, g_BulletsSounds[random_num(0, charsmax(g_BulletsSounds))], 0.3, ATTN_NORM, 0, PITCH_NORM)
						}
						g_fTimeGiveAmmo[id] = time;
					}
				}
			}

			// Show line.
			if (recovery && g_Cvars[CV_SHOW_LINE])
			{
				static color[3];
				color[0] = (iTeam == CS_TEAM_T) : 255 : 0;
				color[1] = 0;
				color[2] = (iTeam == CS_TEAM_CT) : 255 : 0;
				UTIL_BeamEnts(fOriginTarget, fOrigin, color, g_PrecacheSprites[SPR_LASER], 40, 0, 1);
			}
			continue;
		} else
		{
			static targetClassName[32];
			pev(iEnt, pev_classname, targetClassName);
			// Skip. Not Dispenser.
			if (!equali(targetClassName, dispenser_classname))
				continue;

			static targetOwner;
			static CsTeam:targetTeam;
			targetOwner = pev(iEnt, DISPENSER_OWNER);
			targetTeam = CsTeam:pev(id, DISPENSER_TEAM);
			// Skip. Enemies.
			if (targetTeam != iTeam)
				continue;
			
			// Skip. Can't Look Dispenser.
			if (!UTIL_IsVisible(id, iEnt, 1))
				continue;

			// Get Target origin.
			pev(id, pev_origin, fOriginTarget);

			// Get distance dispencer to target.
			static distance;
			distance = get_distance_f(fOrigin, fOriginTarget);

			// If inside recovery radius.
			if (distance <= g_Cvars[CV_RECOVERY_RADIUS])
			{
				// Recovery Dispensers.
				static AmountHP;
				AmountHP = floatmin(g_Cvars[CV_LVL1_AMOUNT_HP + (pev(id, DISPENSER_LEVEL) - 1)], g_Cvars[CV_LVL1_DISPENSER_HEALTH + (pev(id, DISPENSER_LEVEL) - 1)];
				set_pev( ent, pev_health, AmountHP);

				static color[3];
				color[0] = (iTeam == CS_TEAM_T) : 255 : 0;
				color[1] = 0;
				color[2] = (iTeam == CS_TEAM_CT) : 255 : 0;
				UTIL_BeamEnts(fOriginTarget, fOrigin, color, g_PrecacheSprites[SPR_LASER], 40, 0, 1);
			}
		}
	}

	// Breaking....
	static CurrentHealth;
	CurrentHealth = pev(iEnt, pev_health)

	// TODO: NOT USE MAGIC NUMBER 350.0.
	if(CurrentHealth <= 350.0)
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(TE_SMOKE);
		engfunc(EngFunc_WriteCoord, fOrigin[0] + random_float(-8.0, 8.0));
		engfunc(EngFunc_WriteCoord, fOrigin[1] + random_float(-8.0, 8.0));
		engfunc(EngFunc_WriteCoord, fOrigin[2] + random_float(25.0, 50.0));
		write_short(g_PrecSprSmoke);
		write_byte(random_num(3,10));
		write_byte(30); //def: 30
		message_end();
	}

	// Destroy Dispenser when changing teams.
	if(cs_get_user_team(iOwner) != iTeam)
	{
		DestroyPlayerDispensers(iOwner); // remove todos dispensers da PESSOA
		return PLUGIN_CONTINUE;
	}

	set_pev(iEnt, pev_nextthink, get_gametime() + 1.0);	
	return PLUGIN_CONTINUE;
}

stock ForceDestroyDispensers()
{
	new n = 0;
	new iEnt = -1;
	for(new i = 0; i <= MAX_PLAYERS; i++)
	{
		while(iEnt = ArrayGetCell(g_Dispensers[i], n++))
		{
			if(pev_valid(ent))
				RemoveEntity(ent)
		}
		ArrayClear(g_Dispensers[i]);
	}

	iEnt = -1;
	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", dispenser_classname)))
	{
		if(pev_valid(ent))
			RemoveEntity(ent)
	}
}

public DestroyPlayerDispensers(id)
{
	new i = 0, iEnt;
	while(iEnt = ArrayGetCell(g_Dispensers[id], i++))
	{
		if (pev_valid(iEnt))
			RemoveEntity(iEnt);
	}
	ArrayClear(g_Dispensers[id]);
}

public fw_TraceLinePost(Float:v1[3], Float:v2[3], noMonsters, id)
{
	if(!is_valid_player(id) || is_user_bot(id) || !is_user_alive(id))
		return FMRES_IGNORED

	new iHitEnt
	iHitEnt = get_tr(TR_pHit)

	if(iHitEnt <= MaxClients || !pev_valid(iHitEnt))
		return FMRES_IGNORED

	new szClassname[32]
	pev(iHitEnt, pev_classname, szClassname, charsmax(szClassname))

	if(!equal(szClassname, dispenser_classname))
		return FMRES_IGNORED

	new iTeam; iTeam = pev(iHitEnt, DISPENSER_TEAM)

	if(get_user_team(id) != iTeam)
		return FMRES_IGNORED

	new iHealth
	iHealth = pev(iHitEnt, pev_health)

	if(iHealth <= 0)
		return FMRES_IGNORED

	new iOwner; iOwner = pev(iHitEnt, DISPENSER_OWNER)

	if(!is_user_connected(iOwner))
		return FMRES_IGNORED

	new szName[32]
	get_user_name(iOwner, szName, charsmax(szName))

	new iLevel; iLevel = pev(iHitEnt, DISPENSER_LEVEL)

	set_dhudmessage(255, 255, 255, -1.0, 0.65, 0, 0.1, 1.1, 0.0, 0.0)
	show_dhudmessage(id, "Proprietário: %s^nVida: %s^nLevel: %d", szName, xAddPoint(iHealth), iLevel)
	
	return FMRES_IGNORED
}

public ham_TraceAttackPre(ent, iAttacker, Float:flDamage, Float:flDirection[3], iTr, iDamageBits)
{
	if(!pev_valid(ent))
		return HAM_IGNORED
		
	new szClassname[32]
	pev(ent, pev_classname, szClassname, charsmax(szClassname))
	
	if(equal(szClassname, dispenser_classname))
	{
		new iOwner; iOwner = pev(ent, DISPENSER_OWNER)

		if(!is_user_connected(iOwner) || !is_user_connected(iAttacker) || !is_valid_player(iOwner) || !is_valid_player(iAttacker))
			return HAM_SUPERCEDE

		new Float:flEndOrigin[3]
		get_tr2(iTr, TR_vecEndPos, flEndOrigin)
	
		UTIL_Sparks(flEndOrigin)
	}

	return HAM_IGNORED
}

public ham_TakeDamagePre(ent, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!pev_valid(ent))
		return HAM_IGNORED

	new szClassname[32]
	pev(ent, pev_classname, szClassname, charsmax(szClassname))
                                        
	if(equal(szClassname, dispenser_classname))
	{
		new iOwner; iOwner = pev(ent, DISPENSER_OWNER)

		if(!is_user_connected(iOwner) || !is_user_connected(idattacker) || !is_valid_player(iOwner) || !is_valid_player(idattacker))
			return HAM_SUPERCEDE

		if(get_user_team(iOwner) == get_user_team(idattacker) && idattacker != iOwner)
			return HAM_SUPERCEDE
	}

	return HAM_IGNORED 
}

public ham_TakeDamagePost(ent, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!pev_valid(ent))
		return HAM_IGNORED

	new szClassname[32]
	pev(ent, pev_classname, szClassname, charsmax(szClassname))

	if(equal(szClassname, dispenser_classname))
	{
		if(!pev_valid(ent))
			return HAM_IGNORED

		new iOwner; iOwner = pev(ent, DISPENSER_OWNER)

		if(!is_user_connected(iOwner) || !is_user_connected(idattacker) || !is_valid_player(iOwner) || !is_valid_player(idattacker))
			return HAM_SUPERCEDE

		if(get_user_team(iOwner) == get_user_team(idattacker) && idattacker != iOwner)
			return HAM_SUPERCEDE

		if(pev(ent, pev_health) <= 0.0)
		{
			new CsTeam:iTeam; iTeam = CsTeam:pev(ent, DISPENSER_TEAM)

			new Float:originF[3]
			pev(ent, pev_origin, originF)

			new szName[32]
			get_user_name(idattacker, szName, charsmax(szName))

			new szNameOwner[32]
			get_user_name(iOwner, szNameOwner, charsmax(szNameOwner))

			UTIL_BreakModel(originF, iTeam == 1 ? g_PrecDispModelGibsR : g_PrecDispModelGibsB, 2)
			DispenserExplode(originF, 10, 50, 50, 2, 35, 50)

			if(idattacker == iOwner)
			{
				client_print_color(iOwner, print_team_default, "%s ^3Você destruiu seu próprio ^4Dispenser^3.", PREFIX_CHAT)
			}
			else
			{
				client_print_color(0, print_team_default, "%s ^1%s ^3destruiu o ^4Dispenser ^3de ^1%s ^3e ganhou ^4$: %s ^3de dinheiro.", PREFIX_CHAT, szName, szNameOwner, xAddPoint(get_pcvar_num(g_Cvars[CVAR_BONUS_DESTROY])))
				cs_set_user_money(idattacker, cs_get_user_money(idattacker) + get_pcvar_num(g_Cvars[CVAR_BONUS_DESTROY]))
			}

			emit_sound(ent, CHAN_ITEM, g_DispSndDestroy, VOL_NORM, ATTN_NORM, 0, PITCH_HIGH)
			g_DispPlayerCount[iOwner] --
			//xLimitTeamAtt(iOwner)

			xRemoveEntFix(ent)
		}

		if(pev_valid(ent))
			emit_sound(ent, CHAN_STATIC, g_DamageSounds[random_num(0, charsmax(g_DamageSounds))], 0.3, ATTN_NORM, 0, PITCH_NORM)
	}

	return HAM_IGNORED
}

stock bool:xCreateDispanser(Float:origin[3], creator)
{
	if(get_pcvar_num(g_Cvars[CVAR_INSTANT_PLANT]))
	{
		static xEntList[3]

		if(find_sphere_class(creator, dispenser_classname, 130.0, xEntList, charsmax(xEntList)) || TraceCheckCollides(origin, 35.0) || !(pev(creator, pev_flags) & FL_ONGROUND))
		{
			client_print_color(creator, print_team_default, "%s ^3Adicione o ^4dispenser ^3longe dos outros e não o encoste em paredes.", PREFIX_CHAT)
			//client_cmd(creator, "spk %s", g_DispSndFail)
			
			return false
		}
	}
	else
	{
		if(!xAllowPlant(creator))
		{
			client_print_color(creator, print_team_default, "%s ^3Mire para o chão ^1PLANO ^3e perto para poder adicionar o ^4Dispenser^3.", PREFIX_CHAT)
			//client_cmd(creator, "spk %s", g_DispSndFail)

			return false
		}
	}

	if(point_contents(origin) != CONTENTS_EMPTY)
		return false

	new ent; ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))

	if(!pev_valid(ent))
		return false

	new iLevel; iLevel = 1

	set_pev(ent, pev_classname, dispenser_classname)

	engfunc(EngFunc_SetModel, ent, g_DispModel)
	set_pev(ent, pev_modelindex, xModelIndex[1])

	engfunc(EngFunc_SetSize, ent, Float:{ -20.0, -20.0, 0.0 }, Float:{ 20.0, 20.0, 80.0 })
	set_pev(ent, pev_origin, origin)
	set_pev(ent, pev_solid, SOLID_BBOX)
	set_pev(ent, pev_movetype, MOVETYPE_TOSS)
	set_pev(ent, pev_health, float(get_pcvar_num(g_Cvars[CVAR_DISP_HP_LVL1])))
	set_pev(ent, pev_takedamage, 1.0)
//	set_pev(ent, DISPENSER_VIP, g_IsVip[creator])
	set_pev(ent, DISPENSER_OWNER, creator)
	set_pev(ent, DISPENSER_LEVEL, iLevel)
	set_pev(ent, DISPENSER_TEAM, cs_get_user_team(creator))
	

	if(get_pcvar_num(g_Cvars[CVAR_IDLE_SOUND]))
	{
		xDispenserSndIdle(ent)
		set_task(1.9, "xDispenserSndIdle", ent, _, _, "b")
	}

	if(get_pcvar_num(g_Cvars[CVAR_LIGHT]))
		set_task(0.1, "xDispenserLight", ent, _, _, "b")

	g_DispOrigin[creator][0] = origin[0]
	g_DispOrigin[creator][1] = origin[1]
	g_DispOrigin[creator][2] = origin[2]

	switch(cs_get_user_team(creator))
	{
		case CS_TEAM_T:
		{
			g_BeamColor[creator][0] = 255
			g_BeamColor[creator][1] = 0
			g_BeamColor[creator][2] = 0

			if(get_pcvar_num(g_Cvars[CVAR_ONEMODEL]))
				set_pev(ent, pev_body, 4)
			else
			{
//				if(!g_IsVip[creator])
					set_pev(ent, pev_body, 4)
			}

			if(get_pcvar_num(g_Cvars[CVAR_GLOW]))
				fm_set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 10)
			
			//xLimitGlobal[0]++
		}

		case CS_TEAM_CT:
		{
			g_BeamColor[creator][0] = 0
			g_BeamColor[creator][1] = 0
			g_BeamColor[creator][2] = 255
		
			if(get_pcvar_num(g_Cvars[CVAR_ONEMODEL]))
				set_pev(ent, pev_body, 0)
			else
			{
//				if(!g_IsVip[creator])
					set_pev(ent, pev_body, 0)
			}

			if(get_pcvar_num(g_Cvars[CVAR_GLOW]))
				fm_set_rendering(ent, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 10)
			
			//xLimitGlobal[1]++
		}
	}

	emit_sound(ent, CHAN_STATIC, g_DispActive, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	g_DispPlayerCount[creator] ++
	
	set_pev(ent, pev_nextthink, get_gametime() + 0.1)

	return true
}

public xDispenserSndIdle(ent)
{
	if(!pev_valid(ent))
	{
		if(task_exists(ent))
			remove_task(ent)

		return
	}

	emit_sound(ent, CHAN_ITEM, g_DispSndIdle, 0.35, ATTN_IDLE, 0, PITCH_NORM)
}

public xDispenserLight(ent)
{
	if(!pev_valid(ent))
	{
		if(task_exists(ent))
			remove_task(ent)

		return
	}

	static Float:origin[3]
	pev(ent, pev_origin, origin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_DLIGHT)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_byte(3) // radius
	write_byte(100) // r
	write_byte(100) // g
	write_byte(100) // b
	write_byte(20) // life 10 = 1seg
	write_byte(0) // decay
	message_end()
}

stock UTIL_BreakModel(Float:flOrigin[3], model, flags)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
	write_byte(TE_BREAKMODEL)
	engfunc(EngFunc_WriteCoord, flOrigin[0])
	engfunc(EngFunc_WriteCoord, flOrigin[1])
	engfunc(EngFunc_WriteCoord, flOrigin[2])
	write_coord(16)
	write_coord(16)
	write_coord(16)
	write_coord(random_num(-20, 20))
	write_coord(random_num(-20, 20))
	write_coord(10)
	write_byte(10)
	write_short(model)
	write_byte(10)
	write_byte(50) // time = 10 = 1 segundo
	write_byte(flags)
	message_end()
}

stock UTIL_SetAnim(ent, anim, Float:framerate)
{
	if(!pev_valid(ent))
		return
	
	set_pev(ent, pev_animtime, get_gametime())
	set_pev(ent, pev_framerate, framerate)
	set_pev(ent, pev_sequence, anim)
	
}

stock bool:UTIL_IsVisible(index, entity, ignoremonsters = 0)
{
	new Float:flStart[3], Float:flDest[3]

	pev(index, pev_origin, flStart)
	pev(index, pev_view_ofs, flDest)

	xs_vec_add(flStart, flDest, flStart)

	pev(entity, pev_origin, flDest)
	engfunc(EngFunc_TraceLine, flStart, flDest, ignoremonsters, index, 0)

	new Float:flFraction
	get_tr2(0, TR_flFraction, flFraction)

	if(flFraction == 1.0 || get_tr2(0, TR_pHit) == entity)
	{
		return true
	}

	return false
}

stock UTIL_BeamEnts(Float:flStart[3], Float:flEnd[3], rgb[3], sprite, width, ampl, speed)
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
	write_byte(rgb[0]);	//R
	write_byte(rgb[1]);	//G
	write_byte(rgb[2]);	//B
	write_byte(255);	// def: 130
	write_byte(speed);	// def: 30
	message_end();
}

stock bool:TraceCheckCollides(Float:origin[3], const Float:BOUNDS)
{
	static Float:traceEnds[8][3], Float:traceHit[3], hitEnt
	traceEnds[0][0] = origin[0] - BOUNDS
	traceEnds[0][1] = origin[1] - BOUNDS
	traceEnds[0][2] = origin[2] - BOUNDS
	traceEnds[1][0] = origin[0] - BOUNDS
	traceEnds[1][1] = origin[1] - BOUNDS
	traceEnds[1][2] = origin[2] + BOUNDS
	traceEnds[2][0] = origin[0] + BOUNDS
	traceEnds[2][1] = origin[1] - BOUNDS
	traceEnds[2][2] = origin[2] + BOUNDS
	traceEnds[3][0] = origin[0] + BOUNDS
	traceEnds[3][1] = origin[1] - BOUNDS
	traceEnds[3][2] = origin[2] - BOUNDS
	traceEnds[4][0] = origin[0] - BOUNDS
	traceEnds[4][1] = origin[1] + BOUNDS
	traceEnds[4][2] = origin[2] - BOUNDS
	traceEnds[5][0] = origin[0] - BOUNDS
	traceEnds[5][1] = origin[1] + BOUNDS
	traceEnds[5][2] = origin[2] + BOUNDS
	traceEnds[6][0] = origin[0] + BOUNDS
	traceEnds[6][1] = origin[1] + BOUNDS
	traceEnds[6][2] = origin[2] + BOUNDS
	traceEnds[7][0] = origin[0] + BOUNDS
	traceEnds[7][1] = origin[1] + BOUNDS
	traceEnds[7][2] = origin[2] - BOUNDS

	static i, j
	for(i = 0; i < 8; i++)
	{
		if(point_contents(traceEnds[i]) != CONTENTS_EMPTY)
			return true

		hitEnt = trace_line(0, origin, traceEnds[i], traceHit)

		if(hitEnt != 0)
			return true


		for(j = 0; j < 3; j++)
		{
			if(traceEnds[i][j] != traceHit[j])
				return true
		}
	}

	return false
}

stock DispenserExplode(const Float:originF[3], head, sprites, life, tamanho, velo, decals)
{	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0);
	write_byte(TE_SPRITETRAIL);
	engfunc(EngFunc_WriteCoord, originF[0]); // X
	engfunc(EngFunc_WriteCoord, originF[1]); // Y
	engfunc(EngFunc_WriteCoord, originF[2]+head); // Z
	engfunc(EngFunc_WriteCoord, originF[0]); // X
	engfunc(EngFunc_WriteCoord, originF[1]); // Y
	engfunc(EngFunc_WriteCoord, originF[2]+head); // Z
	write_short(g_PrecSprFlare3);
	write_byte(sprites); // quantas sprites vai sair...
	write_byte(life); // life
	write_byte(tamanho); // tamanho
	write_byte(velo); // velo
	write_byte(decals); // decals
	message_end();
}


stock UTIL_Sparks(Float:flOrigin[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, flOrigin[0])
	engfunc(EngFunc_WriteCoord, flOrigin[1])
	engfunc(EngFunc_WriteCoord, flOrigin[2])
	message_end()
}

stock get_origin_from_dist_player(id, Float:dist, Float:origin[3], s3d = 1) 
{
	static Float:idorigin[3];
	entity_get_vector(id, EV_VEC_origin, idorigin);
	
	if(dist == 0)
	{
		origin = idorigin;
		return;
	}
	
	static Float:idvangle[3];
	entity_get_vector(id, EV_VEC_v_angle, idvangle);
	idvangle[0] *= -1;
	
	origin[0] = idorigin[0] + dist * floatcos(idvangle[1], degrees) * ((s3d) ? floatabs(floatcos(idvangle[0], degrees)) : 1.0);
	origin[1] = idorigin[1] + dist * floatsin(idvangle[1], degrees) * ((s3d) ? floatabs(floatcos(idvangle[0], degrees)) : 1.0);
	origin[2] = idorigin[2];
}


stock xAddPoint(number)
{
	new count, i, str[29], str2[35], len
	num_to_str(number, str, charsmax(str))
	len = strlen(str)

	for (i = 0; i < len; i++)
	{
		if(i != 0 && ((len - i) %3 == 0))
		{
			add(str2, charsmax(str2), ".", 1)
			count++
			add(str2[i+count], 1, str[i], 1)
		}
		else add(str2[i+count], 1, str[i], 1)
	}
	
	return str2
}

// PEGA ORIGIN DA FRENTE
stock xGetOriginFromDistPlayer(id, Float:dist, Float:origin[3], s3d = 1) 
{
	static Float:idorigin[3]
	pev(id, pev_origin, idorigin)
	
	if(dist == 0)
	{
		origin = idorigin
		return
	}
	
	static Float:idvangle[3]
	pev(id, pev_v_angle, idvangle)
	idvangle[0] *= -1
	
	origin[0] = idorigin[0] + dist * floatcos(idvangle[1], degrees) * ((s3d) ? floatabs(floatcos(idvangle[0], degrees)) : 1.0)
	origin[1] = idorigin[1] + dist * floatsin(idvangle[1], degrees) * ((s3d) ? floatabs(floatcos(idvangle[0], degrees)) : 1.0)
	origin[2] = idorigin[2]
}
