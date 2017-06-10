#import "FirebaseuiPlugin.h"
#import "Firebase/Firebase.h"
#import "FirebaseAuthPlugin.h"
//#import <FirebasePhoneAuthUI/FUIPhoneAuth.h>
//#import <FirebasePhoneAuthUI/FirebasePhoneAuthUI.h>
//#import <OCMock/OCMock.h>


@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                               message:self.domain
                               details:self.localizedDescription];
}
@end


NSDictionary *toDictionaryTemp(id<FIRUserInfo> userInfo) {
    return @{
             @"providerId" : userInfo.providerID,
             @"displayName" : userInfo.displayName ?: [NSNull null],
             @"uid" : userInfo.uid,
             @"photoUrl" : userInfo.photoURL.absoluteString ?: [NSNull null],
             @"email" : userInfo.email ?: [NSNull null],
             };
}

@implementation FirebaseuiPlugin {

}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"firebaseui"
            binaryMessenger:[registrar messenger]];
  FirebaseuiPlugin* instance = [[FirebaseuiPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"signWithOhone" isEqualToString:call.method]) {
      
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"getCurrentUser" isEqualToString:call.method]){
      FIRUser *user = [FIRAuth auth].currentUser;
      [self sendResult:result forUser:user error:nil];
  }else if([@"signinPhone" isEqualToString:call.method]){
      result(FlutterMethodNotImplemented);
//      FUIPhoneAuth *provider = [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]];
//      [provider signInWithPresentingViewController:self];
  }
    else{
    result(FlutterMethodNotImplemented);
  }
}

//- (void)mockPhoneAuthServerRequests {
//    id mockedProvider = OCMClassMock([FIRPhoneAuthProvider class]);
//    OCMStub(ClassMethod([mockedProvider provider])).andReturn(mockedProvider);
//    OCMStub(ClassMethod([mockedProvider providerWithAuth:OCMOCK_ANY])).andReturn(mockedProvider);
//    
//    OCMStub([mockedProvider verifyPhoneNumber:OCMOCK_ANY completion:OCMOCK_ANY]).
//    andDo(^(NSInvocation *invocation) {
//        FIRVerificationResultCallback mockedCallback;
//        [invocation getArgument:&mockedCallback atIndex:3];
//        mockedCallback(@"verificationID", nil);
//    });
//    
//    id mockedCredential = OCMClassMock([FIRPhoneAuthCredential class]);
//    OCMStub([mockedProvider credentialWithVerificationID:OCMOCK_ANY verificationCode:OCMOCK_ANY]).
//    andReturn(mockedCredential);
//    
//    [self mockSignInWithCredential];
//}
//
//- (void)mockSignInWithCredential {
//    OCMStub([self.authMock signInWithCredential:OCMOCK_ANY completion:OCMOCK_ANY]).
//    andDo(^(NSInvocation *invocation) {
//        FIRAuthResultCallback mockedResponse;
//        [invocation getArgument:&mockedResponse atIndex:3];
//        id mockUser = OCMClassMock([FIRUser class]);
//        mockedResponse(mockUser, nil);
//    });
//}
//返回数据
- (void)sendResult:(FlutterResult)result forUser:(FIRUser *)user error:(NSError *)error {
    if (error != nil) {
        result(error.flutterError);
    } else if (user == nil) {
        result(nil);
    } else {
        NSMutableArray<NSDictionary<NSString *, NSString *> *> *providerData =
        [NSMutableArray arrayWithCapacity:user.providerData.count];
        for (id<FIRUserInfo> userInfo in user.providerData) {
            [providerData addObject:toDictionaryTemp(userInfo)];
        }
        NSMutableDictionary *userData = [toDictionaryTemp(user) mutableCopy];
        userData[@"isAnonymous"] = [NSNumber numberWithBool:user.isAnonymous];
        userData[@"isEmailVerified"] = [NSNumber numberWithBool:user.isEmailVerified];
        userData[@"providerData"] = providerData;
        result(userData);
    }
}

@end
