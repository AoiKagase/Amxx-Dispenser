/* Anti Decompiler :) */
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

#define PREFIX_CHAT "^1[^4P4E^1]"

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

new const g_DamageSounds[][] =
{
	"debris/metal1.wav",
	"debris/metal2.wav",
	"debris/metal3.wav"
};

new const g_BulletsSounds[][] =
{
	"csr/dispenser_bullet_chain.wav",
	"csr/dispenser_bullet_chain2.wav"
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
};

new Float:g_DispOrigin[33][3], 
	Float:f_TimeFloodDispTouch[33], 
	Float:f_TimeGiveMoney[33], 
	g_BeamColor[33][3], 
	g_DispPlayerCount[33];

new g_PrecacheModels	[E_MODELS], 
	g_PrecacheSprites	[E_SPRITES];

new g_PlayerMovingDisp[33], 
	Float:f_TimePostThink[33],
	g_iPlantOk[33], 
	Float:f_TimePlantHud[33], 
	Float:f_TimeGiveAmmo[33];

new xStuck[33], xModelIndex;

#define DISPENSER_OWNER pev_iuser2
#define DISPENSER_LEVEL pev_iuser3
#define DISPENSER_TEAM 	pev_iuser4

// ====================================================
//  Register Cvars.
// ====================================================
register_cvars()
{
	for(new i = 0; i < sizeof(g_CVarString); i++)
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

			console_print(0,"[Dispenser Debug]: Changed Cvar '%s' => '%s' to '%s'", g_CVarString[E_CVARS:i][0], old_value, new_value);
		}
	}
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_event("HLTV", "xEventNewRound", "a", "1=0", "2=0");
	register_forward(FM_TraceLine, "fw_TraceLinePost", true);
	register_forward(FM_CmdStart, "fw_CmdStart");

	RegisterHam(Ham_Touch, "player", "fw_DispenserTouch");
	RegisterHam(Ham_Think, dispenser_classname, "tk_Dispenser");
	RegisterHam(Ham_TakeDamage, "func_breakable", "ham_TakeDamagePost", true);
	RegisterHam(Ham_TakeDamage, "func_breakable", "ham_TakeDamagePre", false);
	RegisterHam(Ham_TraceAttack, "func_breakable", "ham_TraceAttackPre", false);

	xRegisterSay("disp", "xBuyDispenser");
	xRegisterSay("dispenser", "xBuyDispenser");
	xRegisterSay("destroy", "xDestroyDispenser");
	xRegisterSay("destruir", "xDestroyDispenser");
	xRegisterSay("distruir", "xDestroyDispenser");

	register_clcmd("drop", "xHookDrop");

	set_task(0.1, "xCheckStuck", _, _, _, "b");
	//set_task(500.0, "xSitePub", _, _, _, "b")
}

stock xRegisterSay(szsay[], szfunction[])
{
	static sztemp[64];
	formatex(sztemp, 63 , "say /%s", szsay);
	register_clcmd(sztemp, szfunction);
	
	formatex(sztemp, 63 , "say .%s", szsay);
	register_clcmd(sztemp, szfunction);
	
	formatex(sztemp, 63 , "say_team /%s", szsay);
	register_clcmd(sztemp, szfunction );
	
	formatex(sztemp, 63 , "say_team .%s", szsay);
	register_clcmd(sztemp, szfunction);
}

public xHookDrop(id)
{
	static weapon;

	weapon = get_user_weapon(id);

	if(weapon == CSW_KNIFE && g_Cvars[CV_DROP_TO_BUY])
	{
		xBuyDispenser(id);
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

/*
public xSitePub()
{
	client_print_color(0, print_team_red, "%s ^3Acesse: ^4www.CSZTEAM.com.br", PREFIX_CHAT)
}*/

public xCheckStuck()
{
	if(get_pcvar_num(g_Cvars[CVAR_AUTOMATIC_STUCK]))
	{
		static players[32], pnum, player
		get_players(players, pnum)
		static  Float:origin[3], Float:mins[3], hull, Float:vec[3], o, i

		for(i=0; i<pnum; i++)
		{
			player = players[i]

			if(is_user_connected(player) && is_user_alive(player))
			{
				pev(player, pev_origin, origin)
				hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN

				if(!is_hull_vacant(origin, hull,player) && !get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT))
				{
					xStuck[player] ++

					if(xStuck[player] >= 7)
					{
						pev(player, pev_mins, mins)
						vec[2] = origin[2]

						for(o=0; o < sizeof(xStuckSize); ++o)
						{
							vec[0] = origin[0] - mins[0] * xStuckSize[o][0]
							vec[1] = origin[1] - mins[1] * xStuckSize[o][1]
							vec[2] = origin[2] - mins[2] * xStuckSize[o][2]

							if(is_hull_vacant(vec, hull,player))
							{
								engfunc(EngFunc_SetOrigin, player, vec)
								set_pev(player,pev_velocity,{0.0,0.0,0.0})
								o = sizeof(xStuckSize)
							}
						}
					}
				}
				else
				{
					xStuck[player] = 0
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
	RemoveEntMovePlayer(id)
	BreakAllPlayerDispensers(id)

	g_DispOrigin[id][0] = 0.0
	g_DispOrigin[id][1] = 0.0
	g_DispOrigin[id][2] = 0.0
	g_BeamColor[id][0] = false
	g_BeamColor[id][1] = false
	g_BeamColor[id][2] = false
	g_DispPlayerCount[id] = false
	g_PlayerMovingDisp[id] = false
	f_TimeFloodDispTouch[id] = 0.0
	f_TimeGiveMoney[id] = 0.0
	f_TimePostThink[id] = 0.0
	f_TimePlantHud[id] = 0.0
	f_TimeGiveAmmo[id] = 0.0
	g_iPlantOk[id] = false
	xStuck[id] = false
}

public plugin_cfg()
{
	static cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))
	
	server_cmd("exec %s/csr_dispenser.cfg", cfgdir)
}

public plugin_precache()
{
	g_PrecSprFlare3 = precache_model("sprites/flare3.spr")
	g_PrecSprLife = precache_model("sprites/laserbeam.spr")
	
	g_PrecSprSmoke = precache_model(g_DispSprSmoke)
	g_PrecSprHealLifeB = precache_model(g_DispSprHealLifeB)
	g_PrecSprHealLifeR = precache_model(g_DispSprHealLifeR)
	g_PrecDispModelGibsR = precache_model(g_DispModelGibsR)
	g_PrecDispModelGibsB = precache_model(g_DispModelGibsB)
	xModelIndex = precache_model(g_DispModel)

	precache_model(g_DispModelPrint)
	precache_model(g_DispModel)
	precache_model(g_DispModelVip)
	precache_sound(g_DispActive)
	precache_sound(g_DispSndFail)
	precache_sound(g_DispSndDestroy)
	precache_sound(g_DispSndIdle)

	static i
	for(i = 0; i < sizeof(g_DamageSounds);i++) 
		engfunc(EngFunc_PrecacheSound, g_DamageSounds[i])

	for(i = 0; i < sizeof(xBulletsSounds);i++) 
		engfunc(EngFunc_PrecacheSound, xBulletsSounds[i])
}

public xEventNewRound()
{
	if(get_pcvar_num(g_Cvars[CVAR_REMOVE_ROUND_RESTART]))
		UTIL_DestroyDispensers()
}

public client_PreThink(id)
{
	static Float:ftime
	ftime = get_gametime()

	if(ftime - 0.05 > f_TimePostThink[id]) // sem spamar o think
	{
		if(g_PlayerMovingDisp[id] && is_user_alive(id))
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

public xBuyDispenser(id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE

	if(!(pev(id, pev_flags) & FL_ONGROUND))
	{
		client_print_color(id, print_team_default, "%s ^3Tente ficar em um chão ^1PLANO ^3para poder comprar um ^4Dispenser^3.", PREFIX_CHAT)
		client_cmd(id, "spk %s", g_DispSndFail)

		return PLUGIN_HANDLED
	}

	if(g_DispPlayerCount[id] >= get_pcvar_num(g_Cvars[CVAR_LIMIT_PER_PLAYER]))
	{
		client_print_color(id, print_team_default, "%s ^3Você já atingiu o limite de ^4Dispenser ^3.", PREFIX_CHAT)
		client_cmd(id, "spk %s", g_DispSndFail)

		return PLUGIN_HANDLED
	}

	/*if((xLimitGlobal[0] >= get_pcvar_num(g_Cvars[CVAR_LIMIT_GLOBAL]) && get_user_team(id) == 1) || (xLimitGlobal[1] >= get_pcvar_num(g_Cvars[CVAR_LIMIT_GLOBAL]) && get_user_team(id) == 2))
	{
		client_print_color(id, print_team_default, "%s ^3Sua equipe atingiu o limite de ^4Dispenser^3.", PREFIX_CHAT)
		client_cmd(id, "spk %s", g_DispSndFail)

		return PLUGIN_HANDLED
	}*/

	static iMoney; iMoney = cs_get_user_money(id)
	static iPriceDisp; iPriceDisp = get_pcvar_num(g_Cvars[CVAR_LVL1_PRICE])

	if(iMoney < iPriceDisp)
	{
		client_print_color(id, print_team_default, "%s ^3Você não possui dinheiro suficiente! ^4$: %s^3.", PREFIX_CHAT, xAddPoint(iPriceDisp))
		client_cmd(id, "spk %s", g_DispSndFail)

		return PLUGIN_HANDLED
	}

	if(g_PlayerMovingDisp[id])
	{
		client_print_color(id, print_team_default, "%s ^3Você já está com um ^4Dispenser ^3ativado, coloque-o para comprar mais.", PREFIX_CHAT)
		client_cmd(id, "spk %s", g_DispSndFail)

		return PLUGIN_HANDLED
	}
	else
	{
		if(get_pcvar_num(g_Cvars[CVAR_INSTANT_PLANT]))
		{
			static Float:fOrigin[3]
			get_origin_from_dist_player(id, 100.0, fOrigin)

			if(xCreateDispanser(fOrigin, id))
			{
				client_print_color(id, print_team_default, "%s ^4Dispenser ^3plantado!", PREFIX_CHAT)
				cs_set_user_money(id, iMoney - iPriceDisp)
			}
			else
			{
				client_cmd(id, "spk %s", g_DispSndFail)
			}
		}
		else
		{
			CreateDispMoveEffect(id)
			cs_set_user_money(id, iMoney - iPriceDisp)
		}
	}

	return PLUGIN_HANDLED
}

public xDestroyDispenser(id)
{
	if(!g_DispPlayerCount[id])
	{
		client_print_color(id, print_team_default, "%s ^3Você não possui nenhum ^4Dispenser ^3para ser destruído.", PREFIX_CHAT)
		client_cmd(id, "spk %s", g_DispSndFail)

		return PLUGIN_HANDLED
	}

	static ent; ent = FM_NULLENT

	while((ent = find_ent_by_class(ent, dispenser_classname)))
	{
		if(pev(ent, DISPENSER_OWNER) != id) 
			continue

		if(pev_valid(ent)) 
		{
			static iLevel, xGiveMoney
			iLevel = pev(ent, DISPENSER_LEVEL)

			xGiveMoney = 0

			switch(iLevel)
			{
				case 1: { xGiveMoney = (get_pcvar_num(g_Cvars[CVAR_LVL1_PRICE])) / 2; }
				case 2: { xGiveMoney = (get_pcvar_num(g_Cvars[CVAR_LVL2_PRICE])) / 2; }
				case 3: { xGiveMoney = (get_pcvar_num(g_Cvars[CVAR_LVL3_PRICE])) / 2; }
				case 4: { xGiveMoney = (get_pcvar_num(g_Cvars[CVAR_LVL4_PRICE])) / 2; }
			}

			g_DispPlayerCount[id] --
			//xLimitTeamAtt(id)

			cs_set_user_money(id, cs_get_user_money(id) + xGiveMoney)
			client_print_color(id, print_team_default, "%s ^3Você obteve: ^4$: %s ^3de dinheiro por destruír seu ^4Dispenser ^3Lvl: ^4%d^3.", PREFIX_CHAT,
			xAddPoint(xGiveMoney), iLevel)
			xRemoveEntFix(ent)
		}
	}

	return PLUGIN_HANDLED
}

/*
public xLimitTeamAtt(id)
{
	static xMyTeam; xMyTeam = get_user_team(id)

	if(xMyTeam == 1)
		xLimitGlobal[0] --
	else
		xLimitGlobal[1] --
}*/


public xRemoveEntFix(ent)
{
	set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME)
	set_pev(ent, pev_nextthink, get_gametime() + 0.5)
}

public CreateDispMoveEffect(id)
{
	static Float:fOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fOrigin)
	get_origin_from_dist_player(id, 128.0, fOrigin)

	new iEnt

	iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

	if(!pev_valid(iEnt))
		return false
	
	entity_set_string(iEnt, EV_SZ_classname, dispenser_classmove)
	entity_set_model(iEnt, g_DispModelPrint)
	entity_set_vector(iEnt, EV_VEC_origin, fOrigin)
	entity_set_int(iEnt, EV_INT_solid, SOLID_NOT)
	entity_set_int(iEnt, EV_INT_iuser2, id)
	entity_set_float(iEnt, EV_FL_framerate, 0.0)
	entity_set_float(iEnt, EV_FL_animtime, get_gametime())
	entity_set_int(iEnt, EV_INT_sequence, BUILD_DISPENSER_NO)
	fm_set_rendering(iEnt, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 255)
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1)

	g_PlayerMovingDisp[id] = true

	return true
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
		RemoveEntMovePlayer(id)

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

public RemoveEntMovePlayer(id)
{
	static ent; ent = FM_NULLENT

	while((ent = find_ent_by_class(ent, dispenser_classmove)))
	{
		if(entity_get_int(ent, EV_INT_iuser2) != id)
			continue

		if(pev_valid(ent))
		{
			xRemoveEntFix(ent)
		}
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

	static iTeam
	iTeam = pev(ent, DISPENSER_TEAM)

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

public tk_Dispenser(iEnt)
{
	if(pev_valid(iEnt))
	{
		static iOwner
		iOwner = pev(iEnt, DISPENSER_OWNER)

		if(!is_user_connected(iOwner))
			return PLUGIN_CONTINUE

		static id, fRadius, iDispHp, iLevel, iDispAp, Float:iTakeApHp
		iLevel = pev(iEnt, DISPENSER_LEVEL)

		if(get_pcvar_num(g_Cvars[CVAR_EFFECT_LVL_4]))
		{
			if(iLevel == 4)
			{
				if(!(pev(iEnt, pev_effects) & EF_BRIGHTFIELD))
					set_pev(iEnt, pev_effects, pev(iEnt, pev_effects) | EF_BRIGHTFIELD)
			}
		}
		
		switch(iLevel)
		{
			case 1:
			{
				iDispHp = get_pcvar_num(g_Cvars[CVAR_HP_LVL1])
				iDispAp = get_pcvar_num(g_Cvars[CVAR_AP_LVL1])
				iTakeApHp = 1.0
			}

			case 2:
			{
				iDispHp = get_pcvar_num(g_Cvars[CVAR_HP_LVL2])
				iDispAp = get_pcvar_num(g_Cvars[CVAR_AP_LVL2])
				iTakeApHp = 1.5
			}

			case 3:
			{
				iDispHp = get_pcvar_num(g_Cvars[CVAR_HP_LVL3])
				iDispAp = get_pcvar_num(g_Cvars[CVAR_AP_LVL3])
				iTakeApHp = 2.0
			}

			case 4:
			{
				iDispHp = get_pcvar_num(g_Cvars[CVAR_HP_LVL4])
				iDispAp = get_pcvar_num(g_Cvars[CVAR_AP_LVL4])
				iTakeApHp = 2.5
			}
		}
        
		static Float:time
		time = get_gametime()

		for(id = 1; id <= MaxClients; id++)
		{
			static iTeam
			iTeam = get_user_team(id)

			if(is_user_alive(id) && get_user_team(id) == get_user_team(iOwner))
			{
				fRadius = get_pcvar_num(g_Cvars[CVAR_DISTANCE_LIFE])

				static Float:flOrigin[3]
				pev(id, pev_origin, flOrigin)

				if(get_distance_f(g_DispOrigin[iOwner], flOrigin) <= fRadius)
				{
					if(UTIL_IsVisible(id, iEnt, 1))
					{
						if(get_user_health(id) < iDispHp)
						{
							if(pev(id, pev_health) < iDispHp)
							{
								set_pev(id, pev_health, floatmin(pev(id, pev_health) + iTakeApHp, float(iDispHp)))
								
								if(get_pcvar_num(g_Cvars[CVAR_SHOW_LIFE_SPRITE]))
								{
									static iOrigin[3]
									get_user_origin(id, iOrigin)

									message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
									write_byte(TE_PROJECTILE)
									write_coord(iOrigin[0] + random_num(-10, 15))
									write_coord(iOrigin[1] + random_num(-10, 15))
									write_coord(iOrigin[2] + random_num(5, 30))
									write_coord(10)
									write_coord(15)
									write_coord(20)
									write_short(iTeam == 1 ? g_PrecSprHealLifeR : g_PrecSprHealLifeB)
									write_byte(1)
									write_byte(id)
									message_end()
								}
							}
							if(get_pcvar_num(g_Cvars[CVAR_SHOW_LINE_LIFE]))
								UTIL_BeamEnts(flOrigin, g_DispOrigin[iOwner], g_BeamColor[iOwner][0], g_BeamColor[iOwner][1], g_BeamColor[iOwner][2], g_PrecSprLife, 40, 0, 1)
						}
					}

					if(UTIL_IsVisible(id, iEnt, 1) && get_user_armor(id) < iDispAp)
					{                                                             
						if(pev(id, pev_armorvalue) < iDispAp)
						{
							set_pev(id, pev_armorvalue, floatmin(pev(id, pev_armorvalue) + iTakeApHp, float(iDispAp)))
						}
					
						if(get_pcvar_num(g_Cvars[CVAR_SHOW_LINE_LIFE]))
							UTIL_BeamEnts(flOrigin, g_DispOrigin[iOwner], g_BeamColor[iOwner][0], g_BeamColor[iOwner][1], g_BeamColor[iOwner][2], g_PrecSprLife, 40, 0, 1)
					}
				}

				if(UTIL_IsVisible(id, iEnt, 1) && get_distance_f(g_DispOrigin[iOwner], flOrigin) <= float(get_pcvar_num(g_Cvars[CVAR_GIVE_MONEY_DISTANCE])) && iLevel == 4 && get_pcvar_num(g_Cvars[CVAR_GIVE_MONEY_TIME]))
				{
					if(time - float(get_pcvar_num(g_Cvars[CVAR_GIVE_MONEY_TIME])) > f_TimeGiveMoney[id])
					{
						cs_set_user_money(id, cs_get_user_money(id) + random_num(get_pcvar_num(g_Cvars[CVAR_GIVE_MONEY_MIN]), get_pcvar_num(g_Cvars[CVAR_GIVE_MONEY_MAX])))

						f_TimeGiveMoney[id] = time
					}
				}

				if(UTIL_IsVisible(id, iEnt, 1) && get_distance_f(g_DispOrigin[iOwner], flOrigin) <= float(get_pcvar_num(g_Cvars[CVAR_GIVE_AMMO_DISTANCE])) && get_pcvar_num(g_Cvars[CVAR_GIVE_AMMO_TIME]))
				{
					if(get_pcvar_num(g_Cvars[CVAR_ALL_LVL_GIVE_AMMO]) || iLevel == 4)
					{
						if(time - float(get_pcvar_num(g_Cvars[CVAR_GIVE_AMMO_TIME])) > f_TimeGiveAmmo[id])
						{
							static fammo, fbammo, xUserGetWpn
							xUserGetWpn = get_user_weapon(id)

							switch(xUserGetWpn)
							{
								case CSW_P228 : fammo = 13, fbammo = 52;
								case CSW_SCOUT : fammo = 10, fbammo = 90;
								case CSW_MAC10 : fammo = 30, fbammo = 100;
								case CSW_AUG : fammo = 30, fbammo = 90;
								case CSW_ELITE : fammo = 30, fbammo = 120;
								case CSW_FIVESEVEN : fammo = 20, fbammo = 100;
								case CSW_UMP45 : fammo = 25, fbammo = 100;
								case CSW_SG550 : fammo = 30, fbammo = 90;
								case CSW_GALI : fammo = 35, fbammo = 90;
								case CSW_FAMAS : fammo = 25, fbammo = 90;
								case CSW_USP : fammo = 12, fbammo = 100;
								case CSW_GLOCK18 : fammo = 20, fbammo = 120;
								case CSW_AWP : fammo = 10, fbammo = 30;
								case CSW_MP5NAVY : fammo = 30, fbammo = 120;
								case CSW_M249 : fammo = 100, fbammo = 200;
								case CSW_M3 : fammo = 8, fbammo = 32;
								case CSW_M4A1 : fammo = 30, fbammo = 90;
								case CSW_TMP : fammo = 30, fbammo = 120;
								case CSW_G3SG1 : fammo = 20, fbammo = 90;
								case CSW_SG552 : fammo = 30, fbammo = 90;
								case CSW_AK47 : fammo = 30, fbammo = 90;
								case CSW_P90 : fammo = 50, fbammo = 100;
								default: continue
							}

							if(pev_valid(id) == 2)
							{
								static xUserWpn, currentAmmo, currentBammo, newAmmo, newBAmmo

								xUserWpn = get_pdata_cbase(id, 373)
								currentAmmo = cs_get_weapon_ammo(xUserWpn)
								currentBammo = cs_get_user_bpammo(id, xUserGetWpn)
								newAmmo = currentAmmo + random_num(get_pcvar_num(g_Cvars[CVAR_GIVE_AMMO_MIN]), get_pcvar_num(g_Cvars[CVAR_GIVE_AMMO_MAX]))
								newBAmmo = currentBammo + random_num(get_pcvar_num(g_Cvars[CVAR_GIVE_AMMO_MIN]), get_pcvar_num(g_Cvars[CVAR_GIVE_AMMO_MAX]))
								
								if(currentAmmo == fammo && currentBammo == fbammo)
									continue

								if(newAmmo <= fammo)
								{
									cs_set_weapon_ammo(xUserWpn, newAmmo)
									emit_sound(id, CHAN_ITEM, xBulletsSounds[random_num(0, charsmax(xBulletsSounds))], 0.3, ATTN_NORM, 0, PITCH_NORM)
								}
								else
								{
									if(newBAmmo <= fbammo)
										cs_set_user_bpammo(id, xUserGetWpn, newBAmmo)
									else
										cs_set_user_bpammo(id, xUserGetWpn, fbammo)

									emit_sound(id, CHAN_ITEM, xBulletsSounds[random_num(0, charsmax(xBulletsSounds))], 0.3, ATTN_NORM, 0, PITCH_NORM)
								}
							}

							f_TimeGiveAmmo[id] = time
						}
					}
					
				}
			}
        }

        if(get_distance_f(g_DispOrigin[iOwner], flOrigin) <= fRadius)
                {

                     if(iLevel - 1 >= get_pcvar_num(g_Cvars[CVAR_DISPENSER_HP]))
                {
                    new iOwner = pev(iEnt, DISPENSER_OWNER);
                    new iOwnerTeam = _:cs_get_user_team(iOwner);
                    new sClassname [32];
                    new Float:iTakeHp[4] = {1.0, 1.5, 2.0, 2.5};
                    new Float:entHealth;
                    new Float:entMaxHealth;
                    new ent = -1;

                    while((ent = engfunc(EngFunc_FindEntityInSphere, ent, flOrigin, fRadius)) != 0)
                    {
                        if(pev_valid(ent))
                        {
                            pev(ent, pev_health, entHealth);
                            pev(ent, pev_classname, sClassname, charsmax(sClassname));
                            pev(ent, pev_origin, flOrigin);
                            
                            if(equal(sClassname, "bdispenser"))
                            {
                                //check the team by the team's pev_iuser
                                if(iOwnerTeam == pev(ent, DISPENSER_TEAM) && ent != iEnt)
                                {
                                    if(UTIL_IsVisible(id, iEnt))
                                    {
                                        // function that returns the maximum hp of the dispenser at the current level
                                        entMaxHealth == pev(ent, DISPENSER_LEVEL);

                                        if(entHealth >= entMaxHealth)
                                        {
                                            continue;
                                        }

                                        entHealth = entHealth + iTakeHp [iLevel -1] < entMaxHealth ? entHealth + iTakeHp [iLevel -1] : entMaxHealth; 

                                        set_pev( ent, pev_health, entHealth );

                                        UTIL_BeamEnts(flOrigin, g_DispOrigin[iOwner], g_BeamColor[iOwner][0], g_BeamColor[iOwner][1], g_BeamColor[iOwner][2], g_PrecSprLife, 40, 0, 1)

                                    }
                                }
                            }
                        }
                    }
                }

		static Float:entorigin[3]
		pev(iEnt, pev_origin, entorigin)

		static xHP
		xHP = pev(iEnt, pev_health)

		if(xHP <= 350.0)
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_SMOKE)
			engfunc(EngFunc_WriteCoord, entorigin[0] + random_float(-8.0, 8.0))
			engfunc(EngFunc_WriteCoord, entorigin[1] + random_float(-8.0, 8.0))
			engfunc(EngFunc_WriteCoord, entorigin[2] + random_float(25.0, 50.0))
			write_short(g_PrecSprSmoke)
			write_byte(random_num(3,10))
			write_byte(30) //def: 30
			message_end()
		}

		if(get_user_team(iOwner) != pev(iEnt, DISPENSER_TEAM)) // remove o dispenser se eu mudar de time :)
		{
			BreakAllPlayerDispensers(iOwner) // remove todos dispensers da PESSOA

			return PLUGIN_CONTINUE
		}

		set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
    }
	
	return PLUGIN_CONTINUE
}

public BreakAllPlayerDispensers(id)
{
	static ent; ent = FM_NULLENT

	while((ent = find_ent_by_class(ent, dispenser_classname)))
	{
		if(pev(ent, DISPENSER_OWNER) != id)
			continue
		
		if(pev_valid(ent))
		{
			//xLimitTeamAtt(id)
			xRemoveEntFix(ent)
			g_DispPlayerCount[id] --
		}
	}
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
			new iTeam; iTeam = pev(ent, DISPENSER_TEAM)

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
	set_pev(ent, DISPENSER_TEAM, get_user_team(creator))
	

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

stock UTIL_BeamEnts(Float:flStart[3], Float:flEnd[3], r, g, b, sprite, width, ampl, speed)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flStart)
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord, flStart[0])
	engfunc(EngFunc_WriteCoord, flStart[1])
	engfunc(EngFunc_WriteCoord, flStart[2])
	engfunc(EngFunc_WriteCoord, flEnd[0])
	engfunc(EngFunc_WriteCoord, flEnd[1])
	engfunc(EngFunc_WriteCoord, flEnd[2])
	write_short(sprite)
	write_byte(1) // start frame
	write_byte(1) // frame rate
	write_byte(1) // life
	write_byte(width) // widh
	write_byte(ampl) // noise
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(255) // def: 130
	write_byte(speed) // def: 30
	message_end()
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

stock bool:is_hull_vacant(const Float:origin[3], hull,id)
{
	static tr
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	
	if(!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true
	
	return false
}

stock DispenserExplode(const Float:originF[3], head, sprites, life, tamanho, velo, decals)
{	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPRITETRAIL)
	engfunc(EngFunc_WriteCoord, originF[0]) // X
	engfunc(EngFunc_WriteCoord, originF[1]) // Y
	engfunc(EngFunc_WriteCoord, originF[2]+head) // Z
	engfunc(EngFunc_WriteCoord, originF[0]) // X
	engfunc(EngFunc_WriteCoord, originF[1]) // Y
	engfunc(EngFunc_WriteCoord, originF[2]+head) // Z
	write_short(g_PrecSprFlare3)
	write_byte(sprites) // quantas sprites vai sair...
	write_byte(life) // life
	write_byte(tamanho) // tamanho
	write_byte(velo) // velo
	write_byte(decals) // decals
	message_end()
}

stock UTIL_DestroyDispensers()
{
	static ent; ent = FM_NULLENT

	while((ent = find_ent_by_class(ent, dispenser_classname)))
	{
		if(pev_valid(ent))
		{
			static id; id = pev(ent, DISPENSER_OWNER)

			g_DispPlayerCount[id] = 0

			xRemoveEntFix(ent)
		}
	}

	//xLimitGlobal[0] = 0
	//xLimitGlobal[1] = 0
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
	static Float:idorigin[3]
	entity_get_vector(id, EV_VEC_origin, idorigin)
	
	if(dist == 0)
	{
		origin = idorigin
		return
	}
	
	static Float:idvangle[3]
	entity_get_vector(id, EV_VEC_v_angle, idvangle)
	idvangle[0] *= -1
	
	origin[0] = idorigin[0] + dist * floatcos(idvangle[1], degrees) * ((s3d) ? floatabs(floatcos(idvangle[0], degrees)) : 1.0)
	origin[1] = idorigin[1] + dist * floatsin(idvangle[1], degrees) * ((s3d) ? floatabs(floatcos(idvangle[0], degrees)) : 1.0)
	origin[2] = idorigin[2]
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
