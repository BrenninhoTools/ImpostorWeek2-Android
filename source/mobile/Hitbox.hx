package mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

class Hitbox extends FlxSpriteGroup
{
	public static var laneColors:Array<FlxColor> = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];

	public static var arrowPositions:Array<Float> = [0.2, 0.34, 0.66, 0.8];

	public static function arrowX(index:Int):Float
	{
		return ScreenUtil.centeredX(ScreenUtil.BASE_WIDTH * arrowPositions[index]);
	}

	public var ownerState:FlxState;
	public var arrows(default, null):Bool = false;

	var lanes:Array<FlxSprite> = [];

	public function new(ownerState:FlxState)
	{
		super();

		this.ownerState = ownerState;

		var laneWidth:Int = Std.int(FlxG.width / 4);

		for (i in 0...4)
		{
			var lane:FlxSprite = FlxGradient.createGradientFlxSprite(laneWidth, FlxG.height, [FlxColor.TRANSPARENT, laneColors[i]], 1, 90);
			lane.x = laneWidth * i;
			lane.alpha = 0;
			lane.antialiasing = true;
			lanes.push(lane);
			add(lane);
		}

		scrollFactor.set();
		arrows = TouchInput.arrowsMode();
		TouchInput.hitbox = this;
	}

	public function laneAt(x:Float, y:Float):Int
	{
		if (arrows)
		{
			if (y < FlxG.height * 0.4)
				return -1;

			var closest:Int = 0;
			var closestDistance:Float = Math.POSITIVE_INFINITY;
			for (i in 0...arrowPositions.length)
			{
				var distance:Float = Math.abs(x - arrowX(i));
				if (distance < closestDistance)
				{
					closestDistance = distance;
					closest = i;
				}
			}
			return closest;
		}

		var lane:Int = Std.int(x / (FlxG.width / 4));
		if (lane < 0)
			lane = 0;
		if (lane > 3)
			lane = 3;
		return lane;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (i in 0...lanes.length)
		{
			var target:Float = (TouchInput.hitboxHeld[i] && !arrows && FlxG.save.data.invisibleHitbox != true) ? 0.35 : 0;
			lanes[i].alpha += (target - lanes[i].alpha) * Math.min(1, elapsed * 20);
		}
	}

	override public function destroy():Void
	{
		if (TouchInput.hitbox == this)
			TouchInput.hitbox = null;
		ownerState = null;
		lanes = null;
		super.destroy();
	}
}
