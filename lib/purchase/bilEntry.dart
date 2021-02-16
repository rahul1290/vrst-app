class BillEntry {
  final String crop;
  final String variety;
  final String quantity;

  BillEntry(this.crop,this.variety, this.quantity);
  @override
  String toString() {
    return 'BillEntry: crop = $crop, variety= $variety, quantity= $quantity';
  }
}