# TODO

## Minor Changes

- Support levels larger than 20x15.
- Save number of steps player made to complete a level and display it
  in level selection screen.

## Major Changes

- Better UI with support for mouse/keyboard/gamepad controls.
- Multiple player profiles (like in Zelda games).

## New Objects

### Portals

- Up to 3 pairs of portals (white, red blue), similar to Switch/Gate objects.
- An object (player, box, enemy, projectile etc.) moved inside a portal would
  appear on its other side.
- When there is already an object on the other side of a portal, objects on
  both sides get switched.
- Displayed as glowing floor tile with particle effects.

### Ice Floor

- Once an object makes a move on it, it keeps moving in the same direction
  until it's stopped by a solid object or moves onto a non-ice floor.
- Hitting movable object (e.g. box) will transfer the momentum (the same
  way billiard balls interact with each other).

### Rolling Boulder

- A round stone (weight: 2) that has the same movement mechanics as any
  other object on ice floor (keeps moving, transfers its momentum).
- Has rolling animation.
