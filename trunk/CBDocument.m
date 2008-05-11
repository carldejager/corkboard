//
//  CBPDF.m
//  Multitouch
//
//  Created by Bridger Maxwell on 1/9/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "CBDocument.h"


@implementation CBDocument

- (id) initWithPDF: (CGPDFDocumentRef) pdf bounds: (CGRect)rect position: (CGPoint)pos
{
    self = [super init];
    if (self != nil) {
		self.position = pos;
		self.bounds = rect;
		size_t page = 1;
        [self setPDF: pdf page: page];
    }
    return self;
}

- (void) setPDF: (CGPDFDocumentRef) pdf page: (size_t)pageNum
{
	self.borderWidth = 5;
	self.borderColor = CGColorGetConstantColor(kCGColorWhite);
	
	PDFPainter = [[CBDocumentPDFDelegate alloc] initWithPDF: pdf page: pageNum];
	pdfHolder = [[CALayer alloc] init];
	pdfHolder.bounds = [pdfHolder convertRect: self.bounds fromLayer: self];
	CGPoint innerPos = CGPointMake( CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	pdfHolder.position = innerPos;
	
	[pdfHolder setDelegate: PDFPainter];
	pdfHolder.needsDisplayOnBoundsChange = YES;
	[pdfHolder setNeedsDisplay];
	[self addSublayer: (id) pdfHolder];
}

@end


@implementation CBDocumentPDFDelegate

- (id)initWithPDF: (CGPDFDocumentRef) pdf page: (size_t)pageNum {
    self = [super init];
    if (self != nil) {
		currentPage = pageNum;
		layerPDF = pdf;
	}
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)theContext {
	
	CGColorRef background = CGColorGetConstantColor(kCGColorWhite);
	layer.backgroundColor = background;
	
	CGPDFPageRef page = CGPDFDocumentGetPage(layerPDF, currentPage);

	//layer.bounds = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox,layer.bounds, 0, true);
    CGContextSaveGState (theContext);
    CGContextConcatCTM (theContext, pdfTransform);
	CGContextClipToRect (theContext, CGPDFPageGetBoxRect(page, kCGPDFMediaBox));
	CGContextDrawPDFPage (theContext,page);
	CGContextRestoreGState (theContext);
}

@end

