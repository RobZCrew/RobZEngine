package funkin.backend.scripting;

import hscript.Interp;
import funkin.backend.system.crash.CrashHandler;

/**
 * Represents a script execution context.
 *
 * A ScriptContext defines the environment in which
 * a script runs, including its exposed variables,
 * lifecycle hooks, and interpreter reference.
 *
 * Contexts allow scripts to be isolated and reused
 * across different engine systems.
 *
 * @author RobZ
 * @since 0.1.0
 */
class ScriptContext {
    /**
     * Name or identifier of this context.
     *
     * Used mainly for debugging and logging purposes.
     */
    public var name:String;

    /**
     * The hscript interpreter associated with this context.
     *
     * All variables exposed through this context
     * are injected into this interpreter.
     */
    public var interp:Interp;

    /**
     * Creates a new ScriptContext.
     *
     * @param name The name or identifier of the context.
     * @param interp The interpreter used to execute scripts.
     */
    public function new(name:String, interp:Interp) {
        this.name = name;
        this.interp = interp;
    }

    /**
     * Exposes a value to the script environment.
     *
     * This allows scripts to access engine APIs,
     * objects, or custom values defined by the engine.
     *
     * @param key The variable name used inside the script.
     * @param value The value to expose.
     */
    public function expose(key:String, value:Dynamic):Void {
        interp.variables.set(key, value);
    }

    /**
     * Checks whether a variable is exposed in this context.
     *
     * @param key The variable name to check.
     * @return True if the variable exists.
     */
    public function has(key:String):Bool {
        return interp.variables.exists(key);
    }

    /**
     * Removes a variable from the script environment.
     *
     * @param key The variable name to remove.
     */
    public function remove(key:String):Void {
        interp.variables.remove(key);
    }

    /**
     * Calls a function inside the script if it exists.
     *
     * This avoids repetitive checks like:
     * - variable exists
     * - is a function
     * - safe execution
     *
     * Used for lifecycle hooks such as:
     * create, update, destroy, etc.
     *
     * @param funcName Name of the function to call.
     * @param args Optional arguments passed to the function.
     * @return The function result, or null if not called.
     */
    public function call(funcName:String, ?args:Array<Dynamic> = []):Dynamic {
        if (interp == null) return null;
        if (!interp.variables.exists(funcName)) return null;

        var fn = interp.variables.get(funcName);

        if (!Reflect.isFunction(fn)) return null;

        try {
            return Reflect.callMethod(null, fn, args == null ? [] : args);
        } catch (e) {
            var message = Std.string(e);
            var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());

            var realMessage = 'ScriptContext [$name] error calling "$funcName": $message';

            EngineCore.log(realMessage);
            CrashHandler.report(realMessage, stack);
        }

        return null;
    }
}