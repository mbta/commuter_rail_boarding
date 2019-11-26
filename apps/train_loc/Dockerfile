FROM elixir:1.6-alpine AS builder

WORKDIR /

# Install Hex+Rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# Install git
RUN apk --update add git make

ENV MIX_ENV=prod

ADD . .

RUN elixir --erl "-smp enable" /usr/local/bin/mix do deps.get --only prod, compile, release --verbose

FROM alpine:3.9

RUN apk add --update bash \
	&& rm -rf /var/cache/apk

# Set environment
ENV MIX_ENV=prod TERM=xterm LANG=C.UTF-8 REPLACE_OS_VARS=true

COPY --from=builder /_build/prod/rel/ /rel

# Ensure SSL support is enabled
RUN /rel/train_loc/bin/train_loc command crypto supports

CMD ["/rel/train_loc/bin/train_loc", "foreground"]
