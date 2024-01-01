import 'dart:convert';

CpuStats cpuStatsFromJson(String str) => CpuStats.fromJson(json.decode(str));

String cpuStatsToJson(CpuStats data) => json.encode(data.toJson());

class CpuStats {
    Cpu cpu;
    Memory memory;
    Disk swap;
    Disk disk;
    List<Network> network;

    CpuStats({
        required this.cpu,
        required this.memory,
        required this.swap,
        required this.disk,
        required this.network,
    });

    factory CpuStats.fromJson(Map<String, dynamic> json) => CpuStats(
        cpu: Cpu.fromJson(json["cpu"]),
        memory: Memory.fromJson(json["memory"]),
        swap: Disk.fromJson(json["swap"]),
        disk: Disk.fromJson(json["disk"]),
        network: List<Network>.from(json["network"].map((x) => Network.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "cpu": cpu.toJson(),
        "memory": memory.toJson(),
        "swap": swap.toJson(),
        "disk": disk.toJson(),
        "network": List<dynamic>.from(network.map((x) => x.toJson())),
    };
}

class Cpu {
    Total total;
    List<Total> cores;
    List<double> load;

    Cpu({
        required this.total,
        required this.cores,
        required this.load,
    });

    factory Cpu.fromJson(Map<String, dynamic> json) => Cpu(
        total: Total.fromJson(json["total"]),
        cores: List<Total>.from(json["cores"].map((x) => Total.fromJson(x))),
        load: List<double>.from(json["load"].map((x) => x?.toDouble())),
    );

    Map<String, dynamic> toJson() => {
        "total": total.toJson(),
        "cores": List<dynamic>.from(cores.map((x) => x.toJson())),
        "load": List<dynamic>.from(load.map((x) => x)),
    };
}

class Total {
    String name;
    String usage;
    String idle;
    String ioWait;
    String steal;

    Total({
        required this.name,
        required this.usage,
        required this.idle,
        required this.ioWait,
        required this.steal,
    });

    factory Total.fromJson(Map<String, dynamic> json) => Total(
        name: json["name"],
        usage: json["usage"],
        idle: json["idle"],
        ioWait: json["io_wait"],
        steal: json["steal"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "usage": usage,
        "idle": idle,
        "io_wait": ioWait,
        "steal": steal,
    };
}

class Disk {
    DiskBytes bytes;
    DiskBytes readable;

    Disk({
        required this.bytes,
        required this.readable,
    });

    factory Disk.fromJson(Map<String, dynamic> json) => Disk(
        bytes: DiskBytes.fromJson(json["bytes"]),
        readable: DiskBytes.fromJson(json["readable"]),
    );

    Map<String, dynamic> toJson() => {
        "bytes": bytes.toJson(),
        "readable": readable.toJson(),
    };
}

class DiskBytes {
    String total;
    String free;
    String used;

    DiskBytes({
        required this.total,
        required this.free,
        required this.used,
    });

    factory DiskBytes.fromJson(Map<String, dynamic> json) => DiskBytes(
        total: json["total"],
        free: json["free"],
        used: json["used"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "free": free,
        "used": used,
    };
}

class Memory {
    MemoryBytes bytes;
    MemoryBytes readable;

    Memory({
        required this.bytes,
        required this.readable,
    });

    factory Memory.fromJson(Map<String, dynamic> json) => Memory(
        bytes: MemoryBytes.fromJson(json["bytes"]),
        readable: MemoryBytes.fromJson(json["readable"]),
    );

    Map<String, dynamic> toJson() => {
        "bytes": bytes.toJson(),
        "readable": readable.toJson(),
    };
}

class MemoryBytes {
    String total;
    String free;
    String buffers;
    String cached;
    String sReclaimable;
    String shmem;
    String used;

    MemoryBytes({
        required this.total,
        required this.free,
        required this.buffers,
        required this.cached,
        required this.sReclaimable,
        required this.shmem,
        required this.used,
    });

    factory MemoryBytes.fromJson(Map<String, dynamic> json) => MemoryBytes(
        total: json["total"],
        free: json["free"],
        buffers: json["buffers"],
        cached: json["cached"],
        sReclaimable: json["sReclaimable"],
        shmem: json["shmem"],
        used: json["used"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "free": free,
        "buffers": buffers,
        "cached": cached,
        "sReclaimable": sReclaimable,
        "shmem": shmem,
        "used": used,
    };
}

class Network {
    String interfaceName;
    Received received;
    Received transmitted;

    Network({
        required this.interfaceName,
        required this.received,
        required this.transmitted,
    });

    factory Network.fromJson(Map<String, dynamic> json) => Network(
        interfaceName: json["interface_name"],
        received: Received.fromJson(json["received"]),
        transmitted: Received.fromJson(json["transmitted"]),
    );

    Map<String, dynamic> toJson() => {
        "interface_name": interfaceName,
        "received": received.toJson(),
        "transmitted": transmitted.toJson(),
    };
}

class Received {
    Speed speed;
    String packets;
    String errs;
    String drop;
    String fifo;
    String frame;
    String compressed;
    String? multicast;
    String? carrier;

    Received({
        required this.speed,
        required this.packets,
        required this.errs,
        required this.drop,
        required this.fifo,
        required this.frame,
        required this.compressed,
        this.multicast,
        this.carrier,
    });

    factory Received.fromJson(Map<String, dynamic> json) => Received(
        speed: Speed.fromJson(json["speed"]),
        packets: json["packets"],
        errs: json["errs"],
        drop: json["drop"],
        fifo: json["fifo"],
        frame: json["frame"],
        compressed: json["compressed"],
        multicast: json["multicast"],
        carrier: json["carrier"],
    );

    Map<String, dynamic> toJson() => {
        "speed": speed.toJson(),
        "packets": packets,
        "errs": errs,
        "drop": drop,
        "fifo": fifo,
        "frame": frame,
        "compressed": compressed,
        "multicast": multicast,
        "carrier": carrier,
    };
}

class Speed {
    String bytes;
    String readable;

    Speed({
        required this.bytes,
        required this.readable,
    });

    factory Speed.fromJson(Map<String, dynamic> json) => Speed(
        bytes: json["bytes"],
        readable: json["readable"],
    );

    Map<String, dynamic> toJson() => {
        "bytes": bytes,
        "readable": readable,
    };
}
