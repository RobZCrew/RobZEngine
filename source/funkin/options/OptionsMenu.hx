package funkin.options;

import funkin.backend.system.crash.CrashHandler;
import funkin.menus.ui.HelperScreen;

/**
 * Simple options menu.
 *
 * This is an early implementation intended
 * to be expanded later with more settings and better interface (maybe).
 *
 * Inspiration from the OptionsMenu one of my friend's engine.
 *
 * @author RobZ
 * @since 0.1.0
 */
@:todo('Add more options')
class OptionsMenu extends MusicBeatState {
    var optionsTabs:Array<String> = [];
    var optionsBools:Array<String> = [];
    var optionsStuff:Array<String> = [];
    var curTab:Int = 0;
    var curSelected:Int = 0;
    @:noCompletion var checkingKey:Bool = false; // WIP
    @:noCompletion var isAltKey:Bool = false; // WIP

    var grpControls:FlxTypedGroup<FlxText>;
    var grpControlsBools:FlxTypedGroup<FlxText>;
    var grpControlsTabs:FlxTypedGroup<FlxText>;

    override function create() {
        super.create();

        Options.load();

        optionsTabs.push('Gameplay');
        optionsTabs.push('Keybinds');
        optionsTabs.push('User Experience');

        var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/menuDesat'));
        menuBG.color = FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255));
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        add(menuBG);

        var menuGray:FlxSprite = new FlxSprite(30, 60).makeGraphic(1220, 600, FlxColor.BLACK);
        menuGray.alpha = 0.5;
        add(menuGray);

        var tabDivider:FlxSprite = new FlxSprite(30, 112).makeGraphic(1220, 5, FlxColor.BLACK);
        add(tabDivider);

        add(grpControls = new FlxTypedGroup<FlxText>());
        add(grpControlsBools = new FlxTypedGroup<FlxText>());
        add(grpControlsTabs = new FlxTypedGroup<FlxText>());

        setupGameplayTab();

        for (i in 0...optionsTabs.length) {
            var text:FlxText = new FlxText(50, 70, 0, optionsTabs[i]);
            text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.borderSize = 1.25;
            if (i != 0) {
                text.x = grpControlsTabs.members[i - 1].x + grpControlsTabs.members[i - 1].width + 32;
                text.alpha = 0.6;
            }
            grpControlsTabs.add(text);
        }
    }

    function changeSelection(change:Int = 0) {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;

        if (curSelected < 0)
            curSelected = grpControls.length - 1;
        if (curSelected >= grpControls.length)
            curSelected = 0;

        for (i in 0...grpControls.length) {
            grpControls.members[i].alpha = 0.6;
        }
        grpControls.members[curSelected].alpha = 1;

        for (i in 0...grpControlsBools.length) {
            grpControlsBools.members[i].alpha = 0.6;
        }
        if (grpControlsBools.length > curSelected)
            grpControlsBools.members[curSelected].alpha = 1;
    }

    function changeTab(tabChoice:Int = 0) {
        curTab += tabChoice;
        curSelected = 0;

        if (curTab < 0)
            curTab = grpControlsTabs.length - 1;
        if (curTab >= grpControlsTabs.length)
            curTab = 0;

        for (i in 0...grpControlsTabs.length) {
            if (i != curTab)
                grpControlsTabs.members[i].alpha = 0.6;
            else
                grpControlsTabs.members[i].alpha = 1;
        }

        switch(curTab) {
            case 0: setupGameplayTab();
            case 1: setupKBTab();
            case 2: setupUETab();
            default: setupGameplayTab();
        }
    }

    function changeAndSave(name:String) {
        if (!Std.isOfType(Reflect.field(Options, name), Bool)) {
            CrashHandler.report('You can't add a no-boolean value in options, more types will be supported soon.', '');
            return;
        }

         Reflect.setField(Options, name, !Reflect.field(Options, name));
         Options.save();
    }

    function setupGameplayTab() {
        grpControls.clear();
        grpControlsBools.clear();
        untyped optionsStuff.length = 0;
        untyped optionsBools.length = 0;

        optionsStuff.push('Downscroll');
        optionsBools.push((Options.downscroll ? '< ON >' : '< OFF >'));

        addText();
    }

    function setupKBTab() {
        grpControls.clear();
        grpControlsBools.clear();
        untyped optionsStuff.length = 0;
        untyped optionsBools.length = 0;

        optionsStuff.push('Unavailable for now, default notes controls are [Z, X, N, M]');

        /*optionsStuff.push('Left');
        optionsBools.push('< $Options.keyBinds.get('ui_left')[0].toString() >');
        optionsStuff.push('Left (Alt)');
        optionsBools.push('< $Options.keyBinds.get('ui_left')[1].toString() >');

        optionsStuff.push('Down');
        optionsBools.push('< $Options.keyBinds.get('ui_down')[0].toString() >');
        optionsStuff.push('Down (Alt)');
        optionsBools.push('< $Options.keyBinds.get('ui_down')[1].toString() >');

        optionsStuff.push('Up');
        optionsBools.push('< $Options.keyBinds.get('ui_up')[0].toString() >');
        optionsStuff.push('Up (Alt)');
        optionsBools.push('< $Options.keyBinds.get('ui_up')[1].toString() >');

        optionsStuff.push('Note Right');
        optionsBools.push('< $Options.keyBinds.get('note_right')[0].toString() >');
        optionsStuff.push('Note Right (Alt)');
        optionsBools.push('< $Options.keyBinds.get('note_right')[1].toString() >');

        optionsStuff.push('Note Left');
        optionsBools.push('< $Options.keyBinds.get('note_left')[0].toString() >');
        optionsStuff.push('Note Left (Alt)');
        optionsBools.push('< $Options.keyBinds.get('note_left')[1].toString() >');

        optionsStuff.push('Note Down');
        optionsBools.push('< $Options.keyBinds.get('note_down')[0].toString() >');
        optionsStuff.push('Note Down (Alt)');
        optionsBools.push('< $Options.keyBinds.get('note_down')[1].toString() >');

        optionsStuff.push('Note Up');
        optionsBools.push('< $Options.keyBinds.get('note_up')[0].toString() >');
        optionsStuff.push('Note Up (Alt)');
        optionsBools.push('< $Options.keyBinds.get('note_up')[1].toString() >');

        optionsStuff.push('Note Right');
        optionsBools.push('< $Options.keyBinds.get('note_right')[0].toString() >');
        optionsStuff.push('Note Right (Alt)');
        optionsBools.push('< $Options.keyBinds.get('note_right')[1].toString() >');*/

        addText();
    }

    function setupUETab() {
        grpControls.clear();
        grpControlsBools.clear();
        untyped optionsStuff.length = 0;
        untyped optionsBools.length = 0;

        optionsStuff.push('Check For Updates');
        optionsBools.push((Options.checkForUpdates ? '< ON >' : '< OFF >'));

        addText();
    }

    function addText() {
        for (i in 0...optionsBools.length) {
            var text:FlxText = new FlxText(FlxG.width - 40, 122 + (32 * i), 0, optionsBools[i]);
            text.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.borderSize = 1.25;
            text.x -= text.width;
            if (i != 0) text.alpha = 0.6;
            grpControlsBools.add(text);
        }

        for (i in 0...optionsStuff.length) {
            var text:FlxText = new FlxText(40, 122 + (32 * i), 0, optionsStuff[i]);
            text.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.borderSize = 1.25;
            text.x -= text.width;
            if (i != 0) text.alpha = 0.6;
            grpControls.add(text);
        }
    }

    function updateText(name:String, curSelected:Int = 0) {
        if (!Std.isOfType(Reflect.field(Options, name), Bool)) {
            CrashHandler.report('You can't add a no-boolean value in options, more types will be supported soon.', '');
            return;
        }

        grpControlsBools.members[curSelected].text = (Reflect.field(Options, name) ? '< ON >' : '< OFF >');
        grpControlsBools.members[curSelected].x = FlxG.width - grpControlsBools.members[curSelected].width - 40;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.F) {
            openSubState(new HelperScreen(this));

        if (controls.UP_P)
            changeSelection(-1);

        if (controls.DOWN_P)
            changeSelection(1);

        if (controls.LEFT_P)
            changeTab(-1);

        if (controls.RIGHT_P)
            changeTab(1);

        if (controls.ACCEPT) {
            switch(curTab) {
                case 0:
                    switch(curSelected) {
                         case 0:
                             changeAndSave('downscroll');
                             updateText('downscroll', curSelected);
                    }

                case 2:
                    switch(curSelected) {
                         case 0:
                             changeAndSave('checkForUpdates');
                             updateText('checkForUpdates', curSelected);
                    }
            }
        }

        if (controls.BACK) {
            MusicBeatState.switchState(new MainMenuState());
        }
    }
}