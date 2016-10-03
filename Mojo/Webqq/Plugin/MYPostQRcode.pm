package Mojo::Webqq::Plugin::MYPostQRcode;
our $PRIORITY = 0;
our $CALL_ON_LOAD = 1;
use MIME::Base64;
BEGIN{
    our $has_mime_lite = 0;
    eval{require MIME::Lite;};
    $has_mime_lite = 1 if not $@;
}


sub upload {
    my($client,$opt,$name,$data) = @_;
    my $mydomain  = $opt->{mydomain} // "qr.perfi.wang";
    my $appid = $opt->{appid} // 10063136;
    my $bucket = $opt->{bucket} // 'qr';
    my $secretid = $opt->{secretid} // 'AKIDGfoZzPrHrWW98rqFbCF5EHP0DenTqO4N';
    my $secretkey = $opt->{secretkey} // 'eT2sPJnvXQ3IGF4yaaBLGkOXDVAsEqlo';
    my $now = time;
    my $expire = $opt->{expire} // 120;
    $expire = $now + $expire;
    my $rand = int rand 1000000;

    my $fileid = Mojo::Util::url_escape("/$appid/$bucket/$name");
    $fileid=~s/%2F/\//g;
    my $orignal = "a=$appid&b=$bucket&k=$secretid&e=$expire&t=$now&r=$rand&f=$fileid";
    my $signtemp = Digest::SHA::hmac_sha1($orignal,$secretkey);
    my $sign = Mojo::Util::b64_encode($signtemp . $orignal,"");

    my $json = $client->http_post("http://web.file.myqcloud.com/files/v1/$appid/$bucket/$name",
        { Authorization=>$sign, json=>1 ,ua_debug_req_body=>0},
        form=>{
            op=>'upload',
            insertOnly=>1,
            filecontent=>{filename=>$name,content=>$data},
        }
    );
    if(not defined $json){
        $client->warn("二维码图片上传云存储失败: 响应数据异常");
        return;
    }
    elsif(defined $json and $json->{code} != 0 ){
        $client->warn("二维码图片上传云存储失败: " . $client->encode_ut8($json->{message}));
        return;
    }
    
    my $url = $json->{data}{source_url};
    $url=~s/(^https?:\/\/)([^\/]+)(.*)/$1$mydomain$3/ if (defined $url and defined $mydomain);
    if(not defined $url){
        $client->warn("二维码图片上传云存储失败：未获取到有效地址");
        return;
    }
    return $url;
}

sub call{
    my $client = shift;
    my $data   = shift;
    $client->die("插件[". __PACKAGE__ ."]依赖模块 MIME::Lite，请先确认该模块已经正确安装") if not $has_mime_lite;
    $data->{max} =  10 if not defined $data->{max};
    #$data->{charset} =  "UTF-8" if not defined $data->{charset};
    my $count = 0;
    $client->on(login=>sub{$count = 0});
    $client->on(input_qrcode=>sub{
        my($client,$filename,$qrcode_data) = @_;
        if($count > $data->{max}){
            $client->fatal("等待扫描二维码超时");
            $client->stop();
            return 
        }
        
        
        $data->{subject} = "QQ帐号" . (defined $client->qq?$client->qq:'') . "扫描二维码" if not defined $data->{subject};
        #需要产生随机的云存储路径，防止好像干扰
        my $uniq_path = "mojo_webqq_" .  substr(Time::HiRes::gettimeofday(),4) .  sprintf("%.6f",rand(1)) . ".png";
        my $url = upload($client,undef,$uniq_path,$qrcode_data);
        return if not defined $url;
        $client->info("二维码已上传云存储[ $url ]");
        
        my $mime = MIME::Lite->new(
            Type    => 'multipart/mixed',
            From    => $data->{from},
            To      => $data->{to},
        );
        $mime->add("Subject"=>"=?UTF-8?B?" . MIME::Base64::encode_base64($data->{subject},"") . "?=");
        $mime->attach(
            Type     =>"text/plain; charset=UTF-8",
            Data     =>"<br/>\n<img src='$url' /><br/>\n请使用手机QQ扫描附件中的二维码 \n <a href='$url'> ".$url." </a> ",
        );
        $mime->attach(
            Path        => $filename,
            Disposition => 'attachment',
            Type        => 'image/png',
        );
        $data->{data} = $mime->as_string;
        my($is_success,$err) = $client->mail(%$data);
        if(not $is_success){
            $client->error("插件[".__PACKAGE__."]邮件发送失败: $err");
        }   
        else{
            $client->info("登录二维码已经发送到邮箱: $data->{to}");
        }
        $count++;
    });        
}
1;
