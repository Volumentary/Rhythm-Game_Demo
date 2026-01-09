package backend.music;

class MusicBeatState extends FlxState
{
    public var curStep(get, never):Int;
	
	function get_curStep():Int 
		return Conductor.curStep;

	public var curBeat(get, never):Int;

	function get_curBeat():Int 
		return Conductor.curBeat;

	public var curMeasure(get, never):Int;

	function get_curMeasure():Int 
		return Conductor.curMeasure;

    override function create():Void
	{
        Trc.log("State created.");

		super.create();

        Conductor.onStepHit.add(stepHit);
		Conductor.onBeatHit.add(beatHit);
		Conductor.onMeasureHit.add(measureHit);
	}

    override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

    public function stepHit(step:Int):Void {}
	public function beatHit(beat:Int):Void {}
	public function measureHit(measure:Int):Void {}
}