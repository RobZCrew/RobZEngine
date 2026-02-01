/**
 * Global imports for the engine
 * These imports are injected at compile-time.
 *
 * Use this file to avoid repetitive imports across the codebase.
 *
 * @author AstroZ
 */
@:todo('Add more util classes to FUNKIN / ENGINE')
#if !macro
// HAXE / CORE
import Std;
import Type;
import Reflect;
import Math;

// OPENFL
import openfl.Lib;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.utils.Assets; // openfl.Assets just add a typedef with this class, import the class directly is the best option

// FLIXEL
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.FlxPoint;

import flixel.math.FlxMath;

import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;

import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;
import flixel.input.mouse.FlxMouse;

import flixel.text.FlxText;
import flixel.text.FlxTextAlign;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;

// FUNKIN / ENGINE
import funkin.backend.events.*; // WARNING: This does NOT import directories in events, this just import the IMPORTANT events
import funkin.backend.math.FunkinMath;
import funkin.backend.display.video.FunkinVideo;
import funkin.backend.system.EngineCore;
import funkin.backend.system.Main;

// USING CLASSES
using StringTools;
#end