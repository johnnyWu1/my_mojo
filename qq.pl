use Mojo::Webqq;
my ($qq,$host,$port,$post_api);

$ENV{QQ} = '2072335138';
$ENV{QQPWD} = 'qqwu950429.';

$qq   = $ENV{QQ};

$host = "0.0.0.0"; #发送消息接口监听地址，修改为自己希望监听的地址
$port = $ENV{PORT} || 5000;      #发送消息接口监听端口，修改为自己希望监听的端口
$post_api = $ENV{POST_API};  #接收到的消息上报接口，如果不需要接收消息上报，可以删除或注释此行

my $client = Mojo::Webqq->new(
    qq          =>  $qq,
    log_encoding=>  $ENV{LOG_ENCODING} || "utf8",
    log_level   =>  $ENV{LOG_LEVEL} || "info",
    ua_debug    =>  $ENV{UA_DEBUG} || 0,
    pwd			=>  $ENV{QQPWD}||'',
    login_type  =>  "qrlogin",
    (defined $ENV{LOG_PATH}?(log_path =>  $ENV{LOG_PATH}):()),
    (defined $ENV{QRCODE_PATH}?(qrcode_path =>  $ENV{QRCODE_PATH}):()),
);
$client->load("ShowMsg");
$client->load("SmartReply",data=>{
#	12669fb3f28c44d0b1078d5194b71d39
	 	apikey          => '12669fb3f28c44d0b1078d5194b71d39', #可选，参考http://www.tuling123.com/html/doc/apikey.html
        allow_group     => ["41995224"],  #可选，允许插件的群，可以是群名称或群号码
        ban_group       => ["私人群",123456], #可选，禁用该插件的群，可以是群名称或群号码
        notice_reply    => ["对不起，请不要这么频繁的艾特我","对不起，您的艾特次数太多"], #可选，提醒时用语
        is_need_at      => 1,  #默认是1 是否需要艾特才触发回复
#        keyword         => [qw(jonney jonney助手)], #触发智能回复的关键字，使用时请设置is_need_at=>0
});
$client->load("ProgramCode");
#$client->load("Perlcode");

$client->load("Perldoc");
$client->load("FuckDaShen");
$client->load("Riddle");
$client->load("Openqq",data=>{listen=>[{host=>$host,port=>$port}], post_api=>$post_api});
#$client->load("UploadQRcode");

#$client->load("PostImgVerifycode",data=>{
#    smtp    =>  'smtp.163.com', #邮箱的smtp地址  
#    port    =>  '25', #smtp服务器端口，默认25
#    from    =>  '18711180761@163.com', #发件人
#    to      =>  '842269153@qq.com', #收件人
#    user    =>  '18711180761@163.com', #smtp登录帐号
#    pass    =>  'wu950429w', #smtp登录密码
#    post_host => $host , #本机公网IP地址，需要远程访问
#    post_port => $port            , #提交验证码的链接地址中使用的端口，默认1987
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
#KnowledgeBase2
$client->load("KnowledgeBase2");
$client->load("ShowQRcode");
$client->load("SyncGroup");
$client->run();


