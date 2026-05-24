import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../utils/view_state.dart';
import '../../view_models/feiras_view_model.dart';
import '../widgets/feira_card.dart';

class FeirasScreen extends StatefulWidget {
  const FeirasScreen({super.key});

  @override
  State<FeirasScreen> createState() => _FeirasScreenState();
}

class _FeirasScreenState extends State<FeirasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<FeirasViewModel>(context, listen: false);
      if (viewModel.permissionStatus == PermissionStatus.permanentlyDenied) {
        _showPermissionDialog();
      }
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Permissao de Localizacao'),
        content: const Text(
            'Para mostrar as feiras proximas, precisamos da sua permissao de localizacao. Por favor, ative a permissao nas configuracoes do seu dispositivo.'),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: subtitleColor)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Abrir Configuracoes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeirasViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: backgroundColor,
            title: const Text('Feiras da Regiao',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
            floating: true,
          ),
          SliverToBoxAdapter(child: _buildMapSection(viewModel)),
          SliverToBoxAdapter(child: _buildHeader()),
          _buildFeirasList(viewModel),
        ],
      ),
    );
  }

  Widget _buildMapSection(FeirasViewModel viewModel) {
    if (viewModel.state == ViewState.loading ||
        viewModel.userLocation == null) {
      return Container(
        height: 260,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        decoration: const BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: const Center(
            child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Container(
      height: 260,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            viewModel.userLocation!.latitude,
            viewModel.userLocation!.longitude,
          ),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.agromapping',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  viewModel.userLocation!.latitude,
                  viewModel.userLocation!.longitude,
                ),
                width: 80,
                height: 80,
                child: const Icon(Icons.my_location,
                    color: Colors.blueAccent, size: 30),
              ),
              ...viewModel.feiras.map((feira) => Marker(
                    point: feira.latLng,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.location_on,
                        color: primaryColor, size: 40),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Feiras Proximas',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildFeirasList(FeirasViewModel viewModel) {
    if (viewModel.state == ViewState.loading) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (viewModel.state == ViewState.error) {
      return SliverToBoxAdapter(
        child: Center(
          heightFactor: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: dangerColor),
              const SizedBox(height: 16),
              const Text('Erro ao carregar as feiras.',
                  style: TextStyle(color: subtitleColor)),
            ],
          ),
        ),
      );
    }

    if (viewModel.feiras.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          heightFactor: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 64, color: textLightColor),
              const SizedBox(height: 16),
              const Text('Nenhuma feira encontrada na sua regiao.',
                  style: TextStyle(fontSize: 14, color: subtitleColor)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final feira = viewModel.feiras[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FeiraCard(feira: feira),
          );
        },
        childCount: viewModel.feiras.length,
      ),
    );
  }
}
