package funkin.editors;

import customFlixel.FlxUIDropDownMenuCustom;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxObject;
import flixel.ui.FlxButton;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import funkin.backend.MusicBeatState;
import funkin.backend.Conductor;
import funkin.game.PlayState;
import funkin.game.Song;

using StringTools;

class ChartingState extends MusicBeatState {
var cameraPosition:FlxObject;

var _file:FileReference;  
var UI_box:FlxUITabMenu;  

var bpmTxt:FlxText;  

public var ignoreWarnings = false;  

var strumLine:FlxSprite;  
var curSong:String = 'Test';  
var commonStagesLabel:String = "";  
var storyWeek:Int = 1;  
var amountSteps:Int = 0;  
var dumbUI:FlxGroup;  

var highlight:FlxSprite;  

var GRID_SIZE:Int = 40;  
var GRID_START_TIME:Float = 0;  
var VISIBLE_TIME:Float = 2000;  

var dummyArrow:FlxSprite;  

var curRenderedNotes:FlxTypedGroup<Note>;  
var curRenderedSustains:FlxTypedGroup<FlxSprite>;  

var gridBG:FlxSprite;  
var nextGridBG:FlxSprite;  

var _song:RobZChart;  

var typingStuff:FlxInputText;  
var moreTypingStuff:FlxInputText;  

/*  
 * WILL BE THE CURRENT / LAST PLACED NOTE  
**/  
var curSelectedNote:RobZNote = {
 t: 0,
 l: 0,
 len: 0
};  

var tempBpm:Float = 0;  

var vocals:FlxSound;  

var leftIcon:HealthIcon;  
var rightIcon:HealthIcon;  

var scrollBlockThing:Array<FlxUIDropDownMenuCustom> = [];  
var blockedScroll:Bool = false;  

override function create() {  
	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));  
	bg.scrollFactor.set();  
	bg.color = 0xFF222222;  
	add(bg);  

	gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);  
	add(gridBG);  

	leftIcon = new HealthIcon('bf');  
	rightIcon = new HealthIcon('dad');  
	leftIcon.scrollFactor.set(1, 1);  
	rightIcon.scrollFactor.set(1, 1);  

	leftIcon.setGraphicSize(0, 45);  
	rightIcon.setGraphicSize(0, 45);  

	add(leftIcon);  
	add(rightIcon);  

	leftIcon.setPosition(0, -200);  
	rightIcon.setPosition(gridBG.width / 2, -200);  

	var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);  
	add(gridBlackLine);  

	curRenderedNotes = new FlxTypedGroup<Note>();  
	curRenderedSustains = new FlxTypedGroup<FlxSprite>();  

	if (PlayState.SONG != null)  
		_song = PlayState.SONG; else {  
		_song = {  
			"meta": {  
				"song": "Test",  
				"songName": "Test",  
				"needsVoices": true,  
				"bpm": 150,  
				"speed": 1,  
				"offset": 0,  

				"characters": {  
					"player": "bf",  
					"opponent": "dad",  
					"girlfriend": "gf"  
				},  

				"stage": "stage",  
				"uiStyle": "default"  
			},  

			"notes": [],  

			"events": []  
		};  
	}  

	FlxG.mouse.visible = true;  
	FlxG.save.bind('robzengine');  

	tempBpm = _song.meta.bpm;  

	addSection();  

	updateGrid();  

	loadSong(_song.meta.song);  
	Conductor.changeBPM(_song.meta.bpm);  
	Conductor.mapBPMChanges(_song);  

	bpmTxt = new FlxText(975, 50, 0, "", 16);  
	bpmTxt.scrollFactor.set();  
	add(bpmTxt);  

	strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * 8), 4);  
	add(strumLine);  

	cameraPosition = new FlxObject(0, 0, 1, 1);  
	cameraPosition.setPosition(strumLine.x + (GRID_SIZE * 8));  

	dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);  
	add(dummyArrow);  

	var tabs = [  
		{name: "Song", label: 'Song'},  
		{name: "Event", label: 'Event'},  
		{name: "Note", label: 'Note'},  
		{name: "Misc", label: 'Misc'}  
	];  

	UI_box = new FlxUITabMenu(null, tabs, true);  

	UI_box.resize(300, 400);  
	UI_box.x = (FlxG.width / 2) + (GRID_SIZE / 2);  
	UI_box.y = 20;  
	add(UI_box);  

	addSongUI();  
	addEventUI();  
	addNoteUI();  

	add(curRenderedNotes);  
	add(curRenderedSustains);  

	super.create();  
}  

function addSongUI():Void {  
	var UI_songTitle = new FlxUIInputText(10, 25, 175, _song.meta.song, 8);  
	typingStuff = UI_songTitle;  

	var UI_songTitleText = new FlxText(UI_songTitle.x, UI_songTitle.y - 15, 0, "Song Name:");  

	var UI_songNameTitle = new FlxUIInputText(10, 60, 175, (_song.meta.songName != null ? _song.meta.songName : _song.meta.song), 8);  
	moreTypingStuff = UI_songNameTitle;  

	var UI_songNameTitleText = new FlxText(UI_songNameTitle.x, UI_songNameTitle.y - 15, 0, "Watermark Song Name:");  

	var check_voices = new FlxUICheckBox(10, 80, null, null, "Song needs voices?", 100);  
	check_voices.checked = _song.meta.needsVoices;  
	check_voices.callback = function() {  
		_song.meta.needsVoices = check_voices.checked;  
		trace('CHECKED!');  
	};  

	var check_mute_inst = new FlxUICheckBox(10, 275, null, null, "Mute Instrumental (in editor)", 100);  
	check_mute_inst.checked = false;  
	check_mute_inst.callback = function() {  
		var vol:Float = 1;  

		if (check_mute_inst.checked)  
			vol = 0;  

		FlxG.sound.music.volume = vol;  
	};  

	var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y, null, null, "Mute Vocals (in editor)", 100);  
	check_mute_vocals.checked = false;  
	check_mute_vocals.callback = function()  
	{  
		if(vocals != null) {  
			var vol:Float = 1;  

			if (check_mute_vocals.checked)  
				vol = 0;  

			vocals.volume = vol;  
		}  
	};  

	var saveButton:FlxButton = new FlxButton(200, 8, "Save", function() {  
		saveLevel();  
	});  

	var delete_notes:FlxButton = new FlxButton(520, 50, 'Delete notes (STATE BETA)', function()  
		{  
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function(){for (sec in 0..._song.notes.length) {  
				_song.notes = [];  
			}  
			updateGrid();  
		}, null,ignoreWarnings));  

		});  
	delete_notes.color = FlxColor.BLUE;  
	delete_notes.label.color = FlxColor.WHITE;  

	var reloadSong:FlxButton = new FlxButton(saveButton.x, saveButton.y + 30, "Reload Audio", function() {  
		loadSong(_song.meta.song);  
	});  

	var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, reloadSong.y + 30, "Reload JSON", function() {  
		loadJson(_song.meta.song.toLowerCase());  
	});  

	var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 115, 1, 1, 1, 999, 3);  
	stepperBPM.value = Conductor.bpm;  
	stepperBPM.name = 'song_bpm';  

	var stepperBPMText = new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, "BPM:");  

	var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(stepperBPM.x + stepperBPM.width + 10, 115, 0.1, 1, 0.1, 999, 2);  
	stepperSpeed.value = _song.meta.speed;  
	stepperSpeed.name = 'song_speed';  

	var stepperSpeedText = new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, "Speed:");  

	var characters:Array<String> = CoolUtil.coolTextFile(Paths.file('characters/characterList.txt'));  
	var stages:Array<String> = CoolUtil.coolTextFile(Paths.file('stages/stageList.txt'));  

	var player2DropDown = new FlxUIDropDownMenuCustom(140, 165, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String) {  
		_song.meta.characters.opponent = characters[Std.parseInt(character)];  
		updateHeads();  
	});  

	player2DropDown.selectedLabel = _song.meta.characters.opponent;  

	var player2Text = new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, "Opponent:");  
	scrollBlockThing.push(player2DropDown);  

	var gfPlayerDropDown = new FlxUIDropDownMenuCustom(10, 200, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String) {  
		_song.meta.characters.girlfriend = characters[Std.parseInt(character)];  
	});  

	if(_song.meta.characters.girlfriend != null)  
		gfPlayerDropDown.selectedLabel = _song.meta.characters.girlfriend; else  
		gfPlayerDropDown.selectedLabel = "gf";  

	var gfPlayerText = new FlxText(gfPlayerDropDown.x, gfPlayerDropDown.y - 15, 0, "Girlfriend:");  
	scrollBlockThing.push(gfPlayerDropDown);

	var player1DropDown = new FlxUIDropDownMenuCustom(10, 165, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String) {  
		_song.meta.characters.player = characters[Std.parseInt(character)];  
		updateHeads();  
	});  
	scrollBlockThing.push(player1DropDown);  

	player1DropDown.selectedLabel = _song.meta.characters.boyfriend;  

	var player1Text = new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, "Player:");  

	var stageDropDown = new FlxUIDropDownMenuCustom(140, 200, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String) {  
		_song.meta.stage = stages[Std.parseInt(stage)];  
		fixStoryWeek(stages[Std.parseInt(stage)]);  
	});  
	scrollBlockThing.push(stageDropDown);  

	if(_song.meta.stage != null) {  
		stageDropDown.selectedLabel = _song.meta.stage;  
	} else {  
		stageDropDown.selectedLabel = commonStagesLabel;  
	}  

	var stageText = new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, "Stage:");  

	var tab_group_song = new FlxUI(null, UI_box);  
	tab_group_song.name = "Song";  
	tab_group_song.add(UI_songTitle);  
	tab_group_song.add(UI_songTitleText);  
	tab_group_song.add(UI_songNameTitle);  
	tab_group_song.add(UI_songNameTitleText);  
	tab_group_song.add(check_voices);  
	tab_group_song.add(check_mute_inst);  
	tab_group_song.add(check_mute_vocals);  
	tab_group_song.add(saveButton);  
	tab_group_song.add(delete_notes);  
	tab_group_song.add(reloadSong);  
	tab_group_song.add(reloadSongJson);  
	tab_group_song.add(stepperBPM);  
	tab_group_song.add(stepperBPMText);  
	tab_group_song.add(stepperSpeed);  
	tab_group_song.add(stepperSpeedText);  
	tab_group_song.add(gfPlayerDropDown);  
	tab_group_song.add(gfPlayerText);  
	tab_group_song.add(stageDropDown);  
	tab_group_song.add(stageText);  
	tab_group_song.add(player1DropDown);  
	tab_group_song.add(player1Text);  
	tab_group_song.add(player2DropDown);  
	tab_group_song.add(player2Text);  

	UI_box.addGroup(tab_group_song);  
	UI_box.scrollFactor.set();  

	FlxG.camera.follow(cameraPosition);  
}  

function fixStoryWeek(curStage:String) {  
	switch(curStage) {  
		case "limo":  
			storyWeek = 4;  
		case "mallEvil":  
			storyWeek = 5;  
		case "mall":  
			storyWeek = 5;  
		case "philly":  
			storyWeek = 3;  
		case "school":  
			storyWeek = 6;  
		case "schoolEvil":  
			storyWeek = 6;  
		case "schoolMad":  
			storyWeek = 6;  
		case "spooky":  
			storyWeek = 2;  
		case "tank":  
			storyWeek = 7;  
		case "stage":  
			storyWeek = 1;  
		default:  
			storyWeek = 0;  
	}  
}  

var eventTypeDropDown:FlxUIDropDownMenuCustom;  
var eventValueInput:FlxUIInputText;  
var addEventButton:FlxButton;  

function addEventUI():Void {  
	var events:Array<String> = [  
		"", // DONT DELETE THIS  
		"CameraFollow",  
		"BPMChange",  
	];  

	var eventType:String = "";  

	var tab_group_event = new FlxUI(null, UI_box);  
	tab_group_event.name = 'Event';  

	eventTypeDropDown = new FlxUIDropDownMenuCustom(10, 25, FlxUIDropDownMenu.makeStrIdLabelArray(events, true), function(event:String) {  
		eventType = events[Std.parseInt(event)];  
	});  
	eventTypeDropDown.selectedLabel = "";  
	scrollBlockThing.push(eventTypeDropDown);  

	var eventTypeText = new FlxText(eventTypeDropDown.x, eventTypeDropDown.y - 15, 0, "Type:");  

	eventValueInput = new FlxUIInputText(10, 60, 175, "", 8);  

	var eventValueText = new FlxText(eventValueInput.x, eventValueInput.y - 15, 0, "Values (comma separated)");  

	addEventButton = new FlxButton(10, 115 - 15, "Add Event", function() {  
		var time:Float = Conductor.songPosition;  
		var type:String = eventType.trim();  

		if (type.length == 0) return;  

		var values:Array<String> = eventValueInput.text.split(",").map(v -> v.trim());  

		var event:RobZEvent = {  
			t: time,  
			type: type,  
			v: values  
		};  

		_song.events.push(event);  

		_song.events.sort(function(a:RobZEvent, b:RobZEvent) {  
			return Std.int(a.t - b.t);  
		});  
	});  

	tab_group_event.add(eventTypeDropDown);  
	tab_group_event.add(eventTypeText);  
	tab_group_event.add(eventValueInput);  
	tab_group_event.add(eventValueText);  
	tab_group_event.add(addEventButton);  

	UI_box.addGroup(tab_group_event);  
}  

var stepperSusLength:FlxUINumericStepper;  

function addNoteUI():Void {  
	var tab_group_note = new FlxUI(null, UI_box);  
	tab_group_note.name = 'Note';  

	stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);  
	stepperSusLength.value = 0;  
	stepperSusLength.name = 'note_susLength';  

	var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');  

	var duetButton:FlxButton = new FlxButton(10, 30 + 45, "Duet Notes", function()  
		{  
			var duetNotes:Array<Array<RobZNote>> = [];  
			for (note in _song.notes)  
			{  
				var boob = note.l;  
				if (boob>3){  
					boob -= 4;  
				}else{  
					boob += 4;  
				}  
  
				var copiedNote:Array<RobZNote> = {t: note.t, l: boob, len: note.len}  
				duetNotes.push(copiedNote);  
			}  
  
			for (i in duetNotes){  
			_song.notes.push(i);  
  
			}  
  
			updateGrid();  
		});  
		var mirrorButton:FlxButton = new FlxButton(duetButton.x + 100, duetButton.y, "Mirror Notes", function()  
		{  
			var duetNotes:Array<Array<RobZNote>> = [];  
			for (note in _song.notes)  
			{  
				var boob = note.l%4;  
				boob = 3 - boob;  
				if (note.l > 3) boob += 4;  
  
				note.l = boob;  
				var copiedNote:Array<RobZNote> = {t: note.t, l: boob, len: note.len};  
				//duetNotes.push(copiedNote);  
			}  
  
			for (i in duetNotes){  
			//_song.notes.push(i);  

			}  
  
			updateGrid();  
		});  

	tab_group_note.add(stepperSusLength);  
	tab_group_note.add(duetButton);  
	tab_group_note.add(mirrorButton);  
	tab_group_note.add(applyLength);  

	UI_box.addGroup(tab_group_note);  
}  

function loadSong(daSong:String):Void {  
	if (FlxG.sound.music != null) {  
		FlxG.sound.music.stop();  
	}  

	FlxG.sound.playMusic(Paths.inst(daSong), 0.6);  

	if(_song.meta.needsVoices)  
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));  
	else  
		vocals = new FlxSound();  
	FlxG.sound.list.add(vocals);  

	FlxG.sound.music.pause();  
	vocals.pause();  

	FlxG.sound.music.onComplete = function() {  
		vocals.pause();  
		vocals.time = 0;  
		FlxG.sound.music.pause();  
		FlxG.sound.music.time = 0;  
	};  
}  

function generateUI():Void {  
	while (dumbUI.members.length > 0) {  
		dumbUI.remove(dumbUI.members[0], true);  
	}  

	var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);  
	dumbUI.add(title);  
}  

override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {  
	if (id == FlxUICheckBox.CLICK_EVENT) {  
		var check:FlxUICheckBox = cast sender;  
		var label = check.getLabel().text;  
		switch (label) {  
			/*case 'Must hit section':  
				_song.notes[curSection].mustHitSection = check.checked;  
				updateHeads();  

			case 'Change BPM':  
				_song.notes[curSection].changeBPM = check.checked;  
				FlxG.log.add('Changed BPM!');  

			case "Alt Animation":  
				_song.notes[curSection].altAnim = check.checked;*/  
		}  
	} else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {  
		var nums:FlxUINumericStepper = cast sender;  
		var wname = nums.name;  
		FlxG.log.add(wname);  
		if (wname == 'song_speed') {  
			_song.meta.speed = nums.value;  
		} else if (wname == 'song_bpm') {  
			tempBpm = nums.value;  
			Conductor.mapBPMChanges(_song);  
			Conductor.changeBPM(nums.value);  
		} else if (wname == 'note_susLength') {  
			curSelectedNote[2] = nums.value;  
			updateGrid();  
		}  
	}  
}  

override function update(elapsed:Float) {  
	curStep = recalculateSteps();  

	Conductor.songPosition = FlxG.sound.music.time;  
	_song.meta.song = typingStuff.text;  
	_song.meta.songName = moreTypingStuff.text;  

	GRID_START_TIME = Conductor.songPosition - (VISIBLE_TIME * 0.5);  

	strumLine.y = getYfromStrum(Conductor.songPosition - GRID_START_TIME);  
	cameraPosition.y = strumLine.y;  

	FlxG.watch.addQuick('daBeat', curBeat);  
	FlxG.watch.addQuick('daStep', curStep);  

	if (FlxG.mouse.justPressed) {  
		if (FlxG.mouse.overlaps(curRenderedNotes)) {  
			curRenderedNotes.forEach(function(note:Note) {  
				if (FlxG.mouse.overlaps(note)) {  
					if (FlxG.keys.pressed.CONTROL) {  
						selectNote(note);  
					} else {  
						trace('tryin to delete note...');  
						deleteNote(note);  
					}  
				}  
			});  
		} else {  
			if (FlxG.mouse.x > gridBG.x  
				&& FlxG.mouse.x < gridBG.x + gridBG.width  
				&& FlxG.mouse.y > gridBG.y  
				&& FlxG.mouse.y < gridBG.y + gridBG.height) {  
				FlxG.log.add('added note');  
				addNote();  
			}  
		}  
	}  

	if (FlxG.mouse.x > gridBG.x  
		&& FlxG.mouse.x < gridBG.x + gridBG.width  
		&& FlxG.mouse.y > gridBG.y  
		&& FlxG.mouse.y < gridBG.y + gridBG.height) {  
		dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;  
		if (FlxG.keys.pressed.SHIFT)  
			dummyArrow.y = FlxG.mouse.y; else  
			dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;  
	}  

	if (FlxG.keys.justPressed.ENTER) {  
		PlayState.SONG = _song;  
		PlayState.storyWeek = storyWeek;  
		FlxG.sound.music.stop();  
		vocals.stop();  
		MusicBeatState.switchState(new PlayState());  
	}  

	if (FlxG.keys.justPressed.M)  
		MusicBeatState.switchState(new ModchartEditorState());  

	if (FlxG.keys.justPressed.E) {  
		changeNoteSustain(Conductor.stepCrochet);  
	}  
	if (FlxG.keys.justPressed.Q) {  
		changeNoteSustain(-Conductor.stepCrochet);  
	}  

	if (FlxG.keys.justPressed.TAB) {  
		if (FlxG.keys.pressed.SHIFT) {  
			UI_box.selected_tab -= 1;  
			if (UI_box.selected_tab < 0)  
				UI_box.selected_tab = 2;  
		} else {  
			UI_box.selected_tab += 1;  
			if (UI_box.selected_tab >= 3)  
				UI_box.selected_tab = 0;  
		}  
	}  

	if (!typingStuff.hasFocus && !moreTypingStuff.hasFocus) {  
		if (FlxG.keys.justPressed.SPACE) {  
			if (FlxG.sound.music.playing) {  
				FlxG.sound.music.pause();  
				vocals.pause();  
			} else {  
				vocals.play();  
				FlxG.sound.music.play();  
			}  
		}  

		blockedScroll = false;  
		for(menu in scrollBlockThing) {  
			if(menu.dropPanel.visible) {  
				blockedScroll = true;  
				break;  
			}  
		}  

		if (FlxG.mouse.wheel != 0 && !blockedScroll)  
		{  
			FlxG.sound.music.pause();  
			vocals.pause();  

			FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);  
			vocals.time = FlxG.sound.music.time;  
		}  

		if (!FlxG.keys.pressed.SHIFT) {  
			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) {  
				FlxG.sound.music.pause();  
				vocals.pause();  

				var daTime:Float = 700 * FlxG.elapsed;  

				if (FlxG.keys.pressed.W) {  
					FlxG.sound.music.time -= daTime;  
				} else  
					FlxG.sound.music.time += daTime;  

				vocals.time = FlxG.sound.music.time;  
			}  
		} else {  
			if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S) {  
				FlxG.sound.music.pause();  
				vocals.pause();  

				var daTime:Float = Conductor.stepCrochet * 2;  

				if (FlxG.keys.justPressed.W)  
					FlxG.sound.music.time -= daTime;  
				else  
					FlxG.sound.music.time += daTime;  

				vocals.time = FlxG.sound.music.time;  
			}  
		}  
	}  

	_song.meta.bpm = tempBpm;  

	bpmTxt.text = Std.string("Current Pos: "  
		+ FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))  
		+ " / "  
		+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))  
		+ "\ncurBeat: "  
		+ curBeat  
		+ "\ncurStep: "  
		+ curStep;  

	super.update(elapsed);  
}  

function changeNoteSustain(value:Float):Void {  
	if (curSelectedNote != null) {  
		if (curSelectedNote.len != null) {  
			curSelectedNote.len += value;  
			curSelectedNote.len = Math.max(curSelectedNote.len, 0);  
		}  
	}  

	updateNoteUI();  
	updateGrid();  
}  

function recalculateSteps():Int {  
	var lastChange:BPMChangeEvent = {  
		stepTime: 0,  
		songTime: 0,  
		bpm: 0  
	}  
	for (i in 0...Conductor.bpmChangeMap.length) {  
		if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)  
			lastChange = Conductor.bpmChangeMap[i];  
	}  

	curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);  
	updateBeat();  

	return curStep;  
}  

function updateHeads():Void {  
	leftIcon.changeIcon(_song.meta.characters.opponent);  
	rightIcon.changeIcon(_song.meta.characters.player);  
}  

function updateNoteUI():Void {  
	if (curSelectedNote != null)  
		stepperSusLength.value = curSelectedNote.len;  
}  

function updateGrid():Void {  
	while (curRenderedNotes.members.length > 0) {  
		curRenderedNotes.remove(curRenderedNotes.members[0], true);  
	}  

	while (curRenderedSustains.members.length > 0) {  
		curRenderedSustains.remove(curRenderedSustains.members[0], true);  
	}  

	var notesInfo:Array<RobZNote> = _song.notes;  

	for (noteData in notesInfo) {  
		var daNoteInfo = noteData.l;  
		var daStrumTime = noteData.t;  
		var daSus = noteData.len;  

		var note:Note = new Note(daStrumTime, daNoteInfo % 4);  
		note.sustainLength = daSus;  
		note.setGraphicSize(GRID_SIZE, GRID_SIZE);  
		note.updateHitbox();  
		note.x = Math.floor(daNoteInfo * GRID_SIZE);  
		note.y = Math.floor(getYfromStrum(daStrumTime - GRID_START_TIME));  

		curRenderedNotes.add(note);  

		if (daSus > 0) {  
			var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),  
				note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(Math.min(daSus, VISIBLE_TIME), 0, VISIBLE_TIME, 0, gridBG.height)));  
			curRenderedSustains.add(sustainVis);  
		}  
	}  
}  

function selectNote(note:Note):Void {  
	for (noteData in _song.notes) {  
		if (noteData.t == note.strumTime && noteData.l % 4 == note.noteData) {  
			curSelectedNote = noteData;  
			break;  
		}  
	}  

	updateGrid();  
	updateNoteUI();  
}  

function deleteNote(note:Note):Void {  
	for (noteData in _song.notes) {  
		if (noteData.t == note.strumTime && noteData.l % 4 == note.noteData) {  
			_song.notes.remove(noteData);  
			break;  
		}  
	}  

	updateGrid();  
}  

function clearSong():Void {  
	_song.notes = [];  

	updateGrid();  
}  

private function addNote():Void {  
	var noteStrum = getStrumTime(dummyArrow.y) + GRID_START_TIME;  
	var noteData = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);  
	var noteSus = 0;  

	_song.notes.push({  
		t: noteStrum,  
		l: noteData,  
		len: noteSus  
	});  

	curSelectedNote = _song.notes[_song.notes.length - 1];  

	trace(noteStrum);  

	updateGrid();  
	updateNoteUI();  
}  

function getStrumTime(yPos:Float):Float {  
	return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, VISIBLE_TIME);  
}  

function getYfromStrum(strumTime:Float):Float {  
	return FlxMath.remapToRange(strumTime, 0, VISIBLE_TIME, gridBG.y, gridBG.y + gridBG.height);  
}  

private var daSpacing:Float = 0.3;  

function loadLevel():Void {  
	trace(_song.notes);  
}  

function getNotes():Array<RobZNote> {  
	var noteData:Array<RobZNote> = [];  

	noteData.push(_song.notes);  

	return noteData;  
}  

function loadJson(song:String):Void {  
	PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());  
	FlxG.resetState();  
}  

private function saveLevel() {  
	var data:String = Json.stringify(_song);  

	if ((data != null) && (data.length > 0)) {  
		_file = new FileReference();  
		_file.addEventListener(Event.COMPLETE, onSaveComplete);  
		_file.addEventListener(Event.CANCEL, onSaveCancel);  
		_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);  
		_file.save(data.trim(), _song.song.toLowerCase() + ".json");  
	}  
}  

function onSaveComplete(_):Void {  
	_file.removeEventListener(Event.COMPLETE, onSaveComplete);  
	_file.removeEventListener(Event.CANCEL, onSaveCancel);  
	_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);  
	_file = null;  
	FlxG.log.notice("Successfully saved LEVEL DATA.");  
}  

function onSaveCancel(_):Void {  
	_file.removeEventListener(Event.COMPLETE, onSaveComplete);  
	_file.removeEventListener(Event.CANCEL, onSaveCancel);  
	_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);  
	_file = null;  
}  

function onSaveError(_):Void {  
	_file.removeEventListener(Event.COMPLETE, onSaveComplete);  
	_file.removeEventListener(Event.CANCEL, onSaveCancel);  
	_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);  
	_file = null;  
	FlxG.log.error("Problem saving Level data");  
}

}
Aca esta lo adapte lo que pude