import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Introduction'),
            _buildParagraph(
              'Welcome to AgriMart. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.',
            ),
            
            _buildSectionTitle('The Data We Collect About You'),
            _buildParagraph(
              'We may collect, use, store and transfer different kinds of personal data about you which we have grouped together as follows:',
            ),
            _buildBulletPoint('Identity Data: includes first name, last name, username or similar identifier'),
            _buildBulletPoint('Contact Data: includes email address and telephone numbers'),
            _buildBulletPoint('Technical Data: includes internet protocol (IP) address, your login data, browser type and version'),
            _buildBulletPoint('Profile Data: includes your username and password, purchases made by you, your interests, preferences, feedback and survey responses'),
            _buildBulletPoint('Usage Data: includes information about how you use our application and services'),
            _buildBulletPoint('Location Data: includes your current location disclosed by GPS technology'),
            
            _buildSectionTitle('How We Use Your Personal Data'),
            _buildParagraph(
              'We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:',
            ),
            _buildBulletPoint('To register you as a new customer'),
            _buildBulletPoint('To process and deliver your orders'),
            _buildBulletPoint('To manage our relationship with you'),
            _buildBulletPoint('To improve our application, products/services, marketing or customer relationships'),
            _buildBulletPoint('To recommend products that may be of interest to you'),
            
            _buildSectionTitle('Data Security'),
            _buildParagraph(
              'We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorized way, altered or disclosed. In addition, we limit access to your personal data to those employees, agents, contractors and other third parties who have a business need to know.',
            ),
            
            _buildSectionTitle('Data Retention'),
            _buildParagraph(
              'We will only retain your personal data for as long as necessary to fulfill the purposes we collected it for, including for the purposes of satisfying any legal, accounting, or reporting requirements.',
            ),
            
            _buildSectionTitle('Your Legal Rights'),
            _buildParagraph(
              'Under certain circumstances, you have rights under data protection laws in relation to your personal data, including the right to:',
            ),
            _buildBulletPoint('Request access to your personal data'),
            _buildBulletPoint('Request correction of your personal data'),
            _buildBulletPoint('Request erasure of your personal data'),
            _buildBulletPoint('Object to processing of your personal data'),
            _buildBulletPoint('Request restriction of processing your personal data'),
            _buildBulletPoint('Request transfer of your personal data'),
            _buildBulletPoint('Right to withdraw consent'),
            
            _buildSectionTitle('Third-Party Links'),
            _buildParagraph(
              'This application may include links to third-party websites, plug-ins and applications. Clicking on those links or enabling those connections may allow third parties to collect or share data about you. We do not control these third-party websites and are not responsible for their privacy statements.',
            ),
            
            _buildSectionTitle('Changes to the Privacy Policy'),
            _buildParagraph(
              'We may update our privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the "Last Updated" date at the top of this privacy policy.',
            ),
            
            _buildSectionTitle('Contact Us'),
            _buildParagraph(
              'If you have any questions about this privacy policy or our privacy practices, please contact us at:',
            ),
            _buildContactInfo('Email: contact@agrimart.com'),
            _buildContactInfo('Phone: +94 712724924'),
            _buildWebsiteLink('Website: https://agri-mart-landing-page-gy3o.vercel.app/'),
            _buildContactInfo('Address: AgriMart Headquarters, Colombo, Sri Lanka'),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildWebsiteLink(String text) {
    // Extract URL from text
    String displayText = text;
    String url = '';
    
    if (text.contains('https://')) {
      url = text.substring(text.indexOf('https://'));
    }
    
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: GestureDetector(
        onTap: () => _launchUrl(url),
        child: Text(
          displayText,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}