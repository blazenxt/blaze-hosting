class BlazeServer {
  const BlazeServer({
    required this.id,
    required this.uuid,
    required this.name,
    required this.node,
    required this.memoryMb,
    required this.diskMb,
    required this.description,
  });

  final String id;
  final String uuid;
  final String name;
  final String node;
  final int memoryMb;
  final int diskMb;
  final String description;

  factory BlazeServer.fromJson(Map<String, dynamic> json) {
    final a = (json['attributes'] as Map?)?.cast<String, dynamic>() ?? json;
    final limits = (a['limits'] as Map?)?.cast<String, dynamic>() ?? {};
    return BlazeServer(
      id: '${a['identifier'] ?? ''}',
      uuid: '${a['uuid'] ?? ''}',
      name: '${a['name'] ?? 'Server'}',
      node: '${a['node'] ?? ''}',
      memoryMb: int.tryParse('${limits['memory'] ?? 0}') ?? 0,
      diskMb: int.tryParse('${limits['disk'] ?? 0}') ?? 0,
      description: '${a['description'] ?? ''}',
    );
  }
}

class BlazeResources {
  const BlazeResources({required this.state, required this.memoryBytes, required this.cpu});

  final String state;
  final int memoryBytes;
  final double cpu;
}
