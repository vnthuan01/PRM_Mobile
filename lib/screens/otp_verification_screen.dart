import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/dto/request/otp_request.dart';
import '../services/otp_service.dart';

class RegisterData {
  final String fullName;
  final String password;
  final String confirmPassword;

  RegisterData({
    required this.fullName,
    required this.password,
    required this.confirmPassword,
  });
}

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final RegisterData registerData;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.registerData,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final OtpService _otpService = OtpService();

  bool _isLoading = false;
  bool _isVerifying = false;
  String? _error;
  int? _remainingAttempts;
  int? _cooldownSeconds;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = SendOtpRequest(
      email: widget.email,
      purpose: 0, // Registration purpose
    );

    final response = await _otpService.sendOtp(request);

    setState(() {
      _isLoading = false;
      if (response?.success == true) {
        _remainingAttempts = response?.remainingAttempts;
        _cooldownSeconds = response?.cooldownSeconds ?? 60;
        _countdown = _cooldownSeconds!;
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'OTP đã được gửi đến email'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _error = response?.message ?? 'Không thể gửi OTP. Vui lòng thử lại.';
      }
    });
  }

  void _startCountdown() {
    if (_countdown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _countdown--;
          });
          if (_countdown > 0) {
            _startCountdown();
          }
        }
      });
    }
  }

  void _handleOtpInput(int index, String value) {
    if (value.length == 1) {
      _controllers[index].text = value;
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    final otpCode = _controllers.map((c) => c.text).join();

    if (otpCode.length != 6) {
      setState(() {
        _error = 'Vui lòng nhập đầy đủ 6 ký tự OTP';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final request = VerifyOtpRequest(
      email: widget.email,
      otp: otpCode,
      purpose: 0, // Registration purpose
    );

    final response = await _otpService.verifyOtp(request);

    setState(() {
      _isVerifying = false;
      if (response?.success == true) {
        // OTP verified successfully, navigate back with success
        Navigator.pop(context, true);
      } else {
        _error = response?.message ?? 'Mã OTP không hợp lệ. Vui lòng thử lại.';
        _remainingAttempts = response?.remainingAttempts;
        _cooldownSeconds = response?.cooldownSeconds;
        if (_cooldownSeconds != null && _cooldownSeconds! > 0) {
          _countdown = _cooldownSeconds!;
          _startCountdown();
        }
        _clearOtpFields();
      }
    });
  }

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh OTP'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Xác minh email',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Mã OTP đã được gửi đến\n${widget.email}',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2, // giúp text không bị lệch dọc
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ), // căn giữa dọc
                      ),
                      onChanged: (value) => _handleOtpInput(index, value),
                      onTap: () {
                        _controllers[index]
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: _controllers[index].text.length),
                        );
                      },
                      onSubmitted: (_) => _focusNodes[index].unfocus(),

                      // ✅ Cho phép paste toàn bộ OTP
                      onEditingComplete: () {
                        // Nếu user paste toàn bộ mã vào ô đầu tiên
                        if (index == 0) {
                          final text = _controllers[index].text;
                          if (text.length == 6) {
                            for (int i = 0; i < 6; i++) {
                              _controllers[i].text = text[i];
                            }
                            _verifyOtp();
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Remaining Attempts
              if (_remainingAttempts != null && _remainingAttempts! > 0) ...[
                Text(
                  'Số lần thử còn lại: $_remainingAttempts',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],

              // Resend OTP Section
              if (_countdown > 0) ...[
                Text(
                  'Gửi lại mã sau ${_countdown}s',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ] else ...[
                TextButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: Text(
                    'Gửi lại mã OTP',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                height: 54,
                child: _isVerifying
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          _focusNodes.last.unfocus();
                          _verifyOtp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Xác minh'),
                      ),
              ),

              const SizedBox(height: 24),

              // Back Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Quay lại',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
