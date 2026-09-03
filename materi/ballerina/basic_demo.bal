import ballerina/io;

public function main() {
    string appName = "Antigravity Integration Engine";
    decimal basePrice = 1000000.0d;
    decimal taxRate = 0.11d; // PPN 11%
    decimal discount = 0.10d; // Diskon 10%

    // Kalkulasi matematis
    decimal discountAmount = basePrice * discount;
    decimal netPrice = basePrice - discountAmount;
    decimal taxAmount = netPrice * taxRate;
    decimal grandTotal = netPrice + taxAmount;

    io:println("=== " + appName + " ===");
    io:println(string `Harga Dasar     : Rp ${basePrice}`);
    io:println(string `Diskon (10%)    : Rp ${discountAmount}`);
    io:println(string `PPN (11%)       : Rp ${taxAmount}`);
    io:println(string `Total Akhir     : Rp ${grandTotal}`);
}