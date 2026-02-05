package funkin.backend.system;

/**
 * Test state used to verify engine systems
 * This is NOT a final gameplay state
 *
 * @author RobZ
 */
@:experimental
@:access(funkin.backend.system.EngineCore)
class TestState extends MusicBeatState {
    override public function create():Void {
        super.create();

        EngineCore.script = EngineCore.scripts.bindState(this);
        EngineCore.scripts.runFile('mods/TestState.hx');

        EngineCore.script.call('create');

        var text = new FlxText(0, 0, 0, "RobZ Engine\nTestState");
        text.setFormat(null, 24, FlxColor.WHITE, CENTER);
        text.screenCenter();

        add(text);

        EngineCore.script.call('postCreate');
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);

        EngineCore.script.call('update', [elapsed]);

        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new TestState());
        }

        // EngineCore.script.call('postUpdate', [elapsed]);
    }

    override function beatHit():Void {
        EngineCore.script.call('beatHit');
    }

    override function stepHit():Void {
        EngineCore.script.call('stepHit');
    }
}