import 'package:flutter/material.dart';
import 'dart:async'; //
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';


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
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _otherSkillController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _profileImage;
  final picker = ImagePicker();

  String _selectedRole = "Service Provider";
  String _experienceLevel = "Beginner";
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

  final List<String> _experienceLevels = ["Beginner", "Intermediate", "Expert"];

  final Set<String> _selectedSkills = {};
  bool _showOtherSkillField = false;

  Future<void> registerUser({
    required String uid,
    required String email,
    required String fullName,
    required String password,
    required String surName,
    required String role,
    required List<String> skills,
    String? profileImageUrl,
    required String location,
    required String experienceLevel,
  }) async {
    // Create user document
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'password': password,
      'surName': surName,
      'role': role,
      'skills': skills,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'experienceLevel': experienceLevel,
      'isVerified': false,
      'createdAt': Timestamp.now(),
    });

    // If user is a service provider, create a worker document
    if (role == "Service Provider") {
      await FirebaseFirestore.instance.collection('workers').doc(uid).set({
        'uid': uid,
        'fullName': '$fullName $surName',
        'email': email,
        'skills': skills,
        'profileImageUrl': profileImageUrl,
        'location': location,
        'experienceLevel': experienceLevel,
        'rating': 0,
        'totalJobs': 0,
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(
          '${_emailController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(_profileImage!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
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

  Future<void> _submit() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Passwords do not match"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_nameController.text.isEmpty || _surnameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter your name and surname"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter your location"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedRole == "Service Provider" &&
        _selectedSkills.isEmpty &&
        !(_showOtherSkillField && _otherSkillController.text.isNotEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please select at least one skill"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final List<String> finalSkills = _selectedSkills.toList();
      if (_showOtherSkillField && _otherSkillController.text.isNotEmpty) {
        finalSkills.add(_otherSkillController.text.trim());
      }

      String? profileImageUrl = await _uploadProfileImage();

      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await registerUser(
        uid: userCredential.user!.uid,
        email: _emailController.text.trim(),
        fullName: _nameController.text.trim(),
        password: _passwordController.text.trim(),
        surName: _surnameController.text.trim(),
        role: _selectedRole,
        skills: finalSkills,
        profileImageUrl: profileImageUrl,
        location: _locationController.text.trim(),
        experienceLevel: _experienceLevel,
      );

      await userCredential.user!.sendEmailVerification();

      // Force logout after sign up
      await FirebaseAuth.instance.signOut();

      // ✅ Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          const Text("✅ Sign Up Successful! Please verify your email."),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to LoginPage after small delay
      Future.delayed(const Duration(seconds: 0), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred during sign up";
      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "The account already exists for that email";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ $errorMessage"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ An error occurred: $e"),
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2)),
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
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person,
                        size: 50, color: Color(0xFF1976D2))
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
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
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
                        child: _buildTextField(
                            _nameController, "First Name", Icons.person),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTextField(_surnameController, "Surname",
                            Icons.person_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(_emailController, "Email", Icons.email,
                      TextInputType.emailAddress),
                  const SizedBox(height: 15),
                  _buildTextField(
                      _locationController, "Location", Icons.location_on),
                  const SizedBox(height: 15),
                  _buildPasswordField(_passwordController, "Password",
                      _obscurePassword, () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      }),
                  const SizedBox(height: 15),
                  _buildPasswordField(_confirmPasswordController,
                      "Confirm Password", _obscureConfirm, () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      }),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text("Forgot Password?",
                          style: TextStyle(color: Color(0xFF1976D2))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Role
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "I want to join as a:",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2)),
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
                              color: _selectedRole == "Service Provider"
                                  ? Colors.white
                                  : const Color(0xFF1976D2)),
                          onSelected: (_) => setState(
                                  () => _selectedRole = "Service Provider"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Client"),
                          selected: _selectedRole == "Client",
                          selectedColor: const Color(0xFF1976D2),
                          labelStyle: TextStyle(
                              color: _selectedRole == "Client"
                                  ? Colors.white
                                  : const Color(0xFF1976D2)),
                          onSelected: (_) =>
                              setState(() => _selectedRole = "Client"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Experience Level (only for Service Providers)
                  if (_selectedRole == "Service Provider") ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Experience Level:",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1976D2)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _experienceLevel,
                      items: _experienceLevels.map((String level) {
                        return DropdownMenuItem<String>(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _experienceLevel = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
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
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2)),
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
                      labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1976D2)),
                      onSelected: (_selectedRole == "Client")
                          ? null
                          : (_) => _toggleSkill(skill),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
                if (_showOtherSkillField)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildTextField(
                        _otherSkillController, "Enter your skill", Icons.star),
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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 5,
          shadowColor: Colors.blue.shade200,
        ),
        child: const Text(
          "Sign Up",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginPage()));
          },
          child: const Text(
            "Log In",
            style: TextStyle(
                color: Color(0xFF1976D2), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, [TextInputType inputType = TextInputType.text]) {
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

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscureText, VoidCallback onToggle) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF1976D2)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF1976D2)),
          onPressed: onToggle,
        ),
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
}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
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
    super.dispose();
  }
  Future<void> _login() async {
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
      // 1. Authenticate with Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Get user data from Firestore to check actual role
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User data not found");
      }

      final String userRole = userDoc['role'] ?? 'Client';

      // 3. Verify the selected role matches the actual role
      if (userRole != _selectedRole) {
        throw Exception("You are registered as a $userRole, not $_selectedRole");
      }

      // 4. Navigate to the correct dashboard based on ACTUAL role
      if (userRole == "Service Provider") {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ClientDashboard())
        );
      } else if (userRole == "Client") {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ServiceDashboard())
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Login successful as $userRole!"),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ $errorMessage"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
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
              // Header
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
                    _buildTextField(_emailController, "Email Address", Icons.email),
                    const SizedBox(height: 16),
                    _buildPasswordField(_passwordController, "Password", _obscurePassword, () {
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
                            style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w600),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 5,
                          shadowColor: Colors.blue.shade200,
                        ),
                        child: Text(
                          "Login as $_selectedRole",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
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
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w600),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) => TextField(
        controller: controller,
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

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscureText, VoidCallback onToggle) => TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF1976D2)),
          suffixIcon: IconButton(icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF1976D2)), onPressed: onToggle),
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
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


// Make sure you import your other pages & custom widgets like CustomRatingBar, JobsPage, TasksPage, ProfilePage

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _currentIndex = 0;
  final double _userRating = 4.7; // Example rating
  final int _completedJobs = 12; // Example completed jobs

  Future<String> getUsername() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return "User";
    final dat = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var doc = dat.data() as Map<String, dynamic>?;
    if (doc == null) return "User";
    final String name = doc['fullName'] ?? "User";
    return name;
  }

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
                FutureBuilder<String>(
                  future: getUsername(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        "Loading...",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        "Error loading name",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    } else {
                      return Text(
                        "Welcome back, ${snapshot.data}!",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }
                  },
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => JobsPage()));
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => TasksPage()));
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
            },
          ),
        ],
      ),
    );
  }
}

// Example stat card widget (make sure you have this)
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
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
//widget for map markers

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _otherSocialController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  bool _loading = true;

  String _name = "";
  String _surname = "";
  String _location = "";
  Set<String> _selectedSkills = {};

  int _completedJobs = 0;
  double _rating = 0.0;
  double _satisfaction = 0.0;

  final List<String> _skillsList = [
    "Washing", "Gardening", "Painting", "Plumbing", "Electrical",
    "Cooking", "Tutoring", "Cleaning", "Carpentry", "Delivery", "Other"
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // --- Fetch from users table ---
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      _name = userData['name'] ?? "";
      _surname = userData['surname'] ?? "";
      _location = userData['location'] ?? "";
      _selectedSkills = Set<String>.from(userData['skills'] ?? []);

      // --- Fetch worker_description (or create if missing) ---
      final descRef =
      FirebaseFirestore.instance.collection('worker_description').doc(uid);
      final descDoc = await descRef.get();

      if (!descDoc.exists) {
        await descRef.set({
          'userId': uid,
          'bio': '',
          'linkedIn': null,
          'github': null,
          'otherSocial': null,
          'skills': _selectedSkills.toList(),
          'location': _location,
        });
      } else {
        final descData = descDoc.data() ?? {};
        _bioController.text = descData['bio'] ?? "";
        _linkedInController.text = descData['linkedIn'] ?? "";
        _githubController.text = descData['github'] ?? "";
        _otherSocialController.text = descData['otherSocial'] ?? "";
      }

      // --- Calculate stats from jobs + tasks ---
      await _calculateStats(uid);

      setState(() => _loading = false);
    } catch (e) {
      debugPrint("Error loading profile: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _calculateStats(String uid) async {
    // Jobs completed
    final jobsQuery = await FirebaseFirestore.instance
        .collection('jobs')
        .where('workerId', isEqualTo: uid)
        .where('status', isEqualTo: 'complete')
        .get();

    _completedJobs = jobsQuery.docs.length;

    // Rating from tasks table
    final tasksQuery = await FirebaseFirestore.instance
        .collection('tasks')
        .where('workerId', isEqualTo: uid)
        .get();

    double totalRating = 0;
    int count = 0;
    for (var doc in tasksQuery.docs) {
      final rating = (doc['rating'] ?? 0).toDouble();
      totalRating += rating;
      count++;
    }

    if (count > 0) {
      _rating = totalRating / count;
      if (_rating > 5) _rating = 5;
      _satisfaction = (_rating / 5) * 100;
      if (_satisfaction > 100) _satisfaction = 100;
    } else {
      _rating = 0;
      _satisfaction = 0;
    }
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Update worker_description
      await FirebaseFirestore.instance
          .collection('worker_description')
          .doc(uid)
          .update({
        'bio': _bioController.text,
        'linkedIn': _linkedInController.text.isEmpty
            ? null
            : _linkedInController.text,
        'github':
        _githubController.text.isEmpty ? null : _githubController.text,
        'otherSocial': _otherSocialController.text.isEmpty
            ? null
            : _otherSocialController.text,
        'skills': _selectedSkills.toList(),
        'location': _location,
      });

      // Update skills in users as well
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'skills': _selectedSkills.toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Profile updated successfully!"),
          backgroundColor: Colors.green.shade700,
        ),
      );
      _toggleEdit();
    } catch (e) {
      debugPrint("Error saving profile: $e");
    }
  }

  void _toggleEdit() => setState(() => _isEditing = !_isEditing);

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
            color: Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 60, color: Color(0xFF1976D2))
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF1976D2),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "$_name $_surname",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(_location, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 24),

            // Bio
            TextField(
              controller: _bioController,
              enabled: _isEditing,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Social links
            TextField(
              controller: _linkedInController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: "LinkedIn"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _githubController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: "GitHub"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otherSocialController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: "Other Social Media"),
            ),
            const SizedBox(height: 20),

            // Skills
            const Text("Skills",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skillsList.map((skill) {
                final selected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: selected,
                  onSelected: _isEditing ? (_) => _toggleSkill(skill) : null,
                  selectedColor: const Color(0xFF1976D2),
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Stats
            const Text("Service Stats",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn("$_completedJobs", "Jobs Completed"),
                _buildStatColumn(_rating.toStringAsFixed(1), "Rating"),
                _buildStatColumn("${_satisfaction.toStringAsFixed(0)}%", "Satisfaction"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = '';
  List<String> _userSkills = [];
  List<Job> _allJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserSkills();
    _fetchJobs();
  }

  Future<void> _fetchUserSkills() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('workers').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _userSkills = List<String>.from(data['skills'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error fetching user skills: $e');
    }
  }

  Future<void> _fetchJobs() async {
    try {
      final querySnapshot = await _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'Active')
          .orderBy('postedAt', descending: true)
          .get();

      final jobs = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Job(
          id: doc.id,
          title: data['title'] ?? 'No Title',
          description: data['description'] ?? 'No description available',
          clientName: data['postedByName'] ?? 'Unknown Client',
          location: data['location'] ?? 'Location not specified',
          requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
          datePosted: _formatDate(data['postedAt']),
          budget: (data['budget'] ?? 0.0).toDouble(),
          postedBy: data['postedBy'] ?? '',
        );
      }).toList();

      setState(() {
        _allJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching jobs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';

    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
    return 'Unknown date';
  }

  // Case-insensitive skill matching
  bool _skillsMatch(String jobSkill, String userSkill) {
    return jobSkill.toLowerCase().trim() == userSkill.toLowerCase().trim();
  }

  List<Job> get _filteredJobs {
    if (_searchQuery.isEmpty) {
      // Show jobs that match AT LEAST ONE of the user's skills (case-insensitive)
      return _allJobs.where((job) =>
          job.requiredSkills.any((jobSkill) =>
              _userSkills.any((userSkill) => _skillsMatch(jobSkill, userSkill))
          )
      ).toList();
    } else {
      // Show jobs that match search query AND at least one skill (case-insensitive)
      return _allJobs.where((job) =>
      job.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          job.requiredSkills.any((jobSkill) =>
              _userSkills.any((userSkill) => _skillsMatch(jobSkill, userSkill))
          )
      ).toList();
    }
  }

  // Get matching skills count for sorting (most matches first) - case insensitive
  int _getMatchingSkillsCount(Job job) {
    return job.requiredSkills.where((jobSkill) =>
        _userSkills.any((userSkill) => _skillsMatch(jobSkill, userSkill))
    ).length;
  }

  // Get actual matching skills list - case insensitive
  List<String> _getMatchingSkills(Job job) {
    return job.requiredSkills.where((jobSkill) =>
        _userSkills.any((userSkill) => _skillsMatch(jobSkill, userSkill))
    ).toList();
  }

  // Sort jobs by number of matching skills (descending)
  List<Job> get _sortedJobs {
    return _filteredJobs..sort((a, b) {
      final aMatches = _getMatchingSkillsCount(a);
      final bMatches = _getMatchingSkillsCount(b);
      return bMatches.compareTo(aMatches); // Descending order
    });
  }

  void _showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,  //
      isScrollControlled: true,
      builder: (context) => JobDetailsBottomSheet(
        job: job,
        matchingSkills: _getMatchingSkills(job),
        onApply: (proposedPrice) => _applyForJob(job, proposedPrice),
      ),
    );

  }

  Future<void> _applyForJob(Job job, double proposedPrice) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Create a job application/request
        await _firestore.collection('requests').add({
          'jobId': job.id,
          'jobTitle': job.title,
          'workerId': user.uid,
          'workerName': _userSkills.isNotEmpty ? 'Professional Worker' : 'User',
          'clientId': job.postedBy,
          'clientName': job.clientName,
          'proposedPrice': proposedPrice,
          'status': 'pending',
          'appliedAt': FieldValue.serverTimestamp(),
          'location': job.location,
          'requiredSkills': job.requiredSkills,
          'matchingSkills': _getMatchingSkills(job),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Application sent to ${job.clientName} for \$$proposedPrice"),
            backgroundColor: Colors.green.shade700,
          ),
        );

        Navigator.pop(context); // Close the bottom sheet
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error applying for job: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
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
            if (_userSkills.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      const Text(
                        "Your skills:",
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
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                  ),
                )
                    : _sortedJobs.isEmpty
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
                  itemCount: _sortedJobs.length,
                  itemBuilder: (context, index) {
                    final job = _sortedJobs[index];
                    final matchCount = _getMatchingSkillsCount(job);
                    final matchingSkills = _getMatchingSkills(job);

                    return JobCard(
                      job: job,
                      matchCount: matchCount,
                      onTap: () => _showJobDetails(job),
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
  final double budget;
  final String postedBy;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.location,
    required this.requiredSkills,
    required this.datePosted,
    required this.budget,
    required this.postedBy,
  });
}
// Add this JobCard widget before your _JobsPageState class
class JobCard extends StatelessWidget {
  final Job job;
  final int matchCount;
  final VoidCallback onTap;

  const JobCard({
    required this.job,
    required this.matchCount,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(0),
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
            // Job title with blue-white gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF1976D2), // Primary blue
                    Color(0xFF42A5F5), // Lighter blue
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Text(
                      "$matchCount skills match",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Job details section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${job.location} • ${job.budget.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Posted: ${job.datePosted}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'By: ${job.clientName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
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

// Also make sure you have a Job class defined like this:


// Then in your ListView.builder, use the correct widget:


class JobDetailsBottomSheet extends StatefulWidget {
  final Job job;
  final List<String> matchingSkills;
  final Function(double) onApply;

  const JobDetailsBottomSheet({
    super.key,
    required this.job,
    required this.matchingSkills,
    required this.onApply,
  });

  @override
  State<JobDetailsBottomSheet> createState() => _JobDetailsBottomSheetState();
}

class _JobDetailsBottomSheetState extends State<JobDetailsBottomSheet> {
  final TextEditingController _priceController = TextEditingController();
  double _proposedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _proposedPrice = widget.job.budget;
    _priceController.text = _proposedPrice.toStringAsFixed(2);
  }

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
              widget.job.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),

            // Matching skills info
            if (widget.matchingSkills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You match ${widget.matchingSkills.length} required skill${widget.matchingSkills.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Budget Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, color: Color(0xFF1976D2), size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Client's Budget:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        Text(
                          '\$${widget.job.budget.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
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
              widget.job.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Proposed Price Input
            const Text(
              "Your Proposed Price:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Enter your proposed price',
              ),
              onChanged: (value) {
                final price = double.tryParse(value) ?? 0.0;
                setState(() {
                  _proposedPrice = price;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              _proposedPrice > widget.job.budget
                  ? '⚠️ Your price is higher than client\'s budget'
                  : _proposedPrice < widget.job.budget
                  ? '✅ Your price is competitive'
                  : '💰 Matching client\'s budget',
              style: TextStyle(
                color: _proposedPrice > widget.job.budget ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w500,
              ),
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
                widget.job.clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(widget.job.location),
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
              children: widget.job.requiredSkills.map((skill) => Chip(
                label: Text(skill),
                backgroundColor: widget.matchingSkills.any((match) =>
                match.toLowerCase().trim() == skill.toLowerCase().trim())
                    ? Colors.green.shade100
                    : const Color(0xFFE3F2FD),
                labelStyle: TextStyle(
                  color: widget.matchingSkills.any((match) =>
                  match.toLowerCase().trim() == skill.toLowerCase().trim())
                      ? Colors.green.shade800
                      : const Color(0xFF1976D2),
                  fontWeight: widget.matchingSkills.any((match) =>
                  match.toLowerCase().trim() == skill.toLowerCase().trim())
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
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
              widget.job.datePosted,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_proposedPrice > 0) {
                    widget.onApply(_proposedPrice);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("❌ Please enter a valid price"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Apply for \$${_proposedPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
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

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int _currentIndex = 0; // For bottom navigation
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // Fetch tasks from Firestore
  Future<void> _fetchTasks() async {
    try {
      // For testing, use employee ID "1" - replace with _currentUser!.uid in production
      final employeeId = _currentUser?.uid ?? "1";
      final iid = 1; // Use "1" for testing

      QuerySnapshot querySnapshot = await _firestore
          .collection('jobs')
          .where('employee', isEqualTo: iid)
          .where('status', whereIn: ['Active', 'Inactive', 'In Progress', 'Completed'])
          .get();

      setState(() {
        _tasks = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching tasks: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get current tasks (Active, Inactive, In Progress)
  List<DocumentSnapshot> get _currentTasks {
    return _tasks.where((task) =>
    task['status'] == 'Active' ||
        task['status'] == 'Inactive' ||
        task['status'] == 'In Progress').toList();
  }

  // Get completed tasks (only Completed status)
  List<DocumentSnapshot> get _completedTasks {
    return _tasks.where((task) => task['status'] == 'Completed').toList();
  }

  // Convert Firestore status string to TaskStatus enum
  TaskStatus _getStatusFromString(String status) {
    switch (status) {
      case 'Active':
        return TaskStatus.active;
      case 'Inactive':
        return TaskStatus.inactive;
      case 'In Progress':
        return TaskStatus.inProgress;
      case 'Completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.active;
    }
  }

  // Convert TaskStatus enum to Firestore status string
  String _getStringFromStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.active:
        return 'Active';
      case TaskStatus.inactive:
        return 'Inactive';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  // Update task status in Firestore
  Future<void> _updateTaskStatus(DocumentSnapshot taskDoc, TaskStatus newStatus) async {
    try {
      await _firestore.collection('jobs').doc(taskDoc.id).update({
        'status': _getStringFromStatus(newStatus),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh the tasks list
      _fetchTasks();

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Task marked as ${_getStringFromStatus(newStatus)}"),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      print("Error updating task status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update task status"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTaskDetails(DocumentSnapshot taskDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskDetailsBottomSheet(
        taskDoc: taskDoc,
        onStatusUpdate: _updateTaskStatus,
      ),
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
                  _buildStatusCount('Active', _currentTasks.where((t) => t['status'] == 'Active').length, Colors.blue),
                  _buildStatusCount('In Progress', _currentTasks.where((t) => t['status'] == 'In Progress').length, Colors.orange),
                  _buildStatusCount('Completed', _completedTasks.length, Colors.green),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _currentIndex == 0
                    ? _buildTasksList(_currentTasks)
                    : _buildTasksList(_completedTasks),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCount(String status, int count, Color color) {
    IconData icon;

    switch (status) {
      case 'Active':
        icon = Icons.access_time;
        break;
      case 'In Progress':
        icon = Icons.build;
        break;
      case 'Completed':
        icon = Icons.check_circle;
        break;
      default:
        icon = Icons.help_outline;
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
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList(List<DocumentSnapshot> tasks) {
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
        final taskDoc = tasks[index];
        return TaskCard(
          taskDoc: taskDoc,
          onTap: () => _showTaskDetails(taskDoc),
        );
      },
    );
  }
}

enum TaskStatus { active, inactive, inProgress, completed }

class TaskCard extends StatelessWidget {
  final DocumentSnapshot taskDoc;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.taskDoc,
    required this.onTap,
  });

  // Helper method to get status color and icon
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'Active':
        return {'color': Colors.blue, 'icon': Icons.access_time};
      case 'Inactive':
        return {'color': Colors.grey, 'icon': Icons.pause_circle};
      case 'In Progress':
        return {'color': Colors.orange, 'icon': Icons.build};
      case 'Completed':
        return {'color': Colors.green, 'icon': Icons.check_circle};
      default:
        return {'color': Colors.grey, 'icon': Icons.help_outline};
    }
  }

  // Format timestamp to readable date
  String _formatDate(dynamic date) {
    if (date == null) return 'No date set';

    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(taskDoc['status']);
    final Color statusColor = statusInfo['color'];
    final IconData statusIcon = statusInfo['icon'];

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
                      taskDoc['title'] ?? 'No Title',
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
                          taskDoc['status'] ?? 'unknown',
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
                taskDoc['description'] ?? 'No description',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              if (taskDoc['skills'] != null && (taskDoc['skills'] as List).isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (taskDoc['skills'] as List).map((skill) => Chip(
                    label: Text(skill.toString()),
                    backgroundColor: const Color(0xFFE3F2FD),
                    labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              if (taskDoc['skills'] != null && (taskDoc['skills'] as List).isNotEmpty)
                const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Location: ${taskDoc['location'] ?? 'Unknown'}",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDate(taskDoc['postedAt']),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    taskDoc['status'] == 'Completed' ? 'Completed' : _formatDate(taskDoc['postedAt']),
                    style: TextStyle(
                      color: taskDoc['status'] == 'Completed' ? Colors.green : const Color(0xFF1976D2),
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
  final DocumentSnapshot taskDoc;
  final Function(DocumentSnapshot, TaskStatus) onStatusUpdate;

  const TaskDetailsBottomSheet({
    super.key,
    required this.taskDoc,
    required this.onStatusUpdate,
  });

  // Helper method to get status color and icon
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'Active':
        return {'color': Colors.blue, 'icon': Icons.access_time};
      case 'Inactive':
        return {'color': Colors.grey, 'icon': Icons.pause_circle};
      case 'In Progress':
        return {'color': Colors.orange, 'icon': Icons.build};
      case 'Completed':
        return {'color': Colors.green, 'icon': Icons.check_circle};
      default:
        return {'color': Colors.grey, 'icon': Icons.help_outline};
    }
  }

  // Format timestamp to readable date
  String _formatDate(dynamic date) {
    if (date == null) return 'No date set';

    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(taskDoc['status']);
    final Color statusColor = statusInfo['color'];
    final IconData statusIcon = statusInfo['icon'];

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
                    taskDoc['title'] ?? 'No Title',
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
                        taskDoc['status'] ?? 'unknown',
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
              taskDoc['description'] ?? 'No description',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "Location:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              taskDoc['location'] ?? 'Unknown location',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (taskDoc['skills'] != null && (taskDoc['skills'] as List).isNotEmpty) ...[
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
                children: (taskDoc['skills'] as List).map((skill) => Chip(
                  label: Text(skill.toString()),
                  backgroundColor: const Color(0xFFE3F2FD),
                  labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                )).toList(),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              "Posted Date:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(taskDoc['postedAt']),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Status Update Buttons
            if (taskDoc['status'] != 'Completed') ...[
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
                  if (taskDoc['status'] != 'Active')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onStatusUpdate(taskDoc, TaskStatus.active),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Text(
                          "Mark as Active",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  if (taskDoc['status'] != 'Active') const SizedBox(width: 8),
                  if (taskDoc['status'] != 'In Progress')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onStatusUpdate(taskDoc, TaskStatus.inProgress),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.orange),
                        ),
                        child: const Text(
                          "Start Progress",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ),
                  if (taskDoc['status'] != 'In Progress') const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusUpdate(taskDoc, TaskStatus.completed),
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
  double _serviceRating = 0.0; // Will be fetched from Firestore
  int _activeJobsCount = 0;
  int _completedJobsCount = 0;
  String _jobFilter = 'active'; // 'active', 'inactive', or 'all'

  @override
  void initState() {
    super.initState();
    _loadJobCounts();
    _loadServiceRating();
  }

  Future<void> _loadServiceRating() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final ratingDoc = await FirebaseFirestore.instance
          .collection('ratings')
          .doc(userId)
          .get();

      if (ratingDoc.exists) {
        final data = ratingDoc.data() as Map<String, dynamic>;
        setState(() {
          _serviceRating = (data['averageRating'] ?? 0.0).toDouble();
        });
      }
    } catch (e) {
      print('Error loading rating: $e');
    }
  }

  Future<void> _loadJobCounts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Get active jobs count (only those with employee = 1)
    final activeQuery = await FirebaseFirestore.instance
        .collection('jobs')
        .where('postedBy', isEqualTo: userId)
        .where('status', isEqualTo: 'Active')
        .where('employee', isEqualTo: 1) // Only jobs with employee = 1
        .get();

    setState(() {
      _activeJobsCount = activeQuery.size;
    });

    // Get completed jobs count (only those with employee = 1)
    final completedQuery = await FirebaseFirestore.instance
        .collection('jobs')
        .where('postedBy', isEqualTo: userId)
        .where('status', isEqualTo: 'Completed')
        .where('employee', isEqualTo: 1) // Only jobs with employee = 1
        .get();

    setState(() {
      _completedJobsCount = completedQuery.size;
    });
  }

  Future<String> getUsername() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return "User";
    final dat = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var doc = dat.data() as Map<String, dynamic>?;
    if (doc == null) return "User";
    final String name = doc['fullName'] ?? "User";
    return name;
  }

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

            // Jobs section with filter
            _buildJobsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddJobPage()),
          ).then((_) {
            // Refresh counts when returning from AddJobPage
            _loadJobCounts();
          });
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
                FutureBuilder<String>(
                  future: getUsername(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        "Loading...",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        "Error loading name",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    } else {
                      return Text(
                        "Welcome back, ${snapshot.data}!",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }
                  },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Service Rating',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                _serviceRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Navigate to ratings page or show ratings dialog
                  _showRatingDetails(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _serviceRating / 5.0,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 5),
          const Text(
            'Based on customer reviews',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your Rating Details'),
          content: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('ratings')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text('No ratings yet.');
              }

              final ratingData = snapshot.data!.data() as Map<String, dynamic>;
              final totalRatings = ratingData['totalRatings'] ?? 0;
              final averageRating = ratingData['averageRating'] ?? 0.0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Average Rating: ${averageRating.toStringAsFixed(1)}/5.0'),
                  Text('Total Ratings: $totalRatings'),
                  const SizedBox(height: 16),
                  const Text('To improve your rating:'),
                  const Text('• Complete jobs on time'),
                  const Text('• Communicate clearly with clients'),
                  const Text('• Provide quality service'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Active Jobs',
            value: _activeJobsCount.toString(),
            icon: Icons.work,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            title: 'Completed Jobs',
            value: _completedJobsCount.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            title: 'Total Jobs',
            value: (_activeJobsCount + _completedJobsCount).toString(),
            icon: Icons.list_alt,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
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
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Jobs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 10),

        // Filter chips
        Row(
          children: [
            FilterChip(
              label: const Text('Active'),
              selected: _jobFilter == 'active',
              onSelected: (selected) {
                setState(() {
                  _jobFilter = selected ? 'active' : 'all';
                });
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
            ),
            const SizedBox(width: 10),
            FilterChip(
              label: const Text('Inactive'),
              selected: _jobFilter == 'inactive',
              onSelected: (selected) {
                setState(() {
                  _jobFilter = selected ? 'inactive' : 'all';
                });
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
            ),
            const SizedBox(width: 10),
            FilterChip(
              label: const Text('All'),
              selected: _jobFilter == 'all',
              onSelected: (selected) {
                setState(() {
                  _jobFilter = selected ? 'all' : 'active';
                });
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
            ),
          ],
        ),

        const SizedBox(height: 15),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('postedBy', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .where('employee', isEqualTo: 1) // Only show jobs with employee = 1
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            // Filter jobs based on selected filter
            final filteredDocs = docs.where((doc) {
              final job = doc.data()! as Map<String, dynamic>;
              final status = job['status']?.toString().toLowerCase() ?? '';

              if (_jobFilter == 'active') {
                return status == 'active';
              } else if (_jobFilter == 'inactive') {
                return status != 'active';
              } else {
                return true; // Show all jobs
              }
            }).toList();

            if (filteredDocs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No jobs found with the selected filter.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filteredDocs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final job = filteredDocs[index].data()! as Map<String, dynamic>;

                // Proper date formatting from postedAt field
                String formattedDate = 'Date not available';
                if (job['postedAt'] != null) {
                  if (job['postedAt'] is Timestamp) {
                    formattedDate = DateFormat.yMMMd().format((job['postedAt'] as Timestamp).toDate());
                  } else if (job['postedAt'] is DateTime) {
                    formattedDate = DateFormat.yMMMd().format(job['postedAt'] as DateTime);
                  } else if (job['postedAt'] is String) {
                    try {
                      final dateTime = DateTime.parse(job['postedAt'] as String);
                      formattedDate = DateFormat.yMMMd().format(dateTime);
                    } catch (e) {
                      formattedDate = 'Invalid date';
                    }
                  }
                }

                return _JobCard(
                  jobTitle: job['title'] ?? 'No title',
                  jobType: job['type'] ?? 'N/A',
                  location: job['location'] ?? 'N/A',
                  postedDate: formattedDate,
                  applications: job['applications'] ?? 0,
                  status: job['status'] ?? 'Unknown',
                  statusColor: _getStatusColor(job['status'] ?? 'Unknown'),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'in review':
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
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
            blurRadius: 10,
            offset: const Offset(0, 5),
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
              Expanded(
                child: Text(
                  jobTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$jobType • $location',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posted: $postedDate',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '$applications applications',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkerJobsPage extends StatefulWidget {
  const WorkerJobsPage({super.key});

  @override
  State<WorkerJobsPage> createState() => _WorkerJobsPageState();
}

class _WorkerJobsPageState extends State<WorkerJobsPage> {
  List<Map<String, dynamic>> _jobRequests = [];

  @override
  void initState() {
    super.initState();
    _loadJobRequests();
  }

  Future<void> _loadJobRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // First, get the worker document to access their job requests
      final workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .get();

      if (workerDoc.exists) {
        final workerData = workerDoc.data() as Map<String, dynamic>;

        // Get the list of job request IDs from the worker document
        final List<dynamic> jobRequestIds = workerData['jobRequests'] ?? [];

        if (jobRequestIds.isNotEmpty) {
          // Fetch all job requests from the jobRequests collection
          final QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('jobRequests')
              .where(FieldPath.documentId, whereIn: jobRequestIds)
              .get();

          // Debug: Print the fetched documents
          print('Fetched ${snapshot.docs.length} job requests');
          snapshot.docs.forEach((doc) {
            print('Job ID: ${doc.id}');
            print('Job Data: ${doc.data()}');
          });

          setState(() {
            _jobRequests = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                ...data,
              };
            }).toList();
          });
        } else {
          print('No job request IDs found in worker document');
          setState(() {
            _jobRequests = [];
          });
        }
      } else {
        print('Worker document does not exist for user: ${user.uid}');
      }
    } catch (e) {
      print('Error loading job requests: $e');
    }
  }

  Future<void> _updateJobStatus(String jobId, String status) async {
    try {
      // Update the job status in the jobRequests collection
      await FirebaseFirestore.instance
          .collection('jobRequests')
          .doc(jobId)
          .update({'status': status});

      // Reload the job requests
      _loadJobRequests();
    } catch (e) {
      print('Error updating job status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Job Requests"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: _jobRequests.isEmpty
          ? const Center(child: Text("No job requests yet"))
          : ListView.builder(
        itemCount: _jobRequests.length,
        itemBuilder: (context, index) {
          final job = _jobRequests[index];

          // Safely extract data with fallbacks
          final jobId = job['id'] ?? 'N/A';
          final status = job['status'] ?? 'Unknown';
          final title = job['title'] ?? 'No Title';
          final description = job['description'] ?? 'No description';
          final location = job['location'] ?? 'Unknown location';
          final skills = (job['skills'] as List<dynamic>?)?.join(', ') ?? 'No skills specified';

          // Handle timestamp - try both 'createdAt' and 'postedAt'
          Timestamp? timestamp = job['createdAt'] as Timestamp?;
          if (timestamp == null) {
            timestamp = job['postedAt'] as Timestamp?;
          }
          final dateString = timestamp != null
              ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
              : 'Unknown date';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 8),
                  Text("Location: $location"),
                  const SizedBox(height: 8),
                  Text("Skills: $skills"),
                  const SizedBox(height: 8),
                  Text("Status: $status"),
                  Text("Posted: $dateString"),
                  const SizedBox(height: 10),

                  if (status == 'pending' || status == 'Pending')
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _updateJobStatus(jobId, 'accepted'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            "Accept",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _updateJobStatus(jobId, 'cancelled'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            "Decline",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  if (status == 'accepted' || status == 'Accepted')
                    ElevatedButton(
                      onPressed: () => _updateJobStatus(jobId, 'completed'),
                      child: const Text("Mark as Completed"),
                    ),
                ],
              ),
            ),
          );
        },
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
  String _selectedJobType = 'IT & Programming';
  String _selectedStatus = 'Active'; // Default status

  // List of available skills to choose from
// List of available skills to choose from
  final List<String> _skillsList = [
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
    "Other",
  ];

  // Set to store selected skills
  final Set<String> _selectedSkills = {};

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

              // Status Selection
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: <String>[
                  'Active',
                  'Inactive',
                  'In Progress',
                  'Completed'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Skills Selection Section
              const Text(
                'Required Skills',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select skills required for this job:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              // Chip-based skill selection
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _skillsList.map((skill) {
                  return FilterChip(
                    label: Text(skill),
                    selected: _selectedSkills.contains(skill),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Display selected skills
              if (_selectedSkills.isNotEmpty) ...[
                const Text(
                  'Selected Skills:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _selectedSkills.map((skill) {
                    return Chip(
                      label: Text(skill),
                      onDeleted: () {
                        setState(() {
                          _selectedSkills.remove(skill);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

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
                    if (_selectedSkills.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select at least one skill")),
                      );
                      return;
                    }
                    _postJobToFirestore();
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

  Future<void> _postJobToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser?.uid;

      if (user == null) {
        throw Exception("User not logged in");
      }

      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _titleController.text.trim(),
        'type': _selectedJobType,
        'location': _locationController.text.trim(),
        'skills': _selectedSkills.toList(), // Convert set to list
        'description': _descriptionController.text.trim(),
        'postedBy': FirebaseAuth.instance.currentUser!.uid,
        'status': _selectedStatus, // Use the selected status
        'postedAt': FieldValue.serverTimestamp(), // Save timestamp
        'employee': 1, // ← ADD THIS LINE (as number)
        // OR if you prefer string: 'employee': '1',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Job posted successfully!")),
      );

      Navigator.pop(context); // Go back to previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to post job: $e")),
      );
    }
  }
}
// Worker Search Page
class WorkerSearchPage extends StatefulWidget{
  const WorkerSearchPage({super.key});

  @override
  State<WorkerSearchPage> createState() =>_WorkerSearchPageState() ;
}
class _WorkerSearchPageState extends State<WorkerSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _workers = [];
  List<Map<String, dynamic>> _filteredWorkers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
    _searchController.addListener(_filterWorkers);
  }

  Future<void> _fetchWorkers() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('workers').get();

      final workersData = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['fullName'] ?? 'Unknown Worker',
          'skills': List<String>.from(data['skills'] ?? []),
          'rating': (data['rating'] ?? 0).toDouble(),
          'completedJobs': data['completedJobs'] ?? 0,
          'location': data['location'] ?? 'Location not specified',
          'id': doc.id,
          'profileImageUrl': data['profileImageUrl'],
          'experienceLevel': data['experienceLevel'],
          'cellPhone': data['cellPhone'],
          'homePhone': data['homePhone'],
          'whatsapp': data['whatsapp'],
          'linkedIn': data['linkedIn'],
          'github': data['github'],
          'portfolio': data['portfolio'],
        };
      }).toList();

      setState(() {
        _workers = workersData;
        _filteredWorkers = _workers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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
          return worker['name'].toString().toLowerCase().contains(query) ||
              (worker['skills'] as List).any((skill) =>
                  skill.toString().toLowerCase().contains(query)) ||
              worker['location'].toString().toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Workers',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, skill, or location...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            )
                : _filteredWorkers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _workers.isEmpty
                        ? 'No workers available'
                        : 'No workers found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class WorkerProfilePage extends StatelessWidget {
  final Map<String, dynamic> worker;

  const WorkerProfilePage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(worker['name'],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1976D2),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: worker['profileImageUrl'] != null
                          ? NetworkImage(worker['profileImageUrl'])
                          : null,
                      backgroundColor: const Color(0xFFE3F2FD),
                      child: worker['profileImageUrl'] == null
                          ? const Icon(Icons.person,
                          size: 50, color: Color(0xFF1976D2))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    worker['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    worker['location'] ?? 'Location not specified',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    worker['experienceLevel'] ?? 'Beginner',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '${worker['rating'] ?? 0.0}/5.0',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(height: 1, color: Colors.grey),

            // Skills Section
            _buildSectionTitle('Skills'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (worker['skills'] as List? ?? [])
                  .map<Widget>((skill) => Chip(
                label: Text(
                  skill.toString(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ))
                  .toList(),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, color: Colors.grey),

            // Completed Jobs
            _buildSectionTitle('Experience'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.work_history, color: Colors.green.shade700, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${worker['completedJobs'] ?? 0} Jobs Completed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Successfully delivered projects',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, color: Colors.grey),

            // Contact Details Section
            _buildSectionTitle('Contact Information'),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.phone_iphone,
              title: 'Mobile',
              value: worker['cellPhone'] ?? 'Not provided',
              onTap: worker['cellPhone'] != null
                  ? () => _makePhoneCall(worker['cellPhone'])
                  : null,
            ),
            const SizedBox(height: 8),
            _buildContactCard(
              icon: Icons.phone,
              title: 'Home',
              value: worker['homePhone'] ?? 'Not provided',
              onTap: worker['homePhone'] != null
                  ? () => _makePhoneCall(worker['homePhone'])
                  : null,
            ),
            const SizedBox(height: 8),
            _buildContactCard(
              icon: Icons.chat,
              title: 'WhatsApp',
              value: worker['whatsapp'] ?? 'Not provided',
              onTap: worker['whatsapp'] != null
                  ? () => _launchWhatsApp(worker['whatsapp'])
                  : null,
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, color: Colors.grey),

            // Social Links Section
            _buildSectionTitle('Social Profiles'),
            const SizedBox(height: 12),
            _buildSocialLinkCard(
              icon: Icons.link,
              title: 'LinkedIn',
              value: worker['linkedIn'] ?? 'Not provided',
              onTap: worker['linkedIn'] != null && worker['linkedIn'] != 'Not provided'
                  ? () {
                // Handle different LinkedIn URL formats
                String linkedInUrl = worker['linkedIn'];
                if (!linkedInUrl.startsWith('http')) {
                  if (linkedInUrl.contains('linkedin.com')) {
                    linkedInUrl = 'https://$linkedInUrl';
                  } else {
                    linkedInUrl = 'Not provided';
                  }
                }
                _launchUrl(linkedInUrl);
              }
                  : null,
            ),
            const SizedBox(height: 8),
            _buildSocialLinkCard(
              icon: Icons.code,
              title: 'GitHub',
              value: worker['github'] ?? 'Not provided',
              onTap: worker['github'] != null && worker['github'] != 'Not provided'
                  ? () {
                String githubUrl = worker['github'];
                if (!githubUrl.startsWith('http')) {
                  if (githubUrl.contains('github.com')) {
                    githubUrl = 'https://$githubUrl';
                  } else {
                    githubUrl = 'https://github.com/$githubUrl';
                  }
                }
                _launchUrl(githubUrl);
              }
                  : null,
            ),
            const SizedBox(height: 8),
            _buildSocialLinkCard(
              icon: Icons.public,
              title: 'Portfolio',
              value: worker['portfolio'] ?? 'Not provided',
              onTap: worker['portfolio'] != null && worker['portfolio'] != 'Not provided'
                  ? () {
                String portfolioUrl = worker['portfolio'];
                if (!portfolioUrl.startsWith('http')) {
                  portfolioUrl = 'https://$portfolioUrl';
                }
                _launchUrl(portfolioUrl);
              }
                  : null,
            ),

            // Demo link that's always clickable
            const SizedBox(height: 8),
            _buildSocialLinkCard(
              icon: Icons.web,
              title: 'Sample Portfolio',
              value: 'https://groww.in/p/portfolio',
              onTap: () => _launchUrl('https://groww.in/p/portfolio'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1976D2),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1976D2), size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: onTap != null ? const Color(0xFF1976D2) : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: onTap != null ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: onTap != null
            ? Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward,
              size: 18, color: Color(0xFF1976D2)),
        )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSocialLinkCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1976D2), size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: onTap != null ? const Color(0xFF1976D2) : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: onTap != null ? FontWeight.w500 : FontWeight.normal,
            decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
        trailing: onTap != null
            ? Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.open_in_new,
              size: 18, color: Color(0xFF1976D2)),
        )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: try to open in browser if the URL scheme is not supported
      await launchUrl(Uri.parse('https://$url'));
    }
  }
}
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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                ),
                child: const Icon(Icons.person,
                    size: 30, color: Color(0xFF1976D2)),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skills.join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.work, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '$completedJobs jobs',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
// Update the Worker Card to make name clickable

// Update the Job Card to make "View Details" clickable

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

