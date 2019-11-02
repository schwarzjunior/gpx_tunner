import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gpx_tunner/blocs/app_permissions_bloc.dart';
import 'package:gpx_tunner/app_values.dart';

class AppStartPage extends StatefulWidget {
  @override
  _AppStartPageState createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> with SingleTickerProviderStateMixin {
  final _appPermissionsBloc = BlocProvider.getBloc<AppPermissionsBloc>();

  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _appPermissionsBloc.outState.listen((state) {
      if (state == AppPermissionsState.SUCCESS) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _appPermissionsBloc.sendState();
        }
      });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppPermissionsState>(
      stream: _appPermissionsBloc.outState,
      initialData: AppPermissionsBloc.initialState,
      builder: (context, snapshot) {
        switch (snapshot.data) {
          case AppPermissionsState.CHECKING_ALL:
            return _OpacityTransition(
              child: _SplashScreen(buttonVisible: false),
              animation: _animation,
            );
          case AppPermissionsState.FAIL:
            return _SplashScreen(onPressed: _appPermissionsBloc.requestAllPermissions);
          default:
            return Container();
        }
      },
    );
  }

  @override
  void dispose() {
    _appPermissionsBloc.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class _SplashScreen extends StatelessWidget {
  final Function onPressed;
  final bool buttonVisible;

  const _SplashScreen({
    Key key,
    this.onPressed,
    this.buttonVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String msg = 'O GPX Tunner precisa de sua permissão para '
        'ler e gravar dados no seu dispositivo.';

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 50),
            Image.asset(AppValues.IMAGE_GPX_ICON, height: 72, width: 72),
            const SizedBox(height: 20),
            Text('GPX Tunner',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display2.copyWith(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    )),
            Visibility(
              visible: buttonVisible,
              maintainAnimation: true,
              maintainState: true,
              maintainSize: true,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 40),
                  const Text(msg, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(AppValues.BTN_BORDER_RADIUS),
                      ),
                    ),
                    child: const Text('Clique aqui para conceder'),
                    onPressed: onPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpacityTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final opacityTween = Tween<double>(begin: 0.1, end: 1);

  _OpacityTransition({Key key, this.child, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Opacity(
            opacity: opacityTween.evaluate(animation).clamp(0.0, 1.0),
            child: Container(
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}
