FROM perl:5.22
MAINTAINER sjdy521 <sjdy521@163.com>
RUN cpanm Mojo::Webqq \
    && cpanm JSON \
    && cpanm Mojo::SMTP::Client \
    && cpanm Mojo::Weixin \
    && cpanm MIME::Lite \
    && cpanm URI::Escape
WORKDIR /root
ADD ./ /root/
RUN ls -a
# CMD ["sh","app.sh"]
CMD ["perl","./qq.pl","&", "perl","./weixin.pl", "&"]
