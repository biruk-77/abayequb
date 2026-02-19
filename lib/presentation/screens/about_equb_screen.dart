import 'package:flutter/material.dart';

class AboutEqubScreen extends StatelessWidget {
  const AboutEqubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Abay eQub'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildSection(
              context,
              title: 'What is Equb?',
              content:
                  'Equb (Traditional: እቁብ) is an Ethiopian traditional association established by a small group of people to provide rotating funding for members to improve their lives and living conditions.',
            ),
            
            _buildSection(
              context,
              title: 'How it Works',
              content:
                  '1. **Formation**: A group of people agree to contribute a fixed amount of money periodically (daily, weekly, or monthly).\n\n'
                  '2. **Collection**: The collected money forms a "pot".\n\n'
                  '3. **Payout**: In each round, one member receives the entire pot. The winner is typically selected by lottery (drawing lots) or based on urgent need.\n\n'
                  '4. **Cycle**: This continues until every member has received the pot once.',
            ),

            _buildSection(
              context,
              title: 'Why use Abay eQub?',
              content:
                  'Abay eQub digitizes this trust-based system, making it secure, transparent, and accessible to everyone, everywhere. We handle the math, the notifications, and the transfers so you can focus on your goals.',
            ),
            
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
                       'More details from "ROSCAs as a Financial Commons" can be added here regarding community governance and economic resilience.',
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

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
