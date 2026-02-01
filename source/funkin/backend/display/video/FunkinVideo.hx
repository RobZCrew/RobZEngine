package funkin.backend.display.video;

import hxvlc.flixel.FlxVideoSprite;
import funkin.backend.events.video.VideoEndEvent;

/**
 * Simple video wrapper for Funkin-based engines.
 *
 * Provides an easy-to-use API over FlxVideoSprite,
 * avoiding low-level flags and signals.
 *
 * @author RobZ
 * @since 0.1.0
 */
class FunkinVideo extends FlxVideoSprite {
    /** Whether the video should loop. */
    public var loop:Bool = false;

    /** Whether the video has finished playback. */
    public var finished(get, never):Bool;
    inline function get_finished() return _ended;

    /** Called when the video finishes (if not looping). */
    public var onEnd:Void->Void;

    /** Internal guard to avoid multiple end calls. */
    var _ended:Bool = false;

    /** Internal guard to avoid multiple destroy calls */
    var _destroyed:Bool = false;

    /** Internal path for VideoEndEvent */
    var _path:Null<String> = null;

    /**
     * Creates a new FunkinVideo.
     *
     * @param path Path to the video file.
     * @param autoPlay Whether to start playing immediately.
     * @param loop Whether the video should loop.
     */
    public function new(path:String, autoPlay:Bool = false, loop:Bool = false) {
        super();

        this.loop = loop;
        this._path = path;

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
        if (!_destroyed || !_ended) return;

        var event = new VideoEndEvent(this, _path, loop);
        EngineCore.events.dispatch(event);

        if (event.cancelled) return;

        if (onEnd != null) onEnd();
        _ended = true;
        destroy();
    }

    override function destroy():Void {
        if (_destroyed) return;

        EngineCore.log('FunkinVideo: Video successfully destroyed.');

        onEnd = null;
        _ended = false;

        super.destroy();
        _destroyed = true;
    }
}