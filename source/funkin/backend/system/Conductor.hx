package funkin.backend.system;

/**
 * you dont need to know what is this boi
 *
 * @author RobZ
 * @since 0.1.0
 */
class Conductor
{
    /** Current BPM of the song. */
    public static var bpm:Float = 100;

    /** Length of one beat in milliseconds. */
    public static var crochet:Float = (60 / bpm) * 1000;

    /** Length of one step (1/4 beat) in milliseconds. */
    public static var stepCrochet:Float = crochet / 4;

    /** Current song position in milliseconds. */
    public static var songPosition:Float = 0;

    /** Current beat index. */
    public static var curBeat:Int = 0;

    /** Current step index. */
    public static var curStep:Int = 0;

    /** Internal trackers to detect changes. */
    static var _lastBeat:Int = -1;
    static var _lastStep:Int = -1;

    /**
     * Changes the BPM and recalculates timing values.
     *
     * @param newBPM The new BPM value.
     */
    public static function changeBPM(newBPM:Float):Void {
        bpm = newBPM;
        crochet = (60 / bpm) * 1000;
        stepCrochet = crochet / 4;
    }

    /**
     * Updates the Conductor timing.
     *
     * Should be called every frame.
     *
     * @param elapsed Time since last frame (in seconds).
     */
    public static function update(elapsed:Float):Void {
        // Advance song position
        songPosition += elapsed * 1000;

        // Calculate current beat and step
        curBeat = Math.floor(songPosition / crochet);
        curStep = Math.floor(songPosition / stepCrochet);

        // Beat hit
        if (curBeat != _lastBeat) {
            _lastBeat = curBeat;
            beatHit();
        }

        // Step hit
        if (curStep != _lastStep) {
            _lastStep = curStep;
            stepHit();
        }
    }

    /** Called whenever a new beat is reached. */
    public static function beatHit():Void {}

    /** Called whenever a new step is reached. */
    public static function stepHit():Void {}
}