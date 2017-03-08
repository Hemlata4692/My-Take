//
//  MissionService.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionService.h"
#import "MissionDataModel.h"
#import "MissionDetailModel.h"
#import "UploadMissionModel.h"
#import "NullValueChecker.h"

static NSString *kMissionList=@"/api/missions/getAllMissions";
static NSString *kMissionDetail=@"/api/missions/getMissionDetails";
static NSString *kSubmitMissionLater=@"/api/missions/submitMissionLater";
static NSString *kUploadMissionData=@"/api/missions/uploadMissionStep";
static NSString *kMarkMissionComplete=@"/api/missions/markMissionComplete";

@implementation MissionService


#pragma mark- Missons list
- (void)getMissionList:(MissionDataModel *)missionData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = @{@"api_token" :[UserDefaultManager getValue:@"apiKey"]};
    super.baseUrl=[UserDefaultManager getValue:@"baseUrl"];
    [super get:kMissionList parameters:parameters onSuccess:success onFailure:failure];
}
#pragma mark- end

#pragma mark- Misson details
- (void)getMissionDetail:(MissionDetailModel *)missionData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = @{@"api_token" :[UserDefaultManager getValue:@"apiKey"],@"MissionID":[UserDefaultManager getValue:@"missionId"]};
    super.baseUrl=[UserDefaultManager getValue:@"baseUrl"];
    [super get:kMissionDetail parameters:parameters onSuccess:success onFailure:failure];
}
#pragma mark- end

#pragma mark- Submit mission later
- (void)submitMissionLater:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"api_token" :[UserDefaultManager getValue:@"apiKey"],@"MissionID":[UserDefaultManager getValue:@"missionId"]};
    super.baseUrl=[UserDefaultManager getValue:@"baseUrl"];
    [super post:kSubmitMissionLater parameters:parameters onSuccess:success onFailure:failure];
}
#pragma mark- end

#pragma mark- Mark mission complete
- (void)markMissionComplete:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{@"api_token" :[UserDefaultManager getValue:@"apiKey"],@"MissionID":[UserDefaultManager getValue:@"missionId"]};
    super.baseUrl=[UserDefaultManager getValue:@"baseUrl"];
    [super post:kMarkMissionComplete parameters:parameters onSuccess:success onFailure:failure];
}
#pragma mark- end

#pragma mark- Upload mission
//upload mission data in multipart
- (void)uploadMission:(NSMutableArray *)filePath mediaType:(int)mediaType stepId:(NSString *)stepId requestDict:(NSMutableDictionary *)requestDict success:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    NSURLSessionDataTask *uploadTask;
    super.baseUrl=[UserDefaultManager getValue:@"baseUrl"];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]  multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/api/missions/uploadMissionStep",[UserDefaultManager getValue:@"baseUrl"]] parameters:requestDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString *baseDocumentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        for (int i=0; i<filePath.count; i++) {
            //uplaod images in multipart
            NSString *tempPath=[baseDocumentPath stringByAppendingPathComponent:[[filePath objectAtIndex:i] lastPathComponent]];
            if (mediaType==1) {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:tempPath]];
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"value_%@[]",stepId] fileName:@"files.jpg" mimeType:@"image/jpeg"];//image
            }
            //upload audio file
            else if (mediaType==2) {
                NSData *audioData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:tempPath]];
                [formData appendPartWithFileData:audioData name:[NSString stringWithFormat:@"value_%@",stepId] fileName:@"files.wav" mimeType:@"audio/vnd.wave"];//audio
            }
            //uplaod video
            else if (mediaType==3) {
                NSData *videoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:tempPath]];
                [formData appendPartWithFileData:videoData name:[NSString stringWithFormat:@"value_%@",stepId] fileName:@"files.mp4" mimeType:@"video/mp4"];//video
            }
        }
    } error:nil];
    uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (!error) {
            //success
            responseObject=(NSMutableDictionary *)[NullValueChecker checkArrayForNullValue:[responseObject mutableCopy]];
            success(responseObject);
        } else {
            id messageString;
            if (nil!=[responseObject objectForKey:@"message"]) {
                messageString=[responseObject objectForKey:@"message"];
            }
            else {
                messageString=error.localizedDescription;
            }
            failure(messageString);
        }
    }];
    [uploadTask resume];
}
#pragma mark- end
@end
