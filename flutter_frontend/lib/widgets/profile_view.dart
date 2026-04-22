import 'package:flutter/material.dart';

import '../theme.dart';
import 'college_scaffold.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.title,
    required this.role,
    required this.heroIcon,
    required this.name,
    required this.subtitle,
    required this.fields,
  });

  final String title;
  final String role;
  final IconData heroIcon;
  final String name;
  final String subtitle;
  final List<MapEntry<String, String>> fields;

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: title,
      role: role,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8F0D12), Color(0xFFCE5961)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, headerConstraints) {
                              final compact = headerConstraints.maxWidth < 520;
                              return compact
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _LogoBadge(icon: heroIcon),
                                        const SizedBox(height: 16),
                                        _HeaderText(name: name, subtitle: subtitle),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        _LogoBadge(icon: heroIcon),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: _HeaderText(name: name, subtitle: subtitle),
                                        ),
                                      ],
                                    );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (final entry in fields)
                              SizedBox(
                                width: constraints.maxWidth > 680 ? 330 : double.infinity,
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: kSurfaceTint,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: kPrimaryColor.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: kTextLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SelectableText(
                                        entry.value.isEmpty ? '-' : entry.value,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: kTextDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            'assets/images/vvcoe_logo.jpg',
            width: 76,
            height: 76,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
