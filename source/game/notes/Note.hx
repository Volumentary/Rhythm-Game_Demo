package game.notes;

import flixel.util.FlxSort;

class Note extends FlxSprite
{
    public var time:Float = 0.0;
    public var speed:Float = 1.0;

    public var direction:Int = 0;

    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;

    public var lowPriority:Bool = false;

    public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1.0;

    public var generatedNote:Bool = false;

    public var distance:Float = 2000;

    public var type:String = "default";
    public var skin(default, set):NoteStyle;

    public function new(time:Float, direction:Int, skin:NoteStyle, speed:Float)
    {
        super(0, -9999);

        this.time = time;
        this.speed = speed;
        this.direction = direction;

        generate(skin);
    }

    function generate(skin:NoteStyle)
    {
        this.skin = skin;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (time > Conductor.position - Constants.SAFE_ZONE_OFFSET && (time < Conductor.position + (Constants.SAFE_ZONE_OFFSET * 0.5) || time < Conductor.position - (Constants.SAFE_ZONE_OFFSET * 0.5)))
            canBeHit = true;
        else
            canBeHit = false;

        if (time < Conductor.position - Constants.SAFE_ZONE_OFFSET && !wasGoodHit)
            tooLate = true;
    }

    public static function sortHitNotes(a:Note, b:Note):Int
    {
        if (a.lowPriority && !b.lowPriority)
            return 1;
        else if (!a.lowPriority && b.lowPriority)
            return -1;

        return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
    }

    function set_skin(value:NoteStyle):NoteStyle
    {
        if (skin == value) return skin;

        value.applyToNote(this);
        return skin = value;
    }
}