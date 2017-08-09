Application.ensure_all_started(:httpoison)
Application.ensure_all_started(:tzdata)
{:ok, _pid} = TripCache.start_link()
{:ok, _pid} = RouteCache.start_link()
{:ok, _pid} = ScheduleCache.start_link()

ExUnit.start()
