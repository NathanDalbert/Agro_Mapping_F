// lib/ui/screens/profile_screen.dart
import 'package:agromapping/data/models/usuario.dart' show Usuario;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../view_models/profile_view_model.dart';
import '../widgets/profile_menu_item.dart';
import 'login_screen.dart'; // Para a navegação após o logout

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, ProfileViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.loading:
        return const Center(
            child: CircularProgressIndicator(color: primaryColor));
      case ViewState.error:
        return const Center(child: Text('Erro ao carregar o perfil.'));
      case ViewState.success:
        if (viewModel.user == null) {
          return const Center(child: Text('Utilizador não encontrado.'));
        }
        final user = viewModel.user!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildUserMenu(context),

              // Secção do Vendedor (condicional)
              if (user.isSeller) ...[
                const SizedBox(height: 16),
                _buildSellerMenu(context),
              ],

              const SizedBox(height: 24),
              ProfileMenuItem(
                title: 'Sair',
                icon: Icons.exit_to_app,
                color: Colors.red,
                onTap: () async {
                  await viewModel.logout();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProfileHeader(Usuario user) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: primaryColor.withOpacity(0.2),
              child: Text(
                  user.nome.isNotEmpty ? user.nome[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 30, color: primaryColor)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nome,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 4),
                Text(user.email,
                    style: const TextStyle(fontSize: 16, color: subtitleColor)),
                const SizedBox(height: 8),
                Chip(
                  label: Text(user.isSeller ? 'Vendedor' : 'Comprador',
                      style: const TextStyle(color: primaryColor)),
                  backgroundColor: primaryColor.withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
            title: 'Editar Perfil',
            icon: Icons.settings_outlined,
            onTap: () {}),
        ProfileMenuItem(
            title: 'Meus Pedidos',
            icon: Icons.receipt_long_outlined,
            onTap: () {}),
      ],
    );
  }

  Widget _buildSellerMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text('Painel do Vendedor',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ),
        ProfileMenuItem(
            title: 'Meus Produtos',
            icon: Icons.storefront_outlined,
            onTap: () {
              // TODO: Navegar para a tela de gestão de produtos
            }),
        ProfileMenuItem(
            title: 'Cadastrar Produto',
            icon: Icons.add_circle_outline,
            onTap: () {
              // TODO: Navegar para a tela de cadastro de produto
            }),
      ],
    );
  }
}
