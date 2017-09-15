defmodule TrainLoc.Input.FTP do
    use GenServer
    alias TrainLoc.Input.Parser
    require Logger
    require Timex

    @file_location "AVLData.txt"

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end


    def init(_) do
        Process.send_after(self(), :timeout, 1000)
        {:ok, Timex.epoch}
    end

    def handle_info(:timeout, previous_timestamp) do
        {:ok, pid} = connect_ftp()
        current_timestamp = get_file_last_updated(pid)
        Logger.debug("Remote file last updated: #{current_timestamp}")
        if current_timestamp > previous_timestamp do
            Logger.debug("Retrieving and parsing file...")
            parsed_file = pid |> fetch_file() |> Parser.parse()
            Logger.debug("Sending message to TrainLoc.Manager")
            send(TrainLoc.Manager, {:new_file, parsed_file})
        end
        Process.send_after(self(), :timeout, 1000)
        {:noreply, current_timestamp}
    end

    def handle_info(_msg, state) do
        {:norelpy, state}
    end

    def connect_ftp() do
        :inets.start()
        ftp_host = Application.get_env(:trainloc, :input_ftp_host)
        ftp_user = Application.get_env(:trainloc, :input_ftp_user)
        ftp_password = Application.get_env(:trainloc, :input_ftp_password)
        Logger.debug("Connecting to ftp host: #{ftp_host}")
        {:ok, pid} = :inets.start(:ftpc, host: ftp_host)
        :ftp.user(pid, ftp_user, ftp_password)
        Logger.debug("Username/password accepted.")
        :ftp.lcd(pid, to_charlist(Application.app_dir(:trainloc)))
        {:ok, pid}
    end

    def fetch_file(pid) do
        :ftp.recv(pid, to_charlist(@file_location))
        Logger.debug("File retrieved.")
        :ftp.close(pid)
        read_file(Application.app_dir(:trainloc, [@file_location]))
    end

    def read_file(file_path) do
        Logger.debug("Reading file at location: #{file_path}")
        {:ok, file} = File.open(file_path, [:read])
        IO.read(file, :all)
    end

    def get_file_last_updated(pid) do
        {:ok, ls} = :ftp.ls(pid)
        {_,last_updated} = ls |> to_string |> String.split(" "<>@file_location) |> Enum.at(0) |> String.split_at(-12)
        case Timex.parse(last_updated, "{Mshort} {_D} {h24}:{m}") do
            {:ok, result} -> Timex.set(result, [year: Timex.today.year])
            {:error, _} -> last_updated |> Timex.parse("{Mshort} {_D}  {YYYY}") |> elem(1)
        end
    end

    def child_spec(_) do
        %{
            id: TrainLoc.Input.FTP,
            restart: :permanent,
            shutdown: 5000,
            start: {TrainLoc.Input.FTP, :start, []},
            type: :worker
        }
    end
end
