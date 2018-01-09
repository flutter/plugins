package io.flutter.plugins.googlesignin;

import android.accounts.Account;
import android.content.Context;
import android.os.AsyncTask;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import com.google.android.gms.auth.GoogleAuthUtil;
import java.util.Iterator;
import java.util.List;

/** Android inbuilt solution for calling async tasks */
class GetOauthTokenTask extends AsyncTask<GetOauthTokenTask.Request, Void, String> {

  private final OnTokenListener listener;
  @Nullable private Exception error;

  public GetOauthTokenTask(@NonNull OnTokenListener listener) {
    this.listener = listener;
  }

  /**
   * This method avoids the guava dependency. Guava has about 15k methods, to avoid hitting the
   * method limit we write this method ourselves.
   *
   * @param stringsToJoin a list of strings you want to join
   * @return a string that joined the list of strings separated by a space character
   * @see <a href="https://developer.android.com/studio/build/multidex.html#about">Android Method
   *     Limit</a>
   * @see <a href="http://www.methodscount.com/?lib=com.google.guava%3Aguava%3A20.0">Guava Method
   *     count</a>
   */
  @NonNull
  private static String stringJoiner(@NonNull List<String> stringsToJoin) {
    StringBuilder sb = new StringBuilder();
    Iterator<String> it = stringsToJoin.iterator();
    while (it.hasNext()) {
      sb.append(it.next());
      if (it.hasNext()) sb.append(' ');
    }
    return sb.toString();
  }

  @Override
  protected String doInBackground(GetOauthTokenTask.Request... requests) {
    if (requests.length == 1) {
      Request request = requests[0];
      Account account = new Account(request.email, "com.google");
      String scopesStr = String.format("oauth2:%s", stringJoiner(request.scopes));
      try {
        return GoogleAuthUtil.getToken(request.context, account, scopesStr);
      } catch (Exception e) {
        error = e;
      }
    }
    return null;
  }

  @Override
  protected void onPostExecute(String token) {
    // will be called in the mainthread
    if (token != null) {
      listener.onToken(token);
    } else if (error != null) {
      listener.onError(error);
    } else {
      listener.onError(new UnknownError("There was an unknown error while requesting the token"));
    }
  }

  /** Callback to handle the result of the call */
  interface OnTokenListener {
    /**
     * Called only once if the token was received successfully. Method is called on the android main
     * thread.
     *
     * @param token to receive
     */
    void onToken(@NonNull String token);

    /**
     * Called only once when there was an error while catching the token. Method is called on the
     * android main thread.
     *
     * @param error for handling it
     */
    void onError(@NonNull Throwable error);
  }

  /** Options to request an oauth token */
  static class Request {
    final String email;
    final List<String> scopes;
    final Context context;

    /**
     * @param context required for the {@link GoogleAuthUtil#getToken(Context, Account, String)}
     *     method
     * @param email you want a token for
     * @param scopes you need the token for
     */
    public Request(Context context, String email, List<String> scopes) {
      this.email = email;
      this.scopes = scopes;
      this.context = context;
    }
  }
}
