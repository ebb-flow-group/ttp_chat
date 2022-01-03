import 'package:collection/src/iterable_extensions.dart';
import 'package:rive/rive.dart';

class RiveAnimController extends RiveAnimationController<RuntimeArtboard> {
  final String animationName;

  LinearAnimationInstance? _anim;

  RiveAnimController(this.animationName);

  @override
  bool init(RuntimeArtboard artboard) {
    _anim = getInstance(artboard, animationName: animationName);

    isActive = true;
    return _anim != null;
  }

  @override
  void apply(RuntimeArtboard artboard, double elapsedSeconds) {
    // Idle animation
    _anim!.animation.apply(_anim!.time, coreContext: artboard);
    _anim!.advance(elapsedSeconds);
  }

  void stop() {}

  void play() {
    _anim!.time = 0;
    isActive = true;
  }

  @override
  void dispose() {}

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}

  LinearAnimationInstance? getInstance(RuntimeArtboard artboard, {String? animationName}) {
    var animation = artboard.animations.firstWhereOrNull(
          (animation) => animation is LinearAnimation && animation.name == animationName,
    );
    if (animation != null) {
      return LinearAnimationInstance(animation as LinearAnimation);
    }
    return null;
  }
}