plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hisgrace.drugshop"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.hisgrace.drugshop"
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        
        // For barcode scanning
        manifestPlaceholders = [
            'appAuthRedirectScheme': 'pharmacy'
        ]
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
            minifyEnabled true
            shrinkResources true
        }
        debug {
            minifyEnabled false
            shrinkResources false
            debuggable true
        }
    }
    
    // For large images and files
    packagingOptions {
        resources {
            excludes += ['META-INF/DEPENDENCIES', 'META-INF/LICENSE', 'META-INF/LICENSE.txt', 'META-INF/license.txt', 'META-INF/NOTICE', 'META-INF/NOTICE.txt', 'META-INF/notice.txt', 'META-INF/ASL2.0']
            pickFirsts += ['lib/*/libc++_shared.so', 'lib/*/libflutter.so']
        }
    }
    
    // For better performance
    dexOptions {
        preDexLibraries true
        javaMaxHeapSize "4g"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // For barcode scanning
    implementation 'com.google.mlkit:barcode-scanning:17.2.0'
    implementation 'com.google.android.gms:play-services-mlkit-barcode-scanning:18.3.0'
    
    // For camera
    implementation 'androidx.camera:camera-camera2:1.3.0'
    implementation 'androidx.camera:camera-lifecycle:1.3.0'
    implementation 'androidx.camera:camera-view:1.3.0'
    
    // For image picking and compression
    implementation 'com.github.bumptech.glide:glide:4.15.1'
    
    // For printing
    implementation 'androidx.print:print:1.0.0'
    
    // For file provider (camera and gallery)
    implementation 'androidx.documentfile:documentfile:1.0.1'
    
    // For multi-dex support
    implementation 'androidx.multidex:multidex:2.0.1'
    
    // For local storage and caching
    implementation 'com.squareup.okhttp3:okhttp:4.12.0'
    implementation 'com.squareup.okhttp3:logging-interceptor:4.12.0'
}