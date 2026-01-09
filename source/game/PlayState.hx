package game;

import game.managers.SongManager;
import game.managers.MetadataManager;
import game.managers.ChartManager;
import game.managers.PlayerDataManager;
import game.managers.InputManager;

import flixel.ui.FlxBar;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import game.notes.Note;
import game.notes.Receptorline;

/**
 * Gets the song name from the json file located in the data folder.
 */
typedef GameConfig =
{
    var song:String;
}

class PlayState extends MusicBeatState
{
    /**
     * An instance of this class. Used to access variables from here.
     */
    public static var instance:PlayState;

    /**
     * The config file. Used to get the song name.
     */
    public var config:GameConfig;

    /**
     * Checks if the player is still at the intro screen.
     */
    public var inIntro:Bool = true;

    /**
     * A manager containing the song itself.
     */
    public var song:SongManager;

    /**
     * A manager containing the song's metadata information. Used to store BPM information and more.
     */
    public var metadata:MetadataManager;

    /**
     * A manager containing the song's chart. The game reads that chart file and renders notes using milliseconds as positioning. When the song reaches said millisecond, you can hit said note for a perfect rating. The further away you are from that timing the worse your rating is.
     */
    public var chart:ChartManager;

    /**
     * A manager containing the player data. This consists of score, misses and accuracy.
     */
    public var playerData:PlayerDataManager;

    /**
     * Whether or not the conductor updates.
     */
    public var updateConductor:Bool = false;

    /**
     * A group containing each receptor. (They're skinned to look like arrows)
     */
    public var playerReceptors:Receptorline;

    /**
     * Checks if the player inputs are enabled.
     */
    public var enabledInputs(never, set):Bool;

    function set_enabledInputs(value:Bool):Bool
    {
        playerReceptors.inputs = value;
        return value;
    }

    /**
     * Lerp variables that ensure every time a value changes it does it with a smooth transition.
     */
    public var lerpScore:Float = 0;
    public var lerpAccuracy:Float = 0.00;
    public var lerpHealth:Float = 0;

    /**
     * The score & debug text fields.
     */
    public var scoreTxt:FlxText;
    public var debugInfo:FlxText;

    /**
     * The health bar, located on top of the screen.
     */
    public var healthBar:FlxBar;

    /**
     * A solid sprite used for fading out the screen.
     */
    public var solidOverlay:FlxSprite;

    /**
     * A sprite that renders the starting screen.
     */
    public var introPopup:FlxSprite;

    override public function create()
    {
        instance = this;
        config = Paths.json('game');

        InputManager.init();
        
        super.create();

        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF191919));

        setup_song();
        setup_receptors();
        setup_UI();

        solidOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        solidOverlay.alpha = 0;
        add(solidOverlay);

        introPopup = new FlxSprite().loadGraphic(Paths.image("ui/intro"));
        add(introPopup);
    }
    
    override public function destroy()
    {
        super.destroy();

        instance = null;

        InputManager.destroy();
        
        for (assets in [playerReceptors, scoreTxt, healthBar])
            assets.destroy();
    }

    function setup_song():Void
    {
        song = new SongManager(config.song);
        metadata = new MetadataManager(config.song);
        chart = new ChartManager(config.song);
        playerData = new PlayerDataManager(config.song);

        Conductor.setBPM(metadata.bpm);
        Conductor.update(0);
    }

    function setup_receptors():Void
    {
        playerReceptors = new Receptorline({chart: this.chart});
        add(playerReceptors);

        playerReceptors.onNoteHit.add(player_hit);
        playerReceptors.onNoteMiss.add(player_miss);

        enabledInputs = true;
    }

    function player_hit(note:Note):Void
    {
        playerReceptors.killNote(note);
        evaluateRating(Math.abs(note.time - Conductor.position));

        playerData.calculateAccuracy();
        playerReceptors.receptors.members[note.direction].playConfirm();
    }

    function player_miss(note:Note):Void
    {
        playerData.miss();
        playerData.calculateAccuracy();

        createJudgement("miss");

        if (playerData.health <= 0)
        {
            enabledInputs = false;

            song.audio.stop();
            Conductor.update(0);

            FlxTween.tween(solidOverlay, {alpha: 1}, 2, {ease: FlxEase.sineInOut, onComplete: function(t)
            {
                new FlxTimer().start(1, function(t) Sys.exit(0));
            }});
        }
    }

    function evaluateRating(ms:Float):Void
    {
        var rating:String = playerData.calculateRating(ms);
        playerData.judgeRating(rating);

        createJudgement(rating);
    }

    function createJudgement(rating:String)
    {
        var judgement = new FlxSprite().loadGraphic(Paths.image('ui/judgements/$rating'));
        judgement.screenCenter();
        add(judgement);

        judgement.scale.set(1.1, 1.1);
        FlxTween.tween(judgement.scale, {x: 1, y: 1}, 0.6, {ease: FlxEase.expoOut});
        FlxTween.tween(judgement, {alpha: 0}, 0.3, {ease: FlxEase.expoOut, startDelay: 0.2, onComplete: function(t) judgement.destroy()});
    }

    function start_song()
    {
        song.audio.play();
        song.audio.onComplete = end_song;
    }

    function end_song()
    {
        debugInfo.visible = false;
        enabledInputs = false;
        Conductor.update(0);

        FlxTween.tween(solidOverlay, {alpha: 1}, 2, {ease: FlxEase.sineInOut, onComplete: function(t)
        {
            new FlxTimer().start(1, function(t) Sys.exit(0));
        }});
    }

    function setup_UI()
    {
		scoreTxt = new FlxText(0, 0, FlxG.width, 'Score: 0 • Misses: 0 • Accuracy: 0.00%');
		scoreTxt.setFormat('Monsterrat', 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 1.5;
		scoreTxt.antialiasing = true;
		scoreTxt.screenCenter(X);
        scoreTxt.alpha = 0.5;
		scoreTxt.y = FlxG.height - scoreTxt.height - 20;
		add(scoreTxt);

        debugInfo = new FlxText(0, 0, FlxG.width, '');
		debugInfo.setFormat('Monsterrat', 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugInfo.borderSize = 1.5;
		debugInfo.antialiasing = true;
        debugInfo.alpha = 0.5;
        debugInfo.visible = false;
		add(debugInfo);

        healthBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 800, 10);
        healthBar.createFilledBar(0xFF4C4C4C, 0xFFB2B2B2);
        healthBar.numDivisions = 600;
        healthBar.value = 50;
        add(healthBar);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        handle_UI(elapsed);
        handle_song(elapsed);
    }

    function handle_UI(elapsed:Float)
    {
        lerpScore = MathUtil.framerateLerp(lerpScore, playerData.score, FlxMath.bound(elapsed * 30, 0, 1));
        lerpAccuracy = MathUtil.framerateLerp(lerpAccuracy, playerData.accuracy, FlxMath.bound(elapsed * 20, 0, 1));
        lerpHealth = MathUtil.framerateLerp(lerpHealth, FlxMath.remapToRange(playerData.health, Constants.MIN_HEALTH, Constants.MAX_HEALTH, 0, 100), FlxMath.bound(elapsed * 20, 0, 1));

        scoreTxt.text = 'Score: ${Math.round(lerpScore)} • Misses: ${playerData.misses} • Accuracy: ${FlxMath.roundDecimal(lerpAccuracy, 2)}%';
        healthBar.value = lerpHealth;

        if (FlxG.keys.justPressed.TAB)
            debugInfo.visible = !debugInfo.visible;

        debugInfo.text = '[NAME: "${metadata.name}"]\n[BPM: ${metadata.bpm}]\n[CURRENT TIME: ${Conductor.position}ms]\n[CURRENT MEASURE: ${curMeasure}]\n[CURRENT BEAT: ${curBeat}]\n[CURRENT STEP: ${curStep}]\n\n[NOTES RENDERED: ${playerReceptors.notes.members.length}]\n';
        debugInfo.screenCenter();

        if (inIntro && FlxG.keys.justPressed.ENTER)
        {
            introPopup.destroy();

            inIntro = false;
            updateConductor = true;

            start_song();

            var controlsPopup:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ui/controls"));
            controlsPopup.alpha = 0;
            add(controlsPopup);

            FlxTween.tween(controlsPopup, {alpha: 1}, 2, {ease: FlxEase.sineInOut, onComplete: function(t)
            {
                new FlxTimer().start(2, function(t) FlxTween.tween(controlsPopup, {alpha: 0}, 2, {ease: FlxEase.sineOut, onComplete: function(t) controlsPopup.destroy()}));
            }});
        }
    }

    function handle_song(elapsed:Float):Void
    {
        if (updateConductor)
        {
            Conductor.update(Conductor.position + elapsed * 1000);
        }
    }

    override function stepHit(step:Int):Void
	{
		super.stepHit(step);
	}

    override function beatHit(beat:Int):Void
	{
		super.beatHit(beat);
	}

    override function measureHit(measure:Int):Void
	{
		super.beatHit(measure);
	}

    override function openSubState(substate:FlxSubState)
	{
        persistentUpdate = false;

        song.pause();
        enabledInputs = false;

		super.openSubState(substate);
	}
}