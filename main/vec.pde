class Vec {
  // メンバ変数
  float x, y, z;

  // コンストラクタ
  Vec(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  // ベクトル同士の加算
  Vec add(Vec v) {
    return new Vec(this.x + v.x, this.y + v.y, this.z + v.z);
  }

  // ベクトル同士の減算
  Vec sub(Vec v) {
    return new Vec(this.x - v.x, this.y - v.y, this.z - v.z);
  }

  // ベクトルの定数倍
  Vec scale(float s) {
    return new Vec(this.x * s, this.y * s, this.z * s);
  }
  
  // 逆向きのベクトルを返す
  Vec neg() {
    return new Vec(-this.x, -this.y, -this.z);
  }

  // ベクトルの長さを返す
  float len() {
    return sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
  }

  // 正規化（単位ベクトル化）したベクトルを返す
  Vec normalize() {
    return scale(1.0 / len());
  }

  // 内積
  float dot(Vec v) {
    return this.x * v.x + this.y * v.y + this.z * v.z;
  }

  // 外積
  Vec cross(Vec v) {
    return new Vec(this.y * v.z - v.y * this.z,
                   this.z * v.x - v.z * this.x,
                   this.x * v.y - v.x * this.y);
  }

  // 反射
  Vec reflect(Vec n) {
    return this.sub(n.scale(2 * this.dot(n)));
  }
  
  // 屈折
  Vec refract(Vec n, float eta) {
    float dot = this.dot(n);
    float d = 1.0 - sq(eta) * (1.0 - sq(dot));
    if (0 < d) {
      Vec a = this.sub(n.scale(dot)).scale(eta);
      Vec b = n.scale(sqrt(d));
      return a.sub(b);
    }
    return this.reflect(n); // 全反射
  }
  
  // 半球上のランダムな方向を選択する
  Vec randomHemisphere() {
    Vec dir = new Vec(0.0, 0.0, 0.0);

    // [1] 無限ループ、念のため100回で打ち切る
    for (int i = 0; i < 100; i ++) {
      // [2] 立方体内部のランダムな点を決定する
      dir = new Vec(
        random(-1.0, 1.0),
        random(-1.0, 1.0),
        random(-1.0, 1.0)
      );

      // [3] 半径1の球内部であればその点を採用しループを抜ける
      if (dir.len() < 1.0) { break; }
    }

    // [4] 正規化し、方向を求める
    dir = dir.normalize();

    // [5] 法線方向の半球上に合わせる
    if (dir.dot(this) < 0) { dir = dir.neg(); }

    return dir;
  }


  // ベクトルを文字列として返す
  String toString() {
    return "Vec(" + this.x + ", " + this.y + ", " + this.z + ")";
  }
}
