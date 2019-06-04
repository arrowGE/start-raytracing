// 物体のインタフェース
interface Intersectable {
  Intersection intersect(Ray ray);
}

// 球
class Sphere implements Intersectable {
  Vec center;         // 中心座標
  float radius;       // 半径
  Material material;  // マテリアル

  Sphere(Vec center, float radius, Material material) {
    this.center   = center;
    this.radius   = radius;
    this.material = material;
  }

  Intersection intersect(Ray ray) {//交差判定
    Intersection isect = new Intersection();
    
    Vec v = ray.origin.sub(this.center);//v=球の中心からレイの始点に向かうベクトル
    
    float b = ray.dir.dot(v);//レイの方向ベクトルとvの内積
    float c = v.dot(v) - sq(this.radius);//v^2 - 半径の2乗
    float d = b * b - c;//判別式dの計算
    
    if (d >= 0) {//d>=0 つまりレイと球に交点があれば
      float s = sqrt(d);
      float t = -b - s;
      if (t <= 0) { t = -b + s; }
      if (0 < t) {
        isect.t = t;//レイの始点から交点までの距離を計算するのに用いる値
        isect.p = ray.origin.add(ray.dir.scale(t));//レイの始点から交点までのベクトル
        isect.n = isect.p.sub(this.center).normalize();//交点pの法線ベクトル
        isect.material = this.material;//球の材質
      }
    }
    return isect;
  }
}

// 無限平面
class Plane implements Intersectable {
  Vec n;              // 面法線 (a, b, c)
  float d;            // 原点からの距離 (平面の方程式 ax + by + cz + d = 0)
  Material material;  // マテリアル

  // 面法線n、点pを通る平面
  Plane(Vec p, Vec n, Material material) {
    this.n = n.normalize();
    this.d = -p.dot(this.n);
    this.material = material;
  }

  Intersection intersect(Ray ray) {
    Intersection isect = new Intersection();
    float v = this.n.dot(ray.dir);
    float t = -(this.n.dot(ray.origin) + this.d) / v;
    if (0 < t) {
      isect.t = t;
      isect.p = ray.origin.add(ray.dir.scale(t));
      isect.n = this.n;
      isect.material = this.material;
    }
    return isect;
  }
}

// チェック柄の物体
class CheckedObj implements Intersectable {
  Intersectable obj;  // 物体の形状・マテリアルその1
  float gridWidth;    // グリッドの幅
  Material material2; // マテリアルその2

  CheckedObj(Intersectable obj, float gridWidth, Material material2) {
    this.obj = obj;
    this.gridWidth = gridWidth;
    this.material2 = material2;
  }

  Intersection intersect(Ray ray) {//交差判定
    Intersection isect = obj.intersect(ray);//物体の形状はobjに格納されているのでそれと判定をとる

    if (isect.hit()) {
      int i;
      if(this.gridWidth % 2 == 0){//グリッド幅の偶奇で切り替えないと黒欠けが起きる(理由よくわかってない)
        i = (
          ceil(isect.p.x/this.gridWidth) +
          ceil(isect.p.y/this.gridWidth) +
          ceil(isect.p.z/this.gridWidth)
        );
      }else{
        i = (
          round(isect.p.x/this.gridWidth) +
          round(isect.p.y/this.gridWidth) +
          round(isect.p.z/this.gridWidth)
        );
      }   

      if (i % 2 == 0) {
        isect.material = this.material2;
      }
    }
    return isect;
  }
}
