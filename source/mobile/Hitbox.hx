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

	public var ownerState:FlxState;

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
		TouchInput.hitbox = this;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (i in 0...lanes.length)
		{
			var target:Float = TouchInput.hitboxHeld[i] ? 0.35 : 0;
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
