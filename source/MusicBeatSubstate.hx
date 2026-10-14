package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		//everyStep();
		var nextStep = updateCurStep();

		if (nextStep >= 0)
		{
			if (nextStep > curStep)
			{
				for (i in curStep...nextStep)
				{
					curStep++;
					updateBeat();
					stepHit();
				}
			}
			else if (nextStep < curStep)
			{
				//Song reset?
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}

		super.update(elapsed);
	}

	#if mobile
	public var mobileCamera:flixel.FlxCamera;
	public var backButton:mobile.MobileButton;
	public var pauseButton:mobile.MobileButton;

	public function getMobileCamera():flixel.FlxCamera
	{
		if (mobileCamera == null)
			mobileCamera = mobile.MobileButton.createCamera();
		return mobileCamera;
	}

	public function addBackButton():mobile.MobileButton
	{
		if (backButton == null)
		{
			backButton = new mobile.MobileButton(BACK, this);
			backButton.cameras = [getMobileCamera()];
			add(backButton);
		}
		return backButton;
	}

	public function addPauseButton():mobile.MobileButton
	{
		if (pauseButton == null)
		{
			pauseButton = new mobile.MobileButton(PAUSE, this);
			pauseButton.cameras = [getMobileCamera()];
			add(pauseButton);
		}
		return pauseButton;
	}
	#end

	override function destroy()
	{
		#if mobile
		if (mobileCamera != null && FlxG.cameras.list.contains(mobileCamera))
			FlxG.cameras.remove(mobileCamera);
		mobileCamera = null;
		backButton = null;
		pauseButton = null;
		#end

		super.destroy();
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
