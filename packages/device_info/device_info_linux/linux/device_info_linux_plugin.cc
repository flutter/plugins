#include "include/device_info_linux/device_info_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <sys/sysinfo.h>
#include <bits/stdc++.h>
using namespace std;

#define DEVICE_INFO_LINUX_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), device_info_linux_plugin_get_type(), \
                              DeviceInfoLinuxPlugin))

struct _DeviceInfoLinuxPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(DeviceInfoLinuxPlugin, device_info_linux_plugin, g_object_get_type())

const string WHITESPACE = " \n\r\t\f\v";

string ltrim(const string& s)
{
    size_t start = s.find_first_not_of(WHITESPACE);
    return (start == string::npos) ? "" : s.substr(start);
}

string rtrim(const string& s)
{
    size_t end = s.find_last_not_of(WHITESPACE);
    return (end == string::npos) ? "" : s.substr(0, end + 1);
}

string trim(const string& s)
{
    return rtrim(ltrim(s));
}

// Called when a method call is received from Flutter.
static void device_info_linux_plugin_handle_method_call(
    DeviceInfoLinuxPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  // linuxInfo method channel call from Flutter.
    if (strcmp(method, "getLinuxInfo") == 0)
    {
        // Creating a new FlValue map.
        g_autoptr(FlValue) linuxDeviceInfo = fl_value_new_map();

        // parsing values from /proc/meminfo
        g_autoptr(FlValue) linuxMemInfo = fl_value_new_map();
        string command = "cat /proc/meminfo", meminfo = "MemInfo";
        char buffer[256];
        FILE* pipe = popen(command.c_str(), "r");
        while (!feof(pipe))
        {
            if (fgets(buffer, 128, pipe) != NULL)
            {
                string value = "", name = "";
                bool flag = true;
                for (int i = 0; i < strlen(buffer); i++)
                {
                    if (buffer[i] == ':') {
                        flag = false;
                        continue;
                    }
                    if (flag)
                        name += buffer[i];
                    if (!flag)
                        value += buffer[i];
                }
                name = trim(name);
                value = trim(value);
                fl_value_set_string_take(linuxMemInfo, name.c_str(), fl_value_new_string(value.c_str()));
            }
        }
        pclose(pipe);
        // Setting a FlValue map in the value of another map.
        fl_value_set(linuxDeviceInfo, fl_value_new_string(meminfo.c_str()), linuxMemInfo);

        // parsing host information from hostnamectl command's output
        command = "hostnamectl";
        pipe = popen(command.c_str(), "r");
        while (!feof(pipe))
        {
            if (fgets(buffer, 128, pipe) != NULL)
            {
                string value = "", name = "";
                bool flag = true;
                for (int i = 0; i < strlen(buffer); i++)
                {
                    if (buffer[i] == ':') {
                        flag = false;
                        continue;
                    }
                    if (flag)
                        name += buffer[i];
                    if (!flag)
                        value += buffer[i];
                }
                name = trim(name);
                value = trim(value);
                fl_value_set_string_take(linuxDeviceInfo, name.c_str(), fl_value_new_string(value.c_str()));
            }
        }
        pclose(pipe);

        // parsing cpu info from lspci command's output
        command = "lspci";
        string cpuInfo="CpuInfo";
        g_autoptr(FlValue) linuxCpuInfo = fl_value_new_map();
        pipe = popen(command.c_str(), "r");
        while (!feof(pipe))
        {
            if (fgets(buffer, 128, pipe) != NULL)
            {
                string value = "", name = "";
                bool flag = true;
                for (int i = 7; i < strlen(buffer); i++)
                {
                    if (buffer[i] == ':') {
                        flag = false;
                        continue;
                    }
                    if (flag)
                        name += buffer[i];
                    if (!flag)
                        value += buffer[i];
                }
                name = trim(name);
                value = trim(value);
                fl_value_set_string_take(linuxCpuInfo, name.c_str(), fl_value_new_string(value.c_str()));
            }
        }
        pclose(pipe);
        fl_value_set(linuxDeviceInfo, fl_value_new_string(cpuInfo.c_str()), linuxCpuInfo);

        response = FL_METHOD_RESPONSE(fl_method_success_response_new(linuxDeviceInfo));
    } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void device_info_linux_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(device_info_linux_plugin_parent_class)->dispose(object);
}

static void device_info_linux_plugin_class_init(DeviceInfoLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = device_info_linux_plugin_dispose;
}

static void device_info_linux_plugin_init(DeviceInfoLinuxPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  DeviceInfoLinuxPlugin* plugin = DEVICE_INFO_LINUX_PLUGIN(user_data);
  device_info_linux_plugin_handle_method_call(plugin, method_call);
}

void device_info_linux_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  DeviceInfoLinuxPlugin* plugin = DEVICE_INFO_LINUX_PLUGIN(
      g_object_new(device_info_linux_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "plugins.flutter.io/device_info",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
