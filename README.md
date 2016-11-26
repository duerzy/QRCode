# QRCode
## scanning
`let vc = QRScan { (result) in`
            debugPrint(result)`
            }`
        `vc.show()`
## generation
`imageView.image = QRCodeGenerator.QRCode("Hello World!")`
