import 'package:flutter/material.dart';
import 'dart:ui';

class GlowingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isObscured;
  final bool isReadOnly;
  final Widget? suffixIcon;

  const GlowingTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.prefixWidget,
    this.validator,
    this.keyboardType,
    this.isObscured = false,
    this.isReadOnly = false,
    this.suffixIcon,
  });

  @override
  State<GlowingTextField> createState() => _GlowingTextFieldState();
}

class _GlowingTextFieldState extends State<GlowingTextField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? _errorText;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _pulseAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  void _onFocusChange() {
    if (widget.isReadOnly) {
      _focusNode.unfocus();
      return;
    }
    setState(() {
      _hasFocus = _focusNode.hasFocus;
      if (_hasFocus) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _formFieldKey.currentState?.validate();
      }
    });
  }

  void _onTextChanged() {
    if (_hasFocus) {
      _formFieldKey.currentState?.validate();
    }
  }

  final GlobalKey<FormFieldState> _formFieldKey = GlobalKey<FormFieldState>();

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _pulseController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FormField<String>(
      key: _formFieldKey,
      initialValue: widget.controller.text,
      validator: (value) {
        final error = widget.validator?.call(widget.controller.text);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _errorText = error);
        });
        return error;
      },
      builder: (field) {
        final hasError = _errorText != null && _errorText!.isNotEmpty;
        final activeColor = hasError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary; // Royal Gold

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (_hasFocus || hasError)
                        BoxShadow(
                          color: activeColor.withOpacity(0.3),
                          blurRadius: _pulseAnimation.value,
                          spreadRadius: _pulseAnimation.value / 4,
                        ),
                    ],
                  ),
                  child: child,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    readOnly: widget.isReadOnly,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    obscureText: widget.isObscured,
                    keyboardType: widget.keyboardType,
                    cursorColor: activeColor,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                      prefixIcon: widget.prefixWidget ??
                          (widget.icon != null
                              ? Icon(
                                  widget.icon,
                                  color: (_hasFocus || hasError)
                                      ? activeColor
                                      : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                                )
                              : null),
                      suffixIcon: widget.suffixIcon,
                      filled: true,
                      fillColor: isDark 
                          ? Colors.white.withOpacity(0.05) 
                          : Colors.black.withOpacity(0.02),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: hasError ? activeColor : Colors.white10,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: hasError 
                             ? activeColor 
                             : (isDark ? Colors.white12 : Colors.black.withOpacity(0.05)),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: activeColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  _errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
