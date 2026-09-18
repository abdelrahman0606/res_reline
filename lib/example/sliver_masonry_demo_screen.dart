
import 'package:flutter/material.dart';

import '../my_responsive.dart';

/// Demo screen for [SliverMasonryLayout].
///
/// Separate from any existing `MasonryLayout` demo — this file only
/// exercises the new Sliver implementation. It deliberately places a
/// [SliverAppBar], a plain [SliverList], and a [SliverPadding] around
/// [SliverMasonryLayout] to verify it composes correctly as one sliver
/// among others in a single [CustomScrollView], with real shared
/// scrolling (not a scrollable nested inside a scrollable).
///
/// Resize the window to see the packing adapt at large, medium, and
/// small widths — there's no desktop/mobile branching in this file.
class SliverMasonryDemoScreen extends StatelessWidget {
  const SliverMasonryDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Sliver masonry demo'),
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Ordinary content above the masonry section, in its '
                  'own SliverList — scrolling is shared with everything '
                  'below.',
                ),
              ),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverMasonryLayout(
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
                  width: MasonryWidth.body,
                  child: const _DemoTile(
                    label: 'Quarter',
                    height: 100,
                    color: Colors.brown,
                  ),
                ),
                MasonryItem(
                  width: MasonryWidth.side,
                  child: const _DemoTile(
                    label: 'Auto',
                    height: 180,
                    color: Colors.green,
                  ),
                ),
                MasonryItem(
                  width: MasonryWidth.side,
                  child: const _DemoTile(
                    label: 'Quarter 2',
                    height: 130,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Ordinary content below the masonry section, also in '
                  'its own SliverList.',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple colored box used to make the packing behavior visible.
/// Replace with real widgets in your app.
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
