#include maps\mp\_utility;
#include maps\_utility;
#include maps\_effects;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_powerups;


main()
{
	create_dvar("enable_deadlightgreenlight", 1);
	create_dvar("deadlight_rules", 0);
	
	if(getDvarInt("enable_deadlightgreenlight") == 1)
	{
		replacefunc(maps\mp\zombies\_zm_powerups::init_powerups, ::init_powerups_minigame);
		replacefunc(maps\mp\zombies\_zm::round_think, ::round_think_minigame);
		replacefunc(maps\mp\zombies\_zm::round_over, ::new_round_over);
	}
}

init()
{
	if(getDvarInt("enable_deadlightgreenlight") == 1)
	{	
		level.perk_purchase_limit = 9;
		level.lightid = 1;
		level.redgreenlightstarted = 0;
		level.deadlightchance = -3;
		level.playersready = 0;
		level thread lightStatusHUD();
		setStatueLocations();
	
		level.bonus_points_powerup_override = ::bonus_points_powerup_override;
		include_powerup( "bonus_points_team" );
		add_zombie_powerup( "bonus_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", ::func_should_always_drop, 0, 0, 0 );
		level thread onPlayerConnect();
		level thread introHUD();
		level waittill ("end");
		wait 3;
		level thread redlight_greenlight();
	}
}

create_dvar( dvar, set )
{
    if( getDvar( dvar ) == "" )
		setDvar( dvar, set );
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
		player.beingPunished = 0;
		player.oldmoving = 0;
		player.suppress_points = 0;
		player.lightchanges = 0;
        player thread onPlayerSpawned();
//		player thread moveCheckHUD();
		if(level.redgreenlightstarted == 0)
		{
			player thread respawnPlayer();
		}
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("game_ended");

    for(;;)
    {
        self waittill("spawned_player");
		if (level.redgreenlightstarted == 0)
		{
			self EnableInvulnerability();
			self thread wait_for_ready_input();
			level waittill ("end");
			self disableInvulnerability();
		}
		else
		{
			if(self.playedminigamehudmsg == 0)
			{
				self.playedminigamehudmsg = 1;
				self thread startHUDMessage();
			}
		}
    }
}

respawnPlayer()
{
	wait 5;
	if (self.sessionstate == "spectator")
	{
		self [[ level.spawnplayer ]]();
	}
	else
	{
	
	}
	self thread startHUDMessage();
	self.playedminigamehudmsg = 1;
}

spawnRedGreenStatue(location, angle)
{
	statueModel = spawn( "script_model", (location));
	statueModel setmodel ("defaultactor");
	statueModel rotateTo((0,angle,0),.1);
	for(;;)
	{
		level waittill ("move_light_change");
		if(level.lightid == 0)
		{
				statueModel rotateTo((0,angle,0),3);
		}
		else if(level.lightid == 1)
		{
				statueModel rotateTo((0,angle + 180,0),3);
		}
		else if(level.lightid == 2)
		{
				statueModel rotateTo((0,angle + 180,0),3);
		}
		else
		{
				statueModel rotateTo((0,angle,0),3);
		}
	}
}

startHUDMessage()
{
	flag_wait( "initial_blackscreen_passed" );
	
	hud = newClientHudElem(self);
	hud.alignx = "center";
	hud.aligny = "top";
	hud.horzalign = "user_center";
	hud.vertalign = "user_top";
	hud.x = 0;
	hud.y += 24;
	hud.fontscale = 3;
	hud.alpha = 0;
	hud.color = ( 1, 1, 1 );
	hud.hidewheninmenu = 1;
	hud.foreground = 1;
	hud settext("TechnoOps Collection:");
	hud.fontscale = 3;
	hud changefontscaleovertime( 1 );
    hud fadeovertime( 1 );
    hud.alpha = 1;
    hud.fontscale = 1.5;

	wait 1;

	hud2 = newClientHudElem(self);
	hud2.alignx = "center";
	hud2.aligny = "top";
	hud2.horzalign = "user_center";
	hud2.vertalign = "user_top";
	hud2.x = 0;
	hud2.y += 42;
	hud2.fontscale = 8;
	hud2.alpha = 0;
	hud2.color = ( 1, 1, 1 );
	hud2.hidewheninmenu = 1;
	hud2.foreground = 1;
	hud2 settext("Dead Light Green Light");
	hud2.fontscale = 8;
	hud2 changefontscaleovertime( 1 );
    hud2 fadeovertime( 1 );
    hud2.alpha = 1;
    hud2.fontscale = 4;

	wait 1;
	
	hud3 = newClientHudElem(self);
	hud3.alignx = "center";
	hud3.aligny = "top";
	hud3.horzalign = "user_center";
	hud3.vertalign = "user_top";
	hud3.x = 0;
	hud3.y += 90;
	hud3.fontscale = 2;
	hud3.alpha = 0;
	hud3.color = ( 1, 1, 1 );
	hud3.hidewheninmenu = 1;
	hud3.foreground = 1;
	hud3 settext("At Red Light, you must stay still until Green Light.");
	hud3.fontscale = 2;
	hud3 changefontscaleovertime( 1 );
    hud3 fadeovertime( 1 );
    hud3.alpha = 1;
    hud3.fontscale = 1.5;
	wait 1;
	self notify ("can_readyup");

    if(level.redgreenlightstarted == 0)
	{
		level waittill ("end");
	}
	else
	{
		wait 3.25;
	}

    hud changefontscaleovertime( 1 );
    hud fadeovertime( 1 );
    hud.alpha = 0;
    hud.fontscale = 4;
//    wait 1;
	
    hud2 changefontscaleovertime( 1 );
    hud2 fadeovertime( 1 );
    hud2.alpha = 0;
    hud2.fontscale = 6;
//    wait 1;
	
    hud3 changefontscaleovertime( 1 );
    hud3 fadeovertime( 1 );
    hud3.alpha = 0;
    hud3.fontscale = 2;
    wait 1;
	
	hud destroy();
	hud2 destroy();
	hud3 destroy();
}

wait_for_ready_input()
{
	level endon ("end");
	level.introHUD setText ("Press [{+melee}] and [{+speed_throw}] to ready up!: ^5" + level.playersready + "/" + level.players.size);
	if (!isDefined(self.bot))
	{
		self waittill ("can_readyup");
	}
	while(1)
	{
		if((self meleebuttonpressed() && self adsbuttonpressed()) || (isDefined(self.bot)))
		{
			if (self.voted == 0)
			{
				level.playersready += 1;
				self.voted = 1;
				level.introHUD setText ("Press [{+melee}] and [{+speed_throw}] to ready up!: ^5" + level.playersready + "/" + level.players.size);
				if (level.playersready == level.players.size)
				{
					wait 1;
					level.redgreenlightstarted = 1;
					foreach (player in level.players)
					{
						player disableInvulnerability();
					}
					level notify ("end");
				}
			}
		}
		wait 0.01;
	}
}

introHUD()
{
	flag_wait( "initial_blackscreen_passed" );
	level.introHUD = newhudelem();
	level.introHUD.x = 0;
	level.introHUD.y -= 20;
	level.introHUD.alpha = 1;
	level.introHUD.alignx = "center";
	level.introHUD.aligny = "bottom";
    level.introHUD.horzalign = "user_center";
    level.introHUD.vertalign = "user_bottom";
	level.introHUD.foreground = 0;
	level.introHUD.fontscale = 1.5;
	level.introHUD setText ("Press [{+melee}] and [{+speed_throw}] to ready up!: ^5" + level.playersready + "/" + level.players.size);
	level waittill ("end");
	level.introHUD fadeovertime( 0.25 );
	level.introHUD.alpha = 0;
	level.introHUD destroy();
}

moveCheckHUD()
{
	level endon("end_game");
	self endon( "disconnect" );
	
	self.movecheckHUD = newClientHudElem(self);
	self.movecheckHUD.alignx = "center";
	self.movecheckHUD.aligny = "bottom";
	self.movecheckHUD.horzalign = "user_center";
	self.movecheckHUD.vertalign = "user_bottom";
	self.movecheckHUD.x = 0;
	self.movecheckHUD.y = -25;
	self.movecheckHUD.fontscale = 2;
	self.movecheckHUD.alpha = 1;
	self.movecheckHUD.color = ( 1, 1, 1 );
	self.movecheckHUD.hidewheninmenu = 1;
	self.movecheckHUD.foreground = 1;
	self.movecheckHUD setText ("");
	
	self.oldmoving = self.player_is_moving;
	
	for(;;)
	{
		if(self.oldmoving != self.player_is_moving)
		{
			if(self.player_is_moving)
			{
				self.movecheckHUD setText ("Moving");
				self.movecheckHUD.color = ( 0, 1, 0 );
			}
			else
			{
				self.movecheckHUD setText ("Not Moving");
				self.movecheckHUD.color = ( 1, 0, 0 );
			}
		}
		if(level.redgreenlightstarted == 0)
		{
			self.movecheckHUD.alpha = 0;
		}
		else
		{
			self.movecheckHUD.alpha = 1;
		}
		wait 0.1;
	}
}

punishmentHUD(text)
{
	if (isDefined(self.punishmenttext) || isDefined(self.punishmenttitle))
	{
		self.punishmenttext destroy();
		self.punishmenttitle destroy();
	}
	
	level endon("end_game");
	self endon( "disconnect" );
	
	self.punishmenttitle = newClientHudElem(self);
	self.punishmenttitle.alignx = "center";
	self.punishmenttitle.aligny = "bottom";
	self.punishmenttitle.horzalign = "user_center";
	self.punishmenttitle.vertalign = "user_bottom";
	self.punishmenttitle.x = 0;
	self.punishmenttitle.y = -320;
	self.punishmenttitle.fontscale = 2;
	self.punishmenttitle.alpha = 0;
	self.punishmenttitle.color = ( 1, 0.5, 0.5 );
	self.punishmenttitle.hidewheninmenu = 1;
	self.punishmenttitle.foreground = 1;
	self.punishmenttitle setText ("You were caught moving!");
	
	self.punishmenttext = newClientHudElem(self);
	self.punishmenttext.alignx = "center";
	self.punishmenttext.aligny = "bottom";
	self.punishmenttext.horzalign = "user_center";
	self.punishmenttext.vertalign = "user_bottom";
	self.punishmenttext.x = 0;
	self.punishmenttext.y = -280;
	self.punishmenttext.fontscale = 2;
	self.punishmenttext.alpha = 0;
	self.punishmenttext.color = ( 1, 1, 1 );
	self.punishmenttext.hidewheninmenu = 1;
	self.punishmenttext.foreground = 1;
	self.punishmenttext setText (text);
	
	self.punishmenttitle fadeovertime( 1 );
	self.punishmenttitle.alpha = 1;
	
	self.punishmenttext fadeovertime( 1 );
	self.punishmenttext.alpha = 1;
	
	wait 1;
	
	wait 3;
	self.punishmenttext moveOvertime( 1 );
	self.punishmenttext.y = -115;

	self.punishmenttitle fadeovertime( 1 );
	self.punishmenttitle.alpha = 0;
	
	wait 1;
	
	self.punishmenttitle destroy();
}

lightStatusHUD()
{
	level endon("end_game");
	
	level.lightStatus = newHudElem();
	level.lightStatus.alignx = "center";
	level.lightStatus.aligny = "bottom";
	level.lightStatus.horzalign = "user_center";
	level.lightStatus.vertalign = "user_bottom";
	level.lightStatus.x = 0;
	level.lightStatus.y = -64;
	level.lightStatus.fontscale = 2;
	level.lightStatus.alpha = 1;
	level.lightStatus.color = ( 1, 1, 1 );
	level.lightStatus.hidewheninmenu = 1;
	level.lightStatus.foreground = 1;
	level.lightStatus setText ("");
}

redlight_greenlight()
{
	level endon("end_game");
	
	change_light(0);
	wait 90;
	for(;;)
	{
		chance = randomintrange(1,5);
		if(chance <= level.deadlightchance)
		{
			change_light(2);
			level.deadlightchance = randomintrange(-3,0);
			wait randomintrange(20, 40);
		}
		else
		{
			level.deadlightchance += 1;
			change_light(1);
			wait randomintrange(20, 40);
		}

		change_light(0);
		wait randomintrange(20, 60);
	}
}

check_movements()
{
	level endon ("move_light_change");
	level endon("end_game");
	
	wait 2;
	
	for(;;)
	{
		foreach (player in level.players)
		{
			wait 1;
			player check_movements_2();
			
			if(player.player_is_moving == 1 && player.beingPunished == 0 && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !( player.sessionstate == "spectator" ))
			{
				if(getDvarInt("deadlight_rules") ==  2)
				{
					player player_is_down_redlight_greenlight();
				}
				else
				{
					level thread punish_player(player);
				}
			}
		}
	}
}

player_is_down_redlight_greenlight()
{
	self disableInvulnerability();
	
	self.beingPunished = 1;
	
	self dodamage(self.health, self.origin);
	
	self endon ("death");
	
	self waittill_any("player_revived");
	
	wait 10;
	
	self.beingPunished = 0;
}

check_movements_2()
{
	if(getDvarInt("deadlight_rules") ==  3 || getDvarInt("deadlight_rules") ==  2)
	{
		return;
	}
	
	if(self.player_is_moving == 1)
	{
		if(self.score >= 500)
		{
			self.score -= 500;
		}
		else
		{
			if(self.score > 0)
			{
				self.score -= self.score;
			}
			else
			{
				self dodamage(25,self.origin);
			}
		}
	}
}

change_light(lightid)
{
	level notify ("move_light_change");
	
	team = level.players[0].team;
	
	foreach (player in level.players)
	{
		if(player.beingPunished)
		{
			player.lightchanges += 1;
		}
		player reset_punishments();
	}
	
	if(lightid == 0)
	{
		level.zombie_vars[team]["zombie_point_scalar"] = 2;
		level thread light_change_hud(lightid);
		level.lightStatus setText ("Green Light");
		level.lightStatus.color = ( 0, 1, 0 );
		level.lightid = 0;
		sound = "zmb_cha_ching";
	}
	else if(lightid == 1)
	{
		level.zombie_vars[team]["zombie_point_scalar"] = 0;
		level thread light_change_hud(lightid);
		level thread check_movements();
		level.lightStatus setText ("Red Light");
		level.lightStatus.color = ( 1, 0, 0 );
		level.lightid = 1;
		sound = "zmb_weap_wall";
	}
	else if(lightid == 2)
	{
		level.zombie_vars[team]["zombie_point_scalar"] = 1;
		level thread light_change_hud(lightid);
		level.lightStatus setText ("Dead Light");
		level thread deadlight();
		level.lightStatus.color = ( 1, 0, 1 );
		level.lightid = 2;
		sound = "zmb_laugh_child";
	}
	foreach (player in level.players)
	{
		player playlocalsound(sound);
	}
}

light_change_hud(lightid)
{
	hud2 = newhudelem();
	hud2.alignx = "center";
	hud2.aligny = "top";
	hud2.horzalign = "user_center";
	hud2.vertalign = "user_top";
	hud2.x = 0;
	hud2.y += 42;
	hud2.fontscale = 8;
	hud2.alpha = 0;
	hud2.hidewheninmenu = 1;
	hud2.foreground = 1;
	
	if(lightid == 0)
	{
		hud2.color = ( 0, 1, 0 );
		phase = "Green";
	}
	else if(lightid == 1)
	{
		hud2.color = ( 1, 0, 0 );
		phase = "Red";	
	}
	else
	{
		hud2.color = ( 1, 0, 1 );
		phase = "Dead";
	}
	
	hud2 settext(phase + " light!");
	hud2.fontscale = 8;
	hud2 changefontscaleovertime( 1 );
    hud2 fadeovertime( 1 );
    hud2.alpha = 1;
    hud2.fontscale = 3;
	
	
	hud3 = newhudelem();
	hud3.alignx = "center";
	hud3.aligny = "top";
	hud3.horzalign = "user_center";
	hud3.vertalign = "user_top";
	hud3.x = 0;
	hud3.y += 78;
	hud3.fontscale = 8;
	hud3.alpha = 0;
	hud3.hidewheninmenu = 1;
	hud3.foreground = 1;
	
	if(lightid == 0)
	{
		detail = "You can move! - 2x Points!";
	}
	else if(lightid == 1)
	{
		detail = "Stay Still!";	
	}
	else
	{
		detail = "Survive";
	}
	
	hud3 settext(detail);
	hud3.fontscale = 6;
	hud3 changefontscaleovertime( 1 );
    hud3 fadeovertime( 1 );
    hud3.alpha = 1;
    hud3.fontscale = 2;
	

	wait 3.25;
	
    hud2 changefontscaleovertime( 1 );
    hud2 fadeovertime( 1 );
    hud2.alpha = 0;
    hud2.fontscale = 6;
	
    hud3 changefontscaleovertime( 1 );
    hud3 fadeovertime( 1 );
    hud3.alpha = 0;
    hud3.fontscale = 6;

    wait 1;
	
	hud2 destroy();
	hud3 destroy();
}

punish_player(player)
{	
	if(player.beingPunished == 0 && player.player_is_moving == 1 && getDvarInt("deadlight_rules") == 0)
	{
		player roll_punishment();
	}
}

roll_punishment()
{
	if(self.beingPunished == 0)
	{
		self.beingPunished = 1;
		
		chance = randomintrange(0,6);
		
		if(chance == 1)
		{
			self thread punishment_slow_player_down();
			self thread punishmentHUD("Punishment: ^5Slowness!");
		}
		else if(chance == 2)
		{
			self thread punishment_no_ammo();
			self thread punishmentHUD("Punishment: ^5Stripped Ammo!");
		}
		else if(chance == 3)
		{
			self thread punishment_low_health();
			self thread punishmentHUD("Punishment: ^5Critical Health!");
		}
		else if(chance == 4)
		{
			self thread punishment_blur();
			self thread punishmentHUD("Punishment: ^5Blurry View!");
		}
		else if(chance == 5)
		{
			self thread punishment_lose_perk();
			self thread punishmentHUD("Punishment: ^5Perk Loss!");
		}
		else
		{
		
		}
	}
}

init_powerups_minigame()
{
    flag_init( "zombie_drop_powerups" );

    if ( isdefined( level.enable_magic ) && level.enable_magic )
        flag_set( "zombie_drop_powerups" );

    if ( !isdefined( level.active_powerups ) )
        level.active_powerups = [];

    if ( !isdefined( level.zombie_powerup_array ) )
        level.zombie_powerup_array = [];

    if ( !isdefined( level.zombie_special_drop_array ) )
        level.zombie_special_drop_array = [];

	add_zombie_powerup( "nuke", "zombie_bomb", &"ZOMBIE_POWERUP_NUKE", ::func_should_never_drop, 0, 0, 0, "misc/fx_zombie_mini_nuke_hotness" );
	add_zombie_powerup( "insta_kill", "zombie_skull", &"ZOMBIE_POWERUP_INSTA_KILL", ::func_should_always_drop, 0, 0, 0, undefined, "powerup_instant_kill", "zombie_powerup_insta_kill_time", "zombie_powerup_insta_kill_on" );
	add_zombie_powerup( "full_ammo", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 0, 0, 0 );
	add_zombie_powerup( "double_points", "zombie_x2_icon", &"ZOMBIE_POWERUP_DOUBLE_POINTS", ::func_should_never_drop, 0, 0, 0, undefined, "powerup_double_points", "zombie_powerup_point_doubler_time", "zombie_powerup_point_doubler_on" );
	add_zombie_powerup( "carpenter", "zombie_carpenter", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 0, 0, 0 );
	add_zombie_powerup( "fire_sale", "zombie_firesale", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0, undefined, "powerup_fire_sale", "zombie_powerup_fire_sale_time", "zombie_powerup_fire_sale_on" );
	add_zombie_powerup( "bonfire_sale", "zombie_pickup_bonfire", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0, undefined, "powerup_bon_fire", "zombie_powerup_bonfire_sale_time", "zombie_powerup_bonfire_sale_on" );
	add_zombie_powerup( "minigun", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MINIGUN", ::func_should_never_drop, 1, 0, 0, undefined, "powerup_mini_gun", "zombie_powerup_minigun_time", "zombie_powerup_minigun_on" );
	add_zombie_powerup( "free_perk", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_FREE_PERK", ::func_should_never_drop, 0, 0, 0 );
	add_zombie_powerup( "tesla", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MINIGUN", ::func_should_never_drop, 1, 0, 0, undefined, "powerup_tesla", "zombie_powerup_tesla_time", "zombie_powerup_tesla_on" );
	add_zombie_powerup( "random_weapon", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 1, 0, 0 );
	add_zombie_powerup( "bonus_points_player", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", ::func_should_never_drop, 1, 0, 0 );
	add_zombie_powerup( "bonus_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", ::func_should_always_drop, 0, 0, 0 );
	add_zombie_powerup( "lose_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_LOSE_POINTS", ::func_should_never_drop, 0, 0, 1 );
	add_zombie_powerup( "lose_perk", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 1 );
	add_zombie_powerup( "empty_clip", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 1 );
	add_zombie_powerup( "insta_kill_ug", "zombie_skull", &"ZOMBIE_POWERUP_INSTA_KILL", ::func_should_never_drop, 1, 0, 0, undefined, "powerup_instant_kill_ug", "zombie_powerup_insta_kill_ug_time", "zombie_powerup_insta_kill_ug_on", 5000 );


    if ( isdefined( level.level_specific_init_powerups ) )
        [[ level.level_specific_init_powerups ]]();

    randomize_powerups();
    level.zombie_powerup_index = 0;
    randomize_powerups();
    level.rare_powerups_active = 0;
    level.firesale_vox_firstime = 0;
    level thread powerup_hud_monitor();

    if ( isdefined( level.quantum_bomb_register_result_func ) )
    {
        [[ level.quantum_bomb_register_result_func ]]( "random_powerup", ::quantum_bomb_random_powerup_result, 5, level.quantum_bomb_in_playable_area_validation_func );
        [[ level.quantum_bomb_register_result_func ]]( "random_zombie_grab_powerup", ::quantum_bomb_random_zombie_grab_powerup_result, 5, level.quantum_bomb_in_playable_area_validation_func );
        [[ level.quantum_bomb_register_result_func ]]( "random_weapon_powerup", ::quantum_bomb_random_weapon_powerup_result, 60, level.quantum_bomb_in_playable_area_validation_func );
        [[ level.quantum_bomb_register_result_func ]]( "random_bonus_or_lose_points_powerup", ::quantum_bomb_random_bonus_or_lose_points_powerup_result, 25, level.quantum_bomb_in_playable_area_validation_func );
    }

    registerclientfield( "scriptmover", "powerup_fx", 1000, 3, "int" );
}

bonus_points_powerup_override()
{
    points = 500;
    return points;
}

new_round_over()
{
    if ( isdefined( level.noroundnumber ) && level.noroundnumber == 1 )
        return;

    time = level.zombie_vars["zombie_between_round_time"];
    players = getplayers();

    for ( player_index = 0; player_index < players.size; player_index++ )
    {
        if ( !isdefined( players[player_index].pers["previous_distance_traveled"] ) )
            players[player_index].pers["previous_distance_traveled"] = 0;

        distancethisround = int( players[player_index].pers["distance_traveled"] - players[player_index].pers["previous_distance_traveled"] );
        players[player_index].pers["previous_distance_traveled"] = players[player_index].pers["distance_traveled"];
        players[player_index] incrementplayerstat( "distance_traveled", distancethisround );

        if ( players[player_index].pers["team"] != "spectator" )
        {
            zonename = players[player_index] get_current_zone();

            if ( isdefined( zonename ) )
                players[player_index] recordzombiezone( "endingZone", zonename );
        }
    }

    recordzombieroundend();
}



bonus_points_player_powerup( item, player )
{
    points = 500;

    if ( isdefined( level.bonus_points_powerup_override ) )
        points = [[ level.bonus_points_powerup_override ]]();

    if ( !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !( player.sessionstate == "spectator" ) )
        player maps\mp\zombies\_zm_score::player_add_points( "bonus_points_powerup", points );
}

bonus_points_team_powerup( item )
{
    points = 500;

    if ( isdefined( level.bonus_points_powerup_override ) )
        points = [[ level.bonus_points_powerup_override ]]();

    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( !players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !( players[i].sessionstate == "spectator" ) )
            players[i] maps\mp\zombies\_zm_score::player_add_points( "bonus_points_powerup", points );
    }
}


debugCoord()
{
	for(;;)
	{
		if(getDvarInt("show_debug") == 1)
		{
			self iprintln("Location: " + self.origin + " - " + "Angle: " + self.angles[1]);
			println("Location: " + self.origin + " - " + "Angle: " + self.angles[1]);
		}
		wait 1;
	}
}

setStatueLocations()
{
	if ( getDvar( "g_gametype" ) == "zgrief" || getDvar( "g_gametype" ) == "zstandard" )
	{
		if(getDvar("mapname") == "zm_nuked") //nuketown
		{
			level thread spawnRedGreenStatue((1376.65, 14.67, -63.9352), -83.3789);
			level thread spawnRedGreenStatue((1012.26, 409.039, 79.125), 79.6088);
			level thread spawnRedGreenStatue((-496.712, 282.368, -61.5188), 158.892);
			level thread spawnRedGreenStatue((-1731.32, 103.922, -61.8233), -120.699);
			level thread spawnRedGreenStatue((-1010.54, 528.086, 80.125), 157.238);
		}
		else if(getDvar("mapname") == "zm_transit") //transit grief and survival
		{
			if(getDvar("ui_zm_mapstartlocation") == "town") //town
			{
				level thread spawnRedGreenStatue((1119.43, -799.272, -55.875), -134);
				level thread spawnRedGreenStatue((1142.65, 620.408, -40.2209), 178);
				level thread spawnRedGreenStatue((1768.31, 637.58, -55.875), 0);
				level thread spawnRedGreenStatue((2028.53, -678.036, -55.875), -50);
				level thread spawnRedGreenStatue((2334.62, -40.1015, -55.875), 0);
				level thread spawnRedGreenStatue((2138.3, -101.829, 88.125), -87.5653);
				level thread spawnRedGreenStatue((1117.24, -1039.49, 120.125), -2.42122);
				level thread spawnRedGreenStatue((551.603, -1326.36, 120.125), -89.3669);
				level thread spawnRedGreenStatue((824.258, 583.836, -39.4654), 86.8263);
				level thread spawnRedGreenStatue((1913.87, -1678.26, -55.875), -90);
			}
			else if (getDvar("ui_zm_mapstartlocation") == "transit") //busdepot
			{
				level thread spawnRedGreenStatue((-6680.68, 5356.7, -55.875), -135.075);
				level thread spawnRedGreenStatue((-6930.81, 5464.94, -56.1595), 127.416);
				level thread spawnRedGreenStatue((-7087.46, 4935.3, -55.875), 90);
				level thread spawnRedGreenStatue((-6471.17, 4151.1, -63.8538), -89.0641);
				level thread spawnRedGreenStatue((-6560.13, 4595.31, -55.875), -177.834);
				level thread spawnRedGreenStatue((-7380.57, 4590.04, -55.875), -5.16156);
			}
			else if (getDvar("ui_zm_mapstartlocation") == "farm") //farm
			{
				level thread spawnRedGreenStatue((8337.09, -5470.69, 43.7875), 96.3391);
				level thread spawnRedGreenStatue((8284.98, -6419.58, 95.9572), -149.288);
				level thread spawnRedGreenStatue((7768, -6321.18, 117.125),  -151.155);
				level thread spawnRedGreenStatue((7915.94, -6540.96, 117.125), -148.046);
				level thread spawnRedGreenStatue((7967.07, -6323.28, 245.125), 119.553);
				level thread spawnRedGreenStatue((8491.07, -5145.92, 48.125), 7.13562);
				level thread spawnRedGreenStatue((8078.98, -5352.4, 264.125), -145.8);
			}
		}
	}
	else
	{
		if(getDvar("mapname") == "zm_prison") //mob of the dead
		{
			level thread spawnRedGreenStatue((837.331, 10545.4, 1336.13), -177.841);
			level thread spawnRedGreenStatue((371.654, 10219.1, 1336.13), 178.308);
			level thread spawnRedGreenStatue((-402.55, 9087.89, 1336.13), 179.187);
			level thread spawnRedGreenStatue((257.329, 9045.33, 1128.13), -175.946);
			level thread spawnRedGreenStatue((1100.19, 9890.41, 1128.13), -90.3955);
			level thread spawnRedGreenStatue((2150.77, 10428.2, 1144.13), 38.194);
			level thread spawnRedGreenStatue((1986.1, 9942.31, 1336.13), 99.6185);
			level thread spawnRedGreenStatue((2253.78, 9740.41, 1336.13), 145.245);
			level thread spawnRedGreenStatue((3622.03, 9535.28, 1531.07), -78.794);
			level thread spawnRedGreenStatue((1005.05, 9596.2, 1544.13), -93.0927);
			level thread spawnRedGreenStatue((565.058, 8549.78, 832.125), -87.5336);
			level thread spawnRedGreenStatue((-561.661, 6457.66, 65.2816), -170.447);
			level thread spawnRedGreenStatue((-1032.99, 8551.01, 1336.13), -134.951);
			level thread spawnRedGreenStatue((3393.62, 10002.3, 1711.37), 120.828);
		}
		else if(getDvar("mapname") == "zm_buried") //buried
		{
			level thread spawnRedGreenStatue((-3108.05, -800.479, 1360.13), 177.958);
			level thread spawnRedGreenStatue((-760.963, -236.112, 288.125), -0.798118);
			level thread spawnRedGreenStatue((-777.024, -591.747, 109.063), -51.923);
			level thread spawnRedGreenStatue((-916.102, 103.993, -29.0294), -88.7437);
			level thread spawnRedGreenStatue((39.0406, -1143.23, -20.2843), 175.67);
			level thread spawnRedGreenStatue((839.169, -1850.42, 46.536), -86.2113);
			level thread spawnRedGreenStatue((529.553, -446.118, 8.125), 179.218);
			level thread spawnRedGreenStatue((213.842, 1124.43, 8.125), 87.889);
			level thread spawnRedGreenStatue((1697.36, 2386.82, 40.125), 70);
			level thread spawnRedGreenStatue((2265.66, 799.464, 88.125), 43.691);
			level thread spawnRedGreenStatue((3664.26, 1057.93, 4.125), 113.762);
			level thread spawnRedGreenStatue((6739.41, 877.501, 108.125), -6.71426);
			level thread spawnRedGreenStatue((5124.04, 590.992, 9.6608), -4.76968);
			level thread spawnRedGreenStatue((-2655.16, -793.197, 1237.24), -93.519);
		}
		else if(getDvar("mapname") == "zm_transit") //transit
		{
			level thread spawnRedGreenStatue((-11803.1, -1502, 228.125), -178.747);
			level thread spawnRedGreenStatue((-4302.46, -7961.36, -62.875), -88.4398);
			level thread spawnRedGreenStatue((-5407.02, -7808.39, -65.6971), -179.407);
			level thread spawnRedGreenStatue((-6470.75, -7936.55, 0.945047), -131.775);
			level thread spawnRedGreenStatue((13490.9, -678.886, -192.117), -0.13715);
			level thread spawnRedGreenStatue((13593.2, -1603.12, -188.875), -139.916);
			level thread spawnRedGreenStatue((7801.89, -361.099, -203.02), 29.2568);
			level thread spawnRedGreenStatue((11361.9, 7770.59, -535.495), -10.2336);
			level thread spawnRedGreenStatue((12074.7, 8057.92, -755.875), 104.387);
			level thread spawnRedGreenStatue((10614.8, 8725.5, -351.875), -174.715);
			level thread spawnRedGreenStatue((5032.26, 6693.63, -24.3821), -139.076);
			level thread spawnRedGreenStatue((1236.1, 1001.93, -303.875), 45.0661);
		}
		else if(getDvar("mapname") == "zm_tomb") //origins
		{
			level thread spawnRedGreenStatue((2483.18, 4460.28, -315.875), -91.0327);
			level thread spawnRedGreenStatue((1039.57, 4339.34, -341.143), 90);
			level thread spawnRedGreenStatue((157.789, 3779.74, -351.875), -1.16455);
			level thread spawnRedGreenStatue((-728.432, 3074.92, -111.875), 52.1631);
			level thread spawnRedGreenStatue((1899.52, 3408.15, -287.358), -45.9338);
			level thread spawnRedGreenStatue((-2811.21, 535.471, 212.561), 170.189);
			level thread spawnRedGreenStatue((1098.15, -2739.69, 50.125), -33.0853);
			level thread spawnRedGreenStatue((2640.13, 451.668, 149.784), 37.1722);
			level thread spawnRedGreenStatue((-362.466, -3.70188, 40.125), 176.639);
			level thread spawnRedGreenStatue((0.0212979, -452.547, -623.875), -91.0205);
		}
		else if(getDvar("mapname") == "zm_highrise")
		{
			level thread spawnRedGreenStatue((1528.02, 1557.17, 3399.47), 88.8044);
			level thread spawnRedGreenStatue((1803.58, 1146.5, 3216.13), -56.2865);
			level thread spawnRedGreenStatue((1505.65, 1360.61, 3040.13), -179.158);
			level thread spawnRedGreenStatue((1847, 287.11, 1296.13), -123.87);
			level thread spawnRedGreenStatue((2684.59, -512.466, 1120.13), 16.4092);
			level thread spawnRedGreenStatue((1661.29, 46.6346, 2880.13), 144.603);
			level thread spawnRedGreenStatue((2681.98, -531.097, 2880.13), -28.8379);
		}
	}
}

reset_punishments()
{
	if(self.lightchanges >= 2)
	{
		self notify ("reset_punishments");
		self.beingPunished = 0;
		self setmovespeedscale(1);
		self.health = self.maxhealth;
		self setblur( 0, 0.1 );
		self.punishmenttext destroy();
	}
}

punishment_slow_player_down()
{
	self endon ("reset_punishments");
	for(;;)
	{
		self setmovespeedscale(0.3);
		wait 0.1;
	}
}

punishment_no_ammo()
{
    weapon = self getcurrentweapon();
	self setweaponammostock( weapon, 0 );
    self setweaponammoclip( weapon, 0 );
}

punishment_low_health()
{
	self endon ("reset_punishments");
	for(;;)
	{
		if(self.health > 40)
		{
			self.health = 40;
		}
		wait 0.1;
	}
}

punishment_blur()
{
	self endon ("reset_punishments");
	for(;;)
	{
		self setblur( 4, 0.1 );
		wait 0.1;
	}
}

punishment_lose_perk()
{
	self maps\mp\zombies\_zm_perks::lose_random_perk();
}

deadlight()
{
    level thread deadlight_zombies();
	level waittill ("move_light_change");
	wait 0.2;
	playables = getentarray( "player_volume", "script_noteworthy" );
	zombies = getAIArray( level.zombie_team );
	foreach (zombie in zombies)
	{
		for( a = 0; a < playables.size; a++ )
		{
			if(isdefined(zombie.completed_emerging_into_playable_area ) && zombie.completed_emerging_into_playable_area)
			{
				zombie set_zombie_run_cycle("sprint");
			}
			else
			{
				zombie dodamage(zombie.health,zombie.origin);
			}
		}
	}
}

deadlight_zombies()
{
	level endon ("move_light_change");
	for(;;)
	{
		if(level.zombie_total < 5)
		{
			level.zombie_total = 8;
		}
		
		playables = getentarray( "player_volume", "script_noteworthy" );
		zombies = getAIArray( level.zombie_team );
		foreach (zombie in zombies)
		{
			for( a = 0; a < playables.size; a++ )
			{
				zombie set_zombie_run_cycle("super_sprint");
			}
		}
		wait 0.1;
	}
}

round_think_minigame( restart )
{
	if(level.redgreenlightstarted == 0)
	{
		level waittill ("end");
	}
	
	if ( !isdefined( restart ) )
        restart = 0;

/#
    println( "ZM >> round_think start" );
#/
    level endon( "end_round_think" );

    if ( !( isdefined( restart ) && restart ) )
    {
        if ( isdefined( level.initial_round_wait_func ) )
            [[ level.initial_round_wait_func ]]();

        if ( !( isdefined( level.host_ended_game ) && level.host_ended_game ) )
        {
            players = get_players();

            foreach ( player in players )
            {
                if ( !( isdefined( player.hostmigrationcontrolsfrozen ) && player.hostmigrationcontrolsfrozen ) )
                {
                    player freezecontrols( 0 );
/#
                    println( " Unfreeze controls 8" );
#/
                }

                player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
            }
        }
    }

    setroundsplayed( level.round_number );

    for (;;)
    {
        maxreward = 50 * level.round_number;

        if ( maxreward > 500 )
            maxreward = 500;

        level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
        level.pro_tips_start_time = gettime();
        level.zombie_last_run_time = gettime();

        if ( isdefined( level.zombie_round_change_custom ) )
            [[ level.zombie_round_change_custom ]]();
        else
        {
            level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_start" );
            round_one_up();
        }

        maps\mp\zombies\_zm_powerups::powerup_round_start();
        players = get_players();
        array_thread( players, maps\mp\zombies\_zm_blockers::rebuild_barrier_reward_reset );

        if ( !( isdefined( level.headshots_only ) && level.headshots_only ) && !restart )
            level thread award_grenades_for_survivors();

        bbprint( "zombie_rounds", "round %d player_count %d", level.round_number, players.size );
/#
        println( "ZM >> round_think, round=" + level.round_number + ", player_count=" + players.size );
#/
        level.round_start_time = gettime();

        while ( level.zombie_spawn_locations.size <= 0 )
            wait 0.1;

        level thread [[ level.round_spawn_func ]]();
        level notify( "start_of_round" );
        recordzombieroundstart();
        players = getplayers();

        for ( index = 0; index < players.size; index++ )
        {
            zonename = players[index] get_current_zone();

            if ( isdefined( zonename ) )
                players[index] recordzombiezone( "startingZone", zonename );
        }

        if ( isdefined( level.round_start_custom_func ) )
            [[ level.round_start_custom_func ]]();

        [[ level.round_wait_func ]]();
        level.first_round = 0;
        level notify( "end_of_round" );
//        level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_end" );
		level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_start" );
        uploadstats();

        if ( isdefined( level.round_end_custom_logic ) )
            [[ level.round_end_custom_logic ]]();

        players = get_players();

        if ( isdefined( level.no_end_game_check ) && level.no_end_game_check )
        {
            level thread last_stand_revive();
        }
        else if ( 1 != players.size )
            level thread spectators_respawn();

        players = get_players();
        array_thread( players, maps\mp\zombies\_zm_pers_upgrades_system::round_end );
        timer = level.zombie_vars["zombie_spawn_delay"];

        if ( timer > 0.08 )
            level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
        else if ( timer < 0.08 )
            level.zombie_vars["zombie_spawn_delay"] = 0.08;

        if ( level.gamedifficulty == 0 )
            level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
        else
            level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

        level.round_number++;

        if ( 255 < level.round_number )
            level.round_number = 255;

        setroundsplayed( level.round_number );
        matchutctime = getutc();
        players = get_players();

        foreach ( player in players )
        {
            if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
                player maps\mp\zombies\_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );

            player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
            player maps\mp\zombies\_zm_stats::update_playing_utc_time( matchutctime );
        }

        check_quickrevive_for_hotjoin();
        level round_over();
        level notify( "between_round_over" );
        restart = 0;
    }
}