// Imports global libraries that can be used in every class. Use with caution as it can increase compilation times.

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.FlxState;
import flixel.FlxSubState;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

import flixel.text.FlxText;

import flixel.math.FlxMath;

import backend.configs.Constants;
import backend.configs.Options;

import backend.assets.Paths;
import backend.assets.Cacher;

import backend.utils.TraceUtil as Trc;
import backend.utils.TraceUtil.TraceType;
import backend.utils.MathUtil;

import backend.music.MusicBeatState;
import backend.music.Conductor;

import game.PlayState;

using StringTools;