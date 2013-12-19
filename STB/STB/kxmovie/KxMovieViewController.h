
#import <UIKit/UIKit.h>

@class KxMovieDecoder;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL

@interface KxMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>


+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;

@property (readonly) BOOL playing;

- (void) play;
- (void) pause;

- (void)configMoviePath: (NSString *) path
             parameters: (NSDictionary *) parameters;

@end
