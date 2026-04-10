import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/database/database_helper.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<Map<String, dynamic>> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    // Load favorites from database
    if (mounted) {
      setState(() {
        _collections = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '我的收藏',
          style: TextStyle(
            color: AppColors.textBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _collections.isEmpty ? _buildEmptyState() : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: const Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 20),
          const Text(
            '还没有收藏',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBrown,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击答题页的星标可以收藏题目',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8D6E63),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _collections.length,
      itemBuilder: (context, index) {
        final item = _collections[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['category'] ?? '成语',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryYellow,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: AppColors.accentPink),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item['question'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBrown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '答案: ${item['answer'] ?? ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8D6E63),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}