package backend.music;

import flixel.util.FlxSignal;

typedef BPMChangeEvent =
{
    var time:Float;
	var bpm:Float;

	var stepTime:Float;
    var beatTime:Float;
    var measureTime:Float;
}

class Conductor
{
    public static var bpm:Float = 100;
    public static var startingBpm(default, null):Float;

    public static var position:Float = 0;

    public static var curStep(default, null):Int = 0;
    public static var curBeat(default, null):Int = 0;
    public static var curMeasure(default, null):Int = 0;

    private static var canUpdateBeat:Bool;
	private static var canUpdateMeasure:Bool;

    public static var onStepHit(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public static var onBeatHit(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public static var onMeasureHit(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

    public static var onBPMChange(default, null):FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();

    private static var newStep:Int = 0;

    private static var currentBpmChange:BPMChangeEvent;

    private static var defaultBpmChange(get, never):BPMChangeEvent;

	static function get_defaultBpmChange():BPMChangeEvent
		return {stepTime: 0.0, beatTime: 0.0, measureTime: 0.0, time: 0.0, bpm: startingBpm};

	public static var curBpmChange(get, null):BPMChangeEvent;

	static function get_curBpmChange():BPMChangeEvent
		return curBpmChange ?? defaultBpmChange;

    public static var bpmChangeMap:Array<BPMChangeEvent> = [];

    public static var crochet(get, never):Float;

	static function get_crochet():Float
		return crochetOf(bpm);

    public static var stepCrochet(get, never):Float;

	static function get_stepCrochet():Float
		return stepCrochetOf(bpm);

	public static var measureLength(get, never):Float;

	static function get_measureLength():Float
		return measureLengthOf(bpm);

    public static function setBPM(value:Float):Void
	{
		startingBpm = value;
		bpm = value;
	}

    public static function changeBPM(value:Float):Void
    {
        bpm = value;
        onBPMChange.dispatch(bpm);
    }

    public static function reset():Void
	{
		curStep = curBeat = curMeasure = newStep = 0;
		position = 0.0;

        currentBpmChange = defaultBpmChange;
		onBPMChange.removeAll();
		bpmChangeMap = [];
	}

    public static function update(pos:Float):Void
	{
		position = pos;

		if (bpm <= 0.0) return;

        updateBpmChanges(pos - Options.OFFSETS);
        updateSteps(pos - Options.OFFSETS);
	}

    public static function updateBpmChanges(pos:Float):Void
    {
		currentBpmChange = defaultBpmChange;
		currentBpmChange = getChangeAtTime(pos);

		var newBPM:Float = currentBpmChange.bpm;
		if (newBPM <= 0.0 && newBPM == bpm) return;

		changeBPM(newBPM);
    }

    public static function updateSteps(pos:Float):Void
    {
		function updateStep(step:Int)
		{
			var deltaTime = pos - currentBpmChange.time;

			curStep = step;
			curBeat = Math.floor(currentBpmChange.beatTime + (deltaTime / crochet));
			curMeasure = Math.floor(currentBpmChange.measureTime + (deltaTime / measureLength));
		}

		var oldStep:Int = curStep;
		var oldBeat:Int = curBeat;
		var oldMeasure:Int = curMeasure;

		newStep = Math.floor(currentBpmChange.stepTime + ((pos - currentBpmChange.time) / stepCrochet));

		if (curStep != newStep)
		{
			if (newStep > curStep)
			{
				while (curStep < newStep)
				{
					updateStep(curStep + 1);

                    if (oldStep != curStep)
                        onStepHit.dispatch(curStep);

                    if (oldBeat != curBeat)
                        onBeatHit.dispatch(curBeat);

                    if (oldMeasure != curMeasure)
                        onMeasureHit.dispatch(curMeasure);

					oldStep = curStep;
					oldBeat = curBeat;
					oldMeasure = curMeasure;
				}
			}
			else
			{
				updateStep(newStep);
			}
		}
    }

    public static function getChangeAtTime(time:Float):BPMChangeEvent
	{
		var lastChange:BPMChangeEvent = defaultBpmChange;

		for (bpmChange in bpmChangeMap)
		{
			if (bpmChange.time < time)
				lastChange = bpmChange;

			if (bpmChange.time > time) break;
		}

		return lastChange;
	}

    public static inline function crochetOf(bpm:Float):Float
		return (60 / bpm) * 1000;

    public static inline function stepCrochetOf(bpm:Float):Float
		return crochetOf(bpm) / 4;

	public static inline function measureLengthOf(bpm:Float):Float
		return crochetOf(bpm) * 4;
}