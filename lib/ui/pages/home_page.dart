import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gpx_tunner/app_values.dart';
import 'package:gpx_tunner/blocs/gpx_tunner_bloc.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                //
                // botao que abre o arquivo gpx de origem
                //
                Consumer<GpxTunnerBloc>(
                  builder: (context, bloc) => _btnOpenGpxOrigem(bloc),
                ),
                //
                // detalhes da atividade
                //
                // TODO: Implementar
                //
                // botao que converte o gpx e salva o arquivo
                //
                Consumer<GpxTunnerBloc>(
                  builder: (context, bloc) {
                    if (!bloc.isOrigemOk) {
                      return Container(margin: const EdgeInsets.only(bottom: 15));
                    } else if (!(bloc.isDocPickerInProgress || bloc.isFileSystemBusy) &&
                        bloc.isOrigemOk &&
                        !bloc.isDestinoConverted) {
                      return _btnConvert(bloc);
                    } else {
                      return Container();
                    }
                  },
                ),
                //
                // botao dinamico (conforme etapa atual)
                //
                // TODO: Implementar
              ],
            ),
          ),
          //
          // indicador de ocupado
          //
          Consumer<GpxTunnerBloc>(
            builder: (context, bloc) => _busyIndicator(context, bloc),
          ),
        ],
      ),
    );
  }

  _onOpenStravaSite() async {
    print('>>> Abrindo site do strava');
  }

  Widget _bottomWidget(GpxTunnerBloc bloc) {
    if (!bloc.isOrigemOk || !bloc.isDestinoConverted) return Container();
    return _btnOpenStravaSite(bloc);
  }

  Widget _btnOpenStravaSite(GpxTunnerBloc bloc) {
    return Container(
      child: RaisedButton(
        color: Colors.orangeAccent[100],
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(AppValues.BTN_BORDER_RADIUS),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/strava_logo.png', width: 30, height: 30),
              const SizedBox(height: 10),
              const Text(
                'Abrir Strava...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD84315),
                ),
              ),
            ],
          ),
        ),
        onPressed: bloc.isOrigemOk ? _onOpenStravaSite : null,
      ),
    );
  }

  Widget _btnOpenGpxOrigem(GpxTunnerBloc bloc) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(AppValues.BTN_BORDER_RADIUS),
        ),
      ),
      child: const Text('CONVERTER NOVO GPX'),
      onPressed: bloc.isDocPickerInProgress ? null : bloc.openGpxOrigemFile,
    );
  }

  Widget _btnConvert(GpxTunnerBloc bloc) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(AppValues.BTN_BORDER_RADIUS),
        ),
      ),
      child: const Text('Iniciar conversão'),
      onPressed: () async => await bloc.startConversion(),
    );
  }

  Widget _busyIndicator(BuildContext context, GpxTunnerBloc bloc) {
    return IgnorePointer(
      ignoring: !bloc.isFileSystemBusy,
      child: Visibility(
        visible: bloc.isFileSystemBusy,
        child: Container(
          color: Colors.black.withOpacity(0.68),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Lendo GPX',
                    style: Theme.of(context).textTheme.headline.copyWith(
                          color: Theme.of(context).indicatorColor.withOpacity(0.73),
                        )),
                const SizedBox(height: 30),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).indicatorColor.withOpacity(0.73),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: const Text('GPX Tunner'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Configurações',
          onPressed: () => Navigator.of(context).pushNamed('/settings'),
        ),
      ],
    );
  }
}
