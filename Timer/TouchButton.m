#import <Cocoa/Cocoa.h>
#import "TouchButton.h"

static double HOLD_PRESS_TIME = 0.65;
static double DOUBLE_TAP_TIME = 0.3;

@interface TouchButton ()

@property double touchBeganTime;

@end

@implementation TouchButton

NSTimer *pressTimer;
NSDate *lastTapTime;

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)onLongHold {
  [self.delegate onHoldPressed: self];
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
  NSSet<NSTouch *> *touches = [event touchesMatchingPhase:NSTouchPhaseBegan inView:self];
  // Note: Touches may contain 0, 1 or more touches.
  // What to do if there are more than one touch?
  // In this example, randomly pick a touch to track and ignore the other one.

  NSTouch *touch = touches.anyObject;
  if (touch != nil) {
    if (touch.type == NSTouchTypeDirect) {
      self.touchBeganTime = [[NSDate date] timeIntervalSince1970];
      
      pressTimer = [NSTimer scheduledTimerWithTimeInterval:HOLD_PRESS_TIME
                                               target:self
                                             selector:@selector(onLongHold)
                                             userInfo:nil
                                              repeats:NO];
    }
  }

  [super touchesBeganWithEvent:event];
}

- (void)touchesMovedWithEvent:(NSEvent *)event {
  for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseMoved inView:self]) {
    if (touch.type == NSTouchTypeDirect) {
      break;
    }
  }

  [super touchesMovedWithEvent:event];
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
  for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseEnded inView:self]) {
    if (touch.type == NSTouchTypeDirect) {
      if (self.delegate != nil) {
        double touchTime = [[NSDate date] timeIntervalSince1970] - self.touchBeganTime;
        NSTimeInterval timeSinceLastTap = -[lastTapTime timeIntervalSinceNow];
        
        if (touchTime >= HOLD_PRESS_TIME) {
          break;
        } else if (lastTapTime && timeSinceLastTap <= DOUBLE_TAP_TIME) {
          [self.delegate onDoubleTap: self];
          lastTapTime = nil;
        } else {
          [self.delegate onTap: self];
          lastTapTime = [NSDate date];
        }
      }
      break;
    }
  }
  
  [pressTimer invalidate];
  pressTimer = nil;
  
  [super touchesEndedWithEvent:event];
}

- (void)touchesCancelledWithEvent:(NSEvent *)event {
  [pressTimer invalidate];
  pressTimer = nil;
  
  for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseMoved inView:self]) {
    if (touch.type == NSTouchTypeDirect) {
      break;
    }
  }

  [super touchesCancelledWithEvent:event];
}

@end
