#Frequently Asked Questions

## General

1. Why is the application name _App::financeta_ ?

    The commandline name is `financeta` but the Perl package that it invokes is
called `App::financeta`. The _ta_ in _financeta_ stands for technical analysis.

1. Why did you select Perl to write the language ?

    Perl is the only scripting language I know apart from R. Python's
whitespace restrictions are an abomination, hence I do not use it. Once you know Perl, all
other scripting languages seem like toys (I am looking at you Ruby!).

1. When will real time trading be available ?

    In trying to be realistic, we can estimate early to mid 2015.

1. Does this software work only for US stocks ?

    We currently use the Perl package
[Finance::QuoteHist](http://www.metacpan.org/pod/Finance::QuoteHist) for handling stock downloads. As long
as it supports your stock symbol, we support it. Yahoo! is one of
the main data sources being used in `Finance::QuoteHist`, but others are also
available. If you need your custom exchange data or country's stock symbols
added, please contact the `Finance::QuoteHist` developers and have them add it
so that we can benefit downstream from their changes.

1. Do I need to know Perl or PDL to write my strategies ?

    As of today, yes. We are trying to eliminate that by developing a simple
syntax for writing the strategies. We are also trying to avoid developing
something ugly like the existing domain specific languages (DSL) provided by
proprietary software. So far PDL is pretty awesome.

## Operating System

1. Why isn't Microsoft Windows&reg; supported yet ?

    Microsoft Windows&reg; will be supported as soon as we have time to test on it and figure out
the easiest way to install all the dependencies. Currently our focus is to make
our software <u>just work</u>. If that means, making it <u>just work</u> on some systems
first, then that is a priority.

1. Will ready-to-install packages be provided for various operating systems ?

    As of today we do not have this capability yet, but once all the documentation
is ready we shall try to create ready-to-install complete packages for all
supported operating systems.

## User Interface

1. Why does the UI look like the way it does ?

    We use [Prima](http://www.metacpan.org/pod/Prima) which is a very easy to
use GUI toolkit. `Prima` is cross-platform and works well for our needs.

1. The UI looks ugly, will you make it look shiny ?

    Our aim is to have a UI that uses less CPU power, runs fast and doesn't get
in the way of making money. If you care about looks, go look at yourself in the mirror.

1. Why are you using Gnuplot for plotting ?

    Two reasons:

    1. Gnuplot is already an awesome plotting engine and the package
       `PDL::Graphics::Gnuplot` is well supported and works really well out of the
box.
    2. We will eventually try to help the developers of the package
       `PDL::Graphics::Prima` add features required by the software, so that we can embed the plots in the UI itself
instead of having it as a separate application running on the side. However,
this will take a while since a lot of functionality, already available in
Gnuplot, will have to be added.

## Technical Analysis

1. Why do some indicators not work ?

    Please let us know what you're trying to do so that we can see if the
problem is the indicator or the data.


[Back to Home](./index.html) [Next](./usage.html)
