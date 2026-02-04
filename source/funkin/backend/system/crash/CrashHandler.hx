package funkin.backend.system.crash;

import Date;
import sys.io.File;
import sys.FileSystem;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.events.ErrorEvent;
import openfl.errors.Error;
import haxe.CallStack;

/**
 * Global crash handler for the engine.
 *
 * Catches uncaught runtime errors and script exceptions,
 * generates a readable crash report (file + line),
 * saves it to the logs folder and displays a crash message.
 *
 * This handler is engine-level and should not contain
 * gameplay or state-specific logic.
 *
 * @author RobZ
 * @since 0.1.0
 */
class CrashHandler {
    public static var initialized(default, null):Bool = false;

    /**
     * Initializes the global crash handler.
     *
     * This should be called once during engine startup.
     * Automatically hooks into OpenFL's uncaught error events.
     */
    public static function init():Void {
        if (initialized) return;
        initialized = true;
        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
    }

    /**
     * Handles uncaught runtime errors.
     *
     * Determines the error type (Error, ErrorEvent or Dynamic),
     * extracts useful information (message, file, line),
     * and forwards it to the crash reporter.
     *
     * @param e The uncaught error event dispatched by OpenFL.
     */
    static function onUncaughtError(e:UncaughtErrorEvent):Void {
        e.preventDefault();

        var message:String = "Unknown error";
        var stack:String = "";

        // Error (Haxe / runtime)
        if (Std.isOfType(e.error, Error)) {
            var err:Error = cast e.error;
            message = err.message;

            var callStack = CallStack.exceptionStack();
            stack = formatStack(callStack);

        // ErrorEvent (OpenFL)
        } else if (Std.isOfType(e.error, ErrorEvent)) {
            var errEvent:ErrorEvent = cast e.error;
            message = errEvent.text;

        // Fallback
        } else {
            message = Std.string(e.error);
        }

        report(message, stack);
    }

    /**
     * Formats a Haxe call stack into a readable string.
     *
     * Only file paths and line numbers are included
     * to avoid noisy or irrelevant output.
     *
     * @param stack The exception call stack.
     * @return A formatted stack trace string.
     */
    static function formatStack(stack:Array<CallStack.StackItem>):String {
        var out:Array<String> = [];

        for (item in stack) {
            switch (item) {
                case FilePos(_, file, line):
                    out.push(file + ":" + line);

                case Method(className, method):
                    out.push(className + "." + method);

                default: // nothing lol
            }
        }

        return out.join("\n");
    }

    /**
     * Reports a fatal crash.
     *
     * Writes a crash log to disk, displays a crash message
     * to the user and safely terminates the application.
     *
     * @param message The crash error message.
     * @param stack The formatted stack trace.
     */
    static function report(message:String, stack:String):Void {
        trace('[CrashHandler] Uncaught Error: ' + message);
        if (stack != '') trace(stack);

        var logPath = saveLog(message, stack);
        showAlert(message, logPath);

        Sys.exit(1);
    }

    static function saveLog(message:String, stack:String):String {
        var logDir = "logs";

        if (!FileSystem.exists(logDir))
            FileSystem.createDirectory(logDir);

        var date = Date.now();
        var fileName = 'crash_${date.toString().replace(" ", "_").replace(":", "-")}.txt';
        var path = logDir + "/" + fileName;

        var content = 
            "=== CRASH REPORT ===\n" +
            "Time: " + date.toString() + "\n\n" +
            "Message:\n" + message + "\n\n" +
            "Stack trace:\n" + (stack != "" ? stack : "No stack available");

        File.saveContent(path, content);

        return path;
    }

    static function showAlert(message:String, logPath:String):Void {
        var text =
            "The engine has crashed.\n\n" +
            message + "\n\n" +
            "A crash log has been saved at:\n" +
            logPath + "\n\n" +
            "Please report this error.\n" +
            "Crash Handler made by RobZ.";

        Application.current.window.alert(text, "Engine Crash");
    }
}