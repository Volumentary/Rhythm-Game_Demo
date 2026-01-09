package backend.assets;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

import openfl.media.Sound;
import openfl.text.Font;

import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFLAssets;

import openfl.utils.AssetType;

import cpp.vm.Gc as GarbageCollector;
import openfl.system.System;

import openfl.geom.Rectangle;
import lime.graphics.cairo.CairoImageSurface;

class Cacher 
{
    static var dumpExclusions:Array<String> = [];

    static var currentTextures:Map<String, FlxGraphic> = [];
	static var currentAudio:Map<String, Sound> = [];
    static var currentFonts:Map<String, Font> = [];
 
    static var previousTextures:Map<String, FlxGraphic> = [];
	static var previousAudio:Map<String, Sound> = [];
    static var previousFonts:Map<String, Font> = [];

    public static function clearGraphic(?graph:FlxGraphic)
    {
        if (graph == null) return;

        graph.persist = false;
		graph.destroyOnNoUse = true;

        @:privateAccess
			graph?.bitmap?.__texture?.dispose();

		graph.bitmap.dispose();
		graph.bitmap.disposeImage();
		graph.destroy();

		FlxG.bitmap.remove(graph);
    }

    @:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearBitmap(?key:String)
	{
		if (key == null) return;

		FlxG.bitmap.removeByKey(key);

		@:privateAccess
			FlxG.bitmap._cache.remove(key);

		OpenFLAssets.cache.clear(key);
        OpenFLAssets.cache.removeBitmapData(key);

        previousTextures.remove(key);
	}

    public static function preparePurge()
    {
        previousTextures = currentTextures;
		previousAudio = currentAudio;
        previousFonts = currentFonts;

    	currentTextures = [];
		currentAudio = [];
        currentFonts = [];
    }

    @:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
    public static function purge()
    {
        for (key in previousTextures.keys())
        {
			if (dumpExclusions.contains(key)) continue;

            var graph:FlxGraphic = previousTextures.get(key);
			if (graph == null) continue;

			clearGraphic(graph);
			clearBitmap(key);
        }

        for (key in previousAudio.keys())
        {
			if (dumpExclusions.contains(key)) continue;

            var sound = previousAudio.get(key);
			if (sound == null) continue;

			sound.close();
					
            OpenFLAssets.cache.clear(key);
            OpenFLAssets.cache.removeSound(key);

            previousAudio.remove(key);
        }

        for (key in previousFonts.keys())
        {
			if (dumpExclusions.contains(key)) continue;

            var font = previousFonts.get(key);
			if (font == null) continue;

            OpenFLAssets.cache.clear(key);
            OpenFLAssets.cache.removeFont(key);

            previousFonts.remove(key);
        }

        for (key in FlxG.bitmap._cache.keys())
		{
			if (previousTextures.exists(key) || dumpExclusions.contains(key)) continue;

			var graph = FlxG.bitmap.get(key);
			if (graph == null) continue;

			clearGraphic(graph);
			clearBitmap(key);
		}

        FlxG.bitmap.clearCache();
		FlxG.bitmap.clearUnused();
		FlxG.sound.destroy(true);

        GarbageCollector.enable(true);
        GarbageCollector.run(true);
        GarbageCollector.compact();

        System.gc();
    }

    public static function getGraphic(file:String, ?parent:String = 'images'):FlxGraphic
    {
        var ext:String = (!file.endsWith('.png') ? '.png' : '');
        var key:String = 'assets/$parent/$file$ext';

        if (!OpenFLAssets.exists(key, IMAGE)) 
		{
            Trc.log('$key does not exist in the assets folder.', WARNING);
		}

        if (currentTextures.exists(key)) 
		{
			return currentTextures.get(key);
		}

        if (previousTextures.exists(key))
        {
            var graphic = previousTextures.get(key);
            previousTextures.remove(key);

            currentTextures.set(key, graphic);
            return currentTextures.get(key);
        }

        var bitmap:BitmapData = BitmapData.fromFile(key);

        @:privateAccess
		{
			bitmap.width = bitmap.image.width;
			bitmap.height = bitmap.image.height;
	
			bitmap.__textureWidth = bitmap.width;
			bitmap.__textureHeight = bitmap.height;
	
			if (bitmap.image != null && bitmap.image.buffer != null) 
			{
				bitmap.rect = new Rectangle(0, 0, bitmap.image.width, bitmap.image.height);

				#if sys
				bitmap.image.format = BGRA32;
				bitmap.image.premultiplied = true;
				#end
	
				bitmap.__isValid = true;
				bitmap.readable = true;
	
				if (FlxG.stage.context3D != null) 
				{
					bitmap.lock();
					bitmap.getTexture(FlxG.stage.context3D);
                    
					if (bitmap.__surface == null)
						bitmap.__surface = CairoImageSurface.fromImage(bitmap.image);
	
					bitmap.readable = true;
					bitmap.image = null;
				}
			}
		}

        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
        graphic.persist = true;
        graphic.destroyOnNoUse = false;

        currentTextures.set(key, graphic);
        return graphic;
    }

    public static function getAudio(file:String, ?parent:String = 'audio'):Sound
    {
        var ext:String = (!file.endsWith('.ogg') ? '.ogg' : '');
        var key:String = 'assets/$parent/$file$ext';

        var sound:Sound = Sound.fromFile(key);

        currentAudio.set(key, sound);
        return sound;
    }

    public static function getFont(file:String):String
    {
        var key:String = 'assets/data/fonts/$file';

        if (OpenFLAssets.exists(key, FONT))
        {
            var font:Font = OpenFLAssets.getFont(key);
            currentFonts.set(key, font);

            return key;
        }

        return '';
    }
}