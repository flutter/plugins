#include "include/file_selector_linux/file_selector_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <glib.h>
#include <glib/gi18n.h>
#include <glib/gprintf.h>
#include <gtk/gtk.h>

#define FILE_SELECTOR_LINUX_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), file_selector_linux_plugin_get_type(), \
                              FileSelectorLinuxPlugin))

struct _FileSelectorLinuxPlugin {
  GObject parent_instance;
  FlView* view;
};

G_DEFINE_TYPE(FileSelectorLinuxPlugin, file_selector_linux_plugin,
              g_object_get_type())

static bool fl_value_is_valid(FlValue* value, FlValueType type) {
  return value && fl_value_get_type(value) == type;
}

static void fl_value_list_for_each(FlValue* list, GFunc func,
                                   gpointer user_data) {
  g_return_if_fail(func != nullptr);
  if (!list || fl_value_get_type(list) != FL_VALUE_TYPE_LIST) {
    return;
  }

  size_t length = fl_value_get_length(list);
  for (size_t j = 0; j < length; ++j) {
    FlValue* value = fl_value_get_list_value(list, j);
    func(value, user_data);
  }
}

static FlValue* file_chooser_get_filename(GtkFileChooser* chooser) {
  gchar* filename = gtk_file_chooser_get_filename(chooser);
  FlValue* value = fl_value_new_string(filename);
  g_free(filename);
  return value;
}

static FlValue* file_chooser_get_filenames(GtkFileChooser* chooser) {
  FlValue* value = fl_value_new_list();
  GSList* filenames = gtk_file_chooser_get_filenames(chooser);
  while (filenames) {
    const gchar* filename = static_cast<const gchar*>(filenames->data);
    fl_value_append_take(value, fl_value_new_string(filename));
    filenames = filenames->next;
  }
  g_slist_free(filenames);
  return value;
}

static void file_filter_add_pattern(gpointer data, gpointer user_data) {
  FlValue* value = static_cast<FlValue*>(data);
  if (fl_value_is_valid(value, FL_VALUE_TYPE_STRING)) {
    gchar* pattern = g_strdup_printf("*.%s", fl_value_get_string(value));
    gtk_file_filter_add_pattern(GTK_FILE_FILTER(user_data), pattern);
    g_free(pattern);
  }
}

static void file_filter_add_mime_type(gpointer data, gpointer user_data) {
  FlValue* value = static_cast<FlValue*>(data);
  if (fl_value_is_valid(value, FL_VALUE_TYPE_STRING)) {
    gtk_file_filter_add_mime_type(GTK_FILE_FILTER(user_data),
                                  fl_value_get_string(value));
  }
}

static void file_chooser_add_filter(gpointer data, gpointer user_data) {
  FlValue* type = static_cast<FlValue*>(data);
  if (fl_value_is_valid(type, FL_VALUE_TYPE_MAP)) {
    GtkFileFilter* filter = gtk_file_filter_new();

    FlValue* label = fl_value_lookup_string(type, "label");
    if (fl_value_is_valid(label, FL_VALUE_TYPE_STRING)) {
      gtk_file_filter_set_name(filter, fl_value_get_string(label));
    }

    FlValue* extensions = fl_value_lookup_string(type, "extensions");
    fl_value_list_for_each(extensions, file_filter_add_pattern, filter);

    FlValue* mime_types = fl_value_lookup_string(type, "mimeTypes");
    fl_value_list_for_each(mime_types, file_filter_add_mime_type, filter);

    gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(user_data), filter);
  }
}

static FlMethodResponse* file_chooser_show(GtkFileChooserAction action,
                                           FlValue* args, FlView* view) {
  FlMethodResponse* response = nullptr;

  const gchar* accept_label = _("_Open");
  FlValue* confirm = fl_value_lookup_string(args, "confirmButtonText");
  if (fl_value_is_valid(confirm, FL_VALUE_TYPE_STRING)) {
    accept_label = fl_value_get_string(confirm);
  }

  GtkWidget* parent_window = gtk_widget_get_toplevel(GTK_WIDGET(view));
  GtkWidget* dialog = gtk_file_chooser_dialog_new(
      NULL, GTK_WINDOW(parent_window), action, _("_Cancel"),
      GTK_RESPONSE_CANCEL, accept_label, GTK_RESPONSE_ACCEPT, NULL);

  GtkFileChooser* chooser = GTK_FILE_CHOOSER(dialog);

  FlValue* types = fl_value_lookup_string(args, "acceptedTypeGroups");
  fl_value_list_for_each(types, file_chooser_add_filter, chooser);

  FlValue* dir = fl_value_lookup_string(args, "initialDirectory");
  if (fl_value_is_valid(dir, FL_VALUE_TYPE_STRING)) {
    gtk_file_chooser_set_current_folder(chooser, fl_value_get_string(dir));
  }

  FlValue* multiple = fl_value_lookup_string(args, "multiple");
  if (fl_value_is_valid(multiple, FL_VALUE_TYPE_BOOL)) {
    gtk_file_chooser_set_select_multiple(chooser, fl_value_get_bool(multiple));
  }

  FlValue* name = fl_value_lookup_string(args, "suggestedName");
  if (fl_value_is_valid(name, FL_VALUE_TYPE_STRING)) {
    gtk_file_chooser_set_current_name(chooser, fl_value_get_string(name));
  }

  gint res = gtk_dialog_run(GTK_DIALOG(dialog));
  if (res == GTK_RESPONSE_ACCEPT) {
    if (action == GTK_FILE_CHOOSER_ACTION_OPEN) {
      FlValue* filenames = file_chooser_get_filenames(chooser);
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(filenames));
    } else {
      FlValue* filename = file_chooser_get_filename(chooser);
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(filename));
    }
  } else {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }

  gtk_widget_destroy(dialog);
  return response;
}

static void file_selector_linux_plugin_handle_method_call(
    FileSelectorLinuxPlugin* self, FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  static const GtkFileChooserAction none = GtkFileChooserAction(-1);
  GtkFileChooserAction action = none;
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "openFile") == 0 || strcmp(method, "openFiles") == 0) {
    action = GTK_FILE_CHOOSER_ACTION_OPEN;
  } else if (strcmp(method, "getSavePath") == 0) {
    action = GTK_FILE_CHOOSER_ACTION_SAVE;
  } else if (strcmp(method, "getDirectoryPath") == 0) {
    action = GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER;
  }

  if (action != none) {
    FlValue* args = fl_method_call_get_args(method_call);
    response = file_chooser_show(action, args, self->view);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void file_selector_linux_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(file_selector_linux_plugin_parent_class)->dispose(object);
}

static void file_selector_linux_plugin_class_init(
    FileSelectorLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = file_selector_linux_plugin_dispose;
}

static void file_selector_linux_plugin_init(FileSelectorLinuxPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  FileSelectorLinuxPlugin* plugin = FILE_SELECTOR_LINUX_PLUGIN(user_data);
  file_selector_linux_plugin_handle_method_call(plugin, method_call);
}

void file_selector_linux_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  FileSelectorLinuxPlugin* plugin = FILE_SELECTOR_LINUX_PLUGIN(
      g_object_new(file_selector_linux_plugin_get_type(), nullptr));
  plugin->view = fl_plugin_registrar_get_view(registrar);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      "plugins.flutter.io/file_selector", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
