package game.notes;

import flixel.group.FlxGroup;
import flixel.util.FlxSort;
import flixel.math.FlxMath;
import flixel.util.FlxSignal;
import flixel.math.FlxRect;

import game.managers.ChartManager;
import game.managers.InputManager;

typedef ReceptorlineParams =
{
	var chart:ChartManager;
}

class Receptorline extends FlxGroup
{
	public var speed:Float = 1.0;
	public var downscroll:Bool = false;
	public var chart:ChartManager;
	public var resetTimer:Array<FlxTimer> = [];
	public var inputs:Bool = true;
	
    public var skin(default, set):NoteStyle = "default";

	function set_skin(value:NoteStyle):NoteStyle
    {
		if (skin == value) return value;

		forEachReceptor((receptor:Receptor) -> {
			receptor.skin = value;
		});

		return skin = value;
	}

	public var unspawnNotes(default, null):Array<Note> = [];

	public var receptors(default, null):FlxTypedGroup<Receptor> = new FlxTypedGroup<Receptor>();
	public var notes(default, null):FlxTypedGroup<Note> = new FlxTypedGroup<Note>();

	public var onNoteHit(default, null):FlxTypedSignal<Note->Void> = new FlxTypedSignal<Note->Void>();
	public var onEnemyHit(default, null):FlxTypedSignal<Note->Void> = new FlxTypedSignal<Note->Void>();
	public var onNoteMiss(default, null):FlxTypedSignal<Note->Void> = new FlxTypedSignal<Note->Void>();

	public function new(params:ReceptorlineParams)
    {
        super();

		chart = params.chart;
		skin = chart.skin;

		InputManager.onPress.add(pressed);
		InputManager.onRelease.add(released);

        add(receptors);
		add(notes);

		generateReceptors();
		generateNotes();
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		handle_spawning();

		update_notes();
	}

	override function destroy()
	{
		onNoteMiss?.removeAll();
		onNoteMiss = null;

		onNoteHit?.removeAll();
		onNoteHit = null;

		receptors?.destroy();
		receptors?.clear();

		notes?.destroy();
		notes?.clear();

		for (note in unspawnNotes)
		{
			note?.destroy();
		}
		
		unspawnNotes.resize(0);
		unspawnNotes = [];

		super.destroy();
	}

	function pressed(dir:Int)
	{
		if (!inputs) return;

		receptors.members[dir].playPress();

		var pressNotes:Array<Note> = [];
		var notesStopped:Bool = false;
		var sortedNotesList:Array<Note> = [];

		forEachNote(function(note:Note) 
		{	
			if (note.canBeHit && !note.tooLate && !note.wasGoodHit)
				if (note.direction == dir) sortedNotesList.push(note);
		});

		sortedNotesList.sort(Note.sortHitNotes);

		if (sortedNotesList.length > 0)
		{
			for (sNote in sortedNotesList) 
			{
				for (doubleNote in pressNotes) 
				{
					if (Math.abs(doubleNote.time - sNote.time) < 1) 
						killNote(doubleNote);
					else
						notesStopped = true;
				}

				if (!notesStopped) 
				{
					onNoteHit.dispatch(sNote);
					pressNotes.push(sNote);
				}
			}
		}
	}

	function released(dir:Int)
	{
		if (!inputs) return;

		receptors.members[dir].playStatic();
	}

	function handle_spawning() 
	{
		while (unspawnNotes[0] != null && unspawnNotes[0].time - Conductor.position < 2000) 
		{
			var dunceNote:Note = unspawnNotes[0];
			dunceNote.generatedNote = true;

			notes.add(dunceNote);

			forEachGroup(function(group:FlxTypedGroup<Note>) {
				group.sort(FlxSort.byY, downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
			});

			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.splice(index, 1);
		}
	}

	function update_notes() 
	{
		forEachNote(function(note:Note)
		{
			note.active = true;
			note.visible = true;

			var receptorX:Float = receptors.members[note.direction].x;
			var receptorY:Float = receptors.members[note.direction].y;
			
			note.distance = (-0.45 * (Conductor.position - note.time) * speed);

			note.x = ((receptorX + Math.cos(90 * Math.PI / 180) * 2000));
			note.y = ((receptorY + Math.sin(90 * Math.PI / 180) * note.distance));
			note.alpha = receptors.members[note.direction].alpha;
			note.angle = receptors.members[note.direction].angle;

			if (Conductor.position > Constants.NOTE_KILL_THRESHOLD + note.time) 
			{
				if (!note.wasGoodHit)
					onNoteMiss.dispatch(note);

				killNote(note);
			}
		});
	}

	public function killNote(note:Note) 
	{
		notes.remove(note, true);

		note.kill();
		note.destroy();
	}

	public function generateReceptors() 
    {
        for (i in 0...4) 
		{
			var arrow:Receptor = new Receptor(i, skin);
			arrow.x += i * (Constants.RECEPTOR_WIDTH);
			arrow.y = Constants.BASE_RECEPTORLINE_Y;
			arrow.ID = i;
			receptors.add(arrow);

			switch (i)
			{
				case 0:
					arrow.angle = 90;
				case 1:
					arrow.angle = 0;
				case 2:
					arrow.angle = 180;
				case 3:
					arrow.angle = -90;
			}
		}

        var minX:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;

		for (arrow in receptors.members) 
		{
			if (arrow.x < minX)
				minX = arrow.x;
			if (arrow.x + arrow.width > maxX)
				maxX = arrow.x + arrow.width;
		}

		var totalWidth:Float = maxX - minX;
		var offsetX:Float = (FlxG.width - totalWidth) / 2 - minX;
        
		for (arrow in receptors.members) arrow.x += offsetX;
    }

	public function generateNotes() 
	{
		speed = chart.speed;

		for (direction in chart.notes)
		{
			var time:Float = direction.time;
			var id:Int = direction.direction;

			var swagNote:Note = new Note(time, id, skin, speed);
			unspawnNotes.push(swagNote);
		}

		function sortByReceptorTime(a:Note, b:Note):Int
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
		}

		unspawnNotes.sort(sortByReceptorTime);
	}

	public function forEachGroup(func:FlxTypedGroup<Note>->Void) 
	{
		for (group in [notes])
			func(group);
	}

	public function forEachNote(func:Note->Void) 
	{
		forEachGroup(function(group:FlxTypedGroup<Note>) 
		{
			for (i in group.members) 
			{
				if (i == null || !i.alive) continue;
				func(i);
			}
		});
	}

	public function forEachReceptor(func:Receptor->Void)
	{
		for (receptor in receptors.members) 
		{
			if (receptor == null) continue;
			func(receptor);
		}
	}
}