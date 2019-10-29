# 10.3.3 OTA Downgrade Script
Script to downgrade any device that has iOS 10.3.3 OTA signed.
 
Please read this before doing ANYTHING
-------------------------------------------

Yes, this may not work out of the box for everyone. Please note, if you are experienced with compiling things and using package managers, this will be an easy fix. For everyone else, please post any issues on the issues page and I will try to resolve any issues that are present. Also, please do not change a single thing unless you absolutely know what you're doing. Just let the script do its thing.

Only supports the iPhone 5s (6,1 and 6,2), iPad Air (iPad4,1 iPad4,2 and iPad4,3) and iPad Mini 2 (iPad4,4 and iPad4,5). No iPad4,6 support ever because it doesn't have 10.3.3 OTA signed as it shipped with 7.1 not 7.0.

Has been tested on macOS Mojave but SHOULD work on Catalina as it now doesn't need to write to / but CATALINA IS UNTESTED CURRENTLY. Don't complain to us if it doesn't work, just give us errors and we will try fix it. If you are running High Sierra or Catalina, it seems like these are the worst for ipwndfu to exploit your device. I'd advise either running a new install or
just not even running this. You won't get anywhere on those versions until axi0mX updates the exploit.

Windows support will probably be something that would never happen. Axi0mX probably isn't interested in supporting Windows with ipwndfu. Until then, Windows support will not be added.

If this breaks your phone or macOS install neither Matty or Merc take absolutely no responsibility.
This script has been tested by Matty, Merc, and others and should be fine but in case something goes wrong, that's on you not us. 

No verbose boot, custom logo's, or anything else will be added as of now, maybe later on. This will only downgrade your device to 10.3.3 and that's it.

The only things you need for this to work are: 
-------------------------------------------
An iOS 10.3.3 ipsw

A few braincells (VERY IMPORTANT) 

Commonsense (RARE BUT ALSO VERY IMPORTANT)

Patience!!!

How to downgrade:
-------------------------------------------
(Please cd into this directory or else you will have issues.)

1. Download your iOS 10.3.3 ipsw and make sure it's in your current directory.

2. Place device into DFU mode and connect to computer.

3. Run restore.sh as so, with also changing the arguments (don't add the quotes) with what you have: ./restore.sh "pathtoipsw"

4. Wait

5. Install your favorite iOS 10.x jailbreak, or with checkra1n, when its out (and supports iOS 10).

6. Give feedback (issues, a thank you, anything that should be added to this)

Credits: 
-------------------------------------------

Thank you to anyone who helped us with testing or anything else! Couldn't have done it without the help of everyone who contributed. 

Credits to: axi0mx, Tihmstar, LinusHenze, alitek12, xerub and s0uthwest.

Thanks to: @Vyce\_Merculous, @xerusxan, @AyyItzRob123, @BarisUlasCukur, @DaveWijk, @melvin\_zill and anyone else I missed!

<hr>

If you have any questions, either open an issue here, message Matty(@mosk\_i) or Merc (@Vyce\_Merculous) on Twitter, or comment on the reddit post.

Also just note, just because there's something not used in the project, do not send us thousands of messages asking us to add whatever you want.
Do it yourselves, its not hard, at all. Just look things up, the Internet is a thing.
