//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <device_info_linux/device_info_linux_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) device_info_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DeviceInfoLinuxPlugin");
  device_info_linux_plugin_register_with_registrar(device_info_linux_registrar);
}
