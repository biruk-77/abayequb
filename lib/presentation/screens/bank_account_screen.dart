// lib/presentation/screens/bank_account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../providers/wallet_provider.dart';
import '../../data/models/bank_account_model.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<WalletProvider>().fetchBankAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bank Accounts',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, child) {
          if (provider.isAccountsLoading && provider.bankAccounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchBankAccounts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.bankAccounts.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.bankAccounts.length) {
                  return FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildAddAccountButton(context),
                  );
                }

                final account = provider.bankAccounts[index];
                return FadeInUp(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  child: _buildAccountCard(account),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountCard(BankAccountModel account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.account_balance_wallet,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      account.bankName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.verified, color: Colors.white, size: 20),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'ACCOUNT NUMBER',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _maskAccountNumber(account.accountNumber),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HOLDER NAME',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          account.accountName.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white70),
                      onPressed: () => _confirmDelete(account),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _maskAccountNumber(String number) {
    if (number.length < 4) return number;
    return '**** **** **** ${number.substring(number.length - 4)}';
  }

  Widget _buildAddAccountButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Implementation for adding account
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Account feature coming soon in demo')),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade50,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: AppTheme.primaryColor, size: 32),
              const SizedBox(height: 8),
              Text(
                'Add Bank Account',
                style: GoogleFonts.outfit(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BankAccountModel account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Bank Account?'),
        content: Text('Are you sure you want to remove ${account.bankName} account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementation for delete
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
