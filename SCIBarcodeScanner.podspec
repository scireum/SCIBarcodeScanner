Pod::Spec.new do |s|
s.name         = 'SCIBarcodeScanner'
s.version      = '2.0.4'
s.summary      = 'Barcode scanner'
s.description  = <<-DESC
Barcode scanner
DESC
s.homepage     = 'https://github.com/scireum/SCIBarcodeScanner.git'
s.license      = { :type => 'MIT' }
s.author       = { 'scireum' => 'info+dev@scireum.de'}
s.source       = { :git => 'https://github.com/scireum/SCIBarcodeScanner.git', :tag => "#{s.version}" }
s.source_files = 'SCIBarcodeScanner/**/*.{swift}'
s.resources    = 'SCIBarcodeScanner/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,pdf,strings,lproj}'
s.platform     = :ios, '10.0'
end
