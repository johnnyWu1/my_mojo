FROM perl:5.22
MAINTAINER sjdy521 <sjdy521@163.com>
RUN cpanm Mojo::Webqq \
    && cpanm Mojo::SMTP::Client \
    && cpanm Mojo::Weixin 
WORKDIR /root
COPY Mojo-Webqq.pl Mojo-Webqq.pl
CMD ["./app.sh"]