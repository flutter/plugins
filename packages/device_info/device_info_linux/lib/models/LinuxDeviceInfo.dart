import 'CpuInfo.dart';
import 'MemInfo.dart';

/// Information derived from ` hostnamectl `
class LinuxDeviceInfo {
  LinuxDeviceInfo({
    this.memInfo,
    this.cpuInfo,
    this.architecture,
    this.hostname,
    this.kernel,
    this.os,
    this.iconName,
    this.chassis,
    this.machineId,
    this.bootId,
  });

  /// The current system hostname.
  final String hostname;

  /// The os of the system.
  final String os;

  /// The kernel version of the system.
  final String kernel;

  /// The architecture of the system.
  final String architecture;

  //// The name used by graphical applications to visualize the host.
  final String iconName;

  /// The chassis of the system.
  final String chassis;

  /// The machine-id of the system.
  final String machineId;

  /// The boot-id of the system.
  final String bootId;

  /// The memory information of the system using ` /proc/meminfo `
  final MemInfo memInfo;

  /// The CPU configuration of the system using ` lspci `
  final CpuInfo cpuInfo;

  /// Deserializes from the message received from [_Channel].
  static LinuxDeviceInfo fromMap(Map<String, dynamic> map) {
    return LinuxDeviceInfo(
      memInfo: MemInfo.fromMap(map['MemInfo']?.cast<String, dynamic>()),
      cpuInfo: CpuInfo.fromMap(map['CpuInfo']?.cast<String, dynamic>()),
      hostname: map["Static hostname"].toString().trim(),
      os: map['Operating System'].toString().trim(),
      kernel: map['Kernel'].toString().trim(),
      architecture: map['Architecture'].toString().trim(),
      iconName: map['Icon name'].toString().trim(),
      chassis: map['Chassis'].toString().trim(),
      machineId: map['Machine ID'].toString().trim(),
      bootId: map['Boot ID'].toString().trim(),
    );
  }
}
