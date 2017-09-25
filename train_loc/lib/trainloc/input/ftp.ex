defmodule TrainLoc.Input.FTP do
    use GenServer
    alias TrainLoc.Input.Parser
    require Logger
    require Timex

    @type state :: DateTime.t

    @check_delay 2*60*1000

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    @spec init(term) :: {:ok, state}
    def init(_) do
        Logger.debug("Starting #{__MODULE__}...")
        Process.send_after(self(), :timeout, @check_delay)
        {:ok, Timex.epoch}
    end

    @spec handle_info(:timeout, state) :: {:noreply, state}
    def handle_info(:timeout, previous_timestamp) do
        new_state = case connect_ftp() do
            {:ok, pid} -> current_timestamp = get_file_last_updated(pid)
                          Logger.debug("#{__MODULE__}: Remote file last updated: #{current_timestamp}")
                          if current_timestamp > previous_timestamp do
                              Logger.debug("#{__MODULE__}: Retrieving and parsing file...")
                              parsed_file = pid |> fetch_file() |> Parser.parse()
                              Logger.debug("#{__MODULE__}: Sending message to TrainLoc.Manager...")
                              send(TrainLoc.Manager, {:new_file, parsed_file})
                          else
                              :ftp.close(pid)
                          end
                          current_timestamp
            {:error, _} -> previous_timestamp
        end
        Process.send_after(self(), :timeout, @check_delay)
        {:noreply, new_state}
    end

    @spec handle_info(any, state) :: {:noreply, state}
    def handle_info(_msg, state) do
        Logger.debug("#{__MODULE__}: Unknown message received.")
        {:noreply, state}
    end

    @spec connect_ftp() :: {:ok, pid} | {:error, term}
    def connect_ftp() do
        :inets.start()
        ftp_host = :trainloc |> Application.get_env(:input_ftp_host) |> to_charlist
        ftp_user = :trainloc |> Application.get_env(:input_ftp_user) |> to_charlist
        ftp_password = :trainloc |> Application.get_env(:input_ftp_password) |> to_charlist
        case :inets.start(:ftpc, host: ftp_host) do
            {:ok, pid} -> :ftp.user(pid, ftp_user, ftp_password)
                          :ftp.lcd(pid, to_charlist(Application.app_dir(:trainloc)))
                          {:ok, pid}
            {:error, reason} -> {:error, reason}
        end
    end

    @spec fetch_file(pid) :: String.t
    def fetch_file(pid) do
        file_name = Application.get_env(:trainloc, :input_ftp_file_name)
        :ftp.recv(pid, to_charlist(file_name))
        Logger.debug("#{__MODULE__}: File retrieved.")
        :ftp.close(pid)
        read_file(Application.app_dir(:trainloc, [file_name]))
    end

    @spec read_file(String.t) :: String.t
    def read_file(file_path) do
        Logger.debug("#{__MODULE__}: Reading file at location: #{file_path}")
        {:ok, file} = File.open(file_path, [:read])
        IO.read(file, :all)
    end

    @spec get_file_last_updated(pid) :: DateTime.t
    def get_file_last_updated(pid) do
        {:ok, ls} = :ftp.ls(pid)
        file_name = Application.get_env(:trainloc, :input_ftp_file_name)
        {_,last_updated} = ls |> to_string |> String.split(" "<>file_name) |> Enum.at(0) |> String.split_at(-12)
        case Timex.parse(last_updated, "{Mshort} {_D} {h24}:{m}") do
            {:ok, result} -> Timex.set(result, [year: Timex.today.year])
            {:error, _} -> last_updated |> Timex.parse("{Mshort} {_D}  {YYYY}") |> elem(1)
        end
    end
end
