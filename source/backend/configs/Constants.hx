package backend.configs;

class Constants
{
    public static final WINDOW_RESOLUTION:Array<Int> = [800, 600];

    public static final RESYNC_THRESHOLD:Int = 20;

    public static final RECEPTOR_WIDTH:Float = 150 * 0.7;
    public static final BASE_RECEPTORLINE_Y:Int = 50;

    public static var SAFE_ZONE_OFFSET:Float = (12 / 60) * 1000;
    public static var NOTE_KILL_THRESHOLD:Int = 180;

    public static final JUDGEMENT_MAP:Map<String, Array<Float>> =
    [
        "flawless" => [1.75, 400.0, 1.0],
        "perfect" => [1.5, 300.0, 1.0],
        "great" => [0.75, 100.0, 0.65],
        "good" => [0.0, 10.0, 0.2],
        "bad" => [-1.0, -50.0, -2.0],
    ];

    public static final RATING_MAP:Map<String, Int> =
    [
        "flawless" => 50,
        "perfect" => 70,
        "great" => 90,
        "good" => 110
    ];

    public static final MIN_HEALTH:Float = 0;
    public static final MAX_HEALTH:Float = 2;

    public static final MISS_HEALTH_LOSS:Float = 0.1;
    public static final MISS_SCORE_LOSS:Int = 40;
}