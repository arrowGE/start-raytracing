// 点光源
class Light {
  Vec pos;         // 位置
  Spectrum power;  // パワー
  Light(Vec pos, Spectrum power) {
    this.pos = pos;
    this.power = power;
  }
}
