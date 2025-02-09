import 'package:country_flags/country_flags.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkDetection extends StatefulWidget {
  const NetworkDetection({super.key});

  @override
  State<NetworkDetection> createState() => _NetworkDetectionState();
}

class _NetworkDetectionState extends State<NetworkDetection> {
  final ipInfoNotifier = ValueNotifier<IpInfo?>(null);
  final timeoutNotifier = ValueNotifier<bool>(false);
  bool? _preIsStart;
  Function? _checkIpDebounce;

  _checkIp() async {
    final appState = globalState.appController.appState;
    final isInit = appState.isInit;
    final isStart = appState.isStart;
    if (!isInit) return;
    timeoutNotifier.value = false;
    if (_preIsStart == false && _preIsStart == isStart) return;
    _preIsStart = isStart;
    ipInfoNotifier.value = null;
    final ipInfo = await request.checkIp();
    if (ipInfo == null) {
      timeoutNotifier.value = true;
      return;
    } else {
      timeoutNotifier.value = false;
    }
    ipInfoNotifier.value = ipInfo;
  }

  _checkIpContainer(Widget child) {
    return Selector<AppState, num>(
      selector: (_, appState) {
        return appState.checkIpNum;
      },
      builder: (_, checkIpNum, child) {
        if (_checkIpDebounce != null) {
          _checkIpDebounce!();
        }
        return child!;
      },
      child: child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    ipInfoNotifier.dispose();
    timeoutNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkIpDebounce = debounce(_checkIp);
    return _checkIpContainer(
      ValueListenableBuilder<IpInfo?>(
        valueListenable: ipInfoNotifier,
        builder: (_, ipInfo, __) {
          return CommonCard(
            onPressed: () {},
            child: Column(
              children: [
                Flexible(
                  flex: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.network_check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          flex: 1,
                          child: FadeBox(
                            child: ipInfo != null
                                ? CountryFlag.fromCountryCode(
                                    ipInfo.countryCode,
                                    width: 24,
                                    height: 24,
                                  )
                                : ValueListenableBuilder(
                                    valueListenable: timeoutNotifier,
                                    builder: (_, timeout, __) {
                                      if (timeout) {
                                        return Text(
                                          appLocalizations.checkError,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      }
                                      return TooltipText(
                                        text: Text(
                                          appLocalizations.checking,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: globalState.appController.measure.titleLargeHeight +
                      24 -
                      2,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16).copyWith(top: 0),
                  child: FadeBox(
                    child: ipInfo != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                flex: 1,
                                child: TooltipText(
                                  text: Text(
                                    ipInfo.ip,
                                    style: context.textTheme.titleLarge
                                        ?.toSoftBold.toMinus,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ValueListenableBuilder(
                            valueListenable: timeoutNotifier,
                            builder: (_, timeout, __) {
                              if (timeout) {
                                return Text(
                                  "timeout",
                                  style: context.textTheme.titleLarge
                                      ?.copyWith(color: Colors.red)
                                      .toSoftBold
                                      .toMinus,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Container(
                                padding: const EdgeInsets.all(2),
                                child: const AspectRatio(
                                  aspectRatio: 1,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
