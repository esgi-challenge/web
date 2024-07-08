import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showSuccessToast(String message) {
  toastification.show(
    title: const Text("Succès"),
    description: Text(message),
    type: ToastificationType.success,
    style: ToastificationStyle.flatColored,
    autoCloseDuration: const Duration(seconds: 4),
    alignment: Alignment.bottomRight,
  );
}

void showErrorToast(String message) {
  toastification.show(
    title: const Text("Erreur"),
    description: Text(message),
    type: ToastificationType.error,
    style: ToastificationStyle.flatColored,
    autoCloseDuration: const Duration(seconds: 4),
    alignment: Alignment.bottomRight,
  );
}
