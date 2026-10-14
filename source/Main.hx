package;

import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var watermarks = true; // Whether to put Kade Engine literally anywhere

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{

		// quick checks 

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		#if (!cpp || mobile)
		framerate = 60;
		#end

		#if (cpp && !mobile)
		initialState = Caching;
		#end

		game = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		#if mobile
		mobile.TouchInput.init();
		#end

		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		 
		#end

		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);

		#if mobile
		scaleFPS();
		Lib.current.stage.addEventListener(Event.RESIZE, function(e:Event) scaleFPS());
		#end
		toggleFPS(FlxG.save.data.fps);
	}

	var game:FlxGame;

	var fpsCounter:FPS;

	#if mobile
	function scaleFPS():Void
	{
		if (fpsCounter == null)
			return;

		var scale:Float = Math.max(1, Lib.current.stage.stageHeight / 720);
		fpsCounter.scaleX = fpsCounter.scaleY = scale;
		fpsCounter.x = 10 * scale;
		fpsCounter.y = 3 * scale;
	}
	#end

	public function toggleFPS(fpsEnabled:Bool):Void {
		if (fpsCounter != null)
			fpsCounter.visible = fpsEnabled;
	}

	public function changeFPSColor(color:FlxColor)
	{
		if (fpsCounter != null)
			fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		#if !mobile
		openfl.Lib.current.stage.frameRate = cap;
		#end
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter != null ? fpsCounter.currentFPS : 0;
	}
}
