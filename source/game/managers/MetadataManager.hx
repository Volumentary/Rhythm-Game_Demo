package game.managers;

typedef MetaFile =
{
    var name:String;
    var bpm:Float;
}

class MetadataManager
{   
    public var file:MetaFile;

    public var name:String;
    public var bpm:Float;

    public function new(rawName:String)
    {
        file = Paths.json('metadata', 'songs/$rawName');

        name = file.name;
        bpm = file.bpm;
    }
}