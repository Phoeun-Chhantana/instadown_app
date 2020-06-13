package kh.com.instadown_app

import android.annotation.TargetApi
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import android.view.ViewTreeObserver
import android.view.WindowManager

class MainActivity: FlutterActivity() {

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        //Remove full screen flag after load
        val vto = flutterView.viewTreeObserver
        vto.addOnGlobalLayoutListener {
            //TODO("Not yet implemented")
            flutterView.viewTreeObserver.removeOnGlobalLayoutListener {  }
            window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        }
    }
}