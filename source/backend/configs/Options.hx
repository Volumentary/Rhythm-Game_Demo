package backend.configs;

import flixel.input.keyboard.FlxKey;

class Options 
{
    public static var FRAMERATE:Int = 120;

    public static var OFFSETS:Int = 0;

    public static var LEFT_NOTE:Array<FlxKey> = [FlxKey.D, FlxKey.LEFT];
	public static var DOWN_NOTE:Array<FlxKey> = [FlxKey.F, FlxKey.DOWN];
	public static var UP_NOTE:Array<FlxKey> = [FlxKey.J, FlxKey.UP];
	public static var RIGHT_NOTE:Array<FlxKey> = [FlxKey.K, FlxKey.RIGHT];
}