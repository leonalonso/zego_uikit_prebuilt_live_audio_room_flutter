// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/seat/seat_manager.dart';

class ZegoHostLockSeatButton extends StatefulWidget {
  final Size? iconSize;
  final Size? buttonSize;
  final ZegoLiveSeatManager seatManager;

  const ZegoHostLockSeatButton({
    Key? key,
    required this.seatManager,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  @override
  State<ZegoHostLockSeatButton> createState() => _ZegoHostLockSeatButtonState();
}

class _ZegoHostLockSeatButtonState extends State<ZegoHostLockSeatButton> {
  var voiceChangerSelectedIDNotifier = ValueNotifier<String>('');
  var reverbSelectedIDNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    final sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);
    return GestureDetector(
      onTap: () async {
        widget.seatManager.lockSeat(
          !widget.seatManager.isSeatLockedNotifier.value,
        );
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: ValueListenableBuilder<bool>(
              valueListenable: widget.seatManager.isSeatLockedNotifier,
              builder: (context, isSeatLocked, _) {
                return PrebuiltLiveAudioRoomImage.asset(
                  isSeatLocked
                      ? PrebuiltLiveAudioRoomIconUrls.toolbarHostUnLockSeat
                      : PrebuiltLiveAudioRoomIconUrls.toolbarHostLockSeat,
                );
              }),
        ),
      ),
    );
  }
}
