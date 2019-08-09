/*
 * GeneratorSetterVC.m - UI stuff
 *
 * Copyright (c) 2017 Siguza & tihmstar
 */

#include "set.h"
#import "GeneratorSetterVC.h"

@interface GeneratorSetterVC ()

@end

@implementation GeneratorSetterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setGenerator:(NSString*)generator{
    if(set_generator([generator UTF8String]))
    {
        self.errorLabel.hidden = NO;
        [self.errorLabel setTextColor:[UIColor greenColor]];
        self.errorLabel.text = @"Success: generator set";
    }
    else
    {
        [self failedWithError:[NSString stringWithFormat:@"Error: Failed to set generator"]];
    }
}

-(void)failedWithError:(NSString*)error{
    self.errorLabel.hidden = NO;
    [self.errorLabel setTextColor:[UIColor redColor]];
    self.errorLabel.text = error;
}

- (IBAction)btnPastePressed:(id)sender {
    self.textfield.text = [[UIPasteboard generalPasteboard] string];
}

- (IBAction)btnSetPressed:(id)sender {
    self.errorLabel.hidden = YES;
    char gotGen[20] = {0};
    NSString *genStr = self.textfield.text;
    NSLog(@"Setting generator = %@!",genStr);
    uint64_t generator;
    sscanf(genStr.UTF8String, "0x%16llx",&generator);
    sprintf(gotGen, "0x%016llx",generator);
    if (genStr.length == 18 && !strncmp(gotGen, genStr.UTF8String, 18)) {
        NSLog(@"valid generator");
        [self setGenerator:genStr];
    }else{
        NSLog(@"invalid generator = %s",gotGen);
        [self failedWithError:[NSString stringWithFormat:@"Error: Bad generator\nlength = %d",(int)genStr.length]];
    }
}

- (IBAction)kbDoneBtnPressed:(id)sender {
    [self.textfield endEditing:YES];
}

- (IBAction)btnDumpPressed:(id)sender {
    self.errorLabel.hidden = YES;
    bool ret = dump_apticket([[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"apticket.der"].UTF8String);
    if(ret)
    {
        self.errorLabel.hidden = NO;
        [self.errorLabel setTextColor:[UIColor greenColor]];
        self.errorLabel.text = @"Success: Dumped APTicket";
    }
    else
    {
        [self failedWithError:[NSString stringWithFormat:@"Error: Failed to dump APTicket"]];
    }
}

@end
