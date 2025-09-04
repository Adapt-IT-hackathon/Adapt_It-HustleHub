import 'package:flutter/material.dart';
import 'dart:async'; //
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';


//welcome page
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized!');
  } catch (e) {
    print('Firebase failed to initialize: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HustleHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const IntroductionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Local Skills, Local People',
      'subtitle': 'Find skilled professionals right in your neighborhood',
      'image': '🚀'
    },
    {
      'title': 'Close Proximity, Fast Service',
      'subtitle': 'Get help quickly from trusted locals near you',
      'image': '⚡'
    },
    {
      'title': 'Your Community, Your Hub',
      'subtitle': 'Connect with your community like never before',
      'image': '🤝'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll animation with debug log
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _pages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      print("⏩ Auto-scrolling to page $_currentPage"); // debug
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with blue wave
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFE3F2FD)],
              ),
            ),
          ),

          // Content
          Column(
            children: [
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                    print("📄 Page changed to: $_currentPage"); // debug
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (BuildContext context, Widget? child) {
                        double value = 1.0;
                        if (_pageController.hasClients &&
                            _pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
                        }
                        return Transform.scale(
                          scale: Curves.easeOut.transform(value),
                          child: child,
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _pages[index]['image']!,
                            style: const TextStyle(fontSize: 80),
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              _pages[index]['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              _pages[index]['subtitle']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page indicator (with animation)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(_pages.length, (int index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index ? 12 : 10,
                      height: _currentPage == index ? 12 : 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? const Color(0xFF1976D2)
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ),

              // Get Started Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>SignUpPage())); // debug
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // App name and tagline at top
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'HustleHub',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Local Skills. Local People. Fast.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otherSkillController = TextEditingController();

  File? _profileImage;
  final picker = ImagePicker();

  String _selectedRole = "Service Provider"; // default
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final List<String> _skills = [
    "Washing",
    "Gardening",
    "Painting",
    "Plumbing",
    "Electrical",
    "Cooking",
    "Tutoring",
    "Cleaning",
    "Carpentry",
    "Delivery",
    "Other"
  ];

  final Set<String> _selectedSkills = {};
  bool _showOtherSkillField = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _toggleSkill(String skill) {
    if (skill == "Other") {
      setState(() {
        _showOtherSkillField = !_showOtherSkillField;
        if (!_showOtherSkillField) _otherSkillController.clear();
      });
      return;
    }

    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  void _submit() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Passwords do not match"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_showOtherSkillField && _otherSkillController.text.isNotEmpty) {
      _selectedSkills.add(_otherSkillController.text.trim());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("✅ Sign Up Successful!"),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📧 Password reset link sent to your email"),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Join HustleHub",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Create Your Account",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
            ),
            const SizedBox(height: 5),
            const Text(
              "Join our community of local professionals",
              style: TextStyle(fontSize: 14, color: Color(0xFF1976D2)),
            ),
            const SizedBox(height: 20),

            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, size: 50, color: Color(0xFF1976D2))
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Name & Surname
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_nameController, "First Name", Icons.person),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTextField(_surnameController, "Surname", Icons.person_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(_emailController, "Email", Icons.email, TextInputType.emailAddress),
                  const SizedBox(height: 15),
                  _buildPasswordField(_passwordController, "Password", _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
                  const SizedBox(height: 15),
                  _buildPasswordField(_confirmPasswordController, "Confirm Password", _obscureConfirm, () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  }),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF1976D2))),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Role
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "I want to join as a:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1976D2)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Service Provider"),
                          selected: _selectedRole == "Service Provider",
                          selectedColor: const Color(0xFF1976D2),
                          labelStyle: TextStyle(
                              color: _selectedRole == "Service Provider" ? Colors.white : const Color(0xFF1976D2)),
                          onSelected: (_) => setState(() => _selectedRole = "Service Provider"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Client"),
                          selected: _selectedRole == "Client",
                          selectedColor: const Color(0xFF1976D2),
                          labelStyle: TextStyle(
                              color: _selectedRole == "Client" ? Colors.white : const Color(0xFF1976D2)),
                          onSelected: (_) => setState(() => _selectedRole = "Client"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Skills
                  _buildSkillsSelection(),

                  const SizedBox(height: 20),

                  // Sign Up Button
                  _buildSignUpButton(),

                  const SizedBox(height: 10),

                  // Login Link
                  _buildLoginLink(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Your Skills",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1976D2)),
        ),
        const SizedBox(height: 10),
        IgnorePointer(
          ignoring: _selectedRole == "Client",
          child: Opacity(
            opacity: _selectedRole == "Client" ? 0.4 : 1,
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((skill) {
                    final bool isSelected = _selectedSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1976D2),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1976D2)),
                      onSelected: (_) => _toggleSkill(skill),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
                if (_showOtherSkillField)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildTextField(_otherSkillController, "Enter your skill", Icons.star),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 5,
          shadowColor: Colors.blue.shade200,
        ),
        child: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () {
            // Navigate to login page (replace with your LoginPage)
            Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginPage()));
          },
          child: const Text(
            "Log In",
            style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      [TextInputType inputType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscureText, VoidCallback onToggle) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF1976D2)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF1976D2)),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  String _selectedRole = "Service Provider"; // Default role
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔑 Firebase login
  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please fill in all fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Login successful as $_selectedRole!"),
          backgroundColor: Colors.green.shade700,
        ),
      );

      // Navigate based on role
      if (_selectedRole == "Service Provider") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ServiceDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClientDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else {
        message = "⚠️ ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📧 Password reset link sent to your email"),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Sign In to HustleHub",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Access your local services community",
                style: TextStyle(fontSize: 16, color: Color(0xFF1976D2)),
              ),
              const SizedBox(height: 30),

              // Logo
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.work_outline,
                  size: 50,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 30),

              // Role Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "I am logging in as:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleOption(
                            title: "Service Provider",
                            icon: Icons.handyman_outlined,
                            isSelected: _selectedRole == "Service Provider",
                            onTap: () {
                              setState(() {
                                _selectedRole = "Service Provider";
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleOption(
                            title: "Client",
                            icon: Icons.person_outline,
                            isSelected: _selectedRole == "Client",
                            onTap: () {
                              setState(() {
                                _selectedRole = "Client";
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Login Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                        _emailController, "Email Address", Icons.email),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                        _passwordController, "Password", _obscurePassword, () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    }),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                              activeColor: const Color(0xFF1976D2),
                            ),
                            const Text(
                              "Remember me",
                              style: TextStyle(color: Color(0xFF1976D2)),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                                color: Color(0xFF1976D2),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 5,
                          shadowColor: Colors.blue.shade200,
                        ),
                        child: Text(
                          "Login as $_selectedRole",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to SignUpPage
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
          TextEditingController controller, String label, IconData icon) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
        ),
      );

  Widget _buildPasswordField(TextEditingController controller, String label,
          bool obscureText, VoidCallback onToggle) =>
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF1976D2)),
          suffixIcon: IconButton(
              icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF1976D2)),
              onPressed: onToggle),
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF1976D2), width: 2)),
        ),
      );
}

// Small role option widget
class _RoleOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption(
      {required this.title,
      required this.icon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28,
                color: isSelected ? Colors.blue : Colors.grey.shade600),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey.shade600,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? Colors.white : const Color(0xFF1976D2)),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1976D2), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}



class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _currentIndex = 0;
  final double _userRating = 4.7; // Example rating
  final int _completedJobs = 12; // Example completed jobs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HustleHub Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(),
            const SizedBox(height: 20),

            // Rating and progress section
            _buildRatingSection(),
            const SizedBox(height: 20),

            // Quick stats
            _buildStatsSection(),
            const SizedBox(height: 20),



            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 30,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back, Sarah!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ready to find your next service provider?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Client Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Rating display
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomRatingBar(
                    rating: _userRating,
                    itemSize: 30,
                    onRatingChanged: (rating) {
                      // Rating would typically be updated by service providers
                    },
                    ignoreGestures: true,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$_userRating/5.0',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: _userRating / 5,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                    ),
                  ),
                  Text(
                    '${(_userRating / 5 * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: _userRating / 5,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 5),
          const Text(
            'Keep getting rated to improve your ranking!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Completed Jobs',
            value: _completedJobs.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _StatCard(
            title: 'Pending Requests',
            value: '3',
            icon: Icons.access_time,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _StatCard(
            title: 'Messages',
            value: '5',
            icon: Icons.message,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  BottomAppBar _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: _currentIndex == 0 ? const Color(0xFF1976D2) : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.work,
              color: _currentIndex == 1 ? const Color(0xFF1976D2) : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 1;
              });
            Navigator.push(context, MaterialPageRoute(builder: (_)=>JobsPage()));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.task,
              color: _currentIndex == 2 ? const Color(0xFF1976D2) : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 2;
              });
              Navigator.push(context, MaterialPageRoute(builder: (_)=>TasksPage()));

            },
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: _currentIndex == 3 ? const Color(0xFF1976D2) : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 3;
              });
              Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfilePage()));
            },
          ),
        ],
      ),
    );
  }
}

// Custom Rating Bar Widget
class CustomRatingBar extends StatelessWidget {
  final double rating;
  final double itemSize;
  final ValueChanged<double> onRatingChanged;
  final bool ignoreGestures;

  const CustomRatingBar({
    super.key,
    required this.rating,
    this.itemSize = 24.0,
    required this.onRatingChanged,
    this.ignoreGestures = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData iconData;
        Color color;

        if (index < rating.floor()) {
          // Full star
          iconData = Icons.star;
          color = Colors.amber;
        } else if (index < rating.ceil()) {
          // Half star
          iconData = Icons.star_half;
          color = Colors.amber;
        } else {
          // Empty star
          iconData = Icons.star_border;
          color = Colors.grey;
        }

        return GestureDetector(
          onTap: ignoreGestures
              ? null
              : () {
            onRatingChanged(index + 1.0);
          },
          child: Icon(
            iconData,
            size: itemSize,
            color: color,
          ),
        );
      }),
    );
  }
}

// Custom widget for statistics cards
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Custom widget for map markers
class _MapMarker extends StatelessWidget {
  final Color color;
  final String jobType;

  const _MapMarker({
    required this.color,
    required this.jobType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_pin,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            jobType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _otherSocialController = TextEditingController();
  final TextEditingController _otherSkillController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();


  bool _isEditing = false;
  final bool _otherSkillSelected = false;

  final List<String> _skills = [
    "Washing", "Gardening", "Painting", "Plumbing", "Electrical",
    "Cooking", "Tutoring", "Cleaning", "Carpentry", "Delivery",
    "Other"
  ];
  final Set<String> _selectedSkills = {};

  @override
  void initState() {
    super.initState();
    // Initialize with demo data
    _nameController.text = "John";
    _surnameController.text = "Doe";
    _bioController.text = "Experienced plumber with 5+ years of service in residential and commercial properties.";
    _linkedInController.text = "linkedin.com/in/johndoe";
    _githubController.text = "github.com/johndoe";
    _otherSocialController.text = "johndoe_insta";
    _selectedSkills.addAll({"Plumbing", "Electrical"});
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    // Here you would typically save to a database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("✅ Profile updated successfully!"),
        backgroundColor: Colors.green.shade700,
      ),
    );
    _toggleEdit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Colors.white],
            stops: [0.1, 0.4, 0.4],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/default_avatar.png') as ImageProvider,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 50, color: Color(0xFF1976D2))
                          : null,
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "${_nameController.text} ${_surnameController.text}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Service Provider",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),

              // Profile Details Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Surname
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: "First Name",
                              labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                              prefixIcon: const Icon(Icons.person, color: Color(0xFF1976D2)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1976D2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: _surnameController,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: "Surname",
                              labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1976D2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Bio
                    TextField(
                      controller: _bioController,
                      enabled: _isEditing,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Bio",
                        labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1976D2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Social Links
                    const Text(
                      "Social Links",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _linkedInController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: "LinkedIn",
                        labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                        prefixIcon: const Icon(Icons.link, color: Color(0xFF1976D2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1976D2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _githubController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: "GitHub",
                        labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                        prefixIcon: const Icon(Icons.code, color: Color(0xFF1976D2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1976D2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _otherSocialController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: "Other Social Media",
                        labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                        prefixIcon: const Icon(Icons.thumb_up, color: Color(0xFF1976D2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1976D2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Skills
                    const Text(
                      "Skills",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        final bool isSelected = _selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill),
                          selected: isSelected,
                          onSelected: _isEditing ? (_) => _toggleSkill(skill) : null,
                          selectedColor: const Color(0xFF1976D2),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1976D2),
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor: Colors.blue.shade50,
                          showCheckmark: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

        

                    // Stats/Reviews Section
                    const Text(
                      "Service Stats",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn("25", "Jobs Completed"),
                        _buildStatColumn("4.8", "Rating"),
                        _buildStatColumn("98%", "Satisfaction"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}



class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _userSkills = ['Plumbing', 'Electrical', 'Carpentry']; // User's skills

  final List<Job> _allJobs = [
    Job(
      id: '1',
      title: 'Fix Leaking Kitchen Sink',
      description: 'My kitchen sink has been leaking for the past few days. Need someone to fix it as soon as possible. The pipe under the sink seems to be the issue.',
      clientName: 'Sarah Johnson',
      location: 'Cape Town, CBD',
      requiredSkills: ['Plumbing'],
      datePosted: '2 hours ago',
    ),
    Job(
      id: '2',
      title: 'Install New Light Fixtures',
      description: 'Need help installing 4 new light fixtures in my living room and bedroom. I have all the materials, just need someone with electrical experience.',
      clientName: 'Mike Peterson',
      location: 'Johannesburg, Sandton',
      requiredSkills: ['Electrical'],
      datePosted: '5 hours ago',
    ),
    Job(
      id: '3',
      title: 'Build Bookshelf',
      description: 'Looking for a carpenter to build a custom bookshelf for my home office. I have the design and materials ready.',
      clientName: 'Lisa Chang',
      location: 'Durban, Umhlanga',
      requiredSkills: ['Carpentry'],
      datePosted: '1 day ago',
    ),
    Job(
      id: '4',
      title: 'Bathroom Tile Repair',
      description: 'Need someone to repair broken tiles in my bathroom and re-grout the entire area.',
      clientName: 'David Wilson',
      location: 'Pretoria, Centurion',
      requiredSkills: ['Handyman', 'Tiling'],
      datePosted: '2 days ago',
    ),
    Job(
      id: '5',
      title: 'Electrical Outlet Installation',
      description: 'Need to install 3 new electrical outlets in my home office. Must have proper certification.',
      clientName: 'Amanda Roberts',
      location: 'Cape Town, Southern Suburbs',
      requiredSkills: ['Electrical'],
      datePosted: '3 days ago',
    ),
  ];

  List<Job> get _filteredJobs {
    if (_searchQuery.isEmpty) {
      return _allJobs.where((job) =>
          job.requiredSkills.any((skill) => _userSkills.contains(skill))
      ).toList();
    } else {
      return _allJobs.where((job) =>
      job.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          job.requiredSkills.any((skill) => _userSkills.contains(skill))
      ).toList();
    }
  }

  void _showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => JobDetailsBottomSheet(job: job),
    );
  }

  void _showInterest(Job job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Interest sent to ${job.clientName} for ${job.title}"),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Available Jobs",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Colors.white],
            stops: [0.1, 0.4, 0.4],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search jobs by title...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF1976D2)),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    ) : null,
                  ),
                ),
              ),
            ),

            // Skills Filter Chip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    const Text(
                      "Matching your skills:",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ..._userSkills.map((skill) => Chip(
                      label: Text(skill),
                      backgroundColor: const Color(0xFF1976D2),
                      labelStyle: const TextStyle(color: Colors.white),
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Jobs List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: _filteredJobs.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work_outline, size: 64, color: Color(0xFF1976D2)),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? "No jobs matching your skills"
                            : "No jobs found for '$_searchQuery'",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Try updating your skills or check back later",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = _filteredJobs[index];
                    return JobCard(
                      job: job,
                      onTap: () => _showJobDetails(job),
                      onInterest: () => _showInterest(job),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Job {
  final String id;
  final String title;
  final String description;
  final String clientName;
  final String location;
  final List<String> requiredSkills;
  final String datePosted;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.location,
    required this.requiredSkills,
    required this.datePosted,
  });
}

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final VoidCallback onInterest;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    required this.onInterest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: job.requiredSkills.map((skill) => Chip(
                  label: Text(skill),
                  backgroundColor: const Color(0xFFE3F2FD),
                  labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Posted by: ${job.clientName}",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          job.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onInterest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "I'm Interested",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                job.datePosted,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobDetailsBottomSheet extends StatelessWidget {
  final Job job;

  const JobDetailsBottomSheet({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              job.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Job Description:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "Client Information:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              title: Text(
                job.clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(job.location),
            ),
            const SizedBox(height: 20),
            const Text(
              "Required Skills:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.requiredSkills.map((skill) => Chip(
                label: Text(skill),
                backgroundColor: const Color(0xFFE3F2FD),
                labelStyle: const TextStyle(color: Color(0xFF1976D2)),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Posted:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job.datePosted,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("✅ Interest sent to ${job.clientName}"),
                      backgroundColor: Colors.green.shade700,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "I'm Interested - Contact Client",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF1976D2)),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int _currentIndex = 0; // For bottom navigation

  // Sample tasks data
  final List<Task> _allTasks = [
    Task(
      id: '1',
      title: 'Fix Leaking Kitchen Sink',
      clientName: 'Sarah Johnson',
      location: 'Cape Town, CBD',
      date: 'Today, 10:00 AM',
      status: TaskStatus.inProgress,
      description: 'My kitchen sink has been leaking for the past few days. Need someone to fix it as soon as possible. The pipe under the sink seems to be the issue.',
      requiredSkills: ['Plumbing'],
    ),
    Task(
      id: '2',
      title: 'Install New Light Fixtures',
      clientName: 'Mike Peterson',
      location: 'Johannesburg, Sandton',
      date: 'Tomorrow, 2:00 PM',
      status: TaskStatus.scheduled,
      description: 'Need help installing 4 new light fixtures in my living room and bedroom. I have all the materials, just need someone with electrical experience.',
      requiredSkills: ['Electrical'],
    ),
    Task(
      id: '3',
      title: 'Build Bookshelf',
      clientName: 'Lisa Chang',
      location: 'Durban, Umhlanga',
      date: 'Aug 15, 9:00 AM',
      status: TaskStatus.scheduled,
      description: 'Looking for a carpenter to build a custom bookshelf for my home office. I have the design and materials ready.',
      requiredSkills: ['Carpentry'],
    ),
    Task(
      id: '4',
      title: 'Bathroom Tile Repair',
      clientName: 'David Wilson',
      location: 'Pretoria, Centurion',
      date: 'Completed - Aug 10',
      status: TaskStatus.completed,
      description: 'Need someone to repair broken tiles in my bathroom and re-grout the entire area.',
      requiredSkills: ['Handyman', 'Tiling'],
    ),
    Task(
      id: '5',
      title: 'Electrical Outlet Installation',
      clientName: 'Amanda Roberts',
      location: 'Cape Town, Southern Suburbs',
      date: 'Completed - Aug 5',
      status: TaskStatus.completed,
      description: 'Need to install 3 new electrical outlets in my home office. Must have proper certification.',
      requiredSkills: ['Electrical'],
    ),
  ];

  List<Task> get _currentTasks {
    return _allTasks.where((task) => task.status != TaskStatus.completed).toList();
  }

  List<Task> get _completedTasks {
    return _allTasks.where((task) => task.status == TaskStatus.completed).toList();
  }

  void _updateTaskStatus(Task task, TaskStatus newStatus) {
    setState(() {
      task.status = newStatus;
    });

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Task marked as ${newStatus.toString().split('.').last}"),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskDetailsBottomSheet(task: task, onStatusUpdate: _updateTaskStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Tasks",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Colors.white],
            stops: [0.1, 0.4, 0.4],
          ),
        ),
        child: Column(
          children: [
            // Status Summary
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusCount(TaskStatus.scheduled, _currentTasks.where((t) => t.status == TaskStatus.scheduled).length),
                  _buildStatusCount(TaskStatus.inProgress, _currentTasks.where((t) => t.status == TaskStatus.inProgress).length),
                  _buildStatusCount(TaskStatus.completed, _completedTasks.length),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => _currentIndex = 0),
                      style: TextButton.styleFrom(
                        backgroundColor: _currentIndex == 0 ? const Color(0xFFE3F2FD) : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Current Tasks (${_currentTasks.length})",
                        style: TextStyle(
                          color: _currentIndex == 0 ? const Color(0xFF1976D2) : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => _currentIndex = 1),
                      style: TextButton.styleFrom(
                        backgroundColor: _currentIndex == 1 ? const Color(0xFFE3F2FD) : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Completed (${_completedTasks.length})",
                        style: TextStyle(
                          color: _currentIndex == 1 ? const Color(0xFF1976D2) : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: Container(
                color: Colors.white,
                child: _currentIndex == 0
                    ? _buildTasksList(_currentTasks)
                    : _buildTasksList(_completedTasks),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCount(TaskStatus status, int count) {
    Color color;
    String text;

    switch (status) {
      case TaskStatus.scheduled:
        color = Colors.orange;
        text = 'Scheduled';
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        text = 'In Progress';
        break;
      case TaskStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentIndex == 0 ? Icons.assignment_outlined : Icons.assignment_turned_in_outlined,
              size: 64,
              color: const Color(0xFF1976D2),
            ),
            const SizedBox(height: 16),
            Text(
              _currentIndex == 0 ? "No current tasks" : "No completed tasks yet",
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => _showTaskDetails(task),
        );
      },
    );
  }
}

enum TaskStatus { scheduled, inProgress, completed }

class Task {
  final String id;
  final String title;
  final String clientName;
  final String location;
  final String date;
  TaskStatus status;
  final String description;
  final List<String> requiredSkills;

  Task({
    required this.id,
    required this.title,
    required this.clientName,
    required this.location,
    required this.date,
    required this.status,
    required this.description,
    required this.requiredSkills,
  });
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case TaskStatus.scheduled:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case TaskStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.build;
        break;
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          task.status.toString().split('.').last,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: task.requiredSkills.map((skill) => Chip(
                  label: Text(skill),
                  backgroundColor: const Color(0xFFE3F2FD),
                  labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Client: ${task.clientName}",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          task.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    task.date,
                    style: TextStyle(
                      color: task.status == TaskStatus.completed ? Colors.green : const Color(0xFF1976D2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskDetailsBottomSheet extends StatelessWidget {
  final Task task;
  final Function(Task, TaskStatus) onStatusUpdate;

  const TaskDetailsBottomSheet({
    super.key,
    required this.task,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case TaskStatus.scheduled:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case TaskStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.build;
        break;
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        task.status.toString().split('.').last,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Job Description:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "Client Information:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              title: Text(
                task.clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(task.location),
            ),
            const SizedBox(height: 20),
            const Text(
              "Required Skills:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.requiredSkills.map((skill) => Chip(
                label: Text(skill),
                backgroundColor: const Color(0xFFE3F2FD),
                labelStyle: const TextStyle(color: Color(0xFF1976D2)),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Scheduled Date:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.date,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Status Update Buttons
            if (task.status != TaskStatus.completed) ...[
              const Text(
                "Update Status:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (task.status != TaskStatus.scheduled)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onStatusUpdate(task, TaskStatus.scheduled),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.orange),
                        ),
                        child: const Text(
                          "Mark as Scheduled",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ),
                  if (task.status != TaskStatus.scheduled) const SizedBox(width: 8),
                  if (task.status != TaskStatus.inProgress)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onStatusUpdate(task, TaskStatus.inProgress),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Text(
                          "Start Progress",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  if (task.status != TaskStatus.inProgress) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusUpdate(task, TaskStatus.completed),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Mark Complete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF1976D2)),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class ServiceDashboard extends StatefulWidget {
  const ServiceDashboard({super.key});

  @override
  State<ServiceDashboard> createState() => _ServiceDashboardState();
}

class _ServiceDashboardState extends State<ServiceDashboard> {
  int _currentIndex = 0;
  final double _serviceRating = 4.8; // Example rating for service provider
  final int _activeJobs = 5; // Example active jobs
  final int _completedJobs = 23; // Example completed jobs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HustleHub Provider',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WorkerSearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(),
            const SizedBox(height: 20),

            // Rating and progress section
            _buildRatingSection(),
            const SizedBox(height: 20),

            // Quick stats
            _buildStatsSection(),
            const SizedBox(height: 20),

            // Active Jobs section
            _buildActiveJobsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddJobPage()),
          );
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.business_center,
              size: 30,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, TechSolutions Inc!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ready to post your next service job?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),

    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _cStatCard(
            title: 'Active Jobs',
            value: _activeJobs.toString(),
            icon: Icons.work,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _cStatCard(
            title: 'Completed Jobs',
            value: _completedJobs.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _cStatCard(
            title: 'Applications',
            value: '12',
            icon: Icons.group,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Active Jobs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Jobs you\'ve posted and their current status',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 15),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 3, // Example number of jobs
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _JobCard(
              jobTitle: 'Website Development',
              jobType: 'IT & Programming',
              location: 'San Francisco, CA',
              postedDate: '2 days ago',
              applications: 5,
              status: index == 0 ? 'Active' : (index == 1 ? 'In Review' : 'Completed'),
              statusColor: index == 0 ? Colors.green : (index == 1 ? Colors.orange : Colors.blue),
            );
          },
        ),
      ],
    );
  }

  BottomAppBar _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: _currentIndex == 0 ? const Color(0xFF1976D2) : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.work,
              color: _currentIndex == 1 ? const Color(0xFF1976D2) : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 1;
              });
              // Navigator.push(context, MaterialPageRoute(builder: (_)=>PostedJobsPage()));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.track_changes,
              color: _currentIndex == 2 ? const Color(0xFF1976D2) : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 2;
              });
              // Navigator.push(context, MaterialPageRoute(builder: (_)=>JobTrackingPage()));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: _currentIndex == 3 ? const Color(0xFF1976D2) : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 3;
              });
              // Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfilePage()));
            },
          ),
        ],
      ),
    );
  }
}


// Custom Rating Bar Widget (same as before)(rename custom rating and use it propely it already exiat)
class cCustomRatingBar extends StatelessWidget {
  final double rating;
  final double itemSize;
  final ValueChanged<double> onRatingChanged;
  final bool ignoreGestures;

  const cCustomRatingBar({
    super.key,
    required this.rating,
    this.itemSize = 24.0,
    required this.onRatingChanged,
    this.ignoreGestures = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData iconData;
        Color color;

        if (index < rating.floor()) {
          // Full star
          iconData = Icons.star;
          color = Colors.amber;
        } else if (index < rating.ceil()) {
          // Half star
          iconData = Icons.star_half;
          color = Colors.amber;
        } else {
          // Empty star
          iconData = Icons.star_border;
          color = Colors.grey;
        }

        return GestureDetector(
          onTap: ignoreGestures
              ? null
              : () {
            onRatingChanged(index + 1.0);
          },
          child: Icon(
            iconData,
            size: itemSize,
            color: color,
          ),
        );
      }),
    );
  }
}

// Custom widget for statistics cards (same as before)()(rename custom rating and use it propely it already exiat)
class _cStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _cStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Add Job Page
class AddJobPage extends StatefulWidget {
  const AddJobPage({super.key});

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  String _selectedJobType = 'IT & Programming';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Job'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedJobType,
                decoration: const InputDecoration(
                  labelText: 'Job Type',
                  border: OutlineInputBorder(),
                ),
                items: <String>[
                  'IT & Programming',
                  'Design & Creative',
                  'Writing & Translation',
                  'Sales & Marketing',
                  'Admin & Support',
                  'Engineering & Architecture',
                  'Legal',
                  'Other'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedJobType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills Required (comma separated)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter required skills';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process the job posting
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job posted successfully!')),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Post Job',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Worker Search Page
class WorkerSearchPage extends StatefulWidget {
  const WorkerSearchPage({super.key});

  @override
  State<WorkerSearchPage> createState() => _WorkerSearchPageState();
}

class _WorkerSearchPageState extends State<WorkerSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _workers = [
    {
      'name': 'John Doe',
      'skills': ['Plumbing', 'Electrical'],
      'rating': 4.7,
      'completedJobs': 42,
      'location': 'San Francisco, CA'
    },
    {
      'name': 'Jane Smith',
      'skills': ['Design', 'UI/UX'],
      'rating': 4.9,
      'completedJobs': 78,
      'location': 'New York, NY'
    },
    {
      'name': 'Mike Johnson',
      'skills': ['Programming', 'Web Development'],
      'rating': 4.8,
      'completedJobs': 56,
      'location': 'Austin, TX'
    },
    {
      'name': 'Sarah Williams',
      'skills': ['Writing', 'Content Creation'],
      'rating': 4.6,
      'completedJobs': 34,
      'location': 'Chicago, IL'
    },
  ];
  List<Map<String, dynamic>> _filteredWorkers = [];

  @override
  void initState() {
    super.initState();
    _filteredWorkers = _workers;
    _searchController.addListener(_filterWorkers);
  }

  void _filterWorkers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredWorkers = _workers;
      });
    } else {
      setState(() {
        _filteredWorkers = _workers.where((worker) {
          return worker['name'].toLowerCase().contains(query) ||
              worker['skills'].any((skill) => skill.toLowerCase().contains(query)) ||
              worker['location'].toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Workers'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, skill, or location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredWorkers.length,
              itemBuilder: (context, index) {
                final worker = _filteredWorkers[index];
                return _WorkerCard(
                  name: worker['name'],
                  skills: worker['skills'],
                  rating: worker['rating'],
                  completedJobs: worker['completedJobs'],
                  location: worker['location'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkerProfilePage(worker: worker),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



// Worker Profile Page
class WorkerProfilePage extends StatelessWidget {
  final Map<String, dynamic> worker;

  const WorkerProfilePage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(worker['name']),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF1976D2),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    worker['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    worker['location'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Skills',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: worker['skills']
                  .map<Widget>((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rating & Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CustomRatingBar(
                  rating: worker['rating'],
                  itemSize: 24,
                  onRatingChanged: (rating) {},
                  ignoreGestures: true,
                ),
                const SizedBox(width: 8),
                Text(
                  '${worker['rating']}/5.0',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Completed Jobs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${worker['completedJobs']} jobs successfully completed',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Contact this worker
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'View Contact Details',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Update the Worker Card to make name clickable
class _WorkerCard extends StatelessWidget {
  final String name;
  final List<String> skills;
  final double rating;
  final int completedJobs;
  final String location;
  final VoidCallback onTap;

  const _WorkerCard({
    required this.name,
    required this.skills,
    required this.rating,
    required this.completedJobs,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: GestureDetector(
          onTap: onTap, // Avatar click goes to profile
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF1976D2),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: GestureDetector(
          onTap: onTap, // Name click goes to profile
          child: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1976D2),
              decoration: TextDecoration.underline, // Indicate clickable
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              skills.join(', '),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                cCustomRatingBar(
                  rating: rating,
                  itemSize: 16,
                  onRatingChanged: (rating) {},
                  ignoreGestures: true,
                ),
                const SizedBox(width: 8),
                Text('$rating'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.work, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$completedJobs jobs completed'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(location),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

// Update the Job Card to make "View Details" clickable
class _JobCard extends StatelessWidget {
  final String jobTitle;
  final String jobType;
  final String location;
  final String postedDate;
  final int applications;
  final String status;
  final Color statusColor;

  const _JobCard({
    required this.jobTitle,
    required this.jobType,
    required this.location,
    required this.postedDate,
    required this.applications,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                jobTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            jobType,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                postedDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '$applications Applications',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to full job post page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullJobPostPage(
                        jobTitle: jobTitle,
                        jobType: jobType,
                        location: location,
                        postedDate: postedDate,
                        applications: applications,
                        status: status,
                        statusColor: statusColor,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Full Job Post Page (UI only)
class FullJobPostPage extends StatelessWidget {
  final String jobTitle;
  final String jobType;
  final String location;
  final String postedDate;
  final int applications;
  final String status;
  final Color statusColor;

  const FullJobPostPage({
    super.key,
    required this.jobTitle,
    required this.jobType,
    required this.location,
    required this.postedDate,
    required this.applications,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jobTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(jobType, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(location),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(postedDate),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$applications Applications'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Job Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is an example job description. Describe the tasks, requirements, and any other relevant details here.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reviews',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Example reviews
                  Row(
                    children: [
                      cCustomRatingBar(
                        rating: 4.5,
                        itemSize: 16,
                        onRatingChanged: (r) {},
                        ignoreGestures: true,
                      ),
                      const SizedBox(width: 8),
                      const Text('4.5/5 - Excellent work!'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      cCustomRatingBar(
                        rating: 4.0,
                        itemSize: 16,
                        onRatingChanged: (r) {},
                        ignoreGestures: true,
                      ),
                      const SizedBox(width: 8),
                      const Text('4.0/5 - Very professional'),
                    ],
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

