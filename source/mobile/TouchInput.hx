package mobile;

import flixel.FlxG;
import flixel.FlxState;
import flixel.input.IFlxInputManager;
import flixel.math.FlxPoint;

class TouchInput implements IFlxInputManager
{
	public static var instance(default, null):TouchInput;

	public static var swipeUp(default, null):Bool = false;
	public static var swipeDown(default, null):Bool = false;
	public static var swipeLeft(default, null):Bool = false;
	public static var swipeRight(default, null):Bool = false;
	public static var tap(default, null):Bool = false;
	public static var backPressed(default, null):Bool = false;
	public static var pausePressed(default, null):Bool = false;

	public static var hitboxHeld(default, null):Array<Bool> = [false, false, false, false];
	public static var hitboxPressed(default, null):Array<Bool> = [false, false, false, false];
	public static var hitboxReleased(default, null):Array<Bool> = [false, false, false, false];

	public static var swipeThreshold:Float = 70;
	public static var tapMaxDuration:Int = 500;

	public static var buttons(default, null):Array<MobileButton> = [];
	public static var hitbox:Hitbox;

	var startPositions:Map<Int, FlxPoint> = new Map<Int, FlxPoint>();
	var startTimes:Map<Int, Int> = new Map<Int, Int>();
	var consumed:Array<Int> = [];

	public static function init():Void
	{
		if (instance != null)
			return;

		instance = new TouchInput();
		FlxG.inputs.addInput(instance);

		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
	}

	public static function topState():FlxState
	{
		var state:FlxState = FlxG.state;
		while (state != null && state.subState != null)
			state = state.subState;
		return state;
	}

	public static function registerButton(button:MobileButton):Void
	{
		if (!buttons.contains(button))
			buttons.push(button);
	}

	public static function unregisterButton(button:MobileButton):Void
	{
		buttons.remove(button);
	}

	public static function arrowsMode():Bool
	{
		return FlxG.save.data.hitboxMode == 'arrows';
	}

	public static function hitboxActive():Bool
	{
		return hitbox != null && hitbox.exists && hitbox.visible && hitbox.ownerState == topState();
	}

	function new() {}

	public function reset():Void
	{
		clearFrame();
		for (i in 0...4)
			hitboxHeld[i] = false;
		startPositions.clear();
		startTimes.clear();
		consumed = [];
	}

	function clearFrame():Void
	{
		swipeUp = swipeDown = swipeLeft = swipeRight = false;
		tap = backPressed = pausePressed = false;
		for (i in 0...4)
		{
			hitboxPressed[i] = false;
			hitboxReleased[i] = false;
		}
	}

	function update():Void
	{
		clearFrame();

		#if android
		if (FlxG.android.justReleased.BACK)
		{
			backPressed = true;
			pausePressed = true;
		}
		#end

		#if FLX_TOUCH
		var top:FlxState = topState();

		for (touch in FlxG.touches.list)
		{
			var id:Int = touch.touchPointID;

			if (touch.justPressed)
			{
				var button:MobileButton = buttonAt(touch, top);
				if (button != null)
				{
					consumed.push(id);
					button.press();
					switch (button.type)
					{
						case BACK:
							backPressed = true;
						case PAUSE:
							pausePressed = true;
					}
					continue;
				}

				startPositions.set(id, FlxPoint.get(touch.gameX, touch.gameY));
				startTimes.set(id, FlxG.game.ticks);
			}

			if (touch.justReleased)
			{
				if (consumed.remove(id))
					continue;

				var start:FlxPoint = startPositions.get(id);
				if (start != null)
				{
					var dx:Float = touch.gameX - start.x;
					var dy:Float = touch.gameY - start.y;
					var duration:Int = FlxG.game.ticks - startTimes.get(id);

					if (Math.max(Math.abs(dx), Math.abs(dy)) >= swipeThreshold)
					{
						if (Math.abs(dx) > Math.abs(dy))
						{
							if (dx > 0)
								swipeRight = true;
							else
								swipeLeft = true;
						}
						else
						{
							if (dy > 0)
								swipeDown = true;
							else
								swipeUp = true;
						}
					}
					else if (duration <= tapMaxDuration && !hitboxActive())
						tap = true;

					start.put();
					startPositions.remove(id);
					startTimes.remove(id);
				}
			}
		}

		var held:Array<Bool> = [false, false, false, false];

		if (hitboxActive())
		{
			for (touch in FlxG.touches.list)
			{
				if (!touch.pressed || consumed.contains(touch.touchPointID))
					continue;

				var lane:Int = hitbox.laneAt(touch.gameX, touch.gameY);
				if (lane >= 0)
					held[lane] = true;
			}
		}

		for (i in 0...4)
		{
			hitboxPressed[i] = held[i] && !hitboxHeld[i];
			hitboxReleased[i] = !held[i] && hitboxHeld[i];
			hitboxHeld[i] = held[i];
		}
		#end
	}

	#if FLX_TOUCH
	function buttonAt(touch:flixel.input.touch.FlxTouch, top:FlxState):MobileButton
	{
		for (button in buttons)
		{
			if (button == null || !button.exists || !button.visible || button.ownerState != top)
				continue;

			if (touch.overlaps(button, button.camera))
				return button;
		}
		return null;
	}
	#end

	function onFocus():Void {}

	function onFocusLost():Void
	{
		reset();
	}

	public function destroy():Void
	{
		reset();
	}
}
