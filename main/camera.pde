// カメラ
class Camera {
  Vec eye, origin, xaxis, yaxis;

  // 視点からある位置を向くように設定を行う
  void lookAt(Vec eye, Vec target, Vec up, float fov, int width, int height) {
    this.eye = eye;
    float imagePlane = (height / 2) / tan(fov / 2);
    Vec v = target.sub(eye).normalize();//視点から注視点への方向ベクトル
    
    xaxis = v.cross(up).normalize();//外積でx軸を求める
    yaxis = v.cross(xaxis);//x軸と外積を求めることでy軸を求める
    
    Vec center = v.scale(imagePlane);//画面中央へのベクトル
    
    origin = center.sub(xaxis.scale(0.5 * width))
                   .sub(yaxis.scale(0.5 * height));//スクリーンの左上へのベクトル
  }

  // スクリーン座標に対する一次レイを返す
  Ray ray(float x, float y) {
    Vec p = origin.add(xaxis.scale(x)).add(yaxis.scale(y));//スクリーン上のピクセルへのベクトル(一次レイの始点)
    Vec dir = p.normalize();
    return new Ray(eye, dir);
  }
}
