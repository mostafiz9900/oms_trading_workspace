import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// A [GetBuilder] for live-data widgets that does not rebuild while it cannot
/// be seen.
///
/// The home tabs live in an [IndexedStack], which keeps building and laying
/// out hidden tabs, and pages pushed on top keep the home screen mounted
/// underneath. During market hours that means every tick rebuilt charts and
/// lists nobody was looking at.
///
/// Hidden means: an inactive [IndexedStack] child ([Visibility.of]) or a
/// route covered by another page ([TickerMode]). Updates that arrive while
/// hidden are coalesced into a single rebuild as soon as the widget is visible
/// again, so what the user sees is the same as with [GetBuilder].
///
/// Only for controllers that are already registered (it uses [Get.find]; it
/// never creates or removes the controller).
class VisibleGetBuilder<T extends GetxController> extends StatefulWidget {
  const VisibleGetBuilder({
    super.key,
    this.id,
    this.tag,
    required this.builder,
  });

  final Object? id;
  final String? tag;
  final GetControllerBuilder<T> builder;

  @override
  State<VisibleGetBuilder<T>> createState() => _VisibleGetBuilderState<T>();
}

class _VisibleGetBuilderState<T extends GetxController>
    extends State<VisibleGetBuilder<T>> {
  late T _controller;
  VoidCallback? _removeListener;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<T>(tag: widget.tag);
    _subscribe();
  }

  void _subscribe() {
    _removeListener?.call();
    _removeListener = widget.id == null
        ? _controller.addListener(_onControllerUpdate)
        : _controller.addListenerId(widget.id, _onControllerUpdate);
  }

  void _onControllerUpdate() {
    // While hidden, skip: becoming visible again rebuilds with current data.
    if (mounted && _visible) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Both lookups register a dependency, so this runs again, followed by a
    // build with the controller's current data, whenever visibility changes.
    _visible = Visibility.of(context) && TickerMode.valuesOf(context).enabled;
  }

  @override
  void didUpdateWidget(VisibleGetBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tag != widget.tag) {
      _controller = Get.find<T>(tag: widget.tag);
      _subscribe();
    } else if (oldWidget.id != widget.id) {
      _subscribe();
    }
  }

  @override
  void dispose() {
    _removeListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}
