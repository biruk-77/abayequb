// lib/presentation/screens/kyc_upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../data/models/kyc_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/network_error_handler.dart';

class KYCUploadScreen extends StatefulWidget {
  const KYCUploadScreen({super.key});

  @override
  State<KYCUploadScreen> createState() => _KYCUploadScreenState();
}

class _KYCUploadScreenState extends State<KYCUploadScreen> {
  String _selectedDocumentType = 'National ID';
  File? _selectedImage;
  bool _isUploading = false;

  final List<String> _documentTypes = [
    'National ID',
    'Passport',
    'Driving License',
    'Other',
  ];

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

  Future<void> _submitKYC() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document image')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final currentKyc = authProvider.kyc;

    setState(() => _isUploading = true);

    try {
      // Map display type to backend enum
      String docType = 'other';
      if (_selectedDocumentType == 'National ID') docType = 'id_card';
      if (_selectedDocumentType == 'Passport') docType = 'passport';
      if (_selectedDocumentType == 'Driving License') {
        docType = 'driving_license';
      }

      if (currentKyc == null) {
        // New KYC -> POST
        await authProvider.submitKYC(
          documentType: docType,
          filePath: _selectedImage!.path,
        );
      } else if (currentKyc.status == KYCStatus.rejected) {
        // Rejected KYC -> PUT (Update)
        await authProvider.updateKYC(
          kycId: currentKyc.id.toString(),
          documentType: docType,
          filePath: _selectedImage!.path,
        );
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(
              currentKyc == null
                  ? 'KYC documents submitted successfully. We will review them shortly.'
                  : 'KYC documents updated successfully. We will re-review them.',
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
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'KYC Verification',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Identity Verification',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please upload a clear photo of your government-issued ID to verify your identity.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),

            // KYC Status Banner
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final kyc = auth.kyc;
                if (kyc == null) return const SizedBox.shrink();

                Color bannerColor;
                IconData statusIcon;
                String statusText;
                String? statusReason = kyc.reason;

                switch (kyc.status) {
                  case KYCStatus.verified:
                    bannerColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    statusText = 'Verified';
                    break;
                  case KYCStatus.pending:
                    bannerColor = Colors.orange;
                    statusIcon = Icons.hourglass_empty;
                    statusText = 'Pending Review';
                    break;
                  case KYCStatus.rejected:
                    bannerColor = Colors.red;
                    statusIcon = Icons.error_outline;
                    statusText = 'Rejected';
                    break;
                  case KYCStatus.expired:
                    bannerColor = Colors.grey;
                    statusIcon = Icons.timer_off;
                    statusText = 'Expired';
                    break;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bannerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: bannerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(statusIcon, color: bannerColor, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Status: $statusText',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: bannerColor,
                            ),
                          ),
                        ],
                      ),
                      if (statusReason != null && statusReason.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Reason: $statusReason',
                          style: TextStyle(
                            color: bannerColor.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Document Type Dropdown
            Text(
              'Document Type',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final isLocked =
                    auth.kyc?.status == KYCStatus.verified ||
                    auth.kyc?.status == KYCStatus.pending;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey[50] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDocumentType,
                      isExpanded: true,
                      onChanged: isLocked
                          ? null
                          : (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedDocumentType = newValue;
                                });
                              }
                            },
                      items: _documentTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isLocked ? Colors.grey[500] : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Image Picker Area
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final isLocked =
                    auth.kyc?.status == KYCStatus.verified ||
                    auth.kyc?.status == KYCStatus.pending;
                final kyc = auth.kyc;

                return GestureDetector(
                  onTap: isLocked
                      ? null
                      : () => _showImageSourceActionSheet(context),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(
                          alpha: isLocked ? 0.1 : 0.3,
                        ),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: (kyc?.documentUrl != null && _selectedImage == null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              kyc!.documentUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, _, _) => const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 48,
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to upload ID photo',
                                style: TextStyle(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),

            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final isLocked =
                    auth.kyc?.status == KYCStatus.verified ||
                    auth.kyc?.status == KYCStatus.pending;
                if (_selectedImage == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: isLocked
                        ? null
                        : () => _showImageSourceActionSheet(context),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Change Photo'),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final kyc = auth.kyc;
                final isVerified = kyc?.status == KYCStatus.verified;
                final isPending = kyc?.status == KYCStatus.pending;

                String buttonText = 'SUBMIT FOR VERIFICATION';
                if (kyc?.status == KYCStatus.rejected) {
                  buttonText = 'UPDATE DOCUMENTS';
                } else if (isVerified) {
                  buttonText = 'VERIFIED';
                } else if (isPending) {
                  buttonText = 'UNDER REVIEW';
                }

                return ElevatedButton(
                  onPressed: (_isUploading || isVerified || isPending)
                      ? null
                      : _submitKYC,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified
                        ? Colors.green
                        : (isPending ? Colors.orange : AppTheme.primaryColor),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Guidelines',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildGuideline('Ensure all text is readable'),
                  _buildGuideline('No glare or shadows on the ID'),
                  _buildGuideline('The entire document must be in frame'),
                  _buildGuideline('Image must be in color'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
