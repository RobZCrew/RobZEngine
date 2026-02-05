package funkin.backend;

/**
 * like MusicBeatState but without switch and reset state (because is a substate boi)
 *
 * @author RobZ
 * @since 0.1.0
 */
class MusicBeatSubstate extends FlxSubState {
    /** Current beat index. */
    public static var curBeat:Int = 0;

    /** Current step index. */
    public static var curStep:Int = 0;

    /** Internal trackers to detect changes. */
    static var _lastBeat:Int = -1;
    static var _lastStep:Int = -1;

    /** The controls instance. */
    public var controls(get, never):Controls;

    private function get_controls():Controls
        return Controls.instance;

    /** Updates curBeat and curStep every frame. */
    override function update(elapsed:Float):Void {
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
    public static function beatHit():Void {}

    /** Called whenever a new step is reached. */
    public static function stepHit():Void {}
}