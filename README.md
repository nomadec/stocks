# Stocks

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4100`](http://localhost:4100) from your browser.

# Features

- can be started as a server to set up cron jobs for downloading market data as per defined time interval
- has a web interface to browse downloaded files directory
- compresses data after a download to reduce space usage
- allows to manually write data, with automated partitioning into files and compression
- allows to read data for a given time range
