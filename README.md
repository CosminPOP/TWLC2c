# TWLC2c
_!!! Remove `-master` when extracting into your `interface/addons` folder !!!_<BR><br>


<hr>
**v1.0.2.2**<br>
Ony cloak check `/twneed onycloak`<br>
Frame can now be rescaled (type /twneed resetscale - to reset scale/position if the frame is offscreen)<br>
Better First Seen Items resolver
<hr>

WoDlike frames for received loot, need, and roll frames for TWLC raids<Br>


This addon consists of 3 different frames:<BR>
* Win Frame (shows up when you receive/create items)
* Need/Pick Frame (only in BWL raids for now)
* Roll Frame (only in BWL raids for now)

_Supported locales: EN, DE_

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
