FROM elixir:alpine

WORKDIR /root

# Install Hex+Rebar
RUN mix local.hex --force && \
  mix local.rebar --force

ENV MIX_ENV=prod

ADD . .

WORKDIR /root

RUN elixir --erl "-smp enable" /usr/local/bin/mix do deps.get --only prod, compile, release --verbose
