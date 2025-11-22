import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _validationMessage = '';
  Map<String, dynamic>? _validatedStudent;

  void _validateStudentId() async {
    if (_studentIdController.text.isEmpty) {
      setState(() {
        _validationMessage = 'Please enter Student ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _validationMessage = '';
      _validatedStudent = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.validateStudent(_studentIdController.text);

      if (response['valid'] == true) {
        setState(() {
          _validationMessage = '✅ Student ID verified: ${response['student']['name']}';
          _validatedStudent = response['student'];
        });
      } else {
        setState(() {
          _validationMessage = '❌ Student ID not found in system';
          _validatedStudent = null;
        });
      }
    } catch (e) {
      setState(() {
        _validationMessage = 'Error validating Student ID: $e';
        _validatedStudent = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_validatedStudent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please validate your Student ID first')),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = ApiService();
        final response = await apiService.registerStudent(
          _studentIdController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
          
          // Navigate to login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(Icons.school, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'OJT Student Portal', // FIXED: Removed headline5
                style: TextStyle( // FIXED: Using TextStyle directly
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Register with your Student ID',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Student ID Field with Validation
              TextFormField(
                controller: _studentIdController,
                decoration: InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.badge),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.verified_user),
                    onPressed: _validateStudentId,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Student ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Validation Message
              if (_validationMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _validationMessage.contains('✅') 
                        ? Colors.green[50] 
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _validationMessage.contains('✅')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _validationMessage.contains('✅') 
                            ? Icons.check_circle 
                            : Icons.error,
                        color: _validationMessage.contains('✅')
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationMessage,
                          style: TextStyle(
                            color: _validationMessage.contains('✅')
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Student Info (if validated)
              if (_validatedStudent != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Name: ${_validatedStudent!['name']}'),
                        Text('Student ID: ${_validatedStudent!['student_id']}'),
                        if (_validatedStudent!['section_name'] != null)
                          Text('Section: ${_validatedStudent!['section_name']}'),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Register Button
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _validatedStudent != null ? _register : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Register Account'),
                    ),

              const SizedBox(height: 16),

              // Login Link
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text('Already have an account? Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}