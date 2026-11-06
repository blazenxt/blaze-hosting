import 'package:flutter/material.dart';

import 'update_service.dart';

class UpdateGate extends StatefulWidget {
  const UpdateGate({
    super.key,
    required this.service,
    required this.child,
  });

  final UpdateService service;
  final Widget child;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  UpdateOffer? _offer;
  var _busy = false;
  var _progress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offer = widget.service.offer();
      if (offer != null && mounted) {
        setState(() => _offer = offer);
        _show(offer);
      }
    });
  }

  Future<void> _show(UpdateOffer offer) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !offer.force,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1917),
              title: Text(
                offer.force ? 'Update required' : 'Update available',
                style: const TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blaze Hosting ${offer.current} → ${offer.channel.latest} (${offer.platformName})',
                    style: const TextStyle(color: Color(0xFFD6D3D1)),
                  ),
                  if ((offer.channel.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(offer.channel.notes!, style: const TextStyle(color: Color(0xFFA8A29E))),
                  ],
                  if (_busy) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _progress <= 0 ? null : _progress,
                      color: const Color(0xFFF97316),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _progress <= 0
                          ? 'Starting download…'
                          : 'Downloading ${(100 * _progress).clamp(0, 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Color(0xFFA8A29E), fontSize: 12),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Color(0xFFF87171), fontSize: 13)),
                  ],
                ],
              ),
              actions: [
                if (!offer.force && !_busy)
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      setState(() => _offer = null);
                    },
                    child: const Text('Later'),
                  ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
                  onPressed: _busy
                      ? null
                      : () async {
                          setLocal(() {
                            _busy = true;
                            _error = null;
                            _progress = 0;
                          });
                          try {
                            await widget.service.apply(offer, (r, t) {
                              setLocal(() => _progress = t <= 0 ? 0 : r / t);
                            });
                          } catch (e) {
                            setLocal(() {
                              _busy = false;
                              _error = e.toString().replaceFirst('StateError: ', '');
                            });
                          }
                        },
                  child: Text(_busy ? 'Installing…' : 'Update now'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
