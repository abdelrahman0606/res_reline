import 'package:flutter/material.dart';
import '../src/masonry/masonry_layout.dart';

/// Demo screen for [MasonryLayout].
///
/// There is no desktop/tablet/mobile branching anywhere in this file —
/// resize the app window (or run on different device sizes) and the same
/// `Masonry` widgets rearrange themselves automatically.
///
/// This screen shows two things:
/// 1. A full-width masonry, to verify large/medium/small breakpoints.
/// 2. The exact same layout dropped into a fixed-width 320px side panel,
///    to verify `Masonry` also works correctly when nested inside a
///    constrained ancestor rather than given the full screen width.
class MasonryDemoScreen extends StatelessWidget {
  const MasonryDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masonry layout demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resize the window to test large, medium, and small widths.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildDashboard(),
            const SizedBox(height: 32),
            const Text(
              'The same layout, nested in a fixed 320px panel:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              width: 320,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildDashboard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return MasonryLayout(
      gap: 12,
      children: [
        MasonryItem(
          width: MasonryWidth.full,
          child: const _DemoTile(
            label: 'Full • header',
            height: 90,
            color: Colors.indigo,
          ),
        ),
        MasonryItem(
          width: MasonryWidth.side,
          child: const _DemoTile(
            label: 'Third A (tall)',
            height: 220,
            color: Colors.teal,
          ),
        ),
        MasonryItem(
          width: MasonryWidth.side,
          child: const _DemoTile(
            label: 'Third B',
            height: 100,
            color: Colors.orange,
          ),
        ),
        MasonryItem(
          width: MasonryWidth.side,
          child: const _DemoTile(
            label: 'Third C',
            height: 130,
            color: Colors.pink,
          ),
        ),
        MasonryItem(
          width: MasonryWidth.body,
          child: const _DemoTile(
            label: 'Half',
            height: 150,
            color: Colors.blueGrey,
          ),
        ),
        MasonryItem(
          width: MasonryWidth.side,
          child: const _DemoTile(
            label: 'Quarter',
            height: 100,
            color: Colors.brown,
          ),
        ),

      ],
    );
  }
}

/// A simple colored box used to make the packing behavior visible.
/// Replace with real widgets in your app — `Masonry` doesn't care what
/// its children look like.
class _DemoTile extends StatelessWidget {
  const _DemoTile({
    required this.label,
    required this.height,
    required this.color,
  });

  final String label;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
