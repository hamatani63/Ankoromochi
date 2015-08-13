//
//  GraphicsEx.m
//  Ankoromochi
//
//  Created by 浜谷 光吉 on 2015/03/19.
//  Copyright (c) 2015 Mitsuyoshi Hamatani
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GraphicsEx.h"

extern int x[56];
extern int y[56];
extern int z[56];


@implementation GraphicsEx


//コンテキストの指定
- (void)setContext:(CGContextRef)context {
    if (_context!=NULL){
        CGContextRelease(_context);
        _context=NULL;
    }
    _context = context;
    CGContextRetain(_context);
}

//色の指定
- (void)setColor_r:(int)r g:(int)g b:(int)b {
    CGContextSetRGBFillColor(_context, r/255.0f, g/255.0f, b/255.0f, 1.0f);
    CGContextSetRGBStrokeColor(_context, r/255.0f, g/255.0f, b/255.0f, 1.0f);
}

//ライン幅の指定
- (void)setLineWidth:(float)width {
    CGContextSetLineWidth(_context, width);
}

//ラインの描画
- (void)drawLine_x0:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 {
    CGContextSetLineCap(_context, kCGLineCapRound);
    CGContextMoveToPoint(_context, x0, y0);
    CGContextAddLineToPoint(_context, x1, y1);
    CGContextStrokePath(_context);
}

//ポリラインの描画
- (void)drawPolyline_x:(float[])x y:(float[])y length:(int)length {
    CGContextSetLineCap(_context, kCGLineCapRound);
    CGContextSetLineJoin(_context, kCGLineJoinRound);
    CGContextMoveToPoint(_context, x[0], y[0]);
    for (int i=1; i<length; i++){
        CGContextAddLineToPoint(_context, x[i], y[i]);
    }
    CGContextStrokePath(_context);
}

//四角形の描画
- (void)drawRect_x:(float)x y:(float)y w:(float)w h:(float)h {
    CGContextMoveToPoint(_context, x, y);
    CGContextAddLineToPoint(_context, x+w, y);
    CGContextAddLineToPoint(_context, x+w, y+h);
    CGContextAddLineToPoint(_context, x, y+h);
    CGContextAddLineToPoint(_context, x, y);
    CGContextStrokePath(_context);
}

//四角形の塗りつぶし
- (void)fillRect_x:(float)x y:(float)y w:(float)w h:(float)h {
    CGContextFillRect(_context, CGRectMake(x, y, w, h));
}


//初期化
- (id)initWithCoder:(NSCoder *)coder{
    self=[super initWithCoder:coder];
    if (self) {
        _context = NULL;
    }
    return self;
}

//メモリ解放
- (void)dealloc{
    [self setContext:NULL];
}


//描画
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //グラフィックコンテキストの取得
    [self setContext:UIGraphicsGetCurrentContext()];
    //色の指定
    [self setColor_r:255 g:255 b:255];
    //背景のクリア
    [self fillRect_x:0 y:0 w:self.frame.size.width h:self.frame.size.height];
    
    //ラインの描画
    [self setColor_r:200 g:200 b:200];
    [self setLineWidth:1];
    [self drawLine_x0:0 y0:0 x1:self.frame.size.width y1:0];
    [self drawLine_x0:0 y0:self.frame.size.height/4 x1:self.frame.size.width y1:self.frame.size.height/4];
    [self drawLine_x0:0 y0:self.frame.size.height/2 x1:self.frame.size.width y1:self.frame.size.height/2];
    [self drawLine_x0:0 y0:self.frame.size.height/4*3 x1:self.frame.size.width y1:self.frame.size.height/4*3];
    [self drawLine_x0:0 y0:self.frame.size.height x1:self.frame.size.width y1:self.frame.size.height];
    
    //ポリラインの描画
    float dt[56];
    float t0 = 0;
    
    float dx[56];
    float dy[56];
    float dz[56];
    float x0 = self.frame.size.height/2;
    float y0 = self.frame.size.height/2;
    float z0 = self.frame.size.height/2;
    
    for (int i=0; i<56; i++) {
        dt[i]=t0+5*i;
        dx[i]=x0-(float)x[i]/256*self.frame.size.height/2;
        dy[i]=y0-(float)y[i]/256*self.frame.size.height/2;
        dz[i]=z0-(float)z[i]/256*self.frame.size.height/2;
    }
    [self setColor_r:255 g:0 b:0];
    [self setLineWidth:2];
    [self drawPolyline_x:dt y:dx length:56];
    
    [self setColor_r:0 g:255 b:0];
    [self setLineWidth:2];
    [self drawPolyline_x:dt y:dy length:56];
    
    [self setColor_r:0 g:0 b:255];
    [self setLineWidth:2];
    [self drawPolyline_x:dt y:dz length:56];
    
}


@end
