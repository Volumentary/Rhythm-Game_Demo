package game.notes;

abstract NoteStyle(String) from String to String
{
    public static var colorDirections:Array<String> = ['purple', 'blue', 'green', 'red'];
    public static var directions:Array<String> = ['left', 'down', 'up', 'right'];

    var antialiasing(get, never):Bool;
    var size(get, never):Float;

    public function applyToNote(note:Note)
    {
        applyAnimsToNote(note);
        applyPropertiesToNote(note);
    }
    
    function applyAnimsToNote(note:Note)
    {
        note.loadGraphic(Paths.image('skins/note_${this}'));
    }

    function applyPropertiesToNote(note:Note)
    {
        note.antialiasing = antialiasing;
        
        note.scale.set(size, size);
        note.updateHitbox();
    }

    public function applyToReceptor(receptor:Receptor)
    {
        applyAnimsToReceptor(receptor);
        applyPropertiesToReceptor(receptor);
    }

    function applyAnimsToReceptor(receptor:Receptor)
    {
        receptor.loadGraphic(Paths.image('skins/receptor_${this}'), true, 64, 64);

        receptor.animation.add('static', [0, 0], 1, true);
        receptor.animation.add('pressed', [1, 1], 1, true);
        receptor.animation.add('confirm', [2, 2], 1, true);
    }

    function applyPropertiesToReceptor(receptor:Receptor)
    {
        receptor.scale.set(size, size);
        receptor.updateHitbox();

        receptor.scrollFactor.set();
        receptor.antialiasing = antialiasing;
        
        receptor.animation.play('static');
        receptor.centerOffsets();
        receptor.centerOrigin();
    }

    function get_antialiasing():Bool
    {
        return switch (this.toLowerCase())
        {
            default: true;
        }
    }

	function get_size():Float
    {
        return switch (this.toLowerCase())
        {
            default: 1.5;
        }
    }
}