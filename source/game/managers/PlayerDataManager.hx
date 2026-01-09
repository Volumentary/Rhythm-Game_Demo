package game.managers;

class PlayerDataManager
{
    public var song:String = "";
    public var validScore:Bool = true;

    public var score:Int = 0;
    public var misses:Int = 0;
    public var accuracy:Float = 0.00;
    public var health:Float = 1;
    public var combo:Int = 0;

    public var hitNotes:Float = 0;
    public var playedNotes:Int = 0;

    public var sicks:Int = 0;
    public var goods:Int = 0;
    public var bads:Int = 0;
    public var shits:Int = 0;

    public function new(song:String)
    {
        this.song = song;
        this.health = Constants.MAX_HEALTH / 2;
    }

    public function calculateRating(ms:Float):String
    {
        var rating:String = '';

        if (ms >= 0 && ms <= Constants.RATING_MAP.get('flawless'))
            rating = 'flawless';
		else if (ms > Constants.RATING_MAP.get('flawless') && ms <= Constants.RATING_MAP.get('perfect'))
            rating = 'perfect';
		else if (ms > Constants.RATING_MAP.get('perfect') && ms <= Constants.RATING_MAP.get('great'))
            rating = 'great';
        else if (ms > Constants.RATING_MAP.get('great') && ms <= Constants.RATING_MAP.get('good'))
            rating = 'good';
		else if (ms > Constants.RATING_MAP.get('good')) 
            rating = 'bad';

        return rating;
    }

    public function judgeRating(rating:String):Void
    {
        combo++;

        var map = Constants.JUDGEMENT_MAP.get(rating);

		score += Std.int(map[1]);
		health += map[0] / 100.0 * 2;
        hitNotes += map[2];
    }

    public function calculateAccuracy()
    {
        playedNotes++;
		accuracy = hitNotes / playedNotes * 100;
    }

    public function miss()
    {
        if (health <= 0)
        {
            health = 0;
            return;
        }

        combo = 0;

		health -= Constants.MISS_HEALTH_LOSS;
		score = Std.int(Math.max(0, score - Constants.MISS_SCORE_LOSS));

		misses++;
    }
}