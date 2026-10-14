package mobile;

import haxe.io.Path;

class StorageUtil
{
	public static function getStorageDirectory():String
	{
		#if mobile
		return Path.addTrailingSlash(lime.system.System.applicationStorageDirectory);
		#elseif sys
		return Path.addTrailingSlash(Sys.getCwd());
		#else
		return "";
		#end
	}

	public static function getReplayDirectory():String
	{
		return getStorageDirectory() + "assets/replays/";
	}

	public static function init():Void
	{
		#if sys
		createDirectory(getReplayDirectory());
		#end
	}

	public static function createDirectory(path:String):Void
	{
		#if sys
		try
		{
			if (!sys.FileSystem.exists(path))
				sys.FileSystem.createDirectory(path);
		}
		catch (e:Dynamic) {}
		#end
	}
}
