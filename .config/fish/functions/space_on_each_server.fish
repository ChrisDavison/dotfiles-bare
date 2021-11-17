function space_on_each_server
    run_on_cidcom_servers "df -H | grep '/\$\|media'"
end
