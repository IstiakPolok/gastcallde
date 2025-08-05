// lib/feature/calls/order_controller.dart
import 'package:gastcallde/feature/orderManagment/models/order_model.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  // ... (existing lists and methods) ...
  final incomingOrders = <Order>[].obs;
  final inPreparationOrders = <Order>[].obs;
  final outForDeliveryOrders = <Order>[].obs;
  final completedOrders = <Order>[].obs;

  void addOrder(Order order) {
    incomingOrders.add(order);
  }

  void moveToPreparation(Order order) {
    incomingOrders.remove(order);
    order.status = 'In Preparation';
    inPreparationOrders.add(order);
  }

  void moveToDelivery(Order order) {
    inPreparationOrders.remove(order);
    order.status = 'Out for Delivery';
    outForDeliveryOrders.add(order);
  }

  void moveToCompleted(Order order) {
    outForDeliveryOrders.remove(order);
    order.status = 'Completed';
    completedOrders.add(order);
  }

  // New method to delete an order from any list
  void deleteOrder(Order order) {
    if (incomingOrders.contains(order)) {
      incomingOrders.remove(order);
    } else if (inPreparationOrders.contains(order)) {
      inPreparationOrders.remove(order);
    } else if (outForDeliveryOrders.contains(order)) {
      outForDeliveryOrders.remove(order);
    } else if (completedOrders.contains(order)) {
      completedOrders.remove(order);
    }
  }
}
