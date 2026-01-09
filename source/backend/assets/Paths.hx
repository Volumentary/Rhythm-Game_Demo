package backend.assets;

import flixel.graphics.FlxGraphic;
import openfl.media.Sound;

import sys.FileSystem;
import openfl.utils.Assets;

import flixel.graphics.frames.FlxAtlasFrames;

import sys.io.File;

import haxe.Json;

class Paths
{
    public static function image(file:String, ?parent:String = 'images'):FlxGraphic
    {
        return Cacher.getGraphic(file, parent);
    }

    public static function audio(file:String, ?parent:String = 'audio'):Sound
    {
        return Cacher.getAudio(file, parent);
    }

    public static function font(file:String):String
    {
        return Cacher.getFont(file);
    }

    public static function data(file:String, ?parent:String = 'data'):String
    {
        return File.getContent('assets/$parent/$file');
    }

    public static function json(file:String, ?parent:String = 'data'):Dynamic
    {
        return cast Json.parse(data('$file.json', parent));
    }

    public static function song(song:String):Sound
    {
        return Cacher.getAudio('Song', 'songs/$song');
    }

    public static function chart(song:String):Dynamic
    {
        return json('chart', 'songs/$song');
    }

    public static function exists(path:String):Bool
    {
        return FileSystem.exists(path);
    }
}