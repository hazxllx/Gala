# Firebase & Other Dependencies
-keep public class com.google.vending.licensing.ILicensingService
-keep public class com.android.vending.licensing.ILicensingService
-keep class androidx.lifecycle.DefaultLifecycleObserver
-keep class androidx.appcompat.app.AppCompatViewInflater
-keep class okhttp3.**
-keep class com.google.android.gms.common.internal.ReflectedParcelable
-keep class * implements com.google.firebase.components.ComponentRegistrar
-keep class androidx.versionedparcelable.VersionedParcelable
-keep class androidx.versionedparcelable.ParcelImpl

# Prevent ProGuard from removing classes with annotations that need to be kept
-keep @androidx.annotation.Keep class *

# Keep Firebase classes
-keep class com.google.firebase.** { *; }

# Keep FirebaseInstanceId (for messaging, etc.)
-keep class com.google.firebase.iid.FirebaseInstanceId { *; }
-keep class com.google.firebase.iid.FirebaseInstanceIdReceiver { *; }

# Keep FirebaseAuth (authentication-related classes)
-keep class com.google.firebase.auth.** { *; }

# Keep Firestore classes
-keep class com.google.firebase.firestore.** { *; }

# Keep Firebase Storage classes
-keep class com.google.firebase.storage.** { *; }

# Keep Firebase Crashlytics (if using)
-keep class com.google.firebase.crashlytics.** { *; }

# Keep Firebase Analytics (if using)
-keep class com.google.firebase.analytics.** { *; }

# Keep classes that are used in dynamic code loading or reflection (common with Firebase and Google Play Services)
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.messaging.** { *; }

# Keep classes for the Google Play Services libraries
-keep class com.google.android.gms.tasks.** { *; }

# Keep classes for Firebase performance (if using)
-keep class com.google.firebase.perf.** { *; }
