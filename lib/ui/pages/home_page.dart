import 'package:flutter/material.dart';
import 'package:gpx_tunner/app_values.dart';

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
                /*Center(
                  child: Text('Teste', style: Theme.of(context).textTheme.display4),
                ),*/
                _btnOpenGpxOrigem(),
                //
                // botao que abre o arquivo gpx de origem
                //
                // TODO: Implementar
                //
                // detalhes da atividade
                //
                // TODO: Implementar
                //
                // botao que converte o gpx e salva o arquivo
                //
                // TODO: Implementar
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
          // TODO: Implementar
        ],
      ),
    );
  }

  Widget _btnOpenGpxOrigem() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(AppValues.BTN_BORDER_RADIUS),
        ),
      ),
      child: const Text('CONVERTER NOVO GPX'),
      onPressed: () {},
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
