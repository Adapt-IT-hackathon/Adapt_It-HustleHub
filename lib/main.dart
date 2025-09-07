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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
  final TextEditingController _otherSkillController = TextEditingController();

  Future<void> registerUser({
    required String uid,
    required String email,
    required String fullName,
    required String password,
    required String phone,
    required String surName,
    required String role,
    required List<String> skills,
    String? profileImageUrl,
    required String location,
    required String experienceLevel,
  }) async {
    // Create user document with all fields (optional ones set to null)
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'password': password,
      'surName': surName,
      'role': role,
      'phone': phone,
      'skills': skills,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'experienceLevel': experienceLevel,
      'bio': null,
      'linkedIn': null,
      'github': null,
      'portfolio': null,
      'otherSocial': null,
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
        'bio': null,
        'linkedIn': null,
        'github': null,
        'portfolio': null,
        'otherSocial': null,
        'rating': 0,
        'totalJobs': 0,
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      });

      // Also create a worker_description document
      await FirebaseFirestore.instance.collection('worker_description').doc(uid).set({
        'userId': uid,
        'bio': null,
        'linkedIn': null,
        'github': null,
        'portfolio': null,
        'otherSocial': null,
        'skills': skills,
        'location': location,
        'experienceLevel': experienceLevel,
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

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter your phone number"),
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
        phone: _phoneController.text.trim(),
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

                  _buildTextField(_phoneController, "Phone Number", Icons.phone,
                      TextInputType.phone),
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

            // Note about additional profile fields
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "You can add more details like bio, portfolio links, and social media profiles in your profile settings after signing up.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontSize: 14,
                ),
              ),
            ),
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
      IconData icon, [TextInputType inputType = TextInputType.text, int maxLines = 1]) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
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
        prefixIcon: const Icon(Icons.lock, color: const Color(0xFF1976D2)),
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

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}
class _ClientDashboardState extends State<ClientDashboard> {
  int _currentIndex = 0;
  double _userRating = 0.0;
  int _completedJobs = 0;
  int _pendingJobs = 0;
  String _username = "User";
  bool _isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Get user data and jobs data in parallel
      await Future.wait([
        _getUsername(),
        _getJobsData(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading dashboard data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getUsername() async {
    if (_currentUser == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('fullName')) {
          setState(() {
            _username = data['fullName'] ?? "User";
          });
        }
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
  }

  Future<void> _getJobsData() async {
    if (_currentUser == null) return;

    try {
      // Get all jobs where current user is the client
      final List<String> possibleClientFields = ['client', 'clientId', 'userId', 'postedBy', 'clientID'];

      QuerySnapshot? querySnapshot;

      for (final field in possibleClientFields) {
        try {
          querySnapshot = await _firestore
              .collection('jobs')
              .where(field, isEqualTo: _currentUser!.uid)
              .get();

          if (querySnapshot.docs.isNotEmpty) break;
        } catch (e) {
          continue;
        }
      }

      if (querySnapshot == null || querySnapshot.docs.isEmpty) {
        querySnapshot = await _firestore.collection('jobs').get();
      }

      int completed = 0;
      int pending = 0;
      double totalRating = 0.0;
      int ratedJobs = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final isUserJob = _isUserJob(data);
        if (!isUserJob) continue;

        final status = data['status']?.toString() ?? '';

        if (status == 'Completed') {
          completed++;
          final rating = _getRatingFromData(data);
          if (rating > 0) {
            totalRating += rating;
            ratedJobs++;
          }
        } else if (status == 'Active' || status == 'In Progress' || status == 'Inactive' || status == 'Pending') {
          pending++;
        }
      }

      double averageRating = ratedJobs > 0 ? totalRating / ratedJobs : 0.0;

      setState(() {
        _completedJobs = completed;
        _pendingJobs = pending;
        _userRating = double.parse(averageRating.toStringAsFixed(1));
      });

      print("Found $completed completed jobs and $pending pending jobs with average rating: $averageRating");
    } catch (e) {
      print("Error fetching jobs data: $e");
      setState(() {
        _completedJobs = 0;
        _pendingJobs = 0;
        _userRating = 0.0;
      });
    }
  }

  bool _isUserJob(Map<String, dynamic> data) {
    final possibleClientFields = ['client', 'clientId', 'userId', 'postedBy', 'clientID'];
    for (final field in possibleClientFields) {
      if (data.containsKey(field) && data[field] == _currentUser?.uid) {
        return true;
      }
    }
    return true; // fallback
  }

  double _getRatingFromData(Map<String, dynamic> data) {
    final possibleRatingFields = ['rating', 'clientRating', 'userRating', 'reviewScore'];
    for (final field in possibleRatingFields) {
      if (data.containsKey(field)) {
        final rating = data[field];
        if (rating is num) return rating.toDouble();
        if (rating is String) return double.tryParse(rating) ?? 0.0;
      }
    }
    return 0.0;
  }

  Future<int> _loadResponseCount() async {
    final workerId = _currentUser?.uid;
    if (workerId == null) return 0;

    try {
      final querySnapshot = await _firestore
          .collection('response')
          .where('workerId', isEqualTo: workerId)
          .where('status', isEqualTo: 'pending')
          .get();

      return querySnapshot.size;
    } catch (e) {
      print("Error fetching worker responses: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HustleHub Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          FutureBuilder<int>(
            future: _loadResponseCount(),
            builder: (context, snapshot) {
              int responseCount = snapshot.data ?? 0;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Icon(Icons.notifications, color: Colors.grey);
              }
              if (snapshot.hasError) {
                return const Icon(Icons.error, color: Colors.red);
              }

              return Badge(
                largeSize: 37,
                textColor: responseCount == 0 ? Colors.transparent : Colors.red,
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    final workerId = _currentUser?.uid;
                    if (workerId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceProviderNotificationScreen(workerId: workerId,),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildRatingSection(),
            const SizedBox(height: 20),
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
          BoxShadow(color: Colors.blue.shade200, blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 30, color: Color(0xFF1976D2)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, $_username!",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ready to find your next service provider?',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
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
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Client Rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomRatingBar(
                    rating: _userRating,
                    itemSize: 30,
                    onRatingChanged: (rating) {},
                    ignoreGestures: true,
                  ),
                  const SizedBox(height: 5),
                  Text('$_userRating/5.0',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Based on $_completedJobs completed jobs',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const Spacer(),
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
                  Text('${((_userRating / 5) * 100).round()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
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
          Text(
            _userRating > 0
                ? 'Keep getting rated to improve your ranking!'
                : 'Complete jobs to get ratings from service providers!',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(title: 'Completed Jobs', value: _completedJobs.toString(), icon: Icons.check_circle, color: Colors.green),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _StatCard(title: 'Pending Jobs', value: _pendingJobs.toString(), icon: Icons.access_time, color: Colors.orange),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _StatCard(title: 'Total Jobs', value: (_completedJobs + _pendingJobs).toString(), icon: Icons.work, color: const Color(0xFF1976D2)),
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
            icon: Icon(Icons.home, color: _currentIndex == 0 ? const Color(0xFF1976D2) : Colors.grey),
            onPressed: () => setState(() => _currentIndex = 0),
          ),
          IconButton(
            icon: Icon(Icons.work, color: _currentIndex == 1 ? const Color(0xFF1976D2) : Colors.grey),
            onPressed: () {
              setState(() => _currentIndex = 1);
              Navigator.push(context, MaterialPageRoute(builder: (_) => JobsPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.task, color: _currentIndex == 2 ? const Color(0xFF1976D2) : Colors.grey),
            onPressed: () {
              setState(() => _currentIndex = 2);
              Navigator.push(context, MaterialPageRoute(builder: (_) => TasksPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: _currentIndex == 3 ? const Color(0xFF1976D2) : Colors.grey),
            onPressed: () {
              setState(() => _currentIndex = 3);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
            },
          ),
        ],
      ),
    );
  }
}


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
  final TextEditingController _phoneController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  bool _loading = true;

  String _name = "";
  String _surname = "";
  String _location = "";
  String _email = "";
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
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      _name = userData['name'] ?? "";
      _surname = userData['surname'] ?? "";
      _location = userData['location'] ?? "";
      _email = userData['email'] ?? "";
      _phoneController.text = userData['phone'] ?? "";
      _selectedSkills = Set<String>.from(userData['skills'] ?? []);

      // --- Fetch worker_description (or create if missing) ---
      final descRef = FirebaseFirestore.instance.collection('worker_description').doc(uid);
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

      // Update skills and phone in users as well
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'skills': _selectedSkills.toList(),
        'phone': _phoneController.text,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error updating profile: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
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
      // Here you would typically upload the image to Firebase Storage
      // and update the user's profile image URL in Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
              SizedBox(height: 16),
              Text(
                "Loading your profile...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Icon(Icons.person, size: 50, color: Color(0xFF1976D2))
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFF1976D2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "$_name $_surname",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _email,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Stats Cards
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard("Jobs Completed", "$_completedJobs", Icons.work, Color(0xFF1976D2)),
                  _buildStatCard("Rating", _rating.toStringAsFixed(1), Icons.star, Colors.amber),
                  _buildStatCard("Satisfaction", "${_satisfaction.toStringAsFixed(0)}%", Icons.emoji_emotions, Colors.green),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Personal Information Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personal Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: Icon(Icons.phone, color: Color(0xFF1976D2)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: !_isEditing,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    enabled: _isEditing,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Bio",
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.info, color: Color(0xFF1976D2)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: !_isEditing,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Skills Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Skills",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skillsList.map((skill) {
                      final selected = _selectedSkills.contains(skill);
                      return ChoiceChip(
                        label: Text(skill),
                        selected: selected,
                        onSelected: _isEditing ? (_) => _toggleSkill(skill) : null,
                        selectedColor: Color(0xFF1976D2),
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Social Media Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Social Media",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _linkedInController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: "LinkedIn",
                      prefixIcon: Icon(Icons.link, color: Color(0xFF1976D2)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: !_isEditing,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _githubController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: "GitHub",
                      prefixIcon: Icon(Icons.code, color: Color(0xFF1976D2)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: !_isEditing,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _otherSocialController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: "Other Social Media",
                      prefixIcon: Icon(Icons.public, color: Color(0xFF1976D2)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: !_isEditing,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Action Button
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  List<Job> _allJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    try {
      final querySnapshot = await _firestore
          .collection('jobs')
          .where('status',isEqualTo:'Inactive')
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
          requiredSkills: List<String>.from(data['skills'] ?? []),
          datePosted: _formatDate(data['postedAt']),
          budget: (data['budget'] ?? 0.0).toDouble(),
          postedBy: data['postedBy'] ?? '',
          type: data['type'] ?? 'Not specified',
          employeeCount: (data['employee'] ?? 1).toInt(),
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

  List<Job> get _filteredJobs {
    if (_searchQuery.isEmpty) {
      return _allJobs;
    } else {
      return _allJobs.where((job) =>
      job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.type.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
  }

  void _showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => JobDetailsBottomSheet(
        job: job,
        onApply: (proposedPrice) => _applyForJob(job, proposedPrice),
      ),
    );
  }

  Future<void> _applyForJob(Job job, double proposedPrice) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create a job application/request
        await _firestore.collection('requests').add({
          'jobId': job.id,
          'jobTitle': job.title,
          'workerId': user.uid,
          'workerName': 'User', // You might want to get the actual user name
          'clientId': job.postedBy,
          'clientName': job.clientName,
          'proposedPrice': proposedPrice,
          'status': 'pending',
          'appliedAt': FieldValue.serverTimestamp(),
          'location': job.location,
          'requiredSkills': job.requiredSkills,
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
                    hintText: "Search jobs...",
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
                    : _filteredJobs.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work_outline, size: 64, color: Color(0xFF1976D2)),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? "No jobs available"
                            : "No jobs found for '$_searchQuery'",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Check back later for new job postings",
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
  final String type;
  final int employeeCount;

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
    required this.type,
    required this.employeeCount,
  });
}

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({
    required this.job,
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
              child: Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Job details section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${job.location} • \$${job.budget.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.type,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description.length > 100
                        ? '${job.description.substring(0, 100)}...'
                        : job.description,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: job.requiredSkills.map((skill) => Chip(
                      label: Text(skill),
                      backgroundColor: const Color(0xFFE3F2FD),
                      labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                    )).toList(),
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

class JobDetailsBottomSheet extends StatefulWidget {
  final Job job;
  final Function(double) onApply;

  const JobDetailsBottomSheet({
    super.key,
    required this.job,
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

            const SizedBox(height: 16),
            Text(
              widget.job.type,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

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
                          '\R${widget.job.budget.toStringAsFixed(2)}',
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
                prefixText: '\R ',
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
                  "Apply for \R${_proposedPrice.toStringAsFixed(2)}",
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
      final employeeId = _currentUser?.uid ??'1';


      QuerySnapshot querySnapshot = await _firestore
          .collection('jobs')
          .where('employee', isEqualTo: employeeId)
          .where('status', whereIn: ['Active', 'In Progress', 'Completed'])
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
    task['status'] == 'Active').toList();
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
  double _serviceRating = 0.0;
  int _activeJobsCount = 0;
  int _completedJobsCount = 0;
  String _jobFilter = 'active';
  int _totalNotificationCount = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadJobCounts();
    _loadServiceRating();
    _fetchNotificationCount();
  }

  Future<void> _loadServiceRating() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final ratingDoc = await _firestore.collection('ratings').doc(userId).get();
      if (ratingDoc.exists) {
        final data = ratingDoc.data()!;
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

    try {
      final activeQuery = await _firestore
          .collection('jobs')
          .where('postedBy', isEqualTo: userId)
          .where('status', isEqualTo: 'Active')
          .where('employee', isEqualTo: 1)
          .get();

      final completedQuery = await _firestore
          .collection('jobs')
          .where('postedBy', isEqualTo: userId)
          .where('status', isEqualTo: 'Completed')
          .where('employee', isEqualTo: 1)
          .get();

      setState(() {
        _activeJobsCount = activeQuery.size;
        _completedJobsCount = completedQuery.size;
      });
    } catch (e) {
      print('Error loading job counts: $e');
    }
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final querySnapshot = await _firestore
          .collection('response')
          .where('currentUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      setState(() {
        _totalNotificationCount = querySnapshot.size;
      });
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  Future<String> getUsername() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return "User";

    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    return data?['fullName'] ?? "User";
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
              Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerSearchPage()));
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Colors.white),
                if (_totalNotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_totalNotificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClientNotificationsScreen(clientId: userId),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildRatingSection(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            _buildJobsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddJobPage()))
              .then((_) => _loadJobCounts());
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
            child: FutureBuilder<String>(
              future: getUsername(),
              builder: (context, snapshot) {
                final name = snapshot.data ?? "User";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back, $name!",
                      style: const TextStyle(
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
                );
              },
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                _serviceRating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showRatingDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('View Details', style: TextStyle(color: Colors.white)),
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
          const Text('Based on customer reviews', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showRatingDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Your Rating Details'),
          content: FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('ratings').doc(FirebaseAuth.instance.currentUser?.uid).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final totalRatings = data['totalRatings'] ?? 0;
              final averageRating = data['averageRating'] ?? 0.0;
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
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(title: 'Active Jobs', value: _activeJobsCount.toString(), icon: Icons.work, color: Colors.blue)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard(title: 'Completed Jobs', value: _completedJobsCount.toString(), icon: Icons.check_circle, color: Colors.green)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard(title: 'Total Jobs', value: (_activeJobsCount + _completedJobsCount).toString(), icon: Icons.list_alt, color: Colors.purple)),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildJobsSection() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
        const SizedBox(height: 10),
        Row(
          children: [
            FilterChip(label: const Text('Active'), selected: _jobFilter == 'active', onSelected: (selected) => setState(() => _jobFilter = selected ? 'active' : 'all')),
            const SizedBox(width: 10),
            FilterChip(label: const Text('Inactive'), selected: _jobFilter == 'inactive', onSelected: (selected) => setState(() => _jobFilter = selected ? 'inactive' : 'all')),
            const SizedBox(width: 10),
            FilterChip(label: const Text('All'), selected: _jobFilter == 'all', onSelected: (selected) => setState(() => _jobFilter = selected ? 'all' : 'active')),
          ],
        ),
        const SizedBox(height: 15),
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('jobs').where('postedBy', isEqualTo: userId).where('employee', isEqualTo: 1).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!.docs;
            final filteredDocs = docs.where((doc) {
              final job = doc.data()! as Map<String, dynamic>;
              final status = (job['status'] ?? '').toString().toLowerCase();
              if (_jobFilter == 'active') return status == 'active';
              if (_jobFilter == 'inactive') return status != 'active';
              return true;
            }).toList();

            if (filteredDocs.isEmpty) return const Center(child: Text('No jobs found with the selected filter.'));

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filteredDocs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final job = filteredDocs[index].data()! as Map<String, dynamic>;
                String formattedDate = 'Date not available';
                if (job['postedAt'] is Timestamp) formattedDate = DateFormat.yMMMd().format((job['postedAt'] as Timestamp).toDate());
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
            icon: Icon(Icons.home, color: _currentIndex == 0 ? const Color(0xFF1976D2) : Colors.grey),
            onPressed: () => setState(() => _currentIndex = 0),
          ),
          IconButton(
            icon: Icon(Icons.person, color: _currentIndex == 3 ? const Color(0xFF1976D2) : Colors.grey),
            onPressed: () {
              setState(() => _currentIndex = 3);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ClientProfilePage()));
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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadJobRequests();
  }

  Future<void> _loadJobRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "User not authenticated";
      });
      return;
    }

    try {
      debugPrint("Loading requests for worker: ${user.uid}");

      final workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .get();

      if (!workerDoc.exists) {
        setState(() {
          _errorMessage = "Worker profile not found";
          _jobRequests = [];
        });
        return;
      }

      final workerData = workerDoc.data() as Map<String, dynamic>? ?? {};
      final List<dynamic> requestIds = workerData['requests'] ?? [];

      if (requestIds.isEmpty) {
        setState(() {
          _jobRequests = [];
        });
      } else {
        // watch out: `whereIn` supports max 10 items per query
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('requests')
            .where(FieldPath.documentId, whereIn: requestIds)
            .get();

        debugPrint('Fetched ${snapshot.docs.length} requests');

        setState(() {
          _jobRequests = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
        });
      }
    } catch (e, st) {
      debugPrint('Error loading requests: $e\n$st');
      setState(() {
        _errorMessage = "Failed to load job requests";
        _jobRequests = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // update a single request document (requests collection)
  Future<void> _updateRequestStatus(String requestId, String status) async {
    if (requestId.isEmpty) {
      debugPrint("RequestId empty - cannot update request status");
      throw Exception("Missing requestId");
    }

    final requestRef =
    FirebaseFirestore.instance.collection('requests').doc(requestId);

    final snap = await requestRef.get();
    if (!snap.exists) {
      debugPrint("Request doc $requestId does not exist");
      throw Exception("Request document not found");
    }

    await requestRef.update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    debugPrint("✅ Request $requestId updated -> $status");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request updated to $status")),
      );
    }
  }

  // update a single job document (jobs collection)
  // workerId: pass the worker uid when assigning; set removeEmployee=true to delete employee field
  Future<void> _updateJobStatus(String jobId, String status,
      {String? workerId, bool removeEmployee = false}) async {
    if (jobId.isEmpty) {
      debugPrint("jobId empty - skipping job update");
      throw Exception("Missing jobId");
    }

    final jobRef = FirebaseFirestore.instance.collection('jobs').doc(jobId);
    final snap = await jobRef.get();
    if (!snap.exists) {
      debugPrint("Job doc $jobId does not exist");
      throw Exception("Job document not found");
    }

    final Map<String, dynamic> updateData = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status.toLowerCase() == 'Active' && workerId != null && workerId.isNotEmpty) {
      updateData['employee'] = workerId;
    } else if (removeEmployee) {
      updateData['employee'] = FieldValue.delete();
    }

    await jobRef.update(updateData);

    debugPrint("✅ Job $jobId updated -> $status (employee: ${workerId ?? (removeEmployee ? 'removed' : 'no-change')})");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Job updated to $status")),
      );
    }
  }

  // Accept handler: calls both update methods
  Future<void> _acceptJob(String requestId, String jobId) async {
    setState(() {
      _isLoading = true;
    });

    debugPrint("👉 Accept pressed for requestId=$requestId jobId=$jobId");

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      // 1) Update the request status
      await _updateRequestStatus(requestId, 'accepted');

      // 2) Update the job status (if jobId available)
      if (jobId.isNotEmpty) {
        await _updateJobStatus(jobId, 'Active', workerId: user.uid);
      } else {
        debugPrint("No jobId present on request $requestId - only request updated");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request accepted, but jobId was missing")),
          );
        }
      }

      // reload list
      await _loadJobRequests();
    } catch (e, st) {
      debugPrint("❌ Accept failed: $e\n$st");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to accept job: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Decline handler: update request and reset job
  Future<void> _declineJob(String requestId, String jobId) async {
    setState(() {
      _isLoading = true;
    });

    debugPrint("👉 Decline pressed for requestId=$requestId jobId=$jobId");

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      // 1) Update request status
      await _updateRequestStatus(requestId, 'declined');

      // 2) Reset job: mark as Available and remove employee if present
      if (jobId.isNotEmpty) {
        await _updateJobStatus(jobId, 'Available', removeEmployee: true);
      } else {
        debugPrint("No jobId present on request $requestId - only request updated");
      }

      await _loadJobRequests();
    } catch (e, st) {
      debugPrint("❌ Decline failed: $e\n$st");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to decline job: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Job Requests"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _jobRequests.isEmpty
          ? const Center(child: Text("No job requests yet"))
          : RefreshIndicator(
        onRefresh: _loadJobRequests,
        child: ListView.builder(
          itemCount: _jobRequests.length,
          itemBuilder: (context, index) {
            final job = _jobRequests[index];

            final requestId = job['id'] ?? '';
            final jobId = job['jobId'] ?? '';
            final statusRaw = job['status'] ?? 'unknown';
            final status = statusRaw.toString();
            final isPending = status.toLowerCase() == 'pending';

            final title = job['title'] ?? 'No Title';
            final description = job['description'] ?? 'No description';
            final location = job['location'] ?? 'Unknown location';
            final skills = (job['skills'] as List<dynamic>?)?.join(', ') ?? 'No skills specified';

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
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    if (isPending)
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _acceptJob(requestId, jobId),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text("Accept", style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _declineJob(requestId, jobId),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("Decline", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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

class ClientNotificationsScreen extends StatefulWidget {
  final String clientId;

  const ClientNotificationsScreen({Key? key, required this.clientId}) : super(key: key);

  @override
  _ClientNotificationsScreenState createState() => _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState extends State<ClientNotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Job Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: _showDeleteAllDialog,
            tooltip: 'Delete All Processed Requests',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('requests')
            .where('clientId', isEqualTo: widget.clientId)
            .where('status', isEqualTo: 'pending')
            .orderBy('appliedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No pending requests',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var request = snapshot.data!.docs[index];
              var data = request.data() as Map<String, dynamic>;

              return _buildRequestCard(request.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(String requestId, Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    data['jobTitle'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '\$${data['proposedPrice']?.toString() ?? '0'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.person, 'Worker: ${data['workerName'] ?? 'Unknown Worker'}'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.location_on, 'Location: ${data['location'] ?? 'Not specified'}'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, 'Applied: ${_formatTimestamp(data['appliedAt'])}'),
            const SizedBox(height: 12),
            const Text(
              'Required Skills:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (data['requiredSkills'] as List<dynamic>?)
                  ?.map((skill) => Chip(
                label: Text(skill.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white)),
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ))
                  .toList() ??
                  [],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(requestId, data),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptRequest(requestId, data),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _showDeleteDialog(requestId),
                child: const Text(
                  'Delete Request',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
    } else if (timestamp is String) {
      return timestamp;
    }
    return 'Unknown date';
  }

  void _acceptRequest(String requestId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Request', style: TextStyle(color: Color(0xFF1976D2))),
        content: const Text('Are you sure you want to accept this job request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _saveResponseToFirestore(requestId, data, 'accepted');
              _updateRequestStatus(requestId, 'accepted', null);
              _showWorkerProfile(data['workerId']);
              Navigator.pop(context);
            },
            child: const Text('Accept', style: TextStyle(color: Color(0xFF1976D2))),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String requestId, Map<String, dynamic> data) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request', style: TextStyle(color: Color(0xFF1976D2))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason...',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                _saveResponseToFirestore(requestId, data, 'rejected', reason: reasonController.text);
                _updateRequestStatus(requestId, 'rejected', reasonController.text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit', style: TextStyle(color: Color(0xFF1976D2))),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to delete this request? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _deleteRequest(requestId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Processed Requests', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to delete all requests that have been accepted or rejected? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _deleteAllProcessedRequests();
              Navigator.pop(context);
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRequest(String requestId) async {
    try {
      await _firestore.collection('requests').doc(requestId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting request: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAllProcessedRequests() async {
    try {
      // Get all processed requests (accepted or rejected)
      final querySnapshot = await _firestore
          .collection('requests')
          .where('clientId', isEqualTo: widget.clientId)
          .where('status', whereIn: ['accepted', 'rejected'])
          .get();

      // Delete each document
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${querySnapshot.size} processed requests'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting requests: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveResponseToFirestore(String requestId, Map<String, dynamic> data, String status, {String? reason}) async {
    try {
      // Get current user data
      User? user = _auth.currentUser;
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(user?.uid).get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      // Create response data
      Map<String, dynamic> responseData = {
        'requestId': requestId,
        'jobId': data['jobId'],
        'jobTitle': data['jobTitle'],
        'clientId': data['clientId'],
        'clientName': userData['fullName'] ?? 'Unknown Client',
        'workerId': data['workerId'],
        'workerName': data['workerName'],
        'status': status,
        'respondedAt': FieldValue.serverTimestamp(),
        'proposedPrice': data['proposedPrice'],
        'location': data['location'],
      };

      // Add rejection reason if provided
      if (reason != null && status == 'rejected') {
        responseData['rejectionReason'] = reason;
      }

      // Save to responses collection
      await _firestore.collection('responses').add(responseData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Response $status successfully'),
          backgroundColor: status == 'accepted' ? const Color(0xFF1976D2) : Colors.red,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving response: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateRequestStatus(String requestId, String status, String? reason) {
    _firestore.collection('requests').doc(requestId).update({
      'status': status,
      'respondedAt': FieldValue.serverTimestamp(),
      if (reason != null) 'rejectionReason': reason,
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating request: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _showWorkerProfile(String workerId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(workerId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                  ),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Profile Not Found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Could not load worker profile.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }

            var workerData = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Worker Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileItem('Full Name', '${workerData['fullName'] ?? 'N/A'} ${workerData['surName'] ?? ''}'),
                    _buildProfileItem('Email', workerData['email'] ?? 'N/A'),
                    _buildProfileItem('Location', workerData['location'] ?? 'N/A'),
                    _buildProfileItem('Experience Level', workerData['experienceLevel'] ?? 'N/A'),
                    _buildProfileItem('Role', workerData['role'] ?? 'N/A'),
                    if (workerData['skills'] != null && (workerData['skills'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (workerData['skills'] as List<dynamic>)
                                .map((skill) => Chip(
                              label: Text(skill.toString(),
                                  style: const TextStyle(fontSize: 12, color: Colors.white)),
                              backgroundColor: const Color(0xFF1976D2),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class ServiceProviderNotificationScreen extends StatefulWidget {
  final String workerId;

  const ServiceProviderNotificationScreen({Key? key, required this.workerId}) : super(key: key);

  @override
  _ServiceProviderNotificationScreenState createState() => _ServiceProviderNotificationScreenState();
}

class _ServiceProviderNotificationScreenState extends State<ServiceProviderNotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Job Responses', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1976D2),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Accepted', icon: Icon(Icons.check_circle)),
              Tab(text: 'Rejected', icon: Icon(Icons.cancel)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildResponsesList('accepted'),
            _buildResponsesList('rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('responses')
          .where('workerId', isEqualTo: widget.workerId)
          .where('status', isEqualTo: status)
          .orderBy('respondedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'accepted' ? Icons.check_circle_outline : Icons.highlight_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No $status responses',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var response = snapshot.data!.docs[index];
            var data = response.data() as Map<String, dynamic>;
            var documentId = response.id;

            return _buildResponseCard(data, status, documentId);
          },
        );
      },
    );
  }

  Widget _buildResponseCard(Map<String, dynamic> data, String status, String documentId) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    data['jobTitle'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == 'accepted'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: status == 'accepted' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.person, 'Client: ${data['clientName'] ?? 'Unknown Client'}'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, 'Responded: ${_formatTimestamp(data['respondedAt'])}'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.attach_money, 'Price: R${data['proposedPrice']?.toString() ?? '0'}'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.location_on, 'Location: ${data['location'] ?? 'Not specified'}'),

            if (status == 'rejected' && data['rejectionReason'] != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Rejection Reason:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                data['rejectionReason'],
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                if (status == 'accepted')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showClientProfile(data['clientId']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 8),
                          Text('View Client'),
                        ],
                      ),
                    ),
                  ),
                if (status == 'accepted') const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDeleteConfirmation(documentId, data['jobTitle'] ?? 'this response'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
    } else if (timestamp is String) {
      return timestamp;
    }
    return 'Unknown date';
  }

  void _showDeleteConfirmation(String documentId, String jobTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Response'),
          content: Text('Are you sure you want to delete your response for "$jobTitle"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteResponse(documentId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteResponse(String documentId) async {
    try {
      await _firestore.collection('responses').doc(documentId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Response deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting response: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showClientProfile(String clientId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('users').doc(clientId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Profile Not Available',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Could not load client profile information.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }

              var clientData = snapshot.data!.data() as Map<String, dynamic>;
              final fullName = '${clientData['fullName'] ?? ''} ${clientData['surName'] ?? ''}'.trim();
              final email = clientData['email'] ?? 'Not provided';
              final phone = clientData['phone'] ?? 'Not provided';
              final location = clientData['location'] ?? 'Not specified';
              final experienceLevel = clientData['experienceLevel'] ?? 'Not specified';
              final role = clientData['role'] ?? 'Not specified';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1976D2).withOpacity(0.1),
                                border: Border.all(color: const Color(0xFF1976D2), width: 2),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              fullName.isNotEmpty ? fullName : 'Unknown Client',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Contact Information Section
                      const Text(
                        'CONTACT INFORMATION',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildContactItem(
                        Icons.email,
                        'Email Address',
                        email,
                        onTap: email != 'Not provided' ? () {
                          _launchEmail(email);
                        } : null,
                      ),

                      _buildContactItem(
                        Icons.phone,
                        'Phone Number',
                        phone,
                        onTap: phone != 'Not provided' ? () {
                          _makePhoneCall(phone);
                        } : null,
                      ),

                      _buildContactItem(
                        Icons.location_on,
                        'Location',
                        location,
                      ),

                      _buildContactItem(
                        Icons.work,
                        'Experience Level',
                        experienceLevel,
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Congratulations Message Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.celebration, color: Colors.green, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Congratulations!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your application has been accepted! Contact the client early to discuss job details and schedule the work.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green[800],
                                height: 1.4,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Quick communication increases your chances of securing the job!',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (clientData['skills'] != null && (clientData['skills'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Skills & Expertise:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (clientData['skills'] as List<dynamic>)
                                  .map((skill) => Chip(
                                label: Text(
                                  skill.toString(),
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                                backgroundColor: const Color(0xFF1976D2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1976D2),
                                side: const BorderSide(color: Color(0xFF1976D2)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (phone != 'Not provided')
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _makePhoneCall(phone),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone, size: 20),
                                    SizedBox(width: 4),
                                    Text('Call'),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (email != 'Not provided')
                        ElevatedButton(
                          onPressed: () => _launchEmail(email),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email, size: 20),
                              SizedBox(width: 8),
                              Text('Send Email'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: const Color(0xFF1976D2)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onTap != null ? const Color(0xFF1976D2) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Functional contact methods using url_launcher
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch email app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error launching email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    // Clean phone number - remove any non-digit characters
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: cleanedPhone,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not make phone call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error making phone call: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({Key? key}) : super(key: key);

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _otherSocialController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  bool _loading = true;

  String _name = "";
  String _surname = "";
  String _location = "";
  String _mobile = "";

  int _postedJobs = 0;
  int _completedJobs = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Fetch from users table
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final userData = userDoc.data() ?? {};

      setState(() {
        _name = userData['name'] ?? "";
        _surname = userData['surname'] ?? "";
        _location = userData['location'] ?? "";
        _mobile = userData['mobile'] ?? "";
        _mobileController.text = _mobile;
      });

      // Fetch client_description (or create if missing)
      final descRef = FirebaseFirestore.instance
          .collection('client_description')
          .doc(uid);
      final descDoc = await descRef.get();

      if (!descDoc.exists) {
        await descRef.set({
          'userId': uid,
          'bio': '',
          'linkedIn': null,
          'github': null,
          'otherSocial': null,
          'location': _location,
          'mobile': _mobile,
        });
      } else {
        final descData = descDoc.data() ?? {};
        _bioController.text = descData['bio'] ?? "";
        _linkedInController.text = descData['linkedIn'] ?? "";
        _githubController.text = descData['github'] ?? "";
        _otherSocialController.text = descData['otherSocial'] ?? "";
      }

      // Calculate stats from jobs
      await _calculateStats(uid);

      setState(() => _loading = false);
    } catch (e) {
      debugPrint("Error loading profile: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _calculateStats(String uid) async {
    // Jobs posted
    final jobsQuery = await FirebaseFirestore.instance
        .collection('jobRequests')
        .where('clientId', isEqualTo: uid)
        .get();

    _postedJobs = jobsQuery.docs.length;

    // Jobs completed
    final completedJobsQuery = await FirebaseFirestore.instance
        .collection('jobRequests')
        .where('clientId', isEqualTo: uid)
        .where('status', isEqualTo: 'complete')
        .get();

    _completedJobs = completedJobsQuery.docs.length;
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Update client_description
      await FirebaseFirestore.instance
          .collection('client_description')
          .doc(uid)
          .update({
        'bio': _bioController.text,
        'linkedIn':
        _linkedInController.text.isEmpty ? null : _linkedInController.text,
        'github': _githubController.text.isEmpty ? null : _githubController.text,
        'otherSocial': _otherSocialController.text.isEmpty
            ? null
            : _otherSocialController.text,
        'location': _location,
        'mobile': _mobileController.text,
      });

      // Update mobile in users as well
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'mobile': _mobileController.text,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error updating profile: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _toggleEdit() => setState(() => _isEditing = !_isEditing);

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
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
              SizedBox(height: 16),
              Text(
                "Loading your profile...",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
        centerTitle: true,
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
            // Profile Avatar with Edit Button
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF1976D2).withOpacity(0.2),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(
                      _profileImage!,
                      fit: BoxFit.cover,
                    )
                        : Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF1976D2).withOpacity(0.7),
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1976D2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Name and Client Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$_name $_surname",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Client",
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _location,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            // Stats Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard("Posted Jobs", _postedJobs.toString(), Icons.work_outline),
                _buildStatCard("Completed", _completedJobs.toString(), Icons.check_circle_outline),
              ],
            ),

            const SizedBox(height: 24),

            // Bio Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About Me",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _bioController,
                    enabled: _isEditing,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Tell others about yourself...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contact Information
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Mobile Number
                  TextField(
                    controller: _mobileController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      prefixIcon: Icon(Icons.phone, color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),

                  SizedBox(height: 16),

                  // LinkedIn
                  TextField(
                    controller: _linkedInController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: "LinkedIn",
                      prefixIcon: Icon(Icons.link, color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),

                  SizedBox(height: 16),

                  // GitHub
                  TextField(
                    controller: _githubController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: "GitHub",
                      prefixIcon: Icon(Icons.code, color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Other Social Media
                  TextField(
                    controller: _otherSocialController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: "Other Social Media",
                      prefixIcon: Icon(Icons.public, color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Edit/Save Button
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _toggleEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleEdit,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1976D2),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: Color(0xFF1976D2),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}