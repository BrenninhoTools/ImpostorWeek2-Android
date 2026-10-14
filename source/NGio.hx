package;

import flixel.util.FlxSignal;
import lime.app.Application;

class NGio
{
	public static var isLoggedIn:Bool = false;
	public static var scoreboardsLoaded:Bool = false;

	public static var ngDataLoaded(default, null):FlxSignal = new FlxSignal();
	public static var ngScoresLoaded(default, null):FlxSignal = new FlxSignal();

	public static var GAME_VER:String = "";
	public static var GAME_VER_NUMS:String = '';
	public static var gotOnlineVer:Bool = false;

	public static function noLogin(api:String)
	{
		GAME_VER = "v" + Application.current.meta.get('version');
	}

	public function new(api:String, encKey:String, ?sessionId:String)
	{
		GAME_VER = "v" + Application.current.meta.get('version');
	}

	public static function postScore(score:Int = 0, song:String) {}

	public static function logEvent(event:String) {}

	public static function unlockMedal(id:Int) {}
}
