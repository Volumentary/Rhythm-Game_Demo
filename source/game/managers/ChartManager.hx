package game.managers;

typedef ChartFile =
{
    var notes:Array<ChartNote>;

    var skin:String;
    var speed:Float;
}

typedef ChartNote =
{
    var time:Float;
    var direction:Int;
}

class ChartManager
{
    var file:ChartFile;

    public var notes:Array<ChartNote>;

    public var skin:String;
    public var speed:Float;

    public function new(name:String)
    {   
        file = Paths.chart(name);

        notes = file.notes;

        skin = file.skin;
        speed = file.speed;
    }
}