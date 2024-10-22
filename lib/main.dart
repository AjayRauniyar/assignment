import 'package:flutter/material.dart';

/// The entry point of the application.
///
/// This function runs the Flutter app and displays the dock of icons.
void main() {
  runApp(const MyApp());
}

/// A stateless widget that builds the [MaterialApp] containing the dock.
///
/// The [MyApp] widget defines the structure of the app's main screen, which includes
/// a [Dock] widget displaying a row of draggable icons.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          /// Displays the dock with draggable icons in the center of the screen.
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return DraggableIcon(icon: icon);
            },
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// A dock widget that displays and manages draggable and reorderable items.
///
/// The [Dock] widget takes a list of generic items [T] and a builder function
/// that defines how each item is rendered. The items are draggable and can
/// be reordered by dragging them into different slots.
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  /// A list of items to display in the dock.
  ///
  /// The items can be of any type [T], and they are displayed in the order
  /// they appear in the list.
  final List<T> items;

  /// A builder function that generates the UI for each item in the dock.
  ///
  /// The builder takes an item of type [T] and returns a widget that will be
  /// displayed as part of the dock.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// The state class for [Dock], managing the items and drag-and-drop functionality.
///
/// The [_DockState] class keeps track of the list of items and handles the logic
/// for reordering items when they are dragged and dropped into different positions.
class _DockState<T extends Object> extends State<Dock<T>> {
  /// The list of items currently displayed in the dock.
  ///
  /// The [_items] list is initialized with the items passed to the [Dock] widget.
  late List<T> _items;

  /// The index of the item that is currently being dragged.
  ///
  /// This variable keeps track of the index of the item being dragged so that
  /// it can be properly reordered when the drag operation is completed.
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList(); // Initialize the list of items.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return DragTarget<T>(
            /// Called when an item is accepted into a new slot.
            ///
            /// This function updates the [_items] list by removing the item
            /// from its old position and inserting it into the new position.
            onAcceptWithDetails: (details) {
              setState(() {
                final draggedItem = _items.removeAt(_draggingIndex!);
                _items.insert(index, draggedItem);
              });
            },

            /// Determines whether the dragged item should be accepted.
            ///
            /// Always returns true, indicating that any item can be dropped
            /// into any slot.
            onWillAcceptWithDetails: (details) {
              return true;
            },

            /// Builds the drag target and its associated draggable item.
            ///
            /// The [builder] function is used to create the UI for each item in the dock.
            builder: (context, acceptedItems, rejectedItems) {
              return LongPressDraggable<T>(
                data: item,
                feedback: Material(
                  color: Colors.transparent,
                  child: widget.builder(item),

                ),
                child: widget.builder(item),
                childWhenDragging: const SizedBox.shrink(),

                /// Updates the state when dragging starts by recording the index
                /// of the dragged item.
                onDragStarted: () {
                  setState(() {
                    _draggingIndex = index;
                  });
                },

                /// Resets the drag state when dragging ends.
                onDragEnd: (details) {
                  setState(() {
                    _draggingIndex = null;
                  });
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

/// A stateless widget that represents a draggable icon.
///
/// This widget is used within the [Dock] to display icons that can be dragged
/// and reordered. Each icon is wrapped in an [AnimatedContainer] to provide
/// smooth transitions when the layout changes.
class DraggableIcon extends StatelessWidget {
  const DraggableIcon({
    super.key,
    required this.icon,
  });

  /// The icon to be displayed and dragged.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
