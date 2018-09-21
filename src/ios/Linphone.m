#import "Linphone.h"
#import <Cordova/CDV.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@implementation Linphone

@synthesize call ;
@synthesize lc;
static bool_t running=TRUE;
NSString *loginCallBackID ;
NSString *callCallBackID ;
static bool_t isspeaker=FALSE;
static NSTimer *tListen;
static Linphone *himself;

static void stop(int signum){
    running=false;
}
//+(void) registration_state_changed:(struct _LinphoneCore*) lc:(LinphoneProxyConfig*) cfg:(LinphoneRegistrationState) cstate: (const char*)message
static void registration_state_changed(struct _LinphoneCore *lc, LinphoneProxyConfig *cfg, LinphoneRegistrationState cstate, const char *message){
    
    //Linphone *neco = [ Linphone new];
    if( cstate == LinphoneRegistrationFailed){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"RegistrationFailed"];
        
       
        
        [himself.commandDelegate sendPluginResult:pluginResult callbackId:loginCallBackID];
    }
    else if(cstate == LinphoneRegistrationOk){
        //Start Listen
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"RegistrationSuccess"];
          [himself.commandDelegate sendPluginResult:pluginResult callbackId:loginCallBackID];
        
        
    }
}
/*
 * Call state notification callback
 */
static void call_state_changed(LinphoneCore *lc, LinphoneCall *call, LinphoneCallState cstate, const char *msg){
    
    if(cstate == LinphoneCallError ){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Error"];
        [himself.commandDelegate sendPluginResult:pluginResult callbackId:callCallBackID];
        
        call = NULL;
    }
    if(cstate == LinphoneCallConnected){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Connected"];
        [himself.commandDelegate sendPluginResult:pluginResult callbackId:callCallBackID];
    }
    if(cstate == LinphoneCallEnd){
        
        call = NULL;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"End"];
        [himself.commandDelegate sendPluginResult:pluginResult callbackId:callCallBackID];
        isspeaker = FALSE;
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride),
                                &audioRouteOverride);
        
    }
    if(cstate == LinphoneCallIncomingReceived){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Incoming"];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1000);
        
        [himself.commandDelegate sendPluginResult:pluginResult callbackId:callCallBackID];
        
    }
}

- (void)acceptCall:(CDVInvokedUrlCommand*)command
{
    
    bool isAccept = [command.arguments objectAtIndex:0];
    if( isAccept == TRUE){
        
        LinphoneView *lview = [[LinphoneView alloc]init];
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        lview.lc = lc;
        lview.call = call;
        [rootViewController presentViewController:lview animated:NO completion:nil];
        
        callCallBackID = command.callbackId;
    }
    else{
        
        linphone_core_terminate_call( lc, call);
    }
}

- (void)listenCall:(CDVInvokedUrlCommand*)command
{
    callCallBackID = command.callbackId;
    
}

- (void)login:(CDVInvokedUrlCommand*)command
{
    himself = self;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    NSString* username = [command.arguments objectAtIndex:0];
    NSString* password = [command.arguments objectAtIndex:1];
    NSString* domain = [command.arguments objectAtIndex:2];
    NSString* sip = [@"sip:" stringByAppendingString:[[username stringByAppendingString:@"@"] stringByAppendingString:domain]];
    loginCallBackID = command.callbackId;
    char* identity = (char*)[sip UTF8String];

    if (lc == NULL) {
        LinphoneCoreVTable vtable = {0};
        
        signal(SIGINT,stop);
        /*
         Fill the LinphoneCoreVTable with application callbacks.
         All are optional. Here we only use the registration_state_changed callbacks
         in order to get notifications about the progress of the registration.
         */

        vtable.registration_state_changed = registration_state_changed;
        
        /*
         Fill the LinphoneCoreVTable with application callbacks.
         All are optional. Here we only use the call_state_changed callbacks
         in order to get notifications about the progress of the call.
         */
        vtable.call_state_changed = call_state_changed;
        
        lc = linphone_core_new(&vtable, NULL, NULL, NULL);
    }
    
    LinphoneProxyConfig *proxy_cfg = linphone_core_create_proxy_config(lc);
    LinphoneAddress *from = linphone_address_new(identity);
    
    /*create authentication structure from identity*/
    LinphoneAuthInfo *info=linphone_auth_info_new(linphone_address_get_username(from),NULL,(char*)[password UTF8String],NULL,(char*)[domain UTF8String],(char*)[domain UTF8String]);
    linphone_core_add_auth_info(lc,info); /*add authentication info to LinphoneCore*/
    
    // configure proxy entries
    linphone_proxy_config_set_identity(proxy_cfg,identity); /*set identity with user name and domain*/
    const char* server_addr = linphone_address_get_domain(from); /*extract domain address from identity*/
    linphone_proxy_config_set_server_addr(proxy_cfg,server_addr); /* we assume domain = proxy server address*/
    linphone_proxy_config_enable_register(proxy_cfg,TRUE); /*activate registration for this proxy config*/
    linphone_address_destroy(from); /*release resource*/
    linphone_core_add_proxy_config(lc,proxy_cfg); /*add proxy config to linphone core*/
    linphone_core_set_default_proxy(lc,proxy_cfg); /*set to default proxy*/
    
    /* main loop for receiving notifications and doing background linphonecore work: */
    
    //while(running){
    //    linphone_core_iterate(lc); /* first iterate initiates registration */
    //    ms_usleep(50000);
    //}
    call = NULL;
    running = TRUE;
    tListen = [NSTimer scheduledTimerWithTimeInterval: 0.05
                                               target: self
                                             selector:@selector(listenTick:)
                                             userInfo: nil repeats:YES];
    
}
-(void)listenTick:(NSTimer *)timer {
    linphone_core_iterate(lc);
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    
    if(lc != NULL){
        LinphoneProxyConfig *proxy_cfg = linphone_core_create_proxy_config(lc);
        linphone_core_get_default_proxy(lc,&proxy_cfg); /* get default proxy config*/
        linphone_proxy_config_edit(proxy_cfg); /*start editing proxy configuration*/
        linphone_proxy_config_enable_register(proxy_cfg,FALSE); /*de-activate registration for this proxy config*/
        linphone_proxy_config_done(proxy_cfg); /*initiate REGISTER with expire = 0*/
        
        while(linphone_proxy_config_get_state(proxy_cfg) !=  LinphoneRegistrationCleared){
            linphone_core_iterate(lc); /*to make sure we receive call backs before shutting down*/
            ms_usleep(50000);
        }
        
        linphone_core_clear_all_auth_info(lc);
        linphone_core_clear_proxy_config(lc);
        linphone_core_destroy(lc);
        
        call = NULL;
        lc = NULL;
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)call:(CDVInvokedUrlCommand*)command
{
    
    callCallBackID = command.callbackId;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    NSString* address = [command.arguments objectAtIndex:0];
    NSString* displayName = [command.arguments objectAtIndex:1];
    
    call = linphone_core_invite(lc, (char *)[address UTF8String]);
    linphone_call_ref(call);
}

- (void)videocall:(CDVInvokedUrlCommand*)command
{
    
    LinphoneCallParams *cparams = linphone_core_create_call_params(lc, call);
    linphone_call_enable_camera(lc, true);
    linphone_call_params_enable_video(cparams, true);
    linphone_call_params_enable_audio(cparams, true);
    linphone_core_accept_call_with_params(lc, call, cparams);
    
    callCallBackID = command.callbackId;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    NSString* address = [command.arguments objectAtIndex:0];
    NSString* displayName = [command.arguments objectAtIndex:1];
    
    call = linphone_core_invite_with_params(lc, (char *)[address UTF8String], cparams);
    linphone_call_ref(call);
}

- (void)hangup:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    
    if(call && linphone_call_get_state(call) != LinphoneCallEnd){
        linphone_core_terminate_call(lc, call);
        linphone_call_unref(call);
    }
    call = NULL;
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)toggleVideo:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    bool isenabled = FALSE;
    
    if (call != NULL && linphone_call_params_get_used_video_codec(linphone_call_get_current_params(call))) {
        if(isenabled){
            
        }else{
            
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)toggleSpeaker:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    if (call != NULL && linphone_call_get_state(call) != LinphoneCallEnd){
        isspeaker = !isspeaker;
        if (isspeaker) {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride),
                                    &audioRouteOverride);
            
        } else {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride),
                                    &audioRouteOverride);
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)toggleMute:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    bool isenabled = FALSE;
    
    if(call && linphone_call_get_state(call) != LinphoneCallEnd){
        linphone_core_enable_mic(lc, isenabled);
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendDtmf:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    NSString* dtmf = [command.arguments objectAtIndex:0];
    
    if(call && linphone_call_get_state(call) != LinphoneCallEnd){
        linphone_call_send_dtmf(call, [dtmf characterAtIndex:0]);
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendMessage:(CDVInvokedUrlCommand *)command
{
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    NSString* addrs = [command.arguments objectAtIndex:0];
    NSString* msgs = [command.arguments objectAtIndex:1];
    const LinphoneAddress *addr = linphone_core_create_address(lc, (char *)[addrs UTF8String]);
    LinphoneChatRoom *chat_room = linphone_core_get_chat_room(lc,addr);
    LinphoneChatMessage *msg = linphone_chat_room_create_message(chat_room, (char *)[msgs UTF8String]);
    linphone_chat_room_send_chat_message(chat_room, msg);
    linphone_chat_room_ref(chat_room);
    linphone_chat_room_unref(chat_room);
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

@end

@implementation LinphoneView

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (id)init
{
    self = [super init];
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    _hangupbtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _hangupbtn.frame = CGRectMake(116, 510, 142,42);
    [_hangupbtn setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:_hangupbtn];
    [_hangupbtn setTitle:@"挂断" forState:UIControlStateNormal];
    [_hangupbtn addTarget:self action:@selector(hangupEvt:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_hangupbtn];
    
    _lpview = [[UIView alloc] initWithFrame:CGRectMake(251, 0,   124, 127)];
    _lpview.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_lpview];
    
    _lpcview = [[UIView alloc] initWithFrame:CGRectMake(0, 135,   375, 375)];
    _lpcview.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_lpcview];

    linphone_core_set_native_video_window_id(_lc, (__bridge void *)(_lpcview));
    linphone_core_set_native_preview_window_id(_lc, (__bridge void *)(_lpview));
    linphone_core_video_enabled(_lc);
    linphone_core_video_preview_enabled(_lc);
    LinphoneCallParams *cparams = linphone_core_create_call_params(_lc, _call);
    linphone_call_params_enable_video(cparams, true);
    linphone_call_params_enable_audio(cparams, true);
    
    linphone_core_accept_call_with_params(_lc, _call, cparams);
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)hangupEvt:(UIButton*)button
{
    linphone_core_terminate_call(_lc, _call);
    _call = NULL;
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
