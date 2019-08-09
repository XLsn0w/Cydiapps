/*
 * GeneratorSetterVC.h - UI stuff
 *
 * Copyright (c) 2017 Siguza & tihmstar
 */

#import <UIKit/UIKit.h>

@interface GeneratorSetterVC : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UILabel *curGenLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)btnPastePressed:(id)sender;
- (IBAction)btnSetPressed:(id)sender;
- (IBAction)kbDoneBtnPressed:(id)sender;
- (IBAction)btnDumpPressed:(id)sender;

@end
