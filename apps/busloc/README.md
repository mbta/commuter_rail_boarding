# Busloc

Busloc pulls bus location data from TransitMaster and other GPS provider APIs. It posts it to S3 for consumption by our RTAPS vendor (currently Swiftly), as well as by the MBTA API for shuttle bus locations.

In addition, Busloc receives TSP requests from TransitMaster, and posts them to our TSP software on opstech3.

## Installation

Busloc is managed as a service using NSSM, which can be downloaded [here](http://nssm.cc/download). After ensuring that the
appropriate `nssm` file is on the `%PATH%`, services can be configured in the command line using the `nssm` command.

On initial setup, run `nssm install`, enter a name for the service in the box,
and set up the parameters of the service using the GUI that appears.
![NSSM GUI](data/NSSM_gui_1.png)

* **Path**: the full path to the executable it will be running - in this case, the `mix` file in your Elixir install (or `mix.bat` for Windows systems)
* **Startup directory**: the Busloc application directory - the directory containing Busloc's `mix.exs`
* **Arguments**: the arguments provided to the `mix` command - for Busloc, `do local.hex --force, deps.get, run --no-halt`

* The rest of the defaults should be fine, except for Environment variables, which are configured in the "Environment" tab.
You can navigate to it with the right arrow in the upper right corner of the GUI.
  ![NSSM GUI arrow](data/NSSM_gui_2.png)
* By default, log output will go to `stdout`, so if you want to view logs locally, you can tell it to direct the logs to a file using the "I/O" tab. (Logs will still be sent to Splunk regardless.)

---

Once the service is configured, click "Install service" and then the service can be started with
the command line prompt `nssm start <service-name>`.

The configuration can be changed later with the command `nssm edit <service-name>`.
After changing configurations, make sure to run `nssm restart <service-name>` so the new configuration takes effect.

## TSP configuration

If you change the server where Busloc runs, you need to update the TSP configuration.

**Change where TransitMaster sends the requests**
* On hstmkiosk, run regedit
* Browse to HKEY_LOCAL_MACHINE -> SOFTWARE -> ILG -> TransitMaster -> TMTrafficSignalPreemption
* Change the ServerIPAddr to the IP address where Busloc will run.
* In the Services dialog, stop and start the TMTSPClient.
 (If this service ever gets moved to a cluster machine, do this in Failover Cluster Manager rather than the Services dialog.)

**Add the new Busloc machine to the TSP API website's whitelist**
* On opstech3, open Start -> Administrative Tools
* Open Internet Information Services (IIS) Manager
* Browse to OPSTECH3 -> Sites -> TspApi
* Open IP Address and Domain Restrictions
* Click "Add Allow Entry..." and add the new Busloc server's IP
