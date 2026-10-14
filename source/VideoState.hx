package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
#if hxvlc
import hxvlc.flixel.FlxVideoSprite;
#end

class VideoState extends MusicBeatState
{
	public var leSource:String = "";
	public var transClass:FlxState;

	var finished:Bool = false;
	var previousVolume:Float = 1;

	#if hxvlc
	var video:FlxVideoSprite;
	#end

	public function new(source:String, toTrans:FlxState, frameSkipLimit:Int = -1, autopause:Bool = false)
	{
		super();

		leSource = source;
		transClass = toTrans;
	}

	override function create()
	{
		super.create();

		FlxG.autoPause = false;

		if (FlxG.sound.music != null)
		{
			previousVolume = FlxG.sound.music.volume;
			FlxG.sound.music.pause();
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);

		#if hxvlc
		video = new FlxVideoSprite();
		video.antialiasing = true;
		video.bitmap.onFormatSetup.add(function()
		{
			video.setGraphicSize(FlxG.width, FlxG.height);
			video.updateHitbox();
			video.screenCenter();
		});
		video.bitmap.onEndReached.add(finishVideo);
		video.bitmap.onEncounteredError.add(function(message:String)
		{
			finishVideo();
		});
		add(video);

		if (video.load(leSource))
			video.play();
		else
			finished = true;
		#else
		finished = true;
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (finished)
		{
			goToNextState();
			return;
		}

		if (controls.ACCEPT)
			finishVideo();
	}

	function finishVideo()
	{
		finished = true;
	}

	var switched:Bool = false;

	function goToNextState()
	{
		if (switched)
			return;

		switched = true;

		#if hxvlc
		if (video != null)
		{
			video.stop();
			remove(video);
			video.destroy();
			video = null;
		}
		#end

		if (FlxG.sound.music != null)
			FlxG.sound.music.volume = previousVolume;

		FlxG.autoPause = true;
		FlxG.switchState(transClass);
	}
}
