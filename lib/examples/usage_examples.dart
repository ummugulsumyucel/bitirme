import 'package:flutter/material.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/search_widget.dart';
import '../utils/pagination_helper.dart';
import '../services/notification_service.dart';

/// Bu dosya, yeni eklenen widget'ların ve servislerin nasıl kullanılacağını gösterir.
/// Gerçek uygulamada bu dosyayı silip, örnekleri kendi kodunuzda kullanabilirsiniz.

class UsageExamplesScreen extends StatefulWidget {
  const UsageExamplesScreen({super.key});

  @override
  State<UsageExamplesScreen> createState() => _UsageExamplesScreenState();
}

class _UsageExamplesScreenState extends State<UsageExamplesScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanım Örnekleri')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLoadingExamples(),
            const SizedBox(height: 32),
            _buildErrorExamples(),
            const SizedBox(height: 32),
            _buildSearchExamples(),
            const SizedBox(height: 32),
            _buildNotificationExamples(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loading Widget Örnekleri',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Basic loading
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Temel Loading Widget'),
                SizedBox(height: 16),
                LoadingWidget(message: 'Veriler yükleniyor...'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Loading overlay
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Loading Overlay Örneği'),
                const SizedBox(height: 16),
                LoadingOverlay(
                  isLoading: _isLoading,
                  loadingMessage: 'İşlem yapılıyor...',
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text('Bu içerik loading overlay ile kaplanabilir'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = !_isLoading;
                    });
                  },
                  child: Text(
                    _isLoading ? 'Loading\'i Durdur' : 'Loading\'i Başlat',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Error Widget Örnekleri',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Error display
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Error Display Widget'),
                const SizedBox(height: 16),
                ErrorDisplayWidget(
                  title: 'Bağlantı Hatası',
                  message:
                      'Sunucuya bağlanırken bir hata oluştu. Lütfen internet bağlantınızı kontrol edin.',
                  onRetry: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tekrar deneniyor...')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Error snackbar examples
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('SnackBar Örnekleri'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ErrorSnackBar.show(
                            context,
                            'Bu bir hata mesajıdır',
                            actionLabel: 'Tekrar Dene',
                            onAction: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tekrar denendi!'),
                                ),
                              );
                            },
                          );
                        },
                        child: const Text('Hata Göster'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          SuccessSnackBar.show(
                            context,
                            'İşlem başarıyla tamamlandı!',
                          );
                        },
                        child: const Text('Başarı Göster'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Widget Örnekleri',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Search Widget'),
                const SizedBox(height: 16),
                SearchWidget(
                  hintText: 'Bir şeyler ara...',
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_searchQuery.isNotEmpty)
                  Text('Arama sorgusu: "$_searchQuery"'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Örnekleri',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Notification İşlemleri'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _notificationService.sendNotification(
                            userId: 'example_user_id',
                            title: 'Test Bildirimi',
                            body: 'Bu bir test bildirimidir',
                            type: 'general',
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bildirim gönderildi!'),
                              ),
                            );
                          }
                        },
                        child: const Text('Bildirim Gönder'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final hasPermission = await _notificationService
                              .hasPermission();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  hasPermission
                                      ? 'Bildirim izni var'
                                      : 'Bildirim izni yok',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('İzin Kontrol Et'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Pagination Helper kullanım örneği
class PaginationExampleScreen extends StatefulWidget {
  const PaginationExampleScreen({super.key});

  @override
  State<PaginationExampleScreen> createState() =>
      _PaginationExampleScreenState();
}

class _PaginationExampleScreenState extends State<PaginationExampleScreen> {
  late PaginationHelper<Map<String, dynamic>> _paginationHelper;

  @override
  void initState() {
    super.initState();
    _paginationHelper = PaginationHelper<Map<String, dynamic>>(
      collection: 'notes',
      orderByField: 'createdAt',
      descending: true,
      pageSize: 5,
      fromMap: (data, id) => {'id': id, ...data},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagination Örneği')),
      body: PaginatedListView<Map<String, dynamic>>(
        paginationHelper: _paginationHelper,
        itemBuilder: (context, item, index) {
          return ListTile(
            title: Text(item['title'] ?? 'Başlıksız'),
            subtitle: Text(item['description'] ?? 'Açıklama yok'),
            leading: CircleAvatar(child: Text('${index + 1}')),
          );
        },
        loadingWidget: const LoadingWidget(message: 'Notlar yükleniyor...'),
        errorWidget: const ErrorDisplayWidget(
          message: 'Notlar yüklenirken hata oluştu',
        ),
        emptyWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64),
              SizedBox(height: 16),
              Text('Henüz not yok'),
            ],
          ),
        ),
      ),
    );
  }
}
