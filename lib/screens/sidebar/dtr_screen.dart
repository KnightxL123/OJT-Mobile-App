import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class DtrScreen extends StatefulWidget {
  static const String routeName = '/dtr';

  const DtrScreen({super.key});

  @override
  State<DtrScreen> createState() => _DtrScreenState();
}

class _DtrScreenState extends State<DtrScreen> {
  bool _isLoading = false;
  String? _error;
  String? _rawData;

  @override
  void initState() {
    super.initState();
    _fetchDtr();
  }

  Future<void> _fetchDtr() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse(ApiConstants.baseUrl));

      if (response.statusCode == 200) {
        setState(() {
          _rawData = response.body;
        });
      } else {
        setState(() {
          _error = 'Request failed (${response.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading DTR: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_error!),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _fetchDtr,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (_rawData != null) {
      return SingleChildScrollView(
        child: Text(_rawData!),
      );
    }

    return Center(
      child: TextButton(
        onPressed: _fetchDtr,
        child: const Text('Load DTR'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daily Time Record'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Time Record',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
