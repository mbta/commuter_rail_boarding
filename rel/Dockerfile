# The one the elixir image was built with
FROM alpine:latest

RUN apk add --update libssl1.0 ncurses-libs \
	&& rm -rf /var/cache/apk

WORKDIR /root

# Set environment
ENV MIX_ENV=prod TERM=xterm LANG=C.UTF-8 REPLACE_OS_VARS=true

ADD . rel/commuter_rail_boarding
RUN mkdir /root/work

WORKDIR /root/work

CMD ["/root/rel/commuter_rail_boarding/bin/commuter_rail_boarding", "foreground"]
