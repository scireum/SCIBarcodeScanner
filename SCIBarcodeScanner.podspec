Pod::Spec.new do |s|
s.name         = 'SCIBarcodeScanner'
s.version      = '1.1.0'
s.summary      = 'Barcode scanner'
s.description  = <<-DESC
Barcode Scanner
DESC
s.homepage     = 'https://github.com/scireum/SCIBarcodeScanner.git'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.author       = { 'scireum' => 'info+dev@scireum.de'}
s.source       = { :git => 'https://github.com/scireum/SCIBarcodeScanner.git', :tag => "#{s.version}" }
# 8
s.source_files = 'SCIBarcodeScanner/**/*.{swift}'
s.resources = 'SCIBarcodeScanner/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,pdf}'
s.platform     = :ios, '9.0'
s.requires_arc = true
end
