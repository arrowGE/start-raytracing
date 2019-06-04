final float EPSILON = 0.001; // 微小距離

class Ray {
  Vec origin; // 始点
  Vec dir;    // 方向（単位ベクトル）

  Ray(Vec origin, Vec dir) {
    this.dir = dir.normalize(); //方向ベクトルは正規化する
    this.origin = origin.add(this.dir.scale(EPSILON)); //めり込み防止のために微小距離を足した位置を始点とする
  }
}
