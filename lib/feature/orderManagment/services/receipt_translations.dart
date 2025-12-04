class ReceiptTranslations {
  final String locale;

  ReceiptTranslations(this.locale);

  // Receipt title
  String get orderReceipt =>
      locale == 'de' ? 'BESTELLBESTÄTIGUNG' : 'ORDER RECEIPT';

  // Order info
  String get order => locale == 'de' ? 'Bestellung' : 'Order';
  String get date => locale == 'de' ? 'Datum' : 'Date';
  String get type => locale == 'de' ? 'Art' : 'Type';
  String get customer => locale == 'de' ? 'Kunde' : 'Customer';
  String get phone => locale == 'de' ? 'Telefon' : 'Phone';
  String get email => locale == 'de' ? 'E-Mail' : 'Email';
  String get address => locale == 'de' ? 'Adresse' : 'Address';

  // Order types
  String get delivery => locale == 'de' ? 'Lieferung' : 'Delivery';
  String get pickup => locale == 'de' ? 'Abholung' : 'Pickup';
  String get dineIn => locale == 'de' ? 'Im Restaurant' : 'Dine-in';

  // Items section
  String get items => locale == 'de' ? 'ARTIKEL' : 'ITEMS';
  String get item => locale == 'de' ? 'Artikel' : 'Item';
  String get quantity => locale == 'de' ? 'Menge' : 'Qty';
  String get price => locale == 'de' ? 'Preis' : 'Price';
  String get total => locale == 'de' ? 'Gesamt' : 'Total';
  String get extras => locale == 'de' ? 'Extras' : 'Extras';
  String get note => locale == 'de' ? 'Hinweis' : 'Note';

  // Totals
  String get subtotal => locale == 'de' ? 'Zwischensumme' : 'Subtotal';
  String get totalLabel => locale == 'de' ? 'GESAMT' : 'TOTAL';

  // Additional info
  String get notes => locale == 'de' ? 'Notizen' : 'Notes';
  String get allergy => locale == 'de' ? 'Allergie' : 'Allergy';
  String get specialInstructions =>
      locale == 'de' ? 'Besondere Anweisungen' : 'Special Instructions';

  // Status
  String get status => locale == 'de' ? 'Status' : 'Status';
  String get incoming => locale == 'de' ? 'Eingehend' : 'Incoming';
  String get inPreparation =>
      locale == 'de' ? 'In Vorbereitung' : 'In Preparation';
  String get outForDelivery =>
      locale == 'de' ? 'Unterwegs' : 'Out for Delivery';
  String get completed => locale == 'de' ? 'Abgeschlossen' : 'Completed';

  // Footer
  String get thankYou => locale == 'de' ? 'Vielen Dank!' : 'Thank you!';
  String get scanWebsite => locale == 'de' ? 'Website scannen' : 'Scan website';

  // Get status translation
  String getStatusText(String statusKey) {
    switch (statusKey.toLowerCase()) {
      case 'incoming':
        return incoming;
      case 'in_preparation':
        return inPreparation;
      case 'out_for_delivery':
        return outForDelivery;
      case 'completed':
        return completed;
      default:
        return statusKey;
    }
  }

  // Get order type translation
  String getOrderType(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'delivery':
        return delivery;
      case 'pickup':
        return pickup;
      case 'dine-in':
      case 'dinein':
      case 'dine_in':
        return dineIn;
      default:
        return orderType;
    }
  }
}
