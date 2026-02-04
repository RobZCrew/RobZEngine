package funkin.backend.scripting;

import hscript.Parser;
import hscript.Interp;

/**
 * Manages the execution of hscript code inside the engine.
 *
 * This class is responsible for creating and configuring
 * the script interpreter, exposing safe engine APIs,
 * and executing scripts in a controlled environment.
 *
 * It is intentionally minimal and designed to be extended
 * as the scripting system grows.
 *
 * @author RobZ
 * @since 0.1.0 
 */
class ScriptManager {
    /**
     * The hscript interpreter instance.
     *
     * Holds all global variables and functions exposed
     * to scripts and executes parsed expressions. 
     */
    public var interp:Interp;

    /**
     * Creates a new ScriptManager instance.
     *
     * Initializes the hscript interpreter and
     * registers the default global variables
     * available to scripts.
     */
    public function new() {
        interp = new Interp();
        setupGlobals();
    }

    /**
     * Registers global variables and engine APIs
     * that are accessible from scripts.
     *
     * Only safe and intentionally exposed objects
     * should be registered here.
     */
    function setupGlobals():Void {
        interp.variables.set('EngineCore', EngineCore);
        interp.variables.set('FlxG', flixel.FlxG);
        interp.variables.set('CancellableEvent', CancellableEvent);
        interp.variables.set('EngineEvent', EngineEvent);
        interp.variables.set('EventDispatcher', EventDispatcher);
    }

    /**
     * Executes a string of hscript code.
     *
     * @param code The raw script source code.
     * @return The result of the script execution, if any.
     */
    public function run(code:String):Dynamic {
        var parser = new Parser();
        var expr = parser.parseString(code);
        return interp.execute(expr);
    }

    /**
     * Executes a script safely.
     *
     * Any runtime errors thrown by the script
     * are caught to prevent the engine from crashing.
     *
     * Errors are logged for debugging purposes.
     *
     * @param code The raw script source code.
     */
    public function runSafe(code:String):Void {
        try {
            run(code);
        } catch (e) {
            EngineCore.log("Script error: " + e);
        }
    }

    /**
     * Loads and executes a script file from disk.
     *
     * @param path The path to the script file.
     */
    public function runFile(path:String):Void {
        var code = sys.io.File.getContent(path);
        runSafe(code);
    }

    public function bindState(state:Dynamic):ScriptContext {
        var name = Type.getClassName(Type.getClass(state));
        var ctx = new ScriptContext(name, interp);

        ctx.expose('state', state);

        return ctx;
    }
}