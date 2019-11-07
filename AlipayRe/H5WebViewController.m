
#import "H5WebViewController.h"

@interface H5WebViewController ()

@end

@implementation H5WebViewController
 
 
+(NSString*)getNumberRandom:(int)count
{
    NSString *strRandom = @"";
    
    for(int i=0; i<count; i++)
    {
        strRandom = [ strRandom stringByAppendingFormat:@"%i",(arc4random() % 9)];
    }
    return strRandom;
}
 
+(void)collectBubbles:(id)mbrige bubbleId:(NSString*)bID userId :(NSString*)userID
{
      long timems=[[NSDate  date] timeIntervalSince1970]*1000;
      NSString *timeStamp = [NSString stringWithFormat:@"%ld", timems];
      NSString *randNum=[H5WebViewController getNumberRandom:16];
      NSString *arg1=[NSString stringWithFormat:@"[{\"handlerName\":\"remoteLog\",\"data\":{\"seedId\":\"ANTFOREST-BEHAVIOR-CLICK-COLLECT\",\"param1\":\"shareBiz=none^bubbleId=%@^actionUserId=%@^type=behavior^currentTimestamp=%@\",\"param2\":\"monitor_type=clicked^remoteType=info^pageName=home.html^pageState=friend%@_enterhomeOff\",\"bizType\":\"antForest\"},\"callbackId\":\"remoteLog_15105601282940.%@\"},{\"handlerName\":\"rpc\",\"data\":{\"operationType\":\"alipay.antmember.forest.h5.collectEnergy\",\"requestData\":[{\"userId\":%@,\"bubbleIds\":[%@],\"av\":\"5\",\"ct\":\"ios\"}],\"disableLimitView\":true},\"callbackId\":\"rpc_15105601282960.%@\"}] ",bID,userID,timeStamp,userID,randNum,userID,bID,randNum];
      NSString *arg2=[NSString stringWithFormat:@"https://60000002.h5app.alipay.com/app/src/home.html?userId=%@",userID];
      PSDJsBridge *jsB=mbrige;
      [jsB _doFlushMessageQueue:arg1 url:arg2];
}

 
+(void)getTopUserBubbles:(id)mbrige userId:(NSString*)userID
{
        long timems=[[NSDate  date] timeIntervalSince1970]*1000;
        NSString *timeStamp = [NSString stringWithFormat:@"%ld", timems];
        NSString *randNum=[H5WebViewController getNumberRandom:16];
        NSString *arg1=[NSString stringWithFormat:@"[{\"handlerName\":\"remoteLog\",\"data\":{\"seedId\":\"ANTFOREST-PAGE-READY-home\",\"param1\":\"shareBiz=none^type=behavior^currentTimestamp=1510628822616\",\"param2\":\"monitor_type=openPage^remoteType=info\",\"bizType\":\"antForest\"},\"callbackId\":\"remoteLog_15106288226220.36025243042968214\"},{\"handlerName\":\"getSystemInfo\",\"data\":{},\"callbackId\":\"getSystemInfo_15106288226230.7224089596420527\"},{\"handlerName\":\"hideOptionMenu\",\"data\":{},\"callbackId\":\"hideOptionMenu_15106288226230.7351219072006643\"},{\"handlerName\":\"setToolbarMenu\",\"data\":{\"menus\":[],\"override\":true},\"callbackId\":\"setToolbarMenu_15106288226230.6259752095211297\"},{\"handlerName\":\"setGestureBack\",\"data\":{\"val\":true},\"callbackId\":\"setGestureBack_15106288226230.2139696276281029\"},{\"handlerName\":\"remoteLog\",\"data\":{\"seedId\":\"ANTFOREST-H5_PAGE_SET_PAGE_NAME\",\"param1\":\"shareBiz=none^type=behavior^currentTimestamp=%@\",\"param2\":\"monitor_type=clicked^remoteType=info^pageName=home.html\",\"bizType\":\"antForest\"},\"callbackId\":\"remoteLog_15106288226260.2301180271897465\"},{\"handlerName\":\"addNotifyListener\",\"data\":{\"name\":\"NEBULANOTIFY_AFRefresh\"},\"callbackId\":\"addNotifyListener_15106288226260.7617499728221446\"},{\"handlerName\":\"rpc\",\"data\":{\"operationType\":\"alipay.antmember.forest.h5.queryNextAction\",\"requestData\":[{\"userId\":\"%@\",\"av\":\"5\",\"ct\":\"ios\"}],\"disableLimitView\":true},\"callbackId\":\"rpc_15106288226260.%@\"}]",timeStamp,userID,randNum];
        NSString *arg2=[NSString stringWithFormat:@"https://60000002.h5app.alipay.com/app/src/home.html?userId=%@",userID];
        PSDJsBridge *jsB=mbrige;
        [jsB _doFlushMessageQueue:arg1 url:arg2];
}
 
 
+(void)collectTopBub
{
	 APListData *jdata=[APListData sharedInstance];
     NSMutableDictionary *copyDic=[jdata.topBubblesDic mutableCopy];
     NSLog(@"收集top10用户OK,开始一个个采集:%@",copyDic);

      for (id key in copyDic) {
            id obj = [copyDic objectForKey:key];

            NSLog(@"=========:%@=====:%@",key,obj);
            for(NSDictionary *eachbubble in obj){
            	 NSString *collectStatus=[eachbubble objectForKey:@"collectStatus"];
            	 //可用的就摘取
            	 if([collectStatus isEqualToString:@"AVAILABLE"]){
                       NSString *bID=[eachbubble objectForKey:@"id"];
                       NSString *uID=[eachbubble objectForKey:@"userId"];
                       [H5WebViewController collectBubbles:jdata.jsBridge bubbleId:bID userId:uID];
                       NSLog(@"我开始收能量了--:%@",bID);

            	 }
            }
      }
  }

@end