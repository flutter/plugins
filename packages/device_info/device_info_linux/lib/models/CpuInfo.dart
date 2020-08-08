/// Information derived from ` lspci `
class CpuInfo {
  CpuInfo({
    this.hostBridge,
    this.pciBridge,
    this.vgaCompatibleController,
    this.signalProcessingController,
    this.usbController,
    this.ramMemory,
    this.networkController,
    this.communicationController,
    this.sataController,
    this.isaBridge,
    this.audioDevice,
    this.smBus,
    this.serialBusController,
    this.gpuController,
    this.ethernetController,
  });

  /// The Cpu of the system.
  final String hostBridge;

  /// The pci bridge of the system.
  final String pciBridge;

  /// The VGA Compatible Controller.
  final String vgaCompatibleController;

  /// The Signal Processing Controller.
  final String signalProcessingController;

  /// The USB Controller.
  final String usbController;

  /// The RAM Memory.
  final String ramMemory;

  /// The Network Controller.
  final String networkController;

  /// The Communication Controller.
  final String communicationController;

  /// The SATA Controller.
  final String sataController;

  /// The ISA Bridge.
  final String isaBridge;

  /// The Audio Device in the system.
  final String audioDevice;

  /// The Sm Bus.
  final String smBus;

  /// The Serial Bus Controller.
  final String serialBusController;

  /// The GPU in the system.
  final String gpuController;

  /// The Ethernet Controller.
  final String ethernetController;

  /// Deserializes from the message received from [_Channel].
  static CpuInfo fromMap(Map<String, dynamic> map) {
    return CpuInfo(
      hostBridge: map["Host bridge"],
      pciBridge: map["PCI bridge"],
      vgaCompatibleController: map["VGA compatible controller"],
      signalProcessingController: map["Signal processing controller"],
      usbController: map["USB controller"],
      ramMemory: map["RAM memory"],
      networkController: map["Network controller"],
      communicationController: map["Communication controller"],
      sataController: map["SATA controller"],
      isaBridge: map["ISA bridge"],
      audioDevice: map["Audio device"],
      smBus: map["SMBus"],
      serialBusController: map["Serial bus controller [0c80]"],
      gpuController: map["3D controller"],
      ethernetController: map["Ethernet controller"],
    );
  }
}
