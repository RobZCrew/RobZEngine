package funkin.backend;

/**
 * you dont need to know what is this boi
 *
 * @author RobZ
 * @since 0.1.0
 */
class MusicBeatState extends FlxState {
    /** Current beat index. */
    private var curBeat:Int = 0;

    /** Current step index. */
    private var curStep:Int = 0;

    /** Whether the state should skip the next transition. */
    @:noCompletion private static var skipNextTransIn:Bool = false;

    /** Internal trackers to detect changes. */
    var _lastBeat:Int = -1;
    var _lastStep:Int = -1;

    /** The controls instance. */
    public var controls(get, never):Controls;

    private function get_controls():Controls
        return Controls.instance;

    /** Switches the state with a custom transition. */
    public static function switchState(newState:FlxState = null):Void {
        if (newState == null) newState = FlxG.state;
        if (newState == FlxG.state) {
            resetState();
            return; // avoid the function to do something else
        }

        if (skipNextTransIn) startTransition(newState);
        else FlxG.switchState(newState);
    }

    /** Resets the current state with a custom transition. */
    public static function resetState():Void {
        if (skipNextTransIn) startTransition();
        else FlxG.resetState();
    }

    /** Start the custom transition. */
    public static function startTransition(?newState:FlxState = null):Void {
        if (newState == null) newState = FlxG.state;

        FlxG.state.openSubState(new MusicBeatTransition(0.5, false));

        if (newState == FlxG.state)
            MusicBeatTransition.finishCallback = () -> FlxG.resetState();
        else
            MusicBeatTransition.finishCallback = () -> FlxG.switchState(newState);
    }

    /** Gets the current state. */
    public static function getState():MusicBeatState {
       return cast(FlxG.state, MusicBeatState);
    }

    /** Updates curBeat and curStep every frame. */
    override function update(elapsed:Float):Void {
        super.update(elapsed);

        // Calculate current beat and step
        curBeat = Math.floor(Conductor.songPosition / Conductor.crochet);
        curStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);

        // Step hit
        if (curStep != _lastStep) {
            _lastStep = curStep;
            stepHit();

            // Beat hit
            if (curStep % 4 == 0 && curBeat != _lastBeat) {
                _lastBeat = curBeat;
                beatHit();
            }
        }
    }

    /** Called whenever a new beat is reached. */
    public function beatHit():Void {}

    /** Called whenever a new step is reached. */
    public function stepHit():Void {}
}