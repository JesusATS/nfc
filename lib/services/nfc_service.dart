import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../exceptions/app_exception.dart';

class NFCService {
  static Future<String> readCard(BuildContext context) async {
    final completer = Completer<String>();

    NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
      },
      onDiscovered: (NfcTag tag) async {
        try {
          List<int>? identifier;
          final tagData = tag.data;

          if (tagData is Map) {
            // MODO CLÁSICO (Librería 3.3.0)
            final techKeys = ['nfca', 'mifare', 'mifareclassic', 'mifareultralight', 'nfcb', 'nfcf', 'nfcv', 'iso15693'];
            for (var key in techKeys) {
              if (tagData.containsKey(key) && tagData[key] is Map && tagData[key].containsKey('identifier')) {
                final idCrudo = tagData[key]['identifier'];
                if (idCrudo is List) {
                  identifier = idCrudo.map((e) => int.parse(e.toString())).toList();
                  break;
                }
              }
            }
          } else {
            // MODO TAGPIGEON (Librería 4.0+) - Red de arrastre total
            dynamic p = tag.data;
            try { identifier ??= List<int>.from(p.nfca.identifier); } catch(_) {}
            try { identifier ??= List<int>.from(p.nfcb.identifier); } catch(_) {}
            try { identifier ??= List<int>.from(p.nfcf.identifier); } catch(_) {}
            try { identifier ??= List<int>.from(p.nfcv.identifier); } catch(_) {}
            try { identifier ??= List<int>.from(p.iso15693.identifier); } catch(_) {}
            try { identifier ??= List<int>.from(p.mifare.identifier); } catch(_) {}
            try { identifier ??= List<int>.from(p.mifareclassic.identifier); } catch(_) {}
            try { identifier ??= List<int>.from(p.mifareultralight.identifier); } catch(_) {}
            // Algunas versiones de TagPigeon exponen el ID directamente en la raíz:
            try { identifier ??= List<int>.from(p.id); } catch(_) {} 
          }

          if (identifier != null && identifier.isNotEmpty) {
            final idTarjeta = identifier
                .map((e) => e.toRadixString(16).padLeft(2, '0'))
                .join(':')
                .toUpperCase();
            completer.complete(idTarjeta);
          } else {
            // Este mensaje nos dirá exactamente si Flutter sigue terco usando TagPigeon
            completer.completeError(
              NFCException(message: 'UID no encontrado. (Es mapa: ${tagData is Map}).'),
            );
          }
        } catch (e) {
          completer.completeError(
            NFCException(message: 'Error al procesar la tarjeta: $e', originalError: e),
          );
        } finally {
          NfcManager.instance.stopSession();
        }
      },
    );

    return completer.future;
  }

  static Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {
      // Ignorar errores al detener la sesión
    }
  }

  static Future<bool> isAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      return false;
    }
  }
}