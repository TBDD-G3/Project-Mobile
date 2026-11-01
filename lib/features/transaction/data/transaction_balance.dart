import '../../../data/firestore/models/transaction.dart';
import '../../wallet/data/repositories/wallet_repository.dart';

/// Ảnh hưởng của một giao dịch lên số dư ví, dạng `walletId -> delta`.
/// - thu: cộng vào ví
/// - chi: trừ khỏi ví
/// - chuyển khoản: trừ ví nguồn, cộng ví đích
Map<String, double> _effectOf(Transaction? tx) {
  if (tx == null) return {};
  switch (tx.type) {
    case 'income':
      return {tx.walletId: tx.amount};
    case 'expense':
      return {tx.walletId: -tx.amount};
    case 'transfer':
      final result = <String, double>{tx.walletId: -tx.amount};
      final to = tx.toWalletId;
      if (to != null && to.isNotEmpty) {
        result[to] = (result[to] ?? 0.0) + tx.amount;
      }
      return result;
    default:
      return {};
  }
}

/// Độ lệch số dư cần áp lên từng ví khi một giao dịch đổi từ [before] sang [after].
/// - thêm mới: `before = null`
/// - xóa: `after = null`
/// - sửa: truyền cả hai (hoàn lại giao dịch cũ rồi áp giao dịch mới)
Map<String, double> balanceDeltas({Transaction? before, Transaction? after}) {
  final deltas = <String, double>{};
  _effectOf(after).forEach((id, v) => deltas[id] = (deltas[id] ?? 0.0) + v);
  _effectOf(before).forEach((id, v) => deltas[id] = (deltas[id] ?? 0.0) - v);
  deltas.removeWhere((_, v) => v.abs() < 1e-9);
  return deltas;
}

/// Áp các delta lên ví qua `WalletRepository.updateBalance`.
/// Nếu một ví lỗi thì hoàn lại các ví đã áp rồi ném lại lỗi.
Future<void> applyBalanceDeltas(
  WalletRepository wallets,
  Map<String, double> deltas,
) async {
  final applied = <String, double>{};
  try {
    for (final entry in deltas.entries) {
      await wallets.updateBalance(entry.key, entry.value);
      applied[entry.key] = entry.value;
    }
  } catch (_) {
    for (final entry in applied.entries) {
      try {
        await wallets.updateBalance(entry.key, -entry.value);
      } catch (_) {
        // Hoàn tác thất bại thì thôi, lỗi gốc mới là lỗi cần báo cho người dùng.
      }
    }
    rethrow;
  }
}
