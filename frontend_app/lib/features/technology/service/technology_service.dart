import '../model/technology.dart';

class TechnologyService {
  Future<List<TechTrend>> getTechTrends(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (category.toLowerCase()) {
      case 'ai':
        return _getAITrends();
      case 'mobile':
        return _getMobileTrends();
      case 'web':
        return _getWebTrends();
      case 'blockchain':
        return _getBlockchainTrends();
      default:
        return [];
    }
  }

  List<TechTrend> _getAITrends() {
    final now = DateTime.now();
    return [
      TechTrend(category: 'AI', rank: 1, title: 'GPT-5 Announcement', description: 'OpenAI reveals next-generation language model', company: 'OpenAI', impact: 98, timestamp: now.subtract(const Duration(hours: 2)), imageUrl: 'https://picsum.photos/400/300?random=40'),
      TechTrend(category: 'AI', rank: 2, title: 'AI Chip Breakthrough', description: 'New neural processing unit 10x faster', company: 'NVIDIA', impact: 95, timestamp: now.subtract(const Duration(hours: 4))),
      TechTrend(category: 'AI', rank: 3, title: 'Medical AI Diagnosis', description: 'AI system detects cancer with 99% accuracy', company: 'Google Health', impact: 92, timestamp: now.subtract(const Duration(hours: 6))),
    ];
  }

  List<TechTrend> _getMobileTrends() {
    final now = DateTime.now();
    return [
      TechTrend(category: 'Mobile', rank: 1, title: 'iPhone 16 Launch', description: 'Apple unveils revolutionary smartphone features', company: 'Apple', impact: 90, timestamp: now.subtract(const Duration(hours: 1))),
      TechTrend(category: 'Mobile', rank: 2, title: 'Android 15 Features', description: 'Google announces major OS improvements', company: 'Google', impact: 85, timestamp: now.subtract(const Duration(hours: 3))),
    ];
  }

  List<TechTrend> _getWebTrends() {
    final now = DateTime.now();
    return [
      TechTrend(category: 'Web', rank: 1, title: 'React 19 Release', description: 'Major update brings performance improvements', company: 'Meta', impact: 88, timestamp: now.subtract(const Duration(hours: 2))),
      TechTrend(category: 'Web', rank: 2, title: 'WebAssembly 3.0', description: 'New standard enables faster web applications', company: 'W3C', impact: 82, timestamp: now.subtract(const Duration(hours: 5))),
    ];
  }

  List<TechTrend> _getBlockchainTrends() {
    final now = DateTime.now();
    return [
      TechTrend(category: 'Blockchain', rank: 1, title: 'Ethereum 3.0', description: 'Major upgrade improves scalability', company: 'Ethereum Foundation', impact: 94, timestamp: now.subtract(const Duration(hours: 1))),
      TechTrend(category: 'Blockchain', rank: 2, title: 'Bitcoin Lightning', description: 'Lightning Network reaches new milestone', company: 'Lightning Labs', impact: 87, timestamp: now.subtract(const Duration(hours: 4))),
    ];
  }
}