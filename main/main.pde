Scene scene = new Scene(); // シーン
PImage imageTest;

// [1] サンプル数を定義
final int SAMPLES = 10000;

Camera camera = new Camera();

void setup() {
  size(256, 256);//ウィンドウサイズ設定
  // 画像の読み込み
  imageTest = loadImage( "images/neko.png" );
  initScene();
  initCamera();
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
  // 空の色
  scene.setSkyColor(new Spectrum(0.6, 0.65, 0.7));
  //scene.setSkyColor(new Spectrum(0.0,0.0,0.0));

  // 球
  Material mtl1 = new Material(new Spectrum(0.7, 0.3, 0.9));
  scene.addIntersectable(new Sphere(
    new Vec(-2.2, 0, 0),
    1,
    mtl1
  ));

  Material mtl2 = new Material(new Spectrum(0.9, 0.7, 0.3));
  mtl2.reflective = 0.8;
  scene.addIntersectable(new Sphere(
    new Vec(0, 0, 0),
    1,
    mtl2
  ));

  Material mtl3 = new Material(new Spectrum(0.3, 0.9, 0.7));
  mtl3.refractive = 0.8;
  mtl3.refractiveIndex = 1.5;
  scene.addIntersectable(new Sphere(
    new Vec(2.2, 0, 0),
    1,
    mtl3
  ));

  // 光源
  Material mtlLight = new Material(new Spectrum(0.0, 0.0, 0.0));
  mtlLight.emissive = new Spectrum(30.0, 20.0, 10.0);
  scene.addIntersectable(new Sphere(
    new Vec(0, 4.0, 0),
    1,
    mtlLight
  ));

  // チェック柄の床
  Material mtlFloor1 = new Material(new Spectrum(0.9, 0.9, 0.9));
  Material mtlFloor2 = new Material(new Spectrum(0.4, 0.4, 0.4));
  scene.addIntersectable(new CheckedObj(
    new Plane(
      new Vec(0, -1, 0), // 位置
      new Vec(0, 1, 0), // 法線
      mtlFloor1 // 材質1
    ),
    1, // グリッド幅
    mtlFloor2 // 材質2
  ));
}

// カメラ設定
void initCamera() {
  // カメラの設定
  camera.lookAt(
    new Vec(0.0, 0.0, 9.0), // 視点
    new Vec(0.0, 0.0, 0.0), // 注視点
    new Vec(0.0, 1.0, 0.0), // 上方向
    radians(40.0),          // 視野角
    width,
    height
  );
}

Ray calcPrimaryRay(float x, float y) {
  // カメラを用いて一次レイを求める
  return camera.ray(
    x + random(-0.5, 0.5),
    y + random(-0.5, 0.5)
  );
}

/*// 一次レイ(直接照明)を計算
Ray calcPrimaryRay(int x, int y) {
  float imagePlane = height;

  float dx =   x + 0.5 - width / 2;
  float dy = -(y + 0.5 - height / 2);
  float dz = -imagePlane;

  return new Ray(
    eye, // 始点
    new Vec(dx, dy, dz).normalize() // 方向
  );
}*/

/*// 一次レイを計算(アンチエイリアシング)
Ray calcPrimaryRay(int x, int y) {
  float imagePlane = height;

  float dx =   x + random(0.0, 1.0) - width / 2;//レイの投射方向をピクセルの中心ではなく乱数で決める
  float dy = -(y + random(0.0, 1.0) - height / 2);
  float dz = -imagePlane;

  return new Ray(
    eye, // 始点
    new Vec(dx, dy, dz).normalize() // 方向
  );
}*/

/*// ピクセルの色を計算(レイトレーシング)
color calcPixelColor(int x, int y) {
  Ray ray = calcPrimaryRay(x, y);//指定した座標に照射するレイを作成
  Spectrum l = scene.trace(ray, 0);//lにレイトレーシングを行った結果決定されたスペクトルが入る
  return l.toColor();
}*/

// ピクセルの色を計算(パストレーシング)
color calcPixelColor(int x, int y) {
  // [2] sumに計算結果の和を格納する
  Spectrum sum = BLACK;

  for (int i = 0; i < SAMPLES; i ++) {
    // [3] レイを飛ばし、計算結果をsumに足す
    Ray ray = calcPrimaryRay(x, y);
    sum = sum.add(scene.trace(ray, 0));
  }

  // [4] sumをサンプル数で割り、計算結果の平均を求める
  return sum.scale(1.0 / SAMPLES).toColor();
}



// ファイル名の連番で利用
int count = 1;

void keyPressed() {

  // Pのキーが入力された時に保存
  if(key == 'p' || key == 'P') {

    // デスクトップのパスを取得
    String path  = System.getProperty("user.home") + "/Desktop/screenshot" + count + ".jpg";

    // 保存
    save(path);

    // 番号を加算
    count++;

    // ログ用途
    println("screen saved." + path); 
  }
}
