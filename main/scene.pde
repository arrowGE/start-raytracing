final int DEPTH_MAX = 10; // トレースの最大回数
final float VACUUM_REFRACTIVE_INDEX = 1.0; // 真空の屈折率
final Spectrum COLOR_SKY = new Spectrum(0.7, 0.7, 0.7); //空の色

// シーン
class Scene {
  // シーン内の物体・光源を格納するArrayListを定義
  ArrayList<Intersectable> objList = new ArrayList<Intersectable>();
  ArrayList<Light> lightList = new ArrayList<Light>();
  
  Spectrum skyColor = BLACK;
  
  Scene() {}
  
  // 空の色を決める
  void setSkyColor(Spectrum c) {
    this.skyColor = c;
  }

  // 形状の追加
  void addIntersectable(Intersectable obj) {
    this.objList.add(obj);
  }

  // 光源の追加
  void addLight(Light light) {
    this.lightList.add(light);
  }

  /*// レイを撃って色を求める(レイトレーシング)
  Spectrum trace(Ray ray, int depth) {
    // トレースの最大回数に達した場合は計算を中断する
    if (DEPTH_MAX < depth) { return BLACK; }

    // 最も近いオブジェクトとの交点を求める
    Intersection isect = this.findNearestIntersection(ray);
    if (!isect.hit()) { return BLACK; }//どのオブジェクトとも交差していなければ黒

    Material m = isect.material;//交差したオブジェクトの材質
    Spectrum l = BLACK; // ここに最終的な計算結果が入る


    if(isect.n.dot(ray.dir) < 0){// 物体に外側から接触したとき=空気中から物体に入射したとき
      
      // 鏡面反射成分
      float ks = m.reflective;//どれくらいが正反射するか
      if (0 < ks) {//マテリアルが鏡面反射を起こすとき
        Vec r = ray.dir.reflect(isect.n); // 反射レイを導出
        Spectrum c = trace(new Ray(isect.p, r), depth + 1); // 反射点からレイを飛ばしてレイトレーシング
        l = l.add(c.scale(ks).mul(m.diffuse)); // 計算結果に鏡面反射成分を足す
      }
      
      // 屈折成分
      float kt = m.refractive;
      if (0 < kt) {
        Vec r = ray.dir.refract(isect.n, VACUUM_REFRACTIVE_INDEX / m.refractiveIndex); // 屈折レイを導出
        Spectrum c = trace(new Ray(isect.p, r), depth + 1); // 屈折レイを飛ばす
        l = l.add(c.scale(kt).mul(m.diffuse)); // 計算結果に屈折成分を足す
      }


      // 拡散反射成分
      float kd = 1.0 - ks - kt;//正反射(鏡面反射)しなかった分と屈折しなかった分は拡散反射になる
      if (0 < kd) {
        Spectrum c = this.lighting(isect.p, isect.n, isect.material); // 拡散反射面の光源計算を行う
        l = l.add(c.scale(kd)); // 計算結果に拡散反射成分を足す
      }
      
    }else { //物体の内側からレイが飛び出していくとき
      Vec r = ray.dir.refract(isect.n.neg(), m.refractiveIndex / VACUUM_REFRACTIVE_INDEX); // 屈折レイを導出
      l = trace(new Ray(isect.p, r), depth + 1); // 屈折レイを飛ばす
    }
    
    

    return l;
  }*/
  
  // 交点からのレイの方向を求め追跡する
  Spectrum interactSurface(Vec rayDir, Vec p, Vec n, Material m, float eta, int depth) {
    float ks = m.reflective;
    float kt = m.refractive;

    float t = random(0.0, 1.0);//乱数(0~1.0)
    
    if (t < ks) {              // 鏡面反射
      Vec r = rayDir.reflect(n); // 反射レイを導出
      Spectrum c = trace(new Ray(p, r), depth + 1);//交点を始点とし反射方向でトレース
      return c.mul(m.diffuse);
    } else if (t < ks + kt) {  // 屈折
      Vec r = rayDir.refract(n, eta); // 屈折レイを導出
      Spectrum c = trace(new Ray(p, r), depth + 1);//交点を始点とし屈折方向でトレース
      return c.mul(m.diffuse);
    } else {                   // 拡散反射
      Vec r = n.randomHemisphere();
      Spectrum li = trace(new Ray(p, r), depth + 1);

      Spectrum fr = m.diffuse.scale(1.0 / PI);
      float factor = 2.0 * PI * n.dot(r);
      Spectrum l = li.mul(fr).scale(factor);

      return l;
    }
  }
  
    // レイを撃って色を求める
  Spectrum trace(Ray ray, int depth) {
    // トレースの最大回数に達した場合は計算を中断する
    if (DEPTH_MAX < depth) { return BLACK; }

    // 交点を求める
    Intersection isect = this.findNearestIntersection(ray);

    // 物体と交差しなかった場合は空の色を返す
    if (!isect.hit()) { return this.skyColor; }

    Material m = isect.material;
    float dot = isect.n.dot(ray.dir);//法線とレイの内積

    if (dot < 0) { // 物体に外側から接触したとき=空気中から物体に入射したとき
      Spectrum col = interactSurface(ray.dir, isect.p, isect.n, m, VACUUM_REFRACTIVE_INDEX / m.refractiveIndex, depth);
      return col.add(m.emissive.scale(-dot));

    } else { //物体の内側からレイが飛び出していくとき
      return interactSurface(ray.dir, isect.p, isect.n.neg(), m, m.refractiveIndex / VACUUM_REFRACTIVE_INDEX, depth);
    }
  }
  
  /*// レイを撃って色を求める(パストレーシング)
  Spectrum trace(Ray ray, int depth) {
    // トレースの最大回数に達した場合は計算を中断する
    if (DEPTH_MAX < depth) { return BLACK; }

    // 交点を求める
    Intersection isect = this.findNearestIntersection(ray);

    // [1] 物体と交差しなかった場合は空の色を返す
    if (!isect.hit()) { return COLOR_SKY; }

    Material m = isect.material;

    // [2] 反射方向を求め、反射レイを飛ばす
    Vec r = isect.n.randomHemisphere();
    Spectrum li = trace(new Ray(isect.p, r), depth + 1);

    // [3] 計算結果への影響度合いを計算する
    Spectrum fr = m.diffuse.scale(1.0 / PI);
    float factor = 2.0 * PI * isect.n.dot(r);
    Spectrum l = li.mul(fr).scale(factor);

    return l;
  }*/

  // 一番近くの交点を求める
  Intersection findNearestIntersection(Ray ray) {
    Intersection isect = new Intersection();
    for (int i = 0; i < this.objList.size(); i ++) {
      Intersectable obj = this.objList.get(i);//objListから交差判定を行うオブジェクトを1つ取り出す
      Intersection tisect = obj.intersect(ray);//取り出したオブジェクトとレイの交差判定を行う
      if ( tisect.t < isect.t ) { isect = tisect; }//レイと交差したオブジェクトのうち、最も手前にあるものをisectに入れる
    }
    return isect;
  }

  // 光源計算を行う
  Spectrum lighting(Vec p, Vec n, Material m) {
    Spectrum L = BLACK;
    for (int i = 0; i < this.lightList.size(); i ++) {
      Light light = this.lightList.get(i);
      Spectrum c = this.diffuseLighting(p, n, m.diffuse, light.pos, light.power);
      L = L.add(c);
    }
    return L;
  }

  // 拡散反射面の光源計算
  Spectrum diffuseLighting(Vec p, Vec n, Spectrum diffuseColor,
                           Vec lightPos, Spectrum lightPower) {
    Vec v = lightPos.sub(p);//v=レイとの交点pから光源へ向かうベクトル
    Vec l = v.normalize();//l = vの方向ベクトル
    float dot = n.dot(l);//交点の法線との内積をとる
    if (dot > 0) {//内積>0、つまり面が光源を向いていれば
      // 交点と光源の間にさえぎるものがないか調べる
      if (visible(p, lightPos)) {
        float r = v.len();//交点と光源の距離
        float factor = dot / (4 * PI * r * r);//距離による減衰を計算
        return lightPower.scale(factor).mul(diffuseColor);//オブジェクトのマテリアルと乗算して色を決定する
      }
    }
    return BLACK;
  }

  boolean visible(Vec org, Vec target) {
    Vec v = target.sub(org);//交点から光源へのベクトル
    Vec l = v.normalize();//交点から光源への方向ベクトル
    // シャドウレイを求める
    Ray shadowRay = new Ray(org.add(l.scale(EPSILON)), l);//交点から光源に向かってレイを投射する。このときεを足すことでレイの始点がオブジェクトにめり込むのを回避する
    for (int i = 0; i < this.objList.size(); i ++) {//新たに投射したレイがほかのオブジェクトと交差するか調べる
      Intersectable obj = this.objList.get(i);
      // 交差が判明した時点で処理を打ち切る
      if (obj.intersect(shadowRay).t < v.len()) { return false; }//tの初期値はNO_HITなので、ヒットした時点で何かしらの値がはいる
    }
    // シーン中のどの物体ともシャドウレイが交差しない場合にのみtrueを返す
    return true;
  }
}
