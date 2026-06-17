import 'package:agromapping/data/models/usuario.dart' show Usuario;
import 'package:agromapping/data/services/contato_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../utils/view_state.dart';
import '../../view_models/profile_view_model.dart';
import '../widgets/profile_menu_item.dart';
import 'edit_profile_screen.dart';
import 'gerenciar_estoque_screen.dart';
import 'gerenciar_feiras_screen.dart';
import 'login_screen.dart';
import 'meus_contatos_screen.dart';
import 'meus_pedidos_screen.dart';
import 'minhas_reservas_screen.dart';
import 'my_products_screen.dart';
import 'add_product_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, ProfileViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.loading:
        return const Center(
            child: CircularProgressIndicator(color: primaryColor));
      case ViewState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: dangerColor),
              const SizedBox(height: 16),
              const Text('Erro ao carregar o perfil.',
                  style: TextStyle(color: subtitleColor)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.fetchUserProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      case ViewState.success:
        if (viewModel.user == null) {
          return const Center(child: Text('Utilizador nao encontrado.'));
        }
        final user = viewModel.user!;
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 20),
              _buildMenuSection(context, user),
              if (!user.isSeller && !user.isAdmin)
                _buildBecomeSellerBanner(context, viewModel),
              if (user.isSeller) _buildSellerSection(context),
              if (user.isAdmin) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(4, 0, 0, 8),
                        child: Text('Administração',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      ProfileMenuItem(
                        title: 'Gerenciar Feiras',
                        icon: Icons.store_mall_directory_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const GerenciarFeirasScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
              _buildAccountSection(context, viewModel),
              const SizedBox(height: 40),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProfileHeader(Usuario user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.6)],
              ),
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundColor: backgroundColor,
              child: Text(
                user.nome.isNotEmpty ? user.nome[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.nome,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(fontSize: 14, color: subtitleColor),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isSeller ? Icons.storefront : Icons.person,
                  size: 16,
                  color: primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  user.isSeller ? 'Vendedor' : 'Comprador',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, Usuario user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 0, 8),
            child: Text('Minha Conta',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
          ),
          ProfileMenuItem(
            title: 'Editar Perfil',
            icon: Icons.person_outline,
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(usuario: user),
                ),
              );
              if (result == true) {
                context.read<ProfileViewModel>().fetchUserProfile();
              }
            },
          ),
          ProfileMenuItem(
            title: 'Meus Pedidos',
            icon: Icons.receipt_long_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MeusPedidosScreen()),
              );
            },
          ),
          ProfileMenuItem(
            title: 'Minhas Reservas',
            icon: Icons.bookmark_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MinhasReservasScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBecomeSellerBanner(BuildContext context, ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withValues(alpha: 0.1), primaryColor.withValues(alpha: 0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storefront_outlined, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quer vender seus produtos?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cadastre seu telefone e comece a vender no Agro Mapping.',
                        style: TextStyle(fontSize: 13, color: subtitleColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showBecomeSellerDialog(context, viewModel),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Tornar-se Vendedor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBecomeSellerDialog(BuildContext context, ProfileViewModel viewModel) {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tornar-se Vendedor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cadastre seu telefone de contato para ativar sua conta de vendedor.',
              style: TextStyle(color: subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone de Contato',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informe um telefone.'),
                    backgroundColor: dangerColor,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await ContatoService().createContato(phone);
                await viewModel.fetchUserProfile();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agora voce e um vendedor!'),
                      backgroundColor: successColor,
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao ativar conta de vendedor.'),
                      backgroundColor: dangerColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 0, 8),
            child: Text('Painel do Vendedor',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
          ),
          ProfileMenuItem(
            title: 'Meus Produtos',
            icon: Icons.storefront_outlined,
            onTap: () {
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyProductsScreen()),
              );
            },
          ),
          ProfileMenuItem(
            title: 'Cadastrar Produto',
            icon: Icons.add_circle_outline,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
          ),
          ProfileMenuItem(
            title: 'Gerenciar Estoque',
            icon: Icons.inventory_2_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GerenciarEstoqueScreen(),
                ),
              );
            },
          ),
          ProfileMenuItem(
            title: 'Meus Contatos',
            icon: Icons.phone_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MeusContatosScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 0, 8),
            child: Text('Conta',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
          ),
          ProfileMenuItem(
            title: 'Sair',
            icon: Icons.exit_to_app,
            color: dangerColor,
            onTap: () async {
              await viewModel.logout();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
