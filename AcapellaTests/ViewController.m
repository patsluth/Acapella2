//
//  ViewController.m
//  AcapellaTests
//
//  Created by Pat Sluth on 2016-05-06.
//
//

#import "ViewController.h"





@interface ViewController () <UIDynamicAnimatorDelegate>
{
}
@property (strong, nonatomic) IBOutlet UIView *box;
@property (strong, nonatomic) UIDynamicAnimator *animator;

@end





@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
	self.animator.delegate = self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
		
		[self.animator removeAllBehaviors];
		
		UIDynamicItemBehavior *dynamicItem = [[UIDynamicItemBehavior alloc] initWithItems:@[self.box]];
		dynamicItem.density = 70.0;
		dynamicItem.resistance = 10;
		dynamicItem.allowsRotation = NO;
		dynamicItem.angularResistance = CGFLOAT_MAX;
		dynamicItem.friction = 1.0;
		[self.animator addBehavior:dynamicItem];
		
		UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.box snapToPoint:CGPointMake([touch locationInView:self.view].x, self.box.center.y)];
		snap.damping = 0.2;
		[self.animator addBehavior:snap];
		
//		UIFieldBehavior *magneticField = [UIFieldBehavior fieldWithEvaluationBlock:^CGVector(UIFieldBehavior * _Nonnull field, CGPoint position, CGVector velocity, CGFloat mass, CGFloat charge, NSTimeInterval deltaTime) {
//			return CGVectorMake(1.0, 0.0);
//		}];
//		magneticField.region = [[UIRegion alloc] initWithSize:self.view.bounds.size];
//		magneticField.position = [touch locationInView:self.view];
//		[self.animator addBehavior:magneticField];
//		
//		[magneticField addItem:self.box];
		
	}
}

@end




