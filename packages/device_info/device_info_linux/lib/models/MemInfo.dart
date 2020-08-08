/// Information derived from ` proc/meminfo`
class MemInfo {
  MemInfo({
    this.memTotal,
    this.memFree,
    this.memAvailable,
    this.buffers,
    this.cached,
    this.swapCached,
    this.active,
    this.inactive,
    this.activeAnon,
    this.inactiveAnon,
    this.activeFile,
    this.inactiveFile,
    this.unevictable,
    this.mLocked,
    this.swapTotal,
    this.swapFree,
    this.dirty,
    this.writeBack,
    this.anonPages,
    this.mapped,
    this.shmem,
    this.kReclaimable,
    this.sLab,
    this.sReclaimable,
    this.sUnreclaim,
    this.kernelStack,
    this.pageTables,
    this.nfsUnstable,
    this.bounce,
    this.writeBackTmp,
    this.commitLimit,
    this.committedAs,
    this.vMallocTotal,
    this.vMallocUsed,
    this.vMallocChunk,
    this.perCpu,
    this.hardwareCorrupted,
    this.anonHugePages,
    this.shmemHugePages,
    this.shmemPmdMapped,
    this.fileHugePages,
    this.filePmdMapped,
    this.hugePagesTotal,
    this.hugePagesFree,
    this.hugePagesRsvd,
    this.hugePagesSurp,
    this.hugePagesSize,
    this.hugeTlb,
    this.directMap4K,
    this.directMap2M,
    this.directMap1G,
  });

  /// Total ram of the system
  final String memTotal;

  /// Free ram in the system.
  final String memFree;

  /// Available ram in the system.
  final String memAvailable;

  /// Buffers in system.
  final String buffers;

  /// Cached memory.
  final String cached;

  /// Swap Cached memory.
  final String swapCached;

  /// Active Memory
  final String active;

  /// Inactive memory
  final String inactive;

  /// Active-anon
  final String activeAnon;

  /// Inactive-anon
  final String inactiveAnon;

  /// Active (file)
  final String activeFile;

  /// Inactive (file)
  final String inactiveFile;

  /// Enevictabele memory.
  final String unevictable;

  /// M-locked
  final String mLocked;

  /// Total Swap memory.
  final String swapTotal;

  /// Free Swap memory.
  final String swapFree;

  /// Dirty Memory.
  final String dirty;

  /// Write-back memory.
  final String writeBack;

  /// Anon-pages
  final String anonPages;

  /// Mapped memory.
  final String mapped;

  /// Shmem.
  final String shmem;

  /// K-reclaimable
  final String kReclaimable;

  /// S-lab
  final String sLab;

  /// S-reclaimable
  final String sReclaimable;

  /// S-unreclaim
  final String sUnreclaim;

  /// Kernel Stack
  final String kernelStack;

  /// Page Tables
  final String pageTables;

  /// NFS-unstable
  final String nfsUnstable;

  /// Bounce
  final String bounce;

  /// Write-back Temp
  final String writeBackTmp;

  /// Commit Limit
  final String commitLimit;

  /// Committed_AS
  final String committedAs;

  /// V-malloc total
  final String vMallocTotal;

  /// V-malloc Used
  final String vMallocUsed;

  /// V-malloc Chunk
  final String vMallocChunk;

  /// Per-cpu
  final String perCpu;

  /// Hardware Corrupted
  final String hardwareCorrupted;

  /// Anon Huge Pages
  final String anonHugePages;

  ///Shmem Huge Pages
  final String shmemHugePages;

  /// Shmem Pmd Mapped
  final String shmemPmdMapped;

  /// File HUge Pages
  final String fileHugePages;

  /// File Pmd Mapped
  final String filePmdMapped;

  /// Huge Pages Total
  final String hugePagesTotal;

  /// Huge Pages Free
  final String hugePagesFree;

  /// Huge Pages RSVD
  final String hugePagesRsvd;

  /// Huge Pages SURP
  final String hugePagesSurp;

  /// Huge Pages Size
  final String hugePagesSize;

  /// Huge TLB
  final String hugeTlb;

  /// Direct Map 4k
  final String directMap4K;

  /// Direct Map 2M
  final String directMap2M;

  /// Direct Mao 1G
  final String directMap1G;

  /// Deserializes from the message received from [_Channel].
  static MemInfo fromMap(Map<String, dynamic> map) {
    return MemInfo(
      memTotal: map["MemTotal"],
      memFree: map['MemFree'],
      memAvailable: map['MemAvailable'],
      buffers: map['Buffers'],
      cached: map['Cached'],
      swapCached: map['SwapCached'],
      active: map['Active'],
      inactive: map['Inactive'],
      activeAnon: map['Active(anon)'],
      inactiveAnon: map['Inactive(anon)'],
      activeFile: map['Active(file)'],
      inactiveFile: map['Inactive(file)'],
      unevictable: map['Unevictable'],
      mLocked: map['Mlocked'],
      swapTotal: map['SwapTotal'],
      swapFree: map['SwapFree'],
      dirty: map['Dirty'],
      writeBack: map['Writeback'],
      anonPages: map['AnonPages'],
      mapped: map['Mapped'],
      shmem: map['Shmem'],
      kReclaimable: map['KReclaimable'],
      sLab: map['Slab'],
      sReclaimable: map['SReclaimable'],
      sUnreclaim: map['SUnreclaim'],
      kernelStack: map['KernelStack'],
      pageTables: map['PageTables'],
      nfsUnstable: map['NFS_Unstable'],
      bounce: map['Bounce'],
      writeBackTmp: map['WritebackTmp'],
      commitLimit: map['CommitLimit'],
      committedAs: map['Committed_AS'],
      vMallocTotal: map['VmallocTotal'],
      vMallocUsed: map['VmallocUsed'],
      vMallocChunk: map['VmallocChunk'],
      perCpu: map['Percpu'],
      hardwareCorrupted: map['HardwareCorrupted'],
      anonHugePages: map['AnonHugePages'],
      shmemHugePages: map['ShmemHugePages'],
      shmemPmdMapped: map['ShmemPmdMapped'],
      fileHugePages: map['FileHugePages'],
      filePmdMapped: map['FilePmdMapped'],
      hugePagesTotal: map['HugePages_Total'],
      hugePagesFree: map['HugePages_Free'],
      hugePagesRsvd: map['HugePages_Rsvd'],
      hugePagesSurp: map['HugePages_Surp'],
      hugePagesSize: map['Hugepagesize'],
      hugeTlb: map['Hugetlb'],
      directMap4K: map['DirectMap4k'],
      directMap2M: map['DirectMap2M'],
      directMap1G: map['DirectMap1G'],
    );
  }
}
