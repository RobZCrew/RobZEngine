package funkin.backend.events.video;

/**
 * Event fired when a video finishes playback.
 *
 * This event is cancellable. Cancelling it will prevent
 * the video from triggering its onEnd callback and
 * being destroyed.
 *
 * @author RobZ
 * @since 0.1.0
 */
class VideoEndEvent extends CancellableEvent {
    /** Video instance that finished playing. */
    public final video:FunkinVideo;

    /** Path of the video file. */
    public final path:String;

    /** Whether the video was looping. */
    public final wasLooping:Bool;

    public function new(video:FunkinVideo, path:String, wasLooping:Bool) {
        super();
        this.video = video;
        this.path = path;
        this.wasLooping = wasLooping;
    }
}