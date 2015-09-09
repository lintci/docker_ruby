FROM ruby:2.2.3

###### Create user
ENV user=app \
    home=/home/app/ \
    group=app \
    PATH=/home/app/bin:$PATH \
    PORT=8080

RUN mkdir -p $home \
 && groupadd -r $group -g 777 \
 && useradd -u 666 -r -g $group -d $home -s /sbin/nologin -c "Docker image user" $user \
 && chown -R $user:$group $home
WORKDIR $home

###### App Setup
# gems may be cacheable, so do minimal work first to
# install gems to minimize cache bust.
ONBUILD COPY Gemfile $home
ONBUILD COPY Gemfile.lock $home
ONBUILD RUN bundle install --path=vendor/bundle --jobs=4 --retry=3 --deployment --binstubs
ONBUILD COPY . $home
ONBUILD RUN chown -R $user:$group $home
ONBUILD USER $user

EXPOSE 8080
CMD foreman start web
