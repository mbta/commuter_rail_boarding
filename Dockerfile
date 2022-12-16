FROM hexpm/elixir:1.14.2-erlang-25.2-alpine-3.17.0 AS builder

WORKDIR /root

# Install Hex+Rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# Install git
RUN apk --update add git make

ENV MIX_ENV=prod

ADD . .

RUN elixir --erl "-smp enable" /usr/local/bin/mix do deps.get --only prod, compile, release

FROM alpine:3.17.0

RUN apk add --no-cache libssl1.1 ncurses-libs bash libstdc++ libgcc

# Set environment
ENV MIX_ENV=prod TERM=xterm LANG=C.UTF-8 REPLACE_OS_VARS=true

COPY --from=builder /root/_build/prod/rel/ /root/rel

RUN /root/rel/commuter_rail_boarding/bin/commuter_rail_boarding eval ":crypto.supports()"

CMD ["/root/rel/commuter_rail_boarding/bin/commuter_rail_boarding", "foreground"]