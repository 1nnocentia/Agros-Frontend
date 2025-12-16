import 'auth_repository.dart';
import 'lahan_repository.dart';
import 'master_repository.dart';
import 'panen_repository.dart';
import 'tanam_repository.dart';

class AgrosRepository {
  final AuthRepository auth = AuthRepository();
  final MasterRepository master = MasterRepository();
  final LahanRepository lahan = LahanRepository();
  final TanamRepository tanam = TanamRepository();
  final PanenRepository panen = PanenRepository();
}
