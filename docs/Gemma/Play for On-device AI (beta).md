# **[Play for On-device AI (beta)]{.underline}**

## **[Introduction]{.underline}**

[Play for On-device AI brings the benefits of [Android App
Bundles](https://developer.android.com/guide/app-bundle) and Google Play
delivery to custom ML model distribution so you can improve model
performance with less device ecosystem complexity at no additional cost.
It lets you publish a single artifact to Play containing your code,
assets, and ML models and to choose from a number of delivery modes and
targeting options.]{.underline}

### [Benefits]{.underline}

-   [Upload a single publishing artifact to Google Play and delegate
    > hosting, delivery, updates, and targeting to Play at no additional
    > cost.]{.underline}

-   [Deliver your ML models at install-time, fast-follow, or
    > on-demand.]{.underline}

    -   [Install-time delivery can guarantee that a very large model is
        > present when your app is opened. Your model will be installed
        > as an APK.]{.underline}

    -   [Fast-follow delivery occurs automatically in the background
        > after your app has been installed. Users may open your app
        > before your model has been fully downloaded. Your model will
        > be downloaded to your app\'s internal storage
        > space.]{.underline}

    -   [On-demand delivery lets you request the model at runtime, which
        > is useful if the model is only required for certain
        > user-flows. Your model will be downloaded to your app\'s
        > internal storage space.]{.underline}

-   [Deliver variants of your ML models that are targeted to specific
    > devices based on device model, system properties, or
    > RAM.]{.underline}

-   [Keep app updates small and optimized with Play\'s automatic
    > patching, which means only the differences in files need to be
    > downloaded.]{.underline}

### [Considerations]{.underline}

-   [By using Play for On-device AI you agree to the terms in the
    > [Google Play Developer Distribution
    > Agreement](https://play.google.com/about/developer-distribution-agreement.html)
    > and the [Play Core Software Development Kit Terms of
    > Service](https://developer.android.com/guide/playcore#license).]{.underline}

-   [Models downloaded by Play for On-device AI should only be used by
    > your apps. Models shouldn\'t be offered to other
    > apps.]{.underline}

-   [Individual AI packs can be up to 1.5GB, based on their compressed
    > download sizes. The maximum cumulative app size of any version of
    > your app generated from your app bundle is 4GB.]{.underline}

-   [Apps over 1GB in size must set min SDK Level to 21 or
    > higher.]{.underline}

### [How to use Play for On-device AI]{.underline}

[Play for On-device AI uses AI packs. You package custom models that are
ready for distribution in AI packs in your app bundle. You can choose
whether the AI pack should be delivered at install-time, fast-follow, or
on-demand.]{.underline}

[By packaging AI packs with your app bundle, you can use all of Play\'s
existing testing and release tools, such as test tracks and staged
rollouts to manage your app\'s distribution with your custom
models.]{.underline}

[AI packs are updated together with the app binary. If your new app
release doesn\'t make changes to an AI pack, then Play\'s automatic
patching process will ensure the user doesn\'t have to re-download it.
Play will just download what\'s changed when it updates the
app.]{.underline}

[AI packs only contain models. Java/Kotlin and native libraries are not
allowed. If you need to ship libraries or code to run your ML model,
move it into the base module or a [feature
module](https://developer.android.com/guide/playcore/feature-delivery).
You can configure your feature module so that it has the same download
and targeting settings as the AI pack.]{.underline}

[**Note:** AI packs don\'t contain Java/Kotlin or native libraries. You
can ship libraries or code to run your ML models in [feature
modules](https://developer.android.com/guide/playcore/feature-delivery).]{.underline}

### [Use LiteRT and MediaPipe with AI packs]{.underline}

[You can use LiteRT and MediaPipe with AI packs. Package your model in
an AI pack and then access it using the instructions for [install-time
packs](https://developer.android.com/google/play/on-device-ai#install-time-delivery)
or for [fast-follow and on-demand
packs](https://developer.android.com/google/play/on-device-ai#ff-od-delivery).]{.underline}

[Further reading:]{.underline}

-   [[Getting started with
    > LiteRT]{.underline}](https://ai.google.dev/edge/litert/android)

    -   [The [sample
        > app](https://developer.android.com/google/play/on-device-ai#example-app)
        > shows how you can package a LiteRT model in an AI pack and
        > load it at runtime.]{.underline}

    -   [There are many [pretrained LiteRT
        > models](https://ai.google.dev/edge/litert/models/trained) that
        > you can use in AI packs to get started.]{.underline}

-   [[Getting started with
    > MediaPipe]{.underline}](https://ai.google.dev/edge/mediapipe/framework/getting_started/android)

    -   [For fast-follow and on-demand packs, you can use
        > [AssetCache.java](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/java/com/google/mediapipe/framework/AssetCache.java)
        > to load your assets (eg. .binarypb files) by their file
        > paths.]{.underline}

    -   [For install-time packs, you can use
        > [AndroidAssetUtil.java](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/java/com/google/mediapipe/framework/AndroidAssetUtil.java#L56).]{.underline}

## **[Get started with AI packs]{.underline}**

[At a high level, here\'s how you can start using Play for On-device
AI:]{.underline}

1.  [Package your models into AI packs into your Android App Bundle and
    > specify how the AI packs should be delivered.]{.underline}

2.  [\[Optional\] If you want to deliver different models to different
    > devices, you can [configure device
    > targeting](https://developer.android.com/google/play/on-device-ai#device-targeting-configuration)
    > for your AI packs. For example, you could deliver AI pack A to a
    > specific device model, AI pack B to devices with at least 6GB of
    > RAM, and all other devices could receive no model.]{.underline}

3.  [\[Optional\] If you\'re using on-demand or fast-follow delivery,
    > integrate the Play AI Delivery Library into your app to download
    > your AI packs as needed.]{.underline}

4.  [Test and release your app bundle to Google Play.]{.underline}

### [Check Android Gradle Plugin version]{.underline}

[To use AI packs, ensure that your Android Gradle Plugin (AGP) version
is at least 8.8. This version is packaged with Android Studio Ladybug
2.]{.underline}

### [Extract your model into an AI pack]{.underline}

[Android Studio is not required for the following steps.]{.underline}

1.  [In the top-level directory of your project, create a directory for
    > the AI pack. This directory name is used as the AI pack name. AI
    > pack names must start with a letter and can only contain letters,
    > numbers, and underscores.]{.underline}

2.  [In the AI pack directory, create a build.gradle file and add the
    > following code. Make sure to specify the name of the AI pack and
    > only one delivery type:]{.underline}

[// In the AI pack\'s build.gradle file:]{.underline}

[plugins {]{.underline}

[id \'com.android.ai-pack\']{.underline}

[}]{.underline}

[aiPack {]{.underline}

[packName = \"ai-pack-name\" // Directory name for the AI
pack]{.underline}

[dynamicDelivery {]{.underline}

[deliveryType = \"\[ install-time \| fast-follow \| on-demand
\]\"]{.underline}

[}]{.underline}

[}]{.underline}

3.  

4.  [In the project\'s app build.gradle file, add the name of every AI
    > pack in your project as shown below:]{.underline}

[// In the app build.gradle file:]{.underline}

[android {]{.underline}

[\...]{.underline}

[assetPacks = \[\":ai-pack-name\", \":ai-pack2-name\"\]]{.underline}

[}]{.underline}

5.  

6.  [In the project\'s settings.gradle file, include all AI packs in
    > your project as shown below:]{.underline}

[// In the settings.gradle file:]{.underline}

[include \':app\']{.underline}

[include \':ai-pack-name\']{.underline}

[include \':ai-pack2-name\']{.underline}

7.  

8.  [Inside your AI pack, create a src/main/assets/
    > directory.]{.underline}

9.  [Place your models in the src/main/assets directory. You can create
    > subdirectories in here as well. The directory structure for your
    > app should now look like the following:]{.underline}

    -   [build.gradle]{.underline}

    -   [settings.gradle]{.underline}

    -   [app/]{.underline}

    -   [ai-pack-name/build.gradle]{.underline}

    -   [ai-pack-name/src/main/assets/your-model-directories]{.underline}

10. [Add code to load and run your models. How you do this will depend
    > on the delivery mode of your AI packs. See instructions for
    > [install-time](https://developer.android.com/google/play/on-device-ai#install-time-delivery)
    > and
    > [fast-follow/on-demand](https://developer.android.com/google/play/on-device-ai#ff-od-delivery)
    > below.]{.underline}

11. [\[Optional\] [Configure device
    > targeting](https://developer.android.com/google/play/on-device-ai#device-targeting-configuration)
    > to deliver different models to different devices.]{.underline}

12. [[Build the Android App Bundle with
    > Gradle](https://developer.android.com/studio/build/building-cmdline#build_bundle).
    > In the generated app bundle, the root-level directory now includes
    > the following:]{.underline}

    -   [ai-pack-name/manifest/AndroidManifest.xml: Configures the AI
        > pack\'s identifier and delivery mode]{.underline}

    -   [ai-pack-name/assets/your-model-directories: Directory that
        > contains all assets delivered as part of the AI
        > pack]{.underline}

13. [Gradle generates the manifest for each AI pack and outputs the
    > assets/ directory for you.]{.underline}

### [Configure install-time delivery]{.underline}

[AI packs configured as install-time are immediately available at app
launch. Use the Java AssetManager API to access AI packs served in this
mode:]{.underline}

[import android.content.res.AssetManager;]{.underline}

[\...]{.underline}

[Context context = createPackageContext(\"*com.example.app*\",
0);]{.underline}

[AssetManager assetManager = context.getAssets();]{.underline}

[InputStream is = assetManager.open(\"*model-name*\");]{.underline}

### [Configure fast-follow and on-demand delivery]{.underline}

[To download AI packs with fast-follow or on-demand delivery, use the
Play AI Delivery Library.]{.underline}

#### [Declare dependency on the Play AI Delivery Library]{.underline}

[In your app\'s build.gradle file, declare a dependency on the Play AI
Delivery Library:]{.underline}

[dependencies {]{.underline}

[\...]{.underline}

[implementation
\"com.google.android.play:ai-delivery:0.1.1-alpha01\"]{.underline}

[}]{.underline}

#### [Check status]{.underline}

[Each AI pack is stored in a separate folder in the app\'s internal
storage. Use the
[getPackLocation()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#getPackLocation(java.lang.String))
method to determine the root folder of an AI pack. This method returns
the following values:]{.underline}

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [Return value]{.underline}                                                                                      [Status]{.underline}
  --------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------------
  [A valid                                                                                                        [AI pack root folder is ready for immediate access at
  [AiPackLocation](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackLocation)   [assetsPath()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackLocation#assetsPath)]{.underline}
  object]{.underline}                                                                                             

  [null]{.underline}                                                                                              [Unknown AI pack or AI packs are not available]{.underline}
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

[**Note:** Don\'t rely on cached AI pack locations between app launches.
The app should always check for the existence of AI packs at every
launch. AI packs may become invalid due to app updates or if the user
clears the app data.]{.underline}

#### [Get download information about AI packs]{.underline}

[Use the\
[getPackStates()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#getPackStates(java.util.List%3Cjava.lang.String%3E))
method to determine the size of the download and whether the pack is
already downloading.]{.underline}

[Task\<AiPackStates\> getPackStates(List\<String\>
packNames)]{.underline}

[getPackStates() is an asynchronous method that returns a
Task\<AiPackStates\>. The
[packStates()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackStates#packStates())
method of an AiPackStates object returns a Map\<String, AiPackState\>.
This map contains the state of each requested AI pack, keyed by its
name:]{.underline}

[Map\<String, AiPackState\> AiPackStates#packStates()]{.underline}

[The final request is shown by the following:]{.underline}

[final String aiPackName = \"*myAiPackName*\";]{.underline}

[aiPackManager]{.underline}

[.getPackStates(Collections.singletonList(aiPackName))]{.underline}

[.addOnCompleteListener(new OnCompleteListener\<AiPackStates\>()
{]{.underline}

[\@Override]{.underline}

[public void onComplete(Task\<AiPackStates\> task) {]{.underline}

[AiPackStates aiPackStates;]{.underline}

[try {]{.underline}

[aiPackStates = task.getResult();]{.underline}

[AiPackState aiPackState =]{.underline}

[aiPackStates.packStates().get(aiPackName);]{.underline}

[} catch (RuntimeExecutionException e) {]{.underline}

[Log.d(\"MainActivity\", e.getMessage());]{.underline}

[return;]{.underline}

[});]{.underline}

[The following
[AiPackState](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackState)
methods provide the size of the AI pack, the downloaded amount so far
(if requested), and the amount already transferred to the
app:]{.underline}

-   [[totalBytesToDownload()]{.underline}](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackState#totalBytesToDownload())

-   [[bytesDownloaded()]{.underline}](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackState#bytesDownloaded())

-   [[transferProgressPercentage()]{.underline}](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackState#transferProgressPercentage())

[To get the status of an AI pack, use the
[status()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackState#status())
method, which returns the status as an integer that corresponds to a
constant field in the
[AiPackStatus](https://developer.android.com/reference/com/google/android/play/core/aipacks/model/AiPackStatus)
class. An AI pack that\'s not installed yet has the status
AiPackStatus.NOT_INSTALLED.]{.underline}

[If a request fails, use the
[errorCode()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackState#errorCode())
method, whose return value corresponds to a constant field in the
[AiPackErrorCode](https://developer.android.com/reference/com/google/android/play/core/aipacks/model/AiPackErrorCode)
class.]{.underline}

#### [Install]{.underline}

[Use the
[fetch()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#fetch(java.util.List%3Cjava.lang.String%3E))
method to download an AI pack for the first time or call for the update
of an AI pack to complete:]{.underline}

[Task\<AiPackStates\> fetch(List\<String\> packNames)]{.underline}

[This method returns an
[AiPackStates](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackStates)
object containing a list of packs and their initial download states and
sizes. If an AI pack requested via fetch() is already downloading, the
download status is returned and no additional download is
started.]{.underline}

[**Note:** In most cases, you implement a **listener** to track the
download and installation process as covered in the next
section.]{.underline}

#### [Monitor download states]{.underline}

[You should implement an
[AiPackStateUpdateListener](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackStateUpdateListener)
to track the installation progress of AI packs. The status updates are
broken down per pack to support tracking the status of individual AI
packs. You can start using available AI packs before all other downloads
for your request have completed.]{.underline}

[void registerListener(AiPackStateUpdateListener listener)]{.underline}

[void unregisterListener(AiPackStateUpdateListener
listener)]{.underline}

[**Note:** The Play Store automatically triggers the download of any
**fast-follow** packs after the user installs or updates the app.
However, these packs may not be ready to use immediately. You must check
the status of the **fast-follow** packs at every app launch. If the
download is in progress, monitor it with a listener. If the download is
cancelled or paused, you can resume it by using the **fetch()** method,
as covered in the
[Install](https://developer.android.com/google/play/on-device-ai#install)
section.]{.underline}

##### **[Large downloads]{.underline}**

[If the download is larger than 200 MB and the user is not on Wi-Fi, the
download does not start until the user explicitly gives their consent to
proceed with the download using a mobile data connection. Similarly, if
the download is large and the user loses Wi-Fi, the download is paused
and explicit consent is required to proceed using a mobile data
connection. A paused pack has state WAITING_FOR_WIFI. To trigger the UI
flow to prompt the user for consent, use the
[showConfirmationDialog()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#showConfirmationDialog(androidx.activity.result.ActivityResultLauncher%3Candroidx.activity.result.IntentSenderRequest%3E))
method.]{.underline}

[Note that if the app does not call this method, the download is paused
and will resume automatically only when the user is back on a Wi-Fi
connection.]{.underline}

##### **[Required user confirmation]{.underline}**

[If a pack has the REQUIRES_USER_CONFIRMATION status, the download
won\'t proceed until the user accepts the dialog that is shown with
[showConfirmationDialog()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#showConfirmationDialog(androidx.activity.result.ActivityResultLauncher%3Candroidx.activity.result.IntentSenderRequest%3E)).
This status can occur when the app is not recognized by Play---for
example, if the app was sideloaded. Note that calling
[showConfirmationDialog()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#showConfirmationDialog(androidx.activity.result.ActivityResultLauncher%3Candroidx.activity.result.IntentSenderRequest%3E))
in this case will cause the app to be updated. After the update, you
will need to request the AI packs again.]{.underline}

[The following is an example implementation of a listener:]{.underline}

[AiPackStateUpdateListener aiPackStateUpdateListener = new
AiPackStateUpdateListener() {]{.underline}

[private final ActivityResultLauncher\<IntentSenderRequest\>
activityResultLauncher =]{.underline}

[registerForActivityResult(]{.underline}

[new ActivityResultContracts.StartIntentSenderForResult(),]{.underline}

[new ActivityResultCallback\<ActivityResult\>() {]{.underline}

[\@Override]{.underline}

[public void onActivityResult(ActivityResult result) {]{.underline}

[if (result.getResultCode() == RESULT_OK) {]{.underline}

[Log.d(TAG, \"Confirmation dialog has been accepted.\");]{.underline}

[} else if (result.getResultCode() == RESULT_CANCELED) {]{.underline}

[Log.d(TAG, \"Confirmation dialog has been denied by the
user.\");]{.underline}

[}]{.underline}

[}]{.underline}

[});]{.underline}

[\@Override]{.underline}

[public void onStateUpdate(AiPackState aiPackState) {]{.underline}

[switch (aiPackState.status()) {]{.underline}

[case AiPackStatus.PENDING:]{.underline}

[Log.i(TAG, \"Pending\");]{.underline}

[break;]{.underline}

[case AiPackStatus.DOWNLOADING:]{.underline}

[long downloaded = aiPackState.bytesDownloaded();]{.underline}

[long totalSize = aiPackState.totalBytesToDownload();]{.underline}

[double percent = 100.0 \* downloaded / totalSize;]{.underline}

[Log.i(TAG, \"PercentDone=\" + String.format(\"%.2f\",
percent));]{.underline}

[break;]{.underline}

[case AiPackStatus.TRANSFERRING:]{.underline}

[// 100% downloaded and assets are being transferred.]{.underline}

[// Notify user to wait until transfer is complete.]{.underline}

[break;]{.underline}

[case AiPackStatus.COMPLETED:]{.underline}

[// AI pack is ready to use. Run the model.]{.underline}

[break;]{.underline}

[case AiPackStatus.FAILED:]{.underline}

[// Request failed. Notify user.]{.underline}

[Log.e(TAG, aiPackState.errorCode());]{.underline}

[break;]{.underline}

[case AiPackStatus.CANCELED:]{.underline}

[// Request canceled. Notify user.]{.underline}

[break;]{.underline}

[case AiPackStatus.WAITING_FOR_WIFI:]{.underline}

[case AiPackStatus.REQUIRES_USER_CONFIRMATION:]{.underline}

[if (!confirmationDialogShown) {]{.underline}

[aiPackManager.showConfirmationDialog(activityResultLauncher);]{.underline}

[confirmationDialogShown = true;]{.underline}

[}]{.underline}

[break;]{.underline}

[case AiPackStatus.NOT_INSTALLED:]{.underline}

[// AI pack is not downloaded yet.]{.underline}

[break;]{.underline}

[case AiPackStatus.UNKNOWN:]{.underline}

[Log.wtf(TAG, \"AI pack status unknown\")]{.underline}

[break;]{.underline}

[}]{.underline}

[}]{.underline}

[}]{.underline}

[Alternatively, you can use the
[getPackStates()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#getPackStates())
method to get the status of current downloads.
[AiPackStates](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackStates)
contains the download progress, download status, and any failure error
codes.]{.underline}

#### [Access AI packs]{.underline}

[You can access an AI pack using file system calls after the download
request reaches the
[COMPLETED](https://developer.android.com/reference/com/google/android/play/core/aipacks/model/AiPackStatus#completed())
state. Use the
[getPackLocation()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#getPackLocation(java.lang.String))
method to get the root folder of the AI pack.]{.underline}

[AI packs are stored in the assets directory within the AI pack root
directory. You can get the path to the assets directory by using the
convenience method
[assetsPath()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackLocation#assetsPath()).
Use the following method to get the path to a specific
asset:]{.underline}

[private String getAbsoluteAiAssetPath(String aiPack, String
relativeAiAssetPath) {]{.underline}

[AiPackLocation aiPackPath =
aiPackManager.getPackLocation(aiPack);]{.underline}

[if (aiPackPath == null) {]{.underline}

[// AI pack is not ready]{.underline}

[return null;]{.underline}

[}]{.underline}

[String aiAssetsFolderPath = aiPackPath.assetsPath();]{.underline}

[// equivalent to: FilenameUtils.concat(aiPackPath.path(),
\"assets\");]{.underline}

[String aiAssetPath = FilenameUtils.concat(aiAssetsFolderPath,
relativeAiAssetPath);]{.underline}

[return aiAssetPath;]{.underline}

[}]{.underline}

### [Configure device targeting]{.underline}

[You can follow the [device targeting
instructions](https://developer.android.com/google/play/on-device-ai#device-targeting-configuration)
to specify devices or groups of devices that should receive your AI
packs.]{.underline}

### [Other Play AI Delivery API methods]{.underline}

[The following are some additional API methods you may want to use in
your app.]{.underline}

#### [Cancel request]{.underline}

[Use
[cancel()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#cancel(java.util.List%3Cjava.lang.String%3E))
to cancel an active AI pack request. Note that this request is a
best-effort operation.]{.underline}

#### [Remove an AI pack]{.underline}

[Use
[removePack()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#removePack(java.lang.String))
to schedule the removal of an AI pack.]{.underline}

#### [Get locations of multiple AI packs]{.underline}

[Use
[getPackLocations()](https://developer.android.com/reference/com/google/android/play/core/aipacks/AiPackManager#getPackLocations())
to query the status of multiple AI packs in bulk, which returns a map of
AI packs and their locations. The map returned by getPackLocations()
contains an entry for each pack that is currently downloaded and
up-to-date.]{.underline}

## **[Device targeting]{.underline}**

[Device targeting gives you finer control over which parts of your app
bundle are delivered to specific devices. For example, you could ensure
that a large model is only delivered to devices with high RAM or you
could deliver different versions of a model to different
devices.]{.underline}

[You can target device properties such as:]{.underline}

-   [System on chip]{.underline}

-   [Device model]{.underline}

-   [Device RAM]{.underline}

-   [[System
    > features]{.underline}](https://developer.android.com/guide/topics/manifest/uses-feature-element#features-reference)

### [Overview of required steps]{.underline}

[The following steps are required to enable device
targeting:]{.underline}

1.  [Define your device groups in an XML file.]{.underline}

2.  [Specify which parts of your bundle should go to which device
    > groups.]{.underline}

3.  [\[Optional\] Test your configuration locally.]{.underline}

4.  [Upload your bundle (containing the XML file) to Google
    > Play.]{.underline}

### [Check Android Gradle Plugin version]{.underline}

[To use device targeting, ensure that your Android Gradle Plugin (AGP)
version is at least 8.10.0. This is packaged with Android Studio
(Meerkat 2 and later). Download the latest [stable version of Android
Studio](https://developer.android.com/studio).]{.underline}

### [Enable this feature in Android Gradle Plugin]{.underline}

[Device targeting must be enabled explicitly in your gradle.properties
file:]{.underline}

[android.experimental.enableDeviceTargetingConfigApi=true]{.underline}

### [Create a device targeting configuration XML file]{.underline}

[The device targeting configuration file is an XML file in which you
define your custom device groups. For example, you could define a device
group called qti_v79 that contains all devices with the Qualcomm SM8750
system on chip:]{.underline}

[\<config:device-targeting-config]{.underline}

[xmlns:config=\"http://schemas.android.com/apk/config\"\>]{.underline}

[\<config:device-group name=\"qti_v79\"\>]{.underline}

[\<config:device-selector\>]{.underline}

[\<config:system-on-chip manufacturer=\"QTI\"
model=\"SM8750\"/\>]{.underline}

[\</config:device-selector\>]{.underline}

[\</config:device-group\>]{.underline}

[\</config:device-targeting-config\>]{.underline}

[A **device group** is composed of up to 5 **device selectors**. A
device is included in a device group if it satisfies any of its device
selectors.]{.underline}

[A **device selector** can have one or more **device properties**. A
device is selected if it matches all of the selector\'s device
properties.]{.underline}

[If a device matches multiple groups, it will be served the content for
the group that is defined first in the XML file. The order you define
groups in the XML file is your priority order.]{.underline}

[If a device matches no groups, it will receive the default \"other\"
group. This group is automatically generated and shouldn\'t be defined
explicitly.]{.underline}

#### [Available device properties]{.underline}

-   [**device_ram**: Device RAM requirements]{.underline}

    -   [**min_bytes** (*inclusive)*: Minimum required RAM (in
        > bytes)]{.underline}

    -   [**max_bytes** (*exclusive)*: Maximum required RAM (in
        > bytes)]{.underline}

-   [**included_device_ids**: Device models to be included in this
    > selector **(max of 10000 device_ids per group)**. This property is
    > satisfied if the device matches any device_id in the
    > list.]{.underline}

    -   [**build_brand**: Device manufacturer]{.underline}

    -   [**build_device**: Device model code]{.underline}

-   [**excluded_device_ids**: Device models to be excluded in this
    > selector **(max of 10000 device_ids per group)**. This property is
    > satisfied if the device matches no device_id in the
    > list.]{.underline}

    -   [**build_brand**: Device manufacturer]{.underline}

    -   [**build_device**: Device model code]{.underline}

-   [**required_system_features**: Features that a device needs to have
    > to be included by this selector **(max of 100 features per
    > group)**. A device needs to have all system features in this list
    > to satisfy this property.\
    > System [feature
    > reference](https://developer.android.com/guide/topics/manifest/uses-feature-element#features-reference)]{.underline}

    -   [**name**: A system feature]{.underline}

-   [**forbidden_system_features**: Features that a device mustn\'t have
    > to be included by this selector **(max of 100 features per
    > group)**. If a device has any of the system features in this list
    > it doesn\'t satisfy this property.\
    > System [feature
    > reference](https://developer.android.com/guide/topics/manifest/uses-feature-element#features-reference)]{.underline}

    -   [**name**: A system feature]{.underline}

-   [**system-on-chip**: System on chips to be included in this
    > selector. A device needs to have any chip in this list to satisfy
    > this property.]{.underline}

    -   [**manufacturer**: [System on chip
        > manufacturer](https://developer.android.com/reference/android/os/Build#SOC_MANUFACTURER)]{.underline}

    -   [**model**: [System on chip
        > model](https://developer.android.com/reference/android/os/Build#SOC_MODEL)]{.underline}

[**Tip:** Including multiple properties in a single selector creates a
logical AND, for example:]{.underline}

[\<config:device-selector ram-min-bytes=\"7000000000\"\>]{.underline}

[\<config:included-device-id brand=\"google\"
device=\"flame\"/\>]{.underline}

[\</config:device-selector\>]{.underline}

[will create the condition for all devices with \> 7GB of RAM AND it is
a Pixel 4 - also written as follows:]{.underline}

![](media/image2.png){width="6.267716535433071in" height="0.375in"}

[If you want an OR condition, create separate selectors in a single
device group, for example:]{.underline}

[\<config:device-selector ram-min-bytes=\"7000000000\"/\>]{.underline}

[\<config:device-selector\>]{.underline}

[\<config:included-device-id brand=\"google\"
device=\"flame\"/\>]{.underline}

[\</config:device-selector\>]{.underline}

[will create the condition for all devices with \> 7GB of RAM OR it is a
Pixel 4 - also written as follows:]{.underline}

![](media/image1.png){width="6.267716535433071in"
height="0.3611111111111111in"}

[Here is an example showing all possible device properties:]{.underline}

[\<config:device-targeting-config]{.underline}

[xmlns:config=\"http://schemas.android.com/apk/config\"\>]{.underline}

[\<config:device-group name=\"myCustomGroup1\"\>]{.underline}

[\<config:device-selector ram-min-bytes=\"8000000000\"\>]{.underline}

[\<config:included-device-id brand=\"google\"
device=\"redfin\"/\>]{.underline}

[\<config:included-device-id brand=\"google\"
device=\"sailfish\"/\>]{.underline}

[\<config:included-device-id brand=\"good-brand\"/\>]{.underline}

[\<config:excluded-device-id brand=\"google\"
device=\"caiman\"/\>]{.underline}

[\<config:system-on-chip manufacturer=\"Sinclair\"
model=\"ZX80\"/\>]{.underline}

[\<config:system-on-chip manufacturer=\"Commodore\"
model=\"C64\"/\>]{.underline}

[\</config:device-selector\>]{.underline}

[\<config:device-selector ram-min-bytes=\"16000000000\"/\>]{.underline}

[\</config:device-group\>]{.underline}

[\<config:device-group name=\"myCustomGroup2\"\>]{.underline}

[\<config:device-selector ram-min-bytes=\"4000000000\"
ram-max-bytes=\"8000000000\"\>]{.underline}

[\<config:required-system-feature
name=\"android.hardware.bluetooth\"/\>]{.underline}

[\<config:required-system-feature
name=\"android.hardware.location\"/\>]{.underline}

[\<config:forbidden-system-feature
name=\"android.hardware.camera\"/\>]{.underline}

[\<config:forbidden-system-feature
name=\"mindcontrol.laser\"/\>]{.underline}

[\</config:device-selector\>]{.underline}

[\</config:device-group\>]{.underline}

[\</config:device-targeting-config\>]{.underline}

#### [Official device manufacturer and device model codes]{.underline}

[You can find the correct formatting for the device manufacturer and
model code by using the Device Catalog on the Google Play Console, by
either:]{.underline}

-   [Inspecting individual devices using the Device Catalog, and finding
    > the manufacturer and model code in the locations as shown in the
    > example below (For a Google Pixel 4a, the manufacturer is
    > \"Google\" and the model code is \"sunfish\")\'\
    > \
    > ]{.underline}

-   [Downloading a CSV of supported devices, and using the
    > *Manufacturer* and *Model Code* for the *build_brand* and
    > *build_device* fields, respectively.]{.underline}

#### [Include your device targeting configuration file in your app bundle]{.underline}

[Add the following to your main module\'s build.gradle
file:]{.underline}

[android {]{.underline}

[\...]{.underline}

[bundle {]{.underline}

[deviceTargetingConfig =
file(\'device_targeting_config.xml\')]{.underline}

[deviceGroup {]{.underline}

[enableSplit = true // split bundle by #group]{.underline}

[defaultGroup = \"other\" // group used for standalone APKs]{.underline}

[}]{.underline}

[}]{.underline}

[\...]{.underline}

[}]{.underline}

[device_targeting_config.xml is the path of your configuration file
relative to the main module. This ensures that your configuration file
is packaged with your app bundle.]{.underline}

[The deviceGroup clause ensures that the APKs generated from your bundle
are split by device groups.]{.underline}

### [Use device targeting for your AI packs]{.underline}

[You can keep size optimized on devices by only delivering your large
models to devices that can run them.]{.underline}

[Subdivide your AI packs by device groups by taking the **existing** AI
pack directories created in the last step, and post-fixing the
appropriate folders (as described below) with #group_myCustomGroup1,
#group_myCustomGroup2, etc. When using the AI packs in your app, you
won\'t need to address folders by postfix (in other words, the postfix
is automatically stripped during the build process).]{.underline}

[After the previous step, this might look like:]{.underline}

[\...]{.underline}

[\.../ai-pack-name/src/main/assets/image-classifier#group_myCustomGroup1/]{.underline}

[\.../ai-pack-name/src/main/assets/image-classifier#group_myCustomGroup2/]{.underline}

[\...]{.underline}

[In this example, you would reference
ai-pack-name/assets/image-classifier/ without any
postfixes.]{.underline}

[Devices in myCustomGroup1 will receive all the assets under
image-classifier#group_myCustomGroup1/, while devices in myCustomGroup2
will receive all the assets under
image-classifier#group_myCustomGroup2/.]{.underline}

[Devices that don\'t belong to either myCustomGroup1 or myCustomGroup2
will receive an empty ai-pack-name pack.]{.underline}

[This is because devices that don\'t match any device group will receive
the default variant of your AI pack. This includes anything that is not
inside a directory with a #group_suffix.]{.underline}

[Once you have downloaded the AI pack, you can check whether your model
is present by using the
[AssetManager](https://developer.android.com/google/play/on-device-ai#install-time-delivery)
for install-time packs or the
[AiPackManager](https://developer.android.com/google/play/on-device-ai#access-AI-packs)
for fast-follow and on-demand packs. Examples for doing this are shown
for all delivery modes in the [sample
app](https://developer.android.com/google/play/on-device-ai#example-app).]{.underline}

[**Important:** It\'s not possible to prevent **any** variant of your AI
pack being delivered to certain devices. Non-targeted devices will
always receive the default variant.]{.underline}

### [Use device targeting for your feature modules]{.underline}

[You can also use device targeting for feature modules. Instead of
subdividing feature modules by device group, you specify whether the
entire module should be delivered based on device group
membership.]{.underline}

[To deliver a feature module to devices that belong to either
myCustomGroup1 or myCustomGroup2, modify its
AndroidManifest.xml:]{.underline}

[\<manifest \...\>]{.underline}

[\...]{.underline}

[\<dist:module dist:title=\"\...\"\>]{.underline}

[\<dist:delivery\>]{.underline}

[\<dist:install-time\>]{.underline}

[\<dist:conditions\>]{.underline}

[\<dist:device-groups\>]{.underline}

[\<dist:device-group dist:name=\"myCustomGroup1\"/\>]{.underline}

[\<dist:device-group dist:name=\"myCustomGroup2\"/\>]{.underline}

[\</dist:device-groups\>]{.underline}

[\...]{.underline}

[\</dist:conditions\>]{.underline}

[\</dist:install-time\>]{.underline}

[\</dist:delivery\>]{.underline}

[\</dist:module\>]{.underline}

[\...]{.underline}

[\</manifest\>]{.underline}

[**Note:** Devices that are not targeted won\'t receive the feature
module at all. This is different from [targeting for AI
packs](https://developer.android.com/google/play/on-device-ai#targeting-for-ai-packs),
where devices that are not targeted receive a default, empty variant of
the AI pack.]{.underline}

## **[Test locally]{.underline}**

[Before creating a release for your new bundle, you can test locally
with either Internal App Sharing or Bundletool.]{.underline}

### [Internal App Sharing]{.underline}

[Internal App Sharing lets you use an app bundle to quickly generate a
URL that you can tap on a local device to install exactly what Google
Play would install for that device if that version of the app was live
in a test or prod track.]{.underline}

[Take a look at the [internal app sharing
instructions](https://support.google.com/googleplay/android-developer/answer/9844679).]{.underline}

### [Bundletool]{.underline}

[Alternatively, you can generate APKs using
[bundletool](https://developer.android.com/studio/command-line/bundletool)
(1.18.0 or above) and sideload them onto your device. Follow these steps
to test your app locally using bundletool:]{.underline}

1.  [Build your app bundle with Android Studio or
    > bundletool.]{.underline}

2.  [Generate APKs with the \--local-testing flag:]{.underline}

[java -jar bundletool-all.jar build-apks
\--bundle=*path/to/your/bundle.aab* \\]{.underline}

[\--output=*output.apks* \--local-testing]{.underline}

3.  

4.  [Connect a device and run bundletool to sideload the
    > APKs:]{.underline}

[\# Example without Device Targeting Configuration]{.underline}

[java -jar bundletool.jar install-apks
\--apks=*output.apks*]{.underline}

5.  

[\# Example with Device Targeting Configuration (you must specify which
groups the connected device belongs to)]{.underline}

[java -jar bundletool.jar install-apks \--apks=*output.apks*
\--device-groups=*myCustomGroup1,myCustomGroup2*]{.underline}

6.  

#### [Limitations of local testing with bundletool]{.underline}

[The following are limitations of local testing with
bundletool:]{.underline}

-   [fast-follow packs behave as on-demand packs. That is, they won\'t
    > be automatically fetched when the app is sideloaded. Developers
    > need to request them manually when the app starts; this does not
    > require any code changes in your app.]{.underline}

-   [Packs fetch from external storage instead of Play, so you cannot
    > test how your code behaves in the case of network
    > errors.]{.underline}

-   [Local testing does not cover the wait-for-Wi-Fi
    > scenario.]{.underline}

-   [Updates are not supported. Before installing a new version of your
    > build, manually uninstall the previous version.]{.underline}

### [Verify that the correct APKs are being installed]{.underline}

[Use the following method to ensure only the correct APKs are installed
on the device]{.underline}

[adb shell pm path {packageName}]{.underline}

[You should see something like:]{.underline}

[package:{\...}/base.apk]{.underline}

[package:{\...}/split_config.en.apk]{.underline}

[package:{\...}/split_config.xxhdpi.apk]{.underline}

[package:{\...}/split_main_ai-pack-name.apk]{.underline}

[package:{\...}/split_main_ai-pack-name.config.group_myCustomGroup1.apk]{.underline}

[Note that you will only see APKs in this list, which are made from
feature modules and install-time AI packs. On-demand and fast-follow AI
packs are not installed as APKs.]{.underline}

## **[Test and release on Google Play]{.underline}**

[We recommend that you test your app end to end on Google Play with an
[internal test
track](https://support.google.com/googleplay/android-developer/answer/9845334).]{.underline}

[Once you\'ve done this, you can incrementally release your app update
to production with [staged
roll-outs](https://support.google.com/googleplay/android-developer/answer/6346149).]{.underline}

## **[Sample app using Play for On-device AI]{.underline}**

[Download the [sample
app](https://drive.google.com/drive/folders/1zb2O2mDvEh4vOmv1QbjeLU-O25KHrfKJ).]{.underline}

[It demonstrates how to use each of the delivery modes as well as the
device targeting configuration. See the [local
testing](https://developer.android.com/google/play/on-device-ai#local-testing)
section to get started.]{.underline}

## **[Related content]{.underline}**

[Learn more about [Android App
Bundles](https://developer.android.com/guide/app-bundle) and read the
references for the [AI Delivery
SDK](https://developer.android.com/reference/com/google/android/play/core/packages-ai_delivery).]{.underline}

[Was this helpful?]{.underline}

[Content and code samples on this page are subject to the licenses
described in the [Content
License](https://developer.android.com/license). Java and OpenJDK are
trademarks or registered trademarks of Oracle and/or its
affiliates.]{.underline}

[Last updated 2025-10-10 UTC.]{.underline}
