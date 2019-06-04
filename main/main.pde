Scene scene = new Scene(); // シーン
Vec eye = new Vec(0, 0, 4); // 視点

void setup() {
  size(256, 256);//ウィンドウサイズ設定
  initScene();
}

int y = 0;

void draw() {//描画メイン
  for (int x = 0; x < width; x ++) {
    color c = calcPixelColor(x, y);//1ピクセルごとに色を計算
    set(x, y, c);
  }

  y ++;
  if (height <= y) {
    noLoop();
  }
}

// シーン構築
void initScene() {
  // 球
  Material mtlSphere = new Material(new Spectrum(0.9, 0.5, 0.1));
  mtlSphere.reflective = 0.6;
  scene.addIntersectable(new Sphere(
    new Vec(0, 0, 0),
    1,
    mtlSphere
  ));

  // チェック柄の床
  Material mtlFloor1 = new Material(new Spectrum(0.5, 0.5, 0.5));
  Material mtlFloor2 = new Material(new Spectrum(0.2, 0.2, 0.2));
  mtlFloor2.reflective = 0.8;
  scene.addIntersectable(new CheckedObj(
    new Plane(
      new Vec(0, -1, 0), // 位置
      new Vec(0, 1, 0), // 法線
      mtlFloor1 // 材質1
    ),
    1, // グリッド幅
    mtlFloor2 // 材質2
  ));

  // 点光源
  scene.addLight(new Light(
    new Vec(100, 100, 100), // 位置
    new Spectrum(800000, 800000, 800000) // パワー（光源色）
  ));
}


// 一次レイ(直接照明)を計算
Ray calcPrimaryRay(int x, int y) {
  float imagePlane = height;

  float dx =   x + 0.5 - width / 2;
  float dy = -(y + 0.5 - height / 2);
  float dz = -imagePlane;

  return new Ray(
    eye, // 始点
    new Vec(dx, dy, dz).normalize() // 方向
  );
}

// ピクセルの色を計算
color calcPixelColor(int x, int y) {
  Ray ray = calcPrimaryRay(x, y);//指定した座標に照射するレイを作成
  Spectrum l = scene.trace(ray, 0);//lにレイトレーシングを行った結果決定されたスペクトルが入る
  return l.toColor();
}
