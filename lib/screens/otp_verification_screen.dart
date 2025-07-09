import 'dart:async';
import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String contact;
  const OtpVerificationScreen({super.key, required this.contact});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isButtonEnabled = false;

  bool _canResend = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  void _verifyOTP() {
    final otp = _otpController.text.trim();
    if (otp == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(contact: widget.contact),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kode OTP salah')));
    }
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  void _resendOTP() {
    // Simulasikan pengiriman ulang OTP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kode OTP dikirim ulang ke ${widget.contact}')),
    );
    _startResendTimer();
  }

  @override
  void initState() {
    super.initState();

    _otpController.addListener(() {
      setState(() {
        _isButtonEnabled = _otpController.text.trim().length == 6;
      });
    });

    _startResendTimer(); // mulai timer saat halaman dibuka
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kode OTP telah dikirim ke ${widget.contact}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Masukkan Kode OTP',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonEnabled ? _verifyOTP : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isButtonEnabled ? Colors.orange : Colors.grey.shade400,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Verifikasi', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _canResend ? _resendOTP : null,
                child: Text(
                  _canResend
                      ? "Kirim Ulang Kode"
                      : "Menunggu ($_secondsRemaining s)",
                  style: TextStyle(
                    color: _canResend ? Colors.orange : Colors.grey,
                    fontSize: 15,
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
