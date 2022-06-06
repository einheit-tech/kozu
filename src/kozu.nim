import shade
import kozupkg/king
import kozupkg/platform as platformModule

initEngineSingleton(
  "Physics Example",
  1920,
  1080,
  fullscreen = true,
  clearColor = newColor(91, 188, 228)
)

let layer = newPhysicsLayer(vector(0, 1200))
Game.scene.addLayer layer

# King
let player = createNewKing(vector(6, 6))
player.x = 1920 / 2
player.y = 640

# Track the player with the camera.
let camera = newCamera(player, 0.25, easeInAndOutQuadratic)
camera.z = -0.55
Game.scene.camera = camera

let
  (_, groundImage) = Images.loadImage("./assets/lowerGround.png")
  (_, plat1Image) = Images.loadImage("./assets/plat1.png")

# Ground
let
  halfGroundWidth = groundImage.w.float / 2
  halfGroundHeight = groundImage.h.float / 2
  halfplat1Width = plat1Image.w.float / 2
  halfplat1Height = plat1Image.h.float / 2

let groundBounds = newAABB(
  -halfGroundWidth, -halfGroundHeight * 0.5, halfGroundWidth, halfGroundHeight
)

let plat1Bounds = newAABB(
  -halfplat1Width + 10, -halfplat1Height * 0.5 - 12, halfplat1Width - 5, halfplat1Height - 15
)

let ground = newPlatform(groundImage, groundBounds)
let plat1 = newPlatform(plat1Image, plat1Bounds)

ground.x = 1920 / 2
ground.y = 1080 - groundBounds.height / 2

plat1.x = 1920 / 2
plat1.y = ground.y - 400

layer.addChild(player)
layer.addChild(ground)
layer.addChild(plat1)

# Custom physics handling for the player
const
  maxSpeed = 800.0
  acceleration = 100.0
  jumpForce = -750.0

proc physicsProcess(this: Node, deltaTime: float) =
  if Input.wasKeyJustPressed(K_ESCAPE):
    Game.stop()
    return

  let
    leftStickX = Input.leftStickX()
    leftPressed = Input.isKeyPressed(K_LEFT) or leftStickX < -0.01
    rightPressed = Input.isKeyPressed(K_RIGHT) or leftStickX > 0.01

  var
    x: float = player.velocityX
    y: float = player.velocityY

  proc run(x, y: var float) =
    ## Handles player running
    if leftPressed == rightPressed:
      player.playAnimation("idle")
      return

    let accel =
      if leftStickX == 0.0:
        acceleration
      else:
        acceleration * abs(leftStickX)

    if rightPressed:
      x = min(player.velocityX + accel, maxSpeed)
      if player.scale.x < 0.0:
        player.scale = vector(abs(player.scale.x), player.scale.y)
    else:
      x = max(player.velocityX - accel, -maxSpeed)
      if player.scale.y > 0.0:
        player.scale = vector(-1 * abs(player.scale.x), player.scale.y)

    player.playAnimation("run")

  proc jump() =
    if player.isOnGround and (
      Input.wasKeyJustPressed(K_SPACE) or Input.wasControllerButtonJustPressed(CONTROLLER_BUTTON_A)
    ):
      y += jumpForce

  proc friction() =
    x *= (1 - ground.collisionShape.material.friction)

  friction()
  run(x, y)
  jump()

  player.velocity = vector(x, y)

  camera.z += Input.wheelScrolledLastFrame.float * 0.03

player.onUpdate = physicsProcess

when not defined(debug):
  # Play some music
  let someSong = loadMusic("./assets/night_prowler.ogg")
  if someSong != nil:
    fadeInMusic(someSong, 2.0, 0.15)
  else:
    echo "Error playing music"

Game.start()


