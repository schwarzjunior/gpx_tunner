import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';

mixin _AppPermissionsList {
  List<AppPermissionData> _permissions = [
    AppPermissionData(PermissionGroup.storage),
  ];
}

class AppPermissionsBloc extends BlocBase with _AppPermissionsList {
  static const AppPermissionsState initialState = AppPermissionsState.CHECKING_ALL;

  final _permissionsController = BehaviorSubject<List<AppPermissionData>>();
  final _stateController = BehaviorSubject<AppPermissionsState>();

  Stream<List<AppPermissionData>> get outPermissions => _permissionsController.stream;

  Stream<AppPermissionsState> get outState => _stateController.stream;

  AppPermissionsState _state;

  AppPermissionsBloc() : _state = AppPermissionsState.CHECKING_ALL {
//    _changeState(_state);
    checkAllPermissions(changeState: false);
  }

  void sendState() => _changeState(_state);

  void _changeState(AppPermissionsState state) => _stateController.sink.add(state);

  /// Checa todas as permissoes requeridas pelo app.
  Future<void> checkAllPermissions({bool changeState = true}) async {
    if (_state != AppPermissionsState.CHECKING_ALL)
      _changeState(AppPermissionsState.CHECKING_ALL);

    bool hasFailed = false;
    for (AppPermissionData permData in _permissions) {
      await _checkPermission(permData).then((granted) {
        hasFailed = hasFailed || !granted;
      });
    }

    _state = hasFailed ? AppPermissionsState.FAIL : AppPermissionsState.SUCCESS;
    if (changeState) {
      Future.delayed(Duration(seconds: 1)).whenComplete(() {
        _changeState(_state);
      });
    }
  }

  /// Requisita todas as permissoes requeridas pelo app.
  Future<void> requestAllPermissions() async {
    bool hasFailed = false;

    for (AppPermissionData permData in _permissions.where((p) => !p.granted).toList()) {
      final status = await _requestPermission(permData);
      hasFailed = hasFailed || status != PermissionStatus.granted;
    }

    _changeState(hasFailed ? AppPermissionsState.FAIL : AppPermissionsState.SUCCESS);
  }

  /// Checa o status da permissao em [permData].
  Future<bool> _checkPermission(AppPermissionData permData) async {
    permData._status = await PermissionHandler()
        .checkPermissionStatus(permData.group)
        .then((status) => status);
    return permData.granted;
  }

  /// Requisita a permissao em [permData], e retorna o [PermissionStatus] resultante.
  Future<PermissionStatus> _requestPermission(AppPermissionData permData) async {
    final Map<PermissionGroup, PermissionStatus> status =
        await PermissionHandler().requestPermissions([permData.group]);
    return status[permData.group];
  }

  @override
  void dispose() {
    _permissionsController.close();
    _stateController.close();
    super.dispose();
  }
}

///
/// Dados de uma permissioes requeridas pelo app.
///
class AppPermissionData {
  AppPermissionData(this.group) : _status = PermissionStatus.unknown;

  /// O grupo (tipo) da permissao.
  final PermissionGroup group;

  /// O status atual da permissao.
  PermissionStatus get status => _status;
  PermissionStatus _status;

  /// Retorna `true` se a permissao esta concedida ao app.
  bool get granted => _status == PermissionStatus.granted;
}

///
/// Status da checagem das permissoes requerias pelo app.
///
enum AppPermissionsState {
  /// O status de todas as permissoes estao sendo checadas.
  CHECKING_ALL, //
  /// O status de todas as permissoes estao sendo checados novamente.
  RECHECKING, //
  /// A checagem de status de todas as permissoes foi um sucesso.
  SUCCESS, //
  /// A checagem de status de todas as permissoes falhou.
  FAIL, //
}
