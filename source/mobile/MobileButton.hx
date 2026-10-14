package mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

enum MobileButtonType
{
	BACK;
	PAUSE;
}

class MobileButton extends FlxSprite
{
	public static inline var MARGIN:Float = 20;

	public var type(default, null):MobileButtonType;
	public var ownerState:FlxState;

	public function new(type:MobileButtonType, ownerState:FlxState)
	{
		super();

		this.type = type;
		this.ownerState = ownerState;

		var name:String = type == BACK ? 'back' : 'pause';
		frames = Paths.getSparrowAtlas('mobile/${name}Button', 'shared');
		animation.addByIndices('idle', name, [0], "", 24, false);
		animation.addByPrefix('press', name, 24, false);
		animation.onFinish.add(function(anim:String)
		{
			if (anim == 'press')
				animation.play('idle', true);
		});
		animation.play('idle');

		antialiasing = true;
		scrollFactor.set();
		setGraphicSize(Std.int(frameWidth * (type == BACK ? 0.5 : 0.85)));
		updateHitbox();

		switch (type)
		{
			case BACK:
				setPosition(FlxG.width - width - MARGIN, FlxG.height - height - MARGIN);
			case PAUSE:
				setPosition(FlxG.width - width - MARGIN, MARGIN);
		}

		TouchInput.registerButton(this);
	}

	public function press():Void
	{
		animation.play('press', true);
	}

	public static function createCamera():FlxCamera
	{
		var camera:FlxCamera = new FlxCamera();
		camera.bgColor.alpha = 0;
		FlxG.cameras.add(camera, false);
		return camera;
	}

	override public function destroy():Void
	{
		TouchInput.unregisterButton(this);
		ownerState = null;
		super.destroy();
	}
}
