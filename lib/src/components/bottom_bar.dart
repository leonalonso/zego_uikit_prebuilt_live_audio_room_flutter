// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil_zego/flutter_screenutil_zego.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/components.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/effects/sound_effect_button.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/leave_button.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/message/in_room_message_button.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/connect/connect_button.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/connect/defines.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/connect/host_lock_seat_button.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/minimizing/mini_button.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/minimizing/prebuilt_data.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/seat/seat_manager.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

class ZegoBottomBar extends StatefulWidget {
  final Size buttonSize;
  final double height;

  final bool isPluginEnabled;
  final ZegoLiveSeatManager seatManager;
  final ZegoLiveConnectManager connectManager;
  final ZegoLiveAudioRoomController? prebuiltController;
  final ZegoUIKitPrebuiltLiveAudioRoomConfig config;
  final ZegoAvatarBuilder? avatarBuilder;

  final ZegoUIKitPrebuiltLiveAudioRoomData prebuiltAudioRoomData;

  const ZegoBottomBar({
    Key? key,
    this.avatarBuilder,
    required this.config,
    required this.isPluginEnabled,
    required this.seatManager,
    required this.connectManager,
    required this.prebuiltController,
    required this.height,
    required this.buttonSize,
    required this.prebuiltAudioRoomData,
  }) : super(key: key);

  @override
  State<ZegoBottomBar> createState() => _ZegoBottomBarState();
}

class _ZegoBottomBarState extends State<ZegoBottomBar> {
  List<ZegoMenuBarButtonName> buttons = [];
  List<Widget> extendButtons = [];

  @override
  void initState() {
    super.initState();

    updateButtonsByRole();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      height: widget.height,
      child: Stack(
        children: [
          ValueListenableBuilder<ZegoLiveAudioRoomRole>(
            valueListenable: widget.seatManager.localRole,
            builder: (context, role, _) {
              updateButtonsByRole();

              return rightToolbar(context);
            },
          ),
          if (widget.config.bottomMenuBarConfig.showInRoomMessageButton)
            SizedBox(
              height: 124.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  zegoLiveButtonPadding,
                  ZegoInRoomMessageButton(
                    innerText: widget.config.innerText,
                  ),
                ],
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }

  Widget rightToolbar(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ValueListenableBuilder<bool>(
              valueListenable: widget.seatManager.isSeatLockedNotifier,
              builder: (context, isSeatLocked, _) {
                return ValueListenableBuilder<ZegoLiveAudioRoomRole>(
                    valueListenable: widget.seatManager.localRole,
                    builder: (context, localRole, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ...getDisplayButtons(
                              context, isSeatLocked, localRole),
                          zegoLiveButtonPadding,
                          zegoLiveButtonPadding,
                        ],
                      );
                    });
              }),
        ),
      ],
    );
  }

  List<Widget> getDisplayButtons(
    BuildContext context,
    bool isSeatLocked,
    ZegoLiveAudioRoomRole localRole,
  ) {
    final buttonList = <Widget>[
      ...getDefaultButtons(
        context,
        isSeatLocked: isSeatLocked,
        localRole: localRole,
        microphoneDefaultValueFunc: widget
                .prebuiltAudioRoomData.isPrebuiltFromMinimizing
            ? () {
                /// if is minimizing, take the local device state
                return ZegoUIKit()
                    .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
                    .value;
              }
            : null,
      ),
      ...extendButtons
    ];

    var displayButtonList = <Widget>[];
    if (buttonList.length > widget.config.bottomMenuBarConfig.maxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList = buttonList.sublist(
        0,
        widget.config.bottomMenuBarConfig.maxCount - 1,
      )..add(
          buttonWrapper(
            child: ZegoMoreButton(
              menuButtonListFunc: () {
                final buttonList = <Widget>[
                  ...getDefaultButtons(
                    context,
                    isSeatLocked: isSeatLocked,
                    localRole: localRole,
                    microphoneDefaultValueFunc: () {
                      return ZegoUIKit()
                          .getMicrophoneStateNotifier(
                              ZegoUIKit().getLocalUser().id)
                          .value;
                    },
                  ),
                  ...extendButtons
                ]..removeRange(
                    0, widget.config.bottomMenuBarConfig.maxCount - 1);
                return buttonList;
              },
              icon: ButtonIcon(
                icon: PrebuiltLiveAudioRoomImage.asset(
                    PrebuiltLiveAudioRoomIconUrls.toolbarMore),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        );
    } else {
      displayButtonList = buttonList;
    }

    final displayButtonsWithSpacing = <Widget>[];
    for (final button in displayButtonList) {
      displayButtonsWithSpacing
        ..add(button)
        ..add(zegoLiveButtonPadding);
    }

    return displayButtonsWithSpacing;
  }

  Widget buttonWrapper({required Widget child, ZegoMenuBarButtonName? type}) {
    var buttonSize = widget.buttonSize;
    switch (type) {
      case ZegoMenuBarButtonName.applyToTakeSeatButton:
        switch (widget.connectManager.audienceLocalConnectStateNotifier.value) {
          case ConnectState.idle:
            buttonSize = Size(330.r, 72.r);
            break;
          case ConnectState.connecting:
            buttonSize = Size(330.r, 72.r);
            break;
          case ConnectState.connected:
            buttonSize = Size(168.r, 72.r);
            break;
        }
        break;
      default:
        break;
    }

    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: child,
    );
  }

  List<Widget> getDefaultButtons(
    BuildContext context, {
    required bool isSeatLocked,
    required ZegoLiveAudioRoomRole localRole,
    bool Function()? microphoneDefaultValueFunc,
  }) {
    if (buttons.isEmpty) {
      return [];
    }

    return buttons
        .where((button) {
          if (isSeatLocked) {
            if (localRole != ZegoLiveAudioRoomRole.audience &&
                ZegoMenuBarButtonName.applyToTakeSeatButton == button) {
              /// if audience is on seat, then hide the applyToTakeSeatButton
              return false;
            }
            return true;
          }

          /// if seat is not locked, then hide the applyToTakeSeatButton
          return ZegoMenuBarButtonName.applyToTakeSeatButton != button;
        })
        .map((type) => buttonWrapper(
              child: generateDefaultButtonsByEnum(
                context,
                type,
                microphoneDefaultValueFunc: microphoneDefaultValueFunc,
              ),
              type: type,
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
    BuildContext context,
    ZegoMenuBarButtonName type, {
    bool Function()? microphoneDefaultValueFunc,
  }) {
    final buttonSize = zegoLiveButtonSize;
    final iconSize = zegoLiveButtonIconSize;

    switch (type) {
      case ZegoMenuBarButtonName.showMemberListButton:
        return ZegoMemberButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: PrebuiltLiveAudioRoomImage.asset(
                PrebuiltLiveAudioRoomIconUrls.toolbarMember),
            backgroundColor: Colors.white,
          ),
          avatarBuilder: widget.avatarBuilder,
          isPluginEnabled: widget.isPluginEnabled,
          seatManager: widget.seatManager,
          connectManager: widget.connectManager,
          innerText: widget.config.innerText,
          onMoreButtonPressed: widget.config.onMemberListMoreButtonPressed,
        );
      case ZegoMenuBarButtonName.toggleMicrophoneButton:
        var microphoneDefaultOn = widget.config.turnOnMicrophoneWhenJoining;
        final localUserID = ZegoUIKit().getLocalUser().id;
        if (widget.seatManager.isAttributeHost(ZegoUIKit().getLocalUser()) ||
            widget.seatManager.seatsUserMapNotifier.value.values
                .contains(localUserID)) {
          microphoneDefaultOn = true;
        }

        microphoneDefaultOn =
            microphoneDefaultValueFunc?.call() ?? microphoneDefaultOn;

        return ZegoToggleMicrophoneButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          normalIcon: ButtonIcon(
            icon: PrebuiltLiveAudioRoomImage.asset(
                PrebuiltLiveAudioRoomIconUrls.toolbarMicNormal),
            backgroundColor: Colors.white,
          ),
          offIcon: ButtonIcon(
            icon: PrebuiltLiveAudioRoomImage.asset(
                PrebuiltLiveAudioRoomIconUrls.toolbarMicOff),
            backgroundColor: Colors.white,
          ),
          defaultOn: microphoneDefaultOn,
        );
      case ZegoMenuBarButtonName.leaveButton:
        return ZegoLeaveAudioRoomButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: PrebuiltLiveAudioRoomImage.asset(
                PrebuiltLiveAudioRoomIconUrls.topQuit),
            backgroundColor: Colors.white,
          ),
          config: widget.config,
          seatManager: widget.seatManager,
        );
      case ZegoMenuBarButtonName.soundEffectButton:
        return ZegoSoundEffectButton(
          innerText: widget.config.innerText,
          voiceChangeEffect: widget.config.audioEffectConfig.voiceChangeEffect,
          reverbEffect: widget.config.audioEffectConfig.reverbEffect,
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: PrebuiltLiveAudioRoomImage.asset(
                PrebuiltLiveAudioRoomIconUrls.toolbarSoundEffect),
            backgroundColor: Colors.white,
          ),
        );
      case ZegoMenuBarButtonName.applyToTakeSeatButton:
        return ZegoAudienceConnectButton(
          seatManager: widget.seatManager,
          connectManager: widget.connectManager,
          innerText: widget.seatManager.innerText,
        );
      case ZegoMenuBarButtonName.closeSeatButton:
        return ZegoHostLockSeatButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          seatManager: widget.seatManager,
        );
      case ZegoMenuBarButtonName.minimizingButton:
        return ZegoUIKitPrebuiltLiveAudioRoomMinimizingButton(
          prebuiltAudioRoomData: widget.prebuiltAudioRoomData,
        );
    }
  }

  void updateButtonsByRole() {
    switch (widget.seatManager.localRole.value) {
      case ZegoLiveAudioRoomRole.host:
        buttons = widget.config.bottomMenuBarConfig.hostButtons;
        extendButtons = widget.config.bottomMenuBarConfig.hostExtendButtons;
        break;
      case ZegoLiveAudioRoomRole.speaker:
        buttons = widget.config.bottomMenuBarConfig.speakerButtons;
        extendButtons = widget.config.bottomMenuBarConfig.speakerExtendButtons;
        break;
      case ZegoLiveAudioRoomRole.audience:
        buttons = widget.config.bottomMenuBarConfig.audienceButtons;
        extendButtons = widget.config.bottomMenuBarConfig.audienceExtendButtons;
        break;
    }
  }
}
