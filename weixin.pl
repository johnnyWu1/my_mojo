#!/usr/bin/env perl
use Mojo::Weixin;
my ($host,$port,$post_api);
$host = "0.0.0.0"; #发送消息接口监听地址，修改为自己希望监听的地址
$port = $ENV{PORT} || 3000;      #发送消息接口监听端口，修改为自己希望监听的端口
$post_api = $ENV{POST_API};  #接收到的消息上报接口，如果不需要接收消息上报，可以删除或注释此行

my $client = Mojo::Weixin->new(
    log_encoding=>  $ENV{LOG_ENCODING} || "utf8",
    log_level   =>  $ENV{LOG_LEVEL} || "info",
    ua_debug    =>  $ENV{UA_DEBUG} || 0,
    (defined $ENV{LOG_PATH}?(log_path =>  $ENV{LOG_PATH}):()),
    (defined $ENV{QRCODE_PATH}?(qrcode_path =>  $ENV{QRCODE_PATH}):()),
);
$client->load("ShowMsg");
$client->load("Openwx",data=>{listen=>[{host=>$host,port=>$port}], post_api=>$post_api});
#$client->load("UploadQRcode");
# $client->load("Perlcode");
# $client->load("Perldoc");
$client->load("Beauty");
$client->load("Riddle");
$client->load("Weather");
$client->load("FuckDaShen");
$client->load("AutoVerify");
$client->load("XiaoiceReply",data=>{
    is_need_at  => 0,           #可选，是否需要艾特我来触发智能回复
    comamnd_on  => "小冰启动",  #可选，启动智能回复的命令，在手机端发送给任何人/群该消息内容即可
    comamnd_off => "小冰停止",  #可选，停止智能回复的命令，在手机端发送给任何人/群该消息内容即可
});
#$client->load("SmartReply",data=>{
##	12669fb3f28c44d0b1078d5194b71d39
#	 	apikey          => '12669fb3f28c44d0b1078d5194b71d39', #可选，参考http://www.tuling123.com/html/doc/apikey.html
#});
$client->load("PostQRcode",data=>{
    smtp    =>  'smtp.163.com', #邮箱的smtp地址  
    port    =>  '25', #smtp服务器端口，默认25
    from    =>  '18711180761@163.com', #发件人
    to      =>  '2072335138@qq.com', #收件人
    user    =>  '18711180761@163.com', #smtp登录帐号
    pass    =>  'wu950429w', #smtp登录密码
    tls     =>  0,      #可选，是否使用SMTPS协议，默认为0
                        #在没有设置的情况下，如果使用的端口为465，则该选项会自动被设置为1
});
$client->load("ShowQRcode");
#print ref $client;
$client->run();
