// 衝突していないことを表す定数
final float NO_HIT = Float.POSITIVE_INFINITY;

// 交差情報
class Intersection {
  float t = NO_HIT;   // 交差点までの距離
  Vec p;              // 交差点
  Vec n;              // 法線
  Material material;  // マテリアル

  Intersection() {}

  boolean hit() { return this.t != NO_HIT; }
}
