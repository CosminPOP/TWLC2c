# TWLC2c v1.0.3.2
_!!! Remove `-master` when extracting into your `interface/addons` folder !!!_ <br>

If you like my work consider buying me a coffee !<br> 
https://ko-fi.com/xerron <br>
https://paypal.me/xerroner <br>

##### Retail-like(almost) frames for received loot, need, roll, pull, and boss death frames for TWLC raids<Br>

## v1.0.3.2
Naxxramas tokens.<br>
Loatheb healing rotation helper.

## v1.0.3.1
Addon now sends current items for aq tokens.<br>
You can ctrl-click items that drop to see how they look !<br>

## v1.0.3.0
Added transmog option when needing an item and a transmog win frame.<br>

## v1.0.2.6
Quest rewards for items that start a quest or tokens.<br>
Updated pull timer graphics.<br>  

## v1.0.2.5
New Frame added. Boss Frame, pull countdown.<br>
Type `/twboss` to toggle boss death splash.<br>  

## v1.0.2.4
New Frame added. Pull Frame, pull countdown.<br>
Type `/twpull` to toggle BigWigs Pull countdown.<br> 
Type `/twpullsound` to toggle BigWigs Pull countdown sound.<br> 

## v1.0.2.3
Better new items resolver

## v1.0.2.2
Ony cloak check `/twneed onycloak`<br>
Test frame shows `7` items<br>
Frame can now be rescaled (type `/twneed resetscale` - to reset scale/position if the frame is offscreen)<br>

This addon consists of 5 different frames:<BR>
* Boss Frame (boss has been defeated splash)
* Pull Frame (5 seconds countdown)
* Win Frame (shows up when you receive/create items)
* Need/Pick Frame (only in BWL raids for now)
* Roll Frame (only in BWL raids for now)


_Supported locales: EN, DE_

### Boss Frame

Shows a boss defeated splash.<br>
![bossdeath](https://imgur.com/hvG1nfl.png)

### Pull Frame

5 Seconds countdown when a raid assistant starts a BigWigs pull timer.<Br>
![pull](https://imgur.com/H24gQlO.png)

### Win Frame

Whenever you loot an item equal or above the set threshold this frame will pop up, notifying you about what you just got.<BR><BR>
Examples:<BR><BR>
Green/Uncommon - threshold `2`<BR>
![green](https://i.imgur.com/nU2MBAv.png)

Blue/Rare - threshold `3`<BR>
![blue](https://i.imgur.com/3lpn7nh.png)

Purple/epic - threshold `4`<BR>
![purple](https://i.imgur.com/G2mT0pC.png)


##### Slash commands

`/twwin` - show win frame anchor allowing reposition and testing<br>
`/twwinsound` - toggle the win sound on or off<br>
`/twwinsound high/low` - set sound volume to high or low<br>
`/twwin <0-5>` - allows you to set the minimum item quality shown<BR>

Thresholds are:<Br>
0 = Poor<br>
1 = Common<br>
2 = Uncommon<br>
3 = Rare<br>
4 = Epic<br>
5 = Legendary<br>

### Need/Pick Frame

While in a BWL raid, dropped loot will be broadcasted by the master looter to everyone with this addon<Br>
Raiders with the addon will get one frame for each item broadcasted.<Br><Br>
Example:<BR>
Version 1.0.2.6 brings quest rewards for items that start a quest or for AQ tokens:<Br>
![quest rewards](https://imgur.com/SvjEn2o.png)
<br><Br>
![loot frame](https://i.imgur.com/FS2NMC5.png)
<BR>
Raiders can pick each item for one of the 3 reasons:<Br>
* **BIS** - The item is current content's `BEST IN SLOT` for their class/spec<br>
* **MS** - `Main Spec` upgrade means that the item is a pure upgrade over what they currently use for their main spec<br>
* **OS** - `Offspec` means that they want the item for anything other than their current spec<Br>

##### Slash commands
`/twneed` - will show need frame anchor allowing reposition and testing<br>


### Roll Frame
The roll frame will pop up in raid when there's a vote tie.<br>

![roll frame](https://imgur.com/BWZ5RQB.png)

Raiders can now pick to roll or pass. The winner of the roll will get the item in cause.<Br>

##### Slash commands

`/twroll` - show win frame anchor allowing reposition and testing<br>
`/twrollsound` - toggle the roll sound on or off<br>
`/twrollsound high/low` - set roll sound volume to high or low<br>

**New in v1.0.0.5**<Br>
`/twtrombone` - toggle the sad trombone sound on or off for when you lose a roll<br>
