import 'dart:async';
import 'dart:html';
import 'dart:math';

// import 'package:bliss_on_tap/control.dart';
// import 'package:bliss_on_tap/mountain.dart';
// import 'package:color/color.dart';
// import 'package:three/extras/renderers/.dart';
// import 'package:vector_math/vector_math.dart' hide Ray;
import 'package:threejs_facade/three.dart' hide tan;

const easeAmount = 0.05;
final sceneBackgroundColor = new Color(0x9de0ad);
const sceneFont = '100 132px Raleway';
// final control = Control(Point(0, 0));

num windowHalfX = window.innerWidth / 2;
num windowHalfY = window.innerHeight / 2;

final raycaster = Raycaster();
Object3D controlPlane = Mesh(PlaneGeometry(10000, 10000), MeshBasicMaterial())
  ..position.z = 50;

Element container;
PerspectiveCamera camera;
Scene scene;
WebGLRenderer renderer;
Material material;
CircleGeometry circle;
Mesh control;

// CanvasElement canvas;
bool isDragging = false;
Point mousePosition;
num dragHoldX;
num controlTargetX;
StreamSubscription mouseDownListener;
StreamSubscription mouseUpListener;
StreamSubscription mouseMoveListener;

Vector3 normalizedDeviceCoordinates(Point screenCoordinates) {
  return Vector3(
    (screenCoordinates.x / window.innerWidth) * 2 - 1,
    -(screenCoordinates.y / window.innerHeight) * 2 + 1,
    0,
  );
}

void main() {
  // print('test');
  if (document.readyState == ReadyState.COMPLETE) {
    onInit();
  } else {
    document.onReadyStateChange
        .where((_) => document.readyState == ReadyState.COMPLETE)
        .first
        .then((_) => onInit());
  }
}

void onInit() {
  container = Element.div();
  document.body.nodes.add(container);

  // canvas = querySelector('#canvas');
  // canvas.context2D.imageSmoothingEnabled = false;

  camera =
      PerspectiveCamera(75.0, window.innerWidth / window.innerHeight, 1, 10000);
  camera.position.z = 100.0;

  scene = Scene();
  scene.add(camera);

  renderer = WebGLRenderer(WebGLRendererParameters(antialias: true));
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setClearColor(sceneBackgroundColor, 1);
  container.nodes.add(renderer.domElement);

  material = MeshBasicMaterial(MeshBasicMaterialParameters(color: 0x594f4f));
  circle = CircleGeometry(5, 500);
  control = Mesh(circle, material);
  control.position.z = 50;
  scene.add(control);

  print('camera: ${camera.position.toArray()}');
  print('control: ${control.position.toArray()}');

  onResize();
  window.onResize.listen((_) => onResize());

  // Timer.periodic(const Duration(milliseconds: 1500), (timer) {
  //   control.position.x -= 5;
  //   control.position.y -= 5;
  //   print('${control.position.x}, ${control.position.y}');
  //   drawScene();
  // });

  mouseDownListener = document.onMouseDown.listen(onMouseDown);
}

void onResize() {
  // canvas.width = window.innerWidth;
  // canvas.height = window.innerHeight;
  // canvas.style.width = '${canvas.width}px';
  // canvas.style.height = '${canvas.height}px';

  windowHalfX = window.innerWidth / 2;
  windowHalfY = window.innerHeight / 2;

  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();

  renderer.setSize(window.innerWidth, window.innerHeight);

  // control.position.copy(Vector3(0.0, 0.0, 50));

  drawScene();
}

void onTimerTick(_) {
  // print('onTimerTick before: ${control.position.toArray()}');
  control.position.x += easeAmount * (controlTargetX - control.position.x);
  // print('onTimerTick after: ${control.position.toArray()}');

  drawScene();

  // Stop the timer when the target position is reached (close enough).
  if (isDragging && (control.position.x - controlTargetX).abs() > 0.001) {
    window.animationFrame.then(onTimerTick);
  }
}

void drawScene() {
  camera.lookAt(scene.position);
  renderer.render(scene, camera);
  // canvas.context2D.save();

  // Clear scene.
  // canvas.context2D.fillStyle = sceneBackgroundColor.toCssString();
  // canvas.context2D.fillRect(0, 0, canvas.width, canvas.height);

  // Draw control.
  // control.drawToContext(canvas.context2D);

  // Draw text.
  // canvas.context2D.font = sceneFont;
  // canvas.context2D.fillStyle = 'white';
  // canvas.context2D.textAlign = 'center';
  // canvas.context2D
  //     .fillText('BLISS ON TAP', canvas.width / 2, canvas.height / 3);

  // Draw background mountains.
  // for (final mountain in defaultMountains) {
  //   // Used for parallaxing.
  //   final offsetX = (control.position.x - (canvas.width / 2)) * mountain.speed;
  //   canvas.context2D.beginPath();
  //   // Scale to 1000x1000.
  //   final scale = Point(canvas.width / 1000, canvas.height / 1000);
  //   canvas.context2D.moveTo(
  //     offsetX + (mountain.points.first.x * scale.x),
  //     mountain.points.first.y * scale.y,
  //   );
  //   for (final point in mountain.points) {
  //     canvas.context2D.lineTo(offsetX + (point.x * scale.x), point.y * scale.y);
  //   }
  //   canvas.context2D.lineTo(offsetX + (1500 * scale.x), 1500 * scale.y);
  //   canvas.context2D.closePath();
  //   canvas.context2D.fillStyle = mountain.color.toCssString();
  //   canvas.context2D.fill();
  // }

  // canvas.context2D.restore();
}

bool onMouseDown(MouseEvent event) {
  raycaster.setFromCamera(normalizedDeviceCoordinates(event.client), camera);
  final controlIntersections = raycaster.intersectObject(control);

  for (final intersect in controlIntersections) {
    if (intersect.object == control) {
      print('hit!');
      // Hit control!
      isDragging = true;

      // Pay attention to the point on the object where the mouse is "holding on".
      dragHoldX = intersect.point.sub(control.position).x;
      controlTargetX = intersect.point.x;

      // Start animating.
      window.animationFrame.then(onTimerTick);
    }
  }

  if (isDragging) {
    mouseMoveListener = window.onMouseMove.listen(onMouseMove);
  }

  mouseDownListener?.cancel();
  mouseUpListener = window.onMouseUp.listen(onMouseUp);

  // Prevent mouse down from having an effect on the main browser window.
  event.preventDefault();
  return false;
}

void onMouseUp(MouseEvent _) {
  print('mouse up');
  mouseDownListener = document.onMouseDown.listen(onMouseDown);
  mouseUpListener?.cancel();
  if (isDragging) {
    isDragging = false;
    mouseMoveListener?.cancel();
  }
}

void onMouseMove(MouseEvent event) {
  print('mouse move');

  raycaster.setFromCamera(normalizedDeviceCoordinates(event.client), camera);
  final planeIntersection = raycaster.intersectObject(controlPlane);

  // Clamp x and y positions to prevent object from dragging outside of canvas.
  if (planeIntersection.isNotEmpty) {
    var intersection = planeIntersection.first;
    var positionX = intersection.point.x; // - dragHoldX;

    var fov = degToRad(camera.fov);
    var height = tan(fov / 2) * 50;
    var width = height * camera.aspect;

    // print(Vector3(-1, -1, 50).unproject(camera).toArray());
    // print('onMouseMove before: ${control.position}');

    // print('nearWidth: $nearWidth, farWidth: $farWidth');

    controlTargetX = positionX; //.clamp(-width, width);

    // control.position.x = positionX.clamp(
    //   (camera. * 1 / 4) - circle.parameters.radius,
    //   (window.innerWidth * 3 / 4) + circle.parameters.radius,
    // );
    // print('onMouseMove after: ${control.position}');
  }
}

// Width: -103, 103
// Height: -76, 76
