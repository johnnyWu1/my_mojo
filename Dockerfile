FROM perl:5.22
MAINTAINER sjdy521 <sjdy521@163.com>
RUN cpanm Mojo::Webqq \
    && cpanm Mojo::SMTP::Client \
    && cpanm Mojo::Weixin \
    && cpanm MIME::Lite
WORKDIR /root
ADD ./ /root/
# CMD ["sh","./app.sh"]
CMD ["perl","./qq.pl"]