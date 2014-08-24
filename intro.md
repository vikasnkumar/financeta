#Introduction

## History

There are many proprietary and some open source software _systems_ that help an
individual learn and perform [Technical Analysis](https://en.wikipedia.org/wiki/Technical_analysis)
on stock prices. Some of these you may have heard of - TradeStation&reg;,
MetaStock&reg; and countless brokerage houses providing their own analysis
software and tools which you can buy or get for free if you open an account and
put some money in it.

However, I just wanted to do research on stocks without having to purchase any
of these software systems, nor did I want to tie myself to a specific brokerage
account before doing any research. A majority of these software systems have
their own domain specific languages (DSLs) that are obtuse, unwieldy and just
ugly to use. Sure they have many thousands of customers who are using them and
are making money. My aim was to use [ta-lib](http://www.ta-lib.org), which is a
great open source library that works on various operating systems and has about
132 technical analysis indicators. I felt that with access to this many
indicators I could achieve what the other software systems provide without
having to pay a penny, and then when I was ready with possibly working
strategies,
I could pick and choose the appropriate brokerage account and do some trading.

Hence came about _App::financeta_. I initially tried to write this in C++ but
spending time on the GUI seemed like a waste, when I could have been spending
time on learning the indicators and trying out various strategies. So I switched
to using Perl (using the [Prima](http://metacpan.org/pod/Prima) package)  to build the GUI and using the [Perl Data
Language](http://pdl.perl.org) aka PDL to perform a variety of mathematical work.
I also looked at R before I looked at Perl, but R does not have a decent GUI
making library. Moreover, I would have to create a variety of scripts for each
combination of indicators I wanted to try out and various other idiosyncrasies
of the available libraries would need to be dealt with. This
seemed cumbersome, and I wanted to be able to automatically perform tasks like
picking indicators, adding them to the data sets and looking at the plots
in a couple of seconds without having to type anything. Some of you may wonder
why I did not use Python and NumPy to write this application, and all I can say
is that I wanted application development to be **fun** for me!

So in essence, I wanted to trade my own money (not like those hedge funds and
banks who are trading with someone else's money) with my own software, and with
the freedom of choice of picking a brokerage account with the least commission
at a later date. I also did not want to do any day trading or high frequency
trading, since I wanted to learn how to do investing like a normal person and not
worry about having a super high speed internet
connection and other facilities that cost too much and give too little.

## What will this software do ?

The aim of _App::financeta_ is to do the following in no order of importance:

* download stock quotes of any stock symbol in the open-high-low-close (OHLC) style 
from Yahoo! for any date range
* plot the data in various formats such as OHLC bars, candlesticks, volume
  plots, overlaying multiple indicators on each other to look at things like
crossovers etc.
* educate the user on the various technical analysis indicators and what they do
* write custom rules to create buy and sell signals and save as a _strategy_
* calculate profit-and-loss for each strategy on demand
* be able to provide a variety of sample strategies available to any possible
  future users, so that they do not have to reimplement the same strategy over
and over again (This is a serious problem. There maybe 1000s of people who
have the same strategy idea that they copied from the internet and implemented
in their software of choice. If a strategy is common, it will be part of the
software's sample strategies list. Sharing is good!)
* enable the user to make decisions on when to trade stocks for their personal
  investment portfolio
* use PDL which is an awesome data language tool, and
* many more that I have not thought of yet.

## What will this software not do ?

This software will not do the following, although as time progresses this list may
change:

* high frequency trading strategies
* day trading strategies
* real time trading (as of August 2014, may be added in 2015)
* any connections to a real time trading brokerage (Each brokerage has their own
  API which need not integrate well with this application. However, I may add a
message queue/socket feature where this application can be probed for signals.
But this fits in with the real time trading feature which will not be available
till 2015).

## What kind of users does the software cater to ?

Initially the software will be catered to those who know what they are trying to
do but as time progresses, the software will be able to help those who just want
to analyse stocks and make decisions on whether to trade or not. We will get
there as time progresses and I believe that great documentation and easy
workflow will be a necessary requirement for this software to progress in that
regard.

## How much does this software cost ?

This software is free to use and you can look at the license
[here](./license.html). We are however not responsible for any profits or losses
or emotional trauma caused by using this software. Use at your own risk and with
your own intelligence.


## What next ?

Get started with installing the software as given
[here](./install.html), read the [FAQ](./faq.html) and then
start learning [how](/finance/usage.html) to use it.

Hope you have fun using the software as much as I enjoyed writing it!


[Table of Contents](./index.html) [Next](./license.html)
