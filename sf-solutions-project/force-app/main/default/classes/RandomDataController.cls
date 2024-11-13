public class RandomDataController {
    public List<LineItem> lineItems { get; set; }
    
    public RandomDataController() {
        lineItems = new List<LineItem>();
        for (Integer i = 1; i <= 100; i++) {
            lineItems.add(new LineItem(
                'Item ' + i,
                Integer.valueOf(Math.random() * 100),
                Math.round(Math.random() * 1000)
            ));
        }
    }
    
    public class LineItem {
        public String Name { get; set; }
        public Integer Quantity { get; set; }
        public Decimal Price { get; set; }
        
        public LineItem(String name, Integer quantity, Decimal price) {
            this.Name = name;
            this.Quantity = quantity;
            this.Price = price;
        }
    }
}