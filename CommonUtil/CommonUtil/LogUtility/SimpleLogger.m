#import "SimpleLogger.h"

@implementation SimpleLogger

@synthesize logLevelSetting;

#pragma mark Class Method
+ (SimpleLogger *)getLogger
{
	static SimpleLogger *logger = nil;
	if ( logger == nil)
	{
		logger = [[SimpleLogger alloc]init];
	}
	return logger;
}

+ (NSString *)levelName:(SimpleLoggerLevel)level
{
	switch (level) {
		case SLL_TINY:    return @"TINY";break;
		case SLL_DETAIL:  return @"DETAIL";break;
		case SLL_ENTER:   return @"ENTER";break;
		case SLL_RETURN:  return @"RETURN";break;
		case SLL_INFO:    return @"INFO";break;
		case SLL_DEBUG:   return @"DEBUG";break;
		case SLL_WARNING: return @"WARN";break;
		case SLL_ERROR:   return @"ERROR";break;
		case SLL_FATAL:   return @"FATAL";break;
		default: return @"NOLEVE"; break;
	}
}

#pragma mark -
#pragma mark Method init

- (id)initWithLogLevel:(SimpleLoggerLevelSetting)levelSetting
{
	if (self = [super init])
	{
		self.logLevelSetting = levelSetting;
	}
	return self;
}

- (id)init
{
	return [self initWithLogLevel:SLLS_ALL];
}

#pragma mark -
#pragma mark Method

void print()
{
    
}

- (void)log:(NSString *)msg 
  withLevel:(SimpleLoggerLevel)level
	 inFile:(NSString *)fileName 
     inLine:(int)lineNr
{  
	if (level > logLevelSetting)
	{
		NSLog(@"{%@:%d}[%@]%@", fileName, lineNr,
			  [SimpleLogger levelName:level], msg);
	}
}

- (void)enter:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_ENTER inFile:fileName inLine:lineNr];
}

- (void)retrn:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_RETURN inFile:fileName inLine:lineNr];
}

- (void)info:(NSString *)msg 
	  inFile:(NSString *)fileName 
	  inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_INFO inFile:fileName inLine:lineNr];
}

- (void)debug:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_DEBUG inFile:fileName inLine:lineNr];
	
}

- (void)warn:(NSString *)msg 
	  inFile:(NSString *)fileName 
	  inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_WARNING inFile:fileName inLine:lineNr];
	
}

- (void)error:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:SLL_ERROR inFile:fileName inLine:lineNr];
	
}

@end
