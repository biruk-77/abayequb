// lib/presentation/screens/ideas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../providers/ideas_provider.dart';
import 'package:animate_do/animate_do.dart';

class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});

  @override
  State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<IdeasProvider>().fetchIdeas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Ideas',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showCreateIdeaSheet(context),
          ),
        ],
      ),
      body: Consumer<IdeasProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.ideas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.ideas.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchIdeas(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.ideas.length,
              itemBuilder: (context, index) {
                final idea = provider.ideas[index];
                return FadeInUp(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  child: _buildIdeaCard(idea),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No ideas yet',
            style: GoogleFonts.outfit(fontSize: 20, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showCreateIdeaSheet(context),
            child: const Text('Submit First Idea'),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(dynamic idea) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.category_outlined, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        idea['title'] ?? 'Untitled Idea',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        idea['category'] ?? 'General',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              idea['description'] ?? '',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(idea['createdAt']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (idea['file'] != null)
                  const Icon(Icons.attachment, size: 18, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  void _showCreateIdeaSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Start-up';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit an Idea',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: AppTheme.inputDecoration('Title', Icons.title),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: AppTheme.inputDecoration('Category', Icons.category),
              items: ['Start-up', 'Community', 'Saving', 'Other']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => selectedCategory = v!,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: AppTheme.inputDecoration('Description', Icons.description),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || descController.text.isEmpty) {
                  return;
                }
                try {
                  await context.read<IdeasProvider>().createIdea(
                    title: titleController.text,
                    description: descController.text,
                    category: selectedCategory,
                  );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  // Error handled by provider/logger
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Submit Idea'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );