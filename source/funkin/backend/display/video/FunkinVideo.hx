package funkin.backend.display.video;

import hxvlc.flixel.FlxVideoSprite;
import funkin.backend.events.video.VideoEndEvent;

/**
 * Simple video wrapper for Funkin-based engines.
 *
 * Provides an easy-to-use API over FlxVideoSprite,
 * avoiding low-level flags and signals.
 *
 * TIP 1: You can prevent the video from finishing either by cancelling VideoEndEvent or by manually setting video.finished = true.
 *
 * @author RobZ
 * @since 0.1.0
 */
class FunkinVideo extends FlxVideoSprite {
    /** Whether the video should loop. */
    public var loop:Bool = false;

    /** Whether the video has finished playback. */
    public var finished(get, set):Bool;
    inline function get_finished():Bool return _ended;
    inline function set_finished(value:Bool):Bool return _ended = value;

    /** Called when the video finishes (if not looping). */
    public var onEnd:Void->Void;

    /** The background of the video (if addBackground is true). */
    public var videoBackground:FlxSprite;

    /** Internal guard to avoid multiple end calls. */
    var _ended:Bool = false;

    /** Internal guard to avoid multiple destroy calls. */
    var _destroyed:Bool = false;

    /** Internal path for VideoEndEvent. */
    var _path:String;

    /**
     * Creates a new FunkinVideo.
     *
     * @param path Path to the video file.
     * @param autoPlay Whether to start playing immediately.
     * @param loop Whether the video should loop.
     * @param addBackground Whether the video should have a black background.
     */
    public function new(path:String, ?autoPlay:Bool = false, ?loop:Bool = false, ?addBackground:Bool = false) {
        super();

        this.loop = loop;
        this._path = path;

        if (addBackground) {
            if (videoBackground == null) {
                videoBackground = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
                add(videoBackground);
            } else {
                EngineCore.log('FunkinVideo: Video Background already exists, nothing added.');
            }
        }

        load(path, loop ? ['input-repeat=65545'] : null);
        if (autoPlay) play();

        if (!loop) bitmap.onEndReached.add(finishVideo);

        bitmap.onFormatSetup.add(function() {
            setGraphicSize(FlxG.width, FlxG.height);
            updateHitbox();
            screenCenter();
        });
    }

    /** Starts video playback. */
    public override function play():Void {
        _ended = false;
        super.play();
    }

    function finishVideo():Void {
        if (_destroyed || _ended) return;

        var event = new VideoEndEvent(this, _path, loop);
        EngineCore.events.dispatch(event);

        if (event.cancelled) {
            clearBackground();
            return;
        }

        if (onEnd != null) onEnd();
        _ended = true;
        destroy();
    }

    function clearBackground():Void {
        if (videoBackground != null) {
            remove(videoBackground);
            videoBackground = null;
        }
    }

    override function destroy():Void {
        if (_destroyed) return;

        clearBackground();

        onEnd = null;
        _ended = false;

        super.destroy();
        _destroyed = true;
        EngineCore.log('FunkinVideo: Video successfully destroyed.');
    }
}