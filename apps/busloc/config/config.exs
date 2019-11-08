# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :busloc, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:busloc, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#
config :busloc, TmFetcher,
  url: {:system, "TRANSITMASTER_URL"},
  fetch_rate: 5000,
  stale_seconds: 1800

config :busloc, AssignedLogonFetcher,
  fetch_rate: 30_000,
  stale_seconds: 900

config :busloc, VehiclePositionsEnhanced,
  assignment_stale_seconds: 18000,
  vehicles_not_requiring_assignment: ["3000", "3001", "3002", "3003", "3004", "3005"]

config :busloc, SamsaraFetcher,
  url: {:system, "SAMSARA_URL"},
  post_body: "{\"groupId\":2155}",
  fetch_rate: 1000

config :busloc, EyerideFetcher,
  host: {:system, "EYERIDE_HOST"},
  email: {:system, "EYERIDE_EMAIL"},
  password: {:system, "EYERIDE_PASSWORD"},
  fetch_rate: 2000

config :busloc, SauconFetcher,
  url: {:system, "SAUCON_URL"},
  fetch_rate: 5000

config :busloc, Publisher, fetch_rate: 5000

# 100 MPH in (lat/long) degrees per second
config :busloc, AsyncValidator, ang_speed_threshold: 100 * 0.02 / 3600

config :busloc, Operator, cmd: Busloc.Cmd.Sqlcmd

config :busloc, TmShuttle,
  cmd: Busloc.Cmd.Sqlcmd,
  run_to_route: %{
    "9990555" => "Shuttle-Generic",
    "9990501" => "Shuttle-GenericBlue",
    "9990502" => "Shuttle-GenericGreen",
    "9990503" => "Shuttle-GenericOrange",
    "9990504" => "Shuttle-GenericRed",
    "9990505" => "Shuttle-GenericCommuterRail"
  }

config :busloc, AssignedLogon, cmd: Busloc.Cmd.Sqlcmd

# dev and test recipient of TSP. Overridden for prod.
config :busloc, Busloc.Tsp.Sender, tsp_url: "http://tspester.requestcatcher.com/test?"

config :busloc, Tsp,
  # TSP socket port 9005 for prod; 9006 (default, defined in supervisor/tsp.ex) for dev, test, and staging.
  # Needed because startup will fail if another busloc is listening on the same port on that machine,
  # or messages will get received by the wrong busloc.

  socket_port: {:system, "BUSLOC_TSP_PORT"},
  intersection_map: %{
    # event_id => {intersection_id, approach_id}
    # event_id is stored in TransitMaster TMMain.TRAFFIC_SIGNAL.
    # intersection_id is the intersection alias in the TSP processing software/database on opstech3.
    # approach_id 1=N, 2=E, 3=S, 4=W
    # Washington/Melnea Cass
    1 => {"2089", :north},
    # Washington/Melnea Cass
    2 => {"2089", :south},
    # Washington/Massachusetts
    3 => {"98", :south},
    # Washington/E.Berkeley
    5 => {"365", :north},
    # Washington/E.Berkeley
    6 => {"365", :south},
    # Washington/Herald
    7 => {"1127", :north},
    # Washington/Herald
    8 => {"1127", :south},
    # Marginal Rd. & Washington St.
    10 => {"1332", :south},
    # Washington/WNewton
    11 => {"383", :south},
    # Washington/Msgr Reynolds/Dedham
    13 => {"1099", :north},
    # Washington/Msgr Reynolds/Dedham
    14 => {"1099", :south},
    # Oak St./Oak West St and Washington St.
    15 => {"112", :north},
    # Oak St./Oak West St and Washington St.
    16 => {"112", :south},
    # Marginal Rd. & Washington St.
    17 => {"1332", :north},
    # Washington/Brock/Lake
    18 => {"726", :east},
    # Washington/Brock/Lake
    19 => {"726", :west},
    # Washington/Foster
    20 => {"1475", :east},
    # Washington/Foster
    21 => {"1475", :west},
    # Cambridge/Gordon
    22 => {"449", :west},
    # Commonwealth/Babcock
    23 => {"1263", :east},
    # Commonwealth/Babcock
    24 => {"1263", :west},
    # Mass Ave/Brookline St
    25 => {"CA1", :north},
    # Mass Ave/Brookline St
    26 => {"CA1", :south},
    # Washington/Waltham
    27 => {"873", :south},
    # Washington/Waltham
    28 => {"873", :north},
    # Washington/Union Park
    29 => {"872", :south},
    # Washington/Union Park
    30 => {"872", :north},
    # Washington/Brookline St
    31 => {"650", :south},
    # Washington/Brookline St
    32 => {"650", :north},
    # Washington/Concord St
    33 => {"905", :south},
    # Washington/Concord St
    34 => {"905", :north},
    # null - Frankfort St/Coughlin Bypass
    35 => {"99999", :north},
    # null - Coughlin Bypass/Chelsea St
    36 => {"99999", :west},
    # null - Chelsea St/Curtis St
    37 => {"99999", :north},
    # null - Chelsea St Bridge
    38 => {"99999", :north},
    # Mass Ave/Jason St (Arl)
    39 => {"AR1", :east},
    # Mass Ave/Jason St (Arl)
    40 => {"AR1", :west},
    # Mass Ave/Franklin St (Arl)
    41 => {"AR2", :east},
    # Mass Ave/Bates Rd (Arl)
    42 => {"AR3", :east},
    # Mass Ave/Bates Rd (Arl)
    43 => {"AR3", :west},
    # Mass Ave/Lake St (Arl)
    44 => {"AR4", :east},
    # Mass Ave/Lake St (Arl)
    45 => {"AR4", :west},
    # Mt Aub/Homer (Camb)
    46 => {"CA2", :east},
    # Mt Aub/Homer (Camb)
    47 => {"CA2", :west},
    # Mt Aub/Aberdeen (Camb)
    48 => {"CA3", :east},
    # Mt Aub/Aberdeen (Camb)
    49 => {"CA3", :west}
  }

config :busloc,
  start?: true,
  uploaders: [
    %{
      states: [:transitmaster_state, :eyeride_state, :saucon_state],
      uploader: Busloc.Uploader.File,
      encoder: Busloc.Encoder.NextbusXml,
      filename: "nextbus.xml"
    },
    %{
      states: [:transitmaster_state, :eyeride_state, :saucon_state],
      uploader: Busloc.Uploader.File,
      encoder: Busloc.Encoder.VehiclePositionsEnhanced,
      filename: "VehiclePositions_enhanced.json"
    }
  ],
  time_zone: "America/New_York"

config :busloc, Saucon,
  route_ids: %{
    88_001_007 => "Shuttle005",
    88_001_008 => "Shuttle002"
  }

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"
