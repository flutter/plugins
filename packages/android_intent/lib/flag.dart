/// Special flags that can be set on an intent to control how it is handled.
///
/// See
/// https://developer.android.com/reference/android/content/Intent.html#setFlags(int)
/// for the official documentation on Intent flags. The constants here mirror
/// the existing [android.content.Intent] ones.
class Flag {
  /// Specifies how an activity should be launched. Generally set by the system
  /// in conjunction with SINGLE_TASK.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_BROUGHT_TO_FRONT.
  static const int FLAG_ACTIVITY_BROUGHT_TO_FRONT = 4194304;

  /// Causes any existing tasks associated with the activity to be cleared.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_CLEAR_TASK
  static const int FLAG_ACTIVITY_CLEAR_TASK = 32768;

  /// Closes any activities on top of this activity and brings it to the front,
  /// if it's currently running.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_CLEAR_TOP
  static const int FLAG_ACTIVITY_CLEAR_TOP = 67108864;

  /// @deprecated Use [FLAG_ACTIVITY_NEW_DOCUMENT] instead when on API 21 or above.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET
  @deprecated
  static const int FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET = 524288;

  /// Keeps the activity from being listed with other recently launched
  /// activities.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
  static const int FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS = 8388608;

  /// Forwards the result from this activity to the existing one.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_FORWARD_RESULT
  static const int FLAG_ACTIVITY_FORWARD_RESULT = 33554432;

  /// Generally set by the system if the activity is being launched from
  /// history.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY
  static const int FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY = 1048576;

  /// Used in split-screen mode to set the launched activity adjacent to the
  /// launcher.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_LAUNCH_ADJACENT
  static const int FLAG_ACTIVITY_LAUNCH_ADJACENT = 4096;

  /// Used in split-screen mode to set the launched activity adjacent to the
  /// launcher.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_MATCH_EXTERNAL
  static const int FLAG_ACTIVITY_MATCH_EXTERNAL = 2048;

  /// Creates and launches the activity into a new task. Should always be
  /// combined with [FLAG_ACTIVITY_NEW_DOCUMENT] or [FLAG_ACTIVITY_NEW_TASK].
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_MULTIPLE_TASK.
  static const int FLAG_ACTIVITY_MULTIPLE_TASK = 134217728;

  /// Opens a document into a new task rooted in this activity.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_NEW_DOCUMENT.
  static const int FLAG_ACTIVITY_NEW_DOCUMENT = 524288;

  /// The launched activity starts a new task on the activity stack.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_NEW_TASK.
  static const int FLAG_ACTIVITY_NEW_TASK = 268435456;

  /// Prevents the system from playing an activity transition animation when
  /// launching this.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_NO_ANIMATION.
  static const int FLAG_ACTIVITY_NO_ANIMATION = 65536;

  /// Does not keep the launched activity in history.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_NO_HISTORY.
  static const int FLAG_ACTIVITY_NO_HISTORY = 1073741824;

  /// Prevents a typical callback from occuring when the activity is paused.
  ///
  /// https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_NO_USER_ACTION
  static const int FLAG_ACTIVITY_NO_USER_ACTION = 262144;

  /// Uses the previous activity as top when applicable.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_PREVIOUS_IS_TOP.
  static const int FLAG_ACTIVITY_PREVIOUS_IS_TOP = 16777216;

  /// Brings any already instances of this activity to the front.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_REORDER_TO_FRONT.
  static const int FLAG_ACTIVITY_REORDER_TO_FRONT = 131072;

  /// Launches the activity in a way that resets the task in some cases.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_RESET_TASK_IF_NEEDED.
  static const int FLAG_ACTIVITY_RESET_TASK_IF_NEEDED = 2097152;

  /// Keeps an entry in recent tasks. Used with [FLAG_ACTIVITY_NEW_DOCUMENT].
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_RETAIN_IN_RECENTS.
  static const int FLAG_ACTIVITY_RETAIN_IN_RECENTS = 8192;

  /// Will not re-launch the activity if it is already at the top of the history
  /// stack.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_SINGLE_TOP.
  static const int FLAG_ACTIVITY_SINGLE_TOP = 536870912;

  /// Places the activity on top of the home task. Must be used with
  /// [FLAG_ACTIVITY_NEW_TASK].
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_ACTIVITY_TASK_ON_HOME.
  static const int FLAG_ACTIVITY_TASK_ON_HOME = 16384;

  /// Prints debug logs while the intent is resolving.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_DEBUG_LOG_RESOLUTION.
  static const int FLAG_DEBUG_LOG_RESOLUTION = 8;

  /// Does not match to any stopped components.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_EXCLUDE_STOPPED_PACKAGES.
  static const int FLAG_EXCLUDE_STOPPED_PACKAGES = 16;

  /// Can be set by the caller to flag the intent as not being launched directly
  /// by the user.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_FROM_BACKGROUND.
  static const int FLAG_FROM_BACKGROUND = 4;

  /// Will persist the URI permision across device reboots.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_GRANT_PERSISTABLE_URI_PERMISSION.
  static const int FLAG_GRANT_PERSISTABLE_URI_PERMISSION = 64;

  /// Applies the URI permission grant based on prefix matching.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_GRANT_PREFIX_URI_PERMISSION.
  static const int FLAG_GRANT_PREFIX_URI_PERMISSION = 128;

  /// Grants the intent listener permission to read extra data from the Intent's
  /// URI.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_GRANT_READ_URI_PERMISSION.
  static const int FLAG_GRANT_READ_URI_PERMISSION = 1;

  /// Grants the intent listener permission to write extra data from the
  /// Intent's URI.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_GRANT_WRITE_URI_PERMISSION.
  static const int FLAG_GRANT_WRITE_URI_PERMISSION = 2;

  /// Always matches stopped components. This is the default behavior.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_INCLUDE_STOPPED_PACKAGES.
  static const int FLAG_INCLUDE_STOPPED_PACKAGES = 32;

  /// Allows the listener to run at a high priority.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_RECEIVER_FOREGROUND.
  static const int FLAG_RECEIVER_FOREGROUND = 268435456;

  /// Doesn't allow listeners to cancel the broadcast.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_RECEIVER_NO_ABORT.
  static const int FLAG_RECEIVER_NO_ABORT = 134217728;

  /// Only allows registered receivers to listen for the intent.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_RECEIVER_REGISTERED_ONLY.
  static const int FLAG_RECEIVER_REGISTERED_ONLY = 1073741824;

  /// Will drop any pending broadcasts of this intent in favor of the newest
  /// one.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_RECEIVER_REPLACE_PENDING.
  static const int FLAG_RECEIVER_REPLACE_PENDING = 536870912;

  /// Instant Apps will be able to listen for the intent (not the default
  /// behavior).
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#FLAG_RECEIVER_VISIBLE_TO_INSTANT_APPS.
  static const int FLAG_RECEIVER_VISIBLE_TO_INSTANT_APPS = 2097152;
}
