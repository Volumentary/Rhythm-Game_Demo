package game.notes;

class Receptor extends FlxSprite
{
    public var direction:Int;

    public var skin(default, set):NoteStyle;

    function set_skin(value:NoteStyle):NoteStyle
    {
        if (skin == value) return skin;

        value.applyToReceptor(this);

        return skin = value;
    }

    public function new(data:Int, skin:NoteStyle)
    {
        super();

        this.direction = data;
        this.skin = skin;
    }

    public function animPlay(anim:String, ?force:Bool = true)
    {
        animation.play(anim, force);
        centerOffsets();
        centerOrigin();
    }

    public function playStatic(force:Bool = true)
    {
        animPlay('static', true);
    }

    public function playPress(force:Bool = true)
    {
        animPlay('pressed', true);
    }

    public function playConfirm(force:Bool = true)
    {
        animPlay('confirm', true);
    }
}