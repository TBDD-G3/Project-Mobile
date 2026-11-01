import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Một mục trong lịch sử trả giá của phiên đấu giá.
class _BidHistoryEntry {
  const _BidHistoryEntry({required this.bidder, required this.amount});

  final String bidder;
  final double amount;
}

/// Màn hình Phiên Đấu Giá (Câu 5): dựng bám sát mockup "Mã phiên P001".
///
/// Bố cục: thanh tiêu đề xám, ảnh sản phẩm, thẻ thông tin phiên nền xanh nhạt,
/// khung đếm ngược viền đen, bảng lịch sử trả giá và nút đặt giá nhanh.
class AuctionSessionScreen extends StatefulWidget {
  const AuctionSessionScreen({super.key});

  @override
  State<AuctionSessionScreen> createState() => _AuctionSessionScreenState();
}

class _AuctionSessionScreenState extends State<AuctionSessionScreen> {
  /// Bước tăng giá mỗi lần nhấn nút (VND).
  static const double _bidStep = 100000;

  /// Thời gian đếm ngược ban đầu: 02:15:00.
  static const Duration _initialCountdown = Duration(hours: 2, minutes: 15);

  static const Color _titleBarColor = Color(0xFFD8DEDC);
  static const Color _infoCardColor = Color(0xFFE9EFEA);
  static const Color _tableHeaderColor = Color(0xFFE4E8E7);
  static const Color _bidButtonColor = Color(0xFFE9574E);

  Timer? _timer;
  Duration _remaining = _initialCountdown;

  double _currentBid = 1500000;

  // Thời gian bắt đầu và kết thúc phiên (mock).
  final DateTime _startTime = DateTime.now().subtract(const Duration(hours: 1));
  final DateTime _endTime = DateTime.now().add(_initialCountdown);

  // Lịch sử trả giá (mock), mục mới nhất nằm trên cùng.
  final List<_BidHistoryEntry> _history = [
    _BidHistoryEntry(bidder: 'Nguyễn Văn A', amount: 1500000),
    _BidHistoryEntry(bidder: 'Trần Thị B', amount: 1400000),
    _BidHistoryEntry(bidder: 'Lê Văn C', amount: 1300000),
    _BidHistoryEntry(bidder: 'Phạm Thị D', amount: 1200000),
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
      _history.insert(0, _BidHistoryEntry(bidder: 'Bạn', amount: _currentBid));
    });
  }

  /// Định dạng đếm ngược dạng HH:MM:SS.
  String _formatCountdown(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:'
        '${two(d.inSeconds % 60)}';
  }

  /// Định dạng thời gian phiên theo mockup: `HH:mm dd/MM/yyyy`.
  String _formatSessionTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)} ${Formatters.formatDate(t)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: _titleBarColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: const Text(
            'Phiên Đấu Giá',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildItemImage(),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildCountdownCard(),
              const SizedBox(height: 16),
              _buildHistoryTable(),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 280,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _placeQuickBid,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _bidButtonColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Nút Đặt Giá Nhanh'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  /// Ảnh sản phẩm của phiên: khung gradient + tên sản phẩm và giá hiện tại.
  Widget _buildItemImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.smartphone_rounded,
              size: 84,
              color: Colors.white,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'iPhone 15 Pro Max 256GB',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  Formatters.formatCurrency(_currentBid),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ thông tin phiên: mã phiên, thời gian bắt đầu và kết thúc.
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _infoCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mã phiên: P001',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bắt đầu: ${_formatSessionTime(_startTime)}',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Kết thúc: ${_formatSessionTime(_endTime)}',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  /// Khung đếm ngược thời gian còn lại của phiên (cập nhật mỗi giây).
  Widget _buildCountdownCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: Column(
        children: [
          const Text(
            'Thời gian còn lại',
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            _formatCountdown(_remaining),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.black,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  /// Bảng lịch sử trả giá: dòng tiêu đề + các dòng người trả giá.
  Widget _buildHistoryTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            color: _tableHeaderColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Lịch sử trả giá',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  'Bid: ${Formatters.formatCurrency(_currentBid)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          for (final entry in _history) _buildHistoryRow(entry),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(_BidHistoryEntry entry) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black26)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF4A4A4A),
            child: Icon(Icons.person, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.bidder,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          Text(
            'Bid: ${Formatters.formatCurrency(entry.amount)}',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
