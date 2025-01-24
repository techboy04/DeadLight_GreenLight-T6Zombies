# Dead Light Green Light - Plutonium T6 Zombies - 1.0
This is a recreation of the Black Ops 6 Limited Time Mode called Dead Light Green Light, but better.
Its basically Red Light Green Light but with a twist!

I felt like the original mode was lacking some proper punishments for when you move AND it was stupid that EEs were disabled and there was a round limit of 10.
This allows EEs and doesn't have a round limit.

On Green Light, you can move and you get double points.
On Red Light, you have to stand still and you do not gain points. If you move, you get punished!
At a random point, Dead Light will activate, where you can move but zombies will have super sprint.

By Default, there is no perk limit.

There are two different versions, the mod version (Recommended for the full experience) and the script only version.

# Using the Mod version (Recommended)
## zm_deadlight.zip

## Installation
Download zm_deadlight zip and put it in your Plutonium T6 mods folder

```%localappdata%\Plutonium\storage\t6\mods\```

(if the folder isnt there create them)

There are configurable options which can be changed via the **Custom Games** menu instead of the console! (You can still do it in the console)
The values also save after you set them so they load when coming back!

``set deadlight_rules 0/1/2`` - Choose whether or not you wanna use the improved rules or the rules from Black Ops 6.
- 0 - The Improved Rules. Basically allows the punishments.
- 1 - Bo6's rules. Doesn't include punishments.
- 2 - Squid Game's rules. Instead of losing points or getting punish, you get downed.
- **Default:** ``0``

``set deadlight_copyright 0/1`` - Choose whether to enable copyrighted content such as the music. Recommeneded to be disabled by creators.
- 0 - Disable
- 1 - Enable
- **Default:** ``1``

``Note: Currently the only change is the Game Over music and im not sure if it really impacts the content. I tested this on a non Partner Program channel and got No Impact while it warns me it may be different for Partner Program channels.``

``set deadlight_voice 0/1/2`` - Choose the speaker that says Red light and Green light.
- 0 - No voice - Uses sounds like the script version.
- 1 - Statue Entity - Based off my main mod, TechnoOps Collection.
- 2 - Young-Hee - The character from Squid Game.
- **Default:** ``2``

``set enable_deadlight_vox 0/1/2/3`` - Choose whether or not you wanna use the improved rules or the rules from Black Ops 6.
- 0 - Disabled
- 1 - Both Audio and Subtitles
- 2 - Only Audio
- 3 - Only Subtitles
- **Default:** ``1``

# Using the Scripts version
## deadlight_greenlight.gsc

## Installation
Download deadlight_greenlight.gsc and put it in your Plutonium T6 scripts folder

```%localappdata%\Plutonium\storage\t6\scripts\zm\```

(if the folder isnt there create them)

You will have to open console and type in ```set enable_deadlightgreenlight 1``` to enable this! This is so you can still have the script in your folder while also able to disable it if you want to use other mods!

There is one configurable option!

``set deadlight_rules 0/1/2`` - Choose whether or not you wanna use the improved rules or the rules from Black Ops 6.
- 0 - The Improved Rules. Basically allows the punishments.
- 1 - Bo6's rules. Doesn't include punishments.
- 2 - Squid Game's rules. Instead of losing points or getting punish, you get downed.

## Got a Bug or a Suggestion?
As this mode is still being worked on, I accept suggestions and bugs. [Join the Discord server](https://discord.gg/dkwyDzW), Grab the Call of Duty role, and report it to [#technoops-forums](https://discord.com/channels/399600672586203137/1032884888468213811)
