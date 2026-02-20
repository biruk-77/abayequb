import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/equb_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/abay_icon.dart';

class PackageSelectionScreen extends StatefulWidget {
  const PackageSelectionScreen({super.key});

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EqubProvider>().fetchPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final equbProvider = context.watch<EqubProvider>();
    final packages = equbProvider.packages;
    final isLoading = equbProvider.isLoading;
    final error = equbProvider.error;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // Premium Header with deep curve
          Stack(
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0D4348),
                        const Color(0xFF135A5E).withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'ABAY eQUB',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                'Flowing Wealth, Shared Future',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white70,
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white24,
                              backgroundImage:
                                  user?.profileImage != null &&
                                      user!.profileImage!.isNotEmpty
                                  ? NetworkImage(
                                      AbayIcon.getAbsoluteUrl(
                                        user.profileImage!,
                                      )!,
                                    )
                                  : null,
                              radius: 20,
                              child:
                                  user?.profileImage == null ||
                                      user!.profileImage!.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'choose group type',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF135A5E)),
                  )
                : error != null
                ? Center(
                    child: Text('Error: $error', style: GoogleFonts.outfit()),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 25,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return GestureDetector(
                        onTap: () {
                          context.push(
                            '/packages/contribution/${package.id}',
                            extra: package,
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _getBorderColor(index),
                                  width: 2.5,
                                ),
                              ),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: AbayIcon(
                                    iconPath: package.iconPath,
                                    name: package.name,
                                    fit: BoxFit.contain,
                                    color: _getBorderColor(
                                      index,
                                    ), // Tint the icon for better aesthetics
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: Text(
                                package.name ?? 'Group',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D4348), Color(0xFF135A5E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D4348).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Center(
                child: Text(
                  'CONTRIBUTE',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(int index) {
    final colors = [
      const Color(0xFFD4AF37), // Royal Gold
      const Color(0xFFC084FC), // Soft Purple
      const Color(0xFF38BDF8), // Light Blue
      const Color(0xFF4ADE80), // Green
      const Color(0xFFFB923C), // Orange
      const Color(0xFFF472B6), // Pink
      const Color(0xFF2DD4BF), // Teal
    ];
    return colors[index % colors.length];
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);

    var firstControlPoint = Offset(size.width / 2, size.height + 40);
    var firstEndPoint = Offset(size.width, size.height - 60);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
