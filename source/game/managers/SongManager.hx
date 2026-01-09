package game.managers;

import flixel.sound.FlxSound;

class SongManager
{
    public var name:String;

    public var audio:FlxSound;

    public function new(name:String)
    {
        Conductor.onStepHit.add(stepHit);

        this.name = name;

        init_audio();
    }

    public function init_audio()
    {
        if (Paths.exists('assets/songs/$name/Song.ogg'))
            audio = new FlxSound().loadEmbedded(Paths.song(name));
        else
            audio = new FlxSound();

        FlxG.sound.list.add(audio);
    }

    function stepHit(step:Int):Void
	{
		if (Math.abs(audio.time - Conductor.position) > Constants.RESYNC_THRESHOLD)
			Conductor.position = audio.time;
	}

    public function play():Void
    {
        audio.play();
    }

    public function pause():Void
    {
        audio.pause();
    }

    public function stop():Void
    {
        audio.stop();
    }
}