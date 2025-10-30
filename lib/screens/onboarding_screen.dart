import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  bool _isLastPage = false;

  Future<void> _onboardingFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2F7EF), Color(0xFFB388EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _isLastPage = index == 2;
                });
              },
              children: const [
                OnboardingPageContent(
                  image: 'assets/images/onboarding1.png',
                  iconData: Icons.monetization_on,
                  title: 'Track Every Rupiah',
                  description: 'Easily record all your income and expenses in one place.',
                ),
                OnboardingPageContent(
                  image: 'assets/images/onboarding2.png',
                  iconData: Icons.category,
                  title: 'Clear Categories',
                  description: 'Group your transactions into categories for better analysis.',
                ),
                OnboardingPageContent(
                  image: 'assets/images/onboarding3.png',
                  iconData: Icons.auto_graph,
                  title: 'Understand Your Finances',
                  description: 'Check out visual reports to help you make smarter financial decisions.',
                ),
              ],
            ),

            // Controls
            Container(
              alignment: const Alignment(0, 0.9),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // SKIP
                  TextButton(
                    onPressed: () => _controller.jumpToPage(2),
                    child: Text(
                      'SKIP',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: const WormEffect(
                      spacing: 16,
                      dotColor: Colors.white38,
                      activeDotColor: Colors.white,
                    ),
                  ),

                  // NEXT or DONE
                  TextButton(
                    onPressed: _isLastPage
                        ? () async {
                            await _onboardingFinished();
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            }
                          }
                        : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            ),
                    child: Text(
                      _isLastPage ? 'DONE' : 'NEXT',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.image,
    required this.iconData,
    required this.title,
    required this.description,
  });

  final String image;
  final IconData iconData;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: MediaQuery.of(context).size.height * 0.35,
          ),
          const SizedBox(height: 40),

          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              iconData,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
