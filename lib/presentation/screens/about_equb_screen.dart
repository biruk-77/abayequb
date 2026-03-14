// lib/presentation/screens/about_equb_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/legal_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AboutEqubScreen extends StatefulWidget {
  const AboutEqubScreen({super.key});

  @override
  State<AboutEqubScreen> createState() => _AboutEqubScreenState();
}

class _AboutEqubScreenState extends State<AboutEqubScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<LegalProvider>().fetchTerms());
  }

  @override
  Widget build(BuildContext context) {
    final legalProvider = context.watch<LegalProvider>();
    final activeTerms = legalProvider.activeTerms;

    return Scaffold(
      appBar: AppBar(title: const Text('About Abay eQub'), centerTitle: true),
      body: legalProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Image or Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (activeTerms != null) ...[
                    Text(
                      activeTerms['title'] ?? 'Terms & Conditions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    MarkdownBody(
                      data: activeTerms['content'] ?? 'No content available.',
                      styleSheet: MarkdownStyleSheet(
                        p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                    ),
                  ] else if (!legalProvider.isLoading) ...[
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No details available at the moment.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => legalProvider.fetchTerms(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  // Placeholder for PDF content
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Trust-based system digitized for security and transparency.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
