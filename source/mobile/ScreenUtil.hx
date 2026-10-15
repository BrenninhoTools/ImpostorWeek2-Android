package mobile;

import flixel.FlxG;

class ScreenUtil
{
	public static inline var BASE_WIDTH:Int = 1280;
	public static inline var BASE_HEIGHT:Int = 720;
	public static inline var MAX_RATIO:Float = 20 / 9;

	#if android
	static var setFullJNI:Dynamic;
	static var getAspectRatioJNI:Dynamic;
	#end

	public static function isFull():Bool
	{
		return FlxG.save.data.screenStyle == 'full';
	}

	public static function deviceAspectRatio():Float
	{
		#if android
		try
		{
			if (getAspectRatioJNI == null)
				getAspectRatioJNI = lime.system.JNI.createStaticMethod("org/haxe/extension/ScreenStyle", "getAspectRatio", "()F");
			var ratio:Float = getAspectRatioJNI();
			if (ratio > 0)
				return ratio;
		}
		catch (e:Dynamic) {}
		#end

		var stageWidth:Float = FlxG.stage.stageWidth;
		var stageHeight:Float = FlxG.stage.stageHeight;
		if (stageWidth <= 0 || stageHeight <= 0)
			return BASE_WIDTH / BASE_HEIGHT;
		return Math.max(stageWidth, stageHeight) / Math.min(stageWidth, stageHeight);
	}

	public static function targetWidth():Int
	{
		if (!isFull())
			return BASE_WIDTH;

		var ratio:Float = Math.min(deviceAspectRatio(), MAX_RATIO);
		var width:Int = Math.round(BASE_HEIGHT * ratio);
		if (width % 2 != 0)
			width++;
		return width < BASE_WIDTH ? BASE_WIDTH : width;
	}

	public static function apply():Void
	{
		#if android
		try
		{
			if (setFullJNI == null)
				setFullJNI = lime.system.JNI.createStaticMethod("org/haxe/extension/ScreenStyle", "setFull", "(Z)V");
			setFullJNI(isFull());
		}
		catch (e:Dynamic) {}
		#end

		var width:Int = targetWidth();
		if (width == FlxG.width && FlxG.height == BASE_HEIGHT)
			return;

		@:privateAccess
		{
			FlxG.width = width;
			FlxG.height = BASE_HEIGHT;
		}

		FlxG.scaleMode.onMeasure(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		for (camera in FlxG.cameras.list)
		{
			camera.width = FlxG.width;
			camera.height = FlxG.height;
		}
	}

	public static function centeredX(baseX:Float):Float
	{
		return baseX + (FlxG.width - BASE_WIDTH) / 2;
	}
}
