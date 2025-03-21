// To parse this JSON data, do
//
//     final cpuStats = cpuStatsFromJson(jsonString);

import 'dart:convert';

CpuStats cpuStatsFromJson(String str) => CpuStats.fromJson(json.decode(str));

String cpuStatsToJson(CpuStats data) => json.encode(data.toJson());

class CpuStats {
    Cpu? cpu;
    Memory? memory;
    Disk? swap;
    Disk? disk;
    List<Network>? network;

    CpuStats({
        this.cpu,
        this.memory,
        this.swap,
        this.disk,
        this.network,
    });

    CpuStats copyWith({
        Cpu? cpu,
        Memory? memory,
        Disk? swap,
        Disk? disk,
        List<Network>? network,
    }) => 
        CpuStats(
            cpu: cpu ?? this.cpu,
            memory: memory ?? this.memory,
            swap: swap ?? this.swap,
            disk: disk ?? this.disk,
            network: network ?? this.network,
        );

    factory CpuStats.fromJson(Map<String, dynamic> json) => CpuStats(
        cpu: json["cpu"] == null ? null : Cpu.fromJson(json["cpu"]),
        memory: json["memory"] == null ? null : Memory.fromJson(json["memory"]),
        swap: json["swap"] == null ? null : Disk.fromJson(json["swap"]),
        disk: json["disk"] == null ? null : Disk.fromJson(json["disk"]),
        network: json["network"] == null ? [] : List<Network>.from(json["network"]!.map((x) => Network.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "cpu": cpu?.toJson(),
        "memory": memory?.toJson(),
        "swap": swap?.toJson(),
        "disk": disk?.toJson(),
        "network": network == null ? [] : List<dynamic>.from(network!.map((x) => x.toJson())),
    };
}

class Cpu {
    Total? total;
    List<Total>? cores;
    List<double>? load;

    Cpu({
        this.total,
        this.cores,
        this.load,
    });

    Cpu copyWith({
        Total? total,
        List<Total>? cores,
        List<double>? load,
    }) => 
        Cpu(
            total: total ?? this.total,
            cores: cores ?? this.cores,
            load: load ?? this.load,
        );

    factory Cpu.fromJson(Map<String, dynamic> json) => Cpu(
        total: json["total"] == null ? null : Total.fromJson(json["total"]),
        cores: json["cores"] == null ? [] : List<Total>.from(json["cores"]!.map((x) => Total.fromJson(x))),
        load: json["load"] == null ? [] : List<double>.from(json["load"]!.map((x) => x?.toDouble())),
    );

    Map<String, dynamic> toJson() => {
        "total": total?.toJson(),
        "cores": cores == null ? [] : List<dynamic>.from(cores!.map((x) => x.toJson())),
        "load": load == null ? [] : List<dynamic>.from(load!.map((x) => x)),
    };
}

class Total {
    String? name;
    String? usage;
    String? idle;
    String? ioWait;
    String? steal;

    Total({
        this.name,
        this.usage,
        this.idle,
        this.ioWait,
        this.steal,
    });

    Total copyWith({
        String? name,
        String? usage,
        String? idle,
        String? ioWait,
        String? steal,
    }) => 
        Total(
            name: name ?? this.name,
            usage: usage ?? this.usage,
            idle: idle ?? this.idle,
            ioWait: ioWait ?? this.ioWait,
            steal: steal ?? this.steal,
        );

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
    String? totalBytes;
    String? totalReadable;
    String? freeBytes;
    String? freeReadable;
    String? usedBytes;
    String? usedReadable;

    Disk({
        this.totalBytes,
        this.totalReadable,
        this.freeBytes,
        this.freeReadable,
        this.usedBytes,
        this.usedReadable,
    });

    Disk copyWith({
        String? totalBytes,
        String? totalReadable,
        String? freeBytes,
        String? freeReadable,
        String? usedBytes,
        String? usedReadable,
    }) => 
        Disk(
            totalBytes: totalBytes ?? this.totalBytes,
            totalReadable: totalReadable ?? this.totalReadable,
            freeBytes: freeBytes ?? this.freeBytes,
            freeReadable: freeReadable ?? this.freeReadable,
            usedBytes: usedBytes ?? this.usedBytes,
            usedReadable: usedReadable ?? this.usedReadable,
        );

    factory Disk.fromJson(Map<String, dynamic> json) => Disk(
        totalBytes: json["total_bytes"],
        totalReadable: json["total_readable"],
        freeBytes: json["free_bytes"],
        freeReadable: json["free_readable"],
        usedBytes: json["used_bytes"],
        usedReadable: json["used_readable"],
    );

    Map<String, dynamic> toJson() => {
        "total_bytes": totalBytes,
        "total_readable": totalReadable,
        "free_bytes": freeBytes,
        "free_readable": freeReadable,
        "used_bytes": usedBytes,
        "used_readable": usedReadable,
    };
}

class Memory {
    String? totalBytes;
    String? totalReadable;
    String? freeBytes;
    String? freeReadable;
    String? buffersBytes;
    String? buffersReadable;
    String? cachedBytes;
    String? cachedReadable;
    String? sReclaimableBytes;
    String? sReclaimableReadable;
    String? shmemBytes;
    String? shmemReadable;
    String? usedBytes;
    String? usedReadable;

    Memory({
        this.totalBytes,
        this.totalReadable,
        this.freeBytes,
        this.freeReadable,
        this.buffersBytes,
        this.buffersReadable,
        this.cachedBytes,
        this.cachedReadable,
        this.sReclaimableBytes,
        this.sReclaimableReadable,
        this.shmemBytes,
        this.shmemReadable,
        this.usedBytes,
        this.usedReadable,
    });

    Memory copyWith({
        String? totalBytes,
        String? totalReadable,
        String? freeBytes,
        String? freeReadable,
        String? buffersBytes,
        String? buffersReadable,
        String? cachedBytes,
        String? cachedReadable,
        String? sReclaimableBytes,
        String? sReclaimableReadable,
        String? shmemBytes,
        String? shmemReadable,
        String? usedBytes,
        String? usedReadable,
    }) => 
        Memory(
            totalBytes: totalBytes ?? this.totalBytes,
            totalReadable: totalReadable ?? this.totalReadable,
            freeBytes: freeBytes ?? this.freeBytes,
            freeReadable: freeReadable ?? this.freeReadable,
            buffersBytes: buffersBytes ?? this.buffersBytes,
            buffersReadable: buffersReadable ?? this.buffersReadable,
            cachedBytes: cachedBytes ?? this.cachedBytes,
            cachedReadable: cachedReadable ?? this.cachedReadable,
            sReclaimableBytes: sReclaimableBytes ?? this.sReclaimableBytes,
            sReclaimableReadable: sReclaimableReadable ?? this.sReclaimableReadable,
            shmemBytes: shmemBytes ?? this.shmemBytes,
            shmemReadable: shmemReadable ?? this.shmemReadable,
            usedBytes: usedBytes ?? this.usedBytes,
            usedReadable: usedReadable ?? this.usedReadable,
        );

    factory Memory.fromJson(Map<String, dynamic> json) => Memory(
        totalBytes: json["total_bytes"],
        totalReadable: json["total_readable"],
        freeBytes: json["free_bytes"],
        freeReadable: json["free_readable"],
        buffersBytes: json["buffers_bytes"],
        buffersReadable: json["buffers_readable"],
        cachedBytes: json["cached_bytes"],
        cachedReadable: json["cached_readable"],
        sReclaimableBytes: json["sReclaimable_bytes"],
        sReclaimableReadable: json["sReclaimable_readable"],
        shmemBytes: json["shmem_bytes"],
        shmemReadable: json["shmem_readable"],
        usedBytes: json["used_bytes"],
        usedReadable: json["used_readable"],
    );

    Map<String, dynamic> toJson() => {
        "total_bytes": totalBytes,
        "total_readable": totalReadable,
        "free_bytes": freeBytes,
        "free_readable": freeReadable,
        "buffers_bytes": buffersBytes,
        "buffers_readable": buffersReadable,
        "cached_bytes": cachedBytes,
        "cached_readable": cachedReadable,
        "sReclaimable_bytes": sReclaimableBytes,
        "sReclaimable_readable": sReclaimableReadable,
        "shmem_bytes": shmemBytes,
        "shmem_readable": shmemReadable,
        "used_bytes": usedBytes,
        "used_readable": usedReadable,
    };
}

class Network {
    String? interfaceName;
    Received? received;
    Received? transmitted;

    Network({
        this.interfaceName,
        this.received,
        this.transmitted,
    });

    Network copyWith({
        String? interfaceName,
        Received? received,
        Received? transmitted,
    }) => 
        Network(
            interfaceName: interfaceName ?? this.interfaceName,
            received: received ?? this.received,
            transmitted: transmitted ?? this.transmitted,
        );

    factory Network.fromJson(Map<String, dynamic> json) => Network(
        interfaceName: json["interface_name"],
        received: json["received"] == null ? null : Received.fromJson(json["received"]),
        transmitted: json["transmitted"] == null ? null : Received.fromJson(json["transmitted"]),
    );

    Map<String, dynamic> toJson() => {
        "interface_name": interfaceName,
        "received": received?.toJson(),
        "transmitted": transmitted?.toJson(),
    };
}

class Received {
    String? speedBytes;
    String? speedReadable;
    String? packets;
    String? errs;
    String? drop;
    String? fifo;
    String? frame;
    String? compressed;
    String? multicast;
    String? carrier;

    Received({
        this.speedBytes,
        this.speedReadable,
        this.packets,
        this.errs,
        this.drop,
        this.fifo,
        this.frame,
        this.compressed,
        this.multicast,
        this.carrier,
    });

    Received copyWith({
        String? speedBytes,
        String? speedReadable,
        String? packets,
        String? errs,
        String? drop,
        String? fifo,
        String? frame,
        String? compressed,
        String? multicast,
        String? carrier,
    }) => 
        Received(
            speedBytes: speedBytes ?? this.speedBytes,
            speedReadable: speedReadable ?? this.speedReadable,
            packets: packets ?? this.packets,
            errs: errs ?? this.errs,
            drop: drop ?? this.drop,
            fifo: fifo ?? this.fifo,
            frame: frame ?? this.frame,
            compressed: compressed ?? this.compressed,
            multicast: multicast ?? this.multicast,
            carrier: carrier ?? this.carrier,
        );

    factory Received.fromJson(Map<String, dynamic> json) => Received(
        speedBytes: json["speed_bytes"],
        speedReadable: json["speed_readable"],
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
        "speed_bytes": speedBytes,
        "speed_readable": speedReadable,
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
