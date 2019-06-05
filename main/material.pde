// マテリアル
class Material {
  Spectrum diffuse;  // 物体の拡散反射色
  float reflective; // 鏡面反射率
  float refractive = 0; // 屈折割合 半透明度
  float refractiveIndex = 1; // 屈折率 絶対屈折率

  Material(Spectrum diffuse) {
    this.diffuse = diffuse;
  }
}
