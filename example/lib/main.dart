import 'package:flutter/material.dart';
import 'package:aaroh_chat/aaroh_chat.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aaroh Chat SDK Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      // Registered here so MessageAction.route ('/pricing') resolves
      // correctly when pushAarohChat reuses this app's own Navigator.
      routes: {
        '/pricing': (_) => const _PricingPage(),
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ---------------------------------------------------------------------------
  // Example 1: Built-in Aaroh engine (no API key needed)
  // ---------------------------------------------------------------------------
  static final _basicConfig = AarohConfig(
    companyName: 'DemoApp',
    knowledgeBase: [
      'DemoApp is a productivity tool for teams.',
      'We offer a free 14-day trial, no credit card required.',
      'Support: help@demoapp.com',
    ],
    botGreeting: 'Hi! I am the DemoApp assistant. How can I help?',
  );

  // ---------------------------------------------------------------------------
  // Example 2: With Claude API + structured knowledge (KnowledgeItem)
  // ---------------------------------------------------------------------------
  static final _claudeConfig = AarohConfig(
    companyName: 'SmartShop',
    claudeApiKey: 'sk-ant-YOUR_KEY_HERE',   // Uncomment and add your key
    knowledgeBase: [
      // Plain strings still work fine:
      'SmartShop is an e-commerce platform selling electronics, '
          'clothing and home goods.',

      // Structured entries give better matching in built-in engine mode
      // and let you organize by category:
      KnowledgeItem(
        id: 'return-policy',
        question: 'What is your return policy?',
        answer: '30-day hassle-free returns, no questions asked.',
        category: 'Policies',
        keywords: ['refund', 'exchange', 'send back'],
      ),
      KnowledgeItem(
        id: 'delivery',
        question: 'Is delivery free?',
        answer: 'Yes — free delivery on all orders above ₹499.',
        category: 'Shipping',
        keywords: ['shipping', 'courier'],
      ),
      KnowledgeItem(
        id: 'emi',
        question: 'Do you offer EMI?',
        answer: 'Yes, on orders above ₹2000 via major banks.',
        category: 'Payments',
        keywords: ['installment', 'credit card'],
      ),
    ],
    botGreeting: 'Welcome to SmartShop! How can I assist you today?',
    poweredByText: 'Powered by Aaroh',
  );

  // ---------------------------------------------------------------------------
  // Example 3: Rule-based replies + support fallback + deep links
  // (works fully offline — no Claude key needed)
  // ---------------------------------------------------------------------------
  static final _rulesConfig = AarohConfig(
    companyName: 'TripGo',
    topics: [
      TopicRule(
        triggers: ['pricing', 'plans', 'cost', 'how much'],
        reply: 'Here are our current plans — tap below to view details.',
        action: MessageAction(label: 'View Pricing', route: '/pricing'),
      ),
      TopicRule(
        triggers: ['track order', 'where is my order', 'order status'],
        reply: 'Let me pull that up for you.',
        action: MessageAction(label: 'Track Order', actionId: 'track_order'),
      ),
      TopicRule(
        triggers: ['cancel', 'cancellation'],
        reply: 'You can cancel any booking up to 24 hours before departure '
            'for a full refund.',
      ),
    ],
    support: SupportConfig(
      email: 'support@tripgo.com',
      contactUsUrl: 'https://tripgo.com/contact',
      phoneNumber: '1800-555-0199',
    ),
    fallbackReply: "I'm still learning! Try asking about pricing, "
        "order tracking, or cancellations.",
    botGreeting: 'Hi! Ask me about pricing, your order, or cancellations.',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aaroh Chat SDK Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose a demo:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),

            // Basic demo
            FilledButton.icon(
              onPressed: () => pushAarohChat(context, config: _basicConfig),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Basic (Built-in Engine)'),
            ),
            const SizedBox(height: 16),

            // Claude demo
            FilledButton.icon(
              onPressed: () => pushAarohChat(context, config: _claudeConfig),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Smart (Claude API)'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),

            // Rule-based + support + deep link demo
            FilledButton.icon(
              onPressed: () => pushAarohChat(
                context,
                config: _rulesConfig,
                onAction: (actionId) {
                  if (actionId == 'track_order') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('onAction fired: track_order'),
                      ),
                    );
                  }
                },
              ),
              icon: const Icon(Icons.rule_rounded),
              label: const Text('Rules + Support + Deep Links'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 32),

            // Or embed directly
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AarohChatWidget(
                    config: AarohConfig(companyName: 'Embedded Demo'),
                  ),
                ),
              ),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Embedded Widget'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dummy pricing page the 'View Pricing' deep link navigates to.
/// Demonstrates how MessageAction.route resolves against your app's
/// own named routes (passed here via pushAarohChat → your Navigator).
class _PricingPage extends StatelessWidget {
  const _PricingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing')),
      body: const Center(child: Text('Pro plan — ₹999/month')),
    );
  }
}
