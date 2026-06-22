import 'dart:math';

class AttendanceMath {
  /// Menghitung Euclidean Distance antara dua array float 128 dimensi
  static double calculateEuclideanDistance(List<double> vectorA, List<double> vectorB) {
    if (vectorA.length != vectorB.length) {
      throw ArgumentError('Panjang descriptor wajah tidak sama');
    }
    double sum = 0.0;
    for (int i = 0; i < vectorA.length; i++) {
      final diff = vectorA[i] - vectorB[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  /// Menghitung jarak lingkaran besar Haversine antara dua titik koordinat bumi (dalam meter)
  static double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double r = 6371000.0; // Radius Bumi dalam meter
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }
}
