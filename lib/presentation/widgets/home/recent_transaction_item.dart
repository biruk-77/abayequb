// lib/presentation/widgets/home/recent_transaction_item.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/wallet_provider.dart';

class RecentTransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const RecentTransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // logic for icon and color based on type
    final type = transaction.type?.toLowerCase() ?? 'deposit';
    final isCredit = type == 'deposit' || type == 'payout';
    final color = isCredit ? AppTheme.successColor : AppTheme.errorColor;
    final icon = isCredit ? Icons.add_rounded : Icons.remove_rounded;

    return InkWell(
      onTap: () => _showTransactionDetails(context, transaction),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? (type.toUpperCase()),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : AppTheme.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    transaction.createdAt != null
                        ? "${transaction.createdAt!.day}/${transaction.createdAt!.month}/${transaction.createdAt!.year}"
                        : "Recently",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white38
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(0)}",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                Text(
                  "ETB",
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showDisputeForm(context, (tx.referenceId ?? tx.id).toString()),
                icon: const Icon(Icons.gavel_rounded, size: 20, color: Colors.red),
                label: Text(
                  'Dispute Transaction',
                  style: GoogleFonts.outfit(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisputeForm(BuildContext context, String transactionId) {
    String selectedCategory = 'payment_failure';
    final reasonController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Report a Dispute', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'payment_failure', child: Text('Payment Failure')),
                  DropdownMenuItem(value: 'payout_delay', child: Text('Payout Delay')),
                  DropdownMenuItem(value: 'fee_dispute', child: Text('Fee Dispute')),
                  DropdownMenuItem(value: 'group_issue', child: Text('Group Issue')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Describe the issue...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (reasonController.text.isEmpty) return;
                      setState(() => isSubmitting = true);
                      try {
                        await context.read<WalletProvider>().submitDispute({
                          'transactionId': transactionId,
                          'category': selectedCategory,
                          'reason': reasonController.text,
                        });
                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dispute submitted successfully')),
                          );
                        }
                      } catch (e) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit: $e')),
                          );
                        }
                      } finally {
                        if (context.mounted) setState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting ? const CircularProgressIndicator() : const Text('Submit'),
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
