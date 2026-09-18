part of 'masonry_layout.dart';

/// Describes which display zone a [MasonryItem] occupies within a
/// [MasonryLayout] or [SliverMasonryLayout].
///
/// The available width is split into a *body* zone and an optional *side*
/// zone. Exact pixel widths for each zone are controlled by the layout's
/// [bodyMaxWidth], [sideMaxWidth], [bodyMinWidth], and [isSideExpanded]
/// parameters — items only declare *where* they belong, not *how wide*
/// they are in absolute terms.
enum MasonryWidth {

  full,

  body,

  side,
}
