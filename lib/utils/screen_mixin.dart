import 'package:flutter/material.dart';
import 'screen_utils.dart';

mixin ScreenStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String _error = '';
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isInitialized => _isInitialized;

  void setLoading(bool value) {
    if (_isLoading != value) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  void setError(String value) {
    if (_error != value) {
      setState(() {
        _error = value;
      });
    }
  }

  void setInitialized(bool value) {
    if (_isInitialized != value) {
      setState(() {
        _isInitialized = value;
      });
    }
  }

  Future<void> handleAsyncOperation(Future<void> Function() operation) async {
    try {
      setLoading(true);
      setError('');
      await operation();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Widget buildLoadingState() {
    return Center(child: CircularProgressIndicator());
  }

  Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildContent(Widget Function(BuildContext) builder) {
    if (!isInitialized) {
      return buildLoadingState();
    }

    if (error.isNotEmpty) {
      return buildErrorState();
    }

    if (isLoading) {
      return buildLoadingState();
    }

    return builder(context);
  }
} 