import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/wallet_provider.dart';
import '../../data/models/transaction_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchTransactions();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshTransactions() async {
    await context.read<WalletProvider>().fetchTransactions(type: _selectedType);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context);
    final walletProvider = context.watch<WalletProvider>();
    final transactions = walletProvider.transactions;
    final isLoading = walletProvider.isTransactionsLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- Custom Silver AppBar ---
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n?.history ?? 'Transaction History',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Filter Chips ---
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  _buildFilterChip('Contributions', 'contribution'),
                  _buildFilterChip('Deposits', 'deposit'),
                  _buildFilterChip('Payouts', 'payout'),
                  _buildFilterChip('Withdrawals', 'withdrawal'),
                ],
              ),
            ),
          ),

          // --- Transaction List ---
          if (isLoading && transactions.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (transactions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions found',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tx = transactions[index];
                  return FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: Duration(milliseconds: 50 * index),
                    child: _buildTransactionCard(tx),
                  );
                }, childCount: transactions.length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshTransactions,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = type;
          });
          context.read<WalletProvider>().fetchTransactions(type: type);
        },
        selectedColor: AppTheme.primaryColor,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel tx) {
    final isIncome = tx.isPayout || tx.isDeposit;
    final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isIncome
        ? Icons.keyboard_arrow_down_rounded
        : Icons.keyboard_arrow_up_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTransactionDetails(tx),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description ??
                            tx.type?.toUpperCase() ??
                            'Transaction',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.format(
                          tx.createdAt ?? DateTime.now(),
                          'en',
                        ),
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(tx.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx.status?.toUpperCase() ?? 'UNKNOWN',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(tx.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  void _showTransactionDetails(TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Transaction Details',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailRow('Reference ID', tx.referenceId ?? 'N/A'),
            _buildDetailRow('Type', tx.type?.toUpperCase() ?? 'N/A'),
            _buildDetailRow('Amount', CurrencyFormatter.format(tx.amount)),
            _buildDetailRow('Status', tx.status?.toUpperCase() ?? 'N/A'),
            _buildDetailRow('Method', tx.method?.toUpperCase() ?? 'N/A'),
            _buildDetailRow(
              'Date',
              DateFormatter.format(tx.createdAt ?? DateTime.now(), 'en'),
            ),
            _buildDetailRow(
              'Description',
              tx.description ?? 'No description provided',
            ),
            const Spacer(),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: const Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
