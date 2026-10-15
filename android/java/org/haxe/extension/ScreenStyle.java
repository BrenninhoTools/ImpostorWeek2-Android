package org.haxe.extension;

import android.os.Build;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

public class ScreenStyle extends Extension {

	private static boolean full = false;

	public static void setFull(boolean value) {

		full = value;

		if (mainActivity == null) {
			return;
		}

		mainActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				apply();
			}
		});

	}

	public static float getAspectRatio() {

		if (mainActivity == null) {
			return 16f / 9f;
		}

		DisplayMetrics metrics = new DisplayMetrics();
		mainActivity.getWindowManager().getDefaultDisplay().getRealMetrics(metrics);

		float longSide = Math.max(metrics.widthPixels, metrics.heightPixels);
		float shortSide = Math.min(metrics.widthPixels, metrics.heightPixels);

		if (shortSide <= 0) {
			return 16f / 9f;
		}

		return longSide / shortSide;

	}

	private static void apply() {

		if (mainActivity == null) {
			return;
		}

		Window window = mainActivity.getWindow();

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
			WindowManager.LayoutParams params = window.getAttributes();
			params.layoutInDisplayCutoutMode = full
				? WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
				: WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT;
			window.setAttributes(params);
		}

		window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
		window.getDecorView().setSystemUiVisibility(
			View.SYSTEM_UI_FLAG_LAYOUT_STABLE
			| View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
			| View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
			| View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
			| View.SYSTEM_UI_FLAG_FULLSCREEN
			| View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
		);

	}

	@Override
	public void onResume() {

		apply();

	}

}
