package funkin.backend.system;

import funkin.backend.events.system.ConductorUpdateEvent;

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

    /** Updates the Conductor timing. */
    override function update(elapsed:Float):Void {
        // Advance song position
        songPosition += elapsed * 1000;
    }
}