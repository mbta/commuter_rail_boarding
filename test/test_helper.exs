Application.ensure_all_started(:httpoison)
{:ok, _pid} = TripCache.start_link()
{:ok, _pid} = RouteCache.start_link()

ExUnit.start()
