import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const WatchStudioApp());

class CharacterTheme {
  final String name;
  final String tagline;
  final String glyph;
  final Color bg;
  final Color accent;
  final Color ring;
  const CharacterTheme(this.name, this.tagline, this.glyph, this.bg, this.accent, this.ring);
}

const themes = <CharacterTheme>[
  CharacterTheme('Night Guardian', 'Patrol mode', '🦇', Color(0xFF0D1117), Color(0xFFFFC400), Color(0xFF3A3F4B)),
  CharacterTheme('Web Slinger', 'Friendly neighbourhood', '🕷️', Color(0xFF1B0A12), Color(0xFFE53935), Color(0xFF1E88E5)),
  CharacterTheme('Galaxy Rebel', 'Far, far away', '🚀', Color(0xFF050B24), Color(0xFF4FC3F7), Color(0xFF7E57C2)),
  CharacterTheme('Wizard School', 'Spell ready', '🧙', Color(0xFF1A1030), Color(0xFFFFD54F), Color(0xFF8E24AA)),
  CharacterTheme('Dragon Rider', 'Fire and flight', '🐉', Color(0xFF1F0A05), Color(0xFFFF7043), Color(0xFFBF360C)),
  CharacterTheme('Iron Suit', 'Powered up', '🤖', Color(0xFF2A0A0A), Color(0xFFFFCA28), Color(0xFFD32F2F)),
];

enum Anim { pulse, spin, bounce, off }

class WatchStudioApp extends StatelessWidget {
  const WatchStudioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Watch Studio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF00897B), useMaterial3: true, brightness: Brightness.dark),
        home: const StudioPage(),
      );
}

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});
  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> with TickerProviderStateMixin {
  CharacterTheme theme = themes.first;
  Anim anim = Anim.pulse;
  bool countSteps = true; // false = steps disabled
  bool showHeart = true;
  late final AnimationController _beat =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  late final AnimationController _spin =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  late Timer _clock;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => now = DateTime.now()));
  }

  @override
  void dispose() {
    _clock.cancel();
    _beat.dispose();
    _spin.dispose();
    super.dispose();
  }

  String two(int n) => n.toString().padLeft(2, '0');

  Widget _face() {
    final c = theme;
    return AnimatedBuilder(
      animation: Listenable.merge([_beat, _spin]),
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_beat.value);
        double scale = 1;
        double dy = 0;
        double rot = 0;
        if (anim == Anim.pulse) scale = 0.96 + 0.06 * t;
        if (anim == Anim.bounce) dy = -14 * t;
        if (anim == Anim.spin) rot = _spin.value * 6.2832;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(alignment: Alignment.center, children: [
                Transform.rotate(
                  angle: rot,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(colors: [c.accent, c.ring, c.accent]),
                    ),
                  ),
                ),
                Container(
                  width: 232,
                  height: 232,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.bg),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(c.glyph, style: const TextStyle(fontSize: 38)),
                  Text('${two(now.hour)}:${two(now.minute)}',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: c.accent)),
                  Text(c.tagline, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.directions_walk, size: 16, color: countSteps ? c.accent : Colors.white24),
                    const SizedBox(width: 4),
                    Text(countSteps ? '6,432' : 'Steps off',
                        style: TextStyle(color: countSteps ? Colors.white : Colors.white38)),
                    if (showHeart) ...[
                      const SizedBox(width: 14),
                      Icon(Icons.favorite, size: 16, color: c.accent),
                      const SizedBox(width: 4),
                      const Text('72'),
                    ],
                  ]),
                ]),
              ]),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watch Studio')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: _face())),
        Text('Character theme', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in themes)
            ChoiceChip(
              avatar: Text(t.glyph),
              label: Text(t.name),
              selected: theme == t,
              onSelected: (_) => setState(() => theme = t),
            ),
        ]),
        const SizedBox(height: 20),
        Text('Animation', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<Anim>(
          segments: const [
            ButtonSegment(value: Anim.pulse, label: Text('Pulse')),
            ButtonSegment(value: Anim.spin, label: Text('Spin')),
            ButtonSegment(value: Anim.bounce, label: Text('Bounce')),
            ButtonSegment(value: Anim.off, label: Text('Off')),
          ],
          selected: {anim},
          onSelectionChanged: (s) => setState(() => anim = s.first),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Count walking steps'),
          subtitle: const Text('Turn off to disable step display and counting'),
          value: countSteps,
          onChanged: (v) => setState(() => countSteps = v),
        ),
        SwitchListTile(
          title: const Text('Show heart rate'),
          value: showHeart,
          onChanged: (v) => setState(() => showHeart = v),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: const Icon(Icons.watch),
          label: const Text('Send to watch'),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Watch link not set up yet. Preview only for now.'),
          )),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Watch touch not working? Charge fully, then hold the side button 10 to 15 seconds '
              'to force restart. If it still fails, try a factory reset or visit a service centre.',
            ),
          ),
        ),
      ]),
    );
  }
}
