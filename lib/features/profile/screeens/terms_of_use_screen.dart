import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Terms of Use',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            _termsOfUseText,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  static const String _termsOfUseText = '''
Eu in amet ornare integer arcu nulla nisl adipiscing. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc.

Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut.

Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc.

Eu in amet ornare integer arcu nulla nisl adipiscing. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc.

Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut.

Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc.

Eu in amet ornare integer arcu nulla nisl adipiscing. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc.

Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut.

Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc.

Eu in amet ornare integer arcu nulla nisl adipiscing. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc.

Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut.

Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc.

Molestie morbi morbi aliquet masse pellentesque. Molestie morbi morbi aliquet masse pellentesque. Molestie morbi morbi aliquet masse pellentesque. Molestie morbi morbi aliquet masse pellentesque.

Eu in amet ornare integer arcu nulla nisl adipiscing. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc. Nunc mauris mauris, nunc, amet, amet, nunc.

Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut. Mollis fringilla suspendisse integer sit ut.
''';
}

