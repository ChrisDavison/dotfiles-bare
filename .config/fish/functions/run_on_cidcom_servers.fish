function run_on_cidcom_servers
    set -l command $argv
    for server in iona bute jura skye cava uist
        echo $server
        ssh $server $command
        echo (string repeat -n 40 "-")
    end
end
