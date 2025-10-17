import '../data/local/isar/isar_provider.dart';

Future<void> warmupIsar() async {
  // Kick off opening Isar without awaiting
  // ignore: unawaited_futures
  IsarDbProvider.instance.isar;
}
