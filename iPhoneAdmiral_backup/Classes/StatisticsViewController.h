//
//  StatisticsViewController.h
//  BattleInterface
//
//  Created by Piotr Sarnowski on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StatisticsView;
@class StatisticsContainer;

@interface StatisticsViewController : UIViewController {
	StatisticsView * _statsView;
	StatisticsContainer * _stats;
}

@property (nonatomic, retain) IBOutlet StatisticsView * _statsView;
@property (nonatomic, retain) StatisticsContainer * _stats;

@end
