// lib/ui/screens/feiras_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Necessário para o ponto do mapa
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
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
    // Garante que a verificação de permissão aconteça após a tela ser construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<FeirasViewModel>(context, listen: false);
      // Se a permissão foi negada permanentemente, mostra um diálogo útil
      if (viewModel.permissionStatus == PermissionStatus.permanentlyDenied) {
        _showPermissionDialog();
      }
    });
  }

  // Diálogo para guiar o utilizador às configurações do telemóvel
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão de Localização Necessária'),
        content: const Text(
            'Para mostrar as feiras próximas, precisamos da sua permissão de localização. Por favor, ative a permissão nas configurações do seu dispositivo.'),
        actions: [
          TextButton(
            child:
                const Text('Cancelar', style: TextStyle(color: subtitleColor)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Abrir Configurações',
                style: TextStyle(color: primaryColor)),
            onPressed: () {
              openAppSettings(); // Abre as configurações do app
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ouve as mudanças no ViewModel para reconstruir a tela
    final viewModel = context.watch<FeirasViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      // Usamos CustomScrollView para combinar a AppBar, o mapa e a lista
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: backgroundColor,
            title: const Text('Feiras da Região',
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                  icon: const Icon(Icons.send_outlined, color: textColor),
                  onPressed: () {})
            ],
            floating:
                true, // A AppBar aparece assim que se faz scroll para cima
          ),
          SliverToBoxAdapter(child: _buildMapSection(viewModel)),
          SliverToBoxAdapter(child: _buildHeader()),
          _buildFeirasList(viewModel),
        ],
      ),
    );
  }

  // Secção que contém o mapa interativo
  Widget _buildMapSection(FeirasViewModel viewModel) {
    if (viewModel.state == ViewState.loading ||
        viewModel.userLocation == null) {
      return Container(
        height: 250,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: cardColor, borderRadius: BorderRadius.circular(16)),
        child:
            const Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
          ]),
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
            userAgentPackageName:
                'com.example.agromapping', // Substitua pelo seu package name
          ),
          MarkerLayer(
            markers: [
              // Marcador para a localização do utilizador
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
              // Marcadores para cada feira
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

  // Cabeçalho da lista de feiras
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text('Feiras Próximas',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  // Lista de feiras
  Widget _buildFeirasList(FeirasViewModel viewModel) {
    // Não mostra nada se estiver a carregar (o loading já está no mapa)
    if (viewModel.state == ViewState.loading) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (viewModel.state == ViewState.error) {
      return const SliverToBoxAdapter(
        child: Center(
          heightFactor: 5,
          child: Text('Erro ao carregar as feiras.'),
        ),
      );
    }

    if (viewModel.feiras.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          heightFactor: 5,
          child: Text('Nenhuma feira encontrada na sua região.'),
        ),
      );
    }

    // Usa SliverList para integrar a lista dentro da CustomScrollView
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
