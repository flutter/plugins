// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.storage;

import android.net.Uri;
import android.support.annotation.NonNull;
import android.util.SparseArray;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.storage.FileDownloadTask;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.OnPausedListener;
import com.google.firebase.storage.OnProgressListener;
import com.google.firebase.storage.StorageException;
import com.google.firebase.storage.StorageMetadata;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

/** FirebaseStoragePlugin */
public class FirebaseStoragePlugin implements MethodCallHandler {
  private FirebaseStorage firebaseStorage;
  private final MethodChannel channel;

  private int nextUploadHandle = 0;
  private final SparseArray<UploadTask> uploadTasks = new SparseArray<>();

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_storage");
    channel.setMethodCallHandler(new FirebaseStoragePlugin(channel, registrar));
  }

  private FirebaseStoragePlugin(MethodChannel channel, Registrar registrar) {
    this.channel = channel;
    FirebaseApp.initializeApp(registrar.context());
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    String app = call.argument("app");
    String storageBucket = call.argument("bucket");
    if (app == null && storageBucket == null) {
      firebaseStorage = FirebaseStorage.getInstance();
    } else if (storageBucket == null) {
      firebaseStorage = FirebaseStorage.getInstance(FirebaseApp.getInstance(app));
    } else if (app == null) {
      firebaseStorage = FirebaseStorage.getInstance(storageBucket);
    } else {
      firebaseStorage = FirebaseStorage.getInstance(FirebaseApp.getInstance(app), storageBucket);
    }

    switch (call.method) {
      case "FirebaseStorage#getMaxDownloadRetryTime":
        result.success(firebaseStorage.getMaxDownloadRetryTimeMillis());
        break;
      case "FirebaseStorage#getMaxUploadRetryTime":
        result.success(firebaseStorage.getMaxUploadRetryTimeMillis());
        break;
      case "FirebaseStorage#getMaxOperationRetryTime":
        result.success(firebaseStorage.getMaxOperationRetryTimeMillis());
        break;
      case "FirebaseStorage#setMaxDownloadRetryTime":
        setMaxDownloadRetryTimeMillis(call, result);
        break;
      case "FirebaseStorage#setMaxUploadRetryTime":
        setMaxUploadRetryTimeMillis(call, result);
        break;
      case "FirebaseStorage#setMaxOperationRetryTime":
        setMaxOperationTimeMillis(call, result);
        break;
      case "StorageReference#putFile":
        putFile(call, result);
        break;
      case "StorageReference#putData":
        putData(call, result);
        break;
      case "StorageReference#getData":
        getData(call, result);
        break;
      case "StorageReference#delete":
        delete(call, result);
        break;
      case "StorageReference#getBucket":
        getBucket(call, result);
        break;
      case "StorageReference#getName":
        getName(call, result);
        break;
      case "StorageReference#getPath":
        getPath(call, result);
        break;
      case "StorageReference#getDownloadUrl":
        getDownloadUrl(call, result);
        break;
      case "StorageReference#getMetadata":
        getMetadata(call, result);
        break;
      case "StorageReference#updateMetadata":
        updateMetadata(call, result);
        break;
      case "StorageReference#writeToFile":
        writeToFile(call, result);
        break;
      case "UploadTask#pause":
        pauseUploadTask(call, result);
        break;
      case "UploadTask#resume":
        resumeUploadTask(call, result);
        break;
      case "UploadTask#cancel":
        cancelUploadTask(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void setMaxDownloadRetryTimeMillis(MethodCall call, Result result) {
    Number time = call.argument("time");
    firebaseStorage.setMaxDownloadRetryTimeMillis(time.longValue());
    result.success(null);
  }

  private void setMaxUploadRetryTimeMillis(MethodCall call, Result result) {
    Number time = call.argument("time");
    firebaseStorage.setMaxUploadRetryTimeMillis(time.longValue());
    result.success(null);
  }

  private void setMaxOperationTimeMillis(MethodCall call, Result result) {
    Number time = call.argument("time");
    firebaseStorage.setMaxOperationRetryTimeMillis(time.longValue());
    result.success(null);
  }

  private void getMetadata(MethodCall call, final Result result) {
    String path = call.argument("path");
    StorageReference ref = firebaseStorage.getReference().child(path);
    ref.getMetadata()
        .addOnSuccessListener(
            new OnSuccessListener<StorageMetadata>() {
              @Override
              public void onSuccess(StorageMetadata storageMetadata) {
                result.success(buildMapFromMetadata(storageMetadata));
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("metadata_error", e.getMessage(), null);
              }
            });
  }

  private void updateMetadata(MethodCall call, final Result result) {
    String path = call.argument("path");
    Map<String, Object> metadata = call.argument("metadata");
    StorageReference ref = firebaseStorage.getReference().child(path);
    ref.updateMetadata(buildMetadataFromMap(metadata))
        .addOnSuccessListener(
            new OnSuccessListener<StorageMetadata>() {
              @Override
              public void onSuccess(StorageMetadata storageMetadata) {
                result.success(buildMapFromMetadata(storageMetadata));
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("metadata_error", e.getMessage(), null);
              }
            });
  }

  private void getBucket(MethodCall call, final Result result) {
    String path = call.argument("path");
    StorageReference ref = firebaseStorage.getReference().child(path);
    result.success(ref.getBucket());
  }

  private void getName(MethodCall call, final Result result) {
    String path = call.argument("path");
    StorageReference ref = firebaseStorage.getReference().child(path);
    result.success(ref.getName());
  }

  private void getPath(MethodCall call, final Result result) {
    String path = call.argument("path");
    StorageReference ref = firebaseStorage.getReference().child(path);
    result.success(ref.getPath());
  }

  private void getDownloadUrl(MethodCall call, final Result result) {
    String path = call.argument("path");
    StorageReference ref = firebaseStorage.getReference().child(path);
    ref.getDownloadUrl()
        .addOnSuccessListener(
            new OnSuccessListener<Uri>() {
              @Override
              public void onSuccess(Uri uri) {
                result.success(uri.toString());
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("download_error", e.getMessage(), null);
              }
            });
  }

  private void delete(MethodCall call, final Result result) {
    String path = call.argument("path");
    StorageReference ref = firebaseStorage.getReference().child(path);
    final Task<Void> deleteTask = ref.delete();
    deleteTask.addOnSuccessListener(
        new OnSuccessListener<Void>() {
          @Override
          public void onSuccess(Void aVoid) {
            result.success(null);
          }
        });
    deleteTask.addOnFailureListener(
        new OnFailureListener() {
          @Override
          public void onFailure(@NonNull Exception e) {
            result.error("deletion_error", e.getMessage(), null);
          }
        });
  }

  private void putFile(MethodCall call, Result result) {
    String filename = call.argument("filename");
    String path = call.argument("path");
    Map<String, Object> metadata = call.argument("metadata");
    File file = new File(filename);
    StorageReference ref = firebaseStorage.getReference().child(path);
    UploadTask uploadTask;
    if (metadata == null) {
      uploadTask = ref.putFile(Uri.fromFile(file));
    } else {
      uploadTask = ref.putFile(Uri.fromFile(file), buildMetadataFromMap(metadata));
    }
    final int handle = addUploadListeners(uploadTask);
    result.success(handle);
  }

  private void putData(MethodCall call, Result result) {
    byte[] bytes = call.argument("data");
    String path = call.argument("path");
    Map<String, Object> metadata = call.argument("metadata");
    StorageReference ref = firebaseStorage.getReference().child(path);
    UploadTask uploadTask;
    if (metadata == null) {
      uploadTask = ref.putBytes(bytes);
    } else {
      uploadTask = ref.putBytes(bytes, buildMetadataFromMap(metadata));
    }
    final int handle = addUploadListeners(uploadTask);
    result.success(handle);
  }

  private StorageMetadata buildMetadataFromMap(Map<String, Object> map) {
    StorageMetadata.Builder builder = new StorageMetadata.Builder();
    builder.setCacheControl((String) map.get("cacheControl"));
    builder.setContentEncoding((String) map.get("contentEncoding"));
    builder.setContentDisposition((String) map.get("contentDisposition"));
    builder.setContentLanguage((String) map.get("contentLanguage"));
    builder.setContentType((String) map.get("contentType"));

    @SuppressWarnings("unchecked")
    Map<String, String> customMetadata = (Map<String, String>) map.get("customMetadata");
    if (customMetadata != null) {
      for (String key : customMetadata.keySet()) {
        builder.setCustomMetadata(key, customMetadata.get(key));
      }
    }
    return builder.build();
  }

  private Map<String, Object> buildMapFromMetadata(StorageMetadata storageMetadata) {
    Map<String, Object> map = new HashMap<>();
    map.put("name", storageMetadata.getName());
    map.put("bucket", storageMetadata.getBucket());
    map.put("generation", storageMetadata.getGeneration());
    map.put("metadataGeneration", storageMetadata.getMetadataGeneration());
    map.put("path", storageMetadata.getPath());
    map.put("sizeBytes", storageMetadata.getSizeBytes());
    map.put("creationTimeMillis", storageMetadata.getCreationTimeMillis());
    map.put("updatedTimeMillis", storageMetadata.getUpdatedTimeMillis());
    map.put("md5Hash", storageMetadata.getMd5Hash());
    map.put("cacheControl", storageMetadata.getCacheControl());
    map.put("contentDisposition", storageMetadata.getContentDisposition());
    map.put("contentEncoding", storageMetadata.getContentEncoding());
    map.put("contentLanguage", storageMetadata.getContentLanguage());
    map.put("contentType", storageMetadata.getContentType());

    Map<String, String> customMetadata = new HashMap<>();
    for (String key : storageMetadata.getCustomMetadataKeys()) {
      customMetadata.put(key, storageMetadata.getCustomMetadata(key));
    }
    map.put("customMetadata", customMetadata);
    return map;
  }

  private void getData(MethodCall call, final Result result) {
    Integer maxSize = call.argument("maxSize");
    String path = call.argument("path");
    StorageReference ref = firebaseStorage.getReference().child(path);
    Task<byte[]> downloadTask = ref.getBytes(maxSize);
    downloadTask.addOnSuccessListener(
        new OnSuccessListener<byte[]>() {
          @Override
          public void onSuccess(byte[] bytes) {
            result.success(bytes);
          }
        });
    downloadTask.addOnFailureListener(
        new OnFailureListener() {
          @Override
          public void onFailure(@NonNull Exception e) {
            result.error("download_error", e.getMessage(), null);
          }
        });
  }

  private void writeToFile(MethodCall call, final Result result) {
    String path = call.argument("path");
    String filePath = call.argument("filePath");
    File file = new File(filePath);
    StorageReference ref = firebaseStorage.getReference().child(path);
    FileDownloadTask downloadTask = ref.getFile(file);
    downloadTask.addOnSuccessListener(
        new OnSuccessListener<FileDownloadTask.TaskSnapshot>() {
          @Override
          public void onSuccess(FileDownloadTask.TaskSnapshot taskSnapshot) {
            result.success(taskSnapshot.getTotalByteCount());
          }
        });
    downloadTask.addOnFailureListener(
        new OnFailureListener() {
          @Override
          public void onFailure(@NonNull Exception e) {
            result.error("download_error", e.getMessage(), null);
          }
        });
  }

  private void pauseUploadTask(MethodCall call, final Result result) {
    int handle = call.argument("handle");
    UploadTask task = uploadTasks.get(handle);
    if (task != null) {
      task.pause();
      result.success(null);
    } else {
      result.error("pause_error", "task == null", null);
    }
  }

  private void cancelUploadTask(MethodCall call, final Result result) {
    int handle = call.argument("handle");
    UploadTask task = uploadTasks.get(handle);
    if (task != null) {
      task.cancel();
      result.success(null);
    } else {
      result.error("cancel_error", "task == null", null);
    }
  }

  private void resumeUploadTask(MethodCall call, final Result result) {
    int handle = call.argument("handle");
    UploadTask task = uploadTasks.get(handle);
    if (task != null) {
      task.resume();
      result.success(null);
    } else {
      result.error("resume_error", "task == null", null);
    }
  }

  private int addUploadListeners(final UploadTask uploadTask) {
    final int handle = ++nextUploadHandle;
    uploadTask
        .addOnProgressListener(
            new OnProgressListener<UploadTask.TaskSnapshot>() {
              @Override
              public void onProgress(UploadTask.TaskSnapshot snapshot) {
                invokeStorageTaskEvent(handle, StorageTaskEventType.progress, snapshot, null);
              }
            })
        .addOnPausedListener(
            new OnPausedListener<UploadTask.TaskSnapshot>() {
              @Override
              public void onPaused(UploadTask.TaskSnapshot snapshot) {
                invokeStorageTaskEvent(handle, StorageTaskEventType.pause, snapshot, null);
              }
            })
        .addOnCompleteListener(
            new OnCompleteListener<UploadTask.TaskSnapshot>() {
              @Override
              public void onComplete(@NonNull Task<UploadTask.TaskSnapshot> task) {
                if (!task.isSuccessful()) {
                  invokeStorageTaskEvent(
                      handle,
                      StorageTaskEventType.failure,
                      uploadTask.getSnapshot(),
                      (StorageException) task.getException());
                } else {
                  invokeStorageTaskEvent(
                      handle, StorageTaskEventType.success, task.getResult(), null);
                }
                uploadTasks.remove(handle);
              }
            });
    uploadTasks.put(handle, uploadTask);
    return handle;
  }

  private enum StorageTaskEventType {
    resume,
    progress,
    pause,
    success,
    failure
  }

  private void invokeStorageTaskEvent(
      int handle,
      StorageTaskEventType type,
      UploadTask.TaskSnapshot snapshot,
      StorageException error) {
    channel.invokeMethod("StorageTaskEvent", buildMapFromTaskEvent(handle, type, snapshot, error));
  }

  private Map<String, Object> buildMapFromTaskEvent(
      int handle,
      StorageTaskEventType type,
      UploadTask.TaskSnapshot snapshot,
      StorageException error) {
    Map<String, Object> map = new HashMap<>();
    map.put("handle", handle);
    map.put("type", type.ordinal());
    map.put("snapshot", buildMapFromTaskSnapshot(snapshot, error));
    return map;
  }

  private Map<String, Object> buildMapFromTaskSnapshot(
      UploadTask.TaskSnapshot snapshot, StorageException error) {
    Map<String, Object> map = new HashMap<>();
    map.put("bytesTransferred", snapshot.getBytesTransferred());
    map.put("totalByteCount", snapshot.getTotalByteCount());
    if (snapshot.getUploadSessionUri() != null) {
      map.put("uploadSessionUri", snapshot.getUploadSessionUri().toString());
    }
    if (error != null) {
      map.put("error", error.getErrorCode());
    }
    if (snapshot.getMetadata() != null) {
      map.put("storageMetadata", buildMapFromMetadata(snapshot.getMetadata()));
    }
    return map;
  }
}
