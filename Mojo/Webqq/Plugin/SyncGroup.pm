package Mojo::Webqq::Plugin::SyncGroup;
our $PRIORITY = 4;
use List::Util qw(first);
use JSON;
use Encode;
use URI::Escape;

sub getMojoType{
	return {'Mojo::Webqq'=>'QQ','Mojo::Weixin'=>'WX'}->{ref $_[0]};
}
sub retrieve_db {
    my ($client,$db,$file) = @_;
    my $new_db = {};
    my $fd;
    for(keys $db){
    	delete $db->{$_};
    }
    if(open $fd,"<",$file){
    	@linelist=<$fd>;
        $filedb=decode_json( join '',@linelist);
        for(keys $filedb){
        	$db->{$_} = $filedb->{$_};
        }
    }else{
    	$client->warn("无法加载知识库数据文件 $file : $!");
        return;
    }
#    while(<$fd>){
#        s/\r?\n$//;
#        next if /^\\\\.*/;
#        my($space,$target,$mode,$active) = split /\s*(?<!\\)#\s*/,$_,4;
#        next if not $space && $target && $mode && $active;
#        $db->{$space} ={'target' => $target, 'mode'=> $mode, 'active'=> $active};
#    }
    close $fd;
    $db = $new_db;
}
sub store_db {
    my($client,$db,$file) = @_;
    my $fd;
    if(!open $fd,">",$file){
        $client->warn("无法加载知识库数据文件 $file : $!");
        return;
    }
    print $fd encode_json $db;
    close $fd;
}

sub call{
    my $client = shift;
    my $data = shift;
    my ($file_size, $file_mtime);
    my $file = $data->{file} || './SyncGroup.txt';
    my $wx_url = $data->{wx_url}||'http://127.0.0.1:3000/openwx/';
    my $qq_url = $data->{qq_url}||'http://127.0.0.1:5000/openqq/';
#    my $learn_command = defined $data->{learn_command}?quotemeta($data->{learn_command}):'learn|学习';
#    my $delete_command = defined $data->{delete_command}?quotemeta($data->{delete_command}):'delete|del|删除';
    my $base = {};
    if(-e $file){
        ($file_size, $file_mtime) = (stat $file)[7, 9];
        retrieve_db($client,$base,$file);        
    }
    $client->interval($data->{check_time} || 10,sub{
        return if not -e $file;
        return if not defined $file_size; 
        return if not defined $file_mtime; 
        my ($size, $mtime) = (stat $file)[7, 9]; 
        if($size != $file_size or $mtime != $file_mtime){
            $file_size = $size;
            $file_mtime = $mtime;
            retrieve_db($client,$base,$file);        
        }
    });
    
    my $client_type = getMojoType($client);
    
    my $callback = sub{
    	
    	my($client,$msg) = @_;
#    	$msg->dump();
    	return if not $msg->allow_plugin;
#        return if $msg->type !~ /^message|group_message|dicsuss_message|sess_message$/;
        my ($config);
        if($msg->type eq 'group_message'){
        	$config = $base->{$client_type.':'.$msg->type.':'.$msg->group->gnumber};
        	print $client_type.':'.$msg->type.':'.$msg->group->gnumber . "\n";
        }elsif($msg->type eq 'discuss_message'){
        	$config = $base->{$client_type.':'.$msg->type.':'.decode("utf8",$msg->discuss->displayname) };
        	print $client_type.':'.$msg->type.':'.decode("utf8",$msg->discuss->displayname)  . "\n";
        }else{
        	print $msg->type,'不匹配！',"\n";
        	return;
        }
        return if not defined $config;
        return if $config->{active} eq 'off';
        return if $config->{mode} eq 0 and $msg->content !~ /@全体成员/;
        my $reply_context = $msg->sender->nick.": ".$msg->content;
        my @query_string = (
            $config->{target}->{key}       =>  $config->{target}->{value} ,
            "content"    =>  decode("utf8",$reply_context),
        );
		print "@query_string","\n";
		my $url = {'QQ'=>$qq_url,'WX'=>$wx_url}->{$config->{target}->{plat}};
		
		$url .= $config->{target}->{method};
		
		if(not defined $url){
			print "URL错误！";
			return;
		}
		

        $client->http_get($url,{json=>1},form=>{@query_string},sub{
            my $json = shift;
            if( defined $json){
            	print '转发成功：', encode_json $json;
            }else{
            	print '转发失败：';
            }
            print "\n";
            
        });
        
    	
    };
    
    $client->on(receive_message=>$callback);
}

#$base = {};
#
#retrieve_db({},$base,'./SyncGroup.txt');
#print encode_json $base->{'QQ:discuss_message:2922990378'};


1;
