defmodule TrainLoc.Input.FTP do
    use GenServer
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
        send(self(), :timeout)
        {:ok, Timex.epoch}
    end

    @spec handle_info(:timeout, state) :: {:noreply, state}
    def handle_info(:timeout, previous_timestamp) do
        new_state = case connect_ftp() do
            {:ok, pid} -> current_timestamp = get_file_last_updated(pid)
                          Logger.debug("#{__MODULE__}: Remote file last updated: #{current_timestamp}")
                          try do
                              if current_timestamp > previous_timestamp do
                                  new_file = pid |> fetch_file()
                                  Logger.debug("#{__MODULE__}: Sending message to TrainLoc.Manager...")
                                  send(TrainLoc.Manager, {:new_file, new_file})
                              end
                          after
                              :ftp.close(pid)
                              :inets.stop(:stand_alone, pid)
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
        ftp_host = :trainloc |> Application.get_env(:input_ftp_host) |> to_charlist
        ftp_user = :trainloc |> Application.get_env(:input_ftp_user) |> to_charlist
        ftp_password = :trainloc |> Application.get_env(:input_ftp_password) |> to_charlist
        case :inets.start(:ftpc, [{:host, ftp_host}], :stand_alone) do
            {:ok, pid} -> :ftp.user(pid, ftp_user, ftp_password)
                          :ftp.lcd(pid, to_charlist(Application.app_dir(:trainloc)))
                          {:ok, pid}
            {:error, reason} -> {:error, reason}
        end
    end

    @spec fetch_file(pid) :: String.t
    def fetch_file(pid) do
        file_name = Application.get_env(:trainloc, :input_ftp_file_name)
        case :ftp.recv_bin(pid, to_charlist(file_name)) do
            {:ok, file} -> file
            {:error, _reason} -> ""
        end
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
