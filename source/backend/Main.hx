package backend;

import openfl.display.Sprite;
import lime.app.Application;
import flixel.FlxGame;

import backend.CrashHandler;

using StringTools;

class Main extends Sprite
{
	public var window:FlxGame;

	public function new()
	{
		super();

		window = new FlxGame(Constants.WINDOW_RESOLUTION[0], Constants.WINDOW_RESOLUTION[1], game.PlayState, Options.FRAMERATE, Options.FRAMERATE, true, false);
		addChild(window);

		configurate();
		setupSignals();
	}

	public function configurate()
	{
		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;

		CrashHandler.setup();
	}

	public function setupSignals()
	{
		FlxG.signals.preStateSwitch.add(function()
        {
            Cacher.preparePurge();
            Cacher.purge();
        });
	}
}