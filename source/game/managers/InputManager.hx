package game.managers;

import openfl.events.KeyboardEvent;
import flixel.util.FlxSignal;

import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput;

class InputManager
{
    private static var controlArray:Array<Dynamic>;
    private static var loopFix:Array<Bool> = [false, false, false, false];

	public static var parsedHoldArray(get, never):Array<Bool>;

	static function get_parsedHoldArray():Array<Bool>
		return [check(Options.LEFT_NOTE), check(Options.DOWN_NOTE), check(Options.UP_NOTE), check(Options.RIGHT_NOTE)];

    public static var onPress(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public static var onRelease(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

    public static function init()
    {
        controlArray =
        [
			copy(Options.LEFT_NOTE),
			copy(Options.DOWN_NOTE),
			copy(Options.UP_NOTE),
			copy(Options.RIGHT_NOTE)
		];

        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, pressed);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, released);
    }

    public static function destroy()
    {
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, pressed);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, released);

        controlArray = [];
        loopFix = [false, false, false, false];

        onPress.removeAll();
		onRelease.removeAll();
    }

    private static function pressed(kEvent:KeyboardEvent)
    {
        var code:FlxKey = kEvent.keyCode;
        var key:Int = convert(code);

        if (key == -1) return;

        if(!loopFix[key])
		{
			loopFix[key] = true;
            onPress.dispatch(key);
		}
    }

    private static function released(kEvent:KeyboardEvent)
	{
		var code:FlxKey = kEvent.keyCode;
		var key:Int = convert(code);

        if (key == -1) return;

        if(loopFix[key])
		{
			loopFix[key] = false;
            onRelease.dispatch(key);
		}
	}

    public static function check(keys:Array<FlxKey>):Bool
        return FlxG.keys.checkStatus(keys[0], FlxInputState.PRESSED) || FlxG.keys.checkStatus(keys[1], FlxInputState.PRESSED);

    public static function copy(arrayToCopy:Array<FlxKey>):Array<FlxKey>
    {
        var copiedArray:Array<FlxKey> = arrayToCopy.copy();
        var i:Int = 0;
        var len:Int = copiedArray.length;

        while (i < len)
        {
            if(copiedArray[i] == NONE)
            {
                copiedArray.remove(NONE);
                --i;
            }
            i++;

            len = copiedArray.length;
        }
        return copiedArray;
    }

    public static function convert(key:FlxKey):Int
	{
		if(key != NONE)
            for (i in 0...controlArray.length)
                for (i2 in 0...controlArray[i].length)
                    if (key == controlArray[i][i2]) return i;

		return -1;
	}	
}