import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bubble_bottom_nav.dart';
import '../../../core/widgets/primary_button.dart';

/// Một mục trong lịch sử trả giá của phiên đấu giá.
class _BidHistoryEntry {
  const _BidHistoryEntry({
    required this.bidder,
    required this.amount,
    required this.time,
  });

  final String bidder;
  final double amount;
  final DateTime time;
}

/// Màn hình Phiên Đấu Giá (Câu 5): dựng lại mockup "Mã phiên P001" của giáo viên.
///
/// Gồm thẻ sản phẩm, băng đếm ngược thời gian còn lại, thẻ thông tin phiên,
/// lịch sử trả giá và nút đặt giá nhanh. Bottom nav 3 tab chỉ mang tính hiển thị.
class AuctionSessionScreen extends StatefulWidget {
  const AuctionSessionScreen({super.key});

  @override
  State<AuctionSessionScreen> createState() => _AuctionSessionScreenState();
}

class _AuctionSessionScreenState extends State<AuctionSessionScreen> {
  /// Bước tăng giá mỗi lần nhấn nút (VND).
  static const double _bidStep = 100000;

  /// Thời gian đếm ngược ban đầu: 02:15:00.
  static const Duration _initialCountdown =
      Duration(hours: 2, minutes: 15);

  Timer? _timer;
  Duration _remaining = _initialCountdown;

  double _currentBid = 1500000;

  /// Tab đang chọn trên bottom nav (mặc định là Phiên Đấu Giá).
  int _tabIndex = 1;

  // Thời gian bắt đầu và kết thúc phiên (mock).
  final DateTime _startTime =
      DateTime.now().subtract(const Duration(hours: 1));
  final DateTime _endTime = DateTime.now().add(_initialCountdown);

  // Lịch sử trả giá (mock), mục mới nhất nằm trên cùng.
  final List<_BidHistoryEntry> _history = [
    _BidHistoryEntry(
      bidder: 'Nguyễn Văn A',
      amount: 1500000,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    _BidHistoryEntry(
      bidder: 'Trần Thị B',
      amount: 1400000,
      time: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    _BidHistoryEntry(
      bidder: 'Lê Văn C',
      amount: 1300000,
      time: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    _BidHistoryEntry(
      bidder: 'Phạm Thị D',
      amount: 1200000,
      time: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Đếm ngược mỗi giây; luôn huỷ timer trong dispose.
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (_remaining.inSeconds <= 0) {
      timer.cancel();
      return;
    }
    setState(() {
      _remaining -= const Duration(seconds: 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Tăng giá hiện tại một bước cố định và thêm mục "Bạn" lên đầu lịch sử.
  void _placeQuickBid() {
    setState(() {
      _currentBid += _bidStep;
      _history.insert(
        0,
        _BidHistoryEntry(
          bidder: 'Bạn',
          amount: _currentBid,
          time: DateTime.now(),
        ),
      );
    });
  }

  /// Định dạng đếm ngược dạng HH:MM:SS.
  String _formatCountdown(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:'
        '${two(d.inSeconds % 60)}';
  }

  /// Định dạng giờ phút cho lịch sử trả giá.
  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Phiên Đấu Giá'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _buildItemCard(),
          const SizedBox(height: 16),
          _buildCountdownBanner(),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildHistoryCard(),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Đặt Giá Nhanh', onPressed: _placeQuickBid),
        ],
      ),
      bottomNavigationBar: BubbleBottomNav(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          setState(() => _tabIndex = index);
        },
        items: const [
          BubbleBottomNavItem(icon: Icons.home_outlined, label: 'Trang chủ'),
          BubbleBottomNavItem(icon: Icons.gavel, label: 'Phiên Đấu Giá'),
          BubbleBottomNavItem(icon: Icons.person_outline, label: 'Cá nhân'),
        ],
      ),
    );
  }

  /// Thẻ sản phẩm: ảnh minh hoạ gradient, tên sản phẩm và giá hiện tại.
  Widget _buildItemCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppColors.radiusCard),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
              ),
              child: const Icon(
                Icons.smartphone_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'iPhone 15 Pro Max 256GB',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Giá hiện tại',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatCurrency(_currentBid),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Băng đếm ngược thời gian còn lại của phiên (cập nhật mỗi giây).
  Widget _buildCountdownBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.mintChip,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: AppColors.mintChipIcon,
              ),
              SizedBox(width: 6),
              Text(
                'Thời gian còn lại',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mintChipIcon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatCountdown(_remaining),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppColors.mintChipIcon,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ thông tin phiên: mã phiên, thời gian bắt đầu và kết thúc.
  Widget _buildInfoCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _InfoRow(
              icon: Icons.confirmation_number_outlined,
              label: 'Mã phiên',
              value: 'P001',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.play_circle_outline,
              label: 'Bắt đầu',
              value: Formatters.formatDateTime(_startTime),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.flag_outlined,
              label: 'Kết thúc',
              value: Formatters.formatDateTime(_endTime),
            ),
          ],
        ),
      ),
    );
  }

  /// Danh sách lịch sử trả giá, mục mới nhất nằm trên cùng.
  Widget _buildHistoryCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Lịch sử trả giá',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _history.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.divider),
              _buildHistoryRow(_history[i], i),
            ],
          ],
        ),
      ),
    );
  }

  /// Một dòng trong lịch sử trả giá: người trả, số tiền và thời gian.
  Widget _buildHistoryRow(_BidHistoryEntry entry, int index) {
    const avatarColors = [
      AppColors.pastelBudget,
      AppColors.pastelTransfer,
      AppColors.pastelSaving,
      AppColors.pastelExpense,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: avatarColors[index % avatarColors.length],
            child: Text(
              entry.bidder.characters.first,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.bidder,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(entry.time),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(entry.amount),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dòng thông tin trong thẻ thông tin phiên: icon + nhãn + giá trị.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
