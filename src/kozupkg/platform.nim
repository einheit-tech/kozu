import shade

type Platform* = ref object of PhysicsBody
  sprite*: Sprite

proc newPlatform*(image: Image, bounds: AABB): Platform = 
  result = Platform(kind: PhysicsBodyKind.STATIC)
  initPhysicsBody(PhysicsBody(result))
  result.sprite = newSprite(image)
  result.collisionShape = newCollisionShape(bounds) 
  result.collisionShape.material = material.PLATFORM

Platform.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)
