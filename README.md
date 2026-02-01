# Friday Night Funkin': RobZ Engine
 No description here yet.
 > [!NOTE]
 > Remember to check import.hx before import a class that the archive already imports
 > 
 > [Also you can join our discord server for updates and announcements, just click here](https://discord.gg/NynuH8DTEk)

## RobZ Engine Team
 -RobZ (Creator, Programmer)
 
 -Gianfranco Xankin (Artist)

## Special Thanks
 -Realistic Engine (Inspiration / Friend's Engine)
 
 -Codename Engine (Inspiration)

## Build Instructions (Windows)
 > [!WARNING]
 > THIS ENGINE FOR NOW IS ONLY FOR WINDOWS AND ONLY 64 BIT
 > 
 > AND PLEASE DON'T USE THIS STILL BECAUSE THE ENGINE ISN'T FINISHED YET WAIT UNTIL ENGINE'S RELEASE
 
 > [!CAUTION]
 > THE FOLLOWING INSTRUCTIONS IS SOME OUTDATED (still) IT WILL BE UPDATED AGAIN LATER
 
 If you want to compile the game, follow these steps:
 1. [Install Haxe 4.3.7](https://haxe.org/download/version/4.3.7/)
 2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe (Is recommended skip this now)
 
 Now open cmd and type the following commands:
 ```
 haxelib install lime 8.1.2
 haxelib install openfl 9.5.0
 haxelib install flixel 5.3.1
 haxelib install flixel-addons 3.0.2
 haxelib install flixel-ui 2.5.0
 haxelib install hscript 2.4.0
 haxelib install hxvlc 1.9.3
 haxelib run lime setup flixel
 haxelib run lime setup
 haxelib install hxdiscord_rpc 1.1.1
 ```
 After you have installed all the libraries go to the RobZEngine folder and open terminal and place:
 ```
 lime test windows
 ```
 or
 ```
 lime test windows -debug
 ```
 The lime test windows -debug is used to see the errors in the compilation.

 Is it normal that after compiling it tells me a warning at some point?

 Yes, if it is normal, it is not an error, it is just a warning.
