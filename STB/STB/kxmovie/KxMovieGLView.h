#import <UIKit/UIKit.h>

@class KxVideoFrame;
@class KxMovieDecoder;

@interface KxMovieGLView : UIView

- (id) initWithFrame:(CGRect)frame
             decoder: (KxMovieDecoder *) decoder;

- (void) render: (KxVideoFrame *) frame;

@end
