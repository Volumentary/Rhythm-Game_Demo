package backend;

import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import lime.app.Application;
import haxe.CallStack;

class CrashHandler
{
    public static function setup()
    {
        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
    }

    public static function onCrash(e:UncaughtErrorEvent):Void
    {
        var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);

		for (stackItem in callStack)
        {
			switch (stackItem)
            {
				case FilePos(s, file, line, column): errMsg += file + " (line " + line + ")\n";
				default: Sys.println(stackItem);
			}
		}

		errMsg += e.error;

		Sys.println(errMsg);

		Application.current.window.alert(errMsg, "Error!");
		Sys.exit(1);
    }
}