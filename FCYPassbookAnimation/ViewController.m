//
//  ViewController.m
//  FCYPassbookAnimation
//
//  Created by iFangcy on 15/10/12.
//  Copyright © 2015年 iFangcy. All rights reserved.
//

#import "ViewController.h"

#define MAXHEIGHT [UIScreen  mainScreen].bounds.size.height

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;
@property (weak, nonatomic) IBOutlet UIView *view5;

@property (nonatomic, strong) NSMutableArray *imageViewList;
@property (nonatomic, strong) NSArray *animationConstraints;

// 当前执行动画的 view 编号
@property (nonatomic, assign) NSInteger animationIndex;

// 是否正在动画
@property (nonatomic) BOOL willAnimate;

@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.imageViewList = [NSMutableArray arrayWithCapacity: 5];
    [self.imageViewList addObject: self.view1];
    [self.imageViewList addObject: self.view2];
    [self.imageViewList addObject: self.view3];
    [self.imageViewList addObject: self.view4];
    [self.imageViewList addObject: self.view5];
    
    for (int i = 0; i < self.imageViewList.count; i++) {
        
        UIView *childView = self.imageViewList[i];
        childView.backgroundColor = [UIColor colorWithRed:233/255.0 green:(35 + 30*i)/255.0 blue:29/255.0 alpha:1];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tap:)];
        [self.imageViewList[i] addGestureRecognizer: tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(pan:)];
        [self.imageViewList[i] addGestureRecognizer: pan];
    }
    
    
    self.dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.view1, @"view0",
                          self.view2, @"view1",
                          self.view3, @"view2",
                          self.view4, @"view3",
                          self.view5, @"view4",
                          nil];
}

#pragma mark --- 手势
- (void)tap:(UITapGestureRecognizer *)gesture {
    
    self.animationIndex = [gesture view].tag;
    [self animate: self.animationIndex];
}

- (void)pan:(UIPanGestureRecognizer *)gesture {
    
    self.animationIndex = [gesture view].tag;
    
    // 距离手指刚按下时的那个 view 的偏移量
    CGPoint point = [gesture translationInView: [gesture view]];
    
    // 向上拖动
    if (point.y < 0) {
        
        [self.view removeConstraints: _animationConstraints];
        
        NSString *visualFormal = @"V:|";
        for (int i = 0; i < self.imageViewList.count; ++i) {
            
            NSString *key = [@"view" stringByAppendingString:[@(i) stringValue]];
            NSString *value = [NSString stringWithFormat: @"-0-[%@(60)]", key];
            
            // 当第一个 view 不是正在动画的 view 时的约束
            if (i == 0) {
                
                value = [NSString stringWithFormat: @"-(%f)-[%@(60)]", MAXHEIGHT - 5 * 60 + point.y, key];
            }
            
            // 需要执行动画的且不是第一个 view 的哪一个约束
            if (i == self.animationIndex) {
                
                value = [NSString stringWithFormat: @"-0-[%@(%f)]", key, 60 - point.y];
            }
            
            // 当执行动画的是第一个 view 时
            if (i == self.animationIndex && i == 0) {
                
                value = [NSString stringWithFormat: @"-(%f)-[%@(%f)]", (MAXHEIGHT - 5 * 60) + point.y, key, 60 - point.y];
            }
            
            visualFormal = [visualFormal stringByAppendingString: value];
        }
    
        self.animationConstraints = [NSLayoutConstraint constraintsWithVisualFormat: visualFormal options: 0 metrics: nil views: self.dict];
        [self.view addConstraints: self.animationConstraints];
    }
    
    // 向下拖动
    if (point.y > 0) {
        
        [self.view removeConstraints: self.animationConstraints];
        
        NSString *visualFormal = @"V:|";
        for (int i = 0; i < self.imageViewList.count; i++) {
            
            NSString *key = [@"view" stringByAppendingString: [@(i) stringValue]];
            NSString *value = [NSString stringWithFormat: @"-0-[%@(60)]", key];
            
            // 第一个且不是正在动画的那一个 view 的约束
            if (i == 0) {
                
                value = [NSString stringWithFormat: @"-(%f)-[%@(60)]", - 60 * self.animationIndex + point.y, key];
            }
            
            // 正在动画的且不是第一个 view 的约束
            if (i == self.animationIndex) {
                
                value = [NSString stringWithFormat: @"-0-[%@(%f)]", key, MAXHEIGHT - point.y];
            }
            
            // 第一个且是正在动画的 view 的约束
            if (i == self.animationIndex && i == 0) {
                
                value = [NSString stringWithFormat: @"-(%f)-[%@(%f)]", point.y, key, MAXHEIGHT + point.y];
            }
            
            visualFormal = [visualFormal stringByAppendingString: value];
        }
    
        self.animationConstraints = [NSLayoutConstraint constraintsWithVisualFormat: visualFormal options: 0 metrics: nil views: self.dict];
        [self.view addConstraints: self.animationConstraints];
    }
    
    // 拖动距离大于 40 时执行动画
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        if (point.y <= - 40) {
            
            [self animate: self.animationIndex];
        }
        
        if (point.y >= 40) {
            
            [self animate: self.animationIndex];
        }
    }
}


// 对 index 个 view 执行动画
- (void)animate:(NSInteger)index {
    
    NSInteger _index = index;
    
    if (!_willAnimate) {
        
        _willAnimate = YES;
        
        [UIView animateWithDuration: 0.3f animations:^{
            
            [self.view removeConstraints: self.animationConstraints];
            
            NSString *visualFormal = @"V:|";
            for (int i = 0; i < self.imageViewList.count; ++i) {
                
                NSString *key = [@"view" stringByAppendingString: [@(i) stringValue]];
                NSString *value = [NSString stringWithFormat: @"-0-[%@(60)]", key];
            
                if (i == 0) {
                    
                    value = [NSString stringWithFormat: @"-(-%ld)-[%@(60)]", 60 * _index, key];
                }
             
                // 正在执行动画的 view
                if (i == _index) {
                    
                    value = [NSString stringWithFormat: @"-0-[%@(%f)]", key, MAXHEIGHT];
                }
                
                visualFormal = [visualFormal stringByAppendingString: value];
            }
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.view1, @"view0",
                                  self.view2, @"view1",
                                  self.view3, @"view2",
                                  self.view4, @"view3",
                                  self.view5, @"view4",
                                  nil];

            self.animationConstraints = [NSLayoutConstraint constraintsWithVisualFormat: visualFormal options: 0 metrics: nil views: dict];
            [self.view addConstraints: self.animationConstraints];
            
            [self.view layoutIfNeeded];
        }];
        
    }else {
        
        [UIView animateWithDuration: 0.3f animations:^{
           
            [self.view removeConstraints: _animationConstraints];
            [self reset];
            [self.view layoutIfNeeded];
        }];
        
        _willAnimate = NO;
    }
    
}

// 恢复动画
- (void)reset {
    
    [self.view  removeConstraints: _animationConstraints];
    NSString *visualFormal = @"V:";
    for (int i = 0; i < self.imageViewList.count; i++) {
        
        NSString *key = [@"view" stringByAppendingString: [@(i) stringValue]];
        NSString *value = [NSString stringWithFormat: @"[%@(60)]-0-", key];
        visualFormal = [visualFormal stringByAppendingString: value];
    }
    visualFormal = [visualFormal stringByAppendingString: @"|"];
    
    self.animationConstraints = [NSLayoutConstraint constraintsWithVisualFormat: visualFormal options: 0 metrics: nil views: self.dict];
    [self.view addConstraints: self.animationConstraints];
}

@end
