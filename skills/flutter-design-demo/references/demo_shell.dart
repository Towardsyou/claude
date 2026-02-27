import 'package:flutter/material.dart';

/// Page configuration class
class DemoPageConfig {
  final String title;
  final WidgetBuilder builder;

  const DemoPageConfig({
    required this.title,
    required this.builder,
  });
}

/// Demo shell component
/// Provides floating button for page switching
class DemoShell extends StatefulWidget {
  final List<DemoPageConfig> pages;
  final Color? fabColor;
  final Color? selectorBackgroundColor;
  final Widget? placeholderWidget;

  const DemoShell({
    super.key,
    required this.pages,
    this.fabColor,
    this.selectorBackgroundColor,
    this.placeholderWidget,
  });

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  bool _isSelectorOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSelector() {
    setState(() {
      _isSelectorOpen = !_isSelectorOpen;
      if (_isSelectorOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _closeSelector() {
    if (_isSelectorOpen) {
      setState(() {
        _isSelectorOpen = false;
        _animationController.reverse();
      });
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
      _isSelectorOpen = false;
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content area
          GestureDetector(
            onTap: _closeSelector,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: _selectedIndex != null
                  ? widget.pages[_selectedIndex!].builder(context)
                  : Center(
                      child: widget.placeholderWidget ??
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Click floating button to select page',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                    ),
            ),
          ),

          // Selector overlay
          if (_isSelectorOpen)
            GestureDetector(
              onTap: _closeSelector,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: widget.selectorBackgroundColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Select Page',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  widget.pages.length,
                                  (index) => RadioListTile<int>(
                                    title: Text(widget.pages[index].title),
                                    value: index,
                                    groupValue: _selectedIndex,
                                    onChanged: (value) {
                                      if (value != null) {
                                        _selectPage(value);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Floating action button with Semantics identifier for Maestro testing
      floatingActionButton: Semantics(
        identifier: 'fab_button',
        button: true,
        child: GestureDetector(
          onTap: _toggleSelector,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSelectorOpen ? 0 : 56,
            height: _isSelectorOpen ? 0 : 56,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isSelectorOpen ? 0.0 : 1.0,
              child: FloatingActionButton(
                onPressed: _toggleSelector,
                backgroundColor:
                    widget.fabColor ?? Colors.grey.withOpacity(0.7),
                elevation: 4,
                child: const Icon(Icons.layers, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
