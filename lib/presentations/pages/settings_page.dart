import 'package:bettertune/services/settings_service.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settings = SettingsService();

  // Pre-defined colors for background customization
  final List<Color> _colors = [
    const Color(0xFF121212), // Default Dark
    const Color(0xFF000000), // Pure Black (OLED)
    const Color(0xFF1E1E2C), // Navy
    const Color(0xFF2C0e0e), // Dark Red
    const Color(0xFF0e2c15), // Dark Green
    const Color(0xFF2c240e), // Dark Gold
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        forceMaterialTransparency: true,
      ),
      body: AnimatedBuilder(
        animation: _settings,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader("Audio"),
              SwitchListTile(
                title: const Text("Enable Dolby / Hi-Res Audio"),
                subtitle: const Text(
                  "Allow AC3, EAC3, and FLAC formats. Requires device support.",
                ),
                value: _settings.dolbyEnabled,
                onChanged: (val) {
                  _settings.setDolbyEnabled(val);
                },
                secondary: const Icon(Icons.surround_sound),
              ),
              const Divider(),
              _buildSectionHeader("Appearance"),
              const SizedBox(height: 10),
              const Text("Background Color", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _colors.map((color) {
                  final isSelected =
                      _settings.backgroundColor.value == color.value;
                  return GestureDetector(
                    onTap: () => _settings.setBackgroundColor(color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : Border.all(color: Colors.grey, width: 1),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Optional: Image Path input
              // TextField(
              //   decoration: const InputDecoration(
              //     labelText: "Background Image Path",
              //     border: OutlineInputBorder(),
              //   ),
              //   onChanged: (val) {
              //     // Simple debounce or submit?
              //     // For now let's just use colors as primary, image customization
              //     // usually requires file picker which we plan to avoid if possible for now.
              //   },
              // ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
