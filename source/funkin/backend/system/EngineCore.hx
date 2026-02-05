package funkin.backend.system;

import lime.app.Application;
import funkin.backend.events.EventDispatcher;
import funkin.backend.scripting.*;
import funkin.backend.system.crash.CrashHandler;
import funkin.backend.system.display.PerformanceOverlay;

/**
 * Core system of the engine
 * Handles global configuration and engine-level utilities
 *
 * @author RobZ
 */
@:final
class EngineCore {
    public static var instance:EngineCore;

    public static var initialized(default, null):Bool = false;
    public static var debugMode(default, null):Bool = false;
    public static var version(default, null):String;

    public static final events:EventDispatcher;
    public static var scripts:ScriptManager;
    public static var script:ScriptContext;

    public static var overlay:PerformanceOverlay;

    /**
     * Initializes the engine core
     * Should be called once from Main
     */
    public static function init(?debug:Bool = false):Void {
        if (initialized) return;

        instance = this;
        debugMode = debug;
        initialized = true;
        version = Application.meta.version;

        events = new EventDispatcher();
        scripts = new ScriptManager();
        script = null;

        #if !mobile
        Lib.current.stage.addChild(overlay = new PerformanceOverlay());
        #end

        CrashHandler.init();
        Options.load();

        log('EngineCore initialized');
    }

    /** Simple engine logger */
    @:inline
    public static function log(message:String):Void {
        #if debug
        trace('[Engine] ' + message);
        #end
    }
}