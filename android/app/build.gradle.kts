plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Tên gói ứng dụng của bạn
    namespace = "com.example.ung_dung_nghe_nhac_online"
    
    // Ép sử dụng SDK 34 để tránh lỗi tải SDK 35 thất bại
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.ung_dung_nghe_nhac_online"
        
        // minSdk 21 giúp hỗ trợ hầu hết các điện thoại Android hiện nay
        minSdk = flutter.minSdkVersion 
        
        // Ép target về 34 để khớp với môi trường Android Studio của bạn
        targetSdk = 34
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
