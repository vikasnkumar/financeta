# Using _App::financeta_

## Starting the Application

We hope that you have successfully installed the application as outlined
[here](./install.html). If you have installed it from CPAN, you need to start
the application like this:

    $ financeta

If you have installed the software from Github, you are running it in developer
mode and you should be running it like this:

    $ perl -Mblib ./bin/financeta

Please refer to the [install](./install.html) page for more details on
installing the application from Github and CPAN.

On Linux and other Unix variants, you need X-server running to view the GUI. On
Mac OS X, if you have installed Gnuplot, you will already have X-server
installed and the application should automatically start it up.

### Commandline options

The following commandline options are supported:

* `--debug`
  This turns on debugging on the console and can be used to send us any logs of
error messages or warnings if the application is not doing what you think it
should be doing.

## Selecting a Security

When we refer to the word _security_, we mean a company stock. However, as time
progresses and if data is freely available, we will be adding options and
futures to the mix as well. Hence _security_ is a term that groups all of these
under one.

Using the menu option _'Security'_ followed by _'New'_ as shown in the image below,
start the _'Security Wizard'_ dialog. Enter a <span
style="color:red;">**valid**</span> stock symbol such as _'MSFT'_ in
the _'Enter Security Symbol'_ text box, select the start and end dates for which
you want data for (by default this is set to one year back from today) and hit
the _'OK'_ button.

You will see a new tab opens with the name of the symbol you entered, which is
_'MSFT'_ in this case and all the stock data listed in tabular form. You will
also see a plot drawn in Gnuplot in a separate window that is started up and
controlled by the application.

The data downloaded is saved in `$TMPDIR` on Linux or BSD or Mac OSX and `$TEMP` or `$TMP` on Windows. If `$TMPDIR` is not
set, then `/tmp/` is used. The data is stored in a CSV file and if the same date
range is used by the user, the data is downloaded only once. If the user wants
to force the download of the data, they can select the _'Force download'_ option
in the _'Security Wizard'_.

The steps are outlined as follows:

- Select _'New'_ from the _'Security'_ menu option
![Select New from the 'Security' menu option](./images/financeta_sec_new.png "Select 'New' from the 'Security' menu option")
- Enter a <span style="color:red;">**valid**</span> stock symbol and date range in the _'Security Wizard'_ such as _'MSFT'_
![Select a Stock Symbol in the Security Wizard](./images/financeta_sec_wizard.png "Enter a valid stock symbol in the 'Security Wizard'")
- View the retrieved data in a tab titled _'MSFT'_ or the symbol you have
  chosen
![View the data retrieved in a tab](./images/financeta_tab_data.png "View the data retrieved in a tab for that symbol")
- View the open-high-low-close (OHLC) bar plot in Gnuplot that has been started
  by _App::financeta_
![OHLC Gnuplot for data](./images/financeta_plot_ohlc.png "View the OHLC default plot in the adjacent Gnuplot window")
- More securities can be added in the same way by following the above steps.


## Selecting a Plot

Various types of plots are provided to the user as part of this application.
Using the _'Plot'_ menu option, the user can select any type of plot and the
Gnuplot window will automatically display that plot type.

![Plot Menu](./images/financeta_plot_menu.png "Plot Menu options")

The current supported plot types are as follows:

- _OHLC_: This is the default plot type. It displays the Open-High-Low-Close data
  with the price being on the Y-axis and the date on the X-axis. This is a
standard finance plot used in the industry.
![OHLC Plot](./images/financeta_plot_ohlc.png "The OHLC plot")
- _OHLC & Volume_: This plot type shows two plots in one window. The top plot is
  the OHLC plot as described above, and the bottom plot shows Volume in units of
1 million stocks on the Y-axis. There are some Volume based indicators where this kind of
plot can be very useful.
![OHLC & Volume Plot](./images/financeta_plot_ohlcv.png "The OHLC & Volume plot")
- _Close Price_: This plot type plots the Close price of the stock as a line
  graph with the Y-axis being the price and the X-axis being the date. This is
useful when you want to use indicators that prefer using a single price stream such as
Moving Average indicators.
![Close Price Plot](./images/financeta_plot_close.png "The Close Price plot")
- _Close Price & Volume_: This plot type is similar to the Close price plot type
  above and also has a sub-plot of Volume in units of 1 million stocks on the
Y-axis.
![Close Price & Volume Plot](./images/financeta_plot_closev.png "The Close Price & Volume plot")
- _Candlesticks_: Some researchers like to use Candlestick charts to understand
  how stock trades move, and for them we have the candlestick plot feature.
There are about 61 candlestick indicators that _ta-lib_ supports and hence this
plot is essential to _App::financeta_.
![Candlestick Plot](./images/financeta_plot_candle.png "The Candlestick plot")
- _Candlesticks & Volume_: This plot is useful if the user wants to do analysis
  with both Candlesticks and Volume indicators. The Volume is plotted in units
of 1 million stocks as a sub-plot.
![Candlestick & Volume Plot](./images/financeta_plot_candlev.png "The Candlestick & Volume plot")


[Back to Home](./index.html) [Next](./indicators.html)
