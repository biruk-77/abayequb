// lib/presentation/screens/top_up_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../providers/wallet_provider.dart';
import '../../data/models/bank_account_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/network_error_handler.dart';

class TopUpScreen extends StatefulWidget {
  final double? initialAmount;
  const TopUpScreen({super.key, this.initialAmount});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  BankAccountModel? _selectedBankAccount;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController.text = widget.initialAmount!.toString();
    }
    // Fetch bank accounts from server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchBankAccounts();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTopUp() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo of the bank receipt'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<WalletProvider>().uploadReceipt(
        receiptName: _selectedBankAccount?.bankName ?? 'Unknown Bank',
        amount: amount,
        reason: _reasonController.text.isEmpty
            ? 'Wallet Top-up'
            : _reasonController.text,
        filePath: _selectedImage!.path,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Top-up Submitted'),
            content: const Text(
              'Your deposit request has been submitted. The balance will be updated once our team verifies the receipt.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog
                  Navigator.pop(context); // Screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = NetworkErrorHandler.getUserFriendlyMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Top-up Wallet',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, child) {
          if (provider.isAccountsLoading && provider.bankAccounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDynamicHeader(provider),
                const SizedBox(height: 32),

                // Amount Input Section
                _buildSectionTitle('Amount to Add'),
                const SizedBox(height: 12),
                _buildAmountInput(),
                const SizedBox(height: 24),

                // Bank Selection Section
                _buildSectionTitle('Select Transfer Method'),
                const SizedBox(height: 12),
                _buildBankSelection(provider),
                const SizedBox(height: 24),

                // Selected Bank Account Details
                if (_selectedBankAccount != null) ...[
                  _buildSectionTitle('Bank Transfer Details'),
                  const SizedBox(height: 12),
                  _buildBankAccountCard(_selectedBankAccount!),
                  const SizedBox(height: 24),
                ],

                // Receipt Upload Section
                _buildSectionTitle('Upload Transaction Receipt'),
                const SizedBox(height: 12),
                _buildReceiptUploadArea(),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 32),

                // My Payout Accounts Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('My Payout Accounts'),
                    TextButton.icon(
                      onPressed: () => _showAddAccountDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add New'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMyAccountsList(provider),

                const SizedBox(height: 48),

                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyAccountsList(WalletProvider provider) {
    // Note: Assuming we need a separate way to fetch USER accounts vs SYSTEM accounts
    // For now, if provider.bankAccounts contains both, we might need to filter or fetch separately.
    // Based on Postman, GET /api/equb/accounts returns the user's accounts.
    if (provider.bankAccounts.isEmpty) {
      return Text(
        'No payout accounts added yet.',
        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
      );
    }

    return Column(
      children: provider.bankAccounts.map((account) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          tileColor: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(account.bankName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          subtitle: Text(account.accountNumber, style: GoogleFonts.outfit(fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => provider.deleteBankAccount(account.id.toString()),
          ),
        ),
      )).toList(),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final bankNameController = TextEditingController();
    final accountNameController = TextEditingController();
    final accountNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Payout Account', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: bankNameController, decoration: const InputDecoration(labelText: 'Bank Name')),
            TextField(controller: accountNameController, decoration: const InputDecoration(labelText: 'Account Holder Name')),
            TextField(controller: accountNumberController, decoration: const InputDecoration(labelText: 'Account Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (bankNameController.text.isEmpty || accountNumberController.text.isEmpty) return;
              try {
                await context.read<WalletProvider>().createBankAccount({
                  'bankName': bankNameController.text,
                  'accountName': accountNameController.text,
                  'accountNumber': accountNumberController.text,
                });
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                // Error handled by provider/snackbar
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDynamicHeader(WalletProvider provider) {
    final balance = provider.wallet?.availableBalance ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.8),
            AppTheme.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Balance',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const Icon(Icons.account_balance_wallet, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(2)} ETB',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.add_card, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                border: InputBorder.none,
                suffixText: 'ETB',
                suffixStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSelection(WalletProvider provider) {
    if (provider.bankAccounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
        ),
        child: const Text('No transfer methods available at the moment.'),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: provider.bankAccounts.length,
        itemBuilder: (context, index) {
          final bank = provider.bankAccounts[index];
          final isSelected = _selectedBankAccount?.id == bank.id;

          return GestureDetector(
            onTap: () => setState(() => _selectedBankAccount = bank),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 140,
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.account_balance,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bank.bankName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBankAccountCard(BankAccountModel bank) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Bank Name', bank.bankName),
          const Divider(height: 24),
          _buildDetailRow('Account Holder', bank.accountName),
          const Divider(height: 24),
          _buildDetailRow(
            'Account Number',
            bank.accountNumber,
            canCopy: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool canCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            if (canCopy) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(
                  Icons.content_copy,
                  size: 16,
                  color: AppTheme.primaryColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildReceiptUploadArea() {
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selectedImage != null
                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                : Colors.grey[300]!,
            width: 2,
            style: _selectedImage != null ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to upload transfer receipt',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Screenshot or Photo',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: (_isLoading || _selectedBankAccount == null || _selectedImage == null)
            ? null
            : _submitTopUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'SUBMIT FOR VERIFICATION',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
