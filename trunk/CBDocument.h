//
//  CBPDF.h
//  Multitouch
//
//  Created by Bridger Maxwell on 1/9/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "Bit.h"

@interface CBDocumentPDFDelegate : NSObject {
	CGPDFDocumentRef layerPDF;
	size_t currentPage;
}
- (id)initWithPDF: (CGPDFDocumentRef) pdf page: (size_t)pageNum;
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)theContext;

@end


@interface CBDocument : Bit {
	CALayer *pdfHolder;
	CBDocumentPDFDelegate *PDFPainter;
}

- (id) initWithPDF: (CGPDFDocumentRef) pdf bounds: (CGRect)rect position: (CGPoint)pos;
- (void) setPDF: (CGPDFDocumentRef) pdf page: (size_t)page;

@end
