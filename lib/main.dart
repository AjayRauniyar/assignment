import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// A widget building the [MaterialApp] with a dock of icons.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
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
    );
  }
}

/// A dock widget with draggable and reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  /// Initial list of [T] items to display in the dock.
  final List<T> items;

  /// A builder that provides the UI for each item in the dock.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock], used for manipulating the [_items] and handling drag.
class _DockState<T extends Object> extends State<Dock<T>> {
  /// The list of items being displayed and manipulated in the dock.
  final List<T> _items;

  _DockState() : _items = [];

  /// Tracks the index of the item being dragged.
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    _items.addAll(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return LongPressDraggable<T>(
            data: item,
            axis: Axis.horizontal,
            child: DragTarget<T>(
              onAcceptWithDetails: (DragTargetDetails<T> details) {
                setState(() {
                  // Swap the dragged item with the target item
                  final draggedItem = _items[_draggingIndex!];
                  _items[_draggingIndex!] = _items[index];
                  _items[index] = draggedItem;
                });
              },
              onWillAcceptWithDetails: (DragTargetDetails<T> details) {
                setState(() {
                  _draggingIndex = index;
                });
                return true;
              },
              builder: (context, acceptedItems, rejectedItems) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 1.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: widget.builder(item),
                );
              },
            ),
            feedback: Material(
              child: Opacity(
                opacity: 0.8,
                child: widget.builder(item),
              ),
              color: Colors.transparent,
            ),
            childWhenDragging: const SizedBox.shrink(),
            onDragStarted: () {
              setState(() {
                _draggingIndex = index;
              });
            },
            onDragEnd: (details) {
              setState(() {
                _draggingIndex = null;
              });
            },
          );
        }).toList(),
      ),
    );
  }
}

/// A draggable icon widget used within the dock.
class DraggableIcon extends StatelessWidget {
  const DraggableIcon({
    super.key,
    required this.icon,
  });

  /// The icon data for the draggable widget.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Center(child: Icon(icon, color: Colors.white)),
    );
  }
}
